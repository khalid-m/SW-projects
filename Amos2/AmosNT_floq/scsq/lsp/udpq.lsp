;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Erik Zeitler, UDBL
;;; $RCSfile: udpq.lsp,v $
;;; $Revision: 1.8 $ $Date: 2009/04/07 14:56:50 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: UDP [gw, coordinator, client]
;;; =============================================================

; _gw-subscribers_ is a table of subscribers stored at gw
(defglobal _gw-subscribers_ (make-hash-table :test (function equal)))

; Clients add themselves to coordinator's _gw-q_. It is polled by gw
(defglobal _gw-q_ (make-hash-table :test (function equal)))

; _udp-qs_ is the list of output sockets at the gw
(defglobal _udp-qs_ nil)

; _sensor-ids_ is the gw's list of sensors
(defglobal _sensor-ids_ '("192.168.0.121" "192.168.0.133"))

; <Coordinator>
(defun coo-enqueue-gwrequest (signal port)
  (setf (gethash signal _gw-q_)
	(append (gethash signal _gw-q_) (list port))))

(defun coo-dequeue-gwrequests (signallist)
  (mapcar (f/l (id)
	       (prog1 (list id (gethash id _gw-q_))
		 (remhash id _gw-q_)))
	  signallist))
; <Coordinator>

; <Client>
(defun request-gwsignal (signal socket)
  (let ((port (new-port "tcp" "130.238.12.231" (socket-portno socket))))
    (reval@nameserver `(coo-enqueue-gwrequest , signal , port))))

(foreign-lispfn
 get_gwdata ((charstring signal)) ((numarray))
 (let ((mysock (open-socket nil 0)))
   (request-gwsignal signal mysock)
   (let ((incoming (accept-socket mysock nil))
	 (c 0)
	 (tpl))
     (print (mksymbol "emit") incoming)
     (flush incoming)
     (while t
       (setq c (+ c 1))
       (if (= c _continuation-period_) (setq c 0))
       (cond ((= c 0)
	      (print (mksymbol "emit") incoming)
	      (flush incoming)
	      (setq tpl (read incoming))
	      (foreign-result tpl)
	      (cond ((equal tpl (mksymbol "eof"))
		     (print (mksymbol "stop") incoming)
		     (flush incoming)
		     (close-socket incoming)
		     (return nil)))))))))
; </Client>

; <Gateway>
(defun start-udp-recv (ip)
  (cond ((some (f/l (q) (equal (udpq-addr q) (gethostaddress ip)))
	       _udp-qs_))
	(t
	 (setq _udp-qs_ (append _udp-qs_ (list (make-udpq ip)))))))

(defun stop-udp-recv (ip)
  (setq _udp-qs_
	(mapcar (f/l (q)
		     (if
			 (equal (udpq-addr q) (gethostaddress ip))
			 (udpq-stop q)
		       q))
		     _udp-qs_)))

(defun get-udp-q (ip)
  (mapfilter (f/l (q)
		  (equal (udpq-addr q) (gethostaddress ip)))
	     _udp-qs_))

(defun remove-udp-recv (ip)
  (setq _udp-qs_
	(mapfilter (f/l (q) (not (equal (udpq-addr q) (gethostaddress ip))))
		   _udp-qs_)))
(defun gw-retrieve-subscribers (signallist)
  (reval@nameserver
   `(coo-dequeue-gwrequests , (kwote signallist))))

; Wait until request at coo for any of my sensors
(defun gw-wait ()
  (prog-let ((r))
	    (while (notany (f/l (p) (second p))
			   (setq r (gw-retrieve-subscribers _sensor-ids_)))
	      (sleep 2.0))
	    (return r)))

(defun gw-add-newsockets (str)
  (mapcar (f/l
	   (p)
	   (puthash (first p)
		    _gw-subscribers_
		    (append
		     (gethash (first p) _gw-subscribers_)
		     (open-sockets (second p)))))
	  str))

(defun gw-print-hash ()
  (mapcar (f/l
           (p)
	   (print (gethash p _gw-subscribers_)))
	  _sensor-ids_))

(defun open-sockets (portlist)
  (mapcar
   (f/l (p) (open-socket
	     (port-gethostname p) (port-getportno p)))
   portlist))

(defun gw-init ()
  (gw-add-newsockets (gw-wait)))

(defun poll-socketlist (socketlist)
  (remove nil
	  (mapcar
	   (f/l (p)
		(let ((r (read p)))
		  (cond ((equal r (mksymbol "STOP"))
			 (close-socket p)
			 nil)
			(t p))))
	   socketlist)))

; poll all existing subscribers and retrieve+open new ones
(defun gw-poll (sensor-id)
  (puthash sensor-id _gw-subscribers_
	   (poll-socketlist (gethash sensor-id _gw-subscribers_))))

(defun gw-add (sensor-id)
  (gw-add-newsockets (gw-retrieve-subscribers (list sensor-id))))
; </Gateway>

(foreign-lispfn
 sensor_ids () ((charstring))
 (mapc (f/l (q) (foreign-result q)) _sensor-ids_))

(foreign-lispfn
 lport ((stream x) (integer nsub)) ((charstring))
 (mapc (f/l (q) (foreign-result q)) _sensor-ids_))
