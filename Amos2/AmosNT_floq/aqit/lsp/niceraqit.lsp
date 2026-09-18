;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Thanh Truong, UDBL
;;; $RCSfile: niceraqit.lsp,v $
;;; $Revision: 1.3 $ $Date: 2012/10/10 11:46:01 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: <description>
;;; =============================================================
;;; $Log: niceraqit.lsp,v $
;;; Revision 1.3  2012/10/10 11:46:01  thatr500
;;; complete list of transformation rules
;;;
;;; Revision 1.2  2012/10/09 16:18:23  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.1  2012/10/09 07:34:10  thatr500
;;; nicer impelementation of AQIT, which consists of following key functions
;;; - main
;;; - path-finder : backtracking find a path
;;; - mover-up    : recursively move up by swapping nodes in pairwise
;;; - swapper     : swapping nodes
;;; - handle-OR   : handle OR branches
;;;
;;; Still on going
;;;
;;;
;;; =============================================================

(defparameter *enable-aqit* nil)
(defparameter *aqit-fail* nil)
(defparameter *aqit-solution* nil)
(defglobal _CC-BTREE_ (mkstring "B-tree"))

(defglobal _!=_ (getfunctionnamed 'OBJECT.OBJECT.!=->BOOLEAN))
(defglobal _<_ (getfunctionnamed  'OBJECT.OBJECT.<->BOOLEAN))
(defglobal _>_ (getfunctionnamed  'OBJECT.OBJECT.>->BOOLEAN))
(defglobal _>=_ (getfunctionnamed  'OBJECT.OBJECT.>=->BOOLEAN))
(defglobal _<=_ (getfunctionnamed  'OBJECT.OBJECT.<=->BOOLEAN))  

(defglobal _gt-comparisons_
  (list _>_  _>=_) "The gt comparisons")
(defglobal _lt-comparisons_
  (list _<_  _<=_) "The lt comparisons")

;;=================================================================
(defun aqit-tester (pred conj)
  "Event: Tester is trigger if there is a comparison in the conjunction
   Action True if there is an indexed predicate
  "
  (if *enable-aqit*  
      (subset conj
	      (f/l (p)
		   (and (ilistp p)
			(or 
			 (get-descr-index-cc _CC-BTREE_ (car p))
			 (indexes-of-kind (car p) 'MBTREE t)))))))
;;=================================================================
(defun aqit-rewriter (pred conj &optional params) 
  (aqit-transformer conj))

(defun aqit-transformer (pred)
  "Until no change do: Expose indexes in  pred.
   Success when new pred is different from original one"
  (cond ((atom pred) pred)
	((conjunctionp pred)
	 (apply-aqit (cdr pred)))
	((disjunctionp pred)
	 (let ((branches (cdr pred)) b new-b)
	   (setq b (pop branches))
	   (setq new-b (apply-aqit b))
	   ;; until one branch is success or nothing left
	   (while (and (equal b new-b)
		       (setq b (pop branches)))
	     (setq new-b (apply-aqit b)))
	   (orify (cons new-b (remove b branches)))))
	;; list of predicates
	(t (apply-aqit pred))))

(defun apply-aqit (conj)
  (let* (lidxes s path dv)
    (setq dv (simplify-division-tester conj))
    (if dv (setq conj (simplify-division-writer dv conj)))
    (setq *aqit-solution* nil)
    (setq lidxes (indexed-nodes conj)) ;; indexed nodes
    (while (and (null *aqit-solution*)
		(setq s (pop lidxes)))
      (setq path (cons s path))        ;; indexed node is starting node of path
      (path-finder path (not-indexed-preds conj)))
    (if *aqit-solution* *aqit-solution* conj)))
  
;;=================================================================
(defun path-finder (path rest)
  (cond ((not (path-complete path))   ;; not complete, should grow
	 (let ((cnnodes (connecting-nodes path rest)))
	   (dolist (n cnnodes)
	     (path-finder (cons n path) (remove (node-pred n) rest)))))
	((path-moveable? path)        ;; complete, moveable
	  (setq *aqit-solution* (mover-up path nil rest))
	  ;(help 'YY)
	  (nconc *aqit-solution* rest))
	(t  (append (cons (node-pred (second path)) 
			 (cons (node-pred (first path))
			       rest))))))

;;=================================================================
;; rest --> generated from swapper
;; ref  --> other predicates outside of original path
(defun mover-up (path rest &optional ref)   
  "Move up nodes in pair-wise."
    (cond ((stop-moving path)
	   (setq *aqit-solution* 
		 (cons (node-pred (first path))
		       (cons (node-pred (second path)) rest))))
	  ((= (length path) 2)
	   (error "Mover-up is wrong !!!" path))
	  (t
	   (let* ((resl (swapper path ref))        ;; Swap pairwise
		  acc)   
	     ;(help 'NNN)
	     (if (compound-type resl 'OR) 
		 (handle-or path rest (cdr resl) ref)
	       (progn 
		 (setq acc (append rest (cdr resl))) ;; Update rest by new generated one
		 (if (is-used? (second path) acc)
		     (setq acc (cons (node-pred (second path)) acc)))		
		 ;; remove two old nodes,and add a new one
		 (setq path (cons (make-node :pred (first resl) :var nil)
				  (cdr (cdr path))))
		 (mover-up path acc ref)))))))
;;=================================================================	  
(defun handle-or (path rest orcases ref)
  (let (newpath acc resl orresl)
    (dolist (g orcases) ;; through branches
      ;(help 'UU)
      (setq acc (append rest (cdr g)))
      (if (is-used? (second path) acc)
	  (setq acc (cons (node-pred (second path)) acc)))
      (setq newpath  (cons (make-node :pred (first g) :var nil)
			   (cdr (cdr path))))
      (setq resl (mover-up newpath acc ref))
      (if (and (ilistp resl) (length resl))
	  (setq resl (andify resl)))
      (setq orresl (cons resl orresl)))
    (list (orify orresl))))

;;=================================================================
;; Rule-based swappings (transformations)	
(defun swapper (path ref)
  (let* ((compnode (car path)) ;; comparison node
	 (comppred (node-pred compnode))
	 (arithnode (second path)) ;; arithmetic node
	 (arithpred (node-pred arithnode))
	 (arithop (predicate-operator arithpred))
	 (compop (predicate-operator comppred))
	 (var (node-var arithnode))
	 (prevvar (node-var (third path)))
	 (A (car (remove var (remove prevvar (rest arithpred)))))
	 (B (car (remove var (rest comppred))))
	 (nv (dt_genvar (type_of_var var *bindings*)))
	 nv1)
    ;;(help 'BB)
    (cond ((eq arithop _number-plus_)
	   ;;---PLUS and MINUS---
	   (cond ((member arithpred  (list (make-predicate arithop var prevvar A)
					   (make-predicate arithop prevvar var A)))
		  ;; var = A - prevvar AND var theta  B ==> prevvar theta' (A - B)
		  (list (make-predicate (inverse-comp compop) prevvar nv)
			(make-predicate _number-plus_ nv B A)))
		 
		 ((member arithpred (list (make-predicate arithop A var prevvar)
				      (make-predicate arithop var A prevvar)))
		  ;; var =  prevvar - A AND var  theta B ==> prevvar  theta A + B
		  (list (make-predicate compop prevvar nv)
			(make-predicate _number-plus_ A B nv)))

		 ((member arithpred (list (make-predicate arithop  A prevvar var)
					  (make-predicate arithop prevvar A var)))
		  ;; var = prevvar + A AND var  theta B ==> prevvar  theta B - A       
		  (list (make-predicate compop prevvar nv)
			(make-predicate _number-plus_ nv A B)))))
	  ;; ---TIMES and DIV---
	  ((eq arithop _number-times_)
	   (cond ((member arithpred  (list (make-predicate arithop prevvar A var)
					   (make-predicate arithop A prevvar var)))
		  ;; var = A * prevvar AND var theta B ==> (or prevvar theta B/A, prevvar theta' B/A)
		  (setq nv1 (dt_genvar (type_of_var var *bindings*)))	  
		  (orify (list
			  (list (make-predicate compop prevvar nv)
				(make-predicate _number-times_ nv A B)
				(make-predicate _>_ A 0))
			  (list (make-predicate (inverse-comp compop) 
						prevvar nv1)
				(make-predicate _number-times_ nv1 A B)
				(make-predicate _<_ A 0)
				))))
		 ((member arithpred  (list (make-predicate arithop var A prevvar)
					   (make-predicate arithop A var prevvar)))
		  ;; var = prevvar/A AND var theta B ==> (or (prevvar theta B*A A > 0), (prevvar theta' B*A  A < 0)
		  (setq nv1 (dt_genvar (type_of_var var *bindings*)))	  
		  (orify (list
			  (list (make-predicate compop prevvar nv)
				(make-predicate _number-times_ A B nv)
				(make-predicate _>_ A 0))
			  (list (make-predicate (inverse-comp compop) 
						prevvar nv1)
				(make-predicate _number-times_ A B nv1)
				(make-predicate _<_ A 0)
				))))
		 ((and (member arithpred  (list (make-predicate arithop var prevvar A)
						(make-predicate arithop prevvar var A)))
		       (eq B 0))
		  ;; var = A/prevvar AND var theta 0
		  ;; ==> (or (prevvar theta 0 A theta' 0)
		  ;;         (prevvar theta' 0 A theta 0))                                
		  (orify (list (list (make-predicate  compop prevvar 0)
				     (make-predicate _>_ A 0))
			       (list (make-predicate (inverse-comp compop) prevvar 0)
				     (make-predicate  _<_ A 0)))))

		 ((member arithpred  (list (make-predicate arithop var prevvar A)
					   (make-predicate arithop prevvar var A)))
		  ;(help 'BB)
		  ;; var = A/prevvar AND var theta B ==> 
		  ;;(or (prevvar theta A/B A*prevvar < 0),
		  ;;    (prevvar theta' A/B A*prevvar > 0)
		  (let ((nv2 (dt_genvar (type_of_var var *bindings*)))
			(nv3 (dt_genvar (type_of_var var *bindings*))))			
		    (setq nv1 (dt_genvar (type_of_var var *bindings*)))	  
		    (orify (list
			    (list (make-predicate  compop nv prevvar)
				  (make-predicate _number-times_ nv B A)
				  (make-predicate _number-times_ prevvar B nv1)
				  (make-predicate _>_ nv1 0))			  
			    (list (make-predicate (inverse-comp compop) nv2  prevvar)
				  (make-predicate _number-times_ nv2 B A)
				  (make-predicate _number-times_ prevvar B nv3)
				  (make-predicate _<_ nv3 0)
				  )))))

		 ))
	  ;; ---  SQRT ---
	  ((eq arithop _number-sqrt_)
	   ;; SQRT(prevvar)  theta B ==> prevvar  theta (power B 2)
	   (list (make-predicate compop prevvar nv)
		 (make-predicate _number-power_ B 2 nv)))
	  ;; ---  POWER ---
	  ((eq arithop _number-power_)
	   ;; Power(prevvar, A)  theta B ==> prevvar  theta (power B 1/A)
	   (setq nv1 (dt_genvar (type_of_var var *bindings*)))
	   (list (make-predicate compop prevvar nv)
		 (make-predicate _number-times_ nv1 A 1)
		 (make-predicate _number-power_ B nv1 nv)))	
	  ;; ---  ABS ---
	  ((eq arithop _number-abs_)
	   (cond ((or (eq compop _<_) (eq compop _<=_))
		  ;; ABS (prevvar) < B ==> prevvar > - B and prevvar < B
		  (list (make-predicate compop prevvar B)
			(make-predicate _number-plus_ nv B 0)
			(make-predicate (inverse-comp compop) prevvar nv)))
		 ((or (eq compop _>_) (eq compop _>=_))		  
		  ;; ABS (prevvar) > B ==> prevvar > B or prevvar < - B
		  (orify (list
			  (list (make-predicate compop prevvar B))
			  (list (make-predicate (inverse-comp compop) 
						prevvar nv)
				(make-predicate _number-plus_ nv B 0)
			  ))))
		  )))))

;;=================================================================	  
(defun register-aqit-rewriter ()
  "Register AQIT rewriters"
  (dolist (ineqpred _lt-comparisons_)
    (define-late-tr-rewriter (externalize ineqpred) 'aqit-tester 'aqit-rewriter))
  (dolist (ineqpred _gt-comparisons_)
    (define-late-tr-rewriter (externalize ineqpred) 'aqit-tester 'aqit-rewriter)))
;;=================================================================
;; Register AQIT rewriter
(register-aqit-rewriter)


