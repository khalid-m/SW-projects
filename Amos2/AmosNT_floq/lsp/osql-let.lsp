;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1993-2006 Tore Risch, Magnus Werner, EDSLAB, UDBL
;;; $RCSfile: osql-let.lsp,v $
;;; $Revision: 1.11 $ $Date: 2011/12/22 12:55:16 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: AmosQL variable declaration macros
;;; =============================================================
;;; $Log: osql-let.lsp,v $
;;; Revision 1.11  2011/12/22 12:55:16  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.10  2008/08/18 13:02:11  torer
;;; Transactional 'declare'
;;;
;;; Revision 1.9  2006/12/02 13:43:58  torer
;;; Declarations of nested typed collections allowed
;;;
;;; =============================================================


(defvar *vardeclarations* nil)

(defun getdeclaredtype(type)
  "Find type meta-object declared by TYPE"
  (if (listp type)
      (make-param-type-for (car type) (mklist (third type)))
    (gettypenamed type)))

(defmacro osql-declare (type variable)
  "Declare a Lisp variable to be of a specific AMOS type"
  (list 'osql-declarefn (getdeclaredtype type)
	(kwote (osql-interfacevar variable))))

(defmacro osql-undeclare (variable)
  "Remove declaration of Lisp interface variable"
  (list 'osql-undeclarefn (kwote (osql-interfacevar variable))))

(defun osql-undeclarefn (var)
  "Dynamic remove declaration of Lisp interface variable"
  (let ((d (searchdcl var *vardeclarations*)))
    (cond ((null d) nil)
	  (t (/setglobal '*vardeclarations* (remove d *vardeclarations*))
	     t))))

(defun osql-declarefn (type var)
  "Dynamic declaration of value of VAR to value of TYPE"
  (osql-undeclarefn var)
  (/setglobal '*vardeclarations* 
	 (cons (internalize-dcl (list type var)) *vardeclarations*)))

(defmacro osql-declare-vars(dcll)
  "Declare interface variables, called from parser"
  (prognify (mapcar (f/l (dcl) (cons 'osql-declare (internalize-dcl dcl)))
		    dcll)))

(defmacro osql-let (dcl &rest bdy)
  "Declaration and local binding of AMOS and Lisp interface variables"
  (setq dcl (mapcar (f/l (vardecl)
			 (nconc1
			  (butlast vardecl) 
			  (osql-interfacevar (car (last vardecl)))))
		    dcl))
  (setq dcl (substdeclarations dcl))
  `(let ((*vardeclarations* (append (quote ,dcl) *vardeclarations*))
	 ,@(getvars dcl))
     ,@bdy))

(movd 'osql-let 'osql-dcl)
