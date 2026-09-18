;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: rangequery.lsp,v $
;;; $Revision: 1.2 $ $Date: 2004/04/28 18:18:34 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Abstract representation for a B-tree call in the making.
;;;              
;;; ===========================================================================

(defstruct rangequery
  environment
  indexedvariable
  extentpred
  lowinequalitypred
  highinequalitypred
  )

(defun pprq (rq)
  (formatl t "var:" (rangequery-indexedvariable  rq) t
	   "lo:" (rangequery-lowinequalitypred   rq) t
	   "hi:" (rangequery-highinequalitypred  rq) t))

(defun rangequery-index (rq)
  (entity (rangequery-indexedvariable rq)(rangequery-environment rq)))

(defun rangequery-lower-bound (rq)
    (let* ((lopred (rangequery-lowinequalitypred rq))
	   (lo-op  (predicate-operator lopred)))
      (cond ((or (eq lo-op _>_) (eq lo-op _>=_))
	     (predicate-argument 2 lopred))
	    ((or (eq lo-op _<_) (eq lo-op _<=_))
	     (predicate-argument 1 lopred)))))

(defun rangequery-upper-bound (rq)
    (let* ((hipred (rangequery-highinequalitypred rq))
	   (hiop   (predicate-operator hipred)))
      (cond ((or (eq hiop _>_) (eq hiop _>=_))
	     (predicate-argument 1 hipred))
	    ((or (eq hiop _<_) (eq hiop _<=_))
	     (predicate-argument 2 hipred)))))

(defun rangequery-lower-is-strict (rq)
  (let ((op (predicate-operator (rangequery-lowinequalitypred rq))))
    (or (eq op _>_) (eq op _<_))))

(defun rangequery-upper-is-strict (rq)
  (let ((op (predicate-operator (rangequery-highinequalitypred rq))))
    (or (eq op _>_) (eq op _<_))))

(defun rangequery-closed? (rq)
  (and (rangequery-highinequalitypred rq)(rangequery-lowinequalitypred rq)))