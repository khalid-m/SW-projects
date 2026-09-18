;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2005 Ruslan Fomkin, UDBL
;;; $RCSfile: babysitter.lsp,v $
;;; $Revision: 1.7 $ $Date: 2005/04/12 07:18:53 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  
;;;              
;;; ===========================================================================

(defvar _db-name_ nil)

(foreign-lispfn dbname()((charstring name))
				(foreign-result _db-name_))

(defun run-babysitter (fno dbpeer res)
  (loop
	(setq _db-name_ dbpeer)
	(osql "newsubmission(dbname());")
	(system "sleep 20")
	(osql "newsubmission(dbname());")
	(system "sleep 20")
	(osql "newsubmission(dbname());")
	(system "sleep 20")
	(osql "newsubmission(dbname());")
	(system "sleep 20")
	(osql "checkandget(dbname());")
	(osql "ship(dbname(),\"save \\\"current.dmp\\\";\");")
	(osql "ship(dbname(),\"unload(\\\"current.osql\\\");\");")
	))