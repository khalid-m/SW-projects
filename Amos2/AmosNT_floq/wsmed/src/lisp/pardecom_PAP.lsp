(defglobal _parfn_  (theresolvent 'cwo))
(defglobal _no_of_rr_receive_  0)
(defglobal _start_pos_  0)
(defglobal _parallelizable_ 1)
(defglobal _dependentfns_ 1)
(defglobal _dresl_ nil)
(defglobal _cwo-oidl_ nil)
(defglobal _pos_ nil) ;; split point
(defglobal _indefnl_ nil)
(defglobal _visited_ nil)


(quote
(defun replace-bsp-pred(andl argl chgl)
  "Renaming the pass-through arg"
(let 
    (dolist (x chgl)
      (dolist y argl )))))

(defun arguments-TR (tr)
"find arguments for TR expression"
  (let ((argl (free-variables tr nil)) resl nresl)
        
    (dolist (y tr)
      (if (or (equal '#[OID 56 "VECTOR"] (first y)) (equal '#[OID 25 "OBJECT.OBJECT.=->BOOLEAN"]  (first y)))
	  (setq nresl (cons (second y) nresl))
	(setq nresl (cons (car (last y)) nresl))))
    
    (set-difference argl nresl)))

(defun arg-TR (tr)
  "find arguments for TR expression"
  (let ((argl (free-variables tr nil)) resl nresl)
    (dolist (y tr)
      (dolist (x (cdr y))
	(if (string-like (mkstring x) "_V*")
	    (setq nresl (cons x nresl)))))
    
    (set-difference nresl argl)))



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
	  (if  (and (or _parallelizable_ (= _no_of_rr_receive_ 0))(not(member  (concat (fourth x)(fifth x)(sixth x)) _cwo-oidl_))(> (no-of-parfn fn orgplan) 1)(not (= (seventh x) (vector))))
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
		      (setq _cwo-oidl_ (cons (concat (fourth x)(fifth x)(sixth x)) _cwo-oidl_));; to avoid to consider the same web service again
		      (return i) )))
      	  (setq i (1+ i)))
    
    (if par i nil)
    ))	    


(defun aux-search-for-fn-pos (fn orgplan)
  "Returns fn position"
  (let ((i 1) par)
    ;;(if (eq _no_of_rr_receive_ 0)(setq _fanoutl_ nil))
    (dolist (x orgplan)
      (if (and (member fn x)(> i 0))
	  (if  (and (or _parallelizable_ (= _no_of_rr_receive_ 0))(not(member  (concat (fourth x)(fifth x)(sixth x)) _cwo-oidl_))(> (no-of-parfn fn (andify orgplan)) 0)(not (= (seventh x) (vector))))
	      (progn  (cond ((= _no_of_rr_receive_ 0) 
                             (setq _parallelizable_ 1)
			     (setq _coid_ 0)
			     (clrhash _co_stat_);; clear the hash table for coroutines
			     (setq _fanoutl_ (list )) 
			     (setq _cwocount_ 0)
			     (setq _wscall_per_tree_ (list ))
			     (setq _wscall_per_level_ (list ))))
		      
		      (setq _fanoutl_ (cons (list (1+ _no_of_rr_receive_) (list 2) (fourth x)) _fanoutl_));; initialize fanout detail per level
		      (set-hop (1+ _no_of_rr_receive_) 2)
		      (setq _wscall_per_level_ (cons (list (1+ _no_of_rr_receive_)) _wscall_per_level_));;initialize profile for wscall per level
		      (setq par 1)
		      (setq _cwo-oidl_ (cons (concat (second x)(third x)(fourth x)) _cwo-oidl_));; to avoid to consider the same web service again
		      (return i) )))
      (setq i (1+ i)))
    
    t
    ))	    


