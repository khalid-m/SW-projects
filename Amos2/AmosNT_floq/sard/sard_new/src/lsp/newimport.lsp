;;; ===========================================================================
;;; AMOS2
;;;
;;; Author: (c)2009 Silvia Stefanova, UDBL
;;; $RCSfile: newimport.lsp,v $
;;; $Revision: 1.11 $ $Date: 2013/05/01 15:27:10 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Redefinition of import-table funcs  in order to get ident number
;;;as a fisrt column
;;;;;; ===========================================================================


(defun create-relational-core-cluster-res-fn (ds table columns keys relation-name)
  (let*	((width        (length columns))
	 (name         (concat (make-core-cluster-fn-name relation-name)))
	 (fullname     (concat name (packlist (buildn width '+))))
	 (column-names (mapcar #'second columns))
	 (fbunch       (make-string (1+ width) "f"))
	 (fno          (createfunction 
			name
					; the arguments; none
			nil
					; its result types
			(cons '(integer _ident_ )columns)
					; RESV
			'multidirectional
					; QUANT
			`(( , fbunch foreign , fullname))
					; PRED, whatever that is
			nil)))
  ;(declare-keys fno (cons '(integer _ident_) keys)  (cons '(integer _ident_) columns))
 (declare-keys fno keys (cons '(integer _ident_) columns))
  ;(declare-keys fno '(integer _ident_) (cons '(integer _ident_) columns))

 (addfunction 'absorbability (list ds) (list fno))

    (defc (mksymbol fullname) 
      `(lambda , (cons 'fno column-names)
        (let ((no 0))
	 (mapfunction , (resolvename 'sql_nil (list ds ""))
			(vector , ds , (concat "select "
					       (concatl column-names","(function id))
					       " from "table))
	   (f/l (row) (apply (function osql-result) (cons (1++ no) (arraytolist (car row)))))))))
           
    ;; This is something that should be on all mapped types of type 
    ;; relational.
    (/putobject fno 'tablename table)
    ;; Remember that the ds object holds the connection. It must be 
    ;; present on a core-cluster function. These props *should* be put on the 
    ;; generic function but the translator API cannot assume that every extent
    ;; function has a generic function.
    (addfunction 'datasource (list fno) (list ds))

    fno))


(defun import-table-res (ds catalog schema table mtname updateable supertypes)
  (let* ((columns (get-columns-amos-typed ds table 'noerror))
	 (keycols (get-key-columns-amos-typed ds catalog schema table))
	 (cc-fno  (create-relational-core-cluster-res-fn
		   ds table columns keycols mtname))
	 (cc-name (generic-fnname cc-fno))
	 mt)
    (add-rewriter cc-fno (buildn (length columns) '+) 'rewrite-extent)
    (/putobject cc-fno 'CCLUSTERFCT? t);;added
    (setq mt (create-mapped-type mtname 
				 supertypes
				 (cons '(integer _ident_) columns) 
				 (cons '(integer _ident_) keycols) 
				 cc-name))
    (add-amos-type    ds :wrapped table :amos mt)
    (add-wrapped-type ds :wrapped table :amos mt)
    (if updateable (create-keyed-update-fns ds mt columns keycols))
    (if updateable
	(set-constructor mt (create-sql-constructor ds mt))
      (forbid-constructor mt "This mapped type is read-only"))
    mt))


(defun compute-exec-cost-pred-new (optpreds bnd)
  (catch 'predcost;;An exception can be raised in andpredcost
    (let* ((disjs (if (eq 'or (car optpreds)) (cdr optpreds) nil))
	   (ands (cond ((eq (car optpreds) 'and) (cdr optpreds))
		       ((atom optpreds) nil)
		       (t (list optpreds))))
	   (cost (list 0 0)))
      (if (null disjs) 
	  (setq cost (andpredcost ands bnd))
	
        ;;Cost of a disjunction is the sum of the cost of its elements
	(dolist (branch disjs)    
	  (let* ((branch_cost (compute-exec-cost-pred (if (compound-p branch) 
							  (optimize-compound-predicate branch bnd)
							branch) bnd)))
	    (if branch_cost
		(setq cost (list (+ (first cost) (first branch_cost))
				 (+ (second cost) (second branch_cost))))
	      (amos-error "OR branch cannot be executed in the 
                                 given context:" branch)))))
      cost)))





