;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2004 Milena Ivanova, UDBL
;;; $RCSfile: global_def.lsp,v $
;;; $Revision: 1.5 $ $Date: 2005/12/19 13:45:42 $
;;;
;;; Description: 
;;;    Global variables used in many files
;;;              
;;; ===========================================================================

;; statistics of memory utilization
(defglobal _start-imagesize_ nil)
(defglobal _end-imagesize_ nil)

(defglobal _activeboxes_ nil)

(defglobal _keep-running_ t) ;; checked by run-gsdm-server
(defglobal _cq-server_ nil) ; Is an AMOS server a cq-server?

(defglobal _bstart_ nil) ;start time for execution of the current box

;;; Global hash table for exec statistics, key - period no
(defglobal _exec-stat_ (make-hash-table :test 'equal)) 

(defglobal _period-no_ 0) ;; global period id

(defglobal _push-time-sched_ 0.0) ;time for pushing comm per sched. execution

(defglobal _udp-thread-started_ nil)