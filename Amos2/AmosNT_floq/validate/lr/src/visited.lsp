;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Erik Zeitler and Tore Risch, UDBL
;;; $RCSfile: visited.lsp,v $
;;; $Revision: 1.2 $ $Date: 2010/04/01 13:07:55 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Linear Road statistics update functions
;;; =============================================================
;;; $Log: visited.lsp,v $
;;; Revision 1.2  2010/04/01 13:07:55  chexu484
;;; replacing the older one
;;;
;;; Revision 1.10  2007/11/27 20:19:34  torer
;;; Minor improvement
;;;
;;; Revision 1.9  2007/11/27 20:01:57  torer
;;; 3% faster
;;;
;;; Revision 1.8  2007/11/27 19:42:55  torer
;;; Use of BTREE-COUNT
;;;
;;; Revision 1.7  2007/11/27 18:37:40  torer
;;; Correct visited!
;;;
;;; Revision 1.1  2007/10/29 20:51:32  torer
;;; Hopefully more scalable visit.lsp
;;;
;;; Revision 1.3  2007/10/24 12:04:42  torer
;;; Added comments
;;;
;;; Revision 1.2  2007/10/19 19:29:40  torer
;;; Code simplified and somewhat faster
;;;
;;; =============================================================

(defglobal _cars_;; Number of vehicles 
  (vector (make-btree) (make-btree)))

(defglobal _stat_;; To compuite avg speeed in a segment last five minutes
  (vector (make-btree) (make-btree) (make-btree) 
	  (make-btree) (make-btree) (make-btree)))

(defun sdiv (v n)
  (if (eq 0 n) 0 (/ (+ v 0.0) n)))

(osql "
create function init_stat(Integer mn)-> Boolean
  as foreign 'init-stat';")

(defun init-stat (fno mn)
  (seta _cars_  (mod mn 2) (make-btree))
  (let ((i (mod mn 6)))
    (seta _stat_ i (make-btree))))

(osql "
create function add_stat(Vector rep, Integer mn)->Boolean
  as foreign 'add-stat';")

(defun add-stat (fno rep mn);; MN: minute 
  (let ((vehicle (elt rep 2));; Vehicle ID
	(v (elt rep 3));; speed
	(x (elt rep 4));; freeway
	(d (elt rep 6));; direction
	(s (elt rep 7));; Segment
	(stat (elt _stat_ (mod mn 6))))
    (let* ((w (vector s x d vehicle)) 
	   (tmp (get-btree w stat)))
      (put-btree w (elt _cars_ (mod mn 2)) t) 
      ;; Record different cars this minute
      (cond (tmp (rplacd tmp (/ (+ v (* (car tmp) (cdr tmp))) 
				(+ 1.0 (car tmp))))
		 (rplaca tmp (1+ (car tmp))))
	    (t (put-btree w stat (cons 1 v)))))))

(osql "
create function count_visited(Integer s, Integer x, Integer d, Integer mn)
                             -> Integer
  as foreign 'count-visited';")

(defun count-visited (fno s x d mn r)
  (let ((count (count-btree (elt _cars_ (mod mn 2))
			    (vector s x d '*))))
    ;; Count number of different cars
    (osql-result s x d mn count)))

(osql "
create function avgv(Integer s, Integer x, Integer d, Integer mn)->Number
  as foreign 'avg-v';")

(defun avg-v (fno s x d mn r)
  (let ((v 0) 
	(n 0) 
	(w (vector s x d '*))
        (except (mod (+ 1 mn) 6)))
    (maparray
     _stat_ (f/l (ct i)
		 (cond ((eq i except))
		       (t (let ((vxsd 0) 
				(nxsd 0))
			    (map-btree
			     ct w w
			     (f/l (key cell)
				  (setq vxsd (+ vxsd (cdr cell)))
				  (1++ nxsd)))
			    (cond ((eq nxsd 0))
				  (t (setq v (+ v (sdiv vxsd nxsd)))
				     (1++ n))))))))
    (osql-result s x d mn (sdiv v n))))

(osql "
create function prelav(Integer s, Integer x, Integer d, Integer mn)->Vector
  as foreign 'pre-lav';")

(defun pre-lav (fno s x d mn r)
  (let ((v 0) 
	(n 0) 
	(w (vector s x d '*)))
    (map-btree (elt _stat_ (mod mn 6)) w w  
	       (f/l (key cell)
		    (setq v (+ v (cdr cell)))
		    (1++ n)))
    (osql-result s x d mn (vector v n (sdiv v n)))))
