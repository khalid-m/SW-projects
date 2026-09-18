(defvar *c*)
(defvar *s*)

(start-program "run" "-n")
(start-program "run" "-s a")
(wait-until-started 'a)

(setq *c* (open-socket-to 'a))

(send-statement "< 'queries.osql';" *c*)
(setq *s* (open-query-scan-remote "torque2b();" *c*))

(defun check-torque2b ()
  (let ((prev-ts 0.0) (res t) (count 0)
	(row (scan-nextrow-remote *s*)))
    (while (not (string= (substring (1+ (string-rightpos (third row) "/")) 
				    (length (third row)) (third row))
			 "E01PS10-2991-20120511114741.CSV"))
      (formatl t row t)
					;(formatl t count ": " row t)
      (incf count)
      (if (>= (first row) prev-ts)
	  (setf prev-ts (first row))
	(progn (formatl t "!!! " prev-ts " " (first row) t) (setf res nil)))
      (setf row (scan-nextrow-remote *s*)))
    res))

(start-program "run" "-s b")
(wait-until-started 'b)

(send-statement 
 "sleep(1.0); copier(pwd()+'/realdata/',pwd()+'/realdata/target/',3); 
  sleep(1.0); quit;" 
 (open-socket-to 'b))

(checkequal "torque2b" ((check-torque2b) t))

(send-statement "quit;" *c*)
(send-statement "quit;" (open-nameserver-socket))
(quit)
