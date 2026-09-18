;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Tore Risch, UDBL
;;; $RCSfile: aclient.lsp,v $
;;; $Revision: 1.8 $ $Date: 2012/06/22 13:37:59 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Bare bone remote Amos interface
;;; =============================================================
;;; $Log: aclient.lsp,v $
;;; Revision 1.8  2012/06/22 13:37:59  torer
;;; Client server callin interface completely in terms of bare bone
;;; socket client interface
;;;
;;; Revision 1.7  2012/06/20 20:00:34  torer
;;; New function (execute-remote-statement stmt socket)
;;;
;;; Revision 1.6  2012/06/20 18:40:56  torer
;;; (WAIT-UNTIL-STARTED SERVERS) now takes list of servers
;;;
;;; Revision 1.5  2012/06/18 19:41:00  torer
;;; ACLIENT-SEND-STATEMENT -> SEND-STATEMENT
;;;
;;; Revision 1.4  2012/06/18 19:27:35  torer
;;; Removed from aclient.lsp what is now in remote_scan.lsp
;;;
;;; Revision 1.3  2012/05/28 09:58:10  torer
;;; aLisp client interfaces included in main image
;;;
;;; Revision 1.2  2012/05/23 20:24:45  torer
;;; New function to immediately execute remote amos statement asyncronously
;;; and ignoring the result
;;; (ACLIENT-SEND-STATEMENT conn stmt)
;;;
;;; Revision 1.1  2012/05/23 19:05:56  torer
;;; Bare bone Amos client interface from Lisp
;;;
;;; =============================================================

(defun materialize-remote-scan (scan)
  "Materialize a scan as a list of rows"
  (materialize-remote-scan1 scan (tconc)))

(defun materialize-remote-scan1 (scan res)
  (while (null (scan-eos-remote scan))
    (tconc res (scan-nextrow-remote scan)))
  (scan-close-remote scan)
  (car res))

(defun send-statement (cmd sock)
  "Execute remote AmosQL statement without returning scan"
  (socket-send (list 'execute-statement cmd) sock))

(defun execute-remote-statement (cmd sock &optional stopafter)
  "Execute remote AmosQL statement and return result as list of tuple lists"
  (socket-eval (list 'amos-execute cmd stopafter) sock))


