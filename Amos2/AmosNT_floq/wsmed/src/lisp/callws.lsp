
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; cwo cost function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(foreign-lispfn cwocost ((function f)(vector bpat)(vector args))((integer cost)(integer fanout))
		(let ((fanout 101))
		 
		(cond ((equal (aref args 2) "GetPlacesInside") (setq fanout 102))
		      ((equal (aref args 2) "GetPlaceDetails") (setq fanout 103)))
		      
		(foreign-result 100 fanout)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Web Service call and meta-data handling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun find-record-value(fno H E R)
  (do ((I 0 (+ 2 I)))
      ((= I (Length (record-fields H))))
    (if (equal E (aref (record-fields H) I)) (progn (osql-result H E (aref (record-fields H) (1+ I)))))))

(defun find-WSDLtype(fno H E R)
  (osql-let ((Charstring :ename)(Element :ele))
	    (do ((I 0 (+ 2 I)))
		((= I (Length (record-fields H))))
	      (setq AMOS_ele (aref (record-fields H) I))
	      (setq AMOS_ename (caar (osql "name(:ele);")))
	      (if (equal E AMOS_ename)  
		  (progn (osql-result H E (aref (record-fields H) (1+ I))) (return t))))))
                 

(defglobal cwocount 0)

(defun extractelements (arr)
  (let (ele)
    (maparray arr (f/l (e i)
		       (if ele
			   (setq ele (concat ele e))
			 (setq ele e))))
    ele ))
		  
(defun co-busy (fno r)
  (if (co-inside) (co-yield '*busy*)
    (amos-error "Calling BUSY outside coroutine")) )


(defun cwo (fno wu ws opn ip r)
  (mapfunctionres 'callwebserviceoperation (list wu ws opn ip) nil
		  (f/l (row)
		       (if (= (car row) (vector nil))
			   (osql-result wu ws opn ip (vector))
			 (osql-result wu ws opn ip (nth 0 row))) )))
(defglobal elepos 0)

(defun find-ele-wsdltype-pos (ele pos)
  "Iterate through the subelements to find outputelement wsdltype"
  (osql-let ((Element :ele) (Vector :sele)(Charstring :elename))
	    (setq AMOS_ele ele)
	    (setq AMOS_sele (caar (osql "subelements(:ele);")))
	    (if AMOS_sele
		(dolist (e (arraytolist AMOS_sele))
		  (setq AMOS_ele e)
             	  (if (= pos elepos) (return (caar (osql "wsdltype(:ele);")))
		    (progn 
		      (setq elepos (1+ elepos))
		      (setq AMOS_elename (find-ele-wsdltype-pos e pos))
		      (if AMOS_elename (return AMOS_elename))))))))
       
(defun find-output-ele-wsdltype-at-pos (fno op pos elename)
  "find wsdltype of the output element in the given list"
  (osql-let ((Operation :op) (integer :pos)( vector :vele)(Charstring :ename)(Element :ele))
	    (setq AMOS_op op)
	    (setq AMOS_pos pos)
            (setq elepos 0)
	    (setq AMOS_vele (caar (osql "output(:op);")))
	    (cond ((= AMOS_pos 0) (osql-result op pos (caar (osql "select wsdltype(e) from Element e where e in :vele;"))))
		  (t (dolist (e (arraytolist AMOS_vele))
		       (setq AMOS_ele e)
		       (if (= pos elepos) (progn (osql-result op pos (caar (osql "wsdltype(:ele);"))) (return t)))
		       (progn (setq elepos (1+ elepos)) 
			      (setq AMOS_ename (find-ele-wsdltype-pos e pos))
			      (if AMOS_ename (progn (osql-result op pos AMOS_ename)(return AMOS_ename)))))))))
         
(defun find-ele-pos (ele pos)
  "Iterate through the subelements to find outputelement name"
  (osql-let ((Element :ele) (Vector :sele)(Charstring :elename))
	    (setq AMOS_ele ele)
	    (setq AMOS_sele (caar (osql "subelements(:ele);")))
	    (if AMOS_sele
		(dolist (e (arraytolist AMOS_sele))
		  (setq AMOS_ele e)
             	  (if (= pos elepos) (return (caar (osql "name(:ele);")))
		    (progn 
		      (setq elepos (1+ elepos))
		      (setq AMOS_elename (find-ele-pos e pos))
		      (if AMOS_elename (return AMOS_elename))))))))
       
(defun find-output-ele-at-pos (fno op pos elename)
  "find name of the output element in the given list"
  (osql-let ((Operation :op) (integer :pos)( vector :vele)(Charstring :ename)(Element :ele))
	    (setq AMOS_op op)
	    (setq AMOS_pos pos)
            (setq elepos 0)
	    (setq AMOS_vele (caar (osql "output(:op);")))
	    (cond ((= AMOS_pos 0) (osql-result op pos (caar (osql "select name(e) from Element e where e in :vele;"))))
		  (t (dolist (e (arraytolist AMOS_vele))
		       (setq AMOS_ele e)
		       (if (= pos elepos) (progn (osql-result op pos (caar (osql "name(:ele);"))) (return t))
			 (progn (setq elepos (1+ elepos)) 
                                (setq AMOS_ename (find-ele-pos e pos))
                                (if AMOS_ename (progn (osql-result op pos AMOS_ename)(return AMOS_ename))))))))))
          




 

(defglobal _fanout_  (list 2 2 2 2))

(defun setfanout (fno d)
  (setq  _fanout_ (arraytolist d)))



(defun setmaxc (wsdluriv wsnamev opnamev maxcv)
  (osql-let ((charstring :wu) (charstring :ws)(charstring :op) (integer :c))
	    (setq AMOS_wu wsdluriv)
	    (setq AMOS_ws wsnamev)
	    (setq AMOS_op opnamev) 
	    (setq AMOS_c maxcv)
	    (osql "setmaxc(:wu,:ws,:op,:c);")		
	    ))

(defun getmaxc (wsdluriv wsnamev opnamev)
  (osql-let ((charstring :wu) (charstring :ws)(charstring :op))
	    (setq AMOS_wu wsdluriv)
	    (setq AMOS_ws wsnamev)
	    (setq AMOS_op opnamev) 
	    (caar (osql "getmaxc(:wu,:ws,:op);"))
	    ))
(defun cocwo (fno wu ws opn ip res)
  (let ((level (get-level opn)) peerno)
     (if (co-inside)
	(progn
          
	  (add-wscall-per-level opn)
	  (setq _coid_ (1+ _coid_))
	  (mapfunctionres 'callwebserviceoperation (list wu ws opn ip _coid_ level) nil
			  (f/l (row)
			       (set-co-stat-wstime (co-inside) opn (second row));; record cwotime per coroutine
			       (cond ((= (car row) (vector "Message Send Failed Due to Timeout of Web Service"))(throw 'msg-catch -2))
				     ((= (car row) (vector nil))(osql-result wu ws opn ip (vector)))
				     (t (setq _cwocount_ (1+ _cwocount_))(osql-result wu ws opn ip (car row))))))
	
	  )
      (progn 
	(setq _cwocount_ (1+ _cwocount_))
        (mapfunctionres 'callwebserviceoperation (list wu ws opn ip _cwocount_ 0) nil
			(f/l (row) 
			     (setq _wsl_ (list opn (+ (second _wsl_)(second row))));; record wstime
			     (if (= (car row) (vector nil))
				 (osql-result wu ws opn ip (vector))
			       (progn
			       	 (setq _cwotime_ (+ _cwotime_ (nth 1 row)))
				 (osql-result wu ws opn ip (car row))))))))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Profiling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defglobal _fanoutl_ (list ));;stores the level, fanout, web service operation, pertupletime
(defglobal _no_of_rr_receive_  0)
(defglobal _wscall_per_tree_ (list ))
(defglobal _wscall_per_level_ (list ))
(defglobal _wstime_per_level_ (list ))
(defglobal _cwotime_per_operatorl_ (list))
(defglobal _cwocount_ 0)
(defglobal _coid_ 0)
(defglobal _wsl_ (list 0 0))
(defglobal _currentco_ nil)
(defglobal _level_ 0)




(defun add-wstime-per-level (ws wt co)
  "add profile to ws calls per level"
  (dolist (x _wstime_per_level_)
    (cond ((= (get-level ws) (first (last x)))
	   (setq _wstime_per_level_ (subst (cons (list co  wt 0) x)  x _wstime_per_level_)));;
	  )))      
  
(defun add-wscall-per-level(ws)
  "add profile to ws calls per level"
  (dolist (x _wscall_per_level_)
    (cond ((= (get-level ws) (first (last x)))
	   (if (> (length x) 1)
	       (setq  _wscall_per_level_ (subst (cons (1+ (first x)) x) x _wscall_per_level_))
	     (setq _wscall_per_level_ (subst (cons 1 x) x _wscall_per_level_)));;for the first recording
	   (return t)  
	   )))
  (add-wscall-per-tree))


(defun remove-wscall-per-level(ws)
  "remove profile from ws calls per level"
  (dolist (x _wscall_per_level_)
    (cond ((= (get-level ws) (first (last x)))
	   (setq  _wscall_per_level_ (subst (cons (1- (first x)) x) x _wscall_per_level_)) 
	   (return t))))
  (add-wscall-per-tree)
  )

(defun add-wscall-per-tree
  "add profile to ws calls on process tree"
  (let ((templ (list)))
    (dolist (x _wscall_per_level_)
      (setq  templ (cons (first x) templ)))
    (setq _wscall_per_tree_ (cons templ _wscall_per_tree_))))



	     
(defun get-level (ws)
  "Get the level of process tree which calls ws"
  (dolist (x _fanoutl_)
    (cond ((= ws (third x))
	   (return (first x)))))) 

(defun get-maxcall-per-level
  "print profile of ws per level"
  (let (revl)
    (dolist (x _wscall_per_level_)
      (setq revl (reverse x))
      (print ( concat "level " (first revl) " max ws call "  (first (sort (cdr revl) '>)))))))

(defun get-maxcall-per-tree
  "print profile of ws per tree"
  (let ((val 0) wsc sum)
    (dolist (x _wscall_per_tree_)
      (setq sum 0)
      (dolist (y x)
	(setq sum (+ y sum)))
      (cond ((> sum val) (setq val sum) (setq wsc x))))
    (print (concat "maxcall per tree " wsc))
    ))

(defun get-maxcall-per-tree-parallel
  "print profile of ws per tree"
  (let ((val 0) wsc sum)
    (dolist (x _wscall_per_tree_)
      (setq sum 0)
      (dolist (y x)
	(cond ((> y 0) 
	       (setq sum (+ y sum)))
	      ((= y 0)(setq sum 0) (return t)))
	)
      (cond ((> sum val) (setq val sum) (setq wsc x))))
    (print (concat "maxcall per tree with parallelisim on all levels" wsc))
    ))

(defun add-cwotime-per-operator(wt co )
  "add execution time for a web service call"
  (setq _cwotime_per_operatorl_ (cons (list co wt) _cwotime_per_operatorl_)))

(defun get-cwotime-per-operator(co)
  "get execution time for a web service call executed by a given coroutine co"
  (dolist (x _cwotime_per_operatorl_)
    (cond ((equal (first x) co)
	   (setq _cwotime_per_operatorl_ (remove x _cwotime_per_operatorl_))
	   (return (second x))))))

(defglobal _cwotime_ 0)


(defstruct co_stat wsname tuple wstime)
(defglobal _co_stat_ (make-hash-table :TEST (FUNCTION EQUAL)))
(defstruct fn_stat fnum restuple bagcount);;to record the which fn, resulttuple, bagcount for argument  belongs to which coroutine
(defglobal _fn_stat_ (make-hash-table :TEST (FUNCTION EQUAL)))



(defun clean-fn-stat (col)
  "Remove the values from the hashtable _fn_stat_"
  (dolist (x col)
    (remhash x _fn_stat_)))

(defun set-fn-stat-fnum (co fnum bagcount)
  "set funtion number"
  (setf (gethash co _fn_stat_) (make-fn_stat :fnum fnum :restuple nil :bagcount bagcount)))

(defun set-fn-stat-restuple (co restuple)
  "set resulttuple"
 (let (res)
  (setq res  (fn_stat-restuple (gethash co _fn_stat_)))
  (if res (setq res (cons restuple res))
    (setq res (list restuple)))
   (setf (gethash co _fn_stat_) (make-fn_stat :fnum (fn_stat-fnum (gethash co _fn_stat_)) :restuple res :bagcount (fn_stat-bagcount (gethash co _fn_stat_)) ))))

(defun get-fn-stat-fnum(co)
  "get function number for a given coroutine"
  (fn_stat-fnum (gethash co _fn_stat_)))

(defun get-fn-stat-restuple(co)
  "get restuple for a given coroutine"
  (fn_stat-restuple (gethash co _fn_stat_)))

(defun get-fn-stat-bagcount(co)
  "get restuple for a given coroutine"
  (fn_stat-bagcount (gethash co _fn_stat_)))

(defun get-co-stat (co)
  "return statistics about a given coroutine"
  (gethash co _co_stat_))

(defun set-co-stat-tuplecount (co tcount)
  "set tuplecount  for a given coroutine"
  (let ((stat (get-co-stat co)))
    (setf (co_stat-tuple stat) (+ (co_stat-tuple stat) tcount))
    (setf (gethash co _co_stat_) stat)))

(defun set-co-stat-wstime (co ws wt)
  "set webservice call and wstime for a given coroutine"
  (setf (gethash co _co_stat_) (make-co_stat :wsname ws :tuple 0 :wstime wt))
  )
(defun get-co-stat-wstime (co )
  "set webservice call and wstime for a given coroutine"
  (co_stat-wstime (gethash co _co_stat_))
  )

(defun get-per-level-stat
  "get per level statistics"
  (let (level (_levelstat_ (list )))
    (dolist (x _fanoutl_ );; initialise the list _levelstat_
      (setq _levelstat_ (cons (list (first x) 0 0 0 0) _levelstat_))) 

    (maphash   (f/l (key stat)
		    (setq level (get-level (co_stat-wsname stat)))
		    (dolist (y _levelstat_)
		      (if (= (first y) level)
			  (progn
			    (quote (formatl t "level " level " sum of wstime  " (third y) "  wstime for this call " (co_stat-wstime stat) " tuplecount " (co_stat-tuple stat) t))
			    (setq _levelstat_ (subst (list level  (+ (second y)(co_stat-tuple stat)) (+ (third y)(co_stat-wstime stat)) (+ (fourth y) (* (co_stat-wstime stat)(co_stat-wstime stat))) (1+ (fifth y))) y _levelstat_)))))) 
	       _co_stat_)
   
   
    (dolist (y _levelstat_)
      (formatl t "level : " (first y) "  > tuplecount : " (second y) " > webservicetime : " (third y) " > square sum of wstime : " (fourth y) "  > numberofcall : " (fifth y) t))
    ))

(defun average-fanout(ws)
  (let ((count 0) (sum 0))
    (dolist (x _fanoutl_)
      (if (equal (third x) ws) 
	  (dolist (y (second x))
	    (setq sum (+ sum y))
	    (setq count (1+ count)))))
    (/ (* sum 1.0) count)
    ))

(defun get-per-wsoperation
  "get per wsoperation  statistics"
  (let (level (_levelstat_ (list )))
    (dolist (x _fanoutl_ );; initialise the list _levelstat_
      (setq _levelstat_ (cons (list (third x) 0 0 0 0) _levelstat_))) 
    (maphash   (f/l (key stat)
		    (setq level (co_stat-wsname stat))
		    (dolist (y _levelstat_)
		      (if (= (first y) level)
			  	    (setq _levelstat_ (subst (list level  (+ (second y)(co_stat-tuple stat)) (+ (third y)(co_stat-wstime stat)) (+ (fourth y) (* (co_stat-wstime stat)(co_stat-wstime stat))) (1+ (fifth y))(average-fanout (first y)) ) y _levelstat_)))))
	       _co_stat_)
   
    (dolist (y _levelstat_)
      (formatl t "level : " (first y) "  > tuplecount : " (second y) " > webservicetime : " (third y) " > square sum of wstime : " (fourth y) "  > numberofcall : " (fifth y) " > averagefanout: " (sixth y) t))
    
    ))
	      
(defun get-fanout (level)
  (dolist (x _fanoutl_)
    (cond ((= level (first x))
	   (return (car (second x)))))))
 
(defun update-fanout (level nfanout )
  (dolist (x _fanoutl_)
    (cond ((= level (first x))
	   (setq _fanoutl_ (subst (list (first x) (cons nfanout (second x)) (third x)) x _fanoutl_))
	   (return _fanoutl_) ))))
   	  
	  
(defun findpeerno (peerid)
  (let ((pl (cdr (explode (mksymbol peerid))))
        str)
    (dolist (x pl)
      (if str (setq str (concat str x))
	(setq str (mkstring x))))
   (mksymbol str) )
  )

(defun otherpeers ()
  (let ((peerl (list )))
    (mapfunctionres 'other_peers (list ) nil
		    (f/l (row)
			 (setq peerl (cons (first row) peerl))))
    peerl))

(defun get-static-process()
  "Get the time of all web services called in a process"
  _wsl_)

(defun profile-static-processes()
  (let ( (peers (otherpeers)) templ (_levelstat_ (list )))
   
    (dolist (x _fanoutl_ );; initialise the list _levelstat_
      (setq _levelstat_ (cons (list (first x) 0 ) _levelstat_))) 

    (dolist (p peers)
      (setq templ (remote-eval (list 'get-static-process) p))
      
      (dolist (y _levelstat_)
	(cond ((= (first y) (get-level (first templ)))
	       (setq _levelstat_ (subst (list (first y) (+ (second y)(second templ))) y _levelstat_))
	       (return t)))))
   
    
    (dolist (y _levelstat_)
      (formatl t "level " (first y) " wstime " (second y) t))))	   
 
(defun setinit()
  (setq _cwocount_ 0)
  (setq _wsl_ (list 0 0)))

(defun refresh()
  (global-eval '(setinit)))

(defun getall-wstime
 "Get all webservice time called sofar"
 (formatl t "web service >>>>> no of Tuples >>>>> wstime" t)
 (maphash   (f/l (key stat) (formatl t (co_stat-wsname stat) " >>>>> "  (co_stat-tuple stat) " >>>>> "  (co_stat-wstime stat) t)) _co_stat_))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Regression test
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defglobal _regresstest_ nil)