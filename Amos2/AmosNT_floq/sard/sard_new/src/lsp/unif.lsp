;;; ===========================================================================
;;; AMOS2
;;;
;;; Author: (c)2009 Silvia Stefanova, UDBL
;;; $RCSfile: unif.lsp,v $
;;; $Revision: 1.51 $ $Date: 2012/08/27 12:16:11 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Functions for unifyiing a DNF predicate
;;;;;; ===========================================================================

(defglobal _gct_ nil);;to apply GCT  after DNF, before purge-pred
(defglobal _unif_ nil);;to normalize varianle names in a DNF RDB predicate 
(defglobal _sch_ nil) ;if the schema view and some rowid are conjuncted
(defglobal _el-corcl_ nil);;to rewrite the schema view to NIL when possible; needed for ?s ?p <uri>  
(defglobal _elcon_ifnounif_ nil);; to rewrite { * * ?s. ?s ?p ?o }
(defglobal _rewrite_filter_ nil);;to rewrite FILTER on object when object is Literal
(defglobal _is_Literal_ nil);;eliminates for object that are not Literals when FILTER on object
(defglobal _type_Match_ nil);;eliminates for literal object that don't match the type in FILTER

(defun alias-var (var sb)
  "Generates an alias of var"
  (cond ((listp var) nil)
	((atom var)
	 (let ((tpo nil)
	       (vnew nil)
	       (listb (selectbody-bindings sb)))
	   (dolist (a listb vnew)
	     (if (eq var (binding-var a))
		 (progn
		   (setf tpo (binding-type a))
		   (setf vnew (dt_genvar tpo)))
	       (set vnew (cons vnew))))))))  


	   
(defun change-free (pred sb)
"Changes the free vars vith generated ones"
  (let ((rs nil)
	(alias nil)
	(fr (append (selectbody-argl sb)
		    (selectbody-resl sb))))
    (dolist (x fr rs)
      (if (in x pred)
	  (progn
	    (setf alias (alias-var x sb))
	    (setf rs (list (subst alias x pred) (list _=_ x alias))))
	(setf rs (list pred))))))



