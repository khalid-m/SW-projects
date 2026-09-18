;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1995 Tore Risch, Martin Skold, Staffan Flodin, EDSLAB
;;; $RCSfile: proc.lsp,v $
;;; $Revision: 1.35 $ $Date: 2012/09/06 20:52:50 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Stored procedure compiler
;;; =============================================================
;;; $Log: proc.lsp,v $
;;; Revision 1.35  2012/09/06 20:52:50  torer
;;; *enclfn* misspelled
;;;
;;; Revision 1.34  2012/03/18 16:41:47  torer
;;; Could not bind call to bag valued procedure to bag variable
;;;
;;; Revision 1.33  2012/01/14 14:30:03  torer
;;; Nicer error messages
;;;
;;; Revision 1.32  2011/12/22 12:55:16  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.31  2010/05/26 15:29:31  torer
;;; Documentation of global variables
;;;
;;; Revision 1.30  2008/11/11 07:46:12  torer
;;; Stricter checking of conformance with result types in function definitions
;;; Can be turned off with
;;;    (setq _strict-resulttypes_ nil)
;;;
;;; Revision 1.29  2008/09/01 18:45:17  torer
;;; result may emit result tuples from select statement
;;;
;;; Revision 1.28  2008/08/15 11:47:42  torer
;;; Transactional interface variables
;;;
;;; Revision 1.27  2008/04/03 15:00:49  torer
;;; reopt.lsp depatched
;;;
;;; Revision 1.26  2007/10/19 14:31:49  torer
;;; PROCCALL in C
;;;
;;; Revision 1.25  2006/12/16 16:23:57  torer
;;; Verifying that T and NIL not used as local variables
;;;
;;; =============================================================

(defglobal _persistent-interface-variables_ nil 
  "Global interface variables are NOT transactional if true")

