(defglobal _coord-sock_ nil)
(defglobal _base-prephost_ 0)
(defglobal _current-prephost_ 0)
(defglobal _current-prepcpu_ 0)
(defglobal _sp-stdout_ "PrepLog")

(defglobal _sp-imagesize_ nil)

(defglobal _sp-profile_ T)
(defglobal _sp-profile-freq_ 0.05)

(defglobal _sp-flush_ T)
(defglobal _sp-flush-freq_ 0.1)

(defglobal _spid-counter_ 0)

(defglobal _daemon-mode_ 0)

(defun sp-id ()
  (1++ _spid-counter_))

(defmacro mapstring (string fn)
  `(let (res)
     (dotimes (i (length , string))
       (push (funcall , fn (substring i i , string)) res))
     (apply #'concat (reverse res))))

(defun esc-sh (s)
  (mapstring s #'escape-char))

(defun escape-char (s)
  (cond ((string-like s "[';{}()\"]") (concat "\\" s))
	(t s)))

(defun esc-squote (form)
  (mapstring (with-string str (prin1 form str))
	     (f/l (s)(if (string-like s "\"")(concat "\\" s) s))))

(defun localhost? (host)
  (or (equal (string-downcase host) "localhost")
      (equal host "127.0.0.1")
      (equal (string-downcase host) (string-downcase (gethostname)))))

(defun scsqged--+ (fno host dmp res)
  (let* ((idno (daemon-id))
	 (id (concat "scsqd-" idno)))
    (system (esc-sh (concat (caar (getfunction 'gersh '()))
			    " " host " "
			    (caar (getfunction 'prepstartcmd (list "")))
			    " " dmp
			    " -r/scratch/" (getenv "USER") "/scsqd-" idno
			    " -o \"qdaemon('" (gethostname) "',"
			    *nsp* "," idno ");\" &")))
    (osql-result host id)))

(osql "create function scsqged(Charstring host, Charstring dmp)
 -> Charstring as foreign 'scsqged--+';
create function scsqged(Charstring host) -> Charstring
       as scsqged(host, '');")

(defun scsqsld--+ (fno host dmp res)
  (let* ((idno (daemon-id))
	 (id (concat "scsqd-" idno))
	 (cmd (esc-sh (concat (caar (getfunction 'slrsh '()))
			      ;;" -n 1 -N 1 -t 4:00:00 -w " host " "
			      " -n 1 -N 1 -t 0 -w " host " "
			      (caar (getfunction 'prepstartcmd (list "")))
			      " " dmp
			      " -r" (getenv "TMPDIR") "/scsqd-" idno
			      " -o qdaemon('" (gethostname) "',"
			      *nsp* "," idno "); &"))))
    (formatl t cmd t)
    (system cmd)
    (osql-result host id)))

(osql "create function scsqsld(Charstring host, Charstring dmp)
 -> Charstring as foreign 'scsqsld--+';
create function scsqsld(Charstring host) -> Charstring
       as scsqsld(host, '');")

(defun waitfordaemons+ (fno res)
  (let (ready)
    (while (not (setq ready (caar (getfunction 'cooready nil))))
      (sleep 0.3))
    (osql-result ready)))

(osql "create function waitfordaemons() -> Boolean
       as foreign 'waitfordaemons+';")

(defun start-qdaemon (host chost cport)
  (concat 
   (getenv "TMPDIR") "/rsh -n"
   " " host " "
   (esc-sh 
    (concat
     "source $HOME/.bashrc; "
     (caar (getfunction 'sp_start (list "")))
     " "
     (caar (getfunction 'prepstartcmd (list "")))
     " -r DL -o \""
     "print({'" chost "'," cport "});print({'hej'});quit;"
     "\""))))

(defun getnext-host (forcednode hostnum &optional generator)
  (let ((blacklist (generator-portsfrom generator))
	(phosts (arraytolist (caar (getfunction 'prephosts ())))))
    (cond (forcednode
	   forcednode)
	  (hostnum
	   (elt (caar (getfunction 'prephosts ())) hostnum))
	  (blacklist
	   (let ((hostsleft
		  (subset phosts (f/l (x) (not (member x blacklist))))))
	     (if hostsleft
		 (nth (random (length hostsleft)) hostsleft)
	       (getdefault-host))))	; No hosts left. Best effort.
	  (t
	   (getdefault-host)))))

(defun spcmd (local_exec executable curprephost nodename dumpfile spid)
  (let ((stdout (caar (getfunction 'spstdout ()))))
    (concat
     (cond (local_exec "")
	   (t (concat
	       (caar (getfunction 'preprsh ())) " -l "
	       (or (caar (getfunction 'sp_username
				      (list (or curprephost ""))))
		   (caar (getfunction 'sp_username (list ""))))
	       " " curprephost " \"")))
     (cond (local_exec (caar (getfunction 'sp_start (list ""))))
	   (t (or 
	       (caar (getfunction 'sp_start (list (or nodename ""))))
	       (caar (getfunction 'sp_start (list ""))))))
     " "
     (or executable 
	 (cond
	  (local_exec
	   (caar (getfunction 'prepstartcmd (list ""))))
	  (t
	   (or (caar (getfunction 'prepstartcmd (list (or nodename ""))))
	       (caar (getfunction 'prepstartcmd (list "")))))))
     " "
     dumpfile (cond ((null _sp-startform_) "")
                    (t (with-string str
				    (princ " -l \"(eval-sp-startform '" str)
				    (princ (esc-squote _sp-startform_)str)
				    (princ ")\"" str))))
     " -o "
     (esc-quote local_exec)
     (caar (getfunction 'sprocstart ()))
     "(" spid "," (socket-portno _coord-sock_) ",0);"
     (esc-quote local_exec)
     (or (and (equal stdout "") "") (concat stdout spid))
     (caar (getfunction 'sppostfix ()))
     (cond (local_exec "") (t "\"")))))

(defun new-proctime-dir (dirname)
  (or (directoryp dirname)
      (error "No such directory" dirname))
  (setq _proctime-dir_ dirname))

(foreign-lispfn
 sp_basehostnum ((integer i)) ((integer))
 (foreign-result
  (reval@nameserver `(baseprephost , i))))

