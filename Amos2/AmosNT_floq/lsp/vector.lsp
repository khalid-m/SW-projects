;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1995-2002 Tore Risch, EDSLAB, UDBL
;;; $RCSfile: vector.lsp,v $
;;; $Revision: 1.49 $ $Date: 2013/11/20 21:00:23 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Initialization of data type VECTOR
;;; =============================================================
;;; $Log: vector.lsp,v $
;;; Revision 1.49  2013/11/20 21:00:23  torer
;;; aggv() is foreign function
;;;
;;; Revision 1.48  2013/01/28 21:49:09  torer
;;; Vector constructor
;;; new_vector(Number size, Object initelem)->Vector
;;;
;;; Revision 1.47  2013/01/28 21:39:13  torer
;;; Added datatype check
;;;
;;; Revision 1.46  2013/01/28 21:23:26  torer
;;; New function assign_vref(Vector v, Number i, Object v)->Vector
;;;
;;; Revision 1.45  2012/02/21 07:01:26  torer
;;; Errors not allowed in resulttype functions
;;;
;;; Revision 1.44  2011/12/22 12:55:17  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.43  2011/01/29 11:04:40  torer
;;; Base system uses (...) tuple notation, 'return' statement, and systematic indentation
;;;
;;; Revision 1.42  2011/01/26 20:45:40  torer
;;; System function vectorTuple to convert vectors to tuples
;;;
;;; Revision 1.41  2011/01/20 18:04:19  torer
;;; Result types of function vector on generic function
;;;
;;; Revision 1.40  2011/01/09 16:43:49  torer
;;; Function 'in' now overloaded on only basic collection types
;;; (i.e. bag, vector, stream), not on all combinations of collection
;;; type constructor types as before.
;;; Instead 'in' uses type inference to determine result types
;;;
;;; Revision 1.39  2011/01/04 20:06:06  torer
;;; in(Vector) now in C
;;;
;;; Revision 1.38  2010/09/10 13:42:08  torer
;;; Wrong signature of BAGIFY
;;;
;;; Revision 1.37  2010/09/07 21:07:04  torer
;;; Integer -> Number in function arguments to avoid coersion
;;;
;;; Revision 1.36  2010/08/30 18:21:18  torer
;;; Added function substv
;;;
;;; Revision 1.35  2010/08/27 13:27:03  torer
;;; Removed !"#¤% CVS merge conflict
;;;
;;; Revision 1.34  2010/08/27 13:18:00  torer
;;; signature Vector of Number on project to avoid type coersion
;;;
;;; Revision 1.33  2010/08/27 07:47:03  torer
;;; Restored type Vector of Integer on function project
;;;
;;; Revision 1.32  2010/08/25 20:51:02  torer
;;; Relaxed type requirement of indl in function project(Vector v, Vector indl) -> Vector
;;;
;;; Revision 1.31  2010/05/04 07:49:23  torer
;;; Limited but scalable late binding over collections
;;;
;;; Revision 1.30  2009/12/14 20:07:33  torer
;;; Complete MAKE-DYNCONSTRUCTOR
;;;
;;; Revision 1.29  2009/11/17 15:47:11  zeitler
;;; lpcascore(Bag of <Vector of Number, object> b, Integer d)
;;;  -> <Vector of Number, object label>
;;; include a label for each projected vector
;;;
;;; Revision 1.28  2009/10/22 20:25:02  zeitler
;;; PCA() signature
;;;
;;; Revision 1.27  2009/10/22 18:21:33  torer
;;; NIL-intolerant project(vector,vector)->vector
;;;
;;; Revision 1.26  2009/10/22 16:36:05  zeitler
;;; normalization removed from this file
;;;
;;; Revision 1.25  2009/10/22 15:55:44  zeitler
;;; zscore and maxmin normalization of bag of vector
;;;
;;; Revision 1.24  2009/10/20 21:52:59  zeitler
;;; pca(bag of vector of number data)
;;;     -> <vector of number eigval, vector of vector of number eigvec>
;;; returns the eigenvalues and eigenvectors of the covariance matrix of the
;;; data vectors.
;;;
;;; Revision 1.23  2009/10/03 11:05:11  torer
;;; Iterator IN returns Bag of Object
;;;
;;; Revision 1.22  2009/10/02 20:22:15  zeitler
;;; Name change:
;;; avgstdev(vector)-><real,real>
;;; replaced by
;;; vavgstdev(vector)-><real,real>
;;;
;;; New function: avgstdev(bag of number)-><real,real>
;;;
;;; Revision 1.21  2009/04/11 15:47:34  torer
;;; More use of general APPLY
;;;
;;; Revision 1.20  2009/04/11 12:26:08  torer
;;; Use of CommonLisp's generalized APPLY simplifies dynamic calls to OSQL-RESULT
;;; Revision 1.18  2009/02/09 15:04:34  zeitler
;;; common-collection-type refactored
;;;
;;; Revision 1.17  2008/11/30 11:07:32  torer
;;; in(vector) did not filter out nil
;;;
;;; Revision 1.16  2008/11/29 15:47:48  torer
;;; Bug for Boolean vectors
;;;
;;; Revision 1.15  2008/11/11 07:46:13  torer
;;; Stricter checking of conformance with result types in function definitions
;;; Can be turned off with
;;;    (setq _strict-resulttypes_ nil)
;;;
;;; Revision 1.14  2008/10/25 10:39:50  torer
;;; Remove key declaration for concat
;;;
;;; Revision 1.13  2008/10/25 10:24:05  torer
;;; Invertible vector concatenation
;;;
;;; Revision 1.12  2008/08/21 13:59:58  torer
;;; key declaration for avgsdev
;;;
;;; Revision 1.11  2008/08/13 07:58:08  torer
;;; Type STREAM separated from core Amos II
;;;
;;; Revision 1.10  2007/10/24 21:14:55  torer
;;; Code moved to make modules independent
;;;
;;; Revision 1.9  2007/10/09 18:19:14  torer
;;; Invertible string concatenation
;;;
;;; Revision 1.8  2007/09/21 16:16:13  torer
;;; vref-++ in C
;;;
;;; Revision 1.7  2007/09/16 16:33:51  torer
;;; CONSTUCT-VECTOR in C
;;;
;;; Revision 1.6  2007/09/16 14:36:06  torer
;;; VREFbbf always in C
;;;
;;; Revision 1.5  2007/09/15 15:05:40  torer
;;; Reveretad back to Lisp implementation of vref
;;;
;;; Revision 1.3  2007/01/30 17:58:22  torer
;;; inn -> bagify
;;;
;;; Revision 1.2  2006/12/14 18:20:29  torer
;;; Moved all code to define type STREM to stream.lsp
;;; Moved all code to define type VECTOR to vector.lsp
;;;
;;; Revision 1.1  2006/12/14 16:43:55  torer
;;; 1. Basic functions on type VECTOR into file lsp/vector.lsp
;;; 2. Comparisons on vectors element by element
;;;
;;; Revision 1.22  2006/12/06 22:31:49  torer
;;; Strict typing of vector constructors in queries
;;;
;;; Revision 1.21  2006/11/30 20:24:47  torer
;;; count(vector) -> dim(vector) to make count(bag) unambigous
;;;
;;; Revision 1.20  2006/11/24 23:03:39  torer
;;; Datatype STREAM (of type) instroduced
;;;
;;; Revision 1.19  2006/05/17 12:29:03  torer
;;; Looping in decode-type removed
;;;
;;; Revision 1.18  2006/05/16 17:45:34  torer
;;; vectorize function
;;;
;;; Revision 1.17  2006/05/16 14:54:04  torer
;;; inn operator
;;;
;;; Revision 1.16  2006/04/27 12:44:16  ruslan
;;; value of fanout for collection constructors is moved to global variable
;;;
;;; Revision 1.15  2006/04/13 13:29:51  ruslan
;;; default cost model of dynconstruct functions, e.g. vector, is improved that they perform quite earlier if possible, because they bind variables
;;;
;;; Revision 1.14  2006/03/22 15:37:13  torer
;;; construct-vector in C
;;;
;;; Revision 1.13  2006/03/22 06:45:00  torer
;;; vrefbbf in C
;;;
;;; =============================================================

