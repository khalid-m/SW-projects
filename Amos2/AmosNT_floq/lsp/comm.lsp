;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1998 Tore Risch, EDSLAB
;;; $RCSfile: comm.lsp,v $
;;; $Revision: 1.96 $ $Date: 2013/12/31 11:28:54 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Peer communication
;;; =============================================================
;;; $Log: comm.lsp,v $
;;; Revision 1.96  2013/12/31 11:28:54  torer
;;; Initializing communication when image started
;;;
;;; Revision 1.95  2013/10/27 15:12:51  torer
;;; Reorganized communication foreign functions
;;;
;;; Revision 1.94  2013/08/20 17:47:22  torer
;;; Global variable _NAMESERVERHOST_ moved to client.lsp
;;;
;;; Revision 1.93  2013/06/18 18:26:20  torer
;;; _socket-systime_ added
;;;
;;; Revision 1.92  2013/05/27 07:31:00  torer
;;; client_system(Charstring nameserverhost)->Boolean
;;;
;;; Revision 1.91  2013/05/26 21:00:25  torer
;;; New function to allow system to be client in amos communication without
;;; registering as named peer:
;;; client_system(Boolean client)->Boolean
;;;
;;; Revision 1.90  2012/07/31 16:21:14  larme597
;;; Using process functions in server-loop.
;;;
;;; Revision 1.89  2012/07/23 20:27:58  torer
;;; Errors can now be caught through coroutines
;;;
;;; Revision 1.88  2012/06/27 19:53:44  torer
;;; wait_for(peers) function introduced
;;;
;;; Revision 1.87  2012/06/27 09:23:33  larme597
;;; New server loop using coroutines.
;;;
;;; Revision 1.86  2012/06/26 19:10:29  torer
;;; Moved declaration of *NSP*
;;;
;;; Revision 1.85  2012/06/26 07:19:08  torer
;;; Catching CTRL-C in server loop again
;;;
;;; Revision 1.84  2012/06/22 13:37:59  torer
;;; Client server callin interface completely in terms of bare bone
;;; socket client interface
;;;
;;; Revision 1.83  2012/05/22 20:22:33  torer
;;; (open-port-to 'nameserver) now works too
;;;
;;; Revision 1.82  2011/01/29 11:04:39  torer
;;; Base system uses (...) tuple notation, 'return' statement, and systematic indentation
;;;
;;; Revision 1.81  2010/12/20 20:28:47  torer
;;; More compact send-form message
;;;
;;; Revision 1.80  2010/01/19 19:22:59  zeitler
;;; Timeout parameter (open-socket host port &optional timeout)
;;; useful when waiting for peers or nameservers to listen().
;;;
;;; Revision 1.79  2009/04/22 21:11:13  torer
;;; Basic socket management to socket.lsp
;;;
;;; Revision 1.78  2008/11/21 15:17:12  torer
;;; Signature error
;;;
;;; Revision 1.77  2008/10/03 10:48:39  torer
;;; *** empty log message ***
;;;
;;; Revision 1.76  2008/10/03 09:52:26  torer
;;; REMOTE-EVAL with remote name NAMESERVER did not handle proxy objects
;;;
;;; Revision 1.75  2008/10/02 08:34:07  torer
;;; Correct definition of ship
;;;
;;; Revision 1.74  2008/09/17 20:06:43  torer
;;; Some more peer management functions, not least kill_the_federation(); to gracefully kill every peer and the name server.
;;;
;;; Revision 1.73  2008/04/11 12:13:07  silvias
;;; Wait-for in Lisp
;;;
;;; Revision 1.71  2007/12/18 11:36:24  torer
;;; Named subplans
;;;
;;; Revision 1.70  2007/10/24 21:14:54  torer
;;; Code moved to make modules independent
;;;
;;; Revision 1.69  2007/08/27 18:41:30  torer
;;; Separated registering a peer as listening from making it listen
;;;
;;; Revision 1.68  2006/10/24 11:30:29  zeitler
;;; changed hostport to port
;;;
;;; Revision 1.67  2006/10/24 09:46:53  zeitler
;;; changed name from hostport to port
;;;
;;; Revision 1.66  2006/10/24 09:40:38  zeitler
;;; hostport literal type
;;;
;;; Revision 1.65  2006/08/03 06:40:13  torer
;;; OPEN-PORT-TO put back as it is used by C interface
;;;
;;; Revision 1.63  2006/04/29 17:29:52  torer
;;; Removed unused declaration
;;;
;;; =============================================================

(defstruct port 
  name ; logical name of amos server port connects to
  hostname ; host of amos server
  portno ; TCP port number server listens on
  socket ; socket assigned to port
  dbid ; identifier of registered amos system or NIL
  )

(defglobal _nameserver_ nil "set to T if this AMOS is a name server")

(defglobal *open-port-timeout* 5 "Default timeout when connecting to a peer")

(defglobal _portnametbl_ (make-hash-table :test 'equal)
  "table of ports with logical amos names")

(defglobal _listenport_ nil "The port on which an AMOS server is listening")

(defglobal _comm-state_ nil 
  "stores information necessary to restore Amos comm state")

(defglobal _nameamos_) ; To undo AMOS client/server naming

(defvar *client-port* nil
  "the port of the client whose request we are executing")

(defvar *connectionless* nil "true => always (re)open/close connections")

(defvar *serverlog* nil "stream where server error messages printed")

(defglobal _client-system_ nil 
  "Allow client connections without registering peer")
 
(defglobal _socket-systime_ nil 
  "Add delay time stamps on socket communication")

(defglobal _amos-named_)
(defglobal _local-amos-servers_)

;;; =============================================================
;;; Form annotation section
;;; =============================================================

(defglobal *annotation-tag* '**)

(defun annotate-form (form ind val)
   (cond ((or (null val) (equal val "")) form)
         ((not (annotated-form form))
          (list *annotation-tag* form ind val))
         (t (setf (getf (cddr form) ind) val)
           form)))

(defmacro annotated-form (form)
  `(eq (car (ilistp , form)) *annotation-tag*))

(defun get-form-annotation (form ind)
   (if (annotated-form form) (getf (cddr form) ind)))

(defun get-form (form)
   (if (annotated-form form)(cadr form)
      form))

(defmacro traperrors (form)
  `(catch 'traperrors
     (let ((_oldhist_ _history_)
	   (_error_ t))
       (unwind-protect 
	   (prog1 , form (commit)(setq _error_ nil)) ; transaction succeeded
	 (cond (_error_ (history-rollback _oldhist_) ;transaction failed
			(throw 'traperrors 
			       (annotate-form 
				nil :error  
				(error? _error-condition_)))))))))

;;; =============================================================
;;; Unnamed Port section
;;; =============================================================

(defun open-port (hostname portno oldport)
  (let (socket dbid port (*connectionless* nil))
    (if (< portno 0)(error "Not a server on host" hostname))
    (setq socket (open-socket hostname portno *open-port-timeout*))
    (socketstat-clear socket)
    (if oldport (setq port oldport)
      (setq port (make-port)))
    (setf (port-hostname port) hostname)
    (setf (port-portno port) portno)
    (setf (port-socket port) socket)
    (setq dbid (reval (list 'dbinit 'port (gethostname) (kwote _amosid_)) 
		      port))
    (setf (port-dbid port) dbid)
    port))

(defun reopen-port (port)
    (open-port (port-hostname port)(port-portno port) port))

(defvar _server-ports_ (make-hash-table :test 'equal))

(defun dbinit (port hn peer)
   (setf (port-hostname port) hn)
   (setf (port-dbid port) peer)
   _amosid_)

(defun server-port (descr)
   (cond ((gethash descr _server-ports_))
         (t (setf (gethash descr _server-ports_)
                  (make-port :socket descr)))))

(defun close-port (port)
   (cond ((port-socket port)
          (close-socket (port-socket port))
          (close-port1 port))))

(defun close-port1 (port)
   (remhash (port-socket port) _server-ports_)
   (setf (port-socket port) nil)
   )

;;; =============================================================
;;; Named Port section
;;; =============================================================

(defun amos-servername (name) 
  (mkatom name))

(defun name-port (name port)
   ;;; Give NAME to PORT.
   ;;; If a port exists with the same name signal an error.
   (setq name (amos-servername name))
   (let ((port-exists (gethash name _portnametbl_)))
      (if port-exists
         (error "NAME-PORT: Name not unique" name))
      (setf (port-name port) name)
      (setf (gethash name _portnametbl_) port)))

(defun get-port-named (name &optional noerror)
   ;;; Return a port named NAME.
   (setq name (amos-servername name))
   (let ((the-port (gethash name _portnametbl_)))
      (cond (the-port) 
            ((not noerror) (error "GET-PORT-NAMED: No port named" name)))))

(defun create-port-named (name)
   ;;; Return a new port named NAME.
   (name-port name (make-port)))
  
(defun change-port-name (port name)
   ;;; Change the name of PORT to NAME.
   (remhash name _portnametbl_)
   (name-port name port))

(defun open-port-p (port)
  ;;; Returns PORT if PORT is open, NIL otherwise.
  (and (port-p port) (port-socket port) port))
       
(defun close-named-port (name)
   ;;; Close a named port.
   (let (port)
      (if (port-p name) (setq port name)
         (setq port (get-port-named name)))
      (close-port port)
      (cond ((port-name port)
             (setf (gethash (port-name port) _portnametbl_) nil)
             (setf (port-name port) nil)))
      port))

(defun close-named-ports()
   (maphash (f/l (k port)(close-named-port k)) _portnametbl_))

(defun reopen-named-ports()
   (maphash (f/l (k port)(reopen-port port)) _portnametbl_))

(defun open-nameserver-port ()
  (let ((port (get-port-named "NAMESERVER" t))) 
    (cond ((open-port-p port))
	  (port (reopen-port port))
          (t (name-port "NAMESERVER"
			(open-port (nameserverhost) *nsp* port))))))

(defun open-port-to (peer)
  "Open a new port to PEER. First call opens the named port to PEER,
   the next calls open unnamed ports"
  (if (eq peer 'nameserver)(open-nameserver-port)
    (let ((np (get-port-named peer t))
	  info)
      (cond (np	;;; named port to peer open -> open new port
	     (setq info (get-amos-info peer))
	     (open-port (info-host info)
			(info-portno info)
			nil))
	    (t (open-port-named peer)))))) ; first port to peer

(defun open-port-named (name)
  "Open a named port to peer named NAME. 
   Only one named port is allowed per connection to a peer named NAME"
  (let ((port (get-port-named name t)) info)
    (cond ((open-port-p port))
          (port (reopen-port port))
	  ((null(setq info (get-amos-info name)))
	   (error "No Amos named" name))
	  ((< (info-portno info) 0)(error "Not an Amos server" name))
	  (t (name-port name (open-port (info-host info)
					(info-portno info) port))))))

(defun get-amos-info (name)
   ;;; Return the information about amos named NAME, 
   ;;; as stored in the nameserver.
   (setq name (amos-servername name))
   (reval@nameserver (list 'amosinfo (kwote name)))
   )

(defun info-portno (info) (aref info 2))
(defun info-name (info) (aref info 0))
(defun info-host (info) (aref info 1))

;;; =============================================================
;;; Basic RPC section
;;; =============================================================

;contains id of last form which was sent for evaluation 
;without shiping result
(defglobal _noresult-form-id_ 0)
;contains dbid and id of form which was received for evalution 
;without shiping result and result of evaluation which could include error
(defglobal _result-log_ nil)		

(defun set-nameserverhost (addr)
  "Set once the host where the nameserver runs"
  (if (and _nameserverhost_ (not (equal (mkstring addr) _nameserverhost_))) 
      (amos-error "Name server host already set to " _nameserverhost_
                  " and cannot be changed")
    (/setglobal '_nameserverhost_ (mkstring addr))))

(defun print&read (form dbid socket portname)
   (printto form socket dbid)
   (readfrom socket dbid))

(defmacro with-opened-port (socket port form)
  "Execute FORM with SOCKET bound to PORT. 
Always close afterwards if *CONNECTIONLESS*."
  `(let ((, socket (opened-port-socket , port)))
     (unwind-protect , form (if *connectionless* (close-port , port)))))

(defun opened-port-socket (port)
  "Reopen port if closed and get the socket"
  (if (open-port-p port)(port-socket port)
    (port-socket (reopen-port port))))

(defvar *form*) ; currently remote evaluated form
(defvar *port*) ; port of currently remote evaluated form
(defun reval (*form* *port*)
  "Evaluate S-expression *FORM* in server of *PORT*"
  (if (null *port*) (eval *form*)
    (let (remote-res errcond)
      (with-opened-port 
       s *port*
       (cond (s
	      (setq remote-res 
		    (print&read *form* (port-dbid *port*) 
				s (port-name *port*)))
	      (cond ((not (annotated-form remote-res)) remote-res)
		    ((setq errcond (get-form-annotation remote-res :error))
		     (errcond-raise-error errcond 
					  (list 'remote-eval *form* *port*)))
		    (t (get-form errcond))))
	     (t (amos-error "Port closed " *port*)))))))

(defun reval@nameserver (form)
   (if _nameserver_ (eval form)
   (reval form (open-nameserver-port))))

(defun send-form (form port &optional id)
  "One way remote evaluation of FORM. 
ID is an optional integer identity of the evaluation."
  (or (port-p port)(setq port (port-of-peer port)))
  (with-opened-port s port
		    (printto 
		     (annotate-form form :n (or id t))
		     s
		     (port-dbid port)))
  )
    
(defun register-as-listening-peer ()
  "Register this named Amos as a listening peer"
  (if (or _amosid_ _nameserver_) nil 
    (error "This Amos has no name"))
  (cond (_listenport_)
	(t (setq _listenport_ (startlisten (if _nameserver_ *nsp* 0)))
           (reval@nameserver (list 'set-listenport 
				   (mkstring _amosid_) _listenport_))))
  )

(defun run-server ()
  (register-as-listening-peer)
  (if _nameserver_ (princ "Name server " t) (princ "Server " t))
  (formatl t _amosid_ " listening on port " _listenport_ t)
  (if (null (assoc 'server _comm-state_))
      (setq _comm-state_ (nconc1 _comm-state_ (list 'server T))))
  (server-loop))

(defun server-loop ()
  "This is the main event loop in a server"
  (catch 'failure
    (let ((failure t)
	  (co (coroutine (f/l () (while t
				   (check-descriptors 2)
				   ;; Calls remoteeval on incoming socket messages
				   (co-yield))))))
      (unwind-protect
	  (progn
	    (proc-add co)
	    (run-server-coroutines)
	    (proc-purge co)
	    (setq failure nil))
	(cond (failure;; Uncaught error 
	       (proc-purge co)
	       (formatl t "Error caught in server loop. Loop terminated." t)
	       (throw 'failure nil)))))))

(defglobal _form-counter_ 0)
(defun server-eval (descr)
  "Server side evaluation of message sent on socket DESCR"
  (let* ((port (server-port descr))	; This not needed???
	 (*client-port* port)
	 res form noresult dbid)
    (cond ((null (port-socket port)) nil) ; port closed
	  (t (setq form (readfrom descr (setq dbid (port-dbid port))))
             (1++ _form-counter_)
	     (setq res			; the result of the evaluation
		   (traperrors		; rolls back if error, otherwise commit
		    (resetvar _catch-errors_ (null _debugging_)
		      (cond
		       ((setq noresult (get-form-annotation form :n))
			(eval (get-form form)))
		       (t (eval form ))))))
	     (cond ((integerp noresult)
		    (setq _result-log_ (cons (list dbid noresult res) 
					     _result-log_)))
		   (noresult (let ((error (get-form-annotation res :error)))
			       (if error (errcond-print-error 
					  (list :errcond error)))))
		   (t (printto res descr (or dbid 0))))))))

(defglobal _server-communication-errors_ 0) ; Counter of communication errors

(defun server-errorhandler (x)
  (let ((ec _error-condition_))
    (formatl *serverlog*
	     "WARNING! Error caught when SERVER-EVAL processing " x ":" t)
    (errcond-print-error ec *serverlog*)
    (1++ _server-communication-errors_)
    ))
;;; Make SERVER-ERRORHANDLER do all error printing:
(advise-around 'check-descriptors '(catch-error *))
;;; This works since it is always CHECK-DESCRIPTORS that evaluates incoming
;;; messages 

;;; =============================================================
;;; server registration section
;;; =============================================================

(defun set-amos-servername (name &optional reregister)
  (cond ((and _amosid_ (not reregister))
	 (error "This Amos is already acting as a server named" _amosid_))
	(t
	 (history-add _nameamos_ nil nil nil name)
	 (setq _amosid_ (amos-servername name))
	 (if (null (assoc 'amosid _comm-state_))
	     (setq _comm-state_ (nconc1 _comm-state_ 
					(list 'amosid _amosid_)))))))

(defun unnameamos (obj arg old name)
   ;;; Rollback of Amos naming
   (if _nameserver_ (setq _nameserver_ nil) (unregister-amos name))
   (setq _amosid_ nil))

(defun nameserver(name)
  (undo-at-error 
   (if (equal name "") nil		; only nameserver, no peer
     (set-amos-servername (amos-servername name)))
   (setq _nameserver_ t)
   (and _amosid_ 
	(callfunction 'new_amos 
		      (list (mkstring _amosid_) (gethostname) *nsp*)))
   (callfunction 'new_amos (list "NAMESERVER" (gethostname) *nsp*))
   (setq _listenport_ (startlisten *nsp*))
   )
  (commit))

(defun register-amos (logical-name &optional reregister)
   ;;; Inform name server about the name of this AMOS. 
   ;;; Then name will be bound to _AMOSID_.
  (let ((name (amos-servername logical-name)))
    (reval@nameserver `(register-in-nameserver 
			(quote , name) , (gethostname) -1 , reregister))
    (commit)
    (set-amos-servername name reregister)
    ))

(defun unregister-amos (name)
   ;;; Remove NAME from the nameserver.
   ;;; One-way since UNREGISTER-IN-NAMESERVER must close client socket!
   (send-form `(unregister-in-nameserver (quote , name)*client-port*)
        (port-of-peer "NAMESERVER"))
   (close-named-port "NAMESERVER"); nameserver no longer connected!
   (setq _amosid_ nil)
   )

(defun register-in-nameserver (name host portno reregister)
   ;;; Register amos named NAME as running on host
   ;;; HOST listening on port PORTNO."
   ;;; NAME - A string
   ;;; HOST - A string
   ;;; PORTNO - An integer, -1 => not listening.
  (let ((name (amos-servername name)) other)  
      
    (let ((aid (amosinfo name)))
      (cond ((null aid))		; not previously registered
            (reregister			; remove old registration first
             (callfunction 'del_amos (list (mkstring name)))
	     )
	    (t (error "Another Amos running is named" name))))
    (callfunction 'new_amos (list (mkstring name) host portno))
    (setf (port-dbid *client-port*) name)
    (commit)
    ))

(defun unregister-in-nameserver (name &optional port)
   ;;; Register amos named NAME as running on host
   ;;; HOST listening on port PORTNO."
   ;;; NAME - A string
   ;;; PORT - optional client port to be closed
  (let ((name (amos-servername name)))  
    (let ((aid (amosinfo name)))
      (if aid nil (error "No Amos is named" name))
      )
    (if port (close-port port))
    (callfunction 'del_amos (list (mkstring name)))
    (commit)
    ))

(defun set-listenport (name portno)
   (let ((name (amos-servername name)))  
      (let ((aid (amosinfo name)))
         (if aid nil (error "No Amos is named" name))
         (callfunction 'set_portno (list (mkstring name) portno))
         (commit)
         ))) 

(defun amosinfo (name)(car(callfunction 'amosinfo (list (mkstring name)))))

(defun amos-portno (nm)(caar(getfunction 'portnamed (list nm))))

(defun amos-shutdown-comm ()
   (cond (_nameserver_ (unregister-in-nameserver _amosid_)
                       (setq _amosid_ nil)
                       (deleteobject (getobjectnamed 'nameserver _datasource_))
                       )
         (_amosid_ (unregister-amos _amosid_)))
  (initialize-communication))

(defun initialize-communication ()
  "Initialize communication after rollin"
  (setq _amosid_ nil)
  (setq _nameserver_ nil)
  (clrhash _portnametbl_)
  (setq _listenport_ nil))

(defun reopen-nameserver-port ()
  (if (gethash 'nameserver _portnametbl_)
      (reopen-port (get-port-named 'nameserver))))

;;; =============================================================
;;; remote evaluation section
;;; =============================================================

(defun port-of-peer (peer)
   (cond ((null peer) nil) ; local
         ((port-p peer) peer)
         ((eq (setq peer (mkatom peer)) _amosid_) nil) ; local
         ((and (not _client-system_) (null _amosid_))
          (error "Unnamed Amos cannot access other Amos"))
         (t (open-port-named peer))))

(defun remote-eval (form peer)
  "FORM - The form to be evaluated
   PEER - An amosid or an amos name."
   (reval form (port-of-peer peer)))

(defun amos-servers ()
  (let ((fno (getfunctionnamed 'server_names)))
    (mapcar (f/l (x) (oid-name (car x))) (getfunction fno nil))))

(defun global-eval (form &optional dblist asynch)
   ;;; if DBLIST is specified, then FORM is executed in all dabases from DBLIST
   ;;; otherwise FORM is executed in all amos servers and the current database
   ;;; DBLIST is of the form: db1 or (db1 db2 ...)
   ;;; if ASYNCH is specified the evaluation is asynchronuous
   
  (setq dblist (mklist dblist))   
  (let ((all_amos (if dblist
                      dblist
		    (mapcar (f/l (x) (oid-name (car x)))
			    (getfunction 'amos_servers nil))))
	(curr-port nil)
	(tmp nil)
	(res nil))
    (setq all_amos (delete _amosid_ all_amos))
    (setq all_amos (delete 'nameserver all_amos))
    (dolist (a all_amos)
      (cond ((not (null all_amos))
	     (setq curr-port (open-port-named a))
	     (setq tmp (funcall (if asynch 'send-form 'reval)
				`(eval , (kwote form)) 
				(port-of-peer curr-port)))
	     (setq res (cons (list a tmp) res)))))
    (cond ((or (null dblist) (and dblist (memq _amosid_ dblist)))
	   (setq tmp (eval form))
	   (setq res (cons (list _amosid_ tmp) res))))
    res))

(defun amos-remoteeval (string port)
   ;;; Execute the OSQL statement STRING in the mediator server at PORT
   (reval (list 'amos-execute string) (port-of-peer port)))

(defun remote-call (port fn &rest args)
   ;;; Call the Lisp function FN with argument list ARGS in the
   ;;; mediator server at PORT
   (reval (list 'apply (kwote fn) (kwote args)) (port-of-peer port)))

(defun ping (host)
   (null (error? (catch-error (reval t (port-of-peer host))))))

(defun amos-restore-comm ()
  (let ((old-amosid (second (assoc 'amosid _comm-state_)))
	(is-server (second (assoc 'server _comm-state_))))
    (if old-amosid
	(register-amos old-amosid))
    (if is-server
	(run-server))))

(defun set-amosinfo (amosinfo)
  "Set local amosifo for one peer"
  (let ((ao (caar (getfunction _amos-named_ 
			       (list (car amosinfo))))))
    (if ao (setfunction _amosinfo_ (list ao) amosinfo)
      (setfunction _amosinfo_ 
		   (list (setq ao (/createobject 
				   'amos 
				   (car amosinfo)))) 
		   amosinfo))
    ))

(defun ship-result (res fn)
  (if (atom res) nil
    (dolist (x res)
      (funcall fn
	       (cond ((consp x) (listtoarray x))
		     ((arrayp x) x)
		     ((null x) nil)
		     (t (vector x)))))))

(defun is-running (peer)
  (getfunction 'is_running (list peer))
)

(defun wait-for-+ (fno peers)
  "Implementation of wait_for()"
  (cond ((arrayp peers) (wait-until-started (arraytolist peers)))
        ((stringp peers)(wait-until-started peers))
        (t (error "Illegal argument in wait_for" peers)))
  (osql-result peers))

(defun get-my-ip+ (fno)
  (let ((ip (get-my-ip)))
    (if ip (osql-result ip))))

(defun nameserver-+ (fno name r)
  "Make this database nameserver when listening"
  (nameserver name)
  (osql-result name name))
   
(defun register-+ (fno name r)
  "Register this database as inactive peer"	
  (register-amos name)
  (osql-result name name)
  )

(defun nameserverhost-+ (fno namehost r)
  "Declare IP host of nameserver"
  (set-nameserverhost namehost)
  (osql-result namehost namehost))

(defun nameserverport-+ (fno no r)
  "Change port number for name server"
  (/setglobal '*nsp* no)
  (osql-result no no))

(defun porttimeout-+ (fno to r)
  "Change timeout when opening a port to a peer"
  (/setglobal '*open-port-timeout* to)
  (osql-result to to))

(defun reregister--+ (fno name namehost r)
  "Reregister this peer in nameserver"
  (set-nameserverhost namehost)
  (register-amos name t)
  (osql-result name namehost name))

(defun hostname+ (fno name)
  (osql-result (gethostname)))

(defun ship--+ (fno name query result)
  "Ship query for execution in other peer.
   Result shipped back as bag of vectors"
  (ship-result (remote-eval 
		(list 'within-lisp (parse query)) 
		name)
	       (f/l (res)(osql-result name query res))))

(defun send--+ (fno name query peer)
  "Send query for execution in other peer without result"
  (send-form 
   (list 'within-lisp (parse query)) 
   (port-of-peer name))
  (osql-result name query name)
  )

(defun amos-servers+ (fno a)
  "Get all peers objects in nameserver"
  (dolist (nm (if _nameserver_
		  (oid-names (type-extent _amos_))
		(reval@nameserver 
		 '(oid-names (type-extent _amos_)))
		))
    (osql-result (the-object-named nm _amos_))))

(defun this-amosid+ (fno name)
  "The name of this peer"
  (osql-result (mkstring _amosid_)))

(defun kill-peer-+ (fno peer r)
  "Kill named peer unless it is a name server"
  (send-form '(or _nameserver_ (quit)) 
	     (port-of-peer peer))
  (osql-result peer peer))

(defun kill-the-federation (fno)
    (getfunction 'kill_all_peers nil)
    (send-form '(quit) (port-of-peer 'nameserver))
    (quit))

(defun amos-named-+ (fno peer a)
  "Get peer object"
  (let* ((ai (get-amos-info peer))
	 (nm (and ai (mksymbol (aref ai 0)))))
    (and ai nm
	 (osql-result peer
		      (the-object-named nm _amos_)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Definition of AmosQL interface functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun init-comm ()
  (register-shutdown-form '(catch-error (amos-shutdown-comm)) 'first)
  (register-init-form '(initialize-communication))
  (setq _nameamos_ (new-event '/nameamos 'unnameamos))
  (osql "create function name(Amos a)->Charstring nm
as select objectname(a);")
  (setq _amosinfo_ (osql "
create function amosinfo (Amos) -> (Charstring peer key,
                                    Charstring host,
                                    Integer portno)
  /* In nameserver: basic peer information */
  as stored;"))
   
  (osql "
create function all_amosinfo()-> (Charstring name, 
                                  Charstring host, 
                                  Integer portno)
/* In nameserver: information about all known peers */
    as select name,host,portno 
       from Amos a 
       where amosinfo(a)=(name,host,portno);")
   
  (osql "create function portnamed(Charstring peer) -> Integer port
/* In nameserver: get the port of peer */
    as select port 
       from Amos a, Charstring host 
       where amosinfo(a)=(peer,host,port);")
   
  (setq _amos-named_ 
	(prepare-query "select a from Amos a, Charstring nm where name(a)=nm
                        and nm=?1;" 1))
   
  (osql "
create function amosinfo (Charstring peer) -> (Charstring,Charstring,Integer)
    /* In nameserver: information about a peer */
    as select amosinfo(a) from Amos a where name(a)=peer;")
   
  (foreign-lispfn new_amos ((charstring logname) 
			    (charstring host) 
			    (integer portno)) 
		  ((amos ads))
		  "In nameserver: create new peer"
		  (let ((ds_obj (/createobject 'datasource logname)))
		    (/addtype ds_obj _amos_) ; to make datasource names unique
		    (setfunction _amosinfo_ 
				 (list ds_obj) 
				 (list logname host portno))
		    (foreign-result ds_obj)))

  
  (osql "create function del_amos(Charstring peer) -> Charstring 
/* In nameserver: delete peer */
    as for each Amos a 
       where name(a)=peer 
       begin delete a; 
             return peer; 
       end;")
   
  (osql "
create function set_portno (Charstring peer,Integer newport)-> Integer 
/* In nameserver: set port number of peer */
    as for each Charstring nm, Charstring host, Integer portno, Amos o 
       where name(o) = peer and amosinfo(o) = (nm,host,portno)
       begin set amosinfo(o) = (nm,host,newport); 
             return newport; 
       end;")
   


   ;;; What amos servers are running known by the current name server?
  (setq _local-amos-servers_ (compile-query "select a 
    from amos a, charstring nm, charstring host, integer portno
    where amosinfo(a)=(nm,host,portno) and portno != -1;"))
   
  (foreign-lispfn origin_db ((object o))((charstring db))
		  "The peer that created object O"
		  (if (or (not (oid-p o))
			  (not (proxy-p o)))(foreign-result "")
		    (foreign-result (mkstring (proxy-database o)))))

  (foreign-lispfn client_system((charstring host))()
          (setq _client-system_ t)
          (setq _nameserverhost_ host)
          (foreign-result))

  )

(CREATELITERALTYPE 'port (list _literal_) 'port nil nil)
