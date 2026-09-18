;;; ============================================================
;;; AMOS
;;; 
;;; Author: (c) 1995 Salah-Eddine Machani, EDSLAB
;;; $RCSfile: rule_processor.lsp,v $
;;; $Revision: 1.5 $ $Date: 2004/11/20 11:55:57 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description:
;;;     implemets the rule processing algorithm and all the functions
;;;     needed to find out the triggered rules, store them in a sorted
;;;     queue, evaluate the conditions and execute the actions
;;; Requirements: 
;;; =============================================================
;;; $Log: rule_processor.lsp,v $
;;; Revision 1.5  2004/11/20 11:55:57  torer
;;; 1. Entire system code now verified.
;;; 2. Bugs fixed. Duplicate and obsolete code removed
;;; 3. Verification does no longer check for undefined functions to allow for
;;;    quiet function forward definitions
;;;
;;; Revision 1.4  2004/03/06 07:50:43  torer
;;; 1. for each now iterates over copy of selection to not bite its tail
;;; 2. Cleaned up parsed AmosQL query statement compiler (fncall.lsp)
;;;
;;; Revision 1.3  2001/12/27 16:24:57  torer
;;; 1. Modified ECA rules so that the net effect of events now computed correctly
;;; 2. Fixed severe memory leak in logger
;;;
;;; Revision 1.2  2000/10/24 12:44:16  torer
;;; ECA rules OK
;;;
;;; Revision 1.1  2000/08/19 07:32:29  evato
;;; These files are also needed by the rule system.
;;;
;; Revision 2.0  1997/10/29  16:47:10  vanja
;; Derived types support added
;;
;; Revision 1.1  1996/12/05  14:27:27  marsk
;; Added ECA-rule package that can be loaded on demand.
;; Deleted event manager (rewritten in C).
;;
;;;

(defvar *ruletracelevel* 0)

