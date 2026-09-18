;;; ===========================================================================
;;; AMOS2 - GSDM project
;;; 
;;; Author: (c) 2004 Milena Ivanova, UDBL
;;; $RCSfile: dataflow_amos.lsp,v $
;;; $Revision: 1.38 $ $Date: 2005/12/12 12:49:14 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Functions connecting the dataflow graph functionality and 
;;;              stream representation in lisp with Amosql functions.
;;;              
;;; ===========================================================================


;; STREAM objects representation
;; properties: name, source, dest, tag, descr

;; Foreign function to create new stream object from AmosQL
(defun register-stream (strtype id saddr daddr kind &optional logname)
  "Internal function to create stream object of corresponding subtype with id, source and destination address and comm. kind. All parameters are atoms"
  (let (strobj)
    (setq strobj (createobject (gettypenamed strtype) id ))
    (putobject strobj 'source  saddr)
    (putobject strobj 'dest  daddr)
    (putobject strobj 'tag (mkatom (concat strtype "WINDOW")))
    (putobject strobj 'kind  kind)
    (putobject strobj 'descr (create-descr strobj))
    (if logname (putobject strobj 'logname logname))
  strobj)
)

(defun register-streamfn (fno strtype streamid saddr daddr kind strobj)
  "Creates stream object of corresponding subtype with id, source and destination address and kind. Foreign function, all parameters strings"
  (let (strobj (b (get-registered-box (mkatom saddr))))
    
    (setq strobj (register-stream (mkatom strtype) (mkatom streamid)
				(mkatom saddr) (mkatom daddr) (mkatom kind)))
    (if b (add-producer b strobj))
    (osql-result strtype streamid saddr daddr kind strobj)
))



(defun register-stream1fn (fno strtype streamid saddr daddr kind logname strobj)
  "Creates stream object of corresponding subtype with id, source and destination address and kind. Foreign function, all parameters strings"
  (osql-result strtype streamid saddr daddr kind 
	       (register-stream (mkatom strtype) (mkatom streamid)
		 (mkatom saddr) (mkatom daddr) (mkatom kind)(mkatom logname))
))


(defun register-query (id fnname str_args args) 
"Function called locally in WN to install a query with qid, function
to be executed fnname on arguments args and stream sources str_args.
First make an operation box."

(let (b paraml stmt fnres restpnm outstr) ;; create an operator box 
  (setq b (make_box id fnname))

    (setq paraml 
	  (mapcar 'get-str-named (arraytolist str_args)))
    
    (mapc (f/l  (str)
		(setf (box-inputstreaml b)
		      (putassoc str (make-lb) (box-inputstreaml b))))
    paraml)

    (setf (box-paraml b) (append2 paraml (arraytolist args)))
    ;; find the resolvent
    (setq fnres (get-most-specific-resolvent fnname 
				     (mapcar 'arg-type (box-paraml b))))
    ;; put function resolvent as operation
    (setf (box-operation b) fnres)
   
   (setf (box-init b) 'prepare-AmosQL-box)
   (setf (box-cleanup b) 'close-AmosQL-box)

  ;; add the box into the structure(hash table) for all installed boxes
    (register-box b)
  
))

(defun register-queryfn (fnobj id fnname args str_args)
  (register-query (mkatom id) (mkatom fnname) str_args args)
 (osql-result id fnname args str_args t)
)


(defun derive-box-result-type (b)
"Derive the type of the result stream of box b. Return atom - typename"
  (let (restpnm outstr
		(fn (box-operation b)))

   (cond ((amosql-box-p b) 
	  ;;the operation is function resolvent
	  (setq restpnm (getobject (car (getobject fn 'restypes)) 'name))
	  (setq outstr (packlist 
			(reverse (nthcdr 6 (reverse (explode restpnm)))))))
	 ;; type of the merge result is = type of each of the inputs, that must
	 ;; be the same
	 ((and (lisp-box-p b) (equal fn 'tsmerge))
	  (setq outstr 
		(getobject (arg-type (caar (box-inputstreaml b))) 'name)))
	 ((and (lisp-box-p b) (equal fn 'chop))
	  (setq outstr 
		(getobject (arg-type (caar (box-inputstreaml b))) 'name)))
	 ;; type of the combined result must be given explicitly
	 ((and (lisp-box-p b) (equal fn 'tsjoin))
	  (setq outstr (cadr (box-paraml b)))))
   outstr
))



(defun register-producer1fn (fnobj pid qid dest kind logname strobj)
"Create producer with pid of the query qid, to the destination dest of kind kind."
  (let*  ((b (get-registered-box (mkatom qid)))
	  (p (mkatom pid)) 
	    outstr strobj)

    (setq outstr (derive-box-result-type b)) ;; the type of the output stream

     ; the source of producer is the id of query computing the result
    (setq strobj (register-stream outstr p (mkatom qid)
			  (mkatom dest) (mkatom kind) (mkatom logname)))

    ;; add the new producer to the outputstreaml of the box qid, even dynamic
    (add-producer b strobj)
    (osql-result pid qid dest kind strobj)
))

(defun unregister-producerfn (fnobj pid t)
"Delete producer stream with pid."
  (let*  ((strobj (get-str-named pid))
	  (qid (getobject strobj 'source))
	  (b (get-registered-box qid)))
  
    ;; delete producer from the outputstreaml of the box qid, even dynamic
    (delete-producer b strobj)
    (osql-result pid t)
))


(foreign-lispfn activate_query ((charstring qid)) ((integer i))
(let (r)
  (setq r (activate-box  (get-registered-box (mkatom qid))))
  (print (concat  qid " activated ")) (print-timeval (gettimeofday))
(foreign-result (if r 1 0))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Foreign functions accessing logical element of the stream
;;; in the local query buffer

(defun currentWindowfn (fnobj str strel)
"Return single tuple from the stream str without side effect. Read the local 
window buffer for the query prepared _curbox_ "
	(let ((lbs (cdr (assoc str (box-inputstreaml _curbox_))))
	      ;; local buffer for str
	      w)
	  (if (null (lb-winsz lbs)) 
	      (progn (setf (lb-winsz lbs) 1)
		     (setf (lb-kind lbs) 'cnt)))
	  (setq w (and (lb-buf lbs) (car (lb-buf lbs))))

	  (if w (let ()
	      (setf (lb-n lbs) 1)
	      (osql-result str w)))
))

(defun slidingWindowfn (fnobj str sz st strwin)
 "Return window (vector of logical windows) from the stream str without side effect. Read the local window buffer for the query under preparation _curbox_ "
 (let ((lbs (cdr (assoc str (box-inputstreaml _curbox_))))
	      ;; local buffer for str
	      w)
	  (if (null (lb-winsz lbs))
	      (progn
		(setf (lb-winsz lbs) sz)
		(setf (lb-kind lbs) 'cnt)
		;; fixed sch period , fixed No repetitions- set the source rep
	  	(if (and (equal (getobject str 'kind) 'MATR)  
			 _turn-around_)
		    (progn 	(formatl t "window " str sz)
			 (setf (box-rep (get-registered-box 
					 (getobject str 'source))) sz)
			 )
		       )))

	  (if (>= (length (lb-buf lbs)) sz)
	      (let ((l (lb-buf lbs)))
		(setq w (make-array sz))
		(dotimes (i sz) (seta w i (car l)) (pop l))))

	  (if w (let ()
	      (setf (lb-n lbs) st)
	      (osql-result str sz st w)))
))


(defun add-time (tmval len)
"Return timeval after len time from tmval."
(let ((sec (+ (timeval-sec tmval) (round len)))
      (usec (timeval-usec tmval))
      (usec1 (* (mod len 1.0) 1000000))
      pr)

  (setq usec (+ usec usec1))

  (setq pr (round (/ usec 1000000)))
  (setq usec (round (mod usec 1000000)))
 
  (mktimeval (+ sec pr) usec)
))
  

(defun timeWindowfn (fnobj str span strwin) 

"Reads next logical window with tsn from stream str and returns the
time window (vector of logical windows) that is closed by the new
log. window: ts1 to tsn-1, if tsn-span>ts1. The time window is
processed by the SQF and after that all old tuples tsi<tsn-span are
expired since they will not participate in the next time window ending
at tsn."

  (let* ((lbs (cdr (assoc str (box-inputstreaml _curbox_)))) 
	          ;; local buffer for str
         w (n 0)  ;; no of windows to expire
	 (l (lb-buf lbs)))  ;; log. windows in the buffer

    (cond ((null (lb-winsz lbs)) ;; first call, win is not set yet
	   (setf (lb-winsz lbs) span)
	   (setf (lb-kind lbs) 'time))
	  
	  ((and l (< (wallclocktime (get-time-stamp (car l))
				    (get-time-stamp (car (last l))))
		     span))  ;; the window does not cover entire span
	   nil)

	  ((let* ((stop-tm (get-time-stamp (car (last l))))
                                      ;timeval, ts closing w!
		 (k (- (length l) 1)) ;; no of windows in time window
		 (w (make-array k)))
	     ;; form a window 
	     (dotimes (i k) 
	       (seta w i (car l)) 
	       (if (> (wallclocktime (get-time-stamp (car l)) stop-tm) span)
		   (setq n (1+ n)))
	       (pop l))))
	  )
	    
    (if w (let ()
	    (setf (lb-n lbs) n)
	    (osql-result str span w)))
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(foreign-lispfn dump_gsdm ()()
		(formatl t _amosid_ t "Streams" t)
		(dump-streams)
		(formatl t t "Boxes" t)
		(dump-boxes)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; AmosQL interface functions to create op. boxes for special Lisp 
;;;;; operations tsmerge and tsjoin
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun register-merge (id str_args tm)
"Function called locally in WN to install a lisp box with merge operation
 with id,  stream sources str_args to be merged and the output stream."
  (let  (b paraml outstr)
  
    ;; create dataflow box with operation
    (setq b (make_box id 'tsmerge))

    (setq paraml 
	  (mapcar 'get-str-named (arraytolist str_args)))
    
    (mapc (f/l  (str)
		(setf (box-inputstreaml b)
		      (putassoc str nil (box-inputstreaml b))))
    paraml)

    (setf (box-paraml b) (list tm))
    (setf (box-type b) 'lisp)
    ;; merge result type the same as the input streams type
	
 ;;  (setq outstr (getobject (arg-type (caar (box-inputstreaml b))) 'name))
    
  
   (setf (box-init b) 'init-tsmerge)
   (setf (box-cleanup b) 'cleanup-tsmerge)
 ;;  (setf (box-cleanup b) ?)

  ;; add the box into the structure(hash table) for all installed boxes
    (register-box b)
))

(defun register-mergefn (fno id str_args tm)
  "Creates lisp box with tsmerge operation. Merges streams in str_args
  parameter. Foreign function, parameters 2 strings and a real"

 (register-merge (mkatom id) str_args tm)
)


(defun register-operatorfn (fnobj id fnname str_args args) 
"Function called locally in WN to create an operator box depending on
the type."
   (cond ((equal fnname "S-Merge")
       (register-merge (mkatom id) str_args (aref args 0)))

      ((equal fnname "OS-Join")
       (register-tsjoin (mkatom id) str_args (aref args 0)))

      (t (register-query (mkatom id) (mkatom fnname) str_args args))
      )
     (print (concat  id " " fnname " installed ")) 
)


;;;;;;;;;;;; TSJOIN ;;;;;;;;;;;;;;;;;;;;;;;;

(defun register-tsjoin (id str_args comb)
"Function called locally in WN to install a lisp box with timestamped join
 operation with id, stream sources str_args to be joined and the output stream.Eventually the function combining data can be a parameter."
  (let  (b paraml restype)
  
    ;; create dataflow box with operation
    (setq b (make_box id 'tsjoin))

    (setq paraml 
	  (mapcar 'get-str-named (arraytolist str_args)))

    (setq restype (getobject (arg-type (car paraml)) 'name))
    
    (mapc (f/l  (str)
		(setf (box-inputstreaml b)
		      (putassoc str nil (box-inputstreaml b))))
    paraml)

;;    (setf (box-paraml b) nil)
    (setf (box-paraml b) (list  (mkatom comb) (mkatom restype)))
    (setf (box-type b) 'lisp)
    ;; join result type is the same as the input streams type
	

   (setf (box-init b) 'init-tsjoin)
   (setf (box-cleanup b) 'cleanup-tsjoin)

  ;; add the box into the structure(hash table) for all installed boxes
    (register-box b)
))

(defun register-tsjoinfn (fno id str_args comb)
"Creates lisp box with tsjoin operation. Join streams in str_args on
equal timestamp. Comb is a name of function how to combine
streams. restype is the result stream type. Foreign function, all
parameters strings"

 (register-tsjoin (mkatom id) str_args comb)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; CHOP
(defun register-chop (id str_arg n)
"Function called locally in WN to install a lisp box with chop operation
 with id,  stream source str_arg and number of chops n"
  (let  (b paraml outstr)
  
    ;; create dataflow box with operation
    (setq b (make_box id 'chop))
    
    (setf (box-inputstreaml b)
	  (putassoc (get-str-named str_arg) nil (box-inputstreaml b)))
   
    (setf (box-paraml b) (list n))
    (setf (box-type b) 'lisp)
    ;; result type isthe same as the input stream type with smaller dimensionality
   (setf (box-init b) 'init-chop)
   (setf (box-cleanup b) 'cleanup-chop)

  ;; add the box into the structure(hash table) for all installed boxes
    (register-box b)
))

(defun register-chopfn (fno id str_arg n )
"Creates lisp box with chop operation. id and str_arg are strings,n is integer"

 (register-chop (mkatom id) str_arg n)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun print-function-profiles-a (file)
"Same as print-function-profiles but appends to the output file"
   (with-file str file
	      (if (not (null *profiled-fns*))
		  (progn
		    (formatl str t "Function profiles: " t) 
		    (dolist (f *profiled-fns*)
		      
		      (let ((calls (or (getprop f 'calls) 0))
			    (tm (or (getprop f 'time) 0)))
			(formatl str f ": Time: " tm
				 " Calls: " calls ", Avg: " 
				 (if (eq tm 0) '- (roundto (/ tm calls) 
						(1+ _clock_resolution_)))
				 t)))
		    ))
    "a"))

(defun print-image-size (file)
   (with-file str file
      (let ((exp (- _end-imagesize_ _start-imagesize_)))
	(if (> exp 0)
	    (progn
	(formatl str t "Initial image size " _start-imagesize_ )
	(formatl str " End image size " _end-imagesize_  )
	(formatl str " Expansion by " (/ exp  _MB_) " MB" t)
	)))
      "a"))

(foreign-lispfn clear_all_stat () ()
(clear-all-stat))

(foreign-lispfn print_box_stat ((charstring fname)) ()
(print-box-stat fname))

(foreign-lispfn print_stream_stat ((charstring fname)) ()
(print-stream-stat fname))

(foreign-lispfn print_sched_stat ((charstring fname)) ()
(print-exec-statistics fname))

(foreign-lispfn print_image_size ((charstring fname)) ()
(print-image-size fname))

(foreign-lispfn print_fn_profiles ((charstring fname)) ()
(print-function-profiles-a fname))
