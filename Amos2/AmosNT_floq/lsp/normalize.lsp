;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c)  2005 Tore Risch, UDBL
;;; $RCSfile: normalize.lsp,v $
;;; $Revision: 1.6 $ $Date: 2010/01/06 15:29:55 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Normalize predicate to DNF or CNF (org. by M. Carlsson)
;;; =============================================================
;;; $Log: normalize.lsp,v $
;;; Revision 1.6  2010/01/06 15:29:55  torer
;;; CommonLisp standard (append x nil) used for copying top levels of lists
;;;
;;; Revision 1.5  2006/11/08 14:18:13  torer
;;; Flag _ENABLE-PROPTABLES_ (default T)
;;;
;;; Revision 1.4  2006/11/08 14:16:07  torer
;;; Normalization using property table constructors
;;;
;;; =============================================================

(defglobal _rowprops_); property table stream constructor
(defglobal _enable-proptables_ t)

(defun normalizepred (p op)
  "Normalize preicate to DNF if OP=OR or CNF if OP=AND"
  (cond ((atom p) p)
	((and _enable-proptables_
              (orp (car p));; To not normalize property table construction
	      (property-table-construction (cdr p))))
	((eq (car p) (invop op))
	 (connify op
		  (moveinner (cdr p) op)))
	((eq (car p) op)
	 (connify op
		  (moveouter (cdr p) op)))
	(t p)))

(defun invop (op)
  (selectq op
	   (and 'or)
	   (or 'and)
	   (error "Illegal logical connector" op)))

(defun moveouter (tail op)
  (and tail (let ((hd (normalizepred (car tail) op)))
	      (cond ((and (listp hd)
			  (eq (car hd) op))
		     (nconc (mapcar (function list) (cdr hd))
			    (moveouter (cdr tail) op)))
		    (t (cons (list hd)
			     (moveouter (cdr tail) op)))))))

(defun connify (op p)
  (let ((invop (invop op)))
    (funify op (mapcar (f/l (pl) (funify invop pl))
		       p))))

(defun moveinner (tail op)		; iterative version
  (let ((res (list nil)))
    (dolist (p tail)
      (let* ((hd (normalizepred p op))
	     (invop (invop op))
	     (isop (and (listp hd)(eq (car hd) op)))
	     (isinvop (and (listp hd)(eq (car hd) invop))))
	(setq res (mapcan (f/l (c) 
			       (cond (isop
				      (mapcar
				       (f/l (q) (append c (argsof invop q) 
							nil))
				       (cdr hd)))
				     (isinvop
				      (list (append c (cdr hd) nil)))
				     (t (list (append c (list hd)))))) 
			  res))))
    res))

;;;;;;;;;; Rewrite to property list constructor to avoid nested disjunctions


(defun property-table-construction (orargs)
  "Convert OR body to property list constructor if possible"
  (let (triplevars subject subjectval property value len props vals valv)
    (every (f/l (pred)
		(and (listp pred)
		     (andp (car pred))
		     (= (length pred) 4)
		     (every (f/l (p)
				 (and (eq (car(ilistp p)) _=_)
				      (osql-variablep (second p))
				      (let ((v (assq (second p) triplevars)))
					(cond ((null v)
					       (push (append (cdr p) nil) 
						     triplevars))
					      (t (nconc1 v (third p)))))))
			    (cdr pred))))
	   orargs)
    (dolist (b triplevars)
      (cond ((and (null subject)
		  (null (cdr (unique (cdr b)))))
             (setq subjectval (cadr b))
	     (setq subject (car b)))
	    ((every (function stringp)(cdr b))
             (setq property (car b))
	     (setq props (cdr b)))
	    (t (setq value (car b)) 
	       (setq vals (cdr b)))))
    (and subject
	 (= (length props)(length vals))
	 (list 'and (list* (getfunctionnamed 'vector)
			   (setq valv (dt_genvar _vector_)) vals)
               (list _=_ subject subjectval)
	       (list _rowprops_  (listtoarray props)valv
		     property value)))))
