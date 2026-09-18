;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Erik Zeitler and Tore Risch, UDBL
;;; $RCSfile: visited_ht2al.lsp,v $
;;; $Revision: 1.1 $ $Date: 2007/11/15 12:25:51 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Linear Road statistics update functions
;;; =============================================================
;;; $Log: visited_ht2al.lsp,v $
;;; Revision 1.1  2007/11/15 12:25:51  torer
;;; Use of association list
;;;
;;; Revision 1.6  2007/11/13 14:19:40  torer
;;; Code cleanup
;;;
;;; Revision 1.5  2007/10/30 07:25:21  torer
;;; Avoid setq
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
create function add_stat(Vector rep, Integer mn)->Boolean
  as foreign 'add-stat';")

(defun add1 (x)(if x (1+ x) 1))

(defun add-stat (fno rep mn);; MN: minute 
  (let* ((vehicle (elt rep 2));; Vehicle ID
	 (v (elt rep 3));; speed
	 (x (elt rep 4));; freeway
	 (d (elt rep 6));; direction
	 (s (elt rep 7));; Segment
	 (cars (elt _cars_ (mod mn 2)))
	 (stat (elt _stat_ (mod mn 6)))
	 (wc (vector s x d))
	 (bck (gethash wc stat))
	 tmp)
    (setf (gethash wc cars)
	  (add1 (gethash wc cars)))
    (cond ((null bck);; First car in segment and direction
	   (setf (gethash wc stat) (list (list* vehicle 1 v))))
	  ((setq tmp (cdr (assoc vehicle bck)));; Car in table
	   (rplacd tmp (/ (+ v (* (car tmp) (cdr tmp))) 
			  (+ 1.0 (car tmp))))
	   (rplaca tmp (1+ (car tmp))))
	  (t (rplacd bck (cons (list* vehicle 1 v)(cdr bck)))))))

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
                                (bck (gethash w ct)))
                            (if bck (dolist (slot bck)
				      (setq vxsd (+ vxsd (cddr slot)))
				      (1++ nxsd)))
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
	 (bck (gethash w (elt _stat_ (mod mn 6)))))
    (if bt (dolist (slot bck)
	     (setq v (+ v (cddr slot)))
	     (1++ n)))
    (osql-result s x d mn (vector v n (sdiv v n)))))
