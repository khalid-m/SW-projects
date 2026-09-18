;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011, Andrej Andrejev, UDBL
;;; $RCSfile: nma.lsp,v $
;;; $Revision: 1.28 $ $Date: 2013/07/14 11:06:08 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Numeric Multidimensional Array type declarations
;;; =============================================================
;;; $Log: nma.lsp,v $
;;; Revision 1.28  2013/07/14 11:06:08  andan342
;;; Using Integer parameter2 to nma2chunks function
;;;
;;; Revision 1.27  2013/07/12 12:43:15  andan342
;;; Added hexadecimal string option to store binary data on SQL backend (a new parameter to nma2chunks())
;;;
;;; Revision 1.26  2013/02/21 23:34:44  andan342
;;; Renamed NMA-PROXY-RESOLVE to APR,
;;; defined all SciSparql foreign functions as proxy-tolerant,
;;; updated the translator to enable truly lazy data retrieval
;;;
;;; Revision 1.25  2013/02/12 23:48:30  andan342
;;; Disabled single-valued definition of APR
;;;
;;; Revision 1.24  2013/02/08 00:48:14  andan342
;;; Using C implementation of NMA-PROXY-RESOLVE, including (nma-proxy-enabled)
;;;
;;; Revision 1.23  2013/02/05 21:58:36  andan342
;;; Projecting NMA descriptors and proxies with C functions nma-project---+ and nma-project--++
;;;
;;; Revision 1.22  2013/02/05 14:13:45  andan342
;;; Renamed nma-init to nma-fill, aded more typechecks, removed lisp implementation of RDF:SUM and RDF:AVG
;;;
;;; Revision 1.21  2013/02/01 12:02:05  andan342
;;; Using same NMA descriptor objects as proxies
;;;
;;; Revision 1.20  2013/01/28 09:22:13  andan342
;;; Added MOD and DIV functions, cost hints, fixed bug when reading URIs with comma, TODO comments to improve error reporting
;;;
;;; Revision 1.19  2012/12/17 17:35:29  andan342
;;; Added constants to identify NMA element types for C functions
;;;
;;; Revision 1.18  2012/11/26 01:03:40  andan342
;;; Minor bug fixes in PROXY interface
;;;
;;; Revision 1.17  2012/11/19 23:58:09  andan342
;;; - using resolve-nma inside all array-processing functions as part of proxy-allowing polymorphic behavior,
;;; - moved _nma_proxy_threshold_ to core SSDM, setting this value in regression test return NMAs from queries,
;;; - added _nma_limit_ for a max NMA size to be retrieved, printing a warning if exceeded
;;;
;;; Revision 1.16  2012/11/02 19:06:53  andan342
;;; rdf:isArray now returns TRUE on array proxies
;;;
;;; Revision 1.15  2012/10/31 00:42:10  andan342
;;; Added the registry of array functions - their respecive arguments are proxy-resolved
;;;
;;; Revision 1.14  2012/10/29 22:29:28  andan342
;;; Storing NMAs in ArrayChunks table using new BLOB<->BINARY functionality of JDBC interface
;;;
;;; Revision 1.13  2012/09/06 14:08:16  andan342
;;; Refactored polymorphic accessors, added rdf:elttype function
;;;
;;; Revision 1.12  2012/04/14 16:05:24  andan342
;;; Array proxy objects now correctly accumulate STEP information and are completely transparent to array slicing/projection/dereference operations. Added workaraounds for Chelonia step-related bug.
;;;
;;; Revision 1.11  2012/03/27 14:02:19  andan342
;;; Made 'talk.sparql queries work
;;;
;;; Revision 1.10  2012/03/27 10:26:57  andan342
;;; Added C implementations of array aggregates
;;;
;;; Revision 1.9  2012/03/19 11:05:09  andan342
;;; NMA-PROXIES now accumulate ASUB operations, and are resolved automatically in expressions
;;;
;;; Revision 1.8  2012/02/10 11:47:50  andan342
;;; All Amos functions implementing SciSPARQL functions now have/get rdf: namespace
;;;
;;; Revision 1.7  2012/01/30 15:45:10  andan342
;;; Now partially evaluating all simple constructors.
;;; Added call to VERIFY-ALL to regression test, fixed related bugs
;;;
;;; Revision 1.6  2011/09/14 08:40:10  andan342
;;; Enabled arithmetics on RDF literals, added ADIMS accessor to SciSparql
;;;
;;; Revision 1.5  2011/08/09 21:21:19  andan342
;;; Added new dereference-or-project functionality, AmosQL functions Aref and ASub to translate SciSparQL array expressions to
;;;
;;; Revision 1.4  2011/07/20 16:05:20  andan342
;;; Added Permute, Sub & Project array operations to SciSparql
;;; Added AmosQL testcases showing multidirectional array access
;;;
;;; Revision 1.3  2011/07/08 07:38:14  andan342
;;; Defined generic nmaref() function for Literal type
;;;
;;; Revision 1.2  2011/07/06 16:19:22  andan342
;;; Added array transposition, projection and selection operations, changed printer and reader.
;;; Turtle reader now tries to read collections as arrays (if rectangular and type-consistent)
;;; Added Lisp testcases for this and one SparQL query with array variables
;;;
;;; Revision 1.1  2011/06/01 06:15:51  andan342
;;; Defined basic AmosQL functions to handle Numeric Multidimensional Arrays
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(defglobal _nma_)
(defglobal _inma_)
(defglobal _dnma_)
(defglobal _cnma_)

