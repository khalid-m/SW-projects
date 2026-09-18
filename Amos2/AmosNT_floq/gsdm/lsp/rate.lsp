(defun increase-rate (str currate newrate)
"Increase the rate of the stream for this consumer"
;; find the gsdm server producing the stream
 
(let (strprod )
  (setq strprod (getobject str 'source))
  (if (input-TCP-strp str)
      (print (concat "Rate to be increased from" (mkstring currate)
	       " to " (mkstring newrate) " at node " strprod) ))
  ))

(defun decrease-rate (str currate newrate)
"Decrease the rate of the stream for this consumer"
;; find the gsdm server producing the stream
 
(let (strprod )
  (setq strprod (getobject str 'source))
  (if (input-TCP-strp str)
      (print (concat "Rate to be decreased from" (mkstring currate)
	       " to " (mkstring newrate) " at node " strprod)))
))


(defun increase-rate-s (strname currate newrate)
"Increase the rate of the stream for this consumer"
;; find the gsdm server producing the stream
 
(let (strprod )
  (setq strprod (getobject str 'source))
 
 (send-message 
   `(increase-rate-at-producer (quote , (getobject str 'name))
			       (quote , (mkstring _amosid_))
			       (quote , currate)
			       (quote , newrate))
   strprod)
))

(defun decrease-rate-s (str currate newrate)
"Decrease the rate of the stream for this consumer"
;; find the gsdm server producing the stream
 
(let (strprod )
  (setq strprod (getobject str 'source))
			
  (send-message 
   `(decrease-rate-at-producer (quote , (getobject str 'name))
			       (quote , (mkstring _amosid_))
			       (quote , currate)
			       (quote , newrate))
   strprod)
))

(defun increase-refused (strname mrate cons)
   ;;measured rate saturates to maxrate and can not be increased
   ;; TO DO signalize to the coordinator - parallel execution
   ;; inform the consumer for the maxrate 
   (send-message `(set-max-stream-rate (quote , strname) , mrate)
		cons)
)

(defun decrease-rate-at-intern-box (b newrate)

;;- for now executed always without scheduled rate
  ;; => executed always when possible, i.e. data are available 
  ;; mrate = pushing rate
  ;; analyse the input rate and request to decrease it for all streams

  (let* ( (istrl (mapcar 'car (box-inputstreaml b)))
	   (istrstatl (second (assoc (box-id b) _box-exec-stat_))))
    
    (mapc (f/l (str strstat)
	       (let ((istrrate (car strstat)))
		 
		 (if (< newrate istrrate)
		     (decrease-rate str istrrate newrate))))
	  istrl istrstatl)
      )
)

(defun decrease-rate-at-producer (strname cons currate newrate)
;; for now assume 1 consumer per producer-> no need of pconn-rate-> set to nil
;; find the box and analyse separately source box and intermediate box

  (let* ((str (getobjectnamed strname))
	 (b (get-registered-box (getobject str 'source)))
	 (istrnames (mapcar 'car (box-inputstreaml b)))
	 (mrate (get-exp-avg-rate (box-stat b))  ))

    (if (< newrate mrate) ;; decrease
	
	(cond ((null istrnames)
	   ;; source box = box without input streams. 
	   ;; decrease by setting the scheduled rate to smaller value
	   ;; in all cases. TO DO -many consumers - decrease of pconn-rate only
	       (setf (box-rate b) newrate))

	      ;; intermediate box 
	      (t (decrease-rate-at-intern-box b newrate)))

)))

(defun increase-rate-at-producer (strname cons currate newrate)
;; for now assume 1 consumer per producer-> no need of pconn-rate-> set to nil
;; find the box and analyse separately source box and intermediate box

  (let* ((b (get-registered-box (mkatom strname)))
	 (l (assoc (box-id b) _box-exec-stat_)) ;; stat list
	 (istrnames (mapcar 'car (box-inputstreaml b)))
	 (mrate (third l)))
   
(if (> newrate mrate) ;; increase

    (cond ((null istrnames)
;; source box = box without input streams. 
	   (cond ((null (box-rate b))
		  ;; operation executed always when possible
		  ;; mrate=maxrate -> no increase possible
		  ;; set box-maxrate to be eventually used
		  (setf (box-maxrate b) mrate)
		  ;; inform the consumer
		  (increase-refused strname mrate cons))
	

		 ;; op. executed with scheduled rate
		 (t (let ((srate (box-rate b)))
		      (if (< (- srate mrate) 0.5)
			  ;; increase is possible by increase scheduled rate
			  (setf (box-rate b) newrate)
		
			;; sheduled rate is big, measured- small
			(progn
			  ;;=> saturation of mrate to maxrate
			  (setf (box-maxrate b) mrate)
			  ;; inform the consumer
			  (increase-refused strname mrate cons)))))))


  ;; intermediate box - for now executed always without scheduled rate
  ;; => executed always when possible, i.e. data are available 
  ;; mrate = pushing rate
  ;; analyse the input stream rate
	  (t (let* ((istrl (second l))
		    (istr (car istrl)) ;; now for 1 stream only
		    bs ro istrrate istrmaxrate r1)
	
	       (setq istrrate (car istr))
	       (setq bs (second istr))
	       (setq istrmaxrate (third istr))
	       (setq ro (util bs))

	       (cond ((< (abs (- mrate istrrate)) 0.5) 
		 ;; pushing rate considered = inputrate << maxrate 
		 ;; increase the input streams rate if possible
		      (setq r1 (/ (* _max-util_ istrrate) (+ ro 0.001)))
		      (if  istrmaxrate
			  (setq r1 (min r1 istrmaxrate)))
		      ;; increase can not be more than max rate limited from
		      ;; 1- buf size, 2- declared max rate
		      (setq newrate (min newrate r1))
		      (if (> newrate istrrate)
			  ;; send request for increase to the producer
			  (increase-rate (car istrnames) istrrate newrate))
		      )
		     
		     ((> istrrate (+ mrate 0.5)) 
		 ;;measured rate saturates to maxrate and can not be increased
		      ;; set box-maxrate to be eventually used
		      (setf (box-maxrate b) mrate)
		      ;; inform the consumer
		      (increase-refused strname mrate cons))

		     (t ; no change
		      (print "OBS! Why input rate < measured rate")
		      ))
	       ))
))))

(defun set-max-stream-rate (strname rate)
  (setfunction 'maxrate (list (get-str-obj strname)) (list rate)))
