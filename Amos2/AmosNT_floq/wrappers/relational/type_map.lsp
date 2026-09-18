;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: type_map.lsp,v $
;;; $Revision: 1.8 $ $Date: 2007/08/10 12:54:50 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Provides the mapping between the numerous SQL types and their 
;;;              Amos counterparts. The mapping is from symbols to symbols.
;;;              
;;; ===========================================================================
(defvar *sql-amos-types* (make-hash-table))
(defvar *amos-sql-types* (make-hash-table))

(defmacro puttype (&rest args)
  "Inserts a mapping between an Amos type (type object or symbolic name) and an
   sql type. Sql types don't have oids so the name is a symbol."
  `(puttype-int ,@ (parsekeywordparams args '(:sql :amos))))

(defun puttype-int (sqltp amostp) (insert-sql-type sqltp (gettypenamed amostp)))

(defun insert-sql-type (sqltypename amostypename)
  (puthash amostypename *amos-sql-types* sqltypename)
  (puthash sqltypename *sql-amos-types* amostypename))

; Since we use two hash tables (one for each direction), and we have a mapping 
; between many sql types and one Amos type, The table for the Amos->sql direction
; will be constantly overridden. So, the type that is preferred in the Amos->sql
; direction is to be instered last.
(:break)
(puttype :sql 'bigint    :amos 'integer)
(puttype :sql 'smallint  :amos 'integer)
(puttype :sql 'tinyint   :amos 'integer)
(puttype :sql 'int       :amos 'integer)
(puttype :sql (mksymbol "int identity")    :amos 'integer)
(puttype :sql 'integer   :amos 'integer)


(puttype :sql 'bit       :amos 'boolean)

(puttype :sql 'date      :amos 'charstring)
(puttype :sql 'timestamp :amos 'charstring)
(puttype :sql 'char      :amos 'charstring)
(puttype :sql 'character :amos 'charstring)
(puttype :sql 'smalldatetime :amos 'charstring)
(puttype :sql 'varchar   :amos 'charstring)
(puttype :sql 'text      :amos 'charstring)

(puttype :sql 'decimal   :amos 'real)
(puttype :sql 'numeric   :amos 'real)
(puttype :sql (mksymbol "double precision")    :amos 'real)
(puttype :sql 'float     :amos 'real)



(defun sql-to-amos-type (tp &optional noerror)
  "Looks up an Amos type associated with the sql type as a symbol. The type oid
   is returned."
  (let ((answer (gethash tp *sql-amos-types*)))
    (if (and (not answer) (not noerror))
	(error "unknown SQL type or table not imported" tp)
      answer)))

(defun amos-to-sql-type (tp)
  "Looks up an sql type associated with the Amos type as a symbol or oid. The 
   type name is returned as a symbol."
  (let ((answer (gethash (gettypenamed tp) *amos-sql-types*)))
    (if (not answer)
	(error "no correponding SQL type found" tp)
      answer)))