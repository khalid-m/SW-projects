(defstruct bstat fnvec rcol);;fnvec- array to record whether each coroutine received result rcol- coroutine list executing same argument value.
(defglobal _PAP_
  (osql "create function pap(Integer level, Vector vfn, bag args, Vector argorder, Vector resorder, Integer width)
                                 -> Object  as foreign 'pap';"))

(set-resulttypesfn _PAP_ (function pap-resulttypes))

(defun pap-resulttypes (fno args)
   (and (numberp (sixth args))(buildn (sixth args) _object_)))

(quote (fanout (nth (1- level) _fanout_)))
(quote (fanout (get-fanout level)))

(defun pap (fno level vfn args argorder resorder width res)
  (let* ( currentco (fanout (get-fanout level)) (col (list ))  exet (mc 0) opt  
		    (bagcount 0)(lastlevel (caar _fanoutl_)) (fnum -1) bvec c_bagcount
		    (fnvec (listtoarray (make-restuple (length vfn))));;array to maintain the whether result value is received for functions in vfn
		    (bag_stat (make-hash-table :TEST (FUNCTION EQUAL)));; to keep results acheived state each row of args
		    (finished_co (make-hash-table :TEST (FUNCTION EQUAL)));; to keep completed courotines for a given bag number (input tuple)
		    (covec (make-array (length vfn)));; array to maintain completed coroutines
		    corecl (pertuple 0)(prepertuple 0)(threshold 0.2)(relerr 0) (tuplecount 0) (ack 0)(exetime 0))
    
    (mapbag args
	    (f/l (row)
		 (setq bagcount (1+ bagcount))
		 (setq covec (make-array (length vfn)))
		 
		 (setf (gethash bagcount finished_co) covec)
		 (setq corecl nil)
		 (setq fnum -1)
	         (while (<  fnum (1- (length vfn)))
		   
		   (setq fnum (1+ fnum));; selection of function from vfn
		  
		   (setq col (cons (coroutine 'mapfunction (list (aref vfn fnum) (construct-inputarg (listtoarray row) (aref argorder fnum))  'co-yield)) col))
		   (if _regresstest_ (set-co-stat-wstime (first col) "testfun" 1));;for regression test 

		   (set-fn-stat-fnum (first col) fnum bagcount)
		   (setq covec (gethash bagcount finished_co))
		   (seta covec fnum (first col))
		   
		   
		   (setf (gethash bagcount finished_co) covec);;insert the coroutine
		    	
		   (setq corecl (cons (first col) corecl))
		   	
		   (setf (gethash bagcount bag_stat )(make-bstat :fnvec fnvec :rcol corecl))
		   (while (= (length col) fanout);; check fanout number of coroutines are ready for execution
		     (if (> mc 0) (co-sleep 0.01));;sleep to avoid continuous polling
		     (setq mc (1+ mc))
                     		   
		     (dolist (co col)
		       (cond ((not (co-terminated co))
			      (let ((res (catch 'msg-catch (co-resume co))))
				(cond ((= res -2) (cond ((> level 1)(throw 'msg-catch -2)) (t (error "Message Send Failed Due to Timeout of Web Service" co))))
				      ((consp res) 
				       
				       (setq tuplecount (1+ tuplecount))
				       (if (= level lastlevel);; record cwotime per level with tuple count for coroutines at leaf level
					   (set-co-stat-tuplecount co 1))
				       (setq c_bagcount (get-fn-stat-bagcount co))
				       (setq bvec (bstat-fnvec (gethash c_bagcount bag_stat)))	
				      
				       (if (check-result (arraytolist bvec))
					   (progn
					     (seta bvec (get-fn-stat-fnum co) 1)
					     (setf (gethash c_bagcount bag_stat) (make-bstat :fnvec bvec :rcol (bstat-rcol (gethash c_bagcount bag_stat))))))
				       (set-fn-stat-restuple co res)
				      
				     
				       (if (not (check-result (arraytolist bvec)));; to check all results are received for given row of an args
					   (construct-results level vfn args  width argorder resorder (bstat-rcol (gethash c_bagcount bag_stat)) co))
				      
				       ))))
			     (t 
			      (setq ack (1+ ack))
			      (setq exetime (+ exetime (get-co-stat-wstime co)));;get execution time for a cwo
			      (setq c_bagcount (get-fn-stat-bagcount co))
			      (setq covec (gethash c_bagcount finished_co))
			      (seta covec (get-fn-stat-fnum co) 1)
			      (setf (gethash c_bagcount finished_co) covec);;mark the finished coroutine

			      (if (check-finished-coroutines covec (length vfn))
				  (clean-fn-stat (bstat-rcol (gethash c_bagcount bag_stat))));; remove the result tuples for finished coroutines
			      
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
					    (quote (setq fanout (+ fanout _hop_)))
					    (setq fanout (+ fanout (get-hop level)))
					    (quote (update-hop level 3));; update the hop 
					    (update-fanout level fanout))
					   ((>= threshold relerr)(setq opt 1))
					   ))
				    (( and (= ack fanout) (= tuplecount 0))
				     (setq exetime 0);;start a new monitoring cycle
				     (setq ack 0))
				    )
			      (setq col (remove co col));;removing the completd coroutine
			      (setq mc 0)
			      (return t))))))
		
		 ))
    
    (if (co-inside) 
	(set-co-stat-tuplecount (co-inside) bagcount));; record cwotime per level with tuple count for caller coroutine 
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
			 (setq c_bagcount (get-fn-stat-bagcount co))
			 (setq bvec (bstat-fnvec (gethash c_bagcount bag_stat)))			      
			 (if (check-result (arraytolist bvec))
			     (progn
			       (seta bvec (get-fn-stat-fnum co) 1)
			       (setf (gethash c_bagcount bag_stat) (make-bstat :fnvec bvec :rcol (bstat-rcol (gethash c_bagcount bag_stat))))))
			 
			 (set-fn-stat-restuple co res)
			 			
			 (if (not (check-result (arraytolist bvec)));; to check all results are received for given row of an args 
			     (construct-results level vfn args  width argorder resorder (bstat-rcol (gethash c_bagcount bag_stat)) co))
			 ))))
	       (t
		(setq c_bagcount (get-fn-stat-bagcount co))
		(setq covec (gethash c_bagcount finished_co))
		(seta covec (get-fn-stat-fnum co) 1)
		(setf (gethash c_bagcount finished_co) covec);;mark the finished coroutine
		(if (check-finished-coroutines covec (length vfn))
		    (clean-fn-stat (bstat-rcol (gethash c_bagcount bag_stat))));; remove the result tuples for finished coroutines

		(setq exet (get-cwotime-per-operator co))
		(setq col (remove co col))
		(setq mc 0)
		(return t)))))	 
    ))
   


			
