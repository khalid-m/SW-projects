;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1993 Staffan Flodin, Tore Risch, EDSLAB
;;; $RCSfile: typecheck.lsp,v $
;;; $Revision: 1.100 $ $Date: 2013/11/07 19:44:04 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Basic AmosQL typechekcking
;;; =============================================================
;;; $Log: typecheck.lsp,v $
;;; Revision 1.100  2013/11/07 19:44:04  torer
;;; No coercion bag -> Bag
;;;
;;; Revision 1.99  2012/04/13 12:29:11  torer
;;; Circular references removed
;;;
;;; Revision 1.98  2012/02/22 16:49:46  torer
;;; Nicer printing of subplan signatures
;;;
;;; Revision 1.97  2012/02/22 14:01:09  torer
;;; Could not PC transients
;;;
;;; Revision 1.96  2012/02/21 07:29:37  torer
;;; Added some on-line documentation
;;;
;;; Revision 1.95  2012/02/11 16:39:30  torer
;;; pc("*select*"); did not work
;;;
;;; Revision 1.94  2012/01/15 12:03:14  torer
;;; Revert
;;;
;;; Revision 1.93  2012/01/15 11:58:18  torer
;;; Nicer messages
;;;
;;; Revision 1.92  2012/01/14 14:30:03  torer
;;; Nicer error messages
;;;
;;; Revision 1.91  2011/12/22 15:48:10  torer
;;; Mior core reorganization
;;;
;;; Revision 1.90  2011/12/22 12:55:17  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.89  2011/12/14 20:06:07  torer
;;; Added warnings for coersions
;;; Removed coresion storage leak
;;;
;;; Revision 1.88  2011/10/05 17:30:03  torer
;;; Bag of <...> -> Bag of (...) in error message
;;;
;;; Revision 1.87  2011/03/13 17:51:13  torer
;;; Bug fixed in coercion of bagged argument
;;;
;;; Revision 1.86  2011/01/27 12:52:39  torer
;;; New signature format
;;;
;;; Revision 1.85  2011/01/27 12:49:30  torer
;;; Print tuples as (...)
;;;
;;; Revision 1.84  2011/01/21 08:04:19  torer
;;; More robust BAG-TYPE?
;;;
;;; Revision 1.83  2011/01/14 16:53:53  torer
;;; Nicer resolve error message
;;;
;;; Revision 1.82  2011/01/14 16:39:07  torer
;;; Nicer resolve error message
;;;
;;; Revision 1.81  2011/01/14 16:04:22  torer
;;; Nicer resolve error message
;;;
;;; Revision 1.80  2011/01/09 16:39:34  torer
;;; resulttypesfn can be put on generic function if used by all resolvents
;;;
;;; Revision 1.79  2010/08/27 07:49:57  torer
;;; Type inference of {} in function arguments
;;;
;;; Revision 1.78  2010/01/20 20:12:57  torer
;;; (SET-NO-EXTENT TPO) indicates that extent of type TPO cannot be queried
;;;
;;; Revision 1.77  2010/01/06 15:28:20  torer
;;; (FUNCTION-SIGNATURE FNO) and (TYPE-SIGNATURE TPO) introduced
;;;
;;; Revision 1.76  2009/12/30 19:42:53  torer
;;; More readable typing error messages
;;;
;;; Revision 1.75  2009/12/09 20:03:10  torer
;;; Nicer resolvent error printing
;;;
;;; Revision 1.74  2009/12/09 19:42:59  torer
;;; Bag coercion in RESOLVEARGS
;;;
;;; Revision 1.73  2009/11/12 17:58:48  torer
;;; (FUNCTION-EXACTRESULTTYPES FNO ARGS) returns the exact (non-coerced) result types
;;; in a function call
;;;
;;; Revision 1.72  2009/11/10 10:30:55  torer
;;; pc("*select*") did not work
;;;
;;; Revision 1.71  2009/11/02 18:18:29  torer
;;; Bug in type checking of bag valued aggregation functions
;;;
;;; Revision 1.70  2009/04/03 11:09:43  torer
;;; Turn off subtype chekcing in add-type with _checked-addtype_
;;;
;;; Revision 1.69  2008/12/27 21:04:35  torer
;;; Extra argument in call to function-resulttypesfn removed
;;;
;;; Revision 1.68  2008/11/30 16:34:49  torer
;;; Could not print signature when ambigous result types
;;;
;;; Revision 1.67  2008/11/23 18:57:32  torer
;;; Better error message
;;;
;;; Revision 1.66  2008/11/23 17:04:33  torer
;;; File position printed at errors
;;;
;;; Revision 1.65  2008/11/23 15:00:27  torer
;;; Stricter type checking
;;;
;;; Revision 1.64  2008/11/18 21:01:42  torer
;;; OSQL-BAGTYPEP -> BAG-TYPE?
;;;
;;; Revision 1.63  2008/11/17 20:25:32  torer
;;; Initializing *bindings*
;;;
;;; Revision 1.62  2008/11/11 07:46:12  torer
;;; Stricter checking of conformance with result types in function definitions
;;; Can be turned off with
;;;    (setq _strict-resulttypes_ nil)
;;;
;;; Revision 1.61  2008/02/07 13:17:53  torer
;;; Coersion of tuple valued functions to vectors
;;;
;;; Revision 1.60  2007/10/24 21:14:55  torer
;;; Code moved to make modules independent
;;;
;;; Revision 1.59  2007/05/29 19:23:05  torer
;;; Empty type inference result => Default result type
;;;
;;; Revision 1.58  2007/02/01 15:49:30  torer
;;; Better comment for CREATELITERALTYPE
;;;
;;; Revision 1.57  2007/01/07 01:31:55  torer
;;; Bug in coerced function result
;;;
;;; Revision 1.56  2006/12/30 20:40:17  torer
;;; Memory leak
;;;
;;; Revision 1.55  2006/12/26 16:55:42  torer
;;; Coercion introduced
;;;
;;; Revision 1.54  2006/12/14 18:20:29  torer
;;; Moved all code to define type STREM to stream.lsp
;;; Moved all code to define type VECTOR to vector.lsp
;;;
;;; Revision 1.53  2006/12/06 22:31:49  torer
;;; Strict typing of vector constructors in queries
;;;
;;; Revision 1.52  2006/12/05 20:47:42  torer
;;; Cosmetics
;;;
;;; Revision 1.51  2006/12/03 22:04:52  torer
;;; Made OK-ARGTYPE and OK-RESTYPE understandable
;;;
;;; Revision 1.50  2006/11/04 17:08:16  torer
;;; Transparent GET-RESOLVENT-ARGTYPES and GET-RESOLVENT-RESTYPES for both
;;; regular functions and TBR functions
;;;
;;; Revision 1.49  2006/11/04 16:18:21  torer
;;; Systematically using GET-RESOLVENT-ARGTYPES and GET-RESOLVENT-RESTYPES
;;;
;;; Revision 1.48  2006/06/08 21:25:58  torer
;;; Possibility to choose between optimizing top level or including transients
;;;
;;; Revision 1.47  2006/04/29 17:32:32  torer
;;; More general nested expressions in procedures
;;;
;;; Revision 1.46  2006/04/27 19:18:27  torer
;;; Removed unused functions
;;;
;;; Revision 1.45  2006/04/10 11:30:23  torer
;;; Variable binding context introduced (BINDING-CONTEXT bnd)
;;;
;;; =============================================================

