;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997 Vanja Josifovski, EDSLAB
;;; $RCSfile: etemplates.lsp,v $
;;; $Revision: 1.13 $ $Date: 2008/04/03 15:00:49 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Template insertion and expansion as described in the 
;;;              Coopis98 paper
;;; =============================================================
;;; $Log: etemplates.lsp,v $
;;; Revision 1.13  2008/04/03 15:00:49  torer
;;; reopt.lsp depatched
;;;
;;; Revision 1.12  2006/11/04 16:18:20  torer
;;; Systematically using GET-RESOLVENT-ARGTYPES and GET-RESOLVENT-RESTYPES
;;;
;;; =============================================================


(defvar *change_l* nil)    ;change list used in temlate expansion
(defvar *change_flag* nil) ;flag to signal that an temp. expans. has been done
(defglobal _shallow_extent_)

(defglobal _skip_rmt_ nil) ;flag to skip the removal of multiple typechecks
                           ;used for performance comparations

;Entry function in the template expansion. 
;Takes a predicate function args, result and the context is which is 
;the rest of the predicates in innermost AND where pred is located.
;noExpand inhibits the expansions, only typecheck removals are performed
(defun insert_templates (pred argl resl context &optional noExpand)
  (if (atom pred)
      pred
    (let ((head (car pred))
	  (tail (cdr pred)))
      ;;a function or nested AND/OR predicate
      (cond
       ;;OR
       ((eq head 'OR)
	(cons 'OR 
	      (mapcar 
	       (f/l (x) (let ((xi (if (and (listp x)
					   (neq (car x) 'and) 
					   (neq (car x) 'OR))
				      (list 'AND x)
				    x)))
			  (insert_templates xi argl resl nil noExpand)))
	       tail)
	      ))
       ;;AND
       ((eq head 'AND)
	(let ((Ntail (remove_multi_typechecks tail)))
	  (if (eq Ntail 'FALSE)
	      Ntail
	    (andify (texpand_subst_vars 
		     (flatten-insert 
		      (mapcar
		       (f/l (x) (insert_templates x argl resl Ntail noExpand))
		       Ntail))
		     t)))))
       ;;function
       ((function_p head)
	(let* ((tfn (caar (getfunction _extent_funcs_ (list head))))
	       (sb (if tfn (getobject tfn 'selectbody)))
	       (extentVar (if (eq head _shallow_extent_) (second tail) 
			    (first tail)))
	       (varList (var_closure (list extentVar) context))
	       (iovars (if *expandInputVarTemplates*
			   nil
			 (append argl resl))))
	  ;;different typecheck removal/expansion cases
	  (cond 
	   ;;case 1, remove ordinary types typecheks (typesof predicates)
	   ((and (eq head _typesof_)
		 (symbolp extentVar)
		 (context_typechecked varList (second tail) context nil))
	    nil)
;          shallow extents cannot be removed!!!
;	   ((and (eq head _shallow_extent_)
;		 (symbolp extentVar)
;		 (context_typechecked varList (first tail) context T))
;	    nil)
	 
	   ;;remove dt typecheks (extent_dtName predicates)
	   ;;((and tfn 
	   ;;	 (context_typechecked varList
	   ;;			      (first (function-resulttypes head))
	   ;;			      context nil))
	   ;; nil)

	   ;;case 3, expand dt typechecks
	   ((and tfn 
		 (not noExpand)
		 (symbolp (car tail))
		 (not_iovar (car tail) iovars context)
		 ;;in this case mat. is needed: there is a var = const p.
		 ;;needs to be fixed to get in and be handled properly
	         (null (mapfilter (f/l (e) (not (symbolp e))) varList)))
	    (let* ((livars (append (selectbody-argl sb) 
				   (selectbody-locals sb)))
		   (rvars (selectbody-resl sb))
		   (rvarsTypes (getobject tfn 'restypes))
		   (livarsTypes (append (get-resolvent-argtypes tfn)
					(selectbody-loct sb)))
		   (Nlivars (genvars livarsTypes))
		   (Nrvars (genvars rvarsTypes))
		   (vars (append livars rvars))
		   (Nvars (append Nlivars Nrvars))
		   (rtypes (function-resulttypes tfn))
		   (substl (pair vars Nvars))
		   result)
	      ;;(bp intt)	      
	      ;;coerce the input argument if it is a dt object
	      (if (intersection argl varList)
		  (setq *coerced_input* 
			(cons
			 (cons (intersection varlist argl) (list Nrvars))
			 *coerced_input*))
		(update_coerced_input varList Nrvars))
	      ;;add bindings for the new variables
	      (dolist (r_t (pair Nrvars rtypes))
		(addbinding (car r_t) nil (cdr r_t)))
	      ;;mark that an expansion has been done and generate the final
	      ;;code to be inserted in the query
	      (setq result 
		    (argsof 'and
			    (expand-predicate (selectbody-pred sb) substl)))
	      (setq *change_flag* t)
	      (setq *change_l* 
		    (cons (list (car tail) (pair Nrvars rtypes) extentVar)
			  *change_l*)) 
	      ;;insert a materializ.  predicate if the dt var is in the result
	      (if (or (intersection resl varList) 
		      (intersection *extendedResult* varList))
		  (setq result 
			(append (gen_c_pred  Nrvars extentVar tfn head)
				result)))
	      ;;final book keeping 
	      (if (not context)
		  (setq result (andify result)))
	      result))
	   ;; case 4 either non-extent predicate or var used as a arg of a fnc.
	   (t pred))))
       ;;neither function nor AND/OR
       (t pred)))))

(defun tc_var_not_used (varList context)
   (eq 1 (length (mapfilter (f/l (x) x)
			    (mapcar (f/l (p) (intersection p varList)) context)))))

;generate predicates needed for materialization
;if the materialization is defined by keys, add keyf and expand it.
(defun gen_c_pred (Nrvars extentVar tfn head)
  (let* ((cf   (getobject head 'cFunc))
	 (key_vars (genvars (gettypesnamed 
			     (getobject cf 'keytypes))))
	 (typeN (oid-name (getobject tfn 'ofType)))
	 (keyf (car (resolvents (getfunctionnamed (key_func_name typeN) T))))
	 (prefix (list cf)) 
	 (nentry1 (list 
		   (appendl (list prefix Nrvars key_vars (list extentVar)))))
	 (nentry (if key_vars
		     (append 
		      nentry1
		      ;; this mapfilter is to avoid recursion because
		      ;; the keyf contains a ref to the template as a typechk
                      ;; BUG: cannot handle nested OR! /Tore
		      (mapfilter 
		       (f/l(pr)(not (getobject (car pr) 'ofType)))
		       (argsof 'and
			       (expandfn (cons extentVar key_vars)
					 keyf 
					 (getobject keyf 'selectbody)))))
		   nentry1)))
		     
    (setq *extendedResult* (append Nrvars *extendedResult*))
    (setq *extendedVars* (cons extentVar *extendedVars*))
    nentry))

; add an entry to the list containing the specs. for the input vars coercion
(defun update_coerced_input (varList Nrvars)
 (setq *coerced_input*
  (mapcar (f/l (iv_cvl)
	       (let ((iv (car iv_cvl))
		     (cvl (second iv_cvl)))
		 (if (intersection cvl varList)
		     (cons iv (list 
			       (append (set-difference cvl varList) Nrvars)))
		   iv_cvl)))
	  *coerced_input*)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;typecheks remvals (multiple and single)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;checks an and-list for more than one typecheck of the same variable and
;depending on the types returns one of them or FALSE
;should be extended to handle all combinations of shallow and deep typchecks
;it processes only the deep typechecks now
(defun remove_multi_typechecks (predl)
  (if (not _skip_rmt_)
					;derived types deep typechecks
      (let* ((dt_deep (mapfilter 
		       (f/l (pr) 
			    (and
			     (oid-p (car pr))
			     (getfunction _extent_funcs_ (list (car pr)))
			     (symbolp (second pr))))
		       predl
		       (f/l (pr) (list(car (get-resolvent-restypes (car pr)))
				      (second pr)
				      pr))))
					;ordinary types deep typechecks
	     (ord_deep (mapfilter (f/l (pr) (and (eq _typesof_ (car pr))
						 (oid-p (third pr))))
				  predl
				  (f/l (pr) (list (third pr) (second pr) pr))))
	     (all_deep (union ord_deep dt_deep))
	     (all_vars (unique (getvars all_deep)))
	     (all_preds (mapcar (function third) all_deep))
	     (rest (set-difference predl all_preds))
	     res)
					;(bp rmt)
	(dolist (v all_vars)
	  (let ((res1 
		 (single_var_tc 
		  (mapfilter (f/l (tvp) (eq v (second tvp))) all_deep))))
	    (if (eq res1 'false)
		(progn (setq res 'FALSE)
		       (return nil))
	      (setq res (append res res1)))))
	(if (eq res 'FALSE) 
	    res 
	  (append rest res)))
    predl))


;reasons about the typecheks over a single variable. Theinput consists of a 
;list of entires (type var pred) where the var is the same
;it either returns the most specific typechek or FALSE if there is a conflict
(defun single_var_tc (tvpl)
  (let* ((tps (heads tvpl))
	 (stps (sort tps (function subtype-of))))
    (if (chain_subtypes stps)
	(list
	 (third (car (mapfilter (f/l (tvp) (eq (car tvp) (car stps))) tvpl))))
      'FALSE)))
	 
;checks if all types in a list are part of a single subtype chain in the 
;inheritance hierarchy
(defun chain_subtypes (stps)
  (let* ((tl1 (cons (car stps) stps))
	 (tl2 (append stps (last stps))))
    (apply (function and) (mapcar (f/l (t1 t2)(subtype-of t1 t2 T)) tl1 tl2))))



;checks if some variable in the varlist is typechecked by some function in
;the context list. shallowFlag for a exact type typecheck
(defun context_typechecked (varList varType context shallowFlag)
  (let ((ints))
    (dolist (cp context)
	    (if (or
		 ;typechecked if it is used in a func with the exac type
		 (and 
		  (function_p (car cp))
		  (not (getfunction _extent_funcs_ (list (car cp))))
		  (not (and (getfunction _coerce_funcs_ (list (car cp)))
			    (proxytype? varType)))
		  (typechecked varList  varType cp shallowFlag))
		 ;typechecked in a nested AND
		 (and 
		  (eq 'AND (car cp))
		  (context_typechecked varList varType (cdr cp) shallowFlag)))

		(return t)))))

;finds all the variables which are appear in a = or != predicates with the
;variables in the vl list. The search is performed over the preds. in context
(defun var_closure  (vl context)
  (let ((change t))
    (while change
      (setq change nil)
      (dolist (pr context)
	      (if (and (or (eq (car pr) _=_)
			   (eq (car pr) (getfunctionnamed '!=)))
		       (intersection (cdr pr) vl)
		       (not (subsetp (cdr pr) vl)))
		  (progn 
		    (setq change t)
		    (setq vl (union vl (cdr pr)))))))
    vl))
		  

; checks if a variable can be typechecked by being used in a predicate
; which checks the type by the referntial integrity system
; shallwo typecheck is done by type equality, while the other by subtype-of  
(defun typechecked (varList varType pred shallowFlag)
  (let ((head (car pred))
	(tail (cdr pred)))
    (if 
	 (and (function_p head)
	      (not (getobject head 'foreignimpl))
	      (let ((atypes (append (get-resolvent-argtypes head) 
				    (get-resolvent-restypes head))))
		(dolist (vt (pair tail atypes))
			(if (and (memq (car vt) varList)
				 (if shallowFlag 
				     (eq (cdr vt) varType)
				   (subtype-of  (cdr vt) varType t)))
			    (return t)))));returns from the if condition
	t
      nil)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;variable substiution (performed after each template expansion)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; flattens the predicate and then iterates over all of the change records
; and performs variable substitutions according to the change record
; this is described in the paper.
; An entry to the second phase of template expansion
(defun texpand_subst_vars (fpredl  flag)
  (let ((fpredl fpredl))
    (if flag
	(dolist (chR *change_l*)
		(setq fpredl (sub_var_pred chr fpredl))))
    (setq *change_l* nil)
    fpredl))




;for a change record iterates over all of the predicates and all variables in each
(defun sub_var_pred (chR predl)
  (let (res
	(varS (list (first chR)))	;(var_closure (list (first chR)) predl))
	(svars (second chR)))
    (dolist (pr predl)
      (setq res 
	    (cons 
	     (if (and (function_p (car pr)) 
		      (not (getobject (car pr) 'cFunc)))
		 (let* ((head (car pr))
			(argtypes(if (or(eq head _makebag_)(dynconstructorfn head))
				     (mapcar (function arg-type) (cdr pr))
				   (append (get-resolvent-argtypes head)
					   (get-resolvent-restypes head)))))
		   (cons (car pr) (mapcar (f/l (arg argType)
					       (sub_var varS arg argType 
							svars pr))
					  (cdr pr) argtypes)))
	       pr) res)))
    (reverse res)))

;checks a variable in a predicate for substitution
;takes care of = and != where the arg types are of type object

(defun sub_var (varS arg argType svars pr)
  (if (memq arg varS)
      (progn
	(setq argType 
	      (if ;(or (ut_p argType) (dt_p argType))
		  (ut_p argType)
		  argType
		(if (or (eq (car pr) _=_)
			(eq (car pr) (getfunctionnamed '!=)))
		    (type_of_var (if (memq (second pr) varS) 
				     (third pr) 
				   (second pr))
				 *bindings*)
		  ;(bp "Strange case?? (debug output)")
		  (type_of_var arg *bindings*))))
	(let ((res (caar (mapfilter (f/l (e) 
					 (let ((tp (cdr e)))
					   (or (eq tp argType) 
					       (subtype-of tp argType)))) 
				    svars))))
	  (if (not res)
	      ;(amos-error "No corresponding variable to the variable "
	      ;		arg " of type " argType ". Substitutes: " svars)
	      (Setq res (caar svars))
	    )
	  res))
    
    arg))
		

; to flatten the extended predicates in the result of insert_templates
(defun flatten-insert (predl)
  (let (res
	(rpredl (reverse predl)))
    (dolist (p rpredl)
	    (if (and (listp p)
		     (listp (car p)))
		(setq res (append p res))
	      (setq res (cons p res))))
    res))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; misc functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;checks if a var is a result variable or there exists a _=_ predicate which
;unifies this var with a result variable
(defun not_iovar (var resl context)
  (if (or (member var resl)
	  (dolist (cp context)
		  (if (chk_equal cp var resl)
		      (return t))))
      nil
    t))
	
;checks if the pred cp is  (_=_ var var1) or (_=_ var1 var) and var1 is in resl
(defun chk_equal (cp var resl)
  (and (eq (car cp) _=_)
       (or (and (eq (second cp) var)
		(member (third cp) resl))
	   (and (eq (third cp) var)
		(member (second cp) resl)))))	



;removes typechecks for variables that are never used
(defun remove_unused_typechecks (predl iovars)
    (mapfilter (f/l (p)
		    (not
		     (and
		      (deep_tc p)
		      (not (memq (second p) iovars))
		      (tc_var_not_used (list (second p)) predl))))
	       predl))
       

  
					   
	
(defun deep_tc (p)
  (and 
   (listp p)
   (or 
    (and _ENABLE_DT_FLAG_ (caar (getfunction _extent_funcs_ (list (car p)))))
    (eq _typesof_ (car p)))))

	   ;remove typechecks of not used variables
	   ;((and (or tfn (eq head _typesof_))
	   ;	 (not noExpand) ; to be applied after normalization
	   ;	 (tc_var_not_used varList context)
	   ;      (not (intersection varList (append resl argl))))
	   ; (formatl t "Removed: " pred  t) 
	   ; nil)
   
