;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010 Robert Kajic, UDBL
;;; $RCSfile: join.lsp,v $
;;; $Revision: 1.17 $ $Date: 2010/10/13 02:24:00 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Joining over window streams.
;;; =============================================================
;;; $Log: join.lsp,v $
;;; Revision 1.17  2010/10/13 02:24:00  roka4241
;;; Changed the n-theta join to call its joining funtion with n arguments instead of a vector with n elements.
;;;
;;; Revision 1.16  2010/09/21 13:29:31  roka4241
;;; Started using more strict argument typing, for example Stream of Vector and Stream of Window instread of the ambiguous Stream.
;;;
;;; Revision 1.15  2010/09/07 23:22:30  roka4241
;;; Fixed some bugs.
;;;
;;; Revision 1.14  2010/08/22 03:36:48  roka4241
;;; Fixed bugs in stream/window stream joining.
;;;
;;; Revision 1.13  2010/08/10 02:47:49  roka4241
;;; operators\join.lsp
;;;
;;; Revision 1.12  2010/08/07 03:52:10  roka4241
;;; Refactored window stream joining so that most of the functionality can be reused for window stream union and vector stream union all operators. Also properly s_join_n to w_join_n as it joins windows, not streams. Added w_union window join operator and s_join_all stream join all operator. Changed bag input arguments to arrays.
;;;
;;; Revision 1.11  2010/07/22 00:30:26  roka4241
;;; Simplified and generalized stream n-way join. It now takes a bag of window streams and a amos accept-function. The accept-function is executed for each possible joined row and determines which rows should make up the final join results. The accept-function will be given a vector of tuples. Each tuple comes from the corresponding stream in the given bag of streams (they have the same index).
;;;
;;; Revision 1.10  2010/07/07 03:52:12  roka4241
;;; Added additional regression tests for istream / dstream / time window and tuple window operators. Fixed bugs in time window operator. Added sublist and sublst functions for extractions of a lists' subset. Made it so that the swin-make-c wrapper swin-make no longer takes a hashmap argument and passes nil as hashmap to the underlying implementation.
;;;
;;; Revision 1.9  2010/07/03 02:47:06  roka4241
;;; Now using correct versions of extfunction. Wrote regress tests for stream group by and fixed some bugs. Refactored stream window datatype.
;;;
;;; Revision 1.8  2010/07/01 02:37:03  roka4241
;;; Added CVS header.
;;;
;;; =============================================================

(defstruct stream-struct stream cor)

(defun stream-struct-memq (stream l)
  (isome l (f/l (stream-struct tl)
                (eq stream (stream-struct-stream stream-struct)))))
(defun stream-struct-memq-a (stream l)
  (car (stream-struct-memq stream l)))


(defun stream-init-coroutines (stream-list)      
  (mapcar 
   (f/l (stream)
        (let ((stream-struct (make-stream-struct :stream stream :cor nil)))
          (setf (stream-struct-cor stream-struct)
                (coroutine 'mapbag 
                           (list (stream-struct-stream stream-struct) 'co-yield)))
          stream-struct))
   stream-list))

(defun stream-resume-all (stream-struct-list)
  (let ((els nil))      
    (mapc
     (f/l (stream-struct)
          (let
              ((cor (stream-struct-cor stream-struct)))
            (if (co-terminated cor)
                (return nil)
              (progn
                (let
                    ((el (co-resume cor)))                    
                  (unless (consp el)
                    (return nil))
                  (setq els (nconc els (list (car el)))))))))
     stream-struct-list)
    els))

(defun stream-resume-ready (stream-struct-list)
  (let ((els nil))
    (mapc
     (f/l (stream-struct)
          (let
              ((cor (stream-struct-cor stream-struct)))
            (unless (co-terminated cor)
              (progn
                (let
                    ((el (co-resume cor)))                    
                  (unless (consp el)
                    (return nil))
                  (setq els (nconc els (list (car el)))))))))
     stream-struct-list)
    els))

;;; Generic stream join of n streams
(defun stream-join (stream-array join-fn resume-fn &rest args)
  (let* ((r nil)
         (els nil)
         (stream-list (arraytolist stream-array))
         (coroutines (stream-init-coroutines stream-list)))
    (while (setq els (funcall resume-fn coroutines))
      (apply join-fn (cons els (cons stream-array args))))))


;;; Union of n window stream
(defun w-union-join-fn (windows wstream-array)
  (let ((r (unique (flatten (swinl-in windows)))))
    (unless (null r)
      (osql-result wstream-array
                   (make-swin (length r) -1 r (last r))))))

(defun w-union (fno wstream-array r)
  (stream-join wstream-array #'w-union-join-fn #'stream-resume-ready))
(osql "create function w_union_f(Vector wstream) -> Bag of Window as foreign 'w-union';")
(osql "create function w_union(Vector wstream) -> Stream of Window as streamof(w_union_f(wstream));")


;;; Union all of n vector streams
(defun s-union-all-join-fn (tuples stream-array)
  (mapc (f/l (tpl) 
             (osql-result stream-array tpl))
        tuples))
(defun s-union-all (fno stream-array r)
  (stream-join stream-array #'s-union-all-join-fn #'stream-resume-ready))
(osql "create function s_union_all_f(Vector s) -> Bag of Vector as foreign 's-union-all';")
(osql "create function s_union_all(Vector s) -> Stream of Vector as streamof(s_union_all_f(s));")

;;; Cartesian join, with an acceptance test, of n window streams
(defun w-join-join-fn (windows wstream-array accept-fn)
  (let ((r (map-cart-join 
              (f/l (row) 
                   (= (getfunction-firsttuple accept-fn (arraytolist row))
                      '(true))) 
              (swinl-in windows))))
    (unless (null r)
      (osql-result wstream-array
                   accept-fn
                   (make-swin (length r) -1 r (last r))))))

(defun w-join (fno wstream-array accept-fn r)
  (stream-join wstream-array 
                 #'w-join-join-fn 
                 #'stream-resume-all 
                 accept-fn))
(osql "create function w_join_f(Vector wstream, Function accept_fn) -> Bag of Window as foreign 'w-join';")
(osql "create function w_join(Vector wstream, Function accept_fn) -> Stream of Window as streamof(w_join_f(wstream, accept_fn));")

;;; Join window stream with a amos function
(defun w-join-amosfn (window wstream amosfn)
  (let ((r (swin-join-amosfn window amosfn)))
    (unless (null r)	  
      (osql-result wstream amosfn r))))

(defun w-join-amosfn (fno wstream amosfn r)
  (stream-join (listtoarray (list wstream))
               #'w-join-amosfn-fn
               #'stream-resume-all
               amosfn))
(osql "create function w_join_amosfn_f(Stream of Window wstream, Function amosfn) -> Bag of Window as foreign 'w-join-amosfn';")
(osql "create function w_join_amosfn(Stream of Window wstream, Function amosfn) -> Stream of Window as streamof(w_join_amosfn_f(wstream, amosfn));")
