;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Cheng Xu, UDBL
;;; $RCSfile: join.lsp,v $
;;; $Revision: 1.2 $ $Date: 2012/02/29 15:29:15 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: window join
;;; =============================================================
;;; $Log: join.lsp,v $
;;; Revision 1.2  2012/02/29 15:29:15  chexu484
;;; *** empty log message ***
;;;
;;; Revision 1.1  2011/05/20 13:16:33  chexu484
;;; utilize "heartbeat" to unblock sort merge join
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

;; to resolve the blocking, time stamp token is utilized

(defglobal _ts_ "TS") 

(defun localts? (ts)
  (if (arrayp ts)
      (equal _ts_ (elt ts 0))
    nil))  

(foreign-lispfn
 ists ((Vector v)) ((Boolean))
 (if (= (length v) 2)
     (foreign-result (if (= (aref v 0) _TS_) 'TRUE 'FALSE))))

(foreign-lispfn ltssmj ((Vector spv)) ((Object))
  (init-extract)
  (let* ((producers (listtoarray (mapcar (f/l (sp) (get&start-sp sp (bgsep))) (arraytolist spv))))
	 (tsarray (make-array (length producers) :initial-element -1)) mints)
    (while (somea producers (f/l (producer i) producer))
      (setq mints (minimum-element (f/l (a b) (< a b))
				   (mapfilter (f/l (e) e) (arraytolist tsarray))))
      (maparray producers
		(f/l
		 (socket i)
		 (cond ((eq (elt tsarray i) mints)
			(let ((r (ltsread socket)))
			  (cond ((eof? r)
				 (pf 'STOP socket)
				 (seta producers i nil)
				 (seta tsarray i nil))
				((error? r)
				 (error (errcond-msg r) (errcond-arg r)))
				((eq '*BUSY* r))
				((localts? r)
				 (seta tsarray i (elt r 1))) ;; set the time stamp of the heartbeat
				(t
				 (foreign-result r))))))))))) 

(foreign-lispfn lwsmj ((Vector spv) (Integer attrib)) ((Vector of Window))
  (init-extract)
  (let* ((producers (listtoarray (mapcar (f/l (sp) (get&start-sp sp (bgsep))) (arraytolist spv))))
	 (len (length spv))
	 (winarray (make-array len))
	 (flgarray (make-array len)))
    (while (somea producers (f/l (producer i) producer))
      (maparray producers
		(f/l
		 (socket i)
		 (if (not (elt flgarray i))  ;; not doing a cache
		     (let ((r (ltsread socket)))
		       (cond ((eof? r)
			      (pf 'STOP socket)
			      (seta producers i nil)
			      (seta flgarray i T))
			     ((error? r)
			      (error (errcond-msg r) (errcond-arg r)))
			     ((eq '*BUSY* r))
			     ((localts? r)
			      (if (not (elt winarray i)) (seta winarray i (make-swin 0 (elt r 1))))
			      (seta flgarray i T)
			      ;(help flag)
			      (if (everya flgarray (f/l (e i) e))
				  (progn (foreign-result winarray)
					 (setq winarray (make-array len))
					 (setq flgarray (make-array len)))))
			     (t
			      (if (not (elt winarray i)) (seta winarray i (make-swin 0 (elt r attrib))))
			      (window-add-t (elt winarray i) (list r)))))))))))

(osql "create function lwsmjstreamsv(Vector of Stream sv, Integer attrib) -> Stream of Vector of Window as
       select streamof(lwsmj(v, attrib))
       from Vector of Sp v
       where v = (vselect spov(s) from stream s where s in sv);")

(osql "create function ltssmjstreamsv(Vector of Stream sv) -> Bag of Object as
       select ltssmj(v)
       from Vector of Sp v
       where v = (vselect spov(s) from Stream s where s in sv);")  

;; round robin uall, it is unblocking because of every sp has the same heart beat
(defun hb-uall0 (fno spv res)
  (init-extract)
  (let* ((producers (listtoarray (mapcar (f/l (sp) (get&start-sp sp)) (arraytolist spv))))
	 ts graceful)
    (while (> (length producers) 0)
      (maparray producers
		(f/l
		 (socket i)
		 (let (r done)
		   (while (not done)
		     (setq r (tsread socket))
		     (cond ((eof? r)
			    (pf 'STOP socket)
			    (close-socket socket)
			    (setq producers
				  (remove-producer socket producers))
			    (setq done T))
			   ((error? r)
			    (setq producers
				  (remove-producer socket producers))
			    (maparray producers (f/l (p i)
						     (pf 'STOP p)
						     (close-socket p)))
			    (setq done T)
			    (error (errcond-msg r) (errcond-arg r)))
			   ((localts? r)
			    (setq done T)
			    (if (= i (1- (length producers)))
				(progn
				  (osql-result spv r)
				  (setq ts r))))
			   (t
			    (osql-result spv r))))))))))

(osql "create function hb_uall0(Vector of Sp spv) -> Object as foreign 'hb-uall0';")
(osql "create function hb_uall(Vector of Sp spv) -> Stream as select streamof(hb_uall0(spv));")
(osql "create function hb_mergestreams(Vector of Stream sv) -> Stream as
       select hb_uall(v)
       from Vector of Sp v
       where v = (vselect spov(s) from Stream s where s in sv);") 

(foreign-lispfn localts ((Number i)) ((Vector))
		(foreign-result (vector _ts_ i)))  

(foreign-lispfn tstring () ((Object))
		(foreign-result _ts_))