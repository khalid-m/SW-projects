;;; ===========================================================================
;;; AMOS2
;;;
;;; Author: (c) 2010 Robert Kajic, UDBL
;;; $RCSfile: select.lsp,v $
;;; $Revision: 1.1 $ $Date: 2010/07/12 05:12:54 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Evaluate select statement.
;;; ===========================================================================
;;; $Log: select.lsp,v $
;;; Revision 1.1  2010/07/12 05:12:54  roka4241
;;; Parsing of cql select and register queries (still unchanged from sql parser).
;;;
;;;
;;; ===========================================================================

;IN: 
;(SQL-SELECT ((COLUMN nil PERSON SSN) 
;	     (COLUMN nil PERSON NAME) 
;	     (COLUMN nil ZIP CITY)) 
;	    FROM ((nil PERSON) 
;		  (INNERJOIN ZIP nil 
;			     (= (COLUMN nil PERSON ZIP) 
;				(COLUMN nil ZIP ZIP)))) 
;	    WHERE (= (COLUMN nil nil NAME) "Fredrik"))
;OUT: 
;(OSQL-SELECT (#PERSON.SSN #PERSON.NAME #ZIP.CITY) 
;	     FOREACH ((INTEGER #PERSON.SSN) 
;		      (CHARSTRING #PERSON.NAME) 
;		      (INTEGER #PERSON.ZIP) 
;		      (INTEGER #ZIP.ZIP) 
;		      (CHARSTRING #ZIP.CITY)) 
;	     WHERE (AND (= (#PERSON #PERSON.SSN) 
;			   (TUPLE #PERSON.NAME #PERSON.ZIP)) 
;			(= (#ZIP #ZIP.ZIP) #ZIP.CITY) 
;			(AND (= #PERSON.NAME "Fredrik") 
;			     (= #PERSON.ZIP #ZIP.ZIP))))
;
;IN: 
;(SQL-SELECT ((COLUMN nil nil SSN) 
;	     (COLUMN nil nil NAME) 
;	     (CASE (COLUMN nil nil SSN) 740914 
;		   (CASE 
;		    (COLUMN nil nil NAME) 
;		    "Markus" "MARKUS" 
;		    ELSE (COLUMN nil nil NAME)) 
;		   (COND (< (COLUMN nil nil SSN) 740914) 710424 
;			 ELSE 750621) "Kirderf" 
;		   ELSE (COLUMN nil nil NAME))) 
;	    FROM ((nil PERSON)))
;OUT: 
;(OSQL-SELECT 
; (#PERSON.SSN 
;  #PERSON.NAME 
;  (MYIF (= #PERSON.SSN 740914) 
;	(MYIF (= #PERSON.NAME "Markus") "MARKUS" #PERSON.NAME) 
;	(MYIF (= #PERSON.SSN 
;		 (MYIF (< #PERSON.SSN 740914) 710424 750621)) 
;	      "Kirderf" #PERSON.NAME))) 
; FOREACH ((INTEGER #PERSON.SSN) 
;	  (CHARSTRING #PERSON.NAME) 
;	  (INTEGER #PERSON.ZIP)) 
; WHERE (= (#PERSON #PERSON.SSN) 
;	  (TUPLE #PERSON.NAME #PERSON.ZIP)))
;
;IN: 
;(SQL-SELECT ((COLUMN nil nil NAME) 
;	     (COUNT (COLUMN nil nil SSN))) 
;	    FROM ((nil PERSON)) 
;	    GROUPBY ((COLUMN nil nil NAME)))
;OUT: 

(defmacro SQL-SELECT (&rest params)
  "Dynamic call to SQL-SELECT"
  (translate-sql-select params))

(defun translate-sql-select (params)
  "Translates the SQL SELECT S-expression into an AMOSQL S-expression."
  (let ((querytype 'all) (fields nil) (from nil) (where nil) (groupby nil) 
	(having nil)(orderby nil) (vars nil) (funcparams nil) 
	(varslist nil) (thequery nil))
;   (princ "------------------") (terpri)
    ;; Split 'params' into subsections and check that the order of 
    ;;the sections are correct.
    (if (member (car params) '(all distinct))
	(setq querytype (pop params)))
    (if (not (listp (car params)))
	(error "SQL-SELECT" "List of required fields expected."))
    (setq fields (pop params))
    (if (not (= (pop params) 'from))
	(error "SQL-SELECT" "'FROM' expected."))
    (if (not (listp (car params)))
	(error "SQL-SELECT" "Table reference(s) expected after FROM clause."))
    (setq from (pop params))
    (if (= (car params) 'where)
	(progn
	  (pop params)
	  (if (not (listp (car params)))
	      (error "SQL-SELECT" 
		     "Search condition expected after WHERE clause.") )
	  (setq where (pop params)))
      (if (member 'where params)
	  (error "SQL-SELECT" 
		 (concat "WHERE is expected before " (car params) "."))))
    (if (= (car params) 'GROUPBY)
	(progn
	  (pop params)
	  (if (not (listp (car params)))
	      (error "SQL-SELECT" 
		     "Column reference(s) expected after GROUP BY clause."))
	  (setq groupby (pop params)))
      (if (member 'groupby params)
	  (error "SQL-SELECT" 
		 (concat "GROUP BY is expected before " (car params) "."))))
    (if (= (car params) 'having)
	(progn
	  (pop params)
	  (if (not (listp (car params)))
	      (error "SQL-SELECT" 
		     "Search condition expected after HAVING clause."))
	  (setq having (pop params)))
      (if (member 'having params)
	  (error "SQL-SELECT" 
		 (concat "HAVING is expected before " (car params) "."))))
    (if (= (car params) 'orderby)
	(progn
	  (pop params)
	  (if (not (listp (car params)))
	      (error "SQL-SELECT" 
		     "Column reference(s) expected after ORDER BY clause."))
	  (setq orderby (pop params))))
    (if params
	(error "SQL-SELECT" (concat "Unexpected data after end: " params)))
    ;;** Check the FROM clause
    ;;** IN format: 
    ;; ((<joinspec> <tablename> [{<alias> | nil} [<condition>] ]) ...)
    ;;** OUT: 
    ;; (((schema#Table1_name Table1_alias) ((type paramname1) ...) 
    ;; ((type resultname1) ...)) ...))
    (setq funcparams 
	  (mapcar 
	   #'(lambda (x)
	       (let ((tblname (sql_build-table-schema-name (cadr x)) ))
		 (append
		  (list (list
			 tblname
			 (if (caddr x)	;** Namingkonvention for variables:
			     (pack *currentschema* "#" (caddr x)) 
			   ;;**   New name: "... FROM _PERSON newname ..."
			   tblname	;**   Table name
			   )))
		  (getparameters tblname))))
	   from))
;   (princ "funcparams: ") (princ funcparams)(terpri)
    ;;** varslist: A structure with all columns, their type and their table
    ;;** structure: ((type (schema#table1 column1)) ... 
    ;;               (type (schema#tableN columnK)))
    (dolist (x funcparams)
      (setq varslist 
	    (append 
	     varslist (mapcar 
		       #'(lambda (y) (list (car y) (list (cadar x) (cadr y)) ))
		       (cadr x))))
      (setq varslist 
	    (append 
	     varslist (mapcar 
		       #'(lambda (y) (list (car y) 
					   (list (cadar x) 
						 (cadr y)) ))
		       (caddr x) 
		       ))))
    ;;** vars: A complete structure for the FOREACH part of the query.
    (setq vars (mapcar 
		#'(lambda (x) (list (car x) 
				    (pack (car (cadr x)) 
					  "." 
					  (cadr (cadr x))) ))
		varslist))
;   (princ "varslist: ") (princ varslist) (terpri)
;   (princ "vars: ") (princ vars) (terpri)

    ;; Look for stars in the column selection and replace them with all columns
    (setq fields (let ((res nil))
		   (dolist (f fields)
		     (if (= f '*)
			 (setq res (append res (getallfields varslist)))
		       (if (and (listp f) (= (car f) '*))
			   (setq res (append res 
					     (getallfields varslist (cdr f) )))
			 (setq res (append res (list f))))))
		   res))

    ;; Look through the fields to find function calls that has to be translated
    (setq fields (expandfunctions fields t))

    ;; Check the fields for fieldnames without table specified 
    ;; and try to find the table
    ;; If done with strings: "SELECT name" -> "SELECT person.name"
    ;; updatenames ignores the first argument of the list, 
    ;; so we add a dummy, which is removed before used.
    (setq fields (cdr (updatenames (append (list nil) fields) varslist)))
;   (princ "fields(2): ") (princ fields) (terpri)

;   (princ "fields(1): ") (princ fields) (terpri)

    ;; Append the JOIN conditions to the WHERE clause
    (let ((on nil))
      (dolist (x from)
        (if (= (ilength x) 4)
	    (setq on (append on (list (fourth x))))))
      (if (> (ilength on) 0)
	  (if where
	      (setq where (append '(and) (list where) on))
	    (setq where (append (list 'AND) on)))))

    (setq where (expandfunctions where nil)) 
    ;; in the where-clause the first thing in the list is never a column name
;   (princ "where: ") (princ where) (terpri)
    ;; Update all column names in the where clause
    (if (not (null where))
	(setq where (updatenames where varslist)))

    ;; Append the actual JOIN:ing conditions to the WHERE clause 
    ;;(i.e. _PERSON(SSN)=<NAME, ZIP>).
    (let ((pred (list 'and)) (params nil))
      (dolist (func funcparams)
        (setq params 
	      (list
	       (mapcar #'(lambda (x) 
			   (list (car x) 
				 (pack (cadar func) "." (cadr x)))) 
		       (cadr func))
	       (mapcar #'(lambda (x) 
			   (list (car x) 
				 (pack (cadar func) "." (cadr x)))) 
		       (caddr func))))
        (case (ilength (cadr params))
	  ('0
	   (setq pred 
		 (append pred 
			 (list (append
				(list (caar func))
				(mapcar #'(lambda (x) (cadr x)) 
					(car params)) ; 2004-08-18
;            (mapcar #'(lambda (x) (cadr x)) (cadr params))
				)))))
	  ('1
	   (setq pred 
		 (append pred 
			 (list (list
				'= 
				(append (list (caar func)) 
					(mapcar #'(lambda (x) (cadr x)) 
						(car params)))
				(cadr (caadr params))
				)))))
	  (OTHERWISE
	   (setq pred 
		 (append pred 
			 (list (list 
				'=
				(append (list (caar func)) 
					(mapcar #'(lambda (x) (cadr x)) 
						(car params)))
				(append (list 'tuple) 
					(mapcar #'(lambda (x) (cadr x)) 
						(cadr params)))
				)))))))
      (if (> (ilength pred) 0)
	  (if (null where)
	      (setq where pred)
	    (setq where (append pred (list where))))))
;     (setq where (expandfunctions where t))

    ;; Look at the GROUP BY part and rebuild the query if neccesary
    (if (or (not (null groupby)) (findagg fields))
	(let ((agg nil) (sel nil) (temp nil) (curcol nil) (pred nil))
	  ;; If no GROUP BY clause were specified, 
	  ;; we check that aggregate functions are not mixed 
	  ;;with regular columns.
	  (if (null groupby)
	      (if (member nil (mapcar (function findagg) fields))
		  (error "SQL-SELECT" 
			 "It is not allowed to mix aggregated columns (COUNT, MAX, AVG ...) with non aggregated if there is no GROUP BY clause.")))
;         (trace updatenames)
	  (setq groupby (cdr (updatenames (append (list nil) groupby) 
					  varslist)))
;         (untrace)
	  (setq temp (mapcar (function findagg) fields))
          ;; Step through all fields, when an aggregate function is found, 
          ;; the field is added to the A-vector
          ;; otherwise it is added to the V-vector
;         (princ "fileds: ") (princ fields) (terpri)
;         (princ "groupby: ") (princ groupby) (terpri)

	  (dolist (f fields)
	    (setq curcol f)
	    (if (in '* curcol)
		(if agg
		    (setq curcol (subpair '((sql_count *)) 
					  (list (list 'sql_count (car agg))) 
					  curcol))
		  (setq curcol 
			(subpair '((sql_count *)) 
				 (list (list 'sql_count 
					     (car (getallfields varslist)))) 
				 curcol))))
;           (princ "curcol: ") (princ curcol)(terpri)
            ;; Find all aggregate functions used in the SELECT clause 
            ;; and act upon each of them...
	    (setq temp (findagg (list curcol)))
	    (dolist (x temp)
	      (if (findagg (cdr x))
		  (error "SQL-SELECT" 
			 (concat "Aggregate functions may NOT be nested, as is the case with: " 
				 x ".")))
              ;; Add the aggregate to the list 'agg' 
              ;; if it is not there allready.
	      (if (not (member (cadr x) agg))
		  (setq agg (append agg (cdr x))))
              ;;* SQL_COUNT is the only aggregate function 
              ;; that only takes one parameter
	      (setq curcol 
		    (subpair
		     (list x)
		     (if (equal (car x) 'sql_count)
			 (list (list (car x) 'a))
		       (list (list (car x) 
				   'a 
				   (1- (ilength (member (cadr x) 
							(reverse agg)) )) )))
		     curcol)))
            ;; Replace the columns without aggregate functions 
            ;; to a (VREF V nn)-clause.
	    (setq curcol (subpair
			  groupby
			  (let ((tmp nil)) 
			    (dotimes (i (ilength groupby))
			      (setq tmp (cons (list 'vref 'v i) tmp)))
			    (reverse tmp))
			  curcol))
	    (setq sel (append sel (list curcol))))
	  ;;** Convert all field names in the HAVING clause
	  (if (and (listp having) having)
	      (progn
		(setq pred (updatenames having varslist))

		(if (in '* pred)
		    (if agg
			(setq pred (subpair '((sql_count *)) 
					    (list (list 'sql_count (car agg))) 
					    pred))
		      (setq pred
			    (subpair '((sql_count *)) 
				     (list (list 'sql_count 
						 (car (getallfields varslist)))) 
				     pred))))

		(setq temp (findagg pred))
		(dolist (x temp)
		  (if (findagg (cdr x))
		      (error "SQL-SELECT" 
			     (concat "Aggregate functions may NOT be nested, as is the case with: " 
				     x ".")))
		  ;;* SQL_COUNT is the only aggregate function 
		  ;; that only takes one parameter
		  (if (not (member (cadr x) agg))
		      (setq agg (append agg (cdr x))))
		  (setq pred 
			(subpair
			 (list x)
			 (if (equal (car x) 'sql_count)
			     (list (list (car x) 'a))
			   (list 
			    (list (car x) 
				  'a 
				  (1- (ilength (member (cadr x) 
						       (reverse agg)) )) ))
			   )
			 pred)))

		(setq pred (subpair
			    groupby
			    (let ((tmp nil)) 
			      (dotimes (i (ilength groupby))
				(setq tmp (cons (list 'vref 'v i) tmp)))
			      (reverse tmp))
			    pred)))
	    (setq pred 'true))

	  (setq thequery (list 'osql-select))
	  (if (equal querytype 'DISTINCT)
	      (setq thequery (append thequery (list 'distinct))))
	  (setq thequery (append
			  thequery
			  (list
			   sel
			   'foreach '((vector v) (vector a))
			   'where 
			   (list 'and
				 (list '= 
				       '(tuple v a) 
				       (list 'group_by
					     (list 'select (append groupby agg)
						   'foreach vars
						   'where where)
					     (ilength groupby)))
				 pred))))
;          (princ "agg: ") (princ agg) (terpri)
;          (princ "sel: ") (princ sel) (terpri)
;          (princ "pred: ") (princ pred) (terpri)
	  ))

    ;; Assemble the query, unless GROUP BY was use - then the query is 
    ;; allready assembled.
    (if (not thequery)
	(if (equal querytype 'DISTINCT)
	    (setq thequery (list 'osql-select 'distinct fields
				 'foreach vars
				 'where where))
	  (setq thequery (list 'osql-select fields
			       'foreach vars
			       'where where))))

    ;;** Take care of the ORDER BY clause.
    ;;** IN: (({DESC | ASC} {<column name> | <column number>}) [ ... ])
    (if orderby
	(progn
	  (setq orderby (expandfunctions orderby t))
	  (setq orderby 
		(cdr (updatenames (append (list nil) orderby) 
				  varslist)))
	  (setq orderby (subpair
			 fields
			 (let ((tmp nil)) 
			   (dotimes (i (ilength fields))
			     (setq tmp (cons (1+ i) tmp)))
			   (reverse tmp))
			 orderby))
	  (dolist (x orderby)
	    (if (not (numberp (second x)))
		(error "SQL-SELECT" 
		       (concat "Only columns listed in the select clause and numbers are valid for ORDER BY. \"" 
			       (second x) "\" is neither."))))
	  (setq orderby (mapcar 
			 #'(lambda (x)
			     (list (car x) (1- (cadr x))))
			 orderby))
	  (let ((order nil))
	    (dolist (x orderby)
	      (if (not (numberp (cadr x)))
		  (error "SQL-SELECT" 
			 (concat "Unknown column reference: \"" 
				 (cadr x) " " (car x) "\".")))
	      (if (or (< (cadr x) 0) (> (cadr x) (1- (ilength fields)) ))
		  (error "SQL-SELECT" 
			 (concat "Illegal column reference: \"" 
				 (cadr x) " " (car x) "\".")))
	      (setq order (append order (list (cadr x) (mkstring (car x)))))
	      )
;           (princ (list "order: " order)) (terpri)
	    (setq thequery (list
			    'osql-select (list (list
						'order_by
						(cons 'select (cdr thequery))
						(cons 'vector order)))
			    )))))
    (if sql-debugging
	(kwote thequery)
      thequery)))

(defun updatenames (lst data)
  "Recursively convert lst by using function getname"
  (append
   (list (pop lst))
   (mapcar
    #'(lambda (x)
        (if (and x (listp x))
	    (if (equal (car x) 'column)
		(getname x data)
	      (updatenames x data))
          x))
    lst)))

;(defun getname (name data)
;  "Searches for a column name in 'data' and tries to convert \"name\" into \"tbl.name\"."
;  (if (and (symbolp name) (not (= name '*)))
;    (if (member '. (explode name))
;      name
;      (let ((res nil))
;        (dolist (y data)
;          (if (= (cadr (cadr y)) name)
;            (setq res (append res (list (caadr y))))
;          )
;        )
;        (if (= (ilength res) 1)
;          (pack (car res) "." name)
;          (if (= (ilength res) 0)
;            (error "SQL-SELECT" (concat "Unable to resolve column name \"" name "\"."))
;            (error "SQL-SELECT" (concat "The column name \"" name "\" was found in more than one table."))
;          )
;        )
;      )
;    )
;    name
;  )
;)
(defun getname (name data)
  "Searches for a column name in 'data' and tries 
to convert \"name\" into \"tbl.name\"."
  (if (and (equal (car name) 'column) (not (= (nth 3 name) '*)))
      (let ((schema (nth 1 name)) (table (nth 2 name)) (column (nth 3 name)))
	(if (not schema)
	    (setq schema *currentschema*))
	(if (not table)
	    (let ((res nil))
	      (dolist (y data)
		(if (= (cadr (cadr y)) column)
		    (setq res (append res (list (caadr y))))))
	      (if (= (ilength res) 1)
		  (setq table (car res))
		(if (= (ilength res) 0)
		    (error "SQL-SELECT" 
			   (concat "Unable to resolve column name \"" 
				   column "\"."))
		  (error 
		   "SQL-SELECT" 
		   (concat "The column name \"" 
			   column "\" was found in more than one table.")))))
	  (setq table (pack schema "#" table)))
	(pack table "." column))
    name))

(defun getallfields (data &optional table)
  "Returns a list of fields matching '*' and '<table>.*' references."
  (let ((result nil) (field nil))
    (dolist (x data)
      (setq field (cadr x))
      (if (or (equal (car field) table) (not table))
	  (setq result (cons (pack (car field) "." (second field) ) result))))
    (reverse result)))

(defun expandfunctions (lst &optional first)
  "Recursive conversion of all CASE, COND, BETWEEN and IN 
   into nested MYIF statements."
;(princ "expandfunctions: ") (princ lst) (terpri)
  (if (or (not lst) (not (listp lst)))
      lst
    (if (not first)
	(case (car lst)
	  ('case
	      ;; IN: (CASE a 1 "ETT" 2 "TVÅ" 3 "TRE" 4 "FYRA" 5 "FEM" 
	      ;; ELSE "STORT")
	      ;; OUT: (MYIF (= a 1) "ETT" (MYIF (= a 2) "TVÅ" 
	      ;; (MYIF (= a 3) "TRE" (MYIF (= a 4) "FYRA" 
	      ;; (MYIF (= a 5) "FEM" "STORT")))))
	      (let ((res nil) (val (second lst)))
		(setq lst (reverse (cddr lst)))
		;; ("STORT" ELSE "FEM" 5 "FYRA" 4 "TRE" 3 "TVÅ" 2 "ETT" 1)
		(if (not (evenp (ilength lst)))
		    (error "expandfunctions" 
			   "CASE must have an even number of parameters!"))
		(if (= (cadr lst) 'else)
		    (progn
		      (setq res (expandfunctions (car lst)))
		      (setq lst (cddr lst)))
		  (setq res nil))
		(loop
;            (setq res (list 'MYIF (list '= val (expandfunctions (cadr lst))) 
;                                        (expandfunctions (car lst)) res))
		  (setq res 
			(list 
			 'ifsome 
			 (list 'select 
			       (list (list '= val 
					   (expandfunctions (cadr lst))) ))
			 (list 'select 
			       (list (expandfunctions (car lst)) ))
			 (list 'select (list res)) ))
		  (setq lst (cddr lst))
		  (if (< (ilength lst) 1)
		      (return res)))))
	  ('cond
	   ;; IN: (COND (= a 1) "ETT" (= a 2) "TVÅ" (= a 3) "TRE" (= a 4)                 ;; "FYRA" (= a 5) "FEM" (< a 1) "LITET" ELSE "STORT")
	   ;; OUT: (MYIF (= a 1) "ETT" (MYIF (= a 2) "TVÅ" 
	   ;; (MYIF (= a 3) "TRE" (MYIF (= a 4) "FYRA" 
	   ;; (MYIF (= a 5) "FEM" (MYIF (< a 1) "LITET" "STORT")))))
	   (let ((res nil))
	     (setq lst (reverse (cdr lst)))
             ;; ("STORT" ELSE "LITET" (< A 1) "FEM" (= A 5) 
             ;; "FYRA" (= A 4) "TRE" (= A 3) "TVÅ" (= A 2) "ETT" (= A 1))
	     (if (not (evenp (ilength lst)))
		 (error "expandfunctions" 
			"COND must have an even number of parameters!"))
	     (if (= (cadr lst) 'else)
		 (progn
		   (setq res (expandfunctions (car lst)))
		   (setq lst (cddr lst)))
	       (setq res nil))
	     (loop
;            (setq res (list 'MYIF (expandfunctions (cadr lst)) 
;                                  (expandfunctions (car lst)) res))
	       (setq res (list 
			  'ifsome 
			  (list 'select 
				(list (expandfunctions (cadr lst)) ))
			  (list 'select 
				(list (expandfunctions (car lst)) ))
			  (list 'select (list res)) ))
	       (setq lst (cddr lst))
	       (if (< (ilength lst) 1)
		   (return res)))))
	  ('in
	   ;; IN: (IN x 1 7 5 3 8)
	   ;; OUT: (OR (= x 1) (= x 7) (= x 5) (= x 3) (= x 8))
	   (let ((res (list 'OR)) (var (cadr lst)))
	     (dolist (x (cddr lst))
	       (setq res (append res (list (list '= var x)))))
	     res))
          (not
           ;; IN: (NOT x)
           ;; OUT: (NOTANY X) 
            (list 'notany (expandfunctions (second lst))))
	  ('between
	   ;; IN: (BETWEEN x 5 19)
	   ;; OUT: (AND (>= x 5) (<= x 19))
	   (list 'and (list '>= (expandfunctions (second lst)) 
			    (expandfunctions (third lst)))
		 (list '<= (expandfunctions (second lst)) 
		       (expandfunctions (fourth lst)))))
	  (otherwise
	   (append (list (car lst)) (mapcar (function expandfunctions)
					    (cdr lst)))))
      (mapcar (function expandfunctions) lst))))

(defun expandfunctions_not_in_use (lst &optional first table)
  "Recursive conversion of all CASE, COND, BETWEEN and IN 
   into nested MYIF statements."
; (princ "expandfunctions: ") (princ lst) (terpri)
  (if (or (not lst) (not (listp lst)))
      lst
    (if (not first)
	(case (car lst)
	  ('case
	      ;; IN: (CASE a 1 "ETT" 2 "TVÅ" 3 "TRE" 4 "FYRA" 5 "FEM" 
	      ;;      ELSE "STORT")
	      ;; OUT: (MYIF (= a 1) "ETT" (MYIF (= a 2) "TVÅ" (MYIF (= a 3) "TRE"
	      ;;         (MYIF (= a 4) "FYRA" (MYIF (= a 5) "FEM" "STORT")))))
	      (let ((res nil) (val (second lst)))
		(setq lst (reverse (cddr lst)))
		;; ("STORT" ELSE "FEM" 5 "FYRA" 4 "TRE" 3 "TVÅ" 2 "ETT" 1)
		(if (not (evenp (ilength lst)))
		    (error "expandfunctions" 
			   "CASE must have an even number of parameters!"))
		(if (= (cadr lst) 'else)
		    (progn
		      (setq res (expandfunctions (car lst) nil table))
		      (setq lst (cddr lst)))
		  (setq res nil))
		(loop
;            (setq res (list 'MYIF (list '= val 
;                 (expandfunctions (cadr lst) nil table)) 
;                 (expandfunctions (car lst) nil table) res))
		  (setq res 
			(list 
			 'ifsome 
			 (list 
			  'select 
			  (list (list '= val 
				      (expandfunctions (cadr lst) nil table)) ))
			 (list 'select (list 
					(expandfunctions (car lst) nil table) ))
			 (list 'select (list res)) ))
		  (setq lst (cddr lst))
		  (if (< (ilength lst) 1)
		      (return res)))))
	  ('cond
           ;; IN: (COND (= a 1) "ETT" (= a 2) "TVÅ" (= a 3) "TRE" 
           ;; (= a 4) "FYRA" (= a 5) "FEM" (< a 1) "LITET" ELSE "STORT")
           ;; OUT: (MYIF (= a 1) "ETT" (MYIF (= a 2) "TVÅ" 
           ;; (MYIF (= a 3) "TRE" (MYIF (= a 4) "FYRA" 
           ;; (MYIF (= a 5) "FEM" (MYIF (< a 1) "LITET" "STORT")))))
	   (let ((res nil))
	     (setq lst (reverse (cdr lst)))
             ;; ("STORT" ELSE "LITET" (< A 1) "FEM" (= A 5) 
             ;;  "FYRA" (= A 4) "TRE" (= A 3) "TVÅ" (= A 2) "ETT" (= A 1))
	     (if (not (evenp (ilength lst)))
		 (error "expandfunctions" 
			"COND must have an even number of parameters!"))
	     (if (= (cadr lst) 'else)
		 (progn
		   (setq res (expandfunctions (car lst) nil table))
		   (setq lst (cddr lst)))
	       (setq res nil))
	     (loop
;            (setq res (list 'myif (expandfunctions (cadr lst) nil table) 
;                                  (expandfunctions (car lst) nil table) res))
	       (setq res 
		     (list 'ifsome 
			   (list 'select 
				 (list (expandfunctions (cadr lst) nil table)))
			   (list 'select 
				 (list (expandfunctions (car lst) nil table) ))
			   (list 'select (list res)) ))
	       (setq lst (cddr lst))
	       (if (< (ilength lst) 1)
		   (return res)))))
	  ('in
           ;; IN: (IN x 1 7 5 3 8)
           ;; OUT: (OR (= x 1) (= x 7) (= x 5) (= x 3) (= x 8))
	   (let ((res (list 'or)) (var (cadr lst)))
	     (dolist (x (cddr lst))
	       (setq res (append res (list (list '= var x)))))
	     res))
	  ('between
           ;; IN: (BETWEEN x 5 19)
           ;; OUT: (AND (>= x 5) (<= x 19))
	   (list 'and (list '>= (expandfunctions (second lst) nil table) 
			    (expandfunctions (third lst) nil table))
		 (list '<= (expandfunctions (second lst) nil table) 
		       (expandfunctions (fourth lst) nil table))))
	  ('column
           ;; IN: (COLUMN schema table column), schema and table may be nil
           ;; OUT: schema#table.column
	   (if table
	       (let ((schema *currentschema*) (tbl table))
		 (if (nth 1 lst)
		     (setq schema (nth 1 lst)))
		 (if (nth 2 lst)
		     (setq tbl (nth 2 lst)))
		 (pack schema "#" tbl "." (nth 3 lst)))
	     lst))
	  (otherwise
	   (append (list (car lst)) 
		   (mapcar (function expandfunctions) 
			   (cdr lst) 
			   (buildl lst nil) 
			   (buildl lst table)))))
      (mapcar (function expandfunctions)
	      lst (buildl lst nil) (buildl lst table)))))

(defun findagg (col)
  "Recursive search through 'col', looking for a list where 
first element is the name of an aggregate function."
  (if (not (and col (listp col)))
      nil
    (if (member (car col) '(sql_avg sql_avgd sql_sum sql_sumd 
				    sql_count sql_countd sql_max sql_min))
	(list col)
      (let ((res nil))
        (dolist (x col)
          (setq res (append res (findagg x))))
        (setq res (subset
		   res
		   #'(lambda (x) (not (null x)))))
        res))))

;** ORDER BY functions ***********************************
; Example:
; order_by((select s, n, z from integer s, charstring n, integer z 
;           where _person(s)=<n, z>), {1, "asc", 0, "asc"});

(defun sql< (x y)
  "Comparison function used for ORDER BY. Works with strings and numbers.
Everything else is converted to string before comparing."
  (if (stringp x)
    (string< x y)
    (if (numberp x)
      (< x y)
      (string< (mkstring x) (mkstring y)))))

(defun sql_sortfn (l1 l2 order)
  "SQL sort function used for ORDER BY."
; Example: (sort L (f/l (x y) (sql_sortfn x y 
;           '((2 . \"asc\") (0 . \"desc\")))))"
  (if order
      (let* ((dir (cdar order)) (column (caar order)) (x (nth column l1)) 
	     (y (nth column l2)))
	(if (equal x y)
	    (sql_sortfn l1 l2 (cdr order))
	  (if (string= (string-upcase dir) "DESC")
	      (sql< y x)
	    (sql< x y))))))

(defun order_by (fno data order rows)
  (let ((table nil) (myorder nil))
    (mapbag
     data
     #'(lambda (row)
	 (setq table (append table (list row)))))
    (dolist (x (arraytolist order))
      (if (listp (car myorder))
	  (setq myorder (cons x myorder))
        (let ((y (pop myorder)))
          (setq myorder (cons (cons y x) myorder)))))
    (setq myorder (reverse myorder))
    (dolist
	(row (sort table
		   #'(lambda (x y) (sql_sortfn x y myorder))))
      (osql-result data order row))))


(defun recursivelisttoarray (lst)
  (if (or (not lst) (not (listp lst)))
      lst
    (listtoarray (mapcar (function recursivelisttoarray) lst))))

;** SET FUNCTIONS **************
(defun sql-count (fno data cnt)
  "Foreign aggregate function to use together with group_by. 
Returns the size of the vector."
  (osql-result data (array-total-size data)))

(defun sql-countdistinct (fno data field cnt)
  "Foreign aggregate function to use together with group_by. 
Counts the number of rows where the field is non-NULL."
  (let ((cnt 0) (htable (make-hash-table :test (function equal))) (hval nil))
    (dolist (arr (arraytolist data))
      (setq hval (aref arr field))
      (if (not (gethash hval htable))
	  (progn
	    (setf (gethash hval htable) t)
	    (setq cnt (1+ cnt)))))
    (osql-result data field cnt)))

(defun sql-sum (fno data field sum)
  "Foreign aggregate function to use together with group_by. SQL: SUM(col)."
  (let ((sum 0))
    (dolist (arr (arraytolist data))
      (if (numberp (aref arr field))
	  (setq sum (+ sum (aref arr field)))))
    (osql-result data field sum)))

(defun sql-sumdistinct (fno data field sum)
  "Foreign aggregate function to use together with group_by. 
SQL: SUM(DISTINCT col)."
  (let ((sum 0) (htable (make-hash-table :test (function equal))) (val nil))
    (dolist (arr (arraytolist data))
      (setq val (aref arr field))
      (if (not (gethash val htable))
	  (progn
	    (setf (gethash val htable) t)
	    (if (numberp val)
		(setq sum (+ sum val))))))
    (osql-result data field sum)))

(defun sql-avg (fno data field result)
  "Foreign aggregate function to use together with group_by. SQL: AVG(col)."
  (let ((sum nil) (count 0))
    (dolist (arr (arraytolist data))
      (if (numberp (aref arr field))
	  (progn
	    (if (not sum)
		(setq sum (aref arr field))
	      (setq sum (+ sum (aref arr field))))
	    (setq count (1+ count)))))
    (if (> count 0)
	(osql-result data field (/ sum count))
      (osql-result data field sum))))

(defun sql-avgdistinct (fno data field sum)
  "Foreign aggregate function to use together with group_by. 
SQL: AVG(DISTINCT col)."
  (let ((sum nil) (count 0) (htable (make-hash-table :test (function equal))) 
	(val nil))
    (dolist (arr (arraytolist data))
      (setq val (aref arr field))
      (if (not (gethash val htable))
	  (progn
	    (setf (gethash val htable) t)
	    (if (numberp val)
		(progn
		  (if (not sum)
		      (setq sum val)
		    (setq sum (+ sum val)))
		  (setq count (1+ count)))))))
    (if (> count 0)
	(setq sum (/ sum count)))
    (osql-result data field sum)))


(defun sql-max (fno data field sum)
  "Foreign aggregate function to use together with group_by. SQL: MAX(col)."
  (let ((maxval nil))
    (dolist (arr (arraytolist data))
      (if (aref arr field)
	  (if (not maxval)
	      (setq maxval (aref arr field))
;          (setq maxval (max maxval (aref arr field)))
	    (if (sql< maxval (aref arr field))
		(setq maxval (aref arr field))))))
    (osql-result data field maxval)))

(defun sql-min (fno data field sum)
  "Foreign aggregate function to use together with group_by. SQL: MIN(col)."
  (let ((minval nil))
    (dolist (arr (arraytolist data))
      (if (aref arr field)
	  (if (not minval)
	      (setq minval (aref arr field))
;          (setq minval (min minval (aref arr field)))
	    (if (sql< (aref arr field) minval)
		(setq minval (aref arr field))))))
    (osql-result data field minval)))


;IN: 
;(SQL-SELECT (_PERSON.SSN _PERSON.NAME _ZIP.CITY) 
;	    FROM ((nil _PERSON)
;		  (INNERJOIN _ZIP nil (= _PERSON.ZIP _ZIP.ZIP))) 
;	    WHERE (AND (= NAME
;			  "Fredrik")))
