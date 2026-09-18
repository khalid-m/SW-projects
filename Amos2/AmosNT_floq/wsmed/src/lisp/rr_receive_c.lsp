(defglobal _free_peers_ 4)

(defglobal _rr-receive_
 (osql "
create function rr_receive(Integer rrpos, function fn, bag args, Integer width)
                                 -> object
  as foreign 'rr-receive';"))

(set-resulttypesfn _rr-receive_ (function rr-receive-resulttypes))

(defun rr-receive-resulttypes (fno args)
   (and (numberp (fourth args))(buildn (fourth args) _object_)))

(defun pf (x s)
  (print x s)
  (flush s))

(defun rr-receive (fno rrpos fn args width res)
  (let* (peerno ports scockets rd peers
		(thispeer -1))
     
    (if (eq _amosid_ 'me) (setq peerno -1)     
      (setq peerno (cadr (explode (mksymbol  _amosid_)))))
    (setq peers (find-startpos-eq peerno rrpos _free_peers_ ))
    (setq ports (mapcar (function port-of-peer) (arraytolist peers)))
    (setq sockets (mapcar (function port-socket) ports))
     
    (mapbag args
	    (f/l (row) 
		 (setq thispeer (1+ thispeer))
		 
		 (if (>= thispeer (Length peers))(setq thispeer 0))
		 
		 (send-form (list 'start-function (kwote (EXTERNALIZE-FNDEF fn))
				  (kwote row))
			    (port-of-peer (aref peers thispeer)))))
    
    (broadcast-eof peers)
    
    (while sockets;; Start receiving data from peers
	     (mapc (f/l (s);; will spin if all peers busy
			(cond ((not (poll-socket s 0)) nil)
			      ((eq (setq rd (read s)) 'ack)
			       (setq sockets (remove s sockets)))
			      (t (apply (function osql-result)
					(list* rrpos  fn args width rd)))))
		   sockets))


    (quote (while sockets;; Start receiving data from peers
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
					      (list*  rrpos fn args width rd))))))))
	)))



    ))
   
(defun start-function (fn args)
  "This function runs on child and sends result back on client port"
  (let ((s (port-socket *client-port*))
        (fno (INTERNALIZE-CODE fn)))
    ;(print fno)(global-eval '(debugging t)) 
    
    (mapfunction fno args
		 (f/l (row)
		      (pf row s)))
   					
    ))					

(defun broadcast-eof (peers)
  (maparray peers (f/l (p s)(send-form (list 'report-ack) (port-of-peer p)))))

(defun report-ack ()
 (pf 'ack  (port-socket *client-port*)))

(defun find-startpos-eq ( peer_id rr_pos nopeers)
  "Find the starting position of peers"
  (let (peer_pos startpos)
  
    (if (<=  rr_pos 2) (setq peer_pos peer_id)
      (setq peer_pos (- peer_id (1- (/ (1- (expt nopeers (1- rr_pos))) (- nopeers 1))))))
   
    (if (eq peer_id -1)(setq startpos 0)
    (setq startpos (+ peer_id (+ (- (expt nopeers (1- rr_pos)) peer_pos) (* peer_pos nopeers)))))
   
    
     (if (eq rr_pos 1)
	(progn (setq  _no_of_rr_receive_ 0)
	       (setq  _parallelizable_ nil)
	       ))
     
    (arrange-peer startpos nopeers)
    ))

(defun arrange-peer (start no_peers) 
  "arrange the order of the peers"
  (let ((str(make-array no_peers)))
    (do ((j 0 (+ j 1))) ((eq  j no_peers))
      (seta str j (concat "p" (+ j start))))
    str)
  )
     