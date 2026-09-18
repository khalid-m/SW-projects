(defglobal _sp-heartbeat_ T)
(defglobal _sp-hb-freq_ 0.1)
(defglobal _sp-proctime_ T)
(defglobal _sp-proctime-freq_ 0.1)
(defglobal _sp-report-period_ 10.0)
(defglobal _coo-store-delays_ nil)

(defglobal _stat-tab_ (make-btree))
(defglobal _delay-filename_
  (concat (getenv "AMOS_HOME") "/scsq/proctime/delay"))
(defglobal _proctime-dir_ (concat (getenv "AMOS_HOME") "/scsq/proctime"))

(defun get-spnum (id)
  (packlist (nthcdr 3 (explode id))))

(defun getprof (filename)
  (with-input-file 
   s filename
   (let (tpl)
     (while (neq (setq tpl (read s)) '*EOF*)
       (let ((prof (isome (second tpl) (f/l (sym) (eq sym 'PROFILE)))))
	 (print (list (first tpl) prof)))))))

(defun add-dpstat (id pl)
  (put-btree id _stat-tab_ pl))

(defun add-delay (id rl)
  (and _coo-store-delays_
       (mapcar 
	(f/l (x)
	     (addfunction
	      'delay
	      (list (get-spnum (first x)) (get-spnum id) (ts2real (second x)))
	      (list (- (ts2real (third x)) (ts2real (second x))))))
	rl))
  (with-open-file (str _delay-filename_ :direction :append)
    (print (list id rl) str)))

(defun ts2real (ts)
  (+ (timeval-sec ts)
     (* (timeval-usec ts) 0.000001)))

(defun add-proctimes (id times)
  (with-open-file
      (str (concat _proctime-dir_ "/pr" (get-spnum id))
	   :direction :append)
    (print times str)))

(defun add-final-proctime (id sumtime)
  (with-open-file 
      (str (concat _proctime-dir_ "/spr" (get-spnum id))
	   :direction :output)
    (print sumtime str)))

(defun getproctimefiles (dir)
  (osql-declare charstring :ptdir)
  (setq amos_ptdir dir)
  (osql "dir(:ptdir, 'pr*');"))

(defun process-proctimes (dir outfile)
  (let ((proctime-tab (make-btree))
	(filelist
	 (sort (getproctimefiles dir)
	       (f/l (gt lt)
		    (> (packlist (nthcdr 2 (explode (car gt))))
		       (packlist (nthcdr 2 (explode (car lt)))))))))
    (mapcar
     (f/l
      (infile)
      (with-input-file 
       instream (concat dir "/" (car infile))
       (let (row)
	 (while (neq (setq row (read instream)) '*EOF*)
	   (mapcar
	    (f/l
	     (tpl)
	     (let* ((sec (round (ts2real (first tpl))))
		    ;; TODO: Something less crude than (round ...)
		    (olist (get-btree sec proctime-tab))
		    (newlist
		     (push (list (packlist (nthcdr 2 (explode (car infile))))
				 (second tpl)) olist)))
	       (put-btree sec proctime-tab newlist)))
	    row)))))
     filelist)
    (let (minfilenum maxfilenum start-time)
      (catch 'min   
	(map-btree proctime-tab '* '*
		   (f/l (k v) (setq start-time k) (throw 'min nil))))
      (with-open-file
	  (s outfile :direction :output)
	(with-open-file
	    (scsv (concat outfile ".csv") :direction :output)
	  (with-open-file
	      (sv (concat outfile ".vec")  :direction :output)
	    (map-btree 
	     proctime-tab '* '*
	     (f/l 
	      (k values)
	      (princ (concat (- k start-time) " ") s)
	      (princ (concat (- k start-time) ";") scsv)
	      (princ (concat "#(" (- k start-time) " ") sv)
	      (let ((printlist
		     (mapcar
		      (f/l 
		       (fname)
		       (let ((f (packlist (nthcdr 2 (explode (car fname))))))
			 (or
			  (car (subset values (f/l (v) (eq f (car v)))))
			  (list f))))
		      (reverse filelist))))
		(mapc
		 (f/l (pl) (princ (concat (or (second pl) " ") ";") scsv)
		      (princ (concat (second pl) " ") sv))
		 printlist))
	      (mapc
	       (f/l (e) (princ (concat (first e) " " (second e) " ") s))
	       values)
	      (terpri s) (terpri scsv) (princ ")" sv) (terpri sv)))))))))

(foreign-lispfn
 process_proctimes((charstring dir) (charstring outfile)) ()
 (process-proctimes dir outfile)
 (foreign-result))

(defun process-delay (infile outfile)
  (let ((delay-tab (make-btree)))
    (with-open-file
	(s infile)
      (let (tpl)
	(while (neq (setq tpl (read s)) '*EOF*)
	  (mapcar 
	   (f/l 
	    (l) 
	    (let ((x (ts2real (second l)))
		  (y (ts2real (third l))))
	      (let* ((olist (get-btree x delay-tab))
		     (newlist
		      (unique
		       (sort
			(push (list (packlist (nthcdr 5 (explode (car tpl))))
				    (- y x)) olist)
			(f/l (lt gt)
			     (< (car lt) (car gt)))))))
		(put-btree x delay-tab newlist))))
	   (second tpl)))))
    (let (start-time)
      (catch 'min
	(map-btree
	 delay-tab '* '*
	 (f/l (k v)
	      (setq start-time k)
	      (throw 'min nil))))
      (with-open-file
	  (s outfile :direction :output)
	(with-open-file
	    (scsv (concat outfile ".csv") :direction :output)
	  (with-open-file
	      (sv (concat outfile ".vec")  :direction :output)
	    (map-btree 
	     delay-tab '* '* 
	     (f/l (k v)
		  (princ (concat (- k start-time) " ") s)
		  (princ (concat (- k start-time) ";") scsv)
		  (princ (concat "#(" (- k start-time) " ") sv)
		  (mapc
		   (f/l (e)
			(princ (concat (first e) " " (second e) " ") s)
			(princ (concat (second e) ";") scsv)
			(princ (concat (second e) " ") sv))
		   v)
		  (terpri s) (terpri scsv) (princ ")" sv) (terpri sv)))))))))

(foreign-lispfn
 process_delay((charstring infile) (charstring outfile)) ()
 (process-delay infile outfile)
 (foreign-result))

(defun process-all-delays (experiment)
  (mapcar
   (f/l (fo)
	(mapcar
	 (f/l (x)
	      (process-delay (concat experiment "/proctime/fo/" x "/" fo
				     "/ret")
			     (concat "retout/" x fo)))
	 '("bin" "exp" "flat" "twomax" "oob" "opt")))
   '(2 4 8 16 32 64 128 256)))

(defun process-all-bc-delays (experiment)
  (mapcar
   (f/l (bc)
	(mapcar
	 (f/l (x)
	      (process-delay (concat experiment "/proctime/bc/" x "/" bc
				     "/ret")
			     (concat "retout/" x bc)))
	 '("bin" "exp" "flat" "twomax" "oob" "opt")))
   '(0 5 10 50 100 500 1000)))

(foreign-lispfn
 pabr ((charstring exp)) ()
 (process-all-bc-delays exp)
 (foreign-result))

(foreign-lispfn
 pafr ((charstring exp)) ()
 (process-all-delays exp)
 (foreign-result))

(defun dprofile (filename)
  (with-output-file
   str filename
   (map-btree
    _stat-tab_ '* '* 
    (f/l (k v)
	 (print (list k v) str)))))

(defun dumpinst (filename)
  (remote-eval `(dprofile , filename ) 's))

(foreign-lispfn
 dumpinst ((charstring filename)) ()
 (dumpinst filename)
 (foreign-result))


(defun sumprocsum (filelist)
  (let ((sumprocsum 0.0))
    (mapcar
     (f/l (file)
	  (with-open-file
	      (str file)
	    (let ((psum (read str)))
	      (if (neq psum '*eof*)
		  (setq sumprocsum (+ sumprocsum psum))))))
     (arraytolist filelist))
    sumprocsum))

(defun sumprocsum-ext (fno filelist)
  (osql-result filelist (sumprocsum filelist)))

(osql "create function sumprocsum(vector of charstring files)->real as
foreign 'sumprocsum-ext';")

(foreign-lispfn clear_cdelay () ((boolean))
		(reval@nameserver '(osql "clear_function('delay');")))
