;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2000 Martin Hansson, UDBL
;;; $RCSfile: relational_translator.lsp,v $
;;; $Revision: 1.22 $ $Date: 2013/05/03 10:23:29 $
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

(defun get-type2 (v)
  (type_of_var v *bindings*))

(defun get-parameters (varlist)
  (mapcar (f/l (v) (list (get-type2 v) v)) varlist))

(defun create-specialized-query-fn (ds sqlq)
  (let* ((query     (generate-sql-string sqlq));;done first
	 (inparams  (rename-duplicate-variables (get-parameters 
						 (sqlquery-input sqlq))))
	 (outparams (get-parameters (sqlquery-output sqlq)))
	 (invars    (sqlquery-input sqlq))
	 (body      `(sql , ds , query (vector ,@ invars)))
	 (arity     (length outparams))
	 vrefs)
    (setf (sqlquery-sqlstring sqlq) query)
    (dotimes (i arity)(push `(vref v- , (- arity (1+ i))) vrefs))
    (createfunction '*transient* inparams outparams vrefs 
		    '((vector v-)) `(= v- , body))))

(defun rename-duplicate-variables (dcll)
  "Replace duplicate variable declarations in DCLL with unique variable names"
  (let (been)
    (mapcar (f/l (vdcl)(cond ((member (dcl-variable vdcl) been) 
			      (list (dcl-type vdcl) (genvar)))
                             (t (push (dcl-variable vdcl) been) vdcl)))
            dcll)))

(defun relational-translate-source-predicate (ds sp sqlq)
  (let* ((fno (predicate-operator sp));;source predicate
	 (ti  (sqlquery-add-table sqlq (getobject fno 'tablename)))
	 ci)
    (dolists 
     ((arg     (predicate-arguments sp))
      (colname (function-resvars fno)))
     (cond ((named-varsymbolp arg)
	    (setq ci (make-columninfo :tableinfo ti :name colname))
	    (cond ((varboundp arg)
		   (if (null (get-varentity arg))
		       ;;(set-varentity arg ci))
		       (set-varentity arg arg))
		   ;;add input only when arg's dsinst is different
		   ;;with the current sp and is done in sqlquery.lsp
		   (sqlquery-add-predicate sqlq (list _=_ ci arg)))
		  (t (sqlquery-add-output sqlq arg)
		     (set-vards arg ds)
		     (set-varentity arg ci)
		     (bind-var arg)
		     )))
	   ((constantsymbolp arg)
	    (setq ci (make-columninfo :tableinfo ti :name colname))
	    (sqlquery-add-predicate sqlq (list _=_ ci arg))))))
  sqlq)





