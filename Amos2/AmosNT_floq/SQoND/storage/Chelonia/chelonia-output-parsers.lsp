;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Andrej Andrejev, UDBL
;;; $RCSfile: chelonia-output-parsers.lsp,v $
;;; $Revision: 1.8 $ $Date: 2012/04/14 16:05:25 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Line-by-line parsers for Chelonia output
;;; =============================================================
;;; $Log: chelonia-output-parsers.lsp,v $
;;; Revision 1.8  2012/04/14 16:05:25  andan342
;;; Array proxy objects now correctly accumulate STEP information and are completely transparent to array slicing/projection/dereference operations. Added workaraounds for Chelonia step-related bug.
;;;
;;; Revision 1.7  2012/03/19 15:39:26  andan342
;;; Now only retreiving data needed to construct array proxies,
;;; small enough proxies are resolved immediately.
;;;
;;; Revision 1.6  2012/03/19 11:05:10  andan342
;;; NMA-PROXIES now accumulate ASUB operations, and are resolved automatically in expressions
;;;
;;; Revision 1.5  2012/03/18 13:16:07  andan342
;;; Created WRAPPER mode separate from TRIPLE-STORE mode
;;; Added NMA proxies to handle 'too large' arrays
;;;
;;; Revision 1.4  2012/03/17 21:39:36  andan342
;;; - Added debug functionality, including _chelonia_dub_results_ switch
;;;
;;; Revision 1.3  2012/02/23 19:10:32  andan342
;;; Chelonia to SPAQRQL connectivity with updates (except arrays)
;;;
;;; Revision 1.2  2012/02/21 11:03:47  andan342
;;; Amos-to-Chelonia interface with updates (except inserting arrays)
;;;
;;; Revision 1.1  2012/02/18 00:25:20  andan342
;;; Chelonia-to-Amos connectivity: read-only
;;;
;;; Revision 1.1  2012/02/01 19:26:48  andan342
;;; Almost fully-functional Chelonia connectivity
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(with-directory "../../lsp"
		(load "grab.lsp"))

(load "chelonia-nma-proxy.lsp")

(defparameter _chelonia_wait_fist_time_ 0.05) ; seconds
(defparameter _chelonia_wait_granularity_ 0.05) ; seconds
(defparameter _chelonia_wait_limit_ 300) ; times granularity

(defparameter ico " in Chelonia output") ; used in error messages

(defvar _chelonia_dub_results_ nil) ; print all chunks of result file with 'DUB:' prefix if not NIL

