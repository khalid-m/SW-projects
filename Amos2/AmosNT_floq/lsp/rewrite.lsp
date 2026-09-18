;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1995 Gustav Fahl, Tore Risch, Vanja Josifovski EDSLAB, UDBL
;;; $RCSfile: rewrite.lsp,v $
;;; $Revision: 1.57 $ $Date: 2013/12/30 13:29:23 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Re-write of ObjectLog TR predicates
;;; =============================================================
;;; $Log: rewrite.lsp,v $
;;; Revision 1.57  2013/12/30 13:29:23  torer
;;; More robust object comparison
;;;
;;; Revision 1.56  2013/12/27 13:17:14  torer
;;; Bug in rewrite of optional()
;;;
;;; Revision 1.55  2012/10/12 07:44:16  torer
;;; Rewrites over OPTIONAL eliminated
;;;
;;; Revision 1.54  2012/04/27 14:19:44  thatr500
;;; rewrite OR compound predicate by VECTOR.IN if applicable.
;;; It is for performance-wise
;;;
;;; Revision 1.53  2012/04/27 13:31:49  torer
;;; Rewriter for OPTIONAL
;;;
;;; Revision 1.52  2012/04/26 12:49:38  torer
;;; optional(pred) now supported in AmosQL
;;;
;;; Revision 1.51  2011/04/11 07:39:05  thatr500
;;; added freevars to call-late-tr-rewriters0
;;;
;;; Revision 1.50  2011/04/05 11:16:38  thatr500
;;; - reverted inferequals function
;;; - introduced Late TR rewrite
;;;
;;; Revision 1.49  2011/03/29 18:06:25  thatr500
;;; add reasoning inequality on Euclidean
;;;
;;; Revision 1.48  2010/08/23 11:50:35  torer
;;; Faster partial evaluation of DYNCONSTRUCTORs
;;;
;;; Revision 1.47  2010/05/31 12:44:10  torer
;;; Bug in partial evaluation of vectors
;;;
;;; Revision 1.46  2010/05/28 13:41:18  silvias
;;; Parteval on VECTOR
;;;
;;; Revision 1.45  2009/12/13 19:00:07  torer
;;; Bug in null representation
;;;
;;; Revision 1.44  2009/12/12 17:41:06  torer
;;; Bug fix: Variable substitution to nil now works
;;;
;;; Revision 1.43  2009/05/26 12:01:28  torer
;;; Trace of partial evaluation: _TRACE-PARTEVAL_ = T
;;;
;;; Revision 1.42  2009/05/26 09:27:19  torer
;;; Disabled confusing tracing
;;;
;;; Revision 1.41  2008/12/25 19:31:52  torer
;;; Removed obsolete apply_to_pred
;;;
;;; Revision 1.40  2008/10/01 06:55:58  torer
;;; Added flag _remove-equality_ to turn of (= const1 const2) rewrite rule
;;;
;;; Revision 1.39  2008/04/03 15:00:49  torer
;;; reopt.lsp depatched
;;;
;;; Revision 1.38  2007/11/20 10:01:57  torer
;;; Partial evaluation of collection constructors possible
;;;
;;; Revision 1.37  2007/11/16 13:49:44  torer
;;; TR-rewriters allowed on both generic functions and resolvents
;;;
;;; Revision 1.36  2007/09/10 11:07:34  torer
;;; Minor limitation removed in TR-rewriter
;;;
;;; Revision 1.35  2007/05/09 13:18:48  petrini
;;; Modified fn rewrite0 in rewrite.lsp to rewrite simple preds in a disjunction. Since _=_ is not bound to equality pred when rewrite0 is called at first time at installation we only rewrite simple pred when _=_ is bound.
;;;
;;; Revision 1.34  2006/11/11 15:28:59  torer
;;; Bug in unification of nested ORs
;;;
;;; Revision 1.33  2006/11/08 06:53:30  torer
;;; Fewer boolean assinments
;;;
;;; Revision 1.32  2006/11/07 22:15:50  torer
;;; Code unification for OR in AND
;;;
;;; Revision 1.31  2006/11/07 17:20:23  torer
;;; Removed hacks from REWRITEAND
;;;
;;; Revision 1.30  2006/11/07 15:51:09  torer
;;; Moved code from optimizer.lsp to rewrite.lsp
;;;
;;; Revision 1.29  2006/08/18 10:25:00  torer
;;; Partial evaluation now works of functions without constant arguments too
;;;
;;; Revision 1.28  2006/05/18 17:52:39  torer
;;; Removed dead code
;;;
;;; Revision 1.27  2006/04/27 19:18:27  torer
;;; Removed unused functions
;;;
;;; Revision 1.26  2006/04/14 18:42:21  torer
;;; Removed unnest_and_or
;;;
;;; Revision 1.25  2006/04/08 14:19:40  torer
;;; (GET-OC FNO) always used as accessor function for OID property ORGCODE
;;;
;;; Revision 1.24  2006/03/27 09:24:24  torer
;;; Partial evaluation in kernel
;;;
;;; Revision 1.22  2006/03/11 12:59:11  torer
;;; Removed useless code
;;;
;;; =============================================================

