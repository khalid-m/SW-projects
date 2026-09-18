;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013 Cheng Xu, UDBL
;;; $RCSfile: q1.lsp,v $
;;; $Revision: 1.2 $ $Date: 2013/04/20 21:53:31 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: LISP implementation of q1
;;; =============================================================
;;; $Log: q1.lsp,v $
;;; Revision 1.2  2013/04/20 21:53:31  chexu484
;;; q1 takes care of breaks
;;;
;;; Revision 1.1  2013/04/11 22:29:36  chexu484
;;; q1a_addfn() written in lsp, prove to be 3 time faster!
;;;
;;;
;;; =============================================================

(defun isleftsensor (sid)
  (member sid '(13 97 47 49 19 53 23 57 59
                61 99 63 65 67 69 71 73 75 105)))

(defun isrightsensor (sid)
  (member sid '(14 98 16 88 52 54 24 58 28
	        62 100 64 66 68 38 40 74 44 106)))

(defun set-a (a inx v)
  (seta a inx v))

(defun q1aadd-- (fno res e r)
  (cond ((= -1 (na-elt e 1))
	 (if (= -2 (na-elt e 2))	     
	     (setq _break_ 1)))
	(t
	 (let* ((sid (floor (na-elt e 1)))
		(pid (playersensor sid))
		(ts (na-elt e 0))
		(speed (na-elt e 5))
		(pstats (elt res (1- pid)))
		(count (elt pstats 11))
		(fleftflag (elt pstats 12))
		(frightflag (elt pstats 13)))
	   (cond ((and (= -1 fleftflag)
		       (isleftsensor sid))
		  (set-a pstats 2 (x e))
		  (set-a pstats 3 (y e))
		  (set-a pstats 12 1)))
	   (cond ((and (= -1 frightflag)
		       (isrightsensor sid))
		  (set-a pstats 4 (x e))
		  (set-a pstats 5 (y e))
		  (set-a pstats 13 1)))
	   (cond ((isleftsensor sid)
		  (set-a pstats 6 (x e))
		  (set-a pstats 7 (y e))))
	   (cond ((isrightsensor sid)
		  (set-a pstats 8 (x e))
		  (set-a pstats 9 (y e))))
	   (cond ((= -1 count)
		  (setq count 0)
		  (set-a pstats 0 ts)
		  (set-a pstats 10 0)))
	   (set-a pstats 1 ts)
	   (set-a pstats 10 (+ speed (elt pstats 10)))
	   (set-a pstats 11 (1+ count))))))


(defun strIntensity (intensity)
  (cond ((= 0 intensity) "stop")
	((= 1 intensity) "trot")
	((= 2 intensity) "low")
	((= 3 intensity) "medium")
	((= 4 intensity) "high")
	((= 5 intensity) "sprint")))

(defun q1logger--+ (fno file b r)
  (with-output-file
   s file
   (mapbag b (f/l (row)
		  (if (= (length (car row)) 6)
		      (let ((new (copy-array (car row))))
			(seta new 3 (strIntensity (elt new 3)))
			(write-csv-line new s)))
                  (osql-result file b (car row))))
   t))

 (osql "create function q1loggerb(Charstring file, Bag rows) -> Bag of Object
        as foreign 'q1logger--+';")

 (osql "create function q1logger(Charstring file, Stream rows) -> Stream
        as streamof(q1loggerb(file, cast(rows as Bag)));")