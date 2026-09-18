;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997 Vanja Josifovski, EDSLAB
;;; $RCSfile: dt.lsp,v $
;;; $Revision: 1.18 $ $Date: 2011/01/09 16:33:06 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Misc. dt functions and variable definitions
;;; =============================================================
;;; $Log: dt.lsp,v $
;;; Revision 1.18  2011/01/09 16:33:06  torer
;;; Removed redundant definition of _static_funcs_
;;;
;;; Revision 1.17  2008/12/05 12:36:29  torer
;;; New function (DELETED-OBJECT O)
;;;
;;; Revision 1.16  2006/11/04 16:18:20  torer
;;; Systematically using GET-RESOLVENT-ARGTYPES and GET-RESOLVENT-RESTYPES
;;;
;;; =============================================================


;variables used by the validation detection and insertion
(defvar *validate_l* nil)
(defvar *validate_vars_l* nil)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Internal functions naming 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;suffixes and prefixes and names of the amos internal funcs, should contain '-'
;to prevent the user to type in this function in OSQL. Not done here to make
;the predicates more readable

;coercion functions suffix
(defglobal coerceFuncsNameSuffix '_COERCE)

;OID generation foreign functions prefix
(defglobal cFuncPrefix 'COID_)

;materialization wrapper function
(defglobal matFuncPrefix 'MAT_)

;key function prefix
(defglobal keyfPrefix  'KEYF_)
(defglobal ikeyfPrefix 'IKEYF_)
(defglobal rkeyfPrefix 'RKEYF_)
(defglobal skeyfPrefix 'SKEYF_)
;storage function for the materialized keys and oids of integration types


(defun key_storage_func_name (typeN)
  (mkatom (concat skeyfPrefix (type_name_symbol typeN))))

(defun key_func_name (typeN)
  (mkatom (concat keyfPrefix (type_name_symbol typeN))))

(defun ikey_func_name (typeN)
  (mkatom (concat ikeyfPrefix (type_name_symbol typeN))))

(defun rkey_func_name (typeN)
  (mkatom (concat rkeyfPrefix (type_name_symbol typeN))))


;the mapping tables store foreign OIDs as integers
(defun f_type (typeN)
  (if (listp typeN) 'integer typeN))

;generated name of the dt's validation function
(defun validate_f_name (typeN)
  (mkatom (concat 'validate_ typeN)))

(defun gen_mdb_name (name)
  (if (listp name)
      (mkatom (concat (first name) '_AT_ (second name)))
    name))

;compose a coerction function name
(defun gen_intern_fn_name (typeN supertypeN)
  (mkatom (concat typeN  
		  '_to_ 
		  (gen_mdb_name supertypeN) 
		  coerceFuncsNameSuffix)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Predicate functions to detect different kinds of objects and types
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;derived type predicate

(defun dt_p (tpo)
  (and (oid-p tpo)
       (memq _DerivedType_ (oid-types tpo))))

;derived type object predicate
(defun dt_obj_p (obj)
  (and (oid-p obj) (getobject obj 'dto)))

;user-defined type predicate testing

(defun ut_p (tpo)
  ;; Test if type TP is defined by user
  (and (oid-p tpo) (osql-subtypep tpo _userobject_ t)))

;function predicate     
(defun function_p (f)
  (and (oid-p f)
       (memq _function_ (oid-types f))))


;integration type predicate
(defun i_type? (tp) (if tp (getobject tp 'integration_type)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Initalization of the derived types processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar _extent_funcs_)
(defvar _coerce_funcs_)

(defun init-dt-subsystem ()
  "Enables the dt processing called once in init.lsp"
  ;;extent functions of the derived types
  (setq _extent_funcs_ 
	(create-function _extent_funcs_  ((function)) ((function))))

  ;;coercion functions
  (setq _coerce_funcs_
	(create-function _coerce_funcs_  ((function)) ((boolean))))
  ;; Define the cost hint function for the coersion functions
  (createfunction 'dt-coerce-cost
		  '((function f) (vector bpat) (vector args))
		  '((integer cost)(integer fanout))
		  'FOREIGN
		  '(dt-coerce-cost---++))
    
  ;;fill in the static (i.e Compile-Time Executable)  functions table
  (register_as_cte)

					;enables dt processing operations as template insertation and coercion
  (setq _ENABLE_DT_FLAG_ t)

  T)

(defun register_as_cte () 
  "Registers all the system function that can be executed during
   compile time over constant arguments."
  (let ((cte_funs '(< > >= <= typesof NOT_DT_OBJECT)))
    (mapcar (f/l (f) (register_f f '_static_funcs_ t)) cte_funs)))


(defun register_f_cc (Fname osql_fn flag)
  "Adds fnname to the osql_func. used to register the coercion
   and static funcs."
  (register_f Fname osql_fn flag)
  (register_f (car (selectbody-pred (getselectbody Fname))) osql_fn flag))

(defun register_f (Fname osql_fn flag)
  "instead of the set-function macro with which I have troubles"
  (let ((gfn (if (symbolp Fname)
                 (getfunctionnamed 
		  (if (not flag)
                      (generic-fnname Fname)
		    Fname))
	       Fname)))
    (setfunction-dynamic (getfunctionnamed osql_fn) (list gfn) '(true) nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                    Costhint functions for coersion functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun dt-coerce-cost---++ (obj f bpat args c fr)
  "Compute cost hint for a coersion function.
   TODO: costing can be smarter and check if the coersion function
   was already populated and then compute a cost for (+ +)."
  (cond ((equal bpat #(+ +))
	 NIL)				; non executable
	((equal bpat #(- +))
	 (osql-result f bpat args 1 1))
	((equal bpat #(+ -))
	 (osql-result f bpat args 1 1))
	((equal bpat #(- -))
	 (osql-result f bpat args 1 1))))

(defun set-coerce-fn-costs (coerce-fn)
  "Set the costhint of a newly created coersion function.
   Called in 'create-derived-type'"
  (let ((coerce-fn-relation (get-relation (getfunctionnamed coerce-fn)))
	(cost-fn (getfunctionnamed 'dt-coerce-cost)))
    (declarecosts coerce-fn-relation '(+ +) cost-fn)
    (declarecosts coerce-fn-relation '(+ -) cost-fn)
    (declarecosts coerce-fn-relation '(- +) cost-fn)
    (declarecosts coerce-fn-relation '(- -) cost-fn)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                    Validation detection and insertion
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun insert_validate  (predl)
  (let ( *validate_l*
	 *validate_vars_l*)
    (find_validate predl)
    (if *validate_l* 
	(list 'AND predl (gen_validate_preds))
      predl)))

(defun gen_validate_preds ()
  (debug_pt "VALIDATE LIST" *validate_l*)
  (cons 'AND *validate_l*))

(defun find_validate (pr) 
  (cond 

   ((atom pr) nil)

   ((function_p (car pr))
    (if (and (not (getfunction _coerce_funcs_ (list (car pr))))
	     (not (getfunction _extent_funcs_ (list (car pr)))))
	(check_for_validate pr)))
   (t (mapcar (function find_validate) pr))))
	      
(defun check_for_validate (pr)
  (let ((var (second pr))
	(fncall (third pr)))
    (if (and (symbolp var)
	     (listp fncall)
	     (function_p (car fncall))
	     (eq (functiontype (car fncall)) "stored"))
	(let* 
	    ((head (first fncall))
	     (tail (cdr fncall))
	     (argtypes (append (get-resolvent-argtypes head) 
			       (get-resolvent-restypes head))))
	  (dolist ( v_t (pair tail argtypes))
	    (let ((v (car v_t))
		  (tp (cdr v_t)))
	      (if (and (eq tp (type_of_var v *bindings*))
		       (dt_p tp)
		       (not (memq v *validate_vars_l*)))
		  (progn
		    (setq *validate_vars_l* (cons v *validate_vars_l*)) 
		    (setq *validate_l*
			  (cons (list (mk_vf (cdr v_t)) (car v_t))
				*validate_l*))))))))))
			   
(defun mk_vf (tp)
  (let ((tpn (oid-name tp)))
    (first (resolvents (getfunctionnamed (mkatom (concat 'validate_ tpn)))))))
	   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                    Object deletion extension
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;deletes all derived subtypes objects corresponding to object o
(defun dt_delete_in_subt (o)
  (if (not (deleted-object o))
      (let ((oType (arg-type o)))
	(if (dt_p oType)
	    (del_under_type oType o)
	  (dolist (tp (mapfilter (function ut_p) (arg-types o)))
	    (del_under_type tp o))))))

(defun del_under_type (oType o)
  (let* ((oType_nm (oid-name oType))
	 (subtypes (subtypes oType))
	 (dt_subs (mapfilter (function dt_p) subtypes))
	 (dt_subs_names (mapcar (function oid-name) dt_subs))
         (fn_names (mapcar(f/l (sbt)(pack (gen_intern_fn_name sbt oType_nm)))
			  dt_subs_names))
	 (dt_objs1 (mapcar (f/l (fn) (caar (getfunction fn (list o)))) 
			   fn_names))
	 (dt_objs  (mapfilter (f/l (e) e) dt_objs1)))

    (debug_do
     (if dt_objs
	 (formatl t "In type " oType " for object " o
		  " Chain delete objects in types: "
		  dt_subs_names " objects: " dt_objs t )))

    (dolist (obj dt_objs) (deleteobject obj))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;          Functions used during debugging
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                
;returns all functions a type is involved in
(defun af (tp)
  (pps (if (oid-p tp)   
	   (allfunctionsfortype tp)
	 (allfunctionsfortype (gettypenamed tp)))))


(defun ppb () 
  (progn (print '-------------------------*bindings-----------------------)
	 (pps (mapcar (function arraytolist) *bindings*))
	 (print '-------------------------*bindings-----------------------)
	 nil))

