
(defglobal _rr-receive_
 (osql "
create function rr_receive( Integer damper, Integer fanout, Integer rrpos, function fn, bag args, Integer width)
                                 -> object
  as foreign 'rr-receive';"))

(set-resulttypesfn _rr-receive_ (function rr-receive-resulttypes))



(defun rr-receive-resulttypes (fno args)
   (and (numberp (sixth args))(buildn (sixth args) _object_)))

(defun pf (x s)
  (print x s)
  (flush s))



(defun rr-receive (fno d fanout rrpos fn args width res)
  (let* (ports  rd peers 
		(thispeer -1))
     
    (setq peers (find-peers-rr rrpos fanout d ))
    (setq ports (mapcar (function port-of-peer) (arraytolist peers)))
    (setq sockets (mapcar (function port-socket) ports))
       
    (mapbag args
	    (f/l (row) 
		 (setq thispeer (1+ thispeer))
		 
		 (if (>= thispeer (Length peers))(setq thispeer 0))
		 
		 (send-form (list 'start-function (kwote (EXTERNALIZE-FNDEF fn))
				  (kwote row)(kwote (find-peers-rr (1- rrpos) fanout d)))
			    (port-of-peer (aref peers thispeer)))))
    
    
    (broadcast-eof peers)
    
    (while sockets;; Start receiving data from peers
      (let ((socks (poll-sockets (listtoarray sockets) 1)));; Poll parallell
	(cond ((null socks) nil);; Timeout
	      (t (maparray socks 
			   (f/l (e i)
				(cond ((eq (setq rd (read e)) 'ack)
				       ;; Stream done
				       (setq sockets 
					     (remove e sockets)))
				      (t
				       ;; emit
				       (apply (function osql-result)
					      (list*  d  fanout rrpos fn args width rd))))))))
	))
    ))
   
(defun start-function (fn args mpeers)
  "This function runs on child and sends result back on client port"
  (let ((fno (INTERNALIZE-CODE fn)) (thissocket -1)(sockets nil))
        
    (dolist (p (arraytolist mpeers))
      (if (eq (port-dbid *client-port*)(mksymbol p))
	  (setq sockets (cons (port-socket *client-port*) sockets))
	(setq sockets (cons (port-socket (port-of-peer p)) sockets))))
  (print sockets)
    (mapfunction fno args
		 (f/l (row) 
		      (setq thissocket (1+ thissocket))
		      (if (>= thissocket (Length sockets))(setq thissocket 0))
   		      (pf row (nth thissocket sockets))
		      ))
   					
    ))					

(defun broadcast-eof (peers rrpos fanout d)
  (maparray peers (f/l (p s)(send-form (list 'report-ack) (port-of-peer p)))))


(defun report-ack ()
 (pf 'ack  (port-socket *client-port*)))

(defun find-peers-rr (rr_pos fanout damper)
  "Find the starting position of peers"
  (let ( (r (round (* fanout damper))) startpos)
      
    (if (eq rr_pos 0) (kwote #("me"))
      (progn (if (eq  rr_pos 1) (progn (setq startpos 0)(setq r fanout))
	       (progn (setq startpos (round (/ (* fanout  (1- (expt r (- rr_pos 1)))) (* (- r 1) 1.0))))
		      (setq r (*  fanout (expt r (- rr_pos 1))))))
	     (arrange-peer startpos r )))
    )
  )


(defun arrange-peer (start fanout) 
  "arrange the order of the peers"
  (let ((str(make-array fanout)))
    (do ((j 0 (+ j 1))) ((eq  j fanout))
      (seta str j (concat "p" (+ j start))))
    str)
  )

