;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010 Robert Kajic, UDBL
;;; $RCSfile: window.lsp,v $
;;; $Revision: 1.24 $ $Date: 2010/09/21 13:29:31 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Stream to relation (window) operators. Tuple and time
;;; windows are supported as well as an experimental, infinite window
;;; operator.
;;;
;;; =============================================================
;;; $Log: window.lsp,v $
;;; Revision 1.24  2010/09/21 13:29:31  roka4241
;;; Started using more strict argument typing, for example Stream of Vector and Stream of Window instread of the ambiguous Stream.
;;;
;;; Revision 1.23  2010/09/07 23:24:24  roka4241
;;; Renamed w_where to w_filter.
;;;
;;; Revision 1.22  2010/08/22 03:40:38  roka4241
;;; Added distinct, projection and filtering operators over window streams. Slightly simplified partition window operator.
;;;
;;; Revision 1.21  2010/08/10 02:52:44  roka4241
;;; Redeclared w-info into a operator which yields a infinite stream of windows by repeatedly calling a amos function given to it.
;;;
;;;
;;; Revision 1.19  2010/08/07 15:24:00  roka4241
;;; Typo fix.
;;;
;;; Revision 1.18  2010/08/07 04:02:14  roka4241
;;; Changed bag arguments to arrays. Added w_where operator for window filtering.
;;;
;;; Revision 1.17  2010/07/30 18:50:52  roka4241
;;; Fixed bugs in distinct and projection operatators.
;;;
;;; Revision 1.16  2010/07/27 01:10:48  roka4241
;;; Added distinct and projection operators on window streams.
;;;
;;; Revision 1.15  2010/07/22 00:44:06  roka4241
;;; *** empty log message ***
;;;
;;; Revision 1.14  2010/07/14 06:12:34  roka4241
;;; Adjusted all regression tests affected by the recent window operator changes. Fixed some bugs found by the regression tests.
;;;
;;; Revision 1.13  2010/07/13 05:33:15  roka4241
;;; *** empty log message ***
;;;
;;; Revision 1.12  2010/07/13 05:31:32  roka4241
;;; Changed the time window operator so that it always outputs a window when a new timestamp is encountered. Made the same changes to the tuple window. Started testing the partition window, fixing bugs and also made the same changes as were made to the time and tuple windows (windows are emitted at timestamp change). Due to the 'emission'-changes made to the window operators, regression tests will be broken for all and must be fixed.
;;;
;;; Revision 1.11  2010/07/12 05:16:47  roka4241
;;; Updated tuple window to a time driven model. I.e. it only emits at most one window for every time unit and the window will contain the latest tuples from each time unit. Note that the window still can contain tuples from several time units, if there is not enough tuples in one time unit to fill the window. Updated the regression tests for the new tuple window. Added a partition window (still untested).
;;;
;;; Revision 1.10  2010/07/07 03:52:12  roka4241
;;; Added additional regression tests for istream / dstream / time window and tuple window operators. Fixed bugs in time window operator. Added sublist and sublst functions for extractions of a lists' subset. Made it so that the swin-make-c wrapper swin-make no longer takes a hashmap argument and passes nil as hashmap to the underlying implementation.
;;;
;;; Revision 1.9  2010/07/06 18:10:40  roka4241
;;; Added 'new-window' flag to stream windows. Generalized istream and dstream to work on more types of windows. Added istream and dstream regression tests for tuple windows (should also add tests for time windows). Fixed bug which  sometimes caused one additional, errornous, window to be created when applying any windowing operator on a stream.
;;;
;;; Revision 1.8  2010/07/03 02:47:06  roka4241
;;; Now using correct versions of extfunction. Wrote regress tests for stream group by and fixed some bugs. Refactored stream window datatype.
;;;
;;; Revision 1.7  2010/07/02 04:02:38  roka4241
;;; Added getters/setters/unsetters for groupby and join flags in stream windows.
;;;
;;; Revision 1.6  2010/07/01 13:19:07  roka4241
;;; Added CVS header.
;;;
;;; Revision 1.5  2010/07/01 02:37:03  roka4241
;;; Added CVS header.
;;;
;;; =============================================================

