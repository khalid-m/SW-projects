;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Tore Risch, UDBL
;;; $RCSfile: client.lsp,v $
;;; $Revision: 1.30 $ $Date: 2013/08/20 17:47:21 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Bare bone remote Lisp interface
;;; =============================================================
;;; $Log: client.lsp,v $
;;; Revision 1.30  2013/08/20 17:47:21  torer
;;; Global variable _NAMESERVERHOST_ moved to client.lsp
;;;
;;; Revision 1.29  2013/08/20 13:01:37  andan342
;;; Name server host bug fixed by Tore
;;;
;;; Revision 1.28  2013/04/29 19:23:46  torer
;;; (START-PROGRAM xxx) works under OSX
;;;
;;; Revision 1.27  2012/10/21 15:15:19  torer
;;; The enviroment overriding the nameserver location are now:
;;;   NAMESERVERHOST
;;;   NAMESERVERPORT
;;;
;;; Revision 1.26  2012/10/21 14:46:08  torer
;;; removed AMOS_NAMESERVERHOST
;;;
;;; Revision 1.25  2012/10/21 14:40:26  torer
;;; Environment variable NAMESERVERHOST introduced.
;;;
;;; Revision 1.24  2012/06/29 08:44:30  torer
;;; Changed environment variable names to
;;; amos_nameserverhost and amos_nameserverport to avoid name clashes
;;;
;;; Revision 1.23  2012/06/29 07:48:38  torer
;;; Environment variables NAMESERVERHOST and NAMESERVERPORT can be set
;;;
;;; Revision 1.21  2012/06/28 20:00:31  torer
;;; Global variables EXPORTTO and IMPORTFROM removed
;;; New stream headers in C
;;;
;;; Revision 1.20  2012/06/26 19:10:29  torer
;;; Moved declaration of *NSP*
;;;
;;; Revision 1.19  2012/06/26 18:37:02  torer
;;; Wrong default nameserver port
;;;
;;; Revision 1.14  2012/06/26 17:38:43  torer
;;; OS independent program start
;;;
;;; Revision 1.13  2012/06/22 13:37:59  torer
;;; Client server callin interface completely in terms of bare bone
;;; socket client interface
;;;
;;; Revision 1.12  2012/06/20 20:00:34  torer
;;; New function (execute-remote-statement stmt socket)
;;;
;;; Revision 1.11  2012/06/20 18:40:57  torer
;;; (WAIT-UNTIL-STARTED SERVERS) now takes list of servers
;;;
;;; Revision 1.10  2012/06/18 19:25:51  torer
;;; Can now be run in naked alisp
;;;
;;; Revision 1.9  2012/06/14 08:51:51  torer
;;; Revert to old lock method
;;;
;;; Revision 1.8  2012/06/04 14:43:56  larme597
;;; Function socket-call equal to remote-call but using socket-eval instead
;;; of reval. open-socket-to now accepts peer name as a string.
;;;
;;; Revision 1.7  2012/06/01 07:21:12  torer
;;; Bare bone aLisp client now handles proxies for remote objects
;;;
;;; Revision 1.6  2012/05/29 20:24:16  torer
;;; Lisp registered errors now saved in image
;;;
;;; Revision 1.5  2012/05/23 20:08:58  torer
;;; Killing all servers in example
;;;
;;; Revision 1.4  2012/05/23 19:04:35  torer
;;; New function (SOCKET-P S)
;;;
;;; Revision 1.3  2012/05/23 17:44:33  torer
;;; Bare bone client with error handling
;;;
;;; Revision 1.2  2012/05/23 14:54:14  torer
;;; Basic Amos client runnable without image
;;;
;;; Revision 1.1  2012/05/23 13:36:04  torer
;;; A very basic Amos client in Lisp
;;;
;;; =============================================================

;; This file can be used with basic alisp without any image

;;; Error messages:
(defglobal _open-socket-timeout_ 20 "Open socket timeout in seconds")
(defglobal _not-a-socket_ (register-error "Not a socket"))
(defglobal _no-server-named_ (register-error "No server named"))
(defglobal _cant-start_ (register-error "Can't start program under"))
;;;

