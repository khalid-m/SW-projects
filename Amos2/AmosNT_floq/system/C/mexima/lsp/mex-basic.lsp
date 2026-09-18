;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010 Thanh Truong, UDBL
;;; $RCSfile: mex-basic.lsp,v $
;;; $Revision: 1.8 $ $Date: 2013/01/09 15:07:32 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: LISP functions used by EXSTMA
;;; =============================================================
;;; $Log: mex-basic.lsp,v $
;;; Revision 1.8  2013/01/09 15:07:32  thatr500
;;; removed load-index-extension, load-special-extension. Instead,
;;; function load-extension is used.
;;;
;;; Revision 1.7  2012/01/12 07:58:22  thatr500
;;; - changed signature a_initialize_extension
;;; - fixed "Loading Borland /VC++ dynamic dll" on Unix
;;;
;;; Revision 1.6  2012/01/02 08:48:24  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.5  2011/12/28 10:01:42  thatr500
;;; load mex-save-restore.lsp
;;;
;;; Revision 1.4  2011/12/27 09:44:57  thatr500
;;; organized codes
;;;
;;; Revision 1.3  2011/12/20 21:00:56  thatr500
;;; removed dead code
;;;
;;; Revision 1.2  2011/12/13 09:56:01  thatr500
;;; new global sysmbol _transient-indexes_
;;;
;;; Revision 1.1  2011/12/02 12:47:34  thatr500
;;; MEXIMA core
;;;
;;; Revision 1.5  2011/06/25 16:59:09  thatr500
;;; =============================================================

;;-----------------------------------------------------------------------------
;; Meta-data and its associated functions
;;-----------------------------------------------------------------------------
;; Declare hashtable containg <index-owner, {savefn, loadfn}> of all
;; external indexes
(defglobal _exinma-ht_ (make-hash-table) 
  "hashtable containg <index-owner, {strtype savefn, loadfn lang path}>")

;;---------------------------------------------------------------------------------
(load "mex-save-restore.lsp")