;;; ============================================================
;;; AMOS
;;; 
;;; Author: (c) 1995 Salah-Eddine Machani, EDSLAB
;;; $RCSfile: event_manager.lsp,v $
;;; $Revision: 1.6 $ $Date: 2004/03/03 21:22:51 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;         Detects the setrelation and createobject events and records 
;;;         them into delta-relations after considering the net-effect
;;;         of changes.
;;; Requirements: queues
;;; =============================================================
;;; $Log: event_manager.lsp,v $
;;; Revision 1.6  2004/03/03 21:22:51  torer
;;; make-rule-queue removed
;;;
;;; Revision 1.5  2001/12/27 16:24:56  torer
;;; 1. Modified ECA rules so that the net effect of events now computed correctly
;;; 2. Fixed severe memory leak in logger
;;;
;;; Revision 1.4  2000/10/30 11:20:09  torer
;;; 1. Documented transactions and events
;;; 2. Improved performance of events
;;; 3. Fixed bug that turned off demon during parsing
;;; 4. Changed option in oamos.bpr to avoind VIRDEF bug in Borland C++
;;;
;;; Revision 1.3  2000/10/24 12:44:14  torer
;;; ECA rules OK
;;;
;;; Revision 1.2  2000/08/14 07:35:58  torer
;;; Patched rule system temporarily to be able to install system.
;;; The installer no longer tries to load non-existing files.
;;;
;;; Revision 1.1  2000/08/11 16:18:39  evato
;;; New files for ECA rule execution. Some are probably superfluous if CA rules
;;; are excluded, and then they should be removed later.
;;;
;; Revision 2.0  1997/10/29  16:46:11  vanja
;; Derived types support added
;;
;; Revision 1.1  1996/12/05  14:27:16  marsk
;; Added ECA-rule package that can be loaded on demand.
;; Deleted event manager (rewritten in C).
;;
;;;

(load "queues.lsp") 
;;;(require 'queues "queues.lsp") 

(defvar _trig-queue_) ; queue for triggered rules

;=====================================================================================
;; check-setrelation
;;
;; event hook called just before relation updates are logged,
;; changes to monitored functions are stored into their 
;; respective delta-sets
;; arguments:
;; 'obj' is the object that is changed
;; 'arg' is the arguments of the change operation
;; 'old' and 'new' are flags that specify if the old value was changed or not
;; return value T to indicate that the event is to be logged

(defun check-setrelation (obj arg _remove _add)
  (let ((deltaset (get-delta-set (getobject obj 'predof))))
    (if deltaset
	(net-effect deltaset 
		    (cons (gettimeofday) (if (arrayp arg) 
					     (arraytolist arg) 
					   arg))
		    _add))) 
  t)					; log the event!


;=====================================================================================
;; check-createobject 
;;
;; called before database changes are written to the log,
;; changes to monitored functions are stored into their 
;; respective delta-sets
;; arguments:
;; 'ts' is the time of the createobject event
;; 'obj' is the object that is changed
;; 'arg' is the arguments of the change operation
;; 'old' and 'new' are flags that specify if the old value was changed or not
;; return value:
;; none
(defun check-createobject (obj types name  added)
  (let* ((deltaset (car (get-delta-sets (getfunctionnamed 'allobjects)))))   
    (if deltaset
	(net-effect deltaset 
		    (cons (gettimeofday) (list obj)) added)))
   t) ; log the event!

;=====================================================================================
;; check-putobject
;;
;; called before database changes are written to the log,
;; changes to monitored functions are stored into their 
;; respective delta-sets
;; arguments:
;; 'ts' is the time of the putobject event
;; 'obj' is the object that is changed
;; 'arg' is the arguments of the change operation
;; 'old' and 'new' are flags that specify if the old value was changed or not
;; return value:
;; none
(defun check-putobject (ts obj arg old new)
       (print (list 'putobject---> obj arg old new))
   (help "not implemented"))

;=====================================================================================
;; subscribe-events
;;

(defun subscribe-events()
  ;; register subsription for /setrelation event
  (subscribe-event _assertrelation_ #'check-setrelation)

  ;; register subsription for /createobject event
  (subscribe-event _createobject_ #'check-createobject)
  
  ;; register subsription for /putobject event
  ;;(subscribe-event _putobject_ #'check-putobject)
  )


;=====================================================================================
;; usubscribe-events
;;

(defun unsubscribe-events()
  ;; unregister subsription for /setrelation event
  (unsubscribe-event _assertrelation_ #'check-setrelation)

  ;; unregister subsription for /createobject event
  (unsubscribe-event _createobject_ #'check-createobject)
  
  ;; unregister subsription for /putobject event
  ;;(unsubscribe-event _putobject_ #'check-putobject)
  )

;=====================================================================================
;; net-effect
;;
;; performs the net effect of changes to stored functions after each data 
;; modification operation (add/remove/set)and the materialization of changes 
;; into delta sets.
;; arguments:
;; 'delta-set' is the delta-set to be modified
;; 'tuple' is the added/removed tuple 
;; 'adding' is true if the tuple is added, otherwise nil
;; return value:
;; none
(defun net-effect (deltaset args adding)
  (let ((delta-added (get-delta-added deltaset))
	(delta-removed (get-delta-removed deltaset))
	(pat1 (cons '* (cdr args)))    ; pattern to find previous add or remove
	rold- rold+)
    (cond (adding 
	   (maprelation delta-removed pat1 (f/l (&rest x) (setq rold- x))) 
	   (if rold- (/retractrelation delta-removed rold-);; net effect      
	     (/assertrelation delta-added args)))
	  (t 
	   (maprelation delta-added pat1 (f/l (&rest x) (setq rold+ x))) 
	   (if rold+ (/retractrelation delta-added rold+) ;net effect rold+ 
	     (/assertrelation delta-removed args))))
    (if deltaset 
	;; this line can be put in the activate-rule function when considering 
	;; nervous and strict execution of rules
	(set-node-change-flag 
	 (getobject (getobject delta-added 'complete-function) 
		    'network-node) t))))

(defun init-event-manager()
  (setq _trig-queue_ (make-queue)) 
  )


