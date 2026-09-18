;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: load_wrappers.lsp,v $
;;; $Revision: 1.18 $ $Date: 2013/05/01 15:59:10 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Loads all wrappers
;;;              
;;; ===========================================================================

(load "../wrappers/datasource/load_wrapper.lsp")
(load "../wrappers/relational/load_wrapper.lsp")
(load "../wrappers/JDBC/load_wrapper.lsp")
(load-amosql "../wrappers/relational/configuration.osql")

(load "../wrappers/relational/sql_absorber.lsp")
(load "../wrappers/relational/sql_finalizer.lsp")
(load "../wrappers/relational/numwrapper.lsp")
(load "../wrappers/relational/patch.lsp")

; (load "../wrappers/ODBC/load_wrapper.lsp") ; made optional via install.bat
;(load "../wrappers/MBTree/load_wrapper.lsp") does not work! (TR)
;(load "../wrappers/Amos/load_wrapper.lsp") not needed (TR) 
(load "../wrappers/Amos/amos.lsp") 
(init-amos-ds); enough