;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: jdbc.lsp,v $
;;; $Revision: 1.8 $ $Date: 2012/10/23 15:05:03 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Declaration of the jdbc datasource type.
;;;              
;;; ===========================================================================
; To do: As of now, the initializer and finalizer are hooked to the 
; jdbc type, but they really belong in relational. How do we fix inheritance
; for these things?

(defglobal _jdbc_ (createtype 'jdbc '(relational)))

(defun jdbc--+ (fno name driver jds)
  "You specify a driver name as the second argument. For some known 
   datasources (currently DB2) it is enough to give the name e.g. 'db2'" 
  (getfunction 'load_driver (list driver))
  (setq jds (or (getobjectnamed (mksymbol name) _jdbc_ t) (/createobject 'jdbc name)))
  (osql-result name driver jds))

(defun get-tablename (mt)
  "Returns the table name of the table that a mapped type is mapped to."
  (getobject(first(getobject(getobject mt 'cclusterfn)'resolvents))'tablename))