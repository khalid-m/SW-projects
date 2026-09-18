;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2005 Tore Risch, UDBL
;;; $RCSfile: rewriter.lsp,v $
;;; $Revision: 1.3 $ $Date: 2005/03/13 20:34:04 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: TBR rewriter for ABKW
;;; =============================================================

(defglobal _less-preds_ '(< <=))
(defglobal _greater-preds_ '(> >=))
(defglobal _compare-closed_ '((< . <=)(> . >=)))

(defun cc-key (rw)
  (third (rewrite-this rw)))

(defun cc-key-constructor (rw)
  (let ((kvar (cc-key rw)))
    (car (isome (rewrite-rest rw) 
		(f/l (p)(and (eq (car p) _vector-constructor_)
			     (eq (cadr p) kvar)))))))

(defun cc-pred-binds (var preds rw)
  (let ((bnd (rewrite-bnd rw)))
    (car (isome 
	  (rewrite-rest rw)
	  (f/l (p)(and (memq (oid-name (generic-function-of (car p))) preds)
		       (memq var (cdr p))
		       (isome (cdr p)
			      (f/l (v)
				   (and (neq v var)
					(or (memq v bnd)
                                            (osql-constantp v)))))))))))

(defun rewrite-compare-rest (cpred rw)
  (cond (cpred
         (rewrite-retract cpred rw)
	 (if (strict-comparison (car cpred))
	     (rewrite-assert (list _notequal_ (second cpred) (third cpred))
			    rw)))))

(defun normalized-comparison (v pred)
  (cond ((null pred) nil)
        ((eq v (cadr pred)) pred)
	(t (list (compare-inverse (car pred))(third pred)(second pred)))))

(defun compare-limits (rw)
  (let* ((k (cc-key rw));; key vector variable
	 (constr (cc-key-constructor rw));; Vector conctructor for key
	 (kv (third constr));; Key variable
	 (p1 (normalized-comparison 
	      kv 
	      (cc-pred-binds kv _less-preds_ rw)))
         (p2 (normalized-comparison
              kv
              (cc-pred-binds kv _greater-preds_ rw))))
    (cond ((or p1 p2)
	   (rewrite-compare-rest p1 rw)
	   (rewrite-compare-rest p2 rw)
	   (cons (third p2)(third p1))
	   ))))

(defglobal _abkw-interval-pred_
  'INTEGER.VECTOR.VECTOR.BK_GET_INTERVAL->VECTOR.VECTOR)
    
(defun rewrite-abkw (rw)
  (let ((this (rewrite-this rw))
        (lm (compare-limits rw)))
    (rewrite-assert
     (list* (getfunctionnamed _abkw-interval-pred_)
	    (second this)
	    (vector-pred-arg (car lm) rw)
	    (vector-pred-arg (cdr lm) rw)
	    (cddr this))
     rw)
    'success))

