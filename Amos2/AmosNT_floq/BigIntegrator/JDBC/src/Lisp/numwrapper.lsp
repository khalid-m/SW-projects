;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Thanh Truong, Minpeng Zhu UDBL
;;; $RCSfile: numwrapper.lsp,v $
;;; $Revision: 1.10 $ $Date: 2012/08/07 07:03:17 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Numerical expression involving inequality should
;; be pushed to SQL string if possible
;;; =============================================================

(defglobal _num-plus_ 
  (getfunctionnamed 'NUMBER.NUMBER.PLUS->NUMBER))

(defglobal _num-minus_ 
  (getfunctionnamed 'NUMBER.NUMBER.MINUS->NUMBER))

(defglobal _num-times_ 
  (getfunctionnamed 'NUMBER.NUMBER.TIMES->NUMBER))

(defglobal _num-division_ 
  (getfunctionnamed 'NUMBER.NUMBER.DIV->NUMBER))


(defun relational-translate-numop (ds pred env sqlq)
  (let* ((arg1 (predicate-argument 1 pred))
         (arg2 (predicate-argument 2 pred))
         (arg3 (predicate-argument 3 pred))
	 (type1 (get-type arg1 env))       
         (type2 (get-type arg2 env))
         (type3 (get-type arg3 env))
	 (ds1 (if (varsymbolp arg1) (datasource arg1 env)))
	 (ds2 (if (varsymbolp arg2) (datasource arg2 env)))
	 (ds3 (if (varsymbolp arg3) (datasource arg3 env)))
	; at least one argument in a comparison must be a variable from the
        ; source, otherwise there's not much point in pushing the comparison.
	 (ok (or (eq ds1 ds) (eq ds2 ds)(eq ds3 ds))))
    ; at this point one variable may not come from the source. Hence, 
    ; it is an input parameter to the absorbed query fragment.
    ; Bug in generic grouper (TR) (assert ok "Generic grouping did not work")
    (if (and ok (varsymbolp arg1) (neq ds1 ds)) (sqlquery-add-input sqlq arg1))
    (if (and ok (varsymbolp arg2) (neq ds2 ds)) (sqlquery-add-input sqlq arg2))
    (if (and ok (varsymbolp arg3) (neq ds3 ds)) (sqlquery-add-input sqlq arg3))
	  
    ; either way, we have decided whether to absorb or not by now
    (if ok (sqlquery-add-predicate sqlq pred))))

(defun relational-translate-in (ds pred env sqlq)
  (let* ((arg1 (predicate-argument 1 pred))
         (arg2 (predicate-argument 2 pred))
	 (type1 (get-type arg1 env))       
         (type2 (get-type arg2 env))
	 (ds1 (if (varsymbolp arg1) (datasource arg1 env)))
	 (ds2 (if (varsymbolp arg2) (datasource arg2 env)))
	; at least one argument in a comparison must be a variable from the
        ; source, otherwise there's not much point in pushing the comparison.
	 (ok (or (eq ds1 ds) (eq ds2 ds))))
    ; at this point one variable may not come from the source. Hence, 
    ; it is an input parameter to the absorbed query fragment.
    ; Bug in generic grouper (TR) (assert ok "Generic grouping did not work")
    (if (and ok (varsymbolp arg1) (neq ds1 ds)) (sqlquery-add-input sqlq arg1))
    (if (and ok (varsymbolp arg2) (neq ds2 ds)) (sqlquery-add-input sqlq arg2))
	  
    ; either way, we have decided whether to absorb or not by now
    (if ok (sqlquery-add-predicate sqlq pred))))

(defun arithmeticp (pred)
  ;; TRUE if pred is an arithmetic predicate (plus, minus, times, div)
  (in (predicate-operator pred)  
      (list _num-plus_ _num-minus_ _num-times_ _num-division_)))
	  
(defun obsoletednumpredp (bnd joinvarlist predscopy pred)
  "absolute operation produces redundant num pred e.g  (+ _V9 _V10 0), 
   (+ v9 10 0). A num pred is obsoleted if it has some var that only exist 
   in num pred itself and not in any of the other preds."
  (let* ((numpredarglist (predicate-arguments pred))
	 (numpredvarlist (subset numpredarglist 
				 (f/l (arg) (not (constantp arg)))))
	 (boundvarlist (append joinvarlist bnd))
	 )
	   
    (some (f/l (v) (if (and (varsymbolp v)
			    (not (member v boundvarlist)))
		       (notany (f/l (rpred)
				    (member v (predicate-arguments rpred)))
			       (remove pred predscopy))
		     ))
	  numpredvarlist)
    )) 

(defun get-argnumpred (arg numpreds preds accessfiltervarlist bnd)
  (let* ((argnumpreds (subset numpreds 
			      (f/l (numpred) 
				   (member arg 
					   (predicate-arguments numpred)))))
	 )  
    (car (subset argnumpreds (f/l (argnumpred) 
				  (not (obsoletednumpredp bnd
							  accessfiltervarlist 
							  preds argnumpred)))))
))


(defun indirect-reachability (ds arg pred env numpreds)
  (let* ((bnd (gethash 'prebnd env))
	 (accessfiltervarlist (gethash 'accessfiltervarlist env))
	 (preds (gethash 'preds env))
	 
	 (argnumpred (get-argnumpred arg numpreds preds accessfiltervarlist 
				     bnd))
	 numpredarglist lvars res cc-var rc-var)   
    (if argnumpred
	(setq numpredarglist (predicate-arguments argnumpred)))
    (setq lvars (remove arg numpredarglist))
      
    (if (neq argnumpred pred)	
	(progn
	  ;; eliminate constant
	  (setq lvars (subset lvars (f/l (var) (not (constantp var)))))  
	  ;; If one of orgpred's arguments  from cc or
	  ;; from function input and that arg is not from accessfiltervarlist
	  (setq cc-var 
		(car 
		 (subset 
		  lvars
		  (f/l (var)
		       (and argnumpred
			(arithmeticp argnumpred)
			(varsymbolp var)
			(datasource var env))))))
	  ;; (+ x v4 30000) and x is the function input, v4 is intermediate var
	  (setq rc-var
		(car
		 (subset
		  lvars
		  (f/l (var)
		       (and argnumpred
			    (arithmeticp argnumpred)
			    (varsymbolp var)
			    (member var bnd)
			    (not (member var accessfiltervarlist)))))))
	  
	  (cond  ((and argnumpred
		   (arithmeticp argnumpred)  lvars cc-var) ;; found cc-var
		  (list (datasource cc-var env) cc-var))
		 ((and argnumpred
		       (arithmeticp argnumpred)  lvars rc-var) ;; found rc-var
		  (list nil rc-var))
		 ((and (member arg bnd) (neq (datasource arg env) ds))
		  ;;for multidatabase theta join
		  (list nil arg))
		 ((and (neq lvars nil)
		       (arithmeticp argnumpred))
		  ;; recursive call
		  (while (and (eq res nil) lvars)	      
		    (setq numpreds (remove argnumpred numpreds))
		    (setq res (indirect-reachability ds (car lvars) argnumpred 
						     env numpreds))
		    (setq lvars (cdr lvars)))	    
		  res)
		 (t nil))))))


(defun direct-reachability (arg env)
  (if (and (varsymbolp arg) (gethash arg env)) 
      (datasource arg env)))


(defun reachable-from-cc (arg pred env queryinfo)
  ;; Rechability from cc is either directly or indirectly
  (let* ((ds (sqlquery-datasource queryinfo))
	 (numpreds (sqlquery-numpreds queryinfo))
	 (argds (direct-reachability arg env)));;direct reachability from ccfn?
    (if (and (eq argds nil) (varsymbolp arg))
	(indirect-reachability ds arg pred env numpreds);;indirect reachbility?
      (list argds arg))))

(defun relational-translate-comparison-relaxing (ds pred env sqlq)
  ;; Inference on predarg1 predarg2 to see if any of the two arguments coming
  ;; from a core cluster function (datasource)
  ;; Unlike relational-translate-comparison, this translation is a bit
  ;; relaxing. One of two arguments of the pred must be reachable from the
  ;; source.
  ;; Reachability means calculating by a sequences of arithmetic predicates
  (let* ((arg1 (predicate-argument 1 pred))
         (arg2 (predicate-argument 2 pred))
	 rc1 rc2 rc )

    ;; If arg1,arg2 is reachable from cc ?
    (setq rc1 (reachable-from-cc arg1 pred env sqlq))
    (setq rc2 (reachable-from-cc arg2 pred env sqlq))
 
    ;; Push this pred if one of two arguments is reachable from cc
    (setq rc (or (eq (first rc1) ds) (eq (first rc2) ds)))
    ;; If an argument is not computed from cc, it is an input of
    ;; this pred
    (if (and rc (varsymbolp  arg1)
	     (varsymbolp (second rc1))
	     (neq (first rc1) ds))
	  (sqlquery-add-input sqlq arg1))


    (if (and rc (varsymbolp  arg2)
	     (varsymbolp (second rc2))
	     (neq (first rc2) ds))
	(sqlquery-add-input sqlq arg2))

    
    ;; Push it or not?
    (if rc (sqlquery-add-predicate sqlq pred))))


(defun constant-arrayp (a)
  (and (arrayp a)
       (every (f/l (e) (constantp e)) (arraytolist a))))

(defun element-in-array-to-string (e last)  
  (concat (if (stringp e) "'" "")  e (if (stringp e) "'" "")  (if (not last) "," "")))

(defun constant-array-to-string (a)
  (let* ((l (arraytolist a))
	(end (car (last l))))
    (concat "("
	    ;; all elements but not last
	    (apply 'concat (mapcar (f/l (e)
					(element-in-array-to-string e nil))
				   (butlast l)))
	    (element-in-array-to-string end t)
	    ")")))

(defun reverse-args (pred reverse)
  (if (is-true reverse)
      (cons (car pred) (reverse (cdr pred)))
    pred))
  

;; infix         : a op b = c
;; incomple infix: a op b
(defun sql-incomplete-infix-call (op q pred numpreds but-not tablealiases)
  "Construct call to infix SQL function"
  (let ((fno (predicate-operator pred))
	(pos (car (list-positions but-not pred)))
	args)
    ;(sqlquery-remove-numpred pred q)
    (setq args (sql-literal-strings q (remove but-not pred) tablealiases
				    (remove pred numpreds)))
    (if (string= op "+")
	(setq op (cond ((eq pos 3) "+") ((eq pos 2) "-") ((eq pos 1) "-"))))
    (if (string= op "*")
	(setq op (cond ((eq pos 3) "*") ((eq pos 2) "/") ((eq pos 1) "/"))))
    (if (or (eq pos 2) (eq pos 1))
	(setq args (reverse args)))
    (concat "(" (concat (infix-string op args)) ")")))







;;;;;;;;;;;;;;;;;;;;;;;;obsoleted code;;;;;;;;;;;;;;;;;;
(quote

(defglobal _initiates_ (make-hash-table))


(defun inference-origin-pred (var pred preds env)
  "Inference the origin pred of var. It is the predicate where var is actually computed." 
  (let* ((res (remove pred preds))
	 (cnnpreds (subset res (f/l (p) (in var (cdr p)))))
	 res)

    (setq res (car (subset cnnpreds
			   (f/l (p)
				(let* ((ovars (remove var (cdr p))))
				  (and (arithmeticp p)
				       (every (f/l (v)
						   (or (constantp v)
					   (gethash v env))) ovars))))
			   )))  
    (if res res pred)))


(defun get-original-pred (var env)
  (let ((varinfo (gethash var env)))
    (if varinfo
        (varinfo-origin varinfo)
      nil)))

(defun indirect-reachability (arg pred env)
  (let* (;; origin predicate 
	 (orgpred (get-original-pred arg env))
	 (orgpredarglist (predicate-arguments orgpred))
	 (firstarg (car orgpredarglist));;can be var, constant, expression ...
	 ;; list of other variables 	 
	 (lvars (remove arg orgpredarglist))
	 res cc-var)    ;;(help)
    (if (neq orgpred pred)	
	(progn
	  ;; eliminate constant--bug
	  (setq lvars (subset lvars (f/l (var) (not (constantp var)))))  
	  ;; If one of orgpred's arguments  from cc 
	  (setq cc-var 
		(car 
		 (subset 
		  lvars
		  (f/l (var)
		       (and orgpred
			(arithmeticp orgpred)
			(varsymbolp var)
			(datasource var env))))))
	  
	  (cond  ((and 
		   orgpred
		   (arithmeticp orgpred)  lvars cc-var) ;; found cc-var
		  (puthash arg _initiates_ orgpred)
		  (list (datasource cc-var env) cc-var))	   
		 ((and (neq lvars nil)
		       (arithmeticp orgpred))
		  ;; recursive call
		  (while (and (eq res nil) lvars)	      
		    (setq res (indirect-reachability (car lvars) orgpred env))
		    (if res (puthash arg _initiates_ orgpred))
		    (setq lvars (cdr lvars)))	    
		  res)
		 ((and (expression-p firstarg)
		       (member arg (cdr orgpredarglist));;(* _V6 1)
		       (expression-source firstarg));; #[OID 1501 "A"]
		  (list (expression-source firstarg) arg))
		 (t nil))))))

)