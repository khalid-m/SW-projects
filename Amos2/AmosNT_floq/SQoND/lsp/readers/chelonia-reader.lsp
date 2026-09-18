;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012, Andrej Andrejev, UDBL
;;; $RCSfile: chelonia-reader.lsp,v $
;;; $Revision: 1.3 $ $Date: 2013/01/09 14:16:56 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Reader for text files in Chelonia output format
;;; =============================================================
;;; $Log: chelonia-reader.lsp,v $
;;; Revision 1.3  2013/01/09 14:16:56  andan342
;;; *** empty log message ***
;;;
;;; Revision 1.2  2012/12/17 23:30:58  andan342
;;; Enabling file-links with parameters, always resolving in same dir as .TTL file
;;;
;;; Revision 1.1  2012/11/22 12:41:55  andan342
;;; Added extensible plug-in reader mechanism to resolve file-links in Turtle files
;;; Implemented CheloniaArray reader to load BISTAB data
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

;; Should be loaded after reader-utils.lsp, rdf-types.lsp, nma.lsp

(defun chelonia-read-array (read-token-fn sourcename a idx level noleftbrace)
  (let ((state 0) token)
    (unless (or noleftbrace (equal (funcall read-token-fn) "{"))
      (error (concat "Array dimensionality mismatch in " sourcename)))
    (dotimes (i (nma-dim a level))
      (setf (nth level idx) i)
      (if (< level (1- (nma-ndims a)))
	  (chelonia-read-array read-token-fn sourcename a idx (1+ level) nil) ; recursive
	(progn
	  (setq token (funcall read-token-fn))
	  (if (numberp token)
	      (nma-set a idx token)
	    (error (concat "Array element not numeric: " token " in " sourcename))))))
    (unless (equal (funcall read-token-fn) "}")
      (error (concat "Array size mismatch in " sourcename))))) ; '}' should follow after NMA-DIM elements

(defun validate-dims (dims sourcename)
  (unless (and dims (every (f/l (d) (and (integerp d) (> d 0))) dims))
    (error (concat "Invalid array dimensions: " dims " in " sourcename))))

(defun chelonia-read (filename-or-url par verbose) 
  "Read a literal stored in text file in Chelonia output format"
  (let ((ores (open-filename-or-url filename-or-url))
	str co-token (r "") ltype etype dims (state 0) res)
    (setq str (car ores))
    (unwind-protect
	(loop
	  (setq co-token (if (chunked-stream-p res) (chunked-read-token res nil nil t nil)
			   (read-token str nil nil t nil)))
	  (cond ((eq co-token '*eof*) 
		 (return nil))
		((= state 0)
		 (setq ltype co-token)
		 (setq state 1))
		((= state 1) 
		 (selectq (substring 0 0 ltype)
			  ("i" (setq res (read co-token)) ; integer
			   (unless (integerp res)
			     (error (concat "Invalid integer value: " co-token " in " (cdr ores)))))
			  ("f" (setq res (read co-token)) ; float
			   (if (integerp res) (setq res (* 1.0 res))
			     (unless (floatp res)
			       (error (concat "Invalid floating-point value: " co-token " in " (cdr ores))))))
			  ("s" (setq res co-token)) ; string
			  ("a" (setq state 2)) ; array (default behavior of getSubArray)
			  (error "Invalid value type: " ltype " in " (cdr ores)))
		 (when (= state 1) ; if did not change the state
		   (return res)))
		((and (= state 2) (string= co-token ";"))
		 (setq dims (read-number-list str "," ";"))
		 (validate-dims dims (cdr ores))
;		 (setq dims (fix-dims dims rangestr)) ;TODO: remove this once Chelonia bug is fixed
		 (setq etype (substring 1 (1- (length ltype)) ltype))		   
		 (selectq etype ; create NMA
			  ("int" (setq res (make-inma dims)))
			  ("float" (setq res (make-dnma dims)))
			  (error (concat "Invalid array element type: " etype " in " (cdr ores))))
		 (chelonia-read-array (if (chunked-stream-p str)
					  (f/l () (chunked-read-token str "," "{}" nil t))
					(f/l () (read-token str "," "{}" nil t))) 
				      (cdr ores) res (buildn (length dims) 0) 0 nil) ; read in all the elements
		 (return res))))
      (unless (chunked-stream-p str) (closestream str)))))


(defun cheloniaarray-read (filename-or-url par verbose) 
  "Read a literal stored in text file in Chelonia output format"
  (let* ((ores (open-filename-or-url filename-or-url))
	 types dims etype res)
    (unwind-protect
	(progn
	  (when verbose (formatl nil "Reading CheloniaArray from " (cdr ores) t))
	  (setq types (read-string-list (car ores) "," ";"))
	  (setq etype (car (last types))) ;TODO: guessed
	  (setq dims (read-number-list (car ores) ";" "{"))
	  (validate-dims dims (cdr ores))
	  (selectq etype ; create NMA
		   ("int" (setq res (make-inma dims)))
		   ("float" (setq res (make-dnma dims)))
		   (error (concat "Invalid array element type: " etype " in " (cdr ores))))
	  (chelonia-read-array (if (chunked-stream-p (car ores))
				   (f/l () (chunked-read-token (car ores) "," "{}" nil t))
				 (f/l () (read-token (car ores) "," "{}" nil t))) 
			       (cdr ores) res (buildn (length dims) 0) 0 t)
	  res)
      (unless (chunked-stream-p (car ores)) (closestream (car ores))))))

;; Test 
;; (cheloniaarray-read "C:/DATA/TESTCASES/SantaBarbara/CONV/huang_0_1.txt")