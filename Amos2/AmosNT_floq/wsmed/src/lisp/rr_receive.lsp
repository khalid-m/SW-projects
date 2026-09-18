
(defglobal _rr-receive_
 (osql "
create function rr_receive(integer initnodes, function fn, bag args, Integer width)
                                 -> object
  as foreign 'rr-receive';"))

(set-resulttypesfn _rr-receive_ (function rr-receive-resulttypes))

(defglobal _fn_ nil)
(defglobal _rscount_ 0)
(defglobal _count_ 0)
(defglobal _prelowrscount_ 0)
(defglobal _firsttime_ nil)

(defglobal peers nil)

(defun rr-receive-resulttypes (fno args)
   (and (numberp (forth args))(buildn (forth args) _object_)))

(defun pf (x s)
  (print x s)
  (flush s))

(defun findcwocount (peerid)
  (let ((pl (cdddr (explode (mksymbol peerid))))
        str)
    (dolist (x pl)
      (if str (setq str (concat str x))
	(setq str (mkstring x))))
   (mksymbol str) )
  )

(defun rr-receive (fno initnodes fn args width res)
  (let* (ports sockets rd  inittime exetime (preexetime 0) peers1 ports1 sockets1 (thispeer -1) (threshold 0.5)(lowrscount 0) preports availablepeers)
     
    (quote (startprocess initnodes dmp);;start number of (initnodes) processes 
	   (while (neq (length (amos-servers)) (+ initnodes 1))));; wait until all processes are ready


    (if (not peers)
	(setq peers (get-process-names initnodes)))

    (setq ports (mapcar (function port-of-peer) peers))

    (dolist  (p ports) 
      (send-form (list 'compile-function (kwote (EXTERNALIZE-FNDEF fn))) p))

    (setq sockets (mapcar (function port-socket) ports))
	       
    
    
    (mapbag args
	    (f/l (row) 
		 
		 (setq thispeer (1+ thispeer))
		 (setq _rscount_ (1+ _rscount_))
		 (if (>= thispeer (Length peers))(progn 
						   (setq thispeer 0)
						   (print "resultcount")
						   (print lowrscount)
						   (setq availablepeers (remote-eval (list 'get_no_of_peers ) 'nameserver));; get available peers
						   (if ( not _firsttime_ )
						       (progn;;very first time of rr_receive
							 (setq _count_ (1+ _count_))
							 (setq peers1 (get-process-names (expt 2 _count_)))
							 (setq peers (union peers peers1))
							 (print (concat "total processes " (length peers) "  added processes " (length peers1)))
							 (setq preports ports)
							 (setq ports1 (mapcar (function port-of-peer) peers1))
							 (dolist (p ports1)(send-form (list 'compile-function (kwote (EXTERNALIZE-FNDEF fn))) p))
							 (setq ports (union ports ports1))
							 (setq _prelowrscount_ lowrscount)
							 (setq _firsttime_ 1)
							 )
						     (progn	 
						       (if (and (< threshold (abs (- exetime  preexetime))) (>=  lowrscount _prelowrscount_)(< exetime preexetime)(>= lowrscount (length peers)) (<=  (+ (length peers) (expt 2 (1+ _count_))) availablepeers ))
							   (progn
							     (setq _count_ (1+ _count_))
							     (setq peers1 (get-process-names (expt 2 _count_)))
							     (setq peers (union peers peers1))
							     (print (concat "total processes " (length peers) "  added processes " (length peers1)))
							     (setq preports ports)
							     (setq ports1 (mapcar (function port-of-peer) peers1))
							     (dolist (p ports1)(send-form (list 'compile-function (kwote (EXTERNALIZE-FNDEF fn))) p))
							     (setq ports (union ports ports1))
							     (setq _prelowrscount_ lowrscount)
							     )
							 (if (and (> exetime  preexetime)(<  lowrscount _prelowrscount_));;back off the proceses
							     (progn 
							       (print "back off")
							       (remove-process peers1)
							       (setq peers (set-difference peers peers1))
							       (print (concat "processes " (length peers) "  removed processes " (length peers1)))
							       (setq ports preports))
							   ))))

						   (setq preexetime exetime)
						   (setq lowrscount 0)
						   (setq sockets (mapcar (function port-socket) ports))
				         	   
						   ))
		 
		 (if (= thispeer 0) (setq inittime (clock)))
		 (send-form (list 'start-function 
				  (kwote row))
			    (port-of-peer (nth thispeer peers)))
                  
		 (if (= thispeer (1- (Length peers)))
		     (progn 
		       (broadcast-eof peers)
		       (while sockets;; Start receiving data from peers
			 (let ((socks (poll-sockets (listtoarray sockets) 1)));; Poll parallell
			   (cond ((null socks) nil);; Timeout
				 (t (maparray socks 
					      (f/l (e i)
						   (setq rd (read e))
						   (cond ((string-like (mkstring rd) "_ak*")
							  ;; Stream done
							  (progn (setq lowrscount (+ lowrscount (findcwocount rd)))
								 (setq sockets 
								       (remove e sockets))))
							 (t
							  ;; emit
							  (apply (function osql-result)
								 (list* initnodes fn args width rd))))))))))
								    						       
		       (setq exetime (- (clock) inittime))
		       (print "execution time")
		       (print exetime)
		       (print "pre execution time")
		       (print preexetime)
		       ))
		 ))
    
    (if (and (> thispeer -1)(< thispeer (1- (length peers))));; if data stream finished in the middle
	(progn 
	  
	  (broadcast-eof peers)
	  (setq count 0)
	  (while sockets;; Start receiving data from peers
	    (let ((socks (poll-sockets (listtoarray sockets) 1)));; Poll parallell
	      (cond ((null socks) nil);; Timeout
		    (t (maparray socks 
				 (f/l (e i)
				      (setq rd (read e))
				      (cond ((string-like (mkstring rd) "_ak*")
					     ;; Stream done
					     (setq sockets 
						   (remove e sockets)))
					    (t
					     ;; emit
					     (apply (function osql-result)
						    (list* initnodes fn args width rd))))))))))
						  
						    						       
	  (setq exetime (- (clock) inittime))
	  (print "execution time")
	  (print exetime)
	  (print "pre execution time")
	  (print preexetime)
	  ))
    
   
    ))


   
(defun start-function (args)
  "This function runs on child and sends result back on client port"
  (let ((s (port-socket *client-port*)))
    ;(print fno)(global-eval '(debugging t)) 
    (mapfunction _fn_ args
		 (f/l (row)
		      (pf row s)))
   					
    ))					

(defun broadcast-eof (pl)
  (dolist (p pl) (send-form (list 'report-ack) (port-of-peer p))))



(defun report-ack ()
  (let ((cc _rscount_))
    (setq _rscount_ 0)
    (pf (concat "_ak" cc) (port-socket *client-port*))
    ))

(defun compile-function (fn)
  (setq _fn_ (INTERNALIZE-CODE fn)))


(defun get-process-names (no) 
  "get peers"
  (let (str pl)
    (setq pl (remote-eval (list 'getpeer (kwote no)) 'nameserver))
    (dolist (x pl)
      (setq str (adjoin (concat "p" x) str)))
    (reverse str))
  )

(defun remove-process (pl) 
  "remove peers"
  (let (rpl p q )
    (dolist (x pl)
      (setq p (cdr (explode (mksymbol x))))
      (setq q nil)
      (dolist (y p)
	(if q 
	    (setq q (concat y q))
	  (setq q (mkstring y))))
      (setq rpl (adjoin (mksymbol q)  rpl)))
    (send-form (list 'removepeerl (kwote rpl)) 'nameserver))
  )
  





(defun startprocess(lp r d)
  "lp- lastpeer r -number of peers d- meta dump"
  (let* ((s (1+ lp)))
       
    (dotimes (i r)
      (system  (concat "peer.vbs " d " " (+ i s)))
      )))