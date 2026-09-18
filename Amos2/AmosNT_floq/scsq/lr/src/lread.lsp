;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Erik Zeitler, UDBL
;;; $RCSfile: lread.lsp,v $
;;; $Revision: 1.36 $ $Date: 2011/12/29 17:28:30 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Reader and logger of LR events as foreign functions
;;; =============================================================
;;; $Log: lread.lsp,v $
;;; Revision 1.36  2011/12/29 17:28:30  jaba9649
;;; Correcting the tslrhoho function to print the QID in the right place
;;;
;;; Revision 1.35  2010/06/20 14:34:15  fred2431
;;; Introduce function lrmulf that multiplies a multiarray of LR input events with a float number
;;;
;;; Revision 1.34  2010/05/24 14:13:40  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.33  2010/05/21 09:07:29  zeitler
;;; lrmultiply in lisp
;;; test of lrmultiply
;;;
;;; Revision 1.32  2010/05/10 16:24:21  zeitler
;;; lrmultiply(iarray input, integer inputl, integer multiplier)
;;;
;;; Revision 1.31  2009/12/09 10:00:22  zeitler
;;; Heartbeats
;;;
;;; Revision 1.30  2009/11/23 16:52:28  fred2431
;;; adding non-working timestamp code for daily expenditure queries in LR.
;;; lread: fix compilation.
;;;
;;; Revision 1.29  2009/11/12 14:54:59  zeitler
;;; nodelayemit() osql
;;;
;;; Revision 1.28  2009/10/15 21:01:05  zeitler
;;; tslr() time stamping of conventional vectors in LR
;;;
;;; Revision 1.27  2009/09/16 14:22:26  zeitler
;;; optimized test data generator
;;;
;;; Revision 1.26  2009/09/16 13:34:55  zeitler
;;; foreign function generating test numarray data
;;;
;;; Revision 1.25  2009/09/10 20:39:32  zeitler
;;; lr comm testdata with increment
;;;
;;; Revision 1.24  2009/05/19 15:15:12  zeitler
;;; out of band bcast topology
;;;
;;; Revision 1.23  2009/05/12 18:10:14  zeitler
;;; adjustable broadcast fraction in lreadbin
;;;
;;; Revision 1.22  2009/05/07 09:39:11  zeitler
;;; writefile[s] moved to standard SCSQ
;;;
;;; Revision 1.21  2009/05/06 21:05:46  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.20  2009/05/06 18:07:21  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.19  2009/05/04 15:56:47  zeitler
;;; timestamplrbin
;;;
;;; Revision 1.18  2009/03/09 17:07:49  zeitler
;;; more xways in generator
;;;
;;; Revision 1.17  2009/03/05 16:21:19  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.16  2008/12/22 15:08:54  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.15  2008/11/24 23:09:56  zeitler
;;; Fixed closestream bug in writefiles
;;;
;;; Revision 1.14  2008/09/07 08:17:42  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.13  2008/05/07 18:02:36  zeitler
;;; LR with PS
;;;
;;; Revision 1.12  2008/04/25 15:41:29  zeitler
;;; - lread-several spools into any point in time
;;; - fullr (in runfull.osql): run a full lr
;;;
;;; Revision 1.11  2008/04/25 15:33:23  zeitler
;;; writefiles:
;;; - automatic on line splitting when writing files greater than 2GB.
;;; - output file name = filename + chunk number
;;;
;;; Revision 1.10  2008/04/22 21:53:55  zeitler
;;; timestamps compensated in pre-emitting lread
;;;
;;; Revision 1.9  2008/04/22 12:22:37  zeitler
;;; - detailed time measurements
;;; - pre-emitting lread
;;;
;;; Revision 1.8  2008/04/17 22:15:45  zeitler
;;; Improved timestamping
;;;
;;; Revision 1.7  2008/04/09 17:03:45  zeitler
;;; lreadloop in infinite loop
;;;
;;; Revision 1.6  2008/03/26 13:36:53  zeitler
;;; linear road: read multiple input files (solving 2 GB file size problem)
;;;
;;; Revision 1.5  2008/02/04 17:47:01  zeitler
;;; - Fully streamed LR.
;;; - tdiff() replaced by real(). Faster file writes and less state kept.
;;;
;;; Revision 1.4  2007/12/18 20:55:35  masv3245
;;; minor updates
;;;
;;; Revision 1.3  2007/12/12 13:14:50  torer
;;; New function writefile(Charstring filenamen, Bag b)->Charstring to write streams
;;;
;;; Revision 1.2  2007/11/13 14:19:40  torer
;;; Code cleanup
;;;
;;; =============================================================