(defun get-chelonia-result-stream (url)
  (let (cs cc)
    (sleep _chelonia_wait_fist_time_)
    (dotimes (i _chelonia_wait_limit_ (error "Chelonia timed out"))
      (setq cs (get-url-chunked-stream url))      
      (unless (chunked-stream-flip cs) 
	(when _chelonia_dub_results_ (formatl nil "DUB - EMPTY RESULT!" t))
	(return cs)) ; return empty result stream (NIL)
      (setq cc (read-charcode (chunked-stream-s cs)))
      (cond ((eq cc '*eof*) 
	     (return cs)) ; return empty result stream (*EOF*)
	    ((= cc (char-int "?")) 
	     (error (concat "Chelonia error: " (chunked-read-line cs))))
	    ((= cc (char-int "\"")) 
	     (unread-charcode cc (chunked-stream-s cs)) 
	     (when _chelonia_dub_results_
	       (chunked-stream-dub cs))
	     (return cs)) ; return non-empty result stream
	    (t (sleep _chelonia_wait_granularity_)))))) ; keep waiting

(defun chelonia_print_output-- (fno url limit)
  (print-chunks (get-chelonia-result-stream url) limit))
	  
(defun chelonia_parse_strings-+ (fno url res)
  (let ((cs (get-chelonia-result-stream url))
	co-token (r "") (state 0))
    (while t
      (setq co-token (chunked-read-token cs nil nil t nil))
      (cond ((eq co-token '*eof*) 
	     (return t))
	    ((= state 0)
	     (setq r co-token)
	     (setq state 1))
	    ((and (= state 1) (string= co-token "#"))
	     (osql-result url r)
	     (setq state 0))
	    (t (error (concat "Unexpected value: " co-token ico)))))))

(defun chelonia_parse_string_ints-++ (fno url sres ires)
  (let ((cs (get-chelonia-result-stream url))
	co-token (sr "") (ir 0) (state 0))
    (while t
      (setq co-token (chunked-read-token cs nil nil t nil))
      (cond ((eq co-token '*eof*) 
	     (return t))
	    ((= state 0)
	     (setq sr co-token)
	     (setq state 1))
	    ((= state 1)
	     (setq ir (read co-token))
	     (unless (integerp ir) 
	       (error (concat "Not an integer: " co-token ico)))
	     (setq state 2))
	    ((and (= state 2) (string= co-token "#"))
	     (osql-result url sr ir)
	     (setq state 0))
	    (t (error (concat "Unexpected value: " co-token ico)))))))

(defun chelonia_parse_literals-----+ (fno url db tid var rangestr res) ; DB, TID, VAR, RANGSTR are only used when creating NMA proxy
  (let ((cs (get-chelonia-result-stream url))
	co-token (r "") ltype etype dims (state 0))
    (while t
      (setq co-token (chunked-read-token cs nil nil t nil))
      (cond ((eq co-token '*eof*) 
	     (return t))
	    ((= state 0)
	     (setq ltype co-token)
	     (setq state 1))
	    ((= state 1) 
	     (selectq (substring 0 0 ltype)
		      ("i" (setq res (read co-token)) ; integer
		       (unless (integerp res)
			 (error (concat "Invalid integer value: " co-token ico))))
		      ("f" (setq res (read co-token)) ; float
		       (if (integerp res) (setq res (* 1.0 res))
			 (unless (floatp res)
			   (error (concat "Invalid floating-point value: " co-token ico)))))
		      ("s" (setq res co-token)) ; string
		      ("p" (setq dims (mapcar #'read (string-explode co-token ","))) ; array proxy (defaul behavior of getValue)
		       (validate-dims dims)
		       (setq etype (substring 1 (1- (length ltype)) ltype))
		       (setq res (make-chelonia-nma-proxy db tid var rangestr etype dims)) ; construct an nma-proxy
		       (when (or (null _nma_proxy_threshold_) ; resolve nma-proxy immediately if small enough
				 (<= (lproduct dims) _nma_proxy_threshold_)) 
			 (setq res (chelonia-nma-proxy-resolve res))))
		      ("a" (setq state 2)) ; array (default behavior of getSubArray)
		      (error "Invalid value type: " ltype ico))
	     (when (= state 1) ; if did not change the state
	       (when res (osql-result url db tid var rangestr res)) ; return result if any
	       (return t))) ; once at most
	    ((and (= state 2) (string= co-token ";"))
	     (setq dims (read-number-list cs "," ";"))
	     (validate-dims dims)
	     (setq dims (fix-dims dims rangestr)) ;TODO: remove this once Chelonia bug is fixed
	     (setq etype (substring 1 (1- (length ltype)) ltype))
	     (if (and _nma_proxy_threshold_ (> (lproduct dims) _nma_proxy_threshold_))
		 (setq res (make-chelonia-nma-proxy db tid var rangestr etype dims)) ; create proxy object
	       (progn
		 (selectq etype ; create NMA
			  ("int" (setq res (make-inma dims)))
			  ("float" (setq res (make-dnma dims)))
			  (error (concat "Invalid array element type: " etype ico)))
		 (chelonia-read-array cs res (buildn (length dims) 0) 0))) ; read in all the elements
	     (osql-result url db tid var rangestr res)
	     (return t)))))) ; return only once!

(defun validate-dims (dims)
  (unless (and dims (every (f/l (d) (and (integerp d) (> d 0))) dims))
    (error (concat "Invalid array dimensions: " dims ico))))

(defun fix-dims (dims rangestr) ; TODO: remove once Chelonia bug is fixed
  "Fix Chelonia bug for wrong report of array dimensions when accessed with step"
  (let ((rangesplit (string-explode rangestr ",")) ksplit kstep)
    (dotimes (k (length dims))
      (setq ksplit (string-explode (nth k rangesplit) ":"))
      (when (second ksplit)
	(setq kstep (read (second ksplit)))
	(when (> kstep 1)
	  (setf (nth k dims) (ceiling (/ (* 1.0 (nth k dims)) kstep))))))
    dims))

(defun read-number-list (cs delim term)
  (let (res token)
    (while t
      (setq token (chunked-read-token cs delim term nil t))
      (if (numberp token)
	  (push token res)
	(return (nreverse res)))))) ;do not reverse yet	

(defun chelonia-read-array (cs a idx level)
  (let ((state 0) token)
    (unless (string= (chunked-read-token cs "," "{}" nil t) "{")
      (error (concat "Array dimensionality mismatch" ico)))
    (dotimes (i (nma-dim a level))
      (setf (nth level idx) i)
      (if (< level (1- (nma-ndims a)))
	  (chelonia-read-array cs a idx (1+ level)) ; recursive
	(progn
	  (setq token (chunked-read-token cs "," "{}" nil t))
	  (if (numberp token)
	      (nma-set a idx token)
	    (error (concat "Array element not numeric: " token ico))))))
    (unless (string= (chunked-read-token cs "," "{}" nil t) "}")
      (error (concat "Array size mismatch" ico))))) ; '}' should follow after NMA-DIM elements
	

(osql "
create function Chelonia_print_output(Charstring url, Integer chunks) -> Boolean
  as foreign 'chelonia_print_output--';

create function Chelonia_parse_strings(Charstring url) -> Bag of Charstring
  as foreign 'chelonia_parse_strings-+';

create function Chelonia_parse_string_ints(Charstring url) -> Bag of (Charstring, Integer)
  as foreign 'chelonia_parse_string_ints-++';

create function Chelonia_parse_literals(Charstring url, Charstring db, Integer tid, Charstring var, Charstring rangestr) -> Bag of Literal
  as foreign 'chelonia_parse_literals-----+';
")





  
				       