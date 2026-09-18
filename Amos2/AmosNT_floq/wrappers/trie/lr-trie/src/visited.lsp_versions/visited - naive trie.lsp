;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Erik Zeitler and Tore Risch, UDBL
;;; $RCSfile: visited\040-\040naive\040trie.lsp,v $
;;; $Revision: 1.1 $ $Date: 2011/08/24 05:02:19 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Linear Road statistics update functions
;;; =============================================================
;;; $Log: visited\040-\040naive\040trie.lsp,v $
;;; Revision 1.1  2011/08/24 05:02:19  soba1559
;;; Adding trie based implementation of the Linear Road Benchmark
;;;
;;; Revision 1.3  2011/08/24 05:21:00  sobhanb
;;; naive-trie-based version, avgv is implemented in C
;;; B-tree calls replaced with naive trie calls
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
  (vector (make-naive-trie) (make-naive-trie)))

(defglobal _stat_;; To compuite avg speeed in a segment last five minutes
  (vector (make-naive-trie) (make-naive-trie) (make-naive-trie) 
	  (make-naive-trie) (make-naive-trie) (make-naive-trie)))

(defun sdiv (v n)
  (if (eq 0 n) 0 (/ (+ v 0.0) n)))

(osql "
create function init_stat(Integer mn)-> Boolean
  as foreign 'init-stat';")

;;need to free the previous trie before creating the new one
;;this works fine, but a change must be done in foreign functions interface
;;to maintain the list of all tries created in Alisp.
(defun init-stat (fno mn)
  (let (
	(i (mod mn 2))
	(j (mod mn 6))
	)
    (free-naive-trie (AREF _cars_ i));;free the tries that were created before
    (free-naive-trie (AREF _stat_ j))
    (seta _cars_ i (make-naive-trie));create new tries
    (seta _stat_ j (make-naive-trie))
   )
)

;;trie-key (x)takes vector of numbers x (s x d vehicle) and maps it to a unique representative integer

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
    (let* ((w (trie-key (vector s x d vehicle))) 
	   (tmp (get-naive-trie w stat)))
      (put-naive-trie w (elt _cars_ (mod mn 2)) t) 
      ;; Record different cars this minute
      (cond (tmp (rplacd tmp (/ (+ v (* (car tmp) (cdr tmp)))
				(+ 1.0 (car tmp))))
		 (rplaca tmp (1+ (car tmp))))
	    (t (put-naive-trie w stat (cons 1 (+ 0.0 v))))))));; add 0.0 so that v is always a floating point number

;;trie-low-range (x) takes vector of numbers x eg. (s x d *) and returns the trie key representing the buttom of the range

;;trie-high-range (x) takes vector of numbers x eg. (s x d *) and returns the trie key representing the top of the range

(osql "
create function count_visited(Integer s, Integer x, Integer d, Integer mn)
                             -> Integer
  as foreign 'count-visited';")

(defun count-visited (fno s x d mn r)
  (let ((count (count-naive-trie (elt _cars_ (mod mn 2))
			    (trie-low-range (vector s x d '*))
			    (trie-high-range (vector s x d '*))
			    )))
    ;; Count number of different cars
    (osql-result s x d mn count)))

(osql "
create function avgv(Integer s, Integer x, Integer d, Integer mn)->Number
  as foreign 'avg-v';")

(defun avg-v (fno s x d mn r)
  ( osql-result s x d mn (naive-avg-v-c (vector s x d '*) mn  _stat_ ))
)

(osql "
create function prelav(Integer s, Integer x, Integer d, Integer mn)->Vector
  as foreign 'pre-lav';")

(defun pre-lav (fno s x d mn r)
  (let*  (
	 (v 0) 
	 (n 0) 
	 (w (vector s x d '*))
	 (low (trie-low-range w))
	 (high (trie-high-range w))
	 )
    (map-naive-trie (elt _stat_ (mod mn 6)) low high  
	       (f/l (key cell)
		    (setq v (+ v (cdr cell)))
		    (1++ n)))
    (osql-result s x d mn (vector v n (sdiv v n)))))