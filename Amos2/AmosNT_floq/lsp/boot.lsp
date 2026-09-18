;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1998 Tore Risch, EDSLAB
;;; $RCSfile: boot.lsp,v $
;;; $Revision: 1.48 $ $Date: 2013/12/31 11:28:54 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Amos2 bootstrapping 
;;; =============================================================
;;; $Log: boot.lsp,v $
;;; Revision 1.48  2013/12/31 11:28:54  torer
;;; Initializing communication when image started
;;;
;;; Revision 1.47  2012/10/22 20:14:09  torer
;;; Foreign language (e.g. Python) code automatically loaded when saved in image
;;;
;;; Revision 1.46  2012/04/27 14:21:48  thatr500
;;; introduce variable _arithmetic-date_ to allow do arithmetic operations
;;; with DATE/TIMEVAL. Now, it supports only PLUS, MINUS a duration
;;;
;;; Revision 1.45  2012/03/28 19:05:08  torer
;;; Scalable extent functions
;;;
;;; Revision 1.44  2012/03/28 18:50:38  torer
;;; Scalable type extents
;;;
;;; Revision 1.43  2012/02/14 16:03:58  torer
;;; missing argument
;;;
;;; Revision 1.42  2012/02/14 12:09:58  torer
;;; Type BINARY moved to kernel
;;;
;;; Revision 1.41  2010/12/29 20:26:50  torer
;;; Linking foreign languages when initializing system
;;;
;;; Revision 1.40  2008/08/13 21:14:09  torer
;;; Print function for generators
;;;
;;; Revision 1.39  2008/08/13 07:58:07  torer
;;; Type STREAM separated from core Amos II
;;;
;;; Revision 1.38  2008/05/17 15:00:40  torer
;;; Type checking of vectors turned off by default
;;; To turn it on again:
;;;  (setq _not-typechecked-types_ (list _literal_))
;;;
;;; Revision 1.37  2008/04/03 15:00:49  torer
;;; reopt.lsp depatched
;;;
;;; Revision 1.36  2007/11/20 10:01:05  torer
;;; Partial evaluation turned off during boot
;;;
;;; Revision 1.35  2007/10/24 21:14:54  torer
;;; Code moved to make modules independent
;;;
;;; Revision 1.34  2007/10/19 13:51:57  torer
;;; _coercers_ declared
;;;
;;; Revision 1.33  2006/12/26 16:55:42  torer
;;; Coercion introduced
;;;
;;; Revision 1.32  2006/12/02 15:29:31  torer
;;; Type inference for vector construction
;;;
;;; Revision 1.31  2006/11/24 23:03:38  torer
;;; Datatype STREAM (of type) instroduced
;;;
;;; Revision 1.30  2006/03/21 07:57:28  torer
;;; typesofbb in C
;;;
;;; =============================================================

(defvar *_dtrfunction_*)
(defglobal _number_) ; Type NUMBER first mentioned here.
(defglobal _coercers_)
(defglobal _print-amos-error_)
(defglobal _binary_ nil "Type for BLOBs")

; This variable is set to a dummy function that serve as a holder of 
; selectbodys to execute in dtr+-exec and dtr++exec
(defvar *dtrdummyfndtr*)

