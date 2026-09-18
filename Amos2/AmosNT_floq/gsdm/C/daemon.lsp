;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author:  Arsenij Vodjanov
;;;
;;; Description: 
;;;  UDP Broadcaster lisp functions (intended for running daemonized server)
;;;  
;;; =========================================================================== 

(defglobal receivers nil)         ; list of receiver nodes

(defglobal radio-id nil)          ; bound to the ID of our radio-source object
(defglobal radio-stream-id nil)   ; bound to the ID of udp stream to the udp radio source
(defglobal client-stream-id nil)  ; bound to the ID of udp stream to the udp clients

;;;
;;; Local helper functions
;;;

;;; start udp consumer
(defun start-cons ()
  ; open a new udp stream listening on any available port, connectd to nothing, read+write mode
  ; and establish connection to udp radio source through our new udp stream
  (setq radio-stream-id (udp-open 0 "" 0 "rw"))
  (if radio-stream-id (setq radio-id (radio-open radio-stream-id "192.168.0.100" 4096)) nil)
  (if radio-id t nil)
)

;;; start udp producer
(defun start-prod ()
  ; init producer and store the returned ID of udp-stream created by producer
  (setq client-stream-id (producer-start))
  (if client-stream-id t nil)
)


;;;
;;; Broadcaster loop  (udp consumer & udp producer)
;;;
;;; 1) checks incoming commands from peers,
;;; 2) reads client command from producer udp stream
;;; 3) dispatches command to producer command handler function
;;; 4) reads a radio data packet from udp radio source stream
;;; 5) sends the radio packet to all connected udp clients via producer stream
;;; 6) pushes radiodata into elements-list in all receiver amos-nodes
;;;
(defun pump-server-loop ()
;  (check-descriptors 0.000005) ; Calling from driver program with a call_lisp()
  (if (not client-stream-id) nil ; don't do udp-sending if no producer is running
    (let (cdata)  ; udp command data packet
      (setq cdata (udp-get-from client-stream-id))
      (cond ((not cdata)) ; if no data from client, do nothing
	    (t (producer-handle-command (car cdata) (cadr cdata) (cadddr cdata) (caddr cdata) radio-stream-id ) ) ) ) )
  (let (rdata)  ; udp radio data
;    (setq rdata (udp-get-from radio-stream-id))
    (setq rdata (radio-get-from radio-id))
    (cond ((not rdata)) ; if received no data from radio, do nothing
	  (t 
	   (cond ((not client-stream-id)) 
		 (t (producer-send-packet (cadddr rdata) (caddr rdata)))); caddr rdata=1466. Send packet via udp to clients
	   (dolist (peer receivers) ; push data into "elements" list in all receivers	       
	     (remote-eval (list 'radio-get-tcp (bin-to-arr (cadddr rdata))) peer) ) ) ) )
  )


;;;
;;; Remotely executed by receiver-nodes who wish to register
;;;
(defun register-receiver (name) 
  (formatl t name " registering as recv." t)
  (setq receivers (adjoin name receivers)) )



;;;
;;; Interface functions to operate broadcaster
;;;

;;; shuts down broadcasting
(defun close-udp-modules ()
  (if client-stream-id (producer-stop) t)
  (if radio-id (radio-close radio-id) t) 
  (udp-stop-thread)
  (setq radio-id nil) 
  (setq radio-stream-id nil)
  (setq client-stream-id nil)
)


;;; initialize udp modules
(defun init-udp-modules ()
  (udp-debug 0)
  (radio-debug 1)
  (producer-debug 1)
  (udp-start-thread)
  (if (start-cons) (if (start-prod) t nil) nil)
)

;;; initialize Amos TCP connection
(defun init-amos-peer ()
  (if (or _amosid_ _nameserver_) nil (nameserver "broadcaster"))
  (cond (_listenport_)
	(t (setq _listenport_ (startlisten (if _nameserver_ *nsp* 0)))
	   (reval@nameserver (list 'set-listenport
				   (mkstring _amosid_) _listenport_))))
  (if _nameserver_ (princ "Broadcaster (nameserv) " t) (princ "Broadcaster (peer)" t))
  (formatl t _amosid_ " listening on port " _listenport_ t)
  (if (null (assoc 'server _comm-state_))
      (setq _comm-state_ (nconc1 _comm-state_ (list 'server T))))
)


(defun init-broadcaster ()
  (init-amos-peer)
  (init-udp-modules)
)