;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Tore Risch, UDBL
;;; $RCSfile: tuple.lsp,v $
;;; $Revision: 1.2 $ $Date: 2013/12/30 13:35:55 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Tuple types
;;; =============================================================
;;; $Log: tuple.lsp,v $
;;; Revision 1.2  2013/12/30 13:35:55  torer
;;; Better support for tuples
;;;
;;; Revision 1.1  2011/12/29 07:41:12  torer
;;; Tuple types definition
;;;
;;; =============================================================

(defglobal _tuple_ (createtype 'tuple '(collection))
  "OID of type TUPLE")

(defun tuplep (x)
  (and (listp x)
       (eq (car x)
	   _tupletag_)))

(defun make-tupletypename (names)
  (if names
      (let (nl)
	(mapc2 #'(lambda(name1 name2)
		   (if name2
		       (setq nl (nconc (list "," name1) nl))
		     (setq nl (cons name1 nl))))
	       names)
	(packlist (cons "(" (reverse (cons ")" nl)))))
    'tuple))

(defun make-tupletype  (typel)
  "Construct the tuple type whose elements have types in TYPEL"
  (make-param-type typel 
		   (function make-tupletypename)
		   (function null)
		   _tuple_))


(defun construct-tuple (obj tpl &rest e)
  "TUPLE dynconstructor"
  (cond ((eq tpl '*) (apply 'osql-result (cons 'tuple e) e))
	((and (tuplep tpl) (eq (length (cdr tpl))(length e)))
	 (apply 'osql-result tpl (cdr tpl)))))

(defun infer-tupletype (v)
  "Compute the type of a tuple constant"
  (make-tupletype (mapcar (function arg-type) (cdr v))))

(defun initialize-tuple-type ()
  (make-dynconstructor 'tuple 'construct-tuple 'tuple)
  (setq _tuple-constructor_ (getfunctionnamed 'tuple->tuple))
  (putprop 'tuple 'aggregator 'tuple)
  (commit)
  )