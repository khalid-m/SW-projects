
(defglobal _ff-applyp_
 (osql "create function ff_applyp(integer level,  function fn, bag args, Integer width)
                                 -> object as foreign 'ff-applyp';"))

(set-resulttypesfn _ff-applyp_ (function ff-applyp-resulttypes))



(defun ff-applyp-resulttypes (fno args)
   (and (numberp (fourth args))(buildn (fourth args) _object_)))

(defun ff-applyp (fno level fn args width res)
  (let ( currentco (col (list )) (fanout (nth (1- level) _fanout_)) exet (mc 0) (bagcount 0)(lastlevel (caar _fanoutl_)) )
     
   
    (mapbag args
	    (f/l (row)
		 (setq bagcount (1+ bagcount))
		
		 (setq col (cons (coroutine 'mapfunction (list fn row 'co-yield)) col))
		 
 
		 (while (= (length col) fanout);; check fanout number of coroutines are ready for execution
		   (if (> mc 0) (co-sleep 0.01));;sleep to avoid continuous polling
		   (setq mc (1+ mc))
		   
		   (dolist (co col)
		         (cond ((not (co-terminated co))
			    (let ((res (co-resume co)))
			      (if (consp res) 
				  (progn 
				    (if (= level lastlevel);; record cwotime per level with tuple count for coroutines at leaf level
					(set-co-stat-tuplecount co 1))
					
				    (apply (function osql-result)(list*  level fn args width res)))
				)))
			   (t 
			    (quote (setq exet (get-cwotime-per-operator co)))
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
	(cond  ((not (co-terminated co))
		(let ((res (co-resume co)))
		  (if (consp res)
		      (progn 
			(if (= level lastlevel);; record cwotime per level with tuple count for coroutines at leaf level
			    (set-co-stat-tuplecount co 1))
			(apply (function osql-result)(list*  level fn args width res)))
		    )))
	       (t
		(setq exet (get-cwotime-per-operator co))
		(setq col (remove co col))
		(setq mc 0)
		(return t)))))	 
    ))
   
			
(defun findpos (l f)
  (let ((pos 0))
    (dolist (e l)
      (if  (= e f) (return pos)(setq pos (1+ pos))))))

    
    