(defvar *contdata* 'unknown "Data passed to EXPAND-RETURN from PROC-BLOCK")

(defvar __contfn (function global-contfn) "Global result builder")

(defvar *result*)
(document *result* "Result tuple list for GLOBAL-CONTFN")

(defvar *enclfn* nil 
  "Set to the current AmosQL while compiling procedure bodies")

(defvar *within-proc* nil "True during compilation of procedure body")

(defvar *local-scoping* nil 
  "t during compilation of body => global interface variables disallowed")

;;; Global continuation function (used outside stored procedures)

(defun subst-t (x)
  "Change variable T to T. to avoid clash with Lisp's T"
  (subst 't. 't x))

(defmacro define-proc (fnname argl resl &rest body)
  "Procedure definition macro"
  (list 'compile-procedure (kwote fnname) (kwote (subst-t argl))
	(kwote  (subst-t resl)) (kwote (subst-t body))))

(defun global-contfn (x)
  (cond (*within-lisp* 
	 (cond ((not (boundp '*result*)) ; outside block
		(list x))
	       ((stop-after?) (throw 'prog-return *result*))
	       (t (setq *result* (nconc1 *result* x)))))
	(*within-proc* 
	 (error "System error: global __contfn called within procedure"))
	(t (print-tuple x)(terpri))))

(defun compile-procedure (fnname argl resl body &optional recompileflg)
  "AMOS II stored procedure compiler"
  (resetgenvar
   (let* ((*local-scoping* t)		; no interface variables allowed
          (argtypes			; check argument declarations
	   (substdeclarations argl))
          (br (remove-bagged-result fnname resl))
	  (restypes			; check result declarations
	   (remove-boolean-result 
	    (substdeclarations (or br resl))))
	  (nameargtype (mapcar (function dcl-type) argtypes))
	  (namerestype (mapcar (function dcl-type) restypes))
	  (bpat			;;; build binding pattern for foreign function
	   (nconc 
	    (buildl argtypes (quote -))
	    (buildl restypes (quote +))))
	  (rname			; generate exact resolvent for function
	   (make-resolventname fnname nameargtype namerestype))
	  (lfn	;;; generate name of Lisp function implementing procedure
	   (packlist (cons rname bpat)))
	  (argvars			; generate list of argument variables
	   (getvars argtypes))
	  (resvars			; generate list of result variables
	   (getvars  restypes))
	  (allvars (append argvars resvars))
	  (*contdata*		;;; data to construct continuation function
	   (cons argvars (length resvars)))
	  ;; update global list of variable declarations
	  ;; so that type checker works properly on nested OSQL statements
	  (*vardeclarations* 
	   (append argtypes restypes *vardeclarations*))
	  ;; nested select expressions work differently within proc
	  (*within-proc* t)
          (*compiled-fn* *compiled-fn*)
	  fno)
     ;; declare binding pattern of foreign fn
     (bind-foreign rname bpat lfn) 
     ;; Define procedure as foreign function with Lisp function 'lfn'
     ;; as implementation:
     (setq fno
	   (if recompileflg 
	       (createsimplefunction (getfunctionnamed rname) 
				     argtypes restypes body nil nil)
             (createfunction fnname argtypes restypes body nil nil)
             ))
     (rescope-compiled-fn fno)
     ;; compile (macro-expand) generated procedure body
     (setq body (expand-args body allvars fno))
     ;; Finally, define 'lfn:
     (/defc lfn (list* 'lambda
		       (cons '__obj allvars)
		       (nconc (mapcar (f/l(v)(list 'setq v nil)) 
				      resvars) ; init result vars to nil
			      body)))
     (if br (set-bagged fno t))
     fno)))

(defmacro osql-return (&rest x) 
  (expand-return x))

(defun unnest-bag (l)
  "Generated code to extract catesian product of data 
   from all closed bags in L"
  (mapcar (f/l (x)(if (and (or (symbolp x)
                               (osql-constantp x))
			   (bag-type? (type-of-expression x)))
		      (list 'in x) x)) l))

(defun expand-return (x)
  "Compile AmosQL statement: result x;"
  ;; Uses *CONTDATA* which is bound by COMPILE-PROCEDURE
  (let ((ub (unnest-bag x)))
    (cond ((eq *contdata* 'unknown)	; called outside procedure
	   ;; Here we must use the global continuation function __CONTFN
	   (expand-result-query  ub '__contfn))
	  ((every (f/l (y)(or (osql-variablep y)
			      (osql-constantp y))) 
		  ub)
	   (let* ((r (cdr (compile-substosqlvars x)))
                  (test (subset r (f/l (z)(and z (symbolp z))))))
	     (if test `(and ,@test (osql-result ,@(car *contdata*) ,@r))
	       `(osql-result ,@(car *contdata*) ,@r))))
	  (t (expand-result-query 
	      ub
	      `(function;; build continuation function from *contdata*
		(lambda (res) (osql-result 
			       ,@(car *contdata*) 
			       ,@(element-args 'res 
					       (cdr *contdata*) nil)))))))))

(defun expand-result-query (x contfn)
  (add-empty-result 
   (cond ((and (null (cdr x))
	       (listp (car x))
	       (eq (caar x) 'select)) 
	  (compile-procselect contfn (cdar x)))
	 (t (osql-mapselectexpand x nil nil nil contfn 
				  (if (boundp '*enclfn*) *enclfn* nil)
                                  (and *compiled-fn* _strict-restypes_ 
				       (getrestype *compiled-fn*)))))))

(defun add-empty-result (x)
  (cond ((or *within-proc* *within-lisp*) x)
        (t `(progn , x 'no-result))))

;;;
;;; Procedure body compiler and Lisp macro expander:
;;;

(defun expand-args (argl fv enclfn)
  (mapcar (f/l (f)(expand-form f fv enclfn)) argl))

;(putprop 'DELETEDOBJECTP 'specialvar t)

(defun expand-form (bdy fv enclfn);;enclfn is the osql funcion being created
  "Typecheck and macroexpand the body BDY of a procedure with free variable FV"
  (let ((*enclfn* enclfn))
    (if (atom bdy)
	(cond ((not (litatom bdy))
	       bdy)
	      ((null bdy) bdy)
	      ((or (special-variable-p bdy)(global-variable-p bdy)) bdy)
	      ((kwoted bdy) bdy)
	      ((memq bdy fv) bdy)
	      (t (amos-error "Undefined variable: " bdy)))
      (let ((thecar (car bdy)))
	(cond ((and (lambdap thecar)
		    (eq (caadr thecar) '*vardeclarations*))
					; OSQL-LET declaration
	       (check-newdcl bdy fv enclfn))
	      ((eq thecar 'cond)
	       (cons 'cond (mapcar (f/l(x)(expand-args x fv enclfn)) 
				   (cdr bdy))))
	      ((eq thecar 'let)
	       (list* 'let 
		      (mapcar 
                       (f/l (b) (if (listp b)
				    (cons (car b)(expand-args (cdr b) 
							      fv enclfn)) 
				  b))
		       (cadr bdy))
		      (expand-args (cddr bdy) (union (allcars (cadr bdy)) fv)
				   enclfn)))
	      ((eq thecar 'function)
	       (list 'function (expand-lambda (cadr bdy) fv enclfn)))
	      ((eq thecar 'quote) bdy)
	      ((and (listp thecar) (eq (car thecar) 'lambda))
	       (cons 
		(expand-lambda thecar fv enclfn) 
		(expand-args (cdr bdy) fv enclfn)))
	      (t (let ((r (macroexpand bdy)))
		   (if (eq r bdy) 
		       (cons (car bdy) (expand-args (cdr bdy) fv enclfn))
		     (expand-form r fv enclfn)))))))))

(defun expand-lambda (x fv enclfn)
  (cond ((atom x) x)
	((eq (car x) 'lambda)
	 (list* 'lambda (cadr x)
		(expand-args
		 (cddr x)
		 (union (cadr x) fv)
		 enclfn)))
	(t x)))

(defun check-newdcl (bdy fv enclfn)
  (let ((*vardeclarations*
	 (append (pick-elem '(1 1 1) bdy) *vardeclarations*))
	(lbd (cdar bdy)))
    (cons (expand-lambda (list* 'lambda (cdar lbd)(cdr lbd))
			 fv enclfn)
	  (expand-args (cddr bdy) fv enclfn))))

(defmacro proc-block (&rest args)
  (let (res (*local-scoping* t))
    (if (and *within-lisp* 
	     (not *within-proc*))
	(setq res `(prog-let (*result* (*stopafter* *stopafter*)) 
			     ,@ args *result*))
      (setq res (prognify args)))
      
    (if (not *within-proc*)
	(let ((*within-proc* t))
	  (setq res (expand-form res nil nil))))
    res))

(defun parseselect (args keywords)
  "Pick up keywords of parsed select statement"
  (let* ((al args)
         (distinct (cond ((eq (car al) 'distinct) (pop al) t)))
         (resl (if (listp (car al)) (pop al)))
	 (into (cond ((eq (car al) 'into)
		      (pop al)
		      (pop al))))
	 (quant (cond ((eq (car al) 'foreach)
		       (pop al)
		       (pop al))))
	 (pred (cond ((eq (car al) 'where)
		      (pop al)
		      (pop al)))))
    (if al
	(amos-error "Syntax error at "
		    (car al)
		    " in "
		    (cons 'osql-select args)))
    (list distinct resl into quant pred)))

(defun compile-substosqlvars (s &optional dontkwotesymbols)
  (cond ((osql-constantp  s)
	 (if (aggregatep s)
	     (cons
	      (car s)
	      (mapcar
	       (f/l (x) (compile-substosqlvars x dontkwotesymbols)) 
	       (aggregate-data s)))
	   (kwote s)))
	((osql-interfacevarp s)
	 (osql-interfacevar s))
	((atom s)
	 (if dontkwotesymbols s (kwote s)))
	(t (cons 'list
		 (mapcar
		  (f/l (x) (compile-substosqlvars x dontkwotesymbols))
		  s)))))

(defun aggregatep (x)
  (and (listp x)
       (or (eq (car x) 'aggr_bag)
	   (eq (car x) _tupletag_))))

(defun aggregate-data (x)(cdr x))

(defmacro create-type (type &optional super props)
  (list* 'progn
	 (list 'createusertype
	       (list 'quote type)
	       (list 'quote super))
	 (compileproperties type props))) 


(defun compileproperties (tp props)
  (mapcar (f/l (prop)
	       (let ((ad (if (memq (car prop)
				   '(key nonkey))
			     (list tp (pop prop))
			   (list tp))))
		 (list 'create-function
		       (car prop)
		       (list ad)
		       (cdr prop))))
	  props))
