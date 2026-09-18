;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997 Vanja Josifovski, EDSLAB
;;; $RCSfile: coerce.lsp,v $
;;; $Revision: 1.16 $ $Date: 2013/12/30 13:35:53 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: run-time and compile-time coercion
;;; =============================================================
;;; $Log: coerce.lsp,v $
;;; Revision 1.16  2013/12/30 13:35:53  torer
;;; Better support for tuples
;;;
;;; Revision 1.15  2012/04/24 14:59:52  torer
;;; Using COMPOUND-P
;;;
;;; Revision 1.14  2010/08/27 07:49:55  torer
;;; Type inference of {} in function arguments
;;;
;;; Revision 1.13  2008/04/03 15:00:49  torer
;;; reopt.lsp depatched
;;;
;;; Revision 1.12  2006/11/04 16:18:19  torer
;;; Systematically using GET-RESOLVENT-ARGTYPES and GET-RESOLVENT-RESTYPES
;;;
;;; Revision 1.11  2006/07/24 21:32:18  torer
;;; Not called Lisp function APPLYFUNCTION removed
;;;
;;; =============================================================

;the static coercion first passes through the code and finds all places where
;coercion is needed. Info about the extra predicates to be generated is saved
;in this variable in a special format. The preds are generated in a second phase
(defvar *coerceList* nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; run-time (dynamic) oid coercion used before OIDs are STORED in functions.
; Takes an OID list and types, and coerces the OIDs to the types
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;dynamic coercing during storing in functions. Here the types
;are not known during compile time. Called from PARTEVAL-ADDFUNCTION
;and ADDFUNCTION0 in proc.lsp
(defun dynamic-coerce (typesL oidL)
  (tolist oidL)
  (if typesL
      (mapcar (f/l (t_up oid)
		   (if (oid-p oid)
		       (let ((t_dn (arg-type oid)))
			 (if (dt_p t_dn)
			     (if (not (or (eq t_dn t_up)
					  (i_type? t_dn)
					  (i_type? t_up)))
				 (progn
				   (debug_do (formatl t "coerced!!!!" t))
				   (dt_coerce_oid t_dn t_up oid))
			       oid)
			   oid))
		     oid))
	      typesL
	      oidL)
    oidL))

;oid coercion: oid of type t_down is coerced to the returned value of typet_up
(defun dt_coerce_oid (t_down t_up oid)
  (let ((chain (dt_inherit_chain t_down t_up)))
    (if chain
	(dt_coerce_chain_oid chain oid)
      nil)))


;the real work of oid coercion is done here. Chain is a list of types
(defun dt_coerce_chain_oid (chain oid)
  (if (eq (length chain) 1)
      oid
    (let* ((typeN   (oid-name (car chain)))
	   (superN  (oid-name (cadr chain)))
	   (iFnName (mkatom (concat 'i_ (gen_intern_fn_name typeN superN))))
	   (iFn (car (resolvents (getfunctionnamed iFnName))))
           (c_oid   (getfunction iFn (list oid))))
      (if c_oid
	  (dt_coerce_chain_oid (cdr chain) (caar c_oid))
	(amos-error "Could not coerce oid: " oid)))))


;finds a path in the inheritance tree between two types.
;If t_up is a direct supertype of t_down returns t_up
;otherwise returns a list of types in the path.
;nil if the types are not 'related'
(defun dt_inherit_chainR (t_down t_up)
  (let ((imm_st (getobject t_down 'SUPERTYPES))
	(ret_val nil))
    (if (member t_up imm_st)
	(setq ret_val t_up)
      (dolist (st imm_st)
	(if (member t_up (getobject st 'allsupertypes))
	    (return (setq ret_val st)))))
    (if ret_val
	(if (dt_p ret_val)
	    (cons ret_val (dt_inherit_chainR ret_val t_up))
	  (list ret_val))
      nil)))
      
;patches the result of dt_inherit_chainR to be always a list starting with t_down
(defun dt_inherit_chain (t_down t_up)
  (let ((result (dt_inherit_chainR t_down t_up)))
    (if (listp result)
	(cons t_down result)
      (list t_down result))
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Static coercion. Generates code which is inserted in the query
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Static coercing. Takes a TR predicate and adds the coercing predicates
;Called before optimization. *bindigs* is  dynamicaly bound from the
;calling envirionoment. Called through apply_to_pred from optimize-pred
(defvar *in_template_gen* nil) ;a template generation flag to disable certain
                               ;compilation phases for the extent templates

(defun coerce_expand (predl sb)
  (if (and _ENABLE_DT_FLAG_
	   (not *in_template_gen*) 
	   (not *do_not_coerce*) 
	   (not (atom predl)))
      (let* (*coerceList* 
	     (*locals* (selectbody-locals sb))
	     (allvars  (mapfilter (function symbolp) (unnest_list predl)))
	     (argresl  (selectbody-argresl sb))
	     (Npred (mapcar (f/l (pr) (coerce_expandR pr allvars argresl))
			    predl))
	     (dummy (coerce_input_vars))
	     (gp (gen_predicates)))
	(setq Npred (append Npred gp))
;	(if (or (eq 'AND (car Npred)) 
;		(eq 'OR  (car Npred)))
;	    (setq Npred (append Npred gp))
;	  (setq Npred (append (list 'AND Npred) gp)))
	(update-locals sb *locals*)
	(debug_pt "COERCION LIST:" *coerceList*)
	Npred)
    predl))

;Traverses a TR predicate and detects the coerctions needed
;The longest function in the 'hood. Three cases, fairly independed
;of each other.
(defun coerce_expandR (predl &optional allvars argresl)
  (if (or (symbolp predl) (osql-constantp predl)(tuplep predl))
      predl
    (let ((head (first predl))
	  (tail (cdr predl)))

      (cond 

					;case 1: AND or OR headed list
					;this case obsolete, never comes here
       ((compound-p predl)
	(let ((rl (list head)))
	  (dolist (TRclause tail)
	    (setq rl (cons (coerce_expandR TRclause) rl)))
	  (reverse rl)))

					;case 2: equality predicate
       ((eq _=_ head)
	(let* ((var (first tail))
	       (Nvar var)
	       (rhs (second tail))
	       (var_type (type_of_var var *bindings*))
	       (rhs_coerced (coerce_expandR rhs))
	       (rhs_type (cond
                          ((osql-constantp rhs)(arg-type rhs))
			  ((listp rhs)   (get-resolvent-restypes (first rhs)))
			  ((symbolp rhs) (type_of_var rhs *bindings* ))
			  ((oid-p rhs) (arg-type rhs))
			  (t           nil))))
	
	  (if (eq var_type rhs_type)	;most common case, to avoid the rest
	      nil			;do nothing
	    (if  (and (or (and (dt_p var_type)
			       (or (ut_p rhs_type) (dt_p rhs_type)))
			  (and (dt_p rhs_type)
			       (or (ut_p var_type) (dt_p var_type))))
		      (not (i_type? var_type))
		      (not (i_type? rhs_type)))

		(progn
		  (setq Nvar (dt_genvar rhs_type))
		  (expand_coerce_list var Nvar var_type rhs_type))))
		  
	  (list _=_ Nvar rhs_coerced)))


					;case 3: other function applications
       ( (or (function_p head) (eq head 'call))
	 (if (eq head 'call)
	     (progn
	       (setq head (third predl))
	       (setq tail (cddddr predl))))
	 (let* ((argtypes1 (append (get-resolvent-argtypes head) 
				   (get-resolvent-restypes head)))
		(Ltail (length tail))
		(Larglist (length argtypes1))
		(argtypes (if (> Ltail Larglist)
			      (padd argtypes1 (- Ltail Larglist))
			    argtypes1))
		(new_arg_list  
		 (mapcar (f/l(tp arg)(check_for_coerce tp arg allvars argresl))
			 argtypes tail)))
	   (if new_arg_list
	       (cons head new_arg_list)
	     predl)))

					;default case, should not appear
       (t (progn (formatl t "Unknown case:  " ) (pps predl) (help)
		 (bp stopit) predl)))))) 


;checks if the variable arg should be coerced to the type tp
(defun check_for_coerce (tp arg allvars argresl)
  (let ((arg_tp (cond
		 ((symbolp arg) (type_of_var arg *bindings*))
		 ((oid-p arg) (arg-type arg))
		 (t nil))))

    (if (and (not (eq arg_tp tp))
	     arg_tp
	     tp
	     ;;small optimization, to detect when a variable is not used
	     ;;further in the code to avoid coercion
	     ;;some of the IT system gen functions benefit from this case!
	     (or (not (symbolp arg))
	         (memq arg argresl)
	     	 (< 1 (length (mapfilter (f/l (e) (eq e arg)) allvars))))
	     (not (i_type? tp))
	     (not (i_type? arg_tp))
	     (not (memq arg *extendedVars*))
	     (or 
	      (and (dt_p tp) (not (null arg_tp)))
	      (and (dt_p arg_tp)
		   (or (dt_p tp) (ut_p tp)))))
	(let ((n_var (dt_genvar tp)))
	  (expand_coerce_list n_var arg tp arg_tp)
	  n_var)
      arg)))



;padds the list l with n nil entries at the end
(defun padd (l n &optional el)
  (let '(nil_tail)
    (dotimes (i n)
      (setq nil_tail (cons el nil_tail)))
    (append l nil_tail)))


;given two variables and their types, generate the right entries to
;the coercion list (depending on their relative position in the type hirerachy)
(defun expand_coerce_list (var Nvar varType NvarType)
  (debug_do (formatl t "Coercion between " var " of type " varType
		     " <---> " Nvar " of type " NvarType t))
  (cond 


    
   ;;case 1 
   ((subtype-of NvarType varType) 
    (setq *coerceList* (cons (list var Nvar varType NvarType) *coerceList*)))

   ;;case 2
   ((subtype-of varType NvarType)
    (setq *coerceList* (cons (list Nvar var NvarType varType) *coerceList*)))

   ;;default case, find the common supertype if there is one
   ;;else patch the query with an equality to have the same
   ;;semantics as before (although the changed predicate will be always false)
   (t (let  ((target (car 
		      (mapfilter (F/L (tp) (or (ut_p tp) (dt_p tp))) 
				 (intersection (getobject varType 
							  'allsupertypes)
					       (getobject NvarType 
							  'allsupertypes))))))
	(if target
	    (progn
	      (let ((target_var (dt_genvar target)))
		(setq *coerceList* (cons (list target_var Nvar target NvarType)
					 (cons (list target_var var target 
						     varType)
					       *coerceList*))))))))))
	  


;deduces a variable type from given binding; bindingsList format as *bindings*
(movd 'type-of-var 'type_of_var) ; recoded in C by TR

;returns a type of a var or a constant
(defun type_of_arg (a bindingsList)
  (if (symbolp a)
      (type_of_var a bindingsList)
    (car (arg-types a))))


;given a list of coerctions generates the coercion TR predicates
(defun gen_predicates ()
  (let (ret_list)
    (dolist (i *coerceList*)
      (if (dt_p (fourth i))
	  (let ((chain (dt_inherit_chain (fourth i) (third i))))
	    (setq ret_list 
		  (append ret_list 
			  (dt_mk_pred chain (first i) (second i) nil))))
	(setq ret_list (nconc1 ret_list (list _=_ (first i) (second i))))))
    ret_list))
;select name(ss1) for each ss1 where ss1=:i1;

;generates coerction predicate for one entry of the coerction list
;the input is a inheritance chain starting variable, ending variable,
;soFar is used in the recursion to accumulate the result
(defun dt_mk_pred (chain lhs_var arg_var soFar)
  (if (eq (length chain) 1)
      soFar
    (let* ((typeN   (oid-name (car chain)))
	   (superN  (oid-name (cadr chain)))
	   (FnName (gen_intern_fn_name typeN superN))
           (act_lhs (if(eq (length chain) 2) lhs_var (dt_genvar (cadr chain))))
	   (nPred   (cons 
		     (list (get-relation (car (resolvents 
					       (getfunctionnamed FnName))))
			   act_lhs
			   arg_var)
		     soFar)))
      (dt_mk_pred (cdr chain) lhs_var act_lhs nPred))))

;adds coecion entries for the input variables. This is detected during the
;insert_templates and recorded in the variable *coerced_input*
(defun coerce_input_vars ()
  (mapcar (f/l (iv_cvl)
	       (let ((iv (caar iv_cvl))
		     (cvl (second iv_cvl)))
		 (mapcar (f/l(cv) 
			     (expand_coerce_list iv cv 
						 (type_of_var iv *bindings*)
						 (type_of_var cv *bindings*)))
			 cvl)))
	  *coerced_input*))

