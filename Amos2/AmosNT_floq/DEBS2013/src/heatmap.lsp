;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013 Sobhan and Thanh, UDBL
;;; $RCSfile: heatmap.lsp,v $
;;; $Revision: 1.33 $ $Date: 2013/05/22 15:24:12 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Sliding window for the heatmap query (Q3)
;;; =============================================================
;;; $Log: heatmap.lsp,v $
;;; Revision 1.33  2013/05/22 15:24:12  torer
;;; *** empty log message ***
;;;
;;; Revision 1.32  2013/05/20 21:33:18  chexu484
;;; code clean up
;;;
;;; Revision 1.31  2013/05/20 15:17:43  torer
;;; revert to btree
;;;
;;; Revision 1.30  2013/05/20 12:59:30  torer
;;; Using hash tables instead of B-trees
;;;
;;; Revision 1.29  2013/04/22 10:54:16  chexu484
;;; close name server after the running the query
;;; streamid changed to 6400
;;;
;;; Revision 1.28  2013/04/21 19:43:02  chexu484
;;; q3 write file can be run in parallel
;;; now there are three versions of q3:
;;;
;;; q3();  LISP IMPLEMENTATION
;;; q3new(); DECLARATIVE IMPLEMENTATION
;;; q3final(); DECLARATIVE IMPLEMENTATION, WRITE FILE IN PARALLEL
;;;
;;; Revision 1.27  2013/04/21 11:39:13  chexu484
;;; grid settings now correct
;;;
;;; Revision 1.26  2013/04/18 12:42:05  torer
;;; Using B-trees instead of hash tables
;;;
;;; Revision 1.25  2013/04/18 10:18:21  chexu484
;;; complete q3
;;;
;;; Revision 1.24  2013/04/17 11:22:57  chexu484
;;; cellid, cellpos in amos
;;;
;;; Revision 1.23  2013/04/11 17:53:22  chexu484
;;; break event taken care
;;;
;;; Revision 1.22  2013/04/11 14:00:33  chexu484
;;; bug fix for q3, back on track!
;;;
;;; Revision 1.21  2013/04/09 11:50:15  sobso953
;;; -
;;;
;;; Revision 1.20  2013/04/08 10:20:18  chexu484
;;; running all fours queries at the same time by a function call
;;;
;;; Revision 1.19  2013/04/04 12:44:20  chexu484
;;; Q3 bug fix
;;;
;;; Revision 1.18  2013/04/03 15:07:10  sobso953
;;; identical input stream for old and new q3
;;;
;;; Revision 1.17  2013/04/03 12:02:32  sobso953
;;; New strategy for Q3 added:
;;; 1 second sub-window aggregation done at the q3 front end
;;; resulting in reduction of the input stream rate.
;;;
;;; Revision 1.15  2013/03/26 17:36:08  chexu484
;;; Q3 completed!
;;; Note: if we are going to print the result stream on stout, we should keep
;;; the sp logging off otherwise the result stream is streamed to log file again
;;;
;;; Revision 1.14  2013/03/26 14:25:14  chexu484
;;; Bug fix
;;;
;;; Revision 1.13  2013/03/24 21:51:32  chexu484
;;; Q2 broadcast done, check main.osql
;;;
;;; Revision 1.12  2013/03/21 14:32:07  sobso953
;;; initialization for the beginning of halves added.
;;;
;;; Revision 1.11  2013/03/20 18:08:27  sobso953
;;; q3 fully parameterized: can run all possible grid and window settings.
;;;
;;; Revision 1.10  2013/03/20 01:28:48  chexu484
;;; cellid hash function:
;;; (defun cell-hash (cellid gridLx gridLy newx newy))
;;;
;;; Revision 1.9  2013/03/19 23:36:24  chexu484
;;; q3 returns the right result stream
;;; i.e. ts, player_id, cell_x1, cell_y1, cell_x2, cell_y2, percent_time_in_time_cell
;;; fully runnable with: 64 100 grid, 10 minutes sliding window
;;; NOTE:
;;; 1. in lisp: (/ 1 2) => 0!
;;;
;;; Revision 1.8  2013/03/19 22:08:40  chexu484
;;; map cellid to (cell_x1 cell_y1 cell_x2 cell_y2)
;;;
;;; Revision 1.7  2013/03/19 18:02:22  sobso953
;;; position to cell-id maping function  cell-id () implemented
;;;
;;; Revision 1.6  2013/03/14 13:54:46  chexu484
;;; Q3 bug fix, everything works for Q3 now.
;;; Last thing for Q3: mapping between pos and cellid
;;; Cheers!
;;;
;;; Revision 1.5  2013/03/13 19:09:36  sobso953
;;; A running Q3, validation required
;;;
;;; Revision 1.4  2013/03/04 15:59:06  sobso953
;;; -Foreign functions added
;;; -Comments added
;;;
;;; Revision 1.3  2013/03/01 11:24:22  sobso953
;;; slide-HM-base [implementing the slide of the heatmap] and  report-HM [implementing the reporting of the heatmap summary] added
;;;
;;;
;;; =============================================================


