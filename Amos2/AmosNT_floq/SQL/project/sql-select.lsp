;;; ===========================================================================
;;; AMOS2
;;;
;;; Author: (c) 2004 Markus Jägerskogh, UDBL
;;; $RCSfile: sql-select.lsp,v $
;;; $Revision: 1.18 $ $Date: 2013/11/07 18:07:53 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Evaluate SQL's SELECT statement
;;; ===========================================================================
;;; $Log: sql-select.lsp,v $
;;; Revision 1.18  2013/11/07 18:07:53  torer
;;; renamed group_by() into groupby_pos()
;;;
;;; Revision 1.17  2012/02/10 08:18:48  torer
;;; Code reorganization to enable maintenance
;;;
;;; Revision 1.16  2012/02/04 17:14:18  torer
;;; Namespaces for functions and types introduced as name prefixes, e.g.
;;;
;;; create function sql:person(Integer ssn) -> (Charstring name, Integer salary) as stored;
;;;
;;; The prefix sql: makes amos functions queryables with sql, e.g.:
;;;
;;; SELECT * FROM PERSON;
;;;
;;; Revision 1.15  2011/12/27 12:17:31  torer
;;; duplicate code
;;;
;;; Revision 1.14  2011/02/16 20:58:49  torer
;;; Simplified Lisp code
;;;
;;; Revision 1.13  2011/02/16 20:27:49  torer
;;; Changed bad Lisp code
;;;
;;; Revision 1.12  2011/02/16 19:46:33  torer
;;; Warning removed
;;;
;;; Revision 1.11  2010/02/25 21:15:36  torer
;;; Removed myif and not
;;;
;;; Revision 1.10  2009/05/07 21:36:06  torer
;;; groupby_pos moved
;;;
;;; Revision 1.9  2006/09/28 14:28:33  torer
;;; Streamed implementation of SQL function
;;;
;;; Revision 1.8  2006/02/24 20:18:52  torer
;;; Replaced QUOTE with FUNCTION
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
;(OSQL-SELECT (sql:PERSON.SSN sql:PERSON.NAME sql:ZIP.CITY) 
;	     FOREACH ((INTEGER sql:PERSON.SSN) 
;		      (CHARSTRING sql:PERSON.NAME) 
;		      (INTEGER sql:PERSON.ZIP) 
;		      (INTEGER sql:ZIP.ZIP) 
;		      (CHARSTRING sql:ZIP.CITY)) 
;	     WHERE (AND (= (sql:PERSON sql:PERSON.SSN) 
;			   (TUPLE sql:PERSON.NAME sql:PERSON.ZIP)) 
;			(= (sql:ZIP sql:ZIP.ZIP) sql:ZIP.CITY) 
;			(AND (= sql:PERSON.NAME "Fredrik") 
;			     (= sql:PERSON.ZIP sql:ZIP.ZIP))))
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
; (sql:PERSON.SSN 
;  sql:PERSON.NAME 
;  (MYIF (= sql:PERSON.SSN 740914) 
;	(MYIF (= sql:PERSON.NAME "Markus") "MARKUS" sql:PERSON.NAME) 
;	(MYIF (= sql:PERSON.SSN 
;		 (MYIF (< sql:PERSON.SSN 740914) 710424 750621)) 
;	      "Kirderf" sql:PERSON.NAME))) 
; FOREACH ((INTEGER sql:PERSON.SSN) 
;	  (CHARSTRING sql:PERSON.NAME) 
;	  (INTEGER sql:PERSON.ZIP)) 
; WHERE (= (sql:PERSON sql:PERSON.SSN) 
;	  (TUPLE sql:PERSON.NAME sql:PERSON.ZIP)))
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

