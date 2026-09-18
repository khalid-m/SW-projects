(defglobal _did-counter_ 0)
(defglobal _daemon-sock_ nil)

(defun daemon-id ()
  (1++ _did-counter_))

(defun esc-quote (local_exec)
  (cond (local_exec "\"") (t "\\\" ")))

(defun qdaemon (fno chost cport idno res)
  (setq _destnode_ nil)
  (setq _scsq-id_ (concat "scsqd-" idno))
  (formatl t "[" _scsq-id_ "] daemon entering" t)
  (set-nameserverhost chost)
  (setq *nsp* cport)
  (register-amos _scsq-id_ t)
  (run-server))

(osql "create function qdaemon(charstring chost, integer cport, integer idno)
       -> integer as foreign 'qdaemon';")

(defun localdaemon (r)
  (record-get r "daemon"))

(defun lspstart (r)
  (if (null _daemon-sock_) (setq _daemon-sock_ (open-socket nil 0)))
  (let ((exe (or (record-get r "exe")
		 (caar (getfunction 'prepstartcmd (list "")))))
	(dmp (or (record-get r "dump") ""))
	(stdout (record-get r "stdout"))
	(spid (record-get r "spid")))
    (formatl t "lspstart spid=" spid " dsock=" _daemon-sock_ t)
    (system
     (esc-sh (concat "source $HOME/.bashrc && " exe " " dmp
		     " -r" stdout spid
		     " -o lsproc2("
		     spid ","
		     (socket-portno _daemon-sock_)
		     "," (localdaemon r) "); &"))))
  (let* ((prepsock (accept-socket _daemon-sock_ nil))
	 (prep-portno (read prepsock)))
    (formatl t "[prep " prepsock)
    (pf r prepsock)
    (formatl t "]" t)
    (new-port "tcp" (gethostname) prep-portno)))
