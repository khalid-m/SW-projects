;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: load_wrapper.lsp,v $
;;; $Revision: 1.13 $ $Date: 2004/01/23 10:21:14 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Loads the JDBC wrapper
;;;              
;;; ===========================================================================
	   
; The JDBC wrapper

(load "../wrappers/JDBC/jdbc.lsp")
(load-amosql "../wrappers/JDBC/jdbc.osql")