(foreign-lispfn
 sp_currenthostnum ((integer i)) ((integer))
 (foreign-result
  (reval@nameserver `(currentprephost , i))))

(foreign-lispfn
 proctime_dir ((charstring dirname)) ((charstring))
 (foreign-result
  (reval@nameserver `(new-proctime-dir , dirname))))

(foreign-lispfn
 proctime_dir () ((charstring))
 (foreign-result 
  (reval@nameserver `_proctime-dir_)))

(foreign-lispfn
 delay_file ((charstring filename)) ((charstring))
 (foreign-result 
  (reval@nameserver `(setq _delay-filename_ , filename))))

(foreign-lispfn
 reset_ipr () ((integer))
 (foreign-result 
  (reval@nameserver '(progn (setq _current-prephost_ 0)
			    (setq _current-prepcpu_ 0)))))

(foreign-lispfn
 sp_exename ((charstring exe)) ((integer))
 (foreign-result 
  (or (reval@nameserver `(setfunction 'prepstartcmd (list "") (list , exe)))
      1)))

(foreign-lispfn
 sp_dumpfile ((charstring df)) ((integer))
 (foreign-result 
  (or (reval@nameserver `(setfunction 'dumpfile '() (list , df)))
      1)))

(foreign-lispfn
 sp_profile ((integer p)) ((integer))
 (let (ret)
   (if (eq 0 p)
       (setq ret (reval@nameserver `(setq _sp-profile_ , nil)))
     (setq ret (reval@nameserver `(setq _sp-profile_ , T))))
   (foreign-result (if ret 1 0))))

