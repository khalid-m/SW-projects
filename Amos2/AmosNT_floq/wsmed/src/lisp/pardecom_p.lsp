(defglobal _parfn_  (theresolvent 'iota))
(defglobal _no_of_rr_receive_  0)
(defglobal _start_pos_  0)
(defglobal _rr_receive_pos_ 0)
(defglobal _no_peers_ 0)
(defglobal _parallelized_ nil)


(defun search-for-fn-pos (fn orgplan)
  " Returns fn position"
  (let ((i 1)) 
    (dolist (x (argsof 'and orgplan))
      (if (and (member fn x) (> i 1))
	  (return i) 
	(setq i (1+ i))))))


(defun find-no-of-parfn (parfn orgplan)
  " Returns number of parallelizable functions in the orgplan"
  (let ((i 0)) 
    (dolist (x (argsof 'and orgplan))
      (if (member parfn x)
	  (setq i (1+ i)) 
	))
    i
    ))

(defun find-peers (rr_pos)
  "pickup the free peers for rr_receive call"
  (let* (peers free_peers )
    
    (if  (eq  rr_pos  _no_of_rr_receive_)
	(progn (setq free_peers (- _no_peers_ _start_pos_))
	       (setq peers (arrange_peer free_peers))
	       
	       )
      (if (eq rr_pos 1)
	  (progn (setq free_peers (/ _no_peers_ 2))
		 (setq peers (arrange_peer free_peers))
		 (setq _start_pos_ (+ _start_pos_ free_peers))
		 )
	(progn (setq free_peers (/ _no_peers_ (* _no_of_rr_receive_ 2)))
	       (setq peers (arrange_peer free_peers))
	       (setq _start_pos_ (+ _start_pos_ free_peers))
	       )))
 
    peers
    ))

(defun arrange_peer (free_peers) 
  "arrange the order of the peers"
  (let ((str(make-array free_peers)))
    (do ((j 0 (+ j 1))) ((eq  j free_peers))
      (seta str j (concat "p" (+ j _start_pos_))))
    str)
  )


(defun partransform-section-subplan (andl from to argl resl)
  "Modyfy TBR conjuction ANDL by replacing section of ANDL between
   positions FROM and TO with invocation of a subplan. "
  (let* (sp  bsp peersl)
    ;; making a TR expression: first with makebag and last with rr_receive
    (if (> from 1)
	(progn (setq bsp (section-subplan andl 2 from  argl resl)) 
	       (setq sp (section-subplan andl (1+ from) to argl resl))
	       (setq peersl (find-peers _rr_receive_pos_))
	       (andify  `( (, _makebag_  , bsp ,@ (function-argvars bsp) BG) 
			   (, _rr-receive_ , _no_peers_ , _no_of_rr_receive_ , _rr_receive_pos_ , _start_pos_ , peersl , sp BG , (length (function-resvars sp)) ,@ (function-resvars sp) )))))
    ))


(defun split-at-first-parfn (firstpos parfn orgfn) 
  ;; parfn - function need to be parallelised in ORGFN
  ;;firstpos - first split position to introduce parallelism
  " Transform the plan at first split point "
  (let* ((sb (getselectbody orgfn))
         (orgplan (selectbody-optpred sb)))
    (partransform-section-subplan orgplan firstpos 
				  (length orgplan) (selectbody-argl sb)
				  (selectbody-resl sb))))

(defun parallelize (parfn fn)
  (let* (sb tr pos )
   
    (setq sb (getselectbody fn))
    (setq pos (search-for-fn-pos parfn (selectbody-optpred sb)))
       
    (if pos		
	(progn (setq _parallelized_ t)
	       (setq  _rr_receive_pos_ (1+ _rr_receive_pos_))
	       (if (eq _rr_receive_pos_ 1)
		   (progn  (setq _no_peers_ (1+ (aref (car (remote-call 'nameserver 'callfunction (mksymbol 'lastpeer)
		   						(vector) 1)) 0)))
			  (setq _no_of_rr_receive_  (find-no-of-parfn parfn (selectbody-optpred sb)))))
                          
		
	       (setq tr (split-at-first-parfn pos parfn fn))
	       (setq _parallelized_ nil)
	       (setf _no_peers_ 0) 
	       (setf _no_of_rr_receive_  0) 
	       (setf _rr_receive_pos_ 0)
	       (setf _start_pos_ 0)
	       (setf (selectbody-parallelized sb) tr)
	       (optimize-pred tr sb)
					
	       ))
    ))

(defun parallelized-plan (fn)
"Return the parallelized portion"
  (let ((sb (getselectbody fn)))
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
    (setf (selectbody-orgpred sb) pred);; This version used by view expansion
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
	   (if (not _parallelized_)
	    (parallelize _parfn_ fno))
	   (cond ((not (expand-views?))
		  (setf (selectbody-delpred sb);;Update template
			(create-delpred (selectbody-optpred sb)))
		  sb))))))

