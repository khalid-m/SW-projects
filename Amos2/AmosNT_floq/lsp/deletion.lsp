;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1993 Staffan Flodin, Tore Risch, EDSLAB
;;; $RCSfile: deletion.lsp,v $
;;; $Revision: 1.10 $ $Date: 2010/02/16 20:06:57 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Deletion mechanisms for schema evolution
;;; =============================================================


(defglobal _fnstorecompile_ nil)
(defglobal _instancestodelete_ nil)
(defglobal _objectstodelete_ nil)

(defun generic? (c) (getobject c 'generic))
(defun get-uses-obj (fn) (getobject (getfunctionnamed fn) 'usesobjects))
(defun get-usbf (fn) (if (null fn) nil 
		       (getobject (getfunctionnamed fn) 'usedbyfunction)))
(defun get-rsl (genfn) 
  (if (not (null genfn))
      (if (listp genfn)
	  (resolvents (car genfn))
	(resolvents genfn))))

(defun clear_usesobjects_at_delete (e)
  "Given object e which is a member of the set of functions to be deleted
   set the relations of the objects used by e to a consistent state."
  (if (not (function_p e))
      (amos-error "Non-function object: " e)) 
  ;; timka: to check if this is a true assumption
  (let* ((ofn (getfunctionnamed (getobject e 'name) t))
	 (usesobj (if (null ofn) nil (getobject ofn 'usesobjects))))
    (if (null usesobj) nil 
      (mapcar (f/l (x) (clear_usedbyfunction_at_delete x e)) usesobj))))

(defun clear_usedbyfunction_at_delete (o fn)
  "Given object o remove fn from the 'usedbyfunction' property of o."
  (if (not (function_p fn))
      (amos-error "Non-function object: " fn)) 
  ;; timka: to check if this is a true assumption
  (let* ((ubf (delete fn (getobject o 'usedbyfunction))))
    (/putobject o 'usedbyfunction ubf)))

(defun deleteobject1 (o types delsubtypes)
  "Marks functions for deletion. If a function is not generic and 
   the set of resolvents for the generic functions for the function is >1 
   then there exits additional resolvents to the one to be deleted 
   and the generic should therefore not be deleted"
  (cond ((memq o _objectstodelete_) nil)
	((<= (oid-idno o) _system-watermark_)
	 (if (not(transientp o))
	     (formatl t "refusing to delete system object: " o t)))
	(t (let* ((notgeno (not (generic? o))) 
		  (useso (get-uses-obj o))
		  (used-by-functions (get-usbf o))
		  (gen (if notgeno	;find the generic function
                           (mapfilter (function generic?) useso)(list o)))
		  (resolvents (get-rsl gen)) ;all resolvents
		  (usesgen (set-difference (get-usbf (car gen)) resolvents))
		  (more-resolvents? (cdr resolvents)) 
		  ;;> 1 resolvent => keep generic
		  (usedbyotodelete 
		   (if more-resolvents? 
		       (remove (car gen) used-by-functions) used-by-functions))
		  (tpes (if types (intersection types (oid-types o))
			  (oid-types o)))
					;        (copy-tree (oid-types o))))
		  pfns)
	     (if (object-typep o _type_)
		 (dolist (st (getobject o 'supertypes))
		   (/putobject st 'subtypes 
			       (remove o (getobject st 'subtypes))))) 
	     (if (and resolvents notgeno) 
		 (/putobject (car gen) 'resolvents (remove o resolvents)))
	     (dolist (x usedbyotodelete)(clear_usesobjects_at_delete x))
	     (setq _fnstorecompile_ (union usesgen _fnstorecompile_))
	     (if (memq o _fnstorecompile_)
		 (setq _fnstorecompile_ (remove o _fnstorecompile_)))
	     (dolist (x useso) (clear_usedbyfunction_at_delete x o))
	     (setq tpes (remove _object_ tpes))
	     (setq _objectstodelete_ (cons o _objectstodelete_))
	     (and (object-typep o _type_) delsubtypes 
		  (dolist (st (getallsubtypes o))
		    (deleteobject1 st nil nil)))
	     (dolist (fn usedbyotodelete)
	       (deleteobject1 fn nil nil))
	     (mapc (f/l (pfno)
			(and pfno (not (memq pfno _objectstodelete_))
			     (some (f/l (tp) (matchtype tp tpes))
				   (get-resolvent-argtypes pfno))
			     (setq pfns (adjoin pfno pfns))))
		   (allrelations))
	     (dolist (fn pfns) 
	       (setq _instancestodelete_ 
		     (nconc 
                      (delpatterns fn o tpes 
				   (get-resolvent-argtypes fn) nil)
                      _instancestodelete_)))
					;if o is a type...
	     (if (object-typep o _type_)
		 ;;del. not the whole dt extent, but only the mat. portion
		 (if (dt_p o)
		     (progn
					;clean after a dt
		       (clean_after_dt o)
					;delete all the objects
		       (mapextent o (function deleteobject1)))
			 
		   (mapfunction (getfunctionnamed 'type.allobjects->object) 
				(vector o) 
				(f/l (key) (deleteobject1 
					    (car key) nil nil)))))))))

(defun deleteobject (o)
  (cond ((null o) o)
	(t (dt_delete_in_subt o)
	   (deleteobject1 o nil t)
	   (dothedelete)
	   (if (not (null _fnstorecompile_))
	       (do* ((fns (append _fnstorecompile_ 
				  (get-pred-fn (gettypenamed 'object)
					       _fnstorecompile_)) 
			  (cdr fns))
		     (recfn (getfunctionnamed (car fns) t)
			    (getfunctionnamed (car fns) t))
		     (idi (if (deleted-object recfn) nil
			    (recompile (car fns)))
			  (if  (deleted-object recfn) nil
			    (recompile (car fns)))))
		   ((null (cdr fns)) (setq _fnstorecompile_ nil)o))
	     o))))

(defun deleted-object (o)(and (oid-p o)(eq (oid-name o) '*deleted*)))

(defun dothedelete nil 
  (let (d)
    (while _instancestodelete_ 
      (setq d (pop _instancestodelete_))
      (/retractrelation (car d) (cdr d))
      )
    (while  _objectstodelete_ 
      (setq d (pop _objectstodelete_))
      (if (relationp d) (/purgerelation d) 
	(/purgeobject d))
      ))) 

(defmacro purge-function (fn)
  `(deleteobject
    (getfunctionnamed
     (quote , fn))))            
      
(defmacro purge-type (tp)
  `(progn 
     (clean_after_uit (quote , tp))
     (deleteobject (gettypenamed (quote , tp)))))

(defmacro delete-object (o)
  (list 'deleteobject
	(osql-interfacevar o)))

(defun clean_after_uit (tp) 
  "Delete the system generated functions associated with and IUT."
  (let ((tpo (gettypenamed tp)))
    (if tpo
	(let (				;delete the subtypes 
	      (st (getobject tpo 'subtypes))
					;delete the extent function
	      (extf (getobject tpo 'extf))
					;delete the inverse key functions
	      (ifuncs (getobject tpo 'ifuncs)))
	  (mapcar  (function deleteobject) (cons extf (append ifuncs st)))))))

(defun clean_after_dt (tp)
  "Delete the system generated function associated with a DT."
  (let ((extT (getobject tp 'extT)))
					;delete the extent template function
    (deleteobject extT)))
    

