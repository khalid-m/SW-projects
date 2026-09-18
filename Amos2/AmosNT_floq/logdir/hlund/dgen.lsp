(defun slotname (slot)
  (assert (or (symbolp slot) (consp slot)))
  (if (symbolp slot)
      slot
      (car slot)))

(defmacro ml:defstruct (name short-name &rest slots)
  (let ((names (mapcar #'(lambda (slot)
			   (pack name '- (slotname slot)))
		       slots))
	(short-names (mapcar #'(lambda (slot)
				 (pack short-name '- (slotname slot)))
			     slots)))
    `(progn
       (defstruct ,name ,@slots)
       ,@(mapcar #'(lambda (n sn)
		     (list 'movd (kwote n) (kwote sn)))
		 names
		 short-names)
       ,@(mapcar #'(lambda (n sn)
		     (list 'put (kwote sn) ''setfmethod 
			   (list 'get 
				 (kwote n) ''setfmethod)))
		 names
		 short-names))))

(ml:defstruct sim-variable sv
 name time dtime freq valfn)

(defun rrandom ()
  (/ (random 100000) 100000.0))

(defun create-sim-datafile (filename seq time dtime uptime ftime vars)
  (with-open-file (str filename :direction :output)
    (formatl str "H,FileVers,1" t)
    (formatl str "H,ID,E01PB30-3190" t)
    (formatl str "H,FileSequence," seq t)
    (formatl str "H,SpiderSwVers,5.0.0 2011-06-20" t)
    (formatl str "H,SpiderParamVers,5" t)
    (formatl str "H,SpiderSysStart,24" t)
    (formatl str "H,SpiderTime," time t)
    (formatl str "H,SpiderTimeZone,+1" t)
    (formatl str "H,SpiderUpTime," uptime t)
    (formatl str "H,LIU1SwVers,-" t)
    (formatl str "H,LIU2SwVers,-" t)
    (formatl str "H,SpiderLinkVers,1.0.3" t)
    (formatl str "H,SpiderLinkUpTime," t)
    (formatl str "H,DriftTimeP1," dtime t)
    (formatl str "H,DriftTimeP2," dtime t)
    (formatl str "H,DriftTimeP3," dtime t)
    (formatl str "H,DriftTimeP4," dtime t)
    (formatl str "H,LogStartTime," time t)
    (formatl str "A,A1_023" t)
    (formatl str "S,FileTime," ftime t)
    (formatl str "S,UploadTime,3600" t)
    (dolist (v vars)
      (setf (sv-time v) 0.0)
      (formatl str "S," (sv-name v) "," (sv-dtime v) t))
    (dotimes (i ftime)
      (dolist (v vars)
	(dotimes (j (round (/ 1 (sv-dtime v))))
	  (when (< (rrandom) (sv-freq v))
	    (formatl str "L," (sv-name v) "," (roundto (sv-time v) 1) "," 
		     (funcall (sv-valfn v)) t))
	  (incf (sv-time v) (sv-dtime v)))))))

(defun sawfn (min max)
  (let ((i min) (j 1))
    #'(lambda ()
	(incf i j)
	(when (or (< i min) (> i max))
	  (setf j (- j))
	  (incf i (* j 2)))
	i)))

(defun on-or-off-fn (start-time repeat-on repeat-off)
  (let ((on-count (1+ repeat-on))
	(off-count repeat-off)
	(on t))
    #'(lambda ()
	(if (plusp start-time) 
	    (progn (decf start-time) 0)
	    (cond (on (decf on-count)
		      (if (plusp on-count)
			  1
			  (prog1 0
			    (setf on-count repeat-on)
			    (setf on nil))))
		  (t (decf off-count)
		     (if (plusp off-count)
			 0
			 (prog1 1
			   (setf off-count repeat-off)
			   (setf on t)))))))))

(defun timeval-string (tv)
  (let ((date (timeval-to-date tv)))
    (concat (aref date 0) "-" 
	    (add-zero (aref date 1)) "-" 
	    (add-zero (aref date 2)) " " 
	    (add-zero (aref date 3)) ":" 
	    (add-zero (aref date 4)) ":" 
	    (add-zero (aref date 5)))))

;Testdata description:
;REG401: Saw wave from 1-100-1-100... step 1, emit once per second
;REG402: Noise value 0-9, 0-4 times per second
;REG403: Switch, 1 if REG401 >= 75, 0 otherwise
(defun make-simlogs (dir)
  (let ((v1 (make-sim-variable :name "REG401" :time 0.0 :dtime 1.0 
			       :freq 1.0 :valfn (sawfn 0 100)))
	(v2 (make-sim-variable :name "REG402" :time 0.0 :dtime 0.1 
			       :freq 0.25 :valfn #'(lambda () (random 10))))
	(v3 (make-sim-variable :name "REG403" :time 0.0 :dtime 1.0 
			       :freq 1.0 :valfn (on-or-off-fn 74 51 149)))
	(tv (gettimeofday)))
    (dotimes (i 6)
      (create-sim-datafile (concat dir "simlog" i ".csv") (1+ i) 
			   (timeval-string tv) (+ 100000 (* i 150)) (* i 150) 
			   150 (list v1 v3 v2))
      (setf tv (timeval-add-duration tv 150.0)))))

(osql "
create function dir_i(Charstring path, Charstring mask) -> Bag of Charstring
  /* List files in directory named charstring, whose names match 
     the case insensitive regexp in 2nd argument */
  as select ddd from charstring ddd
     where ddd in dir(path) and like_i(ddd, mask);")

(defun sim-logdir-+ (fno dirname)
  (let ((files (mapcar #'(lambda (tpl)
			   (concat dirname (car tpl)))
		       (amos-execute (concat "dir_i('" 
					     dirname "','*.csv');")))))
    (osql-result dirname (first files))
    (dolist (f (rest files))
      (sleep 0.2)
      (osql-result dirname f))))


;; for the sync tests
(defun create-sim-datafile2 (filename seq start reg vstart vcount)
  (with-open-file (file filename :direction :output)
    (formatl file "H,FileSequence," seq t)
    (formatl file "H,LogStartTime,2012-01-01 " start t)
    (formatl file "S,FileTime," vcount t)
    (formatl file "S," reg "," 1.0 t)
    (dotimes (v vcount)
      (formatl file "L," reg "," (+ v (roundto (rrandom) 1)) "," (+ vstart v) 
	       t))))

(defun make-simlogs2 (dir)
  (create-sim-datafile2 (concat dir "1/log1a.csv") 1 "00:00:00" "REG401" 0 30)
  (create-sim-datafile2 (concat dir "1/log2a.csv") 2 "00:00:30" "REG401" 10 30)
  (create-sim-datafile2 (concat dir "1/log3a.csv") 3 "00:01:00" "REG401" 20 30)
  (create-sim-datafile2 (concat dir "2/log1b.csv") 1 "00:00:30" "REG402" 0 30)
  (create-sim-datafile2 (concat dir "2/log2b.csv") 2 "00:01:00" "REG402" 10 30)
  (create-sim-datafile2 (concat dir "2/log3b.csv") 3 "00:01:30" "REG402" 20 30)
  )
