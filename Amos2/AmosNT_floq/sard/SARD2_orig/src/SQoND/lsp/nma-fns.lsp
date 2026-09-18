;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011, Andrej Andrejev, UDBL
;;; $RCSfile: nma-fns.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/08/09 14:26:36 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Numeric Multidimensional Array - function library
;;; =============================================================
;;; $Log: nma-fns.lsp,v $
;;; Revision 1.1  2013/08/09 14:26:36  silvias
;;; *** empty log message ***
;;;
;;; Revision 1.10  2013/02/21 23:34:44  andan342
;;; Renamed NMA-PROXY-RESOLVE to APR,
;;; defined all SciSparql foreign functions as proxy-tolerant,
;;; updated the translator to enable truly lazy data retrieval
;;;
;;; Revision 1.9  2013/02/08 00:48:14  andan342
;;; Using C implementation of NMA-PROXY-RESOLVE, including (nma-proxy-enabled)
;;;
;;; Revision 1.8  2013/02/05 14:13:45  andan342
;;; Renamed nma-init to nma-fill, aded more typechecks, removed lisp implementation of RDF:SUM and RDF:AVG
;;;
;;; Revision 1.7  2013/02/04 12:23:43  andan342
;;; Calling nma-vsum implemented in C
;;;
;;; Revision 1.6  2013/02/01 12:02:05  andan342
;;; Using same NMA descriptor objects as proxies
;;;
;;; Revision 1.5  2012/11/19 23:58:09  andan342
;;; - using resolve-nma inside all array-processing functions as part of proxy-allowing polymorphic behavior,
;;; - moved _nma_proxy_threshold_ to core SSDM, setting this value in regression test return NMAs from queries,
;;; - added _nma_limit_ for a max NMA size to be retrieved, printing a warning if exceeded
;;;
;;; Revision 1.4  2012/10/31 00:42:10  andan342
;;; Added the registry of array functions - their respecive arguments are proxy-resolved
;;;
;;; Revision 1.3  2012/04/21 14:41:48  andan342
;;; Added MAX and MIN binary and aggregate functions, regression test for aggregate functions,
;;; fixed reader bug with negative numbers
;;;
;;; Revision 1.2  2012/03/28 09:52:44  andan342
;;; Added generic aggregate functions (SUM, AVG, ...) to operate both on numbers and NMAs
;;;
;;; Revision 1.1  2012/03/27 14:02:19  andan342
;;; Made 'talk.sparql queries work
;;;
;;;
;;; =============================================================

;; ARRAY FUNCTIONS

