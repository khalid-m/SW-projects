;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010 Lars Melander, UDBL
;;; $RCSfile: scan_remote.lsp,v $
;;; $Revision: 1.18 $ $Date: 2013/09/02 14:22:50 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Open scan to nameserver
;;; =============================================================
;;; $Log: scan_remote.lsp,v $
;;; Revision 1.18  2013/09/02 14:22:50  larme597
;;; New multi scan functions.
;;;
;;; Revision 1.17  2013/08/12 09:14:23  larme597
;;; When remote scan is finished, it is now removed from server.
;;;
;;; Revision 1.16  2013/08/07 17:27:12  larme597
;;; *** empty log message ***
;;;
;;; Revision 1.15  2013/08/07 15:08:36  larme597
;;; Remote scans now get their own sockets.
;;;
;;; Revision 1.14  2013/08/02 10:09:43  larme597
;;; New functions open-multi-scan-remote and open-multi-scan-server.
;;;
;;; Revision 1.13  2012/11/02 13:08:34  torer
;;; Better tag name for atomic result from remote command evaluation
;;;
;;; Revision 1.12  2012/11/02 08:20:34  torer
;;; The decision to materialize scan moved to server
;;; to allow for pure Java client
;;;
;;; Revision 1.11  2012/08/23 13:01:42  larme597
;;; Separate socket not needed to kill remote scan.
;;;
;;; Revision 1.10  2012/08/22 16:07:58  larme597
;;; Bugfixes.
;;;
;;; Revision 1.9  2012/08/21 15:52:50  larme597
;;; New remote scan kill functions.
;;;
;;; Revision 1.8  2012/07/31 16:23:20  larme597
;;; Using process function in scan-fillbuffer-server.
;;;
;;; Revision 1.7  2012/07/26 20:14:06  torer
;;; Error handling in remote scans
;;;
;;; Revision 1.6  2012/06/27 19:20:06  torer
;;; options in custom C functions passed as property list to scan functions
;;;
;;; Revision 1.5  2012/06/27 09:27:02  larme597
;;; Server-side scan running from server loop.
;;;
;;; Revision 1.4  2012/06/19 16:11:03  larme597
;;; Refined functions for polling remote results.
;;;
;;; Revision 1.3  2012/06/08 17:00:47  larme597
;;; Better scans. Remote scans now send entire buffer.
;;;
;;; Revision 1.2  2010/09/10 14:26:30  larme597
;;; Updates and adding comments.
;;;
;;; Revision 1.1  2010/09/09 12:22:48  larme597
;;; Functions for opening scan to nameserver.
;;;
;;; =============================================================

