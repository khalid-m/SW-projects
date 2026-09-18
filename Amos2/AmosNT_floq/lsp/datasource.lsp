;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1999 Timour Katchaounov, EDSLAB
;;; $RCSfile: datasource.lsp,v $
;;; $Revision: 1.53 $ $Date: 2006/04/29 10:11:11 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Basic data source type and related functions
;;; =============================================================
;;; $Log: datasource.lsp,v $
;;; Revision 1.53  2006/04/29 10:11:11  torer
;;; Check for duplicated or conflicting declarations in FROM clause
;;;
;;; =============================================================

;;; Does not work (TR):
;(defun restore-all-connections ()
;  (odbc-reconnect-all-sources)
;  (amos-restore-comm))
;;;

(defun init-ds-subsystem ()
  (foreign-lispfn datasource ((type tp)) ((datasource ds))
		  ;; Get the datasource of a proxy type
		  (let ((r (getobject tp 'datasource)))
		    (if r (foreign-result r))))

  (osql "create function name(datasource ds)->charstring nm
         as select objectname(ds);

         create function datasource_named(charstring dsname) -> datasource
         as select ds from datasource ds where name(ds) = dsname;

         create function imported_types(datasource ds)-> type imptp
         /* The types imported from a datasource */ 
         as select imptp where datasource(imptp)=ds;

        create function imported_types()-> type
        /* The types imported from all datasources */ 
        as select allimptp from type allimptp, datasource ds  
           where datasource(allimptp) = ds;")

  )

(defun get-datasource-named (dsname &optional noerror)
  "Get datasource object named DSNAME. NOERROR=nil => error if not found."
  (getobjectnamed (mksymbol dsname) _datasource_ noerror))

(defun get-all-imported-types ()
  "Convenience wrapper for the OSQL version IMPORTED_TYPES.
    return: a list of ALL imported type objects: (tpo1 tpo2 ...)."
  (let* ((imported_types_fn (getfunctionnamed 'IMPORTED_TYPES->TYPE))
	 result)
    (mapfunction imported_types_fn '() 
		 (f/l (tp) (setq result (cons (car tp) result))))
    result))

(defun get-imported-types (ds_obj)
  "Convenience wrapper for the OSQL version IMPORTED_TYPES.
     return: a list of type objects: (tpo1 tpo2 ...)"
  (assert (oid-p ds_obj) "Non datasource object argument.")
  (let* ((imported_types_fn 
	  (getfunctionnamed 'DATASOURCE.IMPORTED_TYPES->TYPE))
	 result)
    (mapfunction imported_types_fn (list ds_obj) 
		 (f/l (tp) (setq result (cons (car tp) result))))
    result))

(defun get-initializer (ds) (getobject (arg-type ds) 'initializer))

(defun get-finalizer (ds) (getobject (arg-type ds) 'finalizer))