(defun make-vectortype  (typel)
  "Construct the vector type which elements have types in TYPEL"
  (make-param-type typel 
		   (function make-vectortypename)
		   (function init-vectortype)
		   _vector_))

(defun name-of-vectortype (typel)
  "Used by AMOSQL parser"
  (oid-name (make-vectortype typel)))

(defun make-vectortypename (names)
  "Generate internal name for type VECTOR OF TYPE"
  (pack 'vector-
	(if (cdr names)			; elements are tuples
	    (make-tupletypename names)
	  (car names))))

(defun init-vectortype (vt)
  (let ((name (oid-name vt))
	(elems (type-parameters vt))
        bpat)
    (if (equal elems (list _boolean_)) (setq elems nil))
    ;; create function to access vector element:
    (setq bpat (buildnstring (length elems) "f"))
    (set-early-bound 
     (set-type-container 
      (createfunction 'vref 
		      (list (list vt)(list _number_))
		      (mapcar (function list) elems)
		      'multidirectional 
		      (list (list (concat "bb" bpat) 'foreign 'vrefbbf)
			    (list (concat "bf" bpat) 'foreign 'vrefbff)))))
    vt))

(defun buildnstring (n str)(apply 'concat (buildn n str)))

(defun vector.bagify (obj v ind &rest args)
  "Extract elements in vector adding index first"
  (maparray v 
	    (f/l (x i)
		 (cond ((cdr args)	; elements declared as tuples
			(apply 'osql-result
			       v i (arraytolist x)))
		       (t (osql-result v i x)))))) 

(defun encodevectorof (fno decoded res)
  "Copy from untyped to typed vector while checking type correctness"
  (let ((tpl (type-parameters (first (getobject fno 'restypes)))))
    (maparray decoded			; check element types
	      (f/l (x i) 
		   (cond ((cdr tpl)	; elements are tuples
			  (mapc (function check-vectorelement)
				tpl (arraytolist x)))
			 (t (check-vectorelement (car tpl) x)))))
    (osql-result decoded decoded)))

(defun check-vectorelement (tpo x)
  (cond ((osql-subtypep (arg-type x) tpo)) ; type OK
	(t (amos-error "Vector element not of type " tpo ": " x))))

(defun decodevectorof (fno res encoded)
  (osql-result encoded encoded))

(defun construct-vector (obj v &rest e)
  (cond ((eq v '*) (apply 'osql-result (listtoarray e) e))
	((and (arrayp v) (eq (array-total-size v)(length e)))
	 (apply 'osql-result v (arraytolist v)))))

(defun print-vector(tpl stream)
  (print-tuple1 "{" "}" (arraytolist tpl)  stream))

(defun common-collection-type (o omgt)
  (cond ((null o) nil)			; nil ignored
	((and (symbolp o)(not (getbinding o t)))
	 ;; undeclared variable treat as OBJECT
	 _object_) 
	((null omgt) (arg-type o))	;first
	((common-ancestortype		;common
	  omgt (arg-type o)))
	(t _object_)))			;no common

(defun infer-vectortype (v)
  "Compute the type of a vector constant"
  (let (mgt)				;most general type
    (maparray v 
	      (f/l (o i)
                   (if (>= i _max-collection-type-inferences_)
                       (return nil)
		     (setq mgt (common-collection-type o mgt)))))
    (if mgt (make-vectortype (list mgt))
      _vector_)))			;no common

;;; Access vector element:
(osql "
create function vref(Vector v, Number i)->Object e
as multidirectional
  ('bbf' foreign 'vrefbbf' cost {0.8,1})
  ('bff' foreign 'vrefbff' cost {40,50});")

(set-early-bound 'vref) ; never late binding on VREF
(set-type-container 'vref) ; do no type check arguments and results of VREF

;;; Concatenate vectors:

(osql "
create function concat(Vector x, Vector y)->Vector r
  as multidirectional
     ('bbf' foreign 'concat-vector--+' cost {10,1})
     ('fbb' foreign 'concat-vector+--' cost {10,0.9}) 
     ('bfb' foreign 'concat-vector-+-' cost {10,0.9});")

(defun concat-vector--+ (fno x y r)
  (osql-result x y (concatvector x y)))

(defun concat-vector+-- (fno x y r)
  (let ((nv (vector-before-suffix y r)))
    (if nv (osql-result nv y r))))

(defun concat-vector-+- (fno x y r)
  (let ((nv (vector-after-prefix x r)))
    (if nv (osql-result x nv r))))

(defun concatvector (x y)
  (let ((s1 (length x))
	(s2 (length y))
	r)
    (setq r (make-array (+ s1 s2)))
    (dotimes (i s1)
      (setf (aref r i) (aref x i)))
    (dotimes (i s2)
      (setf (aref r (+ i s1)) (aref y i)))
    r))

(defun vector-before-suffix (s v)
  "Return vector of elements in V before V's suffix S"
  (let* ((ls (length s))
	 (lv (length v))
	 (delta (- lv ls)))
    (cond ((< delta 0) nil)
	  ((dotimes (i ls)
	     (if (not (equal (aref v (+ delta i))
			     (aref s i)))
		 (return t))
	     nil) nil)
	  (t (let ((r (make-array delta)))
               (dotimes (i delta)
                 (setf (aref r i)(aref v i)))
               r)))))

(defun vector-after-prefix (p v)
  "Return vector of elements in V after V's prefix P"
  (let* ((lp (length p))
	 (lv (length v))
	 (delta (- lv lp)))
    (cond ((< delta 0) nil)
	  ((dotimes (i lp)
	     (if (not (equal (aref v i)
			     (aref p i)))
		 (return t))
	     nil) nil)
	  (t (let ((r (make-array delta)))
               (dotimes (i delta)
                 (setf (aref r i)(aref v (+ i lp))))
               r)))))

;;; Concatenate integers:
(foreign-lispfn concat ((integer x)(integer y))((integer r))
		(foreign-result (mkatom (concat x y))))

;;; Extract elements from vector:

(create-function in((vector v))((object)) as foreign (vector.in))
(set-type-container 'in) ; both for vectors and bags!
(set-iterator _vector_ 'vector.in)

(defun bagify-resulttypes (fno args)
  "The result type is INTEGER + the type parameters of the 1st bag argument"
  (cons _integer_ (default-type-parameters (arg-type (car args)))))

(set-resulttypesfn
 (osql "
create function bagify(Vector v) -> Bag of (Integer, Object)
  as foreign 'vector.bagify';")
 'bagify-resulttypes)

;;; Constructors

(foreign-lispfn constructorhint ((function f)(vector bpat)(vector args))
		((real cost) (real fanout)) 
		(cond ((legaldynconstructorbpat bpat)
		       (foreign-result 0.1 _default-constructor-fanout_))))

(make-dynconstructor 'vector 'construct-vectorC 'vector)
(movd 'vector 'aggr_vector)		; Alias called by C parser

(setq _vector-constructor_ (getfunctionnamed 'vector))

(set-resulttypesfn _vector-constructor_ 'vector-resulttypesfn)

(defun vector-resulttypesfn (fno v)
  (list (infer-vectortype (listtoarray v))))

(make-dynconstructor 'bag 'construct-bag 'aggr_bag)

(defun vectorof-+ (obj b v)
  "Bag to vector without considering order"
  (let (res (i 0) v)
    (mapbag b
	    (f/l (key)
		 (setq i (1+ i))
		 (setq res (cons (if (cdr key)(listtoarray key)
				   (car key)) res))))
    (setq v (make-array i))
    (dolist (x res)
      (setq i (1- i))
      (setf (aref v i) x))
    (osql-result b v)))

(defun vectorof-resulttypes (fno args)
  "The result type is vectrotype with the type parameters 
   of the 1st bag argument"
  (list (make-vectortype (default-type-parameters (arg-type (car args))))))

(set-resulttypesfn 
 (osql "
create function vectorof(Bag b) -> Vector v
  /* Convert bag to vector without ordering it */
  as foreign 'vectorof-+';")
 'vectorof-resulttypes)

(defun vectorize-+ (fno b v)
  "Bag of (index,v1,...,vn) to vector of (v1,...,vn)"
  (let (res (v (vector)))
    (mapbag b
	    (f/l (key)
		 (let ((index (car key))
		       (val (cdr key)))
		   (if (>= index (length v))
		       (setq v (adjust-array v (1+ index))))
		   (setf (aref v index) 
			 (if (cdr val)(listtoarray val)
			   (car val))))))
    (osql-result b v)))

(defun vectorize-resulttypes (fno args)
  "The result type is vectrotype with the type parameters 
   of the 1st bag argument"
  (let ((tp (default-type-parameters (arg-type (car args)))))
    (cond ((osql-subtypep (car tp) _integer_)
	   (list (make-vectortype (cdr tp))))
	  (t (list _object_)))))

(set-resulttypesfn 
 (osql "
create function vectorize(Bag b)-> Vector v
  as foreign 'vectorize-+';")
 'vectorize-resulttypes)

(defun dim-+ (o v i)(osql-result v (array-total-size v)))

(set-type-container
 (osql "
create function dim(Vector)->Integer
  as foreign 'dim-+';"))

(set-type-container
 (osql "
create function vavgstdev(Vector key) -> (Real, Real) 
  as foreign 'vavgstdevbff';"))

(osql "
create function pca(Bag of Vector)
                -> (Vector of Number, Vector of Vector of Number)
  as foreign 'pcabf';")

(osql "
create function tpca(Bag of (Vector, object))
                 -> (Vector of Number, Vector of Vector of Number)
  as foreign 'pcabf';")

(defun project--+ (fno v ind r)
  (catch 'project
    (let (res (dim (length v)))
      (maparray ind (f/l (vi i)
			 (cond ((and (numberp vi)
				     (>= vi 0)
				     (< vi dim)
				     (aref v vi))(push (aref v vi) res))
			       (t (throw 'project nil)))))
      (osql-result v ind (listtoarray (nreverse res))))))
 
(osql "
create function project(Vector v, Vector of Number indl) -> Vector
  /* Project vector v on indexes in indl */
  as foreign 'project--+';")

(defun substv---+(fno x y v r)
  (let ((res (copy-array v)))
    (maparray res (f/l (e i)(if (= x e)(setf(aref res i) y))))
    (osql-result x y v res)))

(set-resulttypesfn
 (osql "
create function substv(Object x, Object y, Vector v) -> Vector
  /* Replace x with y in v */
  as foreign 'substv---+';")
 '(lambda (fno argl)(list (arg-type (third argl)))))

(set-resulttypesfn
 (osql "
create function vectorTuple(Vector v, Integer w)-> Object
  as foreign 'vectorTuple--+';")
 'vector-tuple-resulttypes)

(defun vectorTuple--+ (fno v w &optional rest)
  (apply (function osql-result) v w 
         (firstn w (arraytolist v))))
 
(defun vector-tuple-resulttypes (fno argl)
  (let ((w (cadr argl)))
    (if (numberp w) 
	(buildn w _object_)
      nil)))

(defun aggv--+ (fno bv fn r)
  "Foreign function implementation of aggv() by Cheng Xu"
  (let (argl res dim)
    (mapbag bv 
	    (f/l (e)
		 (cond ((or (null argl) (null res))
                        (setq dim (length (car e)))
			(setq argl (make-array dim))
			(setq res (make-array dim)))
                       ((not (= (length (car e)) dim))
                        (error "Dimension mismatch for aggv" (car e))))
		 (maparray argl (f/l (arg i)
				     (if (null arg) (seta argl i (tconc)))
				     (tconc (elt argl i) 
					    (list (elt (car e) i)))))))
    (maparray res (f/l (o i)
		       (let (r)
			 (assignfunction fn 
					 (list (cons 'aggr_bag 
						     (car (elt argl i)))) '(r))
			 (seta res i r))))
    (osql-result bv fn res)))

(defun aggv-resulttypes (fno argl)
  (if (second argl)
      (list (make-vectortype (function-resulttypes (second argl))))))

(set-resulttypesfn
 (osql "
create function aggv(Bag of Vector bv, Function fn) -> Vector of Number
  as foreign 'aggv--+';")
 'aggv-resulttypes)

; updating vectors

(defvar _array-update_ (new-event 'array-update 'array-rollback))

(foreign-lispfn set_vref ((vector v)(number i)(object o)) ((object))
		(history-add _array-update_ v i (aref v i) o)
		(setf(aref v i)o)
		(foreign-result o))

(foreign-lispfn assign_vref ((vector v)(number i)(object o)) ((vector))
		(if (arrayp v)
		    (let* ((s (length v))
			   (w (if (< i s) v (adjust-array v (1+ i)))))
		      (history-add _array-update_ w i (aref w i) o)
		      (setf(aref w i)o)
		      (foreign-result w))
		  (error "Not a vector" v)))

(foreign-lispfn new_vector ((number size)(object elem))((vector))
		(foreign-result (make-array size :initial-element elem)))

(defun array-rollback (v i old new)
  (setf (aref v i) old))

