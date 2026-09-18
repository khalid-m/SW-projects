;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2005 Ruslan Fomkin, UDBL
;;; $RCSfile: nginteract.lsp,v $
;;; $Revision: 1.2 $ $Date: 2005/03/22 09:27:17 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Help functions for interacting with NG/ARC-client. Mainly parsing files
;;; where results of execution of NG/ARC commands are saved.
;;;              
;;; ===========================================================================

; Parses file that produced by ngstat. Finds which job are there and they 
; current status.
(defun get-status (fno file job status)
  (open-read-file file)
  (loop
	(let (cur)
	  (setq cur (mkstring (read-read-file)))
		 (do () 
			 ((or (equal cur "*EOF*") (equal cur "JOB")))
		   (setq cur (mkstring (read-read-file)))
		   )
		 (if (equal cur "*EOF*") (return cur) ())
		 (setq job (mkstring (read-read-file)))
		 (do () 
			 ((or (equal cur "*EOF*") (equal cur "STATUS:")))
		   (setq cur (mkstring (read-read-file)))
		   )
		 (if (equal cur "*EOF*") (return cur) ())
		 (setq status (mkstring (read-read-file)))
		 (osql-result file job status)
		 ))
  (close-readfile))

; Parses file that produced by ngsubmit. Finds jobid of the submitted job.
(defun get-jobid (fno file jobid)
  (open-read-file file)
  (let (cur)
	(setq cur (mkstring (read-read-file)))
	(do () ((or (equal cur "*EOF*") (equal cur "JOBID")))
	  (setq cur (mkstring (read-read-file))))
	(if (equal cur "*EOF*") ()
	  (osql-result file (mkstring (read-read-file)))))
  (close-readfile))

; Parses file that produced by ngget. Finds the name of a directory where 
; result of the job is downloaded.
(defun get-jobdir (fno file dir)
  (open-read-file file)
  (let (cur)
	(setq cur (mkstring (read-read-file)))
	(do () ((or (equal cur "*EOF*") (equal cur "TO")))
	  (setq cur (mkstring (read-read-file))))
	(if (equal cur "*EOF*") ()
	  (osql-result file (mkstring (read-read-file)))))
  (close-readfile))

(defun get-etime (fno file exec)
  (open-read-file file)
  (let (cur)
	(setq cur (mkstring (read-read-file)))
	(do () ((or (equal cur "*EOF*") (equal cur "TRUE")))
	  (setq cur (mkstring (read-read-file))))
	(if (equal cur "*EOF*") ()
	(osql-result file (mkstring (read-read-file))))))

(defun get-ltime (fno file load)
  (open-read-file file)
  (let (cur)
	(setq cur (mkstring (read-read-file)))
	(do () ((equal cur "*EOF*"))
	  (if (equal cur "25000")
		  (osql-result file (mkstring (read-read-file))))
	  (setq cur (mkstring (read-read-file))))
	))

;(defun get-etime (fno file load exec)
 ; (open-read-file file)
  ;(let (cur (cload 0.0))
	;(setq cur (mkstring (read-read-file)))
;	(do () ((or (equal cur "*EOF*") (equal cur "TRUE")))
	;  (do () ((or (equal cur "*EOF*") (equal cur "TRUE") (equal cur "25000")))
		;(setq cur (mkstring (read-read-file)))
;		(print cur))
	;  (if (equal cur "*EOF*") ()
		;(if (equal cur "25000")
;			;((print cur)
			 ;(setq cload (+ cload (read-read-file)))
;			 )))
	;(if equal cur "*EOF*") ()
;	(osql-result file (mkstring cload) (mkstring (read-read-file)))))

;(defun get-etime (fno file load exec)
 ; (open-read-file file)
  ;(let (cur (cload ""))
	;(setq cur (mkstring (read-read-file)))
;	(do () ((or (equal cur "*EOF*") (equal cur "TRUE")))
	;  (do () ((or (equal cur "*EOF*") (equal cur "TRUE") (equal cur "25000")))
		;(setq cur (mkstring (read-read-file))))
;	  (if (equal cur "*EOF*") ()
	;	(if (equal cur "25000")
		;	((setq cur (mkstring (read-read-file)))
			; (concat cload cur " ")))))
;	(if equal cur "*EOF*") ()
	;(osql-result file cload (mkstring (read-read-file)))))
