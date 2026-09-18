;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013 Sobhan and Thanh, UDBL
;;; $RCSfile: heatmapOld.lsp,v $
;;; $Revision: 1.6 $ $Date: 2013/04/21 11:39:13 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Sliding window for the heatmap query (Q3)
;;; =============================================================
;;; $Log: heatmapOld.lsp,v $
;;; Revision 1.6  2013/04/21 11:39:13  chexu484
;;; grid settings now correct
;;;
;;; Revision 1.5  2013/04/11 17:53:23  chexu484
;;; break event taken care
;;;
;;; Revision 1.4  2013/04/11 14:00:33  chexu484
;;; bug fix for q3, back on track!
;;;
;;; Revision 1.3  2013/04/09 11:50:16  sobso953
;;; -
;;;
;;; Revision 1.2  2013/04/03 15:07:10  sobso953
;;; identical input stream for old and new q3
;;;
;;; Revision 1.1  2013/04/03 11:59:10  sobso953
;;; Backing up the reference/old implementation.
;;;
;;; Revision 1.16  2013/03/29 16:49:53  thatr500
;;; Added player running statistic
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
  (delete-btree k tbl))

(defun map-table (tbl lower upper fn) 
(map-btree tbl lower upper fn))

;;Global variables
(defglobal _basesize_ nil);;number of sub-windows.
(defglobal _hmbase_ nil);; the sub-window array

(defglobal _hm10064_ nil);; Summary/aggregate table for 64X100

(defglobal _hm5032_ nil);; Summary/aggregate table for 32X50
(defglobal _hm2516_ nil);; Summary/aggregate table for 6X25
(defglobal _hm138_  nil);; Summary/aggregate table for 8X13

(defglobal _hm_sum_(make-table));; total number of sensor readings per player

;;initializes the global variables/tables.
(defun init-hm (fn size)  
  (let ((i 0))
    (setq _basesize_ size)
    (setq _hmbase_ (make-array size))
    (while (< i size)
      (seta _hmbase_ i (make-table))
      (setq i (+ i 1))))
  (setq _hm10064_ (make-table))
  (setq _hm5032_  (make-table))
  (setq _hm2516_  (make-table))
  (setq _hm138_   (make-table)))

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

;; front end filter for q3
(foreign-lispfn q3input0 ((Stream of Numarray s)) ((Numarray))
  (let ((irptbegin))
    (mapbag s (f/l (r)
		   (let ((row (car r)))
		     (cond (irptbegin
			    (if (and (< (na-elt row 1) 0)
				     (= (x row) 0))
				(progn (setq irptbegin nil)
				       (formatl t "game interrupt end!" t))))
			   (t
			    (cond ((< (na-elt row 1) 0)
				   (if (= (x row) 1)
				       (if (not irptbegin)
					   (progn (setq irptbegin 1)
						  (formatl t "game interrupt start!" t)))))
				  (t
				   (if (and (>= (debsts row) 0)
					    ;; to be removed later, 2013.03.29
					    (not (in (floor (na-elt row 1))
						     (ballsensors)))
					    (not (in (floor (na-elt row 1))
						     (refereesensors))))
				       (foreign-result row)))))))))))

