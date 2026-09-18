;;define expression
(defglobal _expression_)

(setq _expression_ (createliteraltype 'expression '(literal) 'expression))

;;Define absorber for GQL
(defun fillHashTable (ccVarList colList)
  (let ((ht (make-hash-table :test (function equal)))
	)
    (mapc (f/l (var col) 
	       (cond ((gethash var ht);;handle same value in ccVarList
		      (setf (gethash var ht) 
			    (cons col (gethash var ht))))
		     (t;;save value as list for above case
		      (setf (gethash var ht) (list col)))))
	  ccVarList colList)
    ht))

(defun findInputVars (this rest)
  "find join variables from this and rest"
  (let ((l (cons this rest))
	(ccfnPredVarList (tconc)))
    (dolist (pred l)
      (let ((absorber (get-absorber pred)))
	(if absorber
	    (tconc ccfnPredVarList (cdr pred)))
	))
    (intersectionl (car ccfnPredVarList))))

(defun absorb-gql (this rest)
  "absorb all preds with the same variable as CCfn pred"
  (let* ((ccfno (car this))
         (ccVarList (cdr this))
	 (colList (function-resvars ccfno))
	 (absorbedList (tconc)) 
	 generatedExpression filterPred ht 
	 (lastRun t)
	 (inputVars (findInputVars this rest))
	 (dsn (string-downcase (caar (getfunction 'extent_dsn (list ccfno)))))
	 (table (caar (getfunction 'extent_collection (list ccfno))))
         (filterFuncName (pack  table '_ dsn '_filter))
	 (filterPreds rest)
	 )
    (setq ht (fillHashTable ccVarList colList))
    (dolist (var ccVarList);;absorb non-symbol in 'this' if there is any
      (cond ((not (symbolp var));;
	     (dolist (val (gethash var ht))
	       (tconc absorbedList (list '= val var)))))) ;(help)
    (cond (rest
	   (dolist (pred rest)
	     (if (getobject (car pred) 'CCLUSTERFCT?);;it means not last run
		 (setq lastRun nil))
	     (if (memq (generic-fnname (car pred)) '(< <= > >= !=))
		 (setq filterPreds (remove pred filterPreds))) ;only filter pred
	     (cond ((and (memq (generic-fnname (car pred)) '(< <= > >= !=))
			 (memq (second pred) ccVarList))
		    (tconc absorbedList pred)
		    )))	
	   (setq generatedExpression (make-expression 
				      (car absorbedList) ;filter  
				      table ;source  
				      colList ;attributes
				      )) ;(help)
	   (setq filterPred (list* (theresolvent filterFuncName)  
				   generatedExpression ccVarList)) ;(help 1)
	   (cond (lastRun 
		  (cons filterPred filterPreds))
		 (t 
		  (cons filterPred rest)))
	   )
	  )
    )
  )

;;Define the finalizer(translator) for GQL Filters
;;(defglobal _gql_ (getfunctionnamed 'CHARSTRING.CHARSTRING.VECTOR.gql->VECTOR))
(defglobal _vector-dynconstructor_ (getfunctionnamed 'vector))
(defglobal _gql2_ (getfunctionnamed 'CHARSTRING.CHARSTRING.VECTOR.gql2->VECTOR))

(defun construct-packedParamList (filter inputVars)
  "construct packed Parameter List"
  (cond ((> (length filter) 1);;filter e.g((< state "CA")(> population 100000))
	 (append (mapcar (f/l (pred) (third pred)) filter)
		 inputVars))
	((= (length filter) 1);;e.g ((< state "CA"))
	 (cons (third (car filter)) inputVars))
	(t;;there is no absorbed predicate 
	 inputVars)))

(defun construct-join (ht inputVars filter)
  "construct join part in where clause"
  (let ((res ""))
    (cond (filter;; => res e.g " and population=? and state=?"
	   (mapc (f/l (var)
		      (setq res (concat res " and " 
					(mkstring (gethash var ht)) "=?")))
		 inputVars) res)
	  (t;; filter is nil => res e.g "where population=? and state=?"
	   (mapc (f/l (var)
		      (setq res (concat res " and " 
					(mkstring (gethash var ht)) "=?")))
		 inputVars) 
	   (concat "where " (string-left-trim " and" res))))
    ))

;;filter e.g ((< state "CA")(> population 100000))
;;=>"STATE<? and POPULATION>?"  
(defun build-condition (filter ht)
  "transform pred to gql filter format in where clause"
  (let ((res ""))
    (mapc (f/l (pred) 
	       (let ((val (gethash (second pred) ht)))
		 (cond (val
			(setq res (concat res (gethash (second pred) ht) 
					  (car pred) "? and ")))
		       (t
			(setq res (concat res (second pred) 
					  (car pred) "? and "))))
		 ))                                   filter)
    (string-right-trim " and" res)))

;; construct whereClause, filter could be list of list or nil
(defun construct-whereClause (filter ht)
  (cond (filter
	 (concat "where " (build-condition filter ht)))
	(t "")))

;;(#[OID 167 "OBJECT.OBJECT.>->BOOLEAN"] _V10 "Z") =>
;;(> _V10 "Z")
(defun transform-Pred (pred)
  "transform pred into (operator var val) format"
  (let ((translatedVar (second pred))
	(operator (generic-fnname (car pred)))
	(parameter (third pred)))
    (list operator translatedVar parameter)))

(defun adjustFilter (filter inputVars)
  "adjust filter to satisfy gql criteria with first encount first absorb"
  (let ((copyFilter filter)
	(gqlFilter (tconc))
	(unabsorbedPreds (tconc))
	)
    (cond (filter
	   (if inputVars;;has join pred var and try to eliminate the join preds
	       (setq copyFilter
		     (mapfilter (f/l (pred) 
				     (not (memq (second pred) inputVars))) 
				filter)))
	   (cond (copyFilter;;copyFilter = filter removes join pred
		  (dolist (pred copyFilter)
		    (let* (transformedPred)
		      (cond ((eq (car pred) '=)	;= pred already transformed
			     (setq transformedPred pred))
			    (t
			     (setq transformedPred (transform-Pred pred))))
		      (cond ((memq (car transformedPred) '(=)) 
					;= pred should be able to absorb
			     (tconc gqlfilter transformedPred))
			    ;;(< <= > >= !=) pred needs to be checked with 
			    ;;preds already in gqlfilter to follow gql criteria
			    (t
			     (let ((ineqlVarList)
				   )
			       (setq ineqlVarList;;(nil) or (nil ...) or (V2)
				     (mapcar (f/l (pred) 
						  (if(memq (car pred) 
							   '(< <= > >= !=))
						      (second pred)))
					     (car gqlfilter))) ;(help 2)
			       (cond ((atom ineqlVarList);;no pred in gqlfilter
				      (tconc gqlfilter transformedPred))
					;no prev < <= > >= != pred in gqlfilter
				     ((equal ineqlVarList '(nil))	
				      (tconc gqlfilter transformedPred))     
				     (t	;already < <= > >= != pred in gqlfilter
				      (cond ((memq (second transformedPred) 
						   ineqlVarList)
					     (tconc gqlfilter transformedPred))
					    (t
					     (tconc unabsorbedPreds 
						    pred))))))))))
		  ))))
    (cons (car gqlFilter) (car unabsorbedPreds))))

(defun translate-gql (tr bnd)
  "TR rewrite rule that generates a new TR predicate to call GQL 
    for a given FILTER call in TR format"
  (let* ((filterFno (car tr))
	 (expression (second tr))
	 (table (expression-source expression))
	 (filter (expression-filter expression))
	 (collist (expression-attributes expression))
	 (dsn (string-downcase (caar (getfunction 'extent_filter_dsn 
                                                  (list filterFno)))))
	 (queryResult (dt_genvar _vector_))
	 (paramVector (dt_genvar _vector_))
	 (varList (cddr tr))
	 whereClause queryString
	 packedParamList gqlCallList unpackedResultList conjunctionList
	 (inputVars (intersection bnd varList));;e.g (v2,...)
	 (preds (adjustFilter filter inputVars))  
	 (gqlFilter (car preds))
	 (unabsorbedPreds (cdr preds))
	 (parameters (construct-packedParamList gqlFilter inputVars))
	 (ht (make-hash-table :test (function equal)))
         )  ;(help)
    ;; fill hash table with expression variable list and column list 
    (mapc (f/l (var col)(setf (gethash var ht) col))
	  varlist collist)
    (setq whereClause (construct-whereClause gqlFilter ht)) ;(help 1)
    (cond (bnd
           (setq whereClause (construct-whereClause gqlFilter ht)) 
	   (setq queryString (concat "select * from " table " " whereClause 
				     (construct-join ht inputVars gqlFilter)))
	   )
	  (t;; The first coming tr get handled here
	   (setq queryString (concat "select * from " table " " whereClause))
	   ))
    (setq packedParamList (list* _vector-dynconstructor_ paramVector 
				 parameters))
    (setq gqlCallList (list _gql2_ dsn queryString paramVector 
			    queryResult))
    (setq unpackedResultList (list* _vector-dynconstructor_ queryResult 
				    varList)) ;(help 2)
    (setq conjunctionList (list packedParamList gqlCallList 
				unpackedResultList))
    (if unabsorbedPreds (setq conjunctionList 
			      (append conjunctionList unabsorbedPreds)))
    (andify conjunctionList))
  )


;; Possible format of filter:
;; 1. TRUE => No where clause
;; 2. (comp ATTR VAL) where comp is one of > < <= >= = !=
;; 3. (P1....Pn) where pI is of type 1. or 2. with some restrictions
;;    imposed by the absorber