;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2004 Milena Ivanova, UDBL
;;; $RCSfile: gsdm.lsp,v $
;;; $Revision: 1.41 $ $Date: 2005/12/19 18:18:47 $
;;;
;;; Description: 
;;;  CQ server loop
;;;  Starting other gsdm servers
;;;              
;;; ===========================================================================
(defun load-oper ()
  (load (concat (getenv "AMOS_HOME") "/gsdm/lsp/fft.lsp"))
  (load (concat (getenv "AMOS_HOME") "/gsdm/lsp/polarization.lsp"))
  )

(defun init-gsdm ()
  (load (concat (getenv "AMOS_HOME") "/gsdm/lsp/global_def.lsp"))
  (load-oper)
  (load (concat (getenv "AMOS_HOME") "/gsdm/lsp/str_buffer.lsp"))
  (load (concat (getenv "AMOS_HOME") "/gsdm/lsp/stat.lsp"))
  (load (concat (getenv "AMOS_HOME") "/gsdm/lsp/pushing.lsp"))
  (load (concat (getenv "AMOS_HOME") "/gsdm/lsp/streams.lsp"))
  (load (concat (getenv "AMOS_HOME") "/gsdm/lsp/dataflow_graph.lsp"))
  (load (concat (getenv "AMOS_HOME") "/gsdm/lsp/scheduler.lsp"))
  (load (concat (getenv "AMOS_HOME") "/gsdm/lsp/lispbox.lsp"))
  (load (concat (getenv "AMOS_HOME") "/gsdm/lsp/dataflow_amos.lsp"))
)

(init-gsdm)


(defglobal _dataflow-no_ 1) ;;timesharing between dataflow execution
(defglobal _check-descr-no_ 1)  ;; and listening