(defun type-of-nma (x)
  (selectq (nma-kind x)
	   (0 _inma_)
	   (1 _dnma_)
	   (2 _cnma_)
	   nil))

(defparameter nma_etype_int 0)
(defparameter nma_etype_double 1)
(defparameter nma_etype_complex 2)

(setq _nma_
  (CREATELITERALTYPE 'NMA (list _literal_) 'nma nil #'type-of-nma))

(setq _inma_
  (CREATELITERALTYPE 'INMA (list _nma_) 'nma nil #'type-of-nma))

(setq _dnma_
  (CREATELITERALTYPE 'DNMA (list _nma_) 'nma nil #'type-of-nma))

(setq _cnma_
  (CREATELITERALTYPE 'CNMA (list _nma_) 'nma nil #'type-of-nma))

(foreign-lispfn rdf:isArray ((Literal x)) ((Boolean)) ;;type-predicate
		(when (eq (typename x) 'nma)
		  (foreign-result 'true)))

(defun inma-+ (fno dims res)
  (osql-result dims (make-nma nma_etype_int (arraytolist dims))))

(defun dnma-+ (fno dims res)
  (osql-result dims (make-nma nma_etype_double (arraytolist dims))))

(defun cnma-+ (fno dims res)
  (osql-result dims (make-nma nma_etype_complex (arraytolist dims))))

(defun nma-dims (x)
  (let* ((ndims (nma-ndims x))
	 (dims (make-array ndims)))
    (dotimes (i ndims dims)
      (setf (aref dims i) (nma-dim x i)))))

(defun are-valid-subscripts (x idxs)
  (when (= (length idxs) (nma-ndims x))
    (let ((k 0))
      (dolist (idx idxs t)
	(when (or (not (integerp idx)) (< idx 0) (>= idx (nma-dim x k)))
	  (return nil))
	(incf k)))))	    

(defun nma-ref--+ (fno x idxs res)
  (when (eq (typename x) 'nma)
    (cond ((numberp idxs) ; if only 1 index provided
	   (when (and (= (nma-ndims x) 1) ; and NMA is 1-dimensional
		      (are-valid-subscripts x (list idxs)))
	     (osql-result x idxs (nma-elt x (list idxs))))) ; create index list
	  (t (let ((idxl (arraytolist idxs)))
	       (when (are-valid-subscripts x idxl)
		 (osql-result x idxs (nma-elt x idxl)))))))) ; use index list

(defun nma-ref-rec (x k kmax idx-stack)
  (let* ((idx-node (list 0))
	 (idx-list (append idx-stack idx-node)))    
    (dotimes (i (nma-dim x k))
      (setf (car idx-node) i)
      (if (= k kmax) (osql-result x (listtoarray idx-list) (nma-elt x idx-list))
	(nma-ref-rec x (1+ k) kmax idx-list))))) ;recursive

(defun nma-ref-++ (fno x idxs res)
  (when (eq (typename x) 'nma)
    (nma-ref-rec x 0 (1- (nma-ndims x)) nil)))

(defun nma-ref1d-++ (fno x idxs res)
  (when (and (eq (typename x) 'nma) (= (nma-ndims x) 1))
    (dotimes (i (nma-dim x 0))
      (osql-result x i (nma-elt x (list i))))))

(osql "
/* NMA Creation */
create function inma(Vector of Integer dims) -> INMA as foreign 'inma-+';
create function dnma(Vector of Integer dims) -> DNMA as foreign 'dnma-+';
create function cnma(Vector of Integer dims) -> CNMA as foreign 'cnma-+';

create function nmaref(Literal x, Vector of Literal idxs) -> Literal as multidirectional
  ('bbf' foreign 'nma-ref--+')
  ('bff' foreign 'nma-ref-++');

/* Multidimensional dereference */
create function vref(INMA x, Vector of Integer idxs) -> Integer as multidirectional
  ('bbf' foreign 'nma-ref--+')
  ('bff' foreign 'nma-ref-++');

create function vref(DNMA x, Vector of Integer idxs) -> Number as multidirectional
  ('bbf' foreign 'nma-ref--+')
  ('bff' foreign 'nma-ref-++');

create function vref(CNMA x, Vector of Integer idxs) -> Complex as multidirectional
  ('bbf' foreign 'nma-ref--+')
  ('bff' foreign 'nma-ref-++');

/* Dereference 1-dimensional NMA:s with single index */

create function nmaref(Literal x, Integer idx) -> Literal as multidirectional
  ('bbf' foreign 'nma-ref--+')
  ('bff' foreign 'nma-ref1d-++');

create function vref(INMA x, Integer idx) -> Integer as multidirectional 
  ('bbf' foreign 'nma-ref--+')
  ('bff' foreign 'nma-ref1d-++');

create function vref(DNMA x, Integer idx) -> Number as multidirectional 
  ('bbf' foreign 'nma-ref--+')
  ('bff' foreign 'nma-ref1d-++');

create function vref(CNMA x, Integer idx) -> Complex as multidirectional 
  ('bbf' foreign 'nma-ref--+')
  ('bff' foreign 'nma-ref1d-++');

")

(defparameter _nma_types_declared_ t)

;; NMA-PROXY interface (implementations are storage-specific)

(osql "
create function apr(Literal x key) -> Literal y key
  as multidirectional
  ('bf' foreign 'APR-+')
  ('fb' select apr(y));

create function aapr(Bag of Literal xs) -> Bag of Literal
  /* identity function - to be re-defined in storage extensions */
  as xs; 
")

;;; ARRAY OPERATIONS

;; Dimensionality access

(defun array-to-inma (x) 
  "Convert 1d array to integer NMA"
  (let ((res (make-nma nma_etype_int (list (length x)))))
    (nma-fill res (arraytolist x))
    res))

(defun nma-dims-+ (fno x res)
  (when (eq (typename x) 'nma)
    (osql-result x (nma-dims x))))

(defun nma-adims-+ (fno x res)
  (when (eq (typename x) 'nma)
    (osql-result x (array-to-inma (nma-dims x)))))

(defun nma-kind-+ (fno x res)
  (when (eq (typename x) 'nma)
    (osql-result x (nma-kind x))))

(osql "
create function dims(NMA x) -> Vector of Integer as foreign 'nma-dims-+';

create function rdf:dims(NMA x) -> Vector of Integer as foreign 'nma-dims-+'; /* RDF Alias */

create function adims(Literal x) -> Literal as foreign 'nma-adims-+';

create function rdf:adims(Literal x) -> Literal as foreign 'nma-adims-+'; /* RDF Alias */

create function rdf:elttype(Literal x) -> Integer as foreign 'nma-kind-+';
")

;; Index permutations

(defun array-every (a)
  "return T if all array elements are non-NIL"
  (dotimes (i (length a) t)
    (unless (aref a i)
      (return nil))))

(defun is-permutation-idxs (idxs)
  "return T if IDXS contains permutaion sequence, like #(3 0 2 1)"
  (let* ((n (length idxs))
	 (bidxs (make-array n)) idx)
    (dotimes (i n (array-every bidxs))
      (setq idx (aref idxs i))
      (if (and (numberp idx) (>= idx 0) (< idx n))
	  (setf (aref bidxs idx) t)
	(return nil)))))

(defun nma-permute--+ (fno x pidxs res) ; TODO: reverse permutation
  (when (and (eq (typename x) 'nma) (= (length pidxs) (nma-ndims x)) (is-permutation-idxs pidxs))
    (osql-result x pidxs (nma-permute x (arraytolist pidxs)))))

(defun nma-transpose-+ (fno x res)
  (when (and (eq (typename x) 'nma) (= (nma-ndims x) 2)) ;2d arrays only
    (osql-result x (nma-permute x '(1 0)))))

(osql "
create function permute(Literal x, Vector of Integer pidxs) -> NMA
  as foreign 'nma-permute--+';

create function rdf:permute(Literal x, Vector of Integer pidxs) -> NMA
  as foreign 'nma-permute--+'; /* RDF Alias */

create function transpose(Literal x) -> NMA as multidirectional
  ('bf' foreign 'nma-transpose-+')
  ('fb' foreign 'nma-transpose-+');

create function rdf:transpose(Literal x) -> NMA as transpose(x); /* RDF Alias */
")

;; Spread-out dereference-projection


(defun nma-sub-----+ (fno x k lo step hi res) ;TODO: lo or hi might be unbound
  (when (and (>= k 0)  ;k is Integer
	     (integerp lo) (>= lo 0) ;lo is Literal
	     (integerp step) (>= step 1) ;step is Literal
	     (integerp hi)) ;hi is Literal
    (cond ((and (eq (typename x) 'nma) ;x is Literal
		(< k (nma-ndims x)) ;k is Integer
		(< lo (nma-dim x k)) ;lo is Literal		
		(< hi (nma-dim x k))) ;hi is Literal
	   (osql-result x k lo step hi (nma-subset x k lo step (if (< hi 0) (1- (nma-dim x k)) hi))))
	  )))
;	  ((and (nma-proxy-p x) _nma_proxy_apply_range_)
;	   (osql-result x k lo step hi (funcall _nma_proxy_apply_range_ x k lo step hi))))))

	  	 
(osql "
create function aref(Literal x, Integer k, Literal idx) -> Literal 
  as multidirectional
  ('bbbf' foreign 'nma-project---+')
  ('bbff' foreign 'nma-project--++' cost {1,1000});

create function asub(Literal x, Integer k, Literal lo, Literal step, Literal hi) -> Literal
  as foreign 'nma-sub-----+';
")

;; rdf:first and rdf:rest compatibility

(defun rdf-first-+ (fno x res)
  (when (eq (typename x) 'nma)
    (osql-result x (if (= (nma-ndims x) 1)
		       (nma-elt x '(0))
		     (nma-project x 0 0)))))

(defun rdf-rest-+ (fno x res)
  (when (eq (typename x) 'nma)
    (let ((d0 (nma-dim x 0)))
      (osql-result x (if (> d0 1) (nma-subset x 0 1 1 (1- d0))
		       (uri "http://www.w3.org/1999/02/22-rdf-syntax-ns#nil"))))))

(osql "
create function rdf:first(Literal x) -> Literal
  as foreign 'rdf-first-+';

create function rdf:rest(Literal x) -> Literal
  as foreign 'rdf-rest-+';
")

;; NMA2chunks functionality

(osql "
create function NMA2Chunks(NMA x, Integer chunkSize, Integer isHex) -> Bag of (Integer chunkId, Binary chunk)
  as foreign 'NMA2Chunks--++';

create function NMA2FragmentSIs(NMA x) -> Bag of (Integer si, Integer fsize)
  as foreign 'NMA2FragmentSIs-++';
")



