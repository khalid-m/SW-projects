;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1993-2005 Staffan Flodin, Tore Risch UDBL
;;; $RCSfile: TBR.lsp,v $
;;; $Revision: 1.28 $ $Date: 2012/10/22 20:14:08 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Managing TBR definitions
;;; =============================================================
;;; $Log: TBR.lsp,v $
;;; Revision 1.28  2012/10/22 20:14:08  torer
;;; Foreign language (e.g. Python) code automatically loaded when saved in image
;;;
;;; Revision 1.27  2012/09/06 20:55:58  torer
;;; New Lisp function (FORWARD-SIGNATURE-BPAT ARITY WIDTH)
;;;
;;; Revision 1.26  2011/12/22 15:48:09  torer
;;; Mior core reorganization
;;;
;;; Revision 1.25  2011/07/06 20:36:00  torer
;;; FNO + bpat passed to foreign function loader
;;;
;;; Revision 1.24  2011/01/21 07:05:20  torer
;;; New macro (AMOS-WARNING X Y ...) for warning messages
;;;
;;; Revision 1.23  2010/12/29 20:24:22  torer
;;; Java independence by using foreign language interface
;;;
;;; Revision 1.22  2010/09/02 16:58:20  torer
;;; Minor bug in failure caching
;;;
;;; Revision 1.21  2010/09/02 15:01:12  torer
;;; Caching failed compilations
;;;
;;; Revision 1.20  2008/12/28 15:51:43  torer
;;; Test for non-executable TBR by BPAT-OPTIMIZE-FUNCTION 'worked' by
;;; catching indefinite recursion error, a very slow, unclean, and difficult to debug method!
;;; Now it is based on catch and throw on CATCH-EXEC-ERROR instead.
;;; In general, catching all errors is ugly.
;;;
;;; Revision 1.19  2008/11/29 15:45:14  torer
;;; Error message for wrong length of binding pattern
;;;
;;; Revision 1.18  2008/05/21 14:54:38  torer
;;; Bug fixed in maintaining local variables for multidirectional derived functions
;;;
;;; Revision 1.17  2008/05/21 10:32:29  torer
;;; Variable *catcherror* can be set to nil if you don't want system to internally
;;; catch optimization errors
;;;
;;; Revision 1.16  2008/05/21 08:08:33  torer
;;; Bug in cost recomputation of TBRs
;;;
;;; Revision 1.15  2008/04/03 15:00:48  torer
;;; reopt.lsp depatched
;;;
;;; Revision 1.14  2006/11/04 17:08:16  torer
;;; Transparent GET-RESOLVENT-ARGTYPES and GET-RESOLVENT-RESTYPES for both
;;; regular functions and TBR functions
;;;
;;; Revision 1.13  2006/07/28 11:06:20  torer
;;; Added possibility to associate cost hints with stored functions
;;;
;;; Revision 1.12  2006/07/28 09:09:09  torer
;;; BPAT-OPTIMIZE-FUNCTION did not save forward selectbody correctly
;;;
;;; Revision 1.11  2006/04/27 19:15:18  torer
;;; Uncached costs
;;;
;;; Revision 1.10  2006/04/22 06:39:45  torer
;;; *** empty log message ***
;;;
;;; Revision 1.9  2006/04/12 19:17:44  torer
;;; Cost profile of predicate now always on format (COST FANOUT [pred])
;;;
;;; Revision 1.8  2006/04/12 08:21:14  torer
;;; Correct reconstruction of variable *BINDINGS* for cost-based optimization
;;;
;;; Revision 1.7  2006/04/10 20:31:47  torer
;;; SELECTBODY-BINDINGS generates new variable *BINDINGS* list from selectbody
;;;
;;; Revision 1.6  2006/03/27 09:12:55  torer
;;; Inconsistent representation of cost/fanout
;;;
;;; Revision 1.5  2006/03/23 20:21:02  torer
;;; Transactional TBR management
;;;
;;; =============================================================

;;; 
;;; describe TBR instances of functions
;;;

(defstruct tbr 
  bpat ; binding pattern
  selbody ; selectbody
  impl ; foreign implementation (Lisp of foreign C predicate)
  cost ; query execution cost profile (cost fanout)
  rewriter ; query rewriter 
  fno ; OID of TBR function
  )

;;;
;;; Accessing TBR structs of resolvent
;;;

(defun copy-tbr (tbr)(copy-array tbr))

