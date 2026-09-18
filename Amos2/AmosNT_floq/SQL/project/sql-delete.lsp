;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) Markus Jägerskogh, UDBL, 2004
;;; $RCSfile: sql-delete.lsp,v $
;;; $Revision: 1.3 $ $Date: 2011/02/16 20:27:49 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Delete row(s) from SQL table
;;; ===========================================================================
;;; $Log: sql-delete.lsp,v $
;;; Revision 1.3  2011/02/16 20:27:49  torer
;;; Changed bad Lisp code
;;;
;;; ===========================================================================

; SQL-DELETE macro
;
; Written in April-2004 by Markus Jägerskogh.
;
; IN: (SQL-DELETE _PERSON (= NAME "Fredrik"))
; OUT: 
;(OSQL-FOREACH ((INTEGER ZIP) (CHARSTRING NAME) (INTEGER SSN)) 
;	      (AND (= (_PERSON SSN) (TUPLE NAME ZIP)) 
;		   (= NAME "Fredrik")) NIL 
;	      (REM-FUNCTION _PERSON (SSN) (NAME ZIP)))

(defmacro SQL-DELETE (name &rest tail)
  "Implement SQL's DELETE statement"
  (let ((name (sql_build-table-schema-name name))
	(params nil) (vars nil) (pred nil) (arg nil) (res nil) (result nil))
    (setq params (getparameters name))
    (setq vars (append (car params) (cadr params)))
    (setq vars (mapcar;; Remove NONKEY and possible other parameters 
		;; than type and name of vars
		#'(lambda (x)
		    (list (car x) (cadr x)))
		vars))
    (case (ilength (cadr params))
      ('0
       (setq pred (cons name (mapcar #'(lambda (x) (cadr x)) vars))))
      ('1
       (setq pred (list '= (cons name
				   (mapcar #'(lambda (x) (cadr x)) 
					   (car params)))
			(cadr (caadr params)))))
      (OTHERWISE
       (setq pred (list '= (cons name
				   (mapcar #'(lambda (x) (cadr x)) 
					   (car params)))
			(cons 'TUPLE 
				(mapcar #'(lambda (x) (cadr x)) 
					(cadr params)))))))
    (setq arg (mapcar #'(lambda (x) (cadr x)) (car params)))
    (setq res (mapcar #'(lambda (x) (cadr x)) (cadr params)))
    (if (not res)
	(setq res '(TRUE)))
;    (if (= (caar tail) 'WHERE)
;      (setq pred (list 'AND pred (cadar tail)))
;    )
    (if tail
	(setq pred (list 'AND pred (convertcolumnnames (car tail)))))
    (setq result (list 'OSQL-FOREACH vars pred nil 
		       (list 'REM-FUNCTION name arg res )))
    (if SQL-DEBUGGING
	(kwote result)
      result)))

; (SQL-DELETE _PERSON (WHERE (= NAME "Fredrik")))