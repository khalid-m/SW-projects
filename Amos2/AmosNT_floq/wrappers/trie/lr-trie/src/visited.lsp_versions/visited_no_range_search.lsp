;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Erik Zeitler and Tore Risch, UDBL
;;; $RCSfile: visited_no_range_search.lsp,v $
;;; $Revision: 1.1 $ $Date: 2011/08/24 05:02:20 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Linear Road statistics update functions
;;; =============================================================
;;; $Log: visited_no_range_search.lsp,v $
;;; Revision 1.1  2011/08/24 05:02:20  soba1559
;;; Adding trie based implementation of the Linear Road Benchmark
;;;
;;; Revision 1.3  2011/08/24 05:18:00  sobhanb
;;; Range-search-free version, avgv is incrementally calculated
;;;
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

(defglobal _stat_;; To compuite avg speeed of a given vehicle in a segment in last five minutes
  (vector (make-btree) (make-btree) (make-btree) 
	  (make-btree) (make-btree) (make-btree)))

(defglobal _avgv_;; maintains moving average avgv in a given dxs in last five minutes in form of sum/count
  (vector
   (MAKE-HASH-TABLE :TEST (FUNCTION EQUAL))
   (MAKE-HASH-TABLE :TEST (FUNCTION EQUAL))
   (MAKE-HASH-TABLE :TEST (FUNCTION EQUAL))
   (MAKE-HASH-TABLE :TEST (FUNCTION EQUAL))
   (MAKE-HASH-TABLE :TEST (FUNCTION EQUAL))
   (MAKE-HASH-TABLE :TEST (FUNCTION EQUAL))
   )
)  

(defun sdiv (v n)
  (if (eq 0 n) 0 (/ (+ v 0.0) n)))

(osql "
create function init_stat(Integer mn)-> Boolean
  as foreign 'init-stat';")

(defun init-stat (fno mn)
  (seta _cars_  (mod mn 2) (make-btree))
  (let ((i (mod mn 6)))
    (seta _stat_ i (make-btree))
    (seta _avgv_ i (MAKE-HASH-TABLE :TEST (FUNCTION EQUAL)))
  )
)

(osql "
create function add_stat(Vector rep, Integer mn)->Boolean
  as foreign 'add-stat';")

(defun add-stat (fno rep mn);; MN: minute 
  (let ((vehicle (elt rep 2));; Vehicle ID
	(v (elt rep 3));; speed
	(x (elt rep 4));; freeway
	(d (elt rep 6));; direction
	(s (elt rep 7));; Segment
	(stat (elt _stat_ (mod mn 6)))
	(avgv_ht (elt _avgv_ (mod mn 6)))
	)
    (let* (
	   (w (vector s x d vehicle))
	   (tmp (get-btree w stat))
	   (avgv_key (vector s x d))
	   (avgv_val (gethash avgv_key avgv_ht))
	   )
      (put-btree w (elt _cars_ (mod mn 2)) t) 
      ;; Record different cars this minute
      (cond (tmp
	     (let ((prev_v (cdr tmp)))
	     (rplacd tmp (/ (+ v (* (car tmp) (cdr tmp))) (+ 1.0 (car tmp))));;update avgv of this car in sxd
	     (rplaca tmp (1+ (car tmp)));;increment number of occurences of this car in sxd
	     ;;adjust avgv in sxd, (no increase in number of cars)
	     (rplacd avgv_val (+ (cdr  avgv_val)  (/  (- (cdr tmp) prev_v) (car avgv_val))))
	     )
	     )
	    (t;;First time this car apperas in sxd
	     (put-btree w stat (cons 1 v));;add vehicle info to sxdmn stats
	     ;;update avgv in sxd
	     (cond 
	      (avgv_val;;in case avgv fo sxd already exists 
	       ;;adjust avgv of sxdmn for new vehicle speed
	       (rplacd avgv_val (/ (+ (*(car avgv_val)(cdr avgv_val)) v ) (+ 1.0 (car avgv_val))  ))
	       ;;Increment the number of vehicles involved in this avgv	
	       (rplaca avgv_val (+ 1.0 (car avgv_val)))
	      )
	      (t;;In case  avgv fo sxd does not exists yet. (this is the first car that appears in sxdmn)
	       (setf (gethash avgv_key avgv_ht ) (cons 1.0 v))
	      )
	     )
	    )
       )
)))

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
create function count_visited_ht(Integer s, Integer x, Integer d, Integer mn)
                             -> Integer
  as foreign 'count-visited-ht';")

(defun count-visited-ht (fno s x d mn r)
  (let*
      (
       (avgv_key (vector s x d))
       (avgv_ht (elt _avgv_ (mod mn 6)))
       (count (car (gethash avgv_key avgv_ht)))
       )
    ;; Count number of different cars
    (osql-result s x d mn count)
  )
)

(osql "
create function avgv(Integer s, Integer x, Integer d, Integer mn)->Number
  as foreign 'avg-v-ht';")

(defun avg-v-ht (fno s x d mn r)
  (let (
	(v 0) 
	(n 0) 
	(w (vector s x d))
        (except (mod (+ 1 mn) 6))
	)
    (
     maparray _avgv_ (f/l (ct i)
			  (cond 
			   ((eq i except))
			   ((gethash w ct)
			    (setq v (+ v  (cdr (gethash w ct))))
			    (1++ n)
			    )
			   )
			  )
	)
    (osql-result s x d mn (sdiv v n))))

(defun avg-v-original (fno s x d mn r)
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
