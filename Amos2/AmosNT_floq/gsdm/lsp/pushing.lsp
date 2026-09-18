;;; ===========================================================================
;;; AMOS2 - GSDM project
;;; 
;;; Author: (c) 2004 Milena Ivanove, UDBL
;;; $RCSfile: pushing.lsp,v $
;;; $Revision: 1.25 $ $Date: 2005/12/02 15:52:33 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Pushing functionality of GSDM working nodes
;;;              
;;; ===========================================================================

(defun send-message (msg servname)
"msg is a lisp form to be evaluated async at servname(charstring)"
(send-form msg (port-of-peer servname)))

;; preparing the TCP connection that includes query to the nameserver
(defun tcp-open (str)
 ; (formatl t "Prep connection" )
  (send-message 't (getobject str 'dest))
)

(defun tcp-put-orig (str el) 
" Send a message to the destination node to put the element in its stream"
  (let ((remstr (mkatom (concat (getobject str 'name) "_" _amosid_)))
	msg)
   (setq msg
	 `(apply 
	   (descr-put (getobject (get-str-named (quote , remstr)) 'descr))
	   (list (get-str-named (quote , remstr)) , el)))
   (send-message msg (getobject str 'dest))
))

;; Output communication happens here!
(defun tcp-put-old (str el) 
" Send a message to the destination node to put the element in its stream"
  (let ((remstr (mkatom (concat (getobject str 'name) "_" _amosid_)))
	(encoder (getobject 
	       (gettypenamed (getobject str 'tag))
	       'tcp-encode))
	enc msg)
    (setq enc (if encoder (apply encoder (list el)) el))

   (setq msg
	 `(apply 
	   (descr-put (getobject (get-str-named (quote , remstr)) 'descr))
	   (list (get-str-named (quote , remstr)) , enc)))
   (send-message msg (getobject str 'dest))
))

(defun tcp-put (str el) 
"Send a message to the destination node to put the element in its stream"
  (let ((remstr (mkatom (getobject str 'name)))

	(encoder (getobject 
	       (gettypenamed (getobject str 'tag))
	       'tcp-encode))
	enc msg)
    (setq el (cdr el)) ;; el is cons -> extract vector data
    (setq enc (if encoder (apply encoder (list el)) el))

   (setq msg
	 `(apply 
	   (descr-put (getobject (get-str-named (quote , remstr)) 'descr))
	   (list (get-str-named (quote , remstr)) , enc)))
   (send-message msg (getobject str 'dest))
))

(defun tcp-put-input (str el) 
  (let ((decoder (getobject 
		  (gettypenamed (getobject str 'tag))
		  'tcp-decode))
	dec)
    (setq dec (if decoder (apply decoder (list el)) el))
    ;; el is vector data-> make a cons
    (gsdm-put str (cons (getobject str 'tag) dec))
)) 

;;; encoding and decoding of vectors of complex for TCP communication
(defun encode-vector-of-complex (vc)
  (let* ((n (array-total-size vc))
	 (vr (make-array (* 2 n))))
    (dotimes (i n)
      (seta vr (* 2 i) (getreal (aref vc i)))
      (seta vr (1+ (* 2 i)) (getimag (aref vc i)))
      )
    vr
))

(defun encode-testsignal (el)
  (let* ((n (array-total-size el))
	 (newel (make-array n)))
    (seta newel 0 (aref el 0))
    (dotimes (i (1- n))
      (seta newel (1+ i) (encodecomplexarray (aref el (1+ i))))
      )
    newel
))

(defun decode-vector-of-complex (vr)
  (let* ((n (/ (array-total-size vr) 2))
	 (vc (make-array n)))
    (dotimes (i n)
      (seta vc i (make-complex (aref vr (* 2 i)) (aref vr (1+ (* 2 i)))))
      )
    vc
))

(defun decode-testsignal (el)
  (let* ((n (array-total-size el))
	 (newel (make-array n)))
    (seta newel 0 (aref el 0))
    (dotimes (i (1- n))
      (seta newel (1+ i) (decodecomplexarray (aref el (1+ i))))
      )
    newel
))


(defun encode-to-binary (el)
  (let* ((n (array-total-size el))
	 (newel (make-array n)))
    (seta newel 0 (aref el 0))
    (dotimes (i (1- n))
      (seta newel (1+ i) (complex-to-binary (aref el (1+ i))))
      )
    newel
))

(defun decode-from-binary (el)
  (let* ((n (array-total-size el))
	 (newel (make-array n)))
    (seta newel 0 (aref el 0))
    (dotimes (i (1- n))
      (seta newel (1+ i) (binary-to-complex (aref el (1+ i))))
      )
    newel
))
(defun tcp-encoding-on ()
  (let ()
 ;;  (putobject (gettypenamed 'testsignalWindow) 'tcp-encode 'encode-to-binary)
 ;;   (putobject (gettypenamed 'testsignalWindow)
;;	       'tcp-decode 'decode-from-binary)
    (putobject (gettypenamed 'testsignalWindow) 'tcp-encode 'encode-testsignal)
    (putobject (gettypenamed 'testsignalWindow) 'tcp-decode 'decode-testsignal)

    (putobject (gettypenamed 'channelWindow) 'tcp-encode 'encode-to-binary)
    (putobject (gettypenamed 'channelWindow) 'tcp-decode 'decode-from-binary)
))
