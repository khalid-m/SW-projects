
(defglobal _generator_ nil)
(defglobal _dsmssource_ nil)
(defglobal _dsmsanswer1_ nil)
(defglobal _dsmsanswer2_ nil)
(defglobal _dsmsanswer3_ nil)
(defglobal _dsmsanswer4_ nil)

(foreign-lispfn
 lrvalidation ((Charstring exec) (Charstring input) (Charstring hostname)) ((Boolean))
 (let* ((coord (open-socket nil 0))
	(coordno (socket-portno coord))
	peer1 source1 source2
	peer2 answer1 answer2 answer3 answer4
	vali1 vali2 vali3 vali4)
   (system (concat "start svali coord.dmp -o lrsocketio(\'" input "\',\'" hostname "\'," coordno ");"))
   (setq peer1 (accept-socket coord nil))
   ;; always start peer1 first
   (setq source1 (read peer1))  ;; THIS SHOULD BE PROVIDED TO THE DSMS
   (setq _dsmssource_ source1)
   (setq source2 (read peer1))
   (pf 'START peer1)
   (system (concat "start svali answer.dmp -o lrvali(\'" hostname "\'," coordno "," source2 ");"))
   (setq peer2 (accept-socket coord nil))
   (setq answer1 (read peer2))  ;; toll alert
   (setq answer2 (read peer2))  ;; accident alert
   (setq answer3 (read peer2))  ;; type 2 alert
   (setq answer4 (read peer2))  ;; type 3 alert
   (pf 'START peer2)
   (system (concat "start svali coord.dmp -o socketmerge(\'" hostname "\'," coordno "," answer1 ");"))
   (setq vali1 (accept-socket coord nil))
   (setq _dsmsanswer1_ (read vali1))
   (system (concat "start svali coord.dmp -o socketmerge(\'" hostname "\'," coordno "," answer2 ");"))
   (setq vali2 (accept-socket coord nil))
   (setq _dsmsanswer2_ (read vali2))
   (system (concat "start svali coord.dmp -o socketmerge(\'" hostname "\'," coordno "," answer3 ");"))
   (setq vali3 (accept-socket coord nil))
   (setq _dsmsanswer3_ (read vali3))
   (system (concat "start svali coord.dmp -o socketmerge(\'" hostname "\'," coordno "," answer4 ");"))
   (setq vali4 (accept-socket coord nil))
   (setq _dsmsanswer4_ (read vali4))
   (system (concat "start " exec " " hostname " " _dsmssource_ " " _dsmsanswer1_
		   " " _dsmsanswer2_ " " _dsmsanswer3_ " " _dsmsanswer4_))))


(foreign-lispfn
 lrvalidationg ((Charstring exec) (Charstring input) (Charstring hostname)) ((Boolean))
 (let* ((coord (open-socket nil 0))
	(coordno (socket-portno coord))
	peer1 source1 source2
	peer2 answer1 answer2 answer3 answer4
	vali1 vali2 vali3 vali4)
   (system (concat "start svali coord.dmp -o lrsocketio(\'" input "\',\'" hostname "\'," coordno ");"))
   (setq peer1 (accept-socket coord nil))
   ;; always start peer1 first
   (setq source1 (read peer1))  ;; THIS SHOULD BE PROVIDED TO THE DSMS
   (setq _dsmssource_ source1)
   (setq source2 (read peer1))
   (pf 'START peer1)
   (system (concat "start svali answer.dmp -o lrvali(\'" hostname "\'," coordno "," source2 ");"))
   (setq peer2 (accept-socket coord nil))
   (setq answer1 (read peer2))  ;; toll alert
   (setq answer2 (read peer2))  ;; accident alert
   (setq answer3 (read peer2))  ;; type 2 alert
   (setq answer4 (read peer2))  ;; type 3 alert
   (pf 'START peer2)
   (system (concat "start svali coord.dmp -o socketrecv(\'" hostname "\'," coordno "," answer1 ",2,3,1,{1,2},{4,5},{0,1},{2,3});"))
   (setq vali1 (accept-socket coord nil))
   (setq _dsmsanswer1_ (read vali1))
   (system (concat "start svali coord.dmp -o socketrecv(\'" hostname "\'," coordno "," answer2 ",1,2,0,{1,3},{4},{0,1},{2});"))
   (setq vali2 (accept-socket coord nil))
   (setq _dsmsanswer2_ (read vali2))
   (system (concat "start svali coord.dmp -o socketrecv(\'" hostname "\'," coordno "," answer3 ",1,2,1,{3},{5},{2},{4});"))
   (setq vali3 (accept-socket coord nil))
   (setq _dsmsanswer3_ (read vali3))
   (system (concat "start svali coord.dmp -o socketrecv(\'" hostname "\'," coordno "," answer4 ",1,2,0,{3},{4},{1},{2});"))
   (setq vali4 (accept-socket coord nil))
   (setq _dsmsanswer4_ (read vali4))
   (system (concat "start " exec " " hostname " " _dsmssource_ " " _dsmsanswer1_
		   " " _dsmsanswer2_ " " _dsmsanswer3_ " " _dsmsanswer4_))))

(foreign-lispfn
 lrvalidationgg ((Charstring gen) (Charstring exec) (Charstring hostname)) ((Boolean))
 (let* ((coord (open-socket nil 0))
	(coordno (socket-portno coord))
	dispatcher generator source1 source2
	peer2 answer1 answer2 answer3 answer4
	vali1 vali2 vali3 vali4)
   (register-amos 'lr-ns')
   (system (concat "start svali coord.dmp -o dispatcher(\'" hostname "\'," coordno ");"))
   (setq dispatcher (accept-socket coord nil))
   (setq source1 (read dispatcher))
   (setq _dsmssource_ source1)          ;; DSMS reads input stream
   (setq source2 (read dispatcher))
   (setq generator (read dispatcher))
   (setq _generator_ generator)         ;; Generator sends input stream
   (system (concat "start svali answer.dmp -o lrvali(\'" hostname "\'," coordno "," source2 ");"))
   (setq peer2 (accept-socket coord nil))
   (setq answer1 (read peer2))   ;; toll alert
   (setq answer2 (read peer2))   ;; accident alert
   (setq answer3 (read peer2))   ;; type 2 alert
   (setq answer4 (read peer2))   ;; type 3 alert
   (pf 'START peer2)
   (system (concat "start svali coord.dmp -o socketrecv(\'" hostname "\'," coordno "," answer1 ",2,3,1,{1,2},{4,5},{0,1},{2,3});"))
   (setq vali1 (accept-socket coord nil))
   (setq _dsmsanswer1_ (read vali1))
   (system (concat "start svali coord.dmp -o socketrecv(\'" hostname "\'," coordno "," answer2 ",1,2,0,{1,3},{4},{0,1},{2});"))
   (setq vali2 (accept-socket coord nil))
   (setq _dsmsanswer2_ (read vali2))
   (system (concat "start svali coord.dmp -o socketrecv(\'" hostname "\'," coordno "," answer3 ",1,2,1,{3},{5},{2},{4});"))
   (setq vali3 (accept-socket coord nil))
   (setq _dsmsanswer3_ (read vali3))
   (system (concat "start svali coord.dmp -o socketrecv(\'" hostname "\'," coordno "," answer4 ",1,2,0,{3},{4},{1},{2});"))
   (setq vali4 (accept-socket coord nil))
   (setq _dsmsanswer4_ (read vali4))
   (while (not (and (get-amos-info 'DSMS) (get-amos-info 'GEN)))
     (formatl t "make sure you have your peers DSMS and GEN registered in the name server and listening for incoming evaluations!!!" t)
     (sleep 5))
   (remote-eval
    `(system (concat "start " ,exec " " ,hostname " " ,_dsmssource_ " " ,_dsmsanswer1_
		   " " ,_dsmsanswer2_ " " ,_dsmsanswer3_ " " ,_dsmsanswer4_)) 'DSMS)     ;; start up the dsms
   (remote-eval
    `(system (concat "start " ,gen " " ,hostname " " ,_generator_)) 'GEN)))   ;; start up the generator

(foreign-lispfn
 generator ((Charstring hostname) (Integer out)) ((Integer))
 (let* ((sock (open-socket hostname out))
       (fh (openstream "cdp_mid15.out" "r"))
       (c (+ 1 (clock)))
       (stime c)
       (eof (mksymbol "*EOF*"))
       (trow -1)
       row)
   (while fh
     (setq row (read fh))
     (cond ((eq row eof)
	    (closestream fh)
	    (setq fh nil))
	   (t
	    (cond ((< trow (elt row 1))
		   (formatl t "debug use " trow " " (elt row 1) t)
		   (while (> c (clock))
		     (sleep 0.1))
		   (1++ trow)
		   (1++ c)))
	    (pf row sock))))
   (foreign-result (- c stime))))

;; the input stream is from file
(foreign-lispfn
 lrsocketio ((Charstring filename) (Charstring hostname) (Integer coordsock)) ((Number))
 (let* ((sock (open-socket hostname coordsock))  ;; open socket to communicate with coord
	;; open a vector of sockets to be general
	(sock1 (open-socket nil 0)) ;; open socket to send the tuples
	(sock2 (open-socket nil 0)) ;; another socket to send the tuples
	(fh (openstream filename "r"))
	(c (+ 1 (clock)))
	(stime c)
	(eof (mksymbol "*EOF*"))
	(trow -1)
	row)
   (pf (socket-portno sock1) sock)
   (pf (socket-portno sock2) sock)
   (if (not (equal (read sock) 'START)) (formatl t "Error Message when start!" t)
     (let ((outsock1 (accept-socket sock1 nil))  ;; socket for dsms
	   (outsock2 (accept-socket sock2 nil))) ;; socket for validation
       (while fh
	 (setq row (read fh))
	 (cond ((eq row eof)
		(closestream fh)
		(pf 'EOF outsock1)
		(pf 'EOF outsock2)
		(if (not (equal (read outsock2) 'STOP)) (formatl t "Error Message when stop 2!" t))
		;;(if (not (equal (read outsock1) 'STOP)) (formatl t "Error Message when stop 1!" t))
		(close-socket sock)
		;;(close-socket sock2)
		;;(close-socket sock1)
		(setq fh nil))
	       (t
		(cond ((< trow (elt row 1))
		       (formatl t "debug use " trow " " (elt row 1) t)
		       (pf (vector _ts_ (elt row 1)) outsock2)
		       (while (> c (clock))
			 (sleep 0.1))
		       (1++ trow)
		       (1++ c)))
		(pf row outsock1)
		(pf row outsock2))))))
   (foreign-result (- c stime))))


(foreign-lispfn
 dispatcher ((Charstring hostname) (Integer coordsock)) ((Number))
 (let* ((sock (open-socket hostname coordsock))
	(in (open-socket nil 0))
	(out1 (open-socket nil 0))
	(out2 (open-socket nil 0))
	(startt (clock))
	(trow -1)
	insock outsock1 outsock2 r)
   ;; register the in and out sockets in coordinator
   (pf (socket-portno out1) sock)
   (pf (socket-portno out2) sock)
   (pf (socket-portno in) sock)
   (setq outsock1 (accept-socket out1 nil))
   (setq outsock2 (accept-socket out2 nil))
   (setq insock (accept-socket in nil))
   (while insock
     (setq r (read insock))
     (cond ((eq r 'EOF)
	    (close-socket insock)
	    (setq insock nil)
	    (pf 'EOF outsock1)
	    (pf 'EOF outsock2)
	    (if (not (equal (read outsock2) 'STOP)) (formatl t "Error Message when stop 2!" t)))
	   (t
	    (cond ((< trow (elt r 1))
		   (pf (vector _ts_ (elt r 1)) outsock2)
		   (1++ trow)))
	    (pf r outsock1)
	    (pf r outsock2))))
   (foreign-result (- (clock) stime))))
 

;; put merge.lsp to be one
(foreign-lispfn
 socketmerge ((Charstring hostname) (Integer coordno) (Integer answer1)) ((Vector))
 (let ((sock (open-socket hostname coordno))
       (dsms (open-socket nil 0))
       dsmssock answer)
   (pf (socket-portno dsms) sock)
   (setq dsmssock (accept-socket dsms nil))
   (setq answer (open-socket hostname answer1))
   (let* ((producers (vector answer dsmssock)))
     (while (somea producers (f/l (producer i) producer))
       (maparray producers
		 (f/l
		  (socket i)
		  (let ((r (read socket)))
		    (cond ((eof? r)
			   (seta producers i nil))
			  (t
			   (formatl t "from " socket " " r t)
			   (foreign-result r))))))))))

(foreign-lispfn
 socketrecv ((Charstring hostname) (Integer coordno) (Integer answerno)
             (Integer dsmstspos) (Integer responpos) (Integer awtspos)
	     (Vector dsmskey) (Vector dsmsvalue)
	     (Vector awkey) (Vector awvalue))
            ((Vector))
 (let ((sock (open-socket hostname coordno))
       (dsms (open-socket nil 0))
       (awhs (make-hash-table :test (function equal)))
       dsmssock answer ts dsmsr awr)
   (pf (socket-portno dsms) sock)
   (setq dsmssock (accept-socket dsms nil))  ;; wait dsms starts to send result
   (setq answer (open-socket hostname answerno)) ;; read from answers
   (while answer
     (let ((awr (read answer)))
       ;;(formatl t awr t)
       (cond ((localts? awr)
	      (formatl t "new time: " awr t)
	      (if (> (hash-table-count awhs) 0)
		  (progn
		    (if (not dsmsr) 
			(if (poll-socket dsmssock 1) (setq dsmsr (read dsmssock))
			  (formatl t #("delayed response or socket closed?") t)))
		    (while (> ts (selt dsmsr dsmstspos))
		      (formatl t (vector "delayed response: " dsmsr) t)
		      (if (poll-socket dsmssock 5) (setq dsmsr (read dsmssock)) (progn (formatl t #("fatal delay!") t) ;; todo: close socket
										       (return #(-1)))))
		    (while (equal ts (selt dsmsr dsmstspos)) ;; the position of the time stamp
		      (if (delayresponse dsmsr dsmstspos responpos) (formatl t (vector "delayed response!" dsmsr) t))  ;; check response time
		      (let* ((key (projectv dsmsr dsmskey))
			     (value (gethash key awhs)))
			(cond (value
			       (if (list-in (projectv dsmsr dsmsvalue) value)
				   (remhash key awhs)
				 (formatl t  (vector "wrong result: " dsmsr) t)))
			      (t
			       (formatl t (vector "false alarm: " dsmsr) t))))
		      (if (poll-socket dsmssock 5) (setq dsmsr (read dsmssock)) (progn (formatl t #("delayed response?"))
										       (setq dsmsr nil))))
		    (maphash (f/l (key val) (formatl t (vector "missed result: " key val) t)) awhs)))
	      (setq awhs (make-hash-table :test (function equal)))
	      (setq ts (elt awr 1)))  ;; update time stamp
	     ((equal 'EOF awr)
	      (pf 'STOP answer)
	      (close-socket answer)
	      (close-socket sock)
	      (setq answer nil))
	     (t
	      (let* ((key (projectv awr awkey))
		     (value (gethash key awhs)))
		(setf (gethash key awhs) (cons (projectv awr awvalue) value)))))))))



(defun delayresponse (v po1 po2)
  (and (arrayp v)
       (> (- (elt v po2) (elt v po1)) 5)))


(defun projectv (v ind)
  (catch 'project
    (let (res (dim (length v)))
      (maparray ind (f/l (vi i)
			 (cond ((and (numberp vi)
				     (>= vi 0)
				     (< vi dim)
				     (aref v vi))
				(push (aref v vi) res))
			       (t (throw 'project nil)))))
      (listtoarray (nreverse res))))) 

(defun list-in (e l)
  (catch 'list-in
    (mapc (f/l (el) (if (equal e el) (throw 'list-in T))) l))) 




























