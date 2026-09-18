;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997 Vanja Josifovski, EDSLAB
;;; $RCSfile: dtcreate.lsp,v $
;;; $Revision: 1.30 $ $Date: 2009/09/04 15:41:39 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Macros and functions for lisp code generation
;;;		  for the derived types creation
;;; =============================================================

(defmacro create-derived-type (typeN super1 keys subInfo1 props)
  "Entry macro called from the expression composed by the parser."
  (progn
    (debug_do
     (formatl t "Creating Derived Type " typeN t)
     (formatl t "Subtype of " super1 t)
     (formatl t "Keys: " keys t)
     (formatl t "Supertype of" subInfo1 t)
     (formatl t "User properties: " props t))
    (let* ((super (cons (fix_at_decl (car super1) t) (cdr super1)))
	   (superNames1 (heads (first super)))
	   ;;translates the external type names from a 
	   ;;list format to symbols 
	   (subinfo (cons
		     (mapcar (f/l (se) 
				  (cons (list (type_name_symbol (caar se)))
					(cdr se)))
			     (car subinfo1))
		     (cdr subinfo1)))
	   (realSubNames (mapcar (function caar) (car subInfo)))
	   (subNames (if realSubNames (all_aux_namesl typeN realSubNames)))
	   ;;some checking of the IUT definition
	   (dummy1 (check_subinfo_consistency subinfo typeN))
	   ;;the inverse key functions for the constituent types are saved 
	   ;;these are not related to the IUT with their arg/res types 
	   ;;and must be explicitly deleted when a IUT is deleted
	   (ifuncs (process_dst_def typeN keys subInfo)) 
	   (supPropsFunc 
	    (let ((code nil)) 
	      ;;(if (= (length superNames1) 1) '(AS (O1) WHERE (= O1 O)))))
	      (mapcar (f/l (spn)
			   `(let (coerce-fn)
			      (setq coerce-fn
				    (CREATE-FUNCTION
				     , (gen_intern_fn_name typeN spn)
				     ((, (f_type spn) O KEY))
				     ((, typeN O1 KEY))
				     , code))
			      (register_f_cc coerce-fn '_coerce_funcs_)
			      ;; set the costhint of the coersion function
			      (set-coerce-fn-costs coerce-fn)))
		      superNames1)))
	   (supPropsInvers
	    ;; timour: I think these functions should not be imported as well
	    (mapcar (f/l (superN)
			 (list 'let (list (list 'fno 
						(create_inverse_function 
						 typeN superN)))
			       '(if fno (/putobject fno 'systemfn T))
			       'fno))
		    superNames1))
	   (externSuperNames (mapfilter (function listp) superNames1))
	   (superNames superNames1))
      `(let ((*DSVE-STRATEGY* 'dsve-none)
	     (ndt (createusertype ,(kwote typeN) ,(kwote superNames) 
				  ,(if (and keys subinfo) _iuttype_ 
				     _derivedtype_) 
				  ,(kwote subNames)))
	     extF extT c_func valF)
	 ,@
	 (compileproperties  typeN props)
	 ,@
	 supPropsFunc
	 ,@
	 supPropsInvers
	 (debug_do (formatl t t  "Generating the c-function...."  t))
	 (setq  c_func 
		(create-c-function , typeN , superNames1 , subNames , keys))
	 (debug_do (formatl t t "Generating the validate function...." t))
	 (let ((*no_typechecks* t))
	   (setq valF
		 (create-validate-function , typeN , super , subNames)))

	 (debug_do (formatl t t "Generating the extent function...." t ))
	 (setq extF 
	       (create-extent-function , typeN , super , subNames))
	 (debug_do (formatl t t "Generating the extent template...." t))
	 (setq extT 
	       (create-extent-template , typeN , super , subNames))
	 ;;add some properties used later 
	 (/putobject extF 'cFunc   c_func)
	 (set-type-container extF)
	 (/putobject extF 'ofType ndt)	 
	 (/putobject extT 'ofType ndt)
	 ;; mark the functions as system, so they are not exported
	 (/putobject extF 'systemfn T)	 
	 (if valF (/putobject valF 'systemfn T))
	 (/putobject extT 'systemfn T)
	 (if c_func 
	     (progn
	       ;; timour:I think these functions should not be imported as well
	       (/putobject c_func 'systemfn T)
	       (/putobject c_func 'cFunc 'T)
	       (/putobject c_func 'keytypes , (kwote (car keys)))))
	 (/putobject ndt  'supernames , (kwote superNames1))
	 (/putobject ndt  'subnames   , (kwote subNames))
	 (/putobject ndt  'extF  extF)
	 (/putobject ndt  'extT  extT)
	 (if , (kwote ifuncs) (/putobject ndt 'ifuncs , (kwote ifuncs)))
	 (addfunction  _extent_funcs_ (list extF) (list extT))
	 ;;(process_dst_def , (kwote typeN) , (kwote keys) , (kwote subInfo))
	 (dst_postproc  , typeN , keys , realSubNames)
	 (dst_functions , typeN , keys , subInfo)
	 ndt))))

(defmacro create-validate-function (typeN super subNames)
  (if (not subNames)
      (let*
	  ((foreachL (first super))
	   (fName (validate_f_name typeN))
	   (arglExpr (list (list typeN 'OBJ)))
	   (verSupPreds (mapcar (f/l (t_v) (gen_val_pred t_v typeN))
				(first super)))
	   (validatePredicate (second (second super))))
	`(CREATE-FUNCTION , fName , arglExpr ((BOOLEAN))
			    AS (TRUE) FOREACH , foreachL WHERE
			    (AND , validatePredicate ,@ verSupPreds)))))

(defun gen_val_pred (t_v typeN)
  (let* ((varType (first t_v))
	 (var (second t_v))
	 (coerceExpr `(= OBJ (, (gen_intern_fn_name typeN varType) , var)))
	 (validateExpr (list  (validate_f_name varType) var))
	 (vto (gettypenamed varType)) 
	 (ptcheck (if (proxytype? vto)  `(= , vto (typesof , var))))
	 (expr (list coerceExpr)))
    (if (dt_p vto)
	(setq expr (cons validateExpr expr)))
    (if ptcheck
	(setq expr (cons ptcheck expr)))
    (andify expr)))
	 
(defmacro create-extent-function (typeN super subNames)
  "Creates the ipl function extent_TYPENAME which is inserted by compileselect
   to select the objects of a derived type."
  (if (not subNames)
      (let*
	  ((foreachL (first super))
	   (fName (extent-function-name typeN))
	   (cFuncName (pack cFuncPrefix typeN))
	   (cFuncArgs (getvars (first super)))
	   (predicates (second super))
	   (anded_predicate (if predicates
                                (if (second predicates)
				    (cons 'AND predicates)
				  (first predicates))
			      nil)))
	;;(formatl t predicates (second predicates)(cons 'AND predicates) t) 
	`(store-extent-function-dt 
	  (quote , typeN)
	  (DEFINE-PROC , fName NIL , (list (list typeN 'KEY))
	    (OSQL-FOREACH , (first super) , anded_predicate NIL 
			    (PROC-BLOCK 
			     (OSQL-RETURN ( , cFuncName ,@ cFuncArgs)))))))
    `(create_it_extent_function , (kwote typeN) , (kwote  subNames))
    ))

(defun store-extent-function-dt (type proc)
  "Since DTs are implemented using extent functions with side effects (ugly),
   we have to set cost so that it is called first in plan"
  (let ((fno (store-extent-function type proc)))
    (declarecosts fno '(+) '(0.00001 0.00001))
    fno))

(defmacro create-extent-template (typeN super subNames)
  (if (not subNames)
      (let*
	  ((foreachL (first super))
	   (fName (pack 'Textent_ typeN))
	   (varlist (getvars (first super)))
	   (predicates (second super))
	   (anded_predicate (if predicates
				(if (second predicates)
				    (cons 'AND predicates)
				  (first predicates))
			      nil)))
	;;(formatl t predicates (second predicates)(cons 'AND predicates) t) 
	`(let ((*in_template_gen* t))
	   (CREATE-FUNCTION , fName NIL , (first super) AS , varlist
			      FOREACH  , foreachL
			      WHERE , anded_predicate)))
    'extF));; Bug here! extF is unbound!

(defun create_it_extent_function (typeN subTnames)
  "Create integration type extent function as an OR of the extent functions 
   of the integrated types."
  (resetgenvar
   (let* (*bindings* 
	  *locals*
	  (dt (gettypenamed typeN))
	  (subt (gettypesnamed subTnames))
	  (varN (mkatom (concat typeN '_o)))
	  (dummy (addbinding varN nil (gettypenamed typeN)))
	  (resl (list varN))
	  (sb (make-selectbody :rest dt 
			       :resl resl))
	  (fno (createfunction (extent-function-name typeN) nil nil))
	  (extfns (mapcar (function get-extent-function)
			  subt))
	  (pred (orify  (mapcar (f/l (ef) (list _=_ varN (list ef))) 
				extfns))))
     (store-extent-function dt fno)
     (/putobject fno 'restypes (list dt))
     (/putobject fno 'resolvents (list fno))
     (/putobject fno 'selectbody sb)
     (/putobject dt 'integration_type subt)
     (compile_phase2 pred resl nil nil nil fno sb)
     fno)))

(defmacro create-c-function (typeN superNames subNames keys &optional nsf)
  "Creates a c-function used in the derived types extent function:
   extend(dt ) = select c-function(supertypes) for each where predicate....
   keys is a pair of the key types list and the keys storage function name,
   e.g ((integer integer) skeys_int_emp)."
  (resetgenvar 
   (if (not subNames)
       (let*
	   (*bindings* *locals*
	    (ret_var (mkatom (concat typeN '_o)))
	    (arg_list1 (mapcar (f/l (x) (list x (mkatom (concat x '_o)))) 
			       superNames))
	    (key_types (car keys))
	    (key_vars  (genvars key_types))
	    (keys_vt   (pairlist key_types key_vars))
	    (arg_list  (append arg_list1 keys_vt))
	    (sf_list1 (mapcar (f/l (x) 
				   (list 'setfunction 
					 (kwote (gen_intern_fn_name typeN x))
					 `(list , (pack x '_o))
					 '(list nObj)
					 nil
					 t))
			      superNames))
	    (sf_list 
	     (if keys
		 (cons 
		  (list 'setfunction (kwote (second keys)) (cons 'list key_vars)
			'(list nobj))
		  sf_list1)
	       sf_list1))
	    (chk 
	     (if keys
		 (append (list 'chk_func1 (kwote (second keys))) key_vars)
	       (cons 
		'allequal 
		(mapcar (f/l (x) 
			     (list 
			      'chk_func1 
			      (kwote (gen_intern_fn_name typeN x)) 
			      (mkatom (concat  x '_o))))
			superNames))))
	    (Fname (mkatom (concat  cFuncPrefix typeN)))
	    (ret_list (list (list typeN ret_var))))
	 (add-key-dcl arg_list)
	 (add-key-dcl ret_list)
	 (if (or superNames nsf)
	     ;;(if (= (length superNames) 1)
	     ;;    (list 'create-function Fname arg_list ret_list 
	     ;;	   (list 'AS (cdar ret_list) 'WHERE (list '= (cdar ret_list)
	     ;;						  (cdar arg_list))))
	     `(foreign-lispfn , Fname  , arg_list , ret_list
				(let ((ret_var , chk))
				  (if ret_var
				      (progn 
					(set_ms_type ret_var 
						     , (gettypenamed typeN))
					(foreign-result ret_var))
				    
				    (let* ((nObj (create-userobjects , typeN)))
				      (/putobject nObj 'dto T)
				      ,@
				      sf_list
				      (foreign-result nObj)))))
	   nil)))))

(defun add-key-dcl (dcll) 
  "Add KEY keyword if only one declaration"
  (cond ((cdr dcll))			; more than one declaration
	((memq 'key (car dcll)))	; KEY already declared
	(t (nconc1 (car dcll) 'key))))	; add the KEY declaration 
               
(defun set_ms_type (obj type)
  (if (neq type (arg-type obj))
      (progn 
	(removetype1 (list obj) (arg-type obj))
	(/addtype obj type))))

;(defmacro create-mat-function (typeN superNames subNames keys cfunc)
;  (if (not subNames)
;      (if (not keys)
;	  cfunc
;	(let*
;	    ((arg_list (mapcar 
;			(f/l (x) (list x (mkatom (concat x '_o)))) 
;			superNames))
;	     (Fname (mkatom (concat  cFuncPrefix typeN)))
;	     (ret_list (list (list typeN (mkatom (concat typeN '_o))))))

(defun create_inverse_function (typeN superTypeN_1)
  "Creates a derived function as an invers of the stored function which
   maps an supertype object to its derived type object
   this functions are used in the path traversal done during object coercing."
  (let* ((supertypeN (gen_mdb_name supertypeN_1))
	 (retType (if (listp superTypeN_1) 'integer superTypeN))
	 (arg (list (list typeN (pack typeN '_o ) 'KEY)))
	 (res (list (list retType (pack superTypeN '_o) 'KEY)))
	 (fnName (gen_intern_fn_name typeN superTypeN))
	 (superObj (pack superTypeN '_o))
	 (typeObj  (pack typeN '_o)))
    `(CREATE-FUNCTION , (pack 'i_ fnName) , arg , res  AS (, superObj)
			WHERE (= , typeObj (, fnName , superObj) ))))

(defun fix-simple-decl (typeN)
  "Fixes the parser tree when no variable is present
   called only from the parser (yyparse.c)"
  (let* ((tp (car typeN))
	 (var (if (atom tp) tp (car tp))))
    (list (copy-tree tp) (copy-tree var))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Derived supertypes auxiliary types and funcitons generation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun check_subinfo_consistency (subinfo iutname)
  "This function checks and reports semantic errors in the IUT definition.
   Currently it checks only if the declared list of functions matches the
   function list definition for each of the cases, more can be added."
  (let* ((funcs (second subinfo))
	 (fnnames (heads (car funcs)))
	 (fnimplist (second funcs))
	 (fnimplnames(mapcar (f/l (fnimp) 
				  (list (Car fnimp) 
					(heads (cadr fnimp))))
			     fnimplist))
	 (errs (mapcar (f/l (fnimp) 
			    (let ((f (first fnimp))
				  (s (second fnimp)))
			      (list f 
				    (set-difference s fnnames)
				    (set-difference fnnames s))))
		       fnimplnames)))
    (mapcar (f/l (err_rec)
		 (if (not (equal (second err_rec) '(nil)))
		     (amos-error 
		      "Undeclared function(s) in definition of the IUT " 
		      iutname ", case " (car err_rec) ", functions " 
		      (butlast (Second err_rec))))
		 (if (third err_rec)
		     (amos-error 
		      "Undefined function(s) in definition of IUT "
		      iutname ", case " (car err_rec) ", functions" 
		      (third err_rec))))
	    errs)))

(defun process_dst_def (typeN keys subInfo)
  "Entry function 1
   Process the definition of a Explicit Supertype (Integration Type)"
  (if (and keys subInfo)
      (let* ((subtypes (car subInfo))
	     (funcs (second subInfo))
	     (ifuncs (mapcan (f/l (kdef) 
				  (create_dst_key_funcs typeN keys kdef ))
			     subtypes)))
	(gen_aux_types typeN subtypes keys)
	ifuncs)))

(defun join_at_name (tpn)
  "name of inner AT"
  (mkatom (concat 'JOIN_ tpn)))

(defun side_at_name (tpn)
  "name of outer ATs"
  (mkatom (concat 'ONLY_ tpn)))

(defun all_aux_namesl (typeN sl)
  (list  (join_at_name typeN)  
	 (side_at_name (car sl)) 
	 (side_at_name (second sl))))

;This blok defines the Aux Types (AT) for a integration type
;For each AT: a name, predicate and supertype list is generated
;the join AT is treated separate, while the two site ATs
;have simetrical generation and are therefore generated using one function
(defun gen_aux_types (typeN subtypes keys)
  (let* ((simplest (mapcar (f/l (tl_v_e) (list (caar tl_v_e) (second tl_v_e)))
			   subtypes))
	 (firstST  (car simplest))
	 (secondST (second simplest)))
    (gen_join_aux_dt firstST secondST typeN keys)
    (gen_side_aux_dt firstST secondST typeN keys)
    (gen_side_aux_dt secondST firstST typeN keys)))

(defun gen_join_aux_dt (firstST secondST typeN keys)
  "Gen. the middle AT (join)"
  (let* ((name (join_at_name typeN))	 
	 (pred (list '= (list (key_func_name (car firstST))
			      (second firstST))
		     (list (key_func_name (car secondST))
			   (second secondST))))
	 (supers (list firstST secondST)))
    (gen_aux_dt  name pred supers keys)))

(defun gen_side_aux_dt (firstST secondST typeN keys)
  "Gen a side AT"
  (let* ((name (side_at_name (car firstST)))
	 ;;this naming scheme should be changed for more than 2 subtypes
	 (pred (list (rkey_func_name (car secondST))
		     (list (key_func_name (car firstST))
			   (second firstST))))
	 (supers (list firstST)))
    (gen_aux_dt  name pred supers nil)))

(defun gen_aux_dt (name pred supers keys)
  "Issue the actual create-derived-type call for AT generation."
  (let* ((at (eval(list 'create-derived-type name (list supers (list pred nil))
			nil nil nil)))
	 ;; The above eval difficult to remove since CREATE-DERIVED-TYPE
	 ;; generates macro expressions too
	 (stn (if (listp (caar supers)) (caadr supers)
		(caar supers))))
    (/putobject at 'hidden t)
    (gen_at_keyf name stn keys)))

(defun gen_at_keyf (atn stn keys)
  "Generate key functions for the ATs."
  (let* ((kfn (key_func_name atn))
	 (kfnst (key_func_name stn))
	 (inl (list (list atn '_vti_)))
	 (res (list (list kfnst '_vti_))))
    (createfunction kfn inl keys res nil nil nil t)))

(defun create_dst_key_funcs (typeN keys kdef)
  "Each of the types integrated by an explicit supertype has
   3 functions defined: 
   keyf(instance) -> keys
   ikeyf(keys) -> instance
   rkeyf(keys) -> nil if it is a key and true if it is not a key
   ikeyf is an aux function, the other 2 are used in the generated preds."
  (let* ((tpn (caar kdef))
	 (fname (key_func_name tpn))
	 (argl  (list (list tpn (second kdef))))
	 (ifname  (ikey_func_name tpn))
	 (keyvars (getvars keys))
	 (ifrom   `((, tpn _itv_))) 
	 (iwhere  `(= (, fname _itv_) , (maketuple keyvars)))
	 (iselect `((ATRUE , (car keyvars))))
	 (iresl    `((INTEGER _itv2_)))	 
	 (rfname  (rkey_func_name tpn))
	 (rwhere (list 'NOTANY (cons ifname keyvars)))
	 res
	 ;;(rresl '((BOOLEAN))
	 )     
    ;;(bp test1)		     		    
    (list
     (createfunction fname argl keys (third kdef) nil nil)
     (createfunction ifname keys iresl iselect ifrom iwhere)
     (createfunction rfname keys nil NIL nil rwhere))
    ))

(defmacro dst_postproc (typeN keys subn)
  "Entry function 2
   Generate some functions that need to be generated after the IT generation."
  (if (and subn keys)
      (let* ((sfname (key_storage_func_name typeN))
	     (input  (if (> (length keys) 1)
			 keys
		       (list (list (caar keys) '_vti_ 'key))))
	     (out    (list (list typeN '_vti2_ 'key)))
	     (sdef (list 'create-function sfname input out))
	     (ktns (heads keys))
	     (rccf1 (gen_rccf_call (join_at_name typeN) typeN ktns))
	     (rccf2 (gen_rccf_call (side_at_name (car subn)) typeN ktns))
	     (rccf3 (gen_rccf_call (side_at_name (second subn)) typeN ktns)))
	(list 'progn sdef rccf1 rccf2 rccf3))))

(defun gen_rccf_call (subtn itn ks) 
  (list 'recreate_c_func subtn itn ks))

(defmacro recreate_c_func (tpn itpn keyTypesN)
  "Recreate the c-funcs of the ATs to include storing the key information."
  (let* ((tp (gettypenamed tpn))
	 (itp (gettypenamed itpn))
	 (superNames (getobject tp 'supernames))
	 (subNames   (getobject tp 'subnames))
	 (skeyf (key_storage_func_name itpn)))
    `(let ((cfn , (list 'create-c-function tpn superNames subNames 
			(list keyTypesN skeyf)))
	   (extF (getobject (gettypenamed , (kwote tpn)) 'extF)))
       (/putobject extF 'cFunc cfn)
       (/putobject cfn 'cFunc 'T)
       (/putobject cfn 'systemfn T)
       (/putobject cfn 'keytypes  ,  (kwote keyTypesN))
       cfn)))

(defun fix_keyf_func (dtname)
  (let* ((fn (car (resolvents (getfunctionnamed (key_func_name dtname)))))
	 (efn (getobject (gettypenamed dtname) 'extf))
	 (sb (getobject fn 'selectbody))
	 (pred (selectbody-pred sb)))
    (setf (selectbody-pred sb) 
	  (mapfilter (f/l (pr) (and (listp pr) (not (eq efn (car pr)))))
		     pred))))

(defmacro dst_functions (typeN keys subInfo)
  (if (and keys subInfo)
      (let* ((subtypes_kdefs (car subInfo))
	     (subtypes (mapcar (f/l (tl_v_e) (list (caar tl_v_e) 
						   (second tl_v_e)))
			       subtypes_kdefs))
	     (funcsall  (second subInfo))
	     (funcdecls (first funcsall))
	     (cases (second funcsall))
	     (idecls (mapcar (f/l (a) (list (second a) (car a))) funcdecls))
	     (alldecls  (append keys idecls))
	     (itf_defs  (gen_itf_defs typeN alldecls))
	     (case_defs (mapcan 
			 (f/l (cs) (gen_case_defs subtypes typeN cs idecls))
			 cases)))
	(list* 'let '((*delayrecompile* t)) (append itf_defs case_defs )))))

(defun itf_def (form)
  `(let* ((*no_typechecks* t)
	  (fn , form))
     (setf (selectbody-pred (getobject fn 'selectbody)) 'FALSE)))

(defun gen_itf_defs (typeN ftl)
  (let ((resl (list (list typeN))))
    (mapcar (f/l (ft) (itf_def 
		       (list 'create-function (cadr ft) resl 
			     (list (mklist (car ft)))
			     )))
	    ftl)))
		 
(defun gen_case_defs (subtypes typeN cs decls)
  (let* ((casel (car cs))
	 (fndl (second cs))
	 (argl (mapfilter (f/l (st) (memq (second st) casel)) subtypes))
	 (argvar (cadar argl))
	 (argTn (cond ((> (length argl) 1) 
		       (join_at_name typeN))
		      (t (side_at_name (caar argl)))))
	 (argN (list (list argTn argvar))))
    (mapcar (f/l (fnd)(gen_case_def (car fnd) (second fnd) argN decls argl)) 
	    fndl)))

(defun gen_case_def (name predIn argN decls argl)
  (if name
      (let* ((rest (car (isome decls (f/l (dec) (eq (second dec) name)))))
             (restype (cons (caar rest)(cdr rest)))
             (vars (getvars argl))
             (types (heads argl))
             (resl  (gen_case_subst_list predIn argl)))
	(list 'create-function name argN (list restype) 'AS resl))))

(defun gen_case_subst_list (l dcll)
  "L is reconciliation expression
   Substitute the functions in L with their resolvents in the
   integrated types. 
   Also, substitute variables with 1st reconciled type variable"
  (mapcar (f/l (fnc)(gen_case_subst_fn fnc dcll)) l))

(defun gen_case_subst_fn (fnc dcll)
  (cond ((atom fnc)(if (searchdcl fnc (cdr dcll))
                       (second (car dcll)) fnc))
	(t (let ((argtpes 
		  (mapcar (f/l (v)
			       (cond ((osql-constantp v)
				      (arg-type v))
				     ((not (symbolp v)) nil)
				     (t (first (searchdcl v dcll)))))
			  (cdr fnc))))
	     (cond ((memq nil argtpes)	; some arg type was not resolvable
		    (cons (car fnc)(gen_case_subst_list 
				    (cdr fnc) dcll)))
		   (t (cons (get-most-specific-resolvent 
			     (car fnc) argtpes)
			    (gen_case_subst_list (cdr fnc) dcll))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                    Run-time lisp support for the generated code 
;                    used in the generated c-functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun chk_func1 (func &rest params)
  "Returns an atom which the last returned value of a function."
  (caar (getfunction func params)))

(defun allequal (&rest lst)
  "If all elements of a list are equal return that element."
  (and lst (listp lst) (every (f/l (e) (equal e (car lst))) lst) (car lst)))