(defmacro trace-trigger (level rule &optional args)
   "To trace rule execution phases"
   `(if (>= *ruletracelevel* , level) 
       (formatl t , (selectq level
                      (1 "  Triggering rule ")
                      (2 " Checking rule condition")
                      (3 "Checking events of rule ")
                      (error "Unsupported trace triggering level" level))
         , rule ,@ (if args (list " for " args)) t)))

;=====================================================================================
;; check-eca
;;
;; starts the check phase by propagating all changes through
;; the network until no more changes are detected
;; arguments: 
;;  c: context (not handled in the current implementation)
;; return value:
;; none
(defun check-eca (c)
   (let ((network the-deferred-network)
         (limit *max-trigger*))
      (propagate network)	  
      
      (loop 
        (cond ((AND (null (get-rules-to-check network)) (empty-queue? _trig-queue_)) 
               (clear-delta-sets network) 
               (clear-queue _trig-queue_)
               (clear-top-nodes network t t)
               (return nil)))  
        
        (check-rules  (get-rules-to-check network) limit)
        ;(queue-content _trig-queue_)
        (trigger-rules)
        (clear-top-nodes network t nil)
        (propagate network))))

;=====================================================================================
;; check-rules
;;
;; executes the event functions of the all the rules marked as 
;; triggered in the propagation network.
;;Arguments:
;;rules: the rules to be checked for execution 
;;limit: the maximum number of iterations a rule can be processed
;;Return:

(defun check-rules (rules limit)
  (mapc 
   (f/l (r-a) 
	(let* ((rule (first r-a))
	       (activations (second r-a))
	       (counter (third r-a))
	       (eventfn (getobject rule 'event-function))
	       args)
          (if (> counter limit)
	      (AMOS-Warning "abnormal termination due to an infinite rule processing loop")
	    (mapc (f/l (activa)
		       (let* ((argl (first activa))
			      (prio (third activa))
			      args)
			 (trace-trigger 3 rule argl)
			 (mapfunction-dist 
			  eventfn argl t
			  (f/l (amos_res)
			       (if amos_res (setq args (cons (append argl amos_res) args)))))
			 (if args (mark-triggered rule args prio))))
		  activations))))			     
   rules))

;=====================================================================================
;; get-rules-to-check
;; 
;;returns all the rules candidates to be triggered in the propagation network
;;Arguments:
;; net: the network to be checked(the-deferred-network)
;;Return:
;;list of the rules to be checked
(defun get-rules-to-check (net)
  (if (getallactivatedrules)
      (let* ((trigfn-nodes (get-top-nodes net))
	     (rule-activations 
	      (remove nil
		      (mapcar 
		       (f/l (n)
			    (let* ((n-ext (externalize-node n)))
			      (if (get-node-change-flag n-ext) 
				  (append 
				   (list 
				    (getobject (car (get-node-activation n-ext)) 'rule))
				   (cdr (get-node-activation n-ext))
				   (list (get-node-count n-ext))))))
			      trigfn-nodes))))
	rule-activations)))
;=====================================================================================
;; trigger-rules
;; 
;; executes the triggered rules in high priorities order,
;; executes the condition function first then the action procedure if a value 
;; is returned from the condition function
;; arguments:
;;   none
;; return value:
;;  none


(defun trigger-rules ()
   "Pick up the next rule from trigger queue and test the condition function.
Then apply the action function on each instance of its result"
   (let* ((trigger (get-trigger)))
      (if trigger
         (funcall  
           (f/l (trig)
             (let* ((rule (first trig))
                    (args-list (second trig))  
                    (condfn (getobject rule 'condition-function))
                    (actproc (getobject rule 'action-procedure)))
                (assert actproc "No action procedure in trigger")
                (cond (args-list ; action with iteration over quantified variable
                        (dolist (args args-list)
                           (cond (condfn ; eca
                                   (trace-trigger 2 rule args) 
                                   (mapfunctionres condfn  args nil
                                     (f/l (amos_res) 
                                       (cond (amos_res 
                                               (trace-trigger 1 rule amos_res)
                                               (mapfunctionres actproc amos_res nil nil))))))
                                 (t (trace-trigger 1 rule args) ; ea
                                   (mapfunctionres actproc args nil nil)))))
                      (condfn ; non-iterated ECA
                        (trace-trigger 2 rule) 
                        (mapfunctionres condfn nil nil
                          (f/l (amos_res) 
                            (cond (amos_res 
                                    (trace-trigger 1 rule amos_res)
                                    (mapfunctionres actproc 'amos_res nil nil))))))
                      (t (trace-trigger 1 rule) ; non-iterated EA
                        (mapfunctionres actproc  nil nil nil))
                      )))
           trigger))))

;=====================================================================================
;; mark-triggered
;;
;; marks a rule as triggered by inserting it in the triggered rules queue
;; arguments:
;;   rule: the triggered rule
;;   argl: tha arguments values to be passed to the condition function
;;   prio: priority of the rule
;; return value:
;;   none
;;
(defun mark-triggered (rule argl prio)  
 (let ((trigger (list rule argl prio)))
    	(insert-trigger-in-queue trigger)))


;=====================================================================================
;; get-trigger
;;
;; removes and returns the first trigger in the queue
;; arguments: none
;; return: 
;;list of triggers

(defun get-trigger ()
    (remove-queue _trig-queue_))

;=====================================================================================
;; insert-trigger-in-queue
;;
;; inserts a rule and its tirgger in the triggered rules queue 
;;Arguments:
;;trigger
;;Return:
;;none
(defun insert-trigger-in-queue (trigger)
   (insert-queue-anywhere _trig-queue_ trigger #'(lambda (e lst) (sort (cons e lst) ; SLOW! (TR)
				#'(lambda (x y) (>= (car (last x)) (car (last y))))))))


;=====================================================================================
;; remove-trigger-from-queue
;;
;; removes the specified trigger from the triggered rules queue 
;;Arguments:
;;trigger
;;Return
;;none
(defun remove-trigger-from-queue (trigger)
    (delete-from-queue _trig-queue_ trigger nil))
 
 

;=====================================================================================
;; sort-triggered-rules
;;
;;
;(defun sort-triggered-rules () 
;     (sort (get-triggered-rules) 
;	         #'(lambda (r1 r2) (> (car (last (getobject r1 'trigger)))
;                                      (car (last (getobject r1 'trigger)))))))
;
;=====================================================================================
;;queue-content
;;
;;prints out the content of a queue
;; Arguments
;;queue
;;Return:
(defun queue-content (queue)
   (progn (formatl t "queue-content:" t)
   (map-queue (f/l (x) (print x)) queue)))


;;===================================================================================
;;clear-queue
;;
;;clears the content of a queue
;;Arguments
;;queue
;;Return:
;;none
(defun clear-queue (queue)
   (do () ((empty-queue? queue)) (remove-queue queue)))

;=====================================================================================
;; getallactivatedrules
;;
;;returns all the activated rules in the transaction
;;Arguments:
;;Return:
;;list of all the activated rules and their activations
(defun getallactivatedrules ()
   (let (res)
      (mapextent _rule_
        (q/l (r)
          (if (getobject r 'activations)(setq res (cons r res)))))
      res))