(foreign-lispfn
 sp_profile_freq ((real r)) ((real))
 (foreign-result (reval@nameserver `(setq _sp-profile-freq_ , r))))

(foreign-lispfn
 sp_ts ((integer hb)) ((integer))
 (let (ret)
   (if (eq 0 hb)
       (setq ret (reval@nameserver `(setq _sp-heartbeat_ , nil)))
     (setq ret (reval@nameserver `(setq _sp-heartbeat_ , T))))
   (foreign-result (if ret 1 0))))

(foreign-lispfn
 sp_proctime ((integer pt)) ((integer))
 (let (ret)
   (if (eq 0 pt)
       (setq ret (reval@nameserver `(setq _sp-proctime_ , nil)))
     (setq ret (reval@nameserver `(setq _sp-proctime_ , T))))
   (foreign-result (if ret 1 0))))

(foreign-lispfn
 coo_storedelays ((integer d)) ((integer))
 (let (ret)
   (if (eq 0 d)
       (setq ret (reval@nameserver `(setq _coo-store-delays_ , nil)))
     (setq ret (reval@nameserver `(setq _coo-store-delays_ , T))))
   (foreign-result (if ret 1 0))))

(foreign-lispfn
 sp_flush ((integer f)) ((integer))
 (let (ret)
   (if (eq 0 f)
       (setq ret (reval@nameserver `(setq _sp-flush_ , nil)))
     (setq ret (reval@nameserver `(setq _sp-flush_ , T))))
   (foreign-result (if ret 1 0))))

(foreign-lispfn
 sp_stdout ((charstring file)) ((charstring))
 (foreign-result 
  (reval@nameserver `(setq _sp-stdout_ , file))))

(foreign-lispfn
 sp_ts_freq ((real f)) ((real))
 (foreign-result 
  (reval@nameserver `(setq _sp-hb-freq_ , f))))

(foreign-lispfn
 sp_proctime_freq ((real f)) ((real))
 (foreign-result 
  (reval@nameserver `(setq _sp-proctime-freq_ , f))))

(foreign-lispfn
 sp_flush_freq ((real f)) ((real))
 (foreign-result 
  (reval@nameserver `(setq _sp-flush-freq_ , f))))

(foreign-lispfn
 sp_flush_freq () ((real))
 (foreign-result
  (reval@nameserver '_sp-flush-freq_)))

(foreign-lispfn
 sp_report_freq ((real f)) ((real))
 (foreign-result 
  (reval@nameserver `(setq _sp-report-period_ , f))))

