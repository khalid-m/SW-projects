;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1998 Vanja Josifovski, EDSLAB
;;; $RCSfile: qd_deftmpfunc.lsp,v $
;;; $Revision: 1.33 $ $Date: 2010/02/26 15:22:45 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Function shiping  and definition in the db's
;;;              where are to be executed
;;; =============================================================


(defvar *real-types* nil)

(defun accept_def_tmp (Spredl args_pair quant_pair fname locals 
			      loct real-types dsve-budget)
  "Accepts a compilation requests locally and  from other amos mediators
   the arguments represent the predicates, a pair of arg vars and types,
   the function name (locally) the local vars, local types, the actual types
   (if some types are faked to pass OIDs through this mediator
   It basically sets the right parameters for createfunction
   Called from def_tmp_func (Define temporary function)"
  (let* ((predl1 (un_mark_external Spredl))
	 (predl2 (mapcar (f/l (x) (cons (getfunctionnamed (car x)) (cdr x)))
			 predl1))
	 (predl (correct_extf predl2))
	 (locs_pair (pairlist loct 
			      (subset locals 
				      (f/l (v)
					   (not(isome 
						args_pair 
						(f/l (p)(eq (cadr p) v))))))))
	 (*no_typechecks* t)

	 (quant1  (append quant_pair locs_pair))
	 (quant (replace_types quant1 real-types))
	 (argtypes (replace_types args_pair real-types)) 
	 (*use_materialized_bags* t)
	 (*DSVE-BUDGET* dsve-budget)
	 (*DSVE-STRATEGY* (if (expand-views?) *DSVE-STRATEGY* 'dsve-none))
	 fno)
    (setq fno (createfunction 
	       fname
	       argtypes
	       nil
	       nil
	       quant
	       ;; IMPORTED replaces FLATTENED because they are conflicting
	       (list 'IMPORTED locals  predl)))
    (cond ((expand-views?)
	   (let ((preds (selectbody-decomptree (getselectbody fno))))
	     ;;only view expansion, do not generate function, return predicates
	     (deleteobject fno)
	     preds))
	  (t;; query compilation, generate a funcion
	   ;;(setf (selectbody-loct (getobject fno 'selectbody))  loct)
	   (/putobject fno 'origquant quant)
	   (/putobject fno 'systemfn T)
	   (cons fno (oid-name fno))))))

(defun replace_types (orig-tv-lst replc-tv-lst)
  "Replace type declarations"
  (mapcar
   (f/l (orig-tv)
	(or (car (mapfilter (f/l (replc-tv) (eq (second replc-tv) 
						(second orig-tv))) 
			    replc-tv-lst))
	    orig-tv))
   orig-tv-lst))

(defun strip_args (arg)
  "Translates objects into object names.
   Used in strip_pred only."
  (cond ((transientp arg)		; This case used in makebag
	 (gnode-fno (tNode-sae (selectbody-decomptree 
				(getobject arg 'selectbody)))))
	((oid-p arg)
	 (let* ((imported_types (get-all-imported-types))
		(it (cadar (mapfilter 
			    (f/l (tp) (eq (oid-name arg) 
					  (proxytype-origname tp)))
			    imported_types))))
	   (or it arg)))
	(t arg)))

(defun strip_pred (pred)
  "Used in def_tmp_func only."
  (if (and (listp pred) (not (listp (car pred))))
      (let ((on (oid-origname (car pred)))
	    (tail (mapcar #'strip_args (cdr pred))))
	(if on
	    (cons on tail)
	  (cons (oid-name (car pred)) tail)))
    pred))
 
(defun def_tmp_func (node graph resl)
  "Precompile each group in its respective server.
   The binding pattern for the new function is based on the node variables 
   connected to variables in other nodes or with the output variables. 
   Therefore here the function is compiled with all variables unbound."
  (assert (not (null (gNode-db node))) "NULL database")
  (let* ((db (gNode-db node))
	 (vars (gNode-vars node))
	 (params (gNode-params node))
	 (other-nodes-vars (unionl (mapcar #'gNode-vars (remove node graph))))
	 ;; the variables that connect this node with the other nodes 
         ;; and the query output
	 (args1 (intersection vars (union resl other-nodes-vars)))
	 (args (set-difference args1 params))
	 (bpat (mapcar (f/l (v) (memq v params) '- '+) args))
	 (locals (set-difference vars args))
         ;; use type_of_arg to allow constants, not only variables
	 (loct (mapcar (f/l (v) (type_of_arg v *bindings*)) locals))
	 (argtypes1 (mapcar (f/l (v) (type_of_var v *bindings*)) args))
	 (dummy (if (memq nil argtypes1)
		    (error "Decomposition error, variable not bound"
			   args)))
	 (argtypes  (mapcar (f/l (at) (real_type_name at db)) argtypes1))
	 (a_t (pairlist argtypes args))
	 (paramtypes1 (gnode-paramtypes node))
	 (paramtypes (mapcar (f/l (at) (real_type_name at db)) paramtypes1))
	 (p_t (pairlist paramtypes params))
	 (ap_t (append a_t p_t))
	 (nodePreds (gNode-predl node))
	 (predl (mapcar #'strip_pred nodePreds))
	 (fname (concat "_" _amosid_ "_" (setq _mdbfunc_ (1+ _mdbfunc_)) "_"))
	 (at_fname (mkatom fname))
	 (quant nil)
	 fno_name fno view_def)
    (setq fno
	  (cond ((eq db 'LOCAL)		; local compilation
		 (car (accept_def_tmp predl ap_t quant at_fname 
				      locals loct *real-types* -1)))
					; compilation in another amos server
		((eq (sourcetype? db) 'proxy)
		 (cond ((expand-views?)
					; perform a remote expansion request.
			(setq view_def 
			      (remote-call db 'accept_def_tmp
					   predl ap_t quant at_fname 
					   locals loct *real-types*
					   *DSVE-BUDGET*)))
		       (t		; if defining a func
			(setq fno_name 
			      (remote-call db 'accept_def_tmp
					   predl ap_t quant at_fname 
					   locals loct *real-types* -1))
			(/putobject (car fno_name) 'origname (cdr fno_name))
			(car fno_name))))
		(t (amos-error "Unknown type of data source :" db))))
    (make-gNode 
     :db       db
     :predl    nodepreds
     :fno      fno
     :vars     args
     :vartypes argtypes
     :params   params
     :paramtypes paramtypes1
     :bpat     bpat
     :view_def view_def)))

(defun real_type_name (tp db)
  "Get the type name used when importing TP from mediator DB"
  (let (sb) 
    (cond
     ((and (neq db 'LOCAL)
	   (symbolp tp))
      ;;a type that is a result of a view openeing - not known locally
      tp)
     ((and (neq db 'LOCAL)
	   (bag-type? tp) 
	   (eq (sourcetype? db) 'proxy))
      (cons 'bag (getobject tp 'bagtypelist)))
     ((and (proxytype? tp) (neq db 'LOCAL))
      (cond ((eq (proxytype-origin tp) db) (proxytype-origname tp)) 
	    (t (throw 'decompose_and nil))));; incompatible predicate->FALSE
     ((and (neq db 'LOCAL) 
	   (or (i_type? tp) (dt_p tp)))	; derived or IUT
      (let* 
	  ((itl (i_type? tp))
	   (allsbsup (if itl 
			 (appendl (mapcar (function type-allsupertypes) 
					  (i_type? tp)))
		       (type-allsupertypes tp)))
	   (proxy (car (isome allsbsup;; choose 1st supertype imported from DB
			      (f/l (tpo)
				   (cond ((not (proxytype? tpo)) nil)
					 (db (eq (proxy-database tpo) db))
					 (t t)))))))
	(if proxy (proxytype-origname proxy)
	  (amos-error "Type " tp " does not import from " db))))
     (t (oid-name tp)))))
