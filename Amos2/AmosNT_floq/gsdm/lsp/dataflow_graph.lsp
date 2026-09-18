;; ===========================================================================
;;; AMOS2 - GSDM project
;;; 
;;; Author: (c) 2003 Milena Ivanova, UDBL
;;; $RCSfile: dataflow_graph.lsp,v $
;;; $Revision: 1.51 $ $Date: 2006/01/20 17:53:54 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Dataflow graph implementation.
;;;              Boxes with operations and stream buffers connecting them.
;;;              CQ execution engine 
;;;              
;;; ===========================================================================

(defglobal _exp-avg_ 0.1) ;;parameter used for exponential average

(defglobal _max-util_ (min (util (* _max-buf-size_ _max-buf-util_)) 0.99))
(defglobal _min-util_ 0.5)
(defglobal _completed_ nil) ;; flag for completion report
(defglobal _box-exec-stat_ nil) ;; associative list for box execution stat
(defglobal _min-interrupt_ 2.0) ;; variable to detect interrupt of execution
(defglobal _max-exec-cnt_ 100) ;; system variable to stop CQ query after fixed number executions, overrided by run_test parameter

(debugging t)

;;; A box is single operation to be scheduled and executed by a GSDM CQ server

(defstruct box
  id ; box id
  operation; name of the function to execute, always applied on the input streams
  paraml ; parameters,e.g. window size
  init  ; init operation if there is a datasource to initialize
  cleanup  ; cleanup operation, e.g. close the streams
  overflow ; overflow management ?
  type ;Type of the operation, AmosQL or Lisp now
  inputstreaml ;assoc list of input streams and theirs window buffers
  outputstreaml ; list of result stream objects (producers)
  stop  ;; rate used for scheduling the operation, rate<=maxrate
        ;; upper limit for the real execution rate
  cost ;; should be time for single call if big enough to be measured
      ;; can be estimated by = 1/maxrate or  box-time/ stat-cnt
  time ;; total time spent for execution: time/stat-cnt = cost per execution
  stat  ;; structure to collect statistics
       ;; cnt and last updated for each call,
       ;; pt0, pcnt set by system box buf-man
  rep ;; number repetitions used by the scheduler
  sched ;; function to decide the number of executions  (mymin of str)
  conseq_exec ;; boolean value used by the scheduler, if T many executions
		;can be scheduled together
  )

;; There is 1 local buffer for each input stream of the query box
;; Local buffers kept in assoc list inputstreaml of the box

(defstruct lb ;; local buffer
  winsz ; number of elements in the window
  buf ; list of elements - tuples
  n ; number of processed elements in the buffer to be dropped after the query
  slide ;size of sliding step for sliding window
  kind;
)

