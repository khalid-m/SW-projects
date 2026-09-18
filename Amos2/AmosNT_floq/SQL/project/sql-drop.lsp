;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) Markus Jägerskogh, UDBL, 2004
;;; $RCSfile: sql-drop.lsp,v $
;;; $Revision: 1.4 $ $Date: 2012/02/04 17:14:18 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Drop SQL table
;;; ===========================================================================
;;; $Log: sql-drop.lsp,v $
;;; Revision 1.4  2012/02/04 17:14:18  torer
;;; Namespaces for functions and types introduced as name prefixes, e.g.
;;;
;;; create function sql:person(Integer ssn) -> (Charstring name, Integer salary) as stored;
;;;
;;; The prefix sql: makes amos functions queryables with sql, e.g.:
;;;
;;; SELECT * FROM PERSON;
;;;
;;; Revision 1.3  2011/02/16 20:27:49  torer
;;; Changed bad Lisp code
;;;
;;; ===========================================================================

; SQL-DROP-TABLE macro
;
; Written in August-2004 by Markus Jägerskogh.
; The macro does NOT do any check that the correct parameters are pased to it,
; it is expected to be used only by the SQL-parser written with Lex/Yacc.
;
;IN: (SQL-DROP-TABLE _PERSON)
;IN: (SQL-DROP-TABLE (SCHEMA1 . _PERSON2))
;OUT: (PURGE-FUNCTION SCHEMANAMEsql:_PERSON)

(defmacro SQL-DROP-TABLE (name)
  "Implements SQL's DROP TABLE statement"
  (let ((result nil))
    (setq name (sql_build-table-schema-name name))
    (setq result (list 'purge-function name))
    (if sql-debugging
	(kwote result)
      result)))

(defun sql_build-table-schema-name (name)
  "Builds a table name by adding the correct <schema name> 
and a 'sql:' before the name."
  (if (not name)
      (error "sql_build-table-schema-name" "Invalid table reference: nil"))
  (if (listp name)
      (pack (car name) "sql:" (cdr name))
    (pack *currentschema* "sql:" name)))