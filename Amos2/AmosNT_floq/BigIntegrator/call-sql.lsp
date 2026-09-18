(defglobal _call-sql_)
(defglobal _call-sql-ffi_)

(setq _call-sql_
       (create-function call-sql ((jdbc c)(charstring query)(integer arity))()
			as foreign 
			("JAVA:jdbc_interface.JDBCInterface/callSQL")))

(setq _call-sql-ffi_ (cadr (substbindadorned (list _call-sql_) '(- - -))))

;;; Example of TBR call:
;;; (call _call-sql-ffi_ _call-sql_ C- "select name from person where ssn=?" 1
;;;       SSN- NAME+)

