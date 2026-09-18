;;; ============================================================
;;; AMOS
;;; 
;;; Author: (c) 1995 Martin Sköld, Magnus Werner, EDSLAB
;;; $RCSfile: queues.lsp,v $
;;; $Revision: 1.5 $ $Date: 2008/04/03 15:00:49 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description:  A queue package for AMOS lisp
;;;
;;; Requirements: 
;;; =============================================================
;;; $Log: queues.lsp,v $
;;; Revision 1.5  2008/04/03 15:00:49  torer
;;; reopt.lsp depatched
;;;
;;; Revision 1.4  2004/11/20 11:55:57  torer
;;; 1. Entire system code now verified.
;;; 2. Bugs fixed. Duplicate and obsolete code removed
;;; 3. Verification does no longer check for undefined functions to allow for
;;;    quiet function forward definitions
;;;
;;; Revision 1.3  2004/03/03 21:22:51  torer
;;; make-rule-queue removed
;;;
;;; Revision 1.2  2000/08/14 07:35:58  torer
;;; Patched rule system temporarily to be able to install system.
;;; The installer no longer tries to load non-existing files.
;;;
;;; Revision 1.1  2000/08/11 16:18:39  evato
;;; New files for ECA rule execution. Some are probably superfluous if CA rules
;;; are excluded, and then they should be removed later.
;;;
;; Revision 2.0  1997/10/29  16:47:00  vanja
;; Derived types support added
;;
;; Revision 1.1  1996/02/07  16:37:31  magwe
;; Initial check in.
;;
;;;

(provide 'queues)

(defstruct queue (head nil) (tail nil) (realisation (list '*)))

(defc 'make-queue '(lambda ()		; hide the original make-queue
		     "Return a new queue."
		     (let ((q (makefn-queue nil nil nil)))
		       (setf (queue-head q) (queue-realisation q))
		       (setf (queue-tail q) (queue-realisation q))
		       q)))

(defun empty-queue? (q)
  "Return -T- if Q is an empty queue. NIL is returned if Q is an
   non-empty queue."
  (if (not (queue-p q))
      (error "EMPTY-QUEUE? expected queue, got:" q))
  (eq (queue-head q) (queue-tail q)))

(defun queue-length (q)
  "Return the number of elements in queue Q."
  (if (not (queue-p q))
      (error "QUEUE-LENGTH expected queue, got:" q))
  (1- (length (queue-realisation q))))

(defun insert-queue (q item)
  "Insert last in queue Q the ITEM."
  (rplacd (queue-tail q) (list item))
  (setf (queue-tail q) (cdr (queue-tail q))))

(defun insert-queue-anywhere (q item fn)
  (setf (queue-realisation q) 
	(cons '* (apply fn (list item (cdr (queue-realisation q))))))
  (setf (queue-head q) (queue-realisation q))
  (setf (queue-tail q) (last (queue-realisation q)))
  q)

(defun remove-queue (q)
  "Remove and return the first element in queue Q. NIL is returned if
   Q is empty."
  (let ((item (cadr (queue-head q))))
    (if item
	(progn
	  (rplacd (queue-head q) (cddr (queue-head q)))
	  (if (not (cdr (queue-head q)))
	      (setf (queue-tail q) (queue-head q)))))
    item))

(defun delete-from-queue (q item fn)
  (setf (queue-realisation q) (remove-match item (queue-realisation q) fn))
  (setf (queue-head q) (queue-realisation q))
  (setf (queue-tail q) (last (queue-realisation q)))
  q)


;; =================================
;; remove-match
;;
;; remove any matching elements from a list
;; this is an iterative version for large lists
;; arguments:
;; 'x' is the item (or pattern) to remove
;; 'l' is the list
;; 'fn' is the optional matching function, default is equal
;; return value:
;; the list with matching elements removed
(defun remove-match (x l fn)
  "remove x from list l using matching function (with equal test as default)" 
  (let (res)
  (dolist 
   (y (reverse l))
   (cond 
    ((and fn
	  (apply fn (list x y)))
     nil)
    ((equal x y)
     nil)
    (t (setq res (cons y res)))))
  res))

; recursive remove-match
;(defun remove-match (x l fn)
;  "remove x from list l using matching function (with equal test as default)" 
;  (cond 
;    ((atom l)
;     l)
;    ((and fn
;	  (apply fn (list x (car l))))
;     (remove-match x (cdr l) fn))
;    ((equal x (car l))
;     (remove-match x (cdr l) fn))
;    (t (cons 
;          (car l)
;          (remove-match x (cdr l) fn)))))

(defmacro first-queue (q)
   `(cadr (queue-head , q)))

(defmacro more-queue (q)
  `(cadr (queue-head , q)))

(defmacro member-queue (q item)
  `(member , item (cdr (queue-realisation , q))))

(defun map-queue (fn q)
  (mapcar fn (cdr (queue-realisation q))))