(defglobal _scan-list_ (make-hash-table :test (function equal))
  "A hash table on the name server containing remote scans.
   Entities are handled by remote scan functions or manually.")

(defglobal _scan-list-keyrange_ 1000000
  "An upper limit for keys in _SCAN-LIST_.")

(defun open-scan-socket (conn)
  "Open a separate socket to be owned by a scan."
  (open-socket (socket-hostname conn) (socket-portno conn)))

(defun open-function-scan-remote (fno args conn &optional options)
  "Open a function scan on a peer.
   Note: Use VECTOR to list arguments."
  (let ((newsock (open-scan-socket conn)))
    (make-scan-remote newsock
		      (socket-eval (list 'open-function-scan-server 
					 (kwote fno) (kwote args)
					 (kwote options))
				   newsock)
		      (make-buffer _scan-buffersize_))))

(defun open-query-scan-remote (query conn &optional options)
  "Open a remote query scan on a peer.
   Commands are executed immediately and return their results, no remote scan"
  (let* ((newsock (open-scan-socket conn))
	 (s (socket-eval (list 'open-query-scan-server
			       (kwote query) (kwote options))
			 newsock)))
    (cond ((consp s) (second s));; Materialized value from server
          (t;; Remote scan from server
	   (make-scan-remote newsock s (make-buffer _scan-buffersize_))))))

(defun open-stream-scan-remote (stream conn &optional options)
  "Open a stream or bag on a peer."
  (let ((newsock (open-scan-socket conn)))
    (make-scan-remote newsock
		      (socket-eval (list 'open-stream-scan-server 
					 (kwote stream) (kwote options))
				   newsock)
		      (make-buffer _scan-buffersize_))))

(defun open-function-scan-server (fno args &optional options)
  "Used internally to open a function scan on a peer."
  (_open-scan-server (function open-function-scan) (list fno args options t)))

(defun open-query-scan-server (query &optional options)
  "Run on the server when remote scan for query is created"
  (cond ((is-query query);; Remote scan for queries only
         (_open-scan-server (function open-query-scan) 
			    (list query options t)))
	(t (list 'value (amos-execute query))
           ;; Commands are executed immediately
	   )))

(defun open-stream-scan-server (stream &optional options)
  "Used internally to open a stream/bag scan on a peer."
  (_open-scan-server (function open-bag-scan) (list stream options t)))

(defun _open-scan-server (fn args)
  (let ((key (random _scan-list-keyrange_)))
    (while (gethash key _scan-list_);; Check that the key is not already in use
      (setq key (random _scan-list-keyrange_)))
    (puthash key _scan-list_ (apply fn args))
    key))

(defun open-multi-scan-remote (query conn &optional options)
  (let ((keylst (socket-eval (list 'open-multi-scan-server
				   (kwote query) (kwote options))
			     conn)))
    (listtoarray (mapcar (f/l (key)
			      (let ((newsock (open-scan-socket conn)))
				(multi-scan-update-socket-remote key newsock)
				(make-scan-remote newsock
						  key
						  (make-buffer _scan-buffersize_))))
			 keylst))))

(defun open-multi-scan-server (query &optional options)
  (let* ((sc (open-query-scan query))
	 (row (arraytolist (car (scan-nextrow sc)))))
    (mapcar (f/l (x)
		 (open-stream-scan-server x options))
	    row)))

(defun multi-scan-update-socket-remote (key socket)
  (socket-eval (list 'multi-scan-update-socket-server
		     (kwote key))
	       socket))

(defun multi-scan-update-socket-server (key)
  (let ((s (gethash key _scan-list_)))
    (scan-update-socket s (port-socket *client-port*))))

(defun scan-nextrow-remote (sr)
  "Retrieve the next tuple from a remote scan."
  (scan-fillbuffer-remote sr)
  (let ((b (scan-remote-getbuffer sr)))
    (cond ((not (buffer-emptyp b))
           (let* ((nxt (buffer-pop b))
                  (errcond (get-form-annotation nxt :error)))
	     (cond (errcond
		    (errcond-raise-error (getf errcond :errcond) 
					 (list 'scan-nextrow-remote sr)))
		   (t (scan-remote-setcurrent sr nxt)))))
	  ((scan-remote-terminated sr)
	   (scan-remote-setcurrent sr (scan-remote-terminated sr)))
	  (t nil))))

(defun scan-eos-remote (sr)
  "Check to see if remote scan has terminated."
  (scan-fillbuffer-remote sr)
  (and (scan-remote-terminated sr)
       (buffer-emptyp (scan-remote-getbuffer sr))))

(defun scan-remote-set-terminated (sr x)
  (selectq x
	   (*terminated* (scan-close-remote sr) x)
	   x))

(defun scan-fillbuffer-remote (sr)
  (if (scan-fillbuffer-remote-request sr)
      (scan-fillbuffer-remote-result sr)))

(defun scan-fillbuffer-remote-request (sr)
  (if (and (not (scan-remote-terminated sr))
	   (buffer-emptyp (scan-remote-getbuffer sr)))
      (socket-send (list (function scan-fillbuffer-server)
			 (scan-remote-id sr))
		   (scan-remote-socket sr))))

(defun scan-remote-poll-socket (sr)
  (poll-socket-block (scan-remote-socket sr) 0))

(defun scan-fillbuffer-remote-result (sr)
  (let ((lst (socket-eval-result (list (function scan-fillbuffer-server)
				       (scan-remote-id sr))
				 (scan-remote-socket sr))))
    (scan-remote-setbuffer sr (car lst))
    (scan-remote-set-terminated sr (cadr lst))))

(defun scan-fillbuffer-server (key)
  (let ((s (gethash key _scan-list_)))
    (buffer-clear (scan-buffer s))
    (proc-add s)))

(defun scan-close-remote (sr)
  "A remote scan MUST be closed manually after use."
  (or (scan-remote-terminated sr)
      (progn
	(scan-remote-terminate sr)
	(_scan-close-remote (scan-remote-id sr)
			    (scan-remote-socket sr)))))

(defun _scan-close-remote (key socket)
  "Called directly from remote scan deallocation."
  (socket-eval (list (function scan-close-server) key) socket))

(defun scan-close-server (key)
  "Used internally to close a remote scan."
  (prog1
      (scan-close (gethash key _scan-list_))
    (remhash key _scan-list_)))

(defun scan-check-id-remote (key socket)
  "Check if a scan exists on the server."
  (socket-eval (list (function scan-check-id-server) key) socket))

(defun scan-check-id-server (key)
  (and (gethash key _scan-list_) t))

(defun scan-kill-remote (sr)
  "Stop a remote scan"
  (socket-send (list (function scan-kill-server) (scan-remote-id sr))
	       (scan-remote-socket sr)))

(defun scan-kill-server (key)
  (co-kill-on-resume (scan-coroutine (gethash key _scan-list_)) 'reset))