(osql "
create function rdf:array_count(Literal x) -> Literal
  as foreign 'nma-count-+';

create function array_aggregate(Literal x, Integer fn) -> Literal
  as foreign 'nma-aggregate--+';

create function rdf:array_sum(Literal x) -> Literal
  as array_aggregate(x, 1);

create function rdf:array_avg(Literal x) -> Literal
  as array_aggregate(x, 2);

create function rdf:mean(Literal x) -> Literal
  as array_aggregate(x, 2); /* Alias */

create function rdf:array_min(Literal x) -> Literal
  as array_aggregate(x, 3);

create function rdf:array_max(Literal x) -> Literal
  as array_aggregate(x, 4);
")

(push "array_count" _sq_literal_fns_)
(push "array_sum" _sq_literal_fns_)
(push "array_avg" _sq_literal_fns_)
(push "array_min" _sq_literal_fns_)
(push "array_max" _sq_literal_fns_)

;; ARRAY AGGREGATES
  
(osql "
create function rdf:sum0(Bag of Literal xs) -> Literal as foreign 'rdf-sum-+';
create function rdf:avg0(Bag of Literal xs) -> Literal as foreign 'rdf-avg-+';
  
create function rdf:sum(Bag of Literal xs) -> Literal as rdf:sum0(aapr(in(xs)));
create function rdf:avg(Bag of Literal xs) -> Literal as rdf:avg0(aapr(in(xs)));

create function rdf:meanAgg(Bag of Literal xs) -> Literal as foreign 'rdf-avg-+'; /* Alias */
")

;;funciton names should always be lowercase, w/o 'rdf:' prefix
(push "meanagg" _sq_aggregate_fns_)


(defun rdf-min-max (xs max-p)
  "Return MIN or MAX for bag XS of numbers or arrays of same dimensionality"
  (let (xdims res nextp xr)
    (mapbag xs (f/l (x) (progn
			  (cond ((and (setq xr (apr (car x))) ; if NMA
				      (eq (typename xr) 'nma)
				      (if xdims (equal (nma-dims xr) xdims) ; and 1st elt is NMA of same dimensionality
					(progn ; or start NMA aggregation
					  (setq xdims (nma-dims xr))
					  (setq res (make-nma nma_etype_double (arraytolist xdims)))
					  t)))
				 (nma-iter-reset xr) ; get min/max
				 (nma-iter-reset res)
				 (while t				 
				   (nma-iter-setcur res (if nextp (funcall (if max-p #'max #'min) 
									   (nma-iter-cur res) (nma-iter-cur xr))
							  (nma-iter-cur (car x))))
				   (unless (and (nma-iter-next res)
						(nma-iter-next xr))
				     (return t))))
				((and (numberp (car x)) ; if number
				      (if xdims (eq xdims 'atom) ; and first element was a number
					(progn ; or set start atomic aggregation
					  (setq xdims 'atom)
					  (setq res 0)
					  t)))
				 (setq res (cond ((null nextp) (car x))
						 (max-p (max res (car x)))
						 (t (min res (car x)))))) ; get min/max
				(t (setq xdims 'error)))
			  (setq nextp t))))					
    (unless (eq xdims 'error) ; error otherwise
      res)))

(defun rdf-min-+ (fno xs res)
  (let ((res (rdf-min-max xs nil)))
    (when res
      (osql-result xs res))))

(defun rdf-max-+ (fno xs res)
  (let ((res (rdf-min-max xs t)))
    (when res
      (osql-result xs res))))

(osql "
create function rdf:min0(Bag of Literal xs) -> Literal as foreign 'rdf-min-+';
create function rdf:max0(Bag of Literal xs) -> Literal as foreign 'rdf-max-+';

create function rdf:min(Bag of Literal xs) -> Literal as rdf:min0(aapr(in(xs)));
create function rdf:max(Bag of Literal xs) -> Literal as rdf:max0(aapr(in(xs)));
")

;; Non-aggregating array extensions of RDF-based arithmetics

(defun rdf-min2-max2 (x y max-p)
  (let (xr yr res)
    (cond ((and (numberp x) (numberp y))
	   (if max-p (max x y) (min x y)))
	  ((and (setq xr (apr x))
		(setq yr (apr y))
		(equal (nma-dims xr) (nma-dims yr)))
	   (setq res (make-nma nma_etype_double (arraytolist (nma-dims xr))))
	   (nma-iter-reset res)
	   (nma-iter-reset xr)
	   (nma-iter-reset yr)
	   (while t				 
	     (nma-iter-setcur res (funcall (if max-p #'max #'min) 
					   (nma-iter-cur xr) (nma-iter-cur yr)))
	     (unless (and (nma-iter-next xr)
			  (nma-iter-next yr)
			  (nma-iter-next res))
	       (return t)))
	   res))))


(defun rdf-min2--+ (fno x y res)
  (let ((res (rdf-min2-max2 x y nil)))
    (when res
      (osql-result x y res))))

(defun rdf-max2--+ (fno x y res)
  (let ((res (rdf-min2-max2 x y t)))
    (when res
      (osql-result x y res))))

(osql "
create function rdf:min2(Literal x, Literal y) -> Literal as foreign 'rdf-min2--+';

create function rdf:max2(Literal x, Literal y) -> Literal as foreign 'rdf-max2--+';
")	  






      