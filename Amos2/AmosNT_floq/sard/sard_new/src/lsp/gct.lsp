;;; ===========================================================================
;;; AMOS2
;;;
;;; Author: (c)2009 Tore Risch, Silvia Stefanova, UDBL
;;; $RCSfile: gct.lsp,v $
;;; $Revision: 1.20 $ $Date: 2012/08/27 12:16:11 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Functions for grouping terms in a DNF predicate
;;;;;; ===========================================================================
(defglobal subjects nil);;table for the triples' subjects, i.e. rowid and vector
(defglobal _subjects_ nil)


(defun gct (pred group-fetcher)
  (cond 
   ((atom pred) pred)
   ((neq (car pred) 'or) pred)
   ((null (cddr pred)) pred)
   (t 
    (let ((ht (make-hash-table :test (function equal)))
	  newpred)
      (dolist (d (cdr pred))
	(cond ((atom d);; constant
               (push d newpred))
	      ((neq (car d) 'and);; disjunct not conjunction
	       (push d newpred))
	      ((null (cddr d));; one element in disjunct
	       (push d newpred))
	      (t (let ((fetch (funcall group-fetcher (cdr d))))
		   (cond ((null fetch);; fetcher failed
                          (push d newpred))
			 (t;; add disjunct with fetched terms removed
			  (setf (gethash fetch ht) 
				(cons (andify (set-difference (cdr d)
							      fetch t))
				      (gethash fetch ht)))))))))
      (maphash 
       (f/l (key dj)
	    (cond ((cdr dj)
                   ;; group key in more than one disjunct 
                   (push (andify (append key 
					 (list (orify dj))))
			 newpred))
		  (t;; group key only in one disjunct
		   (push (andify (append key dj))
			 newpred))))
       ht)
      (orify newpred)))))

(defun is-source-relation (term)
  "returns non-nil if the term refers to o source relation"
  (and (consp term) 
       (oid-p (first term))
       (getobject (first term) 'tablename)))  


(defun is-rowid (term)
  "returns non-nil if the term is a rowid call"
  (and (consp term)
       (oid-p (first term))
       (eq (oid-name (first term))
	   'CHARSTRING.VECTOR.ROWID->CHARSTRING)))
;;(member term subjects)))

(defun is-valueid (term)
  "returns non-nil if the term is a rowid call"
  (and (consp term)
       (oid-p (first term))
       (eq (oid-name (first term))
           'LITERAL.CHARSTRING.VALUEID->CHARSTRING)))



(defun is-ner-rdf (term)
  "returns non-nil if the term is a new rdfres"
  (and (consp term)
       (oid-p (first term))
       (eq (oid-name (first term))
           'OBJECT.NEW_RDF_RESOURCE->RDF_RESOURCE)))

(defun is-like (term)
  "returns non-nil if the term is a like predicate"
  (and (consp term)
       (oid-p (first term))
       (eq (oid-name (first term))
           'CHARSTRING.CHARSTRING.LIKE->BOOLEAN)))

(defun is-ineq (term)
  "returns non-nil if the term is a new rdfres"
  (and (consp term)
       (oid-p (first term))
       (eq (oid-name (first term))
           'OBJECT.OBJECT.!=->BOOLEAN)))


(defun is-typesof (term)
  "returns non-nil if the term is a new rdfres"
  (and (consp term)
       (oid-p (first term))
       (eq (oid-name (first term))
           'OBJECT.TYPESOF->TYPE)))


(defun is-vector (term)
  "returns non-nil if the term is a rowid call"
  (and (consp term)
       (oid-p (first term))
       (eq (oid-name (first term))
	   'VECTOR)
       (member term subjects)))

(defun is-tuple (term)
  "returns non-nil if the term is a tuple"
  (and (consp term)
       (oid-p (first term))
       (eq (oid-name (first term))
	   'TUPLE)))

(defun is-biggerlessthan (term)
  "returns non-nil if the term is a new rdfres"
  (and (consp term)
       (oid-p (first term))
       (or (eq (oid-name (first term))'OBJECT.OBJECT.>->BOOLEAN)
	   (eq (oid-name (first term)) 'OBJECT.OBJECT.!=->BOOLEAN)
	   (eq (oid-name (first term))'OBJECT.OBJECT.<->BOOLEAN))
       (ret-genvar (predicate-variables term))))

(defun is-optional (term)
  "returns non-nil if the term is an optional"
  (and (consp term)
       (oid-p (first term))
       (or (eq (oid-name (first term)) 'BAG.OBJECT.OPTIONAL->OBJECT)
	   (eq (oid-name (first term)) 'FUNCTION.MAKEBAG->BAG)   )))


(defun source-fetcher-original (l)
  "returns list of terms to use as grouping key in L"
  (subset l (f/l (x) (or (is-source-relation x)
			 (is-rowid x)
			 (is-vector x) 
			 (is-rowid x)))))

		

;;(advise-around 'transformpredicate '(gct * (function source-fetcher)))

(defun source-fetcher-optional (l)
  "returns list of terms to use as grouping key in L"
  (subset l (f/l (x) (or (is-source-relation x)
			 (is-like x)
			 (is-biggerlessthan x)
			 (is-rowid x)
			 (is-vector x)
			 (is-optional x)))))

(defun source-fetcher (l)
  "returns list of terms to use as grouping key in L"
  (subset l (f/l (x) (or (is-source-relation x)
			 (is-like x)
			 (is-biggerlessthan x)))))
		
	


(defun source-fetcher-3 (l resvars)
  "returns list of terms to use as grouping key in L"
  "Picks up only the rowid and vector defining the subject S"
  (let ((fetched nil)
	(htk nil)
	(vsub nil)
	(ht (make-hash-table :test (function equal))) )
    (dolist (sp l) 
      (if (is-source-relation sp)
	  (push sp fetched)
	(if (is-rowid sp)
	    (progn
	      (if (in (car resvars) (predicate-variables sp));;checks whether the rowid defines the subject if it is unknown
		  (progn
		    (push sp fetched)
		    (setf vsub (car (set-difference (predicate-variables sp) (car resvars) )) )
		    )
		))
	  (if (is-vector sp)
	      (progn
		(setf htk (list (car sp) (cadr sp))) ;;construct the key of the ht
		(setf (gethash htk ht) sp))) )))
    (maphash 
       (f/l (key el)
	    (if (eq (cadr key) vsub)
		(push el fetched))
	    )
       ht)
    (reverse fetched)))