(defun isublist (vars ls)
  "Finds whether the vars are part of ls or are not gen vars"
  (cond ((atom vars)
	 (if (or (in vars ls) (null (genvar? vars))) 't))
	(t
	 (let ((res nil))
	   (dolist (x vars res)
	     (if (or (in x ls) (null (genvar? x)))
		 (setf res 't)))))))
  



(defun change-free-new (pred sb)
"Changes the free and non-generated vars in pred with new generated ones"
  (let ((result nil)
	(rs nil)
	(fr (append (selectbody-argl sb)
		    (selectbody-resl sb)))
	(alias nil)
	(subst nil))
    (do ((vars (predicate-variables pred))
    ;;(do ((vars (set-difference pred (list(car pred))))
	 (x nil)
	 (varch nil)
	 (chpred pred))
	( (eq nil (car vars)))
      (setq x (car vars))
      (if (or (in x fr) (null (genvar? x)));;if the pred.variable is free or non-generated
	  (progn
	    (setf alias (alias-var x sb))
	    (setf subst (subst alias x chpred))	    
	    (setq chpred subst)
	    (setq varch (predicate-variables chpred))
	   ;; (setq varch (set-difference pred (list(car chpred))))
	    (if (isublist varch fr)  ;;if there are other vars that have to be changed
		(setf rs (cons (list _=_ x alias) rs))
	      (setf rs (append (list subst (list _=_ x alias)) rs)))  )	   
	(setf rs rs) )
       (setq vars (cdr vars))
       (setq x (car vars)))
     (if (null rs)
	(setf result (list pred))
      (setf result rs))))


 
(defun genvar? (var)
"True if the var is generated variable"
  (if (and (eq 95 (char-int (mkstring var)))
	   (string-pos (mkstring var) "V"))
      t))

(defun ret-genvar (listvars)
"Retrieves the generated variables within the listvars"
  (let ((res nil))
  (dolist (x listvars res)
	  (if (genvar? x)
	      (setf res (cons x res))))))


(defun notequal (el1 el2)
"Makes a ref list of 2 generated variables that are not equal"
  (if (and (osql-variablep el1) (osql-variablep el2) (eq 95 (char-int (mkstring el1))) (eq 95 (char-int (mkstring el2))))
      (if (neq el1 el2)
	  (cons el1 el2))))

(defun notrepeat? (l)
"True if there are not duplicates in the list"
(cond ((atom l) 't)
      ((eq nil l) 't)
      (t
       (if (null (in (car l) (cdr l))) 
	   (notrepeat? (cdr l))
	   NIL))))


(defun unif-old (l1 l2)
"Prints how to substitute the generated variables belonging to the lists l1 and l2 only if l1 and l2 have the same length and do not contain diplicates"
  (if (eq (length l1) (length l2))
      (if (and (ret-genvar l1) (ret-genvar l2))
	  (if (and (notrepeat? l1) (notrepeat? l2))
	      (mapcar (function notequal) l1 l2)))))




(defun substequal-dnf (pred fr)
  "Applys substequal on each disjunct in a DNF predicate."  
  (let (res nil)
    (cond 
     ((atom pred) (setf res pred))
     ((neq (car pred) 'or) (setf res pred));;if pred is not a disjunction
     ((null (cddr pred)) (setf res (substequal (cdr pred) fr)));;if it is only one disjunct 
     ((and (eq (car pred) 'or)
	   (or (atom (cadr pred)) (atom (caddr pred))))
	      ;; (and (listp (cadr pred)) (neq (caadr pred) 'and))))
      (setf res pred));;if pred is a simple disjunction
     (t 
      (dolist (d (cdr pred))
	(setf res (cons (substequal d fr) res)))
      (orify (reverse res))))))
    


(defun rewritesubst-dnf (pred sb)
  (let ((fr (append (selectbody-argl sb)
		    (selectbody-resl sb)))
	(unif nil))
	(setf unif (unif-dnf7 pred sb))
	(setf fr (append (car unif) fr))
	(substequal-dnf (cadr unif) fr)))


(defun rewritesubst-dnf-new (pred sb)
"Applys the unification twice"
  (let ((fr (append (selectbody-argl sb)
		    (selectbody-resl sb)))
	(subeq nil)
	(unif2 nil)
	(unif nil))
	(setf unif (unif-dnf6 pred sb))
	(setf fr (append (car unif) fr))
	(setf subeq (substequal-dnf (cadr unif) fr))
	(setf unif2 (unif-dnf6 subeq sb))
	(setf fr (append (car unif2) fr))
	(substequal-dnf (cadr unif2) fr)))
	


(defun rewritesubst-dnf-new2-curr (pred sb)
"Applys the unification until the result of it stops changing "
  (let ((fr (append (selectbody-argl sb)
		    (selectbody-resl sb)))
	(unif (unif-dnf7 pred sb))
	(subeq nil)
	(subeq2 nil)
	(unif2 nil)
	(fr2 nil))
        (setq fr (append (car unif) fr))    
	(setf subeq (substequal-dnf (cadr unif) fr))
	(setf unif2 (unif-dnf7 subeq sb))
	(setf fr2 (append (car unif2) fr))
	(setf subeq2 (substequal-dnf (cadr unif2) fr2))
    (do ((result subeq);;the 1st susbstequal-dnf
	 (unif22 unif2);;2nd unif
	 (fr22 fr2)
	 (result2 subeq2));;2nd sustequal-dnf
	( (equal result result2) result)
      (setq result result2)
      (setq unif22 (unif-dnf7 result sb))
      (setq fr22 (append (car unif22) fr22))
      (setq result2 (substequal-dnf (cadr unif22) fr22))) ))

(defun rewritesubst-dnf-new2 (pred sb)
"Applys the variable normalization 3 times "
  (let ((fr (append (selectbody-argl sb)
		    (selectbody-resl sb)))
	(unif nil)
	(result pred)
	(result2 nil))
    (dotimes (count 3 result2)
      (setq unif (unif-dnf7 result sb))
      (setq fr (append (car unif) fr))
      (setq result (substequal-dnf (cadr unif) fr))      
      ;;(help)
      (setq result2 result))))
      
(defun push-subjects (pred sb) 
  (cond 
   ((atom pred) nil)
   ((neq (car pred) 'or) nil);;if pred is not a disjunction
   ((null (cddr pred)) nil);;if it is only one disjunct
   ((and (eq (car pred) 'or)
	 (or (atom (cadr pred)) (atom (caddr pred))))
    nil)
   (t 
     (setq subjects nil)
     (dolist (d (cdr pred));;loops through DNF pred
       (let ((rowid nil)
	       (vect nil ))
	 (dolist (rd d );;loops through disjuncts
	   (if (leaf-predicate-p rd)
	       (progn
		 (if (eq 'CHARSTRING.VECTOR.ROWID->CHARSTRING (oid-name (car rd)));;if rd is a rowid 
		     (if (eq (car (last rd)) (car (selectbody-resl sb)));;if there is a subject position in rd
			 (if (null (in rd rowid))
			     (push rd rowid))))
		 (if (and (eq 'VECTOR (oid-name (car rd)));;push all vectors first
			  (null (in rd vect)))
		     (push rd vect)))));;close inner loop
	 (dolist (vecel vect)	  
	   (dolist (rowidel rowid)
	     (if (and (eq (second vecel) (third rowidel))
		      (null (member vecel subjects)))
		 (push vecel subjects))
	     (if (null (member rowidel subjects))
		 (push rowidel subjects))))));;close outer loop
     )))


(defun unif-dnf7 (pred sb)
  "Unify 2 terms in a DNF predicate using inferequals; "
   "Works even if the disjunct is not a conjunction"  
   "date: 120209 "
  (cond 
   ((atom pred) (list nil pred))
   ((neq (car pred) 'or) (list nil pred));;if pred is not a disjunction
   ((null (cddr pred)) (list nil pred));;if it is only one disjunct
   ((and (eq (car pred) 'or)
	 (or (atom (cadr pred)) (atom (caddr pred))))
	    ;; (and (listp (cadr pred)) (neq (caadr pred) 'and))))
    (list nil pred));;if pred is a simple disjunction
   (t 
    (let ((ht (make-hash-table :test (function equal)))
	   (elem nil)
	  (htk nil)
	  (midres nil)
	  (res nil)
	  (frees nil)
	  (res1 nil))
      (dolist (d (cdr pred) res)
	(if (listp (second d)) ;;goes through d only if d is a conjunction
	   (progn
	     (dolist (rd d res1)
	     (if (leaf-predicate-p rd);;goes through rd only if it is a leaf predicate
		(progn
		  (cond
		   ((or (eq 'VECTOR (oid-name (car rd)));;if rd is vector 
			(eq 'LITERAL.CHARSTRING.VALUEID->CHARSTRING (oid-name (car rd))) ;;if rd is valueid
			(eq 'BAG.OBJECT.OPTIONAL->OBJECT (oid-name (car rd))) );; if rd is optional
		    (setf htk (list (car rd) (cadr rd))));;then the key of ht =(oid-name, 1st var)
		   ((eq 'CHARSTRING.VECTOR.ROWID->CHARSTRING (oid-name (car rd)));;if rd is a rowid 
		    (if (null (genvar? (last rd)));;if the last var of rd is not generated, i.e. it's free 
			(setf htk (append (set-difference rd (predicate-variables rd)) (last rd)))
		      (setf htk (set-difference rd (predicate-variables rd)))) )
		   (t
		    (setf htk (set-difference rd (predicate-variables rd)))));;if rd is not a vector or valueid		 
		(if (gethash htk ht);;checks whether there is an element in the ht with key=htk
		    (if (hasuniquecommonvar (gethash htk ht) rd);;if yes checks whether the terms are unifiable
			(progn;; if yes unify them
			  (setf midres (inferequals (list rd (gethash htk ht))))			 
			  (dolist (el midres)
			    (setf res1 (cons el res1))
			    (if (eq (first el) _=_)
				(setf frees (adjoin (second (predicate-variables el)) frees))))	  );;addds to the free vars
		      (setf res1 (cons rd res1)))	    
		    (if (core-cluster-fn? (predicate-operator rd)) ;;if it is a core-cluster fn
			(progn
			  (setf midres (change-free-new rd sb))
			  (dolist (el midres)
			    (setf res1 (cons el res1))
			    (if (eq (first el) _=_)
				(setf frees (adjoin (second (predicate-variables el)) frees)));;adds to the free vars	    
			    )
			  (setf (gethash htk ht) (car midres))  );;puts the new pred in the ht
		      (progn;;if it is not a core-cluster fn and the terms are not unifiable
			 (setf (gethash htk ht) rd)
			 (setf res1 (cons rd res1)) )  ) ) )
		(setf res1 res1) ) )
	    (setf res (orify (list res (andify (reverse res1))))))
	    (setf res (cons 'OR (list d)))) ;;if d is not a conjunction
	(setf res1 nil))
      (setf res (list frees res))))))

(defun unif-dnf7-02 (pred sb)
  "Unify 2 terms in a DNF predicate using inferequals; "
   "Works even if the disjunct is not a conjunction"  
   "date: 120225"
  (cond 
   ((atom pred) (list nil pred))
   ((neq (car pred) 'or) (list nil pred));;if pred is not a disjunction
   ((null (cddr pred)) (list nil pred));;if it is only one disjunct
   ((and (eq (car pred) 'or)
	 (or (atom (cadr pred)) (atom (caddr pred))))
	    ;; (and (listp (cadr pred)) (neq (caadr pred) 'and))))
    (list nil pred));;if pred is a simple disjunction
   (t 
    (let ((ht (make-hash-table :test (function equal)))
	   (elem nil)
	  (htk nil)
	  (midres nil)
	  (res nil)
	  (frees nil)
	  (res1 nil))
      (dolist (d (cdr pred) res)
	(if (listp (second d)) ;;goes through d only if d is a conjunction
	   (progn
	     (dolist (rd d res1);;goes throug each predicate rd in d
	     (if (leaf-predicate-p rd);;goes through rd only if it is a leaf predicate
		(progn
		  (cond
		   ((or (eq 'VECTOR (oid-name (car rd)));;if rd is vector 
			(eq 'LITERAL.CHARSTRING.VALUEID->CHARSTRING (oid-name (car rd))) ;;if rd is valueid
			(eq 'BAG.OBJECT.OPTIONAL->OBJECT (oid-name (car rd))));; if rd is optional
		    (setf htk (list (car rd) (cadr rd))));;then the key of ht =(oid-name, 1st var)
		   (t
		    (setf htk (set-difference rd (predicate-variables rd)))));;if rd is not a vector or valueid or optional		 
		(if (gethash htk ht);;checks whether there is a record in ht with key=htk
		    (if (hasuniquecommonvar (gethash htk ht) rd);;if yes checks whether ht record and rd are unifiable
			(progn;; if yes unify them
			  (setf midres (inferequals (list rd (gethash htk ht))))			 
			  (dolist (el midres)
			    (setf res1 (cons el res1))
			    (if (eq (first el) _=_)
				(setf frees (adjoin (second (predicate-variables el)) frees))) ));;addds to the free vars
		      (setf res1 (cons rd res1)))	    
		    (if (or (core-cluster-fn? (predicate-operator rd));;if rd is a core-cluster 
			    (eq 'CHARSTRING.VECTOR.ROWID->CHARSTRING (oid-name (car rd))));;if rd is a rowid
			(progn;;replace free vars in rd with generated ones
			  (setf midres (change-free-new rd sb))
			  (dolist (el midres)
			    (setf res1 (cons el res1))
			    (if (eq (first el) _=_)
				(setf frees (adjoin (second (predicate-variables el)) frees)));;adds to the free vars	    
			    )
			  (setf (gethash htk ht) (car midres)))			  
		      (progn;;if rd is not a core-cluster neither rowid, and there is not record in ht
			(setf (gethash htk ht) rd)
			(setf res1 (cons rd res1)))))
		(setf res1 res1) ) ))
	    (setf res (orify (list res (andify (reverse res1))))))
	    (setf res (cons 'OR (list d)))) ;;if d is not a conjunction
	(setf res1 nil))
      (setf res (list frees res))))))


(defun unif-dnf7_03 (pred sb)
  "Unify 2 terms in a DNF predicate using inferequals; "
   "Works even if the disjunct is not a conjunction"  
   "date: 120309"
  (cond 
   ((atom pred) (list nil pred))
   ((neq (car pred) 'or) (list nil pred));;if pred is not a disjunction
   ((null (cddr pred)) (list nil pred));;if it is only one disjunct
   ((and (eq (car pred) 'or)
	 (or (atom (cadr pred)) (atom (caddr pred))))
	    ;; (and (listp (cadr pred)) (neq (caadr pred) 'and))))
    (list nil pred));;if pred is a simple disjunction
   (t 
    (let ((ht (make-hash-table :test (function equal)))
	   (elem nil)
	  (htk nil)
	  (midres nil) (mid nil)
	  (res nil)
	  (frees nil)
	  (res1 nil))
      (dolist (d (cdr pred) res)
	(if (listp (second d)) ;;goes through d only if d is a conjunction
	   (progn
	     (dolist (rd d res1);;goes throug each predicate rd in d
	       (if (leaf-predicate-p rd);;goes through rd only if it is a leaf predicate
		   (progn		   
		      (cond
		       ((or ;;(eq 'VECTOR (oid-name (car rd)));;if rd is vector 
			    (eq 'LITERAL.CHARSTRING.VALUEID->CHARSTRING (oid-name (car rd))) ;;if rd is valueid
			    (eq 'BAG.OBJECT.OPTIONAL->OBJECT (oid-name (car rd))));; if rd is optional
			(setf htk (list (car rd) (cadr rd))));;then the key of ht =(oid-name, 1st var)
		       ((eq 'VECTOR (oid-name (car rd)));;if rd is vector 
			(setf htk (list (car rd) (caddr rd))));;then the key of ht =(oid-name, 2nd var)
		       ((or (core-cluster-fn? (predicate-operator rd));;if rd is a core-cluster or
			    (eq 'CHARSTRING.VECTOR.ROWID->CHARSTRING (oid-name (car rd))));;if rd is a rowid
			(progn
			  (if (member 'NIL (mapcar (f/l (el) (genvar? el)) (predicate-variables rd)))
				  ;; (null (gethash (set-difference rd (predicate-variables rd)) ht) ))
			      (progn
				(setf midres (change-free-new rd sb));;replace free vars in rd with generated ones
				(setf rd (car midres))
				 (setf htk (set-difference (car midres) (predicate-variables (car midres)))))
			    (progn
			      (setf midres (list rd))
			      (setf htk (set-difference rd (predicate-variables rd))))) ))
			(t
			 (setf htk (set-difference rd (predicate-variables rd)))));;if rd is not a vector or valueid or optional
		      (if (gethash htk ht);;checks whether there is a record in ht with key=htk
			  (progn
			    (if (eq (oid-name (car (gethash htk ht))) (oid-name (car rd)))
			      (if (hasuniquecommonvar (gethash htk ht) rd);;if yes checks whether ht record and rd are unifiable 
				  (progn;; if yes unify them
				    (setf mid (inferequalsss (list rd (gethash htk ht))))
				    (dolist (el mid)
				      (setf res1 (cons el res1))
				      (if (eq (first el) _=_)
					  (setf frees (adjoin (second (predicate-variables el)) frees))) ))
				(setf res1 (cons rd res1)) )
			    ;;(if (second midres);;not unifiable and if rs is rowid or CC transformed
				;;(dolist (el midres)
				 ;; (setf res1 (cons el res1))
				 ;; (if (eq (first el) _=_)
				   ;;   (setf frees (adjoin (second (predicate-variables el)) frees))))
			    (setf res1 (cons rd res1)) ));not unifiable
			(progn ;;no record in ht with key=htk
			  (if (second midres);;if rd is rowid or CC transformed
			      (progn
				(setf (gethash htk ht) (car midres))
				(dolist (el midres)
				  (setf res1 (cons el res1))
				  (if (eq (first el) _=_)
				      (setf frees (adjoin (second (predicate-variables el)) frees))));;adds to the free vars
				(setf midres nil))
			    (progn;;rd is not rowid or CC transformed
			         (setf (gethash htk ht) rd)
				 (setf res1 (cons rd res1))) ))))  ;;close progn before leaf-predicate
		 (setf res1 res1 )));;close internal loop
	     (setf res (orify (list res (andify (reverse res1))))))
	  (setf res (cons 'OR (list d)))) ;;if d is not a conjunction
	(setf res1 nil));;close external loop
      (setf res (list frees res))   (help)     ))))


(defun inferequalsss (predlist)
  (inferequals predlist))

(defun hasuniquecommonvarss (pred1 pred2)
  (hasuniquecommonvar pred1 pred2))






(defun compile_phase2 (pred resl argl quantl quantdecl fno sb)
  "Query simplification, view expansion, normalization, optimization"
  ;; The dynamicaly bound *bindings* and *locals* must be set before invoking
  ;; this function
  (let* (*coerced_input* 
	 *extendedResult* *extendedVars*
	 (bndl (append argl resl (union quantl *locals*)))
	 )
    (setq pred (andify (compilepredicate pred fno)));; Generate TR pred
    (check-unbound-var quantdecl pred nil)
    (if _save-intermediates_ (setf (selectbody-unoptimized sb) pred))

    (setq pred (rewrite-before-view-expansion pred sb))
    (setf (selectbody-orgpred sb) pred);; This version used by view expansion
    (update-locals sb quantl)
    (update-locals sb *locals*)

    (setq pred (expand-predicate pred nil));; View expansion
    (if _save-intermediates_ (setf (selectbody-expanded sb) pred))

    (setq pred (rewrite-after-view-expansion pred sb))
    (if _save-intermediates_ (setf (selectbody-expanded-simplified sb) pred))   

    ;; Normalize to DNF
    (if *use-dnf* (setq pred (transformpredicate pred)))
    (if _save-intermediates_  (setf (selectbody-normalized sb) pred))
    (if (and *use-dnf* _rewrite_filter_ ) (setq pred (rewrite-extra-dnf 'rewrite-filter pred NIL)));;rewrite FILTER on object
    (setq pred (rewrite-after-normalization pred sb))  
    (if (and *use-dnf* _sch_) (setq pred (rewrite-extra-dnf 'rewrite-sview-and-rowid pred NIL)));;if s- view in a unsuitable conjunction with rowid 
    (if (and  *use-dnf* _elcon_ifnounif_) (setq pred (eliminate-con-ifnounif-disj pred  (selectbody-resl sb))));;needed for  { <URI> ?p1 ?s. ?s ?p ?o }
    (if (and *use-dnf* _unif_ ) (setq pred (rewritesubst-dnf-new2 pred sb)));;unify predicates names
    (if (and *use-dnf* _gct_  ) (setq pred (gct pred (function source-fetcher )))) ;apply GCT 
    (setf (selectbody-pred sb) (if pred (copy-tree pred) 'TRUE))
    (update-locals sb *locals*)
    (cond (*skip-optimization* nil)
	  (t      
	   ;;To expand the templates of the input variables
	   ;;These are not expanded because 
	   ;;   they should be so in selectbody-pred
	   (setq pred (process_typechecks pred sb argl resl nil))
	   (optimize-pred pred sb fno);; Coercion and cost-based optimization
	   (cond ((not (expand-views?))
		  (setf (selectbody-delpred sb);;Update template
			(create-delpred (selectbody-optpred sb)))
		  sb))))))
		       
;;(advise-around 'transformpredicate '(gct * (function source-fetcher)))








