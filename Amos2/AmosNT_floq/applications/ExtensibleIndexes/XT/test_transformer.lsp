;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Thanh Truong, UDBL
;;; $RCSfile: test_transformer.lsp,v $
;;; $Revision: 1.6 $ $Date: 2013/08/01 13:05:49 $
;;; $State: Exp $ $Locker:  $
;;;;; Description: Test cases for inequality transformation
;;; =============================================================
;;; $Log: test_transformer.lsp,v $
;;; Revision 1.6  2013/08/01 13:05:49  thatr500
;;; refined regression test
;;;
;;; Revision 1.5  2012/01/04 14:54:42  thatr500
;;; fixed regression test
;;;
;;; Revision 1.4  2011/11/02 16:56:29  thatr500
;;; Use a new term "AQUIT" (Algebraic Query Inequality Transformation)
;;;
;;; Revision 1.3  2011/10/03 08:33:15  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.2  2011/06/26 07:40:57  thatr500
;;; test ABS
;;;
;;; Revision 1.1  2011/06/25 16:56:37  thatr500
;;; added tests for AQUIT
;;;
;;; =============================================================


(osql "


create function colorHistogram(Charstring pic)->Vector of Number features
  as stored;
create function pId(Charstring pic)->Number id as stored;

create_index('pId', 'id', 'MBTREE' , 'multiple');

create_index('colorHistogram', 'features', 'XTREE' , 'multiple');

add colorHistogram('Pic001')={1.0,2.0,3.0,4.0};
add colorHistogram('Pic002')={1.0,2.0,3.0,5.0};
add colorHistogram('Pic003')={1.0,2.0,2.0,6.0};
add colorHistogram('Pic004')={1.0,2.0,3.0,4.0};
add colorHistogram('Pic005')={5.0,6.0,7.0,8.0};
add colorHistogram('Pic006')={1.0,2.0,3.0,4.0};
add colorHistogram('Pic007')={5.0,6.0,7.0,8.0};

add pId('Pic001')= 1;
add pId('Pic002')= 2;
add pId('Pic003')= 3;
add pId('Pic004')= 4;
add pId('Pic005')= 5;
add pId('Pic006')= 6;
add pId('Pic007')= 7;


remove colorHistogram('Pic004')={1.0,2.0,3.0,4.0};
remove colorHistogram('Pic006')={1.0,2.0,3.0,4.0};

remove colorHistogram('Pic005')={5.0,6.0,7.0,8.0};
remove colorHistogram('Pic007')={5.0,6.0,7.0,8.0};

remove pId('Pic004')= 4;
remove pId('Pic006')= 6;
remove pId('Pic005')= 5;
remove pId('Pic007')= 7;

")

(osql "
create function q3() -> Bag of Charstring
  as select p from Charstring p 
     where 
           euclid(colorHistogram(p), {1, 2, 3, 4}) <= 3.0; ")

(osql "
create function q4(Vector of Number v) -> Bag of Charstring
  as select p from Charstring p 
     where 
           euclid(colorHistogram(p), v) <= 3.0; ")

(osql "
 create function q5(Vector of Number v, Number eps) -> Bag of Charstring
  as select p from Charstring p 
     where 
           euclid(colorHistogram(p), v) <= eps; ")

(osql "
create function q6() -> Bag of Charstring
  as select p from Charstring p 
     where 
           (7 / ((3 + euclid(colorHistogram(p), 
                     {1, 2, 3, 4})) *2 - 1))* 2 - 0.0004 > (2/2 + 0) *1;")


(osql "
create function q7() -> Bag of Charstring
  as select p from Charstring p 
     where 
           4/(4/((7 / ((3 + euclid(colorHistogram(p), 
                     {1, 2, 3, 4})) *2 - 1))* 2)) - 0.0004 
            > (3 - (2/2 + 0)*1 - 1);")

(osql "create function t()-> Number 
   as (2-1)*3/4;")

(osql "
create function q8() -> Bag of Charstring
  as select p from Charstring p 
     where 
           4 / euclid(colorHistogram(p), {1, 2, 3, 4})
            > 0.75;")


;; Should not be transformed !!!
(osql "
create function q80() -> Bag of Charstring
  as select p from Charstring p 
     where 
          (3 - (2/2 + 0)*1 - 1) < 
               1/3/4/
               (4/
                 ((7 / 
                    ((3 + euclid(colorHistogram(p), 
                        {1, 2, 3, 4})) *2 - 1))* 28)) - 0.0004;")

(osql "
create function q81() -> Bag of Charstring
  as select p from Charstring p 
     where 
           4/(4/((7 / ((3 + euclid(colorHistogram(p), 
                     {1, 2, 3, 4})) *2 - 1))* 2)) - 0.0004 
          + 1/1 - 1 > (3 - (2/2 + 0)*1 - 1);")


(osql "
create function q82() -> Bag of Charstring
  as select p from Charstring p 
     where 
           4 / euclid(colorHistogram(p), {1, 2, 3, 4})
            + t() > 1;")

(osql "
create function q9(Charstring cap, Number difference) -> Bag of Number
      as 
  select q
  from Charstring p, Charstring q
  where  euclid(colorHistogram(q), colorHistogram(p)) < difference 
         and p = cap;")

(osql "
create function q10(Number id, Number difference) -> Bag of Number
      as 
  select pId(q)
  from Charstring p, Charstring q
  where  euclid(colorHistogram(q), colorHistogram(p)) < difference 
         and pId(p) = id;")


(osql "
create function q11(Number id, Number difference) -> Bag of Number
      as 
  select pId(q)
  from Charstring p, Charstring q, Number pi, 
       Vector of Number f1, Vector of Number f2
  where 
        f1 =  colorHistogram(q)
     and f2 = colorHistogram(p)
     and pi = pId(p)
     and pi = id
     and euclid(f1, f2) < difference;")

(osql "
create function q12(Number id, Number difference) -> Bag of Number
as 
  select pId(q)
  from Charstring p, Charstring q
  where pId(p) = id
  and   
     1 / 
      power(euclid(colorHistogram(p), 
                    colorHistogram(q)), 2)
         
        > difference;")

(osql "
create function q13(Number id, Number difference) -> Bag of Number
as 
  select pId(q)
  from Charstring p, Charstring q
  where pId(p) = id
  and   1 / 
     (sqrt(euclid(colorHistogram(p), colorHistogram(q))) + 1) 
        > (1 / (1 + difference));
")



(osql "
 create function q14(Vector of Number v, Number eps) -> Bag of Charstring
  as select p from Charstring p 
     where 
           1+1+1+euclid(colorHistogram(p), v)+2+3+4 <= eps; ")


(osql "
create function q15(Number id, Number difference) -> Bag of Number
as 
  select pId(q)
  from Charstring p, Charstring q
  where pId(p) = id
  and   abs(euclid(colorHistogram(p), colorHistogram(q)))
        < difference;
")


(osql "
create function q16(Number id, Number difference) -> Bag of Number
as 
  select pId(q)
  from Charstring p, Charstring q
  where pId(p) = id
  and   abs(euclid(colorHistogram(p), colorHistogram(q)))
        < difference;
")

(osql "
create function q17(Number id, Number difference) -> Bag of Number
as 
  select pId(q)
  from Charstring p, Charstring q, Number d
  where pId(p) = id
  and   d = euclid(colorHistogram(p), colorHistogram(q))
  and   abs(d) < difference;
")

(osql "
create function q18(Number id, Number difference) -> Bag of Number
as 
  select pId(q)
  from Charstring p, Charstring q, Number d
  where pId(p) = id
  and   d = euclid(colorHistogram(p), colorHistogram(q))
  and   (1/2) *(1 - sqrt(power(d, 2) + 0.01)) > difference;
")