;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009 Erik Zeitler, UDBL
;;; $RCSfile: knntest.lsp,v $
;;; $Revision: 1.5 $ $Date: 2012/01/10 07:34:18 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Testing knn implementation
;;; =============================================================
;;; $Log: knntest.lsp,v $
;;; Revision 1.5  2012/01/10 07:34:18  torer
;;; New tuple format
;;;
;;; Revision 1.4  2009/12/12 17:28:20  zeitler
;;; kNN cleanup
;;;
;;; Revision 1.3  2009/10/16 09:31:35  zeitler
;;; System functions removed from application
;;;
;;; Revision 1.2  2009/10/08 22:05:23  zeitler
;;; Pre processing implemented
;;;
;;; Revision 1.1  2009/10/07 09:07:17  zeitler
;;; parameterized knn ref impl:
;;; - k
;;; - metric (optional additional input parameter)
;;; - training data sets
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(checkequal "aggv"
((osql "aggv(knowncoordinates(), #'maxagg');")
 '((#(0.015339 173.8 3.97 3.5 75.41 6.21 16.19 3.15 0.51))))
((osql "aggv(knowncoordinates(), #'minagg');")
 '((#(0.015112 107.3 0 0.34 69.81 0 5.87 0 0)))))

(checkequal "avg of zscore"
 ((osql "select roundto(r, 3) 
  from real r
  where r in aggv(zscore(knowncoordinates()), #'avg');")
  '((0.0) (0.0) (0.0) (0.0) (0.0) (0.0) (0.0) (0.0) (0.0))))

(checkequal "maxmin agg"
((osql "select ma, mi
  from vector of number ma, vector of number mi
  where ma = aggv(maxmin(knowncoordinates()), #'maxagg')
  and mi = aggv(maxmin(knowncoordinates()), #'minagg');")
'((#(1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0)
   #(0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0)))))

(checkequal "all_but_this" 
((osql "count(all_but_this({1,1,1,1,1,1,1,1,1}));")
'((163)))
((caar (osql "count(
select all_but_this(v)
from vector of number v, number c1
where c1 in knownclasses(v));"))
(* 163 162))
((osql "count(
select sort(classdistances(v, #'euclid', 0, bagof(all_but_this(v))))
from vector of number v, number c1
where c1 in knownclasses(v));")
'((163))))

(checkequal "k_nearest"
((osql "sort(
select roundto(computed_dist, 3), computed_class
from number computed_dist, number computed_class
where (computed_dist, computed_class) in
  k_nearest({1,1,1,1,1,1,1,1,1}, 3, #'euclid', 0, 
          (select v, c 
           from vector of number v, number c
           where c in knownclasses(v))));")
'((#(#(127.257 2) #(131.57 5) #(131.606 2))))))

(checkequal "avg estimated confidence of knnclassify of known data"
((osql "select roundto(res, 3)
  from number res
  where res = aggv((
    select {c1, knnclassify(v, 3, #'euclid', 0, all_but_this(v))}
    from vector of number v, number c1
    where c1 in knownclasses(v)), #'avg')[2];")
'((73.589))))

(checkequal "count of knnclassify cross-validation"
((osql "count(select c1, knnclassify(v, 3, #'euclid', 0, all_but_this(v))
    from vector of number v, number c1
    where c1 in knownclasses(v));")
'((163))))

(checkequal "performance of knn cross validation, k = 3"
((osql "count(
select known, knnresult
    from vector of number v, number known, number knnresult
    where known in knownclasses(v)
    and knnresult = knn(v, 3, #'euclid', 0, all_but_this(v))
    and knnresult = known);")
'((90))))

(checkequal "performance of dummy-normalized knn, k in 1..5"
((osql "select k, roundto(prec, 3)
from integer k, real prec
where prec = count(
  select 
  from vector of number v
  where trueclasses(v) =
    knnn(v, k, #'euclid', 0, zeros(9), ones(9), all_knownclasses()))/30.0
and k in iota(1, 5);")
'((1 0.733) (2 0.6) (3 0.633) (4 0.633) (5 0.667))))

(checkequal "performance of (avg, stdev)-normalized knn, k in 1..5"
((osql "select k, roundto(prec, 3)
from integer k, real prec, vector of real div
where prec = count(
  select 
  from vector of number v
  where trueclasses(v) =
    knnn(v, k, #'euclid', 0, zeros(9), div, all_knownclasses()))/30.0
and k in iota(1, 5)
and div = aggv(knowncoordinates(), #'stdev');")
'((1 0.733) (2 0.7) (3 0.733) (4 0.7) (5 0.7))))

(checkequal "performance of (min, max)-normalized knn"
((osql "select k, roundto(prec, 3)
from integer k, real prec, vector of real div, vector of real sub
where prec = count(
  select 
  from vector of number v
  where trueclasses(v) =
    knnn(v, k, #'euclid', 0, sub, div, all_knownclasses()))/30.0
and k in iota(1, 5)
and div = aggv(knowncoordinates(), #'maxagg') - sub
and sub = aggv(knowncoordinates(), #'minagg');")
'((1 0.733) (2 0.733) (3 0.667) (4 0.733) (5 0.667))))

(checkequal "performance of knn using maxnorm (L_oo) metric"
((osql "select k, roundto(prec, 3)
from integer k, real prec
where prec = count(
  select 
  from vector of number v
  where trueclasses(v) =
    knn(v, k, #'maxnorm', 0, all_knownclasses()))/30.0
and k in iota(1, 10);")
'((1 0.7) (2 0.633) (3 0.633) (4 0.6) (5 0.667) (6 0.633) (7 0.633) (8 0.633)
  (9 0.633) (10 0.633))))

(checkequal "knn using Minkowski, r in {0.4, 0.8}"
((osql "select r, k, roundto(prec, 3)
from integer k, integer r, real prec
where prec = count(
  select 
  from vector of number v
  where trueclasses(v) =
    knn(v, k, #'minkowski', 2.0*(r+1)/5.0, all_knownclasses()))/30.0
    and r in iota(0, 1)
    and k = 1;")
'((0 1 0.767) (1 1 0.7))))


(checkequal "(avg, stdev)-norm. knn Minkowski r in {0.4, 0.8}, k in 1..3"
((osql "sort(select r, k, roundto(prec, 3)
from integer k, integer r, real prec, vector of real sub, vector of real div
where prec = count(
  select 
  from vector of number v
  where trueclasses(v) =
    knnn(v, k, #'minkowski', 2.0*(r+1)/5.0, sub, div, all_knownclasses()))/30.0
    and r in iota(0, 1)
    and k in iota(1, 3)
    and sub = aggv(knowncoordinates(), #'avg')
    and div = aggv(knowncoordinates(), #'stdev'));")
'((#(#(0 1 0.833) #(0 2 0.733) #(0 3 0.767) #(1 1 0.8) #(1 2 0.767)
     #(1 3 0.733))))))
