
(defglobal _fh_ nil)

(foreign-lispfn 
 write2log ((Bag b) (Charstring filename) (Charstring mode)) ((Object o))
  (let (fh (firsttime T))
    (mapbag b
	    (f/l (row)
		 (if (or (not _fh_) (not (file-exists-p filename)))
		     (setq _fh_(openstream filename mode)))
		   (pf (car row) _fh_)
		 (foreign-result (car row))))))

(foreign-lispfn stream_wrapper0 ((Charstring exec) (Charstring host) (Integer portno)) ((Record r))
  (let* ((s (open-socket nil 0))
	(sno (socket-portno s))
	socket)
    (system (concat "start " exec " " host " " portno " localhost " sno))
    (setq socket (accept-socket s 1))
    (if (null socket) (error "Connection with the wrapper failed"))
    (pf 'START socket)
    (while socket
      (if (socket-closed socket) (prog (close-socket socket)
				       (setq socket nil))
	(foreign-result (json-read socket))))))

(osql "create function stream_wrapper(charstring exec, charstring host, integer portno)
                                   -> stream as streamof(stream_wrapper0(exec, host, portno));")