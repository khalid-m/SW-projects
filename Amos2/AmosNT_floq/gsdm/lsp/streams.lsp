;;; ============================================================
;;; AMOS2, GSDM
;;; 
;;; Author: (c) 2004 Milena Ivanova, UDBL
;;; $RCSfile: streams.lsp,v $
;;; $Revision: 1.3 $ $Date: 2006/01/20 17:53:54 $
;;;
;;; Description:  Stream elements internal representation as tuples
;;;    1) Define window type under literal
;;;    2) Define stream element type under window
;;;    3) Define function constructor for tuple instances and 
;;;        functions-accessors of fields in a tuple
;;;    4) constructor for stream subtype
;;;    5) constructor for stream object
;;;    6) GSDM stream interface functions
;;; =============================================================

(defun amos_print_window (tpl str)
  (let ((data (cdr tpl)))
  (formatl str (car tpl) "(" (aref data 0))
  (dotimes (i (1- (array-total-size data)))
    (formatl str "," (aref data (1+ i))))
  (formatl str ")") ; no CR after
  t ; Success!
  ))

(createliteraltype 'WINDOW (list 'literal) 'WINDOW 
		   #'amos_print_window)

(defun make-window (stp data)
"Make a stream element - literal obj of type stp and data (array) "
    (cons (getobject stp 'name) data)
)

(defun window? (tpl)
(osql-subtypep (gettypenamed (car tpl)) (gettypenamed 'WINDOW)))

(foreign-lispfn window ((type stp) (vector data)) ((window c))
	(foreign-result (make-window stp data)))

(putprop 'window 'aggfn 'make-window) ; how to make constant 

(SET-PRINTFN (gettypenamed 'WINDOW) 'amos_print_window)

(defun fieldfn (fnobj tpl pos obj)
  (osql-result tpl pos (aref (cdr tpl)  pos)))

(osql "create function field(window t, integer pos)-> object as
foreign 'fieldfn';")

;; w is of type window
(defun get-time-stamp (w)
(aref (cdr w) 0))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun stream-elementp (stp se)
"Check if se is literal object of stream element type stp"
(if (equal (getobject stp 'name) (car se)) t nil))

(defun create-window-constructors (tp)
"Create Amosql function constructor for tuples of the stream element type tp"

  (let ( stmt (tpname (getobject tp 'name)) ; stream element type name 
	 tparr n argl)
     (setq stmt (concat "create function "  
			tpname
			"(vector data)-> " tpname
	 " as select cast( window(" tp ", data) as " tpname ") ;"))
	(amos-execute stmt)

;;constructor on tuple of components
	(setq tparr (getobject tp 'schema-types))
	(setq n (length tparr))
	(setq argl "")
	(dotimes (i (1- n))
	  (setq argl (concat argl (aref tparr i) " V" i ", ")))
	(setq argl (concat argl (aref tparr (1- n)) " V"  (1- n)))

	(setq stmt (concat "create function " tpname "(" argl ")-> " tpname))
	(setq argl "")
	(dotimes (i (1- n))
	  (setq argl (concat argl "V" i ",")))
	(setq argl (concat argl "V" (1- n)))
	
	(setq stmt (concat stmt " as select " tpname "(vector(" 
			   argl
			   "));" ))
	(amos-execute stmt)
))	


(defun create-datafield (eltp nm fntp pos)
"Create Amosql function with name nm over tuple type eltp, returning result of type fntp that is at position pos in the vector, representing the tuple"
  (let (stmt)
     (setq stmt (concat "create function "  nm "(" (oid-name eltp) " se)-> " 
	fntp " as select cast(field(se," pos ") as " fntp  ");"))
	(amos-execute stmt)))	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Stream subtype associated with particular tuples (logical record)

(defun create-stream-access-functions (stpname eltpname)

"Create interface Amosql functions to access logical element and window over
new stream subtype.  Defined on stream subtype with name stpname and elements of type named eltpname"

  (let (stmt)
;; functions without side effect accessing internal stream buffer of the box
;; to be used inside the CQ specification
    (setq stmt (concat "create function slidingWindow(" stpname " s,
                       integer sz, integer st)->
                 vector of " eltpname " v as foreign 'slidingWindowfn';"))
    (amos-execute stmt)
    (setq stmt (concat "create function currentWindow(" stpname " s)->
                 " eltpname " x as foreign 'currentWindowfn';"))
    (amos-execute stmt)
    (setq stmt (concat "create function timeWindow(" stpname " s,
                       real span, real st)->
                 vector of " eltpname " v as foreign 'timeWindowfn';"))
    (amos-execute stmt)
))


(defun create-stream-typefn (fno nm snames tnames stpobj)
  (let (stpobj eltpobj stpname eltpname)
    ()
    (setq stpobj (createtype nm (list 'STREAM)))
    ;; create stream element type- literal under window
    (setq eltpname (mkatom (concat nm "WINDOW")))
    (setq eltpobj (createliteraltype eltpname (list 'WINDOW) 
		  eltpname #'amos_print_window))

    (putobject eltpobj 'schema-names snames)
    (putobject eltpobj 'schema-types tnames)
    ;;create Amosql constructor function for tuples of this type
    (create-window-constructors eltpobj)
    ;; create amosql datafield functions to access fields in the tuple
    (dotimes (pos (array-total-size snames))
      (create-datafield eltpobj (aref snames pos) (aref tnames pos) pos))
    
    (create-stream-access-functions nm eltpname)
    
    (osql-result nm snames tnames stpobj)
))

(osql " create function create_stream_type(charstring tpname,
       vector of charstring snames,vector of charstring tnames)
        -> type tp as foreign 'create-stream-typefn';")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GSDM STREAM IMPLEMENTATION - internal representation in Lisp buffers  

;;; GSDM stream implementation functions- access the buffer associated with the stream object by prop buf

(defun create-buf (sz &optional gf)
"Create a new stream buffer with initial size of the heap sz"
 (buf-init sz gf))

(defun get-buf (str)
"Get a buffer associated with the stream object str"
   (getobject str 'buf))

(defun put-buf (str buf)
"Put stream buffer as property 'buf"
   (putobject str 'buf buf))


(defun dump-streams ()
(let ((sl (osql "select s from stream s;"))
      bf k)

(mapc (f/l (s)
	   (let ((str (car s)) st)
	     (formatl t (getobject str 'name) " : " t) 
	   (if (setq bf (get-buf str))
	       (progn 
		 (formatl t "Buffer : " 
			  "Head " (buf-head bf) 
			  " Tail " (buf-tail bf) 
			  " Cursors " (buf-cursors bf) t)

		 (setq k (min 100 (buf-size bf)))
		 (dotimes (i k)
		   (print (aref (aref (buf-heap bf)
			(mod (+ i (buf-head bf))(buf-heap-size bf))) 0)))

		 (if (setq st (getobject str 'stat)) (print-statistics st))
		 )
	     )))
      sl)))


(defun clear-stream-stat ()
  "Initialize stat property of all streams"
(let ((sl (osql "select s from stream s;")))

(mapc (f/l (s)
	   
	   (if (getobject (car s) 'stat)
	       (putobject (car s) 'stat (init-stat)))
      sl))))

(defun print-stream-stat (file)
   (with-file ostr file
	 (let* ((sl (mapcar 'car (osql "select s from stream s;")))
		(isl (mapfilter (function input-tcp-strp) sl))
		bf k)

	   (if isl
	       (progn 
	   (formatl ostr t "Input Streams" t)
	   
	   (mapc 
	    (f/l (str)
		 (let* ((st (getobject str 'stat)))
		   
		   (if st 
		       (let (wt)
		   (formatl ostr (getobject str 'name) " : " ) 
		   (formatl ostr t "Count " (stat-cnt st) t)
		   (formatl ostr "Total elapsed time " 
			    (and (stat-t0 st) 
				 (setq wt (wallclocktime (stat-last st)
							 (stat-t0 st))) wt)
			  ;;  " Avg rate " 
			  ;;  (if (or (null wt)(equal wt 0.0)) '- 
			  ;;    (/ (stat-cnt st) wt)) t
			    t  "Avg inter arrival interval "
			    (if (equal (stat-cnt st) 0) '-  
			      (/ wt (stat-cnt st)))
			     t)

		;;   (formatl ostr "First " (stat-t0 st) t)
		;;   (formatl ostr "Last " (stat-last st) t t)
		   ))))
	    isl))))
	 "a"))

;;; GSDM STREAM INTERFACE functions called by CQEE

(defun gsdm-open (str)
"Opens an internal stream str (OID). Called for all gsdm input streams when query is started or restarted."
  (if (null (get-buf str))
    (putobject str 'buf (create-buf 1000)))
  ;; add cursor for the query that opens the stream if it is input stream
  (if (assoc str (box-inputstreaml _curbox_))
  (add-buf-cursor (get-buf str) (box-id _curbox_)))
  
;;    (if _statistics_ 
   (putobject str 'stat (init-stat))
)

(defun gsdm-get (str)
"Get next element from the internal stream str (OID)"
      ;; buf-read returns list of vectors-> first el-> tagged
(let ((l (buf-read (get-buf str) (box-id _curbox_) 1)))
  (if l (cons (getobject str 'tag) (car l)))  ;;1 literal object 
))

(defun gsdm-put (str el) 
" Put single element(vector) in the buffer of the stream str.
el is (cons tag vectordata) but is put without tag"
(let ((lt (wallclocktime (aref (cdr el) 0) (gettimeofday))))
  (buf-put (get-buf str) (cdr el))
  (update-stat (getobject str 'stat) 1 lt)
  (update-exec-stat (getobject str 'name) (stat-cnt (getobject str 'stat)))
  t
))



(defun gsdm-close (str)
"Close the internal stream str (OID) for the query issuing the operation."
 (if (assoc str (box-inputstreaml _curbox_))
     (delete-buf-cursor (get-buf str) (box-id _curbox_)))
)

(defun get-rate (str)
"Exponential average rate of the stream object str of kind gsdm or input TCP, using stat structure"
(let ((st (getobject str 'stat)))
  (if st (get-exp-avg-rate st))))

;;;;;;;;;;;;;; PLAY interface
(defun player-put (str el) 
" Put single element(vector) in the buffer of the stream str. 
el is (cons tag vectordata)"
 (buf-put (get-buf str) (cdr el)) t)

(defun player-open (str)
"Opens a special internal stream containing stored signal str (OID).
Create a cyclic buffer by adding a 'DUMMY cursor. The signal is recorded in a function with name - source of the stream. Data in the buffer
are vectors"
  (let (sig n)
  (setq sig 
	(caar (getfunction (getfunctionnamed (getobject str 'source)) nil)))
  (setq n (array-total-size sig))
  (if (null (get-buf str))
      (let ()
	(putobject str 'buf (create-buf n))
	(setf (buf-cyclic (get-buf str)) t)

	(dotimes (i n)
	  (apply (descr-put (getobject str 'descr))
		 (list str (cons (getobject str 'tag)(aref sig i)))))
	))

   ;; add cursor for the query that opens the stream
  (add-buf-cursor (get-buf str) (box-id _curbox_))
))

(defun player-get (str)
"Get next element from the player stream str (OID). Refresh the timestamp as if the data just has arrived to avoid extra SQF for timestamping"
      ;; buf-read returns list of vectors-> first el-> tagged
(let ((l (buf-read (get-buf str) (box-id _curbox_) 1)))
  (if l (let ((el (car l)))
	  (seta el 0 (gettimeofday))
	  (cons (getobject str 'tag) el)))  ;;1 literal object 
))

(defun openplayfn (fno s t)
	(player-open s)
(osql-result s t)
)

(defun nextplayfn (fno s el)
(osql-result s (player-get s))
;(osql-result s (gsdm-get s))
)

(defun insertplayfn (fno s el t)
(osql-result s el (player-put s el))
)

(defun closeplayfn (fno s t)
  (gsdm-close s)
(osql-result s t)
)
;;;;;;;;;;;;;;;;;; STDOUT stream interface
(defun stdout-open (str) )
(defun stdout-close (str) )

(defun stdout-put (str el) 
" Print single element of the stream str"
   (print el))

(defun input-TCP-strp (str)
 (and (eq (getobject str 'kind) 'TCP)
      (eq (getobject str 'dest) _amosid_))) ;;input TCP stream

(defun output-TCP-strp (str)
 (and (eq (getobject str 'kind) 'TCP)
      (not (eq (getobject str 'dest) _amosid_)))) ;;output TCP stream

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; UDP Interface for radio streams

(defun udpradio-open (str)
   (if (null _udp-thread-started_)
       (setq  _udp-thread-started_ (udp-start-thread)))
   (if _udp-thread-started_
       (let ((saddr (mkstring (getobject str 'source)))
	     radio-stream-id) ;; source address
	 (setq radio-stream-id (udp-open 0 "" 0 "rw"))
	 (putobject str 'radio-stream-id radio-stream-id)
	 ;; current UDP radio source address     "130.238.30.114"
	 (putobject str 'radio-id (radio-open radio-stream-id saddr 4096))
	 ))
)

(defun udpradio-get (str)
  (let ((radio-id (getobject str 'radio-id))
	p1 p2 w)

    (setq p1 (cadddr (radio-get-from radio-id)))
    (setq p2 (cadddr (radio-get-from radio-id)))
    (setq w (radio-encode-win p1 p2))
    (if w 
	(progn 
	  (seta w 0 (gettimeofday))
	  (cons (getobject str 'tag) w))
      nil)
))

(defun udpradio-put (str el))

(defun udpradio-close (str)
 (let ((radio-id (getobject str 'radio-id)))
   (if radio-id (radio-close radio-id) t) 
;; TO DO check for other UDP streams before stopping the thread
   (udp-stop-thread)
   (putobject str 'radio-id nil) 
   (putobject str 'radio-stream-id nil)
))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; STREAM objects representation
;; properties: name, source, dest, tag, descr
;;
;; descr structure is a stream descriptor containing functions
;; to access a stream with particular implementation

(defstruct descr
  open; function opening the stream
  get ; function getting an element
  put ; putting an element
  close ; 
)


(defun create-descr (s)
  (let ((kind (getobject s 'kind))
	(dst (getobject s 'dest)))

  (cond ((eq kind 'MATR) ;;internal materialized stream
	 (make-descr :open 'gsdm-open
		     :get 'gsdm-get
		     :put 'gsdm-put
		     :close 'gsdm-close
	       ))
	((input-TCP-strp s) ;;input TCP stream
	 (make-descr :open 'gsdm-open  ;; lisp buffer
	       :get 'gsdm-get
	       :put 'tcp-put-input
	       :close 'gsdm-close
	       ))
	((output-TCP-strp s) ;;output TCP stream
	 (make-descr :open 'tcp-open  ;; no buffer
	       :get 'gsdm-get
	       :put 'tcp-put
	       :close 'gsdm-close
	       ))
	((eq kind 'UDPRADIO) ;;UDP stream
	 (make-descr :open 'udpradio-open
	       :get 'udpradio-get
	       :put 'udpradio-put
	       :close 'udpradio-close
	       ))
	((eq kind 'STDOUT) ;;internal to standard output stream
	 (make-descr :open 'stdout-open 
	       :put 'stdout-put
	       :close 'stdout-close
	      ))
	((eq kind 'PLAYER)
	 (make-descr 
	   :open 'player-open
	   :get 'gsdm-get
	   :put 'player-put
	   :close 'gsdm-close
	       ))

	(t
	;; other stream wrappers with AmosQL function definitions
	;; create function open(radiostream s)-> boolean as foreign openfn;
	 (make-descr 
	  :open (list 'lambda '(s) 
		    (list 'getfunction 
		     (get-most-specific-resolvent (mkatom (concat 'open_ 
						  (getobject s 'kind)))
				(list (arg-type s)))
		     '(list s)))
	  :get (list 'lambda '(s) 
			(list 'caar  
		    (list 'getfunction 
		     (get-most-specific-resolvent (mkatom (concat 'next_ 
						  (getobject s 'kind)))
				(list (arg-type s)))
		     '(list s))))
	  :put (list 'lambda '(s el) 
		    (list 'getfunction 
		     (get-most-specific-resolvent (mkatom (concat 'insert_ 
						  (getobject s 'kind)))
				(list (arg-type s) 
				      (gettypenamed (getobject s 'tag))))
		     '(list s el)))
	  :close (list 'lambda '(s) 
		    (list 'getfunction 
		     (get-most-specific-resolvent (mkatom (concat 'close_ 
						  (getobject s 'kind)))
				(list (arg-type s)))
		     '(list s)))
	       ))
)))

;;;;;;;;;;;;;;Registration of new stream interfaces

(defun register-stream-interface 
  (stpname intf openfn nextfn insertfn closefn)

"Create Amosql functions for stream interface intf for stream type stpname."

  (let (stmt)
;; open method implementation
    (setq stmt (concat "create function open_" intf "(" stpname 
                " s)-> boolean as foreign '" openfn "';"))
    (amos-execute stmt)
;; next method implementation
    (setq stmt (concat "create function next_" intf "(" stpname 
                " s)-> "	stpname "Window as foreign '" nextfn"';"))
    (amos-execute stmt)
;; insert method implementation
    (setq stmt (concat "create function insert_" intf "(" stpname 
                " s, " stpname "Window el)-> boolean as foreign '" insertfn"';"))
    (amos-execute stmt)
;; close method implementation
    (setq stmt (concat "create function close_" intf "(" stpname 
                " s)-> boolean as foreign '" closefn"';"))
    (amos-execute stmt)
))

(foreign-lispfn register_stream_interface 
		((charstring stpname) (charstring intf)
		 (charstring openfn) (charstring nextfn)
		 (charstring insertfn) (charstring closefn))
		((boolean))
	(register-stream-interface stpname intf openfn nextfn insertfn closefn)
(foreign-result)
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Latency stream
(defun latency-open (str)
"Initializes state for computing latency."
  (cond ((null (getobject str 'val))
	 (putobject str 'cnt 0)
	 (putobject str 'val 0.0)))
)

(defun latency-next (str))

(defun latency-insert (str el) 
" Updates the latency state with current element latency"
(let ((c (getobject str 'cnt))
      (v (getobject str 'val))
      (lat (wallclocktime (gettimeofday) (aref (cdr el) 0))))
  (putobject str 'cnt (+ c 1))
  (putobject str 'val (+ v lat))
  t
))


(defun latency-close (str)
"Close the latency stream and print the latency"
  (let ((c (getobject str 'cnt)) lat)
    (if (and c (> c 0))
	(setq lat (/ (getobject str 'val) c))
      (setq lat 9.999))
    (print lat)

    (send-message  ;; report to statsrv
	 (list 'osql (concat 
		"set_latency('" (getobject str 'source) "'," lat ");"))
	 'STATSRV)
))

(defun openlatencyfn (fno s t)
	(latency-open s)
(osql-result s t)
)

(defun nextlatencyfn (fno s el)
(osql-result s (latency-next s))
)

(defun insertlatencyfn (fno s el t)
(osql-result s el (latency-insert s el))
)

(defun closelatencyfn (fno s t)
  (latency-close s)
(osql-result s t)
)

;;;;;;;;;;; Info
(defun dump-all-streams ()
(let ((sl (osql "select s from stream s;")))

(mapc (f/l (tpl)
	   (let ((s (car tpl)))
	     (formatl t (getobject s 'name) " : " 
		      "Source " (getobject s 'source)
		      " Dest " (getobject s 'dest)
		      " Tag " (getobject s 'tag) t)))
      sl)))

(defun get-str-named (nm)
  (let ((name (mkatom nm)))
    (getobjectnamed name (gettypenamed 'STREAM))
))





