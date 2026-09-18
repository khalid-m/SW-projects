;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009-2014 Andrej Andrejev, UDBL
;;; $RCSfile: sparql-lsp-parser-datamodel.lsp,v $
;;; $Revision: 1.24 $ $Date: 2014/01/10 11:25:45 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description:  Common definitions for sparql-grammar.lsp and sparql-stream-parser.lsp
;;; =============================================================

;; Common definitions for slr1-grammar.lsp and sparql-lsp-parser.lsp

(defstruct sparql-data (last-blank -1))

(defun sparql-gen-blank (data)
  (incf (sparql-data-last-blank data))
  (list 'genblank (sparql-data-last-blank data)))

(defstruct sqo n ts) ; SparQL object, identified by N, with generated (sub)sequence triples attached in TS

(defun sparql-make-triples (s pos)
  (append (mapcar (f/l (po) (cons (sqo-n s) po)) (sqo-n pos))
	  (sqo-ts s) (sqo-ts pos)))

(defun sparql-collection-to-triples (data nodes)
  (if (null nodes) 
      (make-sqo :n (list 'uri "http://www.w3.org/1999/02/22-rdf-syntax-ns#nil"))
    (let ((res (sparql-gen-blank data))
	  (rest (sparql-collection-to-triples data (cdr nodes)))) ;recursive
      (make-sqo :n res
		:ts (cons (list res (list 'uri "http://www.w3.org/1999/02/22-rdf-syntax-ns#first") (sqo-n (car nodes)))
			  (cons (list res (list 'uri "http://www.w3.org/1999/02/22-rdf-syntax-ns#rest") (sqo-n rest))
				(append (sqo-ts (car nodes)) (sqo-ts rest))))))))

(defstruct sparql-stat type what from where distinct groupby having agg-expr ext-cond ext-ref)

(defstruct sparql-update with delete insert using where)

(defstruct sparql-archive as from triples)

(defun sellist-to-vars (sellist) (mapcar (f/l (nov) (selectq (car nov)
							  (named (second nov))
							  (var (cdr nov))
							  "")) sellist))

(defstruct block conds bound+ ref* partial substs blanks)

(defstruct expr-data prefixes substs bound ref free newconds newconds-tr newvars sources)

(defun clone-expr-data (ed)
  (make-expr-data :prefixes (expr-data-prefixes ed) 
		  :substs (copy-tree (expr-data-substs ed))
		  :bound (expr-data-bound ed)))


(defun add-subst (ed vars modifier)
  (let (ac)
    (dolist (v vars)
      (setq ac (assoc v (expr-data-substs ed)))
      (if ac (setf (cdr ac) (cons (concat (cadr ac) modifier) (cdr ac)))
	(push (list v (concat v (if (string-pos v ":") "" ":") modifier)) 
	      (expr-data-substs ed))))))
		  

(defstruct tla-data exprs aggs)

(defstruct define-stat name agg vars body)