(defglobal _autable_ (make-hash-table))

(foreign-lispfn setauinfo ((charstring wsdlurl)(charstring wsname)(charstring opname)(charstring inputsig)(charstring austr))((charstring status))
		(setf (gethash (mksymbol (concat wsdlurl wsname opname inputsig)) _autable_) austr)
		(foreign-result "true")
		)

(foreign-lispfn getauinfo ((charstring wsdlurl)(charstring wsname)(charstring opname)(charstring inputsig))
		((charstring austr))
		(let (str)
                   (setq str (mkstring (gethash (mksymbol (concat wsdlurl wsname opname inputsig)) _autable_)))
		  (foreign-result str)
		  ))



(defun  tablename (fno tname ftname)
		(let ((i 0) tablel (tempn tname) (found 0))
                 (setq tablel (osql "select name(op) from Operation op;"))
		  (while (= found 0)
		    (dolist (x tablel) 
		      (cond ((= (first x) tempn)
			     (setq tempn (concat tname "_" i))(setq i (1+ i)) (setq found 1)(break)))) 
		    (if (= found 1)
			(setq found 0)
		      (setq found 1))
		    )
		  (osql-result tname tempn)))

(foreign-lispfn tableinput ((function r))
		((charstring column)(charstring datatype))
                
		(if (not(generic? r))
		    (let* ((oc (get-oc r))
			   (argdescr (first oc)))
		     
		      (dolist (x argdescr)
                        (foreign-result (mkstring (second x)) (mkstring (full-type-name (first x))))
			))))

(foreign-lispfn tableoutput ((function r))
		((charstring column)(charstring datatype))
		(if (not(generic? r))
		    (let* ((oc (get-oc r))
			   (resdescr (second oc)))
		      (dolist (x resdescr)
                         (foreign-result (mkstring (second x)) (mkstring (full-type-name (first x))))
			))))
		     


(foreign-lispfn vector_to_str((vector iv))
		((charstring str))
		(let ((ivl (arraytolist iv)) (tstr ""))
		  (dolist (x ivl)
		    (setq tstr (concat tstr (mkstring x))))
		  (foreign-result tstr)))
        
(foreign-lispfn tableinput_v ((function r))
		((charstring tin))
               	(if (not(generic? r))
		    (let* ((oc (get-oc r))
			   (argdescr (first oc)) (str ""))
                      
		      (dolist (x argdescr)
			(if (= str "")
			    (setq str (concat (mkstring (second x)) " : " (mkstring (full-type-name (first x)))))
			  (setq str (concat str " , " (mkstring (second x)) " : " (mkstring (full-type-name (first x)))))))
		      
		      (if (= str "") (setq str "none"))
                      
		      (foreign-result str))))
		
(foreign-lispfn tableoutput_v ((function r))
		((charstring tout))
               	(if (not(generic? r))
		    (let* ((oc (get-oc r))
			   (resdescr (second oc)) (str ""))
		      
		      (dolist (x resdescr)
                       	(if (= str "")
			    (setq str (concat (mkstring (first (reverse x))) " : " (mkstring (full-type-name (first x)))))
			  (setq str (concat str " , " (mkstring (first (reverse x))) " : " (mkstring (full-type-name (first x)))))))
		      (
		       if (= str "")(setq str "none"))
                      
		      (foreign-result str))))