(osql "create function q3input(Stream of Numarray s) -> Stream of Numarray
       as streamof(q3input0(s));")


;;Adds a position report to proper HM-sec subwindo
;;Updates summary/aggregate table, e.g. _hm10_
(defun add-pos (fn vpos sec)
  (let* ((lts (na-elt vpos 0))  ;;latest time stamp
	 (pid (playersensor (floor (na-elt vpos 1))))
	 (cid (cell-id vpos 128 100)) ;; TODO ??? passing a grid setting
	 (hmsec (elt _hmbase_ (mod sec _basesize_)))
	 (key   (vector pid cid))
	 (value (get-table key hmsec))
	 (sum_val (get-table key _hm10064_)) ;;the value in the summary table
	 (total_sum (get-table pid _hm_sum_))) ;;the value in the summary table
    (cond (value
	   (set-table key hmsec (cons lts (+ 1 (cdr value)))))
	  (t
	   (put-table key hmsec (cons lts 1))))  ;;initialize count and time stamp
    (cond (sum_val  ;;update the summary table
	   (set-table key _hm10064_ (cons lts (+ 1 (cdr sum_val)))))
	  (t
	   (put-table key _hm10064_ (cons lts 1))))
    (cond (total_sum;;update the summary table
	   (set-table pid _hm_sum_ (+ total_sum 1)))
	  (t
	   (put-table pid _hm_sum_ 1)))))

;;slides HM base one second
;;NOTE:the output should be produced from the _hm10064_ before doing this!!
;;1-removes the contributions made by the expired sub-window
;;from the summary window
;;2-removes the expired sub-window by making a new index in it's place.
(defun slide-HM-base (fno sec)
  (let*
      ((i (mod sec _basesize_))
       (hm-sec (elt _hmbase_ i)) ;;to be removed table
       (cnt 0) sum_value totalsum_value)
    (map-table hm-sec '* '*
	       (f/l (key cell)
		    (setq cnt (cdr cell))
		    ;;find the corresponsing summary row in the summary table _hm10064_
		    (setq sum_value (get-table key _hm10064_))
		    (setq totalsum_value (get-table (elt key 0) _hm_sum_))
		    ;;if there is a row, deduct cnt from it
		    (cond (sum_value
			   (let ((newcnt (- (cdr sum_value) cnt)))
			     (if (<= newcnt 0)
				 (delete-table key _hm10064_)
			       (set-table key _hm10064_ (cons (car sum_value) newcnt))))))
			       ;;if cnt is reduced to 0 remove the row
		    (cond (totalsum_value
			   (let ((newtotal (- totalsum_value cnt)))
			     (if (<= newtotal 0)
				 (delete-table (elt key 0) _hm_sum_)
			       (set-table (elt key 0) _hm_sum_ newtotal)))))))
		               ;;if cnt is reduced to 0 remove the row
    ;;remove the expired table by replacing it:
    (seta _hmbase_ i (make-table))))

(defun report-table (table gridLx gridLy)
  (map-table table '* '*
	     (f/l (key cell)
		  (let* ((pid (elt key 0))
			 (cellid (aref key 1))
			 (ts (car cell))
			 (cnt (cdr cell))
			 (perc (* 100 (/ (* 1.0 cnt) (get-table pid _hm_sum_)))))
		    (if (> perc 0) (apply 'osql-result `(,ts ,(* gridLx gridLy) ,pid ,@(cell-pos cellid gridLx gridLy) ,perc)))))))

;;sweep the summary tables and produce the output stream
;;TBD: cellid should be mapped to cell coordinates
(defun report-HM (fno ts streamid pid cell_x1 cell_y1 cell_x2 cell_y2 perc)
  (map-table _hm10064_ '* '*
	     (f/l (key cell)
		  (let* ((pid (aref key 0))
			 (cellid (aref key 1))
			 (ts (car cell))
			 (cnt (cdr cell))
			 (perc (* 100 (/ (* 1.0 cnt) (get-table pid _hm_sum_))))
			 (key5032 (vector pid (cell-hash cellid  128 100 100 64 50)))
			 (key2516 (vector pid (cell-hash (elt key5032 1) 64 50 32 25)))
			 (key138 (vector pid (cell-hash (elt key2516 1) 32 25 16 13)))
			 (value5032 (get-table key5032 _hm5032_))
			 (value2516 (get-table key2516 _hm2516_))
			 (value138 (get-table key138 _hm138_)))
		    (cond (value5032
			   (set-table key5032 _hm5032_ (if (> ts (car value5032))
							   (cons ts (+ cnt (cdr value5032)))
							 (rplacd value5032 (+ cnt (cdr value5032))))))
			  (t
			   (put-table key5032 _hm5032_ (cons ts cnt))))
		    (cond (value2516
			   (set-table key2516 _hm2516_ (if (> ts (car value2516))
							   (cons ts (+ cnt (cdr value2516)))
							 (rplacd value2516 (+ cnt (cdr value2516))))))
			  (t
			   (put-table key2516 _hm2516_ (cons ts cnt))))
		    (cond (value138
			   (set-table key138 _hm138_ (if (> ts (car value138))
							 (cons ts (+ cnt (cdr value138)))
						       (rplacd value138 (+ cnt (cdr value138))))))
			  (t
			   (put-table key138 _hm138_ (cons ts cnt))))
		    (apply 'osql-result `(,ts 6400 ,pid ,@(cell-pos cellid 128 100) ,perc)))))
  (report-table _hm5032_ 64 50)
  (report-table _hm2516_ 32 25)
  (report-table _hm138_ 16 13)
  (setq _hm5032_ (make-table))
  (setq _hm2516_ (make-table))
  (setq _hm138_ (make-table)))