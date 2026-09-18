;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009 Lars Melander, UDBL
;;; $RCSfile: scanregress.lsp,v $
;;; $Revision: 1.20 $ $Date: 2013/06/26 17:45:26 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Testing scan functionality
;;; =============================================================
;;; $Log: scanregress.lsp,v $
;;; Revision 1.20  2013/06/26 17:45:26  torer
;;; Reverting (CO-SLEEP)
;;;
;;; Revision 1.18  2012/11/02 07:12:53  torer
;;; The dispatch between command and query in client again temporarily
;;;
;;; Revision 1.16  2012/07/24 12:57:16  torer
;;; Regression test of corrected evalv()
;;;
;;; Revision 1.15  2012/07/17 16:32:36  torer
;;; Regression testing map-query()
;;;
;;; Revision 1.13  2012/03/13 15:05:01  torer
;;; Regression testing late binding and query scans
;;;
;;; Revision 1.12  2012/02/27 12:23:46  larme597
;;; Test of scan with timeout removed.
;;;
;;; Revision 1.11  2011/12/02 14:04:58  larme597
;;; Moved remote scan testing to remote.osql.
;;;
;;; Revision 1.10  2011/11/25 04:42:41  larme597
;;; Adding scan regression to Linux.
;;;
;;; Revision 1.9  2011/11/15 15:14:29  larme597
;;; Added some testing for new scan timeout functionality.
;;;
;;; Revision 1.8  2011/01/01 19:21:22  torer
;;; iota now over type Number, not Integer
;;;
;;; Revision 1.7  2010/10/12 15:10:18  larme597
;;; Fixing a server problem with remote scans.
;;;
;;; Revision 1.6  2010/09/10 14:40:01  larme597
;;; Adding more scan regression and also for remote scans.
;;;
;;; Revision 1.5  2009/09/25 14:10:44  larme597
;;; Changing a setq to a defglobal to get rid of an unnecessary warning
;;;
;;; Revision 1.4  2009/09/04 11:58:01  torer
;;; Temporarily removed leak test
;;;
;;; Revision 1.3  2009/09/02 19:13:55  torer
;;; Tested for memory leak
;;;
;;; Revision 1.2  2009/09/02 12:49:12  torer
;;; Added test
;;;
;;; Revision 1.1  2009/08/21 12:38:50  larme597
;;; Regression tests for scan
;;;
;;; =============================================================

(defglobal s (open-function-scan 'iota (vector 1 2)))

(defglobal s2 (open-query-scan "argrestypes(#'iota');"))

(defglobal s3 (open-query-scan "set :a=5;"))

(defglobal s4 (open-query-scan ":a;"))

(defun scan-test1 ()
  (let ((s (open-function-scan 'iota (list 1 10)))
	lst)
    (while (not (scan-eos s))
      (setq lst (cons (scan-nextrow s) lst)))
    (reverse lst)))

(checkequal "Scan"
            ((scan-eos s) nil)
	    ((scan-nextrow s) '(1))
            ((scan-eos s) nil)
	    ((scan-nextrow s) '(2))
            ((scan-eos s) t)
	    ((scan-nextrow s) '*terminated*)
            ((scan-close s) '*terminated*)
	    ((scan-test1) '((1)(2)(3)(4)(5)(6)(7)(8)(9)(10)))
            ((alloccnt 'coroutine '(scan-test1)) 0) 
            ((externalize (scan-nextrow s2)) '(1 number 0))
            ((externalize (scan-nextrow s2)) '(2 number 0))
            ((externalize (scan-nextrow s2)) '(3 integer 1))
            ((externalize (scan-nextrow s2)) '*terminated*)
            ((externalize (scan-nextrow s3)) '(5))
            ((osql ":a;") '((5)))
            ((externalize (scan-nextrow s4)) '(5))
	    )

; Testing scans with coroutine background

(foreign-lispfn sliota2
		((integer low) (integer high) (number sleep)) ((number))
  (dotimes (count (1+ (- high low)))
    (co-sleep sleep)
    (foreign-result (+ count low))))

;(osql "set :s = openscan(bagof(sliota2(1, 10, 0.3)));")
;(checkequal "Scan with sliota"
;	    ((osql "next(:s, 0.5);") '((#())))
;	    ((osql "next(:s, 0.5);") '((#(1))))
;	    ((osql "next(:s, 0.2);") '((#())))
;	    ((osql "next(:s, 0.2);") '((#(2))))
;	    ((osql "next(:s, 0);") '((#())))
;	    ((osql "peek(:s);") '((#(3))))
;)

(rollback)
