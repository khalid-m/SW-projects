;;;System complain #OPERATOR_IBDS not exist when doing sql query for q00001, 
;;;therefore make the ccfn from OPERATOR_IBDS_CC to #OPERATOR_IBDS, mapped type;;; is still the same
(advise-around 'make-core-cluster-fn-name '(let ((prefix "#"))
					     (if fnname
						 (pack prefix entity-name '_ fnname)
					       (pack prefix entity-name))))

;;
(defun create-relational-cc-filter-fn (ds table columns keys relation-name)
  (let*	((width        (length columns))
	 (name         (concat (make-core-cluster-fn-name relation-name))) ;(help)
	 (fullname     (concat "#" name (packlist (buildn width '+))))
	 (column-names (mapcar #'second columns))
	 (fbunch       (make-string width "f"))
	 (cc-filter-fn-name (pack (string-left-trim "#" name) '_filter))
	 (fno          (createfunction cc-filter-fn-name
				       '((Expression f))
				       columns
				       'foreign
				       '("abstract-function")
				       nil)  ))
    (declare-keys fno keys columns)
    fno))

;;Fanout: 1000 Cost: 100000
(osql "create function sqlFilter_cost(function,vector,vector)-><integer,integer> as select 100000,1000;")

;;advise around this function later ...
(advise-around 'import-table 
  '(let* ((columns (get-columns-amos-typed ds table 'noerror))
	 (keycols (get-key-columns-amos-typed ds catalog schema table))
	 (cc-fno  (create-relational-core-cluster-fn
		   ds table columns keycols mtname))
	 (cc-filter-fno (create-relational-cc-filter-fn
			 ds table columns keycols mtname))
	 (cc-name (generic-fnname cc-fno))
	 mt)
    ;(add-rewriter cc-fno (buildn (length columns) '+) 'rewrite-extent)
    (/putobject cc-fno 'absorber 'absorb-sql)
    (/putobject cc-fno 'CCLUSTERFCT? t)
    (/putobject cc-filter-fno 'translator 'translate-sql)
    (declarecosts cc-filter-fno '*any* 'sqlFilter_cost)
    (setq mt (create-mapped-type  mtname 
				 supertypes
				 columns 
				 keycols
				 cc-name))
    (add-amos-type    ds :wrapped table :amos mt)
    (add-wrapped-type ds :wrapped table :amos mt)
    (if updateable (create-keyed-update-fns ds mt columns keycols))
    (if updateable
	(set-constructor mt (create-sql-constructor ds mt))
      (forbid-constructor mt "This mapped type is read-only"))
    mt))

;;
(defun absorb-sql (this rest)
  (let* ((bpat      (buildl (cdr this) '+))
	 (extentfno (car this))
	 (ccVarList (cdr this))
	 (ds        (getobject extentfno 'datasource))
	 (defabs    (getobject extentfno 'defaultabsorbent))
	 initfn
	 finfn
	 (restPreds rest)
	 (env       (make-environment))
	 (table (getobject extentfno 'tablename))
	 (dsn (getobject ds 'name))
	 (filterFuncName (pack table '_ dsn '_filter)) 
	 acc untranslated result bnd generatedExpression filterPred)
    (if (not ds) (error "extent function has no datasource" extentfno))
    (if(not defabs)(error"extent function has no default absorbent."extentfno))
    (setq initfn (get-initializer ds))
    (setq finfn (get-finalizer ds))
    (if (not initfn)(error "no initializer for datasource's translator." ds))
    (if (not finfn) (error "no finalizer for datasource's translator." ds))

    ; Call the datasource's initializer. Returns the accumulator.
    (setq acc (funcall initfn ds env))
    (update-environment this env bpat)
    (puthash 'org-this env this)
    (puthash 'org-rest env rest) 
    ; Try running the default absorbent w/o resorting to capabilities
    (if (not (translate ds this env acc defabs)) (push this untranslated))

    ;make expression 
    (setq generatedExpression (make-expression env ds acc))
    ;make filter predicate
    (setq filterPred (list* (theresolvent filterFuncName) generatedExpression ccVarList))

    (judgeLastRun rest)
    ;construct new TR list
    (cond (_lastRun_
	   ;;when last run, remove absorbed preds from rest
	   (dolist (pred (car _absorbedPredCollection_))
	     (if (some (f/l (pred1) (equal pred1 pred)) rest)
		 (setq restPreds (remove pred restPreds))))
	   (mapc (f/l (pred) (if (and (memq (generic-fnname (car pred)) 
					    '(< <= > >= != like))
				      (memq (second pred) ccVarList))
				 (setq restPreds (remove pred restPreds))))
		 rest)
	   (setq _absorbedPredCollection_ (tconc))
	   (cons filterPred restPreds))
	  (t
	   (cons filterPred rest)))
    )
)

;(quote
(defun absorbp (pred env)
  (some (f/l (arg) (in arg (predicate-variables (gethash 'org-this env))))
	(predicate-variables pred)))
;)
;;update capable function by putting constraint that the absorbed predicate
;;should have at least one shared variable with source predicate
;(quote
(advise-around 'capable
	       '  (let* ((op (predicate-operator pred))
			 (bpat  (bpat pred env)))  ;(help 3)
			 (if (and (get-best-cover ds op bpat)
				  (absorbp pred env))
			     t 
			   nil)))
;)

;;
(defun translate-sql (tr bnd)
  "Translate the access filter predicate with bnd into algebra program. 
   If variable (arg)is bound, (1)update accumulator by adding arg into 
   input field, (2)update env by setting the datasource of arg to nil, 
   (3)update accumulator by adding 
   (list _=_ (varinfo-entity (gethash arg env)) arg) into selectpred field, 
   (4)update accumulator by removing the bound variable from output field. 
   All these steps can't be done in absorb-sql and have to be done in here 
   due to the bound variables are only available until this step."
  (let* ((filterFno (car tr))
	 (expression (second tr))
	 (ds (expression-source expression))
	 (env (expression-filter expression))
	 (acc (expression-attributes expression))
	 (org-rest (gethash 'org-rest env))
	 (orgthis-varList (cdr (gethash 'org-this env)))
	 newbnd
         )				;(help 1) 
    (setq newbnd (set-difference (append bnd orgthis-varList) 
				 orgthis-varList))
    (dolist (v newbnd) (putvar v env :bind '- :entity v))  ;(help 2)
    (translate-and-prune org-rest ds env acc)  ;(help 3)
    ;if variable is not yet in input field and is in the output field 
    ;of accumulator, then update the accumulator 
    (if (not (null bnd))
	(mapc (f/l (arg) (cond ((and (in arg (sqlquery-output acc)) 
                                     (not (in arg (sqlquery-input acc))))
				(sqlquery-add-input acc arg)
				(setf (varinfo-datasource (gethash arg env)) 
				      nil)
				(sqlquery-add-predicate acc (list _=_ 
								  (varinfo-entity (gethash arg env)) arg))
				(setf (sqlquery-output acc) 
				      (remove arg (sqlquery-output acc)))))) 
	      bnd))
;(help 3)
    (car (relational-finalize ds env acc)))
  )



