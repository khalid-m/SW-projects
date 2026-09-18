;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997 Tore Risch, Vanja Josifovski, Magnus Werner, EDSLAB
;;; $RCSfile: function.lsp,v $
;;; $Revision: 1.123 $ $Date: 2013/05/31 09:18:24 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Function definition
;;; =============================================================
;;; $Log: function.lsp,v $
;;; Revision 1.123  2013/05/31 09:18:24  torer
;;; Introduced accessfilter predicates
;;;
;;; Revision 1.122  2013/05/14 15:11:02  minzh812
;;; print expression
;;;
;;; Revision 1.121  2013/03/25 20:57:56  torer
;;; Bug in 'key' declaration on stored functions
;;;
;;; Revision 1.120  2013/02/07 12:45:43  torer
;;; Place holder for the absorber manager added
;;;
;;; Revision 1.119  2013/02/07 10:24:07  torer
;;; *** empty log message ***
;;;
;;; Revision 1.118  2012/10/20 14:12:52  torer
;;; New flag to disallow source code to be stored in image:
;;;   _INCLUDE-SOURCE_
;;;
;;; Revision 1.117  2012/09/06 20:54:00  torer
;;; Cost binding pattern for transient foreign functions corrected
;;;
;;; Revision 1.116  2012/08/15 18:23:13  torer
;;; New function
;;; (CREATE-TRANSIENT-FOREIGN-FUNCTION ARGTYPES RESTYPES DEF &OPTIONAL COST)
;;; to create transient foreign function which is garbage collected when
;;; no longer referenced
;;;
;;; Revision 1.115  2012/05/02 17:16:47  torer
;;; optional() aware optimization of conjunctions and
;;; order preserving generation of conjunctive predicate
;;;
;;; Revision 1.114  2012/04/24 14:07:13  torer
;;; ANDORP -> COMPOUND-P for more generality
;;;
;;; Revision 1.113  2012/04/13 17:02:57  torer
;;; pc("*select*"); did not work
;;;
;;; Revision 1.112  2012/04/13 12:29:11  torer
;;; Circular references removed
;;;
;;; Revision 1.111  2012/03/12 21:47:13  torer
;;; Optional checking of result types in CREATEFUNCTION-DISTINCT
;;;
;;; Revision 1.110  2012/02/24 11:37:31  torer
;;; More on-line documentation
;;;
;;; Revision 1.109  2012/02/11 16:39:30  torer
;;; pc("*select*"); did not work
;;;
;;; Revision 1.108  2012/02/11 12:47:01  torer
;;; select (x,y)...  <->  select x,y ...
;;;
;;; Revision 1.107  2012/02/09 22:28:11  andan342
;;; Fixed FOREIGN-LISPFN macro: now generating resolvent names compatible with CREATE FUNCTION ... AS FOREIGN ... syntax even for names with ':'
;;;
;;; Revision 1.106  2012/01/25 19:55:51  torer
;;; EXTERNALIZE confusing over bags and tuples
;;;
;;; Revision 1.105  2011/12/29 07:37:15  torer
;;; Introduced tuple types
;;;
;;; Revision 1.104  2011/12/22 23:01:25  torer
;;; Nicer error message
;;;
;;; Revision 1.103  2011/12/22 15:48:09  torer
;;; Mior core reorganization
;;;
;;; Revision 1.102  2011/12/22 12:55:16  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.101  2011/03/09 07:13:24  torer
;;; Wrong kind of default index on tuple valued function without arguments
;;;
;;; Revision 1.100  2011/02/27 18:32:37  torer
;;; Unique index on stored function without argument returning atomic value
;;;
;;; Revision 1.99  2011/02/16 18:47:29  torer
;;; 1. Correct signature for evalv and eval
;;; 2. tuples_in -> tuples
;;;
;;; Revision 1.98  2011/02/13 15:50:27  torer
;;; loop and while allowed as procedure body
;;;
;;; Revision 1.97  2011/01/14 16:01:03  torer
;;; THERESOLVENT accepts OID too
;;;
;;; Revision 1.96  2011/01/09 16:37:34  torer
;;; The function 'in' always return a bag
;;;
;;; Revision 1.95  2010/12/01 07:43:39  torer
;;; Spurious '
;;;
;;; Revision 1.94  2010/08/27 07:49:57  torer
;;; Type inference of {} in function arguments
;;;
;;; Revision 1.93  2010/02/26 15:22:45  torer
;;; Disallowing same declaration in arguments and FROM clause in derived function
;;;
;;; Revision 1.92  2010/02/17 18:58:51  torer
;;; Better ranksort optimization
;;;
;;; Revision 1.91  2010/01/06 15:29:54  torer
;;; CommonLisp standard (append x nil) used for copying top levels of lists
;;;
;;; Revision 1.90  2009/12/12 11:14:34  torer
;;; Better SET-BAGGED
;;;
;;; Revision 1.89  2009/12/09 19:38:33  torer
;;; Removed wrong duplicate declaration error
;;;
;;; Revision 1.88  2009/11/02 18:17:38  torer
;;; Removed duplicate ADDFUNCTIONSUSING
;;;
;;; Revision 1.87  2009/11/02 07:58:02  torer
;;; Incremental recompilation of derived functions with transient subplans now works
;;;
;;; Revision 1.86  2009/10/03 11:13:52  torer
;;; Function to test if bagged result (HAS-BAGGED-RESULT FNO)
;;;
;;; Revision 1.85  2009/09/06 19:00:26  torer
;;; Tougher test for unused variables
;;;
;;; Revision 1.84  2009/09/04 18:43:39  torer
;;; ECA rules removed
;;;
;;; Revision 1.83  2009/09/04 15:41:39  torer
;;; Tougher unused variable test
;;;
;;; Revision 1.82  2009/09/04 14:48:42  torer
;;; Check for unused variables
;;;
;;; Revision 1.81  2009/04/29 20:51:27  torer
;;; Boolean values in foreign functions treated as other values
;;;
;;; Revision 1.80  2008/12/27 21:03:05  torer
;;; Redundant ADDRESDCL removed
;;;
;;; Revision 1.79  2008/11/23 15:00:26  torer
;;; Stricter type checking
;;;
;;; Revision 1.78  2008/11/13 08:39:35  torer
;;; #'foo' now evaluated by parser.
;;; Enables computed result types for tclose(function,object)->object
;;;
;;; Revision 1.77  2008/11/11 07:46:12  torer
;;; Stricter checking of conformance with result types in function definitions
;;; Can be turned off with
;;;    (setq _strict-resulttypes_ nil)
;;;
;;; Revision 1.76  2008/10/10 13:08:38  torer
;;; Adding ; last in source of foreign function
;;;
;;; Revision 1.75  2008/09/27 15:36:04  torer
;;; New syntax for 'vector selection' as in SCSQ:
;;;
;;; vselect iota(2,10); <=> vectorof(select iota(2,20));
;;;
;;; Revision 1.74  2008/05/17 15:00:40  torer
;;; Type checking of vectors turned off by default
;;; To turn it on again:
;;;  (setq _not-typechecked-types_ (list _literal_))
;;;
;;; Revision 1.73  2008/04/03 15:00:49  torer
;;; reopt.lsp depatched
;;;
;;; Revision 1.72  2008/02/01 10:41:49  torer
;;; Warning message on slow late binding of vector of
;;;
;;; Revision 1.71  2007/12/20 16:15:19  msabesan
;;; " * is skipped "
;;;
;;; Revision 1.70  2007/11/19 16:49:53  msabesan
;;;  add new field to selectbody to include  extra stage in query optimzer to implement parallelization
;;;
;;; Revision 1.69  2007/10/24 21:14:55  torer
;;; Code moved to make modules independent
;;;
;;; Revision 1.68  2007/10/18 12:22:54  torer
;;; Added code to split TBRs into transportable subplans
;;;
;;; Revision 1.67  2007/10/11 12:23:32  torer
;;; Predicate functions could not be used in select clauses
;;;
;;; Revision 1.66  2007/07/25 16:03:22  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.65  2007/05/29 15:31:30  torer
;;; remove allowed on top level in procedure
;;;
;;; Revision 1.64  2007/03/01 07:56:42  torer
;;; Clean and correct definition of CHECKDUPDECL
;;;
;;; Revision 1.63  2006/12/01 16:30:09  torer
;;; Fully nested typed collections
;;;
;;; Revision 1.62  2006/11/04 16:18:20  torer
;;; Systematically using GET-RESOLVENT-ARGTYPES and GET-RESOLVENT-RESTYPES
;;;
;;; Revision 1.61  2006/11/04 15:14:53  torer
;;; selectbody-argt and selectbody-rest set for stored functions
;;;
;;; Revision 1.60  2006/04/29 17:32:31  torer
;;; More general nested expressions in procedures
;;;
;;; Revision 1.59  2006/04/29 10:11:12  torer
;;; Check for duplicated or conflicting declarations in FROM clause
;;;
;;; Revision 1.58  2006/04/27 19:18:27  torer
;;; Removed unused functions
;;;
;;; Revision 1.57  2006/04/14 18:39:36  torer
;;; Added accessor functions for ORGCODE
;;;
;;; Revision 1.56  2006/04/12 08:21:14  torer
;;; Correct reconstruction of variable *BINDINGS* for cost-based optimization
;;;
;;; Revision 1.55  2006/04/08 14:19:39  torer
;;; (GET-OC FNO) always used as accessor function for OID property ORGCODE
;;;
;;; =============================================================


