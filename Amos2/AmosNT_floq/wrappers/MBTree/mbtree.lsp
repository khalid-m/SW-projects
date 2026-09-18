;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: mbtree.lsp,v $
;;; $Revision: 1.2 $ $Date: 2003/10/27 13:21:38 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Definition of the type MBTree and accompanying functionality 
;;;
;;; To do: Move all functions regarding the btree datasource here, such as
;;;        addindex0, 1, 2, whatever.
;;;              
;;; ===========================================================================

(defvar _mbtree_ (createtype 'mbtree '(datasource)))
(putobject _mbtree_ 'initializer 'mbtree-initialize)
(putobject _mbtree_ 'finalizer 'mbtree-finalize)


(defglobal _mbt_ (/createobject 'mbtree "mbtds"))

; A little 'rerouting' to hook the translator API instead of the mbtree 
; rewriter that was previously used. See mbindex.lsp line 102.
(putprop 'mbtree 'index-rewriter 'rewrite-extent)

(defun mbtree+ (mbtds)
  "The constructor for main-memory B-tree datasource objects. There is
   only one such object, which the constructor returns."
  (osql-result _mbt_))

; Redefinition of system function to hook up this particular implementation
; of MBTrees. This function originally belongs in relation.lsp
(defun addindex0 (ro pos type unique permanent)
  (let (old indx ind temp)
    (selectq unique 
	     ((t nil))
	     (amos-error "Unique tag must be T or NIL " unique)) 
    (setq indx (make-index :pos pos :owner ro :unique unique :type type))
    (buildindex ro indx)
    (cond (permanent)
	  (t (setq ind (getindex ro pos t))
	     (if ind (setq old (index-params ind)))
	     (history-add _addindex_ ro pos old (cons type unique))))
    (putobject ro 'indexes
	       (addindex1 ro (relation-indexes ro t) indx))
    (if (setq temp (getprop (index-type indx) 'index-rewriter))
	(progn
	  (add-rewriter ro (buildn (getobject ro 'width) '+) temp)
	  ; these two lines is the only change:
	  (/putobject ro 'datasource _mbt_)
	  (/putobject ro 'defaultabsorbent 'mbtree-rewrite-extent)))
    (cons ro pos)))

(defun mbtree-select-range (obj fno pos lower upper resrow)
  (map-btree
   (index-rows
    (get-mbtindex-at fno pos))
   lower upper
   (f/l (key row)
	(if (arrayp row) ;unique index
	    (osql-result fno pos lower upper row)
	  (dolist (r row) ;multiple index
	    (osql-result fno pos lower upper r)))
	t)))

 (defglobal _mbtree-select-range_ 
; function to hold generic B-tree implementation 
       (create-function mbtree-select-range 
			((function ro)	; indexed relation
			 (integer pos)	; indexed position
			 (object low)	; low range
			 (object high))	; high range
			((vector result)) ;result row
			as foreign (mbtree-select-range)))