(defglobal *nsp* 35021 "Default port number of name server")
(defglobal _nameserverhost_ nil "host name of name server (default this host)")

;;; Proxy objecs for remote OIDs:
(make-root-objects);; Creates _object_ and _type_
(defglobal _proxy_ 
  (/createobject _type_ 'opaque_proxy) "OID for type OPAQUE_PROXY")
 ;; The global variable _type_ is used by OID reader in C

(defun nameserver-host ()
  "Get the host name of the computer running the name server"
  (or _nameserverhost_
      (getenv "NAMESERVERHOST") ;; Either determined by environment variable
      (gethostname) ;; or default this computer
      ))

(defun nameserver-port ()
  "Get the port number on which the name server is listening"
  (nameserver-port1 (getenv "NAMESERVERPORT")))

(defun nameserver-port1 (nsp)
  (if nsp (read nsp);; Set by environment variable
    *nsp*;; default port number
    ))

(defun socket-legal (s)
  "Return S if S is a socket object"
  (selectq (typename s)
	   (socket s)
	   (raise-error _not-a-socket_ s)))

(defun socket-p (s)
  "Is S a socket?"
  (eq (typename s) 'socket))

(defun socket-call (socket fn &rest args)
  (socket-eval (list 'apply (kwote fn) (kwote args)) socket))

(defun socket-eval-request (form socket)
  "Request FORM to be evaluated on server without waiting for result"
  (printto form (socket-legal socket) (socket-destination socket))
  )

(defun socket-eval (form socket)
  "Remote evaluate FORM on server to which SOCKET is connected"
  (socket-eval-request form socket)
  (socket-eval-result form socket))

(defun socket-eval-result (form socket)
  ((lambda (res errcond)
     (cond ((null (and (listp res)(eq (car res) '**))) 
	    ;; not annotated form returned
	    res)
	   ((setq errcond (getf res :error))
	    ;; raise error condition if reply error annotated
	    (faulteval (car errcond)(cadr errcond) (caddr errcond)
		       (list 'socket-eval form socket) nil))
	   (t (cadr res);; ignore other annotations
	      )))
   (readfrom socket (socket-destination socket)) nil))

(defun socket-send (form socket)
  "Send FORM for evaluation on server to which SOCKET is connected
   without waiting for the result"
  (printto (list '** form :n t) (socket-legal socket) 
	   (socket-destination socket))
  socket)

(defun open-nameserver-socket ()
  "Open a socket to the nameserver"
  (open-socket-block (nameserver-host)
		     (nameserver-port)
                     _open-socket-timeout_))

(defun open-socket-to (server)
  "Open new socket to server"
  ((lambda (info)			; namserver info about server
     (if (arrayp info)
	 (open-socket-to-server server (elt info 1)(elt info 2) 
				_open-socket-timeout_)
       (raise-error _no-server-named_ server)))
   (socket-eval (list 'amosinfo (kwote (mksymbol server))) 
		(open-nameserver-socket))))

(defun wait-until-started (servers &optional nomsg)
  "Wait for remoteval server or list of servers to be started"
  (cond (nomsg) (t (princ "[Waiting for ") (prin1 servers) (princ " ...")))
  ((lambda (srv nsock)
     (int-while (consp srv) 
		(int-while (null (socket-call nsock 
					      'amosinfo 
					      (mksymbol (car srv))))
			   (sleep 0.1));; decreases nameserver load
		(setq srv (cdr srv))) 
     t)
   (mklist servers) (open-nameserver-socket))
   (cond (nomsg) (t (princ "]")(terpri))))

(defun start-program (prog &optional params)
  "Start background program with given command line parameters"
  (let ((env (system-environment)))
    (cond ((equal env "VisualC++")
	   (system (concat "start /min " prog " " (or params ""))))
	  ((member env '("Unix" "Apple"))
	   (system (concat prog " " (or params "") "&")))
	  (t (raise-error _cant-start_ env)))))
