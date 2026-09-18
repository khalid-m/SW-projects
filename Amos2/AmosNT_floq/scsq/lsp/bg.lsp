;;; ============================================================
;;; AMOS2
;;;
;;; Author: (c) 2006 Erik Zeitler, UDBL
;;; $RCSfile: bg.lsp,v $
;;; $Revision: 1.2 $ $Date: 2009/11/13 15:57:34 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: bg.lsp contains BlueGene specific lisp functions.
;;; bg.lsp should be loaded by sc.osql.
;;; =============================================================
;;; $Log: bg.lsp,v $
;;; Revision 1.2  2009/11/13 15:57:34  zeitler
;;; scsq.lsp split
;;;
;;; Revision 1.1  2007/04/24 12:19:26  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.2  2006/09/14 09:20:21  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.1  2006/08/14 15:16:48  zeitler
;;; preparator project
;;;
;;;
;;; =============================================================

(if (eq (system-environment) "Unix")
    (defun gethostname () (get-varstring 'bghostid)))


;; MPI related
(defglobal _bg-q_ nil)
(defglobal _cnc-rank_ 1)
(defglobal _mpistreambufsize_ 10000)
(defglobal _mpismergemaxpoll_ 2)
(defglobal _continuation-period_ 100)
(defglobal _my-mpirank_ 9999)
(defglobal _free-nodes_ nil)

(foreign-lispfn 
 setmaxpoll((integer bs))
 nil
 (setq _mpismergemaxpoll_ bs))

;; BGOUT
(defglobal _front-hostport_ nil)
(defglobal _front-listen-sock_ nil)
(defglobal _event-head_ nil)
(defglobal _event-last_ nil)


(defun sendto-nameserver (x) (send-form x (open-nameserver-port)))

(defun sendto-front (x) (send-form x (open-port-named 'front)))

(defun open-fls ()
  (setq _front-listen-sock_ (open-socket nil 0))
  (setq _front-hostport_
	(list
	 (get-varstring 'bghostid)
	 (socket-portno _front-listen-sock_))))

(defun open-sock-to-front ()
  (open-socket (first _front-hostport_) (second _front-hostport_)))

(defun save-bgstate ()
  (resetvar _amosid_ nil		; BG peer not a nameserver
	    (resetvar _nameserver_ nil
		      (resetvar _debugging_ nil
				(rollout 
				 (concat
				  (get-varstring 'bghome) "bg.dmp"))))))

(defun mknodelist (n)
  (cond ((eq n 0) '(0))
	(t (append (mknodelist (- n 1)) (list n)))))

(defun get-freenode ()
  (let ((fn (car _free-nodes_)))
    (setq _free-nodes_ (cdr _free-nodes_)) fn))

(defun return-freenode (num)
  (setq _free-nodes_ (append (list num) _free-nodes_)))

(foreign-lispfn copy_to_bghome ((charstring file))((integer))
		(cond ((equal (SYSTEM-ENVIRONMENT) "Unix")
		       (foreign-result
			(system
			 (concat "cp " file " "
				 (get-varstring 'bghome)))))
		      (t		;windows
		       (foreign-result
			(system
			 (concat "copy " file " "
				 (get-varstring 'bghome)))))))

(defun init-front ()
;; Registers at the local nameserver
  (register-amos "front" T)
  (cond (_listenport_)
	(t (setq _listenport_ (startlisten (if _nameserver_ *nsp* 0)))
	   (reval@nameserver (list 'set-listenport 
				   (mkstring _amosid_) _listenport_))))
  (if _nameserver_ (princ "Name server " t) (princ "Server " t))
  (formatl t _amosid_ " listening on port " _listenport_ t))


(defun init-bg-node (rank size)
  "This function is run when BG node is initalized"
  (setq _NAMESERVERHOST_ nil)
  (clrhash _PORTNAMETBL_)
  (set-nameserverhost (get-varstring 'prepcoordhost))
  (setq _my-mpirank_ rank)
  (setq _amosid_ nil)
;;(trace reval@nameserver)
;;(trace open-socket)
;;(trace register-in-nameserver)
  (setq _batch_ t)
  (debugging t)) 

(foreign-lispfn 
 setmpibuf((integer bs))
 nil
 (setq _mpistreambufsize_ bs))

(foreign-lispfn 
 profiler((charstring query))
 ((charstring prof)(charstring status)(vector result))
 (let ((c (clock))
       res wt ec)
   (catch-error
    (setq res (amos-execute query))
    (setq ec _error-condition_))
   (setq wt (- (clock) c))
   (foreign-result (concat "Wall time: " wt)
		   (if ec (errcond-errormessage ec)
		     "OK")
		   (vectorize res))))

(set-resulttypesfn 
 (osql "create function bg(bag)->object as foreign 'bgsubmitbf';") 
 'bg-resulttypes)

(defun bg-resulttypes (fno args)
  "The result type is the type parameters of the 1st argument"
  (type-parameters (arg-type (car args))))

(defun r (tpl)
  (cond ((null _event-head_)
	 (setq _event-head_ (list tpl))
	 (setq _event-last_ _event-head_))
	(t (rplacd _event-last_ (list tpl))
	   (setq _event-last_ (cdr _event-last_)))))

(defun eof ()
  (r 'eof))

;; <bgout related fcns>

(defun request-bgport (generator nsubscribers bgport)
  (reval@nameserver `(coo-init-bgsp , generator , nsubscribers , bgport)))

(defun coo-init-bgsp (generator nsubscribers bgport)
  (let ((sp-name (concat "sp-" (gensym))))
    (coo-enqueue-bgrequest (list 'cnc-init-bgsp generator
				 nsubscribers bgport sp-name))))

(defun coo-enqueue-bgrequest (form)
  (setq _bg-q_ (append _bg-q_ (list form))))

(defun cnc-retrieve-bgrequests ()
  (reval@nameserver '(prog1 _bg-q_ (setq _bg-q_ nil))))

(defun cnc-init-bgsp (generator nsubscribers bgport sp-name)
  (let ((rank (port-gethostname bgport))
	(tag  (port-getportno bgport)))
    (mpi-send-block generator rank tag)
    (mpi-send-block nsubscribers rank tag)))

(defun start-bgport (subport bgport)
  (reval@nameserver `(coo-start-bgsp , subport , bgport)))

(defun coo-start-bgsp (subport bgport)
  (coo-enqueue-bgrequest (list 'cnc-start-bgsp subport bgport)))

(defun cnc-start-bgsp (subport bgport)
  (let ((rank (port-gethostname bgport))
	(tag  (port-getportno bgport)))
    (mpi-send-block subport rank tag)))

;; </bgout related fcns>
