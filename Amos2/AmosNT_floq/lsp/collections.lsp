;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Tore Risch, UDBL
;;; $RCSfile: collections.lsp,v $
;;; $Revision: 1.55 $ $Date: 2012/04/13 11:39:33 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Collection types: bags, vectors, tuples
;;; =============================================================
;;; $Log: collections.lsp,v $
;;; Revision 1.55  2012/04/13 11:39:33  torer
;;; select x from ... where x in (1,2,3) now works
;;;
;;; Revision 1.54  2011/12/29 07:37:14  torer
;;; Introduced tuple types
;;;
;;; Revision 1.53  2011/12/22 12:55:15  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.52  2011/01/09 16:43:48  torer
;;; Function 'in' now overloaded on only basic collection types
;;; (i.e. bag, vector, stream), not on all combinations of collection
;;; type constructor types as before.
;;; Instead 'in' uses type inference to determine result types
;;;
;;; Revision 1.51  2010/12/11 16:18:43  torer
;;; revert
;;;
;;; Revision 1.50  2010/12/09 18:54:42  torer
;;; New function (map-done result) to terminate map function
;;;
;;; Revision 1.49  2010/09/02 18:04:17  torer
;;; Function MEMO-FUNCTION replaces macro CACHE and function MEMO
;;;
;;; Revision 1.48  2010/08/27 07:49:56  torer
;;; Type inference of {} in function arguments
;;;
;;; Revision 1.47  2010/05/04 08:10:36  torer
;;; New function (BAG-SIZE B)
;;;
;;; Revision 1.46  2010/05/04 07:49:22  torer
;;; Limited but scalable late binding over collections
;;;
;;; Revision 1.45  2009/12/30 19:33:40  torer
;;; Added cost function for dynconstructors
;;;
;;; Revision 1.44  2009/12/14 20:07:33  torer
;;; Complete MAKE-DYNCONSTRUCTOR
;;;
;;; Revision 1.43  2009/11/03 19:57:13  torer
;;; Inferring types of materialized bags
;;;
;;; Revision 1.42  2009/10/29 21:57:55  torer
;;; Bug in FLATTEN-IN
;;;
;;; Revision 1.41  2009/10/29 10:59:11  torer
;;; x in foo(..) where foo is bagged -> x = foo(...)
;;;
;;; Revision 1.40  2009/10/03 11:08:26  torer
;;; in(Collection of X)->Bag of X
;;;
;;; Revision 1.39  2009/08/17 14:00:27  torer
;;; New function (COLLECTION-PARAMETERS tpo)
;;;
;;; Revision 1.38  2009/04/11 12:26:07  torer
;;; Use of CommonLisp's generalized APPLY simplifies dynamic calls to OSQL-RESULT
;;;
;;; Revision 1.37  2008/11/29 16:13:06  torer
;;; Bug for Boolean bags
;;;
;;; Revision 1.36  2008/11/23 15:00:25  torer
;;; Stricter type checking
;;;
;;; Revision 1.35  2008/11/20 19:29:45  torer
;;; Checking result types of aggregate functions
;;;
;;; Revision 1.34  2008/11/18 21:07:25  torer
;;; Flattening subqueries under IN
;;;
;;; Revision 1.33  2008/09/17 12:18:17  zeitler
;;; Deferring execution of streams
;;;
;;; Revision 1.32  2008/08/18 14:23:33  torer
;;; Setting bag values allowed
;;;
;;; Revision 1.31  2008/08/13 21:14:10  torer
;;; Print function for generators
;;;
;;; Revision 1.30  2007/10/22 22:32:49  torer
;;; System function MAKEBAG now in C
;;;
;;; Revision 1.29  2007/10/21 15:00:15  torer
;;; Not tested code for bag materialization removed
;;;
;;; Revision 1.28  2007/02/16 11:35:56  torer
;;; Type checked efficient numerical arrays
;;;
;;; Revision 1.27  2006/12/14 18:20:28  torer
;;; Moved all code to define type STREM to stream.lsp
;;; Moved all code to define type VECTOR to vector.lsp
;;;
;;; Revision 1.26  2006/12/05 20:47:41  torer
;;; Cosmetics
;;;
;;; Revision 1.25  2006/12/02 15:29:31  torer
;;; Type inference for vector construction
;;;
;;; Revision 1.24  2006/11/30 19:42:23  torer
;;; Functions may return materialized bags
;;;
;;; Revision 1.23  2006/11/24 23:03:38  torer
;;; Datatype STREAM (of type) instroduced
;;;
;;; Revision 1.22  2006/11/04 16:18:19  torer
;;; Systematically using GET-RESOLVENT-ARGTYPES and GET-RESOLVENT-RESTYPES
;;;
;;; Revision 1.21  2006/05/22 19:57:37  torer
;;; Use of DEFAULT-TYPE-PARAMETERS to handle dynamic collections of OBJECT
;;;
;;; Revision 1.20  2006/05/17 13:10:32  torer
;;; Bug in default-type-parameters
;;;
;;; Revision 1.19  2006/05/17 12:29:03  torer
;;; Looping in decode-type removed
;;;
;;; Revision 1.18  2006/05/16 14:54:04  torer
;;; inn operator
;;;
;;; Revision 1.17  2006/05/03 19:14:06  torer
;;; in(select x,y ...) now works
;;;
;;; Revision 1.16  2006/04/13 13:29:50  ruslan
;;; default cost model of dynconstruct functions, e.g. vector, is improved that they perform quite earlier if possible, because they bind variables
;;;
;;; Revision 1.15  2006/03/22 06:47:22  torer
;;; Caching the bag of result type of a function result type on function object
;;;
;;; Revision 1.14  2006/03/20 13:57:28  torer
;;; countbb defined + bug fixed so that typecontainer for VECTOR now works
;;;
;;; Revision 1.13  2006/02/15 07:26:07  torer
;;; Caching bag type names
;;;
;;; Revision 1.12  2006/02/13 22:08:57  torer
;;; Bags implemented using stream generators
;;;
;;; =============================================================

