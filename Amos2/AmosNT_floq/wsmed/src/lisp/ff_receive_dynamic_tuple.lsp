
(defglobal _aff-applyp_
 (osql "
create function aff_applyp(function fn, bag args, Integer width)
                                 -> object
  as foreign 'aff-applyp';"))

(set-resulttypesfn _aff-applyp_ (function aff-applyp-resulttypes))

(defglobal _fn_ nil)
(defglobal _sendingfn_ nil)
(defglobal  _firsttime_ 1)
(defglobal _availablepeers_ 60)
(defglobal _peers_ nil)
(defglobal _initnodes_ 2)
(defglobal _stop_ nil)
(defglobal  _pertuple_ 0)
(defglobal  _prepertuple_ 0)
(defglobal _count_ 0)


(defun aff-applyp-resulttypes (fno args)
   (and (numberp (forth args))(buildn (forth args) _object_)))

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



(defun initpeers ()
  (setq _firsttime_ 1)
  (setq _peers_ nil)
  (setq _sendingfn_ nil)
  (setq _initnodes_ 4)
  (setq _stop_ nil)
  (setq  _pertuple_ 0)
  (setq  _prepertuple_ 0)
  )

(defun findpeerno (peerid)
  (let ((pl (cdr (explode (mksymbol peerid))))
        str)
    (dolist (x pl)
      (if str (setq str (concat str x))
	(setq str (mkstring x))))
   (mksymbol str) )
  )

(defun aff-applyp (fno fn args width res)
  (let* (peerno  rd  ports sockets (thispeer -1) termin (listeningpeers 0) hasvalue nextpeer ff currentpeer nextpeerl  lp  fol as newpeers
		 inittime exetime (preexetime 0) peers1 ports1 sockets1 (threshold 0.25)(rscount 0) (prerscount 0) (lowrscount 0) preports 
		 (ackcount 0)tempsoc rerror)
    
    
    (if (not _peers_)
	(setq _peers_ (remote-eval (list 'getpeer (kwote _initnodes_))(port-of-peer "nameserver"))))
          
    (setq ports (mapcar (function port-of-peer) _peers_))
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
		       (if (= thispeer (Length _peers_))
			   (setq thispeer 0)
			 (setq thispeer (1+ thispeer)))
		       (setq currentpeer (nth thispeer _peers_)))
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
	        		  
		 (if (= listeningpeers (Length _peers_))
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
									(list*  fn args width rd)))))))))
			 
			    
			   
			   (if (and (= ackcount (length _peers_))(> rscount 0) (not _stop_));; adaptive phase
			       (progn
				 (setq exetime (- (clock) inittime))
				 (quote 
				  (print "execution time")
				  (print exetime)
				  (print "pre execution time")
				  (print preexetime))
				 (setq _prepertuple_ _pertuple_)
				 (setq _pertuple_ (/ (* exetime 1.0) rscount))

				 (quote (print (concat "pertuple " _pertuple_))
					(print (concat "prepertuple " _prepertuple_)))
				 (if _firsttime_ (setq rerror 1)
				   (progn (setq rerror (/ (- _prepertuple_  _pertuple_) (* _prepertuple_ 1.0)))
					  ))

			
				 (if (or _firsttime_ (< threshold rerror))
				     (progn 
				       (quote 
				       (setq _prepertuple_ (/ (* exetime 1.0) rscount)))
				       (setq prerscount (* rscount 1.0))
				       (setq newpeers (remote-eval (list 'getpeer (kwote 2))(port-of-peer "nameserver")))
				       (if newpeers
					   (progn
					     (setq _count_ (+ _count_ 1))
					     (quote (print (concat "newpeers " newpeers)))
					     (dolist (p newpeers)
					       (setq nextpeerl (adjoin p nextpeerl))
					       (setq _peers_ (adjoin (mkstring p) _peers_)))
  
					     (setq preports ports)
					     (setq ports1 (mapcar (function port-of-peer) newpeers))
					     (dolist (p ports1)(send-form (list 'compile-function (kwote (EXTERNALIZE-FNDEF fn))) p))
					     (setq ports (union ports ports1))
					     (setq sockets (mapcar (function port-socket) ports))
					     (setq _firsttime_ nil)
					     (setq termin 1)
					     (setq preexetime exetime)
					     )
					 (setq _stop_ 1))
 
				       )
				   (if (>= threshold rerror)
				       (progn;;back off the proceses
					 
					 (setq _stop_ 1)
					 (quote 
					  (print "stop")
					  (print _prepertuple_)
					  (print _pertuple_))
					 (quote
					  (if (> (length _peers_) 2)
					      (progn
						(print (concat  _peers_ " removed process " (car nextpeerl)))
						(send-form (list 'addpeerl (kwote (list (car nextpeerl)))) 'nameserver)
						(setq _peers_ (remove (car nextpeerl) _peers_))
						(quote (setq sockets (remove tempsoc sockets)));; have to check no pending results in the socket
						(setq nextpeerl (cdr nextpeerl))
						)))
					 )))
				  
				 (setq ackcount 0)
				 (setq rscount 0)
				 (if (not nextpeerl)
				     (setq inittime (clock))
				   (setq inittime nil))
				 ))

			   (if (and (= ackcount (length _peers_))(= rscount 0))
			       (progn
				 (setq ackcount 0)
				 (setq inittime nil)
				 ))
			   (if _stop_
			       (progn
				 (setq ackcount 0)
				 (setq rscount 0)
				  ))
			   (if (not nextpeerl)
				      (setq termin nil))
			    			  
			   (if termin 
			       (progn (setq nextpeerl (reverse nextpeerl))(setq termin nil)(return row)))
 
			   ));; end of while
		       ));; end of if
		 ));; end of map bag
  
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
						      (list*  fn args width rd)))))))))
	      ))))

    (print (concat "final_peers  "  _peers_ ))

    (if (eq _amosid_ 'me)
	(progn
	  (global-eval '(initpeers ))
	  (send-form (list 'setintial ) 'nameserver)))
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


