;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Matin Hansson, UDBL
;;; $RCSfile: sqlquery.lsp,v $
;;; $Revision: 1.7 $ $Date: 2012/08/07 07:04:29 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: SQL finalizer
;;; =============================================================

; Fn used to wrap relational data sources with different SQL dialects.
(defglobal 
  _dialect_ 
  (osql "
create function dialect(Charstring datasource)->Charstring as stored;"))

(defglobal _dsname_ (getfunctionnamed 'datasource.name->charstring))


; Fn used to extract dialect of a data source
(defun ds-dialect (q)
  (caar (getfunction
	 _dialect_ (car 
		    (getfunction _dsname_ 
				 (list (sqlquery-datasource q)))))))

(defun print-sqlquery (sqlq)
  (princ "datasource:")(print (sqlquery-datasource sqlq))
  (princ "input     :")(print (sqlquery-input      sqlq))
  (princ "output    :")(print (sqlquery-output     sqlq))
  (princ "selectpred:")(pps (sqlquery-selectpred sqlq)))

; publicly available functions

(defun sqlquery-add-table (q table) 
  "Adds a table name as symbol to the tables queried in this sqlquery.
   Returns a tableinfo struct."
  (let* ((incarnations (sqlquery-projections q))
	 (incarnation  (assq table incarnations))
	 incarnation-no)
    (cond (incarnation
	   (setq incarnation-no (1+ (cdr incarnation)))
	   (rplacd incarnation incarnation-no))
	  (t
	   (setq incarnation-no 1)
	   (setf (sqlquery-projections q)
		 (push (cons table 1) incarnations))))
    (make-tableinfo :name table :incarnation-no incarnation-no)))

(defun sqlquery-tables (q)
  (mapcar (function first) (sqlquery-projections q)))


(defun sqlquery-tableinfos (sqlq)
  "Retrieves the tableinfo:s for all table incarnations in the sqlquery."
  (mapcan (f/l (pair)
	       (let ((tablename (car pair))
		     (count (cdr pair)) 
		     res) 
		 (while (> count 0)
		   (push (make-tableinfo :name tablename :incarnation-no 
					 (--1 count)) res))
		 res))
	  (sqlquery-projections sqlq)))

(defun sqlquery-add-output (q v)
  "Adds a variable to the output varables in the query."
  (setf (sqlquery-output q) (adjoin-last (sqlquery-output q) v)))

(defun adjoin-last (l x)
  (if (memq x l) l
    (nconc1 l x)))

(defun sqlquery-add-input (q v)
  "Adds a variable to the input varables to the query if not already 
   a member of those."
  (setf (sqlquery-input q) (nconc1 (sqlquery-input q) v)))

(defun sqlquery-get-referenced-columns (q)
  (let ((allvars
	 (append
	  (sqlquery-input q)
	  (sqlquery-output q)
	  (fold-predicate #'predicate-variables (sqlquery-selectpred q)))))
    (unique (mapcar (f/l (v) (entity v (sqlquery-environment q))) allvars))))

(defun column-ambiguous? (q ci)
  "Tells if a column name is ambiguous given a column identifier ci and a 
   query context q. The quick rejection is if the same tablename appears
   more than once. Otherwise the column name is compared for equality with 
   all other columns in all other tables in the query." 
  (let* ((colname   (columninfo-name ci))
	 (tablename (columninfo-table ci))
	 (othertbls (remove tablename (sqlquery-tables q))))
    (or
     (> (cdr (assq tablename (sqlquery-projections q))) 1)
     (dolist (table othertbls)
       (if (memq colname (get-column-names (sqlquery-datasource q) table))
	   (return t))))))

(defun sqlquery-add-predicate (q pred)
  (let ((sp (sqlquery-selectpred q)))
    (cond ((conjunctionp sp)
	   (nconc1 (sqlquery-selectpred q) pred))
	  ((leaf-predicate-p sp)
	   (setf (sqlquery-selectpred q)
		 (andify (nconc1 (list sp) pred))))
	  (t
	   (setf (sqlquery-selectpred q) pred)))
    q))

(defun sqlquery-add-numpreds (queryinfo numpreds)
  (setf (sqlquery-numpreds queryinfo) numpreds)) 

(defun sqlquery-remove-numpred (numpred queryinfo)
  (setf (sqlquery-numpreds queryinfo) 
	(remove numpred (sqlquery-numpreds queryinfo))))

;;;-------------------------------------------------------------------
;;;
;;; Conversion to SQL strings
;;;
;;;-------------------------------------------------------------------

(defun shortest-unique-prefix (symbol symbols)
  "Find the shortest prefix that distinguishes a string
   from all the others. The empty string if none."
  (let ((lsyms (mapcar (function explode) symbols))
	(lsym (explode symbol))
	prefix)
    (while lsyms
      (let ((s (pop lsym)))
	(setq lsyms (mapfilter (f/l (ls) (equal (first ls) s)) lsyms))
	(mapl (f/l (l) (rplaca l (cdar l))) lsyms)
	(putlast prefix s)))
    (apply (function concat) prefix)))

(defun make-table-aliases (projections)
  "A table alias is used when a table is ambiguous, for instance in a 
   self-join. The purpose of aliases is to find the minimal string that can 
   uniquely distinguish a table. This is done by finding a shortest prefix
   to distinguish it from other tables, and by adding a number at the end
   to distinguish it from itself, if necessary.
   All tables have aliases created for them,
   should the need arise. If the table name is unambiguous in the given 
   context its alias becomes the empty string."
  (let ((allnames (mapcar (function car) projections))
	aliases)
    (dolist (name allnames)
      (let* ((count  (cdr (assq name projections)))
	     (prefix (shortest-unique-prefix name (remove name allnames))))
	(dotimes (i count)
	  (let* ((ti       (make-tableinfo :name name :incarnation-no (1+ i)))
		 (idno       (if (= count 1) "" (1+ i)))
		 (usedprefix (if (and (equal prefix "") (> count 1))
				 (first (explode name))prefix))
		 (alias      (concat usedprefix (if (equal usedprefix "") "" 
						  '_) idno)))
	    (push (cons ti alias) aliases)))))
    aliases))

(defun make-column-string (q ci tablealiases)
  (let* ((ti (columninfo-tableinfo ci))
	 (colname (columninfo-name ci)))
    (if (column-ambiguous? q ci)
	(concat (cdr (assoc ti tablealiases))"."colname)
      colname)))


(defun make-infer-string (v sqlq tablealiases numpreds)
  (let* ((env (sqlquery-environment sqlq))
	 (bnd (gethash 'prebnd env))
	 (preds (gethash 'preds env))
	 (accessfiltervarlist (gethash 'accessfiltervarlist env))
	 (numinferpred (get-argnumpred v numpreds preds accessfiltervarlist 
				       bnd))
	)
    (cond (numinferpred
	   (let* ((numfno (predicate-operator numinferpred))
		  (sqlop (car (getfunction-firsttuple _sqlop_ (list numfno))))
		  )
	     (sql-incomplete-infix-call sqlop sqlq numinferpred numpreds 
					v tablealiases)
	     )))))

(defun make-variable-string (sqlq v tablealiases &optional numpreds)
  (let* ((ds (sqlquery-datasource sqlq))
	 (env (sqlquery-environment sqlq))
	 (e (entity v env)))  
    (cond ((and (columninfo-p e) (eq (datasource v env) ds))
	   (make-column-string sqlq e tablealiases))
	  ((and (sqlquery-numpreds sqlq) (null e) (null (datasource v env)))
	   (make-infer-string v sqlq tablealiases numpreds))
	  (t                "?"))))

;;changed by MP
(defun make-literal-string (q li tablealiases &optional numpreds)
  (cond ((varsymbolp li)   (make-variable-string q li tablealiases numpreds))
	((stringp li) 	   
	 (cond ((or (equal li "is not null") (string-like li "*<>*")) 
		li)
	       ((equal li "?")
		li)
	       (t
		(concat "'"li"'"))))
	((columninfo-p li) (make-column-string q li tablealiases))
;	((expression-p arg)
;	 (expression-to-string li))
	(t li)
	))

(defun sql-literal-strings (q pred tablealiases &optional numpreds)
  "Generate SQL references to arguments of predicate PRED in SQL query Q"
  (mapcar (f/l (a)
	       (cond ((datep a) (date-to-string a))
		     ((timevalp a) (timeval-to-string a))
		     ((constant-arrayp a) (constant-array-to-string a))
		     (t (make-literal-string q a tablealiases numpreds)))) 
	  (predicate-arguments pred)))



(defglobal _sqlop_ (theresolvent 'sqlop) "OID of table sqlop()")

(defun make-predicate-string (q pred tablealiases)
  "Generate SQL string for predicate PRED in SQL query Q"
  (let ((fno (predicate-operator pred))
	(numpreds (sqlquery-numpreds q)))
    (apply (f/l (op infix hasvalue reverse)
		(cond ((null op)
		       ;; Default infix operator with same name
                       (infix-string (generic-fnname fno) 
				     (sql-literal-strings q pred tablealiases 
							  numpreds)))
		      ((is-true infix)
		       (if (is-true hasvalue) 
                           (sql-infix-call op q  
					   (reverse-args pred reverse)
					   tablealiases)
			 (infix-string 
			  op
			  (sql-literal-strings q 
					       (reverse-args pred reverse)
					       tablealiases numpreds))))
		      (t (error "Cannot translate to SQL" fno))))
	   (getfunction-firsttuple _sqlop_ (list fno)))))

(defun sql-infix-call (op q pred tablealiases)
  "Construct call to infix SQL function"
  (let ((fno (predicate-operator pred))
        (args (sql-literal-strings q pred tablealiases)))
    (concat (car (last args))
	    " = "
	    (infix-string op (butlast args)))))
 
(defun make-selectclause (q tablealiases)
  (let ((output (sqlquery-output q)))
    (concat
     "select "
     (if output
	 (concatl output","(f/l (v)(make-literal-string q v tablealiases)))
       "1"))))

(defun make-fromclause (q tablealiases)
  (concat 
   " from "
   (concatl tablealiases
	    ","
	    (f/l (aliaspair) 
	      (let ((name  (tableinfo-name (car aliaspair)))
		    (alias (cdr aliaspair)))
		(concat name (if (equal alias "") "" (concat " "alias))))))
   " "))

;;changed by MP
(defun make-whereclause (q tablealiases)
  (let ((pred (sqlquery-selectpred q)))
    (if pred
	(concat 
	 "where "
	 (map-over-pred pred
			(f/l (pred) (make-predicate-string q pred 
							   tablealiases))
			(f/l (pred) (concatl (predicate-arguments pred)
					     " and "))
			))
      "")))

	       
(defun get-sql-string (q)
  (let ((tablealiases (make-table-aliases (sqlquery-projections q))))
    (concat (make-selectclause q tablealiases)
	    (make-fromclause   q tablealiases)
	    (make-whereclause  q tablealiases))))











;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;obsoleted code;;;;;;;;;;;;;;;;;;;;;;;
(quote
(defun sql-literal-strings (q pred tablealiases)
  "Generate SQL references to arguments of predicate PRED in SQL query Q"
  (mapcar (f/l (a)
	       (let* ((dppred (gethash a  _initiates_ )))		 
		 (cond ((neq dppred nil)
			;; subsitute a by infix-string from dppred
			(let* ((fno (predicate-operator dppred))
			       (sqlop (getfunction-firsttuple _sqlop_ 
							      (list fno)))
			       (op (first sqlop))
			       (infix (second sqlop))
			       (hasvalue (third sqlop)))
			  (sql-incomplete-infix-call op q dppred a  
						     tablealiases)))
		       ((datep a) (date-to-string a))
		       ((timevalp a) (timeval-to-string a))
		       ((constant-arrayp a) (constant-array-to-string a))
		       (t (make-literal-string q a tablealiases))))) 
	  (predicate-arguments pred)))
)


(quote
(defun make-whereclause (q tablealiases)
  (let ((pred (sqlquery-selectpred q)))
    (if pred
	(concat 
	 "where "
	 (visit-predicate (f/l (pred) (concatl (predicate-arguments pred)
					       " and "
					       (predicate-operator pred)))
			  (f/l (pred) (make-predicate-string q pred 
							     tablealiases))
			  (sqlquery-selectpred q)))
      "")))
)