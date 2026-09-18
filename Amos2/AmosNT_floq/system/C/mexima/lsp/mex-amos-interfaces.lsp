;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010 Thanh Truong, UDBL
;;; $RCSfile: mex-amos-interfaces.lsp,v $
;;; $Revision: 1.7 $ $Date: 2012/01/05 16:54:17 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: MEXIMA <---> Amos interfaces (AMOSQL)
;;; =============================================================
;;; $Log: mex-amos-interfaces.lsp,v $
;;; Revision 1.7  2012/01/05 16:54:17  thatr500
;;; removed some old cold. To be added new code
;;;
;;; Revision 1.6  2012/01/04 14:50:27  thatr500
;;; - allowed to extend indexing through Foreign function
;;; - add XTree as built-in index
;;;
;;; Revision 1.5  2012/01/02 08:44:55  thatr500
;;; - used default extent if any
;;; - create one extent on a relation in case there are several MEXI indexes
;;;
;;; Revision 1.4  2011/12/28 10:00:15  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.3  2011/12/27 09:44:57  thatr500
;;; organized codes
;;;
;;; Revision 1.2  2011/12/13 09:54:27  thatr500
;;; AMOSQL interfaces
;;;
;;; Revision 1.1  2011/12/02 12:45:11  thatr500
;;; MEXIMA at AMOSQL level
;;;
;;; Revision 1.5  2011/06/25 16:59:09  thatr500
;;; *** empty log message ***
;;;
;;; =============================================================
(defun generate-fn-stubs (indextype redefined)    
  (let* ( (stridxtype (mkstring indextype))
	  (lp (concat "create function ")) 
	  (sig-make   (concat stridxtype "_make"))
	  (sig-put    (concat stridxtype  "_put"))
	  (sig-delete (concat stridxtype "_delete"))
	  (sig-save   (concat stridxtype "_save"))
	  (sig-load   (concat stridxtype  "_load"))
	  (sig-get    (concat stridxtype "_get"))
	  (sig-clear  (concat stridxtype  "_clear"))
	  (sig-mapping (concat stridxtype "_map"))

	  (makep (concat lp  sig-make))
	  (putp  (concat lp  sig-put))
	  (deletep (concat lp sig-delete))
	  (savep (concat lp   sig-save))
	  (loadp (concat lp   sig-load))
	  (getp (concat lp    sig-get))
	  (clearp (concat lp  sig-clear))
	  (mappingp (concat lp sig-mapping))
	  (makefn nil) (putfn nil) (deletefn nil) (getfn nil) 
	  (clearfn nil) (mappingfn nil))

    ;; MAKE
    (setq makefn (getlatestresolvent  (mksymbol sig-make)))
    (cond ((and (eq makefn nil) (eq redefined nil))
	   (setq makefn (amos-execute 
			 (concat makep  
				 "()->Integer as foreign 'not-yet-implfn';")))))
    ;; PUT
    (setq putfn (getlatestresolvent  (mksymbol sig-put)))
    (cond ((and (eq putfn nil) (eq redefined nil))
	   (setq putfn (amos-execute 
			(concat putp   "(Integer extid, Object f,Object o)->Object 
                               as foreign 'not-yet-implfn';")))))
    ;; GET
    (setq getfn  (getlatestresolvent  (mksymbol sig-get)))
    (cond ((and (eq getfn nil) (eq redefined nil))
	   (setq getfn (amos-execute
			(concat getp "(Integer extid, Object o)->Bag of Object 
                              as foreign 'not-yet-implfn';")))))
    ;; DELETE
    (setq deletefn  (getlatestresolvent  (mksymbol sig-delete)))
    (cond ((and (eq deletefn nil) (eq redefined nil))
	   (setq deletefn (amos-execute
			   (concat deletep "(Integer extid, Object f)->Boolean 
                              as foreign 'not-yet-implfn';")))))
    ;; CLEAR (DROP)
    (setq clearfn  (getlatestresolvent  (mksymbol sig-clear)))
    (cond ((and (eq clearfn nil) (eq redefined nil))
	   (setq clearfn (amos-execute		       
			  (concat clearp "(Integer extid)->Boolean 
                              as foreign 'not-yet-implfn';")))))
    ;; MAPPING
    (setq mappingfn  (getlatestresolvent  (mksymbol sig-mapping)))
    (cond ((and (eq mappingfn nil) (eq redefined nil))
	   (setq mappingfn (amos-execute 
			    (concat mappingp "(Integer extid)->Bag of Object 
                              as foreign 'not-yet-implfn';")))))
    (list makefn putfn deletefn  getfn clearfn mappingfn)))

;;-----------------------------------------------------------------------------
(defun unregister_exindextypefn (fno indextype res)
  "If there is an index of such kind which is currently used,
   an error message shall be raised.
   Otherwise, clean all metadata of it "
  (maphash 
   (function (lambda (owner val)
	       (let* ((indexes (relation-indexes owner nil)))
		 (dolist (idx indexes)
		  (cond ((eq (index-type idx) (mksymbol indextype))
			 (error (concat 
				"Error !! This index type is "
				"currently in used in " 
				(stringify-amos-object owner)))))))))
  	   _mexi-objects_))

;;-----------------------------------------------------------------------------
(defglobal _ff-indextypes_ nil)
(defun register-indextype0 (name mansaver redefined) 
  "Register a new index type. It routines (MAKE, GET, PUT, MAP..) is defiend
  as foregin functions"
  (let ((stubs (generate-fn-stubs name redefined))
	res)
    (setq res (register-indextype1 name stubs))
    (if (eq redefined nil)
	(setq _ff-indextypes_ 
	      (nconc1 _ff-indextypes_ (list name mansaver))))
    res))


(defun register-indextypefn (fn name mansaver res) 
  "Register a new index type. It routines (MAKE, GET, PUT, MAP..) is defiend
  as foregin functions"
  (osql-result name mansaver (register-indextype0 name mansaver nil)))
 
(defun reload-ff-indextypes ()
  (mapc (f/l(x)(or (register-indextype0 (first x) (second x) t)
		   (formatl t "WARNING: Index type  " x 
			    " could not be loaded" t))) 
	_ff-indextypes_))

(register-init-form '(reload-ff-indextypes))
;;-----------------------------------------------------------------------------
;; Interface
;;-----------------------------------------------------------------------------
;; Register new index kind
(osql
 "create function register_exindextype(Charstring name, Boolean mansaver)
  /* Register a new external index type with given name.
     - name: index type name
     - mansaver : manually saver. If TRUE, the extender has to save/restore        an index on his own. Amos II shall invoke saving/restoring provided         by the extender.*/
   ->Boolean as foreign 'register-indextypefn';")

(osql
 "create function unregister_exindextype(Charstring name)
   ->Boolean as foreign 'unregister_exindextypefn';")
