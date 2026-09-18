;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013 Andrej Andrejev, UDBL
;;; $RCSfile: in-memory-storage.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/12/20 14:48:21 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: In-memory storage facilities for SSDM
;;; =============================================================
;;; $Log: in-memory-storage.lsp,v $
;;; Revision 1.1  2013/12/20 14:48:21  andan342
;;; Supporting multiple stored graphs:
;;; - added GRAPH and FROM NAMED syntax
;;; - LOAD() and CLEAR() functions now take a graph URI as the last argument
;;; - default stored graph is now in GRAPH(0)
;;;
;;;
;;; =============================================================

;; Depends on:
;;  _sq_string_based_

(defvar _sq_default_triples_fn_ "GRAPH(0)")

(if _sq_string_based_
(osql "
/* create function DEF() -> (Charstring s, Charstring p, Charstring o); */

create function GRAPH(Integer g) -> Bag of (Charstring s, Charstring p, Charstring o);

create function NGDict(Charstring uri) -> Integer i;

create function GRAPHS(Vector of integer vg) -> Bag of (Charstring s, Charstring p, Charstring o)
  as select s, p, o from Integer g
      where (s, p, o) in GRAPH(g)
        and g in vg;

create function rdf:insert(Integer g, Charstring s, Charstring p, Charstring o) -> Boolean
/* Simple insert function, may be redefined by storage engines */
  as add GRAPH(g) = (s,p,o);

create function TermInDEF(Charstring x) -> Boolean
  /* Lookup function for blanks */
  as some(select x
            from Integer g, Charstring s, Charstring p, Charstring o
           where (s,p,o) in GRAPH(g)
             and ((s = x) or (p = x) or (o = x)));
")
(osql "
/* create function DEF() -> Bag of (Literal s, Literal p, Literal o); */

create function GRAPH(Integer g) -> Bag of (Literal s, Literal p, Literal o);

create function NGDict(Literal uri) -> Integer i;

create function GRAPHS(Vector of integer vg) -> Bag of (Literal s, Literal p, Literal o)
  as select s, p, o from Integer g
      where (s, p, o) in GRAPH(g)
        and g in vg;

create function rdf:insert(Integer g, Literal s, Literal p, Literal o) -> Boolean
/* Simple insert function, may be redefined by storage engines */
  as add GRAPH(g) = (s,p,o);

create function TermInDEF(URI x) -> Boolean
  /* Lookup function for blanks */
  as some(select x
            from Integer g, Literal s, Literal p, Literal o
           where (s,p,o) in GRAPH(g)
             and ((s = x) or (p = x) or (o = x)));
"))

(osql "
/* create_index('def','s','hash','multiple');
create_index('def','p','hash','multiple');
create_index('def','o','hash','multiple'); */

create_index('graph','g','hash','multiple');
create_index('graph','s','hash','multiple');
create_index('graph','p','hash','multiple');
create_index('graph','o','hash','multiple');
")

(defun get-blank-in-DEF (x)
  "Check if string X represnets a node inside the tripels"
  (getfunction (car (getobject (getfunctionnamed 'TermInDEF) 'resolvents)) 
	       (list (if _sq_string_based_ x (URI x)))))

(setq _sq_get_blank_ #'get-blank-in-DEF)

(defparameter graph-dict-fn (car (getobject (getfunctionnamed 'NGDict) 'resolvents)))

(defun ngdict-lookup (graph add-missing)
  "Lookup a graph id in NGDict, add if missing and allowed to add, signal error otherwise"
  (if (if _sq_string_based_ (string= graph "") (not (eq (typename graph) 'uri))) 0
    (let ((res (caar (getfunction graph-dict-fn (list graph)))))
      (unless res
	(if add-missing
	    (progn
	      (setq res 1)
	      (dolist (row (extent graph-dict-fn))
		(when (>= (second row) res)
		  (setq res (1+ (second row)))))
	      (addfunction graph-dict-fn (list graph) (list res)))
	  (error (concat "Graph " (if _sq_string_based_ graph (concat "<" (uri-id graph) ">")) " not found!")))) ;TODO: maybe should silently return an empty graph!
      res)))

(defun graphs-to-triples-fn (graphs add-missing)
  "Translate a list of graph URIs into triples-fn to be used in translation of triple patterns"
  (cond ((null graphs)
	 "GRAPH(0)")
	((cdr graphs)
	 (concat "GRAPHS({" (strings-to-string (mapcar (f/l (g) (mkstring (ngdict-lookup g add-missing))) graphs) "" "," "") "})"))
	(t
	 (concat "GRAPH(" (ngdict-lookup (car graphs) add-missing) ")"))))


