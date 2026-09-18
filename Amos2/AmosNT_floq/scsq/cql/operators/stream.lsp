;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010 Robert Kajic, UDBL
;;; $RCSfile: stream.lsp,v $
;;; $Revision: 1.14 $ $Date: 2010/10/12 13:08:18 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Relation (window) to stream operators. 
;;; =============================================================
;;; $Log: stream.lsp,v $
;;; Revision 1.14  2010/10/12 13:08:18  roka4241
;;; Removed s_project and s_filter, using AmosQL functions instead.
;;;
;;; Revision 1.13  2010/09/21 13:29:31  roka4241
;;; Started using more strict argument typing, for example Stream of Vector and Stream of Window instread of the ambiguous Stream.
;;;
;;; Revision 1.12  2010/09/08 00:03:38  roka4241
;;; Fixed typo in s_project.
;;;
;;; Revision 1.11  2010/09/07 23:21:05  roka4241
;;; Added stream filtering.
;;;
;;; Revision 1.10  2010/08/22 03:38:25  roka4241
;;; Simplified rstream operator. Added stream projection.
;;;
;;; Revision 1.9  2010/08/10 02:51:15  roka4241
;;; Made rstream into a foreign function.
;;;
;;;
;;; Revision 1.7  2010/08/07 15:22:51  roka4241
;;; Added stream projection operator. Added 'now window' shorthand (wrapping the time window operator).
;;;
;;; Revision 1.6  2010/08/07 03:57:19  roka4241
;;; Added rstream operator.
;;;
;;; Revision 1.5  2010/07/06 18:10:40  roka4241
;;; Added 'new-window' flag to stream windows. Generalized istream and dstream to work on more types of windows. Added istream and dstream regression tests for tuple windows (should also add tests for time windows). Fixed bug which  sometimes caused one additional, errornous, window to be created when applying any windowing operator on a stream.
;;;
;;; Revision 1.4  2010/07/01 13:19:07  roka4241
;;; Added CVS header.
;;;
;;; =============================================================

(defun xstream (win-stream first-fn order-windows-fn)
  (let 
      (win-prev
       (first t))
    (mapbag win-stream
            (f/l (win-cur)
                 (let
                     ((win-cur (car win-cur)))
                   (if (= first t) 
                       (progn 
                         ;; first window
                         (funcall first-fn win-stream win-cur)
                         (setq first nil))
                     (progn
                       ;; compare windows
                       (let ((cur-prev-windows (funcall order-windows-fn win-cur win-prev)))
                         (emit-window-change win-stream cur-prev-windows))))
                   (setq win-prev win-cur))))))

(defun emit-window (win-stream w)
  "Emit all elements in window [w]."
  (let
      ((head (swin-get-head w)))   
    (dotimes (i (swin-get-sizec w))
      (osql-result win-stream (car head))
      (setq head (cdr head)))))

(defun emit-window-change (win-stream windows)
  "Emit tuples that can be found in (first [windows]) but not in
   (second [windows])."
  (let ((win-cur (first windows))
        (win-prev (second windows)))
    (let
        ((win-cur-head (swin-get-head win-cur))
         (win-prev-head (swin-get-head win-prev))
         (win-cur-length (swin-get-sizec win-cur))
         (win-prev-length (swin-get-sizec win-prev)))    
      (dolist (tuple-cur (firstn win-cur-length win-cur-head))         
        (unless (= (dolist (tuple-prev (firstn win-prev-length win-prev-head))
                     (when (= tuple-cur tuple-prev)
                       (return 'not-new)))                   
                   'not-new)
          (osql-result win-stream tuple-cur))))))

(defun istream (fno win-stream r) 
  "Outputs an incremental stream such that the emitted elements exists in win-stream[n] but not in win-stream[n-1]."
  (xstream win-stream 
           #'emit-window
           (f/l (win-cur win-prev) (list win-cur win-prev))))

(osql "create function istream_f(Stream of Window wstream) -> Bag of Vector as foreign 'istream';")
(osql "create function istream(Stream of Window wstream) -> Stream of Vector as streamof(istream_f(wstream));")

;;;
;;; dstream operator
;;; 
(defun dstream (fno win-stream r)
  "Outputs an incremental stream such that the emitted elements exists in win-stream[n] but not in win-stream[n-1]."
  (xstream win-stream 
           (f/l (win))
           (f/l (win-cur win-prev)
                (list win-prev win-cur))))
(osql "create function dstream_f(Stream of Window wstream) -> Bag of Vector as foreign 'dstream';")
(osql "create function dstream(Stream of Window wstream) -> Stream of Vector as streamof(dstream_f(wstream));")

;;;
;;; rstream operator
(defun rstream (fno wstream r)
  (mapbag wstream
          (f/l (w)
               (emit-window wstream (car w)))))
(osql "create function rstream_f(Stream of Window wstream) -> Bag of Vector as foreign 'rstream';")
(osql "create function rstream(Stream of Window wstream) -> Stream of Vector as streamof(rstream_f(wstream));")
