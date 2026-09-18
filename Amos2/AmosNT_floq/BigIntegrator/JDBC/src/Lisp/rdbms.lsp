;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) <year>2012  <author>Minpeng Zhu, UDBL
;;; $RCSfile: rdbms.lsp,v $
;;; $Revision: 1.28 $ $Date: 2012/08/08 08:32:33 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: JDBC wrapper's absorber (absorb-sql) and 
;;;                             finalizer (translate-sql)
;;; =============================================================

(defun nonnuminferable-p (pred joinvarlist absorbedpreds)
  "suppose joinvarlist is (V8, V2) and pred is (< V6 30000). V6 is 
   not in joinvarlist, but V6 is in at least one pred's argument list 
   of numinferpreds. e.g
   suppose joinvarlist is (SQL:L.TIME SQL:L.MACHINE SQL:L.POWCON) and pred
   is (> SQL:L.POWCON _V6). L.Powcon is in ccvar, v6 is in numinferpreds.
   theta join pred (> v8 v6), numleaf pred (> v6 30000)"
  (let ((predarglist (predicate-arguments pred))
	)
    (or 
     ;;(< V8 30000) and thetha join (> V8 V6)
     (some (f/l (var)
		(member var joinvarlist))
	   predarglist)
     ;;num leaf pred (> v6 30000)
     (some (f/l (absorbedpred) 
		(some (f/l (var) (if (varsymbolp var)
				     (member var (predicate-arguments 
						  absorbedpred))))
		      predarglist))
	   absorbedpreds))	  
    ))


(defun sp-infer-numpred-p (numpred filtervarlist)
  "If every var in numpred is in filtervarlist, then return true
   e.g (v8 v2) filtervarlist (plus v8 v8 40000) numpred"
  (every (f/l (var) (member var filtervarlist))
	 (mapfilter (f/l (var) (varsymbolp var))
		    (predicate-arguments numpred))))


(defun redundantnumpredp (joinvarlist predscopy pred)
  "absolute operation produces redundant num pred e.g  (+ _V9 _V10 0),
   (+ v9 10 0). A num pred is redundant if all its var that doesn't exist
   in joinvarlist and not exist in any of the other preds."
  (let* ((numpredarglist (predicate-arguments pred))
	 (numpredvarlist (subset numpredarglist 
				 (f/l (arg) (not (constantp arg)))))
	 )  
    (every (f/l (v) (if (and (varsymbolp v)
			     (not (member v joinvarlist)))
			(notany (f/l (rpred)
				     (member v (predicate-arguments rpred)))
				(remove pred predscopy))
		      ))
           numpredvarlist)
    
    )) 


  
(defun numinferable-p (joinvarlist pred absorbedNSPs)
  "judge whether the inference numerical pred is absorbable or not. The pred 
   either has at least one var common with any of the already absorbed 
   numinferpreds or in case if numinferpreds is nil, then the pred has at 
   least one var in common with joinvarlist and its operator is in the 
   absorbability list"
  (let ((predarglist (predicate-arguments pred))
	)
    (or 
     ;;The pred has at least one var common with any of the already 
     ;;absorbed numinferpreds. e.g (v8 v2) cc-varlist 
     ;;((plus 100 v4 v2)) numinferpreds, (times 2 v5 v4) pred
     (some (f/l (absorbedNSP) 
		(some (f/l (var) (if (varsymbolp var)
				     (member var (predicate-arguments 
						  absorbedNSP))))
		      predarglist))
	   absorbedNSPs)
     ;;In case if numinferpreds is nil, The pred has at least one var in 
     ;;common with joinvarlist and its operator is in the absorbability 
     ;;list e.g (v8 v2) cc-varlist    (plus 100 v4 v2) pred
     (some (f/l (var)
		(member var joinvarlist))
	   predarglist)
     ;;In case if numinferpreds is nil, the pred has at least one var in
     ;;common with absorbedNSPs. e.g (< SQL:L.POWCON _V6) absorbedNSPs
     ;;(plus 500 _V7 _V6)
     (some (f/l (absorbedNSP)
		(some (f/l (var) (if (varsymbolp var)
				     (member var (predicate-arguments
						  absorbedNSP))))
		      predarglist))
	   absorbedNSPs)
     )
    ))

