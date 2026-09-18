;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: load_wrapper.lsp,v $
;;; $Revision: 1.6 $ $Date: 2005/01/04 17:51:42 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Loads the Amos II wrapper
;;;              
;;; ===========================================================================
	   
; The Amos wrapper addon

;(load "../wrappers/Amos/amos.lsp") already loaded
;(load-amosql "capabilities.osql")
(load "import.lsp")
(load-amosql "amos.osql")
(load-amosql "amos_typemap.osql")
(load "apply_remote.lsp")
(load "amosentity.lsp")
(load "amos_translator.lsp")
(load "remoteplan.lsp")
(load "remotefninfo.lsp")
;(init-amos-ds) ; already done