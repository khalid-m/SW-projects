;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author:  Arsenij Vodjanov
;;; $RCSfile: receiver.lsp,v $
;;; $Revision: 1.4 $
;;;
;;; Description: 
;;;  Receiver node loop
;;;              
;;; =========================================================================== 

(defglobal receivers nil)         ; list of receiver nodes

(defglobal elements nil)          ; elements contains a list of all
				  ; elements in queue right now
				  ; (received from Broadcaster node)


(defglobal client-stream-id nil)  ; bound to the ID of udp stream used
				  ; to communicate with the udp
				  ; clients

;;;
;;; Main receiver loop. Start once udp producer is ready to accept
;;; connections
;;;
;;; 1) checks incoming commands from peers
;;; 2) checks incoming commands from visualizers
;;; 3) loops through new received elements and sends the data to all
;;;    active visualizers
;;; 
(defun run-server ()
; Amos node stuff
  (if (or _amosid_ _nameserver_) nil
    (error "This Amos has no name"))
  (cond (_listenport_)
        (t (setq _listenport_ (startlisten (if _nameserver_ *nsp* 0)))
           (reval@nameserver (list 'set-listenport
                                   (mkstring _amosid_) _listenport_))))
  (if _nameserver_ (princ "Receiver (and name serv) " t) (princ "Receiver " t))
  (formatl t _amosid_ " listening on port " _listenport_ t)
  (if (null (assoc 'server _comm-state_))
      (setq _comm-state_ (nconc1 _comm-state_ (list 'server T))))
; register this node as receiver (in broadcaster, which must already be running)
  (remote-eval (list 'register-receiver (mkstring _amosid_)) "broadcaster")
; loop
  (while t
    (check-descriptors 0.02)
    (let (cdata)  ; get command data
      (setq cdata (udp-get-from client-stream-id))
      (cond ((not cdata))
	    (t (producer-handle-command (car cdata) (cadr cdata) (cadddr cdata) (caddr cdata) -1 ) ) ) )
    (dolist (elem (reverse elements)) ; get radio data
;      (dolist (peer receivers) ; push data into "elements" list in all receivers
;	(remote-eval (list 'push elem 'elements) peer) )
      (let ( (rdata (arr-to-bin elem)) )
	(producer-send-packet rdata 1466) ) ) ; send packets via udp to all clients
    (setq elements nil) ) ) ; reset elements list


;;;
;;; Remotely executed by receiver-nodes who wish to register
;;;
(defun register-receiver (name) 
  (formatl t name " registering as recv." t)
  (setq receivers (adjoin name receivers)) )


;;;
;;; Remotely executed by broadcaster
;;;
(defun radio-get-tcp (rdata)
  (setq elements (push rdata elements)) )

;;; helper funcs for test

;;; loads udp producer
(defun start-producer ()
  ; init producer and store the returned ID of udp-stream created by producer
  (if (udp-start-thread) nil (error "Failed to start udp-streams thread"))
  (setq client-stream-id (producer-start))
;  (udp-debug 0)
  (if client-stream-id t
    (error "Couldn't initialize udp producer")))


;;; Top-level receiver startup function
(defun start-recv ()
  (if _amosid_ nil (register-amos "receiver01"))
  (if _amosid_ nil (error "Can't register amos peer."))
  (if (start-producer) (run-server) nil))
