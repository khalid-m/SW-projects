
(defglobal _ff-receive_
 (osql "
create function ff_receive(Vector fanout, Integer rrpos, function fn, bag args, Integer width)
                                 -> object
  as foreign 'ff-receive';"))

(set-resulttypesfn _ff-receive_ (function ff-receive-resulttypes))

(defglobal _fn_ nil)
(defglobal _sendingfn_ nil)

(defun ff-receive-resulttypes (fno args)
   (and (numberp (fifth args))(buildn (fifth args) _object_)))

(defun pf (x s)
  (print x s)
  (flush s))

(defun findpeerno (peerid)
  (let ((pl (cdr (explode (mksymbol peerid))))
        str)
    (dolist (x pl)
      (if str (setq str (concat str x))
	(setq str (mkstring x))))
   (mksymbol str) )
  )

(defun ff-receive (fno fanoutl  rrpos fn args width res)
  (let* (peerno ports sockets rd peers
		(thispeer -1) q termin listenmode (listeningpeers 0) hasvalue nextpeer ff currentpeer)
     
   
    (if (eq _amosid_ 'me) (setq peers (arrange-peer 0 (aref fanoutl 0)))
      (setq peers (find-peers (findpeerno _amosid_) rrpos fanoutl)))
    
    (setq ports (mapcar (function port-of-peer) peers))
    
    (if (or (not _sendingfn_) (neq _sendingfn_ fn))
	(progn (setq _sendingfn_ fn)
	       (dolist  (p ports) (send-form (list 'compile-function (kwote (EXTERNALIZE-FNDEF fn))) p))))
        
    (setq sockets (mapcar (function port-socket) ports))
     
    (mapbag args
	    (f/l (row)
		 (if (not hasvalue)
		     (setq hasvalue 1))
		 
		 (if (not ff)
		     (progn (setq thispeer (1+ thispeer))
			    (setq currentpeer (nth thispeer peers)))
		   (setq currentpeer nextpeer))
		 
		
		 (send-form (list 'start-function 
				  (kwote row))
			    (port-of-peer currentpeer))
		 (send-form (list 'report-ack) (port-of-peer currentpeer))
		 (setq listeningpeers (1+ listeningpeers))
		 
		 (if (= listeningpeers (Length peers))
		     (progn  
		      
		       (while sockets;; Start receiving data from peers
			 (let ((socks (poll-sockets (listtoarray sockets) 1)));; Poll parallell
			   (cond ((null socks) nil);; Timeout
				 (t (maparray socks 
					      (f/l (e i) 
						   (cond ((eq (setq rd (read e)) 'ack)
							  ;; Stream done
							  (progn
							    (setq ff 1)
							    ;; find the peer that finished its execution
							    (dolist (p ports)
							      (if (eq (port-socket p) e)
								  (progn  
								    (setq nextpeer (concat "p" (findpeerno (port-name p))))
								    (return t)
								    )))
							    
							    (setq termin 1)
							    (setq listeningpeers (1- listeningpeers))
							    ))
							 (t
							  ;; emit
							  (apply (function osql-result)
								 (list*  fanoutl  rrpos fn args width rd))))))))
			   (if termin 
			       (progn (setq termin nil)(return row)))))
		       )) 
		 ))
   
    (if (and hasvalue ( > listeningpeers 0))
	(progn 
	       (while sockets;; Start receiving data from peers
		 (let ((socks (poll-sockets (listtoarray sockets) 1)));; Poll parallell
		   (cond ((null socks) nil);; Timeout
			 (t (maparray socks 
				      (f/l (e i) 
					   (cond ((eq (setq rd (read e)) 'ack)
						  ;; Stream done
						  (progn
						    (setq listeningpeers (1- listeningpeers))
						    (setq sockets 
							  (remove e sockets))
						    (if (eq listeningpeers 0)
							(setq termin 1))
						    ))
						 (t
						  ;; emit
						  (apply (function osql-result)
							 (list*  fanoutl  rrpos fn args width rd))))))))
		   (if termin 
		       (progn (setq termin nil)(return t)))))))

    ))
   
(defun start-function (args)
  "This function runs on child and sends result back on client port"
  (let ((s (port-socket *client-port*)))
    ;(print fno)(global-eval '(debugging t)) 
    
    (mapfunction _fn_ args
		 (f/l (row)
		      (pf row s)))
   					
    ))					

(defun broadcast-eof (peers)
  (dolist (p peers) (send-form (list 'report-ack) (port-of-peer p))))



(defun report-ack ()
 (pf 'ack  (port-socket *client-port*)))

(defun compile-function (fn)
  (setq _fn_ (INTERNALIZE-CODE fn)))


(defun find-peers (peer_id rr_pos fl)
  (let ((cp 1) lp peerl peerpos (i 0))
    
    (if (> rr_pos 1)(progn  (while (< i (1- rr_pos))
			      (setq cp (* cp (aref fl i)))
			      (setq i (1+ i)))
			    (setq lp (1- (+ cp (* cp (aref fl (1- rr_pos))))))))
   
    (setq peerpos (+ peer_id cp))
    (setq peerl (list (concat "p" peerpos)))
    (setq peerpos (+ peerpos cp))
    
    (while (<= peerpos lp) 
      (setq peerl (cons (concat "p" peerpos) peerl))
      (setq peerpos (+ peerpos cp))
      )
	       
    (reverse peerl)
    ))

(defun arrange-peer (start fanin) 
  "arrange the order of the peers"
  (let (str)
    (do ((j 0 (+ j 1))) ((eq  j fanin))
      (setq str (cons (concat "p" (+ j start)) str)))
    (reverse str))
  )


