;(defvar _relational_ (createtype 'relational '(datasource)))

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




