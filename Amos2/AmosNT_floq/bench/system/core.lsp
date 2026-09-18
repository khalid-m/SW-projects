;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Tore Risch, UDBL
;;; $RCSfile: core.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/03/17 09:42:05 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: aLisp benchmark
;;; =============================================================
;;; $Log: core.lsp,v $
;;; Revision 1.1  2013/03/17 09:42:05  torer
;;; Micro-benchmarks
;;;
;;; =============================================================

;;; Sorting

(defglobal _ll_ nil)

(null (rptq 1000000 (push (random 10000) _ll_)))

(null (sort _ll_ (function <)))
;; MacBook pro, Windows32, VS6.0:  9.389s
