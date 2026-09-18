(defglobal _parfn_  (theresolvent 'cwo))

(defglobal _start_pos_  0)
(defglobal _parallelizable_ 1)
(defglobal _hop_ 2);; expansion of fanout
(defglobal _cwo-oid_ nil)

(defun search-for-fn-pos (fn orgplan)
  "Returns fn position"
  (let ((i 1) par)
    ;;(if (eq _no_of_rr_receive_ 0)(setq _fanoutl_ nil))
    (dolist (x (argsof 'and orgplan))
        (if (and (member fn x)(> i 1))
	  (if  (and (or _parallelizable_ (= _no_of_rr_receive_ 0))(not(equal _cwo-oid_ (concat (fourth x)(fifth x)(sixth x))))(> (no-of-parfn fn orgplan) 1)(not (= (seventh x) (vector))))
	      (progn  (cond ((= _no_of_rr_receive_ 0)
                             (setq _parallelizable_ 1)
			     (setq _coid_ 0)
			     (clrhash _co_stat_);; clear the hash table for coroutines
			     (setq _fanoutl_ (list )) 
			     (setq _cwocount_ 0)
			     (setq _wscall_per_tree_ (list ))
			     (setq _wscall_per_level_ (list ))))
		      
		      (setq _fanoutl_ (cons (list (1+ _no_of_rr_receive_) (list 2) (sixth x)) _fanoutl_));; initialize fanout detail per level
		      (setq _wscall_per_level_ (cons (list (1+ _no_of_rr_receive_)) _wscall_per_level_));;initialize profile for wscall per level
		      (setq par 1)
		      (setq _cwo-oid_ (concat (fourth x)(fifth x)(sixth x)));; to avoid to consider the same web service again
		     
		      (return i) )))
      (setq i (1+ i)))
    
  (if par i nil)
  ))	    

(defun no-of-parfn (fn orgplan)
  "Returns the number of parallelizable functions"
  (let ((i 0)) 
    (dolist (x (argsof 'and orgplan))
      (if (member fn x)
	  (setq i (1+ i))))
      i))



(defun partransform-section-subplan (andl from to argl resl)
  "Modyfy TBR conjuction ANDL by replacing section of ANDL between
   positions FROM and TO with invocation of a subplan. "
  (let* (sp  bsp rr_pos str)
     
    ;; making a TR expression: first with makebag and last with rr_receive
    (if (> from 1)
	(progn (setq  rr_pos _no_of_rr_receive_)
	       (setq _parallelizable_ nil)
	       (setq bsp (section-subplan andl 2 from  argl resl nil)) 
	       (setq _parallelizable_ 1)
	       (setq sp (section-subplan andl (1+ from) to argl resl nil))
	       (if (selectbody-parallelized (getselectbody sp))
		   (setq sp (parallelized-plan sp)))
	       (if (eq rr_pos 1)
		   (progn (setq  _no_of_rr_receive_ 0)
			  (setq  _parallelizable_ 1)
                          (setq  _coid_ 0)
			  ))
	       (andify  `( (, _makebag_  , bsp ,@ (function-argvars bsp) BG) 
			   (, _aff-applyp_ , rr_pos , sp BG , (length (function-resvars sp)) ,@ (function-resvars sp) )))))
    
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
    (setq pos (search-for-fn-pos parfn (selectbody-optpred sb)))
    
    (if pos		
	(progn (setf  _no_of_rr_receive_ (1+  _no_of_rr_receive_))
	       
	       (if (eq _no_of_rr_receive_ 1)
		   (progn (setq lookupl nil)
			  (setq addl nil)
			  (setq rnl nil)))
	       (setf tr (split-at-first-parfn  pos parfn fn))
	       (setf (selectbody-parallelized sb) tr)
	       (optimize-pred tr sb)
	       ))))

(defun parallelized-plan (fn)
"Return the parallelized portion"
  (let ((sb (getselectbody fn)))
    ;(print (selectbody-resl sb))
    (create-subplan (selectbody-argl sb)
		    (selectbody-resl sb)
		    (selectbody-parallelized sb))))




(advise-around 'compile_phase2 '(prog1 * (if (not *skip-optimization*)(if  _parallelizable_
									     (parallelize _parfn_ fno)))))







      