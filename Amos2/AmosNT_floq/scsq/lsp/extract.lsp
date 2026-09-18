;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2008 Erik Zeitler, UDBL
;;; $RCSfile: extract.lsp,v $
;;; $Revision: 1.58 $ $Date: 2012/09/17 20:42:23 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Extract functions retrieve data from SPs
;;; =============================================================
;;; $Log: extract.lsp,v $
;;; Revision 1.58  2012/09/17 20:42:23  torer
;;; Clearing dribble directory log files
;;;
;;; Revision 1.57  2012/03/13 10:28:52  zeitler
;;; (append (list (list ... replaced by (cons (list ...
;;;
;;; Revision 1.56  2011/01/13 10:56:25  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.55  2011/01/13 10:31:34  zeitler
;;; lread multiarray zip
;;;
;;; Revision 1.54  2011/01/12 17:59:10  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.53  2011/01/12 17:04:37  zeitler
;;; lzipstreams: lread based zip streams
;;;
;;; Revision 1.52  2011/01/12 15:40:10  zeitler
;;; eliminated duplicate tslraed definition
;;;
;;; Revision 1.51  2011/01/12 14:45:59  zeitler
;;; lread extract
;;;
;;; Revision 1.50  2011/01/12 01:19:02  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.49  2011/01/12 01:16:10  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.48  2011/01/06 17:21:18  zeitler
;;; removed dead code
;;;
;;; Revision 1.47  2010/12/19 13:47:34  zeitler
;;; lprint + lread based operators
;;;
;;; Revision 1.46  2010/12/17 13:26:15  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.45  2010/12/06 23:25:44  zeitler
;;; new extract operators
;;;
;;; Revision 1.44  2010/11/27 10:45:58  zeitler
;;; co routine uall
;;;
;;; Revision 1.43  2010/10/26 14:48:46  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.42  2010/09/02 14:31:47  zeitler
;;; Refactoring
;;;
;;; Revision 1.41  2010/08/19 14:59:00  zeitler
;;; extract re-written in C
;;;
;;; Revision 1.40  2010/08/19 11:54:40  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.39  2010/08/18 12:16:57  zeitler
;;; optimized uall + smj
;;;
;;; Revision 1.38  2010/07/05 22:24:00  zeitler
;;; zipreadm collects profile from all producers
;;;
;;; Revision 1.37  2010/06/27 19:46:43  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.36  2010/06/26 14:59:41  zeitler
;;; Optimized multibuffer zip
;;;
;;; Revision 1.35  2010/06/24 11:43:55  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.34  2010/06/23 16:31:05  zeitler
;;; C helper functions for stream merge on multiarrays
;;;
;;; Revision 1.33  2010/06/10 15:36:13  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.32  2010/06/09 23:00:29  zeitler
;;; uallr is utilizing rand-sockets
;;;
;;; Revision 1.31  2010/06/03 15:45:22  torer
;;; *** empty log message ***
;;;
;;; Revision 1.30  2010/06/03 15:16:30  torer
;;; bugfix in retard
;;;
;;; Revision 1.29  2010/05/25 12:27:52  zeitler
;;; exit gracefully on interrupted uall
;;;
;;; Revision 1.28  2010/05/19 20:05:25  zeitler
;;; graceful exit: print STOP symbol on all upstreams
;;;
;;; Revision 1.27  2010/02/24 12:02:14  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.26  2010/02/14 13:10:16  zeitler
;;; EOF is annotated with profile information
;;;
;;; Revision 1.25  2010/02/13 16:35:09  zeitler
;;; SP emits proctime with EOF
;;;
;;; Revision 1.24  2010/02/09 14:39:36  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.23  2010/02/04 16:39:26  zeitler
;;; async-read forces no read order
;;;
;;; Revision 1.22  2009/09/16 14:20:36  zeitler
;;; optimized smj
;;;
;;; Revision 1.21  2009/09/16 13:33:09  zeitler
;;; smjna-nosync is a less synchronuous implementation of SMJ,
;;; utilizing poll-sockets.
;;;
;;; Revision 1.20  2009/08/19 12:36:03  zeitler
;;; Optimized extract
;;;
;;; Revision 1.19  2009/08/17 15:15:18  zeitler
;;; newsp-resulttypes operating on types instead of decoded types
;;;
;;; Revision 1.18  2009/07/27 14:55:17  zeitler
;;; delay is source-tracable
;;;
;;; Revision 1.17  2009/07/23 16:00:02  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.16  2009/06/19 00:13:06  zeitler
;;; init random seed individually for each sp
;;;
;;; Revision 1.15  2009/06/17 15:00:35  zeitler
;;; trace timeout
;;;
;;; Revision 1.14  2009/06/11 18:37:34  zeitler
;;; localize hostnames in port
;;;
;;; Revision 1.13  2009/05/19 15:11:39  zeitler
;;; heartbeats changed: from tokens to annotated tpls
;;;
;;; winagg-resulttypes
;;;
;;; Revision 1.12  2009/04/20 16:35:56  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.11  2009/04/05 16:25:06  zeitler
;;; performance improvement by moving printstat to separate fcn.
;;;
;;; Revision 1.10  2009/04/01 09:47:40  torer
;;; Using setq for setting _heartbeat_
;;;
;;; Revision 1.9  2009/03/30 20:24:28  zeitler
;;; trace zip removed
;;;
;;; Revision 1.8  2009/03/30 09:35:39  zeitler
;;; zipstreams bug fix
;;; _scsq-id_ is used in trace prints
;;;
;;; Revision 1.7  2009/03/24 21:24:39  zeitler
;;; windows version fixed
;;;
;;; Revision 1.6  2009/03/24 20:42:03  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.5  2009/03/24 18:31:38  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.4  2009/03/24 17:47:20  zeitler
;;; 1. all extract functions now in lisp:
;;;    extract, zip, uall, smj, smjna
;;;
;;; 2. Interrupt driven heartbeats enabling retention time measurements
;;;
;;; Revision 1.3  2009/02/25 21:51:56  zeitler
;;; sort merge join on numarray
;;;
;;; Revision 1.2  2008/10/02 17:07:26  zeitler
;;; Global variable _spv-tag_ eliminated
;;; ostream(Sp, tag) implemented
;;;
;;; Revision 1.1  2008/08/04 22:55:55  zeitler
;;; smj: streamed merge join
;;;
;;;
;;; =============================================================

(defglobal _merge-proctimes_ nil "Merge proc times when EOF received")

(defun init-extract ()
  (setq _sourcenode_ nil)
  (setq _others-proctimes_ (make-record #())))

(defun port-localize-hostname (port)
  (let ((p (port-gethostname port)))
    (if (or (equal p (gethostname))
	    (equal p "localhost"))
	'127.0.0.1
      p)))

(defun timestamp? (f)
  (and (listp f)
       (eq (car f) 'TS)))

(defun merge-proctimes (f)
  (and _merge-proctimes_
       (recordp (second f))
       (setq _others-proctimes_
	     (merge-records _others-proctimes_ (second f)))))

(defun eof? (f)
  (if (and (listp f)
	   (eq (car f) 'EOF))
      (or (merge-proctimes f) t))) ;; return t even if no proctime info

(defun add2delaytimes (tpl)
  (setq _delay-times_
	(cons
	 (list (third tpl) (second tpl) (gettimeofday))
	 _delay-times_))
  (setq _timestamp_ (firstn 3 tpl))
  (fourth tpl))

(defun tsread (sock)
  (let ((tpl (read sock)))
    (cond ((timestamp? tpl)
	   (add2delaytimes tpl)
	   (fourth tpl))
	  (t
	   tpl))))

(defun read-sockets (socklist)
  (mapcar
   (f/l
    (socket)
    (cond (socket
	   (let ((tpl (tsread socket)))
	     (cond ((eof? tpl)
		    (pf 'STOP socket)
		    (close-socket socket)
		    nil)
		   ((error? tpl)
		    (setq socklist (remove socket socklist))
		    (mapc (f/l (p)
			       (pf 'STOP p)
			       (close-socket p))
			  socklist)
		    (error (errcond-msg tpl) (errcond-arg tpl)))
		   (t
		    tpl))))))
   socklist))

(defun async-read (socklist) ;; socklist is list or array
  (let* ((socklist (al2l socklist))
	 (tplarray (buildl socklist nil))
	 (lefttopoll socklist))
    (while (consp lefttopoll)
      (let ((polled (arraytolist (or (poll-sockets
				      (listtoarray lefttopoll) 1.0)
				     #()))))
	(setq lefttopoll (set-difference lefttopoll polled))
	(setq tplarray (mapcar (f/l (tpl sock)
				    (if (and sock (memq sock polled))
					(instr-ezread sock socklist)
				      tpl))
			       tplarray socklist))))
    (listtoarray tplarray)))

(defun al2l (al)
  (if (arrayp al) (arraytolist al) al))

(defun stop-sockets (socket socklist) ;; socklist is list or array
  (let ((all-others (remove socket (al2l socklist))))
    (cond ((consp all-others)
	   (mapc (f/l (p)
		      (pf 'STOP p)
		      (close-socket p))
		 all-others)))))

;; mzipread is called from multiarray zip reader
(defun mzipread (socket socklist lreadflag)
  (let ((tpl (if lreadflag (ltsread socket) (tsread socket))))
    (cond
     ((eof? tpl)
      (pf 'STOP socket)
      (close-socket socket)
      (let ((all-others (remove socket socklist)) tmp)
	(cond ((consp all-others)
	       (mapc
		(f/l
		 (s)
		 (pf 'STOP s)
		 (while
		     (not 
		      (eof? (setq tmp (if lreadflag (lread s) (read s)))))))
		all-others))))
      nil)
     ((error? tpl)
      (let ((all-others (remove socket socklist)))
	(cond ((consp all-others)
	       (mapc (f/l (p)
			  (pf 'STOP p)
			  (close-socket p))
		     all-others)))
	(error (errcond-msg tpl) (errcond-arg tpl))))
     (t tpl))))

(defun zipm (fno spv nalen res)
  (init-extract)
  (let* ((producers (mapcar (f/l (sp) (get&start-sp sp)) (arraytolist spv)))
	 (n (length spv))
	 (bufarr (make-array n))
	 (bufpos (make-iarray n))
	 (prodv (listtoarray producers)))
    (dotimes (i n) (seta bufarr i (make-iarray nalen)))
    (while (dest-readsome bufarr bufpos prodv producers nalen nil)
      (osql-result spv nalen (new-emitarr bufarr bufpos nalen)))))

(defun lzipm (fno spv nalen res)
  (init-extract)
  (let* ((producers (mapcar (f/l (sp) (get&start-sp sp (bgsep)))
			    (arraytolist spv)))
	 (n (length spv))
	 (bufarr (make-array n))
	 (bufpos (make-iarray n))
	 (prodv (listtoarray producers)))
    (dotimes (i n) (seta bufarr i (make-iarray nalen)))
    (while (dest-readsome bufarr bufpos prodv producers nalen t)
      (osql-result spv nalen (new-emitarr bufarr bufpos nalen)))))

(defun selt (a i) ;; "secure" elt: No error if a is not an array
  (if (arrayp a) (elt a i)))

; Sort Merge Join does a merge sort of the output from all SPs in SPV, using
; attribute attr. Prerequisite: Each stream is ordered on attr.

(defun smj (fno spv attrib res)
  (init-extract)
  (let* ((producers (mapcar (f/l (sp) (get&start-sp sp)) (arraytolist spv)))
	 (tplarray (read-sockets producers)) min)
    (while (setq min (selt (minimum-element
			    (f/l (a b) (< (elt a attrib) (elt b attrib)))
			    (mapfilter (f/l (x) x) tplarray))
			   attrib))
      (let ((emitlist (subset tplarray
			      (f/l (x) (equal (selt x attrib) min)))))
	(mapc (f/l (e) (osql-result spv attrib e)) emitlist))
      (setq tplarray
	    (mapcar
	     (f/l (x y)
		  (if (equal (selt x attrib) min) 
		      (let ((tpl (instr-ezread y producers)))
			tpl)
		    x))
	     tplarray producers)))))

(defun zipread (socklist)
  (catch 'zip
    (mapcar
     (f/l
      (socket)
      (cond (socket
	     (let ((tpl (tsread socket)))
	       (cond ((eof? tpl)
		      (pf 'STOP socket)
		      (let ((rest (remove socket socklist)) tmp)
			(mapc
			 (f/l (s)
			      (pf 'STOP s)
			      (while (not (eof? (setq tmp (read s))))))
			 rest)
			(throw 'zip))
		      nil)
		     ((error? tpl)
		      (error (errcond-msg tpl) (errcond-arg tpl)))
		     (t
		      tpl))))))
     socklist)))

(defun zip (fno spv res)
  (init-extract)
  (let* ((spl (arraytolist spv))
	 (producers (mapcar (f/l (sp) (get&start-sp sp)) spl)))
    (let ((emitlist (zipread producers)))
      (while (and emitlist (notany (f/l (x) (null x)) emitlist))
	(osql-result spv (listtoarray emitlist))
	(setq emitlist (zipread producers))))))

(defun lzip (fno spv res)
  (init-extract)
  (let* ((spl (arraytolist spv))
	 (producers (mapcar (f/l (sp) (get&start-sp sp (bgsep))) spl)))
    (let ((emitlist (ziplread producers)))
      (while (and emitlist (notany (f/l (x) (null x)) emitlist))
	(osql-result spv (listtoarray emitlist))
	(setq emitlist (ziplread producers))))))

(defun ltsread (sock)
  (let ((tpl (lread sock)))
    (cond ((timestamp? tpl)
	   (add2delaytimes tpl)
	   (fourth tpl))
	  (t
	   tpl))))

(defun ziplread (socklist)
  (catch 'zip
    (let ((tpllist (buildl socklist nil)))
      (while (some (f/l (tpl) (null tpl)) tpllist)
	(setq tpllist
	      (mapcar
	       (f/l
		(socket tpl)
		(if (null tpl)
		    (let ((r (ltsread socket)))
		      (cond ((eof? r)
			     (pf 'STOP socket)
			     (let ((rest (remove socket socklist)) tmp)
			       (mapc
				(f/l (s)
				     (pf 'STOP s)
				     (while (not (eof? (setq tmp
							     (ltsread s))))))
				rest)
			       (throw 'zip))
			     nil)
			    ((error? r)
			     (error (errcond-msg r) (errcond-arg r)))
			    ((eq '*BUSY* r) nil)
			    (t r)))
		  tpl))
	       socklist tpllist)))
      tpllist)))

(defun zipreadm (socklist readthese)
  (catch 'zip
    (mapcar
     (f/l
      (socket r)
      (if (and socket r)
	  (let ((tpl (tsread socket)))
	    (cond ((eof? tpl)
		   (pf 'STOP socket)
		   (let ((rest (remove socket socklist)) tmp)
		     (mapc
		      (f/l (s)
			   (pf 'STOP s)
			   (while (not (eof? (setq tmp (read s))))
			     (formatl t "read " tmp t)))
		      rest)
		     (throw 'zip))
		   nil)
		  ((error? tpl)
		   (error (errcond-msg tpl) (errcond-arg tpl)))
		  (t
		   tpl)))))
     socklist readthese)))

(defun na-selt (a i)
  (if a (na-elt a i)))

(defun na-min (tplarray attrib)
  (na-selt (minimum-element
	    (f/l (a b) (< (na-elt a attrib) (na-elt b attrib)))
	    (remove nil tplarray))
	   attrib))

(defun emitlist (tplarray attrib min)
  (subset tplarray (f/l (x) (equal (na-selt x attrib) min))))

(defun readlist (tplarray producers attrib min)
  (mapcar (f/l (tpl sock)
	       (if (equal (na-selt tpl attrib) min) sock nil))
	  tplarray producers))

(defun pollist (lefttopoll)
  (arraytolist (or (poll-sockets (listtoarray lefttopoll) 1.0) #())))

(defun smjna-nosync (fno spv attrib res)
  (init-extract)
  (setq _readtime_ 0.0)
  (let* ((spl (arraytolist spv))
	 (producers (mapcar (f/l (sp) (get-sp-socket sp)) spl)))
    (mapc (f/l (sp socket) (start-sp-socket sp socket)) spl producers)
    (let ((tplarray (arraytolist (async-read producers))) min)
      (while (setq min (na-min tplarray attrib))
	(let ((emitlist (emitlist tplarray attrib min))
	      (readlist (readlist tplarray producers attrib min)))
	  (mapc (f/l (e) (osql-result spv attrib e)) emitlist)
	  (let ((lefttopoll (subset readlist (f/l (s) (not (null s))))))
	    (while (consp lefttopoll)
	      (let ((polled (pollist lefttopoll)))
		(setq lefttopoll (set-difference lefttopoll polled))
		(setq tplarray
		      (mapcar (f/l (tpl sock)
				   (if (and sock (memq sock polled))
				       (instr-ezread sock producers)
				     tpl))
			      tplarray producers))))))))))

(defun remove-producer (socket a)(listtoarray (remove socket (arraytolist a))))

(defun uallr (fno spv to res)
  (init-extract)
  (setq _readtime_ 0.0)
  (let* ((spl (arraytolist spv))
	 (producers
	  (mapcar
	   (f/l (sp) (open-socket (port-localize-hostname sp)
				  (port-getportno sp)))
	   spl)) graceful)
    (mapc (f/l (p sp) (start-sp-socket sp p)) producers spl)
    (setq producers (listtoarray producers))
    (unwind-protect
	(progn
	  (while (> (length producers) 0)
	    (let ((socket (rand-sockets producers to)))
	      (cond ((null socket) nil)
		    (t
		     (let (tpl)
		       (setq tpl (tsread socket))
		       (cond ((eof? tpl)
			      (pf 'STOP socket)
			      (close-socket socket)
			      (setq producers
				    (remove-producer socket producers)))
			     ((error? tpl)
			      (setq producers
				    (remove-producer socket producers))
			      (maparray producers (f/l (p i)
						       (pf 'STOP p)
						       (close-socket p)))
			      (error (errcond-msg tpl) (errcond-arg tpl)))
			     (t
			      (osql-result spv to tpl))))))))
	  (setq graceful t))
      (if (not graceful)
	  (maparray producers (f/l (p i)
				   (pf 'STOP p)
				   (close-socket p)))))))

(defun derror (tpl)
  (error (errcond-msg tpl) (errcond-arg tpl)))

(defun uallezread (fno spv to res)
  (init-extract)
  (let* ((spl (arraytolist spv))
	 (producers
	  (mapcar
	   (f/l (sp) (open-socket (port-localize-hostname sp)
				  (port-getportno sp)))
	   spl)) graceful)
    (mapc (f/l (p sp) (start-sp-socket sp p)) producers spl)
    (setq producers (listtoarray producers))
    (unwind-protect
	(progn
	  (while (> (length producers) 0)
	    (let (rv tpl)
	      (setq rv (poll-sockets producers to))
	      (cond ((null rv) nil)
		    (t
		     (maparray
		      rv
		      (f/l
		       (socket i)
		       (if (setq tpl (instr-ezread socket producers))
			   (if (consp tpl)
			       (error
				"Tuple extraction not yet implemented")
			     (osql-result spv to tpl))
			 (setq producers
			       (remove-producer socket producers)))))))))
	  (setq graceful t))
      (if (not graceful)
	  (maparray producers (f/l (p i)
				   (pf 'STOP p)
				   (close-socket p)))))))

(defun ualll (fno spv to res)
  (init-extract)
  (let* ((spl (arraytolist spv))
	 (producers (mapcar (f/l (sp) (get-sp-socket sp)) spl))
	 graceful)
    (mapc (f/l (sp socket) (start-sp-socket sp socket)) spl producers)
    (setq producers (listtoarray producers))
    (unwind-protect
	(let (rv)
	  (while (> (length producers) 0)
	    (setq rv (poll-sockets producers to))
	    (if rv
		(let ((ev (instr-ezreads rv producers)))
		  (maparray 
		   ev (f/l
		       (e i) 
		       (if e
			   (osql-result spv to e)
			 (setq producers
			       (remove-producer (elt rv i) producers))))))))
	  (setq graceful t))
      (if (not graceful)
	  (maparray producers (f/l (p i)
				   (pf 'STOP p)
				   (close-socket p)))))))

(defun couallbf (fno spv to res)
  (init-extract)
  (let* ((spl (arraytolist spv))
	 (producers (mapcar (f/l (sp) (get-sp-socket sp)) spl))
	 (cov (make-array (length spv)))
	 graceful)
    (mapc (f/l (sp socket) (start-sp-socket sp socket)) spl producers)
    (setq producers (listtoarray producers))
    (maparray producers
	      (f/l (socket i)
		   (seta cov i
			 (coroutine ;;;
			  'rs
			  (list socket)))))
    (unwind-protect
	(let (resl)
	  (while (setq resl (co-select cov 0.1))
	    (mapc (f/l (tpl)
		       (and tpl (neq tpl 'EOF)
			    (osql-result spv to tpl)))
		  resl))
	  (setq graceful t))
      (if (not graceful)
	  (maparray producers (f/l (p i)
				   (pf 'STOP p)
				   (close-socket p)))))))

(defun rs (s)
  (let (tpl)
    (while (setq tpl (instr-tsread s))
      (co-yield tpl)))
  'EOF)

(defun get-sp-socket (sp &optional reader)
  (open-socket (port-localize-hostname sp) (port-getportno sp) 1.0 reader))

(defun start-sp-socket (sp socket &optional reader)
  (let ((r (or reader (make-record #()))))
    (pf (list (port-getsubscriber sp) r) socket)))

(defun get&start-sp (sp &optional reader)
  (let ((s (get-sp-socket sp reader)))
    (start-sp-socket sp s reader)
    s))

(defun lextractbf (fno sp res)
  (init-extract)
  (let ((socket (get-sp-socket sp)))
    (start-sp-socket sp socket)
    (let (tpl graceful)
      (unwind-protect
	  (progn 
	    (while (setq tpl (instr-tsread socket))
              (if (consp tpl)
		  (error "Tuple extraction not yet implemented"))
	      (osql-result sp tpl))
	    (setq graceful t))
	(if (not graceful)
	    (pf 'STOP socket))))))

(defun dprofile++ (fno res)
  (mapc 
   (f/l (key)
	(osql-result key (record-get _others-proctimes_ key)))
   (record-keys _others-proctimes_)))

(osql "create function dprofile()-> <charstring sp, record profiles>
  as foreign 'dprofile++';")

(defun bgsep () (make-record #("bg" t "sep" t)))

(osql "
create function spov(Stream) -> Sp as foreign 'spov';

/* uall: conventional union-all (implemented in C) */
create function uall(Vector of sp spv, real timeout) -> Object
  as foreign 'uallcbbf';
create function uall(Vector of sp spv) -> Object
  as select uall(spv, 1.0);

/* uallr: rand-socket instead of poll-sockets */
create function uallr(Vector of sp spv, real timeout) -> Object
  as foreign 'uallr';
create function uallr(Vector of sp spv) -> Object
  as select uallr(spv, 1.0);

/* ualll: lisp implementation of union-all */
create function ualll(Vector of sp spv, real timeout) -> Object
  as foreign 'ualll';
create function ualll(Vector of sp spv) -> Object
  as select ualll(spv, 1.0);

/* couall: experimental union-all using co-routines */
create function couall(Vector of sp spv, real timout) -> Object
  as foreign 'couallbf';

/* bguall: union-all using bg recv t */
create function bguall(Vector of sp spv, real timeout) -> Object
  as foreign 'bguallbbf';
create function bguall(Vector of sp spv) -> Object
  as select bguall(spv, 1.0);

/* extract: extract implemented in C */
create function extract(sp)->object
  as foreign 'csixtractbf';

/* lextract: extract implemented in lisp */
create function lextract(sp)->object
  as foreign 'lextractbf';

/* extract using bg recv t */
create function bgextract(sp)->object
  as foreign 'bgextractbf';

create function smjnal(Vector of sp spv, integer attrib) -> Numarray
  as foreign 'smjna-nosync';
create function smjna(Vector of sp spv, integer attrib, real timeout)
 -> Numarray as foreign 'smjnacbbbf';
create function smjna(Vector of sp spv, integer attrib) -> Numarray
as smjna(spv, attrib, 1.0);
create function smj(Vector of sp spv, integer attrib) -> Object
  as foreign 'smj';

/* zip: implemented in lisp */
create function zip(Vector of sp) -> Vector as foreign 'zip';

/* zipmulti: implemented in lisp */
create function zipmulti(Vector of sp, integer nasize)
 -> Vector as foreign 'zipm';

/* lzip: zip using lread */
create function lzip(Vector of sp) -> Vector as foreign 'lzip';

/* lzipmulti: multiarray zip using lread */
create function lzipmulti(Vector of sp, integer nasize)
 -> Vector as foreign 'lzipm';")
