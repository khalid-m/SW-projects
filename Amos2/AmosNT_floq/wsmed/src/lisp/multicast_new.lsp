;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Tore Risch, UDBL
;;; $RCSfile: multicast_new.lsp,v $
;;; $Revision: 1.2 $ $Date: 2007/09/25 17:20:50 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Function to multicast computations in parallel to peers
;;; =============================================================
;;; $Log: multicast_new.lsp,v $
;;; Revision 1.2  2007/09/25 17:20:50  msabesan
;;; *** empty log message ***
;;;
;;; Revision 1.1  2007/09/21 07:47:42  msabesan
;;; *** empty log message ***
;;;
;;; Revision 1.1  2007/08/27 19:19:11  torer
;;; Multicasting with result stream merging
;;;
;;; =============================================================

(setq _system-watermark_ 0)

(osql "
create function multicastReceive(Vector peers, Charstring fn, Vector args) 
                                 -> Object
  as foreign 'multicast-receive';

create function rr_receive(Vector peers, Charstring fn, Bag args)-> Object
  as foreign 'rr-receive';")

(defvar *not-ready-peers*) ; counter of not ready peers
(defvar *multicastreceive-args*) ; arguments of multicastReceive

(defun multicast-receive (fno peers function arguments result)
  (let ((*not-ready-peers* (length peers)))
    (setq *multicastreceive-args* (list peers function arguments))
    (register-as-listening-peer);; Register as listening before multicasting
    (maparray peers;; Multicast function and arguments to the peers
	      (f/l (p i)
		   (send-form (list 'reply-to (kwote _amosid_)
				    (kwote function)
				    (aref arguments i))
			      (port-of-peer p))))
    (broadcast-eof peers)
    (run-until-all-received);; Wait for results to arrive
    ))

(defun rr-receive (fno peers function arguments result)
  (let ((*not-ready-peers* (length peers))
        (nopeers (length peers)) 
        (thispeer -1))
    
    (setq *multicastreceive-args* (list peers function arguments))
    (register-as-listening-peer);; Register as listening before multicasting
    (mapbag arguments 
	    (f/l (row)
		 (setq thispeer (1+ thispeer))
		 (if (>= thispeer nopeers)(setq thispeer 0))
		 (send-form (list 'reply-to (kwote _amosid_)
				  (kwote function)
				  (car row))
			    (port-of-peer (aref peers thispeer)))))
    (broadcast-eof peers)
    (run-until-all-received);; Wait for results to arrive
    ))

(defun broadcast-eof (peers)
  (maparray peers (f/l (p i)(send-form (list 'report-ready (kwote _amosid_))
				       (port-of-peer p)))))

(defun reply-to (peer fn args)
  "Send to PEER return stream from applying FN on ARGS"
  (let ((port (port-of-peer peer)))
    (mapfunctionres (getfunctionnamed (mksymbol fn))
		    args nil 
		    (f/l (row)(send-form 
			       (list 'peer-reply (kwote (car row)))
			       port)))
    ))

(defun report-ready (to)
  (send-form `(peer-ready (quote , _amosid_))(port-of-peer to)))

(defun peer-reply (val)
  "Emit received reply from peer"
  (apply 'osql-result (append *multicastreceive-args* (list val))))

(defun peer-ready (peer)
  "Register that another peer has sent all data"
  (1-- *not-ready-peers*))

(defun run-until-all-received ()
   "Receive answers until all peers ready"
   (while (> *not-ready-peers* 0) (check-descriptors 2)))