(defun findpos (l f)
  (let ((pos 0))
    (dolist (e l)
      (if  (= e f) (return pos)(setq pos (1+ pos))))))

(defglobal _result_ nil)

(defun construct-inputarg (row argordl)
  (let (inputl)
    (if (not (natom argordl)) (setq argordl (arraytolist argordl)))
  
    (dolist (x argordl)
      (if inputl (setq inputl (cons (aref row (1- x)) inputl))
	(setq inputl (list (aref row (1- x))))))
    (reverse inputl)))

(defun construct-results( level vfn args  width argorder resorder col co)
  "Construct result from difgerent sub results" 
  (let (fnum restuple retl templ first newl )
    
    (setq _result_ nil)
    (dolist (x col)
      (setq fnum (get-fn-stat-fnum x))
      (setq restuple (get-fn-stat-restuple x))
      (if (= co x)
	  (setq restuple (list (car restuple))))
      (setq templ retl)
      (dolist (z restuple)
	(if retl 
	    (progn 
	      
	      (dolist (a templ)
		(setq retl (aux-construct-results  level vfn args  width a retl argorder resorder fnum z )))
	      
	      (if (not _result_ ) 
		  (if (and first (eq z (car (last restuple))))
		      (progn(setq templ retl)
			    (setq first nil))
		    (if (not (eq z (car (last restuple))))
			(setq retl (union templ retl))))))
	  (progn
	    (setq first 1)
	    (setq retl (aux-construct-results level vfn args  width (make-restuple (length resorder)) retl argorder resorder fnum z))
	    (setq retl (cons (make-restuple (length resorder)) retl))
	    (setq templ (list (car retl)))
	    ))))
       
    t))



(defun aux-construct-results ( level vfn args  width a retl argorder resorder fnum restuple)
  (let ((tempa a)  (ypos 0) (tempretl retl) (count 0)) 
    (setq tempretl retl)
    
    (dolist (y (arraytolist resorder))
     
      (if (not (natom y)) (setq y (arraytolist y)));; for regression test

      (if (and (= (1+ fnum) (first y)) (check-member ypos a))
	  (progn (setq count (1+ count))
		 (setq a (subst (nth (1- (second y)) restuple) (list (concat ypos '*)) a))
		 
		 (if (not (check-result a))(progn 
					     (apply (function osql-result)(list*  level vfn args argorder resorder width a))
					     (setq _result_ 1)
					     (setq retl tempretl)
					     (return retl))
		   (progn 
		     (if (not retl)(setq retl (list a))
		       (setq retl (subst a tempa  retl)))
		     (setq tempa a)))))
      (setq ypos (1+ ypos))
      (if (= count (length restuple)) (return retl)))
    retl))

(defun make-restuple(len)
  "make restuple with given length"
  (let (restuple)
    (dotimes (i len)
      (setq restuple (cons (list (concat i '*)) restuple)))
    (reverse restuple)))

(defun check-member (fnum al)
  "Check the list contains given function number"
  (member (list (concat fnum '*)) al))



(defun check-result(resl)
"Check whether all the elements of result having values"
  (intersection (make-restuple (length resl)) resl))

(defun check-finished-coroutines(resarr len)
  "Check whether all coroutines completed for an inputtuple"
 (= resarr (listtoarray (buildn len 1))))
   

(defun print-hashtable(ht)
  "Get all webservice time called sofar"
   (maphash   (f/l (key val) (formatl t key  " >>>>> "  val  t)) ht))

(defglobal _hophash_ (make-hash-table :TEST (FUNCTION EQUAL)))

(defun update-hop(level val)
  (let* ((hop (gethash level _hophash_)))
  (setf (gethash level _hophash_) (+ hop val))))

(defun get-hop(level)
  (gethash level _hophash_))
   
(defun set-hop(level val)
  (setf (gethash level _hophash_) val)) 
    

		     

    


 