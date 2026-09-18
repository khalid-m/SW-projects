;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2000 Tore Risch, UDBL
;;; $RCSfile: createuobj.lsp,v $
;;; $Revision: 1.10 $ $Date: 2008/12/05 12:55:22 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Implementation of CREATE-USEROBJECT, ADD-TYPE and REMOVE-TYPE
;;; statements
;;; =============================================================
;;; $Log: createuobj.lsp,v $
;;; Revision 1.10  2008/12/05 12:55:22  torer
;;; Transactional variable assignments in create object
;;;
;;; Revision 1.9  2008/10/01 17:38:19  torer
;;; Readable error message when creating object with illegal interface variable
;;;
;;; Revision 1.8  2006/11/04 16:18:19  torer
;;; Systematically using GET-RESOLVENT-ARGTYPES and GET-RESOLVENT-RESTYPES
;;;
;;; =============================================================

(defmacro create-userobjects (type propfns settings &optional addtype)
  "Compile CREATE-USEROBJECT or ADD-TYPE (if ADDTYPE=T) statement"
  (let* ((tpo (gettypenamed type))
	 (constructor (getobject tpo 'constructor)))
    (if constructor
	(call-constructors type constructor propfns settings)
      (cond ((null settings)
	     (list '/createobject tpo nil))
	    (t (let ((resolvents 
		      (mapcar
		       (f/l (fn)
			    (get-most-specific-resolvent fn (list tpo)))
		       propfns)))
		 (compileinstances tpo resolvents settings addtype nil)))))))

(defun amosql-interfacevarname (x)
  (cond (*local-scoping* x)
        (t (pack ': x))))

(defun compileinstances (tpo resolvents settings addtype objv)
  "Compile body of CREATE-USEROBJECT or ADD-TYPE statement"
  (let (res theobjflg (thisv (amosql-interfacevarname 'this-)))
    (dolist (s settings)
      (cond ((atom s);; variable assignment ... :a (p1, p2, p3)
             (and (not *within-proc*)
                  (not (keywordp s))
		  (error "Not an interface variable" s)) 
	     (setq objv s)
	     (setq res (compileemptycreate tpo (compile-substosqlvars objv)
					   addtype res)))
	    ((not (= (length s)(length resolvents)))
	     (amos-error "Instance properties have length " (length s)
			 " while initializer function list has " 
			 (length resolvents)))
	    (t (cond ((null objv)
		      (setq objv thisv)
		      (setq res (compileemptycreate 
				 tpo 
				 (compile-substosqlvars objv) 
				 addtype res))
		      (setq theobjflg t)))
	       (mapc (f/l (fno setting) 
			  (setq res (nconc (compilefunsettings 
					    fno (list objv) setting) 
					   res))) 
		     resolvents s)
	       (setq objv nil))))
    (setq res (cons nil res))
    (setq res (nreverse res))
    (if theobjflg (list* 'osql-let (list2 tpo thisv) res)
      (prognify res))))

(defun compileemptycreate (tpo objv addtype res)
  "Compile object creation of type addition"
  (if objv 
      (cons (if addtype (list 'checked-addtype objv tpo)
	      (list 'assign-variable objv 
		    (list '/createobject tpo nil)))
	    res)
    res))

(defun compilefunsettings (fno key vallist)
  "Compile function initialization"
  (cond ((null vallist) nil)
	((and (listp vallist) 
	      (eq (car vallist)'bag));; expand bag
	 (mapcan (f/l (bagel)
		      (compilefunsettings fno key bagel)) 
		 (cdr vallist)))
        ((tuplep vallist);; tuple result
	 (list (list 'add-function (oid-name fno) 
		     key (cdr vallist))))
	(vallist (list (list 'add-function (oid-name fno) key 
			     (list vallist))))))

(defmacro add-type (tpe &rest settings)
   "Compile add type statement"
   (let (initfns)
      (if (listp
            (car settings))
         (setq initfns (pop settings)))
      (list 'create-userobjects tpe initfns settings t)))

(defmacro remove-type (tpe &rest ol)
   "Compile remove type statement"
   (list 'removetype1
     (cons 'list
       (mapcar
         (function osql-interfacevar)
         ol))
     (list 'gettypenamed
       (list 'quote tpe))))

(defun removetype1 (objl tpo)
   (dolist (obj objl)
      (let ((oldtypes
              (oid-types obj))
            toremove)
         (cond ((not (memq tpo oldtypes))
                nil)
               (t (dolist (t1 oldtypes)
                     (if (memq tpo
                           (getobject t1 'allsupertypes))
                        (setq toremove
                          (cons t1 toremove))))
                 (/remtypes obj toremove)
                 (dolist (pfn (predicatefunctionsusingtypes toremove))
                    (removefrompfn obj pfn toremove)))))))

(defun predicatefunctionsusingtypes (types)
   (let (pfns)
      (dolist (pfno (allrelations))
         (if pfno
            (if (some
                  (function
                    (lambda (tp)
                      (memq tp types)))
                  (get-resolvent-argtypes pfno))
               (setq pfns
                 (adjoin pfno pfns)))))
      pfns))

(defun removefrompfn (obj pfn tpes)
   (dolist
       (dp (delpatterns pfn obj tpes
             (get-resolvent-argtypes pfn)
             nil))
      (/retractrelation
        (car dp)
        (cdr dp))))

(defun delpatterns (fn o tpes argtypes head)
   (cond
         ((null argtypes)
          nil)
         ((matchtype
            (car argtypes)
            tpes)
          (cons
            (cons fn
              (nconc2
                (reverse head)
                (cons o
                  (buildn
                    (ilength
                      (cdr argtypes))
                    '*))))
            (delpatterns fn o tpes
              (cdr argtypes)
              (cons '* head))))
         (t (delpatterns fn o tpes
              (cdr argtypes)
              (cons '* head))))) 
