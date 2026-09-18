;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: load_wrapper.lsp,v $
;;; $Revision: 1.2 $ $Date: 2012/05/21 09:53:11 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Loads the relational wrapper
;;;              
;;; ===========================================================================
	   
; The relational wrapper

(load        "relational.lsp")
(load-amosql "relational.osql")
(load        "sqlquery.lsp")
(load        "import-table.lsp")
(load        "export-type.lsp")
(load        "exportlog.lsp")
(load        "import-foreign-keys.lsp")
(load        "metadata.lsp")
(load        "sql.lsp")
;;(load        "sql_cost.lsp")
;;(load-amosql "sql_cost.osql")
(load        "relational_translator.lsp")
(load-amosql "relational_typemap.osql")
(load        "sql_constructor.lsp")


