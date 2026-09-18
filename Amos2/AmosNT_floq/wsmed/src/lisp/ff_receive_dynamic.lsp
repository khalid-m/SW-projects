
(defglobal _ff-receive_
 (osql "
create function ff_receive(integer rrpos, function fn, bag args, Integer width)
                                 -> object
  as foreign 'ff-receive';"))

(set-resulttypesfn _ff-receive_ (function ff-receive-resulttypes))

(defglobal _fn_ nil)
(defglobal _sendingfn_ nil)
(defglobal  _firsttime_ 1)
(defglobal _availablepeers_ 60)
(defglobal peers nil)
(defglobal _initnodes_ 2)
(defglobal _count_ 0)
(defun ff-receive-resulttypes (fno args)
   (and (numberp (fifth args))(buildn (fifth args) _object_)))

(defun pf (x s)
  (print x s)
  (flush s))

(defun startprocess (r d)
  "lp- lastpeer r -number of peers d- meta dump"
  (let* (s as pl lp )
    (setq as (amos-servers))
    (if (eq (length as) 2)
	(setq lp -1)
      (setq lp (findpeerno (car (last as)))))
    
    (setq s (1+ lp))
    (dotimes (i r)
      (system  (concat "peer.vbs " d " " (+ i s)))
      (while (neq (length (amos-servers)) (+ (length as) (1+ i))))
      (setq pl (adjoin (concat "P" (+ i s)) pl))
      )
    pl
    ))

(defun findpeerno (peerid)
  (let ((pl (cdr (explode (mksymbol peerid))))
        str)
    (dolist (x pl)
      (if str (setq str (concat str x))
	(setq str (mkstring x))))
   (mksymbol str) )
  )

(defun ff-receive (fno rrpos fn args width res)
  (let* (peerno  rd  ports sockets (thispeer -1) termin (listeningpeers 0) hasvalue nextpeer ff currentpeer nextpeerl  lp  fol as newpeers
		 inittime exetime (preexetime 0) peers1 ports1 sockets1 (threshold 0.5) (rscount 0) (prerscount 0) (lowrscount 0) preports 
		 (ackcount 0)tempsoc)
    
    (setq _firsttime_ 1)
    (if (not peers)
	(progn 
	 
	  (if (eq (length (amos-servers)) 1);;start number of (initnodes) processes) 
	      (setq peers (startprocess _initnodes_ "wsmed.dmp"))
	    (setq peers (remote-eval (list 'startprocess (kwote _initnodes_) (kwote "wsmed.dmp"))(port-of-peer "co"))))
	  (osql "sleep(1);")
	  ))

    (setq ports (mapcar (function port-of-peer) peers))
    (if (neq _sendingfn_ fn)
	(progn (setq _sendingfn_ fn)
	       (dolist  (p ports) (send-form (list 'compile-function (kwote (EXTERNALIZE-FNDEF fn))) p)
			)))
    (setq sockets (mapcar (function port-socket) ports))
              
    (mapbag args
	    (f/l (row)
		 (if (not hasvalue)
		     (setq hasvalue 1))
		 
		 (if (not ff)
		     (progn 
		       (if (= thispeer (Length peers))
			   (setq thispeer 0)
			 (setq thispeer (1+ thispeer)))
		       (setq currentpeer (nth thispeer peers)))
		   (if (> (length nextpeerl) 0);; check the free peers
		       (progn (setq currentpeer (car nextpeerl))
			      (setq nextpeerl (cdr nextpeerl)))))
		
		
			 
		 (send-form (list 'start-function 
				  (kwote row))
			    (port-of-peer currentpeer))
		 (send-form (list 'report-ack) (port-of-peer currentpeer))
		
		 (setq listeningpeers (1+ listeningpeers))

		  (if (and (= ackcount 0) (not inittime))
		     (setq inittime (clock)))
	        		  
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
							    (setq ackcount (1+ ackcount))
							    ;; find the peer that finished its execution
							    (dolist (p ports)
							      (if (eq (port-socket p) e)
								  (progn  
								    (setq nextpeerl (adjoin (mkstring (port-name p)) nextpeerl))
								    (setq tempsoc e)
								    (return t)
								    )))
							    							    
							    (setq termin 1)
							    (setq listeningpeers (1- listeningpeers))
							   
							    ))
							 (t
							  ;; emit
							  (progn (setq rscount (1+ rscount))
								 (apply (function osql-result)
									(list*  rrpos fn args width rd)))))))))
			 
			    
			
			   (if (and (= ackcount (length peers))(> rscount 0))
			       (progn
				 (setq exetime (- (clock) inittime))
				 (quote
				 (print "execution time")
				 (print exetime)
				 (print "pre execution time")
				 (print preexetime))
				 (if (or _firsttime_ (and (< threshold (abs (- exetime  preexetime))) (>  (/ (* rscount 1.0) (length peers)) prerscount)(< exetime preexetime) (<=  (+ (length peers) 1) _availablepeers_ )))
				     (progn 
				       (setq _count_ (1+ _count_))
				       (setq prerscount (/ (* rscount 1.0) (length peers)))
				       (setq newpeers (remote-eval (list 'startprocess (kwote (expt 2 _count_)) (kwote "wsmed.dmp"))(port-of-peer 'co)))
				       (quote (setq newpeers (remote-eval (list 'startprocess (kwote 2) (kwote "wsmed.dmp"))(port-of-peer 'co))))
				       (osql "sleep(1);")
				       (dolist (p newpeers)
					 (setq nextpeerl (adjoin p nextpeerl)))
				       (dolist (p newpeers)
					 (setq peers (adjoin (mkstring p) peers)))  
				       (setq preports ports)
				       (setq ports1 (mapcar (function port-of-peer) newpeers))
				       (dolist (p ports1)(send-form (list 'compile-function (kwote (EXTERNALIZE-FNDEF fn))) p))
				       (setq ports (union ports ports1))
				       (setq sockets (mapcar (function port-socket) ports))
				       (setq _firsttime_ nil)
				       (setq termin 1)
				       (setq ackcount 0)
				       (setq preexetime exetime)
				       
				       
				       )
				   (if (and (< threshold (abs (- exetime  preexetime)))(> exetime  preexetime)(< (/ (* rscount 1.0) (length peers)) prerscount) (> (length peers) 1));;back off the proceses
				       (progn 
					 (print "back off")
					 (quote	(print (/ (* rscount 1.0) (length peers)))
						(print prerscount))

					 (quote 
					  (send-form (list 'kill_lowpeers) (port-of-peer (car nextpeerl)))
					  (send-form '(osql "quit;")(port-of-peer (car nextpeerl)))
					  (close-named-port (car nextpeerl)))
					 
					 
					 (print (concat  peers " removed process " (car nextpeerl)))
					 (setq peers (remove (car nextpeerl) peers))
					 (setq sockets (remove tempsoc sockets))
					 (setq nextpeerl (cdr nextpeerl))
					 
					 (print (concat peers "after removal " nextpeerl ))
					  
					 (if (not nextpeerl)
					     (setq termin nil))
					 					 
					 (setq ackcount 0)
					 )))

				
				 (setq rscount 0)
				 (if (= ackcount 0) 
				     (if (not nextpeerl)
					 (setq inittime (clock))
				       (setq inittime nil)))
				 ))

			   (if (and (= ackcount (length peers))(= rscount 0))
			       (progn
				 (setq ackcount 0)
				 (setq inittime nil)
				 ))
			     
				 
			  
			   (if termin 
			       (progn (setq nextpeerl (reverse nextpeerl))(setq termin nil)(return row)))))
 
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
					       (dolist (p ports)
						 (if (eq (port-socket p) e)
						     (progn  
						       (setq nextpeer (mkstring (port-name p)))
						       (quote
							(print "last receive")
							(print nextpeer))
						       (return t)
						       )))
					       (setq sockets 
						     (remove e sockets))
					       (if (eq listeningpeers 0)
						   (setq sockets nil))
					       ))
					    (t
					     ;; emit
					     (progn 
					       (apply (function osql-result)
						      (list*  rrpos fn args width rd)))))))))
	      ))))
    (print (concat peers " " listeningpeers))
    (quote (if (eq rrpos 1)
	       (osql "kill_all_peers()	;")));;kill all peers
  
    ))
   
(defun start-function (args)
  "This function runs on child and sends result back on client port"
  (let ((s (port-socket *client-port*)))
    (mapfunction _fn_ args
		 (f/l (row)
		      (pf row s)))
    ))					



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


