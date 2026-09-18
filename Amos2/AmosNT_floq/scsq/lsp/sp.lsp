(defglobal _sp_ (CREATELITERALTYPE 'sp (list _object_) 'port))
(defglobal _hb-count_ 0)
(defglobal _flush-count_ 0)
(defglobal _int-count_ 0)
(defglobal _interrupttime_ 0.0)
(defglobal _others-proctimes_ (make-record #()))
(defglobal _last-proctime_ 0.0)
(defglobal _last-flush_ 0.0)
(defglobal _last-report_ 0.0)
(defglobal _last-heartbeat_ 0.0)
(defglobal _cumul-proctime_ 0.0)
(defglobal _readtime_ 0.0)
(defglobal _start-time_ nil)

(defglobal _last-flushcount_ 0)

(defvar _subs_ (vector))
(defvar _subkinds_ (vector))

; A _sourcenode_ does not do extract, merge, smj, or uall.
(defglobal _sourcenode_ t) 

; A _destnode_ does not run lsproc.
(defglobal _destnode_ t)
(defglobal _timestamp_ nil)

(defglobal _delay-times_ nil)
(defglobal _proctimes_ nil)

(defglobal _sp-startform_ nil "Form to evaluate when starting new SP")

(defun add-sp-startform (form)
  "Evaluate FORM when new SP has been started"
  (global-eval `(eval-sp-startform ',form)))

(defun eval-sp-startform (form)
  "SP startform for this peer"
  (cond (_sp-startform_ (nconc1 _sp-startform_ form))
        (t (setq _sp-startform_ (list 'progn form))))
  (eval (copy-tree form)))

(defmacro catch-error-sp (form repair) `(catch-error ,form ,repair))

(defglobal _dribble-dir_ nil)

(defun sp-read (x)(read x))

(defun dribble-+ (fno logdir res)
  (let ((p (fullpath logdir)))
    (cond ((directoryp p)
           (mapfunctionres 'dir (list p "*.log")nil 
			   (f/l (row)(delete-file (concat (add/last p)
							  (car row)))))
	   (global-eval (list 'dribble-to p))
           (add-sp-startform (list 'setq '_dribble-dir_ p))
	   (osql-result logdir p))
          (t (error "Not a directory" p)))))

(defun dribble-to (dir)
  (let ((d (add/last dir)))
    (cond (_scsq-id_ (dribble (concat d _scsq-id_ ".log")))
	  (_amosid_ (dribble (concat d _amosid_ ".log")))
	  (t (dribble (concat d "client.log"))))))

(defun scsq-profile (fno logdir r)
  (dribble-+ fno logdir r)
  (add-sp-startform '(progn (start-profile nil)
			    (register-shutdown-form '(pps(profile)))))
  )

(defun elt-or-atom (v i)
  (if (arrayp v)
      (elt v i)
    v))

(defun record-sget (r a)
  (if (recordp r)
      (record-get r a)))

(defun lnewsp (fno s res)
  (let ((result
	 (lspv (make-record (listtoarray (list "generator" (vector s)
					       "nsub" 1))))))
    (osql-result s (elt result 0))))

(defun lnewspr (fno s args res)
  (let* ((r
	  (merge-records
	   args
	   (make-record (listtoarray (list "generator" (vector s)
					   "nsub" 1)))))
	 (result (lspv r)))
    (osql-result s args (elt result 0))))

(defun lnewspv (fno sv res)
  (let ((resv (lspv (make-record (listtoarray (list "generator" sv))))))
    (osql-result sv resv)))

(defun lnewspvr (fno sv args res)
  (let* ((r
	  (merge-records
	   args
	   (make-record (listtoarray (list "generator" sv
					   "nsub" 1)))))
	 (resv (lspv r)))
    (osql-result sv args resv)))

(defun default-request ()
  (make-record
   (listtoarray
    (list
     "generator" nil
     "nsub" 1
     "sfn" nil
     "rfn" nil
     "bfn" nil
     "sargs" #()
     "rargs" #()
     "dump" nil
     "hostname" nil
     "exe" nil
     "osql" nil
     "imagesize" nil
     "rand" nil))))

(defun arrayarrayp (a)
  (and (arrayp a)
       (> (length a) 0)
       (let ((c 0))
	 (maparray
	  a
	  (f/l (x i)
	       (and (arrayp x 0) (1++ c))))
	 (eq c (array-total-size a)))))

(defun elementify (r i)
  (let ((ret (make-record #())))
    (mapc
     (f/l (key)
	  (cond ((equal key "sargs")
		 (record-put ret "sargs"
			     (if (arrayarrayp (record-get r "sargs"))
				 (elt (record-get r "sargs") i)
			       (record-get r "sargs"))))
		((equal key "rargs")
		 (record-put ret "rargs"
			     (if (arrayarrayp (record-get r "rargs"))
				 (elt (record-get r "rargs") i)
			       (record-get r "rargs"))))
		(t
		 (record-put ret key (elt-or-atom (record-get r key) i)))))
     (record-keys r))
    ret))

(defun lspv (args)
  (if (not _amosid_) (register-scsq-client))  
  (let* ((sv (record-get args "generator"))
	 (margs (merge-records args (default-request)))
	 (reqv (make-array (array-total-size sv)))
	 (resv (make-array (array-total-size sv))))
    (maparray
     sv
     (f/l (generator i)
	  (seta reqv i (elementify margs i))))
    (maparray
     reqv
     (f/l (ssrc i)
	  (seta resv i (remote-eval `(ipr , ssrc) 's))))
    resv))

(defun sp-p (x)(eq (typename x) 'port))

(defun spov (fno s sp)
  (let ((p (generator-params s)))
    (and (sp-p (car p))(osql-result s (car p)))))

(defun tag-port (fno p tag res)
  (osql-result
   p tag (new-port (port-getproto p) (port-gethostname p) (port-getportno p)
		   tag)))
(osql "create function tagsp(Sp p, Integer i) -> Sp 
as foreign 'tag-port';")

(osql "create function lsproc2(integer port, integer id, integer local)
       -> integer as foreign 'lsproc';")

(defun set-initial-subscribers (n listensock)
  (let ((subs (make-array n :adjustable t))
	(subkinds (make-array n :adjustable t)))
    (dotimes (i n)
      (formatl t "[" i)
      (let* ((subscriber (accept-socket listensock nil))
	     (subinfo (prog2 (formatl t "]" t) (sp-read subscriber)))
	     (sub_id (car subinfo))
	     (subkind (second subinfo)))
	(formatl t "subinfo " subinfo t)
	(formatl t "subkind " subkind t)
	(cond ((integerp sub_id)
	       (seta subs sub_id subscriber)
	       (seta subkinds sub_id (record-get subkind "bg")))
	      ((null sub_id)
	       (seta subs i subscriber)
	       (seta subkinds i (record-get subkind "bg")))
	      (t
	       (error "Invalid subscriber ID" sub_id)))))
    (setq _subs_ subs)
    (setq _subkinds_ subkinds)
    (formatl t "set-initial-subscribers " _subs_ " subkinds " _subkinds_ t)))

(defun sperror ()
  (formatl t _scsq-id_ " [ERROR " (rnow) "] " _error-condition_ t)
  (let ((subsleft (mapcar (f/l (v) (and (not (socket-closed v)) v))
			  (arraytolist _subs_))))
    (formatl t "subsleft " subsleft t)
    (mapc
     (f/l (s k) (and s
		     (if k
			 (progn (lprint _error-condition_ s) (flush s))
		       (pf _error-condition_ s))))
     subsleft (arraytolist _subkinds_))
    (formatl t "[" _scsq-id_ " sperror: waiting for 'STOP from all subs: ")
    (let (tmp)
      (mapc
       (f/l (v)
	    (formatl t v " ")
	    (if (null v)
		(formatl t "(skip nil) ")
	      (if (error? ;; Close socket if other end died
		   (catch-error
		    (while
			(not (equal (setq tmp (sp-read v)) 'STOP))
		      (formatl t "[" _scsq-id_ " read " tmp " from " v "] "))))
		  (progn (formatl t "got error" t) (close-socket v)))
	      (formatl t "tmp is " tmp t)))
       subsleft)
      (formatl t "done]" t)))
 (quit))

(defun report-delay (&optional sync)
  (if _delay-times_
      (progn
	(if sync
	    (reval@nameserver
	     `(add-delay (quote , _scsq-id_) (quote , _delay-times_)))
	  (send-form
	   `(add-delay (quote , _scsq-id_) (quote , _delay-times_))
	   (open-nameserver-port)))
	(setq _delay-times_ nil))))

(defun report-proctimes (&optional sync)
  (if _proctimes_
      (progn
	(if sync
	    (reval@nameserver
	     `(add-proctimes (quote , _scsq-id_) (quote , _proctimes_)))
	  (send-form
	   `(add-proctimes (quote , _scsq-id_) (quote , _proctimes_))
	   (open-nameserver-port)))
	(setq _proctimes_ nil))))

(defun sp-interrupt ()
  (1++ _int-count_)
  (let ((start-time (rnow)))
    (stat-function)
    ;; adaptive flush freq
    '(let ((st (fourth (instr-commstat))))
       (if (< (- st _last-flushcount_) 3)
	   (progn
	     (setq _sp-flush-freq_ (max (/ _sp-flush-freq_ 2) 0.02))
	     (set-timer nil)
	     (set-timer 'sp-interrupt (min _sp-flush-freq_ 
					   _sp-hb-freq_)))))
    (if (and _sp-proctime_
	     (> start-time (+ _last-proctime_ _sp-proctime-freq_ )))
	(progn
	  (let ((pt (proctime)))
	    (setq _proctimes_
		  (cons (list 
			 (gettimeofday)
			 (* 100 (/ (- pt _cumul-proctime_)
				   (- start-time _last-proctime_))))
			_proctimes_))
	    (setq _cumul-proctime_ pt))
	  (setq _last-proctime_ start-time)))
    (if (> start-time (+ _last-flush_ _sp-flush-freq_))
	(progn
	  (flush-all)
	  (setq _last-flush_ start-time)))
    (if (and _sp-heartbeat_ _sourcenode_
	     (> start-time (+ _last-heartbeat_ _sp-hb-freq_)))
	(progn
	  (heart-beat)
	  (setq _last-heartbeat_ start-time)))
    (if (> start-time (+ _last-report_ _sp-report-period_))
	(progn (report-proctimes)
	       (report-delay)
	       (setq _last-report_ start-time)))
    (setq _interrupttime_ (+ _interrupttime_ 
			     (- (rnow) start-time)))))
(push 'sp-interrupt _exclude-profile_)

(defun flush-all ()
  (1++ _flush-count_)
  (maparray _subs_ (f/l (sub i) (flush sub))))

(defun heart-beat ()
  (1++ _hb-count_)
  (setq _timestamp_ (list 'TS (gettimeofday) _scsq-id_)))

(defun sp-stat (proc-start proc-end generator sfn sargs)
  (let ((tear-down (rnow)) (prof (profile 1)))
    (formatl t _scsq-id_ " [exiting " tear-down 
	     "] " (instr-commstat)
	     t)
    (formatl t prof t)
    (and _sp-heartbeat_
	 (report-delay t))
    (if _sp-proctime_
	(prog1 (report-proctimes t)
	  (reval@nameserver
	   `(add-final-proctime
	     (quote , _scsq-id_)
	     (quote , _cumul-proctime_)))))
    '(reval@nameserver
      `(add-dpstat
	(quote , _scsq-id_) 
	(list
	 'commstat , (instr-commstat)
	 'init , (- proc-start _start-time_)
	 'interrupttime , _interrupttime_
	 'int-count , _int-count_
	 'hb-count , _hb-count_
	 'hostname , (gethostname)
	 'generator (quote , generator)
	 'sfn (quote , sfn)
	 'sargs (quote , sargs)
	 'profile (quote , prof))))))

(defun set-globalvars (r)
  (mapc (f/l (key)
	     (let ((val (record-get r key)))
;;	       (and val (eval `(setq , (pack "_sp-" key "_") val)))))
	       (eval `(setq , (pack "_sp-" key "_") val))))
	'("flush" "flush-freq" "heartbeat" "hb-freq" "proctime" "proctime-freq"
	  "report-period" "profile-freq")))

(defun set-globalfns (r)
  (mapc (f/l (key)
	     (let ((val (record-get r key)))
	       (and val (apply (mksymbol key) (list val)))))
	'("randominit" "imagesize")))

(defun init-timers (r)
  (setq _last-proctime_ (rnow))
  (setq _cumul-proctime_ (proctime))
  (setq _last-flush_ (rnow))
  (setq _last-report_ (rnow))
  (setq _last-heartbeat_ (rnow))
  (formatl t "init-timers: " (and _sp-flush_ "flush yes") t)
  (if (record-get r "profile") (start-profile) (stop-profile))
  (setq _stat-enabled_ nil)
  (if (or (and _sourcenode_ _sp-heartbeat_) _sp-flush_ _sp-proctime_)
      (set-timer 'sp-interrupt
		 (min _sp-hb-freq_ _sp-flush-freq_ _sp-proctime-freq_
		      _sp-profile-freq_))))

(defun init-osql (r)
  (let ((val (record-get r "osql")))
    (and val (eval `(osql , val)))))

(defun all-set (r listensock)
  (setq _destnode_ nil)
  (set-nameserverhost (record-get r "nhost"))
  (/setglobal '*nsp* (record-get r "nport"))
  (set-globalvars r)
  (set-globalfns r)
  (init-timers r)
  (formatl t "[waiting on " (socket-portno listensock) " for "
	   (record-get r "nsub") " subs")
  (set-initial-subscribers (record-get r "nsub") listensock)
  (formatl t "]" t)
  (init-na2m r)
  (init-osql r))

(defun report-me (report)
  (make-record (listtoarray (list _scsq-id_ report))))

(defun stop-subs (spid report)
  ;; flush all subscribers and collect socketstat. Then pf EOF to them.
  (let (sockstat)
    (maparray
     _subs_
     (f/l (v i)
	  (flush v)
	  (formatl t _scsq-id_ " socketstat " i ": " (socketstat v) t)
	  (push (listtoarray (socketstat v)) sockstat)
	  (push (listtoarray (list (socket-hostname v) (socket-portno v)))
		sockstat)))
    (let* ((ss (make-record
		(listtoarray
		 (list "commstat" (make-record (listtoarray sockstat))))))
	   (rs (merge-records report ss)))
      (maparray
       _subs_
       (f/l
	(v i)
	(let* ((msg (list
		     'EOF
		     (merge-records (report-me rs) _others-proctimes_)
		     ))
	       (tmpdir (getenv "TMPDIR"))
	       (outfile (concat tmpdir "/dp-" spid)) e)
	  (and tmpdir (with-open-file (fstr outfile :direction :output)
			(print (report-me rs) fstr)))
	  (if (setq e (error?
	       (catch-error
		(progn
		  (if (elt _subkinds_ i)
		      (instr-print (list 'EOF) v (elt _subkinds_ i))
		    (instr-print msg v (elt _subkinds_ i)))
		  (flush v)))))
	      (progn
		(formatl t "error when printing to subscriber " i ":" e t)
		(close-socket v))))))
      (formatl t _scsq-id_ " waiting for 'STOP from all subs: ")
      (maparray
       _subs_
       (f/l (v i)
	    (let (tmp e)
	      (formatl t i " ")
	      (if (setq e (error?;; Close socket if other end died
		   (catch-error
		    (while
			(not (equal (setq tmp (sp-read v)) 'STOP))
		      (formatl t _scsq-id_ " [read " tmp " from " i "] ")))))
		  (progn
		    (close-socket v)
		    (formatl t "error when reading 'STOP from sub "
			     i ": " e t))))))
      (formatl t "done" t))))

(defun rprofile (prof)
  (make-record
   (listtoarray
    (mapcan (f/l (x)
		 (or (and (listp x) (list (mkstring (car x)) (cdr x)))
		     (list "samples" x))) prof))))

(defun daehost (var)
  (if (eq var 1)
      'localhost
    (caar (getfunction 'prepcoordhost '()))))

(defun make-report (proc-start proc-end prof mappertime)
  (merge-records (instr-commstat)
		 (make-record
		  (listtoarray (list
				"mappertime" (roundto mappertime 3)
				"init" (roundto (- proc-start _start-time_) 3)
				"exetime" (roundto (- proc-end proc-start) 3)
				"interrupttime" (roundto _interrupttime_ 3)
				"int-count" _int-count_
				"hb-count" _hb-count_
				"hostname" (gethostname)
				"profile" (rprofile prof))))))

;; subscribers is an argument (not necessarily the global var _subs_)

(defun spmapper-sfn (r subs subkind)
  (let ((nsub (array-total-size subs))
	(generator (record-get r "generator"))
	(sfn (record-get r "sfn"))
	(sargs (arraytolist (record-get r "sargs"))))
    (mapbag generator
     (f/l (tpl)
	  (mapfunction 
	   sfn (list* (car tpl) nsub sargs)
	   (f/l (r)
		(if _timestamp_
		    (let ((ptpl (append2 _timestamp_ (list (second r)))))
		      (instr-print ptpl (aref subs (first r))
				   (aref subkind (first r)))
		      (setq _timestamp_ nil))
		  (instr-print (second r) (aref subs (first r))
			       (aref subkind (first r))))))))))

(defun spmapper-randr (r subs)
  (let ((generator (record-get r "generator"))
	(nsubs (array-total-size subs)))
    (mapbag generator
     (f/l (tpl)
	  (let ((outputnum (ez-rand nsubs)))
	    (if _timestamp_
		(let ((ptpl (append2 _timestamp_ tpl)))
		  (instr-print ptpl (elt subs outputnum))
		  (setq _timestamp_ nil))
	      (instr-print (car tpl) (elt subs outputnum))))))))

(defun spmapper-rs-randr (r subs)
  (let ((generator (record-get r "generator"))
	(nsubs (array-total-size subs)))
    (mapbag generator
     (f/l (tpl)
	  (let (writeable)
	    (while (null writeable)
	      (setq writeable (rand-sockets subs 1.0 t))
	      (if (null writeable)
		  (formatl t "[wait " tpl "]" t)
		(if _timestamp_
		    (let ((ptpl (append2 _timestamp_ tpl)))
		      (instr-print ptpl writeable)
		      (setq _timestamp_ nil))
		  (instr-print (car tpl) writeable)))))))))

(defun spmapper-nb-randr (r subs)
  (let ((generator (record-get r "generator"))
	(nsubs (array-total-size subs))
	(cnt 0))
    (mapbag generator
     (f/l (tpl)
	  (let (writeable)
	    (while (null writeable)
	      (setq writeable (poll-sockets subs 1.0 t))
	      (if (null writeable)
		  (formatl t "wait " cnt t)
		(let ((output (elt writeable
				   (ez-rand (array-total-size writeable)))))
		  (if _timestamp_
		      (let ((ptpl (append2 _timestamp_ tpl)))
			(instr-print ptpl output)
			(setq _timestamp_ nil))
		    (instr-print (car tpl) output))
		  (1++ cnt)))))))
    (formatl t "total count " cnt t)))

(defun spmapper (r subs subkind)
  (let ((generator (record-get r "generator")))
    (mapbag generator
     (f/l (tpl)
	  (if _timestamp_
	      (let ((ptpl (append2 _timestamp_ tpl)))
		(maparray subs
			  (f/l (sub i) (instr-print ptpl sub (elt subkind i))))
		(setq _timestamp_ nil))
	    (maparray subs
		      (f/l (sub i) (instr-print (car tpl) sub
						(elt subkind i)))))))))

(defglobal _multibuff_ nil)
(defglobal _multibuff-pos_ nil)
(defglobal _multibuff-maxpos_ nil)
(defglobal _multibuff-count_ nil)

(defun init-na2m (r)
  (let ((nsub (record-get r "nsub"))
	(na2m (record-get r "na2m")))
    (setq _multibuff-pos_ (make-array nsub :initial-element 0))
    (if na2m
	(let ((ma-size (record-get na2m "ma-size")))
	  (setq _multibuff_ (make-array nsub))
	  (setq _multibuff-maxpos_ (make-array nsub))
	  (if (arrayp ma-size)
	      (setq _multibuff-count_ ma-size)
	    (setq _multibuff-count_
		  (make-array nsub :initial-element ma-size)))))))

;; na2m-flush is sensitive to _subkinds_

(defun na2m-flush (i sub)
  (if (equal (aref _multibuff-pos_ i) (aref _multibuff-maxpos_ i))
      (instr-print (aref _multibuff_ i) sub (elt _subkinds_ i))
    (let ((toprint
	   (na-project
	    (aref _multibuff_ i)
	    0
	    (/ (* (aref _multibuff-pos_ i) (dim-numarray (aref _multibuff_ i)))
	       (aref _multibuff-maxpos_ i)))))
      (instr-print toprint sub (elt _subkinds_ i))))
  (seta _multibuff-pos_ i 0))

(defun na2m-flushall (subs)
  (maparray _multibuff_
	    (f/l (b i)
		 (formatl t i " pos " (aref _multibuff-pos_ i) t)
		 (if (> (aref _multibuff-pos_ i) 0)
		     (na2m-flush i (aref subs i))))))

(defun na2m (i na sub)
  (or (aref _multibuff_ i)
      (let ((maxpos (* (dim-numarray na) (aref _multibuff-count_ i))))
	(seta _multibuff-maxpos_ i maxpos)
	(seta _multibuff_ i (make-numarray maxpos (arg-type na)))))
  (na-smash (aref _multibuff_ i) (aref _multibuff-pos_ i) na)
  (seta _multibuff-pos_ i (+ (dim-numarray na) (aref _multibuff-pos_ i)))
  (if (= (aref _multibuff-pos_ i) (aref _multibuff-maxpos_ i))
      (na2m-flush i sub)))

;; NOTE: spmapper-na2m does not pass time stamps

(defun spmapper-na2m (r subs subkind)
  (let ((nsub (array-total-size subs))
	(generator (record-get r "generator"))
	(sargs (arraytolist (record-get r "sargs"))))
    (mapbag generator
     (f/l (tpl)
	  (maparray subs (f/l (sub i) (na2m i (car tpl) sub)))))
    (na2m-flushall subs)))

;; NOTE: spmapper-sfn-na2m does not pass time stamps

(defun spmapper-sfn-na2m (r subs subkind)
  (let ((nsub (array-total-size subs))
	(generator (record-get r "generator"))
	(sfn (record-get r "sfn"))
	(sargs (arraytolist (record-get r "sargs"))))
    (mapbag generator
     (f/l (tpl)
	  (mapfunction 
	   sfn (list* (car tpl) nsub sargs)
	   (f/l (res)
		(na2m (first res) (second res) (aref subs (first res)))))))
    (na2m-flushall subs)))

;; spmapper-rbfn is currently not used. spmapper-rbfnfo is used instead.

(defun spmapper-rbfn (r)
  (let ((nsub (array-total-size _subs_))
	(generator (record-get r "generator"))
	(rbfn (record-get r "rbfn")))
    (mapbag generator
     (f/l (tpl)
	  (mapfunction 
	   rbfn (nconc1 tpl nsub)
	   (f/l (sub)
		(if _timestamp_
		    (let ((ptpl (append2 _timestamp_ tpl)))
		      (instr-print ptpl (aref _subs_ (car sub)))
		      (setq _timestamp_ nil))
		  (instr-print (car tpl) (aref _subs_ (car sub))))))))))

(defun spmapper-rbfnfo (r subs)
  (let ((nsub (array-total-size subs))
	(generator (record-get r "generator"))
	(rbfnfo (record-get r "rbfnfo")))
    (mapbag generator
     (f/l (tpl)
	  (mapfunction 
	   rbfnfo tpl
	   (f/l (sub)
		(if _timestamp_
		    (let ((ptpl (append2 _timestamp_ tpl)))
		      (instr-print ptpl (aref subs (car sub)))
		      (setq _timestamp_ nil))
		  (instr-print (car tpl) (aref subs (car sub))))))))))

(defun trail-summary (x)
  (cond ((atom x) x)
	(t (firstn 5 x))))

(defun lsproc (fno spid cport localdae res)
					;(setq _batch_ t)
  (debugging t)
  (setq _scsq-id_ (concat "sp-" spid))
  (if _dribble-dir_ (dribble-to _dribble-dir_))
  (setq _start-time_ (rnow))
  (let ((to-dae (open-socket (daehost localdae) cport))
	(listensock (open-socket nil 0)) proc-start proc-end mappertime)
    (formatl t "[Starting " _scsq-id_ " on " (gethostname) 
	     " listening on port " (socket-portno listensock) "]" t t)
    (pf (socket-portno listensock) to-dae)
    (let* ((r (sp-read to-dae))
           (gfn (generator-function (record-get r "generator")))
	   (trail (plan-trail gfn)))
      (formatl t _scsq-id_ " record " r t)
      (formatl t t "Generator: " 
	       (generator-function (record-get r "generator"))
	       t "Stream function:" "~PP" (get-orgcode gfn) 
               t "Plan trail: " "~PP" trail t)
      (if (equal (system-environment) "VisualC++")
	  (system (concat "title "  _scsq-id_ ":" (trail-summary trail))))
      (if (equal r 'STOP) (return 0))
      (all-set r listensock)
      (formatl t _scsq-id_ " all-set " (setq proc-start (rnow)) t)
      (if (or (record-get r "rfn") (record-get r "bfn"))
	  (record-put
	   r "rbfnfo"
	   (rewrite-rbfnfo
	    (record-get r "nsub") (record-get r "rfn")
	    (record-get r "bfn") 'r-n-b (record-get r "rargs"))))
      (resetvar _stat-enabled_ t
		(setq mappertime (proctime))
		(formatl t "mappertime at start " mappertime t)
		(cond ((record-get r "rs-randr")
		       (catch-error-sp (spmapper-rs-randr r _subs_) (sperror)))
		      ((record-get r "nb-randr")
		       (catch-error-sp (spmapper-nb-randr r _subs_) (sperror)))
		      ((record-get r "randr")
		       (catch-error-sp (spmapper-randr r _subs_) (sperror)))
		      ((record-get r "rbfnfo")
		       (catch-error-sp (spmapper-rbfnfo r _subs_) (sperror)))
		      ((and (record-get r "na2m") (record-get r "sfn"))
		       (catch-error-sp (spmapper-sfn-na2m r _subs_ _subkinds_)
				       (sperror)))
		      ((record-get r "na2m")
		       (catch-error-sp (spmapper-na2m r _subs_ _subkinds_)
				       (sperror)))
		      ((record-get r "sfn")
		       (catch-error-sp (spmapper-sfn r _subs_ _subkinds_)
				       (sperror)))
		      (t
		       (catch-error-sp (spmapper r _subs_ _subkinds_)
				       (sperror)))))
      (setq mappertime (- (proctime) mappertime))
      (formatl t t "CPU time used: " mappertime t)
      (setq proc-end (rnow))
      (formatl t "Wall time used: " (- proc-end proc-start) t)
      (formatl t "Average CPU utilization: " (if (> (- proc-end proc-start) 0)
						 (roundto (* (/ mappertime
								(- proc-end 
								   proc-start))
							     100) 4)
					       0) "%" t t)
      (set-timer nil)
      (let ((prof (profile)))
	(stop-subs spid
		   (merge-records (make-report proc-start proc-end prof 
					       mappertime)
				  (make-record
				   (listtoarray
				    (mapcan
				     (f/l (k)
					  (let ((val (record-get r k)))
					    (if (or (function-p val) 
						    (generatorp val))
						(list k (mkstring val))
					      (list k val))))
				     (record-keys r))))))
	(quit)))))

(defun rewrite-rbfn (fanout rfn bfn fname &optional rargs)
  (let* ((rfnsb (getselectbody rfn)) (bfnsb (getselectbody bfn))
	 (rfnarg (selectbody-argl rfnsb))
	 (rfnargt (selectbody-argt rfnsb))
	 (bfnarg (selectbody-argl bfnsb))
	 (newbfnpred (subst 'SFN-TPL (first bfnarg)
			    (selectbody-orgpred bfnsb)))
	 (newrfnpred (subst 'SFN-RES (first (selectbody-resl rfnsb))
			    (subst 'SFN-FANOUT (second rfnarg) 
				   (subst 'SFN-TPL (first rfnarg)
					  (selectbody-orgpred rfnsb)))))
	 (rt (first rfnargt))
	 (bt (first (selectbody-argt bfnsb)))
	 (ot (cond ((subtype-of bt rt t) bt)
		   ((subtype-of rt bt) rt)
		   (t (error "No type hierarchy" (list rt bt)))))
	 (sfnargt (list (list ot 'SFN-TPL)
			(list (gettypenamed 'integer) 'SFN-FANOUT)))
	 (rargbind (and rargs
			(mapcar (f/l (arg bind) `(= , arg , bind))
				(nthcdr 2 rfnarg) (arraytolist rargs))))
	 (sfnpred `(OR (AND , newbfnpred
			      (= SFN-RES (IN (IOTA 0 (MINUS SFN-FANOUT 1)))))
		       , (append newrfnpred rargbind)))
	 (sfnquant (mapcar
		    (f/l (type var) (list type var))
		    (append (selectbody-loct rfnsb) (nthcdr 2 rfnargt))
		    (append (selectbody-locals rfnsb) (nthcdr 2 rfnarg)))))
    (createfunction fname
		    sfnargt 
		    (list (list 'integer 'SFN-RES))
		    (list 'SFN-RES)
		    sfnquant
		    sfnpred)))

(defun rewrite-rbfnfo (fanout rfn bfn fname &optional rargs)
  (let* ((rfnsb (getselectbody rfn)) (bfnsb (getselectbody bfn))
	 (rfnarg (selectbody-argl rfnsb))
	 (rfnargt (selectbody-argt rfnsb))
	 (bfnarg (selectbody-argl bfnsb))
	 (newbfnpred (subst 'SFN-TPL (first bfnarg)
			    (selectbody-orgpred bfnsb)))
	 (newrfnpred (subst 'SFN-RES (first (selectbody-resl rfnsb))
			    (subst 'SFN-FANOUT (second rfnarg) 
				   (subst 'SFN-TPL (first rfnarg)
					  (selectbody-orgpred rfnsb)))))
	 (rt (first rfnargt))
	 (bt (first (selectbody-argt bfnsb)))
	 (ot (cond ((subtype-of bt rt t) bt)
		   ((subtype-of rt bt) rt)
		   (t (error "No type hierarchy" (list rt bt)))))
	 (sfnargt (list (list ot 'SFN-TPL)))
	 (rargbind (and rargs
			(mapcar (f/l (arg bind) `(= , arg , bind))
				(nthcdr 2 rfnarg) (arraytolist rargs))))
	 (sfnquant (mapcar
		    (f/l (type var) (list type var))
		    (append (list 'INTEGER) (selectbody-loct rfnsb)
			    (nthcdr 2 rfnargt))
		    (append (list 'SFN-FANOUT) (selectbody-locals rfnsb)
			    (nthcdr 2 rfnarg))))
	 (sfnpred `(AND
		    (= SFN-FANOUT , fanout)
		    (OR (AND , newbfnpred
			       (= SFN-RES (IN (IOTA 0 (MINUS SFN-FANOUT 1)))))
			, (append newrfnpred rargbind)))))
    (createfunction fname
		    sfnargt 
		    (list (list 'integer 'SFN-RES))
		    (list 'SFN-RES)
		    sfnquant
		    sfnpred)))