(defun translate-sql-select (exp)
  "Translates the SQL SELECT S-expression into an AMOSQL S-expression."
  (let ((params exp) (querytype 'all) fields from where groupby 
	having orderby vars funcparams
	varslist thequery)
    ;; Split 'params' into subsections and check that the order of 
    ;;the sections are correct.
    (if (memq (car params) '(all distinct))
	(setq querytype (pop params)))
    (if (not (listp (car params)))
	(error "List of required fields expected in select" (car params)))
    (setq fields (pop params))
    (if (not (eq (pop params) 'from))
	(error "'FROM' expected in SELECT"))
    (if (not (listp (car params)))
	(error "Table reference(s) expected after FROM clause" (car params)))
    (setq from (pop params))
    (cond ((eq (car params) 'where)
	   (pop params)
	   (if (not (listp (car params)))
	       (error "Search condition expected after WHERE clause."
		      (car params))
	     (setq where (pop params))))
	  ((memq 'where params)
	   (error "WHERE is expected before" (car params))))
    (cond ((eq (car params) 'GROUPBY)
	   (pop params)
	   (if (not (listp (car params)))
	       (error "Column reference(s) expected after GROUP BY clause."
                      (car params)))
	   (setq groupby (pop params)))
	  ((memq 'groupby params)
	   (error "GROUP BY is expected before" (car params))))
    (cond ((eq (car params) 'having)
	   (pop params)
	   (if (not (listp (car params)))
	       (error "Search condition expected after HAVING clause"
                      (car params)))
	   (setq having (pop params)))
	  ((memq 'having params)
	   (error "HAVING is expected before" (car params))))
    (cond ((eq (car params) 'orderby)
	   (pop params)
	   (if (not (listp (car params)))
	       (error "Column reference(s) expected after ORDER BY clause"
                      (car params)))
	   (setq orderby (pop params))))
    (if params
	(error "Unexpected data after end" params))
    ;;** Check the FROM clause
    ;;** IN format: 
    ;; ((<joinspec> <tablename> [{<alias> | nil} [<condition>] ]) ...)
    ;;** OUT: 
    ;; (((schemasql:Table1_name Table1_alias) ((type paramname1) ...) 
    ;; ((type resultname1) ...)) ...))
    (setq funcparams (sql-translate-from from)) 
;   (princ "funcparams: ") (princ funcparams)(terpri)
    ;;** varslist: A structure with all columns, their type and their table
    ;;** structure: ((type (schemasql:table1 column1)) ... 
    ;;               (type (schemasql:tableN columnK)))

    (setq varslist (sql-extract-varslist funcparams))
    ;;** vars: A complete structure for the FOREACH part of the query.
    (setq vars (sql-make-vars varslist))
;   (princ "varslist: ") (princ varslist) (terpri)
;   (princ "vars: ") (princ vars) (terpri)

    ;; Look for stars in the column selection and replace them with all columns
    (setq fields (sql-add-star-fields varslist fields))

    ;; Look through the fields to find function calls that has to be translated
    (setq fields (expandfunctions fields t))

    ;; Check the fields for fieldnames without table specified 
    ;; and try to find the table
    ;; If done with strings: "SELECT name" -> "SELECT person.name"
    ;; updatenames ignores the first argument of the list, 
    ;; so we add a dummy, which is removed before used.
    (setq fields (cdr (updatenames (cons nil fields) varslist)))
;   (princ "fields(2): ") (princ fields) (terpri)

;   (princ "fields(1): ") (princ fields) (terpri)

    ;; Append the JOIN conditions to the WHERE clause
    (setq where (sql-add-join-conditions from where))

    (setq where (expandfunctions where nil)) 
    ;; in the where-clause the first thing in the list is never a column name
;   (princ "where: ") (princ where) (terpri)
    ;; Update all column names in the where clause
    (if where (setq where (updatenames where varslist)))

    ;; Append the actual JOIN:ing conditions to the WHERE clause 
    ;;(i.e. _PERSON(SSN)=<NAME, ZIP>).
    (setq where (sql-join-from-clause funcparams where))
;     (setq where (expandfunctions where t))

    ;; Look at the GROUP BY part and rebuild the query if neccesary
    (if (or groupby (findagg fields))
	(let (agg sel temp curcol pred)
	  ;; If no GROUP BY clause were specified, 
	  ;; we check that aggregate functions are not mixed 
	  ;;with regular columns.
	  (and (null groupby)
	       (memq nil (mapcar (function findagg) fields))
	       (error "It is not allowed to mix aggregated columns 
(COUNT, MAX, AVG ...) with non aggregated if there is no GROUP BY clause"
		      ))
	  (setq groupby (cdr (updatenames (cons nil groupby) 
					  varslist)))
          (setq thequery (sql-translate-groupby querytype fields groupby having
						where varslist vars))))

    ;; Assemble the query, unless GROUP BY was use - then the query is 
    ;; allready assembled.
    (if (not thequery)
	(if (eq querytype 'DISTINCT)
	    (setq thequery `(osql-select distinct ,fields
					 foreach ,vars
					 where ,where))
	  (setq thequery `(osql-select ,fields
				       foreach ,vars
				       where ,where))))

    ;;** Take care of the ORDER BY clause.
    ;;** IN: (({DESC | ASC} {<column name> | <column number>}) [ ... ])
    (if orderby
	(setq thequery (sql-translate-order-by orderby varslist fields 
					       thequery)))
    (if sql-debugging
	(kwote thequery)
      thequery)))

(defun sql-translate-from (from)
  (mapcar 
   #'(lambda (x)
       (let ((tblname (sql_build-table-schema-name (cadr x)) ))
	 (cons (list
		tblname
		(if (caddr x)		;** Namingkonvention for variables:
		    (pack *currentschema* "sql:" (caddr x)) 
		  ;;**   New name: "... FROM _PERSON newname ..."
		  tblname		;**   Table name
		  ))
	       (getparameters tblname))))
   from))

(defun sql-extract-varslist (funcparams)
  (let (varslist)
    (dolist (x funcparams)
      (setq varslist 
	    (nconc 
	     varslist (mapcar 
		       #'(lambda (y) (list (car y) (list (cadar x) (cadr y)) ))
		       (cadr x))))
      (setq varslist 
	    (nconc 
	     varslist (mapcar 
		       #'(lambda (y) (list (car y) 
					   (list (cadar x) 
						 (cadr y)) ))
		       (caddr x) 
		       ))))
    varslist))

(defun sql-make-vars (varslist)
  (mapcar #'(lambda (x) (list (car x) 
			      (pack (car (cadr x)) 
				    "." 
				    (cadr (cadr x))) ))
	  varslist))

(defun sql-add-star-fields (varslist fields)
  (let (res)
    (dolist (f fields)
      (if (eq f '*)
	  (setq res (append res (getallfields varslist)))
	(if (and (listp f) (eq (car f) '*))
	    (setq res (append res 
			      (getallfields varslist (cdr f) )))
	  (setq res (append res (list f))))))
    res))

(defun sql-add-join-conditions (from where)
  (let (on)
    (dolist (x from)
      (if (= (ilength x) 4)
	  (setq on (nconc on (list (fourth x))))))
    (cond ((atom on) where)
	  (where
	   (list* 'and where on))
	  (t (cons 'and on)))))

(defun sql-join-from-clause (funcparams where)
  (let ((pred (list 'and)) params)
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
	(0
	 (setq pred 
	       (append pred 
		       (list (cons
			      (caar func)
			      (mapcar (function cadr) 
				      (car params))
			      )))))
	(1
	 (setq pred 
	       (append pred 
		       `((= ,(cons (caar func)
				   (mapcar (function cadr)
					   (car params)))
			    ,(cadr (caadr params))
			    )))))
	(otherwise
	 (setq pred 
	       (append pred 
		       `((= ,(cons (caar func) 
				   (mapcar (function cadr) 
					   (car params)))
			    ,(cons 'tuple 
				   (mapcar (function cadr)
					   (cadr params)))
			    )))))))
    (if (> (ilength pred) 0)
	(if (null where) pred
	  (append pred (list where))))))

(defun sql-translate-groupby (querytype fields groupby having where 
				      varslist vars)
  (let (agg sel temp curcol pred thequery)
    (setq temp (mapcar (function findagg) fields))
    ;; Step through all fields, when an aggregate function is found, 
    ;; the field is added to the A-vector
    ;; otherwise it is added to the V-vector
    (dolist (f fields)
      (setq curcol f)
      (if (in '* curcol)
	  (if agg
	      (setq curcol (subpair '((sql_count *)) 
				    `((sql_count ,(car agg))) 
				    curcol))
	    (setq curcol 
		  (subpair '((sql_count *)) 
			   `((sql_count ,(car (getallfields varslist)))) 
			   curcol))))
      ;; Find all aggregate functions used in the SELECT clause 
      ;; and act upon each of them...
      (setq temp (findagg (list curcol)))
      (dolist (x temp)
	(if (findagg (cdr x))
	    (error "Aggregate functions may NOT be nested" x))
	;; Add the aggregate to the list 'agg' 
	;; if it is not there allready.
	(if (not (member (cadr x) agg))
	    (setq agg (append agg (cdr x))))
	;;* SQL_COUNT is the only aggregate function 
	;; that only takes one parameter
	(setq curcol 
	      (subpair
	       (list x)
	       (if (eq (car x) 'sql_count)
		   `((,(car x) a))
		 `((,(car x) a ,(1- (ilength (member (cadr x) 
						     (reverse agg)) )) )))
	       curcol)))
      ;; Replace the columns without aggregate functions 
      ;; to a (VREF V nn)-clause.
      (setq curcol (subpair
		    groupby
		    (let (tmp) 
		      (dotimes (i (ilength groupby))
			(setq tmp (cons (list 'vref 'v i) tmp)))
		      (reverse tmp))
		    curcol))
      (setq sel (append sel (list curcol))))
    ;;** Convert all field names in the HAVING clause
    (cond ((and (listp having) having)
	   (setq pred (updatenames having varslist))
	   (if (in '* pred)
	       (if agg
		   (setq pred (subpair '((sql_count *)) 
				       `((sql_count ,(car agg))) 
				       pred))
		 (setq pred
		       (subpair 
			'((sql_count *)) 
			`((sql_count ,(car (getallfields varslist)))) 
			pred))))

	   (setq temp (findagg pred))
	   (dolist (x temp)
	     (if (findagg (cdr x))
		 (error "Aggregate functions may NOT be nested" x))
	     ;;* SQL_COUNT is the only aggregate function 
	     ;; that only takes one parameter
	     (if (not (member (cadr x) agg))
		 (setq agg (append agg (cdr x))))
	     (setq pred 
		   (subpair
		    (list x)
		    (if (eq (car x) 'sql_count)
			`((,(car x) a))
		      `((,(car x) a 
			 ,(1- (ilength (member (cadr x) 
					       (reverse agg)) )) ))
		      )
		    pred)))

	   (setq pred (subpair
		       groupby
		       (let (tmp) 
			 (dotimes (i (ilength groupby))
			   (setq tmp (cons (list 'vref 'v i) tmp)))
			 (reverse tmp))
		       pred)))
	  (t (setq pred 'true)))

    (setq thequery (list 'osql-select))
    (if (eq querytype 'DISTINCT)
	(setq thequery (append thequery (list 'distinct))))
    (append
     thequery
     `(,sel foreach ((vector v) (vector a))
	    where 
	    (and (= (tuple v a) 
		    (in (groupby_pos (select ,(append groupby agg)
					  foreach ,vars
					  where ,where)
				  ,(ilength groupby))))
		 ,pred)))))

(defun sql-translate-order-by (orderby varslist fields thequery)
  (let ((orderby (expandfunctions orderby t)))
    (setq orderby 
	  (cdr (updatenames (cons nil orderby) 
			    varslist)))
    (setq orderby (subpair
		   fields
		   (let (tmp) 
		     (dotimes (i (ilength fields))
		       (setq tmp (cons (1+ i) tmp)))
		     (reverse tmp))
		   orderby))
    (dolist (x orderby)
      (if (not (numberp (second x)))
	  (error "Only columns and numbers are valid for ORDER BY"
		 (second x))))
    (setq orderby (mapcar 
		   #'(lambda (x)
		       (list (car x) (1- (cadr x))))
		   orderby))
    (let (order)
      (dolist (x orderby)
	(if (not (numberp (cadr x)))
	    (error  "Unknown column reference" 
		    (concat (cadr x) " " (car x))))
	(if (or (< (cadr x) 0) (> (cadr x) (1- (ilength fields)) ))
	    (error "Illegal column reference" 
		   (concat (cadr x) " " (car x))))
	(setq order (append order (list (cadr x) (mkstring (car x)))))
	)
      `(osql-select ((order_by (select ,@(cdr thequery))
			       (vector ,@order)))
		    ))))

(defun updatenames (lst data)
  "Recursively convert lst by using function getname"
  (cons
   (pop lst)
   (mapcar
    #'(lambda (x)
        (if (and x (listp x))
	    (if (eq (car x) 'column)
		(getname x data)
	      (updatenames x data))
          x))
    lst)))

(defun getname (name data)
  "Searches for a column NAME in DATA and tries 
   to convert NAME into TBL.NAME"
  (if (and (eq (car name) 'column) (not (eq (nth 3 name) '*)))
      (let ((schema (nth 1 name)) (table (nth 2 name)) (column (nth 3 name)))
	(if (not schema)
	    (setq schema *currentschema*))
	(if (not table)
	    (let (res)
	      (dolist (y data)
		(if (= (cadr (cadr y)) column)
		    (setq res (append res (list (caadr y))))))
	      (if (= (ilength res) 1)
		  (setq table (car res))
		(if (= (ilength res) 0)
		    (error "Unable to resolve column name" 
			   column)
		  (error "Column name in more than one table" 
			 column))))
	  (setq table (pack schema "sql:" table)))
	(pack table "." column))
    name))

(defun getallfields (data &optional table)
  "Returns a list of fields matching '*' and TABLE.* references"
  (let (result field)
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
	  (case
	      ;; IN: (CASE a 1 "ETT" 2 "TVÅ" 3 "TRE" 4 "FYRA" 5 "FEM" 
	      ;; ELSE "STORT")
	      ;; OUT: (MYIF (= a 1) "ETT" (MYIF (= a 2) "TVÅ" 
	      ;; (MYIF (= a 3) "TRE" (MYIF (= a 4) "FYRA" 
	      ;; (MYIF (= a 5) "FEM" "STORT")))))
	      (let (res (val (second lst)))
		(setq lst (reverse (cddr lst)))
		;; ("STORT" ELSE "FEM" 5 "FYRA" 4 "TRE" 3 "TVÅ" 2 "ETT" 1)
		(if (not (evenp (ilength lst)))
		    (error "expandfunctions" 
			   "CASE must have an even number of parameters!"))
		(if (eq (cadr lst) 'else)
		    (progn
		      (setq res (expandfunctions (car lst)))
		      (setq lst (cddr lst)))
		  (setq res nil))
		(loop
;            (setq res (list 'MYIF (list '= val (expandfunctions (cadr lst))) 
;                                        (expandfunctions (car lst)) res))
		  (setq res 
			`(ifsome 
			  (select ((= ,val ,(expandfunctions (cadr lst))) ))
			  (select (,(expandfunctions (car lst)) ))
			  (select (,res)) ))
		  (setq lst (cddr lst))
		  (if (< (ilength lst) 1)
		      (return res)))))
	  (cond
	   ;; IN: (COND (= a 1) "ETT" (= a 2) "TVÅ" (= a 3) "TRE" (= a 4)
           ;; "FYRA" (= a 5) "FEM" (< a 1) "LITET" ELSE "STORT")
	   ;; OUT: (MYIF (= a 1) "ETT" (MYIF (= a 2) "TVÅ" 
	   ;; (MYIF (= a 3) "TRE" (MYIF (= a 4) "FYRA" 
	   ;; (MYIF (= a 5) "FEM" (MYIF (< a 1) "LITET" "STORT")))))
	   (let (res)
	     (setq lst (reverse (cdr lst)))
             ;; ("STORT" ELSE "LITET" (< A 1) "FEM" (= A 5) 
             ;; "FYRA" (= A 4) "TRE" (= A 3) "TVÅ" (= A 2) "ETT" (= A 1))
	     (if (not (evenp (ilength lst)))
		 (error "expandfunctions" 
			"COND must have an even number of parameters!"))
	     (if (eq (cadr lst) 'else)
		 (progn
		   (setq res (expandfunctions (car lst)))
		   (setq lst (cddr lst)))
	       (setq res nil))
	     (loop
;            (setq res (list 'MYIF (expandfunctions (cadr lst)) 
;                                  (expandfunctions (car lst)) res))
	       (setq res `(ifsome 
			   (select (,(expandfunctions (cadr lst)) ))
			   (select (,(expandfunctions (car lst)) ))
			   (select (,res)) ))
	       (setq lst (cddr lst))
	       (if (< (ilength lst) 1)
		   (return res)))))
	  (in
	   ;; IN: (IN x 1 7 5 3 8)
	   ;; OUT: (OR (= x 1) (= x 7) (= x 5) (= x 3) (= x 8))
	   (let ((res (list 'OR)) (var (cadr lst)))
	     (dolist (x (cddr lst))
	       (setq res (append res `((= ,var ,x)))))
	     res))
          (not
           ;; IN: (NOT x)
           ;; OUT: (NOTANY X) 
	   (list 'notany (expandfunctions (second lst))))
	  (between
	   ;; IN: (BETWEEN x 5 19)
	   ;; OUT: (AND (>= x 5) (<= x 19))
	   `(and (>= ,(expandfunctions (second lst)) 
		     ,(expandfunctions (third lst)))
		 (<= ,(expandfunctions (second lst)) 
		     ,(expandfunctions (fourth lst)))))
	  (otherwise
	   (cons (car lst) (mapcar (function expandfunctions)
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
	  (case
	      ;; IN: (CASE a 1 "ETT" 2 "TVÅ" 3 "TRE" 4 "FYRA" 5 "FEM" 
	      ;;      ELSE "STORT")
	      ;; OUT:(MYIF (= a 1) "ETT"(MYIF (= a 2) "TVÅ" (MYIF (= a 3) "TRE"
	      ;;         (MYIF (= a 4) "FYRA" (MYIF (= a 5) "FEM" "STORT")))))
	      (let (res (val (second lst)))
		(setq lst (reverse (cddr lst)))
		;; ("STORT" ELSE "FEM" 5 "FYRA" 4 "TRE" 3 "TVÅ" 2 "ETT" 1)
		(if (not (evenp (ilength lst)))
		    (error "expandfunctions" 
			   "CASE must have an even number of parameters!"))
		(if (eq (cadr lst) 'else)
		    (progn
		      (setq res (expandfunctions (car lst) nil table))
		      (setq lst (cddr lst)))
		  (setq res nil))
		(loop
;            (setq res (list 'MYIF (list '= val 
;                 (expandfunctions (cadr lst) nil table)) 
;                 (expandfunctions (car lst) nil table) res))
		  (setq res 
			`(ifsome 
			  (select 
			   ((= ,val ,(expandfunctions (cadr lst) nil table)) ))
			  (select (,(expandfunctions (car lst) nil table) ))
			  (select (,res))))
		  (setq lst (cddr lst))
		  (if (< (ilength lst) 1)
		      (return res)))))
	  (cond
           ;; IN: (COND (= a 1) "ETT" (= a 2) "TVÅ" (= a 3) "TRE" 
           ;; (= a 4) "FYRA" (= a 5) "FEM" (< a 1) "LITET" ELSE "STORT")
           ;; OUT: (MYIF (= a 1) "ETT" (MYIF (= a 2) "TVÅ" 
           ;; (MYIF (= a 3) "TRE" (MYIF (= a 4) "FYRA" 
           ;; (MYIF (= a 5) "FEM" (MYIF (< a 1) "LITET" "STORT")))))
	   (let (res)
	     (setq lst (reverse (cdr lst)))
             ;; ("STORT" ELSE "LITET" (< A 1) "FEM" (= A 5) 
             ;;  "FYRA" (= A 4) "TRE" (= A 3) "TVÅ" (= A 2) "ETT" (= A 1))
	     (if (not (evenp (ilength lst)))
		 (error "expandfunctions" 
			"COND must have an even number of parameters!"))
	     (if (eq (cadr lst) 'else)
		 (progn
		   (setq res (expandfunctions (car lst) nil table))
		   (setq lst (cddr lst)))
	       (setq res nil))
	     (loop
;            (setq res (list 'myif (expandfunctions (cadr lst) nil table) 
;                                  (expandfunctions (car lst) nil table) res))
	       (setq res 
		     `(ifsome 
		       (select (,(expandfunctions (cadr lst) nil table)))
		       (select (,(expandfunctions (car lst) nil table) ))
		       (select (,res)) ))
	       (setq lst (cddr lst))
	       (if (< (ilength lst) 1)
		   (return res)))))
	  (in
           ;; IN: (IN x 1 7 5 3 8)
           ;; OUT: (OR (= x 1) (= x 7) (= x 5) (= x 3) (= x 8))
	   (let ((res (list 'or)) (var (cadr lst)))
	     (dolist (x (cddr lst))
	       (setq res (append res `((= ,var ,x)))))
	     res))
	  (between
           ;; IN: (BETWEEN x 5 19)
           ;; OUT: (AND (>= x 5) (<= x 19))
	   (list 'and (list '>= (expandfunctions (second lst) nil table) 
			    (expandfunctions (third lst) nil table))
		 (list '<= (expandfunctions (second lst) nil table) 
		       (expandfunctions (fourth lst) nil table))))
	  (column
           ;; IN: (COLUMN schema table column), schema and table may be nil
           ;; OUT: schemasql:table.column
	   (if table
	       (let ((schema *currentschema*) (tbl table))
		 (if (nth 1 lst)
		     (setq schema (nth 1 lst)))
		 (if (nth 2 lst)
		     (setq tbl (nth 2 lst)))
		 (pack schema "sql:" tbl "." (nth 3 lst)))
	     lst))
	  (otherwise
	   (cons (car lst)
		 (mapcar (function expandfunctions) 
			 (cdr lst) 
			 (buildl lst nil) 
			 (buildl lst table)))))
      (mapcar (function expandfunctions)
	      lst (buildl lst nil) (buildl lst table)))))

(defun findagg (col)
  "Recursive search through COL, looking for a list where 
   first element is the name of an aggregate function"
  (if (not (and col (listp col)))
      nil
    (if (member (car col) '(sql_avg sql_avgd sql_sum sql_sumd 
				    sql_count sql_countd sql_max sql_min))
	(list col)
      (let (res)
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
  (let (table myorder)
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

(osql "create function order_by(bag data, vector order)->object row 
  as foreign 'order_by';")

;** SET FUNCTIONS **************
(defun sql-count (fno data cnt)
  "Foreign aggregate function to use together with groupby_pos. 
   Returns the size of the vector."
  (osql-result data (array-total-size data)))

(osql "create function sql_count(vector a)->integer cnt 
  as foreign 'sql-count';")

(defun sql-countdistinct (fno data field cnt)
  "Foreign aggregate function to use together with groupby_pos. 
   Counts the number of rows where the field is non-NULL."
  (let ((cnt 0) (htable (make-hash-table :test (function equal))) hval)
    (dolist (arr (arraytolist data))
      (setq hval (aref arr field))
      (if (not (gethash hval htable))
	  (progn
	    (setf (gethash hval htable) t)
	    (setq cnt (1+ cnt)))))
    (osql-result data field cnt)))

(osql "create function sql_countd(vector a, integer field)->integer cnt 
  as foreign 'sql-countdistinct';")

(defun sql-sum (fno data field sum)
  "Foreign aggregate function to use together with groupby_pos. SQL: SUM(col)."
  (let ((sum 0))
    (dolist (arr (arraytolist data))
      (if (numberp (aref arr field))
	  (setq sum (+ sum (aref arr field)))))
    (osql-result data field sum)))

(osql "create function sql_sum(vector a, integer field)->number sum 
  as foreign 'sql-sum';")

(defun sql-sumdistinct (fno data field sum)
  "Foreign aggregate function to use together with groupby_pos. 
   SQL: SUM(DISTINCT col)."
  (let ((sum 0) (htable (make-hash-table :test (function equal))) val)
    (dolist (arr (arraytolist data))
      (setq val (aref arr field))
      (if (not (gethash val htable))
	  (progn
	    (setf (gethash val htable) t)
	    (if (numberp val)
		(setq sum (+ sum val))))))
    (osql-result data field sum)))

(osql "create function sql_sumd(vector a, integer field)->integer sum 
  as foreign 'sql-sumdistinct';")

(defun sql-avg (fno data field result)
  "Foreign aggregate function to use together with groupby_pos. SQL: AVG(col)."
  (let (sum (count 0))
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

(osql "create function sql_avg(vector a, integer field)->number res 
  as foreign 'sql-avg';")

(defun sql-avgdistinct (fno data field sum)
  "Foreign aggregate function to use together with groupby_pos. 
   SQL: AVG(DISTINCT col)."
  (let (sum (count 0) (htable (make-hash-table :test (function equal))) 
	    val)
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

(osql "create function sql_avgd(vector a, integer field)->integer sum 
  as foreign 'sql-avgdistinct';")
 
(defun sql-max (fno data field sum)
  "Foreign aggregate function to use together with groupby_pos. SQL: MAX(col)."
  (let (maxval)
    (dolist (arr (arraytolist data))
      (if (aref arr field)
	  (if (not maxval)
	      (setq maxval (aref arr field))
;          (setq maxval (max maxval (aref arr field)))
	    (if (sql< maxval (aref arr field))
		(setq maxval (aref arr field))))))
    (osql-result data field maxval)))

(osql "create function sql_max(vector a, integer field)->number sum 
  as foreign 'sql-max';")


(defun sql-min (fno data field sum)
  "Foreign aggregate function to use together with groupby_pos. SQL: MIN(col)."
  (let (minval)
    (dolist (arr (arraytolist data))
      (if (aref arr field)
	  (if (not minval)
	      (setq minval (aref arr field))
;          (setq minval (min minval (aref arr field)))
	    (if (sql< (aref arr field) minval)
		(setq minval (aref arr field))))))
    (osql-result data field minval)))

(osql "create function sql_min(vector a, integer field)->number sum 
  as foreign 'sql-min';")

;IN: 
;(SQL-SELECT (_PERSON.SSN _PERSON.NAME _ZIP.CITY) 
;	    FROM ((nil _PERSON)
;		  (INNERJOIN _ZIP nil (= _PERSON.ZIP _ZIP.ZIP))) 
;	    WHERE (AND (= NAME
;			  "Fredrik")))
