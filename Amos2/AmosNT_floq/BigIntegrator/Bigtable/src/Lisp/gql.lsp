(defglobal _gql_ (getfunctionnamed 'CHARSTRING.CHARSTRING.VECTOR.gql->VECTOR))

(defun Bigtableds-+ (fno name btds)
  (setq btds (or (getobjectnamed (mksymbol name) _Bigtable_ t) 
		 (/createobject 'Bigtable name)))
  (osql-result name btds))


(defun validpredp (absorbedNSPs pred ccVarList)
  "check whether the predicate is valid to be absorbed. e.g all
   equality predicates are valid, and the first inequality predicate, e.g
   (< v5 30000) or (< v5 v6), having one variable in common with the source 
   predicate is valid. If an inequality predicate is valid to be absorbed, 
   then the first inverse inequality for the same variable is also valid."
  (let ((predvarlist (mapfilter (f/l (arg) (osql-variablep arg))  
				(predicate-arguments pred)))
	(absorbedpredvarlist (mapcar (f/l (pred)
					  (if (memq (generic-fnname (car pred))
						    '(< <= > >= !=))
					      (second pred)))
				     absorbedNSPs))
	)
    (if (some (f/l (arg) (member arg ccVarList)) predvarlist)
	(cond ((null absorbedpredvarlist)
	       t)
	      (t;;there is already absorbed inequality pred
	       (cond ((memq (second pred)
			    absorbedpredvarlist)
		      t)
		     (t nil)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;GQL absorber;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
(defun absorb-gql (pred preds ds env)
  "Do fixed point iteration to absorb the non source predicates has at least 
   one common var with ccVarList, including thetha join predicate. Absorb theta
   join predicate first compared to (< v5 30000) to avoid cartesian product."
  (let* ((change t)
	 (newrest preds)
	 (unabsorbedpreds (tconc))
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
	      (t 
	       (update-environment opred env)   
	       (cond ((sourcepred? (predicate-operator opred))
		      (tconc unabsorbedpreds opred))
		     (t;;non source predicates
		      (let* ((op (predicate-operator opred))	     
			     (opname (getobject op 'name))) 
			;;op in absorbability
			(cond ((and (member (list opname) abslist)
				    (validpredp (car absorbedNSPs) opred 
						 (predicate-arguments pred)))
			       (tconc _absorbedPreds_ opred)
			       (tconc absorbedNSPs opred)
			       (setq change t))
			      (t (tconc unabsorbedpreds opred)))
			  ))))))
      (setq preds (car unabsorbedpreds))) 
    (setf (gethash 'accessfiltervarlist env) (predicate-arguments pred)) 
    (list (append (list pred) (car absorbedNSPs)) newrest)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;utility functions;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun gql-translate-comparison (ds pred env gqlq)
  (let* ((arg1 (predicate-argument 1 pred))(arg2 (predicate-argument 2 pred))
	 (type1 (get-type arg1 env))       (type2 (get-type arg2 env))
	 (ds1 (if (varsymbolp arg1) (datasource arg1 env)))
	 (ds2 (if (varsymbolp arg2) (datasource arg2 env)))
	; at least one argument in a comparison must be a variable from the
        ; source, otherwise there's not much point in pushing the comparison.
	 (ok (or (eq ds1 ds) (eq ds2 ds))))

    (if (and ok (varsymbolp arg1) (neq ds1 ds)) (gqlquery-add-input gqlq arg1))
    (if (and ok (varsymbolp arg2) (neq ds2 ds)) (gqlquery-add-input gqlq arg2))
	  
    (if ok (gqlquery-add-predicate gqlq pred))))

(defun gql-translate-core-cluster (ds cc-call env gqlq)
  (let* ((fno (predicate-operator cc-call))
	 (ti  (gqlquery-add-table gqlq 
				  (caar (getfunction 'extent_collection 
						     (list fno)))))
	 ci) 
    (dolists 
     ((arg     (predicate-arguments cc-call))
      (coltype (getrestype fno))
      (colname (function-resvars fno)))
     (cond ((named-varsymbolp arg)
	    (setq ci (make-columninfo :tableinfo ti :name colname))
	    (cond ((bound arg env)
		   (if (null (get-entity arg env))
		       (set-entity arg env ci))
		   (cond ((eq (datasource arg env) ds)
			  (gqlquery-add-predicate gqlq 
						  (list _=_ ci arg)))
			 (t (set-type arg env coltype)
			    (gqlquery-add-predicate gqlq (list _=_ ci arg))
			    (gqlquery-add-input gqlq arg))))
		  (t (gqlquery-add-output gqlq arg)
		     (bind arg env :type coltype
			   :entity ci
			   :origin cc-call
			   :datasource (getobject fno 'datasource)))))
	   ((constantsymbolp arg)
	    (setq ci (make-columninfo :tableinfo ti :name colname))
	    (gqlquery-add-predicate gqlq (list _=_ ci arg))))))
  t)

(defun gqlquery-add-table (q table) 
  "Adds a table name as symbol to the tables queried in this gqlquery.
   Returns a tableinfo struct."
  (let* ((incarnations (gqlquery-projections q))
	 (incarnation  (assq table incarnations))
	 incarnation-no)
    (cond (incarnation
	   (setq incarnation-no (1+ (cdr incarnation)))
	   (rplacd incarnation incarnation-no))
	  (t
	   (setq incarnation-no 1)
	   (setf (gqlquery-projections q)
		 (push (cons table 1) incarnations))))
    (make-tableinfo :name table :incarnation-no incarnation-no)))

(defun gqlquery-add-output (q v)
  "Adds a variable to the output varables in the query."
  (setf (gqlquery-output q) (gql-adjoin-last (gqlquery-output q) v)))

(defun gql-adjoin-last (l x)
  (if (memq x l) l
    (nconc1 l x)))

(defun gqlquery-add-input (q v)
  "Adds a variable to the input varables to the query if not already 
   a member of those."
  (setf (gqlquery-input q) (nconc1 (sqlquery-input q) v)))

(defun gqlquery-add-predicate (q pred)
  (let ((sp (gqlquery-selectpred q)))
    (cond ((conjunctionp sp)
	   (nconc1 (gqlquery-selectpred q) pred))
	  ((leaf-predicate-p sp)
	   (setf (gqlquery-selectpred q)
		 (andify (nconc1 (list sp) pred))))
	  (t
	   (setf (gqlquery-selectpred q) pred)))
    q))


(defun getcolname (arg gqlqueryinfo)
  "get column name for a arg in a predicate"
  (let* ((env (gqlquery-environment gqlqueryinfo))
	 columnname)
    (cond (env
	   (let ((vi (gethash arg env))) 
	     (cond (vi
		    (let ((ci (varinfo-entity vi)))
		      (cond (ci
			     (cond ((columninfo-p ci)
				    (let ((colname (columninfo-name ci)))
				      (cond (colname
					     (setq columnname colname))
					    (t
					     (error "column name is nil" colname)))))
				   ((osql-variablep ci)
				    (setq columnname '?))
				   (t
				    (setq columnname ci))
			       )
			       )
			    (t (error "column infor is nil" ci)))))
		   (t (error "variable infor is nil" vi)))))
	  (t (error "environment is nil" env)))
    columnname))

(defun make-gql-column-string (q ci)
  (columninfo-name ci))
    

(defun gql-simplefunc (pred gqlqueryinfo)
  "do transformation of pred (> _V2 80000) into e.g. POPULATION > 80000"
  (let ((operator (predicate-operator pred))
	(predarglist (predicate-arguments pred))
	transformedpred transformedpredargl gqloperator)
    (setq transformedpredargl (mapcar (f/l (arg) 
					   (cond ((columninfo-p arg)
						  (make-gql-column-string  
						   gqlqueryinfo arg))
						 ((osql-variablep arg)
						  (getcolname arg 
							      gqlqueryinfo))
						 ((equal arg "?")
						  (mksymbol arg))
						 ((stringp arg)
						  (concat "'" arg "'"))
						 (t 
						  arg)))
				      predarglist))
    (setq gqloperator (oid-name (getobject operator 'genfn)))
    (setq transformedpred (concat (car transformedpredargl) " "
				  gqloperator " "
				  (cadr transformedpredargl) " "))))
					    
(defun gql-compfunc (preds)
  "concat all predicates with and delimeter"
  (let ((predstringl (cdr preds))
	gqlstring
	)
    (setq gqlstring (concatl predstringl " and "))
    ))

(defun make-gql-fromclause (gqlqueryinfo)
  (let ((projection (gqlquery-projections gqlqueryinfo))
	table)
    (setq table (concat "from " (mkstring (caar projection)) " "))))

(defun make-gql-whereclause (gqlqueryinfo)
  "construct gql whereclause in gql query"
  (let ((absorbedpreds (gqlquery-selectpred gqlqueryinfo))
	whereclause)
    (cond (absorbedpreds
	   (setq whereclause (concat "where " 
				     (map-over-pred absorbedpreds 
						    (function gql-simplefunc) 
						    (function gql-compfunc) 
						    gqlqueryinfo))))
	  (t;;absorbedpreds is nil
	   (setq whereclause "")))
    whereclause))


(defun gen-gql-string (gqlqueryinfo)
  "generate gql query string"
  (concat "select * "
	  (make-gql-fromclause gqlqueryinfo)
	  (make-gql-whereclause gqlqueryinfo))  
  )


(defun create-specialized-gql-query-fn (ds env gqlq varlist)
  "outparams has to be build as the length as source predicate varlist
   since a GQL query is in form of select * from table where ... and 
   has to return a vector, which contains all column values that satisfy 
   the query filter condition."
  (let* ((inparams  (get-parameters (gqlquery-input gqlq) env))
	 (outparams (buildn (length varlist) '(object)));;diff
	 (invars    (gqlquery-input gqlq))
	 (query     (gen-gql-string gqlq))
	 (dsn (string-downcase (mkstring (oid-name ds))))
	 (body      `(gql ,dsn ,query (vector ,@ invars)))
	 (arity     (length outparams))
	 vrefs) 
    (setf (gqlquery-gqlstring gqlq) query)
    (dotimes (i arity)(push `(vref v , (- arity (1+ i))) vrefs))
    (createfunction '*transient* inparams outparams vrefs 
		    '((vector v)) `(= v , body))))


(osql "create function gql_cost(function,vector,vector)->(integer,integer) as select 100,100;")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;GQL finalizer;;;;;;;;;;;;;;;;;;;;;;;;
(defun translate-gql (ds queryinfo filtervarlist)
  "TR rewrite rule that generates a new TR predicate to call GQL 
    for a given FILTER call in TR format"
  (let ((dsn (string-downcase (mkstring (oid-name ds))))
	(env (gqlquery-environment queryinfo))
	gqlquery queryfn invars outvars gql-algebra-op 
	)		
    (setq queryfn (create-specialized-gql-query-fn ds env queryinfo 
						   filtervarlist))
    (setq gqlquery (gqlquery-gqlstring queryinfo));;gql query string
    (setq invars (gqlquery-input queryinfo));;input vars to the gql call
    (setq outvars filtervarList);;output vars by the gql call
    (declarecosts queryfn '*any* 'gql_cost);;C  F
    (/putobject
     queryfn 'name
     (concat "gql@" dsn ":'" gqlquery "'" 
	     (or invars "()" ) "->"(or outvars "()")))
    (/putobject queryfn 'gqlquery queryinfo)
    (setq gql-algebra-op
	  `((, _apply_pred_ , queryfn ,@ invars ,@ outvars)))
    ))
