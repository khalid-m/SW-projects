;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Timour Katchaounov, Martin Hansson, UDBL
;;; $RCSfile: odbc.lsp,v $
;;; $Revision: 1.13 $ $Date: 2004/12/08 18:38:08 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Definition of the ODBC type and the functionality it provides.
;;;              
;;; ===========================================================================
; To do: As of now, the initializer and finalizer are hooked to the 
; odbc type, but they really belong in relational. How do we fix inheritance
; for these things?

(defglobal _sql-statement-cache_ (make-hash-table :test (function equal)))
(defglobal _odbc_ (createtype 'odbc '(relational)))
(putobject _odbc_ 'initializer 'relational-initialize)
(putobject _odbc_ 'finalizer 'relational-finalize)

; defined in HandleManager.h too. Must have the same value.
(defglobal _invalid-handle_ -1)

; front functions

(defun odbc--+ (fno name ds)
  (let ((ds))
    (setq ds (/createobject 'odbc name))
    (/addtype ds _odbc_) ; to make datasource names unique
    (odbc-set-handle ds _invalid-handle_)
    (/putobject ds 'initializer 'relational-initialize)
    (/putobject ds 'finalizer 'relational-finalize)
    (osql-result name ds)))

(defun connect----+ (fno ds dsn usr pass ds2)
   ; first disconnect if already connected
  (if (odbc-connected-p ds) (odbc-disconnect (odbc-get-handle ds)))
  ; now connect again
  (let ((connection_handle (odbc-connect dsn usr pass)))
    (cond ((= connection_handle _invalid-handle_)
	   (amos-error "Unable to connect to: " dsn))
	  (t
	   (odbc-set-handle ds connection_handle)
	   (addfunction 'odbc_dsn (list ds) (list dsn))
	   (addfunction 'username (list ds) (list usr))
	   (addfunction 'password (list ds) (list pass))
	   (osql-result ds dsn usr pass ds)))))

(defun disconnect-+ (fno ds success)
  (cond ((odbc-connected-p ds)
	 (odbc-disconnect (odbc-get-handle ds))
	 (odbc-set-handle ds _invalid-handle_)
	 (remfunction 'odbc_dsn (list ds) (list (get-func 'odbc_dsn ds)))
	 (remfunction 'username (list ds) (list (get-func 'username ds)))
	 (remfunction 'password (list ds) (list (get-func 'password ds)))
	 (remfunction 'native_conn (list ds) (list (get-func 'native_conn ds)))
	 (osql-result ds t))))

(defun tables-++++ (fno ds table catalog schema owner)
  (if (odbc-connected-p ds)
      (dolist (tuple (odbc-tables (odbc-get-handle ds)))
	(apply #'osql-result (cons ds tuple)))
    (amos-error "Data source not connected " ds)))

(defun columns--++ (fno ds table column_type column_name)
  (if (odbc-connected-p ds)
      (dolist (tuple (odbc-columns (odbc-get-handle ds) table))
	(apply #'osql-result (cons ds (cons table tuple))))
    (amos-error "Data source not connected " ds)))

(defun primary_keys--++ (fno ds table column_name constraint_name)
  (if (odbc-connected-p ds)
      (dolist (tuple (odbc-primary-keys (odbc-get-handle ds) table))
	(apply #'osql-result (cons ds (cons table tuple))))
    (amos-error "Data source not connected " ds)))

(defun sql--+ (fno ds query res)
  (if (not (odbc-connected-p ds)) (amos-error "Datasource not connected"))
  (let* ((connection_handle (odbc-get-handle ds))
	 result scan_handle statement_handle)
    (setq statement_handle (odbc-prepare-statement connection_handle query))
    (setq scan_handle (odbc-execute-query statement_handle))
    (unwind-protect
	(while (setq result (odbc-next-row scan_handle))
	  (osql-result ds query result))
      (progn
	(odbc-close-scan scan_handle)
        (odbc-free-statement statement_handle)))))

(defun sql---+ (fno ds query params res)
  (if (not (odbc-connected-p ds)) (amos-error "Datasource not connected"))
  (let* ((connection_handle (odbc-get-handle ds))
	 result scan_handle
	 (statement_handle 
	  (odbc-prepare-statement-cached connection_handle query)))
    ;; alternative non-caching prepare
    ;; to use - uncomment 'odbc-free-statement' below
    ;;(odbc-prepare-statement connection_handle query))
    (odbc-bind-params statement_handle params)
    (setq scan_handle (odbc-execute-query statement_handle))
    (unwind-protect
	(while (setq result (odbc-next-row scan_handle))
	  (osql-result ds query params result))
      (progn
	(odbc-close-scan scan_handle)
	;; do not free statement handles if they are cached
	;;(odbc-free-statement statement_handle)
	))))

(defun sqlu----+ (fno ds query params res)
  (if (not (odbc-connected-p ds)) (amos-error "Datasource not connected"))
  (let* ((connection_handle (odbc-get-handle ds))
	 (statement_handle (odbc-prepare-statement connection_handle query))
	 num_rows)
    (odbc-bind-params statement_handle params)
    (setq num_rows (odbc-execute-update statement_handle))
    (unwind-protect
	(osql-result ds query params num_rows)
      (odbc-free-statement statement_handle))))

; TODO: Does not work. _odbc_ds_ undefined. needs testing
(quote (defun odbc-reconnect-all-sources ()
  "Reconnect to all ODBC data sources stored in the database."
  (mapextent _odbc_ds_
	     (f/l (ds)
		  ; reset old (invalid) handles
		  (odbc-set-handle ds _invalid-handle_)
		  ; reconnect using old information
		  (let ((dsn (get-func 'odbc_dsn ds))
			(usr (get-func 'username ds))
			(pass (get-func 'password ds))
			(native-str (get-func 'native_conn ds)))
		    (if native-str
			(get-func 'connect_native native-str)
		      (get-func 'connect ds dsn usr pass))))))
)
; private functions

(defun odbc-get-handle (ds)
  (assert (osql-subtypep (arg-type ds) _odbc_) "Invalid handle")
  (getobject ds 'connhandle))

(defun odbc-set-handle (ds handle)
  (assert (and (osql-subtypep (arg-type ds) _odbc_)
	       (>= handle _invalid-handle_)) "Invalid handle")
  (/putobject ds 'connhandle handle))

(defun odbc-valid-handle-p (handle)
  (if (> handle _invalid-handle_) T nil))

(defun odbc-connected-p (ds)
  (if (odbc-valid-handle-p (odbc-get-handle ds)) T nil))

; Not complete. Useful for performance experiments to avoid
; unnecessary compilations
(defun odbc-prepare-statement-cached (connection_handle query)
  "Checks if an SQL statement was previously prepared.
   TODO:
   - the cache should have limited size - some ODBC drivers have a limit
     on the maximum number of prepared statements"
  (let* ((key (cons connection_handle (string-upcase query)))
	 (statement_handle (gethash key _sql-statement-cache_)))
    (cond (statement_handle
	   statement_handle)
	  (t (let ((new_handle (odbc-prepare-statement connection_handle query)))
	       (puthash key _sql-statement-cache_ new_handle)
	       new_handle)))))

  ; commit a datasource
(foreign-lispfn odbc_commit ((odbc ds)) ()
		(if (odbc-commit (odbc-get-handle ds))
		    (foreign-result)))

  ; rollback a datasource
(foreign-lispfn odbc_rollback ((odbc ds)) ()
		(if (odbc-rollback (odbc-get-handle ds))
		    (foreign-result)))
