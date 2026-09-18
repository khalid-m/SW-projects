;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: sql_cost.lsp,v $
;;; $Revision: 1.7 $ $Date: 2005/10/28 14:08:25 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: A cost metric for inst $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: A cost metric for insta $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: A cost metric for instances of the ADT sqlquery.
;;; see sqlquery-cost for details on the algorithm
;;; see sqlquery.lsp for the implementation of the ADT sqlquery.
;;;              
;;; ===========================================================================

(defvar *sql-cost-per-tuple* 100)

(defun sql_cost---++ (fno sql-query-fno bpat args cost fanout)
  (let ((costtuple (sql-cost sql-query-fno bpat args)))
    (osql-result sql-query-fno bpat args (first costtuple) (second costtuple))))


(defun sql-cost (sql-query-fno bpat args)
  "Estimates the cost of this anonymous query function under the given binding
   pattern and arguments. <sql-query-fno> is a transient function as created 
   by create-specialized-query-fn in relational.lsp"
  (sqlquery-cost (getobject sql-query-fno 'sqlquery)))

(defun sqlquery-cost (sqlq)
  "Determines the cost of this sqlquery (see sqlquery.lsp) by the following formula:
   For each table incarnation in the query:
     if the primary key is bound by an equality, either with constant or 
       through an equijoin with another table incarnation, its fanout is 1.
     else
       fanout = 100
   The total-fanout is the product of the fanout for all tables
   The result is the list [ *sql-cost-per-tuple* * total-fanout, total-fanout ]"
  (let* ((ds         (sqlquery-datasource sqlq))
	 (env        (sqlquery-environment sqlq))
	 (tableinfos (sqlquery-tableinfos sqlq))
	 (selpred    (sqlquery-selectpred sqlq))
	 (preds      (cond ((conjunctionp selpred) (rest selpred))
			   ((leaf-predicate-p selpred) (list selpred))
			   (t nil)))
	 (fanout 1))
    (dolist (tinf tableinfos)
      (cond ((primary-key-bound? ds tinf preds env)nil)
	    ((some (f/l(x)(eq (oid-name (generic-function-of (car x))) '=)) preds)
	     (setq fanout (* fanout 10)))
	    (preds (setq fanout (* fanout 100.)))
	    (t  (setq fanout (* fanout 1000.)))))
    (list (* *sql-cost-per-tuple* fanout) fanout)))

(defun primary-key-bound? (ds tinf preds env)
  "True if for every column that make up the primary key of the table
   pointed out by <tinf> in datasource <ds>, there is a pred in <preds> that
   binds the column. <env> is the variable environment."
  (let* ((catalog (tableinfo-catalog tinf))
	 (schema  (tableinfo-schema tinf))
	 (table   (tableinfo-name tinf))	 
	 (keycols (get-declared-key ds catalog schema table)))
    (every (f/l (keycol) 
	     (some (f/l (pred) 
		      (binds-primary-key? pred tinf keycol env))
		   preds))
	   keycols)))

(defun binds-primary-key? (pred tinf pkey-column env)
  (if (eq (predicate-operator pred) _=_)
      (let ((arg1 (predicate-argument 1 pred))
	    (arg2 (predicate-argument 2 pred)))
	(or (binds-column? arg1 tinf pkey-column env)
	    (binds-column? arg2 tinf pkey-column env)))))
		  
(defun binds-column? (arg tinf column env)
  (or (and (columninfo-p arg)
	   (equal (columninfo-tableinfo arg) tinf)
	   (eq (columninfo-name arg) column))
      (and (varsymbolp arg)
	   (columninfo-p (entity arg env))
	   (binds-column? (entity arg env) tinf column env))))
