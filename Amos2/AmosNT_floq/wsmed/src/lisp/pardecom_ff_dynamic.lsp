(defglobal _parfn_  (theresolvent 'cwo))
(defglobal _no_of_rr_receive_  0)
(defglobal _start_pos_  0)
(defglobal _parallelizable_ nil)
(defglobal _hop_ 2);; expansion of fanout
(defglobal _fanoutl_ (list ));;stores the fanout per level

(defun search-for-fn-pos (fn orgplan)
  "Returns fn position"
  (let ((i 1) par)
    (dolist (x (argsof 'and orgplan))
         (if (and (member fn x)(> i 1))
	  (if  (and (or _parallelizable_ (= _no_of_rr_receive_ 0))(> (no-of-parfn fn orgplan) 1)(not (= (seventh x) (vector))))
	      (progn  (setq _fanoutl_ (cons (list (1+ _no_of_rr_receive_) 2 (sixth x)) _fanoutl_))(setq par 1)(return i) ))
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



(defun partransform-section-subplan (andl from to argl resl)
  "Modyfy TBR conjuction ANDL by replacing section of ANDL between
   positions FROM and TO with invocation of a subplan. "
  (let* (sp  bsp rr_pos str)
     
    ;; making a TR expression: first with makebag and last with rr_receive
    (if (> from 1)
	(progn (setq  rr_pos _no_of_rr_receive_)
	       (setq _parallelizable_ nil)
	       
	       (setq bsp (section-subplan andl 2 from  argl resl)) 
	       (setq _parallelizable_ 1)
	       (setq sp (section-subplan andl (1+ from) to argl resl))
	       (if (selectbody-parallelized (getselectbody sp))
		   (setq sp (parallelized-plan sp)))
	       (if (eq rr_pos 1)
		   (progn (setq  _no_of_rr_receive_ 0)
			  (setq  _parallelizable_ nil)
			  ))
	       (andify  `( (, _makebag_  , bsp ,@ (function-argvars bsp) BG) 
			   (, _aff-applyp_ , sp BG , (length (function-resvars sp)) ,@ (function-resvars sp) )))))
    
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
    
    
    (setf pos (search-for-fn-pos parfn (selectbody-optpred sb)))
    
    (if pos		
	(progn (setf  _no_of_rr_receive_ (1+  _no_of_rr_receive_))
	       
	       (if (eq _no_of_rr_receive_ 1)
		   (progn (setq lookupl nil)
			  (setq addl nil)
			  (setq rnl nil)
			  (setq _fanoutl_ nil)))
	       (setf tr (split-at-first-parfn  pos parfn fn))
	       (setf (selectbody-parallelized sb) tr)
	       (optimize-pred tr sb)
					;(print (selectbody-parallelized sb))
	       )
      )
    )
  )

(defun parallelized-plan (fn)
"Return the parallelized portion"
  (let ((sb (getselectbody fn)))
    ;(print (selectbody-resl sb))
    (create-subplan (selectbody-argl sb)
		    (selectbody-resl sb)
		    (selectbody-parallelized sb))))



(advise-around 'compile_phase2 '(prog1 * (if (not *skip-optimization*) (if (eq _amosid_ 'me)
		  (parallelize _parfn_ fno)))))



(quote
(defun compile_phase2 (pred resl argl quantl fno sb)
  "Query simplification, view expansion, normalization, optimization"
  (let* (*coerced_input* 
	 *extendedResult* *extendedVars*
	 (bndl (append argl resl (union quantl *locals*)))
	 )
    (setq pred (andify (compilepredicate pred fno)))
    (if _save-intermediates_ (setf (selectbody-unoptimized sb) pred))

    (setq pred (rewrite pred sb))
    (setf (selectbody-orgpred sb) pred)	;This version used by view expansion
    (update-locals sb quantl)
    (update-locals sb *locals*)

    (setq pred (expand-predicate pred nil))
    (if _save-intermediates_ (setf (selectbody-expanded sb) pred))

    (setq pred (rewrite pred sb))
    (if _save-intermediates_ (setf (selectbody-expanded-simplified sb) pred))

    ;; Normalize to DNF
    (if *use-dnf* (setq pred (transformpredicate pred)))
    (if _save-intermediates_ (setf (selectbody-normalized sb) pred))

    (setq pred (rewrite pred sb))
    (setf (selectbody-pred sb) (if pred (copy-tree pred) 'TRUE))
    (update-locals sb *locals*)
    (cond (*skip-optimization* nil)
	  (t      
	   ;;To expand the templates of the input variables
	   ;;These are not expanded because 
	   ;;   they should be so in selectbody-pred
	   (setq pred (process_typechecks pred sb argl resl nil))
	   
	   (optimize-pred pred sb fno);; Coercion and cost-based optimization
	   
           (update-locals sb *locals*) 
	   	  
	   ;;(print (selectbody-orgpred sb))
	   ;;(break parallelize)
	   
	    (if (eq _amosid_ 'me)
		  (parallelize _parfn_ fno))
	   	   
	   (cond ((not (expand-views?))
		  (setf (selectbody-delpred sb);;Update template
			(create-delpred (selectbody-optpred sb)))
		  sb))))))

)




      