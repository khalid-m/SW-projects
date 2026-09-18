;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013, UDBL
;;; $RCSfile: full.lsp,v $
;;; $Revision: 1.2 $ $Date: 2013/04/21 22:38:35 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Full performance tehsing DEBS 2013
;;; =============================================================
;;; $Log: full.lsp,v $
;;; Revision 1.2  2013/04/21 22:38:35  thatr500
;;; removed SAMPLING !!!!
;;;
;;; Revision 1.1  2013/04/18 13:31:49  torer
;;; DEBS full performance testing
;;;
;; =============================================================

(osql "
set :largefile = 'data/head3Min.csv';")

(checkequal
 "debs new complete no sampling"
 ((time (osql "count(fullgamenew(:largefile));"))
  '((0)))
 )
