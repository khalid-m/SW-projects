;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Cheng Xu, UDBL
;;; $RCSfile: window.lsp,v $
;;; $Revision: 1.29 $ $Date: 2013/11/16 13:40:01 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: new data type window
;;; =============================================================
;;; $Log: window.lsp,v $
;;; Revision 1.29  2013/11/16 13:40:01  chexu484
;;; validation functions returns nil when everything is right
;;; function to construct alert messages
;;;
;;; Revision 1.28  2013/11/10 21:42:05  chexu484
;;; partition window
;;;
;;; Revision 1.27  2013/10/31 12:32:43  chexu484
;;; partition window
;;;
;;; Revision 1.26  2013/10/29 15:32:24  chexu484
;;; *** empty log message ***
;;;
;;; Revision 1.25  2013/10/29 15:22:48  chexu484
;;; copy header when emitting windows
;;; this allows you to create window of window (arbitrary levels of windows)
;;;
;;; Revision 1.24  2013/07/10 09:23:55  chexu484
;;; bug fix
;;;
;;; Revision 1.23  2013/04/17 13:55:13  chexu484
;;; assignfunction instead of getfunction-nocheck
;;;
;;; Revision 1.22  2013/04/08 15:02:18  chexu484
;;; jumping predicate included in time window
;;;
;;; Revision 1.21  2013/03/29 00:46:52  chexu484
;;; now possible to return intermediate window
;;; extra argument for both count and time based window operator
;;;
;;; Revision 1.20  2013/03/28 19:37:48  chexu484
;;; init bug fix
;;; NOTE: result of aggregation doesn't support bag values yet.
;;;
;;; Revision 1.19  2013/01/08 12:49:45  chexu484
;;; model and validate returns stream of vector instead of stream of qua-tuple
;;;
;;; Revision 1.18  2013/01/04 13:43:03  chexu484
;;; *** empty log message ***
;;;
;;; Revision 1.17  2012/10/11 20:36:59  chexu484
;;; comment out debugging code
;;;
;;; Revision 1.16  2012/08/22 15:06:18  chexu484
;;; *** empty log message ***
;;;
;;; Revision 1.15  2012/08/22 14:41:37  chexu484
;;; it's now possible to register aggregation function(s) on window at run time
;;; using three (user defined) functions: init, add, remove
;;;
;;; Revision 1.14  2012/08/01 17:02:00  chexu484
;;; given two windows:
;;; linear_interpolation
;;; interpolates the windows so that they are compariable (e.g. distance)
;;; note:
;;; 1. two windows of key value paris
;;; 2. only XY two dimension linear interpolation, e.g. (time, value)
;;;
;;; Revision 1.13  2012/07/30 22:15:29  chexu484
;;; moving average for stream or window (sub-stream)
;;;
;;; Revision 1.12  2012/05/28 15:08:12  chexu484
;;; avoiding type checking!!! hooray...
;;;
;;; Revision 1.11  2012/05/22 11:51:00  chexu484
;;; map_window(Window w, Function mapper) -> Window
;;; sum_window(Bag of Window, Function addfn) -> Window
;;;
;;; Revision 1.10  2012/04/19 17:17:49  chexu484
;;; 1. renaming
;;; 2. when event meets stop predicate, check start for next window
;;;
;;; Revision 1.9  2012/02/29 15:28:22  chexu484
;;; possible to compute window statistics incrementally
;;; scales much better
;;;
;;; Revision 1.8  2012/02/15 14:47:08  chexu484
;;; namespace for functions svali:
;;;
;;; Revision 1.7  2012/01/16 13:29:48  chexu484
;;; stopfn in predicate-based window takes both the event and
;;; the result of startfn as arguments
;;;
;;; Revision 1.6  2012/01/03 16:22:23  chexu484
;;; 1. added new validation function
;;;    STREAM.FUNCTION.FUNCTION.FUNCTION.INTEGER.FUNCTION.NUMBER.RECORD_N_VALIDATE
;;; 							->STREAM-(INTEGER,VECTOR)
;;; 2. added regression test for data type window
;;; 3. added regression test for validation functions
;;;
;;; Revision 1.5  2011/11/30 21:29:17  chexu484
;;; predicate based window added into svali
;;;
;;;
;;; =============================================================

