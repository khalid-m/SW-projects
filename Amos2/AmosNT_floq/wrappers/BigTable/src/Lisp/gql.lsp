(defglobal _gql_ (getfunctionnamed 'CHARSTRING.CHARSTRING.VECTOR.gql->VECTOR))

(defun Bigtableds-+ (fno name btds)
  (setq btds (or (getobjectnamed (mksymbol name) _Bigtable_ t) 
		 (/createobject 'Bigtable name)))
  (osql-result name btds))


(defun validpredp (absorbedpreds pred ccVarList)
  "check whether the predicate is valid to be absorbed. e.g all
   equality predicates are valid, and the first inequality predicate, e.g
   (< v5 30000) or (< v5 v6), having one variable in common with the source 
   predicate is valid. If an inequality predicate is valid to be absorbed, 
   then the first inverse inequality for the same variable is also valid."
  (let* ((op (predicate-operator pred))
	 (predvarlist (predicate-vars pred))
	 (absorbedNSPs (subset absorbedpreds 
			       (f/l (pred) (not (sourcepred? pred)))))
	 (absorbedpredvarlist (mapcar (f/l (pred)
					   (if (memq (generic-fnname op)
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

(defun gql-absorbablep (pred capabilitylist absorbedpreds accessfiltervarlist)
  "leaf pred can be a source predicate or non source predicate. Non source
   predicate is absorbable if dsinst is capable to handle and share a common
   variable with absorbedpreds and it is valid by validpredp. Source predicate
   is not absorbable because join is not supported."
  (and (supported-by-dsinst pred capabilitylist)
       (joins-with pred absorbedpreds)
       (not (sourcepred? (predicate-operator pred)))
       (validpredp absorbedpreds pred accessfiltervarlist)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;GQL absorber;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
(defun absorb-gql (sp preds)
  "Do fixed point iteration to absorb the non source predicates has at least 
   one common var with ccVarList, including thetha join predicate. Absorb theta
   join predicate first compared to (< v5 30000) to avoid cartesian product."
  (let* ((rest preds)
	 (change t)
	 (dsinst (datasource-of sp));;ds instance
	 ;;use predicate-arguments to emit all column values
	 (accessfiltervarlist (predicate-arguments sp));;not use predicate-vars
	 (capabilitylist (dsinst-capable dsinst));wrapper and dsinst capable
	 (absorbedpreds (list sp))
	 )
    (while change
      (setq change nil)
      (dolist (p rest)
	(cond ((compound-p p))
	      ((osql-variablep p))
	      ((osql-constantp p))
	      ((gql-absorbablep p capabilitylist absorbedpreds 
				accessfiltervarlist)
	       (push p absorbedpreds);;push p into absorbedpreds
	       (setq rest (remove p rest));;absorb p just once
	       (setq change t)))))
    (make-absorberresult :absorbedpreds absorbedpreds
			 :newrest preds
			 :accessfiltervarlist accessfiltervarlist
			 )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;utility functions;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun gql-translate-source-predicate (ds sp gqlq)
  (let* ((fno (predicate-operator sp))
	 (ti  (gqlquery-add-table gqlq 
				  (caar (getfunction 'extent_collection 
						     (list fno)))))
	 ci) 
    (dolists 
     ((arg     (predicate-arguments sp))
      (coltype (getrestype fno))
      (colname (function-resvars fno)))
     (cond ((named-varsymbolp arg)
	    (setq ci (make-columninfo :tableinfo ti :name colname))
	    (cond ((varboundp arg)
		   (if (null (get-varentity arg))
		       (set-varentity arg arg))
		   ;;differ with sql, add input whenever the var is bound
		   ;;no matter the source predicate dsinst is different or not
		   ;;because there is no join supported in gql, every gql query
		   ;;is a single source predicate query with filter predicates.
		   (gqlquery-add-input gqlq arg)
		   (gqlquery-add-predicate gqlq (list _=_ ci "?")))
		   ;;(gqlquery-add-predicate gqlq (list _=_ ci arg)))
		  (t (gqlquery-add-output gqlq arg)
		     (set-vards arg ds)
		     (set-varentity arg ci)
		     (bind-var arg))))
	   ((constantsymbolp arg)
	    (setq ci (make-columninfo :tableinfo ti :name colname))
	    (gqlquery-add-predicate gqlq (list _=_ ci arg))))))
  gqlq)

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
  (setf (gqlquery-input q) (nconc1 (gqlquery-input q) v)))

(defun gqlquery-add-predicate (q pred)
  (let ((nsp (gqlquery-selectpred q)))
    (cond ((sourcepred? pred)
	   (setf (gqlquery-sourcepred q) pred))
	  ((conjunctionp nsp);;more than one pred in gqlquery-selectpred
	   (nconc1 (gqlquery-selectpred q) pred))
	  ((leaf-predicate-p nsp)
	   (setf (gqlquery-selectpred q)
		 (andify (nconc1 (list nsp) pred))))
	  (t;;no pred is added to gqlquery-selectpred
	   (setf (gqlquery-selectpred q) pred)))
    q))


(defun getcolname (arg gqlqueryinfo)
  "get column name for a arg in a predicate"
  (let ((ci (get-varentity arg));;column information
	 columnname)
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
		  (setq columnname ci))))
	  (t (error "column infor is nil" ci)))
    columnname))

(defun make-gql-column-string (q ci)
  (columninfo-name ci))
					    
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

(defun arg-columnlist (predarglist gqlqueryinfo)
  "translate predicate arguments to column names or constant or ?"
  (mapcar (f/l (arg) 
	       (cond ((columninfo-p arg)
		      (make-gql-column-string  
		       gqlqueryinfo arg))
		     ((osql-variablep arg)
		      (getcolname arg 
				  gqlqueryinfo))
		     ((equal arg "?")
		      (mksymbol arg)
		      )
		     ((stringp arg)
		      (concat "'" arg "'"))
		     ((constantp arg)
		      arg)
		     (t 
		      arg)))
	  predarglist))

(defun make-wherestring (absorbedpreds gqlqueryinfo)
  (concat "where " 
	  (map-over-pred absorbedpreds 
			 (f/l (pred)
			      (let ((predarglist (predicate-arguments pred))
				    transformedpredargl operator)
				(setq transformedpredargl 
				      (arg-columnlist predarglist 
						      gqlqueryinfo))
				(setq operator (generic-fnname 
						(predicate-operator pred)))
				;;return translated pred
				(concat (car transformedpredargl) 
					" " operator " "
					(cadr transformedpredargl) " "))) 
			 (function gql-compfunc) 
	  )))


(defun make-gql-whereclause (gqlqueryinfo)
  "construct gql whereclause in gql query"
  (let ((absorbedpreds (gqlquery-selectpred gqlqueryinfo))
	whereclause)
    (cond (absorbedpreds
	   (setq whereclause (make-wherestring absorbedpreds gqlqueryinfo))) 
	  (t;;absorbedpreds is nil
	   (setq whereclause "")))
    whereclause))

(defun translate-gql-sourcepredicate (gqlq)
  (let ((ds (gqlquery-datasource gqlq))
	(sp (gqlquery-sourcepred gqlq))
	)
    (gql-translate-source-predicate ds sp gqlq)))

(defun generate-gql-string (gqlq)
  (translate-gql-sourcepredicate gqlq)
  (gen-gql-string gqlq))

(defun gen-gql-string (gqlqueryinfo)
  "generate gql query string"
  (concat "select * "
	  (make-gql-fromclause gqlqueryinfo)
	  (make-gql-whereclause gqlqueryinfo))  
  )


(defun create-specialized-gql-query-fn (ds gqlq varlist)
  "outparams has to be build as the length as source predicate varlist
   since a GQL query is in form of select * from table where ... and 
   has to return a vector, which contains all column values that satisfy 
   the query filter condition."
  (let* ((query     (generate-gql-string gqlq));;done first
	 (inparams  (get-parameters (gqlquery-input gqlq)))
	 (outparams (buildn (length varlist) '(object)));;diff
	 (invars    (gqlquery-input gqlq))
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
(defun finalize-gql (ds translatablepreds sb)
  "TR rewrite rule that generates a new TR predicate to call GQL 
    for a given FILTER call in TR format"
  (let ((dsn (string-downcase (mkstring (oid-name ds))))
	(querystruct (make-gqlquery :datasource ds))
	(filtervarlist (get-spvarlist translatablepreds));;source pred varlist
	gqlquery queryfn invars outvars gql-algebra-op 
	)		
    (distribute-gqlpreds translatablepreds querystruct)
    (setq queryfn (create-specialized-gql-query-fn ds querystruct 
						   filtervarlist))
    (setq gqlquery (gqlquery-gqlstring querystruct));;gql query string
    (setq invars (gqlquery-input querystruct));;input vars to the gql call
    (setq outvars filtervarList);;output vars by the gql call
    (declarecosts queryfn '*any* 'gql_cost);;C  F
    (/putobject
     queryfn 'name
     (concat "gql@" dsn ":'" gqlquery "'" 
	     (or invars "()" ) "->"(or outvars "()")))
    (/putobject queryfn 'gqlquery querystruct)
    (setq gql-algebra-op
	  `((, _apply_pred_ , queryfn ,@ invars ,@ outvars)))
    ))

(defun distribute-gqlpreds (translatablepreds querystruct)
  "distribute the translatable predicates to the holding place in gqlquery
   structure"
  (mapc (f/l (pred) (gqlquery-add-predicate querystruct pred))
	translatablepreds)
)

(defun get-spvarlist (translatablepreds)
  "get the source predicate arguments"
  (let ((sp (car (subset translatablepreds (f/l (pred) (sourcepred? pred)))))
	)
    (if sp
	(predicate-arguments sp)
      (error "no source predicate" sp))))