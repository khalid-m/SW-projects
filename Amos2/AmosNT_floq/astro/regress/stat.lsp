(checkequal "statistics"
	    ((osql "avgstdev({1,2,3});")
	     '((2.0 1.0))))

(checkequal "avgstdev on vector of integers"
	    ((osql "select roundto(a,1), roundto(s,5) from real a, real s where <a,s> =avgstdev(winagg(iota(1,10),10,10));")
	     '((5.5 3.02765))))

(checkequal "avgstdev on vector of real"
	    ((osql "select roundto(a,5), roundto(s,5) from real a, real s where <a,s> =avgstdev(winagg(2.55*iota(1,10),10,10));")
	     '((14.025 7.72051))))

(rollback)