(defvar *expandInputVarTemplates* t)
(defvar *current-compile-fn* nil)
(defvar *replace_list* nil)
(defvar *imported_def* nil)
(defvar *do_not_coerce* nil)
(defvar *coerced_input* nil)
(defvar *extendedResult* nil)
(defvar *extendedVars* nil)
(defvar *this-resolvent* nil "The resolvent being compiled")
(defglobal _system-watermark_ -1 "OID number of the last system object")
(defglobal _=_)
(defglobal _optimize-typechecking_ t)
(defglobal _include-source_ t "Make AmosQL sources availabile in image")
(defglobal _proctags_ 
  '(proc-block osql-foreach add-type remove-type 
	       set-function add-function rem-function osql-return
	       if delete-object create-userobjects 
	       progn amosql-loop amosql-while amosql-leave commit rollback) 
  "List of forms allowed in procedure body top level")

(defglobal _boolean_)
(defglobal _res_ext_extent_)
(defvar *optmethod* 'ranksort)

(defvar *fno*)
(defvar *fullsig*)
(defvar *in_csdfunction* nil)
(defvar *def*)
(defvar *no_typechecks* nil)

(defglobal _not-typechecked-types_)

(defstruct selectbody
  ;;; A SELECTBODY is a structure containing a compiled AMOSQL 
  ;;; function for a given binding pattern. 
  argl;; Argument symbols
  resl;; Result symbols
  pred;; Re-written predicate
  optpred;; Optimized selection predicate
  delpred;; Expression used when updating function. 
  ;;NIL if not updatable definition.
  locals;; Local symbols in predicates.
  orgpred;; Original predicate after simplification
   ;;; DO NOT CHANGE THE ORDER OF THE ABOVE FIELDS!
  argt;; Types of arguments.
  rest;; Types of results.
  loct;; Types of local variables.
  unoptimized;; original predicate before simplification
  expanded;; after view expansion
  expanded-simplified;; after view expansion and simplification
  aqit;; after the AQIT rewite
  normalized;; after normalization 
  normalized-simplified;; after normalization and simplification
  coercedpred;; Coerced predicate (if different).
  absorbed;;After calling the aborber
  parallelized;; Parallelized plan
  decomptree);; Decomposition tree.

(defun selectbody-argresl (sb)
  "List of input and output parameters of selectbody"
  (append (selectbody-argl sb)(selectbody-resl sb)))

(defun getfunctionnamed (name &optional noerror)
  "Get AmosQL function named by symbol NAME"
  (getobjectnamed name _function_ noerror))

(defun theresolvent (name &optional noerror)
  (let ((r (resolvents (getfunctionnamed (if (oid-p name) name
					   (mksymbol1 name)) noerror))))
    (if (cdr r) (error "More than one resolvent for" name)
      (car r))))

(defun generic-fnname (fnn &optional noerror)
  (let* ((fno (getfunctionnamed fnn noerror))
         (gfn (and fno (generic-function-of fno noerror))))
    (and gfn (oid-name gfn))))

(defun generic-function-of (fno &optional noerror)
  (let (temp)
    (cond ((getobject fno 'generic) fno) ; already generic
	  ((getobject fno 'genfn))	; regular resolvent
	  ((and (setq temp (getobject fno 'predof)) ; stored relation
		(getobject temp 'genfn)))
          ((transientp fno) fno)
          ((null (getobject fno 'resolvents)) fno)
          (noerror nil)
	  (t (amos-error "Cannot get generic function for " fno)))))

(defun externalize (s &optional short inmsg)
  "Traslate S expression with OIDs into more readable format"
  (cond ((oid-p s) (cond ((null (oid-name s)) s)
                         (short (if (memq _function_ (oid-types s))
				    (generic-fnname s)
				  (oid-printname s)))
                         (t (oid-printname s))))
	((stringp s) s)
	((and (arrayp s) (if (> (array-total-size s) 0)
			     (eq (elt s 0) 'GNODE) 
			   nil))
	 (let ((str (maketextstream 100)))
	   (gnpstr s str "")
	   (textstreamstring str)))
	((arrayp s)
	 (externalize (arraytolist s) short))
	((atom s) s)
        ((and inmsg (or (tuplep s)(bag-p s)))
         (with-string str (print-tuple s str)))
	(t;;(cons (externalize (car s) short)(externalize (cdr s)short)):
	 (let ((res (tconc nil)))
	   (loop 
	     (cond ((null s)(return (first res)))
		   ((atom s)(return (nconc (first res) 
					   (externalize s short))))
		   (t (tconc res (externalize (pop s) short)))))))))

(defun oid-printname (oid)
  (let ((nm (oid-name oid)))
    (if (listp nm) oid nm)))

(defmacro resetgenvar (form)
  "Reset variable generation numbers and other local info when evaluating FORM"
  `(let (res gva)
     (let* ((*genvar* (if *in_csdfunction* *genvar* 0))
	    *locals*)
       (setq res  , form)
       (setq gva *genvar*))
     (if *in_csdfunction*
	 (setq *genvar* gva))
     res))

(defun rescope-compiled-fn (fno)
  "Change current named compiled fn if not transient"
  (if (not (transientp fno))
      (setq *compiled-fn* fno)))

(defun procedure-body-p (body)
  "True if BODY is parsed procedure body"
  (and (listp body)
       (memq (car body) _proctags_)))

(defun createfunction (name argtypes1 restypes1
			    &optional resv quant pred proid 
                            dontcheckresulttypes)
  "Create new OSQL function
   resv, quant and pred = NIL => stored function
   resv = FOREIGN => foreign function, resv = implementation name for table FF
   otherwise derived function with select expression defined by resv, quant, 
   and pred"
  (let ((nf
	 (resetgenvar
	  (let* (bagged-res
		 (argtypes (fix_at_decl argtypes1))
		 (restypes (fix_at_decl restypes1))
		 (*locals* (delete nil 
				   (nconc (getvars argtypes)(getvars restypes) 
					  (and (not (foreigntag resv))
					       (getvars quant)))))
		 (overloads? (if (null (getfunctionnamed name t)) nil t))) 
	    ;;overloads?
	    (setq argtypes (substdeclarations argtypes)) ; if name exists
	    (cond ((setq bagged-res (remove-bagged-result name restypes))
		   (and argtypes
			(not (memq 'nonkey (car argtypes)))
			;; returning one bag and index on 1st arg
			;; add nonkey on first argument
			(nconc1  (car argtypes) 'nonkey))
		   (setq restypes bagged-res)))                     
	    (setq restypes (substdeclarations restypes))
	    (let (rfn rfnname *locals*
		      (derivedp 
		       (and (not (or (foreigntag resv)
                                     (procedure-body-p resv)))
			    (or (consp resv)(consp quant) pred)))
		      (fno (createfunction1 name)) ;creates a function object
		      (*compiled-fn* *compiled-fn*)
		      (rt (mapcar (function dcl-type) argtypes))
		      boolresvar)
	      (rescope-compiled-fn fno)
	      (cond ((null restypes))
		    ((and (null (cdr restypes))
			  (eq (caar restypes) _boolean_))
		     ;; boolean: functions without result
		     (cond ((not derivedp) nil)
			   ;; derived function with boolean result
			   ((null (setq boolresvar(dcl-variable 
						   (car restypes))))
			    (error "No Boolean result variable" 
				   (car restypes)))
			   ((cdr resv)(amos-error 
				       "Illegal tuple result selected for "
				       fno))
			   (t 
			    ;; derived function with declared 
			    ;; result variable
			    (setq quant (cons (car restypes) quant))
			    (cond (resv
				   ;; assign boolean result variable
				   (setq pred (andify (list (list '= boolresvar
								  (car resv))
							    pred)))
				   (setq resv (list boolresvar))))))
		     (setq restypes nil)))
	      (cond ((setq rfn (getresolvent fno rt)) 
		     ;;redefine instead of error
		     (redefinefunction fno rfn argtypes 
                                       restypes resv 
				       quant pred bagged-res)
                     (set-bagged rfn bagged-res)
		     rfn) 
		    (t 
		     (cond ((eq name '*transient*)
			    (setq rfn fno))
			   (t (setq rfnname 
				    (make-resolventname-dcl name argtypes 
							    restypes))
			      (setq rfn (createfunction1 rfnname proid))
			      (creategenericfunction fno)))
		     (addresolvent fno rfn argtypes restypes)
		     (or (transientp rfn)(/putobject rfn 'genfn fno))
                     (set-bagged rfn bagged-res)
		     (createsimplefunction rfn argtypes
					   restypes resv quant pred
					   dontcheckresulttypes)
		     (if overloads?;; new resolv overl existing
			 (if (recompilation? rfn (resolvents fno))
			     ;;recompilation?
			     (mapcar (function recompile)
				     (get-pred-fn
				      (car (get-resolvent-argtypes rfn))
				      (resolvents fno)))
			   nil)
		       nil)
		     rfn)))))))
    (chain_set_lb nf) 
    nf))

(defun set-bagged (fno flg)
  (cond (flg (/putobject fno 'bagged-result t))
        ((getobject fno 'bagged-result)(/putobject fno 'bagged-result nil))))

(defun has-bagged-result (fno)(or (has-generic-function fno 'in)
                                  (getobject fno 'bagged-result)))

(defun remove-bagged-result (fn restypes)
  "Convert bag of X in result into X or return NIL"
  (if (and (cdr restypes)(assq 'bag restypes))
      (error "Bags not allowed in tuple result" fn))
  (let ((temp (isome restypes 
		     (f/l (rt) (and (eq (first rt) 'bag)
				    (eq (second rt) 'of))))))
    (cond ((null temp) nil)
	  (t (third (car temp))))))

(defun foreigntag (x)
  "Does symbol X indicated foreign function?"
  (or (eq x 'foreign)(eq x 'multidirectional)))

(defun createfunction1 (name &optional proid)
  "Create function object"
  (cond ((eq name '*transient*) 
	 (create-transient-object _function_)) ; For internal functions
        (proid
	 (set-oid-name proid name)
	 (/addtype proid (gettypenamed 'function))
	 proid)
	(t (cond ((null name)(/createobject 'function nil))
		 ((getobjectnamed name _function_ t))
		 ((/createobject 'function name))))))

(defun substdeclarations (dcll)
  "Check semantics of variable declaration list and internalize it"
  (mapcar (function internalize-dcl) dcll))

(defun internalize-dcl (dcl)
  "Internalize parsed declaration"
  (cond ((atom dcl)(error "Illegal declaration" dcl))
	((eq (second dcl) 'of)
	 (cons (car (internalize-nested-dcl (list (car dcl) 
						  'of (third dcl))))
	       (internalize-vardcl (cdddr dcl))))
	((atom (car dcl))
	 (cons (gettypenamed (car dcl))
	       (internalize-vardcl (cdr dcl))))
        (t (cons (car dcl)(internalize-vardcl (cdr dcl))))))

(defun internalize-nested-dcl (l)
  "Internalize declaration 'x of L'"
  (cond ((null l) nil)
	((null (cdr l))(list (gettypenamed (car l))))
	((eq (cadr l) 'of)
	 (cons (make-param-type-for (car l) 
				    (internalize-nested-dcl 
				     (mklist (third l))))
	       (internalize-nested-dcl (cdddr l))))
	(t (cons (car l)(internalize-nested-dcl (cdr l))))))

(defun internalize-vardcl (vd)
  "Handle variable part"
  (cons (cond ((and (not(memq (car vd) '(key nonkey)))
		    (car vd)))
	      (t (genvar)))
	(cond ((memq 'key vd) (list 'key))
	      ((memq 'nonkey vd) (list 'nonkey)))))

(defun createsimplefunction (fno argtypes restypes resv quant pred
				 &optional dontcheckresulttypes)
  "Create a single resolvent function"
  (let (sb (*this-resolvent* fno))
    (addresolvent fno fno argtypes restypes)
    (prog1 
        (cond ((null (or resv quant pred))
               (createsimplestoredfunction fno argtypes restypes))
              ((or (foreigntag resv)
                   (procedure-body-p (car resv)));; procedural fns are foreign
               (createforeignfunction fno argtypes restypes quant resv))
              (t (setq quant(substdeclarations quant))
		 (createsimplederivedfunction fno argtypes restypes resv quant
					      pred dontcheckresulttypes)))
      (setq sb(getobject fno 'selectbody))
      (set-orgcode fno argtypes restypes resv quant pred)
      (/putobject fno 'procedure nil)
      )))

(defun bagify-result-types (fno rest)
  "Add bag of if function markes as having bagged result types"
  (if (has-bagged-result fno)(list(list _bag_ 'of rest)) rest))

(defun set-orgcode (fno argtypes restypes resv quant pred)
  (/putobject fno
	      'orgcode
	      (nconc (list argtypes (bagify-result-types fno restypes))
		     (if resv(list 'as resv))
		     (if quant(if (foreigntag resv) (list quant)
				(list 'foreach quant)))
		     (if pred (list 'where pred)))
	      ))

(defun get-oc (o) (getobject o 'orgcode))

(defun get-orgcode (fno &optional reconstruct)
  "Get S-expression the defines FNO. 
   RECONTRUCT = T => Function reconstructed if S-expression evaluated"
  (list* 'create-function (cond ((transientp fno) '*transient*) 
				(reconstruct (externalize fno t));;No OID 
				(t fno))
	 (if reconstruct (get-oc fno);; keep OIDs
	   (externalize (get-oc fno)))))

(defun orgcode-argl (orgcode)
   "The argument declaration of parsed function definintion"
   (car orgcode))

(defun orgcode-resl (orgcode)
   "The result declaration of parsed function definintion"
   (second orgcode))

(defun print-function-definition (fn stream)
  "Pretty-print definition of function FN on STREAM"
  (let ((fno (theresolvent fn)))
    (pps (get-orgcode fno t) stream)
    fno))

(defun function-argvars (fno)
   "The argument variables used in ObjectLog for FNO"
   (selectbody-argl (getselectbody fno)))

(defun function-resvars (fno)
   "The result variables used in ObjectLog for FNO"
   (selectbody-resl (getselectbody fno)))

(defun declare-as-objects (vars)
   "Declare variables VARS as type Object"
   (mapcar (f/l (v)(list 'object v)) vars))

(defun createsimplestoredfunction (fno argtypes restypes)
  "Create stored resolvent with all dependencies"
  (let* ((*this-resolvent* fno)
         (argl (getvars argtypes))
	 (resl (getvars restypes))
	 (pfn (/createrelation;; will contain extent of fno
	       (pack 'p_ (oid-name fno)) 
	       nil
	       (+ (length argl)(length resl))))
	 (pargl (or (append argl resl) '(true)))
	 (pargtpes 
	  (append (gettypes argtypes) (gettypes restypes)))
	 pred)
    (checkdupdecl nil (append argtypes restypes));; Check declarations ok
    (addfunctionsusing fno pfn);; add dependencies for referential integrity
    (addfunctionsusing pfn fno)
    ;; Build reference from fno to its extent:
    (/putobject pfn 'selectbody	(make-selectbody :argl pargl :argt pargtpes))
    (/putobject pfn 'resolvents (list pfn))
    (set-resolvent-types pfn pargtpes nil)
    (/putobject pfn 'predof fno)
    (setq pred (cons pfn pargl))
    ;; Build indexes declared by KEY:
    (cond (argtypes
	   (buildkeyindexes pfn 
			    ;; index by default on first arg. 
			    (buildkeyindexes pfn 0 (list (car argtypes)) 
					     t 
					     ;;unique if only one argument:
					     (null(cdr argtypes)))
			    (append (cdr argtypes) restypes) nil))
          (t (buildkeyindexes pfn 0 (list (car restypes)) 
                              ;; Unique if non-bagged with single result:
			      (and (null (cdr restypes))
                                   (not (has-bagged-result fno))) t))) 
    (/putobject fno 'selectbody
		(make-selectbody :argl argl :resl resl 
                                 :argt (gettypes argtypes) 
				 :rest (gettypes restypes)
				 :pred pred :optpred pred :delpred pred))
    fno))

(defun addfunctionsusing (fn s)
  "Register that functions in S are used in function FN"
  (cond ((or (null fn)(null s) nil))
	((not (atom s))(addfunctionsusing fn (car s))
	 (addfunctionsusing fn (cdr s)))
	((and (oid-p s)(not (eq s fn))
	      (or (and (transientp fn) (function-p fn))
		  (> (oid-idno fn) _system-watermark_)))
	 (unionobject s 'usedbyfunction (list fn))
	 (unionobject fn 'usesobjects (list s))))
  nil)

(defun functions-usedby (fn0 &optional allfunctions)
  "Compute the generic functions referenced by FN0"
  (let ((r (make-hash-table)) res q s (sb (getselectbody fn0)))
    (cond ((null sb))
	  (t (push (selectbody-orgpred sb) q)
	     (while q
	       (setq s (pop q))
	       (cond ((or (null s)(eq s fn0)(symbolp s)) nil)
		     ((not (atom s))
		      (push (car s) q) 
		      (push (cdr s) q))
		     ((gethash s r) nil)
		     (t (setf (gethash s r) t)
			(cond ((transientp s) 
			       (let ((sb (getselectbody s)))
				 (if sb (push (selectbody-orgpred sb) q))))))))
	     (maphash 
	      (f/l (k v)
		   (cond ((and (function-p k)
			       (or allfunctions
				   (> (oid-idno k) _system-watermark_)))
			  (setq res (adjoin (or (generic-function-of k t)
						k) res)))))
              r)
	     res
	     ))))

(defun checkdupdecl (conflictflg dcll)
  "Check for duplicate or conflicting variable declarations"
  (mapl (f/l (l)
	     (checkdupdecl1 (car l)(cdr l) conflictflg)) 
	dcll))

(defun checkdupdecl1 (dc1 dcl conflictflg)
  "Internal"
  (dolist (dc2 dcl)
    (cond ((and (dcl-variable dc1)
                (dcl-variable dc2)
                (eq (dcl-variable dc1) (dcl-variable dc2)))
	   (cond ((not conflictflg)
		  (amos-error "Duplicate declaration in " 
			      (or *compiled-fn* "query") ": " 
			      dc1 " and " dc2))
		 ((not (equal (dcl-type dc1)
			      (dcl-type dc2)))
		  (amos-error "Conflicting declarations in " 
			      (or *compiled-fn* "query") ": "
			      dc1 " and " dc2)))))))

(defun createsimplederivedfunction (fno argtypes restypes resv quant pred
					&optional dontcheckresulttypes)
  "Create derived resolvent"
  (let ((sb (make-selectbody))
	(*in_csdfunction* T)
        (*this-resolvent* fno))
    (/putobject fno 'selectbody sb)
    (compileselect argtypes restypes resv quant pred sb fno 
		   dontcheckresulttypes)
    (if (not (getobject fno 'cost))
	(/putobject fno 'cost (compute-exec-cost sb)))
    fno))

(defun reslist-types (l)
  "Construct result sinature excluding single BOOLEAN"
  (let ((r (arglist-types l)))
    (cond ((null r) nil)
          ((cdr r) r)
          ((eq (car r) _boolean_) nil)
          (t r))))

(defun compileselect (argtypes restypes resv quant0 pred sb fno
			       &optional dontcheckresulttypes)
  "First part of the query compilation: flattening and typechecks"
  (let* ((quant (fix_at_decl (addresdcl resv restypes quant0)))
	 (argl (getvars argtypes))
	 (quantl (getvars quant))
	 (resulttypes (gettypes restypes))
	 resl predl tchecks flargs 
	 (*change_flag* t) *bindings* *locals* *change_l* *imported_def*
	 (*CURRENT-COMPILE-FN* (cons fno *CURRENT-COMPILE-FN*))
         bpos)
      
    (debug_pt "PARSED PREDICATE" pred)
    (checkdupdecl nil (append argtypes restypes))
    (checkdupdecl nil (append argtypes quant))
    (checkdupdecl t (append argtypes restypes quant))
    (and (null (cdr resv))(consp (car resv)) (eq (caar resv) _tupletag_)
	 ;; select (x, y) ... -> select x, y ...
	 (setq resv (cdar resv)))
    (check-unbound-var (set-difference quant0 restypes t) (cons resv pred) t)
    (setf (selectbody-argl sb) argl)
    (setf (selectbody-argt sb) (gettypes argtypes))
    (binddcl argtypes)
    (binddcl quant)
    (binddcl restypes)

    ;; First flatten the WHERE clause:
    (setq predl (if (and (listp pred) (eq (car pred) 'IMPORTED))
		    (progn (setq *locals* (second pred)) 
			   (setq  *imported_def* t)
			   (third pred))
		  (flattenpredicate pred)))
    (setq predl (assigntemporaries predl nil t))

    ;; Flatten the SELECT clause:
    (setq bpos *bindings*)
    (setq flargs (flattenarglist resv resulttypes))
    (setq resl (separate-argresvars flargs argl))
    (setq predl (assigntemporaries predl bpos)) ;; Preserve order for OPTIONAL

    (setq bpos *bindings*)
    (if (and (null (cdr resl))
             (eq (arg-type (car resl)) _boolean_))
        ;;single boolean result => predicate without result
	(setq predl (cons (car resl) predl))
      (setf (selectbody-resl sb) resl))
    (setf (selectbody-rest sb) (reslist-types flargs));;new
    (and (not dontcheckresulttypes)
	 (not (= (length (selectbody-rest sb)) (length resulttypes)))
	 (amos-error "Width of function "
                     *compiled-fn*
		     " incompatible with " (selectbody-rest sb)))

    (if (not *no_typechecks*)
	(setq tchecks (gen_typechecks (append2 argtypes quant))))
    
    (setq predl (andify (assigntemporaries 
			 (nconc (nreverse tchecks)predl) bpos)))
    (debug_pt "AFTER INSERTING EXTENT PREDICATES" predl)

    (if _ENABLE_DT_FLAG_ 
	(setq predl (insert_validate predl)))
    (debug_pt "AFTER INSERT VALIDATE" predl)
    (compile_phase2 predl resl argl quantl quant0 fno sb)))

(defun gen_typechecks (qList)
  "Function dealing with FOR EACH clause"
  (let (tchecks)
    (dolist (q qList);;q is a pair (var-type . var) 
      (let* ((tp (dcl-type q))
	     (var (if (cdr q) (dcl-variable q)))
	     (bnd (if var (getbinding var)))
	     extfn t1)
	(if (and var 
		 (not (eq tp _object_))
		 (null (intersection (getobject tp 'allsupertypes)
				     _not-typechecked-types_))
		 (not (binding-notypecheck bnd))) ;end of the big and
	    ;; (not (proxytype? tp)) <== not needed
	    ;; all proxy funcs are foreign
	    ;; so type cheks are not removed unless there is a local
	    ;; function invoked over the proxy type. As should be!
	    ;;note that only user types can have derived subtypes
	    (setq 
	     tchecks 
	     (append 
	      (cond ((setq extfn (get-extent-function tp))
		     (flattenpredicate
		      (list '=  var 
			    (list extfn))))
		    (t (if (setq t1 (slow-typecheck tp))
			   (formatl t 
				    "WARNING! Dynamic checking type of " 
				    var
                                    " in " (externalize *compiled-fn* t)
				    " may be slow. Consider declaring as " 
				    (externalize t1) t))
		       (list (list _=_ tp (list _typesof_ var)))))
	      tchecks)))))
    tchecks))

(defun slow-typecheck (tpo)
  "Is checking the type variable bound to TPO slow?"
  (cond ((osql-subtypep tpo _vector_ t) _vector_)))

(defun extent-function-name (tp)
  "Generates the standard extent function name for type TP"
  (pack 'extent_ (if (oid-p tp) (oid-name tp) tp)))

(defun store-extent-function (tp fno)
  "Stores Amos function FNO as extent function for type TP"
  (/putobject (gettypenamed tp) 'extentfn fno))

(defun get-extent-function (tpo)
  "The extent function for type TPO"
  (getobject tpo 'extentfn))

(defun separate-argresvars (resvars argvars)
  "In case any of the variables in RESVARS also appear in ARGVARS
   then introduce alias variable. Assures that args and results of
   ObjectLog predicate don't overlap"
  (cond ((null resvars) nil)
	((or (memq (car resvars) argvars)(osql-constantp (car resvars)))
	 (cons (addbinding (genvar) (car resvars) 
			   (arg-type (car resvars)))
	       (separate-argresvars (cdr resvars) argvars)))
	(t (cons (car resvars)
		 (separate-argresvars (cdr resvars) argvars)
		 ))))

(defun create-delpred (pred)
  "Construct update template for updatable functions"
  (if (listp pred)
      (let (res)
	(catch 'delete-pred
	  (let ((g_3 (car pred)))
	    (cond
	     ((eq g_3 'and)
	      (dolist
		  (p (cdr pred))
		(cond
		 ((atom p))
		 ((compound-p p)
		  (throw 'delete-pred nil))
		 ((foreign-predicatep
		   (car p))
		  (if (not (eq (foreign-name
				(car p))
			       'typesof))
		      (throw 'delete-pred nil)))
		 (res (throw 'delete-pred nil))
		 (t (setq res p))))
	      res)
	     ((eq g_3 'or)
	      nil)
	     (t pred)))))))

(defun is-declared (var dcll)
  (some (f/l (dcl)(eq (dcl-variable dcl) var)) dcll))

(defun addresdcl (resv restypes quantl)
  "Declare result variables in select"
  (mapc
   (function
    (lambda (rv rt)
      (cond ((not (symbolp rv)))
            ((is-declared rv quantl))
            ((is-declared rv restypes)
	     (setq quantl
		   (cons (list (dcl-type rt) rv)
			 quantl))))))
   resv restypes)
  quantl)

(defun createforeignfunction (fno argtypes restypes def tag)
  "Define a foreign function resolvent"
  (let ((argl (getvars argtypes))
	(resl (getvars restypes))
	(*do_not_coerce* t)
        (*this-resolvent* fno) fno1
        *bindings*
	pred sb bpdl foreignflg)
    (binddcl restypes)
    (binddcl argtypes);; needed by decomposer if this is a proxy fn
    (cond ((null def);; default name used
	   (move-forward-bpat (oid-name fno) fno))             
	  ((consp def);; multidirectional functions
	   (selectq tag 
		    (multidirectional
                     (setq bpdl def)
		     (dolist (bpd def)
                       (if (getf (cdr bpd) 'foreign)
                           (setq foreignflg t))
                       (define-tbr fno argtypes restypes bpd nil))
                     (if (not foreignflg) ; all TRBs are SELECTS
			 (dolist (bpd def)
			   (define-tbr fno argtypes restypes bpd t))))

		    (progn;; name of foreign function specified
		      (bind-foreign fno (nconc (buildl argtypes '-)
					       (buildl restypes '+)) 
				    (mkatom(car def))
				    (car def))
		      (setq def nil))))
	  (t;; name of predefined binding pattern definition specified
	   (setq def (mkatom def))
	   (move-forward-bpat def fno)
	   )) 
    (checkdupdecl nil (append argtypes restypes))
    (cond ((transientp fno)
           ;; This is to avoid circular references for 
           ;; transient foreign functions
	   (setq fno1 (create-transient-object _function_));; alias fno
	   (putobject fno1 'bindings (getobject fno 'bindings)))
	  (t (setq fno1 fno)))
    (setq pred (append (list fno1) argl resl))
    (/putobject fno1 'foreignimpl
		(cond ((listp def)(or (oid-name fno) '*transient*))
		      ;; omitted implementation => internal name
		      (t def);; explicitly specified implementation
                      ))
    (let ((keys (mapcar (f/l (vardecl)
			     (eq (caddr vardecl) 'key))
			(append argtypes restypes))))
      (mapc (f/l (pos)(add-keygroup fno (list pos)))
	    ;; To handle KEY declarations on foreign functions
	    (list-positions t keys))
      (/putobject fno 'keys;; Backward compatability for KEY-INFO
		  keys))
    (setq sb (make-selectbody :argl argl :argt (gettypes argtypes)
                              :resl resl :rest (gettypes restypes)
			      :pred pred))
    (update-locals sb argl)
    (update-locals sb resl)
    (/putobject fno 'selectbody sb)
    (if foreignflg;; some foreign TBRs, some SELECTs
	(dolist (bpd bpdl)
	  (define-tbr fno argtypes restypes bpd t)))
    (optimize-pred pred sb fno)
    fno))

(defun create-transient-foreign-function (argtypes restypes impl 
						   &optional costs)
  "Create transient foreign function which is garbage collected when
   no longer referenced"
  (resetgenvar;; Own namespace for genvar() in substdeclarations()
   (resetvar _histflg_ nil;; no logging
	     (let ((fno (create-transient-object _function_)))
	       (if costs (declarecosts fno (forward-signature-bpat 
					    (length argtypes)(length restypes))
				       costs))
	       (createforeignfunction fno
				      (substdeclarations argtypes)
				      (substdeclarations restypes)
				      (list impl) 'foreign)))))

(defun creategenericfunction (fno)
  "Initialize generic function"
  (cond ((getobject fno 'generic) nil)
	(t (/putobject fno 'generic t)
           (/putobject fno 'selectbody (make-selectbody))
           fno)))

(defun dcl-type (dcl) 
  "Type in declaration"
  (car dcl))

(defun dcl-variable (dcl)
  "Variable in declaration"
  (cadr dcl))

(defun set-dcl-variable (dcl v)
  "Set variable in declaration"
  (rplaca (cdr dcl) v))

(defun variable-declared-in (v dcll) 
  "Is the variable v declared among the variables in dcll?"
  (if (null v) t;; no variable specified => regarded as declared
    (dolist (d dcll)
      (if (eq v (dcl-variable d)) (return t)) ; declared!
      )))

(defun set-source (oid source)
  "sets the source of a function OID (etc) to the string SOURCE"
  (and (oid-p oid) 
       _include-source_
       (/putobject oid 'source_text (add-semi-last source)))
  oid)

(defun last-char (str)
  "Returns last character in string STR"
  (let ((p (1- (length str))))
    (if (> p 0) (substring p p str) "")))

(defun add-semi-last (str)
  "Add ; last in STR if missing"
  (let ((lc (last-char str)))
    (if (equal lc ";") str (concat str ";"))))

(defmacro create-function (fn argl &rest tail)
  "Entry macro for definition of derived and foreign function"
  (let* ((tl tail)(resl (pop tl))(as (pop tl)))
    (cond ((and (listp as)(eq (car as) 'call-procedure))
	   ;; Body is single function call -> translate to select
           (list 'create-function fn argl resl 'as (list (cons (second as)
                                                               (third as)))))
          ((not (or(null as)(eq as 'as)))
	   (amos-error "as expected in "
		       (list* 'create-function fn argl tail)))
	  ((or(null tl)(foreigntag (car tl)))
	   (list 'createfunction (kwote fn)(kwote argl)(kwote resl)
                 (kwote (car tl))(kwote(cadr tl)) nil))
	  (t (apply (f/l (distinct sl into quant pred)
			 (if distinct
                             (list 'createfunction-distinct (kwote fn) 
				   (kwote argl)
				   (kwote resl)(kwote sl) (kwote quant)
				   (kwote pred))
			   (list 'createfunction (kwote fn) (kwote argl)
				 (kwote resl)(kwote sl) (kwote quant)
				 (kwote pred))))
		    (parseselect tl '(distinct foreach where)))))))

(defun createfunction-distinct (name argtypes1 restypes1 resv quant pred 
                                &optional proid dontcheckresulttypes)
  "Create function not returning duplicates"
  (let ((temp (remove-bagged-result name restypes1)))
    (if temp (setq  restypes1 temp))) 
  (setq quant (insert-result-declarations restypes1 quant resv pred))
  (if (cdr resv)
      (createfunction 
       name argtypes1 restypes1 
       (tuple-accesses resv restypes1 '*tp)
       '((vector *tp)) 
       `(= *tp (in (tuples 
		    (select distinct ,resv 
			    foreach ,quant 
			    where ,pred)))) 
       proid)
    (createfunction name argtypes1 restypes1 
		    `((in (select distinct ,resv 
				  foreach ,quant where ,pred))) 
		    nil nil proid dontcheckresulttypes)))

(defun tuple-accesses (resv restypes tp &optional n)
  "Generate tuple accesses from result vector"
  (cond ((null resv) nil)
	(t (or n (setq n 0))
           (cons (list 'cast (list 'vref tp n) (list (caar restypes)))
		 (tuple-accesses (cdr resv) (cdr restypes) tp (1+ n))))))

(defun insert-result-declarations (restypes quant resv pred)
  "Move declarations from RESTYPES to QUANT"
  (let (dcl)
    (cond ((null restypes) quant)
	  ((let ((var (dcl-variable(car restypes))))
	     (or (variable-declared-in var quant);; already declared
		 (not (or (in var resv);;not used in body
			  (in var pred)))))
	   (insert-result-declarations (cdr restypes) quant resv pred))
	  (t (setq dcl (append (car restypes) nil))
	     (set-dcl-variable (car restypes) nil)
	     (insert-result-declarations (cdr restypes)(cons dcl quant)
					 resv pred)))))

(defun buildkeyindexes (pfn pos dcll keydflt &optional nomoreargs)
  "Build indexes for stored function arguments"
  (dolist (dcl dcll)
    (cond ((memq 'nonkey dcl))
	  ((memq 'key dcl)
	   (/addindex pfn pos _default-indextype_ t))
	  (keydflt			; first arg key if no more arguments
	   (/addindex pfn pos _default-indextype_ nomoreargs)))
    (setq pos (1+ pos)))
  pos)

(defmacro foreign-lispfn (&rest args)
  "Define forward directional foreign function in Lisp"
  (list* 'foreign-lispfn1 'create-function args))

(defmacro foreign-lispfn1 (crefn fnname argl resl &rest body)
  "Expands macro FOREIGN-LISPFN"
  (resetgenvar
   (let* ((argtypes (substdeclarations argl))
	  (restypes (substdeclarations resl))
	  (nameargtype (if (null argtypes) argtypes 
			 (heads argtypes)))
	  (namerestype (if (null restypes) restypes 
			 (heads restypes)))
	  (restypel (mapcar (function dcl-type) restypes))
	  (bpat (nconc (buildl argl '-) (buildl resl '+)))
	  (rname (mkatom (string-replace-char (mkstring (make-resolventname fnname nameargtype namerestype)) ":" "-"))) ;; by Andrej
	  (lfn (packlist (cons rname bpat)))
	  (argvars (getvars argtypes))
	  (resvars (getvars restypes))
	  (comment (and (stringp (car body))(car body)))
	  (realbody (if comment (cdr body) body))
	  (newbody 
           (list* 'flet 
		  (list (list 'foreign-result resvars 
			      (list* 'checkforeignresults 
				     (list 'quote rname)
				     (list 'quote restypel)
				     resvars)
			      (cons 'osql-result (append2 argvars resvars))))
		  realbody)))
     (list 'progn 
	   (list* 'defun lfn 
		  (cons '__obj (append2 argvars resvars))
		  (if comment (list comment newbody) (list newbody))
		  )
	   (list crefn fnname argl resl 'as 'foreign (list lfn))
	   ))))

(defun remove-boolean-result (resl)
  "Single Boolean result is treated as no result"
  (if (and (null (cdr resl))
	   (eq (caar resl) _boolean_)) nil 
    resl))

(defun checkforeignresults (fn types &rest res)
  "Check the types of foreign function results"
  (cond (_debugging_
	 (mapc 
	  (f/l (r tpe)
               (or (matcharg r tpe)
                   (amos-error "foreign lisp function " fn 
			       " returns illegal result: "
			       r)))
	  res types)
	 res))) 

(defun key-list (key)
  "Convert argument key to list"
  (if (arrayp key)(arraytolist key)key)) 

(defun functiontype (fno)
  "Kind of function as string"
  (let (sb (rs (resolvents fno)))
    (cond ((cdr rs) "overloaded")
	  ((generic? fno) "generic")
          ((null rs) nil)
	  ((relationp fno)nil)
          ((getobject (car rs) 'procedure) "procedure")
          (t (setq sb (getselectbody (car rs)))
             (cond ((null sb) nil)
                   ((get-relation fno) "stored")
                   ((getobject (car rs) 'foreignimpl) "foreign")
                   (t "derived"))))))

(defun osql-functionp (fno)
  (member (functiontype fno) '("stored" "derived" "overloaded")))

(defun foreign-functionp (fno) (equal (functiontype fno) "foreign"))

(defun allfunctionsfortype(type) 
  "Returns sorted list of all non-generic functions used by a given 
    type object"
  (let ((usedby (getobject type 'usedbyfunction))
	res)
    (mapc #'(lambda(fn)
	      (and (get-oc fn) ; top function
		   (not (generic? fn))
                   (let* ((argtypes (get-resolvent-argtypes fn))
                          (restypes (get-resolvent-restypes fn)))
		     (if (or (memq type argtypes)(memq type restypes))
                         (setq res (cons fn res))))))
	  usedby)
    (csort res (function function<))))

(defun function< (x y)
  (let ((gx (getobject x 'genfn))(gy (getobject y 'genfn)))
    (cond ((or (null gx)(null gy)) (list< x y))
	  (t (list< (oid-name gx) (oid-name gy))))))
