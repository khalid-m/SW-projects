;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) <year>2012  <author>Minpeng Zhu, UDBL
;;; $RCSfile: sql_finalizer.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/05/01 15:35:28 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: JDBC wrapper's finalizer 
;;; =============================================================


(defun create-specialized-query-fn2 (ds sqlq)
  (let* ((query     (generate-sql-string sqlq));;done first
	 (inparams  (rename-duplicate-variables (get-parameters 
						 (sqlquery-input sqlq))))
	 (outparams (get-parameters (sqlquery-output sqlq)))
	 (invars    (sqlquery-input sqlq))
	 ;;do any input vars here instead of ds???
	 (body      `(multisql , ds , query (vector ,@ invars)));;temp 
	 (arity     (length outparams))
	 vrefs)
    (setf (sqlquery-sqlstring sqlq) query)
    (dotimes (i arity)(push `(vref v- , (- arity (1+ i))) vrefs))
    (createfunction '*transient* inparams outparams vrefs 
		    '((vector v-)) `(= v- , body))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SQL finalizer;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun finalize-sql (dsinst translatablepreds sb) 
  "Each wrapper has a finalizer, which is a plug-in that translates 
   each access filter in the plan to an algebra operator called an 
   interface function, specific for each kind of source. The interface 
   function sends a query to the data source (i.e. a SQL query)."
  (let* ((inputvar (selectbody-argl sb))
	 (resl (selectbody-resl sb))
	 (accessfiltervarlist (allsp-varlist translatablepreds))
	 (varpredassnlst (predbindsintermvarp translatablepreds 
					      accessfiltervarlist 
					      inputvar))
	 (querystruct (make-sqlquery :datasource dsinst 
				     :accessfiltervarlist accessfiltervarlist 
				     :varpredassnlst varpredassnlst))
	 queryfn sqlquery invars outvars sql-algebra-op
	)
    ;;distribute absorbed pred into proper place in sqlquery
    (distribute-preds translatablepreds querystruct resl)
    (cond ((consp dsinst);;
	   (setq queryfn (create-specialized-query-fn2 (car dsinst) querystruct))
	   (setq sqlquery (sqlquery-sqlstring querystruct)) 
	   (setq invars (sqlquery-input querystruct))
	   (setq outvars (sqlquery-output querystruct))
	   (declarecosts queryfn '*any* 'sqlq_cost)
	   (/putobject 
	   queryfn 'name
	    (concat "multisql:'" sqlquery "'" (or invars "()")
		    "->" (or outvars "()")))
	   (/putobject queryfn 'sqlquery querystruct)
	   ;;do append with predicate logdbid_js ???
	   (setq sql-algebra-op 
		 `((, _apply_pred_ , queryfn ,@ invars ,@ outvars))))
	  (t;;only a data source
	   (setq queryfn (create-specialized-query-fn dsinst querystruct))
	   (setq sqlquery (sqlquery-sqlstring querystruct)) 
	   (setq invars (sqlquery-input querystruct))
	   (setq outvars (sqlquery-output querystruct))
	   (declarecosts queryfn '*any* 'sqlq_cost)
	   (/putobject 
	    queryfn 'name
	    (concat "sql@" (oid-name dsinst) ":'" sqlquery "'" (or invars "()")
		    "->" (or outvars "()")))
	   (/putobject queryfn 'sqlquery querystruct)
	   (setq sql-algebra-op 
		 `((, _apply_pred_ , queryfn ,@ invars ,@ outvars)))))
    ))

(defun predbindsintermvarp (absorbedpredl accessfiltervarlist inputvar)
  "traverse absorbed predicates absorbedpredl and build the association list 
   with var and the arithmetic pred binds that var"
  (let ((boundvarlist (append accessfiltervarlist inputvar *bvars*))
	;;get pred absorbed order from left to right by reverse absorbedpredl
	(reversepredl (reverse absorbedpredl));;needed
	;;initial value
	(change t)
	varpredassnlst
	)
    (while change
      (setq change nil)
      (dolist (pred reversepredl) 
	(cond ((numericalp pred)
	       ;;check number of new bound intermediate var
	       ;;new var = not ccvar and not inputvar
	       (let (freevars)
		 (mapc (f/l (arg) 
			    (if (not (variable-is-bound arg boundvarlist))
				    (push arg freevars)))
		       (predicate-vars pred))
		 (cond ((= (length freevars) 1)
			;;in addition, two constant and one intermvar
			;;or has no ccvar??
			(push (list (car freevars) '. pred) varpredassnlst)
			(nconc1 boundvarlist (car freevars));;binds new var
			(setq change t)))))
	      ((compound-p pred)
	       (map-over-pred pred 
			      (f/l (p)
				   (if (numericalp p)
				       (let (freevars)
					 (mapc (f/l (arg) 
						    (if (not (variable-is-bound
							      arg boundvarlist))
						      (push arg freevars)))
					       (predicate-vars p))
					 (cond ((= (length freevars) 1)
						(push (list (car freevars) '. 
							    p) 
						      varpredassnlst)
						(nconc1 boundvarlist 
							(car freevars))
						(setq change t))))))
			      (function id))
	       ))))
    varpredassnlst))

(defun distribute-preds (translatablepreds querystruct resl)
  "distribute the translatable predicates to the holding place in sqlquery
   structure"
  (mapc (f/l (pred) (sqlquery-add-predicate querystruct pred resl))
	translatablepreds)
)


(osql "create function sqlq_cost(function,vector,vector)->(integer,integer) as select 100,100;")
