;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: sql.lsp,v $
;;; $Revision: 1.1 $ $Date: 2012/03/21 15:10:32 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: A layer on top of the metadata layer that deals with tables
;;;   with their corresponding Amos types.
;;;              
;;; ===========================================================================

(defun sql-column-to-amos-prop (ds column &optional noerror)
  "Converts a 2-element list (<t> <name>) to a list (<t'> <name>) where t is 
   an sql type and t' is the corresponding Amos type"
  (let ((amos-tpo (wrapped-to-amos-type ds (first column) noerror)))
    (if amos-tpo (cons (getobject amos-tpo 'name) (rest column)))))

(defun sql-columns-to-amos-props (ds columns &optional noerror)
  "Converts a list ((<ti> <name>) ...) to a list ((<ti'> <name>) ...) where ti
   is an sql type and ti' is the corresponding Amos type"
  (if columns
      (let ((amosql-column (sql-column-to-amos-prop ds(first columns)noerror)))
	(if amosql-column
	    (cons amosql-column (sql-columns-to-amos-props ds (rest columns) noerror))
	  (sql-columns-to-amos-props ds (rest columns) noerror)))
    '()))

(defun get-columns-amos-typed (ds table &optional noerror)
  "Return the properties of a table on the form ((<type> <name>)...) where 
  <type> is the Amos type. Throws error for nonexisting tables.
  If a column's type is unknown an error is raised unless <noerror> is true,
  in which case any offending columns are skipped."
  (let ((mtpo (wrapped-to-amos-type ds table 'noerror)))
    (if mtpo (getobject mtpo 'properties)
      (sql-columns-to-amos-props ds (get-columns ds table) noerror))))

(defun convert-column (ds table column &optional foreignkey-means)
  (let ((type (first column))
	(name (second column)))
    (cons 
     (getobject 
      (wrapped-to-amos-type
       ds
       (selectq foreignkey-means
		(type (or (get-referenced-table ds table name) type))
		type))
      'name)
     (rest column))))

;;; Does not work (TR)
(quote
(defun typeencode-columns (ds table columns)
  "Creates a tuple out of column information by substituting the types of 
   columns that are part of foreign keys for the mapped type that the 
   referenced table maps to. Keys can be compund, and thus a type may
   span several columns. Primary keys are discarded as this value is 
   already stored in the decode function."
  (let ((colnames (mapcar (function second) columns))
	 skippednames 
	 encodedprops)
    (dolist (column columns)
      (let ((name (second column)))
	(if (not (memq name skippednames))
	  ; this column has not been covered by a type yet
	  (let ((basetable (get-referenced-table ds table name)))
	    (if basetable
	        ; ok, so the column is part of a foreign key
		; error check: is the whole key part of columns?
		(let* ((xref     (get-cross-reference ds basetable table))
		       (xrefnames (mapcar (function first) xref)))
		  (cond ((subsetp xrefnames colnames)
			 (push (list (wrapped-to-amos-type ds basetable) (packlist xrefnames)) 
			       encodedprops)
			 (setq skippednames (append skippednames xrefnames)))
			(t
			 (error "A foreign key has been split"))))
	       (push column encodedprops))))))
    (reverse encodedprops)))
)