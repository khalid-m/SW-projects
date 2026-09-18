;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Matin Hansson, UDBL
;;; $RCSfile: sqlquery.lsp,v $
;;; $Revision: 1.23 $ $Date: 2013/05/01 15:35:28 $
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
    (unique (mapcar (f/l (v) (get-varentity v)) allvars))))

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


(defun simpfunc3 (pred q varpredassnlst)
  "this function transform the orblock"
  (let ((sp (sqlquery-sourcepred q))
	 )
    (cond ((sourcepred? pred)
	   (cond (sp
		  (setf (sqlquery-sourcepred q) (nconc1 sp pred)))
		 (t;;no SP
		  (setf (sqlquery-sourcepred q) (list pred)))))
	  ((and (numericalp pred) 
		(arithpred-binds-var-p pred varpredassnlst))
	   nil);;return nil 
	  (t;; 
	   pred)
	  )))

(defun sql-outputpred (pred resl accessfiltervarlist)
  "the predicate has a argument in selectbody-resl and that var is not a 
   accessfitervarlist"
  (let ((predvarlist (predicate-vars pred))
	)
    (some (f/l (var)
	       (and (memq var resl)
		    (not (memq var accessfiltervarlist))))
	  predvarlist)))

(defun arithpred-binds-var-p (pred varpredassnlst)
  (memq pred (mapcar (f/l (assnlst) (lastelem assnlst))
		     varpredassnlst)))

;;absorbed predicates are distributed here
(defun sqlquery-add-predicate (q pred &optional resl)
  "distribute the pred into proper place in q and might also need to modify 
   the OR block to remove the intermediate num pred used to help to translate
   into a combination of comparison and num perd sql expression"
  (let* ((sp (sqlquery-sourcepred q))
	 (nsp (sqlquery-selectpred q))
	 (accessfitervarlist (sqlquery-accessfiltervarlist q))
	 (varpredassnlst (sqlquery-varpredassnlst q))
	 )
    (cond ((sourcepred? pred)
	   (cond (sp
		  (setf (sqlquery-sourcepred q) (nconc1 sp pred)))
		 (t;;no SP
		  (setf (sqlquery-sourcepred q) (list pred)))))
	  ((and (numericalp pred) 
		(sql-outputpred pred resl accessfitervarlist))
	   ;;add the last element in argument list to sql output
	   (sqlquery-add-output q (lastelem (predicate-arguments pred)))
	   )
	  ;;intermediate num pred should not be put into sqlquery-selectpred
	  ((and (numericalp pred) 
		(arithpred-binds-var-p pred varpredassnlst)
		));;do nothing
	  ((compound-p pred)
	   (let (orblock
		 )
	     (setq orblock
		   (map-over-pred pred 
				  (f/l (simppred)
				       (simpfunc3 simppred q varpredassnlst))
				  (function id)))
	     (cond (nsp
		    (setf (sqlquery-selectpred q) (nconc1 nsp orblock)))
		   (t
		    (setf (sqlquery-selectpred q) (list orblock))))))
	  (t;; 
	   (cond (nsp
		  (setf (sqlquery-selectpred q) (nconc1 nsp pred)))
		 (t
		  (setf (sqlquery-selectpred q) (list pred))))))
    q))

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

(defun translate-sourcepredicate (sqlq)
  "translate absorbed source predicates"
  (let ((ds (sqlquery-datasource sqlq))
	(SPs (sqlquery-sourcepred sqlq))
	)
    (mapc (f/l (sp)
	       (relational-translate-source-predicate ds sp sqlq))
	  (reverse SPs))))

(defun make-column-string (q ci tablealiases)
  (let* ((ti (columninfo-tableinfo ci))
	 (colname (columninfo-name ci)))
    (if (column-ambiguous? q ci)
	(concat (cdr (assoc ti tablealiases))"."colname)
      colname)))


(defun make-infer-string (v sqlq tablealiases)
  "generate the complicated sql string, e.g numerical expression"
  (let* ((arithpred (get-arithpred v sqlq));;arithmetic pred binds v
	 )
    (cond (arithpred
	   (let* ((fno (predicate-operator arithpred))
		  (op (generic-fnname fno));;amos function operator
		  ;;sql operator, infix, hasvalue, reverse
		  (sqlopinfor (getfunction-firsttuple _sqlop_ (list fno)))
		  (infix (second sqlopinfor))
		  (sqlop (car sqlopinfor))
		  )
	     (if sqlop
		 (sql-infer-call arithpred sqlop infix sqlq  v tablealiases)
	       (sql-infer-call arithpred op infix sqlq v tablealiases))
	       )))))
			    

(defun boundbyarithpredp (v varpredassnlst)
    ;;if v is arithmetic pred binds var, return true
  (memq v (mapcar (f/l (assnlst) (car assnlst))
		  varpredassnlst)))


