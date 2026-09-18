;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997 Gundars Kulups, Vanja Josifovski, Timour Katchaounov, EDSLAB
;;; $RCSfile: typeimp.lsp,v $
;;; $Revision: 1.45 $ $Date: 2011/12/22 12:55:17 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Type and function importation module.
;;; =============================================================
;;; $Log: typeimp.lsp,v $
;;; Revision 1.45  2011/12/22 12:55:17  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.44  2007/10/18 13:12:36  torer
;;; Now calling FUNCTION-ARGVARS and FUNCTION-RESVARS
;;;
;;; Revision 1.43  2006/11/04 16:18:21  torer
;;; Systematically using GET-RESOLVENT-ARGTYPES and GET-RESOLVENT-RESTYPES
;;;
;;; Revision 1.42  2006/04/08 14:19:40  torer
;;; (GET-OC FNO) always used as accessor function for OID property ORGCODE
;;;
;;; =============================================================


(defvar *executable-proxies* T)

(defstruct funcinfo
; stores information about a function needed to import a function
  name
  oid
  genericname
  argumentl ; ((typei vari) ...)
  resultl   ; ((typei vari) ...)
  proxyinfo ; if a proxy function - (xoid, db); else NIL
)

(defun i_key_storage_func_name (type)
  (mkatom (concat 'i_ (key_storage_func_name type))))

(defun inherit-types (obj supertype-oids)
  "Set the list of the supertypes of object OID to be as inherited from
   a list of type objects."
   (let (tpl)
      (dolist (st supertype-oids)
         (if _bootflg_ (addsupertype obj st)) ; why?
         (dolist (sst (getobject st 'allsupertypes))
            (/addobject obj 'allsupertypes sst)))
      (setq tpl  (cons obj (type-allsupertypes obj))) ; to save event in history list
      (putobject obj 'allsupertypes tpl) ; not logged
      (/putobject obj 'allsupertypes (sort-types tpl)) ; logged
      obj))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Importing from AMOS data sources
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun import-db (db)
  "Make Amos server NAME ready for type/function importation
   Returns the Amos datasource object AMOS_OBJ."
   (let ((db (mksymbol db))
	 ;osql call for recieving Amos info from nameserver 
	 (osqlcall (concat "amosinfo('" (string-upcase db) "');"))
         amos_obj ds_info)
      (cond ((eq db _amosid_) 
             (amos-error "Trying to import the local database: " db))
            ((setq amos_obj (get-datasource-named db t)) ; DB was already imported
	     amos_obj)
	    ; get info about DB from nameserver
            ((setq ds_info (car (reval@nameserver (list 'osql osqlcall))))
	     (setq amos_obj (get-datasource-named db t))
	     (if amos_obj 
		  ; amos-object already existed: update info
		 (setfunction _amosinfo_ (list amos_obj) ds_info)
	         ; else create new Amos object:
	         (setfunction _amosinfo_
			      (list (setq amos_obj (/createobject 'amos db))) ds_info))
	     amos_obj)
	    (t
	     (amos-error "Unknown database called: " db)))))

(defun import-functions (tp ds_obj)
  "Import all functions of type 'tp' defined in datasource 'ds_obj'."
  (let* ((dbname (oid-name ds_obj))
	 (allimptpsN  ; all names of types imported from this source so far
	  (mapcar (f/l (tp) (proxytype-origname tp))
		  (get-imported-types ds_obj)))
	 ;all functions that can be imported from the source, connected
	 ;with the newly imported type and other previously imported types
	 (get_func_info_expr
	  (list 'importable-functions (kwote (mkatom tp)) (kwote allimptpsN)))
	 (funcsInfo (remote-eval get_func_info_expr dbname)))
    ;generate local proxy functions for the remote functions
    (mapc (f/l (fn) (create-proxy-function fn dbname)) funcsInfo)))

;;; Does not work (TR):
(quote
(defun import-single-type (type db &optional no_func_import)
  (import-db db)
  (let* ((proxytp_name (mkatom (proxy_type_name type DB))))
    (if (null (gettypenamed proxytp_name t))
	(let* ((ds_obj (get-datasource-named db))
	       (get_type_expr (list 'gettypenamed (kwote (mkatom type))))
	       proxytp_oid)
	  (setq proxytp_oid (remote-eval get_type_expr DB))
	  (create-proxy-type proxytp_name NIL proxytp_oid)))))

(defun get-func (func &rest args)
  "Get a func (property) of an object and maximally unnest the result.
   Purpose: to make life easier when calling OSQL from Lisp."
  (let (res)
    (setq res (getfunction (mksymbol func) args))
    (cond ((null res) nil)
	  ((= (length res) 1)
	   (if (= (length (car res)) 1)
	       (caar res)
	     (car res)))
	  ((= (length (car res)) 1)
	   (mapcar (function car) res))
	  (t res))))

(defun import-subtypes (type db &optional no_func_import)
  (let* ((rmt-expr (list 'get-func ''allsubtypes (mkstring type)))
	 (subtps (unique (remote-eval rmt-expr db))))
    (mapcar (f/l (tp)
		 (import-single-type tp db no_func_import))
	    subtps)))
)
;;;

(defun import-types (types db)
  "Import list of types and their functions from other mediator"
  (let (imported-types)
    (setq db (mksymbol db))
    (dolist (tp types)
      (setq imported-types (append (import-type tp db t) imported-types)))
    (setq db (getobjectnamed db _datasource_)) ; why such stupid inconsistency????
    (dolist (tp imported-types)
      (import-functions (proxytype-origname tp) db))
    imported-types)) 

(defun import-type (type DB &optional no_func_import)
  "Imports type and its functions from another AMOS mediator named DB.
   'no_func_import' - controls if functions of this type are to be imported
                      with the type too.
   Output: proxy type OID.
   Returns list of all imported proxy types."
  (import-db db)
  (setq type (mkatom type))
  (let* ((proxytp_name (mkatom (proxy_type_name type DB))) ; the name of the new proxy type
	 (ds_obj (get-datasource-named db)) ; the data source object 
					; supertypes of the imported type
	 (super_types (remote-eval `(real_supertypes , (kwote type)) DB))
					; leave only the supertypes that were not yet imported
	 (non_imported_supertypes
	  (mapfilter (f/l (tp)
			  (not (gettypenamed (proxy_type_name tp DB) t)))
		     super_types))
	 local_supertypes proxytp_oid imported-types)

  ;;; TODO: perhaps this behavior should be changed, and instead of importing all
  ;;; supertypes, when a type is imported to check if it is someone's supertype
  ;;; and added accordingly to that type's supertypes.
  ;;; import first the supretypes
    (mapc (f/l (st) 
	       (setq imported-types (append (import-type st DB no_func_import) 
					    imported-types)))
	  non_imported_supertypes)
					; get the names of the imported supertypes
    (setq local_supertypes (mapcar (f/l (tp) (proxy_type_name tp DB))
				   super_types))

					; generate a proxy OID using the remote_eval built-in OID mapping
    (setq proxytp_oid (remote-eval `(gettypenamed , (kwote type)) DB))

					; TODO: proxytp_oid is wrong here - it inherits from PROXY. Patched below.
					; Create proxy type named NAME with SUPERTYPES
					; If OID is provided, convert object OID to become new proxy object
    (createtype proxytp_name (add-inherit _userobject_ local_supertypes)
		_proxytype_ nil proxytp_oid)

					;add some data used in the query processing
    (/putobject proxytp_oid 'datasource ds_obj)
    (/putobject proxytp_oid 'origname (mkatom type))
    
    (if (null no_func_import)
					; import all functions related to this type
	(import-functions type ds_obj))

    (cons proxytp_oid imported-types)))

(defun proxy_type_name (tpn dbn)
  "Makes a proxy type name from a type and db name."
  (mkatom (concat tpn '_ dbn)))  

(defun type_name_symbol (tpn)
 (assert tpn "nil for a type name")
 (if (listp tpn) (proxy_type_name (car tpn) (second tpn)) tpn))

(defun real_supertypes (type)
  "Returns name of imediate supertypes that should be imported with the type."
  (let* ((tp (gettypenamed type))
	 (directSts (getobject tp 'supertypes))
	 (realSts (mapfilter #'ut_p directSts))) ; filter the user-defined types only
    (mapcar (f/l (t1) (oid-name t1)) realSts)))

(defun create-proxy-function (finfo DB)
  "Generates function proxy
   finfo  - funcinfo structure
   DB     - string"
   (assert (and (not (null finfo) ) (not (null DB))) "Null argument to create-proxy-function.")
   
   (let* ((f_name (funcinfo-name finfo))
          (genname (funcinfo-genericname finfo))
          (proxy (funcinfo-oid finfo))
          (arglist (funcinfo-argumentl finfo))
          (reslist (funcinfo-resultl finfo))
          accessorfnname accessfno proxyfno)
      (cond ((getobject proxy 'name)
             proxy)
            (t ; create the proxy function as a foreign Lisp function implemented
               ; by 'access-proxy-function'
              (setq proxyfno (createfunction genname
			       arglist reslist
                               'FOREIGN
                               '("access-proxy-function")
                               NIL
                               proxy))
              (/putobject proxy 'proxyfunc (mkatom DB))
              (/putobject proxy 'origname (mkatom f_name))
	      (cond (*executable-proxies*
		     ; Create the accessor function for this proxy fn. This is the function that
	             ; gets executed when a proxy function is called.
		     (setq accessorfnname (accessor-fnname proxyfno))
		     (setq accessfno (createfunction accessorfnname
						     arglist reslist
						     (list (cons genname (getvars arglist)))
						     NIL NIL))
		     (/putobject accessfno 'systemfn T) ; make it a system function
		     (/putobject proxyfno 'accessor accessfno)))
              proxyfno))))

(defun accessor-fnname (proxyfno)
    (concat 'accessor- (oid-name proxyfno)))

(defun access-proxy-function (fno oid val)
  "The implementation for all AMOS proxy functions. Calls the appropriate accessor function."
  (let ((accessor (getobject fno 'accessor)))
    (if accessor
	(mapfunction accessor (vector oid)
		     (f/l (row) (osql-result oid (car row))))
        (amos-error "Trying to call a non-executable proxy function"))))

(defun importable-functions (typeN imported-types-in-caller)
  "Functions which can be imported to another DB - all functions of a type, but:
   system, coersion and proxy accessor functions."
  (setq imported-types-in-caller (mapcar #'gettypenamed imported-types-in-caller))
  (let* ((type (gettypenamed typeN))
	 (all_fns (allfunctionsfortype type))
	 (filtered_functions
	  (mapfilter (f/l (fn) (and
				(not (getobject fn 'systemfn))
				(not (getfunction _coerce_funcs_ (list fn)))))
		     all_fns))
	 (result_info (mapcar (f/l (fn)
				   (func_info fn imported-types-in-caller NIL))
			      filtered_functions)))
    (mapfilter (f/l (x) (not (null x))) result_info)))

(defun export_single_func (fnname imported-types-in-caller fakeTypes)
  "Return local function information. Called from (import_single_func)."
  (let ((fno (getfunctionnamed fnname)))
    (if fno (func_info fno imported-types-in-caller fakeTypes))))

(defun import_single_func (fnname db fakeTypes)
  (let* ((imported-types (get-imported-types (get-datasource-named db)))
	 (expr (list 'export_single_func (kwote fnname) (kwote imported-types) (kwote fakeTypes)))
	 (finfo (remote-eval expr DB))
	 (f_name (funcinfo-name finfo))
	 proxy_f)
    (if finfo
	(progn
	  (setq proxy_f (create-proxy-function finfo DB))
	  (/putobject proxy_f 'proxyfunc (mkatom DB))
	  (/putobject proxy_f 'origname f_name)
	  proxy_f))))

(defun check_type_list (lis imported-types-in-caller)
  "Checks list lis for containing only literal types and types from list imported-types-in-caller.
   USED only in func_info"
  (flet ((goodtype (type imported-types-in-caller)
	 ; returns T if 'type' is either non-userobject type (i.e. exists in every DB)
         ; or it is among 'imported-types-in-caller'
		   (if (or (not (ut_p type)) (memq type imported-types-in-caller))
		       t)))
    (apply #'and (mapcar (f/l (tp) (goodtype tp imported-types-in-caller)) lis))))

(defun map_tp_to_name (inlst)         
  "Makes list for foreign server to create function.
   USED only in func_info"
  (mapcar (f/l (el)
	       (let ((name (oid-name (car el))))
		 (if (ut_p (car el))
		     (cons (mkatom (concat name '_ _amosid_)) (cdr el))
		   (cons name (cdr el)))))
	  inlst))

(defun set_to_integer_t (typelst)
  "Change all usertypes to type INTEGER
   input: typelist is of the form: (type1 type2 ...)
   USED only in func_info"
  (mapcar (f/l (tp) (if (ut_p tp) _integer_ tp)) typelst))

(defun set_to_integer_tv (tpl)
  "tpl is of the form: ((type var) ...)
   USED only in func_info"
  (let ((type-lst (mapcar (f/l (tp) (if (ut_p (car tp))	_integer_ (car tp)))
			  tpl))
	(var-lst (mapcar #'second tpl)))
    (mapcar #'list type-lst var-lst)))

(defun key-info (fno)
  "Get a mask for all i/o vars of 'fno' where 'T' stands for unique key, 'NIL' o/w.
   Based on hasuniqueindex"
  (let* ((sb (getselectbody fno))
	 (argl (selectbody-argl sb))
	 (resl (selectbody-resl sb))
	 (argl-len (length argl))
	 (resl-len (length resl))
	 (width (+ argl-len resl-len))
	 (rel (if (relationp fno) fno (get-relation fno)))
	 argl-keys resl-keys)
  (cond ((relationp rel)
	 (let* ((indxobj (mapfilter #'index-unique (relation-indexes rel)))
		(indxpos (mapcar #'index-pos indxobj)))
	   (setq argl-keys (mkarray argl-len NIL))
	   (setq resl-keys (mkarray resl-len NIL))
	   (dolist (pos indxpos)
	     (if (< pos argl-len)
		 (setf (aref argl-keys pos) T)
	         (setf (aref resl-keys (- pos argl-len)) T)))
	   (list (arraytolist argl-keys) (arraytolist resl-keys))))
	;((dynconstructorfn fno) t)
	((foreign-predicatep fno)
	 (let ((keys (getobject fno 'keys)))
                  (list (firstn argl-len keys)(nthcdr argl-len keys)))))))


(defun add-key-tags (tpvars keys keytag)
  (if (neq (length tpvars) (length keys))
      (amos-error "Different lengths of variable list and key list: "
		  tpvars ", " keys))
  (mapcar (f/l (tv k)
	       (if (and k (not (memq keytag tv)))
		   (append tv (list keytag))
		   tv))
	  tpvars keys))

(defun func_info (fn_obj imported-types-in-caller fakeTypes)
  "Collect the information about a function needed to import that function
   in another DB. Returns a func-info structure."
  (assert (not (null fn_obj)) "nil function object")
  (if (generic? fn_obj)
      (amos-error fn_obj " is a generic function. Only resolvents can be imported.")
      (let* ((rl1 (get-resolvent-restypes fn_obj))
	     (al1 (get-resolvent-argtypes fn_obj))
	     (rl (if fakeTypes (set_to_integer_t rl1) rl1))
	     (al (if fakeTypes (set_to_integer_t al1) al1))
	     (orgc (get-oc fn_obj))
	     (arg (car orgc))
	     (res (cadr orgc))
	     (allargs (append arg res))
	     (args (function-argvars fn_obj))
	     (orgarg1 (mapfilter (f/l (x) (memq (second x) args)) allargs))
	     (orgres1 (set-difference allargs orgarg1))
	     (orgarg (if fakeTypes (set_to_integer_tv orgarg1) orgarg1))
	     (orgres (if fakeTypes (set_to_integer_tv orgres1) orgres1))
        ;(origininfo (if (proxyfunc? fn_obj)
	;			 (let ((xoid (proxy-oid fn_obj))
	;			       (db (proxyfunc-origin fn_obj)))
	;			   (list xoid db))
	;		       NIL)))
	     origininfo finfo)

	(if (and (or (check_type_list al imported-types-in-caller) (not al))
		 (or (check_type_list rl imported-types-in-caller) (not rl)))
	    (let ((argl (map_tp_to_name orgarg))
		  (resl (map_tp_to_name orgres))
		  (keys (key-info fn_obj)))
	      (cond (keys
		     (setq argl (add-key-tags argl (first keys) 'key))
		     (setq resl (add-key-tags resl (second keys) 'key))))
	      (make-funcinfo
	       :name (oid-name fn_obj)
	       :oid fn_obj
	       :genericname (generic-fnname (oid-name fn_obj))
	       :argumentl argl
	       :resultl resl
	       :proxyinfo origininfo))
	       ; If the test fails, this means that most probably the "type fakeing" went wrong.
	       ; Reason: if a type is not among among the types imported in the remote DB 
	       ; (the caller), then it must have been faked (i.e. changed to a type that 
	       ; exists in every DB - an 'integer' in our case).
	  (amos-error fn_obj 
		      " contains types that are unknown in the caller " (port-dbid *client-port*) ". "
		      " Types imported in the caller: " imported-types-in-caller ". "
		      " FakeTypes: " fakeTypes)
	  ))))
