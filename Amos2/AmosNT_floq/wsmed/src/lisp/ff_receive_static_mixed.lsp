
(defglobal _ff-applyp_
 (osql "
create function ff_applyp(Integer level, function fn, bag args, Integer width)
                                 -> Object  as foreign 'ff-applyp';"))

(set-resulttypesfn _ff-applyp_ (function ff-applyp-resulttypes))

(defglobal _mff-applyp_
 (osql "
create function mff_applyp(Integer level, Vector vfn, bag args, Integer width, Vector resorder)
                                 -> Object  as foreign 'mff-applyp';"))

(set-resulttypesfn _mff-applyp_ (function mff-applyp-resulttypes))

(defglobal _fn_ nil)
(defglobal _sendingfn_ nil)
(defglobal _receivedfn_ nil)


(defglobal count 0)
(defglobal resultcount 0)
(defglobal receivedcount 0)

(defun ff-applyp-resulttypes (fno args)
   (and (numberp (fifth args))(buildn (fifth args) _object_)))

(defun mff-applyp-resulttypes (fno args)
   (and (numberp (sixth args))(buildn (sixth args) _object_)))

(defun pf (x s)
  (print x s)
  (flush s))
(defun startprocess (lp r d)
  "lp- lastpeer r -number of peers d- meta dump"
  (let* ((s (1+ lp)))
       
    (dotimes (i r)
      (system  (concat "peer.vbs " d " " (+ i s)))
      )))

(defun findpeerno (peerid)
  (let ((pl (cdr (explode (mksymbol peerid))))
        str)
    (dolist (x pl)
      (if str (setq str (concat str x))
	(setq str (mkstring x))))
   (mksymbol str) )
  )


(defun mff-applyp (fno level vfn args width resorder res)
  (let* (peerno  rd peers ports sockets (thispeer -1) (thisfn 0) termin (listeningpeers 0) 
		 hasvalue nextpeer ff currentpeer nextpeerl needbreak)
    
       
    (if (eq _amosid_ 'me) (setq peers (arrange-peer 0 (aref fanoutl 0)))
      (setq peers (find-peers (findpeerno _amosid_) rrpos fanoutl)))
    
    (setq ports (mapcar (function port-of-peer) peers))
    
    (if (and (neq _sendingfn_ (first vfn))( > (length vfn) 1))
	(progn (setq _sendingfn_ (first vfn))
	       (dolist  (p ports) (send-form (list 'compile-function (kwote (EXTERNALIZE-FNDEF (first vfn)))) p)
			)))
 
    (setq sockets (mapcar (function port-socket) ports))
   
        
    (mapbag args
	    (f/l (row)
		 (if (not hasvalue)
		     (setq hasvalue 1))
		 (while (< thisfn (Length vfn));; to send functions to free peers	 
		   
		   (while (and (< listeningpeers (Length peers))(< thisfn (Length vfn)))
		     ;;find the current peer
		     (if (not ff)
			 (progn 
			   (if (= thispeer (Length peers))
			       (setq thispeer 0)
			     (setq thispeer (1+ thispeer)))
			   (setq currentpeer (nth thispeer peers)))
		       (if (> (length nextpeerl) 0);; check the free peers
			   (progn (setq currentpeer (car nextpeerl))
				  (setq nextpeerl (remove currentpeer nextpeerl)))))
		     ;;find the function to ship
		     (setq thisfn (1+ thisfn))
		     (send-form (list 'start-function 
				      (kwote (EXTERNALIZE-FNDEF (nth thisfn vfn)))
				      (kwote row))
				(port-of-peer currentpeer))
		     ;;request for ack
		     (send-form (list 'report-ack) (port-of-peer currentpeer))
		     (setq count (1+ count))
		     (setq listeningpeers (1+ listeningpeers))
		     )
		     
		   (if (= thisfn (Length vfn))
		       (setq thisfn 0))
		
		   (quote (print "send")
			  (print currentpeer))
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
								      (setq nextpeerl (adjoin (mkstring (port-name p)) nextpeerl))
								      (quote 
								       (print "receive")
								       (print  (mkstring (port-name p))))
								      (return t)
								      )))
							    							    
							      (setq termin 1)
							      (setq listeningpeers (1- listeningpeers))
							   
							      ))
							   (t
							    ;; emit
							    (progn 
							      (apply (function osql-result)
								     (list*  fanoutl  rrpos fn args width resorder rd)))))))))
			     (if termin
				 (progn (setq nextpeerl (reverse nextpeerl))(setq termin nil)
					(return t)))
			       
			     ))
			 ))
		   (if termin
		       (if (eq thisfn 0)
			   (return row)))
		   )
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
						      (list*  fanoutl  rrpos fn args width rd)))))))))
	      ))))
   
    ))


(defun ff-applyp (fno level  rrpos fn args width res)
  (let* (peerno  rd peers ports sockets (thispeer -1) termin (listeningpeers 0) 
		 hasvalue nextpeer ff currentpeer nextpeerl (np 0) (pp -1) fol)
    
    

    
    (if (eq _amosid_ 'me) (setq peers (arrange-peer 0 (aref fanoutl 0)))
      (setq peers (find-peers (findpeerno _amosid_) rrpos fanoutl)))
    
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
			      (setq nextpeerl (remove currentpeer nextpeerl)))))
		 
		 (send-form (list 'start-function 
				  (kwote row))
			    (port-of-peer currentpeer))
		 (send-form (list 'report-ack) (port-of-peer currentpeer))
		 (setq count (1+ count))
		 (setq listeningpeers (1+ listeningpeers))
		 (quote (print "send")
			(print currentpeer))
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
								    (setq nextpeerl (adjoin (mkstring (port-name p)) nextpeerl))
								    (quote 
								     (print "receive")
								     (print  (mkstring (port-name p))))
								    (return t)
								    )))
							    							    
							    (setq termin 1)
							    (setq listeningpeers (1- listeningpeers))
							   
							    ))
							 (t
							  ;; emit
							  (progn 
							    (apply (function osql-result)
								   (list*  fanoutl  rrpos fn args width rd)))))))))
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
						      (list*  fanoutl  rrpos fn args width rd)))))))))
	      ))))
    
    ))

   
(defun start-function (fn args)
  "This function runs on child and sends result back on client port
   It is called if more than one function are sent by MFF_APPLYP"
  (let ((s (port-socket *client-port*)))
    (quote (print fno)(global-eval '(debugging t)) )
    
    (setq _fn_ (INTERNALIZE-CODE fn))
    (setq receivedcount (1+ receivedcount))
    (mapfunction _fn_ args
		 (f/l (row)
		      (pf row s)))
   				
    ))					

(defun start-function (args)
  "This function runs on child and sends result back on client port. 
   It is called if only one function is sent by FF_APPLYP "
  (let ((s (port-socket *client-port*)))
    (setq receivedcount (1+ receivedcount))
    (mapfunction _fn_ args
		 (f/l (row)
		      (pf row s)))
    ))					


(defun report-ack ()
 (pf 'ack  (port-socket *client-port*)))

(defun compile-function (fn)
  (let (exet initt)
    (setq initt (clock))
    (setq _fn_ (INTERNALIZE-CODE fn))
    (setq exet (- (clock) initt))
    (print (concat " compiling time "  exet))
    
    ))


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


