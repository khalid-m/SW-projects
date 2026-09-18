;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2005 Ruslan Fomkin, UDBL
;;; $RCSfile: exchange.lsp,v $
;;; $Revision: 1.1 $ $Date: 2005/09/10 14:00:02 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Functions to exchange event object between executor and client. Naive
;;;  implementation.
;;;              
;;; ===========================================================================

(defun aleh-print(fno obj res)
  (cond 
   ((equal 'EVENT (getobject (caar (getfunction 'TYPEOF (list obj))) 'NAME))
	(prin1 "EVENT" *mystream*)
	(prin1 (caar (getfunction 'ID (list obj))) *mystream*)
	(print (caar (getfunction 'FILE (list obj))) *mystream*))
   (t (print obj *mystream*))))

(defvar *alehfile* nil)

(defun open-alehfile (fno file res)
  (setq *alehfile* (openstream (mkstring file) "r")))

(defun close-alehfile (fno res)
  (closestream *alehfile*))

(defun aleh-read(fno res)
  (let ((exp (read *alehfile*))(obj nil))
	(cond
	 ((equal exp "EVENT")
	  (setq id (read *alehfile*))
	  (setq file (read *alehfile*))
	  (cond 
	   ((not (getfunction 'event (list id file)))
		(setq obj (/createobject 'event))
		(addfunction 'id (list obj) (list id))
		(addfunction 'file (list obj) (list file))
		(osql-result obj))))
	 (t (osql-result exp)))))
