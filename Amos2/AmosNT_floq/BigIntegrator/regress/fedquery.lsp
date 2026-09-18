;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) <year>2013 <author>Minpeng Zhu, UDBL
;;; $RCSfile: sql_finalizer_new.lsp,v $
;;; $Revision: 1.2 $ $Date: 2013/09/10 11:51:58 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: <description>
;;; =============================================================

(defun purge-nullpar (inparams)
  (subset inparams (f/l (argpair)
			(let ((argtype (car argpair)))
			  (not (null argtype))))))

(defun generate-sql-string2 (q)
  (translate-sourcepredicate2 q);;first translate source predicate 
  (get-sql-string q);;translate predl in sqlquery-selectpred
  )

(defun translate-sourcepredicate2 (sqlq)
  "translate absorbed source predicates"
  (let ((ds (sqlquery-datasource sqlq))
	(SPs (sqlquery-sourcepred sqlq))
	)
    (mapc (f/l (sp)
	       (relational-translate-source-predicate2 ds sp sqlq))
	  (reverse SPs))))

(defun relational-translate-source-predicate2 (ds sp sqlq)
  (let* ((fno (predicate-operator sp));;source predicate
	 (ti  (sqlquery-add-table sqlq (getobject fno 'tablename)))
	 ;;expanded args with logdb_URI as first argument
	 (expandedArgs     (predicate-arguments sp))
	 (logdb_URIvar (car expandedArgs));;logdb_URI variable to find logdb
	 (args (cdr expandedArgs))
	 (expandedColnames (function-resvars fno))
	 (colnames (cdr expandedColnames))
	 ci)
    ;;add logdb_URIvar as the 
    (sqlquery-add-input sqlq logdb_URIvar)
    (dolists ((arg args) (colname colnames))
     ;;do nothing for first argument
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