(defglobal _remove-equality_ t  "Enable equality rewrites")
(defvar *enable-parteval* t "Enable partial evalaluation")
(defglobal _trace-parteval_ nil "Trace of partial evaluation")

(defun rewrite (pred sb)
  (rewrite0 pred (append (selectbody-argl sb)
			 (selectbody-resl sb))))

(defun rewrite0 (pred freevars)
  "Generic calculus rewrite optimization."
  (cond ((compound-p pred)
	 (selectq (car pred)
		  (and (rewriteand (cdr pred) freevars))
		  (or (orify (mapcar (f/l (orclause)
					  (rewrite0 orclause freevars))
				     (cdr pred))))
                  (optional (make-optional (rewriteand (cdr pred) freevars)))
		  (error "Predicate rewrites not implemented for" (car pred))))
	((osql-variablep pred)(list _=_ pred 'true))
	((boundp '_=_) (rewriteand (list pred) freevars))
	(t pred)))


(defun rewrite-or-by-in (preds)  
  "Rewrite (OR (= X 1) (= X 2) (= X 3)) by (IN (VECTOR 1 2 3) X)"
  (if (listp preds)
      (mapcar (f/l (p)
		   (if (and (compound-p p)
			    (listp p)
			    (rewrite-or-by-in-tester p))
		       (rewrite-or-by-in-transformer p)
		     p))
	      preds)
    preds))

(defun join-vars (predl)
  "The variables in PREDL that are used for joining predicates"
  (let (vcnt)
    (dolist (b predl)
      (dolist (v (free-variables b nil))
	(let ((cnt (assq v vcnt)))
	  (if cnt (rplacd cnt (1+ (cdr cnt)))
	    (setq vcnt (cons (cons v 1) vcnt))))))
    (mapcan (f/l (x)(if (> (cdr x) 1)(list (car x))))
	    vcnt)))

(defun rewriteand (predl freevars)
  "Rewrite conjunction"
  (cond ((assoc 'optional predl) 
	 (andify (let* ((blocks (and-blocks predl))
			(jv (join-vars blocks))
			(fv (union jv freevars)))
		   (mapcar (f/l (b)
				(selectq (car b)
					 (optional 
					  (make-optional 
					   (rewriteand (cdr b) fv)))
					 (rewriteand (andargs b) fv)))
			   blocks))))
        (t (rewriteand-no-optional predl freevars))))

(defun rewriteand-no-optional (predl freevars)
  "Rewrite conjunction not containing OPTIONAL"
  (let* ((upred (unify-key-preds (add-boolean-assignments predl)
				 freevars))
	 (npred (andify (rewrite-or-by-in 
			 (if  *after-view-expansion* 
			     (call-late-tr-rewriters0 upred freevars) 
			   upred)))))
    (cond ((osql-variablep npred)(list _=_ npred 'true)) 
	  ((neq (car (ilistp npred)) 'and) npred)
	  ((assq 'or (cdr npred))	; or in and
	   (rewrite-orinand (cdr npred) freevars))
	  (t npred))))

(defun rewriteand0 (predl freevars)
  "Rewrite conjunction not containing OPTIONAL"
  (andify (mapcar 
	   (f/l (block) 
		(let* ((upred (unify-key-preds 
			       (add-boolean-assignments (cdr block))
			       freevars)) ;; Core unification
		       (npred (andify (rewrite-or-by-in 
				       (if  *after-view-expansion* 
					   (call-late-tr-rewriters0 upred 
								    freevars) 
					 upred)))))
		  (cond ((osql-variablep npred)(list _=_ npred 'true)) 
			((eq (car block) 'optional)
			 (make-optional npred))
			((neq (car (ilistp npred)) 'and) npred)
			((assq 'or (cdr npred)) ; or in and
			 (rewrite-orinand (cdr npred) freevars))
			(t npred))))
	   (and-blocks predl))))

(defun and-blocks (predl &optional secl)
  "Split conjunctive predicate body into list of conjunctive predicate blocks
   delimited by OPTIONAL predicates"
  (cond ((null predl) (if secl (list (cons 'and (nreverse secl)))))
        ((optional-p (car predl))
	 (nconc (if secl (list (cons 'and (nreverse secl))))
		(cons (car predl)
		      (and-blocks (cdr predl) nil))))
        ((is-true (car predl)) (and-blocks (cdr predl)secl))
        (t (and-blocks (cdr predl)(cons (car predl) secl)))))
                                                 
(defun add-boolean-assignments (predl)
  "Adds assignment to TRUE for boolean variables destructively"
  (mapl (f/l (root)
	     (if (osql-variablep (car root))
		 (rplaca root (list _=_ (car root) 'true))))
	predl)
  predl)

(defun rewrite-orinand (andl freevars)
  "Rewrite disjunctions inside conjunctions"
  (let (orclauses andclauses (freecnt (make-hash-table)) 
		  (newfreevars freevars))
    (dolist (pred andl)			; separate or-in-and from rest
      (selectq (car(ilistp pred))
	       (or (push pred orclauses))
	       (push pred andclauses)))
    ;; variables occurring in > 1 clause are locally declared as free
    ;; to permit joins through OR clauses:
    (dolist (fv (free-variables (andify andclauses) freevars))
      (setf (gethash fv freecnt) 1))
    (dolist (orpred orclauses)
      (dolist (fv (free-variables orpred freevars))
        (setf (gethash fv freecnt)(1+ (or (gethash fv freecnt) 0)))))
    (maphash (f/l (v cnt)(if (> cnt 1)(push v newfreevars)))
	     freecnt)
    ;;Rewrite each inner OR clase using NEWFREEVARS:
    (unify-key-preds ;simplifies subclause rewrites
     (andify (nconc (nreverse andclauses)
		    (mapcar (f/l (orpred)
				 (orify (mapcar 
					 (f/l (orclause)
					      (rewrite0 orclause newfreevars))
					 (cdr orpred))))
			    (nreverse orclauses))))
     freevars)))

(defun transformpredicate (pred)
  "The current optimizer requires disjunctive normal form predicates"
  (normalizepred pred 'or))

(defun unify-key-preds (predl freevars)
  "Until no change do: Infer equality preds and substitute equalities"
  (if (atom predl) predl
    (let (new-predl)
      (setq predl (substequal predl freevars))
      (setq new-predl (inferequals predl))
      (while (not (equal new-predl predl))
	(setq predl (substequal new-predl freevars))
	(setq new-predl (inferequals predl))
	)
      new-predl)))

(defun substequal (andargs freevars)
  "In a conjunctive clause ANDARGS with free variables FREEVARS, 
   substitute variable names according to
   encountered equality predicates.
   E.g. (and ... (= V1 V2)...) => (= V1 V2) can be removed and
   every occurence of V1 can be removed and substituted for V2, or
   V2 can be removed and substituted for V1
   The transformed conjunction is returned."
  (let (res trueflg)
    (clrhash _varsubstitutions_)
    (cond ((dolist (p andargs)
	     (cond ((atom p)
		    (cond ((eq p 'false) (return 'false))
			  ((eq p 'true) (setq trueflg t))
			  (t (setq res (cons p res)))))
		   ((or (neq (car p) _=_)
                        (and (not _remove-equality_)
                             (osql-constantp (second p))
			     (osql-constantp (third p)))
			(let ((tp1 (type_of_arg (second p) 
						*bindings*))
			      (tp2 (type_of_arg (third  p) 
						*bindings*)))
			  (and (neq tp1 tp2)
			       (not (memq tp1 (i_type? tp2)))
			       (not (memq tp2 (i_type? tp1)))
			       (or (dt_p tp1) (dt_p tp2))))) 
		    (setq res (cons p res)))
		   ((bindeqvarsubst (cadr p) (caddr p) freevars))
		   (t (return 'false))))) 
	  ((substeqvars (nreverse res) freevars))
	  (t 'true)))) 

;Gustavs new bindeqvarsubst
(defun bindeqvarsubst (x y freevars)
  "Maintains all equalities in a query for later substitution"
  (cond 
   ((= 0 (compare x y)))
   ((osql-constantp x)
    (if (osql-constantp y)
        nil 
      (bindeqvarsubst y x freevars)))
   ((if (not (osql-constantp y))
        (eqvarorder< x y freevars));; CHANGED!
    (bindeqvarsubst y x freevars))
   ((null (gethash x _varsubstitutions_))
    (puthash x _varsubstitutions_ (or y '*null*))
    t)
   (t (bindeqvarsubst (gethash x _varsubstitutions_) y freevars))))

(defun eqvarorder< (x y freevars)
  "The order in wich variables are to be stored as equal"
  (cond ((and (memq x freevars)
	      (not (memq y freevars))) t)
	((let ((tpx (type_of_var x *bindings*))
	       (tpy (type_of_var y *bindings*)))
	   (and tpx tpy (subtype-of tpy tpx))) nil)
	((and (< (compare x y) 0)
	      (not (memq y freevars))) t)))

(defun substeqvars (predl freevars)
  "In the conjunction predl where all equality predicates have been removed,
   substitute equality variables, 
   then add extra equality assignments for variables in predl that are
   removed by the substitutions (so they get their correct assignments)."
  (let (newpredl sp)
    (dolist (pred predl)
      (selectq (setq sp (substeqvars1 pred))
	       (true nil)
	       (false (error "Cannot bind variables to FALSE" predl))
	       (push sp newpredl)))
    (maphash (f/l (v c)
		  (if (and (memq v freevars)
			   (or (osql-constantp c)
			       (memq c freevars)))	
		      (push (list _=_ v c) newpredl)))
	     _varsubstitutions_)
    (nreverse newpredl)))

(defun substeqvars1 (l)
  "In expression l, substitute every variable occurrence 
   for its equality substited variable"
  (cond ((or (null l)(eq l '*null*)) nil)
	((listp l) (cons (substeqvars1 (car l))
			 (substeqvars1 (cdr l))))
	(t (getmostgeneralsubst l))))

(defun getmostgeneralsubst (var)
  "Get the variable to equality substiture var against
   see bindeqvarsubst for how equality substitutions are defined"
  (let ((v2 (gethash var _varsubstitutions_)))
    (if v2 (getmostgeneralsubst v2)
      var)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Inference of equalities (compile time unification),
;;; partial evaluation, and TR-rewrite rules:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun inferequals (andpred)
  "Given a conjunction, andl, this function tries to do compile time 
   unification of variables by looking at several calls the same
   stored predicate with common argument variables having unique indexes
   For eaxmple:
      income(p,q) and income(p,r) and unique index on p
    <=> q=r and income(p,r)"
  (let (other res rw cndres epred (andl andpred) eupred tmp)
    (while (not (atom andl))
      (cond 
       ((member (car andl) (cdr andl))	;Remove any duplicate in ANDL
	)
       ((atom (car andl))(push (car andl) res))
       ((and (oid-p (caar andl))
	     (setq rw (get-tr-rewriter (caar andl)))
	     (setq cndres 
		   (call-rewrite-condition (car rw) (car andl) andpred)))
	(setq res (append (call-rewrite-transformer 
			   (cdr rw)(car andl) andpred cndres)
			  res))
        )
       ((and *enable-parteval* 
	     (oid-p (caar andl));;Part-eval of pred/fn with some args bound.
	     (not (and (eq _typesof_ (caar andl)) 
		       (not (every (function osql-constantp) (cdar andl)))
		       ))
	     (ct_executablep (caar andl))
	     (setq epred (parteval-pred (car andl))))
        (cond (_trace-parteval_ (formatl t "Parteval:" "~PP" (car andl)
					 "==>" "~PP" epred 
                                           "-----------------------------" t)))
	(setq res (nconc epred res)))
       ((null (hasuniqueindex (car andl)))
	(setq res (cons (car andl) res)))
       ((setq other
	      (car (isome (cdr andl)
			  (f/l (p2) (hasuniquecommonvar (car andl) p2)))))
	(setq res (nconc (compunify (car andl) other) res)))
       (t
	(setq res (cons (car andl) res))))
      (setq andl (cdr andl)))
    (cond 
     ((null andl) (nreverse res))
     ((null res) andl)
     (t (nreverse (append andl res))))))

(defun call-rewrite-condition (rw pred rest)
  (funcall rw pred rest))

(defun call-rewrite-transformer (rw pred rest cndres)
  (argsof 'and (funcall rw pred rest cndres)))

(defun define-tr-rewriter (fno testfn actionfn)
  "If the a predicate P in conjuncts C has FNO as generic function
   and (TESTFN P C) returns non-NIL value V
   then call (ACTIONFN P C V) to return transformed conjuncts"
  (/putobject (getfunctionnamed fno) 
	      'tr-rewriter (cons testfn actionfn)))

(defun get-tr-rewriter (fno)
  "Get the TR rewriter for a function or its generic function"
  (or (getobject fno 'tr-rewriter)
      (getobject (generic-function-of fno) 'tr-rewriter)))

(defun parteval-pred (pr)
  (let* ((bpat (mapcar (f/l (x)(if (osql-constantp x) '- '+)) (cdr pr)))
         (fno (if (dynconstructorfn (car pr)) (car pr)
		(the-tbr-function (if (relationp (car pr))
				      (getobject (car pr) 'predof)
				    (car pr)) 
				  bpat t)))
         (count 0) 
         res)
    (cond ((null fno) nil);;no TBR fn applicable -> do nothing
          ((dynconstructorfn fno)
           (parteval-dynconstructor fno (cdr pr)))
	  ((catch 'fail 
	     (mapfunction 
	      fno 
	      (mapcan (f/l (x)
			   (if (osql-constantp x) 
			       (list x))) 
		      (cdr pr))
	      (f/l (r);;Iterate over result of partial evaluated fn
		   (setq count (+ count 1))
		   (cond ((<= count 1)		
			  (setq res 
				(mapcan (f/l (c v) 
					     (if (osql-constantp v) nil 
					       (list (list _=_ c v))))
					r (subset (cdr pr) 
						  (function symbolp)))))
			 (t (throw 'fail t))))))
           nil);;more than one result tuple -> do nothing
	  ;;((help))
	  ((< count 1) (list 'false));;pr evaluated without any result -> FALSE
	  ((= count 1) (if res res 'true));;pr evaluated with one 
	  (t nil))));;else -> do nothing

(defun parteval-dynconstructor (fno args)
  (let (fi)
    (cond ((and (not (osql-constantp (car args)))
		(every (function osql-constantp) (cdr args))
		(setq fi (aggregator (foreign-predicatep fno))))
	   (list2 _=_ (car args)
		  (apply fi (cdr args))))
	  ((arrayp (car args))
	   (if (= (length (car args))(length (cdr args)))
	       (mapcar (f/l (val var)(list _=_ var val)) 
		       (arraytolist (car args))
		       (cdr args))
	     '(false))))))

(defun hasuniquecommonvar (pred1 pred2)
  "Are there common argument variables in pred1 and pred2 that
   make PRED1 and PRED2 equivalent?"
  (and (eq (car pred1)
	   (car pred2))
       (cond ((equivalent-keygroup pred1 pred2))
	     ((dynconstructorfn (car pred1))
	      (and (= (length pred1)(length pred2))
                   (or (eq (cadr pred1)(cadr pred2))
		       (equal (cddr pred1) (cddr pred2)))))
             ((relationp (car pred1))
              (some (f/l (i)
			 (and (index-unique i)
			      (equal (nth (index-pos i) (cdr pred1))
				     (nth (index-pos i) (cdr pred2)))))
		    (relation-indexes (car pred1) nil))))))

(defun hasuniqueindex (pred)
  "Is pred a call to stored function with unique index?"
  (let ((predobj (car pred)))
    (cond ((relationp predobj)
	   (or (isome (relation-indexes predobj nil)
		      (function index-unique))
               (getobject (un_pred_fn predobj) 'keygroups)))
	  ((dynconstructorfn predobj) t)
	  ((oid-p predobj) (keygroups predobj)))))

(defun compunify (b1 b2)
  "Compile time unification of b1 and b2:"
  (cond ((null b1) nil)
	((equal (car b1)(car b2))
	 (compunify (cdr b1)(cdr b2)))
	(t (cons (list _=_ (car b1)(car b2))
		 (compunify (cdr b1)(cdr b2))))))

(defun ct_executablep (fn) 
  (let (genfn)
    (and (boundp '_static_funcs_)
	 (or (getfunction _static_funcs_ (list fn))
	     (and 
	      (setq genfn (generic-function-of fn t))
	      (getfunction _static_funcs_ (list genfn)))))))

(defun equivalent-keygroup (pred1 pred2)
  "Get key group making PRED1 and PRED2 equivalent"
  (and (eq (car pred1)(car pred2))
       (let ((pobj (un_pred_fn (car pred1))) 
	     (argl1 (cdr pred1))
	     (argl2 (cdr pred2)))
	 (car (isome (keygroups pobj)
		     (f/l (g)
			  (every (f/l (i)(equal (nth i (cdr pred1))
						(nth i (cdr pred2))))
				 g)))))))

(defun keygroups (fno)(getobject fno 'keygroups))

(defun set-keygroups (fno groups)(/putobject fno 'keygroups groups)) 

(defun add-keygroup (fno group)
  (and group
       (set-keygroups fno (adjoin (sort group (function <)) (keygroups fno)))))
 
(defun rem-keygroup (fno group)
  (set-keygroups fno (remove (sort group (function <))(keygroups fno))))

;; Intendedly, call-late-tr-rewriters0 will have a real definition
;; by (movd 'call-late-tr-rewriters0 'call-late-tr-rewriters1)
(defun call-late-tr-rewriters0 (lpreds freevars)  lpreds)