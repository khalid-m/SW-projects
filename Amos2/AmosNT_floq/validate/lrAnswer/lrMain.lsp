
(defglobal _tollalert_ nil)
(defglobal _accalert_ nil)
(defglobal _type2_ nil)
(defglobal _type3_ nil)

(foreign-lispfn
 lrreadsocket ((Charstring hostname) (Integer coordno) (Integer source2)) ((Vector of Integer))
 (let ((sock (open-socket hostname coordno))
       ;; open four sockets to send the result
       (answer1 (open-socket nil 0))
       (answer2 (open-socket nil 0))
       (answer3 (open-socket nil 0))
       (answer4 (open-socket nil 0)) row insock)
   (pf (socket-portno answer1) sock)
   (pf (socket-portno answer2) sock)
   (pf (socket-portno answer3) sock)
   (pf (socket-portno answer4) sock)
   (if (not (equal (read sock) 'START)) (formatl t "Error Message when start to read!" t)
     (progn (setq _tollalert_ (accept-socket answer1))
	    (setq _accalert_ (accept-socket answer2))
	    (setq _type2_ (accept-socket answer3))
	    (setq _type3_ (accept-socket answer4))
	    (setq insock (open-socket hostname source2))
	    (while (not (equal 'EOF (setq row (read insock))))
	      (foreign-result row))
	    (pf 'STOP insock)
	    (pf 'EOF _tollalert_)
	    (pf 'EOF _accalert_)
	    (pf 'EOF _type2_)
	    (pf 'EOF _type3_)
	    (if (equal 'STOP (read _tollalert_)) (close-socket answer1) (error "exception when closing toll alert socket!"))
	    (if (equal 'STOP (read _accalert_)) (close-socket answer2) (error "exception when closing accident alert socket!"))
	    (if (equal 'STOP (read _type2_)) (close-socket answer3) (error "exception when closing account balance socket!"))
	    (if (equal 'STOP (read _type3_)) (close-socket answer4) (error "exception when closing daily expenditure socket!"))
	    (close-socket sock)
	    (close-socket insock)))))

(foreign-lispfn
 broadcast ((vector x)) ((boolean))
 (pf x _tollalert_)
 (pf x _accalert_)
 (pf x _type2_)
 (pf x _type3_))

(foreign-lispfn
 swtoll ((vector x)) ((boolean))
 (pf x _tollalert_))

(foreign-lispfn
 swaccident ((vector x)) ((boolean))
 (pf x _accalert_))

(foreign-lispfn
 swtype2 ((Integer vid) (Integer sec) (Integer qid) (Bag b)) ((Boolean))
		(mapbag b (f/l (ob) (pf (vector vid sec qid (car ob) (cadr ob)) _type2_))))

(foreign-lispfn
 swtype3 ((vector x)) ((boolean))
 (pf x _type3_))