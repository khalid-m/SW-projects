;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Robert Kajic, UDBL
;;; $RCSfile: init.lsp,v $
;;; $Revision: 1.1 $ $Date: 2011/05/05 16:44:13 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Loads all lisp code. 
;;; =============================================================
;;; $Log: init.lsp,v $
;;; Revision 1.1  2011/05/05 16:44:13  roka4241
;;; moved the whole project down one directory
;;;
;;; Revision 1.4  2011/04/27 14:23:44  torer
;;; *** empty log message ***
;;;
;;; Revision 1.3  2011/02/18 15:31:31  roka4241
;;; Getting compilation and tests running without having to compile python yourself.
;;;
;;; Revision 1.2  2011/02/03 14:13:38  roka4241
;;; Added console based compilation of the project.
;;;
;;; Revision 1.1  2011/02/01 18:45:00  roka4241
;;; Added regression tests for much of the current callout functionality.
;;;
;;;
;;; =============================================================

(load "list.lsp")
(load "../../../scsq/cql/lsp/base.lsp")