;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Erik Zeitler and Tore Risch, UDBL
;;; $RCSfile: visited_BT_Inc_del.lsp,v $
;;; $Revision: 1.1 $ $Date: 2011/08/24 05:02:20 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Linear Road statistics update functions
;;; =============================================================
;;; $Log: visited_BT_Inc_del.lsp,v $
;;; Revision 1.1  2011/08/24 05:02:20  soba1559
;;; Adding trie based implementation of the Linear Road Benchmark
;;;
;;; Revision 1.3  2011/08/24 05:18:00  sobhanb
;;; B-tree based version, with incremental deletion
;;; avgv is implemented in C
;;; Alisp B-tree calls replaced with stand alone B-tree calls
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
  (make-bt))

(defglobal _stat_;; To compuite avg speeed in a segment last five minutes
  (make-bt))

(defun sdiv (v n)
  (if (eq 0 n) 0 (/ (+ v 0.0) n)))

(osql "
create function init_stat(Integer mn)-> Boolean
  as foreign 'init-stat';")

(defun init-stat (fno mn)
(BT-bulk-del mn 5 _stat_)
(BT-bulk-del mn 1 _cars_)
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
	)
    (let( (tmp (get-BT64 s x d vehicle mn _stat_)) )
      (put-BT64 s x d vehicle mn  _cars_ t) 
      ;; Record different cars this minute
      (cond (tmp (rplacd tmp (/ (+ v (* (car tmp) (cdr tmp))) 
				(+ 1.0 (car tmp))))
		 (rplaca tmp (1+ (car tmp))) )
	    (t (put-BT64 s x d vehicle mn _stat_ (cons 1  (+ 0.0 v)  ))))))) ;;added + 0.0 so that the DT of cell is always real

(osql "
create function count_visited(Integer s, Integer x, Integer d, Integer mn)
                             -> Integer
  as foreign 'count-visited';")

(defun count-visited (fno s x d mn r)
    ;; Count number of different cars
    (osql-result s x d mn (count-bt64 _cars_ s x d mn )))

(osql "
create function avgv(Integer s, Integer x, Integer d, Integer mn)->Number
  as foreign 'avg-v';")

(defun avg-v (fno s x d mn r)
(osql-result s x d mn (BT-avg-v-c64 s x d mn _stat_)))