;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) Markus Jägerskogh, UDBL, 2004
;;; $RCSfile: sql-update.lsp,v $
;;; $Revision: 1.5 $ $Date: 2011/02/16 20:27:50 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Update SQL tables
;;; ===========================================================================
;;; $Log: sql-update.lsp,v $
;;; Revision 1.5  2011/02/16 20:27:50  torer
;;; Changed bad Lisp code
;;;
;;; ===========================================================================

; SQL-UPDATE macro
;
; Written in April-2004 by Markus Jägerskogh.
;
; IN: 
;(SQL-UPDATE _PERSON SET 
;	    ((ZIP . 75445)) 
;	    (WHERE (= NAME "Fredrik")))
; OUT: 
;(OSQL-FOREACH ((INTEGER ZIP) (CHARSTRING NAME) (INTEGER SSN)) 
;	      (AND (= (_PERSON SSN) (TUPLE NAME ZIP)) 
;		   (= NAME "Fredrik")) 
;	      NIL 
;	      (ADD-FUNCTION _PERSON (SSN) (NAME 75445)))
(defmacro SQL-UPDATE (tname set values &rest tail)
  "The form an SQL update statement is parsed into"
  (sql-update-expand tname set values tail))

(defun sql-update-expand (tname set values tail)
  "Implements SQL's UPDATE statement"
  (let ((name (sql_build-table-schema-name tname))
	params vars pred arg res rem xvars thequery)
    (setq params (getparameters name))
    (setq vars (append (car params) (cadr params)))
    (setq vars (mapcar;; Remove NONKEY and possible other parameters 
		;; than type and name of vars
		#'(lambda (x)
		    (list (car x) (cadr x)))
		vars))
    (selectq (ilength (cadr params))
	     (0 (setq pred (cons name
				 (mapcar #'(lambda (x) (cadr x)) vars))))
	     (1 (setq pred 
		      (list '= (cons name
				     (mapcar #'(lambda (x) (cadr x)) 
					     (car params)))
			    (cadr (caadr params)))))
	     (setq pred (list '= (cons name
				       (mapcar #'(lambda (x) (cadr x)) 
					       (car params)))
			      (cons 'tuple
				    (mapcar #'(lambda (x) (cadr x)) 
					    (cadr params))))))
    ;;* The variables bellow are divided as the create statement: 
    ;;CREATE FUNCTION name (arg)=<res>; 
    (setq arg (mapcar #'(lambda (x) (cadr x)) (car params)))
    (setq res (mapcar #'(lambda (x) (cadr x)) (cadr params)))
    (if (not res)
	(setq res '(true)))
    ;; If there are any changes in the function arguments, 
    ;; we must perform both a REMOVE and an ADD operation. 
    ;; Otherwise it is enough to just perform a SET operation.
    (if (not (equal arg (sublis values arg)))
	(setq rem (list 'rem-function name arg res )))
    (setq arg (sublis values arg))
    (setq res (sublis values res))
    (setq arg (mapcar 
	       #'(lambda (x y) 
		   (if (listp x)
		       (progn
			 (setq xvars (cons (list (car y) 
						 (gensym)) 
					   xvars))
			 (setq pred (list 'and 
					  pred 
					  (list '= (cadar xvars) x)))
			 (cadar xvars))
		     x))
	       arg
	       (car params)))
    (setq res (mapcar 
	       #'(lambda (x y) 
		   (if (listp x)
		       (progn
			 (setq xvars (cons (list (car y) (gensym)) xvars))
			 (setq pred (list 'and pred (list '= (cadar xvars) x)))
			 (cadar xvars))
		     x))
	       res
	       (cadr params)))
    (setq vars (append vars xvars))
    (dolist (x tail)
      (selectq (car x)
	       (where
		(setq pred (list 'and pred (cadr x))))
	       nil)
;       (ORDER-BY
;	 nil
;       )
;       (LIMIT
;	 nil
;      ))
      nil)
    (setq arg (expandfunctions (convertcolumnnames arg) T))
    (setq res (expandfunctions (convertcolumnnames res) T))
    (setq pred (expandfunctions (convertcolumnnames pred) T))
    (if rem
	(setq thequery (list 'osql-foreach vars pred nil 
			     (list 'proc-block rem 
				   (list 'add-function name arg res ))))
      (setq thequery (list 'osql-foreach vars pred nil 
			   (list 'set-function name arg res ))))
    (if sql-debugging
	(kwote thequery)
      thequery)))

(defun convertcolumnnames (lst)
  (if (listp lst)
      (if (= (car lst) 'COLUMN)
	  (nth 3 lst)
	(mapcar (function convertcolumnnames) lst))
    lst))

