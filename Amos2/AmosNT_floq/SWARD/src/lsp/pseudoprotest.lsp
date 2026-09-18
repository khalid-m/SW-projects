;;; Help functions
(defun probe-call (fn argl)
  (probe-query (internalize fn argl)))

(defun internalize (fn argl)
  (cons (getfunctionnamed fn) argl))

;;; Test cases probing:
(checkequal "Probing"
	    ((probe-call 'number.number.plus->number '(1 2 x)) '((3)))
	    ((probe-call 'number.number.plus->number '(1 x 2)) '((1)))
	    ((probe-call 'number.number.plus->number '(1 2 3)) '((true)))
	    ((probe-call 'number.number.plus->number '(1 2 2)) nil)
	    ((probe-call 'number.number.plus->number '(x y 2)) 'fail)
	    )

;;;Test cases partial evaluation (setup):

;;Defining andl1:
;;select "ok" 
;;where 
;;      pMap("ORDERS","ORDERID","udbl.it.uu.se/schemas/company","udbl.it.uu.se/schemas/company#OrderID");
(defglobal _andl1_ (list 'AND
(internalize 'object.object.=->boolean '(_V1 "ok"))
(internalize 'charstring.charstring.charstring.charstring.pmap->boolean 
	     '("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" "udbl.it.uu.se/schemas/company#OrderID"))))

(defglobal _andl1fv_ (list '_V1))

;;;Defining the result of andl1: and1lr
(defglobal _andl1r_ (internalize 'object.object.=->boolean '(_V1 "ok")))

;;Defining andl2:
;;select "ok" 
;;where 
;;      pMap("ORDERS","ORDERID","udbl.it.uu.se/schemas/company","udbl.it.uu.se/schemas/company#FOO");
(defglobal _andl2_ (list 'AND
(internalize 'object.object.=->boolean '(_V1 "ok"))
(internalize 'charstring.charstring.charstring.charstring.pmap->boolean 
	     '("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" "udbl.it.uu.se/schemas/company#FOO"))))

(defglobal _andl2fv_ (list '_V1))

;;;Defining the result of andl2: andl2r
(defglobal _andl2r_ 'FALSE)

;;;Defining andl3:
;;;select p1
;;;from Charstring p1
;;;where 
;;;      pMap("ORDERS","ORDERID","udbl.it.uu.se/schemas/company",p1) and true;
(defglobal _andl3_ 
      (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" P1)))

(defglobal _andl3fv_ (list 'P1))

(defglobal _andl3r_ 
      (internalize 'object.object.=->boolean '("udbl.it.uu.se/schemas/company#OrderID" P1)))

;;;Defining andl4:
;;;select p
;;;from Charstring col, Charstring p 
;;;where
;;;      pMap("ORDERS",col,"udbl.it.uu.se/schemas/company",p);
(defglobal _andl4_ 
      (internalize 'charstring.charstring.charstring.charstring.pmap->boolean 
		   '("ORDERS" COL "udbl.it.uu.se/schemas/company" P)))
(defglobal _andl4fv_ (list 'P))


(defglobal _andl4r_ 
   (internalize 'charstring.charstring.charstring.charstring.pmap->boolean 
	       '("ORDERS" COL "udbl.it.uu.se/schemas/company" P)))

;;;Defining andl5:
;;;select p
;;;from Charstring col, Charstring p 
;;;where
;;;      pMap("FOO",col,"udbl.it.uu.se/schemas/company",p);
(defglobal _andl5_ 
      (internalize 'charstring.charstring.charstring.charstring.pmap->boolean 
		   '("FOO" COL "udbl.it.uu.se/schemas/company" P)))

(defglobal _andl5fv_ (list 'P))

(defglobal _andl5r_ 'FALSE)

;;;Defining andl6
(defglobal _andl6_ 
      (internalize 'number.number.plus->number '(x y 2)))

(defglobal _andl6fv_ 
      (list 'X 'Y))

(defglobal _andl6r_  
   (internalize 'number.number.plus->number '(x y 2)))

;;;Defining andl7:
;;;select p1,c1
;;;from Charstring p1, Charstring t1, Charstring c1
;;;where 
;;;      pMap("ORDERS","ORDERID","udbl.it.uu.se/schemas/company",p1) and
;;;      pMap(t1,"OCUSTID","udbl.it.uu.se/schemas/company","udbl.it.uu.se/schemas/company#OrderCustomer") and
;;;      cMap(t1,"udbl.it.uu.se/schemas/company", c1);
(defglobal _andl7_ 
      (list 'AND (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" P1))
	    (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '(T1 "OCUSTID" "udbl.it.uu.se/schemas/company" "udbl.it.uu.se/schemas/company#OrderCustomer"))
	    (internalize 'charstring.charstring.charstring.cmap->boolean '(T1 "udbl.it.uu.se/schemas/company" C1))))

(defglobal _andl7fv_ (list 'P1 'C1))

(defglobal _andl7r_ 
      (list 'AND
	    (internalize 'object.object.=->boolean '("udbl.it.uu.se/schemas/company#OrderID" P1))
	    (internalize 'object.object.=->boolean '("udbl.it.uu.se/schemas/company#Orders" C1))))

;;;Defining andl8:
;;;select p1, p2
;;;from Charstring p1, Charstring p2
;;;where 
;;;      pMap("ORDERS","FOO","udbl.it.uu.se/schemas/company",p1) and
;;;      pMap("ORDERS","OCUSTID","udbl.it.uu.se/schemas/company",p2);
(defglobal _andl8_ 
      (list 'AND (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "FOO" "udbl.it.uu.se/schemas/company" P1))
	    (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "OCUSTID" "udbl.it.uu.se/schemas/company" P2))))

(defglobal _andl8fv_ (list 'P1 'P2))

(defglobal _andl8r_ 'FALSE)

;;;Defining orl1
;;;select p 
;;;from Charstring p
;;;where
;;;      pMap("ORDERS","ORDERID","udbl.it.uu.se/schemas/company",p) or
;;;      pMap("FOO","OCUSTID","udbl.it.uu.se/schemas/company",p);
(defglobal _orl1_ (list 'OR 
	   (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" P))
	   (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '("FOO" "OCUSTID" "udbl.it.uu.se/schemas/company" P))))

(defglobal _orl1fv_ (list 'P))

(defglobal _orl1r_ 
   (internalize 'object.object.=->boolean '("udbl.it.uu.se/schemas/company#OrderID" P)))

;;;Defining orl2
;;;select p 
;;;from Charstring p
;;;where
;;;      pMap("ORDERS","ORDERID","udbl.it.uu.se/schemas/company",p) or 
;;;      pMap("ORDERS","ORDERID","udbl.it.uu.se/schemas/company","udbl.it.uu.se/schemas/company#OrderID");
(defglobal _orl2_ (list 'OR 
	   (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" P))
	   (internalize 'charstring.charstring.charstring.charstring.pmap->boolean 
	     '("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" "udbl.it.uu.se/schemas/company#OrderID"))))

(defglobal _orl2fv_ (list 'P))

(defglobal _orl2r_ 'TRUE)

;;;Defining orl3
;;;select p 
;;;from Charstring p
;;;where
;;;      (pMap("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" "udbl.it.uu.se/schemas/company#OrderID") or 
;;;       pMap("ORDERS","OCUSTID","udbl.it.uu.se/schemas/company","udbl.it.uu.se/schemas/company#OrderCustomer")) and
;;;       pMap("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" P);
(defglobal _orl3_ (list 'AND (list 'OR 
	   (internalize 'charstring.charstring.charstring.charstring.pmap->boolean 
	     '("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" "udbl.it.uu.se/schemas/company#OrderID"))
	   (internalize 'charstring.charstring.charstring.charstring.pmap->boolean 
             '("ORDERS","OCUSTID","udbl.it.uu.se/schemas/company","udbl.it.uu.se/schemas/company#OrderCustomer")))
	   (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" P))))

(defglobal _orl3fv_ (list 'P))

(defglobal _orl3r_  (internalize 'object.object.=->boolean '("udbl.it.uu.se/schemas/company#OrderID" P)))

;;;Defining andorl1
;;;select p1, p2
;;;from Charstring p1, Charstring p2
;;;where 
;;;      pMap("ORDERS","ORDERID","udbl.it.uu.se/schemas/company",p1) and
;;;      (pMap("ORDERS","OCUSTID","udbl.it.uu.se/schemas/company",p2) or
;;;       pMap("ORDERS","FOO","udbl.it.uu.se/schemas/company",p2));	

(defglobal _andorl1_ (list 'AND
   (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" P1))
	(list 'OR 
	      (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "OCUSTID" "udbl.it.uu.se/schemas/company" P2))
	      (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "FOO" "udbl.it.uu.se/schemas/company" P2)))))

(defglobal _andorl1fv_ (list 'P1 'P2))

(defglobal _andorl1r_ 
   (list 'AND 
	 (internalize 'object.object.=->boolean '("udbl.it.uu.se/schemas/company#OrderID" P1))
	 (internalize 'object.object.=->boolean '("udbl.it.uu.se/schemas/company#OrderCustomer" P2))))

;;;Defining orandl1
;;;select p1, p2
;;;from Charstring p1, Charstring p2
;;;where 
;;;      (pMap("ORDERS","ORDERID","udbl.it.uu.se/schemas/company",p1) and
;;;       pMap("ORDERS","OCUSTID","udbl.it.uu.se/schemas/company",p2)) or
;;;      (pMap("ORDERS","OCUSTID","udbl.it.uu.se/schemas/company",p1) and
;;;       pMap("ORDERS","FOO","udbl.it.uu.se/schemas/company",p2));

(defglobal _orandl1_ 
   (list 'OR
      (list 'AND 
	   (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" P1))
	   (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "OCUSTID" "udbl.it.uu.se/schemas/company" P2)))
      (list 'AND 
	   (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "OCUSTID" "udbl.it.uu.se/schemas/company" P1))
	   (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "FOO" "udbl.it.uu.se/schemas/company" P2)))))

(defglobal _orandl1fv_ (list 'P1 'P2))

(defglobal _orandl1r_ 
   (list 'AND 
	 (internalize 'object.object.=->boolean '("udbl.it.uu.se/schemas/company#OrderID" P1))
	 (internalize 'object.object.=->boolean '("udbl.it.uu.se/schemas/company#OrderCustomer" P2))))

;;;Defining orandl2
;;;select p1, p2
;;;from Charstring p1, Charstring p2
;;;where 
;;;      (pMap("ORDERS","ORDERID","udbl.it.uu.se/schemas/company",p1) and
;;;       pMap("ORDERS","FOO","udbl.it.uu.se/schemas/company",p2)) or
;;;      (pMap("ORDERS","FOO","udbl.it.uu.se/schemas/company",p1) and
;;;       pMap("ORDERS","OCUSTID","udbl.it.uu.se/schemas/company",p2));

(defglobal _orandl2_ 
   (list 'OR
      (list 'AND 
	   (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" P1))
	   (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "FOO" "udbl.it.uu.se/schemas/company" P2)))
      (list 'AND 
	   (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "FOO" "udbl.it.uu.se/schemas/company" P1))
	   (internalize 'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "OCUSTID" "udbl.it.uu.se/schemas/company" P2)))))

(defglobal _orandl2fv_ (list 'P1 'P2))

(defglobal _orandl2r_  'FALSE)

;;;Defining andorandl1
;;;select p1
;;;from Charstring p1
;;;where 
;;;      ((pMap("ORDERS","ORDERID","udbl.it.uu.se/schemas/company",p1) and
;;;       pMap("ORDERS","ORDERID","udbl.it.uu.se/schemas/company","udbl.it.uu.se/schemas/company#OrderID")) or
;;;      (pMap("ORDERS","ORDERID","udbl.it.uu.se/schemas/company",p1) and
;;;       pMap("ORDERS","OCUSTID","udbl.it.uu.se/schemas/company","udbl.it.uu.se/schemas/company#OrderID"))) and
;;;      ((pMap("ORDERS","ORDERID","udbl.it.uu.se/schemas/company",p1) and
;;;       pMap("ORDERS","ORDERID","udbl.it.uu.se/schemas/company","udbl.it.uu.se/schemas/company#OrderCustomer")) or
;;;      (pMap("ORDERS","ORDERID","udbl.it.uu.se/schemas/company",p1) and
;;;       pMap("ORDERS","OCUSTID","udbl.it.uu.se/schemas/company","udbl.it.uu.se/schemas/company#OrderCustomer")))

(defglobal _andorandl1_ (list 'AND 
	       (list 'OR 
		     (list 'AND 
			   (internalize 
'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" P1))
			   (internalize 
'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" "udbl.it.uu.se/schemas/company#OrderID")))
		     (list 'AND 
			   (internalize 
'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" P1))
			   (internalize 
'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "OCUSTID" "udbl.it.uu.se/schemas/company" "udbl.it.uu.se/schemas/company#OrderID"))))
	       (list 'OR 
		     (list 'AND 
			   (internalize 
'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" P1))
			   (internalize 
'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" "udbl.it.uu.se/schemas/company#OrderCustomer")))
		     (list 'AND 
			   (internalize 
'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "ORDERID" "udbl.it.uu.se/schemas/company" P1))
			   (internalize 
'charstring.charstring.charstring.charstring.pmap->boolean '("ORDERS" "OCUSTID" "udbl.it.uu.se/schemas/company" "udbl.it.uu.se/schemas/company#OrderCustomer"))))))

(defglobal _andorandl1fv_ (list 'P1))

(defglobal _andorandl1r_  
  (list 'AND 
	(internalize 'object.object.=->boolean '("udbl.it.uu.se/schemas/company#OrderID" P1))
	(internalize 'object.object.=->boolean '("udbl.it.uu.se/schemas/company#OrderID" P1))))

;;;Defining andorandl2

(defglobal _andorandl2_ 
  (list 'AND 
	(list 'OR 
	      (list 'AND 
		    (list "OID" 1 2 3 'g)
		    (list "OID" 1 2 3 'h))
	      (list "OID" 1 2 3 'd))
	(list "OID" 1 2 3 'c)
	(list "OID" 1 2 3 'b)
	(list 'OR (list "OID" 1 2 3 'g)
	      (list "OID" 1 2 3 'g))))

(defglobal _andorandl2fv_ (list 'H))

(defglobal _andorandl2r_ (list 'G 'H))


;;;Test cases partial evaluation:
(checkequal "Check simple AND list with arguments as constants (true): andl1"
	    ((parteval _andl1_ _andl1fv_) _andl1r_))

(checkequal "Check simple AND list with arguments as constants (false): andl2"
	    ((parteval _andl2_ _andl2fv_) _andl2r_))

(checkequal "Check pred with some arguments as constants -> res = 1 (addequals): andl3"
	    ((parteval _andl3_ _andl3fv_) _andl3r_))

(checkequal "Check pred with some arguments as constants -> res > 1 (skip): andl4"
	    ((parteval _andl4_ _andl4fv_) _andl4r_))

(checkequal "Check pred with some arguments as constants -> res < 1 (false): andl5"
	    ((parteval _andl5_ _andl5fv_) _andl5r_))

(checkequal "Check pred with some arguments as constants -> pred (fail): andl6"
	    ((parteval _andl6_ _andl6fv_) _andl6r_))

(checkequal "Check simple AND list with some arguments as constants -> res = 1 (substitution): andl7"
	    ((parteval _andl7_ _andl7fv_) _andl7r_))

(checkequal "Check simple AND list with some arguments as constants -> false (first conjunct): andl8"
	    ((parteval _andl8_ _andl8fv_) _andl8r_))

(checkequal "Check simple OR list with some arguments as constants -> res = 1 (addequals), false: orl1"
	    ((parteval _orl1_ _orl1fv_) _orl1r_))

(checkequal "Check simple OR list with some arguments as constants. Testing set semantics."
	    ((parteval _orl2_ _orl2fv_) _orl2r_))

(checkequal "Check simple OR list with some arguments as constants. Testing set semantics."
	    ((parteval _orl3_ _orl3fv_) _orl3r_))

(checkequal "Check complex ANDOR list (3 pred) with some arguments as constants -> 1 result, 1 result, 1 false: andorl1"
	    ((parteval _andorl1_ _andorl1fv_) _andorl1r_))

(checkequal "Check complex ORAND list (4 pred) with some arguments as constants -> 1 result, 1 result, 1 result, 1 false,: orandl1"
	    ((parteval _orandl1_ _orandl1fv_) _orandl1r_))

(checkequal "Check complex ORAND list (4 pred) with some arguments as constants -> 1 result, 1 false, 1 result, 1 false,: orandl2"
	    ((parteval _orandl2_ _orandl2fv_) _orandl2r_))

(checkequal "Check complex ANDORAND list (8 pred) with some arguments as constants -> 2 result,2 AND false,2 AND true: andorandl1"
	    ((parteval _andorandl1_ _andorandl1fv_) _andorandl1r_))

(checkequal "Check complex ANDORAND list (7 pred) for finding free variables -> H and G: andorandl2"
	    ((addfv _andorandl2_ _andorandl2fv_) _andorandl2r_))






