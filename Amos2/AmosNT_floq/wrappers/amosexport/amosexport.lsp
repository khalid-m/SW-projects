;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: amosexport.lsp,v $
;;; $Revision: 1.3 $ $Date: 2004/03/29 18:51:17 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Definition of the type amosexport.
;;;              
;;; ===========================================================================
(defvar _amosexport_ (createtype 'amosexport '(jdbc)))
(putobject _amosexport_ 'initializer 'relational-initialize)
(putobject _amosexport_ 'finalizer 'relational-finalize)

(defun amosexport--+ (fno name driver ae)
  "You specify a driver name as the second argument."
  (getfunction 'load_driver (list driver))
  (setq ae (/createobject 'amosexport name))
  (osql-result name driver ae))

(defun most_specific_type---+ (fno ds key general-type specific-type)
  (osql-result ds key general-type (most-specific-type ds general-type key)))

(defun amosexport.charstring.charstring.boolean.vector.import_table-----+
  (fno ds tablename typename updateable supertypes mtp)
  (let ((mt (import-oo-table ds (convert tablename)
			     (convert typename)
			     (convert updateable)
			     (mapcar (function gettypenamed)
				     (convert supertypes)))))
    (osql-result ds tablename typename updateable supertypes mt)))

(defun import-oo-table (ds table mtname updateable supertypes)
  (let* ((columns (get-columns-amos-typed ds table 'noerror))
	 (keycols  (get-key-columns-amos-typed ds "" "" table))
	 (cc-fno  
	  (create-relational-core-cluster-fn ds table columns keycols mtname))
	 (cc-name (generic-fnname cc-fno))
	 mt)
    (add-rewriter cc-fno (buildn (length columns) '+) 'rewrite-extent)
    (setq mt (create-mapped-type mtname 
				 supertypes
				 columns 
				 keycols
				 cc-name))
    (add-amos-type    ds :wrapped table :amos mt)
    (add-wrapped-type ds :wrapped table :amos mt)
    (if updateable (create-keyed-update-fns ds mt columns keycols))
    mt))

(defun most-specific-type (ds type key)
  "Returns the most specific type whose key is key, ie the table from which 
   the type was imported has a row with the number key in the oid colum."
  (let ((subtypes (subtypes type))
	tpo)
    (while (and (setq tpo (pop subtypes)) (not (isinstance ds tpo key))))
    (or (and tpo (most-specific-type ds tpo key)) 
	(if (isinstance ds type key) type))))

(defun isinstance (ds mtpo id)
  "True if the table which the mapped type mtpo is imported from has a row
   with the number id in the oid column."
  (getfunction 'isinstance (list ds mtpo id)))
