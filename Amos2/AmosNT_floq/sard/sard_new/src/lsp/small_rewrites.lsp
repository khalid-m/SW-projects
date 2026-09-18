;;; ===========================================================================
;;; AMOS2
;;;
;;; Author: (c)2010 Silvia Stefanova, UDBL
;;; $RCSfile: small_rewrites.lsp,v $
;;; $Revision: 1.30 $ $Date: 2012/08/24 15:53:28 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Rewrites for unbloun-property queries to and RDF view of RDBMS
;;;;;; ===========================================================================

(defun subsublist (l ll)
  "Subtsract the list ll from list l"
  (let ((res nil)
	(llels nil))
    (cond ((null ll) (setf res l))
	  ((atom ll)  (setf res l))	 
	  (t 
	   (if (listp (car ll)) (setf llels (car ll))
	     (setf llels ll))
	   (mapcar (f/l (els)
			(if (equal els llels) (setf res (cons nil res))
			  (setf res (cons els res)))) l)
	   (setf res (nreverse (remove 'nil res)))))
    res))


(defun string-like-withinlist (lofstring compstring)
"Finds the string correposnding to compstring within the list lofstring"
  (if (and (listp lofstring) (listp (car lofstring)))
      (mapcar (f/l (el)
		   (if (string-like-i (car (last el)) compstring)
		       (car (last el))))  lofstring) ))
	  



(defun rewrite-rowid-and-like-old (con)
"Rewrites a conjunction whose conjuncts include rowid and like"
  (cond ((atom con) con)
	((null (cddr con)) con)
	((null (eq 'AND (car con))) con);;if con is not a conjunction
	(t
	 (let ((ht (make-hash-table :test (function equal)))
	       (res con))
	   (dolist (c (cdr con) )
	     (if (eq (oid-name (first c)) 'CHARSTRING.CHARSTRING.LIKE->BOOLEAN)
		 (progn ;; if c is a like predicate
		   (if (gethash (second c) ht) ;;if there is an elem in ht with key=subject
		       (setf (gethash (second c) ht) (cons c (gethash (second c) ht) ) ) ;;if yes, adds to it by 'cons'
		     (setf (gethash (second c) ht) (list c) ) );;if no puts the like pred in ht with key =subject
		   )
	       (progn ;; if c is not like predicate
		 (if (eq (oid-name (first c)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING);; if c is a rowid predicate
		     (if (gethash (car (last c)) ht) ;;if there is an elem in ht with key=subject
			 (setf (gethash (car (last c)) ht) (cons c (gethash (car (last c)) ht))) ;;if yes, adds to by 'cons'
		       (setf (gethash (car (last c)) ht) (list c) ) );;if no puts the like pred in ht with key =subject
		   )))
	     )
	   (maphash (f/l (key predlist);;goes through the ht
			 (let ((rowid nil)
			       (likelist nil) )
			   (dolist (pr predlist rowid)
			     (if (listp pr)
				 (progn 
				   (if (eq (oid-name (first pr)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING);; if c is a rowid predicate
				       (setf rowid pr)))))
			   (if (null (null rowid));;if rowid is not empty
			       (progn
				 (setf likelist (subsublist predlist rowid))
				 (mapcar (f/l (els)  
					      (if (string-like-i (second rowid) (third els));;if the rowid and like strings match
						  (setf res (subsublist res els)) ;;rewrites rowid-and-like to rowid
						(if (string-like (third els) "*/_*") ;;if the strings do not match
						    (if (string-like
							 (second rowid) (substring 0 (- (string-pos (third els) "/_" ) 1) (third els ) )  )
							(setf res res)
						      (setf res nil)) ;;rewrites the conjunction to nil
						  (setf res nil))
						) ) likelist)  )
			     (setf res res));;if rowid is empty
			   )) ht)
	   res))))

(defun rewrite-rowid-and-like (con)
"Rewrites a conjunction whose conjuncts include rowid and like"
  (cond ((atom con) con)
	((null (cddr con)) con)
	((null (eq 'AND (car con))) con);;if con is not a conjunction
	(t
	 (let ((ht (make-hash-table :test (function equal)))
	       (res con))
	   (dolist (c (cdr con) )
	     (if (or (eq (oid-name (first c)) 'CHARSTRING.CHARSTRING.LIKE->BOOLEAN);; if c is a like or comparison predicate
		     (eq (oid-name (first c)) 'OBJECT.OBJECT.>->BOOLEAN)
		     (eq (oid-name (first c)) 'OBJECT.OBJECT.<->BOOLEAN) 
		     (eq (oid-name (first c)) 'OBJECT.OBJECT.!=->BOOLEAN))
		 (progn 
		   (if (gethash (second c) ht) ;;if there is an elem in ht where key=variable (s,p,o)
		       (setf (gethash (second c) ht) (cons c (gethash (second c) ht) ) ) ;;if yes, adds it to the ht by cons
		     (setf (gethash (second c) ht) (list c) ) );;if no puts the like pred in ht with key =subject
		   )
	       (progn ;; if c is either rowid or valueid predicate
		 (if (or (eq (oid-name (first c)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING)
			 (eq (oid-name (first c)) 'LITERAL.CHARSTRING.VALUEID->CHARSTRING) )
		     (if (gethash (car (last c)) ht) ;;if there is an elem in ht with key=var
			 (setf (gethash (car (last c)) ht) (cons c (gethash (car (last c)) ht))) ;;if yes, adds to by 'cons'
		       (setf (gethash (car (last c)) ht) (list c) ) );;if no puts the like pred in ht with key =subject
		   )) )
	     )
	   (maphash (f/l (key predlist);;goes through the ht
			 (let ((rowid nil)
			       (likelist nil)
			       ( newel nil))
			   (dolist (pr predlist rowid)
			     (if (listp pr)
				 (progn 
				   (if (or (eq (oid-name (first pr)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING);; if c is a rowid predicate
					   (eq (oid-name (first pr)) 'LITERAL.CHARSTRING.VALUEID->CHARSTRING))
				       (setf rowid pr)))))
			   (if (null (null rowid));;if rowid is not empty
			       (progn
				 (setf likelist (subsublist predlist rowid));;goes through the rest 
				 (mapcar (f/l (els)  ;;goes through the rest of the ht element
					      (cond ((and (eq (oid-name (first els)) 'CHARSTRING.CHARSTRING.LIKE->BOOLEAN)
							  (eq (oid-name (first rowid)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING))
						     (progn
						       (if (string-like-i (second rowid) (third els));;if the rowid and like strings match
							   (setf res (subsublist res els)) ;;rewrites rowid-and-like to rowid
							 (if (string-like (third els) "*/_*") ;;checks this if the string do not match
							     (if (string-like
								  (second rowid) (substring 0 (- (string-pos (third els) "/_" ) 1) (third els ) )  )
								 (setf res res);;if the rowid doesn't match the string but contains '/_'
							       (setf res nil)));;if the rowid doesn't match the string and '/_' rewrites the conjunction to nil
							   (setf res nil)) ) )
						    ((eq (oid-name (first rowid)) 'LITERAL.CHARSTRING.VALUEID->CHARSTRING);;if it is a valueid-works only for Literals				
						     (setf newel (list (first els) (second rowid) (third els) ) );; replaces the variables and reconstruct the con
						     (setf res (andify (list (subsublist res els) newel))))
						    ((and (eq (oid-name (first rowid)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING);;> and < on rowid not allowed
							   (or (eq (oid-name (first els)) 'OBJECT.OBJECT.>->BOOLEAN)
							       (eq (oid-name (first els)) 'OBJECT.OBJECT.<->BOOLEAN)))
						     (setf res nil)))) likelist)  )
			     (setf res res));;if rowid is empty
			   )) ht)
	   res))))


(defun unify-tuple-and-vector (con)
"Unifies ( tuple and vector )"
 (let ((new nil)
       (vec '())
       (tup '())
       (resl nil)
       (res nil))
   (dolist (c con)
     (if (eq  'TUPLE (oid-name (car c)))
	 (push c tup)
       (if (eq  'VECTOR (oid-name (car c)))
	   (push c vec))))
   (dolist (tt tup )
     (setf resl nil)
     (dolist (vv vec)
       (setf new (list (car vv) (second tt) (third tt)));;constructs vector with tuple's vars
       (if (hasuniquecommonvar new vv )
	   (progn
	     (setf new (inferequals (list new vv)))
	     (setf  resl new))) )
     (if (null resl)
	 (setf res (cons tt res))
       (dolist (el resl)
	 (setf res (cons el res)))))
   (dolist (c con)
     (if (neq  'TUPLE (oid-name (car c)))
	 (setf res (cons c res))))
   res))
   

(defun rewrite-rowid-and-rowidfk (con sb)
"Rewrites a conjunction includong rowid and rowid-fk"
  (cond ((atom con) con)
	((null (cddr con)) con)
	((null (eq 'AND (car con))) con);;if con is not a conjunction
	(t
	 (let ((ht (make-hash-table :test (function equal)))
	       (htk nil)
	       (res1 nil)
	       (res nil))
	   (dolist (c (cdr con) )
	      (if (or (eq 'CHARSTRING.VECTOR.ROWID->CHARSTRING (oid-name (car c)))
		      (eq 'CHARSTRING.TUPLE.ROWID_FK->CHARSTRING (oid-name (car c))))
		  (progn
		    (setf htk (list (car c) (second c) (cadddr c)) );;rd is rowid or rowid_fk, htk=(oid-name,string,last var)
		    (setf (gethash htk ht) c))));;record in ht with key=htk
	   (maphash (f/l (key1 rec1)
			 (maphash (f/l (key2 rec2)
				       (if (and (eq 'CHARSTRING.TUPLE.ROWID_FK->CHARSTRING (oid-name (car key1)))
						(eq 'CHARSTRING.VECTOR.ROWID->CHARSTRING (oid-name (car key2)))
						(equal (second key1) (second key2))
						(eq (caddr key1) (caddr key2)))
					   (progn
					     (setf (gethash key1 ht) NIL)
					     (setf (gethash key1 ht) (cons (list _=_ (third rec1) (third rec2)) (list rec2) )) );;'unifies' rowid_fk with rowid
					 (if (and (eq 'CHARSTRING.TUPLE.ROWID_FK->CHARSTRING (oid-name (car key1)))
						  (eq 'CHARSTRING.VECTOR.ROWID->CHARSTRING (oid-name (car key2)))
						  (null (equal (second key1) (second key2)))
						  (eq (caddr key1) (caddr key2)))
					     (setf (gethash key1 ht) 'del)));;records NIL in rec2 for key1
				       ) ht )) ht)
	   (dolist (c (cdr con)  )
	     (if (eq 'CHARSTRING.TUPLE.ROWID_FK->CHARSTRING (oid-name (car c)))
		 (progn
		   (setf htk (list (car c) (second c) (cadddr c)) )
		   (if (gethash htk ht)
		       (if (equal (gethash htk ht) 'del)
			   (setf res1 'del)
			 (if (listp (car (gethash htk ht)))
			     (if (eq (caar (gethash htk ht)) _=_ );;if unification has happened			 
				 (dolist (el (gethash htk ht))
				   (setf res (cons el res))))
			   (setf res (cons (gethash htk ht) res)) );;if no unification
			 (setf res (cons (gethash htk ht) res)))));;unnecessary ?
	       (setf res (cons c res)) ));;if c is not rowid_fk
	   (if (eq res1 'del)
	       (setf res NIL)
	     (progn
	       (setf res (andify (reverse res)))
	       (setf res (substequal res (append (selectbody-resl sb) (selectbody-argl sb))))	      
	       (setf res (unify-tuple-and-vector (cdr res)))	   
	       (setf res (andify res))))
	   res))))




(defun rewrite-filter-new(con)
"Rewrites a conjunction whose conjuncts include rowid or/and valueid and FILTER "
  (cond ((atom con) con)
	((null (cddr con)) con)
	((null (eq 'AND (car con))) con);;if con is not a conjunction
	(t
	 (let ((ht (make-hash-table :test (function equal)))
	       (res con))
	   (dolist (c (cdr con) )
	     (if (or (eq (oid-name (first c)) 'CHARSTRING.CHARSTRING.LIKE->BOOLEAN);; if c is a like or comparison predicate
		     (eq (oid-name (first c)) 'OBJECT.OBJECT.>->BOOLEAN);; if c is a >
		     (eq (oid-name (first c)) 'OBJECT.OBJECT.<->BOOLEAN) ;; if c is a <
		     (eq (oid-name (first c)) 'OBJECT.OBJECT.!=->BOOLEAN);; if c is != 
		     (eq (oid-name (first c)) 'OBJECT.OBJECT.=->BOOLEAN))
		 (progn 
		  (if (gethash (second c) ht) ;;if there is an elem in ht with key=var (second vat in any function)
		       (setf (gethash (second c) ht) (cons c (gethash (second c) ht) ) ) ;;if yes, adds to it by 'cons'
		     (setf (gethash (second c) ht) (list c) ) );;if no puts the like pred in ht with key =subject
			   ))
		;; if c is either rowid or valueid predicate
		(if (or (eq (oid-name (first c)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING)
			     (eq (oid-name (first c)) 'LITERAL.CHARSTRING.VALUEID->CHARSTRING) )		
		      (if (gethash (car (last c)) ht) ;;if there is an elem in ht with key=var
			 (setf (gethash (car (last c)) ht) (cons c (gethash (car (last c)) ht))) ;;if yes, adds to by 'cons'
			(setf (gethash (car (last c)) ht) (list c))) )   );;if no puts the like pred in ht with key =subject
	   (maphash (f/l (key predlist);;goes through the ht			
			 (let ((rowid nil)
			       (likelist nil)
			       ( newel nil))
			   (dolist (pr predlist rowid)			     	
			     (if (cdr predlist)
				(progn
				  ;;(help)
				  (if (or (eq (oid-name (first pr)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING)
					   (eq (oid-name (first pr)) 'OBJECT.OBJECT.=->BOOLEAN)
					   (eq (oid-name (first pr)) 'LITERAL.CHARSTRING.VALUEID->CHARSTRING))
				       (setf rowid pr)))))
			   (if (null (null rowid));;if rowid is not empty
			       (progn						
				 (setf likelist (subsublist predlist rowid));;the rest of predlist (without rowid)
				 (mapcar (f/l (els)  ;;goes through the rest of the predlist				     
					     (cond ((and (eq (oid-name (first rowid)) 'LITERAL.CHARSTRING.VALUEID->CHARSTRING)
							  (neq (oid-name (first els)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING) )
						    (if (null (or (and (numberp (encode-numeric (third els)) (equal (third rowid) "http://www.w3.org/2001/XMLSchema#string")));;if xsdstring is plain literal
		(and (stringp (encode-numeric (third els))) (equal (third rowid) "http://www.w3.org/2001/XMLSchema#int"))
		(and (stringp (encode-numeric (third els))) (equal (third rowid) "http://www.w3.org/2001/XMLSchema#integer"))		(and (stringp (encode-numeric (third els))) (equal (third rowid) "http://www.w3.org/2001/XMLSchema#decimal"))
		(and (stringp (encode-numeric (third els))) (equal (third rowid) "http://www.w3.org/2001/XMLSchema#float"))
		(and (is-date? (third els))                 (equal (third rowid) "http://www.w3.org/2001/XMLSchema#string"))
		(and (null (is-date? (third els)))          (equal (third rowid) "http://www.w3.org/2001/XMLSchema#dateTime"))
		(and (null (is-date? (third els)))          (equal (third rowid) "http://www.w3.org/2001/XMLSchema#date"))
		(and (stringp (encode-numeric (third els))) (equal (third rowid) "http://www.w3.org/2001/XMLSchema#double")) ))
							(progn
							   ;;(help)
							   (setf newel (list (first els) (second rowid) (third els) ) ) ;; replaces the variables and reconstructs the con
							   (setf res (andify (list (subsublist res els) newel))))
						      (setf res nil)));;otherwise rewrite con to nil
						    ((and (eq (oid-name (first rowid)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING)
							   (or (eq (oid-name (first els)) 'CHARSTRING.CHARSTRING.LIKE->BOOLEAN)
							       (eq (oid-name (first els)) 'OBJECT.OBJECT.!=->BOOLEAN)
							       (eq (oid-name (first els)) 'OBJECT.OBJECT.>->BOOLEAN)
							       (eq (oid-name (first els)) 'OBJECT.OBJECT.<->BOOLEAN)))
						     (setf res nil));;rewrites the conjunction to nil if (AND rowid like)	
						     ((and (eq (oid-name (first rowid)) 'OBJECT.OBJECT.=->BOOLEAN)
							   (or (eq (oid-name (first els)) 'CHARSTRING.CHARSTRING.LIKE->BOOLEAN)
							       (eq (oid-name (first els)) 'OBJECT.OBJECT.!=->BOOLEAN)
							       (eq (oid-name (first els)) 'OBJECT.OBJECT.>->BOOLEAN)
							       (eq (oid-name (first els)) 'OBJECT.OBJECT.<->BOOLEAN)))
						     (setf res nil));;rewrites the conjunction to nil if (AND = >(<)(like) ) 	
						    (t (setf res res)) ) ) likelist)  )
			     (setf res res));;if rowid is empty
			   )) ht)
	   res))))


 

      
		       



(defun rewrite-filter (con)
"Rewrites a conjunction whose conjuncts include rowid or/and valueid and FILTER "
  (cond ((atom con) con)
	((null (cddr con)) con)
	((null (eq 'AND (car con))) con);;if con is not a conjunction
	(t
	 (let ((ht (make-hash-table :test (function equal)))
	       (res con))
	   (dolist (c (cdr con) )
	     (if (or (eq (oid-name (first c)) 'CHARSTRING.CHARSTRING.LIKE->BOOLEAN);; if c is a like or comparison predicate
		     (eq (oid-name (first c)) 'OBJECT.OBJECT.>->BOOLEAN);; if c is a >
		     (eq (oid-name (first c)) 'OBJECT.OBJECT.<->BOOLEAN) ;; if c is a <
		     (eq (oid-name (first c)) 'OBJECT.OBJECT.!=->BOOLEAN);; if c is != 
		     (eq (oid-name (first c)) 'OBJECT.OBJECT.=->BOOLEAN))
		 (progn 
		  (if (gethash (second c) ht) ;;if there is an elem in ht with key=var (second vat in any function)
		       (setf (gethash (second c) ht) (cons c (gethash (second c) ht) ) ) ;;if yes, adds to it by 'cons'
		     (setf (gethash (second c) ht) (list c) ) );;if no puts the like pred in ht with key =subject
			   ))
		;; if c is either rowid or valueid predicate
		(if (or (eq (oid-name (first c)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING)
			     (eq (oid-name (first c)) 'LITERAL.CHARSTRING.VALUEID->CHARSTRING) )		
		      (if (gethash (car (last c)) ht) ;;if there is an elem in ht with key=var
			 (setf (gethash (car (last c)) ht) (cons c (gethash (car (last c)) ht))) ;;if yes, adds to by 'cons'
			(setf (gethash (car (last c)) ht) (list c))) )   );;if no puts the like pred in ht with key =subject
	   (maphash (f/l (key predlist);;goes through the ht			
			 (let ((rowid nil)
			       (likelist nil)
			       ( newel nil))
			   (dolist (pr predlist rowid)			     	
			     (if (cdr predlist)
				(progn
				  ;;(help)
				  (if (or (eq (oid-name (first pr)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING)
					   (eq (oid-name (first pr)) 'OBJECT.OBJECT.=->BOOLEAN)
					   (eq (oid-name (first pr)) 'LITERAL.CHARSTRING.VALUEID->CHARSTRING))
				       (setf rowid pr)))))
			   (if (null (null rowid));;if rowid is not empty
			       (progn						
				 (setf likelist (subsublist predlist rowid));;the rest of predlist (without rowid)
				 (mapcar (f/l (els)  ;;goes through the rest of the predlist				    
					     (cond ((and (eq (oid-name (first rowid)) 'LITERAL.CHARSTRING.VALUEID->CHARSTRING)
							  (neq (oid-name (first els)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING) )
						     (progn 
						       (if (and (eq _type_Match_ t);;activate the rewrite Type-Match
								(eq (oid-name (first els)) 'CHARSTRING.CHARSTRING.LIKE->BOOLEAN )
								 (or (and (numberp (encode-numeric (third els)) (equal (third rowid) "http://www.w3.org/2001/XMLSchema#string")));;if xsdstring is plain literal
								    (and (stringp (encode-numeric (third els))) (equal (third rowid) "http://www.w3.org/2001/XMLSchema#int"))
								    (and (stringp (encode-numeric (third els))) (equal (third rowid) "http://www.w3.org/2001/XMLSchema#integer"))	
								    (and (stringp (encode-numeric (third els))) (equal (third rowid) "http://www.w3.org/2001/XMLSchema#decimal"))
								    (and (stringp (encode-numeric (third els))) (equal (third rowid) "http://www.w3.org/2001/XMLSchema#float"))
								    (and (is-date? (third els))                 (equal (third rowid) "http://www.w3.org/2001/XMLSchema#string"))
								    (and (null (is-date? (third els)))          (equal (third rowid) "http://www.w3.org/2001/XMLSchema#dateTime"))
								    (and (null (is-date? (third els)))          (equal (third rowid) "http://www.w3.org/2001/XMLSchema#date"))
								    (and (stringp (encode-numeric (third els))) (equal (third rowid) "http://www.w3.org/2001/XMLSchema#double")) ) )
							   (setf res nil);;eliminate if wrong data type
							 (progn;;rewrite if correct data type
							   (setf newel (list (first els) (second rowid) (third els) ) ) ;; replaces the variables and reconstructs the con
							   (setf res (andify (list (subsublist res els) newel)))))))
						    ((and (eq _is_Literal_ t);;activate the rewrite is_literal
						           (eq (oid-name (first rowid)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING)
							   (or (eq (oid-name (first els)) 'CHARSTRING.CHARSTRING.LIKE->BOOLEAN)
							       (eq (oid-name (first els)) 'OBJECT.OBJECT.>->BOOLEAN)
							       (eq (oid-name (first els)) 'OBJECT.OBJECT.<->BOOLEAN)))
						     (setf res nil));;rewrite the conjunction to nil if (AND rowid like)	
						     ((and (eq _is_Literal_ t);activate the rewrite is_literal
						           (eq (oid-name (first rowid)) 'OBJECT.OBJECT.=->BOOLEAN)
							   (or (eq (oid-name (first els)) 'CHARSTRING.CHARSTRING.LIKE->BOOLEAN)
							       (eq (oid-name (first els)) 'OBJECT.OBJECT.>->BOOLEAN)
							       (eq (oid-name (first els)) 'OBJECT.OBJECT.<->BOOLEAN)))
						     (setf res nil));;rewrite the conjunction to nil if (AND = >(<)(like) ) 	
						     (t (setf res res)))) likelist ))
			     (setf res res));;if rowid is empty
			   )) ht)
	   res))))







(defun rewrite-filter-on-sub_ob (con)
"Rewrites a conjunction whose conjuncts include rowid or/and valueid and FILTER predicates"
  (cond ((atom con) con)
	((null (cddr con)) con)
	((null (eq 'AND (car con))) con);;if con is not a conjunction
	(t
	 (let ((ht (make-hash-table :test (function equal)))
	       (res con))
	   (dolist (c (cdr con) )
	     (if (or (eq (oid-name (first c)) 'CHARSTRING.CHARSTRING.LIKE->BOOLEAN);; if c is a like or comparison predicate
		     (eq (oid-name (first c)) 'OBJECT.OBJECT.>->BOOLEAN)
		     (eq (oid-name (first c)) 'OBJECT.OBJECT.<->BOOLEAN) 
		     (eq (oid-name (first c)) 'OBJECT.OBJECT.!=->BOOLEAN))
		 (progn 
		   (if (gethash (second c) ht) ;;if there is an elem in ht with key=var (second vat in any function)
		       (setf (gethash (second c) ht) (cons c (gethash (second c) ht) ) ) ;;if yes, adds to it by 'cons'
		     (setf (gethash (second c) ht) (list c) ) );;if no puts the like pred in ht with key =subject
		   )
	       (progn ;; if c is either rowid or valueid predicate
		 (if (or (eq (oid-name (first c)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING)
			 (eq (oid-name (first c)) 'LITERAL.CHARSTRING.VALUEID->CHARSTRING) )
		     (if (gethash (car (last c)) ht) ;;if there is an elem in ht with key=var
			 (setf (gethash (car (last c)) ht) (cons c (gethash (car (last c)) ht))) ;;if yes, adds to by 'cons'
		       (setf (gethash (car (last c)) ht) (list c) ) );;if no puts the like pred in ht with key =subject
		   )) )
	     )
	   (maphash (f/l (key predlist);;goes through the ht
			 (let ((rowid nil)
			       (likelist nil)
			       ( newel nil))
			   (dolist (pr predlist rowid)
			     (if (listp pr)
				 (progn 
				   (if (or (eq (oid-name (first pr)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING);; if c is a rowid predicate
					   (eq (oid-name (first pr)) 'LITERAL.CHARSTRING.VALUEID->CHARSTRING))
				       (setf rowid pr)))))
			   (if (null (null rowid));;if rowid is not empty
			       (progn
				 (setf likelist (subsublist predlist rowid));;the rest of predlist (without rowid)
				 (mapcar (f/l (els)  ;;goes through the rest of the predlist
					      (cond ((and (eq (oid-name (first els)) 'CHARSTRING.CHARSTRING.LIKE->BOOLEAN)
							  (eq (oid-name (first rowid)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING))
						     (progn
						       (if (string-like-i (second rowid) (third els));;if the rowid and like strings match
							   (setf res (subsublist res els)) ;;rewrites rowid-and-like to rowid
							 (if (string-like (third els) "*/_*") ;;if the strings matches '/_'
							     (if (string-like
								  (second rowid) (substring 0 (- (string-pos (third els) "/_" ) 1) (third els ) )  )
								 (setf res res)
							       (setf res nil)) ;;rewrites the conjunction to nil
							   (progn;;if the strings doesn't match '/_'
							     (setf res res)
							    ;; (setf newel (list (first els) (third rowid) (third els)));; ;; replaces the variables and reconstructs the con
							    ;; (setf res (andify (list (subsublist res els) newel)) )
							     )))))
						    ((and (eq (oid-name (first rowid)) 'LITERAL.CHARSTRING.VALUEID->CHARSTRING)
							  (neq (oid-name (first els)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING) )
						     (progn 
						       (setf newel (list (first els) (second rowid) (third els) ) ) ;; replaces the variables and reconstructs the con
						       (setf res (andify (list (subsublist res els) newel)))))
						    ((and (eq (oid-name (first rowid)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING)
							   (or (eq (oid-name (first els)) 'OBJECT.OBJECT.>->BOOLEAN)
							       (eq (oid-name (first els)) 'OBJECT.OBJECT.<->BOOLEAN)))
						     (setf res nil))
						    (t (setf res res)) ) ) likelist)  )
			     (setf res res));;if rowid is empty
			   )) ht)
	   res))))
		    

(defun rewrite-extra-dnf-orig (rewfun predicate)
"Applys rewrite 'rewfun' on each disjunct 
 of the DNF 'predicate'"
  (let ((res nil))
    (cond 
     ((atom predicate) predicate)
     ((neq (car predicate) 'or) (funcall rewfun predicate));;if predicate is not a disjunction
     ((null (cddr predicate)) (funcall rewfun (cadr predicate ) ));;if it is only one disjunct
     (t 
      (dolist (con (cdr predicate) res)
	(let ((res1 nil))
	  (setf res1 (funcall rewfun con));;rewrite a disjunct
	  (setf res (cons res1 res))))
      (setf res (orify (nreverse res)))))))


(defun rewrite-extra-dnf (rewfun predicate args)
"Applys rewrite 'rewfun' on each disjunct 
 of the DNF 'predicate'"
  (let ((res nil))
    (cond 
     ((atom predicate) predicate)
     ((neq (car predicate) 'or) (funcall rewfun predicate args));;if predicate is not a disjunction
     ((null (cddr predicate)) (funcall rewfun (cadr predicate ) args ));;if it is only one disjunct
     (t 
      ;(help)
      (dolist (con (cdr predicate) res)
	(let ((res1 nil))
	  (setf res1 (funcall rewfun con args));;rewrite a disjunct
	  (setf res (cons res1 res))))
      (setf res (orify (nreverse res)))))))


(defun rewrite-extra-dnf-latset (rewfun predicate args)
"Applys rewrite 'rewfun' on each disjunct 
 of the DNF 'predicate'"
  (let ((res nil))
    (cond 
     ((atom predicate) predicate)
     ((leaf-predicate-p predicate) predicate);;it is a simple predicate
     ((and (eq (car predicate) 'and) 
	   (leaf-predicate-p (cadr predicate))
	   (neq (caar (last predicate)) 'or))
      (funcall rewfun predicate args));;if predicate is not a disjunction, (AND () ())
     ((null (cddr predicate)) (funcall rewfun (cadr predicate ) args ));;if it is only one disjunct
      ((and (eq (car predicate) 'and) (eq (caar (last predicate)) 'or)) 
      (setf res (append2 (funcall rewfun (set-difference-equal predicate (last predicate)) args )(last predicate)))
      (help))  ;;predicate (AND () (OR ()))
     (t 
      (dolist (con (cdr predicate) res)
	(let ((res1 nil))
	  (setf res1 (funcall rewfun con args));;rewrite a disjunct
	  (setf res (cons res1 res))))
      (setf res (orify (nreverse res)))))))


(defun rewrite-rowid-and-rowidfk-disj (predicate sb)
" for each disjunct"
  (let ((res nil))
    (cond 
     ((atom predicate) predicate)
     ((neq (car predicate) 'or) (rewrite-rowid-and-rowidfk predicate sb));;if predicate is not a disjunction
     ((null (cddr predicate)) (rewrite-rowid-and-rowidfk (cadr predicate ) sb ));;if it is only one disjunct
     (t 
      (dolist (con (cdr predicate) res)
	(let ((res1 nil))
	  (setf res1 (rewrite-rowid-and-rowidfk con sb));;rewrite a disjunct
	  (setf res (cons res1 res))))
      (setf res (orify (nreverse res)))))))



(defun rewrite-filter-on-sub_ob-disj (predicate)
 "Rewrite-filter-on-sub_ob for an OR predicate, calling the
  originalrewrite-filter-on-sub_ob for each disjunct"
  (let ((res nil))
    (cond 
     ((atom predicate) predicate)
     ((neq (car predicate) 'or) (rewrite-filter-on-sub_ob predicate));;if predicate is not a disjunction
     ((null (cddr predicate)) (rewrite-filter-on-sub_ob (cadr predicate ) ));;if it is only one disjunct
     (t 
      (dolist (con (cdr predicate) res)
	(let ((res1 nil))
	  (setf res1 (rewrite-filter-on-sub_ob con));;rewrite a disjunct
	  (setf res (cons res1 res))))
      (setf res (orify (nreverse res)))))))


(defun rewrite-sview-and-rowid-o (con)
"Rewrites a conjunction of materialized s-view and rowid"
  (cond ((atom con) con)
	((null (cddr con)) con)
	((null (eq 'AND (car con))) con);;if con is not a conjunction
	(t
	 (let ((rowid nil);;reserved for a rowid predicate
	       (func nil)
	       (sper nil);;reserved for the s-view
	       (res con))
	   (dolist (c (cdr con) )
	     (setf func (oid-name (first c)))
	     (if (and (string-like (mkstring func) "P_CHARSTRING.CHARSTRING.CHARSTRING.S*")
		      (string-like (mkstring func) "*->BOOLEAN")) ;;if c is the schema view
		 (setf sper 'true))
	     (if (eq (oid-name (first c)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING);; if c is a rowid 
		 (setf rowid 'true) ))
	   (if (and sper rowid );;if the schema view and some rowid are in a conjunction
	       (setf res nil));;rewrites the conjunction to nil 
	   res))))


(defun rewrite-sview-and-rowid (con)
"Rewrites a conjunction of materialized s-view and rowid"
  (cond ((atom con) con)
	((null (cddr con)) con)
	((null (eq 'AND (car con))) con);;if con is not a conjunction
	(t
	 (let ((rowid nil);;reserved for a rowid predicate
	       (func nil)
	       (sper nil);;reserved for the s-view
	       (valueid nil);;reserved for a valueid predicate
	       (res con))
	   (dolist (c (cdr con) )
	     (setf func (oid-name (first c)))
	     (if (and (string-like (mkstring func) "P_CHARSTRING.CHARSTRING.CHARSTRING.S*")
		      (string-like (mkstring func) "*->BOOLEAN")) ;;if c is the schema view
		 (setf sper c))
	     (if (eq (oid-name (first c)) 'CHARSTRING.VECTOR.ROWID->CHARSTRING);; if c is a rowid 
		 (setf rowid c) )
	     (if (eq (oid-name (first c)) 'LITERAL.CHARSTRING.VALUEID->CHARSTRING)
		 (setf valueid c)) ;;if c is a valueid    
	     )
	   (if (and sper rowid );;if the schema view and some rowid are in a conjunction
	       (setf res nil);;rewrites t he conjunction to nil 
	     (if (and (and sper valueid);;if (and s-view valueid)
		      (eq (car (predicate-variables sper));;if they share variable defining subject
			  (cadr (predicate-variables valueid))))
		 (setf res nil)))
	   res))))
	     

(defun rewrite-sview-and-rowid-disj (predicate)
 "Rewrite-sview-and-rowid for and OR predicate, calling the
  originalrewrite-sview-and-rowid for any disjunct"
  (let ((res nil))
    (cond 
     ((atom predicate) predicate)
     ((neq (car predicate) 'or) (rewrite-sview-and-rowid predicate));;if predicate is not a disjunction
     ((null (cddr predicate)) (rewrite-sview-and-rowid (cadr predicate ) ));;if it is only one disjunct
     (t 
      (dolist (con (cdr predicate) res)
	(let ((res1 nil))
	  (setf res1 (rewrite-sview-and-rowid con));;rewrite a disjunct
	  (setf res (cons res1 res))))
      (setf res (orify (nreverse res)))))))


(defun eliminate-core-cluster (con ls)
"Eliminates a core cluster in a conjunction con
 if one of its elements is set to an elementa value 
 from the list ls, i.e. a valid URI in SARD.
 Necessary when a triple pattern is ( ?s ?p <uri> ) "
  (cond ((atom con) con)
	((null (cddr con)) con)
	((null (eq 'AND (car con))) con);;if con is not a conjunction
	(t
	 (let ((nvars nil)
 	       (res con))
	   (dolist (c (cdr con) )
	     (if (core-cluster-fn? (predicate-operator c));;if the conjuct is a core cluster fn
		 (progn
		   (setf nvars (cdr (set-difference c (predicate-variables c))))
		   (dolist (el nvars)
		     (mapcar (f/l (lsel) 
				  (if (or (and (string-like-i (mkstring el) lsel) (string-like (mkstring el) "*/_*"))
					  (string-like-i (mkstring el) lsel))
				      (setf res nil)))  ;;if el is like from the list ls sets the con to nil
			     ls) ))))
	   res))))

(defun eliminate-core-cluster-disj (predicate ls)
 "Eliminate core clutser within a disjunctive predicate"
  (let ((res nil))
    (cond 
     ((atom predicate) predicate)
     ((neq (car predicate) 'or) (eliminate-core-cluster predicate ls));;if predicate is not a disjunction
     ((null (cddr predicate)) (eliminate-core-cluster (cadr predicate ) ls ));;if it is only one disjunct
     (t 
      (dolist (con (cdr predicate) res)
	(let ((res1 nil))
	  (setf res1 (eliminate-core-cluster con ls));;rewrites a disjunct
	  (setf res (cons res1 res))))
      (setf res (orify (nreverse res)))))))			    
		   
(defun const-URI-list (mapf)
"Constructs a list of URIs from the function mapf 
 necessary for the eliminate-core-cluster"
  (let ((res nil)
	(tls (getfunction mapf )))
    (mapcar (f/l (tlel) (setf res (cons (concat (car (last tlel)) "*") res)) ) tls)
     res) )


(defun const-forbURI-list (lsmapf)
"Constructs a list of forbidden URIs when taking 
 as input a list of mapfunctions lsmapf "
  (cond ((eq lsmapf nil) nil)
	((atom lsmapf) 
	  (let ((res nil)
		(tls (getfunction lsmapf )))
	    (mapcar (f/l (tlel) (setf res (cons (concat (car (last tlel)) "*") res)) ) tls)
	    res))
	(t
	 (let ((res nil))
	   (dolist (mapf lsmapf)
	     (mapcar (f/l (tlel) (setf res (cons (concat (car (last tlel)) "*") res))) (getfunction mapf )))
	   res))))


(defun eliminate-con-ifnounif (con ls)
"Eliminates conjunction con if two (or more) conjuncts, 
determing one and the same variable from list ls, don't
have unique common vars, i.e. are not unifyable.
 Necessary when ( * * ?s. ?s ?p ?o )" 
 (cond ((atom con) con)
	((null (cddr con)) con)
	((null (eq 'AND (car con))) con);;if con is not a conjunction
	(t
	 (let ((pvars nil)
 	       (res con)
	       (ht (make-hash-table :test (function equal))) )
	   (dolist (c (cdr con) )
	     (setf pvars (predicate-variables c))
	      (mapcar (f/l (varel)
			  (if (and (in varel ls);;if the pred var belongs to ls
				   (or (is-valueid c) (is-rowid c))) ;;and the pred is rowid or valueid
			      (progn
				(if (gethash varel ht);;if there is an elem in the ht with htk=varel 
				    (if (or (and (is-rowid (gethash varel ht)) (is-valueid c))
					      (and (is-valueid (gethash varel ht)) (is-rowid c)))
					(setf res nil);;then sets the con to nil
				      )
				  ;; (if (null(hasuniquecommonvar (gethash varel ht) c));;if yes checks whether the terms aren't unifiable
				  (setf (gethash varel ht) c)))));;puts an elem in the ht with htk=varel
		      pvars))
	   res))))


(defun eliminate-con-ifnounif-disj (predicate ls)
 "Eliminates a conj if nounif disjunctive predicate"
  (let ((res nil))
    (cond 
     ((atom predicate) predicate)
     ((neq (car predicate) 'or) (eliminate-con-ifnounif predicate ls));;if predicate is not a disjunction
     ((null (cddr predicate)) (eliminate-con-ifnounif (cadr predicate ) ls ));;if it is only one disjunct
     (t 
      (dolist (con (cdr predicate) res)
	(let ((res1 nil))
	  (setf res1 (eliminate-con-ifnounif con ls));;rewrites a disjunct
	  (setf res (cons res1 res))))
      (setf res (orify (nreverse res)))))))		


 
(defun calculate-mon-day (fno year mon day number)
"Calculates the day of a month mon for year"
  (cond ((or (< mon 1) (> mon 12)) (print "The month has to be 1..12"))
	((or (< day 1) (> day 365)) (print "The day has to be 1..365"))
	((< year 1900) (print "Type year > 1900"))
	(t
	 (let ((tab (vector 31 28 31 30 31 30 31 31 30 30 30 31))
	       (dd day)
	       (i 0))
	   (if (equal (* 4 (/ year 4)) year)
	       (setf (aref tab 1) 29))
	   (dotimes (i (- mon 1) )
	     (setf dd (- dd (aref tab i))))
	   (if (and (> dd 0) (> dd 0) (< dd 31))
	       (osql-result year mon day dd))
	   (if (= dd 0)
	     (osql-result year mon day (aref tab (- mon 2))))
	   (if (or (< dd 0) (> dd 31))
	       (print "Some value is wrong!"))
	   ))))



(defun time-round-tominutes (fno hour tim)
  (cond ((or (< hour 0) (> hour 24)) "Wrong hour")
        ((eq hour (round hour)) hour)
	(t
	 (if (> (round hour) hour)
	     (osql-result hour (concat (- (round hour) 1) ":" (round (* (- hour (- (round hour) 1)) 60))))
	   (osql-result hour (concat (round hour) ":" (round (* (- hour (round hour)) 60))))))))




(defun add-notnil-to-cc (con rvars)
"Conjuncts a '!= NIL' predicate to a core cluster ccfn
in the conjunction con if one of the arguments of ccfn
is a result argument"
  (cond ((atom con) con)
	((null (cddr con)) con)
	((null (eq 'AND (car con))) con);;if con is not a conjunction
	(t
	 (let ((res nil))
	   (dolist (c (cdr con) )
	     (if (core-cluster-fn? (predicate-operator c));;if c is a core cluster fn
		 (mapcar (f/l (el)
			    (if (in el (predicate-variables c))
				(progn
				  (setf res (cons (list (getfunctionnamed 'OBJECT.NOTNULL->OBJECT) el  el) res))
				  (if (null (in c res))
				      (setf res (cons c res))))
			      (if (null (in c res))
				  (setf res (cons c res))) )) rvars)
	       (setf res (cons c res))))
	   (andify res )))))


(defun add-notnil-topr-incon (con sb)
"Conjuncts a notnull predicate to any predicate
in the conjunction con if one of its arguments 
is a result argument"
(let ((res nil)
	       (genvar nil)
	       (free (append (selectbody-argl sb)
			   (selectbody-resl sb)))
	       (rvars (selectbody-resl sb)))
  (cond ((atom con) (cons free con))
	((null (cddr con)) (cons free con))
	((null (eq 'AND (car con))) (cons free con));;if con is not a conjunction
	(t	 
	   (dolist (c (cdr con) )
	     (mapcar (f/l (el)
			  (if (in el (predicate-variables c));;if c contains a result var
			      (progn
				(setf genvar (alias-var el sb));;generates a var
				(setf free (adjoin genvar free));;adds to the free vars
				(setf res (cons (list (getfunctionnamed 'OBJECT.NOTNULL->OBJECT) el genvar) res))
				(if (null (in c res));;if c hasn't been included in res
				  (setf res (cons c res))))
			    (if (null (in c res));;if c hasn't been included in res
				(setf res (cons c res))))) rvars))
	   (setf res (andify res))
	   (cons free res)))))
		 

(defun add-notnil-to-cc-disj (predicate sb)
 "Add-notnil-to-cc for an OR predicate, calling the
  original add-notnil-to-cc for each disjunct"
  (let ((res nil)
	(rvars (selectbody-resl sb)))
    (cond 
     ((atom predicate) predicate)
     ((neq (car predicate) 'or) (add-notnil-to-cc  predicate rvars));;if predicate is not a disjunction
     ((null (cddr predicate)) (add-notnil-to-cc (cadr predicate ) rvars ));;if it is only one disjunct
     (t 
      (dolist (con (cdr predicate) res)
	(let ((res1 nil))
	  (setf res1 (add-notnil-to-cc con rvars));;rewrite a disjunct
	  (setf res (cons res1 res))))
      (setf res (orify (nreverse res)))))))


(defun add-notnil-topr-incon-disj (predicate sb)
 "Add-notnil-topr-incon for an OR predicate, calling the
  original add-notnil-topr-incon for each disjunct"
  (let ((res nil)
	(rvars (selectbody-resl sb)))
    (cond 
     ((atom predicate) predicate)
     ((neq (car predicate) 'or) (add-notnil-topr-incon  predicate rvars));;if predicate is not a disjunction
     ((null (cddr predicate)) (add-notnil-topr-incon (cadr predicate ) rvars ));;if it is only one disjunct
     (t 
      (dolist (con (cdr predicate) res)
	(let ((res1 nil))
	  (setf res1 (add-notnil-topr-incon con rvars));;rewrite a disjunct
	  (setf res (cons res1 res))))
      (setf res (orify (nreverse res)))))))

    

(defun add-notnil-d (prdisj sb)
 "Add-notnil-topr-incon for an OR predicate, calling the
  original add-notnil-topr-incon for each disjunct"
 (let ((res nil)
       (fr nil))
   (dolist (con (cdr prdisj) res)
     (let ((res1 nil)
	   (res2 nil))
       (setf res2 (add-notnil-topr-incon con sb));;rewrite a disjunct
       (setf res1 (cdr res2))
       (setf fr (append (car res2) fr));;builds the fr vars list
       (setf res (cons res1 res))))
   (setf res (orify (nreverse res)))
   (setf res (cons fr (substequal-dnf res fr)))))
	 


(defun apply-add-notnill (predicate sb)
"Apply add-notnil-topr-inco"
(let ((res1 nil))
    (cond 
     ((atom predicate) predicate)

     ((and (eq (car predicate) 'and) (null (in 'or (cdr predicate))) 
	   (null (in 'and (cdr predicate)))) ;;simple conjunction
      (setf res1 (add-notnil-topr-incon predicate sb))
      (substequal (cdr res1) (car res1)))

     ((and (eq (car predicate) 'and) (eq (car (caddr predicate)) 'or));;conjunction and .. or
      (setf res1 (add-notnil-d (caddr predicate) sb))
      (andify (reverse (list (cdr res1) (substequal (cadr predicate) (car res1))))))

     (t ;disjunction
       (cdr (add-notnil-d predicate sb))))))


(defun pick-valid-cid (rid)
"Picks up the correct class URI from the row identifier rid"
  (let ( (ls  (amosql "cmap();")))
    (dolist (el ls)
	(if (stringp (car (last el)))
	  (if (string-like-i rid (concat (car (last el)) "*"))
	      (return (car (last el))))))))



(defun row-ident-ls (rid cid)
"Decodes a row identifier from the 'rid' and 'cid'" 
    (if (and (stringp rid)(is-valid-cid cid) );;if rid is a string and cid is a valid class URI
       (progn
	(cond 
	  ((null (string-pos rid "/_")) nil);;if '/_' is not included in the rid	
          (t 
		  (if (null (string-like-i rid (concat (substring 0 (- (length cid) 2) cid) "*")))
			nil    ;;if rid and cid do not belong to the same table
		   (progn
		      (if  (null (equal ">" (substring (- (length rid) 1) (length rid) rid)));;unload case
			  (let ((concvec (substring (+ (length cid) 1) (length rid) rid)))
			    (separate-CKels concvec))
			(let ((concvec (substring (length cid)  (- (length rid) 2) rid)));; restore case
			  (separate-CKels concvec)))) ))))))




(defun open-optbag (pred )
"Rewrites (opens up) transients inside OPTIONALs" 
"Works only for conjunction"
 (let (( ht (make-hash-table :test (function equal)))
       	 htk result tpred optvar lres nonopt rest)
   (dolist (con (cdr pred) );;constructs ht with mbag and opt elements
     (if (and (neq 'OR (car con))
	      (or (eq 'FUNCTION.MAKEBAG->BAG (oid-name (car con)))
		  (eq 'BAG.OBJECT.OPTIONAL->OBJECT (oid-name (car con)))))
	 (progn	  
	   (setq opt-list nil)
	   (if (eq 'FUNCTION.MAKEBAG->BAG (oid-name (car con)))
	       (setf htk (list 'mbag (car (last con)))) ;;htk=(mbag _V115)
	     (if (eq 'BAG.OBJECT.OPTIONAL->OBJECT (oid-name (car con)))
		 (setf htk (list 'opt (second con)))));;htk=(opt _V115 )
	   (if (null (gethash htk ht))
	       (setf (gethash htk ht) con))) ) )
   (dolist (con (cdr pred) );;goes through pred again
     (if (neq 'OR (car con))
	  (if (and (eq 'FUNCTION.MAKEBAG->BAG (oid-name (car con)))
		   (transientp (cadr con)))
	      (progn ;;if con is transient
		(setf optvar (car (last (gethash (list 'opt (car (last con))) ht))));;finds corresp optional var(so far if it is one)
		(setf tpred (cadr con))
		(setf lres (cdr (selectbody-expanded-simplified (getselectbody tpred))))
		(dolist (l lres);;go through lres
		  (if (core-cluster-fn? (predicate-operator l))
		      (push l opt-list))
		  (if (member (car (selectbody-resl (getselectbody tpred))) 
			      (predicate-variables l));;if .. change the variable with 		     
		      (setf result (cons 
				    (subst optvar (car (selectbody-resl (getselectbody tpred))) l)
				    result ))
		    (setf result (cons l result)))))
	    (if (neq 'BAG.OBJECT.OPTIONAL->OBJECT (oid-name (car con)))
		(progn ;;if con is neither transient nor OPTIONAL
		  (setf result (cons con result))
		  (setf nonopt (cons con nonopt))) ));;the old conjunction without optional part
       (setf rest con) ))  ;;if cons is disjunction don't change it
   (setf result (andify (reverse result)));;forms the new conjunction
   (setf nonopt (cons (list _=_ optvar "") nonopt))
   (setf nonopt (andify (reverse nonopt)));;the old conjunction without optional part	 
   (if (null (not rest))
       (progn
	 (setf result (andify (adjoin result (list rest))));;conjucts new with rest
	 (setf nonopt (andify (adjoin nonopt (list rest)))) ));;conjucts nonopt with rest -->> needs to reduce left
   (setf result (transformpredicate result))
   (setf nonopt (transformpredicate nonopt))
   (setf result (orify (list result nonopt)))
    result ))


(defun rewrite-optional-dnf (pred)
"Rewrites OPTIONAL in a conjunction pred"
"!!! Directly after  DNF !!!"
  (cond ((atom pred) pred)
	((null (cddr pred)) pred)
	((null (eq 'AND (car pred))) pred);;if con is not a conjunction
	(t
	 (let (( ht (make-hash-table :test (function equal)))
	        htk result tpred optvar lres nonopt frees)
	   (dolist (con (cdr pred) );;defines ht with mbag and opt elements
	      (if (or (eq 'FUNCTION.MAKEBAG->BAG (oid-name (car con)))
		      (eq 'BAG.OBJECT.OPTIONAL->OBJECT (oid-name (car con))))
		  (progn	  
		    (if (eq 'FUNCTION.MAKEBAG->BAG (oid-name (car con)))
			(setf htk (list 'mbag (car (last con)))) ;;htk=(mbag _V115)
		      (if (eq 'BAG.OBJECT.OPTIONAL->OBJECT (oid-name (car con)))
			  (setf htk (list 'opt (second con)))));;htk=(opt _V115 )
		    (if (null (gethash htk ht))
			(setf (gethash htk ht) con))) ) )
	   (dolist (con (cdr pred) );;goes through pred 
	     (if (and (eq 'FUNCTION.MAKEBAG->BAG (oid-name (car con)))
		      (transientp (cadr con)))
		 (progn ;;if con is bag with transient
		   (setf optvar (car (last (gethash (list 'opt (car (last con))) ht))));;finds corresp optional var(so far if it is one)-last in OPTIONAL
		   (setf tpred (cadr con))
		   (setf lres (cdr (selectbody-expanded-simplified (getselectbody tpred))))
		   (dolist (l lres);;go through lres
		     (if (member (car (selectbody-resl (getselectbody tpred))) (predicate-variables l));;if ..
			 (progn
			   (setf result (cons (subst optvar (car (selectbody-resl (getselectbody tpred))) l) result ));; change the variable with optvar		     
			  ;; (setf result (cons (list _=_ optvar (car (predicate-variables con ))) result ))
			   )
			   (setf result (cons l result)))));;close progn
	       (if (neq 'BAG.OBJECT.OPTIONAL->OBJECT (oid-name (car con)))
		(progn ;;if con is neither transient nor OPTIONAL
		  (setf result (cons con result))
		  (setf nonopt (cons con nonopt))) )) );;the old conjunction without optional part
	   (setf result (andify (reverse result)));;forms the new conjunction
	   (setf nonopt (cons (list _=_ optvar "") nonopt))
	   (setf nonopt (andify (reverse nonopt)));;the old conjunction without optional part	
	   (setf result (orify (list result nonopt)))
	   ;;(help)
	   result))))

(defun rewrite-optional (pred)
"Rewrites OPTIONAL in a conjunction pred
 !!! After purge variables !!! "
  (cond ((atom pred) pred)
	((null (cddr pred)) pred)
	((null (eq 'AND (car pred))) pred);;if con is not a conjunction
	(t
	 (let (( ht (make-hash-table :test (function equal)))
	        htk result tpred optvar lres nonopt frees)
	   (dolist (con (cdr pred) );;defines ht with mbag and opt elements
	      (if (or (eq 'FUNCTION.MAKEBAG->BAG (oid-name (car con)))
		      (eq 'BAG.OBJECT.OPTIONAL->OBJECT (oid-name (car con))))
		  (progn	  
		    (if (eq 'FUNCTION.MAKEBAG->BAG (oid-name (car con)))
			(setf htk (list 'mbag (car (last con)))) ;;htk=(mbag _V115)
		      (if (eq 'BAG.OBJECT.OPTIONAL->OBJECT (oid-name (car con)))
			  (setf htk (list 'opt (second con)))));;htk=(opt _V115 )
		    (if (null (gethash htk ht))
			(setf (gethash htk ht) con))) ) )
	   (if (gethash htk ht) ;;there is an element in the hash table
	       (progn
		 (dolist (con (cdr pred) );;goes through pred 
		   (if (and (eq 'FUNCTION.MAKEBAG->BAG (oid-name (car con)))
			    (transientp (cadr con)))
		       (progn ;;if con is bag with transient
			 (setf optvar (car (last (gethash (list 'opt (car (last con))) ht))));;finds corresp optional var(so far if it is one)-last in OPTIONAL	
			 (setf tpred (cadr con))
			 (setf lres (cdr (selectbody-expanded-simplified (getselectbody tpred))));;opens up the transient (bag)
			 (dolist (l lres);;go through 
			   (if (member (car (selectbody-resl (getselectbody tpred))) (predicate-variables l));;if ..
			       (progn
				 (setf result (cons (subst optvar (car (selectbody-resl (getselectbody tpred))) l) result ));; change the internal var in tpred with optvar	
				 (if (selectbody-argl (getselectbody tpred));;if unknown variable inside OPTIONAL
				     (setf result (cons (list _=_  (car (predicate-variables (gethash (list 'mbag (car (last con))) ht))) (car (selectbody-argl (getselectbody tpred))) )  result )) );;extra condition, join condition
				 )
			     (setf result (cons l result)))));;close progn (if con is no bag)
		     (if (neq 'BAG.OBJECT.OPTIONAL->OBJECT (oid-name (car con)))
			 (progn ;;if con is neither transient nor OPTIONAL
			   (setf result (cons con result))
			  ;; (setf nonopt (cons con nonopt))) 
		       )    )		      ) ) 
		 (setf result (andify (reverse result)));;forms the new conjunction
		 ;;(setf nonopt (cons (list _=_ optvar "") nonopt))
		 ;;(setf nonopt (andify (reverse nonopt)));;the old conjunction without optional part	
		 ;;(setf result (orify (list result nonopt)))
		 )
	     (setf result pred) );;if there is not makebag and optional in pred
	    result))))



     
	     




	 

      
    
	     
        
       
     
    



	    
	     
	       
		   
	     
		 
  
  