(defun secondstep (filename fh c)
  (let (trow)
    (while fh
      (let ((row (read fh)))
	(if (not trow) (setq trow (elt row 1)))
	(cond ((eq row '*EOF*)
	       (closestream fh)
	       (setq fh nil))
	      (t
	       (cond ((< trow (elt row 1))
		      (osql-result filename
				   (push-vector row (+ 1 (rnow))))
		      (while (> c (clock))
			(sleep 0.1))
		      (1++ trow)
		      (1++ c))
		     (t
		      (osql-result
		       filename (push-vector row (rnow)))))))))
    trow))

(defun lread-one (fno filename)
  (let ((fh (openstream filename "r"))
	(c (+ 1 (clock))))
    (secondstep filename fh c)))

(osql "create function lread0(charstring filename)->vector of integer
         as foreign 'lread-one';")

(defun herald (value)
  (listtoarray (append (list 4 value) (buildn 13 -1) (list (rnow)))))

(defun lread-several (fno filenames)
  (let ((c (+ 1 (clock)))
	(trow 0)
	row fh)
    (mapcar (f/l (filename)
		 (setq fh (openstream filename "r"))
		 (while fh
		   (let ((row (read fh)))
		     (cond ((eq row '*EOF*)
			    (closestream fh)
			    (setq fh nil))
			   (t
			    (cond ((< (+ 1 trow) (elt row 1))
				   (setq trow (elt row 1))
				   (osql-result filenames
						(herald (elt row 1)))))
			    (cond ((< trow (elt row 1))
				   (osql-result filenames
						(push-vector row (+ 1 (rnow))))
				   (while (> c (clock))
				     (osql-result filenames
						  (herald (elt row 1)))
				     (sleep 0.1))
				   (1++ trow)
				   (1++ c))
				  (t
				   (osql-result
				    filenames (push-vector row (rnow))))))))))
	    (arraytolist filenames))))

(osql "create function lread0(vector of charstring filename)->vector of integer
         as foreign 'lread-several';")

(defun corr-bcast (desired-fraction)
; 990/995 tpls are position reports.
; 5/995 tpls are account balance queries (to be broadcasted).
; use corr-bcast with desired fraction to determine how many times the 
; broadcast of each account balance query should be repeated
; to achieve the desired fraction of broadcasts.
  (/ (* 990 (/ desired-fraction (- 1.0 desired-fraction))) 5))

(defun binomial (p)
  (or (and (equal p 0.0) 0)
      (/ (+ 1 (compare p (random 1000))) 2)))

(defun adjusted-emit (filenames adj rt row bc-factor rnd)
  (cond ((eq (na-elt row 0) 2)
	 (let ((count (or bc-factor (binomial rnd))))
	   (dotimes (i count)
	     (osql-result filenames adj rt row))))
	(t
	 (osql-result filenames adj rt row))))

(defun lreadbins0adj (fno filenames adj rt)
  (let ((current (+ 1 (clock)))
	(trow 0) (nrow 0)
	(realtime (eq rt 1))
	row rnd bc-factor)
    (cond ((< adj 0.0)
	   (setq bc-factor 1))
	  ((< (setq bc-factor (corr-bcast adj)) 1.0)
	   (setq rnd (* 1000 bc-factor))
	   (setq bc-factor nil))
	  (t (setq bc-factor (round bc-factor))))
    (mapcar
     (f/l 
      (filename)
      (with-open-file
       (fh filename)
       (while (neq (setq row (read fh)) '*EOF*)
	 (if (> (na-elt row 1) (+ 1 trow)) ; > 1 second diff =>
	     (setq trow (na-elt row 1)))   ; warp
	 (cond ((> (na-elt row 1) trow)
		(adjusted-emit filenames adj rt row bc-factor rnd)
		(1++ nrow)
		(if realtime
		    (while (> current (clock))
		      (sleep 0.1)))
		(1++ trow)
		(1++ current))
	       (t
		(adjusted-emit filenames adj rt row bc-factor rnd)
		(1++ nrow))))))
     (arraytolist filenames))))

(osql "create function lreadbins0adj(vector of charstring, real, integer)
-> iarray  as foreign 'lreadbins0adj';

create function lreadbinsadj(vector of charstring v, real adj, 
                                    integer rt) -> stream of iarray
as streamof(lreadbins0adj(v, adj, rt));

create function lreadbins(vector of charstring v)->stream of iarray
as streamof(lreadbins0adj(v, -1.0, 1));

create function lreadfastbins(vector of charstring v)->stream of iarray
as streamof(lreadbins0adj(v, -1.0, 0));

create function lreadfastbin(charstring c)->stream of iarray
as streamof(lreadbins0adj({c}, -1.0, 0));")

(defun lreadloop (fno filename)
  (let ((fh (openstream filename "r"))
	(c (+ 1 (clock)))
	(trow 0)
	row)
    (secondstep filename fh c)))

(defun timestamplrbin (fno v res)
  (let* ((res (copy-numarray v))
	 (tindex (- 3 (compare (na-elt v 0) 0.0))))
    (na-seta res tindex (rnow))
    (osql-result v res)))

(osql "create function timestamplrbin(darray)->darray
         as foreign 'timestamplrbin';")

(defun tslr-+ (fno v res)
  (let* ((res (copy-array v))
	 (tindex (- 3 (compare (elt v 0) 0.0))))
    (seta res tindex (rnow))
    (osql-result v res)))

(osql "create function tslr(vector of number)->vector of number
         as foreign 'tslr-+';")

(defun tslrhoho-+ (fno v res)
  (let* ((res (copy-array v))
	 (tindex (- 3 (compare (elt v 0) 0.0))))
    (seta res tindex (rnow))
    (osql-result v res)))

(osql "create function tslrhoho(vector)->vector of number
         as foreign 'tslrhoho-+';")

(defun destructive_tslrbin (fno v res)
  (let ((tindex (- 3 (compare (na-elt v 0) 0.0))))
    (na-seta v tindex (rnow))
    (osql-result v v)))

(osql "create function dtslrbin(darray)->darray
         as foreign 'destructive_tslrbin';")

(defun naseta---+ (fno v index value res)
  (let ((res (copy-numarray v)))
    (osql-result v index value (na-seta res index value))))

(osql "create function na_seta(numarray v, integer index, number value)
       -> numarray as foreign 'naseta---+';")

(defun get-lroutput-files (dir filenamestart)
  (let (fl1)
    (osql-declare charstring :lroutputdir)
    (osql-declare charstring :lrfilemask)
    (setq amos_lroutputdir dir)
    (setq amos_lrfilemask (concat filenamestart "?"))
    (setq
     fl1 (arraytolist (caar (osql "sort(dir(:lroutputdir, :lrfilemask));"))))
    (setq amos_lrfilemask (concat filenamestart "??"))
    (setq
     fl1
     (append
      fl1
      (arraytolist (caar (osql "sort(dir(:lroutputdir, :lrfilemask));")))))
    (mapcar (f/l (x) (concat dir "/" x)) fl1)))

(defun process-lrstat (filelist outfile tmin sampling-rate)
  (with-output-file
   outstream outfile
   (let ((sample-counter 0)
	 (row-counter 0))
     (mapcar
      (f/l
       (infile)
       (with-input-file 
	instream infile
	(let (row)
	  (while (neq (setq row (read instream)) '*EOF*)
	    (1++ sample-counter)
	    (if (equal sample-counter sampling-rate)
		(progn (setq sample-counter 0)
		       (1++ row-counter)
		       (formatl
			outstream
			(na-elt row 2) " "
			(- (na-elt row 3) (+ tmin (na-elt row 2))) t)))))))
      filelist)
     row-counter)))

(defun plrstat (fno indir infile outfile tmin sampling-rate)
  (osql-result
   indir infile outfile tmin sampling-rate
   (process-lrstat (get-lroutput-files indir infile)
		   outfile tmin sampling-rate)))

(osql "create function
plrstat(charstring indir, charstring infile, charstring outfile, real tmin,
        integer samplingrate)->integer as foreign 'plrstat';")

(osql "create function i_hybrid_ann_foreign(integer L, integer promille, 
       integer rep) -> iarray as foreign 'ann-hybrid';")

(defun ann-hybrid (fno xways promille rep res)
  (rptq rep
	(mapc (f/l (x)
		   (osql-result xways promille rep (na-enum (car x) 1)))
	      (getfunction 'lrinp_hybrid (list xways promille)))))


(foreign-lispfn
 nodelayemit () ((boolean))
 (delay-emit nil)
)

(defun lrmultiplybbbf (fno b inputl multiplier res)
  (mapbag b
	  (f/l (x)
	       (let ((tpl (copy-numarray (car x))))
		 (cond ((equal 0 (na-elt tpl 0))
			(dotimes (i multiplier)
			  (osql-result b inputl multiplier (copy-numarray tpl))
			  (na-seta tpl 2 (+ (na-elt tpl 2) (* inputl 140000)))
			  (na-seta tpl 4 (+ (na-elt tpl 4) inputl))))
		       ((equal 2 (na-elt tpl 0))
			(dotimes (i multiplier)
			  (osql-result b inputl multiplier (copy-numarray tpl))
			  (na-seta tpl 2 (+ (na-elt tpl 2) (* inputl 140000)))
			  (na-seta tpl 9 (+ (na-elt tpl 9)
					    (* inputl 125000)))))
		       ((equal 3 (na-elt tpl 0))
			(dotimes (i multiplier)
			  (osql-result b inputl multiplier (copy-numarray tpl))
			  (na-seta tpl 2 (+ (na-elt tpl 2) (* inputl 140000)))
			  (na-seta tpl 9 (+ (na-elt tpl 9)
					    (* inputl 125000)))))
		       ((equal 4 (na-elt tpl 0))
			(dotimes (i multiplier) ; just repeat type 4 queries
			  (osql-result b inputl multiplier tpl))))))))

(osql "create function
lrmultiply(bag of iarray input, integer inputl, integer multiplier)
 -> iarray as foreign 'lrmultiplybbbf';")

(osql "create function
clrmultiply(iarray input, integer inputl, integer multiplier)
 -> iarray as foreign 'clrmulbbbf';")

(osql "create function
clrmultiplyf(iarray input, integer inputl, real multiplier)
 -> iarray as foreign 'clrfmulbbbf';")

;; init_fh, wstat, waccident, wtoll, wtype2, and wtype3 are part of the
;; publicly downloadable scsq-lr.

(defglobal _tollalert-fh_ nil)
(defglobal _acc-alert-fh_ nil)
(defglobal _type2-fh_ nil)
(defglobal _type3-fh_ nil)
(defglobal _stat-fh_ nil)

(foreign-lispfn 
 init_fh () ((boolean))
 (setq _tollalert-fh_ 
       (openstream
	(concat "o-tollalert" (if (stringp _amosid_) _amosid_ "")) "w"))
 (setq _acc-alert-fh_ 
       (openstream
	(concat "o-acc-alert" (if (stringp _amosid_) _amosid_ "")) "w"))
 (setq _type2-fh_
       (openstream
	(concat "o-t2" (if (stringp _amosid_) _amosid_ "")) "w"))
 (setq _type3-fh_
       (openstream
	(concat "o-t3" (if (stringp _amosid_) _amosid_ "")) "w"))
 (setq _stat-fh_
       (openstream
	(concat "o-stat" (if (stringp _amosid_) _amosid_ "")) "w")))

(foreign-lispfn close_fh () ((boolean))
		(closestream _tollalert-fh_)
		(closestream _acc-alert-fh_)
		(closestream _type2-fh_)
		(closestream _type3-fh_)
		(closestream _stat-fh_))

(foreign-lispfn wstat ((vector x)) ((boolean))
		(print x _stat-fh_))

(foreign-lispfn waccident ((vector x)) ((boolean))
		(print x _acc-alert-fh_))

(foreign-lispfn wtoll ((vector x)) ((boolean))
		(print x _tollalert-fh_))

(foreign-lispfn wtype2 ((vector x)) ((boolean))
		(print x _type2-fh_))

(foreign-lispfn wtype3 ((vector x)) ((boolean))
		(print x _type3-fh_))
