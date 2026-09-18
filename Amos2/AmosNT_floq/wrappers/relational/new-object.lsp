;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: new-object.lsp,v $
;;; $Revision: 1.5 $ $Date: 2010/02/16 20:01:55 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: A creator for objects that updates a relational database.
;;;              redefines the function new_object in AmosNT/lsp
;;;              Does not get loaded during install.
;;;              
;;; ===========================================================================
(defvar _oid_mapping_ (getfunctionnamed 'integer.oid_mapping->object))
(defvar *oidmap-counter* 0)
(defvar *oidmap-list* NIL)
;(defvar *oidmap-table* (make-hash-table :test (function equal)))
;(setq logfilecounter 0)

(defun new_object--+ (fno orgno typename )
  (let ((res (new-object-int orgno (mksymbol typename))))
    (osql-result orgno typename res)))

(defun new-object (fno orgno typename )
  (let ((res (new-object-int orgno (mksymbol typename))))
    (osql-result orgno typename res)))

(defun new-object-int (orgno typename)
  (let ((oldobj (caar (getfunction _oid_mapping_ (list orgno)))))
    (or oldobj
	(let* ((mt (getobjectnamed typename _mappedtype_ 'noerror))
	       (newobj (if mt
			   (new-mapped-object orgno typename mt)
			 (/createobject (mksymbol typename) NIL))))
	  (addfunction _oid_mapping_ (list orgno) (list newobj))
	  newobj))))

(defun new-mapped-object (orgno typename mt)
  (let ((newid (1++ *oidmap-counter*))
	(ds (getobject (getresolvent (getobject mt 'cclusterfn)) 'datasource)))
    (dolist (mtpo (reverse (mapfilter  (f/l (o) (subtype-of o _userobject_))
				       (sort-types (type-allsupertypes mt)))))
      (let* ((keys (getobject mtpo 'keys))
	     (ccfno (getresolvent (getobject mtpo 'cclusterfn)))
	     (table-name (getobject ccfno 'tablename)))
	(if (> (length keys) 1) (error "primary key not atomic"))
	(if (not (eq (first (first keys)) 'integer))
	    (error "wrong key type" (caar keys)))
	(amos-execute
	 (concat "sqlu("ds",'insert into "table-name
		 "("(concatl keys "," (function second))")"
		 " values ("newid")');"))))
    (amos-execute
     (concat "sqlu("ds",\"update userobject "
	                "set original_type_name='"typename"' "
  	                "where oid="newid"\");"))
; return a new object that maps to the row in the table
    (caar
     (amos-execute
      (concat "select x from "typename" x where oid(x)="*oidmap-counter*";")))))
