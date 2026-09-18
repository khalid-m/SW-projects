;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Ruslan Fomkin, UDBL
;;; $RCSfile: dynamic_statistics.lsp,v $
;;; $Revision: 1.1 $ $Date: 2007/10/16 11:51:40 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  
;;; ===========================================================================
;;; $Log: dynamic_statistics.lsp,v $
;;; Revision 1.1  2007/10/16 11:51:40  ruslan
;;; collecting statistics dynamically using confidence interval
;;;
;;; ===========================================================================

;(load "../lsp/profiling.lsp")

(defglobal _zAlpha_ 1.96)
(defglobal _Delta_ 0.1)

(setq *stop-profiling* 'collected_agg)
(setq *ungroup* t)

(foreign-lispfn eventstat ((boolean flg))()
		"To toggle collecting statistics on stored event properties"
		(/setglobal '*profiling* flg)
		(/setglobal '*struct-stat* flg)
;		(if (eq flg 'false)(setq flg nil)(init-profilers))
		(if flg (foreign-result)))

(foreign-lispfn set_confident ((real zAlpha)(real Delta)) ()
		(/setglobal '_zAlpha_ zAlpha)
		(/setglobal '_Delta_ Delta))

(defun isConfident (zAlpha Delta)
  (let* ((el-stat (first (callfunction *struct-stat-fn* (list *eventtype* 4))))
	 (mu-stat (first (callfunction *struct-stat-fn* (list *eventtype* 5))))
	 (jb-stat (first (callfunction *struct-stat-fn* (list *eventtype* 6))))
	 (el-n (+ (aref el-stat 0) 0.0))
	 (el-mean (/ (aref el-stat 1) el-n))
	 (el-stderr (sqrt (- (/ (aref el-stat 2) (* el-n el-n))
			     (/ (* el-mean el-mean) el-n))))
	 (mu-n (+ (aref mu-stat 0) 0.0))
	 (mu-mean (/ (aref mu-stat 1) mu-n))
	 (mu-stderr (sqrt (- (/ (aref mu-stat 2) (* mu-n mu-n))
			     (/ (* mu-mean mu-mean) mu-n))))
	 (jb-n (+ (aref jb-stat 0) 0.0))
	 (jb-mean (/ (aref jb-stat 1) jb-n))
	 (jb-stderr (sqrt (- (/ (aref jb-stat 2) (* jb-n jb-n))
			     (/ (* jb-mean jb-mean) jb-n)))))
    (and
     (> (* Delta el-mean) (* zAlpha el-stderr))
     (> (* Delta mu-mean) (* zAlpha mu-stderr))
     (> (* Delta jb-mean) (* zAlpha jb-stderr)))))

(defun collected_agg (tfn argl)
    (cond
     ((isConfident _zAlpha_ _Delta_)
      (setq *profiling* nil)
      (setq *struct-stat* nil)
      (reoptimize2 tfn)
      t)))
