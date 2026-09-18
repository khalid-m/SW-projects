;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2003 Tore Risch, UDBL
;;; $RCSfile: socket.lsp,v $
;;; $Revision: 1.8 $ $Date: 2011/12/21 20:59:37 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Basic socket interface
;;; =============================================================

(defun open-socket (host port &optional timeout bgrecv nb)
  "Open socket to PORT on HOST with optional TIMEOUT in seconds"
  (cond ((null timeout)
	 (open-socket-block host port 1 bgrecv nb))
	(t
	 (let (sock)
	   (while (and (null sock) (> timeout 0))
	     (setq sock (open-socket-block host port (min 1 timeout) 
					   bgrecv nb))
	     (setq timeout (- timeout 1)))
	   sock))))

(defun poll-socket-block (s timeout &optional writesock)
  "Poll socket S for TIMEOUT seconds. 
   WRITESOCK = NIL => read socket polling, otherwise write socket polling"
  (poll-sockets-block (vector s) timeout writesock))

(defun accept-socket (s timeout)
  "Ask socket S to accept TCP connection for TIMEOUT seconds"
  (cond ((null timeout) 
	 (while (not (poll-socket-block s 1))) ; one second only
	 (accept-socket-block s)) 
        ((poll-socket s timeout)(accept-socket-block s))))

(defun poll-sockets (sa timeout &optional writesock)
  "Poll sockets in array SA for TIMEOUT seconds.
   WRITESOCK = NIL => read socket polling, otherwise write socket polling"
  (while (> timeout 1)
    (poll-sockets-block sa 1 writesock)		; Block one second only
    (setq timeout (- timeout 1)))
  (poll-sockets-block sa timeout writesock))

(defun rand-sockets (sa timeout &optional writesock)
  (while (> timeout 1)
    (rand-sockets-block sa 1 writesock)		; Block one second only
    (setq timeout (- timeout 1)))
  (rand-sockets-block sa timeout writesock))

(defun poll-socket (s timeout &optional writesock)
  "Poll sockets in list S for timeout seconds.
   WRITESOCK = NIL => read socket polling, otherwise write socket polling"
  (poll-sockets (vector s) timeout writesock))
