
(defglobal _rr-receive_
 (osql "
create function rr_receive(Integer no_peers, Integer no_rr_receive, Integer rr_receive_pos ,Integer start_pos_peer,Vector peers, function fn, bag args, Integer width)
                                 -> object
  as foreign 'rr-receive';"))

(set-resulttypesfn _rr-receive_ (function rr-receive-resulttypes))

(defun rr-receive-resulttypes (fno args)
   (and (numberp (eight args))(buildn (eight args) _object_)))

(defun pf (x s)
  (print x s)
  (flush s))



(defun rr-receive (fno no_peers no_rr_receive rr_receive_pos start_pos_peer peers fn args width res)
  (let* ((ports (mapcar (function port-of-peer) (arraytolist peers)))
         (sockets (mapcar (function port-socket) ports))
         (thispeer -1)
	 rd
         arga)
      
    (quote (mapc (f/l (p po);; send function to peers 
	       (send-form (remote-eval (list 'make-function no_peers no_rr_receive rr_receive_pos start_pos_peer fn) p) po))
	  (arraytolist peers) ports))    
       
    (mapbag args
	    (f/l (row) 
		 (setq thispeer (1+ thispeer))
		 (if (>= thispeer (Length peers))(setq thispeer 0))
		 
		 (send-form (list 'start-function (kwote no_peers) (kwote no_rr_receive) (kwote rr_receive_pos) (kwote start_pos_peer) (kwote (externalize-fndef fn))  (kwote row))    (port-of-peer (aref peers thispeer)))))
    
    (broadcast-eof peers)
    
    (while sockets;; Start receiving data from peers
      (mapc (f/l (s);; will spin if all peers busy
		 (cond ((not (poll-socket s 0)) nil)
		       ((eq (setq rd (read s)) 'ack)
			(setq sockets (remove s sockets)))
		       (t (apply (function osql-result)
				 (list* peers fn args width rd)))))
	    sockets))))
   
(defun start-function (no_peers no_rr_receive rr_receive_pos start_pos_peer fn args)
  "This function runs on child and sends result back on client port"
  (let* ((s (port-socket *client-port*)) fno)
    (setq _no_peers_ no_peers) 
    (setq _no_of_rr_receive_  no_rr_receive) 
    (setq _rr_receive_pos_ rr_receive_pos)
    (setq _start_pos_   start_pos_peer)
    
    (setf fno (internalize-code fn))
    
    
    (mapfunction fno args
		 (f/l (row)(print row)
		      (pf row s)))
    ))					

(defun broadcast-eof (peers)
  (maparray peers (f/l (p s)(send-form (list 'report-ack) (port-of-peer p)))))

(defun report-ack ()
 (pf 'ack  (port-socket *client-port*)))


     