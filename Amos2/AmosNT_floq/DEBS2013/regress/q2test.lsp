;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013 Thanh Truong, UDBL
;;; $RCSfile: q2test.lsp,v $
;;; $Revision: 1.4 $ $Date: 2013/04/09 09:52:29 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Test for Q2
;;; =============================================================
;;; $Log: q2test.lsp,v $
;;; Revision 1.4  2013/04/09 09:52:29  thatr500
;;; Added test_Q2.osql
;;;
;;; Revision 1.3  2013/04/08 18:00:04  thatr500
;;; Added some tests for Q2
;;; Added new design for splitting ballhitter stream so that Q4 can re-use
;;;
;;; Revision 1.2  2013/04/08 15:50:58  thatr500
;;; removed stored procedures.
;;;
;;; Revision 1.1  2013/03/22 13:31:28  thatr500
;;; Added simple test for Q2
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================
(osql "set :testQ4bin = 'data/testQ4.bin';
       set :testbin = 'data/head4M.bin';
       set :fullbin =   'data/full-game.bin';")

(checkequal 
 "Test ballhitter on small data"
 ((osql "count(select v from Numarray v where v in ballhitter_bag(inputstreamna(:testQ4bin)) and isballhitter(v));")
  '((2))))

(checkequal 
 "Heavy Test Ball_hitter on head4M.bin"
 ((osql "count(ballhitter_bag(inputstreamna(:testbin)));")
  '((168))))
