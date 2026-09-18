;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Tore Risch, UDBL
;;; $RCSfile: remotescan.lsp,v $
;;; $Revision: 1.22 $ $Date: 2013/08/12 09:16:09 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Stand-alone test of remote scans
;;; =============================================================
;;; $Log: remotescan.lsp,v $
;;; Revision 1.22  2013/08/12 09:16:09  larme597
;;; Check that finished scan has been removed.
;;;
;;; Revision 1.21  2013/08/07 17:33:24  larme597
;;; Closing/deallocation of remote scan.
;;;
;;; Revision 1.20  2013/08/07 16:43:08  torer
;;; *** empty log message ***
;;;
;;; Revision 1.19  2013/08/07 15:46:34  torer
;;; Measuring remote scan setup time
;;;
;;; Revision 1.18  2013/08/07 15:35:43  torer
;;; Measuring setup time for remore scans
;;;
;;; Revision 1.17  2013/08/07 15:10:21  larme597
;;; Testing remote multiscan.
;;;
;;; Revision 1.16  2012/10/26 15:06:47  torer
;;; *** empty log message ***
;;;
;;; Revision 1.15  2012/10/26 13:26:19  torer
;;; Testing remote stream error handling
;;;
;;; Revision 1.14  2012/10/21 15:03:43  torer
;;; Handling overloaded heartbeat()
;;;
;;; Revision 1.13  2012/10/05 06:50:22  torer
;;; Timing error when shutting down nameserver
;;;
;;; Revision 1.12  2012/08/23 13:03:08  larme597
;;; Separate socket not needed to kill remote scan.
;;;
;;; Revision 1.11  2012/08/22 16:11:38  larme597
;;; Regression for killing remote scan.
;;;
;;; Revision 1.10  2012/07/26 20:14:06  torer
;;; Error handling in remote scans
;;;
;;; Revision 1.9  2012/06/26 17:40:41  torer
;;; OS independent regression
;;;
;;; Revision 1.8  2012/06/20 20:01:15  torer
;;; Testing execute-remote-statement
;;;
;;; Revision 1.7  2012/06/19 18:30:31  torer
;;; Testing remote scans over streams
;;;
;;; Revision 1.5  2012/06/18 19:41:49  torer
;;; Using SEND-STATEMENT to kill peers
;;;
;;; Revision 1.4  2012/06/18 19:29:54  torer
;;; Removed code now in lsp/aclient.lsp
;;;
;;; Revision 1.3  2012/06/14 06:36:05  torer
;;; Robust test
;;;
;;; Revision 1.2  2012/06/14 06:16:31  torer
;;; Timing error
;;;
;;; Revision 1.1  2012/06/14 06:03:54  torer
;;; Stand-alone test of remote scans
;;;
;;; =============================================================

(defglobal _c_)
(defglobal _s_)
(defglobal _s1_)
(defglobal _s2_)
(defglobal _r_)

(start-program "amos2" "-n") ;; start nameserver
(start-program "amos2" "-s a") ;; start peer named A

(wait-until-started 'a)


(setq _c_ (open-socket-to 'a)) ;; Open client connection to peer named A

(setq _s_ (open-query-scan-remote "iota(1,2);"  
				  _c_));; Execute a query on peer A

(checkequal 
 "Remote scans"
 ((setq _r_ (scan-nextrow-remote _s_)) '(1));; next row as a list

 ((setq _r_ (scan-nextrow-remote _s_)) '(2));; next row as a list

 ((setq _r_ (scan-nextrow-remote _s_)) '*terminated*);; end of scan
 ((scan-check-id-remote (scan-remote-id _s_) _c_) '()) ;; Not exist anymore
 ((scan-close-remote _s_) '*terminated*) ;; Should do nothing

 ((materialize-remote-scan (open-query-scan-remote "iota(3,9);" _c_))
  '((3) (4) (5) (6) (7) (8) (9)))
 ((length (materialize-remote-scan 
	   (open-query-scan-remote "first_n(heartbeat(0.1),5);" _c_)))
  5)
 ((execute-remote-statement "iota(1,4);" _c_) '((1)(2)(3)(4)))
 ((errstring (materialize-remote-scan (open-query-scan-remote "1/0;" _c_)))
  "Divide by zero")
 )

(defun call-remote (conn fno args)
  (materialize-remote-scan (open-function-scan-remote conn fno args)))

(defglobal _fno_ (theresolvent 'identity))

(checkequal "100 remote scan Amos function call"
	    ((time (rptq 100 (call-remote  _fno_ '(1) _c_)))
	     '((1)))
	    )

;; org mac: 0.195s
;; separate socket: 0.292s

; Set up multiscan
(execute-remote-statement "create function twostream(Number l, number u) \
  -> Vector of Stream of Number \
  as {diota(0.5,l,u),diota(1,10*l,10*l+u)};" _c_)

(setq _s_ (open-query-scan-remote "twostream(1, 5);" _c_))
(setq _r_ (car (scan-nextrow-remote _s_)))
(setq _s1_ (open-stream-scan-remote (elt _r_ 0) _c_ '(:timeout 0.1)))
(setq _s2_ (open-stream-scan-remote (elt _r_ 1) _c_ '(:timeout 0.1)))

(checkequal
 "Remote multiscans"
 ((scan-nextrow-remote _s1_) '(1))
 ((scan-nextrow-remote _s2_) '(10))
 )

(setq _r_ (scan-remote-id _s2_)) ;; Store key temporarily
(checkequal
 "Closing remote scan"
 ((scan-close-remote _s1_) '*terminated*)
 ((scan-close-remote _s1_) '*terminated*) ;; Should not return error
 ((scan-check-id-remote (scan-remote-id _s1_) _c_) '()) ;; Not exist anymore
 ((scan-check-id-remote _r_ _c_) t) ;; Should exist
 ((setq _s2_) '()) ;; Should deallocate scan on server
 ((scan-check-id-remote _r_ _c_) '()) ;; Should not exist now
 )

(setq _s_ (open-query-scan-remote "heartbeat(0.1);" _c_ '(:buffersize 1)))
(setq _r_ (open-function-scan-remote
	   (getfunctionnamed 'heartbeat) (list 0.1) _c_ '(:buffersize 1)))

(setq _s1_ (open-query-scan-remote "foo(2);" _c_));; no error here

(checkequal 
 "Error handling"
 ((errstring (scan-nextrow-remote _s1_));; error here!
  "No object found named FOO of type FUNCTION")
 ((scan-nextrow-remote _s1_) '*terminated*);; scan closed after error
 )

(checkequal "Killing remote scan"
	    ((scan-nextrow-remote _s_) '(0.0));; returns (0)
	    ((null (scan-kill-remote _s_)) NIL)
	    ((scan-nextrow-remote _s_) '*terminated*);; returns *terminated*
	    ((scan-nextrow-remote _r_) '(0.0));; returns (0)
	    ((null (scan-kill-remote _r_)) NIL)
	    ((scan-nextrow-remote _r_) '*terminated*);; returns *terminated*
	    )

(send-statement "quit;" _c_) ;; Kill the peer

(send-statement "quit;" (open-nameserver-socket)) ;; Kill the nameserver
(sleep 0.1) ;; Make sure message sent
(quit) ;; Bye