;;; -------------------------------------------------------------
;;; Generic code for all parameterized types
;;; -------------------------------------------------------------

(defglobal _max-collection-type-inferences_ 5
  "Max number of elements searched in collection for type inference")

(defun oid-names (l)(mapcar (function oid-name) l))

(defun make-param-type-for (ptype typel)
  "Generic constructor of new parameterized type PTYPE of TYPEL"
  (let ((c (getobject (gettypenamed ptype) 'type-constructor)))
    (if c
	(funcall c typel)
      (error "Not a parameterized type" ptype))))

(defun param-type-p (type)
  "Is TYPE is parameterized type?"
  (let (tp)
    (and (symbolp type) 
	 (setq tp (gettypenamed type t))
	 (getobject tp 'type-constructor))))

(defun make-parameterized-type (tp type-constructor)
  "Make the type TP a parameterized type having the specified TYPE-CONSTRUCTOR"
  (putobject tp 'type-constructor type-constructor))

(defun make-param-type (tl typename-constructor type-initializer
			   root-type)
  "Make parameterized type with element types TYPEL. 
   (TYPENAME-CONSTRUCTOR TYPENAMES) generates name of specific parameterized 
   type. (TYPE-INITIALIZER ..) remains to be explained"
  (let* ((typel (cond ((null tl)(list _boolean_))
                      ((atom tl)
                       (error 
                        "Illegal elements of parameterized type specification"
                        tl))
                      (t tl)))
         (types (gettypesnamed typel)))
    (cond 
     ((and (null (cdr types))
	   (eq (car types) _object_)) 
      root-type)			; root = root of object
     (t (let ((ttn (funcall typename-constructor
			    (oid-names types)))) ; make unique type name
	  (or (gettypenamed ttn t)	; type already defined
	      (let* ((tpo 
		      (createtype	; new type created
		       ttn 
		       (parent-param-types ; but create all ansestors first
			types
			typename-constructor
			type-initializer
			root-type))))
		(set-type-parameters tpo types)
		(/putobject tpo 'root-type root-type)
		(/putobject tpo 'type-checker 
			    `(lambda (o tpo) (osql-subtypep (arg-type o) 
							    , root-type))) 
					; default necessary condition
		(funcall type-initializer tpo) ; type initialization
		tpo
		)))))))

(defun set-iterator (tpo iterator)
  "Set the iterator of a type"
  (/putobject tpo 'iterator iterator))

(defun type-iterator (tpo)
  (or (getobject tpo 'iterator)
      (error "Collection type has no iterator" tpo)))

(defun parent-param-types (typel typename-constructor 
				 type-initializer root-type)
  "Create all ancestor parameterized types for the types in TYPEL.
   Limitation: only inheritance placement on the first type"
  (cond ((eq (car typel) _object_) (list root-type))
	(t (mapcar (f/l (super)		; make ansestors first
			(make-param-type (cons super (cdr typel)) 
					 typename-constructor
					 type-initializer
					 root-type))
		   (supertypes (car typel))))))

(defun root-type (tpo)
  "Get the root type of parameterized type TPO"
  (getobject tpo 'root-type))

(defun type-parameters (tpo)
  "Get the parameters of a parameterized type"
  (getobject tpo 'type-parameters))

(defun collection-parameters (tpo)
  "Get the member types of a collection type"
  (cond ((not (collection-type? tpo))(error "Not a collection type" tpo))
        ((type-parameters tpo))
        (t (list _object_))))

(defun set-type-parameters (tpo params)
  (/putobject tpo 'type-parameters params))

(defun default-type-parameters (tpo)
  (setq tpo (gettypenamed tpo t))
  (cond ((null tpo) (list _object_))
        ((type-parameters tpo))
	(t (list _object_))))

(defun iterator-parmtypes (itfno)
  "Get the parameters of the type of a collection iterator"
  (type-parameters (car (get-resolvent-argtypes itfno))))

;;; -------------------------------------------------------------
;;; Generic code to generate invertible constructors with dynamic arity.
;;; Called as <collectiontype>(o1, o2, ...)
;;; -------------------------------------------------------------


(defun make-dynconstructor(typename amosql-constructor lisp-constructor)
  "Create a dynamic constructor function for TYPENAME
   The constructor function will be named TYPENAME too
   AMOSQL-CONSTRUCTOR: constructor as foreign Lisp implementation
   LISP-CONSTRUCTOR:   constructor as no-spread Lisp function"
  (let (fno (fnname (pack typename "->" typename)))
    (gettypenamed typename)		; just to check 
    (bind-foreign fnname '*any* amosql-constructor)
    (/putprop typename 'aggfn lisp-constructor)
    (setq fno (createfunction typename nil 
			      (list(list typename)) 'foreign nil))
    (set-type-container fno)
    (/putobject (getfunctionnamed typename) 'dynconstructor t)
    (/putobject (getfunctionnamed typename) 'foreignimpl typename)
    (/putobject (getfunctionnamed typename) 'bindings
		(getobject fno 'bindings))
    (declarecosts fnname '*any*
		  'function.vector.vector.constructorhint->real.real)
    (declarecosts typename '*any* 
		  'function.vector.vector.constructorhint->real.real)
    typename))

(defun legaldynconstructorbpat (bpat)
  "A dynamic constructor predicate is executable if either
   the first argument is bound or all the others are bound:"
  (let ((s (array-total-size bpat)))
    (and (> s 0) 
	 (or (eq (aref bpat 0) '-)
	     (do ((i 1 (1+ i)))
		 ((= i s)t)
	       (if (not (eq (aref bpat i) '-)) (return nil)))))))

(defun flattendynconstructor (fn args)
  "Flatten call to dynamic constuctor"
  (let ((aggfn (aggregator fn))
        (argl (flattenarglist args nil)))
    (cond ((and aggfn (every (function osql-constantp) argl)
		(apply aggfn argl)))
	  (t (cons (getfunctionnamed fn) argl)))))

(defun dynconstructorfn (fn)
  "Test if FN is a dynamic constructor"
  (let ((o (getfunctionnamed fn t)))
    (if o  (getobject o 'dynconstructor))))


;;; Constant aggregate expressions

(defun aggregator (x)
  "Get Lisp function constructing aggregate X"
  (getprop x 'aggfn))

(defun aggr-constant (xpr)
  "Evaluate XPR or pieces of XPR if XPR is an aggregate constructor"
  (cond ((atom xpr) xpr)
        ((null (aggregator (car xpr))) xpr)
        ((let (notconstant)
	   (mapl (f/l (tl)
		      (let ((c (aggr-constant (car tl))))
			(cond ((neq c (car tl)) (rplaca tl c)) ; subaggregate
                              ((osql-constantp c)) 
                              (t (setq notconstant t)))))
                 (cdr xpr))
	   notconstant) xpr)
        (t (apply (aggregator (car xpr))(cdr xpr)))))


;;; -------------------------------------------------------------
;;; Bag types
;;; -------------------------------------------------------------

(memo-function (defun make-bagtypename(names)
		 (pack 'bag- (if (cdr names)
				 (make-tupletypename names)
			       (car names)))))

(defun make-bagtype  (typel)
  "Construct the bag type which elements have types in TYPEL"
  (make-param-type typel 
		   (function make-bagtypename)
		   (function init-bagtype)
		   _bag_))

(defun init-bagtype (tpo)
  (let ((types (type-parameters tpo))
        (fno 
	 (createfunction1 
	  (pack 'make- 
		(oid-name tpo)))))	; Closure constructor
    (/putobject fno 'argtypes 
		(cons _function_ types))
    (/putobject fno 'restypes 
		(list tpo))
    (set-resolvents fno 
		    (list fno))
    (/putobject tpo 'makebag fno)
    (/putobject fno 'ismakebag t)
    tpo))

(defun bag.in (obj b &rest resl)
  "Iterate over elements in bag"
  (mapbag b (f/l (row)
		 (cond ((null (cdr resl))
			(osql-result b (car row)))
                       ((cdr row)
			(apply (function osql-result) b row))
		       (t (apply 'osql-result b (arraytolist (car row))))))))

(defun bag-p (x)(and (listp x)(eq (car x) 'aggr_bag))) 

(defun is-bag (b)
  (or (bag-p b) (and (generatorp b)(bag-type? (generator-type b))))) 

(defun aggr_bag (&rest l)
  (cons 'aggr_bag 
	(mapcar (f/l (tpl) 
		     (cond ((tuplep tpl) (cdr tpl))
			   ((bag-p tpl)
			    (amos-error "Nested bags disallowed: "
					tpl))
			   ((atom tpl) (list tpl))
			   (t tpl)))
		l)))

(defun bagify (l)(cons 'aggr_bag l))

(defun infer-bagtype (b)
  "Compute the type of a bag constant"
  (let (mgtl (cnt 0))			;most general types
    (catch 'infer-bagtype (mapbag 
			   b 
			   (f/l (row)
				(if (> (1++ cnt) 
				       _max-collection-type-inferences_) 
				    (throw 'infer-bagtype))
				(setq mgtl (common-bagrow-types b row mgtl)))))
    (cond ((null mgtl) _bag_)
          (t (make-bagtype mgtl)))))

(defun common-bagrow-types (b row mgtl)
  (if (bag-p row)(amos-error "Nested bags disallowed: " b)
    (let ((tpl (mapcar (function arg-type) row)))
      (cond ((null mgtl) tpl)
	    ((equal mgtl tpl) mgtl)
	    ((not (= (length mgtl)(length tpl)))
	     (error "Inconsistent bag" (stringify-amos-object b)))
	    (t (mapcar (function common-ancestortype) tpl mgtl))))))

(defun construct-bag (obj b &rest e)
  (let ((s (list 'aggr_bag)))
    (cond 
     ((eq b '*)
      (apply 'osql-result (apply 'aggr_bag e) e))
     ((and (bag-p b)
	   (if (not (listp b))
	       (mapbag b (f/l (tpl) (rplacd s tpl)))
	     (setq s b))
	   (eq (length (cdr s)) 
	       (length e)))
      (apply 'osql-result s (apply 'aggr_bag e))))))

;;; -------------------------------------------------------------
;;; Representing bags as generators
;;; -------------------------------------------------------------

(defun generatorp (x)(eq (typename x) 'generator))

(putprop 'generator 'amostype '(lambda (g) (generator-type g)))

(defun decode-type (type)
  "Takes a composite type and returns a 
  description of it in terms of basic types"
  (cond ((null type) nil)
	((atom type)
	 (if (type-parameters type)
	     (cons (decode-type (root-type type)) 
		   (decode-type (type-parameters type)))
	   (oid-name type)))
	(t (cons (decode-type (car type)) (decode-type (cdr type))))))

(defun encode-type (description)
  "Inverse of decode-type: Creates a type by reading its description"
  (cond ((null description) nil)
	((atom description)
	 (gettypenamed description))
	(t (make-param-type-for (encode-type (car description)) 
				(mapcar (function encode-type) 
					(cdr description))))))

(defun makebag (obj bfn &rest args)
   "This function defined as MAKE-BAG as foreign ObjectLog predicate
    It is defined in Lisp only to still support Vanja's code.
    Implements ObjectLog predicate
        makebag(fn,a1,...,an,b)
    It creates a transient bag object, b, represented as a
   'stream generator' of OSQL function fn applied to arguments a1,...,an."
   (let ((arglist (cons bfn (butlast args))))
     (apply (quote osql-result)
	    (append arglist 
		    (list (make-generator (arg-bagtype bfn) 
					  bfn (cdr arglist)))))))

(defun arg-bagtype (bfn)
  "Construct the bag type for a given generator function"
  (or (getobject bfn 'bagtype)
      (/putobject bfn 'bagtype (make-bagtype (get-resolvent-restypes bfn)))))

(defun bag-result-types (bag)
  "Retrieve the result type list of elements in a bag"
  (cond 
   ((bag-p bag)
    (amos-error 
     "Extraction of type signatures from materialized bags not implemented" 
     bag))
  ((generatorp bag)(type-parameters (generator-type bag)))
  (t (amos-error "Not a bag: " bag))))

(defun bag-printfn (b stream)
  (cond ((generatorp b) 
	 (formatl stream "#" (oid-name (arg-type b)) "#") 
	 t)))

(defun bag-size (b)
  "The number of elements in B"
  (let ((r 0))
    (mapbag b (f/l (row)(1++ r)))
    r))

;;; -------------------------------------------------------------
;;; Bag Coersion
;;; -------------------------------------------------------------

(defun aggregatefunctionp (fn)
  "If some resolvent of FN is a bag valued function 
   then FN is regarded as an aggregate function."
  (isome (resolvents fn)
	 (f/l (rfno)
	      (isome (get-resolvent-argtypes rfno)
		     (function bag-type?)))))

(defun has-generic-function (fno gfno)
  "Has FNO the generic unction GFNO"
  (let ((gfn (generic-function-of (getfunctionnamed fno) t)))
    (and gfn (eq gfn (getfunctionnamed gfno t)))))

(defun coerce-bag-arguments (gfno args)
  "GFNO is a generic function. If some arguments of GFNO
   requires bag valued arguments then coerce those arguments to
   bags when needed.
   If GFNO is overloaded on both bag and nonbag arguments, no coercion
    will take place.
   If GFNO is overloaded on different bag arguments, no overloading either"
  (cond ((flatten-in gfno (car args)))
	((aggregatefunctionp gfno)
	 (let ((cr (mapcar (f/l (r)(bagcoerceresolvent gfno r args))
			   (resolvents gfno))))
	   (cond ((memq 'match cr)	
		  ;; there was some non-bag resolvent, no coercion
		  nil)
		 ((isome cr 
			 (f/l (x tl)
			      (and (consp x) 
				   (isome (cdr tl)
					  (f/l (y)
					       (and y (not (equal y x))))))))
		  ;; There was more than one bag resolvent 
		  ;; but with coercion on different
		  ;; arguments, no coercion because of possible ambiguity
		  nil)
		 (t			; return unique coerced expression
		  (car (isome cr (function consp)))))))))

(defun flatten-in (gfno xpr)
  (and (memq(oid-name gfno) '(in bag.in->object)) 
       (cond ((not (consp xpr)) nil)
             ((eq (car xpr) _tupletag_) 
              ;; in((1,2,3)) -> in({1,2,3})
	      (list 'in (cons 'vector (cdr xpr))))
             ((memq (car xpr) '(bag aggr_bag)) nil)
             ((eq (car xpr) _tupletag_)
	      (flatten-in gfno (cons 'vector (cdr xpr))))
             ((eq (car xpr) 'bagof) (cadr xpr))
             ((eq (car xpr) 'select)
	      (cond ((memq 'distinct xpr) nil)
		    ((and (null (cddr xpr))
			  (null (cdadr xpr)))
		     (caadr xpr))
		    (t nil)))
             ((eq (car xpr) 'streamof)
              (flatten-in gfno  (cadr xpr)))
             ((every (function has-bagged-result) 
		     (resolvents (getfunctionnamed (car xpr))))
	      ;; x in foo(..) where foo is bagged -> x = foo(...)
              xpr)
	     ((let ((at (arg-type xpr)))
		(and at (collection-type? at))) 
              ;; x in c where c collection retained
              nil)
	     (t xpr))))
 
(defun bagxprp (x)
  "Test if X is bag valued"
  (cond ((and (listp x)(memq (car x) '(bag bagof select))))
	(t (isome (arg-types x) (f/l (x)(and (oid-p x) 
                                             (bag-type? x)))))))

(defun bag-applicable? (r args)
  "Is the resolvent R applicable on ARG, eventually with bag coercion?"
  (let ((rtl (get-resolvent-argtypes r)))
    (if (not (= (length args)(length rtl))) nil ; arity mismatch
      (every (f/l (rt a)
                  (let ((at (or (arg-type a) _boolean_)) bo)
		    (and rt (atom at)
			 (or (osql-subtypep at rt) ; applicble non-coerced
			     (cond ((not (bag-type? rt)) nil) 
					; not bag resolvent argument
				   ((bag-type? at) nil) 
					; both resolvent and actual arg bags
				   ((eq rt _bag_) t) 
					; resolvent accepts bag of anything
				   (t (setq bo (type-parameters rt))
                                      (and  (null (cdr bo))
					    (osql-subtypep at (car bo))))))))) 
					; applicable after coercion
	     rtl args))))

(defun bagcoerceresolvent (gfno fno args)
  "If resolvent FNO of GFNO needs to coerce argument(s) A to bags
       then wrap those argumens with (BAGOF A)
   If FNO not applicable then return NIL
   If FNO applicable without coercion then return MATCH"
  (if (not(bag-applicable? fno args)) nil
    (let (nargs coerced (at (get-resolvent-argtypes fno)))
      (setq nargs 
	    (mapcar (f/l (tpe a)
			 (cond ((and (bag-type? tpe)
				     (not(bagxprp a))) 
				(setq coerced t)
				(list 'bagof a))
			       (t a)))
		    at args))
      (if coerced (cons gfno nargs) 'match))))

(defun bag.in-cost (x y z)(help))

(defun init-collections ()
  (let ((iterator 
	 (create-function in((bag))((object)) 
			  as foreign (bag.in))))
    (set-iterator _bag_ 'bag.in)
    (set-early-bound 'in)
    (set-resulttypesfn (getfunctionnamed 'in) 
		       'transparent-collection-resulttypes)
    (set-type-container 'in)		; for all kinds of collections
    ))