;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2005 Ruslan Fomkin, UDBL
;;; $RCSfile: coordinatorserver.lsp,v $
;;; $Revision: 1.1 $Date: 2005/08/05 08:24:51 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Help functions required for coordinatorserver.osql
;;;              
;;; ===========================================================================

;; The partitioning function is implemented in procedural way. It can be
;; implemented in functional way also.
(defun create-jobs (fno submission jobs sum-file-size files)
  "Create jobs's number of job objects for submission containing files 
number of eventdata object with total size sum-file-size events. 
Partitioning of files between jobs is done in such way that each job 
contains equal number of events except last one. It can contain few jobs if
number of files and jobs are not dividable. All created jobs are added to
the database to the submission."
  (let ((job-size (+ (/ sum-file-size jobs)
					 (if (> (mod sum-file-size jobs) 0) 1 0)))
		(current-file 0)(all-files (getfunction 'data (list submission)))
		(job-oid (/createobject 'job)))
	(addfunction 'jobs (list submission) (list job-oid))
	(do* ((current-job 1)(job-rest job-size)
		  (file-position 0)
		  (file-oid (first (nth current-file all-files)))
		  (file-size (caar (getfunction 'size (list file-oid)))))
		((>= current-file files))
	  (cond
	   ((= job-rest (- file-size file-position))
		(addfunction 'data (list job-oid) 
					 (list (listtoarray 
							(list file-oid file-position (1- file-size)))))
		(setq current-job (1+ current-job))
		(setq job-rest job-size)
		(cond ((>= jobs current-job)
			   (setq job-oid (/createobject 'job))
			   (addfunction 'jobs (list submission) (list job-oid))))
		(setq current-file (1+ current-file))
		(setq file-position 0)
		(cond ((< current-file files)
			   (setq file-oid (first (nth current-file all-files)))
			   (setq file-size (caar (getfunction 'size (list file-oid))))))
		)
	   ((> job-rest (- file-size file-position))
		(addfunction 'data (list job-oid)
					 (list (listtoarray
							(list file-oid file-position (1- file-size)))))
		(setq job-rest (- job-rest (- file-size file-position)))
		(setq current-file (1+ current-file))
		(setq file-position 0)
		(cond ((< current-file files)
			   (setq file-oid (first (nth current-file all-files)))
			   (setq file-size (caar (getfunction 'size (list file-oid))))))
		)
	   (t
		(addfunction 'data (list job-oid)
					 (list (listtoarray
							(list file-oid file-position 
								  (+ file-position (1- job-rest))))))
		(setq file-position (+ file-position job-rest))
		(setq current-job (1+ current-job))
		(setq job-rest job-size)
		(cond ((>= jobs current-job)
			   (setq job-oid (/createobject 'job))
			   (addfunction 'jobs (list submission) (list job-oid))))
		)
	   ))))