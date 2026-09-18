;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) <year> 2012 <author> Minpeng Zhu, UDBL
;;; $RCSfile: accessfilter.lsp,v $
;;; $Revision: 1.3 $ $Date: 2013/06/03 15:37:00 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: cost model for access filters.
;;; =============================================================

(defglobal _access-filter_
  (CREATE-FUNCTION access-filter ((EXPRESSION E)) nil
		   AS FOREIGN ("abstract-function")))

(defun gen-accessfilter (genexpression accessfiltervarlist)
  (list* _access-filter_ genexpression accessfiltervarlist) ;accessfilter pred
  )

(defglobal _def-accessfilter-cost_ 100000)

(defglobal _def-accessfilter-fanout_ 10000)

(defun accessfilter-cost---++ (fno accessfilter-fno bpat args cost fanout)
  (let* ((expression (aref args 0))
	 (filter (expression-filter expression));;query fragment
	 (absorbedpredl (cdr filter));;absorbed preds by first met source pred
	 (dsinst (expression-source expression))
	 (cost _def-accessfilter-cost_)
	 (fanout _def-accessfilter-fanout_)
	 (collection (mkstring (getobject accessfilter-fno 'collection)))
	 )
    ;;R=(F-1)/C
    (cond ((consp dsinst);;set of data source instances
	   (let ((numofdsinst (length dsinst)))
	     (setq fanout (* numofdsinst (* fanout 100)))
	     (setq cost (+ 10000 (* fanout 100)))))
	  (t;;single data source instance
	   (let* ((dsn (string-downcase (mkstring (oid-name dsinst))))
		  (collectionSize (caar (getfunction 'collectionSize 
						     (list dsn collection)))))
	     (cond (absorbedpredl
		    (cond ((some (f/l (pred) (compound-p pred)) absorbedpredl)
			   (setq cost (+ 10000 (* fanout 100))))
			  ((some (f/l (pred) (sourcepred? (predicate-operator 
							   pred)))
				 absorbedpredl);;join query
			   (setq fanout (* fanout 100))
			   (setq cost (+ 10000 (* fanout 100))))
			  (t;; query on single collection
			   (cond (collectionSize;;collection size known
				  (cond ((some (f/l (pred)(eq (generic-fnname 
							       (car pred)) '=))
					       absorbedpredl)
					 (setq fanout (/ collectionSize 200))
					 (setq cost (+ 10000 (* fanout 100)))
					 )
					(t;;
					 (setq fanout (/ collectionSize 10))
					 (setq cost (+ 10000 (* fanout 100)))
					 )))
				 (t;;no meta data about collection size
				  (cond ((some (f/l (pred)(eq (generic-fnname 
							       (car pred)) '=)) 
					       absorbedpredl)
					 (setq fanout (/ fanout 200))
					 (setq cost (+ 10000 (* fanout 100)))
					 )
					(t;;
					 (setq fanout (/ fanout 10))
					 (setq cost (+ 10000 (* fanout 100)))))
				  )))))
		   (t;;no absorbed preds
		    (cond (collectionSize
			   (setq fanout collectionSize)
			   (setq cost (+ 10000 (* collectionSize 100)))))
		    )))))
    (osql-result accessfilter-fno bpat args cost fanout))
  )

(defglobal _accessfilter-cost_
  (osql "
create function accessfilter_cost(Function fno, Vector bpat, Vector args)
  -> (Number acost, Number afanout)
  as foreign 'accessfilter-cost---++';"))

(declarecosts _access-filter_ '*any* _accessfilter-cost_) ;;C  F

(bind-foreign _access-filter_ '*any* 'abstract-function)