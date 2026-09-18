;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Tore Risch, UDBL
;;; $RCSfile: multicast.lsp,v $
;;; $Revision: 1.6 $ $Date: 2012/02/23 20:27:38 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Function to multicast computations in parallel to peers
;;; =============================================================
;;; $Log: multicast.lsp,v $
;;; Revision 1.6  2012/02/23 20:27:38  torer
;;; Wrong result type
;;;
;;; Revision 1.5  2008/01/16 08:51:04  torer
;;; Lingering bug
;;;
;;; Revision 1.4  2008/01/16 08:21:49  torer
;;; Bug fixed: Must iterate through all selected sockets
;;;
;;; Revision 1.3  2008/01/15 21:20:58  torer
;;; Multiple polling
;;;
;;; Revision 1.2  2007/09/27 16:37:38  torer
;;; multicast-receive with sockets
;;; (socket-closed s) tests if socket closed
;;;
;;; Revision 1.1  2007/08/27 19:19:11  torer
;;; Multicasting with result stream merging
;;;
;;; =============================================================

(osql "
create function multicastReceive(Vector peers, Charstring fn, Vector args) 
                                 -> Bag of Object
  as foreign 'multicast-receive';")

(defun pf (x s)
  (print x s)
  (flush s))

(defun multicast-receive (fno peers fn args res)
  (let* ((ports (mapcar (function port-of-peer) (arraytolist peers)))
         (sockets (mapcar (function port-socket) ports))
         (arglists (arraytolist args))
	 rd)
    (mapc (f/l (p argl);; start peers
	       (send-form (list 'start-function fn argl) p))
	  ports arglists)
    (while sockets;; Start receiving data from peers
      (let ((socks (poll-sockets (listtoarray sockets) 1)));; Poll parallell
	(cond ((null socks) nil);; Timeout
              (t (maparray socks 
			   (f/l (e i)
				(cond ((eq (setq rd (read e)) '*eof*)
				       ;; Stream done
				       (setq sockets 
					     (remove e sockets)))
				      (t
				       ;; emit
				       (osql-result peers fn args rd)))))))
	))))
   
(defun start-function (fn args)
  "This function runs on child and sends result back on client port"
  (let ((s (port-socket *client-port*))
        (fno (resolvename (mksymbol fn) args nil)))
    (mapfunction fno args
		 (f/l (row)
		      (pf (car row) s)))
    (pf '*eof* s)))
