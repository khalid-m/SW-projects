;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Thanh Truong, UDBL
;;; $RCSfile: extract-sql.lsp,v $
;;; $Revision: 1.1 $ $Date: 2012/05/23 07:53:58 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Extracting SQL queries
;;; =============================================================
;;; $Log: extract-sql.lsp,v $
;;; Revision 1.1  2012/05/23 07:53:58  thatr500
;;; To extract/compare SQL string from a given function name
;;;
;;; Revision 1.1  2012/05/21 15:45:09  thatr500
;;; added SQL query extractor
;;;
;;;
;;; =============================================================

(defun extract-optpred (&optional fn)
  (if (eq fn nil) 
      (selectbody-optpred (getselectbody (getfunctionnamed '*select*)))
    (selectbody-optpred (getselectbody  (car (resolvents (getfunctionnamed fn)))))))


(defun optpred-contain (p optpred)
  (let ((conj (if (compound-p optpred) (cdr optpred) optpred)))
    (some (f/l (q)
	       (or (eq (second q) p)
		   (and (eq (car q) 'CALL)
			(eq (third q) p)))) conj)))


(defun contain-sql-pattern (pattern &optional fn)
  (some (f/l (sql)
	     (string-like (string-upcase sql) (string-upcase pattern)))
	(extract-sql-strings-from-fn fn)))

(defun extract-sql-strings-from-fn (&optional fn)
  (let (optpred)
    (setq optpred  (extract-optpred fn))
    (if (or (conjunctionp optpred) (compound-p optpred))
	(mapfilter #'sqlp (rest optpred) #'extract-sql)
      (if (sqlp optpred)
	  (list (extract-sql optpred))))))

(defun extract-sql (pred)
  ;; after finalizing the query, the origin table is swept out. Therefore,
  ;; we look at optpred
  ;; Otherwise,(get-sql-string (getobject (fourth pred) 'sqlquery)))
  (let ((optpred (selectbody-optpred (getobject (fourth pred) 'selectbody))))
    (nth 4 (car (subset (cdr optpred)
			(f/l (p) (eq (oid-name (third p)) 
				     'JDBC.CHARSTRING.VECTOR.SQL->VECTOR)))))))

(defun sqlp (pred)
  (equal (firstn 2 pred) '(call apply-pred-+)))

;; Contain a pattern in SQL string of a given fname
(foreign-lispfn contain_sql_pattern
		((charstring pattern)
		 (charstring fname)) ((boolean))
		 (foreign-result (contain-sql-pattern pattern fname)))

;; Contain a pattern in SQL string of '*select*'
(foreign-lispfn contain_sql_pattern
		((charstring pattern)) ((boolean))
		 (foreign-result (contain-sql-pattern pattern)))

;; Get SQL string of a given fname
(foreign-lispfn getsql ((charstring fname)) ((charstring))
		 (foreign-result (extract-sql-strings-from-fn fname)))

;; Get SQL string of '*select*'
(foreign-lispfn getsql () ((charstring))
		 (foreign-result (extract-sql-strings-from-fn)))

(defglobal _number-plus_ 
  (getfunctionnamed 'NUMBER.NUMBER.PLUS->NUMBER))

(defglobal _number-minus_ 
  (getfunctionnamed 'NUMBER.NUMBER.MINUS->NUMBER))

(defglobal _number-times_ 
  (getfunctionnamed 'NUMBER.NUMBER.TIMES->NUMBER))

(defglobal _number-div_ 
  (getfunctionnamed 'NUMBER.NUMBER.DIV->NUMBER))

(defglobal _number-power_ 
  (getfunctionnamed 'NUMBER.NUMBER.POWER->NUMBER))

(defglobal _number-abs_
  (getfunctionnamed 'NUMBER.ABS->NUMBER))

(defglobal _number-sqrt_ 
  (getfunctionnamed 'NUMBER.SQRT->NUMBER))