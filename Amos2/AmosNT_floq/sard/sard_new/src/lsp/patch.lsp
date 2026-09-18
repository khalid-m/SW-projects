

(defun already-optimized (pred)
  (selectq (car (ilistp pred))
	   (call t)
	   ((or and) (cond ((assq 'call (cdr pred)) t)
			   (t (some (f/l (p) (and (compound-p p)(already-optimized p)))
				    (cdr pred)))))
	   nil))

(defun orpredcost (l bnd)
  "Estimate the cost and fanout to evaluate a conjunction L with
   variables BND bound"
  ;; The costs and fanouts of a disjunction is the sum of the 
  ;; the costs and fanouts of its elements
  (catch 'orpredcost 
    (let ((cost 0)(fanout 0)) 
      (dolist (pred l)    
	(let* ((lcst (compute-exec-cost-pred (cond ((not (compound-p pred)) pred)
						   ((already-optimized pred) pred)
						   (t (optimize-compound-predicate pred bnd)))
					     bnd)))
	  (cond (lcst (setq cost (+ (first lcst) cost))
		      (setq fanout (+ (second lcst) fanout)))
		(t (throw 'orpredcost nil)))))
      (list cost fanout))))

(defun flattenorargs-nonrecursive (xpr)
  "Flatten disjunction"
  (let ((res (tconc nil)))
    (while xpr
      (cond ((atom (car xpr)) (tconc res (pop xpr)))
	    ((orp (caar xpr))
	     ;; OR in OR
	     (setq xpr (append (cdar xpr) (cdr xpr))))
	    (t (tconc res 
		      (andify
		       (let (new-bindings) ; New local bindings in OR clause
			 (prog1		; return flatted OR clause
			     (let* ((*bindings* (copy-bindings *bindings*)) 
				    ;; new scope. POS is old environment
				    (pos *bindings*)
				    ;; PREDL is flattened body of OR clause
				    (predl (flattenpredicate (car xpr))))
			       (setq new-bindings 
				     ;; Newly introduced declarations in OR clause
				     (ldiff *bindings* pos))
			       ;; Initialize variables in OR clause
			       (assigntemporaries predl pos))
			   ;; Clear initializations by ASSIGNTEMPORARIES:
			   ;; Otherwise it will be doubly initialized
			   (dolist (b new-bindings)
			     (setf (binding-val b) nil))
			   ;; Add declarations of new local variables:
			   ;; Reason: IUT relies on global list of all 
			   ;; declared variables
			   (setq *bindings*;; nconc OK here since new-bindings copy
				 (nconc new-bindings *bindings*))))))
	       (pop xpr))))
    (car res)))




(defun write-ntuples2--+ (fno bag filename r)
"Redifines write-ntuples for wtiting in N-triples format"
  (let ((toprint ""))
    (with-output-file 
     s filename
     (mapbag
      bag
      (f/l (row)
	   (maparray
	    (car row)
	    (f/l (x i)
		 (if (or (eq i 0) (eq i 1))
		     (setf toprint (concat toprint (concat "<" x "> "))))
		 (if (eq i 2)
		      (if  (not (equal (mkstring x) "sql null"));;Print only if the o in (s,p,o) is non-NULL values
			  (progn
			    (if (or (string-like-i (mkstring x) "*user.it.uu.se/~udbl/sard*")
				(string-like-i (mkstring x) "*www.w3.org*"))		
				(setf toprint (concat toprint (concat "<" x ">") ));;if o is a URI
			    (setf toprint (concat toprint x)));;if o is a Literal
			    (princ toprint s)
			    (terpri s)
			    (setf toprint ""))
			(setf toprint "")))))))))
	  ;; (terpri s)))))
   (osql-result bag filename filename))

(defun write-ntuples1--+ (fno bag filename r)
"Redefines write-ntuples to write {s,p,o} into an N-triples file format"
  (with-output-file
   s filename
   (mapbag
    bag
    (f/l (row)
	 (maparray
	  (car row)
	  (f/l (x i)
	       (if (or (eq i 0) (eq i 1));;
		   (princ (concat "<" x "> ") s);;s and p are always URIs 
		 (if (or (string-like-i (mkstring x) "*user.it.uu.se/~udbl/sard*")
			 (string-like-i (mkstring x) "*www.w3.org*"))
		     (princ (concat "<" x "> .") s);;if o is an URI
		   (princ (concat "\"" x "\"" ".") s)));;if o is a literal
	       (princ " " s)))
	 (terpri s))))
  (osql-result bag filename filename))



(defun write-ntuplesNT--+ (fno bag filename r)
"Redefines write-ntuples to write {s,p,o} into an N-triples file format"
  (with-output-file s filename
   (mapbag
    bag
    (f/l (row)
	 (maparray
	  (car row)
	  (f/l (x i)
	       (cond ((string-like-i (mkstring x) "_:*")
			   (princ x s) );;if blank node
		     ((string-like-i (mkstring x) "http://*")     
		      (princ (concat "<" x "> ") s));;if URI
		     ((string-like-i (mkstring x) "*www.w3.org*");;if typed literal
		      (princ x s))
		     (t  ;;if a string
		      (princ (concat "\"" x "\"" ) s)))
	       (if (eq i 2)
		   (princ " ." s));;put '.' at the end
	       (princ " " s)))
	 (terpri s))))
  (osql-result bag filename filename))


(defun write-ntuplesCSV--+ (fno bag filename r)
"Redefines write-ntuples to write {s,p,o} into an N-triples file format"
  (with-output-file s filename
   (mapbag
    bag
    (f/l (row)
	 (maparray
	  (car row)
	  (f/l (x i)
	       (cond ((string-like-i (mkstring x) "_:*")
			   (princ x s) );;if blank node
		     ((string-like-i (mkstring x) "http://*")     
		      (princ (concat "<" x "> ") s));;if URI
		     ((string-like-i (mkstring x) "*www.w3.org*");;if typed literal
		      (princ x s))
		     (t  ;;if a string
		      (princ (concat "\"" x "\"" ) s)))
	        (if (eq i 1)
		    (declare-amosql "add store_prop('" (mkstring x) "')=true;") )
		  (if (or (eq i 0) (eq i 1))
		      (princ "|" s)
		    (princ "~%" s ))));;write carriage return ????
	 (terpri s))))
  (osql-result bag filename filename))

(quote
(defun relational-finalize (ds env sqlq)
  (let ((queryfn (create-specialized-query-fn ds env sqlq))
	(query   (get-sql-string sqlq))
	(dsname  (oid-name ds))
	(invars  (sqlquery-input sqlq))
	(outvars (sqlquery-output sqlq)))
    (declarecosts queryfn '*any* 'sql_cost)
    (/putobject 
     queryfn 'name
     (concat "sql@"dsname":'"query"'"(or invars "()")"->"(or outvars "()")))
    (/putobject queryfn 'sqlquery sqlq)
    (if (and (eq (aref sqlq 4) nil) (eq (aref sqlq 3) nil));;don't go in the RDBMS if all *
	t
      `((, _apply_pred_ , queryfn ,@ invars ,@ outvars)))))
)


(defun create-relational-core-cluster-fn-new (ds table columns keys relation-name)
  (let*	((width        (length columns))
	 (name         (concat (make-core-cluster-fn-name relation-name)))
	 (fullname     (concat name (packlist (buildn width '+))))
	 (column-names (mapcar #'second columns))
	 (fbunch       (make-string (1+ width) "f"))
	 (fno          (createfunction 
			name
					; the arguments; none
			nil
					; its result types
			(cons '(integer _ident_ key) columns)
					; RESV
			'multidirectional
					; QUANT
			`(( , fbunch foreign , fullname))
					; PRED, whatever that is
			nil)))

    (addfunction 'absorbability (list ds) (list fno))

    (defc (mksymbol fullname) 
      `(lambda , (cons 'fno column-names)
	 (let ((no 0))
	   (dolist 
	       (result
		(getfunction 
		 'sql 
		 '( , ds , (concat "select "
				   (concatl column-names","(function id))
				   " from "table))))
	     (apply (function osql-result) (cons no (arraytolist (first result))))
	     (1++ no)))))
    ;; This is something that should be on all mapped types of type 
    ;; relational.
    (/putobject fno 'tablename table)
    ;; Remember that the ds object holds the connection. It must be 
    ;; present on a core-cluster function. These props *should* be put on the 
    ;; generic function but the translator API cannot assume that every extent
    ;; function has a generic function.
    (addfunction 'datasource (list fno) (list ds))

    fno))


(defun import-table-new (ds catalog schema table mtname updateable supertypes)
  (let* ((columns (get-columns-amos-typed ds table 'noerror))
	 (keycols (get-key-columns-amos-typed ds catalog schema table))
	 (cc-fno  (create-relational-core-cluster-fn-new
		   ds table columns keycols mtname))
	 (cc-name (generic-fnname cc-fno))
	 mt)
    (add-rewriter cc-fno (buildn (length columns) '+) 'rewrite-extent)
    (/putobject cc-fno 'CCLUSTERFCT? t);;added
    (setq mt (create-mapped-type mtname 
				 supertypes
				 (cons '(integer _ident_) columns )
				 '((integer _ident_))
				 cc-name))
    (add-amos-type    ds :wrapped table :amos mt)
    (add-wrapped-type ds :wrapped table :amos mt)
    (if updateable (create-keyed-update-fns ds mt columns keycols))
    (if updateable
	(set-constructor mt (create-sql-constructor ds mt))
      (forbid-constructor mt "This mapped type is read-only"))
    mt))


(defun import_table_new-------+ (fno ds catalog-name schema-name table-name 
				 type-name updateable supertypes mtp)
  (let ((mt (import-table-new ds 
			  (convert catalog-name)
			  (convert schema-name)
			  (convert table-name)
			  (or (convert type-name) 
			      (make-mapped-typename ds table-name))
			  (convert updateable)
			  (mapcar #'gettypenamed (convert supertypes)))))
    (osql-result ds catalog-name schema-name table-name
		 type-name updateable supertypes mt)))


(quote
(defun translate-sql2 (ds queryinfo filtervarlist) 
"Overwrite the function so that it doesn't generate 
 sql query if there are only '*' for the non-primary key variables  

  Each wrapper has a finalizer, which is a plug-in that translates 
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
    (if (and (eq (aref queryinfo 4) nil) (eq (aref queryinfo 3) nil) );;don't make sql if all *
	t 
      (setq sql-algebra-op 
	    `((, _apply_pred_ , queryfn ,@ invars ,@ outvars))))  ))
)