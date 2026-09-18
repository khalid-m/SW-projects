;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2008 Tore Risch, UDBL
;;; $RCSfile: unloadschema.lsp,v $
;;; $Revision: 1.3 $ $Date: 2010/09/02 18:04:17 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Schema unloader helping functions
;;; =============================================================
;;; $Log: unloadschema.lsp,v $
;;; Revision 1.3  2010/09/02 18:04:17  torer
;;; Function MEMO-FUNCTION replaces macro CACHE and function MEMO
;;;
;;; Revision 1.2  2008/10/10 17:08:34  torer
;;; Corrected comparison of functions
;;;
;;; Revision 1.1  2008/10/10 09:44:48  torer
;;; Unloader of user schema
;;;
;;; =============================================================

(defvar *objects-in-list*)
(defvar *been-objects-in-list*)

(defun objects-in (fno tpo)
  "Return list of all objects of type TPO found in definition of FNO"
  (let (*objects-in-list* *been-objects-in-list*)
    (oid-objects-in-list1 fno tpo)
    *objects-in-list*))

(defun oid-objects-in-list1 (oid tpo)
  (objects-in-list1 (getselectbody oid) tpo)
  (objects-in-list1 (getobject oid 'bindings) tpo))

(defun objects-in-list1 (l tpo)
  (cond ((consp l)
         (cond ((and (eq (car l) 'call)
		     (symbolp (second l))
		     (not (memq (second l) *been-objects-in-list*)))
		(push (second l) *been-objects-in-list*)
		(objects-in-list1 (getd (second l)) tpo)))
	 (dolist (x l)(objects-in-list1 x tpo)))
	((arrayp l)(maparray l (f/l (x i)(objects-in-list1 x tpo))))
	((not (oid-p l)) nil)
	((and (transientp l)(function-p l)
	      (not (memq l *been-objects-in-list*)))
	 (push l *been-objects-in-list*)
	 (oid-objects-in-list1 l tpo))
	((transientp l) nil)
	((osql-subtypep (arg-type l) tpo) 
	 (setq *objects-in-list* (adjoin l *objects-in-list*)))))

(memo-function (defun functionsIn (fno)
		 "The functions occurring in the definition of OID"
		 (objects-in fno _function_)))

(defun user-supertypes (tpo)
  (subset (supertypes tpo)
	  (f/l (tp)(osql-subtypep tp _userobject_ t))))

(foreign-lispfn functionsIn((Object o))((Function))
		(dolist (fno (functionsIn o))
		  (foreign-result fno)))

(foreign-lispfn clearFunctionsInCache()()
		(clear-memo-function 'functionsIn))

