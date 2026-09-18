;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2000 Martin Hansson, UDBL
;;; $RCSfile: relational_translator.lsp,v $
;;; $Revision: 1.8 $ $Date: 2012/07/24 12:51:22 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: A Wrapper must specify functions for translating all the
;;; functions in its capability table. These functions, referred to as 
;;; absorbents will be expected to take three arguments:
;;;
;;; 1) The datasource object for the datasuource that we are currently
;;;    translating for
;;; 1) The (leaf) predicate itself as it sits. (A leaf predicate is 
;;;    <operator> <variables>).
;;; 2) A variable environment, which is a hashtable where identifiers
;;;    are hashed to a varinfo structure, see variable.lsp, environment.lsp
;;; 3) An accumulator, which can be anything. Nothing is done to this by
;;;    the wrapper framework. In the SQL case this is simply an 
;;;    abstract SQL select statement, as specified in abstractsql.lsp
;;;       
;;; If the absorbent function return t it must have succeeded. Otherwise the
;;; predicate will not be removed from the conjunction.
;;;
;;; Furthermore, there is the option of supplying a function to initialize the
;;; accumulator, and a function to convert the accumulator into a proper 
;;; function call to the interface.       
;;;
;;; ===========================================================================
(defvar _sql_ nil)

(defun init-relational-translator ()
  (setq _sql_ (getfunctionnamed 'sql))
)

(defstruct tableinfo
  catalog        ; symbol
  schema         ; symbol
  name           ; symbol
  incarnation-no ; when the same table is used more than once, this 
                 ; field is used to uniquely identify one
)

(defun columninfo-table (ci)
  (tableinfo-name (columninfo-tableinfo ci)))

; The struct columninfo is the "source entity" that a variable maps to 
; in the SQL case
(defstruct columninfo
  tableinfo ; struct tableinfo
  name
)

(defun relational-translate-like (ds pred env sqlq)
  (let ((a1 (predicate-argument 1 pred))
	(a2 (predicate-argument 2 pred)))
    (cond ((stringp a2)
	   (sqlquery-add-predicate 
	    sqlq (list
		  (car pred) 
		  a1
		  (concatl (subst "%" "*" (explode a2)) "")
		  )))
          (t nil))			; no rewrite
    ))

(defun relational-translate-comparison (ds pred env sqlq)
  (let* ((arg1 (predicate-argument 1 pred))(arg2 (predicate-argument 2 pred))
	 (type1 (get-type arg1 env))       (type2 (get-type arg2 env))
	 (ds1 (if (varsymbolp arg1) (datasource arg1 env)))
	 (ds2 (if (varsymbolp arg2) (datasource arg2 env)))
	; at least one argument in a comparison must be a variable from the
        ; source, otherwise there's not much point in pushing the comparison.
	 (ok (or (eq ds1 ds) (eq ds2 ds))))
    ; at this point one variable may not come from the source. Hence, 
    ; it is an input parameter to the absorbed query fragment.
    ; Bug in generic grouper (TR) (assert ok "Generic grouping did not work")
    (if (and ok (varsymbolp arg1) (neq ds1 ds)) (sqlquery-add-input sqlq arg1))
    (if (and ok (varsymbolp arg2) (neq ds2 ds)) (sqlquery-add-input sqlq arg2))
	  
    ; either way, we have decided whether to absorb or not by now
    (if ok (sqlquery-add-predicate sqlq pred))))

(defun get-parameters (varlist env)
  (mapcar (f/l (v) (list (get-type v env) v)) varlist))

(defun create-specialized-query-fn (ds env sqlq)
  (let* ((inparams  (rename-duplicate-variables (get-parameters 
						 (sqlquery-input sqlq) env)))
	 (outparams (get-parameters (sqlquery-output sqlq) env))
	 (invars    (sqlquery-input sqlq))
	 (query     (get-sql-string sqlq))
	 (body      `(sql , ds , query (vector ,@ invars)))
	 (arity     (length outparams))
	 vrefs)

    (setf (sqlquery-sqlstring sqlq) query)
    (dotimes (i arity)(push `(vref v , (- arity (1+ i))) vrefs))
    (createfunction '*transient* inparams outparams vrefs 
		    '((vector v)) `(= v , body))))

(defun rename-duplicate-variables (dcll)
  "Replace duplicate variable declarations in DCLL with unique variable names"
  (let (been)
    (mapcar (f/l (vdcl)(cond ((member (dcl-variable vdcl) been) 
			      (list (dcl-type vdcl) (genvar)))
                             (t (push (dcl-variable vdcl) been) vdcl)))
            dcll)))

(defun relational-translate-core-cluster (ds cc-call env sqlq)
  (let* ((fno (predicate-operator cc-call))
	 (ti  (sqlquery-add-table sqlq (getobject fno 'tablename)))
	 ci)
    (dolists 
     ((arg     (predicate-arguments cc-call))
      (coltype (getrestype fno))
      (colname (function-resvars fno)))
     (cond ((named-varsymbolp arg)
	    (setq ci (make-columninfo :tableinfo ti :name colname))
	    (cond ((bound arg env)
		   (if (null (get-entity arg env))
		       (set-entity arg env ci))
		   (cond ((eq (datasource arg env) ds)
			  (sqlquery-add-predicate sqlq 
						  (list _=_ ci arg)))
			 (t (set-type arg env coltype)
			    (sqlquery-add-predicate sqlq (list _=_ ci arg))
			    (sqlquery-add-input sqlq arg))))
		  (t (sqlquery-add-output sqlq arg)
		     (bind arg env :type coltype
			   :entity ci
			   :origin cc-call
			   :datasource (get-datasource fno)))));;changed
	   ((constantsymbolp arg)
	    (setq ci (make-columninfo :tableinfo ti :name colname))
	    (sqlquery-add-predicate sqlq (list _=_ ci arg))))))
  t)