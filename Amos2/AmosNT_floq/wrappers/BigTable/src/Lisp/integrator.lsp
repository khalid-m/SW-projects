;;define a new type for a new kind of datasource
(defvar _Bigtable_ (createtype 'Bigtable '(datasource)))

(defun source--+ (fno dsn dstype ds)
  "receives charstring data source name and type, to attach the data 
   source type to the generated data source object and returns 
   the data source object"
  (setq ds (or (getobjectnamed (mksymbol dsn) (pack '_ dstype '_) t) 
	       (/createobject (mksymbol dstype) dsn)))
  (/putobject ds 'dstype dstype)  
  (cond ((string-like-i dstype "Bigtable")
	 (/putobject ds 'absorber 'absorb-gql)
	 (/putobject ds 'finalizer 'translate-gql)
	 (addfunction 'absorber (list ds) (list "absorb-gql"))
	 (addfunction 'finalizer (list ds) (list "translate-gql")))
	((string-like-i dstype "jdbc")
	 (/putobject ds 'absorber 'absorb-sql)
	 (/putobject ds 'finalizer 'translate-sql)
	 (addfunction 'absorber (list ds) (list "absorb-sql"))
	 (addfunction 'finalizer (list ds) (list "translate-sql"))))
  (osql-result dsn dstype ds))