(defun make-variable-string (sqlq v tablealiases)
  (let* ((ds (sqlquery-datasource sqlq))
	 (e (get-varentity v))
	 (vboundby (get-varboundby v))
	 (varpredassnlst (sqlquery-varpredassnlst sqlq))
	 )  
    (cond ((and (columninfo-p e) (eq (get-vards v) ds)
		(null vboundby));;v is already bound  
	   (make-column-string sqlq e tablealiases))
	  ;;((and (numpredvarp v numpreds) (null (get-vards v)))
	  ((and (boundbyarithpredp v varpredassnlst) (null (get-vards v)) 
		(null (varboundp v)))
	   (make-infer-string v sqlq tablealiases))
	  (t                
	   (sqlquery-add-input sqlq v)
	   "?"))))

;;for predicate like
(defun make-like-pred-string (q li tablealiases)
  (cond ((varsymbolp li)   (make-variable-string q li tablealiases))
	((stringp li) 	   
	 (concat "'" (concatl (subst "%" "*" (explode li)) "") "'"))
	((columninfo-p li) (make-column-string q li tablealiases))
	(t li)
	))

(defun make-literal-string (q li tablealiases)
  (cond ((varsymbolp li)   
	 (make-variable-string q li tablealiases))
	((stringp li) 	   
	 (cond ((or (equal li "is not null") (string-like li "*<>*")) 
		li)
	       ((equal li "?")
		li)
	       (t
		(concat "'"li"'"))))
	((columninfo-p li) (make-column-string q li tablealiases))
	(t li)
	))

;;entry function to translate a variable to a column name
(defun sql-literal-strings (q pred tablealiases)
  "Generate SQL references for arguments of predicate PRED"
  (cond ((eq (generic-fnname (predicate-operator pred)) 'like)
	 (mapcar (f/l (arg) 
		      (make-like-pred-string q arg tablealiases))
		 (predicate-arguments pred)))
	(t
	 (mapcar (f/l (a)
		      (cond ((datep a) (date-to-string a))
			    ((timevalp a) (timeval-to-string a))
			    ((constant-arrayp a) (constant-array-to-string a))
			    (t (make-literal-string q a tablealiases))))
	  (predicate-arguments pred)))
))


(defglobal _sqlop_ (theresolvent 'sqlop) "OID of table sqlop()")

;;entry function to make where clause string
(defun make-predicate-string (q pred tblaliases)
  "Generate SQL where clause predicate string for predicates in selectpred 
   of sqlquery q"
  (let* ((fno (predicate-operator pred))
	 (sqlopinfor (getfunction-firsttuple _sqlop_ (list fno)))
	 )
    (cond (sqlopinfor
	   (apply (f/l (sqlop infix hasvalue reverse)
		       (cond ((is-true infix)
			      (if (is-true hasvalue) 
				  ;;+, -, *, /, etc
				  (sql-infix-call sqlop q  
						  (reverse-args pred reverse)
						  tblaliases) 
				;;infix and has no value, e.g in 
				(infix-string 
				 sqlop
				 (sql-literal-strings q 
						      (reverse-args pred 
								    reverse)
						      tblaliases))))
			     (t;;prefix
			      (if (is-true hasvalue)
				  ;;abs, greater, etc
				  (sql-prefix-call sqlop q pred tblaliases)
				;;prefix and has no value, 
				(prefix-string fno
					       (sql-literal-strings q pred 
								    tblaliases))))))
		  sqlopinfor))
	  (t (error "can't find in SQLoperator table" fno)))
    ))

(defun sql-prefix-call (op q pred tablealiases)
  "Construct predicate string of prefix SQL function with return value."
  (let ((fno (predicate-operator pred))
	(args (sql-literal-strings q pred tablealiases)))
    (concat (prefix-string fno (butlast args))
	    " = "
	    (car (last args)))))
	
(defun sql-infix-call (op q pred tablealiases)
  "Construct predicate string of infix SQL function with return value.
   e.g. salary+salary=50000."
  (let ((fno (predicate-operator pred))
        (args (sql-literal-strings q pred tablealiases))) 
    (concat (car (last args))
	    " = "
	    (infix-string op (butlast args)))))



(defun make-selectclause (q tablealiases)
  (let ((output (sqlquery-output q))
	)
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
	   
(defun transform-compoundpred (predl)
  "predl, e.g (AND 'salary > v13' nil)"
  (let* ((filteredpredl (mapfilter (f/l (pred) (if pred
						  t
						nil))
				  predl));;filter out nil 
	(numofpreds (length (cdr filteredpredl)))
	)
    (cond ((= numofpreds 1);;only one pred
	   (concat (cdr filteredpredl)))
	  (t;;more than one pred inside predl
	   (concatl (cdr filteredpredl) (concat " " (car filteredpredl) " "))))
    ))

(defun trim-whereclausestring (whereclausestring)
  "take off the redundent starting left parentheses and ending right 
   paratheses for the where clause string."
  (substring 1 (- (length whereclausestring) 2)  whereclausestring)) 

(defun translate-wherepredl (predl q tablealiases)
  (map-over-pred predl
		 (f/l (pred) 
		      (if (leaf-predicate-p pred)
			  (make-predicate-string q pred tablealiases)
			pred))
		 (f/l (predl) 
		      ;;add extra parenthese for compound predl
		      (concat "(" 
			      (transform-compoundpred predl)
			      ")"))))

(defun make-whereclause (q tablealiases)
  (let ((preds (sqlquery-selectpred q))
	predl
	)
    (cond ((= (length preds) 1);;one predicate
	   (setq predl (car preds))
	   (concat "where " (translate-wherepredl predl q tablealiases)))
	  ((> (length preds) 1);;more than one predicate
	   (setq predl (andify preds))
	   (concat "where " 
		   (trim-whereclausestring 
		    (translate-wherepredl predl q tablealiases))))
	  (t ;; no predicate in where clause
	   ""))))	

(defun get-sql-string (q)
  (let ((tablealiases (make-table-aliases (sqlquery-projections q))))
    (concat (make-selectclause q tablealiases)
	    (make-fromclause   q tablealiases)
	    (make-whereclause  q tablealiases))))


(defun generate-sql-string (q)
  (translate-sourcepredicate q);;first translate source predicate 
  (get-sql-string q);;translate predl in sqlquery-selectpred
  )