(defun object.typesof+- (obj x y)
  (let ((extentfn (getobject y 'extentfn)))
    (cond (extentfn			; explicit extent function
           (mapfunction-apply (theresolvent extentfn) nil
			      (f/l (x)(osql-result x y))))
	  ((null (getobject y 'exportto)) ; local type
	   (mapextent y (f/l (o)(if (not (dt_obj_p o))
				    (osql-result o y))) t))
	  (t (map-query (concat "select x from " (oid-name y) " x;")
			(f/l (tp)(osql-result tp y)))))))

(defun object.typesof-- (obj x y)
  (let ((tc (getobject y 'type-checker)))
    (cond (tc (if (funcall tc x y)(osql-result x y)))
	  ((matcharg x y) (osql-result x y)))))

(defun object.typesof-+ (obj x y)
   (dolist (tp (arg-types x))
      (osql-result x tp)))

(defun typesofcost (obj f bpat args v1 v2)
   (let ((res (typesofcostfn bpat args)))
      (if res (osql-result f bpat args (car res)(cdr res)))))

(defun typesofcostfn (bpat args)
   "Compute (COST . FANOUT) for call (OBJECT.TYPESOF . ARGS)
with  binding pattern BPAT"
   (let (res (o (aref args 0))
          (tp (aref args 1))
          (tpub (eq (aref bpat 1) '+)))
      (cond
            (tpub (cons 1 4))
            ((oid-p tp)
             (cond ((surrogate-type? tp) 
                    (setq res
                      (max 100 (type-cardinality tp)))
                    (cons res res))))
            (t (setq res
                 (type-cardinality _object_))
              (cons res res)) )))

(defmacro undo-effects (form)
   "Evaluate form and rollback afterwards"
   `(let ((save-point _history_))
       (unwind-protect , form)
       (history-rollback save-point)))

(defun create-root-types()
  (make-root-objects)
  (/addtype _object_ _type_)
  (addsupertype _type_ _object_)
  (setq _bootflg_ t)
  (setq _system-watermark_ -1)
   
					; type place holders during boot:
  (setq _storedtype_ (createobject _type_ nil)) 
  (setq _derivedtype_ (createobject _type_ nil))
  (setq _function_ (createobject _type_ nil))
  (setq _relation_ (createobject _type_ nil))

  (setq _bootflg_ nil)

   ;;; Patch place holders:
  (createtype 'storedtype (list _type_) nil nil _storedtype_)
  (putobject _storedtype_ 'types (type-allsupertypes _storedtype_))
  (createtype 'function (list _object_) nil nil _function_)
  (createtype 'relation (list _function_) nil nil _relation_)
  (createtype 'DerivedType  (list _type_) nil nil _derivedtype_)
  (/addtype _type_ _storedtype_)
  (/addtype _object_ _storedtype_)   
   ;;; CREATETYPE now fully functional.
   
  (setq _iuttype_ (createtype 'iut (list _derivedtype_))) 

   ;;; Literals:   
  (setq _literal_ (createtype 'literal (list _object_)))
  (setq _number_ (createtype 'number (list _literal_)))
  (setq _integer_ (createtype 'integer (list _number_)))
  (setq _real_ (createtype 'real (list _number_)))
  (setq _charstring_ (createtype 'charstring (list _literal_)))
  (setq _boolean_    (createtype 'boolean '(literal)))
  (createtype 'bit (list _literal_))	; SQL-99 bitstrings
  ;;; Root of datasources:
  (setq _datasource_ (createtype 'datasource '(object)))
  (setq _amos_ (createtype 'amos '(datasource)))
   ;;; Collections:
  (setq _collection_ (createtype 'collection '(object)))
  (setq _bag_ (createtype 'bag '(collection)))
  (make-parameterized-type _bag_ (function make-bagtype))
  (setq _not-typechecked-types_ (list _literal_ _collection_))
  (setq _vector_ (createliteraltype 'vector (list _collection_)
				    'array #'print-vector 'infer-vectortype))
  (setq _binary_ (createliteraltype 'binary (list _literal_) 'binary nil))
  (setq _invoke-plan_ (createobject _function_ '*invoke-plan*))
  (set-printfn _bag_ 'bag-printfn)
)   

(defun boot ()
  (let (*enable-parteval*) 
    (make-parameterized-type _vector_ (function make-vectortype))

    (setq _=_
	  (createobject 'function 'object.object.=->boolean))

    (setq _typesof_
	  (create-function 
	   typesof ((object))((type)) 
	   as multidirectional (("fb" foreign object.typesof+-)
				("bb" foreign typesofbb) ; in C
				("bf" foreign object.typesof-+))))
   
    (declarecosts 'object.typesof->type '(- -) '(1 0.9)) 
					; Redefined in amosfns.lsp!
   
    (setq _coercers_
	  (create-function coercers
			   ((type t1)(type t2))((function c))))
    (setq *_dtrfunction_* nil)		; to boot dtr (used in test in DTR?)
    (setq *_dtrfunction_*
	  (create-function dtr ((object f) (object o))
			   ((object oo)) 
			   as multidirectional (("bbf" foreign dtr--+)
						("bfb" foreign dtr--+)
						("bff" foreign dtr--+))))
    (setq _select_ (createfunction1 '*select*))
    (setq *dtrdummyfndtr* (create-function dtrdummyfn()((integer))))
   
  ;;;  Objects of type OPAQUE_PROXY are proxies for opaque objects 
  ;;;  imported from other databases.
    (setq _proxy_ (createtype 'opaque_proxy (list _object_)))

    (setq _mappedtype_ (createtype 'mappedtype (list _type_)))
    (setq _proxytype_   (createtype 'proxytype    (list _mappedtype_)))
	;;; external types from realtional data sources
   

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					; user types - subtypes of userobject
    (setq _userobject_ (createtype 'userobject (list _object_)))
   
   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    (register-connect-form '(load-all-foreign-language-functions))

    (setq _print-amos-error_
	  (osql "
create function error(Charstring errmsg,Object errobj)->Boolean
   as foreign 'print-amos-error';"))

    (defun print-amos-error (fno errmsg errobj) (error errmsg errobj))
    (setq _in_
	  (createobject 'function 'Vector.in->object))
    ))

(defun startamos()
   (setq _histflg_ t)
   (setq _system-watermark_ _oidno_))

(defun logging (x)
   "Turn logging ON or OFF"
   (selectq x 
     (on (setq _histflg_ t))
     (off (setq _histflg_ nil))
     (amos-error "Illegal option: " x)))

(defun vector-p (x)(arrayp x))


