;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010 Thanh Truong, UDBL
;;; $RCSfile: mex-lisp-interfaces.lsp,v $
;;; $Revision: 1.4 $ $Date: 2012/01/06 13:26:53 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: MEXIMA <---> ALisp interface
;;; Main memory index operations
;;; =============================================================
;;; $Log: mex-lisp-interfaces.lsp,v $
;;; Revision 1.4  2012/01/06 13:26:53  torer
;;; Mexima enabled when environment variable MEXI set
;;;
;;; Revision 1.3  2011/12/28 09:59:27  thatr500
;;; added counte-btree
;;;
;;; Revision 1.2  2011/12/24 11:43:50  thatr500
;;; cleaned up according to the new design
;;;
;;; Revision 1.1  2011/12/02 12:45:40  thatr500
;;; MEXIMA at Lisp level
;;;
;;; =============================================================

;; TO MINIMIZE THE CHANGE, THE FOLLOWING LINES TRIES TO REDEFINE
;; EXISTING 'MBT' ACCESS METHODS (on Lisp)

;; redefine original access methods of internal MBT
(defun get-btree (k bt)  (mexima-get k bt))
(defun put-btree (k bt v) (mexima-put k bt v))
(defun delete-btree (k bt)  (mexima-delete k bt))
(defun map-btree (bt l u fn)  (mexima-range-map bt l u fn))
(defun total-map-btree (bt fn) (mexima-map bt fn))
(defun make-btree () (mexima-make "MBTREE"))

;; Overwrite count-btree used in LR
(defun count-btree (bt patt)
  (let ((newpatt (copy-array patt))
	(cnt 0))
    (map-btree bt patt newpatt (f/l (x)
				    (1++ cnt)))
    cnt))

;; suppress 'redefined warning
(dolist (x '(make-btree get-btree put-btree map-btree count-btree 
			delete-btree))
  (remprop x 'redefined))
