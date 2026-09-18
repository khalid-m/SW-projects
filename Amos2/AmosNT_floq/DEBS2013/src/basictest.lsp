;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) <year> <author>, UDBL
;;; $RCSfile: basictest.lsp,v $
;;; $Revision: 1.5 $ $Date: 2013/05/20 21:33:18 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Basic unit tests
;;; =============================================================
;;; $Log: basictest.lsp,v $
;;; Revision 1.5  2013/05/20 21:33:18  chexu484
;;; code clean up
;;;
;;; Revision 1.4  2013/04/14 10:51:47  torer
;;; Removed old code from the DEBS-wrapper
;;;
;;; Revision 1.3  2013/04/13 08:55:57  torer
;;; New version of eventstreamna() using debs_event_file_tuples()
;;;
;;; =============================================================

(checkequal 
 "debs_event_file_tuples"
 ((osql "in(eventstreamna('data/humbledata.csv'));")
  (osql "debs_event_file_tuples('data/humbledata.csv',
                                           start1sthalf());"))
 )