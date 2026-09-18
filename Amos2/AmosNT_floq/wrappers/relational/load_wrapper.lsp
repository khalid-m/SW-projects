;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: load_wrapper.lsp,v $
;;; $Revision: 1.20 $ $Date: 2012/10/23 15:07:18 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Loads the relational wrapper
;;;              
;;; ===========================================================================
	   
; The relational wrapper

(load        "../wrappers/relational/relational.lsp")
(load-amosql "../wrappers/relational/relational.osql")
(load        "../wrappers/relational/sqlquery.lsp")
;(load-amosql "../wrappers/relational/capabilities.osql")
(load        "../wrappers/relational/import-table.lsp")
(load        "../wrappers/relational/export-type.lsp")
(load        "../wrappers/relational/exportlog.lsp")
(load        "../wrappers/relational/import-foreign-keys.lsp")
(load        "../wrappers/relational/metadata.lsp")
(load        "../wrappers/relational/sql.lsp")
;(load        "../wrappers/relational/sql_cost.lsp")
;(load-amosql "../wrappers/relational/sql_cost.osql")
(load        "../wrappers/relational/relational_translator.lsp")
(load-amosql "../wrappers/relational/relational_typemap.osql")
(load        "../wrappers/relational/sql_constructor.lsp")


