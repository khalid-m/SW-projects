;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2004 Markus Jägerskogh, UDBL
;;; $RCSfile: init.lsp,v $
;;; $Revision: 1.20 $ $Date: 2012/02/22 09:22:50 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Master file for SQL-92 processor
;;; =============================================================
;;; $Log: init.lsp,v $
;;; Revision 1.20  2012/02/22 09:22:50  torer
;;; Added comment
;;;
;;; Revision 1.19  2011/11/17 11:23:43  torer
;;; SQL parser integrated
;;; Try:  amos2 -q SQL
;;;
;;; Revision 1.18  2011/01/29 11:04:37  torer
;;; Base system uses (...) tuple notation, 'return' statement, and systematic indentation
;;;
;;; Revision 1.17  2010/02/25 21:15:36  torer
;;; Removed myif and not
;;;
;;; Revision 1.16  2006/10/08 20:20:05  torer
;;; Illegal call to foreign-result
;;;
;;; Revision 1.15  2006/09/28 14:28:33  torer
;;; Streamed implementation of SQL function
;;;
;;; Revision 1.14  2006/02/12 19:44:22  torer
;;; Added CVS header
;;;
;;; =============================================================

; Declare global variables
(defvar *currentschema* "")
(defvar sql-debugging nil)

(defun sql-parse (stmt) (parse stmt nil "SQL"))
 
;(debugging t) ; Will verify Lisp code

(load "project/sql-create.lsp")
(load "project/sql-insert.lsp")
(load "project/sql-update.lsp")
(load "project/sql-delete.lsp")
(load "project/sql-select.lsp")
(load "project/sql-drop.lsp")

(defun sql (str)
  "Executes an SQL string."
  (within-lisp (eval (sql-parse str)))
  )

(defun sql-+ (fno statement r)
  "Define SQL(Charstring statement)->Vector rows"
  (let ((parsed (sql-parse statement)))
    (selectq (car parsed)
	     (sql-select (let ((translated (translate-sql-select 
					    (cdr parsed))))
			   (map-select (select-get translated 'result)
				       (select-get translated 'foreach)
				       (select-get translated 'where)
				       (select-get translated 'distinct)
				       (f/l (row)
                                        (osql-result statement 
                                          (listtoarray row))))))
	     (dolist (row (within-lisp (eval parsed)))
	       (osql-result statement (listtoarray row))))))

(osql "create function sql(Charstring stmt)->Bag of Vector res
  /* Execute SQL statement over local database. 
     Return result tuples as bag of vectors */
  as foreign 'sql-+';")

(foreign-lispfn sql_schema ()((charstring))
		(foreign-result (mkstring *currentschema*)))

(foreign-lispfn sql_full_tablename ((charstring table))((charstring fullname))
		(foreign-result (mkstring 
				 (sql_build-table-schema-name table))))

(osql "
create function sql_columns (Vector of Vector args)
                        ->  (Charstring name, Charstring tpe)
  as select args[i][1], 
            generic_relational_from_amos_type(cast(args[i][0] as Type))
     from Integer i;

create function sql_key_columns(Charstring table) 
                            -> (Charstring name, Charstring tpe)
  as sql_columns(cast(arguments(sql_implementation(sql_full_tablename(table)))
                 as Vector of Vector));

create function sql_nonkey_columns(Charstring table) 
                               -> (Charstring name, Charstring tpe)
as sql_columns(cast(results(sql_implementation(sql_full_tablename(table)))
               as Vector of Vector));
")
         
; Make sure our function definitions can't "fall out" 
; if the user does a rollback
(setq _system-watermark_ _oidno_)
(commit)

