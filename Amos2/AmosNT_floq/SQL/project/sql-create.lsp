;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) Markus Jägerskogh, UDBL, 2004
;;; $RCSfile: sql-create.lsp,v $
;;; $Revision: 1.10 $ $Date: 2011/02/16 20:27:49 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Create SQL table
;;; ===========================================================================
;;; $Log: sql-create.lsp,v $
;;; Revision 1.10  2011/02/16 20:27:49  torer
;;; Changed bad Lisp code
;;;
;;; ===========================================================================


; SQL-CREATE-TABLE macro
;
; Written in Mars-2004 by Markus Jägerskogh.
; The macro does NOT do any check that the correct parameters are passed to it,
; it is expected to be used only by the SQL-parser written with Lex/Yacc.
;
;IN: 
; (SQL-CREATE-TABLE _PERSON 
;		  ((SSN (INT) NOT-NULL PRIMARY-KEY) 
;		   (NAME (CHAR 50)) (CITY (CHAR 30))))
;IN: 
;(SQL-CREATE-TABLE _PERSON2 
;		  ((SSN (INT)) 
;		   (NAME (CHAR 50)) 
;		   (CITY (CHAR 30)) 
;		   (CONSTRAINT pers_pk PRIMARY-KEY (SSN))))
;OUT: 
;(CREATEFUNCTION _PERSON ((INTEGER SSN)) 
;		((CHARSTRING NAME) (CHARSTRING CITY)))

; 
;(SQL-CREATE-TABLE _PERSON2 
;		  ((SSN (INT) NOT-NULL PRIMARY-KEY) 
;		   (NAME (CHAR 50)) 
;		   (CITY (CHAR 30)) 
;		   (CONSTRAINT pers_pk PRIMARY-KEY (NAME))))

(osql "
create function sql_implementation (Charstring tbl)->Function fno as stored;")

(defun set-sql-implementation (table fno)
  (setfunction 'charstring.sql_implementation->function 
	       (list (mkstring table))(list fno)))

(defmacro sql-create-table (table fields)
  "The form an SQL create table statement is translated into"
  (sql-create-table-expand table fields))

(defun sql-create-table-expand (table fields)
  "Implements definition of SQL's CREATE TABLE statement"
  (let ((name (sql_build-table-schema-name table))
	(reserved_words '(constraint primary-key unique index))
	query primary func temp)
    (setq func (getfunctionnamed name t))
    (if func
	(error "SQL-CREATE-TABLE" (concat "Table " name " already exists!")))
    (dolist (l fields)
      (if (member 'primary-key l)
	  (if (member (car l) '(constraint primary-key))
	      (setq primary (append primary (car (last l)))) 
	    ;; CONSTRAINT PRIMARY KEY (field, ...)
	    (setq primary (append primary (list (car l)))) 
	    ;; (name TYPE PRIMARY KEY)
	    )))
    ;;** Make sure all primary keys come before any other column **
    (let ((afternonkey nil))
      (dolist (x fields)
	(if (not (member (car x) reserved_words))
	    (if (member (car x) primary)
		(if afternonkey
		    (error "SQL-CREATE-TABLE" 
			   (concat "Primary keys must come before non-key fields! Primary key " 
				   (car x) " does not!"))
		  )
              (setq afternonkey T)
	      )
	  )
	))
    (setq query 
	  (append (list 'createfunction (kwote name))
		  (cond 
		   ((= (ilength primary) 1)
		    (cons
		     (kwote 
		      (list (list 
			     (sql-osql-type (caadr (car fields))) 
			     (caar fields))))
		     (let ((result (list)))
		       (dolist (x (cdr fields))
			 (if (not (member (car x) reserved_words))
			     (setq result 
				   (append result
					   (list (list (sql-osql-type 
							(caadr x))
						       (car x)))))))
		       (list (kwote result)))))
		   ((= (ilength primary) 0)
		    (list
		     (let ((result (list)))
		       (dolist (x fields)
			 (if (not (member (car x) reserved_words))
			     (setq result 
				   (append result
					   (list (list (sql-osql-type 
							(caadr x))
						       (car x) 'NONKEY
						       ))))))
		       (kwote result))
		     (kwote (list (list 'boolean)))))
		   (t			; (ilength primary) > 1
		    (list
		     (let ((result (list)) (temp nil))
		       (dolist (x primary)
			 (setq temp (assoc x fields))
			 (if (not (member (car temp) reserved_words))
			     (setq result 
				   (append result
					   (list (list (sql-osql-type 
							(caadr temp))
						       (car temp) ;**'NONKEY
						       ))))))
		       (kwote result))
		     (let ((result (list)))
		       (dolist (x fields)
			 (if (not (member (car x) 
					  (append reserved_words primary)))
			     (setq result 
				   (append result
					   (list (list (sql-osql-type 
							(caadr x))
						       (car x) ;**'NONKEY
						       ))))))
		       (kwote result)))))
		  (list nil nil nil)))
    (setq query (list 'set-sql-implementation (kwote name) query))
    (if sql-debugging
	(kwote query)
      query)))

(defun sql-osql-type (sqltype)
  (or (caar (getfunction 'amos_type_from_generic_relational 
			 (list (string-upcase sqltype))))
      (error "Not supported SQL type" sqltype)))

(defun osql-sql-type (tpo)
  (or (caar (getfunction 'generic_relational_from_amos_type 
			 (list tpo)))
      (error "Not supported Amos II type in SQL" tpo)))
  
