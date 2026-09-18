;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: load_wrapper.lsp,v $
;;; $Revision: 1.2 $ $Date: 2003/10/27 13:21:38 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Loads the ancestor wrapper (parent to all datasources) called
;;;   datasource.
;;;              
;;; ===========================================================================
	   
; The abstract supertype of all datasources

(load-amosql "../wrappers/datasource/typemap.osql")
(load        "../wrappers/datasource/typemap.lsp")
(load        "../wrappers/datasource/core-cluster.lsp")
(load-amosql "../wrappers/datasource/core-cluster.osql")