(defun find-first-cwo-pos (tr)
  "Returns first cwo position in TR"
  (let ((i 1))
    (dolist (x tr)
      (cond ((member (theresolvent 'cwo) x)
	     (return i))
	    ( t (setq i (1+ i)))))
    i))	

(defun find-next-cwo-pos (pos orgplan)
  "Returns next cwo position in orgplan"
  (let ((i 1) )
    (if (eq (car orgplan) 'and)
	(setq orgplan (argsof 'and orgplan)))
    (dolist (x orgplan)
      (cond ((and (member (theresolvent 'cwo) x)(> i pos))
	     (setq _cwo-oidl_ (cons (concat (second x)(third x)(fourth x)) _cwo-oidl_));; to avoid to consider the same web service again
	     (return i))
	    (t (setq i (1+ i)))))
    i))	      


(defun no-of-parfn (fn orgplan)
  "Returns the number of parallelizable functions"
  (let ((i 0)) 
    (dolist (x (argsof 'and orgplan))
      (if (member fn x)
	  (setq i (1+ i))))
    i))

(defun no-of-parallelizable-cwo (orgplan)
  "Returns the number of parallelizable functions"
  (let ((i 0)) 
    (dolist (x orgplan)
      (if (and (member _parfn_ x)(not (= (fifth x) (vector))))
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



(defun auxdependent-check (tr argl pos)
  "Find the dependency between predicates."
  (let* ( (first (firstn pos tr))
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






(defun rearrange-pred(tr argl pos)
  "reorder the predicates in TR to comply with dependency order of cwo calls"
  (let* ((npos (find-next-cwo-pos pos tr))
	 (andl (firstn npos tr))
	 (last  (nthcdr npos  tr))
	 (dependent (auxdependent-check andl argl pos))
	 ( newl (cdr (firstn pos tr))))
   
    (cond ((and (not dependent) (> npos 1))
	   (union (reverse (set-difference andl newl)) (union  (reverse newl) last)))
	  )))
     
(defun group-plans(tr pos)
  "Group the dependent plan functions"
  (let* (gpl  atr (newtr (argsof 'and tr)) first newtr1 npos npos1 npos2 next dependent sgpl templ)
    	
    (while (> pos 0)
      (setq npos pos)
      (setq sgpl (list (firstn (1- npos) newtr)))
      (setq npos (find-next-cwo-pos pos newtr))
            
      (setq templ sgpl)
      (setq npos1 pos)
      
      (setq first (firstn (1- pos) newtr))
      (while (> npos npos1)
       	(setq next  (set-difference (nthcdr (1- npos1) newtr) (nthcdr (1- npos) newtr)))
	(setq newtr1 (union (reverse first) next))
	(setq dependent (dependent-check newtr1 (arg-TR newtr1) (1- pos)))
		     
	(if dependent
	    (setq sgpl (cons next sgpl)))
	(setq npos1 npos)
	(setq npos (find-next-cwo-pos npos newtr))		     
	)
      (setq newtr (nthcdr (1- pos) newtr))
      (if (not (eq templ sgpl))
	  (if gpl 
	      (setq gpl (cons (reverse sgpl) gpl))
	    (setq gpl (list (reverse sgpl)))))
      (cond ((> (no-of-parallelizable-cwo newtr) 1)
	     (setq pos (find-next-cwo-pos 1 newtr)))
	    (t (setq pos 0))))
    (reverse gpl)
    )) 
 

(defun parallel-subplans (dpl)
  "make independent plan functions"
  (let  ( (firstl (car dpl)) gpl sl tz mem)
    (dolist (x (cdar dpl))
      (setq mem nil)
      (setq tz nil)
      (dolist (a (cdr dpl))
	(cond ((member x a) 
	       (setq mem 1)
	       (dolist (z a)
		 (if tz
		     (setq tz (union (reverse tz) z))
		   (setq tz z)))
	       
	       (cond (gpl (setq gpl (cons tz gpl)))
		     (t   (setq gpl (list tz)))) 
	       (return t))
	      ))
      (if (not mem)(cond (gpl (setq gpl (cons x gpl)))
			 (t   (setq gpl (list x))))))
    gpl
    ))


	    

(defun partransform-section-subplan (andl from to argl resl)
  "Modyfy TBR conjuction ANDL by replacing section of ANDL between
   positions FROM and TO with invocation of a subplan. "
  (let (sp  bsp rr_pos str nresl len resorder inde newandl tfrom toid dpl ipl nindl templ tbgresl temp_rr_pos temp_lookupl )
    ;; making a TR expression: first with makebag and last with FF_APPLYP or MFF_APPLYP
    (if (> from 1)
	(progn (setq  rr_pos _no_of_rr_receive_)
	       (setq ipl nil)
	       (quote (cond  ((eq rr_pos 1) )))
	       (setq toid _cwo-oidl_)
	       (setq tfrom (find-next-cwo-pos from andl))
	       (setq dpl (group-plans (predify-tbr andl) tfrom));; create the dependent list of plan functions 
	       ;;(pps dpl)
	       (setq _cwo-oidl_ toid)
	       (setq ipl (parallel-subplans dpl))
		       
	       (setq _parallelizable_ nil)
	       (cond ( _visited_ 
		       (setq bsp (section-subplan andl 2 from  argl resl nil))
		       (setq _parallelizable_ 1)
		       (setq _visited_ nil)
		       
		       (setq resorder (resl-order _indefnl_ resl))
		       (setq len (length resl))
		       (setq templ _indefnl_)
		       (setq _indefnl_ nil)
		       
		       (andify  `( (, _makebag_  , bsp ,@ (function-argvars bsp) BG) 
				   (, _PAP_ , rr_pos , (listtoarray templ) BG  , (arg-order bsp templ), (listtoarray resorder), len  ,@ resl ))))
		     ((> (length ipl) 1);; independent groups
		      (setq bsp (section-subplan andl 2 from  argl resl 0))
		      
		      (setq tbgresl bgresl)
		      (setq templ nil)
		      (setq _lastplan_ nil)
		       (setq toid _cwo-oidl_)
		       (setq temp_lookupl lookupl)
		      (dolist (x ipl)
			(setq _parallelizable_ 1)
			(setq bgresl nil);; clear the previous values in subplan.lsp
			(aux-search-for-fn-pos _parfn_ x);; set the fanout and level for a cwo call
			(setq _no_of_rr_receive_ (1+ _no_of_rr_receive_))
			(if (not templ) (setq templ  (intersection resl (free-variables x)))
			  (setq templ (union (intersection resl (free-variables x)) templ)))
					
			(if (equal (list x) (last ipl))
			    (progn (setq _lastplan_ t)
			    (setq sp (section-subplan (andify x)  2 (+ (length x) 1) (arg-TR x)  (union (intersection resl (free-variables x)) (set-difference resl templ)) 1)))
			  (setq sp (section-subplan (andify x) 2 (+ (length x) 1) (arg-TR x)  (intersection resl (free-variables x)) 1)))
			(setq _no_of_rr_receive_ rr_pos)
			
			(if (not _indefnl_)
			    (setq _indefnl_ (list sp))
			  (setq _indefnl_ (adjoin sp _indefnl_))))
		      (setq templ nil)
		      (setq _visited_ 1)
		      (setq bgresl tbgresl);; reset the bgresl to the previous values in subplan.lsp
		      
		      (setq _cwo-oidl_ toid)
		      (setq lookupl temp_lookupl);; revert to old lookupl
		      (setq sp (section-subplan andl (1+ from) to argl resl 0))
		      
		      (setq len (length resl))
		      (if (eq rr_pos 1)
			  (progn (setq  _no_of_rr_receive_ 0)
				 (setq  _parallelizable_ 1)))
		      (andify  `( (, _makebag_  , bsp ,@ (function-argvars bsp) BG) 
				  (, _PAP_ , rr_pos ,  (listtoarray (list sp)) BG  , (arg-order bsp (list sp)) , (listtoarray (resl-order (list sp) resl)) , len ,@ resl ))))
		     (t
		      (cond ((not (dependent-check andl argl from));; to check the independent plans
			     (setq inde 1)
		     
			     (rearrange-fanoutl (sixth (nth _pos_ andl))) 
			     ))
			    
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
			    )))))))))


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
    (if (eq _no_of_rr_receive_ 0);;initialise _cwo-oidl_
	(setq _cwo-oidl_ (list )))
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










     
