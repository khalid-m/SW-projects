;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009 Erik Zeitler, UDBL
;;; $RCSfile: fork.lsp,v $
;;; $Revision: 1.6 $ $Date: 2012/09/06 21:25:01 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Fork and non-blocking rollout
;;; =============================================================
;;; $Log: fork.lsp,v $
;;; Revision 1.6  2012/09/06 21:25:01  torer
;;; Using MAPBAG instread of MAPFUNCTION
;;; Added some debugging primitives
;;;
;;; Revision 1.5  2009/06/25 16:54:23  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.4  2009/06/25 14:13:41  zeitler
;;; no autoflush in pipestreams
;;; shorter numarray header
;;;
;;; Revision 1.2  2009/02/20 17:00:56  zeitler
;;; fork and nbrollout tests
;;;
;;; Revision 1.1  2009/02/19 14:59:41  zeitler
;;; fork and non blocking rollout
;;;
;;;
;;; =============================================================

;; TODO: poll _uppipe_ before read. Requires poll in pipestream.c.

(defglobal _pipebufsize_ 4096)
(defglobal _rollout-pid_ nil)
(defglobal _uppipe_ nil)

(defun newpsp (fno s res)
 (let ((sp (psp _pipebufsize_)))
   (pf s (third sp))
   (osql-result s (new-port "pipe" (gethostname) sp))))

(defun pextract (fno p res)
  (let (tpl (rpipe (second (port-getportno p))))
    (while (not (eq (setq tpl (read rpipe)) '*EOF*))
      (osql-result p tpl))
    (pf 'STOP (third (port-getportno p)))
    (waitproc (first (port-getportno p)))))

(defun new-pipestream (&optional bs)
  (if bs
      (new-pipestream0 bs)
    (new-pipestream0 _pipebufsize_)))

(defun pspmapper (generator sub)
  (mapbag generator
   (f/l (tpl)
	(instr-print (car tpl) sub))))

(defun psp (bs)
  (let ((uppipe (new-pipestream bs))
	(downpipe (new-pipestream bs))
	(p (fork0)))
    (cond ((eq p 0)
	   (setq _batch_ t)
	   (let ((generator (read downpipe)))
	     (pspmapper generator uppipe)
	     (pf '*EOF* uppipe)
	     (let (tmp)
	       (while (not (eq (setq tmp (read downpipe)) 'STOP))))
	     (exit)))
	  (t (list p uppipe downpipe)))))

(defun pstract (port)
  (let (tpl (c 0) starttime endtime)
    (while (not (eq (setq tpl (read (second port))) '*EOF*))
      (if (eq c 0) (setq starttime (rnow)))
      (1++ c))
    (setq endtime (rnow))
    (pf 'STOP (third port))
    (waitproc (first port))
    '(formatl t "[count " c ", time " (- endtime starttime) " "
	     (- (rnow) endtime) "]" t)))

(defun fork (fn)
  (setq _uppipe_ (new-pipestream))
  (let ((a (fork0)))
    (cond ((equal a 0)
	   (setq _batch_ t)
	   (funcall fn _uppipe_)
	   (pf '*EOF* _uppipe_)
	   (exit))
	  (t a))))

(defun wait-nbrollout ()
  (cond ((and _rollout-pid_ (> 0 _rollout-pid_))
	 (waitproc _rollout-pid_)
	 (setq _rollout-pid_ nil))))

(defun nbrollout (filename)
  (wait-nbrollout)
  (setq _rollout-pid_
	(fork (f/l (p) (pf (rollout filename) p)))))

(defun forkbf (fno s res)
  (let ((pid
	 (fork
	  (f/l (p)
	       (mapbag s
		       (f/l (tpl) (print tpl p)))
	       (flush p))))
	(ltpl))
    (while (not (eq (setq ltpl (read _uppipe_)) '*EOF*))
      (osql-result s ltpl))
    (waitproc pid)))

(osql "create function fork(stream s)->object as foreign 'forkbf';") 
