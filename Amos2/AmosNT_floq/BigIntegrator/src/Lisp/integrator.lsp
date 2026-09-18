;;define expression
(defglobal _expression_)

(defglobal _wrapper_ (createtype 'wrapper '(datasource)))


(setq _expression_ (createliteraltype 'expression '(literal) 'expression))


(defun coverp (pred allboundvars)
  "judge whether every osql variable in pred is bound or inferable 
   through filter"
  ;;remove (> V1 V2) if V1, V2 are not all bound
  (and (not (numericalp pred))
       (every (f/l (var) (memq var allboundvars))
	      (predicate-vars pred)))
    )


(defun get-absorbability (ds)
  "get absorbability database for a datasource"
  (getfunction 'get_absorbability (list ds)))