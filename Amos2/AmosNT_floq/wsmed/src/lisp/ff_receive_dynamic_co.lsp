

(defglobal _aff-applyp_
  (osql "create function aff_applyp(Integer level, function fn, bag args, Integer width)
                                 -> object  as foreign 'aff-applyp';"))

(set-resulttypesfn _aff-applyp_ (function aff-applyp-resulttypes))



(defun aff-applyp-resulttypes (fno args)
   (and (numberp (fifth args))(buildn (fifth args) _object_)))

(quote (fanout (nth (1- level) _fanout_)))
(quote (fanout (get-fanout level)))

(defun aff-applyp (fno level fn args width res)
  (let ((col (list )) (fanout (get-fanout level)) (tuplecount 0) (mc 0)(bagcount 0)(ack 0) (exetime 0)(pertuple 0)(prepertuple 0)(threshold 0.2)(relerr 0) (lastlevel (caar _fanoutl_)) opt)
        
    (mapbag args
	    (f/l (row) 
		
		 (setq col (cons (coroutine 'mapfunction (list fn row 'co-yield)) col))
		  (setq bagcount (1+ bagcount))
		 
		 (while (= (length col) fanout);; check fanout number of coroutines are ready for execution
		    (if (> mc 0) (co-sleep 0.01));;sleep to avoid continuous polling
		    (setq mc (1+ mc))
		   (dolist (co col)
		     (setq _currentco_ co)
		     (cond ((not (co-terminated co))
			    (let ((res (catch 'msg-catch (co-resume co))))
                              
			      (cond ((= res -2) (cond ((> level 1)(throw 'msg-catch -2)) (t (error "Message Send Failed Due to Timeout of Web Service" co))))
				    ((consp res)  
				     (setq tuplecount (1+ tuplecount))
				     (if (= level lastlevel);; record cwotime per level with tuple count for coroutines at leaf level
					 (set-co-stat-tuplecount co 1))
				     
				     (apply (function osql-result)(list* level fn args width res))))))
			   (t 
			    (setq ack (1+ ack))
			    (setq exetime (+ exetime (get-co-stat-wstime co)));;get execution time for a cwo
			    (cond (( and (= ack fanout) (> tuplecount 0));; calculate the pertuple time
				   
				   (setq prepertuple pertuple)
				  (quote (print (concat level " " tuplecount " " (/ exetime fanout))))
				   (setq pertuple (/ (* exetime 1.0) tuplecount));; calculate per tuple time
				   (setq exetime 0);;start a new monitoring cycle
				   (setq tuplecount 0)
				   (setq ack 0)
				   
				   (if (> prepertuple 0) 
				       (setq relerr (/ (- prepertuple  pertuple) (* prepertuple 1.0))));; calculate relative error
				   
				   (cond ((and (or (= prepertuple 0)(< threshold relerr))(not opt));; increase the fanout by hop
					  (setq fanout (+ fanout _hop_))
					  (update-fanout level fanout))
					 ((>= threshold relerr)(setq opt 1))
					 ))
				  (( and (= ack fanout) (= tuplecount 0))
				   (setq exetime 0);;start a new monitoring cycle
				   (setq ack 0))
				  )
			    (setq col (remove co col));;removing the completd coroutine
			   (setq mc 0)
			    (return t)))))))
		 		   
		
    (if (co-inside)
	(set-co-stat-tuplecount (co-inside) bagcount);; record cwotime per level with tuple count for caller coroutine 
      )

    (while (> (length col) 0);; receiving results from remaining coroutines
      (if (> mc 0) (co-sleep 0.01));;sleep to avoid continuous polling
      (setq mc (1+ mc))
      (dolist (co col)
	(setq _currentco_ co)
	(cond  ((not (co-terminated co))
		(let ((res (catch 'mag-catch (co-resume co))))
                   (cond ((= res -2) (cond ((> level 1)(throw 'msg-catch -2)) (t (error "Message Send Failed Due to Timeout of Web Service" co))))
			((consp res)  
			 (if (= level lastlevel);; record cwotime per level with tuple count for coroutines at leaf level
			     (set-co-stat-tuplecount co 1))	 
			 (apply (function osql-result)(list* level fn args width res))))))
	       (t
		(setq exetime (get-cwotime-per-operator co))
		(setq col (remove co col))
		(setq mc 0)
		(return t)))))	  
    
    ))
   
			



  
   
