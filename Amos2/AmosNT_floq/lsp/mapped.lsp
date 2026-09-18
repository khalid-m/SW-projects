;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 1999 Joern Gebhardt, Tore Risch UDBL
;;; $RCSfile: mapped.lsp,v $
;;; $Revision: 1.32 $ $Date: 2009/11/17 16:46:22 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: - lisp functions for creating mapped types and functions
;;;              - for background see Thesis LiTH-IDA-Ex-99/77 "Integration of 
;;;                Heterogeneous Data Sources with Limited Query Capabilities" 
;;;                by Joern Gebhardt, Sept. 1999
;;;
;;; ===========================================================================
;;; $Log: mapped.lsp,v $
;;; Revision 1.32  2009/11/17 16:46:22  torer
;;; Use of 'in' instead of '='
;;;
;;; Revision 1.31  2009/05/18 19:57:55  torer
;;; New function mapped_functions(Type)->Vector of Function
;;;
;;; Revision 1.30  2009/04/11 12:26:08  torer
;;; Use of CommonLisp's generalized APPLY simplifies dynamic calls to OSQL-RESULT
;;;
;;; Revision 1.29  2008/12/18 21:57:51  torer
;;; Composite key mapped types
;;;
;;; Revision 1.28  2007/02/20 09:21:58  torer
;;; Added dynamic declaration of _DECODE_ as bijective
;;;
;;; Revision 1.27  2006/11/04 16:18:20  torer
;;; Systematically using GET-RESOLVENT-ARGTYPES and GET-RESOLVENT-RESTYPES
;;;
;;; Revision 1.26  2006/04/08 14:19:39  torer
;;; (GET-OC FNO) always used as accessor function for OID property ORGCODE
;;;
;;; Revision 1.25  2006/02/22 20:49:03  torer
;;; Removed superflous function argument
;;;
;;; ===========================================================================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; general functions for mapped types
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun create-mapped-type (typename supertypes propl keys cclusterfctn
				    &optional systemtype earlybound)
  " - Creates a new mapped type named TYPENAME
    - if SUPERTYPES is not provided it become a subtype of UserObject 
    - CCLUSTERFCTN is the name of the core cluster function
    - Creates also the functions for mapping OIDs to key-values 
      and for creating OIDs. (_decode_XXX)
    - PROPL is a list of tupels (property-type property-name) 
      that form the core cluster
    - KEYS is a list of tupels (key-type key-name) the OID 
      gets mapped to (i.e. key types)"
   
  (let (tpo				; the new mapped type  
	(keyvars     (getvars keys))
	(keytypes    (heads keys))
	cclusterfct propl_with_keys extfno)
      
    (setq propl_with_keys (mapcar (f/l (prop)
				       (if (memq (second prop) keyvars)
					   (append prop (list 'key))
                                         prop))
				  propl))
    ;; create mapped type:
    (setq tpo (createtype typename 
			  (if systemtype supertypes 
			    (add-inherit _userobject_ supertypes))
			  _mappedtype_ 
			  nil 
			  nil))
    (/putobject tpo 'properties propl) 
    ;; store type and name of all attributes of mapped type 
    (/putobject tpo 'keys keys) 
    ;; store key type and name of all keys
    (cond (cclusterfctn
	   (setq cclusterfct (getfunctionnamed cclusterfctn))
	   )
	  (t (amos-error "No core cluster function specified")))
    (/putobject cclusterfct 'mappedtype tpo)
    (/putobject cclusterfct 'cclusterfct? T)
    (/putobject tpo 'cclusterfn cclusterfct) 
    ;; relationship between mapped type and core cluster fn
    (create-decode-function typename keytypes)
      
    ;; create all property functions as derived fcts from ccluster_XXX:
    (/putobject tpo 'coreprops (create-mapped-prop-funcs 
				tpo propl keys cclusterfctn earlybound))
      
    ;; create extent-function that returns OIDs:
    (setq extfno (create-extent-fct tpo keys))
    (store-extent-function tpo extfno) 
      
    ;; return mapped type:
    tpo))

(defun mapped-props (tpo)
  "Get core property declarations for mapped type TPO"
  (getobject tpo 'properties))

(defun decodefn (type)
  "Overloaded on all mapped types"
  (get-most-specific-resolvent '_decode_ (list type))) 

(defun create-decode-function (typename keytypes)
  (resetgenvar
   (let* (*locals*
	  (resdecl (mapcar (f/l (tp)(list tp (genvar))) keytypes))
	  (decodefn 
	   (createfunction '_decode_
			   (list (list typename typename)) resdecl
			   'multidirectional
			   `((, (listbpat (append '(-)(buildl resdecl '+)))
				key t foreign "mapped-to-external")
			     (, (listbpat (append '(+)(buildl resdecl '-)))
				key t foreign "external-to-mapped")
			     (, (listbpat (cons '- (buildl resdecl '-)))
				foreign "decoded-ok")))))
     (set-type-container decodefn)	; Decode is always type container!!!
     (setfunction 'bijective_function (list (getfunctionnamed '_decode_))
		  '(true))
     (/putobject (gettypenamed typename) 'decodefn decodefn)
     (set-early-bound decodefn)
     (set-early-bound (generic-function-of decodefn))
     )))

(defun encode-mapped-object (extobj tpo)
  "Convert external object EXTOBJ to transient mapped object of type TPO"
  (let ((new (create-transient-object tpo)))
    (putobject new 'encodes extobj)
    new))

(defun decode-mapped-object (o)
  "Convert mapped object O to the corresponding external object"
  (getobject o 'encodes))

;;; AMOSQL implementations of DECODE: 
(defun external-to-mapped (fno o &rest decodedtuple) 
  "Convert DECODED -> OID"
  (let ((mapped-type (first (get-resolvent-argtypes fno))) ; the type of O
	res)
    (setq res (encode-mapped-object (make-key decodedtuple) mapped-type))
    (if res (apply 'osql-result res decodedtuple))))

(defun mapped-to-external (fno o &rest decodedtuple) 
  "Convert OID -> DECODED"
  (let ((mapped-type (first (get-resolvent-argtypes fno))) ; the type of O
	res)
    (cond (o
	   (setq res (mklist (decode-mapped-object o)))
	   (if res (apply 'osql-result o res))))))

(defun decoded-ok (fno o &rest decodedtuple)
  "Check that O is encoding of decodedtuple with most specific type
   given by type of FNO"
  (let ((mapped-type (first (get-resolvent-argtypes fno))) ; the type of O
	res)
    (and o (eq (arg-type o)mapped-type)
	 (equal (mklist(decode-mapped-object o)) decodedtuple)
	 (apply 'osql-result o decodedtuple))))
   
(defun  create-mapped-type1(typename propnames proptypes keyname 
				     keytype cclusterfctn)
  "Aux. Lisp function for AMOSQL function CREATE_MAPPED_TYPE"
  (let* ((propl (mapcar (f/l (pr) (list (car pr) (cdr pr)))
			(pair (mapcar (f/l (str) (gettypenamed (mksymbol str)))
				      (arraytolist proptypes))
			      (mapcar (function mksymbol) 
				      (arraytolist propnames)))))
	 (keyl (list (list (gettypenamed (mksymbol keytype)) 
			   (mksymbol keyname)))))
    (create-mapped-type (mksymbol typename) nil propl keyl 
			(mksymbol cclusterfctn))))

(defun init-mapped-types ()
  (foreign-lispfn 
   create_mapped_type 
   ((charstring typename) (vector propnames) 
    (vector proptypes) (charstring keyname) (charstring keytype) 
    (charstring cclusterfctn))
   ((type m_type))
   "Create a mapped type"
   (let ((tpo (create-mapped-type1 
	       typename  
	       propnames proptypes keyname keytype cclusterfctn)))
     (if tpo (foreign-result tpo))))
   
  )

; ----------------------------------------------------------------------------

(defun create-mapped-prop-funcs (tpo propl keyl cclustfctn earlybound)
  " - gets called from 'create-mapped-type' and creates the derived 
      property functions from the core-cluster function
    - TPO: user-object-type (i.e. the mapped type)
    - PROPL: list of property tuples (property-type property-name)
    - KEYL: list of key tuples (key-type key-name)
    - CCLUSTERFCTN: name of the core-cluster function"
   
  (let ((keyvars (getvars keyl)))
    ;;create all property functions:
    (mapcar (f/l (property)
		 (let* ((fname (second property))
			;; name of property is name of fct
			(restype (car property))
			;; type of property is result type
			(fno (create-mapped-prop-func 
			      fname restype tpo 
			      propl keyvars cclustfctn)))
		   (if earlybound (set-early-bound (generic-function-of fno)))
		   fno))
	    propl)))

; -----------------------------------------------------------------------------


(defun create-mapped-prop-func (fname restype mtype propl keyvars cclustfctn)
  "creates and returns mapped property function of the following form (e.g.):
    create function name(person p)->charstring as
      select name
      from integer ssn, charstring name, ....
      where ccluster_person() = <ssn, name, ...> and
            _decode_person(p) = ssn;
    PROPL list of tuples (property-type property-name)
    FNAME name of property function
    MTYPE mapped type the property function is defined on
    RESTYPE name of the result type, i.e. type of property
    KEYVARS name of key variables
    CCLUSERFCTN name of the core-cluster fct"
  (let* ((propvars (getvars propl))
 	 (pred (list 'and  
		     (list '= (maketuple propvars)
			   (list 'in (list cclustfctn))
			   )
		     (list '= (list (decodefn mtype) '-MT-) 
			   (maketuple keyvars))))
	 (argtypes (list (list (oid-name mtype) '-MT-)))
	 (restypes (list (list restype)))
	 (resv (list fname))
	 (quant propl))
    (createfunction fname argtypes restypes resv quant pred)))

; ---------------------------------------------------------------------------

(defun create-extent-fct (tp keys)
  "creates the extent fct that returns the OIDs for a mapped type. 
     It has the folowing form (e.g.):
       create function extent_Person() -> Person as
         select p
         from Person p, Integer ssn
         where ssn = SSN(p)
           and _decode_Person(p) = ssn;
   TP mapped type object (e.g. BTPerson)
   KEYS list of tupels (keytype keyname)
   RETURNS extent function object"
  (let ((fnname (extent-function-name tp))
	(keynames (getvars keys))
	pred quant extfno)
    ;;create list of (= keyname (keyname -MT-)) for every key:
    (setq pred (mapcar (f/l (key) (list '= (second key) 
					(list (second key) '-MT-)))
		       keys))
    ;;add (= (_decode_typename -MT-) (tuple . keynames)):
    (setq pred (cons (list '= (list (decodefn tp) '-MT-) 
			   (maketuple keynames)) pred))
    (setq pred (andify pred))

    (setq quant (cons (list (oid-name tp) '-MT-) keys))
					;create extent function:
    (createfunction fnname 
		    nil			; no args
		    (list (list (oid-name tp))) ; result type
		    '(-MT-)		; result var
		    quant
		    pred
		    nil)))

;;;;; AmosQL interface

(foreign-lispfn  
 create_mapped_type 
 ((charstring name)(vector keys)(vector attributes)(charstring ccfn)) 
 ((type))
 "Creates mapped type, given name, keys, attributes, and Core Cluster Function"
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
         ((null (member (functiontype ccfn) '("stored" "foreign")))))
   (create-mapped-type (mksymbol name) nil
		       attrs
		       (mapcar (f/l (k)
				    (or (searchdcl (mksymbol k) attrs)
					(error "Undefined mapped type key" k)))
			       keys)
		       (oid-name ccfn))
   ))

(defun mapped-functions-+ (fno mtpo r)
  (let ((props (getobject mtpo 'coreprops)))
    (if props 
	(osql-result mtpo (listtoarray props))))) 