;;;;;;;;;;;;;;;;;;;;;;;;;new type WINDOW;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; create a new type WINDOW in Amos II
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defglobal _window_)

(if (not (gettypenamed 'window t))
    (setq _window_ (createliteraltype 'window (list _collection_) 'swin)))

(defun windowp (w)
  (= _window_ (arg-type w)))


;; note: pwindowize doesn't have aggregation and intermediate window 2013.03.28
(foreign-lispfn
 pwindowize0 ((Stream s) (Function start) (Function stop)) ((Window))
 (let ((tl (tconc)) (size 0) startp sres)
   (mapbag s
	   (f/l (event)
		(cond (startp
		       ;;(if (>= (elt (car event) 0) 1001) (help 1))
		       ;; check if it is the end of window creation
		       (if (testfunction stop (cons sres event))
			   (progn (foreign-result (make-swin 'list size size tl))
				  (if (caar (getfunction-nocheck start event))
				      (progn (setq sres (car event))
					     (setq tl (tconc (tconc) sres))
					     (setq size 1))
				    (progn (setq startp nil)
					   (setq sres nil)
					   (setq size 0)
					   (setq tl (tconc)))))
			 (progn (tconc tl (car event))
				(1++ size))))
		      (t
		       (if (testfunction start event)
			   (progn (setq startp T)
				  (setq sres (car event))
				  (tconc tl sres)
				  (1++ size)))))))))

(osql "create function pwindowize(Stream s, Function start, Function stop)
                                                               -> Stream of Window
        as streamof(pwindowize0(s, start, stop));")

(defun agg-init (agglist)
  (mapc (f/l (e)
	     (let* ((descr (cadr e))
		    (initfn (elt descr 0))
		    (v (elt descr 3)) res)
	       (assignfunction initfn nil '(res))
	       (seta descr 3 res)))
	agglist))

(defun agg-add-tuple (agglist event)
  (mapc (f/l (e)
	     (let* ((descr (cadr e))
		    (addfn (elt descr 1))
		    (v (elt descr 3)) res)
	       (assignfunction addfn (list v event) '(res))
	       (if res (seta descr 3 res))))
	agglist))

(defun agg-remove-tuple (agglist event)
  (mapc (f/l (e)
	     (let* ((descr (cadr e))
		    (removefn (elt descr 2))
		    (v (elt descr 3)) res)
	       (assignfunction removefn (list v event) '(res))
	       (if res (seta descr 3 res))))
	agglist))

(defun re-register (w agglist)
  (mapc (f/l (e)
	     (let* ((name (car e))
		    (descr (cadr e))
		    (initfn (elt descr 0))
		    (addfn (elt descr 1))
		    (removefn (elt descr 2)) v)
	       (assignfunction initfn nil '(v))
	       (window-addagg w (list name (vector initfn addfn removefn v)))))
	agglist))

(foreign-lispfn
 partwindowize0 ((Stream s) (Function partVar)) ((Window))
 (let* ((tl (tconc))
    (tupleCounter 0)
    prev curv)
   (mapbag s
       (f/l (event)
        (assignfunction partVar event '(curv))
        (cond ((or (= curv prev) (not curv))  ;; the same
               (tconc tl (car event))
               (1++ tupleCounter))
              (t
	       (if (> tupleCounter 0)
		   (foreign-result (make-swin 'list tupleCounter 0 tl)))
               (setq tl (tconc))
               (tconc tl (car event))
               (setq tupleCounter 1)))
	(if curv (setq prev curv))))))

(osql "create function partwindowize(Stream s, Function partVar) -> Stream of Window
        as streamof(partwindowize0(s, partVar));")

;; count window
(foreign-lispfn
 cwindowize0 ((Stream s) (Integer size) (Integer slide) (Integer repfreq)) ((Window))
 (let* ((tl (tconc)) (counter 0)
	(res (make-swin 'list 0 0 tl))
	(agglist (window-getallaggs res))
	(repcount 0))
   (mapbag s
	   (f/l (event)
		(tconc tl (car event))
		(if agglist (agg-add-tuple agglist (car event)))

		;; if it it time to emit micro-window
		;; but not the complete window
		(cond ((and (if (= repfreq (1++ repcount))
				(setq repcount 0))
			    (> size (1+ counter)))
		       (swin-setter res (1+ counter) (1+ counter)
				    (cons (car tl) (cdr tl)))
		       (foreign-result (copy-swin res))
		       (setq agglist (window-getallaggs res))))

		(if (<= size (1++ counter))
		    (progn
		      (swin-setter res size size (cons (car tl) (cdr tl)))
		      (foreign-result (copy-swin res))
		      ;; every time you emit the window
		      ;; do an update on the agglist
		      (setq agglist (window-getallaggs res))
		      (cond ((<= size slide)
			     (setq tl (tconc))
			     (if agglist (agg-init agglist)))
			    (t			     
			     (dotimes (i slide)
			       (if agglist (agg-remove-tuple agglist (caar tl)))
			       (setf (car tl) (cdr (car tl))))))
		      (setq counter (- size slide))))))))

(osql "create function cwindowize(Stream s, Integer size, Integer slide, Integer repfreq) -> Stream of Window
        as streamof(cwindowize0(s, size, slide, repfreq));")

(osql "create function cwindowize(Stream s, Integer size, Integer slide) -> Stream of Window
        as streamof(cwindowize0(s, size, slide, -1));")

(foreign-lispfn
 twindowize0 ((Stream s) (Function timefn) (Number size) (Number slide)
              (Number repfreq) (Function jpstartfn) (Function jpendfn)) ((Window))
 (let* ((tl (tconc)) starttime
	(res (make-swin 'list 0 0 tl))
	(logicounter 0) (tuplecounter 0)
	(pretime 0)
	(agglist (window-getallaggs res))
	(repcounter 0) (jump 0))
   (mapbag s
	   (f/l (event)
		(cond ((= jump 1)  ;; during the jump?
		       (if (testfunction jpendfn event)  ;; a jump stop event
			   (setq jump 0)))
		      (t
		       (cond ((testfunction jpstartfn event)
			      (if starttime
				  (progn (swin-setter res tuplecounter logicounter (cons (car tl) (cdr tl)))
					 (swin-setts res pretime)
					 (foreign-result (copy-swin res))
					 (setq agglist (window-getallaggs res))))
			      (print "window jump point!")
			      (setq jump 1)
			      (setq tl (tconc))
			      (setq starttime nil)
			      (setq res (make-swin 'list 0 0 tl))
			      (setq logicounter 0)
			      (setq tuplecounter 0)
			      (setq pretime 0)
			      (re-register res agglist)
			      (setq agglist (window-getallaggs res))
			      (setq repcounter 0))
			     (t
			      (let (time)
				(assignfunction timefn event '(time))
				(if (not starttime) (progn (setq starttime time)
							   (setq repcounter (+ starttime repfreq))))
				(cond ((< (- time starttime) size)  ;; not enough
				       
				       ;; before add current event to window
				       ;; check if we need to emit the micro-window
				       (cond ((and (>= time repcounter)  ;; time to emit the micro-window
						   (> repfreq 0))
					      (swin-setter res tuplecounter logicounter (cons (car tl) (cdr tl)))
					      (swin-setts res pretime)
					      (foreign-result (copy-swin res))
					      (setq agglist (window-getallaggs res))
					      (setq repcounter (+ repcounter
								  (* repfreq (1+ (floor (/ (- time repcounter) repfreq))))))))
				       
				       (tconc tl (car event))
				       (1++ tuplecounter)
				       (setq logicounter (- time starttime))
				       (if agglist (agg-add-tuple agglist (car event))))
				      (t
				       (swin-setter res tuplecounter logicounter (cons (car tl) (cdr tl)))
				       (swin-setts res pretime)
				       (foreign-result (copy-swin res))
				       ;; every time you emit a new window
				       ;; do an update on the agglist
				       (setq agglist (window-getallaggs res))
				       (cond ((or (= size slide) (< logicounter slide)) ;; NOTE: not <=
					      ;; if it is a tumpling window
					      ;; OR the window size is not large enough
					      (setq tl (tconc))
					      (setq starttime time)
					      (setq tuplecounter 0)
					      (agg-init agglist))
					     (t
					      (let (expired expiredts)
						(while (< (- (setq expiredts
								   (caar (getfunction-nocheck
									  timefn
									  (list (setq expired (caar tl))))))
							     starttime)
							  slide)
						  (1-- tuplecounter)
						  (agg-remove-tuple agglist expired)
						  (setf (car tl) (cdr (car tl))))
						(setq starttime expiredts))))
				       
				       ;; if this is also the point to emit the micro-window
				       ;; to avoid emit twice, we only update repcounter
				       (cond ((and (>= time repcounter)
						   (> repfreq 0))
					      (setq repcounter (+ repcounter
								  (* repfreq (1+ (floor (/ (- time repcounter) repfreq))))))))
				       
				       (tconc tl (car event))
				       (1++ tuplecounter)
				       (setq logicounter (- time starttime))
				       (if agglist (agg-add-tuple agglist (car event)))))
				(setq pretime time))))))))))

   ;;(swin-setter res tuplecounter logicounter tl)
   ;;(swin-setts res pretime)
   ;;(foreign-result res))

(osql "create function twindowize(Stream s, Function timefn, Number size, Number slide,
                                  Number repfreq, Function jpstartfn, Function jpendfn)
                                                                         -> Stream of Window
        as streamof(twindowize0(s, timefn, size, slide, repfreq, jpstartfn, jpendfn));")

(osql "create function truefn() -> Boolean as true;")
(osql "create function falsefn() -> Boolean as nil;")

(osql "create function twindowize(Stream s, Function timefn, Number size, Number slide)
                                                                         -> Stream of Window
        as streamof(twindowize0(s, timefn, size, slide, -1, #'falsefn', #'truefn'));")

(osql "create function twindowize(Stream s, Function timefn, Number size, Number slide, Number repfreq)
                                                                         -> Stream of Window
        as streamof(twindowize0(s, timefn, size, slide, repfreq, #'falsefn', #'truefn'));")

(foreign-lispfn ts ((Window w)) ((Number))
  (let ((_ts (swin-getts w)))
    (foreign-result (ts _ts))))

(foreign-lispfn window2vector ((Window w)) ((Vector))
  (foreign-result (window2vector w)))  

(defun setwindowagg-resulttypes (fno args)
  (let ((addfn (fourth args)))
    (if addfn (get-resolvent-restypes addfn))))

(set-resulttypesfn
 (foreign-lispfn window_agg((Window w) (Charstring name)
			    (Function init) (Function addfn) (Function removefn))
		           ((Object))
   (let ((aggdescr (window-getagg w name)) v)
     (cond (aggdescr
	    (foreign-result (elt (cadr aggdescr) 3)))
	   (t
	    (let (v)
	      (assignfunction init nil '(v))
	      ;;(setq v (caar (getfunction-nocheck init '())))
	      (window-addagg w (list name (vector init addfn removefn v)))
	      (let* ((descr (cadr (window-getagg w name))))
		(mapc (f/l (e)
			   (let* ((itm (elt descr 3)) res)
			     (assignfunction addfn (list itm e) '(res))
			     (if res (seta descr 3 res))))
		  (car (window2list w)))
		(foreign-result (elt descr 3))))))))
 'setwindowagg-resulttypes)

(defun window-plus (tconc1 tconc2 plusfn)
  (let ((tl (tconc)))
    (mapc (f/l (e1 e2) (tconc tl (caar (getfunction-nocheck plusfn `(,e1 ,e2)))))
	  (car tconc1) (car tconc2))
    tl))

(defun plus---+ (fno window1 window2 plusfn)
  (let* ((tconc1 (window2list window1))
	 (tconc2 (window2list window2))
	 (res (window-plus tconc1 tconc2 plusfn))
	 (ressize (length (car res))))
    (osql-result window1 window2 plusfn (make-swin 'list ressize ressize res))))

(osql "create function plus(Window w1, Window w2, Function plusfn) -> Window
       as foreign 'plus---+';")

(defun copy-tconc (tl)
  (let ((res (tconc)))
    (mapc (f/l (e) (tconc res e)) (car tl))
    res)) 

;; copy the tconc everytime! lead to performance problem?
(defun sum-window--+ (fno bw plusfn)
  (let ((firsttime T)
	res)
    (mapbag bw (f/l (w)
		    (cond (firsttime
			   (setq res (copy-tconc (window2list (car w))))
			   (setq firsttime nil))
			  (t
			   (setq res (window-plus res (window2list (car w)) plusfn))))))
    (let* ((hd (car res))
	   (size (length hd)))
      (osql-result bw plusfn (make-swin 'list size size res)))))

(osql "create function sum_window(Bag of Window bw, Function plusfn)
                                              -> Window as foreign 'sum-window--+';")

(osql "create function in(Window w) -> Bag of Object as foreign 'inwindowbf';")

(osql "create function window_count(Window w) -> Integer as foreign 'windowcountbf';")

(defun set-sumtype (fno args)
  (default-type-parameters (arg-type (car args))))

(defun map-window--+ (fno w mapfn argv)
  (let* ((res (tconc))
	 (hl (car (window2list w)))
	 (size (length hl))
	 (argl (arraytolist argv)))
    (mapc (f/l (e)
	       (tconc res (caar (getfunction-nocheck mapfn `(,e ,@argl)))))
	  hl)
    (osql-result w mapfn argv (make-swin 'list size size res))))     

(osql "create function map_window(Window w, Function mapfn, Vector argv)
                                            -> Window as foreign 'map-window--+';")

(osql "create function map_window(Window w, Function mapfn) -> Window as map_window(w, mapfn, {});")


;; stream as input since SMA requires order
(defun simple-move-average-s--+ (fno s size slide)
  "implements the simple moving average for a stream s"
  (let ((counter 0) (sub (tconc))
	(latest 0) (expired 0) (avg 0))
    (if (> slide size) (error "sub slide shouldn't be greater than sub size"))
    (mapbag s
	    (f/l (event)
		 (let ((e (car event)))
		   (setq latest (+ latest e))
		   (setq sub (tconc sub e))
		   (1++ counter)
		   (if (= counter size)
		       (progn
			 (setq avg
			       (+ (- avg (/ expired (* 1.0 size))) (/ latest (* 1.0 size))))
			 (osql-result s size slide avg)
			 (setq expired 0)
			 (setq latest 0)
			 (setq counter (- counter slide))
			 (cond ((> size slide)
				(dotimes (i slide)
				  (setq expired (+ (caar sub) expired))
				  (setf (car sub) (cdr (car sub)))))
			       (t
				(setq sub (tconc))
				(setq expired (* size avg)))))))))))

(osql "create function simple_move_average0(Stream of Number s, Integer size, Integer slide)
                                                                              -> Bag of Number
       as foreign 'simple-move-average-s--+';")

(defun window2substream+- (fno w s)
  (let ((size 0) (tl (tconc)))
    (mapbag s
	    (f/l (e)
		 (1++ size)
		 (setq tl (tconc tl (car e)))))
    (osql-result (make-swin 'list size size tl) s))) 

(osql "create function window2substream(Window w) -> Stream as
       multidirectional ('bf' select streamof(in(w)))
                        ('fb' foreign 'window2substream+-');")

;; take a list of pairs returns a tail list
(defun linear-interpolation (l multiplier)
  (let (previous (res (tconc)))
    (if (= multiplier 0) (error "multiplier should be non-zero"))
    (if l (progn
	    (setq previous (car l))
	    (setq res (tconc res previous))
	    (setq l (cdr l))
	    (mapc (f/l (this)
		       (let* ((x0 (car previous)) (y0 (cadr previous))
			     (x1 (car this)) (y1 (cadr this))
			     (step (/ (- y1 y0) (* 1.0 multiplier)))) ;; multiplier * 1.0 due to /
			 (cond ((= x1 x0)
				(dotimes (i (1- multiplier))
				  (setq res (tconc res (list x0 (+ y0 (* step (1+ i))))))))
			       (t
				(let* ((k (/ (- y1 y0) (* 1.0 (- x1 x0))))
				       (b (- y0 (* k x0))) (x x0))
				  (dotimes (i (1- multiplier))
				    (setq x (+ x step))
				    (setq res (tconc res (list x (+ (* k x) b))))))))
			 (setq res (tconc res this))
			 (setq previous this)))
		  l)
	    res))))

(defun linear-interpolation-w--++ (fno w1 w2)
  (let* ((w1size (swin-size w1))
	 (w2size (swin-size w2))
	 (lcm (lcm (- w1size 1) (- w2size 1)))
	 (w1multiplier (/ lcm (- w1size 1)))
	 (w2multiplier (/ lcm (- w2size 1)))
	 res1 res2)
    (setq res1 (linear-interpolation (car (window2list w1)) w1multiplier))
    (setq res2 (linear-interpolation (car (window2list w2)) w2multiplier))
    (let ((res1size (length (car res1)))
	  (res2size (length (car res2))))
      (apply 'osql-result
	     (list w1 w2 (make-swin 'list res1size res1size res1)
		   (make-swin 'list res2size res2size res2)))))) 

(osql "create function linear_interpolation(Window w1, Window w2) -> (Window ww1, Window ww2)
       as foreign 'linear-interpolation-w--++';")


;(setq window1 (tconc))
;(setq window1 (tconc window1 '(1 1)))
;(setq window1 (tconc window1 '(2 2)))
;(setq window1 (tconc window1 '(3 3)))
;(setq amos_window1 (make-swin 3 3 window1))

;(setq window2 (tconc))
;(setq window2 (tconc window2 '(1 1)))
;(setq window2 (tconc window2 '(2 2)))
;(setq window2 (tconc window2 '(3 3)))
;(setq window2 (tconc window2 '(4 4)))
;(setq amos_window2 (make-swin 4 4 window2))

;(setq window1 (tconc))
;(setq window1 (tconc window1 #(1 1)))
;(setq window1 (tconc window1 #(2 2)))
;(setq window1 (tconc window1 #(3 3)))
;(setq amos_window1 (make-swin 3 3 window1)) 

;(setq window2 (tconc))
;(setq window2 (tconc window2 #(1 1)))
;(setq window2 (tconc window2 #(2 2)))
;(setq window2 (tconc window2 #(3 3)))
;(setq window2 (tconc window2 #(4 4)))
;(setq amos_window2 (make-swin 4 4 window2))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;QUEUE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; a list implementation of FIFO queue
;; which is used for keeping the headers of the windows
;; "windows should be closed in the order they created"
;; obsolete
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(defun make-queue ()
;  "to void bundary check the empty queue hold an aditional cell"
;  (let ((q (list nil)))
;    (cons q q))) 

;(defun empty-queue-p (q)
;  (null (cdar q))) 

;(defun peak-queue (q)
;  (cadar q)) 

;(defun push-queue (q elem)
;  (setf (cdr q) (setf (cddr q) (list elem)))) 

;(defun pop-queue (q)
;  (car (setf (car q) (cdar q))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

;; home-made hash table copy
(defun copy-hash (hs)
  (let ((chs (make-hash-table :test (Function equal))))
    (maphash (f/l (key value)
		  (setf (gethash key chs) value))
	     hs)
    chs))