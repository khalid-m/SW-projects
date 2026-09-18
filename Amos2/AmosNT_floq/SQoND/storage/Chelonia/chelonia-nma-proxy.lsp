;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Andrej Andrejev, UDBL
;;; $RCSfile: chelonia-nma-proxy.lsp,v $
;;; $Revision: 1.3 $ $Date: 2012/04/14 16:05:25 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: NMA proxy for Chelonia storage/wrapper intefaces
;;; =============================================================
;;; $Log: chelonia-nma-proxy.lsp,v $
;;; Revision 1.3  2012/04/14 16:05:25  andan342
;;; Array proxy objects now correctly accumulate STEP information and are completely transparent to array slicing/projection/dereference operations. Added workaraounds for Chelonia step-related bug.
;;;
;;; Revision 1.2  2012/03/19 11:05:10  andan342
;;; NMA-PROXIES now accumulate ASUB operations, and are resolved automatically in expressions
;;;
;;; Revision 1.1  2012/03/18 13:16:06  andan342
;;; Created WRAPPER mode separate from TRIPLE-STORE mode
;;; Added NMA proxies to handle 'too large' arrays
;;;
;;;
;;; =============================================================

(defvar _nma_proxy_threshold_ 12000) ; if there are more elements in NMA coming from Chelonia, create proxy URI, NIL = disable NMA proxies

(defun make-chelonia-nma-proxy (db tid var rangestr etype dims)
  "Construct proxy URI with all information necessary to retrieve an array"
  (uri (concat "nma:" db "|" tid "|" var "|" rangestr "|" etype "|" 
	       (strings-to-string (mapcar #'mkstring dims) "" "," ""))))

(defun chelonia-nma-proxy-dims (x)
  (listtoarray (mapcar #'read 
		       (string-explode (sixth (string-explode (uri-id x) "|")) ","))))

(setq _nma_proxy_dims_ #'chelonia-nma-proxy-dims)

(defun npsplit1-db (npsplit1)
  (substring 4 (1- (length npsplit1)) npsplit1))

(defun get-k-range-idx (rangesplit k)
  "Return list position of K-th string in RANGESPLIT, counting only those strings containing ':'"
  (let ((idx 0))
    (dolist (r rangesplit)      
      (when (string-pos r ":")	
	(if (> k 0) (decf k)
	  (return idx)))
      (incf idx))))

(defun delete-nth (list n)
  "Destructively delete N-th element of LIST"
  (if (= n 0) (cdr list)
    (let ((prev (nthcdr (1- n) list)))
      (rplacd prev (cddr prev))
      list)))

(defun chelonia-nma-proxy-apply-range (x k lo step hi)
  "Reconstruct proxy URI by applying selection range in k-th dimension,
   if HI = NIL - perform 'proxy' equivalent of projection/derefernce on LO"
  (let* ((npsplit (string-explode (uri-id x) "|"))
	 (dimsplit (string-explode (sixth npsplit) ","))
	 (kdim-str (nth k dimsplit))
	 kdim rangesplit k-range-idx krange klo kstep newlo)
    (when kdim-str (setq kdim (read kdim-str)))
    (when (and kdim (< lo kdim) (or (null hi) (< hi kdim)))
      (when (and hi (< hi 0)) 
	(setq hi (1- kdim))) ; default hi value
      (if (string= (fourth npsplit) "")
	  (progn ; construct default RANGESPLIT
	    (setq rangesplit (mapcar (f/l (d) (concat "1:1:" d)) dimsplit))
	    (setq k-range-idx k)
	    (setq klo 1)
	    (setq kstep 1))
	(progn ; parse RANGESPLIT to get KLO and KSTEP
	  (setq rangesplit (string-explode (fourth npsplit) ","))
	  (setq k-range-idx (get-k-range-idx rangesplit k))
	  (setq krange (string-explode (nth k-range-idx rangesplit) ":"))
	  (setq klo (read (first krange))) ; get k-th lo
	  (setq kstep (read (second krange)))))
      (setq newlo  (+ (* lo kstep) klo))
      (setf (nth k-range-idx rangesplit) ; update k-th range
	    (if hi (concat newlo ":" (* step kstep) ":" (+ (* hi kstep) klo)) ;new range
	      (concat newlo))) ; new projection/dereference
      (if hi (setf (nth k dimsplit) ; update k-th dim if applying range
		   (mkstring (1+ (/ (- hi lo) step))))
	(setf dimsplit (delete-nth dimsplit k))) ; remove k-th dim if projecting/dereferencing
      (make-chelonia-nma-proxy (npsplit1-db (first npsplit)) ; reconstruct proxy
			       (second npsplit) (third npsplit) 
			       (strings-to-string rangesplit "" "," "")
			       (fifth npsplit) dimsplit))))

(setq _nma_proxy_apply_range_ #'chelonia-nma-proxy-apply-range)

(defun lproduct (l)
  "Product of list elements"
  (let ((res 1))
    (dolist (e l res)
      (setq res (* res e)))))

(defun chelonia-nma-proxy-resolve (x)
  "Resolve array proxy if not too large"
  (let ((npsplit (string-explode (uri-id x) "|")))
    (if (and _nma_proxy_threshold_ (> (lproduct (mapcar #'read (string-explode (sixth npsplit) ","))) ; if X is too large
				      _nma_proxy_threshold_)) x ; return nma-proxy unchanged
      (let ((rangesplit (string-explode (fourth npsplit) ",")) ; else call getSubArray 
	    (k 0) proj-list res) ; PROJ-LIST stores (DIM . IDX) pairs in DIM-descending order
	(unless (string= (car rangesplit) "") ; check for projections if range is specified
	  (dolist (r rangesplit)
	    (unless (string-pos r ":")
	      (setf (nth k rangesplit) (concat r ":1:" r))
	      (push (cons k (read r)) proj-list))	  
	    (incf k)))
	(setq res (caar (getfunction (car (getobject (getfunctionnamed 'getSubArray) 'resolvents))
				     (list (npsplit1-db (first npsplit)) (read (second npsplit)) (third npsplit) 
					   (strings-to-string rangesplit "" "," "")))))
	(when (eq (typename res) 'nma)
	  (dolist (proj proj-list) ; apply all projections, reducing dimensionality by 1 each time
	    (setq res (nma-project res (car proj) 0)))) ; (1- (cdr proj))))))
	res))))

(setq _nma_proxy_resolve_ #'chelonia-nma-proxy-resolve)
		     

      

	 
    
			       

   