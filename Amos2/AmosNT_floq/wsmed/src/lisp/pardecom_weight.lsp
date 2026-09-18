(defglobal _parfn_  (theresolvent 'cwo))
(defglobal _no_of_rr_receive_  0)
(defglobal _start_pos_  0)
(defglobal _parallelizable_ nil)
(defglobal _prl_  nil)
(defglobal _nrl_  nil)
(defglobal _no_peers_  0)

(defun search-for-fn-pos (fn orgplan)
  " Returns fn position"
  (let ((i 1))
  
    (dolist (x (argsof 'and orgplan))
        (if (and (member fn x) (> i 1))
	  (if _parallelizable_  (return i)
	    (if (> (no-of-parfn fn orgplan) 1)
		(progn (setq _parallelizable_ 1)(setq i (1+ i)))
	      (return nil)))
	(setq i (1+ i)))
      )))

(defun no-of-parfn (fn orgplan)
  " Returns the number of parallelizable functions"
  (let ((i 0)) 
    (dolist (x (argsof 'and orgplan))
      (if (member fn x)
	  (setq i (1+ i))))
    i))


(defun make-par-resourcelist (fn orgplan)
  (let ((i 0) (prl nil) pra)
    (dolist (x (argsof 'and orgplan))
      (if (member fn x)
	  (progn (if ( > i 0) (setq prl (cons (getvalue (concat (nth 3 x) (nth 4 x) (nth 5 x))) prl)))
		 (setq i (1+ i)))))
    (reverse prl)
    ))

(defun find-nrl (prl nopeers norrr)
  (let ( (sum 0) root peerl i)
    (setq root (newton-raphson norrr (max 1 (/ (* nopeers 1.0) (car prl))) 0.000001 (cons (* nopeers -1) prl)))
    (dolist (x prl)
      (setq i (round (* root x)))
        (if (<= (+ sum i) nopeers)
	  (setq peerl (cons  i peerl))
	(setq peerl (cons (- nopeers sum) peerl)))
      (setq sum (+ sum i)))
(reverse peerl)))
  

(defun newton-raphson ( degree initval approx coffl)
  (let 
      (( x (- initval (/ (* ( findf degree initval coffl) 1.0) (findfd degree initval coffl)))))
    
    ( while (> (abs (- x initval)) approx)
      (setq initval x) 
      (setq x  (- initval (/ (* ( findf degree initval coffl) 1.0) (findfd degree initval coffl))))
      )
    x )     
  )



(defun findf (degree initval coffl )
  (let ((sum 0) (i 0))
    (while ( <= i degree) 
      (setq sum (+ sum (* (nth i coffl)(expt initval i))))
      (setq i (1+ i)))
    sum
    )
  )          
(defun findfd (degree initval coffl )
  (let ((sum 0) (i 0))
    (while ( <= i (1- degree)) 
      (setq sum (+ sum (* (* (nth (1+ i) coffl) (1+ i))(expt initval i))))
      (setq i (1+ i)))
    sum
    )
  ) 

(defun par-resourcel (no_rr no_peers cwol)
  
 (newton-raphson no_rr initval 0.00001 coffl)
)

(defun partransform-section-subplan (no_peers andl from to argl resl)
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
	       (if (eq rr_pos _no_of_rr_receive_) (setq _nrl_ (find-nrl _prl_  _no_peers_  _no_of_rr_receive_)))
			   
	       (andify  `( (, _makebag_  , bsp ,@ (function-argvars bsp) BG) 
			   (, _rr-receive_ , (listtoarray _nrl_) , rr_pos , sp BG , (length (function-resvars sp)) ,@ (function-resvars sp) )))))
    
    ))


(defun split-at-first-parfn (no_peers firstpos parfn orgfn) 
  ;; parfn - function need to be parallelised in ORGFN
  ;;firstpos - first split position to introduce parallelism
  " Transform the plan at first split point "
  (let* ((sb (getselectbody orgfn))
         (orgplan (selectbody-optpred sb)))
    (partransform-section-subplan no_peers orgplan firstpos 
				  (length orgplan) (selectbody-argl sb)
				  (selectbody-resl sb))))

(defun parallelize (parfn fn)
  (let* (sb tr pos )
    
    (setf sb (getselectbody fn))
    (setf pos (search-for-fn-pos parfn (selectbody-optpred sb)))
    
    (if pos		
	(progn (setf  _no_of_rr_receive_ (1+  _no_of_rr_receive_))
	       (if (eq _no_of_rr_receive_ 1)
		   (progn
		     (setq _prl_  (make-par-resourcelist parfn (selectbody-optpred sb)))
		     (setq _no_peers_ (1+ (aref (car (remote-call 'nameserver 'callfunction (mksymbol 'lastpeer)
								  (vector) 1)) 0)))
		     ))
	       (setf tr (split-at-first-parfn _no_peers_ pos parfn fn))
	       (setf (selectbody-parallelized sb) tr)
	       (optimize-pred tr sb)
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
    (if _use_dnf_ (setq pred (transformpredicate pred)))
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


