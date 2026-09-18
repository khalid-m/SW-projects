;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: typemap.lsp,v $
;;; $Revision: 1.2 $ $Date: 2003/11/27 12:59:45 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: A lisp interface toward the mappings between a wrapped
;;;              datasources' native data types and intended Amos II 
;;;              counterparts, and vice versa
;;;              
;;; ===========================================================================
(defvar _wrapped_type_ (getfunctionnamed 'wrapped_type))
(defvar _amos_type_    (getfunctionnamed 'amos_type))

(defmacro add-amos-type (ds &rest args)
  "Inserts a mapping from a wrapped datasource, ds:s, type name to an Amos 
   type. The argument named :wrapped is the datasource's native data type name,
   strings or symbols accepted, and the argument named :amos is the Amos type
   oid or symbolic name."
  `(add-amos-type-int , ds ,@ (parsekeywordparams args '(:wrapped :amos))))

(defun add-amos-type-int (ds wrapped-type-name amos-type)
  (addfunction _amos_type_
	       (list ds (mkstring wrapped-type-name))
	       (list amos-type)))

(defmacro add-wrapped-type (ds &rest args)
  "Inserts a mapping to a wrapped datasource, ds:s, type name from an Amos 
   type. The argument named :wrapped is the datasource's native data type name,
   strings or symbols accepted, and the argument named :amos is the Amos type
   oid or symbolic name."
  `(add-wrapped-type-int , ds ,@ (parsekeywordparams args '(:wrapped :amos))))

(defun add-wrapped-type-int (ds wrapped-type-name amos-type)
  (addfunction _wrapped_type_
	       (list ds amos-type)
	       (list (mkstring wrapped-type-name))))

(defun wrapped-to-amos-type (ds type-name &optional noerror)
  "Looks up an Amos type associated with the datasource ds:s type name given 
   as a symbol or string. The type oid is returned."
  (let ((answer(caar(getfunction _amos_type_(list ds(mkstring type-name))))))
    (if (and (not answer) (not noerror))
	(error "unknown native data type, possibly not imported" type-name)
      answer)))

(defun amos-to-wrapped-type (ds tp)
  "Looks up a datasource ds:s type name associated with the Amos type, given 
   as a symbol or oid, returned as a symbol."
  (let ((answer (caar (getfunction _wrapped_type_ (list ds (gettypenamed tp))))))
    (if (not answer)
	(error "no correponding native data type found" tp)
      answer)))