
(defglobal _rr-receive_
 (osql "
create function rr_receive( Vector nrl, Integer rrpos, function fn, bag args, Integer width)
                                 -> object
  as foreign 'rr-receive';"))

(set-resulttypesfn _rr-receive_ (function rr-receive-resulttypes))

(defglobal _fn_ nil)

(defun rr-receive-resulttypes (fno args)
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

(defun rr-receive (fno nrl rrpos fn args width res)
  (let* (peerno ports sockets rd peers
		(thispeer -1))
     
    (if (eq _amosid_ 'me) (setq peers (arrange-peer 0 (nth (1- rrpos) (arraytolist nrl))))     
      (setq peers (find-peers (findpeerno _amosid_) rrpos (arraytolist nrl))))
    
    (setq ports (mapcar (function port-of-peer) peers))

    (dolist  (p ports) 
      (send-form (list 'compile-function (kwote (EXTERNALIZE-FNDEF fn))) p))

    (setq sockets (mapcar (function port-socket) ports))
     
    (mapbag args
	    (f/l (row)
		 (setq thispeer (1+ thispeer))
		 
		 (if (>= thispeer (Length peers))(setq thispeer 0))
		 
		 (send-form (list 'start-function 
				  (kwote row))
			    (port-of-peer (nth thispeer peers)))))
    
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
					      (list*  nrl rrpos fn args width rd))))))))
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

(defun broadcast-eof (peers)
  (dolist (p peers) (send-form (list 'report-ack) (port-of-peer p))))

(defun report-ack ()
 (pf 'ack  (port-socket *client-port*)))

(defun compile-function (fn)
  (setq _fn_ (INTERNALIZE-CODE fn)))


(defun find-peers (peer_id rr_pos prl)
  (let ((cp (nth (- rr_pos 2) prl)) (lp (find-lastpeer rr_pos prl)) peerl i peerpos)
    
    (if ( > (+ peer_id cp) lp) (setq peerl (list (concat "p"  (+ (mod peer_id (nth (- rr_pos 1) prl)) cp))))
      (progn (setq peerpos (+ peer_id cp))
	     (setq peerl (list (concat "p" peerpos)))
	     (setq peerpos (+ peerpos cp))
	     (while (<= peerpos lp) 
	       (setq peerl (cons (concat "p" peerpos) peerl))
	       (setq peerpos (+ peerpos cp)))))
    (reverse peerl)
    ))

(defun find-lastpeer (pos prl)
  (let ((i 0) (sum 0))
    (while (< i pos)
      (setq sum (+ sum (nth i prl)))
      (setq i (1+ i)))
    (1- sum)))
      
(defun arrange-peer (start fanin) 
  "arrange the order of the peers"
  (let (str)
    (do ((j 0 (+ j 1))) ((eq  j fanin))
      (setq str (cons (concat "p" (+ j start)) str)))
    (reverse str))
  )

