;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author:  Arsenij Vodjanov
;;;
;;; Description: 
;;;  Broadcaster node loop
;;;              
;;; =========================================================================== 

(defglobal receivers nil)         ; list of receiver nodes

(defglobal radio-id nil)          ; bound to the ID of our radio-source object
(defglobal radio-stream-id nil)   ; bound to the ID of udp stream to the udp radio source
(defglobal client-stream-id nil)  ; bound to the ID of udp stream to the udp clients


;;;
;;; Main broadcaster loop  (udp consumer & udp producer)
;;;
;;; Should only be started after all other sussystems are up and running.
;;;
;;; 1) checks incoming commands from peers,
;;; 2) reads client command from producer udp stream
;;; 3) dispatches command to producer command handler function
;;; 4) reads a radio data packet from udp radio source stream
;;; 5) sends the radio packet to all connected udp clients via producer stream
;;; 6) uses remote-eval to push radiodata into elements-list in all receiver amos-nodes
;;;
(defun run-server ()
; Amos node stuff
  (if (or _amosid_ _nameserver_) nil
    (error "This Amos has no name"))
  (cond (_listenport_)
        (t (setq _listenport_ (startlisten (if _nameserver_ *nsp* 0)))
           (reval@nameserver (list 'set-listenport
                                   (mkstring _amosid_) _listenport_))))
  (if _nameserver_ (princ "Broadcaster (and name serv) " t) (princ "Broadcaster " t))
  (formatl t _amosid_ " listening on port " _listenport_ t)
  (if (null (assoc 'server _comm-state_))
      (setq _comm-state_ (nconc1 _comm-state_ (list 'server T))))
; loop
  (while t
    (check-descriptors 0)
    (if (not client-stream-id) nil ; don't do udp-sending if no producer is running
      (let (cdata)  ; udp command data packet
	(setq cdata (udp-get-from client-stream-id))
	(cond ((not cdata))
	      (t (producer-handle-command (car cdata) (cadr cdata) (cadddr cdata) (caddr cdata) radio-stream-id ) ) ) ) )
    (let (rdata)  ; udp radio data
      (setq rdata (radio-get-from radio-id))
      (cond ((not rdata)) ; if received no data, do nothing
	    (t 
	     (cond ((not client-stream-id)) 
		   (t (producer-send-packet (cadddr rdata) (caddr rdata)))) ; send packet via udp to clients
	     (dolist (peer receivers) ; push data into "elements" list in all receivers	       
	       (remote-eval (list 'radio-get-tcp (bin-to-arr (cadddr rdata))) peer) ) ) ) )
    ) 
  )


;;;
;;; Remotely executed by receiver-nodes who wish to register
;;;
(defun register-receiver (name) 
  (formatl t name " registering as recv." t)
  (setq receivers (adjoin name receivers)) )



;;;
;;; Helper functions
;;;

;;; loads up udp consumer
(defun start-cons ()
  ; open a new udp stream listening on any available port, connectd to nothing, read+write mode
  (setq radio-stream-id (udp-open 0 "" 0 "rw"))
  (if radio-stream-id nil
    (error "Failed to create udp stream"))
  ; establish connection to udp radio source through our new udp stream
;;;  (setq radio-id (radio-open radio-stream-id "130.238.30.208" 4096))
  (setq radio-id (radio-open radio-stream-id "192.168.0.100" 4096))
  (if radio-id t
    (error "Failed to connect to udp radio source"))
)



;;; loads up udp producer
(defun start-prod ()
  ; init producer and store the returned ID of udp-stream created by producer
  (setq client-stream-id (producer-start))
  (if client-stream-id t
    (error "Couldn't initialize udp producer"))
)


; shuts down broadcasting
(defun stop-cast ()
  (if radio-id (radio-close radio-id) t) 
  (if client-stream-id (producer-stop) t)
  (udp-stop-thread)
  (setq radio-id nil) 
  (setq radio-stream-id nil)
  (setq client-stream-id nil)
)


;;; loads up broadcaster demo with both producer and consumer
(defun start-cast ()
  (print "Starting broadcaster." t)
  (if (or _amosid_ _nameserver_) nil (nameserver "broadcaster"))
  (if (udp-start-thread) nil (error "Failed to start udp-streams thread"))
  (udp-debug 1)
  (if (start-prod) (if (start-cons) (run-server) nil) nil)
)



;;; Top-level broadcaster startup (only udp consumer, no udp producer)
(defun start-cast1 ()
  (if (or _amosid_ _nameserver_) nil (nameserver "broadcaster"))
  (if (udp-start-thread) nil (error "Failed to start udp-streams thread"))
  (udp-debug 0)
  (if (start-cons) (run-server) nil)
)


