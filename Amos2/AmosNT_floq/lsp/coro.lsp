;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009 Tore Risch, UDBL
;;; $RCSfile: coro.lsp,v $
;;; $Revision: 1.7 $ $Date: 2013/06/26 17:45:26 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: coroutine threads
;;; =============================================================
;;; $Log: coro.lsp,v $
;;; Revision 1.7  2013/06/26 17:45:26  torer
;;; Reverting (CO-SLEEP)
;;;
;;; Revision 1.5  2011/11/15 15:10:45  larme597
;;; Added some coroutine documentation.
;;;
;;; Revision 1.4  2011/08/23 12:11:00  larme597
;;; co-vresumev regression. co-terminatedv -> co-allterminatedv
;;;
;;; Revision 1.3  2009/06/16 14:58:52  larme597
;;; Brief coroutine vector documentation + lisp coroutine vector functions.
;;;
;;; Revision 1.2  2009/05/05 18:57:04  torer
;;; Better documentation
;;;
;;; Revision 1.1  2009/05/02 14:01:58  torer
;;; Coroutine documentation
;;;
;;; =============================================================

(document 
 (coroutine fn args)
 "Create a new coroutine thread where FN is the 'coroutine function', which is
   applied on ARGS when coroutine is started with CO-RESUME"
 (co-resume co)
 "Resume running coroutine CO. 
   Returns values send by next call to CO-YIELD from coroutine thread
   or the final value from the coroutine function.
   Returns *BUSY* if coroutine thread is busy" 
 (co-yield msg)
 "Suspend coroutine thread and yield MSG as value of calling CO-RESUME"
 (co-kill co)
 "Terminate coroutine CO"
 (co-terminated co)
 "Returns T is coroutine CO terminated"
 (co-inside)
 "Returns coroutine handle if running in coroutine thread or NIL otherwise"
 (co-busyp co)
 "Returns T if coroutine thread CO is busy"
 (co-sleep s)
 "Make current thread sleep for S seconds"
 (co-resumet co &optional timeout msg)
 "Like co-resume, but if the coroutine is busy, wait for timeout seconds or
   indefinitely. Return nil if timeout (seconds) occurs before able to
   return value.
   NOTE: If the coroutine leaves background within the set time, but then
   enters background again, the time spent waiting so far will be
   subtracted from the new waiting time."
 (co-resumev cov &optional timeout msg)
 "Return value from first available coroutine in array cov.
   Return nil if all coroutines are terminated.
   Return *busy* if timeout (seconds) occurs before able to return value.
   NOTE: If a coroutine leaves background within the set time, but then
   enters background again, the same timeout value will be applied."
 (co-vresumev cov &optional msg)
 "Return an array of values from coroutines in array cov.
   A coroutine that is busy will return nil. If all are busy, the function
   will wait until one coroutine returns a value.
   If all coroutines are terminated, an array containing only nil values
   is returned."
 (co-applyv fn cov)
 "Apply predicate fn on array of coroutines cov.
   If all resolve to t, return t. Otherwise return nil."
 (co-allterminatedv cov)
 "Check status of coroutines in array cov.
   If all are terminated, return t. Otherwise return nil."
 (co-anyterminatedv cov)
 "Check status of coroutines in array cov.
   If any one is terminated, return t. Otherwise return nil."
 (co-busyvp cov)
 "Check status of coroutines in array cov.
   If all are busy, return t. Otherwise return nil."
)

(defun co-applyv (fn cov)
  (catch '_stop
    (maparray cov 
	      (f/l (co i)
		   (if (not (funcall fn co))
		       (throw '_stop))
		   t))))

(defun co-allterminatedv (cov)
  (co-applyv 'co-terminated cov))

(defun co-busyvp (cov)
  (co-applyv 'co-busyp cov))