(foreign-lispfn
 sp_imgsize ((integer sz)) ((integer))
 (foreign-result 
  (reval@nameserver `(setq _sp-imagesize_ , sz))))

;; this is the crude scheduler: Prevent stream processes from being
;; scheduled on hostnums below _base-prephost_
;; _base-prephost_ is changed using foreign-lispfn sp_basehostnum(integer)
(defun incr-prephost (num)
  (setq _current-prepcpu_ (+ _current-prepcpu_ 1))
  (cond ((eq _current-prepcpu_ (caar (getfunction 'cpus_per_host ())))
	 (setq _current-prepcpu_ 0)
	 (setq _current-prephost_ (+ _current-prephost_ 1))
	 (if (eq _current-prephost_ num)
	     (setq _current-prephost_ _base-prephost_)))))

(defun baseprephost (i)
  (setq _base-prephost_ i)
  (setq _current-prephost_ i))

(defun currentprephost (i)
  (setq _current-prephost_ i))

(defun getdefault-host ()
  (let ((phosts (caar (getfunction 'prephosts ()))))
    (prog1 (aref phosts _current-prephost_)
      (incr-prephost (array-total-size phosts)))))

;; (defglobal _index-seq_
;;   (vector 1 3 5 0 0 0 0
;; 	  1 1 1 2 2 2 2
;; 	  3 3 3
;; 	  7
;; 	  4 4 4 4
;; 	  5 5 5 6 6 6 6
;; 	  7 7 7
;; 	  0 0 0 0 1 1 1 1 2 2 2 2 3 3 3 3
;; 	  4 4 4 4 5 5 5 5 6 6 6 6 7 7 7 7))

;; (defglobal _index-seq_
;;   (vector 0 1 1 2 2 2 2
;; 	  3 2 3
;; 	  1 3 3 3
;; 	  1 1 1
;; 	  0 4 4 4 4
;; 	  5 4 5
;; 	  0 5 5 5
;; 	  0 0 0
;; 	  2 2 2 2 2 2
;; 	  3 3 3 3 3 3
;; 	  1 1 1 1
;; 	  4 4 4 4 4 4
;; 	  5 5 5 5 5 5
;; 	  0 0 0 0))

;; (defun getdefault-host ()
;;   (let* ((phosts (caar (getfunction 'prephosts ())))
;; 	 (defhost (aref phosts (aref _index-seq_ _current-prephost_))))
;;     (formatl t "[hnum " (aref _index-seq_ _current-prephost_)
;; 	     " host " defhost "]" t)
;;     (1++ _current-prephost_)
;;     (if (equal _current-prephost_ (length _index-seq_))
;; 	(setq _current-prephost_ 0))
;;     defhost))

(defun default-rec ()
  (make-record
   (listtoarray
    (list
     "daemon" _daemon-mode_
     "nhost" (caar (getfunction 'prepcoordhost ()))
     "stdout" _sp-stdout_
     "nport" *nsp*
     "flush" _sp-flush_
     "flush-freq" _sp-flush-freq_
     "heartbeat" _sp-heartbeat_
     "proctime" _sp-proctime_
     "profile" _sp-profile_
     "profile-freq" _sp-profile-freq_
     "proctime-freq" _sp-proctime-freq_
     "hb-freq" _sp-hb-freq_
     "report-period" _sp-report-period_
     "imagesize" _sp-imagesize_))))

(defun ipr (request)
  (if (null _coord-sock_) (setq _coord-sock_ (open-socket nil 0)))
  (let* ((rec (merge-records request (default-rec)))
	 (spid (sp-id))
	 (curprephost (getnext-host (record-get request "hostname")
				    (record-get request "hostnum")))
	 (local_exec (localhost? curprephost)))
    (formatl t "[sp-" spid " initiated at " (gethostname) 
	     " listening on port "
             (socket-portno _coord-sock_) " prepared by " curprephost "]" t)
    (record-put rec "spid" spid)
    (if (not (record-get rec "dump"))
	(record-put rec "dump" (caar (getfunction 'dumpfile '()))))
    (cond ((eq 1 (record-get rec "daemon"))
	   (formatl t "[hostname " curprephost "] [peername "
		    (caar (getfunction 'peername (list curprephost))) "]" t)
	   (if (localhost? curprephost)
	       (lspstart rec)
	     (remote-eval
	      `(lspstart , rec)
	      (caar (getfunction 'peername (list curprephost))))))
	  (t
	   (let ((string (spcmd (localhost? curprephost) (record-get rec "exe")
				curprephost curprephost
				(or (record-get rec "dump")
				    (caar (getfunction 'dumpfile '())) "")
				spid)))
	     (system string)
	     (record-put rec "randominit" (and (record-get request "rand") 
					       spid)))
	   (let* ((prepsock (accept-socket _coord-sock_ nil))
		  (prep-portno (prog2 (formatl t "[read port of sp-" spid 
					       " from socket " 
					       (socket-portno prepsock)
                                               " to port " 
					       (socket-portno _coord-sock_))
                                   (read prepsock))))
             (formatl t " as " prep-portno)
	     (pf rec prepsock)
	     (formatl t " nsub: " (record-get rec "nsub") "]" t)
	     (new-port "tcp" (if (localhost? curprephost) (gethostname)
			       curprephost) prep-portno))))))

(foreign-lispfn
 daemon_mode ((integer mode)) ((integer))
 (reval@nameserver `(setq _daemon-mode_ , mode)))

(foreign-lispfn
 hide_sp() ((boolean))
 (reval@nameserver '(setfunction-dynamic
		     'sp_start (list "") '("start /min "))))

(foreign-lispfn
 show_sp() ((boolean))
 (reval@nameserver '(setfunction-dynamic
		     'sp_start (list "") '("start cmd.exe /k"))))
