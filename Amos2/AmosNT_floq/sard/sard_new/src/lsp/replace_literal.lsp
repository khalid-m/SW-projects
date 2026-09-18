;;; ===========================================================================
;;; AMOS2
;;;
;;; Author: (c)2012 Silvia Stefanova, UDBL
;;; $RCSfile: replace_literal.lsp,v $
;;; $Revision: 1.3 $ $Date: 2012/04/25 20:24:20 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Replaces literals in predicate with generated variables
;;;;;; ===========================================================================

(defglobal _repl_literal_ nil);;the functions are activated by setting to true


(defun alias-literal (lit)
  "Generates an alias variable for the literal lit"
  (cond ((listp lit) nil)
	((equal lit '*) nil)
	((and (atom lit)
	      (neq (typename lit) 'SYMBOL) )
	 (if (eq (typename lit) 'STRING)
	     (dt_genvar 'CHARSTRING)
	   (dt_genvar (gettypenamed (typename lit)))))))
	


(defun change-literal (pred )
"Replaces the literals in predicate pred 
with generated variables "
(cond ((atom pred) pred)
      ((null (leaf-predicate-p pred)) pred)
      (t
       (let((chpred pred )
	    lits result rs alias sub )
	 (setf lits (set-difference (cdr pred) (predicate-variables pred)))
	 (if (car lits);;if there are literals in pred
	     (progn
	       (do ((el (car lits)))
		   ( (eq nil (car lits) ))
		 (setf alias (alias-literal el ));;generate alias
		 (if (null (null alias))
		     (progn
		       (setf sub (subst alias el chpred));;replace literal by the alias 
		       (setf chpred sub);;new predicate
		       (setf rs (cons (list _=_ alias el) rs))
		       (setf lits (set-difference (cdr chpred) (predicate-variables chpred)))		       
		       (setf result (cons chpred rs)))		  
		   (progn;;if no alias was generated
		     (setf chpred chpred)
		     (setf lits (cdr lits))
		     ;;(setf result (cons chpred result))  
		     ))
		 (setq el (car lits)) ) )
	   (setf result pred))
	 result))))
     
       
(defun starlist? (ls)
"True if all elements in ls are * "
  (let ((res t ))
    (cond ((atom ls)
	 (if (null (equal ls '*)) 
	     (setf res nil)))
	(t
	 (dolist (el ls)
	   (if (null (equal el '*))
		     (setf res nil)))))
    res)) 


 
	   

(defun change-literal-con (con fr)
"In conjunction con in core-cluter fn
replaces literals by variables  "
 (cond ((atom con) con)
       ((null (cddr con)) con)
       (( and (null (eq 'AND (car con)))
	      (leaf-predicate-p con) )
	(if (core-cluster-fn? (predicate-operator con));;if con is CC fn	    
	    (change-literal con )
	  con ))
       (( and (null (eq 'AND (car con)))
	      (null (leaf-predicate con))) con)
       (t;;if con is a (AND (..) (..) )
	 (let (
	       ;;(fr (append (selectbody-argl sb)
			;;(selectbody-resl sb)))
	       res newpr frees eqss repl)
	   (dolist (pr (cdr con) );;go through con and change-literal
	      (if (leaf-predicate-p pr)
		  (if (and (core-cluster-fn? (predicate-operator pr))
			   (null (starlist? (set-difference (cdr pr) (predicate-variables pr)))))
		      (progn
			(setf newpr (change-literal pr ));;apply change-literal
			(dolist (el newpr)
			  (setf res (cons el res))) )
		    (setf res (cons pr res)))
		(setf res (cons pr res))))
	   (setf res (andify (reverse res)))
	   (setf res (infer-equality res fr))
	   (dolist (el (cdr res))
	     (if (and (eq (first el) _=_) 
		      (neq (typename (third el)) 'SYMBOL)
		      (null (member (second el) fr)))
		 (progn
		   (setf frees (cons (second el) frees ));;vars that shouldn't replace
		   (setf eqss (cons el eqss))
		   (setf repl (cons (subst (car (resolvents (getfunctionnamed 'like))) _=_ el) repl)) 
		   ) ) );;list of _=_ predicates with frees	   
	   (setf res (andify (append2 (substequal (set-difference-equal (cdr res) eqss) frees) repl)))
	   ;;(setf res (andify (append2 (substequal (set-difference-equal (cdr res) eqss) frees) eqss)))
	   ;;(help)
	   res ))))



(defun infer-equality (con fr)
"Infers equalities among _=_  predicates in con"
   (let (excl res comp newcomp flag u);;list of _=_ predicates to compare with
     (dolist (pr (cdr con));;go through con 
       (if (leaf-predicate-p pr)
	   (if (and (eq 'OBJECT.OBJECT.=->BOOLEAN (oid-name (car pr)))
		    (set-difference (cdr pr) (predicate-variables pr))
		    (null (in (second pr) fr))
		    (null (in (third pr) fr)))
	       (setf comp (cons pr comp)))));;populate comp list
     (dolist (pr (cdr con))
       (if (leaf-predicate-p pr)
	   (if (and (eq 'OBJECT.OBJECT.=->BOOLEAN (oid-name (car pr)))
		    (set-difference (cdr pr) (predicate-variables pr))
		    (null (in (second pr) fr))
		    (null (in (third pr) fr)))
	       (if (null (member pr excl));;if pr is not in excluding list
		   (progn;;infer equality
		     ;;(setf newcomp (set-difference comp (list pr)))
		     (setf newcomp (set-difference comp (cons pr excl)))
		     (setf flag nil)
		     (dolist (el newcomp)		   		         
		       (if (and (neq (typename (third el)) 'SYMBOL)
				(neq (typename (third pr)) 'SYMBOL)
				(eq (typename (second el)) 'SYMBOL)
				(eq (typename (second pr)) 'SYMBOL)			      
				(eq (typename (third el)) (typename (third pr)))
				(equal (third el ) (third pr)))
			   (progn
			     (setf flag 't)
			     (setf res (cons pr res))
			     (setf res (cons (list _=_ (second el) (second pr)) res))
			     (setf excl (cons el excl))  );;push el into the exclude list
		 	 ) )		  
		     (if (null flag)
			 (setf res (cons pr res)))) );;close if not excl
	     (setf res (cons pr res)))
	 (setf res (cons pr res)) ))    
     (setf res (andify (reverse res)))
     res))
       
 



(defun decompose-pred (pred sb)
  "Do cost-based local optimization of PRED with selectbody SB"
  (if *old-decompose* (old-decompose-pred pred sb);; obsoltete code
    (let ((*bindings* (selectbody-bindings sb))
	  (pred0 (purge-void-preds pred sb));; Insert * for unused variables
	  (argl (selectbody-argl sb)))
      (if _repl_literal_ (setq pred0 (rewrite-extra-dnf 'change-literal-con pred0 (selectbody-resl sb) )));;replace literal by variables in CC function
      (setf (selectbody-coercedpred sb) pred0)
      (optimize-compound-predicate pred0 argl))));; cost-based optimization 



;;(defun relational-translate-like (ds pred env sqlq)
;;  (if _repl_literal_ (relational-translate-like-my ds pred env sqlq)
;;    (relational-translate-like ds pred env sqlq)))




(defun relational-translate-like (ds pred env sqlq)
"Translates even if the argument a2 is not string but
literal; it makes a string of it then "
  (let ((a1 (predicate-argument 1 pred))
	(a2 (predicate-argument 2 pred)))
    (cond ((stringp a2)
	   (sqlquery-add-predicate 
	    sqlq (list
		  (car pred) 
		  a1
		  (concatl (subst "%" "*" (explode a2)) "")   )))
          ((neq (typename a2) 'SYMBOL)
	   (setf a2 (mkstring a2))
	   (sqlquery-add-predicate 
	    sqlq (list
		  _=_
		  a1
		  (concatl (explode a2) "")   )))
	  (t nil )   )))







