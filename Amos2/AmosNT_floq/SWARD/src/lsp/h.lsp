;;;Fn for compiling a query.
(defun compile-query (fno query res)
  "Compile AMOSQL query string into transient function"
  (osql-result query (prepare-query query 0)))

(defun p-stat(fno)
"To get status of partial evaluation"
 (if *enable-parteval* (osql-result fno t)))

(defun setwm (fno oidno)
  (osql-result oidno (setq _system-watermark_ oidno)))

(defun resvars (fno q r)
  "Extract result variables from AmosQL query q into vector r"
  (osql-result q (listtoarray (mapcar (f/l (x) (concat "?" (mkstring x)))(aref (getselectbody q) 2)))))

(defun ressqlvars (fno q r)
  "Extract result variables from SQL query q into vector r"
  (osql-result q (listtoarray (mapcar (f/l (x) (mkstring (packlist (cdr (explode x)))))(select-get (translate-sql-select (cdr (sql-parse q))) 'result)))))


;(defglobal _profiler-frequency_ 0.1); How often to sample stack per sec

;(defun stat-function ()
;      (and _stat-enabled_
;	   ((lambda (x)
;	      (and (eq x '***olog***) _current-ologpred_ 
;		   (setq x (oid-name _current-ologpred_)))
;	      (and x (setf (gethash (print x) _profile-stats_) 
;			   (1+ (or(gethash x _profile-stats_)0 )))))
;	    (topcall _exclude-profile_))))

;;(defun resvars (fno q r)
;;  "Extract result variables from AmosQL query q into vector r"
;;  (osql-result q (listtoarray (mapcar (f/l (x) (concat "?" (mkstring x)))(aref (getselectbody (prepare-query q 0)) 2)))))