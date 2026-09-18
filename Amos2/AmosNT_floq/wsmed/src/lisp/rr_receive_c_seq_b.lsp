

(defglobal _rr-receive_
 (osql "
create function rr_receive(Integer fanin, Integer shl, Integer rrpos, function fn, bag args, Integer width)
                                 -> object
  as foreign 'rr-receive';"))

(set-resulttypesfn _rr-receive_ (function rr-receive-resulttypes))

(defun rr-receive-resulttypes (fno args)
   (and (numberp (fourth args))(buildn (fourth args) _object_)))

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

(defun rr-receive (fno fanin shl rrpos fn args width res)
  (let* (peerno ports scockets rd peers
		(thispeer -1))
     
    (if (eq _amosid_ 'me) (setq peerno -1)     
      (setq peerno (findpeerno _amosid_)))
    (setq peers (find-startpos-eq-b peerno rrpos fanin  shl ))
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
				 (list*  fanin shl rrpos  fn args width rd)))))
	    sockets))

    
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



(defun find-startpos-eq-b ( peer_id rr_pos fanin shl)
  "Find the starting position of peers"
  (let (peer_pos startpos)
      
    (if (<=  rr_pos 2) (setq peer_pos peer_id)
      (setq peer_pos (- peer_id (/ (* (expt fanin shl) (1- (expt fanin (- rr_pos 2)))) (* (expt fanin (- rr_pos 3)) (1- fanin))))))
    
    
    
    (if (eq peer_id -1)
	(progn (setq startpos 0)
	       (setq fanin (expt fanin shl)))
      (progn (setq startpos (+ peer_id (+ (- (expt fanin (-  shl (-  rr_pos 2))) peer_pos) (/ peer_pos  fanin))))
	     (setq fanin 1)))
   
       
    (arrange-peer startpos fanin)
    )
)
(defun arrange-peer (start fanin) 
  "arrange the order of the peers"
  (let ((str(make-array fanin)))
    (do ((j 0 (+ j 1))) ((eq  j fanin))
      (seta str j (concat "p" (+ j start))))
    str)
  )
     