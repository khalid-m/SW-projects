;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010 Robert Kajic, UDBL
;;; $RCSfile: aggregate.lsp,v $
;;; $Revision: 1.11 $ $Date: 2010/09/21 13:29:31 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Aggregation over window streams.
;;; =============================================================
;;; $Log: aggregate.lsp,v $
;;; Revision 1.11  2010/09/21 13:29:31  roka4241
;;; Started using more strict argument typing, for example Stream of Vector and Stream of Window instread of the ambiguous Stream.
;;;
;;; Revision 1.10  2010/08/22 03:34:02  roka4241
;;; Simplified distinct count by using the amos functions unique and count.
;;;
;;; Revision 1.9  2010/08/10 02:46:25  roka4241
;;; Added distinct count aggregate function.
;;;
;;; Revision 1.8  2010/08/07 03:56:25  roka4241
;;; Updated groupby so that it can group on any number of columns and perform sepearate aggregation on several columns. Changed bag input arguments to arrays.
;;;
;;; Revision 1.7  2010/07/22 00:19:31  roka4241
;;; Greatly simplified and generalized stream aggregation by wrapping amos groupby functionality.
;;;
;;; Revision 1.6  2010/07/14 06:12:34  roka4241
;;; Adjusted all regression tests affected by the recent window operator changes. Fixed some bugs found by the regression tests.
;;;
;;; Revision 1.5  2010/07/07 03:52:12  roka4241
;;; Added additional regression tests for istream / dstream / time window and tuple window operators. Fixed bugs in time window operator. Added sublist and sublst functions for extractions of a lists' subset. Made it so that the swin-make-c wrapper swin-make no longer takes a hashmap argument and passes nil as hashmap to the underlying implementation.
;;;
;;; Revision 1.4  2010/07/03 02:47:05  roka4241
;;; Now using correct versions of extfunction. Wrote regress tests for stream group by and fixed some bugs. Refactored stream window datatype.
;;;
;;; Revision 1.3  2010/07/02 04:00:43  roka4241
;;; Finished group by operator (still needs to be tested).
;;;
;;; Revision 1.2  2010/07/01 02:37:03  roka4241
;;; Added CVS header.
;;;
;;; Revision 1.1  2010/07/01 02:27:21  roka4241
;;; Started with group_by over stream windows.
;;;
;;; =============================================================

(defun w-group-by (fno key-idx-array val-idx-array agg-fn-array wstream r)
  "Group the windows in the window stream [wstream] as specified by the tuple index array [key-idx-array]. For each pair from [val-idx-array] and [agg-fn-array] (a pair is made up of one element from each array) an aggregate value is calculated on the val-idx column using the agg-fn aggregate function, on each aggregate group. The result will be a stream of windows where
each window is made up of tuples created from the group by key indexes, followed by each aggregate value for that group."
  (let 
      ((key-idx-list (arraytolist key-idx-array))
       (val-idx-list (arraytolist val-idx-array))
       (agg-fn-list (arraytolist agg-fn-array)))
    (mapbag wstream
            (f/l (w)
                 ;; Calculate separate aggregate results using each
                 ;; of the supplied aggregate functions. 
                 (let
                     ((wagg-separated
                       (mapcar 
                        (f/l (val-idx agg-fn)                       
                             (let 
                                 ((wbag 
                                   (bagify 
                                    (mapcar 
                                     (f/l (tpl)
                                          (list (arefl tpl key-idx-list)
                                                (elt tpl val-idx)))
                                     (swin-in (car w))))))
                               (callfunction 'groupby (list wbag agg-fn))))
                        val-idx-list agg-fn-list))
                      (w-new (make-swin)))
                   ;; Merge all aggregate results so that each group 
                   ;; row contains the results of all aggregations. 
                   (apply #'mapc 
                          (cons 
                           (f/l (&rest wagg-rows) 
                                (let
                                    ((tpl
                                      (let ((group-key (elt (car wagg-rows) 0))
                                            (agg-values 
                                             (mapcar 
                                              (f/l (wagg-row)
                                                   (elt wagg-row 1))
                                              wagg-rows)))
                                        (concatvector 
                                         group-key
                                         (listtoarray agg-values)))))
                                  (w-tuple-add w-new tpl)))
                           wagg-separated))   
                   (osql-result key-idx-array val-idx-array agg-fn-array wstream w-new))))))

(osql "create function w_group_by_f(Vector key_idx, Vector val_idx, Vector agg_fn, Stream of Window wstream) -> Bag of Window as foreign 'w-group-by';")
(osql "create function w_group_by(Vector key_idx, Vector val_idx, Vector agg_fn, Stream of Window wstream) -> Stream of Window as streamof(w_group_by_f(key_idx, val_idx, agg_fn, wstream));")

;;; Count distinct elements
(osql "create function count_distinct(Bag b) -> Number as 
  count(unique(b));")