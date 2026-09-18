;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Erik Zeitler, UDBL
;;; $RCSfile: visited_sht2bt.lsp,v $
;;; $Revision: 1.1 $ $Date: 2007/10/30 07:29:09 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Linear Road statistics update functions
;;; =============================================================
;;; $Log: visited_sht2bt.lsp,v $
;;; Revision 1.1  2007/10/30 07:29:09  torer
;;; Wrapper around add_stat to spread arguments
;;;
;;; Revision 1.4  2007/10/29 20:51:32  torer
;;; Hopefully more scalable visit.lsp
;;;
;;; Revision 1.3  2007/10/24 12:04:42  torer
;;; Added comments
;;;
;;; Revision 1.2  2007/10/19 19:29:40  torer
;;; Code simplified and somewhat faster
;;;
;;; =============================================================

(defun new-ht ()(make-hash-table :test 'equal))

(defglobal _cars_;; Number of vehicles 
  (vector (new-ht) (new-ht)))

(defglobal _stat_;; To compuite avg speeed in a segment last five minutes
  (vector (new-ht) (new-ht) (new-ht) 
	  (new-ht) (new-ht) (new-ht)))

(defun sdiv (v n)
  (if (eq 0 n) 0 (/ (+ v 0.0) n)))

(osql "
create function init_stat(Integer mn)-> Boolean
  as foreign 'init-stat';")

(defun init-stat (fno mn)
  (seta _cars_  (mod mn 2) (clrhash (elt _cars_ (mod mn 2))))
  (let ((i (mod mn 6)))
    (seta _stat_ i (clrhash (elt _stat_ (mod mn 6))))))

(osql "
create function add_stat0(Number vehicle, Number v, Number x, 
                          Number d, Number s, Number mn)->Boolean
  as foreign 'add-stat0';

create function vi(Vector v, Integer i)->Number
  as select v[i]; /* Casting function */

create function add_stat(Vector rep, Number mn)->Boolean
  /* Temporary wrapper function before spreading arguments everywhere! */
  as select add_stat0(vi(rep,2),vi(rep,3),vi(rep,4),vi(rep,6),vi(rep,7),mn);
")

(defun add1 (x)(if x (1+ x) 1))

(defun add-stat0 (fno vehicle v x d s mn);; MN: minute 
  (let ((cars (elt _cars_ (mod mn 2)))
	(stat (elt _stat_ (mod mn 6)))
        wc bt tmp)
    (setq wc (vector s x d))
    (setq bt (gethash wc stat))
    (setf (gethash wc cars)
	  (add1 (gethash wc cars)))
    (cond ((null bt);; First car in segment and direction
	   (setq bt (make-btree))
	   (setf (get-btree vehicle bt) (cons 1 v))
	   (setf (gethash wc stat) bt))
	  ((setq tmp (get-btree vehicle bt));; Car in table
	   (rplacd tmp (/ (+ v (* (car tmp) (cdr tmp))) 
			  (+ 1.0 (car tmp))))
	   (rplaca tmp (1+ (car tmp))))
	  (t (setf (get-btree vehicle bt)(cons 1 v))))))

(osql "
create function count_visited(Integer s, Integer x, Integer d, Integer mn)
                             -> Integer
  as foreign 'count-visited';")

(defun count-visited (fno s x d mn r)
  (osql-result s x d mn (or (gethash (vector s x d) 
				     (elt _cars_ (mod mn 2)))
			    0)))

(osql "
create function avgv(Integer s, Integer x, Integer d, Integer mn)->Number
  as foreign 'avg-v';")

(defun avg-v (fno s x d mn r)
  (let ((v 0) 
	(n 0) 
	(w (vector s x d)))
    (maparray
     _stat_ (f/l (ct i)
		 (cond ((eq i (mod (+ 1 mn) 6)))
		       (t (let ((vxsd 0) 
				(nxsd 0)
                                (bt (gethash w ct)))
                            (if bt (map-btree bt '* '* 
				    (f/l (vehicle stat)
					 (setq vxsd (+ vxsd (cdr stat)))
					 (1++ nxsd))))
			    (cond ((= nxsd 0))
				  (t (setq v (+ v (sdiv vxsd nxsd)))
				     (1++ n))))))))
    (osql-result s x d mn (sdiv v n))))

(osql "
create function prelav(Integer s, Integer x, Integer d, Integer mn)->Vector
  as foreign 'pre-lav';")

(defun pre-lav (fno s x d mn r)
  (let* ((v 0) 
	 (n 0) 
	 (w (vector s x d))
	 (bt (gethash w (elt _stat_ (mod mn 6)))))
    (if bt (map-btree bt '* '* (f/l (vehicle stat) 
				    (setq v (+ v (cdr stat)))
				    (1++ n))))
    (osql-result s x d mn (vector v n (sdiv v n)))))
