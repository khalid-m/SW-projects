(defglobal _logevent_ (gettypenamed 'logevent))

(set-no-extent _logevent_)

(defun stream-ntuples-+ (fno filename r)
  "Emit stream of CSV rows"
  (with-input-file
   s filename
   (mapstream
    s #'read-line
    (f/l (row)
       (with-textstream
        tstr row
        (let (v)
         (mapstream
          tstr #'(lambda (str) (read-token str ","))
          (f/l (o)
               (setq v (push-vector v o))))
         (osql-result filename v)))))))

(defun logevent-logfile (fno e)
  "Get log file of log event e"
  (when e
    (osql-result e (getobject e 'logfile))))

(defun logevent-prev (fno e)
  "Previous log event changing the variable as e"
  (when (and e (getobject e 'prev))
    (osql-result e (getobject e 'prev))))

(defun logevent-timestamp (fno e)
  "The computed time stamp for event" 
  (when e
    (osql-result e (getobject e 'timestamp))))

(defun logevent-measurement (fno e)
  "The stored attributes (var, ts, val) for e"
  (when e
    (osql-result e (getobject e 'measurement))))

(defun copy-logevent (e &optional keep-prev)
  "Make copy of log event"
  (let ((obj (create-transient-object _logevent_)))
    (putobject obj 'logfile (getobject e 'logfile))
    (putobject obj 'timestamp (getobject e 'timestamp))
    (putobject obj 'measurement (getobject e 'measurement))
    (when keep-prev
      (putobject obj 'prev (getobject e 'prev)))
    obj))

(defun ml:callfn1 (fn &rest args)
  "Call osql function"
  (car (getfunction-firsttuple (getfunctionnamed fn) args t)))

(defun ml:callfn1* (fn args)
  "Call osql function"
  (car (getfunction-firsttuple (getfunctionnamed fn) args t)))

(defun tv2real (tv)
  "Convert timeval to real number"
  (+ (timeval-sec tv) (* (timeval-usec tv) 0.000001)))

(defun measurement-logevents (fno logfilestream)
  "Emit the log events of a log file stream assumed to be sorted"
  (let ((prev-events (make-hash-table :test #'equal)))
    (mapbag 
     logfilestream
     #'(lambda (logfile)
	 (setf logfile (car logfile))
	 (when logfile
	   (let (logstart filename)
	     (osql-let 
	      ((logfile :lf) (charstring :filename) 
	       (timeval :logstart))
	      (setf amos_lf logfile)
	      (osql "select filename(:lf) into :filename;")
	      (osql "select property(:lf,'LogStartTime') into :logstart;")
	      (setf filename amos_filename)
	      (setf logstart amos_logstart))
	     (setf logstart (tv2real logstart))
	     (mapbag (ml:callfn1 
		      'charstring.stream_ntuples->stream-vector filename)
		     #'(lambda (vec)
			 (setf vec (car vec))
			 (when (string= (aref vec 0) "L")
			   (let ((obj (create-transient-object 
				       _logevent_)))
			     (putobject obj 'logfile logfile)
			     (putobject obj 'prev (gethash (aref vec 1)
							   prev-events))
			     (putobject obj 'timestamp (+ logstart 
							  (aref vec 2)))
			     (putobject obj 'measurement (vector 
							  (aref vec 1) 
							  (aref vec 2) 
							  (aref vec 3)))
			     (puthash (aref vec 1) prev-events 
				      (copy-logevent obj))
			     (osql-result logfilestream obj)))))))))))

(defun timevalize-string (str)
  "Convert a timeval to a string"
  (let ((space-pos (string-pos str " ")))
    (concat "|" (substring 0 (1- space-pos) str) "/" 
	    (substring (1+ space-pos) (length str) str) "|")))

(defun timevalize-+ (fno tvstr)
  "Convert a string to a timeval"
  (osql-result tvstr (caar (amos-execute (concat 
					  (timevalize-string tvstr) ";")))))

(defun mklogfile-+ (fno filename)
  "Create a new LOGFILE object representing file of log events"
  (osql-result filename
	       (or (getobjectnamed (mksymbol filename) 
				   (gettypenamed 'logfile) t)
		   (/createobject (gettypenamed 'logfile) 
				  (mksymbol filename)))))

(defun record-agg--+ (fno stream tsfn)
  "Implemenets record_agg(Bag stream, Function tsfn)-> Bag of Record"
  (let ((rec (make-record))
	buf ts-prev)
    (mapbag stream
	    #'(lambda (e)
		(if (or (null buf)
			(equal (ml:callfn1 tsfn (car buf)) 
			       (ml:callfn1 tsfn (car e))))
		    (push (car e) buf)
		  (progn
		    (dolist (b buf)
		      (let ((var (aref (getobject b 'measurement) 0))
			    (val (aref (getobject b 'measurement) 2)))
			(record-put rec var val)
			(record-put rec (concat var "-EVENT") b)))
		    (record-put rec "TS" (ml:callfn1 tsfn (car buf)))
		    (when ts-prev
		      (record-put rec "TS-PREV" ts-prev))
		    ;;(osql-result stream tsfn rec)
		    (osql-result stream tsfn 
				 (make-record 
				  (copy-array (record-fields rec))))
		    (setf ts-prev (record-get rec "TS"))
		    (setf buf e)))))
    (when buf
      (dolist (b buf)
	(let ((var (aref (getobject b 'measurement) 0))
	      (val (aref (getobject b 'measurement) 2)))
	  (record-put rec var val)
	  (record-put rec (concat var "-EVENT") b)))
      (record-put rec "TS" (ml:callfn1 tsfn (car buf)))
      (when ts-prev
	(record-put rec "TS-PREV" ts-prev))
      (osql-result stream tsfn (make-record (copy-array 
					     (record-fields rec)))))))