(if (not (gettypenamed 'window t))
    (createliteraltype 'window (list _collection_) 'swin))

(defun make-swin (sizec timec head tail flags)
  (let ((swin (make-swin-c sizec timec nil head tail flags)))
    swin))

(defun swin-length (swin)
  (swin-get-sizec swin))

(defun swin-in (w)
  (firstn (swin-get-sizec w) (swin-get-head w)))

(defun swinl-in (wl)
  (mapcar (f/l (w) (swin-in w)) wl))

(defun swinbag-in (wbag)
  (mapcar (f/l (w) (swin-in (car w))) wbag))


(defun swin-mapcar (w fn)
  (let ((w-new (mapcar fn (swin-in w))))
    (make-swin (length w-new) -1 w-new (last w-new))))

(defun swin-join-amosfn (w amosfn)
  (let ((r (mapfunction amosfn (swin-in window) (f/l (row) row))))
    (unless (null r)
      (let ((new-w (flatten r)))     
        (make-swin (length new-w) -1 new-w (last new-w))))))

(defun swin-filter (w fn)
  (let ((w-new (mapfilter
                (f/l (row)
                     (= (getfunction-firsttuple fn (list row))
                        '(true))) 
                (swin-in w))))
    (unless (null w-new)
      (make-swin (length w-new) -1 w-new (last w-new)))))

(defun swin-unique (w idx-list)
  (let* ((seen (make-hash-table :test #'equal))
         (unique-list 
          (mapfilter 
           (f/l (tpl)
                (let ((key (arefl tpl idx-list)))                  
                  (if (not (gethash key seen))                      
                      (puthash key seen tpl))))
           (swin-in w))))
    (unless (null unique-list)
      (make-swin (length unique-list) -1 unique-list (last unique-list)))))

(defun swin-project (w idx-list)
  (swin-mapcar w (f/l (tpl)
                      (arefl tpl idx-list))))

(defun swin-project-join (w idx-list)
  (swin-mapcar w (f/l (tpl)
                      (alrefl tpl idx-list))))


(defun swin-empty-p (w)
  "check if a given window is empty"
  (and (null (swin-get-head w))
       (null (swin-get-tail w))))

(defun swin-emptyh-p (w)
  "check if a given window's head is empty"
  (null (swin-get-head w)))

(defun swin-emptyt-p (w)
  "check if a given window's tail is empty"
  (null (swin-get-tail w)))

(osql "create function swin_in(Window w) -> Bag of Object as foreign 'swin-in';")

(defun foreign-swin-get-head (fno w r)
  (osql-result w (swin-get-head w)))
(osql "create function swin_get_head(Window w) -> Bag of Vector as foreign 'foreign-swin-get-head';")

(defparameter *swin-join-mask* 1)

(defun swin-join-p (w)
  (> (band (swin-get-flags w) *swin-join-mask*) 0))
(defun swin-join-set (w)
  (swin-set-flags w (bor (swin-get-flags w) *swin-join-mask*)))
(defun swin-join-unset (w)
  (swin-set-flags w (band (swin-get-flags w) (bnot *swin-join-mask*))))

;;; 
;;; Tuple window
;;; 
(defun w-tuple-add (w tpl)
  "Add tuple [tpl] to window [w]."
  (let ((tpl (list tpl)))
    (cond ((swin-empty-p w)
           (swin-set-head w tpl)
           (swin-set-tail w tpl))
          (t
           (rplacd (swin-get-tail w) tpl)
           (swin-set-tail w tpl))))
  (swin-inc-sizec w 1))

(defun w-tuple-slide (w slide)
  (let ((hdl (swin-get-head w)))
    (dotimes (i slide)
      (setq hdl (cdr hdl)))
    (swin-set-head w hdl))
  (swin-inc-sizec w (- slide)))

(defun w-tuple (fno stream size slide ts-idx r)
  "Apply a tuple window of size [size] and with slide [slide] on stream [stream]. The [slide] must be smaller or equal to the [size]."              
  (let* ((w (make-swin))
         (prev-ts nil))
    (mapbag stream
            (f/l (tpl)
                 (let 
                     ((ts (elt (car tpl) ts-idx)))
                   
                   (when (null prev-ts)
                     (setq prev-ts ts))
                   
                   ;; we are still on the same timestamp
                   (when (= prev-ts ts)
                     ;; the window is overfilled, drop one old tuple
                     (when (= (swin-get-sizec w) size)                       
                       (w-tuple-slide w 1))                                       
                     
                     ;; add new tuple                     
                     (w-tuple-add w (car tpl)))                                      
                   
                   ;; we are on a new timestamp
                   (when (< prev-ts ts)

                     (osql-result stream size slide ts-idx w)                     
                     (setq w (make-swin (swin-get-sizec w) -1 (swin-get-head w) (swin-get-tail w)))
                     
                     ;; add the tuple to the new window
                     (w-tuple-add w (car tpl))
                     
                     ;; the window is full, drop [slide] tuples
                     (when (> (swin-get-sizec w) size)                       
                       (w-tuple-slide w slide)))
                   
                   ;; save latest timestamp
                   (setq prev-ts ts))))
    ;; emit last window

    (osql-result stream size slide ts-idx w)))
(osql "create function w_tuple_f(Stream of Vector s, Integer size, Integer slide, Integer ts_idx) -> Bag of Window as foreign 'w-tuple';")
(osql "create function w_tuple(Stream of Vector s, Integer size, Integer slide, Integer ts_idx) -> Stream of Window as streamof(w_tuple_f(s, size, slide, ts_idx));")

;;; 
;;; Partition window
;;;
(defun partition-w-toswin (btree)
  (let ((w (make-swin)))
    (map-btree btree '* '*
               (f/l (key tpl-list)
                    (dolist (tpl (reverse tpl-list))
                      (w-tuple-add w (car tpl)))                    
                    ;; seems like we must return non-nil to continue with the next key-value pair. bug?
                    t))
    w))

(defun w-partition-add (tree key tpl)
  (let ((bucket (get-btree key tree)))
    (if (null bucket)
        (put-btree key tree (list tpl))           
      (put-btree key tree (cons tpl bucket)))))

(defun w-partition-slide (tree key slide)
  (let ((bucket (get-btree key tree)))
    (put-btree key tree (firstn (- (length bucket) slide) bucket))))

(defun w-partition-length (tree key)
  (length (get-btree key tree)))

(defun w-partition (fno stream idx size slide ts-idx r)
  "Apply a partition window on [stream]. The window is partitioned on the tuple column indexes in [idx]. The partitions will contain at most [size] tuples and slide forward [slide] tuples. [ts-idx] identifies the timestamp column in the stream tuples."
  (let ((idx-list (arraytolist idx))
        (p-w (make-btree))
        (prev-ts nil))
    (mapbag stream
            (f/l (tpl)
                 (let ((ts (elt (car tpl) ts-idx))                        
                       (key (arefl (car tpl) idx-list)))
                   
                   (when (null prev-ts)
                     (setq prev-ts ts))
                   
                   ;; we are still on the same timestamp
                   (when (= prev-ts ts)
                     ;; the bucket is full, we need to drop the oldest tuple
                     (when (= (w-partition-length p-w key) size)
                       (w-partition-slide p-w key 1))                     
                     
                     ;; add new tuple
                     (w-partition-add p-w key tpl))      
                   
                   ;; we are on a new timestamp, emit the window
                   (when (< prev-ts ts)   
                     (osql-result stream idx size slide ts-idx
                                  (partition-w-toswin p-w))
                     
                     (w-partition-add p-w key tpl)
                     
                     ;; check if the bucket is full and must be slided
                     (let ((b-len (w-partition-length p-w key)))
                       (when (> b-len size)
                           (w-partition-slide p-w key slide))))
                   
                   ;; save latest timestamp
                   (setq prev-ts ts))))
    ;; emit last window if the partition window contains unemited tuples 
    (osql-result stream idx size slide ts-idx
                 (partition-w-toswin p-w))))
(osql "create function w_partition_f(Stream of Vector s, Vector idx, Integer size, Integer slide, Integer ts_idx) -> Bag of Window as foreign 'w-partition';")
(osql "create function w_partition(Stream of Vector s, Vector idx, Integer size, Integer slide, Integer ts_idx) -> Stream of Window as streamof(w_partition_f(s, idx, size, slide, ts_idx));")

;;; 
;;; Time window
;;; 
(defun w-time-add (w tpl ts-idx)
  "Add tuple [tpl] to window [w]."
  (let ((tpl (list tpl)))
    (cond ((swin-emptyh-p w)
           (swin-set-head w tpl)
           (swin-set-tail w tpl)
           (swin-set-timec w (elt (car tpl) ts-idx)))
          (t           
           (rplacd (swin-get-tail w) tpl)
           (swin-set-tail w tpl)))
    (swin-inc-sizec w 1)))

(defun w-time-slide (w ts-idx)
  "Slide window [w] forward to its current starting timestamp [w_start_ts], removing all tuples with timestamps smaller than {w_start_ts}. The vector index [ts-idx] specifies the index of the timestamp cell in each tuple." 
  (let 
      ((ts nil) 
       (head (swin-get-head w)) 
       (w-head-ts (swin-get-timec w)))
    (loop
     (setq ts (elt (car head) ts-idx))
     (when (<= w-head-ts ts) 
       (swin-set-head w head)
       (return))
     (swin-inc-sizec w -1)
     (setq head (cdr head)))))

(defun w-time (fno stream size slide ts-idx r)
  "Apply a time window of [size] seconds and with a slide of [slide] seconds on stream [stream], using [ts-idx] to point out the index of the timestamp column in each stream tuple."     
  (let ((w (make-swin 0 0))
        (prev-ts nil))
    (mapbag stream
            (f/l (tpl)
                 (let*
                     ((ts (elt (car tpl) ts-idx))
                      (w-head-ts (swin-get-timec w)) 
                      (potential-size (- ts w-head-ts)))   
                   
                   (when (null prev-ts)
                     (setq prev-ts ts))

                   
                   ;; add tuple if fits within the window size and it has the same timestamp as the previous tuple
                   (when (and (< potential-size size)
                              (= prev-ts ts))
                     (w-time-add w (car tpl) ts-idx))
                     
                   ;; emit window if we are on a new timestamp
                   (when (< prev-ts ts)
                     (osql-result stream size slide ts-idx w) 
                                          
                     (setq w (make-swin (swin-get-sizec w) (swin-get-timec w)
                                        (swin-get-head w) (swin-get-tail w)))
                     
                     ;; add left-over tuple
                     (w-time-add w (car tpl))
                     
                     ;; slide the window if it is full
                     (when (>= potential-size size)
                       (swin-set-timec w (+ w-head-ts slide))
                       (w-time-slide w ts-idx)))
                   (setq prev-ts ts))))
    ;; emit last window
    (osql-result stream size slide ts-idx w)))
(osql "create function w_time_f(Stream of Vector s, Integer size, Integer slide, Integer ts_idx) -> Bag of Window as foreign 'w-time';")     
(osql "create function w_time(Stream of Vector s, Integer size, Integer slide, Integer ts_idx) -> Stream of Window as streamof(w_time_f(s, size, slide, ts_idx));")

;;;
;;; Now window shortcut, a time window with a slide of one second and a stide of one second
;;;
(osql "create function w_now(Stream of Vector s, Integer ts_idx) -> Stream of Window as streamof(w_time_f(s, 1, 1, ts_idx));")

;;;
;;; Distinct operator
;;; 
(defun w-distinct (fno idx wstream r)
  "Take an input stream [wstream] of windows and output new window stream where non-unique elements have been removed where uniqueness is determined by the columns in [idx]."

  (let ((idx-list (arraytolist idx)))
    (mapbag wstream
            (f/l (w)
                 (osql-result idx wstream (swin-unique (car w) idx-list))))))
(osql "create function w_distinct_f(Vector idx, Stream of Window wstream) -> Bag of Window as foreign 'w-distinct';")
(osql "create function w_distinct(Vector idx, Stream of Window wstream) -> Stream of Window as streamof(w_distinct_f(idx, wstream));")

;;;
;;; Projection on window stream
;;;
(defun w-project (fno idx wstream r)
  "Project upon the windows in the stream [wstream] the indexes in [idx]."
  (let ((idx-list (arraytolist idx))
        (fn nil))
    (if (consp (car idx-list)) 
        (setq fn #'swin-project-join)
      (setq fn #'swin-project))
    (mapbag wstream
            (f/l (w)
                 (osql-result idx wstream (funcall fn (car w) idx-list))))))
(osql "create function w_project_f(Vector idx, Stream of Window wstream) -> Bag of Window as foreign 'w-project';")
(osql "create function w_project(Vector idx, Stream of Window wstream) -> Stream of Window as streamof(w_project_f(idx, wstream));")

;;;
;;; Filtering on window stream
;;;
(defun w-filter (fno wstream accept-fn)
  (mapbag wstream 
          (f/l (w)
               (let ((w-filtered (swin-filter (car w) accept-fn)))
                 (unless (null w-filtered)
                   (osql-result wstream accept-fn w-filtered))))))
(osql "create function w_filter_f(Stream of Window wstream, Function accept_fn) -> Bag of Window as foreign 'w-filter';")
(osql "create function w_filter(Stream of Window wstream, Function accept_fn) -> Stream of Window as streamof(w_filter_f(wstream, accept_fn));")