(defun thetajoinp (arglist absorbedpreds joinvarlist)
  "e.g sp1(v1 * * v3) sp2(v2 * v4 * v5) nsp1(> v1 v2). the case is sp1 tries 
   to absorb sp2, pred is like sp2, absorbedpreds is nsp1(> v1 v2),
   joinvarlist is (v1 v3). sp1 and sp2 don't have a common var, but sp2 
   should be absorbed for sp1."
  (mapfilter (f/l (pred)
		  (let ((op (generic-fnname (predicate-operator pred)))
			(arg1 (predicate-argument 1 pred))
			(arg2 (predicate-argument 2 pred)))
		    (and (memq (generic-fnname (car pred)) '(< <= > >= !=))
			 (and (varsymbolp arg1) (varsymbolp arg2))
			 (or (and (member arg1 joinvarlist)
				  (member arg2 arglist))
			     (and (member arg1 arglist)
				  (member arg2 joinvarlist)))))
		  absorbedpreds)))

(defun absorbSPp (ds joinvarlist pred env absorbedpreds)
  "absorb a Source Predicate if it shares at least a var with this pred and 
   they head to the same datasource. 
   Or 
   absorb a Source Predicate if they head to the same datasource and there 
   is a thetha join pred link them (theta join)"
  (let* ((op (predicate-operator pred))
	 (arglist (remove '* (predicate-arguments pred)))
	 (ds1 (get-datasource op))
	 )
    (and (eq ds ds1)
	 (or 
	  (some (f/l (var) (varsymbolp var))  
		(intersection (remove '* joinvarlist) 
			      (remove '* arglist)))
	  (and 
	   (notany (f/l (var) (varsymbolp var))
		   (intersection (remove '* joinvarlist)
				 (remove '* arglist)))
	   (thetajoinp arglist absorbedpreds joinvarlist))))
    ))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SQL absorber;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun absorb-sql (pred preds ds env)
  "Do fixed point iteration to absorb the source predicates,e.g equal join
   or thetha join source predicate, and absorb the non-source predicates. 
   After relaxing the absorbing rule, numerical predicates with at least one 
   variable common with the already absorbed predscan be absorbed."
  (let* ((change t)
	 (joinvarlist (mapfilter (f/l (arg) (osql-variablep arg))  
				 (predicate-arguments pred)))
	 (newrest preds)
	 (predscopy preds)
	 (unabsorbedpreds (tconc))
	 (absorbedSPs (tconc))
	 (absorbedNSPs (tconc))
	 (abslist (mapcar (f/l (l) (list (getobject (car l) 'name)))
			  (get-absorbability ds)));;absorbability list of a ds
	 )
    (update-environment pred env);;update pred into env
    (while change
      (setq unabsorbedpreds (tconc))
      (setq change nil)
      (dolist (opred preds)
	(cond ((compound-p opred))
	      ((equal opred t));;t
	      (t 
	       (update-environment opred env)   
	       (cond ((sourcepred? (predicate-operator opred))
		      (cond ((absorbSPp ds joinvarlist opred env 
					(append (car absorbedSPs)
						(car absorbedNSPs)))
			     (setq joinvarlist (append joinvarlist
						      (remove '* (cdr opred))))
			     (tconc absorbedSPs opred);;absorb equal join SP
			     ;;remove absorbed source predicate
			     (setq newrest (remove opred newrest))
			     (setq change t))
			    (t (tconc unabsorbedpreds opred))))
		     (t;;non source predicates
		      (let* ((op (predicate-operator opred))	     
			     (opname (getobject op 'name)))
			(if (member (list opname) abslist);;op in absorbability
			    (cond ((not (arithmeticp opred)) 
				   (cond ((nonnuminferable-p opred joinvarlist
					             (append (car absorbedSPs)
							  (car absorbedNSPs))) 
					  ;;pred has varlist (< V8 30000)
					  (tconc _absorbedPreds_ opred)
					  (tconc absorbedNSPs opred)
					  (setq change t))
					 (t (tconc unabsorbedpreds opred))))
				  ((arithmeticp opred)
				   (cond ((numinferable-p joinvarlist opred
							  (car absorbedNSPs))
					  ;;((plus 100 v4 v2)), (times 2 v5 v4)
					  (tconc _absorbedPreds_ opred)
					  (tconc absorbedNSPs opred)
					  (setq change t))
					 ((sp-infer-numpred-p opred 
							      joinvarlist)
					  ;;(plus v8 v8 40000)
					  (tconc _absorbedPreds_ opred)
					  (tconc absorbedNSPs opred)
					  (setq change t))
					 ;;e.g (+ v9 10 0)
					 ((redundantnumpredp joinvarlist  
							     predscopy opred)
					  (setq newrest (remove opred newrest))
					  (setq change t))
					 (t (tconc unabsorbedpreds opred))))
				  (t (tconc unabsorbedpreds opred))))))))))
      (setq preds (car unabsorbedpreds))) 
    (setf (gethash 'accessfiltervarlist env) (unique joinvarlist)) 
    (setf (gethash 'preds env) predscopy)
    (list (append (list pred)(car absorbedSPs)(car absorbedNSPs)) newrest)))




(osql "create function sqlq_cost(function,vector,vector)->(integer,integer) as select 100,100;")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SQL finalizer;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun translate-sql (ds queryinfo filtervarlist) 
  "Each wrapper has a finalizer, which is a plug-in that translates 
   each access filter in the plan to an algebra operator called an 
   interface function, specific for each kind of source. The interface 
   function sends a query to the data source (i.e. a SQL query)."
  (let ((dsname (oid-name ds))
	(env (sqlquery-environment queryinfo)) 
	queryfn sqlquery invars outvars sql-algebra-op
	)
    (setq queryfn (create-specialized-query-fn ds env queryinfo))
    (setq sqlquery (sqlquery-sqlstring queryinfo)) 
    (setq invars (sqlquery-input queryinfo))
    (setq outvars (sqlquery-output queryinfo))
    (declarecosts queryfn '*any* 'sqlq_cost)
    (/putobject 
     queryfn 'name
     (concat "sql@" dsname ":'" sqlquery "'" (or invars "()") "->" 
	     (or outvars "()")))
    (/putobject queryfn 'sqlquery queryinfo)
    (setq sql-algebra-op 
	  `((, _apply_pred_ , queryfn ,@ invars ,@ outvars)))
    ))