;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: export-type.lsp,v $
;;; $Revision: 1.11 $ $Date: 2010/02/16 20:01:55 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: <description>
;;; =============================================================
;;; $Log: export-type.lsp,v $
;;; Revision 1.11  2010/02/16 20:01:55  torer
;;; CommonLisp syntax
;;;
;;; Revision 1.10  2007/10/18 13:12:37  torer
;;; Now calling FUNCTION-ARGVARS and FUNCTION-RESVARS
;;;
;;; Revision 1.9  2006/02/24 20:13:33  torer
;;; Removed name collision + followed Martin's own coding conventions
;;;
;;; ===========================================================================
(defvar _default_string_size_ 200)
(defvar _userobject-table-name_ 'userobject)
(defvar _sql-reserved-words_ '(file index value level filter desc user))
(defvar _unexportable-types_ '(boolean vector))
(defvar _nullable-can-be-unique_ nil)
(defvar _interbase-max-tablename-length_ 31)
(defvar _sql-max-tablename-length_ _interbase-max-tablename-length_)
(defvar _sql-max-colname-length_ 1000)
(defvar *sql-stream*)
(defvar *sql-stream-name* "sqllog.sql")

; osql front functions

(defun export_types--+ (fno ds tp typenames)
  (osql-result ds 
	       (export-types ds 
			     (mapcar (function gettypenamed) (convert tp)))))

(defvar _sql-constraint-counter_ 1)

(defun make-constraint ()
  (pack 'constraint_ (++1 _sql-constraint-counter_)))

(defvar _sql-index-counter 1)

(defun make-index-name ()
  (pack 'index (++1 _sql-index-counter)))

(defun multivaluedp (fno)
  "True if a function has its return value defined as key, and thus 
   returns only a single value."
  (notany (f/l (indx)
	       (and (index-unique indx)
		    (< (index-pos indx)
		       (getarity fno))))
	  (relation-indexes (get-relation fno))))

(defun export-types (ds tpos)
  (open-exportlog)
  (setq *sql-stream* (openstream *sql-stream-name* "w"))
  (if (not (has-table ds 'userobject))
      (create-table ds 'userobject
		    `((integer oid not null primary key)
		      (varchar original_type_name (, _default_string_size_)))))
  (dolist (tpo tpos)
    (export-type ds tpo)
    (exportlog-report-type tpo)
    )
  (dolist (tpo tpos)
    (dolist (fno (allfunctionsfortype tpo))
      (let ((ownertype (first (get-resolvent-argtypes fno))))
	(cond ((eq ownertype tpo)
	       (export-function ds tpo fno))
	      ((not (memq ownertype tpos))
	       (exportlog-report-endangeredfn fno))
	      ))))
  (close-exportlog)
  (closestream *sql-stream*))

(defun export-type (ds tpo)
  (dolist (supertpo (remove _userobject_ (type-supertypes tpo)))
    (if (not (has-table ds (make-table-name supertpo)))
	(error "Export supertype first" supertpo)))
  (create-table ds (make-table-name tpo)(make-primary-key-columns tpo))
  (add-amos-type    ds :amos tpo :wrapped (make-table-name tpo))
  (add-wrapped-type ds :amos tpo :wrapped (make-table-name tpo)))

(defun make-primary-key-columns (tpo)
  ;; thanks to the table 'userobject', all types 
  ;; have a supertype in the relational database
  (list
   (append
    '(integer oid not null primary key references)
    (mapcar (f/l (supertpo) (make-table-name supertpo))
	    ;; this is weird. type-supertypes are only 
            ;; the immediate supertypes!
	    (sort-types (type-supertypes tpo)))
    '(on delete cascade on update cascade))))

(defun unexportable (fno)
  (or (memq _vector_ (get-resolvent-argtypes fno))
      (memq _vector_ (getrestype fno))))

(defun export-function (ds tpo fno)
  (selectq (functiontype fno)
	   ("foreign" (exportlog-report-endangeredfn fno))
	   ("derived" (exportlog-report-endangeredfn fno))
	   ("stored" (if (unexportable fno)
			 (exportlog-report-skippped-fn fno)
		       (export-stored-function ds tpo fno)))
	   (error "Unknown function type" (functiontype fno))))

(defun export-stored-function (ds tpo fno)
  (let* ((arginfos  (get-arginfo fno))
	 (fn        (generic-fnname fno))
	 (bagvalued (multivaluedp fno))
	 (usesuffix (> (length (function-resvars fno)) 1))
	 (paramname (make-column-name (arginfo-name (pop arginfos))))
	 (owner     (make-table-name tpo))
	 tablename)
    (dolist (ai arginfos)
      (let ((tpo (oid-name (arginfo-type ai))))
	(if (memq tpo _unexportable-types_)
	    (progn
	      (princ (concat "Warning, skipping stored function "
			     "with "tpo" as argument or result:"fno))
	      (setq arginfos nil)))))
    (cond (bagvalued
	   (setq tablename (make-table-name fno))
	   (create-table ds tablename 
			 (list (make-foreign-key 
				(list 'integer paramname) owner))))
	  (t
	   (setq tablename owner)))
    (dolist (ai arginfos)
      (let* ((basetypename (arginfo-type ai))
	     (basetype     (gettypenamed basetypename))
	     (basetable    (make-table-name basetype))
	     (argname      (arginfo-name ai))
	     (isusertype   (subtype-of basetype _userobject_))
	     (colname      (make-column-name (pack (if isusertype 'i_ "")
						   fn
						   (if usesuffix argname ""))))
	     (coltype      (if isusertype 
			       'integer
			     (catch-error (amos-to-wrapped-type 
					   ds basetypename))))
	     (reference    (if isusertype (list basetable))))
	(if (error? coltype)
	    (print (concat "Warning. The type "basetypename
			   " could not be converted. Type "
			   "defaults to "(setq coltype 'integer)".")))
	(if (and isusertype (not (has-table ds basetable)))
	    (error "Referenced type not exported" basetypename))
	(if (not usesuffix)
	    (create-column ds tablename (list coltype colname) reference))
	(create-index ds tablename colname coltype (arginfo-isunique ai))
	)
      )
    (if bagvalued
	(exportlog-report-bagfn fno)
      (exportlog-report-keyedfn fno))))

(defun create-index (ds table colname coltype unique)
  ;; unfortunately, we can't have unique indices w/o implying 'not null'
  ;; in interbase, and the only column we can guarantee is not null is
  ;; the primary key column, which we know is OID
  (if (neq colname 'oid) (setq unique nil))
  (sqllog ds (concat "create "(if unique "unique" "")" index "
		     (make-index-name)" on "table "("colname")")))

;;tar (typ namn)
(defun create-column (ds table column &optional referenced-tables)
  (let ((type  (first column))
	(name  (second column))
	(extra (if referenced-tables 
		   (concat "references "
			   (concatl referenced-tables ","))
		 "")))
    (if (or (eq type 'varchar) (equal type "VARCHAR"))
	(setq type (concat type "(" _default_string_size_ ")")))
    (sqllog ds (concat "alter table "table " add "name" "type" "extra))))

;tar (typ namn)
(defun create-table (ds name &optional cols)
  (if (eq cols nil)
      (setq cols '((integer oid not null primary key))))
  (sqllog
   ds
   (concat "create table "name"("
	   (concatl cols (quote ,) (f/l (col)
				 (concat (second col)" " (first col)" "
					 (concatl (cddr col)" "))))
	   ")")))

;tar (typ namn)
(defun make-foreign-key (fkey owner &rest extra)
  "Creates a foreign key as a table constraint."
  `( ,@ fkey not null constraint
	,(make-constraint) references , (sqlify-table-name owner) ,@ extra))
  
(defun make-table-name (oid)
  "OID is a usertype or function"
  (let* ((amosname
	  (cond ((subtype-of oid _userobject_)
		 (pack 'at_ (getobject oid 'name)))
		((function_p oid)
		 (pack 'af_
		       (getobject (first (get-resolvent-argtypes oid)) 'name)
		       '_
		       (generic-fnname oid)))
		((eq oid _userobject_)
		 _userobject-table-name_ )))
	 (candidate (sqlify-table-name amosname)))
    (if (memq candidate _sql-reserved-words_)
	(pack candidate '_)
      candidate)))

(defun sqlify-table-name (symb)
  "Removes characters that are illegal in SQL from a table name"
  (let ((l (explode symb))
	res)
    (cond ((> (length l) _sql-max-tablename-length_)
	   (setq res (packlist (firstn _sql-max-tablename-length_ l)))
;	   (print (concat "Warning, table name "symb" truncated to "res))
	   )
	  (t 
	   (setq res (packlist (delete '- (explode symb))))))
    res))

(defun make-column-name (symb)
  (cond ((memq symb _sql-reserved-words_)
	 (let ((newname (pack (sqlify-column-name symb) '_)))
;	   (exportlog-report-functionname symb newname)
	   newname))
	(t
	 (sqlify-column-name symb))))

(defun sqlify-column-name (symb)
  "Removes characters that are illegal in SQL from a column name"
  (let ((l (explode symb)) res)
    (delete '- l)			; remove any -
    (while (eq (first l) '_) (pop l))	; and any leading _
    (cond ((> (length l) _sql-max-colname-length_)
	   (setq res (packlist (firstn _sql-max-colname-length_ l)))
	   (print (concat "Warning, column name "symb" truncated to "res)))
	  (t (setq res (packlist l))))
    res))

(defun sqllog (ds update)
  (princ update *sql-stream*)
  (princ ";" *sql-stream*)
  (terpri *sql-stream*)
  (sql-update-table ds update))

(defun dependent (tpo2 tpo1)
  (or (subtype-of tpo1 tpo2)
      (references tpo1 tpo2)))

(defun references (tpo1 tpo2)
  (dolist (fno (allfunctionsfortype tpo1))
    (if (memq (getobject tpo2 'name)
	      (mapcar (function first) (make-tuple-spec fno)))
	(return t))))

(defun neurotypes ()
  (let (tps)
    (mapextent _storedtype_ 
	       (f/l (tpo) 
		    (if (>= (oid-idno tpo) (oid-idno (gettypenamed 'file)))
			(push tpo tps))))
    tps))