(defun get-tbr (fno bpat &optional readonly)
  "Get copy of the TBR of FNO with binding pattern BPAT.
   READONLY=T => no copy and no new TBR created"
  (let ((tbrl (getobject fno 'bindings)) tbr)
    (cond ((setq tbr 
		 (car (isome tbrl 
			     (f/l (x)(equal (tbr-bpat x) bpat))))) ; old TBR
           (if readonly tbr (copy-tbr tbr)))
          (readonly nil)
          (t (make-tbr :bpat bpat)))))

(defun put-tbr (fno bpat tbr)
  "Save TBR for FNO under BPAT"
  (/putobject fno 'bindings 
     (insert-tbr bpat tbr (getobject fno 'bindings)))
  tbr)

(defun insert-tbr (bpat tbr tbrl)
  "Insert TBR with binding pattern BPAT in list of TBRs TBRL"
  (cond ((null tbrl)(list tbr))
        ((equal (tbr-bpat (car tbrl)) bpat)
         (cons tbr (cdr tbrl)))
        (t (cons (car tbrl)(insert-tbr bpat tbr (cdr tbrl))))))

(defun get-best-covering-tbr  (fno bpat)
  "Given a function FNO find the TBR whose binding pattern best covers BPAT"
  (let (mincv found)
    (mapbpats 
     fno
     (f/l (tbr)
	  (let* ((cv (and (neq (tbr-cost tbr) 'fail)
                          (covers-dyn fno (tbr-bpat tbr) bpat))))
	    (cond ((null cv))		; incompatible
		  ((or (null mincv)
		       (< cv mincv))	; best so far
		   (setq mincv cv)
		   (setq found tbr))))))
    found))

(defmacro mapbpats (fno fn) 
  "Apply FN on all TBRs of FNO. (RETURN v) in FN terminates mapping"
  `(dolist (tbr (getobject (getfunctionnamed , fno) 'bindings))
     (funcall , fn tbr)))

;;;
;;; Main interface functions
;;;

(defun the-tbr-function (fno bpat &optional catcherror)
  "Get or create the TBR function of resolvent FNO for binding pattern BPAT"
  (let ((r (bpat-optimize-function fno bpat catcherror)))
    (cond ((null (tbr-p r)) r)
          ((eq (tbr-cost r) 'fail) nil)
          ((tbr-fno r))
          (t (setf (tbr-fno r) 
		   (createfunction1 '*transient*))
	     (/putobject (tbr-fno r) 'selectbody 
			 (tbr-selbody r))
             (tbr-fno r)))))

(defun declarecosts (fn bpat costs)
  "Declare COSTS of FN for given binding pattern BPAT (BPAT *ANY* allowed)"
  (let* ((fno (getfunctionnamed fn)) 
	 (tbr (get-tbr fno bpat)))
    (if (atom costs)
	(setq costs (getfunctionnamed costs)))
    (setf (tbr-cost tbr) (check-costs fn costs))
    (put-tbr fno bpat tbr)))

(defun getcosthint (fno bpat)
  "Search TBRs of FNO for cost hint with given BPAT, 
   or that covers BPAT, or default"
  (let (dflt bestcover besttbr)
    (or (mapbpats 
	 (un_pred_fn fno)
	 (f/l (tbr)
	      (let ((bp (tbr-bpat tbr))
		    (cst (tbr-cost tbr))
		    temp)
		(cond ((and cst
			    (neq cst 'fail)
			    (setq temp (covers-dyn fno bp bpat)))
		       (cond ((or (null bestcover)(< temp bestcover))
			      (setq bestcover temp)
			      (setq besttbr tbr))))
		      ((equal bp '*any*) ; default cost
		       (setq dflt cst))))))
	(cond (bestcover (tbr-cost besttbr))
	      (t dflt)))))

;;;
;;; Multi-directional foreign function definitions
;;;

(defglobal _forward-bpats_ (make-hash-table)) 
   ; table of binding patterns defined 'forwardly' with BIND-FOREIGN 
   ; before AMOSQL function is defined.

(defun bind-foreign (tr bpat impl &optional fname)
  "Bind TBR of function TR with binding pattern BPAT to implementation IMPL"
  (let* ((fno (if (oid-p tr) tr
		(getfunctionnamed tr t)))
	 tbr)
    (load-foreign-function fname bpat)
    (cond (fno)				;TR function previously defined
	  ((setq fno (gethash tr _forward-bpats_))) ; old forward reference
	  (t				; new forward reference
	   (setq fno (create-transient-object _function_)) 
	   (setf (gethash tr _forward-bpats_) fno)))
    (setq tbr (get-tbr fno bpat))
    (setf (tbr-impl tbr) impl)
    (put-tbr fno bpat tbr)
    tbr))


(defun check-costs (fn cf)
  (cond ((atom cf) (selectq cf (fail nil) cf))
	((and (listp cf)(listp (cdr cf))
	      (numberp (car cf))(numberp (cadr cf))) cf)
	(t (amos-error "Illegal cost/fanout list for " fn ":" cf))))

;;;
;;; Accessing TBR-rewriters
;;;

(defun add-rewriter (fn bpat rewriter)
  "Declare query rewriter for AMOSQL function FN under binding pattern BPAT"
  (let* ((fno (getfunctionnamed fn)) 
         (tbr (get-tbr fno bpat)))
    (cond ((not (memq rewriter (tbr-rewriter tbr)))
	   (setf (tbr-rewriter tbr) 
		 (append (tbr-rewriter tbr) (list rewriter)))
	   (put-tbr fn bpat tbr)))))

(defun remove-rewriter (fn bpat rewriter)
  (let* ((fno (getfunctionnamed fn)) 
         (tbr (get-tbr fno bpat)))
    (setf (tbr-rewriter tbr)
	  (remove rewriter (tbr-rewriter tbr)))
    (put-tbr fno bpat tbr)))

(defun get-rewriters (fn bpat)
  (let* ((fno (getfunctionnamed fn)) 
	 (tbr (get-best-covering-tbr fno bpat)))
    (if tbr (tbr-rewriter tbr))))

;;;
;;; Iterating over TRB extents
;;;

(defun map-matching-function-extent (fno key lfn)
  "Iterate over the extent rows of resolvent FNO matching KEY"
  (let ((r (get-relation fno)))
    (cond (r				; fastpath to main memory relation
	   (maprelation r key 
			(f/l (&rest row)
			     (funcall lfn row))))
	  (t (let* ((tfno (the-tbr-function fno (bpat-of-key fno key) t)))
	       (if tfno
		   (mapfunction 
		    tfno (known-key-part key) 
		    (f/l (row)
			 (selectq key
				  (* (funcall lfn row))
				  (funcall 
				   lfn
				   (mapcar (f/l (v)
						(if (osql-constantp v) v
						  (pop row)))
					   key)))))))))))

;;;
;;; Internal functions
;;;

(defun bpat-of-key (fno key)
  (selectq key 
	   (* (buildn (+ (getarity fno)(getwidth fno)) '+))
	   (mapcar (f/l (v)(if (osql-constantp v) '- '+))
		   key)))

(defun known-key-part (key)
  (subset key (function osql-constantp)))

(defun all-butlast (bpat)
  (and (every (f/l (x) (eq x '-)) (butlast bpat)) 
       (eq (car (last bpat)) '+)))

(defun move-forward-bpat (name fno)
  "Move definitions of foreign functions defined under NAME to function FNO"
  (if (neq name (oid-name fno))
      (amos-warning "TBR definition " NAME 
		    " should be named " (oid-name fno)"!"))
  (let ((bpato (gethash name _forward-bpats_)))
    (cond ((null bpato) 
	   (or (getobject fno 'bindings)
	       (amos-error 
		"No foreign function defined using the forward name" 
		name)))
	  (t (/putobject fno 'bindings (getobject bpato 'bindings))
	     ;; remove forward definition
	     (setf (gethash name _forward-bpats_) nil))))) 

(defvar *bpat-optimized-functions* nil)
(defun bpat-optimize-function (fno bpat &optional catcherror recompute)
  "Optimize function FNO to execute according to the pattern specified in BPAT"
  (let ((tbrfno (getbpatfn fno bpat)))	;find pbat code if possible
    (cond 
     ((and tbrfno (not recompute)
	   (if (tbr-p tbrfno) (tbr-selbody tbrfno) 
	     (getobject tbrfno 'cost))) tbrfno)
     ((and *bpat-optimized-functions*
           (gethash (list fno bpat) *bpat-optimized-functions*)) nil)
     (t 
      (resetgenvar
       (let* ((sb (getobject fno 'selectbody))
	      (argl (selectbody-argl sb))                  
	      (resl (selectbody-resl sb))                 
              (*bindings* (selectbody-bindings sb))
              *coerced_input*
              tbr)
         (if recompute (/putobject fno 'cost nil))
	 (if (not (eq (+ (length argl)(length resl)) (length bpat)))
	     (error "Binding pattern does not conform to function arity+width" 
		    fno))
	 (let* ((new-sb (copy-selectbody sb))
		(allargs (append argl resl))
		(nresl (mapfilter (f/l (bat) (equal (car bat) '+))
				  (pair bpat allargs)
				  (function cdr)))
		(nargl (set-difference allargs nresl))
					;nargl nresl
		nbpatass errorflag
                (*bpat-optimized-functions* 
		 (or *bpat-optimized-functions*
		     (make-hash-table :test 'equal))))
	   (setf (selectbody-argl new-sb) nargl)
           (setf (selectbody-argt new-sb) (arg-typel nargl))
	   (setf (selectbody-resl new-sb) nresl)
           (setf (selectbody-rest new-sb) (arg-typel nresl))	    	
	   (setf (selectbody-optpred new-sb) nil)
           (setf (gethash (list fno bpat) *bpat-optimized-functions*) t)
	   (if catcherror
	       (setq errorflag 
		     (null (catch-exec-error
			    (optimize-pred (selectbody-pred new-sb) 
					   new-sb fno))))
	     (optimize-pred (selectbody-pred new-sb) new-sb fno))
	   (cond ((forward? fno bpat)	; forward selectbody
                  (cond (errorflag nil)
                        (t (or (getcosthint fno bpat) ; user forward costhint
			       (/putobject fno 'cost 
					   (compute-exec-cost new-sb)))
			   (/putobject fno 'selectbody new-sb)
			   fno)))
		 (t (setq tbr (get-tbr fno bpat)) ; inverse selectbody
		    (setf (tbr-selbody tbr) new-sb)
		    (cond (errorflag (setf (tbr-cost tbr) 'fail)
				     (setf (tbr-selbody tbr) nil))
			  ((tbr-cost tbr)) ; allows user costhint
			  (t (setf (tbr-cost tbr)(compute-exec-cost new-sb))))
		    (put-tbr fno bpat tbr)
		    tbr)))))))))

(defun arg-typel (l)
  "Get types of AmosQL forms in L"
  (mapcar (function arg-type) l))

(defun getbpatfn (fno bpat)
  "Returns function selectbody for a given binding pattern if it exists"
  (if (forward? fno bpat) fno
    (get-tbr fno bpat t)))

(defun forward-bpat (fno)
  "Construct the forward binding pattern for FNO"
  (cond ((generic? fno)(error "Generic functions not handled" fno))
        (t (forward-signature-bpat (getarity fno)(getwidth fno)))))

(defun forward-signature-bpat (arity width)
  "Make the forward binding pattern for given arity and width"
  (nconc (buildn arity '-)(buildn width '+)))

(defun forward? (fno bpat)
  "True if BPAT is the forward pattern of function FNO"
  (let ((arity (getarity fno)))
    (and (= (length bpat)(+ arity (getwidth fno)))
	 (every (f/l (v)
		     (if (< (1-- arity) 0) 
			 (eq v '+)
		       (eq v '-)))
		bpat))))

(defun  selectbody-bindings (sb)
  "Generate *BINDINGS* list from compiled selectbody"
  (flet ((bindvars (vars types)
	   (mapcar (f/l (var type)
			(make-binding :var var :type type))
		   vars types)))
    (nconc (bindvars (selectbody-argl sb)(selectbody-argt sb))
           (bindvars (selectbody-resl sb)(selectbody-rest sb))
           (bindvars (selectbody-locals sb)(selectbody-loct sb)))))

(defun define-tbr (fno argtypes restypes bpd selectflg)
  "Define TBR function for FNO"
  (let (temp
	(bpat (bpatlist (first bpd)))
        (foreign (getf (cdr bpd) 'foreign))
        (select (getf (cdr bpd) 'select))
        (key (getf (cdr bpd) 'key)))
    (if (= (length bpat)(+ (length argtypes)(length restypes))) nil
     (error "Wrong length of binding pattern" (first bpd))) 
    (cond (selectflg
	   (and select
		(put-tbr-function fno bpat 
				  (gen-tbr-derivedfn 
				   select bpat
				   (append argtypes
					   restypes)))))
	  (foreign (bind-foreign fno 
				 bpat (mksymbol foreign)
				 foreign)))
    (if (getf (cdr bpd) 'key)
        (add-keygroup fno (list-positions '- bpat)))
    (if (setq temp (getf (cdr bpd) 'rewriter))
	(add-rewriter fno bpat (pack 'rewrite- temp)))
    (if (setq temp (getf (cdr bpd) 'cost))
	(declarecosts fno bpat temp))))

(defun gen-tbr-derivedfn (def bpat argrestypes)
  (createfunction '*transient* 
		  (bound-vars bpat argrestypes)
		  (unbound-vars bpat argrestypes)
		  (first def) (getf (cdr def) 'foreach) 
		  (getf (cdr def) 'where)))

(defun bound-vars (bpat argrestypes)
  "Select bound variable declarations"
  (mapcan (f/l (p v)(if (eq p '-)(list v))) bpat argrestypes))

(defun unbound-vars (bpat argrestypes)
  "Select unbound variable declarations"
  (mapcan (f/l (p v)(if (neq p '-)(list v))) bpat argrestypes))

(defun put-tbr-function (fno bpat bpfno)
  (put-tbr fno bpat (make-tbr :bpat bpat :impl bpfno
			      :selbody (getselectbody bpfno))))
