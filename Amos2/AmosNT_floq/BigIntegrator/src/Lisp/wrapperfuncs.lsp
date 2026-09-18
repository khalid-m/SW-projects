;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) <year> 2012 <author> Minpeng Zhu, UDBL
;;; $RCSfile: wrapperfuncs.lsp,v $
;;; $Revision: 1.4 $ $Date: 2013/05/01 15:19:26 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: The wrapper functions hold the query info structure
;;;              for each wrapper.
;;; =============================================================

;;;;;;;;;;;;;;;;;;query structure info;;;;;;;;;;;;;;;;;

;;;;;;;;;;;sql;;;;;;;;;;;;;
(defstruct sqlquery
  ; public fields
  datasource
  environment
  input; list of variable symbols
  output; list of variable symbols
  ; private fields, do not reference
  sourcepred; source predicate
  selectpred; an predicate expression
  projections; assoc list of (table . n) n is no of occurences
  sqlstring; sql query string
  accessfiltervarlist;;all SP vars
  varpredassnlst;;association list of var and the arithmetic predicate binds it
  )

;;;;;;;;;;;gql;;;;;;;;;;;;;
(defstruct gqlquery
  datasource
  environment
  input; list of variable symbols
  output; list of variable symbols

  sourcepred; source predicate
  selectpred; an predicate expression
  projections; assoc list of (table . n) n is no of occurences
  gqlstring
  )

;;;;;;;;;;SparQL;;;;;;;;;;;;
(defmacro my-defstruct (name short-name &rest slots)
  (let ((names (mapcar #'(lambda (slot)
			   (pack name '- slot))
		       slots))
	(short-names (mapcar #'(lambda (slot)
				 (pack short-name '- slot))
			     slots)))
    `(progn
       (defstruct ,name ,@slots)
       ,@(mapcar #'(lambda (n sn)
		     (list 'movd (kwote n) (kwote sn)))
		 names
		 short-names)
       ,@(mapcar #'(lambda (n sn)
		     (list 'put (kwote sn) ''setfmethod (list 'get (kwote n) ''setfmethod)))
		 names
		 short-names))))

(my-defstruct sparql-query sq
  where
  invars
  outvars
  environment
  bvar-count
  bvar-db
  filters)