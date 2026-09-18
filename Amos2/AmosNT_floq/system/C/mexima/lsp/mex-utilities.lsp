;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Thanh Truong, UDBL
;;; $RCSfile: mex-utilities.lsp,v $
;;; $Revision: 1.2 $ $Date: 2011/12/24 11:43:50 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Utilities
;;; =============================================================
;;; $Log: mex-utilities.lsp,v $
;;; Revision 1.2  2011/12/24 11:43:50  thatr500
;;; cleaned up according to the new design
;;;
;;; Revision 1.1  2011/12/02 12:48:07  thatr500
;;; MEXIMA utilities
;;;
;;;
;;; =============================================================

(defun not-yet-implfn (fno &optional arg res)
  (error (concat (concat "Foregin function " (generic-fnname fno))
		 " is not yet implemented!!")))

(defun amosindexes-of-kind (fno kind &optional noerror)
  "Return a list of the indexes of a given kind associated with FNO"
  (cond ((relationp fno);; FNO must be a relation
	 (subset (relation-indexes fno);; All indexes of relation FNO
		 (f/l (i)(eq (index-type i);; INDEX-TYPE is kind of an index
			     kind))))
        (noerror nil);; return NIL if NOERROR flag true and no index found
        (t (amos-error fno " has no " kind " index"))))

(defun getlatestresolvent (fname) 
  "Return the most recent resolvent of a given function name."
  (car (resolvents (getfunctionnamed fname t))))

