(checkequal "avg"
 ((osql "select roundto(a,1), roundto(s,1) 
   from real a, real s
   where (a,s) = avgstdev(iota(1,3));")
  '((2.0 1.0))))

(checkequal "avgstdev on bag of integers"
 ((osql "select roundto(a,1), roundto(s,5)
   from real a, real s
   where (a,s) = avgstdev(iota(1,10));")
  '((5.5 3.02765))))

(checkequal "avgstdev on vector of real"
((osql "select roundto(a,5), roundto(s,5)
  from real a, real s
  where (a,s) = avgstdev(2.55*iota(1,10));")
 '((14.025 7.72051))))

(checkequal "over and underflow in avgstdev"
((osql "roundto(stdev(1e-6*iota(1,3000)), 6);") ;correct
 '((0.000866)))
((osql "roundto(stdev(1e6 - 1e-6*iota(1,3000)), 6);") ;underflow
 '((0.000866)))
((osql "roundto(stdev(1e7 - 1e-6*iota(1,3000)), 6);") ;overflow
 '((0.000866))))

(checkequal "vavg"
 ((osql "select roundto(a,1), roundto(s,1) 
   from real a, real s
   where (a,s) = vavgstdev({1,2,3});")
  '((2.0 1.0))))

(checkequal "vavgstdev on vector of integers"
 ((osql "select roundto(a,1), roundto(s,5)
   from real a, real s
   where (a,s) = vavgstdev(winagg(iota(1,10),10,10));")
  '((5.5 3.02765))))

(checkequal "vavgstdev on vector of real"
((osql "select roundto(a,5), roundto(s,5)
  from real a, real s
  where (a,s) = vavgstdev(winagg(2.55*iota(1,10),10,10));")
 '((14.025 7.72051))))

(rollback)
