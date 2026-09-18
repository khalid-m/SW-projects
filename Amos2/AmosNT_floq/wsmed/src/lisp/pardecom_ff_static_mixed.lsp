(defglobal _parfn_  (theresolvent 'cwo))
(defglobal _no_of_rr_receive_  0)
(defglobal _start_pos_  0)
(defglobal _parallelizable_ nil)
(defglobal _dependentfns_ nil)
(defglobal _dependent_ nil)
(defglobal _dresl_ nil)


(defun resl-order ( vfn resl)
  " Returns the result arguments order"
  (let (( ordl (list )) (fncount 1) (fnargcount 1) found)
    (dolist (z resl)
      (setq found nil)
      (dolist (x vfn)
	(dolist (y (function-resvars x))
	  (if (eq y z)
	      (progn
		(setq found 1)
		(setq ordl (adjoin (list fncount fnargcount) ordl))))
	  (if found (return t))
	  (setq fnargcount (1++ fnargcount)))
	(if found (return t))
	(setq fncount (1++ fncount))
	(setq fnargcount 1)
	)
      (setq fnargcount 1)
      (setq fncount 1)
      )
    (reverse ordl)))

(defun search-for-fn-pos (fn orgplan)
  "Returns fn position"
  (let ((i 1) par)
    (dolist (x (argsof 'and orgplan))
      (if (and (member fn x)(> i 1))
	  (if  (and (or _parallelizable_ (= _no_of_rr_receive_ 0))(> (no-of-parfn fn orgplan) 1)(not (= (seventh x) (vector))))
	      (progn (setq par 1)(return i) ))
	(setq i (1+ i))))
    
    (if par i nil)
    ))	      


(defun no-of-parfn (fn orgplan)
  "Returns the number of parallelizable functions"
  (let ((i 0)) 
    (dolist (x (argsof 'and orgplan))
      (if (member fn x)
	  (setq i (1+ i))))
    i))
(defun dependent-check (andl argl pos)
"Find the dependency between predicates"
  (let* ((tr (predify-tbr andl))
	 (first (andify (firstn (1- pos) tr)))
	 (last  (andify (nthcdr (1- pos) tr)))
	 (fvfirst (free-variables first nil))
         (fvlast (free-variables last nil))
	 (temp (intersection (intersection fvfirst fvlast) argl)))
       (if temp t nil)
    ))


(defun partransform-section-subplan (andl from to argl resl)
  "Modyfy TBR conjuction ANDL by replacing section of ANDL between
   positions FROM and TO with invocation of a subplan. "
  (let* (sp  bsp rr_pos str nresl len resorderl)
     
    ;; making a TR expression: first with makebag and last with FF_APPLYP
    (if (> from 1)
	(progn (setq  rr_pos _no_of_rr_receive_)
	       (setq _parallelizable_ nil)
	       
	       (if (dependent-check andl argl from)
		   (progn
		     (setq _dependent_ 1)
		     (setq bsp (section-subplan andl 2 from  argl resl))
		     (setq _parallelizable_ 1)
		     (setq sp (section-subplan (andify (nthcdr from andl)) 2  (length (andify (nthcdr from andl))) argl resl))
		     (if (selectbody-parallelized (getselectbody sp))
			 (setq sp (parallelized-plan sp)))
		     (if (eq rr_pos 1)
			 (progn (setq  _no_of_rr_receive_ 0)
				(setq  _parallelizable_ nil)
				))
		     (setq _dependentfns_ (list bsp sp))
		     (setq _dresl_ resl)
		     (setq sp (andify (list 2 bsp sp)))
		    
		     )
		 (progn
		   (setq bsp (section-subplan andl 2 from  argl resl)) 
		   (setq _parallelizable_ 1)
		   (setq sp (section-subplan andl (1+ from) to argl resl))
		    
		   (if (eq rr_pos 1)
		       (progn (setq  _no_of_rr_receive_ 0)
			      (setq  _parallelizable_ nil)
			      ))

		   (if (not _dependentfns_)
		       (progn
			 (if (selectbody-parallelized (getselectbody sp))
			     (setq sp (parallelized-plan sp)))
			 (setq nresl (function-resvars sp))
			 (setq len (length (function-resvars sp)))
			 
			 (andify  `( (, _makebag_  , bsp ,@ (function-argvars bsp) BG) 
			       (, _ff-applyp_ ,  (listtoarray  _fanout_)  , rr_pos ,  sp BG , len ,@ nresl )))
			 )
		     (progn
		       (setq sp _dependentfns_)
		       (setq nresl _dresl_)
		       (setq resorder (resl-order sp nresl))
		       (setq len (length _dresl_))
		       (setq _dependentfns_ nil)
		       (setq _dresl_ nil)
		       (andify  `( (, _makebag_  , bsp ,@ (function-argvars bsp) BG) 
			       (, _mff-applyp_ ,  (listtoarray  _fanout_)  , rr_pos ,  (listtoarray sp) BG , len , (listtoarray resorder) ,@ nresl )))
		       )
		     )
		   
		   
		  
		       
		    ))))
    
    ))


(defun split-at-first-parfn (firstpos parfn orgfn) 
  ;; parfn - function need to be parallelised in ORGFN
  ;;firstpos - first split position to introduce parallelism
  " Transform the plan at first split point "
  (let* ((sb (getselectbody orgfn))
         (orgplan (selectbody-optpred sb)))
    (partransform-section-subplan  orgplan firstpos 
				  (length orgplan) (selectbody-argl sb)
				  (selectbody-resl sb))))

(defun parallelize (parfn fn)
  (let* (sb tr pos )
    
    (setf sb (getselectbody fn))
    (if (eq _no_of_rr_receive_ 0)(setq _wsl_ nil))
   
    (setf pos (search-for-fn-pos parfn (selectbody-optpred sb)))
   
    
    (if pos		
	(progn (setf  _no_of_rr_receive_ (1+  _no_of_rr_receive_))
	       (if (eq _no_of_rr_receive_ 1)
		   (progn (setq lookupl nil)
			  (setq addl nil)
			  (setq rnl nil)
			  (setq _fanoutl_ nil)
			  (setq _dependent_ nil)
			  (setq _dependentfns_ nil)
			  ))
	       (setf tr (split-at-first-parfn  pos parfn fn))
	      
	       	      
	       (if (neq (second tr) 2)
		   (progn
		     (setf (selectbody-parallelized sb) tr)
		     (optimize-pred tr sb)
		     )
		 (setf (selectbody-parallelized sb) nil)
		 )
	       
	       ))
    )
  )
  
(defun parallelized-plan (fn)
  "Return the parallelized portion"
  (let ((sb (getselectbody fn)))
					;(print (selectbody-resl sb))
    (create-subplan (selectbody-argl sb)
		    (selectbody-resl sb)
		    (selectbody-parallelized sb))))

(advise-around 'compile_phase2 '(prog1 * (if (not *skip-optimization*)(if (> (length _fanout_) _no_of_rr_receive_) 
									     (parallelize _parfn_ fno)))))









     
