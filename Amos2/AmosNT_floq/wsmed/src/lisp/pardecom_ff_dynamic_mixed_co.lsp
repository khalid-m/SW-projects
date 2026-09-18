(defglobal _parfn_  (theresolvent 'cwo))
(defglobal _no_of_rr_receive_  0)
(defglobal _start_pos_  0)
(defglobal _parallelizable_ 1)
(defglobal _dependentfns_ 1)
(defglobal _dresl_ nil)
(defglobal _cwo-oid_ nil)
(defglobal _pos_ nil) ;; split point



(defun rearrange-fanoutl(ws)
  "when independent among subplans found, fanout list will be revised"
  (dolist (x _fanoutl_)
    (if (member ws x)
	(progn
	  (setq _fanoutl_ (subst (subst (1- (first x)) (first x) x) x _fanoutl_))
	  (setq _no_of_rr_receive_ (1- _no_of_rr_receive_))
	  (return t)))))

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

(defun arg-order (bsp vfn)
  "Returns the input arguments order"
  (let ((arg (make-array (length vfn))) i (j 0) templ)
    (dolist (f vfn)
      
      (setq templ (list))
      (dolist (x (function-argvars f))
	(setq i 1)
	(dolist (b (function-resvars bsp))
	  (cond ((= b x)
		 (if templ (setq templ (cons i templ))
		   (setq templ (list i)))
		 ))
	  (setq i (1+ i))))
      (seta arg j (reverse templ))
      (setq j (1+ j)))
    arg  ))
    



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
		      (set-hop (1+ _no_of_rr_receive_) 2)
		      (setq _wscall_per_level_ (cons (list (1+ _no_of_rr_receive_)) _wscall_per_level_));;initialize profile for wscall per level
		      (setq par 1)
		      (setq _cwo-oid_ (concat (fourth x)(fifth x)(sixth x)));; to avoid to consider the same web service again
		     
		      (return i) )))
      (setq i (1+ i)))
    
  (if par i nil)
  ))	    

(defun find-next-cwo-pos (pos orgplan)
  "Returns next cwo position in orgplan"
  (let ((i 1) )
    (dolist (x (argsof 'and orgplan))
      (if (and (member (theresolvent 'cwo) x)(> i pos))
	  (return i)
	(setq i (1+ i))))
    i))	      


(defun no-of-parfn (fn orgplan)
  "Returns the number of parallelizable functions"
  (let ((i 0)) 
    (dolist (x (argsof 'and orgplan))
      (if (member fn x)
	  (setq i (1+ i))))
    i))
   

(defun check-valid(andl)
  (let (valresult)
    (dolist (x andl)
      (if (and (symbolp x) (neq x (mksymbol '*)))
	  (progn (setq valresult 1)
		 (return valresult))))
    valresult))


(defun dependent-check (andl argl pos)
  "Find the dependency between predicates."
  (let* ((tr (predify-tbr andl))
	 (first (firstn pos tr))
         (last  (nthcdr pos  tr))
	 dependent val)
    (dolist (x (cdr first))
      (dolist (y last)
	(setq val (intersection (nthcdr 1 x) (nthcdr 1 y)))
	(if ( and val (check-valid val))
	    (if (not (intersection val argl))
		(progn 
		  (setq dependent t) 
		  (return dependent)))))
      (if dependent (return dependent)))
    dependent))
	    

(defun partransform-section-subplan (andl from to argl resl)
  "Modyfy TBR conjuction ANDL by replacing section of ANDL between
   positions FROM and TO with invocation of a subplan. "
  (let (sp  bsp rr_pos str nresl len resorder inde)
    ;; making a TR expression: first with makebag and last with FF_APPLYP or MFF_APPLYP
    (if (> from 1)
	(progn (setq  rr_pos _no_of_rr_receive_)
	       (if (not (dependent-check andl argl from));; to check the independent plans
		   (progn (setq inde 1)
                          (quote (rearrange-fanoutl (sixth (nth _pos_ andl)))) ))
	       (setq _parallelizable_ nil)

	        
	       (setq bsp (section-subplan andl 2 from  argl resl inde))
	       (setq _parallelizable_ 1)
	       	       
	       (setq sp (section-subplan andl (1+ from) to argl resl inde))
	        
	       (if (eq rr_pos 1)
		   (progn (setq  _no_of_rr_receive_ 0)
			  (setq  _parallelizable_ 1)))

	        (if (selectbody-parallelized (getselectbody sp))
		    (setq sp (parallelized-plan sp)))
	                    
	       (if  inde
		   (progn 
		     (setq _dresl_ resl)
		     (quote (if (selectbody-parallelized (getselectbody bsp))
			 (setq sp (parallelized-plan bsp))))
		     (if (not _dependentfns_)
			 (setq _dependentfns_ (list bsp sp))
		       (setq _dependentfns_ (adjoin bsp _dependentfns_)))
		     (setq sp nil))
		 (if (not _dependentfns_)
		     (progn 
		       (setq nresl (function-resvars sp))
		       (setq len (length (function-resvars sp)))
		       (andify  `( (, _makebag_  , bsp ,@ (function-argvars bsp) BG) 
				   (, _PAP_ , rr_pos ,  (listtoarray (list sp)) BG  , (arg-order bsp (list sp)) , (listtoarray (resl-order (list sp) resl)) , len ,@ nresl ))))
		   (progn
		     (setq sp _dependentfns_)
		     (setq nresl _dresl_)
		     (setq resorder (resl-order sp nresl))
		     (setq len (length _dresl_))
		     (setq _dependentfns_ nil)
		     (setq _dresl_ nil)
		     (andify  `( (, _makebag_  , bsp ,@ (function-argvars bsp) BG) 
				 (, _PAP_ , rr_pos , (listtoarray sp) BG  , (arg-order bsp sp), (listtoarray resorder), len  ,@ nresl )))
		     )))))))


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
    (setq _pos_ pos)
    (if pos		
	(progn 
	  
	  (setf  _no_of_rr_receive_ (1+  _no_of_rr_receive_))
	  (if (eq _no_of_rr_receive_ 1)
	      (progn (setq lookupl nil)
		     (setq addl nil)
		     (setq rnl nil)
		     (setq _dependentfns_ nil)))

	  (setf tr (split-at-first-parfn  pos parfn fn))
	          	      
	  (if tr (setf (selectbody-parallelized sb) tr)
	    (setq tr (selectbody-parallelized sb)))
	  (optimize-pred tr sb)))))
  
(defun parallelized-plan (fn)
  "Return the parallelized portion"
  (let ((sb (getselectbody fn)))
    (create-subplan (selectbody-argl sb)
		    (selectbody-resl sb)
		    (selectbody-parallelized sb))))

(advise-around 'compile_phase2 '(prog1 * (if (not *skip-optimization*)(if _parallelizable_  (parallelize _parfn_ fno)))))










     
