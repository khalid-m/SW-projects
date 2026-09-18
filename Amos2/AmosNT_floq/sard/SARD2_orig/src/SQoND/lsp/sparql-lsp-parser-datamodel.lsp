;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009-2010 Andrej Andrejev, UDBL
;;; $RCSfile: sparql-lsp-parser-datamodel.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/08/09 14:26:39 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description:  Common definitions for sparql-grammar.lsp and sparql-lsp-parser.lsp
;;; =============================================================

;; Common definitions for slr1-grammar.lsp and sparql-lsp-parser.lsp

(defstruct sparql-data (last-blank -1))

(defun sparql-gen-blank (data)
  (incf (sparql-data-last-blank data))
  (list 'genblank (sparql-data-last-blank data)))

(defstruct sqo n (ts nil)) ; SparQL object, identified by N, with generated (sub)sequence triples attached in TS

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

(defstruct sparql-stat type what from where distinct groupby having agg ext-what)

(defun sellist-to-vars (sellist) (mapcar (f/l (nov) (selectq (car nov)
							  (named (second nov))
							  (var (cdr nov))
							  "")) sellist))

(defstruct block conds bound+ ref* partial substs blanks newvars)

(defstruct expr-data prefixes substs bound free newconds newvars)

(defstruct define-stat name agg vars body)