(defglobal *enable-coercers* t "Enables use of coersers")

(defglobal _strict-restypes_ t "Checking result type matching")

(defglobal _checked-addtype_ t "Enable checking for add type only to subtypes")

(document resolvename 
	  "(extfn RESOLVENAME (FN ARGL RESL)...)
   returns the resolvent of applying FN on argument tuple ARGL.
   Generates an error if function cannot be resolved.
   if RESL!=NIL then the system also checks the result types")

(defun subtypes(type) 
  "List of immediate subtypes of TYPE"
  (getobject type 'subtypes))

(defun supertypes (type)
  "List of immediate supertypes of TYPE" 
  (getobject type 'supertypes))

(defun createusertype (name supertypes &optional kind-of-type subtypes oid)
  "Create user type named NAME with list of supertypes SUPERTYPES
   KIND-OF-TYPE is meta-type to which new type belongs (default STOREDTYPE).
   SUBTYPES are optional subtypes.
   OID is optional preallocated OID to be coerced into the new object."
  (createtype name 
	      (if supertypes (get-usertypes supertypes)
		(list _userobject_))
	      kind-of-type
	      subtypes
	      oid))

(defun get-usertypes (typel)
  "Check and retrieve the supertypes of a user defined type"
  (cond ((null typel) nil)
	((atom typel)(amos-error "Supertypes not list: " typel))
	(t (mapcar (f/l (x)
			(let ((tpo (gettypenamed x)))
			  (if (ut_p tpo) tpo 
                            (amos-error "Not a user type: " tpo))))
		   typel))))

(defun get-metatype (type)
  "Check and retrieve a meta type object"
  (if (null type) _storedtype_
    (let ((tpo (gettypenamed type)))
      (if (osql-subtypep tpo _type_) tpo
	(amos-error "Not a meta-type object: " type)))))

(defun createtype (name supertypes &optional kind-of-type subtypes oid)
  "Create type meta-object named NAME with list of supertypes SUPERTYPES
   USERTYPE = T => User defined type.
   KIND-OF-TYPE:  The type meta-object containing the new type
   SUBTYPES: optional list of subtypes
   OID: preallocated OID to hold the new meta-object"
   
  (assert name "Types must have names!")
  (let (obj st tpl
	    (oobj (gettypenamed name t))
	    (tp-kind (get-metatype kind-of-type)))
    (if oobj (amos-error "Type " NAME " already defined"))
    (cond (oid	;;; change old OID to be the new type object
	   (setq obj oid)
	   (/putobject obj 'types (type-allsupertypes tp-kind))
	   (if name (set-oid-name obj name)))
	  (t (setq obj 
		   (/createobject tp-kind name))))
    (dolist (stn supertypes)
      (setq st (gettypenamed stn nil))
      (and (not (eq tp-kind _derivedtype_))
	   (boundp '*validate_l*)	; nil during boot
           (dt_p st)
	   (amos-error "Non-derived subtype " obj " for derived type: " st))
      (or _bootflg_ (addsupertype  obj st))
					;   (bp ct) CT unbound!!!
      (dolist (sst (getobject st (quote allsupertypes)))
	(/addobject obj (quote allsupertypes) sst)
	))
    (setq tpl  (cons obj (type-allsupertypes obj))) 
    ;; to save event in history list
    (putobject obj 'allsupertypes tpl)	; not logged
    (/putobject obj 'allsupertypes (sort-types tpl)) ; logged
    (dolist (sbt subtypes)
      (let ((ast (getobject obj  'allsupertypes))
	    (sbto (gettypenamed sbt)))
	(addsupertype  sbto obj)
	(dolist (ost ast)
	  (/addobject sbto (quote allsupertypes) ost))))
    obj))

(defun add-inherit (root types)
  "Add type ROOT to TYPES in case none of them inherit from ROOT
    TYPES can be type OIDs or names, 
    where names are replaced with corresponding OIDs"
  (let ((tpl (gettypesnamed types))) 
    (if (some (f/l (tp)(osql-subtypep tp root)) tpl) tpl
      (adjoin root tpl))))

(defun sort-types (tpl) 
  "Sort types TPL with lower types before higher types"
  (csort tpl (function osql-subtypep)))

(defun subtype-of (c2 c1 &optional andequal)
  "If C1 and C2 are types then T is returned if C2 is subtype of C1.
   If C1 and C2 are lists of types then T is returned if all types in C2 are
   subtypes of C1."
  (cond ((null c2) nil)
	((null c1) nil)
	((and andequal (equal c1 c2)) t)
	((and (listp c2)(listp c1))
	 (if (eq (length c2)(length c1))
             (do* ((tl1 c1 (cdr tl1))
                   (tl2 c2 (cdr tl2))
                   (onlyequals t onlyequals)
                   (result (or (equal (car tl2)(car tl1))
                               (if (subtype-of (car tl2)(car tl1) andequal)
				   (progn (setq onlyequals nil) t)))
			   (or (equal (car tl2)(car tl1))
			       (if (subtype-of (car tl2)(car tl1) andequal)
				   (progn (setq onlyequals nil) t)))))
		 ((or (null result)(null (cdr tl1))) 
		  (and result (not onlyequals)))) nil))
	((listp c1) nil)
	((listp c2) nil)
	(t (subtype-of1 c2 c1 andequal))))

(defun subtype-of1 (c2 c1 &optional andequal)
  "Is C2 subtype of C1?"
  (cond ((eq c1 _OBJECT_) t)		;everything is subtype to object
	((or (null c2) (null c1)) nil)
	((eq c2				;supertypes of c2
	     (if (listp c1) (car c1) 
               c1))
         andequal);;c1=c2 -> nil if andequal flag is nil, strict subtype-of
	(t (do ((supertypes-of-c2 (getobject c2 'allsupertypes)
				  (cdr supertypes-of-c2))
		(cone (if (listp c1) (car c1) c1) cone))
	       ((or (null (cdr supertypes-of-c2)) 
		    (eq cone (car supertypes-of-c2)))
		(eq cone (car supertypes-of-c2)))))))

(defun resolvents (fn)
  "Get the resolvent of function FN"
  (cond ((null (oid-p fn)) nil)
        (t (getobject fn 'resolvents))))

(defun resolvents1 (fno)
  (cond ((resolvents fno))
        ((getobject fno 'selectbody) (list fno))))

(defun ambigous-resolvents? (rl) 
  (and (listp rl)(listp (car rl))
       (< 1 (length (car rl)))))

(defun addresolvent (fno rfn argtypes restypes)	
  ;;fno=name or =rfn, rfn=resolvent
  (let ((r (getobject fno 'resolvents)) 
	r1);;r=all resolvents never called if rfn exists
    (if (not (eq fno rfn))(progn (addfunctionsusing fno rfn) 
				 (addfunctionsusing rfn fno)))  
    ;;adds to usedbyfunction and usesobject props
    (set-resolvent-types rfn  
			 (mapcar (function dcl-type)  argtypes)  
			 ;;dcl-type(x)=car(x), overloads on
			 (mapcar  (function dcl-type)  restypes)) ;first arg
    (cond ((memq rfn r));;is there a resolvent rfn in list of resolvs r?
          ((and (transientp rfn)(eq rfn rfn));; avoid circular reference
	   nil)
	  ((null r)(set-resolvents fno  (list rfn))) 
	  ;;arent there any resolvents ?
	  (t (set-resolvents fno (mergel r (list rfn) 
					 (function compareresolvents))))) 
    rfn))

(defun set-resolvent-types (rfn argtypes restypes)
  (addfunctionsusing rfn argtypes)
  (addfunctionsusing rfn restypes)
  (/putobject rfn 'argtypes argtypes)
  (/putobject rfn 'restypes restypes)
  rfn)

(defun set-resolvents (fno resolvents)
  "Assign list of RESOLVENTS to FNO"
  (/putobject fno 'resolvents resolvents))	

(defun getresolvent (fno atl &optional errorflg)
  "Get the resolvent of the generic function FNO, given the list of
   exact matching argument types ATL. 
   ERRORFLG != nil => generate error if resolvent not found"
  (cond ((car (isome
	       (resolvents fno)
	       (f/l (resolv)
		    (equal atl (get-resolvent-argtypes resolv))))))
	(errorflg
	 (amos-error "Function " (function-signature fno)
		     " not defined for argument types " atl))))
 
(defun getuniqueresolvent (fn &optional type)
  "Get unique resolvent of Amos function FN"
  (let ((fno (getobjectnamed fn _function_ nil)))
    (cond (type (getresolvent fno (list (gettypenamed type))))
	  ((cdr (resolvents fno))
	   (amos-error fn " defined for more than one type"))
	  (t (car (resolvents fno))))))

(defun make-resolventname (name argtypes restypes1)
  "Generate name of resolvent, given generic function NAME,
   argument types ARGTYPES, and result types RESTYPES"
  (let* ((argtypenames (mapcar (function getnameoftype) argtypes))
	 (restypes (if (null restypes1) (list _boolean_) restypes1))
	 (restypenames (mapcar (function getnameoftype) restypes))
	 (initname "")
	 (flag 0))
    (mapcar (f/l (x)(setq initname (concat initname (concat x ".")))) 
	    argtypenames)
    (setq initname (concat initname (concat name "->")))
    (mapcar 
     (f/l (x)
          (if (= flag 0)
	      (progn (setq flag 1) (setq initname (concat initname x)))
	    (setq initname (concat initname (concat "." x))))) restypenames)
    (mkatom initname))) 

(defun make-resolventname-dcl (name argdcl resdcl)
  "Generate resolvent name, given generic name NAME,
   argument declarations ARGDCL, and result declarations RESDCL"
  (make-resolventname name (gettypes argdcl)
		      (gettypes resdcl)))

(defun getnameoftype (tp)
  "Get the name of a type object"
  (cond ((symbolp tp)
	 tp)
	((oid-name tp))
	(t (amos-error "There is no name of type object" tp ))))

(defun resolve-error (fno argtypes restypes argl)
  "Error in resolving a function call"
  (let* ((gfn (or (generic-function-of fno t) fno))
	 (msg (concat 
	       (function-signature1 
		fno argtypes 
		(and (unambigous-restypes restypes) restypes))
               _CR_
	       "Resolvents for " (oid-name gfn) ":"
	       (function-signatures (resolvents gfn)))))
    (error "Cannot resolve function call" msg)))

(defun function-signature (fno)
  "Construct function signature of resolvent"
  (function-signature1 fno (get-resolvent-argtypes fno)
		       (function-exactresulttypes fno nil)))

(defun function-signature1 (fno argtypes restypes)
  "Construct function sigtnature given its arguments and results"
  (let ((nm (or (generic-fnname fno t) (oid-name fno))))
    (concat (if (or (stringp nm)(symbolp nm)) (string-downcase nm)"<subplan>")
	    "(" (if argtypes (stringify-typel argtypes "" "") "") ")"
	    (if (null restypes) ""
	      (concat "->"
		      (stringify-typel restypes))))))

(defun function-dynargtypes (fno argl)
  "Get the dynamic result types of FNO called with arguments ARGL"
  (if (function-resulttypesfn fno) (mapcar (function arg-type) argl)
    (get-resolvent-argtypes fno)))

(defun function-signatures (fnl)
  "Construct string for printing list of function signatures" 
  (apply 'concat 
	 (mapcan (f/l (fno)
		      (list _CR_
			    (function-signature fno)
			    (if (abstract-functionp fno) " (abstract)" "") 
			    )) 
		 fnl)))

(defun abstract-functionp (fno)
   "Is FNO an abstract function?"
   (eq (get-foreign-lispfn fno t) 'abstract-function))

(defun mkfunsig (fno delim argl resl)
  "Construct a function signature string"
  (let ((argl1 (or (listp (car argl))argl))
        (resl1 (if (listp (car resl)) nil resl)))
    (setq argl1 (externalize argl1))
    (setq resl1 (externalize resl1))
    (let ((str (opentextstream)))
      (cond ((and (null resl1) (eq fno _tupletag_))
	     (prinargl argl1 str t))
	    (t (princ (string-downcase (externalize fno)) str)
	       (prinargl (key-list argl1) str)
	       (cond (resl (princ delim str)
			   (prinargl (key-list resl1) str t)))))
      (textstreamstring str))))

(defun stringify-typel (l &optional b e)
  (cond ((atom l) (type-signature l))
	((null (cdr l)) (type-signature (car l)))
	(t (concat (or b "(")
		   (concatl  l "," (function type-signature)) 
                   (or e ")")))))
  
(defun type-signature (tpo)
  "Stringify type TPO"
  (and (type-p tpo)(stringify-decoded-type (decode-type tpo))))

(defun stringify-decoded-type (dtpo)
  "Stringify decoded type description DTPO"
  (cond ((atom dtpo) (string-capitalize dtpo))
        ((cddr dtpo)
	 (concat (stringify-decoded-type (car dtpo)) " of ("
		 (concatl (cdr dtpo) "," (function stringify-decoded-type))
		 ")")) 
        (t  (concat (stringify-decoded-type (car dtpo)) " of " 
		    (stringify-decoded-type (cadr dtpo))))))

(defun prinargl (l str &optional resflg)
  "Print a function argument list L in stream STR"
  (cond ((not resflg) (print-tuple1 "(" ")" l str))
	((cdr l) (print-tuple1 "(" ")" l str))
	(t (print-tuple1 "" "" l str))))

(defun compareresolvents (x y);; seems incorrect
  (let ((rtx (car (get-resolvent-argtypes x)))
	(rty (car (get-resolvent-argtypes y))))
    (> (length (if rtx (getobject rtx 'allsupertypes)))
       (length (if rty (getobject rty 'allsupertypes))))))

(defun type-of-most-spec-resolvntl (arg-type list-of-resolvents)
  "returns the type of the most specific resolvent
   ARG-TYPE may be atomic or list of types"
  (let ((resolvents list-of-resolvents)
	(types (get-resolvent-argtypes (car list-of-resolvents)))
	(spec-type
	 (if (subtype-of (get-resolvent-argtypes (car list-of-resolvents))
			 arg-type)
	     (get-resolvent-argtypes (car list-of-resolvents))
	   arg-type)))
    (while (cdr resolvents)
      (pop resolvents)
      (setq types (get-resolvent-argtypes (car resolvents)))
      (if (subtype-of types spec-type) (setq spec-type types)))
    spec-type))

(defun arglist-types (argl)
  "Get the list of types in arguments of a function call"
  (mapcar (function arg-type) argl))

(defun most-specific-type (tpl)
  "Get the most specific type in type list TPL"
  (car tpl))

(defun all-possible-argtypes(fn)
  "Construct list of all possible argument types of FN"
  (let* ((genfn (getfunctionnamed fn))
	 (resolvents (resolvents genfn))
	 (argtypes (unique (mapcar (f/l (x) (get-resolvent-argtypes x)) 
				   resolvents))))
    (if (= (length argtypes) 1) (car argtypes) argtypes)))

(defun function-resulttypesfn (fno)
  "Get the type inference function of FNO"
  (and (oid-p fno) (or (getobject fno 'resulttypesfn)
                       (let ((gfn (generic-function-of fno t)))
                         (if gfn (getobject gfn 'resulttypesfn))))))

(defun set-resulttypesfn (fno lfn)
  "Define user defined result types inference function"
  (/putobject fno 'resulttypesfn lfn))

(defun function-resulttypes (nf &optional booleantoo)
  "Get the static result types of function NF"
  (let ((x (if (listp nf) (car nf) nf)) res)
    (setq res
	  (cond ((eq x 'and) nil)
		((eq x 'or) nil)
		((dtr? (getfunctionnamed x t))
		 (function-resulttypes (first-function-in-dtr nf)))
		(t (all-possible-resulttypes nf))))
    (cond ((null booleantoo) res)
	  ((null res) (list _boolean_))
	  (t res))))

(defun function-dynresulttypes (fno args &optional booleantoo)
  "Get the dynamic result types of FNO with argument list ARGS"
  (let ((rtf (function-resulttypesfn fno)))
    (cond ((and rtf (funcall rtf fno args)))
          ((null (oid-p fno)) nil)
          (booleantoo (getrestype fno))
	  (t (get-resolvent-restypes fno)))))

(defun function-exactresulttypes (fno args)
  "The full actual result types of FNO for arguments ARGS"
  (let ((rtl (function-dynresulttypes fno args t)))
    (if (has-bagged-result fno)
	(list (make-bagtype rtl))
      rtl)))

(defun all-resulttypes (fnl args &optional exact)
  (mapcar (f/l (fno) (if exact (function-exactresulttypes fno args)
		       (function-dynresulttypes fno args nil)))
	  fnl)) 

(defun all-possible-resulttypes(form &optional exact)
  (let* ((fn (if (listp form) (car form) form))
					;fn is a list->several poss fns
	 (args (and (listp form)(cdr form)))
         (genfn (if (listp fn) nil (getfunctionnamed fn t)))
	 (resolvents (if (null genfn) nil (resolvents1 genfn)))
	 (allresulttypes 
	  (if (listp fn) (all-resulttypes fn args exact)
	    (all-resulttypes resolvents args exact)))
	 (resulttypes (unique allresulttypes)))
    (if (= (length resulttypes) 1);;generic valid test if
	(car resulttypes) resulttypes)));; dtr not used as lateb

(defun unique-any (nf)
  (if (atom nf) t (atom (car nf))))

(defun unique-fn (nf)
  (cond ((atom nf)(getfunctionnamed nf t))
	((atom (car nf))(getfunctionnamed (car nf) t))))

(defun no-fn (args)
  (or (null args)(atom args)
      (atom (car args))
      (osql-constantp (car args))))

(defun make-expr(e a) 
  (if (< 1 (length e)) (mapcar (f/l (x) (cons x a)) e)
    (append e a)))

(defun map-over-types(y rest)
  (mapfilter (f/l (z)
		  (let ((fnrest (function-resulttype y)))
		    (or (equal fnrest (car z))
			(subtype-of (car z) fnrest)))) rest (f/l (x) y)))

(defun add-bindings-separately (vars tps)
  (cond ((or (null vars) (null tps)) *bindings*)
	(t (addbinding (car vars) nil (car tps))
	   (add-bindings-separately (cdr vars) (cdr tps)))))

(defun resolveargs (genfn argl restypes)
  "Compute resolvent of GENFN, given flat argument list ARGL
   and optional required result types RESTYPES"
  (if (and (not (generic? genfn)) (applicable? genfn argl)) genfn
    (let* ((restypesl (mklist restypes))
	   (argtypes (arglist-types argl))	
	   (res (resolvents-with-arity (length argtypes)
				       (resolvents genfn)))
	   (poss1 (combine-signatures genfn argtypes restypesl res argl nil))
           (poss2 (or poss1 (combine-signatures genfn 
						argtypes restypesl res argl
                                                t)))
	   (poss (if (cdr poss2)
		     (remove-general-resolvents poss2) 
		   poss2))
	   (result (cond ((null poss)	
			  (resolve-error genfn argtypes restypesl argl))
			 ((null (cdr poss)) 
                          (if (null poss1) 
			      (add-coercion argl argtypes (car poss))
			    (car poss)))
			 (t  (error "Ambiguous resolvents" 
				    (function-signatures poss))))))
      result)))

(defun get-most-specific-resolvent (fn types)
  "Resolve generic function FN given list of argument types"
  (let ((fno (getfunctionnamed fn))
	(tpl (mapcar (function gettypenamed) types))
	(vars (buildargl types 0))
	(*bindings* *bindings*))
    (mapc (f/l (v tp)(addbinding v nil tp)) vars tpl)
    (resolveargs fno vars nil)))

(defun remove-general-resolvents (lor)
  "Remove the resolvents in LOR that are more general than other 
   resolvents in LOR"
  (cond ((null (cdr lor)) lor)
	((isome (cdr lor)(f/l(r)(more-specific-resolvent? r (car lor))))
	 (remove-general-resolvents (cdr lor)))
	(t (cons (car lor)
		 (remove-general-resolvents 
		  (subset (cdr lor) (f/l (r) 
					 (not (more-specific-resolvent? 
					       (car lor) r)))))))))

(defun  more-specific-resolvent? (a b)
  "Is A a more specific resolvent than B?"
  (let ((atypes (get-resolvent-argtypes a))
	(btypes (get-resolvent-argtypes b)))
    (and (= (length atypes)(length btypes))
	 (every (function osql-subtypep) atypes btypes))))

(defun combine-argsignatures (genfn sigs resolvents argl coerce)
  "Return subset of RESOLVENTS where some arguement signature in SIGS match"
  (subset resolvents 
	  (f/l (x) 
	       (let ((argtypes (get-resolvent-argtypes x))
                     (eb (early-bound genfn)))
                 (some (f/l (y) (ok-argtype y argtypes argl coerce eb))
		       sigs)))))

(defun combine-signatures (genfn atl rtl resl argl &optional coerce)
  "ATL is a list of argument types, RTL is a list of reult types and
   RESL is a list of resolvents"
  (let* ((possres (combine-argsignatures genfn (list atl) resl argl coerce))
	 (lort (if (and (listp rtl) (not (listp (car rtl))))
		   (list rtl)		; one sig 
		 rtl)))			; many sigs
    (if (or (null rtl)(equal rtl '(nil)))
	possres
      (mapfilter 
       (f/l (x) (some (f/l (y)
			   (ok-restype y (function-dynresulttypes x argl t)))
		      lort))
       possres))))

(defun ok-argtype (tpl argtypes argl coerce early-bound)
  "Do resolvent argument types in TPL match function ARGTYPES?"
  (and (= (length tpl)(length argtypes))
       (every (f/l (tp argt arg) 
		   (or (equal tp argt)
		       (osql-subtypep tp argt)
                       (and (equal arg #())
                            (not early-bound) 
                            (osql-subtypep argt _vector_))
                       (and coerce (get-coercer tp argt))))
	      tpl argtypes argl)))

(defun ok-restype (tpl restypes)
  "Do resolvent result types in TPL match function RESTYPES?"
  (cond ((and _strict-restypes_
	      (null (cdr tpl))(oid-p (car tpl))
              (bag-type? (car tpl))
              (not (bag-type? (car restypes))))
         ;; To handle functions with implicit bag results
         (ok-restype (or (type-parameters (car tpl))
                         (list _object_)) restypes)) 
        ((= (length tpl)(length restypes)) 
	 (every (function ok-restype1) tpl restypes))
        ((and tpl (null (cdr tpl))(osql-subtypep (car tpl) _vector_)))))

(defun ok-restype1 (tp rt)
  (or (not _strict-restypes_)
      (eq tp rt)
      (subtype-of tp rt)
      (subtype-of rt tp)))

(defun get-coercer (t1 t2)
  "Get coerce function from type T1 to type T2"
  (cond ((eq t1 t2) nil)
        ((null *enable-coercers*) nil)
        ((car (getfunction-firsttuple _coercers_ (vector t1 t2))))
        ((and (bag-type? t1)(bag-type? t2)) nil);;no bag coercion
	((and (bag-type? t2)
	      (or (eq t2 _bag_)
		  (subtype-of t1 (car (type-parameters t2)) t)))
	 (setfunction _coercers_ (list t1 t2)  '(bagof))
	 'bagof)))

(defun add-coercion (argl atpl resolvent)
  "Add coercion predicates to coerce arguments ARGL types ATPL
   of call to RESOLVENT"
  (amos-warning "Coercing argument in call to " 
		(function-signature resolvent))
  (or (get-cached-coercion resolvent atpl)
      (put-cached-coercion 
       resolvent atpl 
       (resetgenvar (let* (*bindings*
			   (argvars (genvars atpl))
			   (argtypes (get-resolvent-argtypes resolvent))
			   (restypes (get-resolvent-restypes resolvent))
			   (bagged (has-bagged-result resolvent)) 
			   fno
			   )
		      (setq fno
			    (createsimplederivedfunction
			     (create-transient-object _function_)
			     (mapcar (function list) atpl argvars)
			     (mapcar (function list) restypes)
			     (list (cons resolvent 
					 (mapcar 
					  (f/l (arg tpo rtpo)
					       (let ((cfno 
						      (get-coercer tpo rtpo))
						     var)
						 (cond (cfno (list cfno arg))
						       (t arg))))
					  argvars atpl argtypes)))
			     nil nil))
		      (if bagged (set-bagged fno t))
		      fno)))))

(defun get-cached-coercion (resolvent types)
  (cdr (assoc types (getobject resolvent 'cached-coercions))))

(defun put-cached-coercion (resolvent types coercion)
  (cdar (/putobject resolvent 'cached-coercions 
		    (cons (cons types coercion)
			  (get-cached-coercion resolvent types)))))

(defun getrestype (x)
  "Get the list of types in a function's result tuple. 
   Even if it's just one result you get a list back."
  (let ((tp (get-resolvent-restypes x)))
    (if (null tp) (list _boolean_) tp)))

(defun resolvents-with-arity (arity resolvents)
  (subset resolvents 
	  (f/l (x) (= (length 
		       (get-resolvent-argtypes x))
		      arity))))

(defun b()
  "Backtrace of variable binding stack during flattening"
  (dolist (x *bindings*)(print(arraytolist x))))
  
(defun createliteraltype (name supertypes lisptag printfn &optional amostypefn)
  "Create a new literal Amos type named NAME.
   SUPERTYPES list of supertypes.
   LISPTAG symbolic name of ALisp data type representing the literals.
   PRINTFN Lisp function F(X,STR) to print literal X on stream STR.
        If it returns NIL the default printfn is used instead.
   AMOSTYPEFN Lisp function F(X) that returns the type object of X"
  (let ((tp (createtype name supertypes)))
    (putprop lisptag 'amostype (or amostypefn
				   `(lambda () , tp)))
    (putobject tp 'printfn printfn)
    tp))

(defun move-type (type below)
  "Move TYPE to below type BELOW"
  (setq type (gettypenamed type))
  (setq below (gettypenamed below))
  (let ((supertypes (type-supertypes type))
	(subtypes (getallsubtypes type))
	(allsupertypes (type-allsupertypes type))
	(newallsupertypes (adjoin type (type-allsupertypes below))))
    ;;(/retractrelation _IMMSUBSUPERTYPES_ (list type '*))
    (dolist (tp subtypes)
      (differenceobject tp 'allsupertypes allsupertypes))
    (addsupertype type below)
    (/putobject type 'allsupertypes (csort newallsupertypes 
					   (function subtype-of))) 
					;sort
    (dolist (tp subtypes)
      (unionobject tp 'allsupertypes (csort newallsupertypes 
					    (function subtype-of)) ))
					;sort
    below))


(defun common-ancestortype (t1 t2)
  "Compute the closest common ancestor to types T1 and T2"
  (cond ((or (symbolp t1)(symbolp t2)) nil)
        ((eq t1 t2) t1)
        ((osql-subtypep t1 t2) t2)
        ((osql-subtypep t2 t1) t1)
        ((and (null (cdr (supertypes t1)))
              (null (cdr (supertypes t2)))); single inheritance
         (common-ancestortype (car (supertypes t1))
                              (car (supertypes t2))))
        (t (lowest-type (intersection (type-allsupertypes t1)
				      (type-allsupertypes t2))))))
(defun lowest-type (tpol)
  "Returns the type in tpol that is lowest in type hierarchy"
  (let (lowest (l tpol))
    (loop
      (setq lowest			; Lowest types in l
	    (subset l 
		    (f/l (t1)
			 (null (isome (subtypes t1)
				      (f/l (t2)(memq t2 l)))))))
      (cond ((null (cdr lowest))(return (car lowest)))
	    (t (setq l (set-difference l lowest)))))))

(defvar *subtypes*)

(defun getallsubtypes (tp)
  "Get transitive closure of all subtypes under type TP"
  (let (*subtypes*)
    (getallsubtypes1
     (list tp))
    (cdr *subtypes*)))

(defun getallsubtypes1 (tp)
  (cond ((memq
	  (car tp)
	  *subtypes*))
	(t (setq *subtypes*
		 (nconc1 *subtypes*
			 (car tp)))
           (mapfunction (getfunctionnamed 'type.subtypes->type) tp
			(function getallsubtypes1)))))

(defun argrestypes (fno)
  "Returns the concatenation of the argument and 
   result type objects. Boolean functions don't have result types."
  (cons (get-resolvent-argtypes fno)
        (getrestype fno)))

(defun remtype (tpe o)
  "Remove type from type set of object"
  (setf (oid-types o) (remove tpe (oid-types o))))

(defun searchdcl (v dcll)
  "Get declaration of variable V in variable type declarations DCLL"
  (car (isome dcll
	      (function
	       (lambda (x)
		 (eq (dcl-variable x)
		     v))))))

(defun matchtype (type typel)
  (dolist (tp typel)(if (osql-subtypep tp type)(return t))))

(defun function-resulttype (fno)
  "Should be removed!"
  (car (function-resulttypes fno t)))

(defun gettypes (argl)
  (mapcar
   (function dcl-type)
   argl))

(defun binddcl (dcll)
  (dolist
      (d dcll)
    (addbinding
     (dcl-variable d)
     nil
     (dcl-type d))))

(defun get-resolvent-argtypes (fno)
  (or (getobject fno 'argtypes)
      (let ((sb (getobject fno 'selectbody)))
	(and sb (selectbody-argt sb)))))

(defun get-resolvent-restypes (fno)
  (or (getobject fno 'restypes)
      (let ((sb (getobject fno 'selectbody)))
	(and sb (selectbody-rest sb)))))

(defun getarity (fno) (length (get-resolvent-argtypes fno)))

(defun getwidth (fno) (length (get-resolvent-restypes fno)))

(defun surrogate-type? (tp)
  (and (not (getobject tp 'no-extent))
       (not (or (osql-subtypep tp _literal_)
		(osql-subtypep tp _collection_)))))

(defun set-no-extent (tpo)
  (/putobject (gettypenamed tpo) 'no-extent t))

(defun collection-type? (tp) 
  "Test if type TP under type Collection"
  (and (oid-p tp) (osql-subtypep tp _collection_)))

(defun bag-type? (tp)
  "Test if type TP under type Bag"
  (and (oid-p tp) (osql-subtypep tp _bag_)))

(defun checkbinding (xpr)
  "Make sure XPR is bound on *BINDINGS* if variable"
  (cond
   ((osql-constantp xpr) nil)
   ((listp xpr)
    (if (eq (car xpr)
	    _tupletag_)
	(mapc
	 (function checkbinding)
	 (cdr xpr)) 
      nil))
   ((getbinding xpr))
   (t (amos-error "Shouldn't happen!"))))

(defun maketuple (l)
  (funify _tupletag_ l))

(defun tuple (&rest l)(cons _tupletag_ l)) ; convenience function

(defun /addtype (obj type)
  (/putobject obj 'types 
	      (csort
	       (union (oid-types obj)
		      (type-allsupertypes type))
	       (function subtype-of))))

(defun checked-addtype (obj type)
  "Restricted /addtype as used in the 'add type' statement"
  (cond ((or (osql-subtypep type (most-specific-type(oid-types obj)))
             (null _checked-addtype_))
	 (/addtype obj type))
	(t (error "Trying to add a non-subtype to object" obj))))

(defun /remtypes (obj toremove)
  (differenceobject obj 'types toremove))
