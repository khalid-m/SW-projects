;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) Markus Jägerskogh, UDBL, 2004
;;; $RCSfile: sql-insert.lsp,v $
;;; $Revision: 1.8 $ $Date: 2012/02/10 08:18:48 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Insert row(s) into SQL table
;;; =============================================================
;;; $Log: sql-insert.lsp,v $
;;; Revision 1.8  2012/02/10 08:18:48  torer
;;; Code reorganization to enable maintenance
;;;
;;; Revision 1.7  2006/04/14 19:07:02  torer
;;; Using ORGCODE accessor GET-OC
;;;
;;; Revision 1.6  2006/02/24 20:18:52  torer
;;; Replaced QUOTE with FUNCTION
;;;
;;; ===========================================================================

; SQL-INSERT
; 
; The macro does NOT do any check that the correct parameters are pased to it,
; it is expected to be used only by the SQL-parser written with Lex/Yacc.
;
;IN: (SQL-INSERT _PERSON (SSN NAME CITY) VALUES (780602 "Daniel" "Vallentuna"))
;IN: (SQL-INSERT _PERSON VALUES (780602 "Daniel" "Vallentuna"))
;IN: (SQL-INSERT _PERSON SET ((SSN 780602) (NAME "Daniel") (CITY "Vallentuna")))
;OUT: (ADD-FUNCTION _PERSON (780602) ("Daniel" "Vallentuna"))

(defmacro SQL-INSERT (name &rest tail)
  "Implements SQL's INSERT statement"
  (setq name (sql_build-table-schema-name name))
  (let ((ignore nil) (params nil) (values nil) (temp nil) (result nil)) 
    (setq params (getparameters name))	
    ;; Generate a list with the field names and values together
    (case (car tail)
      ('values
       (setq temp (append (mapcar (function second) (car params)) 
			  (mapcar (function second) (cadr params))
			  (list '__NONE__) 
			  ;; Too many arguments should generate en  error..
			  ))
       (dolist (x (cdr tail))
	 (setq values (append values (list (mapcar (function list) temp x)))))
       (list 
	(list (caadr tail))
	(cdadr tail)))
      ('set
       (setq values (cdr tail))
       )
      (otherwise;; when (car tail) is a list. 
       ;; Tail: ((name ...) VALUES ("Markus" ...))
       (dolist (x (cddr tail))
	 (if (= (ilength (car tail)) (ilength x))
	     (setq values (append values (list (mapcar (function list)
						       (car tail) x))))
;            (setq values (mapcar 'list (car tail) (third tail)))
	   (error "SQL-INSERT" 
		  "Number of fields does not match number of values.")))))
					; check number of arguments
    (setq temp (ilength (append (car params) (cadr params))))
    (dolist (x values)
      (if (> temp (ilength x))
	  (error "SQL-INSERT" 
		 (concat "Insufficent number of arguments. Table " 
			 name " expects "  temp " arguments.")))
      (if (< temp (ilength x))
	  (error "SQL-INSERT" (concat "Too many argumets. " temp 
				      " arguments expected for table "
				      name "."))))
    (if (> (ilength values) 1)
	(setq result (list 'proc-block))
      (setq result nil))
    (dolist (vals values)
      (setq result 
	    (append 
	     result 
	     (list (append 
		    (list 'add-function name)
		    (list 
		     (let ((res nil))
		       (dolist (x (car params))
			 (setq res (append res (list (getvalues x vals)))))
		       res)
		     (let ((res nil))
		       (dolist (x (cadr params))
			 (setq res (append res (list (getvalues x vals))))) 
		       res)))))))
    (if (= (ilength values) 1)
	(setq result (car result)))
    (if sql-debugging
	(kwote result)
      result)))

(defun getvalues (find values)
; The function finds the corresponding value to find in values and 
; returns it after a type check. If the types does not match (error) is called.
; IN: find = (INTEGER NAME)
;     values = ((SSN 123) (NAME "Markus")
; OUT: "Markus"
  (let ((val nil))
    (setq val (cadr (assoc (cadr find) values)))
    (case (car find)
      ('INTEGER
       (if (integerp val)
	   val
	 (error "SQL-getvalues" 
		(concat "Incorrect value for " 
			(cadr find) 
			". INTEGER expected."))))
      ('REAL
       (if (numberp val)
	   (if (floatp val)
	       val
	     (float val))
	 (error "SQL-getvalues"
		(concat "Incorrect value for " 
			(cadr find) 
			". REAL expected."))))
      ('NUMBER
       (if (numberp val)
	       val
	 (error "SQL-getvalues"
		(concat "Incorrect value for " 
			(cadr find) 
			". NUMBER expected."))))
      ('CHARSTRING
       (if (stringp val)
	   val
	 (error "SQL-getvalues"
		(concat "Incorrect value for " 
			(cadr find) 
			". CHARSTRING expected.")))))))

; getparameters
;
; by Markus Jägerskogh 2004-04-02
; The function searches for a function named 'name' and if found returns the parameters for that function.
;
; IN: (getparameters '_person)
; OUT: (((INTEGER SSN)) ((CHARSTRING NAME) (INTEGER ZIP)))

(defun getparameters (fn)
  "Get attribute declarations (argdcl resldcl) of function named FN"
  (let (func sb def)
    (setq func (getfunctionnamed fn t))
    (if (not func)
	(error "Does not exist" fn))
    (setq func (resolvents func))
    (if (cdr func)
	(error "Duplicate resolvents of" fn))
    (setq def (get-oc (car func)))
    (externalize (list (car def)(result-tuple-dcl (cadr def))))))

(defun result-tuple-dcl (resdcl)
  "The declarations of a result tuple"
  (cond ((eq (externalize (caar resdcl)) 'bag)
         (assert (eq (cadar resdcl) 'of) "BAG not followed by OF")
         (third (car resdcl)))
        (t resdcl)))