
;; the argument record:
;; exe, the executable
;; ssh, if it is to be started using ssh
;; incomes, which is a vector of incoming source, when this is "nil" it is a SOURCE
;; merge, merge function to read from the in sockets
;; outhosts, which is a vector of addresses to send the stream to, when this is "nil" it is a SINK
;; dispatch, dispatch functions to send the derived stream

;; the source program should be run by:
;;               SOURCE.exe destinaddr portno
;; a dsms can also be wrappered by:
;;               SCSQ-LR.exe sourceaddr portno destinaddr portno
;; the sink porgram should be run by:
;;               SINK.exe sourceaddr portno

(defglobal _coordsock_ nil)   

(defun defaultr ()
  (make-record
   (vector
    "exe" "amos2"
    "merger" (function merger)
    "dispatcher" (function dispatcher))))    

(defun vector?tostring (v sep)
  (if (not (arrayp v)) v
    (let ((res ""))
      (maparray v
		(f/l (e i)
		     (if (= i 0) (setq res (concat res e))
		       (setq res (concat res sep e)))))
      res)))

(foreign-lispfn new_external ((Record r) (Charstring curhost)) ((Sp))  ;; NOTE: when it is a sink there will be no return value
  (let ((res (external r curhost)))
    (foreign-result res)))

(defun external (r curhost)
  (if (null _coordsock_) (setq _coordsock_ (open-socket nil 0)))
  (setq r (merge-records r (defaultr)))
  (system (concat "start svali svali.dmp -l \"(wrapper-external " r " \\\"" curhost "\\\" " (socket-portno _coordsock_) ")\""))
  (let ((sock (accept-socket _coordsock_ nil)))
    (read sock)))

(foreign-lispfn new_internal ((Record r) (Charstring curhost)) ((Sp))
  (let ((res (internal r curhost)))
    (foreign-result res)))

(defun internal (r curhost)
  (if (null _coordsock_) (setq _coordsock_ (open-socket nil 0)))
  (setq r (merge-records r (defaultr)))
  (help 1)
  (let ((ssh (record-get r "ssh"))
	(exe (vector?tostring (record-get r "exe") " "))
	(portno (socket-portno _coordsock_)) cmd)
    (setq cmd (if ssh (concat "start ssh " ssh " " exe)
		(concat "start " exe)))
    (system (concat cmd " -l \"(wrapper-internal " r "\\\"" curhost "\\\" " portno ")\""))
    (let ((sock (accept-socket _coordsock_ nil)))
      (read sock))))

(defun wrapper-internal (r curhost hostno)
  (let ((sock (open-socket curhost hostno))
	(incomes (record-get r 'incomes))
	(generator (record-get r 'generator))
	(merger (record-get r 'merger))
	(dispatcher (record-get r 'dispatcher))
	(outhosts (record-get r 'outhosts)))
    (help 1)
    (cond (outhosts
	   (let* ((s (open-socket nil 0))
		  (sno (socket-portno s)) ssock)
	     (pf (new-port "tcp" curhost sno) sock)
	     (cond (incomes
		    (setq ssock (accept-socket s nil))
		    (apply merger (list (listtoarray (mapcar (f/l (e)
								  (open-socket (port-gethostname (car e)) (port-getportno (car e))))
							     (arraytolist incomes)))
					dispatcher ssock)))
		   (t
		    (setq ssock (accept-socket s nil))
		    (help 2)
		    (mapbag generator
			    (f/l (e) (apply dispatcher (list (car e) ssock))))
		    (pf 'EOF ssock)))))
	  (t
	   (apply merger (list (listtoarray (mapcar (f/l (e)
							 (open-socket (port-gethostname (car e)) (port-getportno (car e))))
						    (arraytolist incomes)))))
	   (pf 'STOP sock)))))

(defun wrapper-external (r curhost hostno)
 (let* ((sock (open-socket curhost hostno))  ;; socket for coord
	(ext (open-socket nil 0))
	(extno (socket-portno ext)) extsock  ;; socket for external 
	(ssh (record-get r 'ssh))
	(exe (vector?tostring (record-get r 'exe) " "))
	(merger (record-get r 'merger))
	cmd dispatcher incomes outhosts)
   (setq cmd (if ssh (concat "start ssh " ssh " " exe)
	       (concat "start " exe)))
   (cond ((setq outhosts (record-get r 'outhosts)) ;; reminder: right now only one output, to do: vector of outhosts
	  (let* ((s (open-socket nil 0))
		 (dispatcher (record-get r 'dispatcher))
		 (sno (socket-portno s)) ssock)        ;; socket sent back to coord
	    (pf (new-port "tcp" curhost sno) sock)  ;; as a return value of (cp r curhost)	    
	    (cond ((setq incomes (record-get r 'incomes))
		   (dolist (income (arraytolist incomes))
		     (setq cmd (concat cmd " " (port-gethostname income) " " (port-getportno income))))
		   (formatl t (setq ssock (accept-socket s nil)) t)      ;; accept this first: out
		   (system (concat cmd " " outhosts " " extno))
		   (formatl t (setq extsock (accept-socket ext nil)) t)  ;; in
		   (pf 'START extsock)
		   (apply  merger (list (vector extsock) dispatcher ssock)))
		  (t
		   (system (concat cmd " " outhosts " " extno))
		   (formatl t (setq ssock (accept-socket s nil)) t)      ;; accept this first: out
		   (formatl t (setq extsock (accept-socket ext nil)) t)  ;; in
		   (pf 'START extsock)
		   (apply merger (list (vector extsock) dispatcher ssock))))))
	 (t
	  (setq incomes (record-get r 'incomes))
	  (dolist (income (arraytolist incomes))
	    (setq cmd (concat cmd " " (port-gethostname income) " " (port-getportno income))))
	  (system cmd)
	  (pf 'STOP sock))))
 (quit))


(defun merger (vs dispatcher out)
  (let ((sockets (arraytolist vs)))
    (while sockets
      (mapc (f/l (s)
		 (let (e)
		   (if (poll-socket s 0.1)
		       (progn (setq e (read s))
			      (cond ((equal 'EOF e)
				     (pf 'EOF out)
				     (close-socket s)
				     (setq sockets (remove s sockets)))
				    (t
				     (apply dispatcher (list e out))))))))
	    sockets))))    


(defun sink (s)
  (let ((sockets (arraytolist s)))
    (while sockets
      (mapc (f/l (s)
		 (let (e)
		   (if (poll-socket s 0.1)
		       (prog (setq e (read s))
			     (cond ((equal 'EOF e)
				    (close-socket s)
				    (setq sockets (remove s sockets)))
				   (t
				    (formatl t e t)))))))
	    sockets))))   

(defun dispatcher (e out)
  (pf e out))

(foreign-lispfn retrieve ((Sp p)) ((Object))
    (let ((s (open-socket (port-gethostname p) (port-getportno p)))
            e)
       (while (neq 'EOF (setq e (read s)))
	 (foreign-result (car e)))))