;; General framework for using indexes
(defun make-table () 
  (make-btree))

(defun put-table (k tbl v) 
  (put-btree k tbl v))

(defun get-table (k tbl) 
  (get-btree k tbl))

(defun set-table (k tbl v) 
  (setf (get-btree k tbl) v))

(defun delete-table (k tbl)
  (setf (get-btree k tbl) nil))

(defun map-table (tbl lower upper fn) 
   (map-btree tbl '* '*  fn))

(defun print-table (table)
  (map-table table '* '*
	     (f/l (key cell)
		  (print `(,key ,cell)))))

;;the following assume the data is normalized into metric scale.
(defglobal _x-corner_  -52.477);; x coordinate for the top left point
(defglobal _y-corner_  33.965);; y coordinate for the top left point
(defglobal _x-l_  (* 2 52.477));; The length of the field
(defglobal _y-l_  (* 2 33.965));; The width of the field

;;first does a coordinate system transformation,
;;that is moving the origin to the top left corner
;;of the field.
;;Then the grid is formed as following:
;;for a given x and y the grid cell GX,GY is computed by 
;;a rather simple division operation.
;;Finally cell_id is computed from Gx and GY by left-to-right
;;top-to-down numbering of cells.
(defun cell-id (vpos gridLx gridLy)
  (let*(
	(x-pos (x vpos))
	(y-pos (y vpos))
	(n-x-pos (- x-pos _x-corner_));;transformation
	(n-y-pos (- _y-corner_ y-pos));;transformation(negation taken care of)
	(gx (floor (/ n-x-pos (/ _x-l_  gridLx))));;grided coordes
	(gy (floor (/ n-y-pos (/ _y-l_  gridLy)))));;grided coordes
    (+ (* gy gridLx) gx)));;cell id

(defun cell-id---+ (fno vpos gridLx gridLy r)
  (let*(
	(x-pos (x vpos))
	(y-pos (y vpos))
	(n-x-pos (- x-pos _x-corner_));;transformation
	(n-y-pos (- _y-corner_ y-pos));;transformation(negation taken care of)
	(gx (floor (/ n-x-pos (/ _x-l_  gridLx))));;grided coordes
	(gy (floor (/ n-y-pos (/ _y-l_  gridLy)))));;grided coordes
    (osql-result vpos gridLx gridLy (+ (* gy gridLx) gx))));;cell id

(osql "create function cellid(Numarray vpos, Number gridLx, Number gridLy) -> Number
       as foreign 'cell-id---+';")

(defun cell-pos (cellid gridLx gridLy)
  (let* ((x (/ _x-l_ gridLx))
	 (y (/ _y-l_ gridLy)) ;; TO DO: should x and y in this case be a integer?
	 (n-x (mod cellid gridLx))
	 (n-y (floor (/ cellid gridLx)))
	 (cell_x1 (+ _x-corner_ (* n-x x)))
	 (cell_y1 (- _y-corner_ (* (1+ n-y) y)))
	 (cell_x2 (+ cell_x1 x))
	 (cell_y2 (+ cell_y1 y)))
    (list cell_x1 cell_y1 cell_x2 cell_y2)))

(defun cell-pos---++++ (fno cellid gridLx gridLy)
  (apply 'osql-result `(,cellid ,gridLx ,gridLy ,@(cell-pos cellid gridLx gridLy))))

(osql "create function cellpos(Number cellid, Number gridLx, Number gridLy)
                             -> (Number cell_x1, Number cell_y1, Number cell_x2, Number cell_y2)
       as foreign 'cell-pos---++++';")

;; given a most grained cellid i.e. 64 * 100, hash it to 
;; the right numbering w.r.t. another gridLx, gridLy
;; note: this hash function only works when:
;; gridLx/newx == 2 && gridLy/newy == 2
;; but should be enough for this project
(defun cell-hash (cellid gridLx gridLy newx newy)
  (cond ((oddp cellid)
	 (cell-hash (1- cellid) gridLx gridLy newx newy))
	((oddp (floor (/ cellid gridLx)))
	 (cell-hash (- cellid gridLx) gridLx gridLy newx newy))
	(t
	 (+ (* (floor (/ cellid (* 2 gridLx))) newx)
	    (/ (mod cellid gridLx) 2)))))

(memo-function 'cell-hash)
(memo-function 'cell-pos)


(defglobal _dic5032_ (make-table))
(defglobal _dic2516_ (make-table))
(defglobal _dic138_  (make-table))

(defun init-dict ()
  (setq _dic5032_ (make-table))
  (setq _dic2516_ (make-table))
  (setq _dic138_  (make-table)))

(defun report-dict (hm10064 hmsum dict gridLx gridLy)
  (map-table dict '* '* (f/l (key value)
			    (let* ((pid (elt key 0))
				   (cellid (elt key 1))
				   (ts (elt value 0))
				   (cnt (elt value 1))
				   (perc (* 100 (/ (* 1.0 cnt) (get-table pid hmsum)))))
			      (apply 'osql-result `(,hm10064 ,hmsum ,ts ,(* gridLx gridLy) ,pid ,@(cell-pos cellid gridLx gridLy) ,perc))))))

(defun populate-dict (dict key value ts cnt)
  (cond (value
	 (seta value 1 (+ (elt value 1) cnt))
	 (if (> ts (elt value 0))
	     (seta value 0 ts)))
	(t
	 (put-table key dict (vector ts cnt)))))

(defun heatmap--++++++++ (fno hm10064 hmsum)
  (map-table hm10064 '* '* (f/l (key value)
				(if value  ;; in hash table, will nil entries removed?
				    (let* ((pid (elt key 0))
					   (cellid (elt key 1))
					   (ts (elt value 0))
					   (cnt (elt value 1))
					   (perc (* 100 (/ (* 1.0 cnt) (get-table pid hmsum))))
					   (key5032 (vector pid (cell-hash cellid 128 100 64 50)))
					   (key2516 (vector pid (cell-hash (elt key5032 1) 64 50 32 25)))
					   (key138 (vector pid (cell-hash (elt key2516 1) 32 25 16 13)))
					   (value5032 (get-table key5032 _dic5032_))
					   (value2516 (get-table key2516 _dic2516_))
					   (value138 (get-table key138 _dic138_)))
				      (populate-dict _dic5032_ key5032 value5032 ts cnt)
				      (populate-dict _dic2516_ key2516 value2516 ts cnt)
				      (populate-dict _dic138_ key138 value138 ts cnt)
				      (apply 'osql-result `(,hm10064 ,hmsum ,ts 6400 ,pid ,@(cell-pos cellid 128 100) ,perc))))
				t))
  (report-dict hm10064 hmsum _dic5032_ 64 50)
  (report-dict hm10064 hmsum _dic2516_ 32 25)
  (report-dict hm10064 hmsum _dic138_ 16 13)
  (init-dict))

(osql "create function heatmap_report(Dictionary hm10064, Dictionary hmsum)
                               -> Bag of (Number ts, Integer streamid, Number pid, 
                                          Number cell_x1, Number cell_y1, Number cell_x2, 
                                          Number cell_y2, Number perc)
       as foreign 'heatmap--++++++++';")