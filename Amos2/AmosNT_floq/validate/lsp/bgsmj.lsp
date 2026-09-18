
;; Stream Sort Merge Join atomic read
(defun lsmj (fno spv attrib res)
  (init-extract)
  (let* ((producers (mapcar (f/l (sp) (get&start-sp sp (bgsep))) (arraytolist spv)))
	 (tplarray (smjlread producers (buildl producers nil))) min busycounter activepro)
    (setq producers
	  (mapcar
	   (f/l
	    (socket tpl)
	    (if (eq 'terminated tpl) 'terminated socket))
	   producers tplarray))
    (setq tplarray (remove 'terminated tplarray))
    (setq producers (remove 'terminated producers))
    (while (setq min (selt (minimum-element
			    (f/l (a b) (< (elt a attrib) (elt b attrib)))
			    (mapfilter (f/l (x) x) tplarray))
			   attrib))
      (setq busycounter 0)
      (let ((emitlist (subset tplarray
			      (f/l (x) (equal (selt x attrib) min)))))
	(setq activepro (length emitlist))
	(mapc (f/l (e) (osql-result spv attrib e)) emitlist))
      (setq tplarray
	    (mapcar
	     (f/l
	      (socket tpl)
	      (if (equal (selt tpl attrib) min)
		  (let ((r (ltsread socket)))
		    (cond ((eof? r)
			   (pf 'STOP socket)
			   (setq producers (remove socket producers))
			   'terminated)
			  ((error? r)
			   (error (errcond-msg r) (errcond-arg r)))
			  ((eq '*BUSY* r)
			   (1++ busycounter)
			   nil)
			  (t r)))
		tpl))
	     producers tplarray))
      (setq tplarray (remove 'terminated tplarray))
      (if producers
	  (while (some (f/l (tpl) (null tpl)) tplarray)
	    (setq tplarray
		  (mapcar
		   (f/l
		    (socket tpl)
		    (if (null tpl)
			(let ((r (ltsread socket)))
			  (cond ((eof? r)
				 (pf 'STOP socket)
				 (setq producers (remove socket producers))
				 'terminated)
				((error? r)
				 (error (errcond-msg r) (errcond-arg r)))
				((eq '*BUSY* r)
				 (1++ busycounter)
				 nil)
				(t r)))
		      tpl))
		   producers tplarray))))
      (if (<= activepro busycounter) (sleep 0.001))
      (setq tplarray (remove 'terminated tplarray)))))

(defun lsuj (fno spv attrib res)
  (init-extract)
  (let* ((producers (mapcar (f/l (sp) (get&start-sp sp (bgsep))) (arraytolist spv)))
	 (tplarray (smjlread producers (buildl producers nil))) min)
    (setq producers
	  (mapcar
	   (f/l
	    (socket tpl)
	    (if (eq 'terminated tpl) 'terminated socket))
	   producers tplarray))
    (setq tplarray (remove 'terminated tplarray))
    (setq producers (remove 'terminated producers))
    (while (setq min (selt (minimum-element
			    (f/l (a b) (< (elt a attrib) (elt b attrib)))
			    (mapfilter (f/l (x) x) tplarray))
			   attrib))
      (setq tplarray
	    (mapcar (f/l (socket tpl)
			 (while (equal (selt tpl attrib) min)
			   (osql-result spv attrib tpl)
			   (setq tpl (ltsread socket))
			   (setq tpl
				 (cond ((eof? tpl)
					(pf 'STOP socket)
					(setq producers (remove socket producers))
					'terminated)
				       ((error? tpl)
					(error (errcond-msg tpl) (errcond-arg tpl)))
				       ((eq '*BUSY* tpl) nil)
				       (t tpl)))))
		    producers tplarray))
      (setq tplarray (remove 'terminated tplarray))
      (if (every (f/l (x) (null x)) tplarray)
	  (sleep 0.01))
      (setq tplarray (smjlread producers tplarray))
      (setq producers
	    (mapcar
	     (f/l
	      (socket tpl)
	      (if (eq 'terminated tpl) 'terminated socket))
	     producers tplarray))
      (setq tplarray (remove 'terminated tplarray))
      (setq producers (remove 'terminated producers)))))



 
(defun smjlread (socklist tpllist)
  (while (some (f/l (tpl) (null tpl)) tpllist)
    (setq tpllist
	  (mapcar
	   (f/l
	    (socket tpl)
	    (if (null tpl)
		(let ((r (ltsread socket)))
		  (cond ((eof? r)
			 (pf 'STOP socket)
			 'terminated)
			((error? r)
			 (error (errcond-msg r) (errcond-arg r)))
			((eq '*BUSY* r) nil)
			(t r)))
	      tpl))
	   socklist tpllist)))
  tpllist)

(osql "create function lsmj(Vector of sp spv, Integer attrib) -> Object as foreign 'lsmj';")

(osql "create function lsmjstreamsv(Vector of Stream sv, Integer attrib) -> Stream of Vector as
       select streamof(lsmj(v, attrib))
       from Vector of Sp v
       where v = (vselect spov(s) from stream s where s in sv);")

(osql "create function lsuj(Vector of sp spv, Integer attrib) -> Object as foreign 'lsuj';")

(osql "create function lsujstreamsv(Vector of Stream sv, Integer attrib) -> Stream of Vector as
       select streamof(lsuj(v, attrib))
       from Vector of Sp v
       where v = (vselect spov(s) from stream s where s in sv);")