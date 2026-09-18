;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Tore Risch, UDBL
;;; $RCSfile: tr-rewrites.lsp,v $
;;; $Revision: 1.2 $ $Date: 2011/12/22 12:55:17 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: TR rewrite rules
;;; =============================================================
;;; $Log: tr-rewrites.lsp,v $
;;; Revision 1.2  2011/12/22 12:55:17  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.1  2007/11/16 13:52:04  torer
;;; Vector access rewrites
;;;
;;; =============================================================

(define-tr-rewriter 'vref  'vref-test 'vref-transform)

(defun vref-test (pred rest)
  "Rewrite (and ..(vector v v0 v1...)..(vref v i x)..)
            -> (vector v v0 v1 ... x ..)"
  (let ((v (second pred));; vector variable
	(pos (third pred));; position
	(val (fourth pred)));; value
    (and (numberp pos)
	 (dolist (p rest)
	   (cond ((and (listp p)
		       (eq (car p) _vector-constructor_)
		       (equal v (second p)))
		  (return (cons val (nth pos (cddr p))))))))))

(defun vref-transform (pred rest test)
  (list _=_ (car test)(cdr test)))

(defun makebag-tester (pred conj) 
  "Test in makebag in makebag"
  (let ((p1 (selectbody-pred (getselectbody (second pred)))))
    (and (consp p1) (eq (car p1)(car pred))(= (length pred) (length p1))
         (second p1))))
    
(defun makebag-rewriter (pred conj testerv)
  "Rewrite makebag in makebag into makebag"
  (list* (car pred) testerv (cddr pred)))

(define-tr-rewriter 'makebag 'makebag-tester 'makebag-rewriter)
