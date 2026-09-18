;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2004 Johan Petrini, Tore Risch UDBL
;;; $RCSfile: parteval.lsp,v $
;;; $Revision: 1.8 $ $Date: 2012/05/18 14:34:46 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Partial evaluation of:
;;; multidirectional foreign functions, 
;;; derived functionsand.  
;;; ===========================================================================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Inference of equalities (compile time unification):
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Given a conjunction, andl, this function tries to do compile time 
;;; unification of variables by looking at several calls the same
;;; stored predicate with common argument variables having unique indexes
;;; For eaxmple:
;;;    income(p,q) and income(p,r) and unique index on p
;;;  <=> q=r and income(p,r)
;;; Also functions in table xxx are declared to be partial evaluatable
;;; For those functions the system tries to evaluate them given arguments
;;; known at query rewrite time

(defvar *enable-parteval* t);; To enable dynamic on/off of parteval

(defun inferequals (andl)
  (let (other epred rw cndres)
    (cond ((atom andl) andl)
          ((eq (car andl) 'false) nil)
	  ((member (car andl) (cdr andl));;Remove any duplicate in ANDL
	   (inferequals (cdr andl)))
          ((and (oid-p (caar andl))
                (setq rw (getobject (caar andl) 'tr-rewriter))
                (setq cndres 
		      (call-rewrite-condition (car rw) (car andl) (cdr andl))))
           (call-rewrite-transformer (cdr rw)(car andl)(cdr andl) cndres))
	  ((and *enable-parteval*
                (oid-p (caar andl));;Part-eval of pred/fn with some args bound.
		(not (and (eq (car (resolvents (getfunctionnamed 'typesof))) 
			      (caar andl)) 
			  (not (every (function osql-constantp) (cdar andl)))))
		(ct_executablep (caar andl))
		(some (function osql-constantp) (cdar andl))
		(setq epred (parteval-pred (car andl))))
	   (nconc epred (inferequals (cdr andl))))  
	  ((null (hasuniqueindex (car andl)))
	   (recons (car andl) (inferequals (cdr andl)) andl))
	  ((setq other
		 (car (isome (cdr andl)
			     (f/l (p2) (hasuniquecommonvar (car andl) p2)))))
	   (nconc (compunify (car andl) other)
		  (inferequals (cdr andl))))
	  (t (recons (car andl)
		     (inferequals (cdr andl)) 
		     andl)))))

(defun call-rewrite-condition (rw pred rest cndres)
  (funcall rw pred rest cndres))

(defun call-rewrite-transformer (rw pred rest)
  (funcall rw pred rest))

(defun define-tr-rewriter (fno testfn actionfn)
  "If the a predicate P in conjuncts C has FNO as generic function
   and (TESTFN P C) returns non-NIL value V
   then call (ACTIONFN P C V) to return transformed conjuncts"
  (/putobject (getfunctionnamed fno) 
	      'tr-rewriter (cons testfn actionfn)))

(defun parteval-pred (pr)
  (let* ((bpat (mapcar (f/l (x)(if (osql-constantp x) '- '+)) (cdr pr)))
         (fno (the-tbr-function (if (relationp (car pr))
                                    (getobject (car pr) 'predof)
				  (car pr)) 
				bpat t))
         (count 0) 
         res)
    (cond ((null fno) nil);;no TBR fn applicable -> do nothing
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This code executes the predicates which
;have all constant arguments during compile time
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun ct_executablep (fn) 
  (let (genfn)
    (and (boundp '_static_funcs_) 
	 (setq genfn (generic-function-of fn t))
	 (getfunction _static_funcs_ (list genfn)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;end constant args predicates execution block
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(osql "create function parteval(Charstring fn)->Function
  as begin
     declare Function fno;
     set fno = functionnamed(upper(fn));
     set _static_funcs_(fno)=true;
     return fno;
     end;
create function unparteval(Charstring fn)->Function
  as begin
     declare Function fno;
     set fno = functionnamed(upper(fn));
     set _static_funcs_(fno)=false;
     return fno;
     end;
 ")
(commit)
    