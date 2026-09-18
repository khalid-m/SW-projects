;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Thanh Truong, UDBL
;;; $RCSfile: aqit_utilities.lsp,v $
;;; $Revision: 1.16 $ $Date: 2013/08/01 13:07:26 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Utilities
;;; =============================================================
;;; $Log: aqit_utilities.lsp,v $
;;; Revision 1.16  2013/08/01 13:07:26  thatr500
;;; fixed bug in getidentifier0
;;;
;;; Revision 1.15  2013/04/03 15:18:47  thatr500
;;; ordered the rewrite
;;;
;;; Revision 1.14  2013/02/19 05:56:50  thatr500
;;; Limited Search with simple Heuristics
;;;
;;; Revision 1.13  2012/09/06 08:57:40  thatr500
;;; Added code to simplify a conjunction of predicates when it has invalid intervals
;;; of types:  (a, b) or [a, b] or [a, b) or (a, b] or (infinite, a] , (infinite, a)
;;; Example:
;;; (AND (P X)
;;;      (OR (AND (> X 1)
;;;               (< X 0))
;;;          (AND (> X 0)
;;;               (< X 1))))
;;; results in
;;;   (AND (P X)
;;;        (> X 0
;;;        (< X 1))
;;;
;;; Revision 1.12  2012/06/19 14:56:15  thatr500
;;; write to CSV file
;;;
;;; Revision 1.11  2012/06/12 07:38:51  thatr500
;;; added
;;; - sublist(from to list)
;;; - replace-e(pos x l) --> replace element in list l at position pos by x
;;;
;;; Revision 1.10  2012/05/22 13:51:56  thatr500
;;; removed some code not needed when BigIntegrator is ON
;;;
;;; Revision 1.9  2012/05/21 07:31:21  thatr500
;;; Extracting SQL string from a given function now works with Disjunction
;;;
;;; Revision 1.8  2012/04/27 14:29:24  thatr500
;;; to get fully SQL statement
;;; -  getsql ()
;;; -  getsql (Charstring fname)
;;;
;;; to test a pattern (regular expression) against SQL string of a function.
;;; -  contain-sql-pattern(charstring pattern, Charstring fname)
;;; -  contain-sql-pattern(charstring pattern)
;;;
;;; Revision 1.7  2012/04/16 07:33:01  thatr500
;;; modified 'print-cnd ' to print out debug information
;;;
;;; Revision 1.6  2012/02/24 13:51:28  thatr500
;;; added  'print-aqit-transformation' given fname
;;;
;;; Revision 1.5  2012/01/06 13:18:37  torer
;;; New tuple syntax
;;;
;;; Revision 1.4  2012/01/04 14:53:16  thatr500
;;; get index identifier of a mexi index defined through foreign function
;;;
;;; Revision 1.3  2011/12/24 11:40:05  thatr500
;;; removed code
;;;
;;; Revision 1.2  2011/12/20 21:17:02  thatr500
;;; reorganized !
;;;
;;; Revision 1.1  2011/12/02 13:05:55  thatr500
;;; AQit loading order
;;;
;;; Revision 1.9  2011/11/15 10:06:29  thatr500
;;; 'print-cnd' is to print when a condition holds
;;;
;;; Revision 1.8  2011/11/09 11:12:57  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.7  2011/10/07 08:06:23  thatr500
;;; to support Euclidean on 1D (not yet)
;;;
;;; Revision 1.6  2011/09/26 13:16:54  thatr500
;;; Added Intersection distance (for histograms)
;;;
;;; Revision 1.5  2011/08/22 08:19:55  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.4  2011/08/17 08:08:54  thatr500
;;; extractkeyvalue returns a tuple instead of an object
;;;
;;; Revision 1.3  2011/04/11 07:34:25  thatr500
;;; add function to compute index identifier from fn and index-pos
;;;
;;; Revision 1.2  2011/04/05 11:23:28  thatr500
;;; add extractkeyvalue function
;;;
;;; Revision 1.1  2011/03/19 15:13:22  thatr500
;;; separated Mexima and Xtree code
;;;
;;; Revision 1.1  2011/03/04 23:55:56  thatr500
;;; utilities
;;;
;;; =============================================================
(defun insert-after (lst index newelt)
  (push newelt (cdr (nthcdr index lst))) 
  lst)
  
;; Compute index identifier given index postion
;; and function object having index on
;; This function will be invoked at runtime
;; This is the one and the only place where identifier
;; of external index is computed.
(defun get-index-identifier--+ (fno pos;; position of index
				    fname xtid);; function name having index on
  "Get index identifier from given position on given function"
 (osql-result pos fname (get-index-identifier0 pos fname)))
			

(defun get-index-identifier0 (pos;; position of index
				fname);; function name having index on
  "Get index identifier from given position on given function"
  (let* ((ro (get-relation fname)) 
	 (indxl (cond ((null ro) (relation-indexes fname))
		      (t (relation-indexes ro)))
		(relation-indexes ro)) 
	 (idx (nth pos indxl))
	 (mx  (if (neq idx nil) (index-rows idx))))
    (cond ((null mx) -1)
 	  ((is-mexi mx) (mexima-getidentifier mx))
	  (t (mexi-foreign-getid mx)))))

;; Question 
;;    Why the C foreign function takes (index position, function) as
;;    input parameters to compute index identifier which possibly can
;;    be computed in excution plan.?
;; Answer 
;;    If such index identifier (id) appears in excution plan, it makes 
;;    hard-wired execution plan since for some reasons, the id value 
;;    can be changed.i.e: a function is redefined
;;
;;    Therefore, it should be computed at runtime by the foreign function.
;; Compute index identifier
(osql "
 create function get_index_identifier(Integer pos, Function fname) 
   -> Integer xtid
   as multidirectional
      ('bbf' key foreign 'get-index-identifier--+');")

;; Foreign function to extract key value from object o which
;; was stored as index node (key, list of values)
(osql "create function extractkeyvalue(Object o)-> (Object, Object) 
 as foreign 'extractkeyvalue';")


(defun intersection_distancefn (fno v1 v2 dist)
  ;; Interection distance which is mostly used in
  ;; comparing histograms (vectors)
  (let* ((dim (min (length v1) (length v2)))
	 (sum 0))
    (dotimes (i dim) 
      (setq sum (+ sum (min (elt v1 i) (elt v2 i)))))
    (setq sum (- 1 (/ (* sum 1.0) dim))) 	
    (osql-result v1 v2 sum)))

(osql "
create function intersection_distance(Vector of Number v1, Vector of Number v2)->Number 
 as foreign 'intersection_distancefn';")

(defun inter_distfn (fno v1 v2 dist)
  ;; Interection distance which is mostly used in
  ;; comparing histograms (vectors)
  (let* ((dim (min (length v1) (length v2)))
	 (sum 0))
    (dotimes (i dim) 
      (setq sum (+ sum (min (elt v1 i) (elt v2 i)))))
    (osql-result v1 v2 sum)))

(osql "
 create function inter_dist(Vector of Number v1, Vector of Number v2)->Number 
 as foreign 'inter_distfn';")  

(defun mbtree-range-searchfn (fn pos fno lower upper)  
  (map-btree (index-rows 
	      (get-mbtindex-at (get-relation fno) pos)) 
	     (min lower upper) (max lower upper)
	     (f/l (key row)
		  (if (arrayp row)
		      (osql-result pos fno lower upper (arraytolist row))
		    (dolist (r row)
		       (osql-result pos fno lower upper (arraytolist r))))
		  t
		  )))

(osql "
 create function mbtree_range_search(Integer pos, Function fno, Object lower, Object upper)->Object 
 as foreign 'mbtree-range-searchfn';")  

(defun euclid1dfn (fn a b c)
  (osql-result a b (abs (- a b))))

(osql " create function euclid1(Number a, Number b)-> Number c 
 as foreign 'euclid1dfn';")  
;;-------------------------------------------------------------------
;; Predicate utilities
;;-------------------------------------------------------------------
(defun arithmetic-p (pred)
  ;; TRUE if p is an arithmetic predicate (plus, minus, times, div)
  (in (predicate-operator pred)  
      (list _number-plus_ _number-minus_ _number-times_ _number-div_)))

(defun predicate-plus-p (pred)
  (and (predicate-p pred)
       (eq (predicate-operator pred) _number-plus_)))

(defun predicate-minus-p (pred)
  (and (predicate-p pred)
       (eq (predicate-operator pred) _number-minus_)))

(defun predicate-times-p (pred)
  (and (predicate-p pred)
       (eq (predicate-operator pred) _number-times_)))

(defun predicate-div-p (pred)
  (and (predicate-p pred)
       (eq (predicate-operator pred) _number-div_)))

(defun intersection-args (pred1 pred2)
  "Intersection between arguments of two given predicates"
  (intersection (predicate-arguments pred1)
		(predicate-arguments pred2)))

  
;;==============================================================
;; Spatial global variables
;;==============================================================

(defglobal _euclid_ 
  (getfunctionnamed 'VECTOR-NUMBER.VECTOR-NUMBER.EUCLID->NUMBER)
  "The resolvent euclid(Vector, Vector)->Number")

(defglobal _euclid1D_ 
  (getfunctionnamed 'NUMBER.NUMBER.EUCLID1->NUMBER)
  "The resolvent euclid(Number, Number)->Number")

(defglobal _manhattan_ 
  (getfunctionnamed 'VECTOR-NUMBER.VECTOR-NUMBER.MANHATTAN->NUMBER)
  "The resolvent manhattan(Vector, Vector)->Number")

(defglobal _intersection_distance_ 
  (getfunctionnamed 'VECTOR-NUMBER.VECTOR-NUMBER.INTERSECTION_DISTANCE->NUMBER)
  "The resolvent intersection distance(Vector, Vector)->Number")

(defglobal _minkowski_ 
  (getfunctionnamed 'VECTOR-NUMBER.VECTOR-NUMBER.NUMBER.MINKOWSKI->REAL)
  "The resolvent minkowski(Vector, Vector, Number)->Real")


(defglobal _distance-predicates_ (list _euclid_ _euclid1D_ _manhattan_ _intersection_distance_
				        _minkowski_)
  "List of supported distance preidcates")


(defun sort-idxpreds (idxpreds freevars)
  (sort idxpreds 
	(f/l (pa pb) (let (posa posb v 
				(lvars freevars)
				(lavars (cdr pa))
				(lbvars (cdr pb)))

		       (while (and (setq v (pop lavars))
				   (eq posa nil))
			 (setq posa (getpos v lvars)))

		       (if (eq posa nil) (setq posa -10000))
		       (while (and (setq v (pop lbvars))
				   (eq posb nil))
			 (setq posb (getpos v lvars)))
		       (if (eq posb nil) (setq posb -10000))
		       (> posa posb)))))
