;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: mbtree_translator.lsp,v $
;;; $Revision: 1.5 $ $Date: 2003/07/01 10:16:40 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Translator part of MBTree wrapper. All functions except
;;;              mbtree-initialize and mbtree-finalize correspond to
;;;              capabilities in mbtree_capability.osql
;;;              
;;; ===========================================================================

(defvar _!=_ (getfunctionnamed 'object.object.!=->boolean))
(defvar _>_  (getfunctionnamed 'object.object.>->boolean ))
(defvar _>=_ (getfunctionnamed 'object.object.>=->boolean))
(defvar _<_  (getfunctionnamed 'object.object.<->boolean ))
(defvar _<=_ (getfunctionnamed 'object.object.<=->boolean))
(defvar _vref_ (getfunctionnamed 'vector.integer.vref->object))

(defun mbtree-initialize (ds env)
  (make-rangequery :environment env))

(defun mbtree-rewrite-extent (ds pred env ambt)
  (let ((i 0)
	(op (predicate-operator pred))
	indx
	)
    (dolist (arg (predicate-arguments pred))
      (bind arg env :datasource ds :entity (getindex op (++1 i) t)))
    (setf (rangequery-extentpred ambt) pred)
    )
  t)

(defun mbtree-rewrite-inequality (ds ineq env rq)
  "Rewrites an inquality predicate where the data source is ds and add it to 
   the rangequery if the index matches the index we are absorbing for. If 
   none is specified in the range query, set it to the current index."
  (let* ((fno       (predicate-operator ineq))
	 (left      (predicate-first ineq))
	 (right     (predicate-second ineq))
	 (chosenvar (rangequery-indexedvariable rq))
	 leftindex rightindex
	 (ok nil))
    (if (and chosenvar (or (eq left chosenvar) (eq right chosenvar)))
	(setq ok t))
    (if (not chosenvar)
	(progn (setq chosenvar (choose-indexed-variable left right ds env))
	       (setf (rangequery-indexedvariable rq) chosenvar)
	       (setq ok t)))
    (if ok
	(cond ((or (eq fno _>_) (eq fno _>=_))
	       (if (eq left chosenvar) 
		   (setf (rangequery-lowinequalitypred rq) ineq)
		 (setf (rangequery-highinequalitypred rq) ineq)))
	      ((or (eq fno _<_) (eq fno _<=_))
	       (if (eq right chosenvar) 
		   (setf (rangequery-lowinequalitypred rq) ineq)
		 (setf (rangequery-highinequalitypred rq) ineq)))
	      (t nil)))))

(defun choose-indexed-variable (left right ds env)
  (if (and (varsymbolp left) (eq (datasource left env) ds))
      (let ((index (entity left env)))
	(if index left))
    (if (and (varsymbolp right) (eq (datasource right env) ds))
	(let ((index (entity left env)))
	  (if index right)))))

(defun mbtree-finalize (ds env rq)
  (if (rangequery-closed? rq)
  (let* ((relpred (rangequery-extentpred rq))
	 (rel     (predicate-operator  relpred))
	 (relargs (predicate-arguments relpred))
	 (loineqp (rangequery-lowinequalitypred  rq))
	 (hiineqp (rangequery-highinequalitypred rq))
	 (lobound (rangequery-lower-bound rq))
	 (hibound (rangequery-upper-bound rq))
	 (indexpos(index-pos (rangequery-index rq)))
	 (indxvar (rangequery-indexedvariable rq))
	 (resvect (genvar))
	 (i 0))
    (putvar resvect env :bind '+)
    `((, _mbtree-select-range_ , rel , indexpos , lobound , hibound , resvect)
      ,@ (mapcar (f/l (arg) (list _vref_ resvect (++1 i) arg)) relargs)
      ,@ (if (rangequery-lower-is-strict rq)`((, _!=_ , indxvar , lobound)))
      ,@ (if (rangequery-upper-is-strict rq)`((, _!=_ , indxvar , hibound))))
    )))
	      
	 