(defun make_box (id op)
(make-box :id id :operation op 
  :type 'amosql :stat (init-stat) :time 0.0
  :sched 'mymin :conseq_exec T))
;;rate, maxrate and cost are nil at the beginning



(defun make-lisp-box (id op)
(make-box :id id :operation op  :type 'lisp 
  :stat (init-stat) :time 0.0 :conseq_exec T))


(defun lisp-box-p (b)
  (eq (box-type b) 'lisp))
(defun amosql-box-p (b)
  (eq (box-type b) 'amosql))

(defun dump-box (b)
  (formatl t (box-operation b) " " (box-paraml b) t
 (box-inputstreaml b) " Time " (box-time b) t )
  (formatl t (print-statistics (box-stat b))t)
)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Boxes are organized in:
;; 1)hash table with all installed boxes, key - CQ id _installed-boxes_ 
;; 2)list of active boxes that are executed in an order defined by the list

;;; Global hash table of installed query boxes, key - qid
(defglobal _installed-boxes_ (make-hash-table :test 'equal)) 

(defglobal _curbox_ nil)

(defun activebox? (b)
"Check if a box is in the _activeboxlist_"
(member b _activeboxes_)
)


(defun add-active-box (newbox)
"Add newbox at the end of _activeboxes_"
   (setq _activeboxes_ (nconc1 _activeboxes_ newbox)))
 

(defun drop-active-box (boxid)
"Drop box from the boxlist bl"
(let ((l _activeboxes_)
      newl)
  (dolist (b l)
    (if (not (equal (box-id b) boxid))
	(setq newl (append newl (list b)))))

  (setq _activeboxes_ newl)
))


(defun dump-activeboxlist ()
  (let ((l  _activeboxes_))
    (mapc 'dump-box l)
))

(defun dump-boxes ()
  (maphash (f/l (k b)
		(formatl t k " : " t (box-operation b) )
		(formatl t  " " (box-paraml b) t (box-inputstreaml b) t)
		(formatl t "Exec time " (box-time b) " Cost per exec " 
		  (if (equal (stat-cnt (box-stat b)) 0) '- 
		    (/ (box-time b) (stat-cnt (box-stat b)))) t)
		(formatl t (print-statistics (box-stat b)) t ))
	   _installed-boxes_)
)



(defun register-box (b)
"Put a query box into the hash table"
   (puthash (box-id b) _installed-boxes_ b))

(defun get-registered-box (qid)
"Get a query box associated with the qid"
   (gethash qid _installed-boxes_))

(defun unregister-box (qid)
"Remove a query box from the hash table when the query is uninstalled"
   (remhash qid _installed-boxes_ ))

(defun set-box-rep (qid n)
(setf (box-rep (get-registered-box qid)) n))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Box rate measurement and controll
;; function names contain bstat to imply box-statistics



(defun update-exec-stat (what num)
  (puthash  _period-no_ _exec-stat_ 
	    (append2 (gethash _period-no_ _exec-stat_)
		     (list (list what num (gettimeofday)))))
)


(defun update-bstat (st k)
"Update stat structure st for box execution with k result data.
Update only cnt and last slots. Called for every box execution."
(let* ((tnow (gettimeofday)))

   (if (eq (stat-cnt st) 0) ;; first box call
       (setf (stat-t0 st) _bstart_)) ;;set by the sch. before box exec
	         
   (setf (stat-last st) tnow)
   (setf (stat-cnt st) (+ (stat-cnt st) k))
   
   ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Box execution

(defun add-producer (b strobj)
  (let ()
    (if (not (member strobj (box-outputstreaml b)))
	(setf (box-outputstreaml b)
	      (cons strobj (box-outputstreaml b))))
    (if (activebox? b)
	(apply (descr-open (getobject strobj 'descr)) (list strobj)))
    )
)

(defun delete-producer (b strobj)
  (let ()
    (setf (box-outputstreaml b)
	  (delete strobj (box-outputstreaml b)))
    (if (activebox? b)
	(apply (descr-close (getobject strobj 'descr)) (list strobj)))
    ))

(defun prepare-AmosQL-box (b)
  (let (( insl (mapcar 'car (box-inputstreaml b))) 
	(outl (box-outputstreaml b)))
    (mapc (f/l (s) (apply (descr-open (getobject s 'descr)) (list s))) insl)
;; prepare the output streams 
    (mapc (f/l (s) (apply (descr-open (getobject s 'descr)) (list s))) outl)   
    ;(apply (descr-open (getobject out 'descr)) (list out)) 
))

(defun close-AmosQL-box (b)
  (let ((insl (mapcar 'car (box-inputstreaml b))) 
	(outl (box-outputstreaml b)))
    (mapc (f/l (s) (apply (descr-close (getobject s 'descr)) (list s))) insl)

;; close the output streams 
    (mapc (f/l (s) (apply (descr-close (getobject s 'descr)) (list s))) outl)
))

;;; execution of box with lisp function
;;; ! OBS! Only for lisp functions without stream processing
(defun exec-Lisp-box (b)
  (let (res inputs)

     ;;read data from input stream buffers and put them into window buffers
     ;; where window function will get them
;;     (setq inputs (box-inputstreaml b))
;;     (mapc (f/l (s) 
;;		  ;; s is (cons strname strwbuf)
;;		  (let (w)
;;		  (setq w (buf-read (get-strbuf (car s)) (box-id b) 1))
;;		 (setf (box-inputstreaml b)
;;		  (putassoc (car s) w (box-inputstreaml b)))))
;;	     inputs)
     
     ;;; execute operation
     (setq res (apply (box-operation b) 
	   (box-paraml b)))
;;     (if  res
;;	 (progn (update-bstat (box-stat b) 1)
;;		(update-exec-stat (box-id b) (stat-cnt (box-stat b)))))
     ;; update with 1 for each call
;; How does result look like?
  ;;    (mapc (f/l (tpl) (buff-results tpl b)) res)  
))

;;;execution of box with AmosQL function defined on stream objects
(defun exec-Amosql-box (b)
   (let ((insl (mapcar 'car (box-inputstreaml b))) 
	 (outl (box-outputstreaml b)) 
	;(out (get-str-named (box-id b)))
	res startpush)

     ;;read data from input stream buffers and put them into the 
     ;; local window buffers where window function will get them
      (mapc (f/l (s) 
	  ;; s is strobj
	(let ((lbs (cdr (assoc s (box-inputstreaml b))))
	      el)
	  (cond ((null (lb-winsz lbs)))  ;; no info what to do
		
		((equal (lb-kind lbs) 'CNT) ;; count-based window
		 (dotimes (i (- (lb-winsz lbs) (length (lb-buf lbs))))
		   (setq el 
			 (apply (descr-get (getobject s 'descr)) (list s)))
		   (if el (setf (lb-buf lbs) 
				(append2 (lb-buf lbs) (list el))))
		   ))
		
		((equal (lb-kind lbs) 'TIME) ;; time-based window
		  ;; get 1 log window and let time window fun to check it
		 (setq el (apply (descr-get (getobject s 'descr))(list s)))
		 (if el (setf (lb-buf lbs) 
			      (append2 (lb-buf lbs) (list el))))
		   )
		))
	)
	    insl)
     ;;; execute operation
     (setq res (getfunction (box-operation b) 
	   (box-paraml b)))
    
     (setq startpush (gettimeofday))
     (mapc (f/l (out)
		(mapc (f/l (restpl) 
			   (apply (descr-put (getobject out 'descr))
				  (list out (car restpl))))
		      res))
	   outl)
     (setq _push-time-sched_ (+ _push-time-sched_ 
				(wallclocktime startpush (gettimeofday))))

     (if  res (update-bstat (box-stat b) (length res)))

     ;;Clean local input buffers from data processed
     (mapc (f/l (s)   ;; s is strobj
		(let ((lbs (cdr (assoc s (box-inputstreaml b)))))
		  (cond ((lb-n lbs)
			 (setf (lb-buf lbs) (nthcdr (lb-n lbs) (lb-buf lbs)))
			 (setf (lb-n lbs) nil)))))
	   insl)
))

(defun execbox (b)
  (cond ((lisp-box-p b) (exec-lisp-box b))
	((amosql-box-p b) (exec-amosql-box b))
))



(defun activate-box (b)
"Execute the box initialization and put it to the _activeboxlist_"
  (resetvar _curbox_ b
    (apply (box-init b) (list b))
    (add-active-box b)
    (setf (box-stat b) (init-stat))
))

(defun deactivate-box (b)
"Execute the box cleanup and drop it from the _activeboxlist_"
    (resetvar _curbox_ b 
	      (apply (box-cleanup b) (list b))
	      (drop-active-box (box-id b))
))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; System management box:
;; - cleans stream buffers
;; - scans activeboxlist and collects box execution rates
;;      (new period tripple in stat-rate)
;; - calculates measured-rate - exponential formula for mrate?
;; - store lists (box-id ((input-rate buf-size maxrate)..) mrate maxrate)
;;    in a global variable - assoc list on box-id
;; - analyse the lists to find whether an adjustment is needed
;; Has associated rate to not be executed too often to minimize the
;; overhead
;; Can be called in addition (or part of it ?) if 
;; - other node ask for statistics or change in execution/pushing rates


;;TO DO extend buf-man with overflow management

(defun buf-man ()
"Part of buffer-manager module. Cleans all stream buffers from consumed data"
(let ((sl (osql "select s from stream s;")))

(mapc (f/l (s)
	   (if (get-buf (car s)) (buf-clean (get-buf (car s)))))
 sl)))

(defun register-completing ()
(send-message 
	(list 'osql (concat "gsdm_completing('" _amosid_ "');" ))
	 'STATSRV)
)


(defun check-for-exit ()
  (let ((nas 0) st ; number of active streams
;;	(l (boxlist-first _activeboxlist_))
	(l _activeboxes_)
	(nab 0))  ;number active boxes
    ;; count boxes in the _activeboxes_ not executed at all or 
    ;; executed at least once during the last 5 sec.
    ;; if the box has not reach the max number executions 
    ;;but does not have input data to execute - stop the loop after some time
    ;; if the box has not been executed at all - keep waiting
    ;; _cd_ always active -nab>=1

  (mapc (f/l (b)
	     (let ((ls (stat-last (box-stat b))))
	       (cond ((null ls) (setq nab (1+ nab)))
		     ((eq (box-id b) 'CD) (setq nab (1+ nab)))
		     ((< (wallclocktime ls (gettimeofday)) 5.0)
		      (setq nab (1+ nab))))))
	l)

  (mapextent (gettypenamed 'stream)
     (f/l (s)
	  (if (and (setq st (getobject (car s) 'stat))
		   (< (wallclocktime (stat-last st) (gettimeofday)) 5.0))
	      (setq nas (1+ nas)))))

  (if (and (<= nab 1) (eq nas 0)) 
     ;; (setq _keep-running_ nil))
      (if (null _completed_)
	  (let ()
;;      (setq _cq-server_ nil)
	    (register-completing)
	    (setq _completed_ T)
	    (setq _end-imagesize_ (imagesize))
;;    (mapc (f/l (b)
;;		 (print (box-id b))
;;		 (print (stat-last (box-stat b))))
;;	    l)
	    (print (concat "CQ server completed "  (print-timeval (gettimeofday))))
      ))
    (setq _completed_ nil))
  ))



(defun sys-man ()
  (let ()
    (buf-man)
    (check-for-exit)
   t
))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun clear-box-stat ()
  (maphash (f/l (k b)
		(setf (box-stat b) (init-stat)))
	   _installed-boxes_)
)

(defun clear-all-stat ()
  (let ()
    (clear-box-stat)
    (clear-stream-stat)
    (clear-function-profiles)
))

(defun print-box-stat (file)
   (with-file str file
      (let ()
	(formatl str t "Boxes" t)
	(maphash (f/l (k b)
		      (let ((st (box-stat b)) wt)
	      (formatl str k " : Count " (stat-cnt st) 
		       " Sched rep " (box-rep b) 
		       t (box-operation b))
	      ;; my profiling of the box 
	      (formatl str t "Exec time " (box-time b) " Cost per exec " 
		  (if (equal (stat-cnt st) 0) '- 
		    (/ (box-time b) (stat-cnt st))) t)
	      ;; statistics based on total elapsed time
;;	      (if (null (eq (box-id b) 'CD))
;;		  (let ()
	   ;;   (formatl str "Total elapsed time " 
;;		(and (stat-t0 st) 
;;		     (setq wt (wallclocktime (stat-last st) (stat-t0 st))) wt)
;;		" Avg rate " 
;;		(if (or (null wt)(equal wt 0.0)) '- (/ (stat-cnt st) wt)) t)

;;	      (formatl str "Exp aggregated rate "  (get-exp-avg-rate st) 
;;		       "  History rate "  (stat-rate-hist st) t)
;;	      (formatl str "First " (stat-t0 st) t)
;;	      (formatl str "Last " (stat-last st) t)))
	      ;; For TCP producers, print throughput on the socket
	      (dolist ( p (box-outputstreaml b))
		(if (equal 'TCP (getobject p 'kind))
		    (formatl str (getobject p 'name) " -> "
			     (getobject p 'dest) " : "
			     (socketstat (port-socket 
				  (get-port-named (getobject p 'dest)))) t)))
	      ))
		 _installed-boxes_))
      "a"))

