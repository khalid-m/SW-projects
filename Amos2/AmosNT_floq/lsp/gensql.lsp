;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1998 Vanja Josifovski, EDSLAB
;;; $RCSfile: gensql.lsp,v $
;;; $Revision: 1.17 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: ODBC wrapper 
;;; =============================================================


(defun gen_sql (predl ap_t fname bpat db &optional existingOid)
  "Generate a function which executes a SQL call and possibly OID materialization
   and mappings for the types translated to ODBC sources.
   predl - list of predicates to be translated to SQL
   ap_t  - list (arguments parameters): ((type var) ...)   
           If bpat shorter than ap_t: the remaining are parameters
   fname - name of the function to be generated
   bpat  -
   db    -
   existingoid - "
  (let* ((resl (mapfilter (f/l (bta) (eq (car bta) '+))
				(pair bpat ap_t)
				(function cdr)))
	 (argl (set-difference ap_t resl))
	 ;extract var names only
	 (fnresvars  (getvars resl))
	 (fnargvars  (getvars argl))

	 ;divide the predicates into typechecks, displaceable, selections and 
	 ;group the rest by the res. All preds are of form (func arg res)
	 (displ  (mapfilter (f/l (p)(displaceable? (getfunctionnamed (car p))))
			    predl))
	 (predl1 (set-difference predl displ))
	 (tpchkl (mapfilter (f/l (p)(eq 'OBJECT.TYPESOF->TYPE (car p))) predl1))
	 (predl2 (set-difference predl1 tpchkl))
	 ; predicates with OID parameters (arguments), but no typechecks for them
	 (oidpreds (mapfilter (f/l (p) (oid-p (second p))) predl2))
	 (predl3 (set-difference predl2 oidpreds))
	 (selections0 (mapfilter (f/l (p) (not (symbolp (third p)))) predl3))
	 (rest  (set-difference predl3 selections0))
	 (locals (set-difference (mapcar (function third) rest) 
				 (append fnresvars fnargvars)))
	 (localsQuantList (mapcar (f/l (v) (list (type_of_var v *bindings*) v))
				 locals))
	 (wpred0 (group_pred rest (function third)))

	 ;generate the from clause text
         (fromtext (mk_from_clause tpchkl oidpreds))

	 ;input variables which are not of non literal type
	 (objectsin  (mapfilter (f/l (tcp) (memq (second tcp) fnargvars)) 
				tpchkl))
	 ;output variables which are not of non literal type
	 (objectsout (mapfilter (f/l (tcp) (memq (second tcp) fnresvars)) 
				tpchkl))

	 ;OIDs as input
	 (ssmq (handle_arguments fnargvars objectsin wpred0 predl tpchkl))
	 (sqlargl     (first ssmq))
	 (selections  (append selections0 (second ssmq)))
	 (coercepreds (third ssmq))
	 (inQuantList (fourth ssmq))

	 ;OID generation, change the result of the sql, the where pred. list
	 ;generate the materialization preds and quantifier entries for the
	 ;newly generated variables
	 (swmq (handle_object_result objectsout resl wpred0 rest))
	 ; "-1" is a value (arbitrarily selected) that we use when we only need
	 ; to detect existence of tuples.
	 (sqlresl      (or (first swmq) '(-1))) 
	 (wpred        (second swmq))
	 (matpreds     (third swmq))
	 (OutQuantList (fourth swmq))

	 ;generate the select clause text
	 (selecttext (mk_select_clause sqlresl (append wpred (list oidpreds)) predl))

	 ;generate sql for the displaceable predicates
	 (disppred (where_disp displ wpred predl))
	 ;generate sql for the joins
	 ; (joinpred (where_join wpred))
	 ; here we regroup all preds left to include joins with the oidpreds
	 (joinpred (where_join (group_pred (append oidpreds (ungroup-pred wpred)) #'third)))
	 ;generate sql for the selections
	 (wselectpred (where_selections selections))
	 ; generate sql for preds over OIDs
	 (opred (where_oidpreds oidpreds))
	 ;add all up lists
	 (wherepred (append disppred wselectpred joinpred opred))
	 ;produce the complete where clause text from the lists generated above
	 (wheretext (make_clause 'WHERE wherepred 'AND))
	 ;the text of the sql 
     	 (sqltext (concat selecttext fromtext wheretext))
	 ; maximum number of tuples to be emitted. -1 means all
	 (max_tuples -1)
	 sqlpred outovar fnresl fnargl fnresv fnpred quantList cbpat fno nbpatass)

    ; if only a test is to be executed, set the required number of tuples to be 1
    (if (equal sqlresl '(-1))
	(setq max_tuples 1))

    ;the sql call itself
    (setq sqlpred (list '=
			(list 'ODBC_DS.CHARSTRING.VECTOR.INTEGER.SQL->VECTOR
			      ; timka: patch code
			      (getobjectnamed (mkatom db) (gettypenamed 'odbc_ds))
			      sqltext
			      (cons 'vector sqlargl)
			      max_tuples)
			(cons 'vector sqlresl)))

    ;aux var for the next definition
    (setq outovar (getvars objectsout))
    ;function return pairs of (type var); corrects the typename
    (setq fnresl (mapcar (f/l (tv)(cons (real_tn (car tv) db)(cdr tv))) resl))
    (setq fnargl (mapcar (f/l (tv)(cons (real_tn (car tv) db)(cdr tv))) argl))
    ;return var names
    (setq fnresv (getvars fnresl) )
    ;assemble all generated predicates 
    (setq fnpred (andify (append (cons sqlpred matpreds) coercepreds)))
    (setq quantList (append localsQuantList inQuantList outQuantList))

    ;the binding pattern of the generated function (---..+++...) does
    ;not match the one reqired by the tree, to match this, 
    ;a bindpat record 
    ;with the correct tree pattern and cost_fanout is added
    (setq cbpat  (padd bpat (- (length ap_t) (length bpat)) '-))
    ;create the resulting function
    (setq fno (let ((*no_typechecks* t))
		(createfunction fname fnargl fnresl fnresv quantList fnpred 
				existingOID)))
    
     ;set the recompilation info correctly
    (setq nbpatass (list cbpat (getobject fno 'selectbody) 
			 (odbc_query_cost nil cbpat nil)))
    ;this info is used to recompile the fn for different binding patterns
    (/putobject fno 'sqlrecompileInfo (list predl ap_t db))
    (/putobject fno 'bindpat (cons nbpatass (getobject fno 'bindpat)))
    (/putobject fno 'wrappergen T) ; used only in mat_bags, needed?
    (/putobject fno 'systemfn T) ; this is a non-importatble function
    fno))


(defun handle_arguments (fnargvars objectsin wpred predl tpchkl)
  "Handles bound arguments to an sql function, including the object to key map."
  (let* ((objvars (getvars objectsin))
	 (valvars (set-difference fnargvars objvars))
	 (valf0 (mapcar (f/l (v) (find_a_pred v wpred predl)) valvars)) 
                     ; picks predicates over arguments
	 (allf (mapfilter
		(f/l (v) (not (null v)))
                valf0
		(f/l (v) (list (car v) (second v) '?))))
	 quantList
	 newpreds
         ; find those vars that are in wpred and NOT in predl
	 ;(ungrouped (ungroup-pred wpred))
	 ;(wvars (mapcar #'third ungrouped))
	 )
	    
    (dolist (tc objectsin)
      (let* ((tp (third tc))
	    (tp_var (second tc))
	    (keys (getobject tp 'keys))
	    (iskeyfname (mkatom (i_key_storage_func_name  (oid-name tp))))
	    (nvars (genvars keys))
	    (qe (mapcar (f/l (k v) (list (car k) v)) keys nvars))
	    (sels (mapcar (f/l (k) (list (second k) tp_var '?)) keys))
	    (npred (list '= (maketuple nvars) (list iskeyfname tp_var)))) 
	
	(setq newpreds  (cons npred newpreds))
	(setq fnargvars (delete tp_var (append fnargvars nvars)))
	(setq allf      (append allf sels))
	(setq quantList (append quantList qe))))
    ;(setq fnargvars (set-difference fnargvars wvars))
    (list fnargvars allf newpreds quantList)))

	 
(defun  handle_object_result (outobjs resl wpred0 rest)
  "Handles requests for materialized translated types objects (OID in the resl)
   for each such var, inserts the key predicates in the wpred, ODBC retrieves
   the keys. Materialization preds are generated to generate OIDS from the keys."
  (let ((sqlresl (getvars resl))
	(wpred wpred0)
	mat_func_arg_list
	quantlist)
    (dolist (tc outobjs)
      (let* ((tp (third tc))
	    (tp_var (second tc))
	    (keys (getobject tp 'keys))
	    (cfname (mkatom (concat cFuncPrefix (oid-name tp))))
	    mfal)
	(setq sqlresl (delete tp_var sqlresl))
	(dolist (k keys)
	  (let*  ((fn (second k))
		  (var1 (third 
			 (car (mapfilter (f/l (pr) (and (eq fn (car pr))
							(eq tp_var (second pr))))
					 rest))))
		  (var (if var1 var1 (genvar))))
	    ;(bp hor)
	    (setq mfal (cons var mfal))
	    (if (not (memq var sqlresl)) 
		(setq sqlresl (cons var sqlresl)))

	    (if (not var1)
		(progn 
		  (setq quantlist (cons (list (car k) var) quantlist))
		  (setq wpred (cons (list (list fn tp_var var)) wpred))))))
	
	(setq mat_func_arg_list (cons 
				 (list '= tp_var (cons cfname (nreverse mfal)))
				 mat_func_arg_list))))
    (list sqlresl wpred mat_func_arg_list quantlist)))
	    
	


;where clause generation

(defun where_disp (displ wpred predl)
  "Where predicates from displaceable predicates, e.g:
   (< B C) --> f1.a < g1.h"
  (let (result)
    (dolist (el displ)
      (setq result (cons (concat (pathify (second el) wpred predl) 
				 " " (generic-fnname (car el)) " "
				 (pathify (third el) wpred predl))
			 result)))
    (nreverse result)))

(defun where_selections (selections)
  "Where predicates which are selections, e.g.
   (F1 A 5) --> a.f1 = 5"
  (let (result)
    (dolist (el selections)
      (let* ((te (third el))
	     (rhs (if (stringp te) (concat "'" te  "'") te)))
	(setq result (cons (concat (path_ex el) " = " rhs) result))))
    result))

(defun where_join (wpred)
  "Where predicates which are joins, e.g.
   (F1 A B) (F2 A B) ---> a.f1 = a.f2"
  (mapcan #'where_var_join wpred))

(defun where_var_join (wgroup)
  "Where predicates which are joins for a single variable (e.g B above)"
  (let ((curr (path_ex (car wgroup)))
	result)
    (dolist (el (cdr wgroup))
      (let ((next (path_ex el)))
	(setq result (cons (concat curr " = " next) result))
	(setq curr next)))
    result))

(defun where_oidpreds (oidpreds)
  "Predicates over OIDs - they map OIDs to keys. Therefore:
   (F1 oid var) ---> Void.key_of_oid = convert-oid-to-key(oid)"
  (let* ((oidl (mapcar #'second oidpreds))
	 predl)
    (dolist (o oidl)
      (let* ((type (arg-type o))
	     (keys (mapcar #'second (getobject type 'keys)))
	     (i_keyfn (getfunctionnamed (i_key_storage_func_name (oid-name type))))
	     ; keys are unique - there is only 1 tuple, so we get the CAR of the result
	     (key-vals (car (getfunction i_keyfn (list o))))
	     (tbl-var-name (amos_to_odbc_var o))
	     (where-preds (mapcar (f/l (k v) (concat
					      tbl-var-name "." k
					      " = "
					      (if (stringp v)
						  (concat "'" v "'")
						  v)))
				  keys key-vals)))
	(setq predl (append where-preds predl))))
    predl))
    
(defun mk_from_clause (tpchkl oidpreds)
  "FROM clause generation"
  (let ((tpchk-vars (mapcar (f/l (tc)
				 (concat (getobject (third tc) 'origname)
					 " "
					 (amos_to_odbc_var (second tc))))
			    tpchkl))
	(oidpred-vars (mapcar (f/l (p)
				   (concat (getobject (arg-type (second p)) 'origname)
					   " "
					   (amos_to_odbc_var (second p))))
			      oidpreds)))
    (make_clause 'FROM (append tpchk-vars oidpred-vars) ",")))

(defun mk_select_clause (resl wpred predl)
  "SELECT clause generation"
  (if (equal resl '(-1)) 
      "SELECT -1 " 
      (let* ((varpred (mapcar (f/l (v) (find_a_pred v wpred predl)) resl))
	     (varsqlpred (mapcar #'path_ex varpred))
	     (clause_text (make_clause 'SELECT varsqlpred ",")))
	clause_text)))

(defun make_clause (prefix lst delimeter)
  "Make a text string from a list, delimeter and a clause prefix."
  (let ((result ""))
    (if lst
	(progn
	  (setq result (concat prefix " " (car lst)))
	  (dolist (e (cdr lst))
	    (setq result (concat result " " delimeter " " e)))))
    (concat result " ")))

(defun path_ex (fvr) 
  "Converts a objectlog function call to sql call (F A B) ---> 'A.F'"
  (concat (amos_to_odbc_var (second fvr)) "." (car fvr)))

(defun amos_to_odbc_var (v) 
  "make the amos vars acceptable by the ODBC driver
   the v is added in the front because amos vars start with '_': error in ODBC"
  (if (oid-p v)
      (mkatom (concat "V" (oid-idno v)))
      (mkatom (concat "V" v))))

(defun pathify (a wpred predl) 
  "Finds an objectlog pred for a var and returns a sql call: B --> 'F.A'"
  (cond ((symbolp a)
	 (let ((pred (find_a_pred a wpred predl)))
	   (if pred
	       (path_ex pred)
	       "?")))
	((stringp a) (concat "'" a "'") )
	(t a)))

(defun find_a_pred (v wpred predl)
  "Find a predicate in which a given var is a result: B --> (F A B)"
  (let* ((varl (sql_var_closure (list v) predl))) ;a list of var that are equal to this
    (car (mapfilter (f/l (pg) (memq (third (car pg)) varl)) 
		    wpred 
		    (function car)))))

(defun sql_var_closure  (vl context)
  "handles ="
  (let ((change t))
    (while change
      (setq change nil)
      (dolist (pr context)
	      (if (and (eq (car pr) 'OBJECT.OBJECT.=->BOOLEAN)
		       (intersection (cdr pr) vl)
		       (not (subsetp (cdr pr) vl)))
		  (progn 
		    (setq change t)
		    (setq vl (union vl (cdr pr)))))))
    vl))

(defun group_pred (predl fn)
  "Groups predicates by the same result on applying the function f
   returns a list of lists of predicates (groups of predicates)"
  (let (result)
    (while predl
      (let* ((v (apply fn (list (car predl))))
	     (ng (mapfilter (f/l (p) (eq v (apply fn (list p))))
			    predl)))
	(setq result (cons ng result))
	(setq predl (set-difference predl ng))))
  result))

(defun ungroup-pred (predgrp)	    
  "Unnest the predicates in predl, which is of the form:
   (((P1 A B) (P2 C D) ...) ((P3 E F) (P4 G H) ...) ...)"
  (let ((res))
    (dolist (grp predgrp)
      (dolist (p grp)
	(setq res (cons p res))))
    (nreverse res)))

(defglobal odbc-costs nil)

(defun get-fixed-cost ()
  (let ((cf (assq _amosid_ odbc-costs)))
    (if cf (cdr cf) '(1000 100))))

(defun odbc_query_cost (fn bpat db)
  "Simulation of cost for the odbc functions."
  ; (all - not_bound)/all is the coeficient for the costs and the fanout
  (let* ((db-cost (get-fixed-cost))
	 (defcost (first db-cost))
	 (deffanout (second db-cost))
	 (bound (length (mapfilter (f/l (e) (eq '- e)) bpat)))
	 (all1 (+ 0.0 (length bpat)))
	 (all  (if (equal 0.0 all1) 1.0 all1))
	 (coef (/  (+ 0.2 (- all bound))  all)))
    (cons (* defcost coef) (* deffanout coef))))

(defun real_tn (tn db) 
  (if (gettypenamed (proxy_type_name tn db) T)
      (proxy_type_name tn db)
    tn))

(defun get_cost_odbc (fn bpat db)
  "If proxy function (should) returns a stored cost according to the indexing 
   information. Othewise recompiles and returns a cost."
(if (proxyfunc? fn)
    (odbc_query_cost fn bpat db)
  (third 
   (or
    (sqlbpatfn fn bpat)
    (let*  ((recompinfo  (getobject fn 'sqlrecompileinfo))
	    (predl (car recompinfo))
	    (ap_t  (second recompinfo))
	    (tmp   (gen_sql predl ap_t (generic-fnname fn) bpat db fn)))
      (sqlbpatfn fn bpat))))))

		
(defun sqlbpatfn (fn bpat)
  (let ((bpats (getobject fn 'bindpat)))
        (cond ((null bpats) nil)
	      (t (lookupbpatfn bpats bpat)))))
