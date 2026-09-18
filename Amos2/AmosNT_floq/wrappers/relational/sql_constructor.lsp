;;; =============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: sql_constructor.lsp,v $
;;; $Revision: 1.9 $ $Date: 2012/05/15 19:27:16 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Creates an AmosQL constructor that calls SQL with an insert
;;;              statement. For example:
;;;
;;;              create function create_person@ds(ssn integer) -> person@ds
;;;              as begin
;;;                 declare person@ds res;
;;;                 sql(<ds>,'insert into person(ssn) values (?)',{ssn});
;;;                 select x into res from person@ds where _decode_(x)=ssn;
;;;              return res
;;;              end;
;;;              
;;; =============================================================
;;; $Log: sql_constructor.lsp,v $
;;; Revision 1.9  2012/05/15 19:27:16  torer
;;; result -> return
;;;
;;; Revision 1.8  2011/01/29 11:04:43  torer
;;; Base system uses (...) tuple notation, 'return' statement, and systematic indentation
;;;
;;; Revision 1.7  2006/12/06 21:50:55  torer
;;; Corrected type declarations. No more incorrect late bindings.
;;;
;;; =============================================================

; to do: The constructor must have as arguments all columns which are non-null
; in order for the transaction to be accepted by SQL, not just the primary keys

; public functions

(defun create-sql-constructor (ds mtpo)
  (let ((mtname  (oid-name mtpo))
	(table   (get-tablename mtpo))
	(pkeys   (getobject mtpo 'keys))
	(columns (getobject mtpo 'properties)))
    ; "Empty constructor", only the primary keys.
    (amos-execute (declare-sql-constructor (oid-name ds) table mtname pkeys))))

; private functions

(defun make-key-string (key)
  (concat (first key)" "(second key)))

(defun declare-sql-constructor (dsname table mtname properties)
  (let* ((args  (concatl properties "," (function make-key-string)))
         (type (oid-name (arg-type (getobjectnamed dsname _datasource_))))
	 (props (concatl properties "," (function second)))
	 (props1 (if (cdr properties) (concat "(" props ")") props))
	 (questionmarks (cons "?" (buildl (cdr properties) ",?"))))
    (concat
     "create function create_"mtname"("args") -> "mtname" res "
     "as begin declare "type" ds;"
     "set ds = relational_named('"dsname"');"
     "sqlu(ds,"
     "'insert into "table"("props") values "questionmarks
     "',{"props"});"
     "select x into res from "mtname" x where _decode_(x)= "props1";"
     "return res "
     "end;")))

