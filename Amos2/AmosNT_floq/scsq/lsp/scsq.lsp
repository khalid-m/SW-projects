

(defglobal _scsq-watermark_ nil)
(defglobal _scsq-id_ nil)

(setq _sql-namespace_ nil) ;; Old CC function names

;;(register-init-form '(delay-emit nil))

(if (equal (system-environment) "Unix")
    (load "../lsp/fork.lsp"))

(set-resulttypesfn (theresolvent 'winagg) 'winagg-resulttypes)

(defun winagg-resulttypes (fno args)
    (list (make-vectortype (default-type-parameters (arg-type (car args))))))

(set-resulttypesfn 
 (foreign-lispfn 
  sbetween ((bag of vector b)(integer attribute)(integer start)(integer stop))
  ((object))
  (catch 'within
    (mapbag b
	    (f/l (r)
		 (if (>= (aref (car r) attribute) stop)(throw 'within nil))
		 (if (>= (aref (car r) attribute) start)
		     (apply 'osql-result 
			    (list* b attribute start stop r)))))))
 'transparent-collection-resulttypes)

(defun ezrand (fno max res)
  (osql-result max (ez-rand max)))

(osql "create function ezrand(integer max)->integer as foreign 'ezrand';")

(defun defaultbbf (fno test def)
  (catch 'test
    (let count
      (mapbag test (f/l (r)
			(osql-result test def (car r)) (throw 'test nil)))
      (osql-result test def def))))

(osql "create function default(bag test, object default)->object as foreign
'defaultbbf';")

(defun tcountbf (fno b res)
  (let ((inittime (rnow)) (starttime (rnow)) stoptime (count 0))
    (mapbag b (f/l (r)
		   (if (equal count 0) (setq starttime (rnow)))
		   (1++ count)))
    (setq stoptime (rnow))
    (osql-result b (vector starttime (- starttime inittime)
			   (- stoptime starttime) count))))

(osql "create function tcount(stream)->vector of number as foreign 'tcountbf';
create function stcount(stream s)->stream of vector of number as 
streamof(tcount(s));")

(foreign-lispfn
 drop ((function fno)) ((boolean))
 (dropfunction fno))

(foreign-lispfn
 q() ((boolean))
 (reval@nameserver 't)
 (getfunction 'killdaemons nil)
 (send-form '(quit) (open-nameserver-port))
 (quit))

(defun in-q ()
  (getenv "TMPDIR"))

(foreign-lispfn
 in_q () ((boolean))
 (foreign-result (in-q)))

(foreign-lispfn
 check_q() ((boolean))
 (if (in-q)
     (foreign-result t)
   (progn (formatl t "Not in queue system. Quitting!" t) (quit))))

(foreign-lispfn
 domainname ((Charstring a)) ((Charstring))
 (let ((dotpos (string-pos a ".")))
   (and dotpos 
	(foreign-result (substring (+ 1 dotpos) (- (length a) 1) a)))))

(foreign-lispfn
 shortname ((Charstring a)) ((Charstring))
 (let ((dotpos (string-pos a ".")))
   (and dotpos 
	(foreign-result (substring 0 (- dotpos 1) a)))))

(defun vextend-vector (arg v dim)
  (cond ((< (length v) dim)
	 (osql-result
	  arg dim
	  (concatvector
	   v (make-array (- dim (length v))
			 :initial-element (aref v (- (length v) 1))))))
	(t
	 (osql-result arg dim v))))

(defun vextend (fno v dim res)
  (cond ((equal (length v) 0)
	 (osql-result v dim v))
	((arrayp (aref v 0)) ;; if vector of vector, pass the inner vector.
	 (vextend-vector v (aref v 0) dim))
	(t
	 (vextend-vector v v dim))))

(defun eternitybf (fno interval res)
  (while t
    (sleep interval)
    (osql-result interval 'TRUE)))
(osql "create function eternity(Real interval)->Boolean 
       as foreign 'eternitybf';")

;; Concat of vectors returns the most specific common ancestortype.

(set-resulttypesfn (getfunctionnamed 'vector.vector.concat->vector)
                 'concatvector-resulttypes)

(defun concatvector-resulttypes (fno args)
  (list (common-ancestortype (arg-type (first args))
                           (arg-type (second args)))))

(foreign-lispfn writefile((Charstring file)(Bag b))((boolean))
		(with-output-file
		 s file
		 (mapbag b (f/l (row)(print (car row) s))))
		T)

(foreign-lispfn 
 writefiles
 ((Charstring filename)(integer rowsperfile)(Bag b)) ((Real) (Real))
 (let ((filenum 0) (rowc 0) fh (start-time (rnow)) proc-time (firsttime t))
   (mapbag b
	   (f/l (row)
		(cond (firsttime
		       (setq proc-time (rnow))
		       (setq firsttime nil)))
		(cond ((equal rowc 0)
		       (setq fh (openstream (concat filename filenum) "wb"))))
		(1++ rowc)
		(print (car row) fh)
		(cond ((equal rowc rowsperfile)
		       (closestream fh)
		       (1++ filenum)
		       (setq rowc 0)))))
   (cond ((> rowc 0)
	  (closestream fh)
	  (foreign-result (- (rnow) start-time) (- proc-time start-time)))
	 (t
	  (foreign-result (- (rnow) start-time) 0.0)))))

(defun sysenv (fno res)
  (osql-result (SYSTEM-ENVIRONMENT)))
(osql "create function system()->charstring as foreign 'sysenv';")

(defun get-varstring (x)
  (let* ((var (pack 'amos_ x))
	 (uvar (pack ': x))
	 (val (symbol-value var)))
    (cond ((eq val 'nobind)
	   (error "get-varstring: variable not bound" uvar))
	  ((stringp val) val)
	  (t (error "get-varstring: variable not string" uvar)))))

(defun generator-portsfrom (generator)
  (if generator
      (list-portsfrom (generator-params generator))
    nil))

(defun list-portsfrom (l)
  (cond ((eq 'PORT (typename l))
	 (list (port-gethostname l)))
	((arrayp l)
	 (list-portsfrom (arraytolist l)))
	((atom l)
	 nil)
	(t
	 (nconc (list-portsfrom (car l)) (list-portsfrom (cdr l))))))

(defun register-scsq-client ()
  (let ((me (concat "client-" (reval@nameserver '(gensym)))))
    (register-amos me)))

;; prod(bag of number)->number multiplies all elements in a bag

(defun prodbf (fno values prod)
  (let ((prod 1) row)
    (mapbag values
	    (f/l (row)
		 (setq prod (* prod (car row)))))
    (osql-result values prod)))

(osql "create function prod(bag of number)->number as foreign 'prodbf';")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; groupagg ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun groupAgg-impl (fno stride values low aggv)
  "Implements grouping of pairs in VALUES based on STRIDE over first element"
  (let ((first t)low group)
    (mapbag values
	    (f/l (row)
		 (cond (first (setq low (car row))
			      (setq group (init-group-array (second row)))
			      (setq first nil))
		       ((>= (car row)(+ stride low))
			(osql-result stride values low group)
			(setq low (car row))
			(setq group (init-group-array (second row))))
		       (t (push-vector group (second row))))))
    (osql-result stride values low group)))

(defun init-group-array (x)
  "Initialize adjustable array of grouped values"
  (make-array 1 :adjustable t :initial-element x))

(defun groupagg2-impl (fno size stride attrib values aggv)
  (let (winstart winend group tmp)
    (mapbag values
	    (f/l (row)
		 (cond ((not winstart)
			(setq winstart (elt (car row) attrib))
			(setq winend (+ winstart size))))
		 (cond ((>= (elt (car row) attrib) winend)
			(osql-result size stride attrib values
				     (listtoarray (reverse group)))
			(setq winstart (+ winstart stride))
			(setq winend (+ winend stride))
			(setq group (subset
				     group
				     (f/l (e) (>= (elt e attrib) winstart))))))
		 (cond ((>= (elt (car row) attrib) winstart)
			(setq group (append row group))))))
    (osql-result size stride attrib values (listtoarray (reverse group)))))

(defun groupagg2e-impl (fno size stride attrib values aggv)
  (let (winstart winend group tmp warmup)
    (mapbag values
	    (f/l (row)
		 (cond ((not winstart)
			(setq winstart (elt (car row) attrib))
			(cond ((> size stride)
			       (setq winend (+ winstart stride))
			       (setq warmup t))
			      (t
			       (setq winend (+ winstart size))))))
		 (cond ((>= (elt (car row) attrib) winend)
			(osql-result size stride attrib values
				     (listtoarray (reverse group)))
			(cond (warmup
			       (if (>= (- winend winstart) size)
				   (setq warmup nil))))
			(if (not warmup)
			    (setq winstart (+ winstart stride)))
			(setq winend (+ winend stride))
			(setq group (subset
				     group
				     (f/l (e) (>= (elt e attrib) winstart))))))
		 (cond ((>= (elt (car row) attrib) winstart)
			(setq group (append row group))))))
    (osql-result size stride attrib values (listtoarray (reverse group)))))

;;;;;;;;;;;;;;;;;;;;;; skip the first element of a bag ;;;;;;;;;;;;;;;;;;;;;;;;

(defun skipfirst-impl (fno size attrib values retval)
  (let (start)
    (mapbag values
	    (f/l (row)
		 (cond ((not start)
			(setq start (elt (car row) attrib)))
		       ((>= (elt (car row) attrib) (+ start size))
			(osql-result size attrib values row)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; splitstream trees ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun opt-fanout (targetfo a b)
  (if (= 0 b)
      (vector targetfo)
    (let ((bcast (/ b 1000.0)))
      (concatvector (vector 2) (fo_i bcast a 2 targetfo)))))

(defun fo_i (bcast a cumulfo targetfo)
  (cond ((>= cumulfo targetfo)
	 #())
	(t
	 (let ((fanout
		(floor (+ 2 (*
			     (+ 1 a)
			     (/ (- 1 bcast) bcast)
			     (- 1 (/ 1 cumulfo)))))))
	   (if (> (* cumulfo fanout) targetfo)
	       (vector (ceiling (/ targetfo (+ cumulfo 0.0))))
	     (concatvector
	      (vector fanout)
	      (fo_i bcast a (* cumulfo fanout) targetfo)))))))

(defun opt-fanout+++- (fno targetfo a b res)
  (osql-result targetfo a b (opt-fanout targetfo a b)))

(defun newsp-resulttypes (fno argl)
  (let ((st (arg-type (first argl)))
	(sfno (third argl)) 
	argtypes restypes)
    (cond ((not (function-p sfno)) (list _stream_))
	  ((or (null st)
	       (and
		(setq argtypes (get-resolvent-argtypes sfno))
		(osql-subtypep (car (collection-parameters st))
			       (car argtypes))
                
		(setq restypes (function-resulttypes sfno))
		(= (length restypes) 2)
		(= (first restypes) _integer_)))
           (list (make-vectortype (list (make-streamtype 
					 (list (second restypes))))))))))

(defun retard--+ (fno delay bag res)
  (mapbag bag
	  (f/l (row)
	       (apply 'osql-result delay bag row)
	       (co-sleep delay))))


(set-resulttypesfn 
 (osql "create function retard(Number delay, Bag b) -> Bag of Object
  /* Delay emitting objects in b */
  as foreign 'retard--+';")
 (f/l (fno args) (default-type-parameters (arg-type (second args))))) 
