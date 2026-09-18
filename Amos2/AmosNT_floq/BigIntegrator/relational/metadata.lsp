;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: metadata.lsp,v $
;;; $Revision: 1.1 $ $Date: 2012/03/21 15:10:31 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Lisp 2 $
;;; $State: Exp $ $ $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Lisp 2 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Lisp interface to relational metadata functions.
;;; =============================================================
;;; $Log: metadata.lsp,v $
;;; Revision 1.1  2012/03/21 15:10:31  torer
;;; moved JDBC wrapper to BigIntegrator
;;;
;;; Revision 1.13  2006/02/24 20:13:33  torer
;;; Removed name collision + followed Martin's own coding conventions
;;;
;;; ===========================================================================

(defglobal _columns_           (getfunctionnamed 'columns))
(defglobal _keys_              (getfunctionnamed 'primary_keys))
(defglobal _has_table_         (getfunctionnamed 'has_table))
(defglobal _referenced_table_  (getfunctionnamed 'referenced_table))
(defglobal _table_cardinality_ (getfunctionnamed 'cardinality))

; public functions

(defun get-columns (ds table)
  "Return the columns of a table on the form ((<type> <name>)...) where 
  <type> is the columnn type. Throws error for nonexisting tables"
  (if (has-table ds table)
      (convert (getfunction _columns_ (list ds (mkstring table))))
    (error "Table does not exist" table)))

(defun get-column-names (ds table)
  (mapcar (function second) (get-columns ds table)))

(defun get-primary-keys (ds catalog schema table)
  "Returns the primary keys of the chosen table in the given catalog and 
   schema, either of the latter two may be NIL, in which case tables that lack
   schema or catalog are returned. This is also the method to be used for 
   drivers that don't handle schemas or catalogs."
  (if (not (has-table ds table)) (error "Table does not exist" table))
  (convert (getfunction _keys_ (list ds
				     (if catalog (mkstring catalog) "")
				     (if schema  (mkstring schema) "")
				     (mkstring table)))))

(defun get-key-columns (ds catalog schema table)
  "Returns the set of columns that make up the primary key of the chosen table 
   in the given catalog and schema, either of the latter two may be NIL, in 
   which case tables that lack schema or catalog are returned. This is also the
   method to be used for drivers that don't handle schemas or catalogs. If the 
   table has a primary key, the list of two-element lists
   ((<type> <name>) ...) will be returned. If no primary key exists the set of 
  all columns is returned."
  (let ((keynames (mapcar #'first (get-primary-keys ds catalog schema table)))
	(cols (get-columns ds table)))
    (or (mapfilter (f/l (col) (memq (second col) keynames)) cols) cols)))

(defun get-key-columns-amos-typed (ds catalog schema table)
  (mapcar (f/l (col) (sql-column-to-amos-prop ds col))
	  (get-key-columns ds catalog schema table)))

(defun get-declared-key (ds catalog schema table)
  "Returns the declared key stored on the mapped type that maps the table 
   named <table> in relational database <ds>."
  (let ((mtpo (wrapped-to-amos-type ds table 'noerror)))
    (or (and mtpo (getobject mtpo 'keys))
	(get-key-columns ds catalog schema table))))

(defun has-table (ds table)
  (caar (getfunction _has_table_ (list ds (mkstring table)))))

(defun get-referenced-table (ds table columnname)
  "Gets the table that the given column in the
   given table is part of a foreign key to, if any."
  (mkatom
   (caar (getfunction _referenced_table_
		      (list ds (mkstring table)(mkstring columnname))))))

(defun get-cardinality (ds table)
  (if (has-table ds table)
      (caar (getfunction _table_cardinality_ (list ds (mkstring table))))
    (error "Table does not exist" table)))

(defun sql-update-table (ds s)
  (getfunction 'SQLU (list ds s)))