(defun register-listening ()
(send-message 
	(list 'osql (concat "gsdm_listening('" _amosid_ "');" ))
	 'STATSRV)
)


;;;**************************************************************************
;;; Redefine run-server and server-eval to distinguish between regular and CQ server
 
(defun run-gsdm-server (ls)
"Execute GSDM listen with parameter ls for listening on sockets"
  (if _amosid_ nil (error "This Amos has no name"))
  (cond (_listenport_)
	(t (setq _listenport_ (startlisten (if _nameserver_ *nsp* 0)))
           (reval@nameserver (list 'set-listenport 
				   (mkstring _amosid_) _listenport_))))
  (if _nameserver_ (princ "Name server " t) (princ "GSDM Server " t))
  (formatl t _amosid_ " listening on port " _listenport_ t)
  (if (null (assoc 'server _comm-state_))
      (setq _comm-state_ (nconc1 _comm-state_ (list 'server T))))
  (setq _keep-running_ t)
  ;; set select time and number of repetitions for check-descr
  (setf (box-paraml _cd_) (list ls))
  (register-listening)
  (while _keep-running_ 
    (if _cq-server_ 
	(run-period)
      (check-descriptors 2)) 
    )
)

(foreign-lispfn listen_gsdm()()
 "Starts GSDM working node"
 (setq _cq-server_ T)
 (run-gsdm-server 0.0))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun cq-server-on ()
  (setq _cq-server_ T)
  (setq _start-imagesize_ (imagesize))
;;(register-starting)
  (prepare-check-descr)
;;(profile-functions 'tcp-put-input 'encode-to-binary 'decode-from-binary)
  (init-stat-period (gettimeofday)) ;; init statistics
  )

(foreign-lispfn listen_gsdm((real ls))()
 "Starts GSDM listening with ls listen and dfno repetitions of exec-dataflow"
	  (run-gsdm-server ls))
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Primitives for starting gsdm working nodes from inside the coordinator
(defun start-gsdm (opt)
"Starts working node with visualization and signal generator- gsdm.exe"
  (let* ((gsdm_exe (concat (getenv "AMOS_HOME") "/gsdm/gsdm.exe"))
	 (gsdm_dmp (concat (getenv "AMOS_HOME") "/gsdm/gsdm.dmp"))
	 (options (if (null opt) "" opt)))
    (system (concat "start " gsdm_exe
		    " -b "   gsdm_dmp
		    " "	    options))))

(foreign-lispfn start_gsdm ((charstring osqlscript)) ()
 (start-gsdm (concat " -O " osqlscript)))

(defun start-wn (opt)
"Starts working node"
  (let* ((gsdm_exe (concat (getenv "AMOS_HOME") "/bin/bcast.exe"))
	 (gsdm_dmp (concat (getenv "AMOS_HOME") "/gsdm/gsdm.dmp"))
	 (options (if (null opt) "" opt)))
    (system (concat "start " gsdm_exe
		    " -b "   gsdm_dmp
		    " "	    options))))

(foreign-lispfn start_wn ((charstring osqlscript)) ()
(start-wn (concat " -O " osqlscript)))

(foreign-lispfn start_wn_opt ((charstring opt)) ()
 (start-wn opt))

(defun start-amos (opt)
"Starts original amos"
  (let* ((amos_exe (concat (getenv "AMOS_HOME") "/bin/amos2.exe"))
	 (amos_dmp (concat (getenv "AMOS_HOME") "/bin/amos2.dmp"))
	 (options (if (null opt) "" opt)))
    (system (concat "start " amos_exe
		    " -b "   amos_dmp
		    " "	    options))))

(foreign-lispfn start_amos ((charstring opt)) ()
 (start-amos opt))

(foreign-lispfn start_amos ((charstring opt)(charstring nm)) ()
	(if (null (get-amos-info nm)) (start-amos opt)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun make-profile (fn def params)
  `((let ((**time** (getprop (quote , fn) 'time))
	  (**cnt** (getprop (quote , fn) 'calls))
	  **start** **elapsed**)
      (setq **start** (gettimeofday))
      (unwind-protect 
	  , def
	(progn
	  (setq **elapsed** (wallclocktime (gettimeofday) **start**))
	  (putprop (quote , fn) 'time
		   (roundto (+ **elapsed** (or **time**  0)) _clock_resolution_))
	  (putprop (quote , fn) 'calls
		   (1+ (or **cnt** 0))))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defglobal _prof-comm_ (list 'tcp-put))

(defglobal _prof-op_ nil)


(defun profile-fun (flist)
"Add functions in flist to the list of profiled functions _prof-op_ "
(setq _prof-op_ (append2 _prof-op_ flist))
)

(foreign-lispfn prof_fun ((charstring fnname)) () 
	(profile-fun (list (mkatom fnname)))
	(foreign-result)
)

(defun profile-comm ()
(eval (cons 'profile-functions _prof-comm_)))

(defun profile-op ()
(eval (cons 'profile-functions _prof-op_)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(foreign-lispfn set_schedule((integer chd)(integer dfn)) ()
(setq _check-descr-no_ chd)
(setq _dataflow-no_ dfn)
)

(defun set-max-cnt (n)
(setq _max-exec-cnt_ n))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun register-amos-at (logical-name addr &optional reregister)
   ;;; Inform name server about the name of this AMOS. 
   ;;; Then name will be bound to _AMOSID_.
  (let ((name (amos-servername logical-name)))
    (reval@nameserver `(register-in-nameserver 
			(quote , name) , (mkstring addr) -1 , reregister))
    (commit)
    (set-amos-servername name reregister)
    ))

(foreign-lispfn register_at ((charstring name)(charstring addr))((charstring))
		  "Register this database as inactive peer"	
		  (register-amos-at name addr)
		  (foreign-result name)
		  )

(defun trace-sockets ()
(mapc (f/l (s)
	(if (output-TCP-strp s)
	(let ()
		(print 	(getobject s 'name) )
	(print (socketstat (port-socket 
			  (get-port-named (getobject s 'dest)))))
	)))	
 (mapcar 'car (osql "select s from stream s;"))))

