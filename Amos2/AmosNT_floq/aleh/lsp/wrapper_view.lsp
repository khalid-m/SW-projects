;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2005 Ruslan Fomkin UDBL
;;; $RCSfile: wrapper_view.lsp,v $
;;; $Revision: 1.5 $ $Date: 2006/02/07 07:30:05 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Necessary extension for definining mapping between ROOT 
;;; wrapper and ALEH ontology.
;;;
;;; ===========================================================================

; create_mapped_type function with ability to specify super types and boolean
; for earlier binding.
(foreign-lispfn  
 create_mapped_type 
 ((charstring name)(vector stypes)(vector keys)(vector attributes)
  (charstring ccfn)(boolean early)) 
 ((type))
 "Creates mapped type, given name, supertypes, keys, attributes, and Core Cluster Function"
 (let ((ccfn (resolvents (getfunctionnamed (mksymbol ccfn))))
       rt attrs pos)
   (if (cdr ccfn) 
       (error "More than one resolvent for Core Cluster Function" ccfn)
     (setq ccfn (car ccfn)))
   (if (get-resolvent-argtypes ccfn)
       (error "Core Cluster Function cannot have arguments" ccfn))
   (setq rt (get-resolvent-restypes ccfn))
   (if (not (= (length rt)(length attributes)))
       (error "Width of Core Cluster Function different from # attributes" 
	      name))
   (setq attrs (mapcar (f/l (tpe an)(list (oid-name tpe) (mksymbol an))) 
		       rt (arraytolist attributes)))
   (setq keys (mapcar (function mksymbol) (arraytolist keys)))
   (setq stypes (mapcar (function mksymbol) (arraytolist stypes)))
   (cond ((null keys)(error "No key specified in mapped type" name))
         ((cdr keys))
         ((null (member (functiontype ccfn) '("stored" "foreign"))))
         ((setq pos (getpos (searchdcl (car keys) attrs) attrs))
	  (if (not (memq 'key 
			 (nth pos (second (getobject ccfn 'orgcode)))))
	      (formatl t "Core Cluster element " (car keys) 
		       " should be KEY" t))))
   (create-mapped-type (mksymbol name) stypes
		       attrs
		       (mapcar (f/l (k)
				    (or (searchdcl (mksymbol k) attrs)
					(error "Undefined mapped type key" k)))
			       keys)
		       (oid-name ccfn) nil early)
   ))

; create_mapped_type function without requiring to specify super types and 
; provide boolean for earlier binding.
(foreign-lispfn  
 create_mapped_type 
 ((charstring name)(vector keys)(vector attributes)
  (charstring ccfn)(boolean early)) 
 ((type))
 "Creates mapped type, given name, supertypes, keys, attributes, and Core Cluster Function"
 (let ((ccfn (resolvents (getfunctionnamed (mksymbol ccfn))))
       rt attrs pos)
   (if (cdr ccfn) 
       (error "More than one resolvent for Core Cluster Function" ccfn)
     (setq ccfn (car ccfn)))
   (if (get-resolvent-argtypes ccfn)
       (error "Core Cluster Function cannot have arguments" ccfn))
   (setq rt (get-resolvent-restypes ccfn))
   (if (not (= (length rt)(length attributes)))
       (error "Width of Core Cluster Function different from # attributes" 
	      name))
   (setq attrs (mapcar (f/l (tpe an)(list (oid-name tpe) (mksymbol an))) 
		       rt (arraytolist attributes)))
   (setq keys (mapcar (function mksymbol) (arraytolist keys)))
   (cond ((null keys)(error "No key specified in mapped type" name))
         ((cdr keys))
         ((null (member (functiontype ccfn) '("stored" "foreign"))))
         ((setq pos (getpos (searchdcl (car keys) attrs) attrs))
	  (if (not (memq 'key 
			 (nth pos (second (getobject ccfn 'orgcode)))))
	      (formatl t "Core Cluster element " (car keys) 
		       " should be KEY" t))))
   (create-mapped-type (mksymbol name) nil
		       attrs
		       (mapcar (f/l (k)
				    (or (searchdcl (mksymbol k) attrs)
					(error "Undefined mapped type key" k)))
			       keys)
		       (oid-name ccfn) nil early)
   ))

(defglobal _VREF_ (getfunctionnamed 'VECTOR.INTEGER.VREF->OBJECT))
(defglobal _VECTOR-FUNC_ (getfunctionnamed 'VECTOR))

;; Rule for unification array element access
(defun inferequals (andl)
  "Given a conjunction, andl, this function tries to do compile time 
   unification of variables by looking at several calls the same
   stored predicate with common argument variables having unique indexes
   For eaxmple:
      income(p,q) and income(p,r) and unique index on p
    <=> q=r and income(p,r)"
  (let (other res ivar)
    (while (not (atom andl))
      (cond 
       ((member (car andl) (cdr andl)))	;Remove any duplicate in ANDL
       ((and (equal (caar andl) _VREF_) 
	     (integerp (third (car andl)))
	     (setq ivar 
		   (nth (third (car andl))
			(cddar 
			 (isome (append2 res (cdr andl))
				(f/l (p2) 
				     (and (equal (car p2) _VECTOR-FUNC_)
					  (equal (second p2) 
						 (second (car andl))))))))))
	(setq res (cons (list _=_ (fourth (car andl)) ivar) res)))
       ((null (hasuniqueindex (car andl)))
	(setq res (cons (car andl) res)))
       ((setq other
	      (car (isome (cdr andl)
			  (f/l (p2) (hasuniquecommonvar (car andl) p2)))))
	(setq res (nconc (compunify (car andl) other) res)))
       (t
	(setq res (cons (car andl) res))))
      (setq andl (cdr andl)))
    (cond 
     ((null andl) (nreverse res))
     ((null res) andl)
     (t (nreverse (cons andl res))))))

(defvar arcounter 0)
(foreign-lispfn  reset_arcounter ()((integer))
		 (setq arcounter 0)
		 (foreign-result arcounter))
(foreign-lispfn arcount((object o))((object))
		(setq arcounter (+ 1 arcounter))
		(foreign-result o))
(foreign-lispfn arcounter ()((integer))
		(foreign-result arcounter))
