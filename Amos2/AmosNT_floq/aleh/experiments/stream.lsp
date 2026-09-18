;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Ruslan Fomkin, UDBL
;;; $RCSfile: stream.lsp,v $
;;; $Revision: 1.19 $ $Date: 2008/03/25 14:50:21 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  
;;; ===========================================================================
;;; $Log: stream.lsp,v $
;;; Revision 1.19  2008/03/25 14:50:21  ruslan
;;; reorganization: split experiments, which run without safisticated query optimization, and experiments on advanced system. experiment to tune zAplah and delta are added
;;;
;;; Revision 1.18  2008/03/01 10:07:54  ruslan
;;; dropping slot stat fucntion
;;;
;;; Revision 1.17  2008/02/23 09:11:52  ruslan
;;; sending messages from AmosQL
;;;
;;; Revision 1.16  2008/01/29 09:58:36  ruslan
;;; more general execute
;;;
;;; Revision 1.15  2008/01/28 14:28:52  ruslan
;;; logging off moved into general part
;;;
;;; Revision 1.14  2008/01/26 12:49:12  ruslan
;;; reoptimization with calculating mean and standard deviation
;;;
;;; Revision 1.13  2008/01/20 13:03:18  ruslan
;;; performance evaluation of exp cut on every single bkg file
;;;
;;; Revision 1.12  2008/01/19 09:25:33  ruslan
;;; small improvements
;;;
;;; Revision 1.11  2008/01/17 16:02:47  ruslan
;;; some generalization. more use of proccall and mapfunction
;;;
;;; Revision 1.10  2008/01/17 14:06:23  ruslan
;;; a bug is fixedstream.lsp
;;;
;;; Revision 1.9  2008/01/17 13:16:42  ruslan
;;; using proccall and mapfunction instead of callfunction
;;;
;;; Revision 1.8  2007/10/19 07:42:19  ruslan
;;; execute and reopt2 returns standard deviation and sum of squares
;;;
;;; Revision 1.7  2007/10/08 07:46:18  ruslan
;;; static cm with reoptimize2
;;;
;;; Revision 1.6  2007/10/03 11:46:45  ruslan
;;; tuning confidence
;;;
;;; Revision 1.5  2007/10/03 08:42:36  ruslan
;;; tuning II and SH of randomopt
;;;
;;; Revision 1.4  2007/10/02 08:15:05  ruslan
;;; II tunning
;;;
;;; Revision 1.3  2007/10/01 07:23:33  ruslan
;;; experiments over all bkgs files together
;;;
;;; Revision 1.2  2007/09/26 07:08:43  ruslan
;;; tunning static cost model approach
;;;
;;; Revision 1.1  2007/09/20 13:08:18  ruslan
;;; experimental setup to do experiments for MAN cuts 2003 over bkg files
;;;
;;; ===========================================================================

;(load "stream.naive.lsp")

;;;
;;; mean values for electrons, muons, jetbs
;;;
(foreign-lispfn electron_mean () ((real mean))
		(let* ((el-stat (first (callfunction *sobject-stat-fn* 
						     (list *eventtype* 
							   *elslott*))))
		       (el-n (+ (aref el-stat 0) 0.0))
		       (el-mean (/ (aref el-stat 1) el-n)))
		  (foreign-result el-mean)))

(foreign-lispfn muon_mean () ((real mean))
		(let* ((mu-stat (first (callfunction *sobject-stat-fn* 
						     (list *eventtype* 
							   *muslott*))))
		       (mu-n (+ (aref mu-stat 0) 0.0))
		       (mu-mean (/ (aref mu-stat 1) mu-n)))
		  (foreign-result mu-mean)))

(foreign-lispfn jetb_mean () ((real mean))
		(let* ((jb-stat (first (callfunction *sobject-stat-fn* 
						     (list *eventtype* 
							   *jbslott*))))
		       (jb-n (+ (aref jb-stat 0) 0.0))
		       (jb-mean (/ (aref jb-stat 1) jb-n)))
		  (foreign-result jb-mean)))
