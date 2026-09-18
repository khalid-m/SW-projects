;Regression tests

(checkequal "atom" ((polland 'a) 'a))

(checkequal "list" ((polland '(a b c )) '(a b c)))

(checkequal "(AND )" ((polland '(and a b c)) '(and a b c))) 

(checkequal "(OR)" ((polland '(or a b c)) '(or a b c)))
 
(checkequal "(OR (AND ) (AND ))1" 
	    ((polland '(or (and a b c x)(and a c d y))) 
	     '(and a c (or (and b x)(and d y)))))

(checkequal "(OR (AND )(AND ))2" 
	    ((polland '(or (and u v) (and b a)(and a d))) 
	     '(or (and u v)(and a (or b d)))))

(checkequal "(OR (AND )(AND ))3"  
	    ((polland '(or (and b a)(and a d))) 
	     '(and a (or b d))))

(checkequal "(OR ...)"
	    ((polland '(or (and a b c) (and d e f) (and a c g h)(and d i h))) 
	     '(or (and  a c (or b (and g h))) 
		  (and d (or (and e f)(and i h))))))

(checkequal "(AND .. (OR ..() ()))1" 
	    ((polland '(and a b (or (and x y) (and c d e)(and d e f g)))) 
	     '(and a b (or (and x y) (and d e (or c (and f g)))))))

(checkequal "(AND .. (OR ..() ()))2" 
	    ((polland '(and a b (or (and x y) (and x k) (and c d e)
				    (and d e f g)))) 
	     '(and a b (or (and x (or y k)) (and d e (or c (and f g)))))))

(checkequal "(AND .. (OR ..() ()))3" 
	    ((polland '(and a b (or (and c d e)(and d e f g)))) 
	     '(and a b d e (or c (and f g)))))

(checkequal "(AND .. (OR ..() ()))4" 
	    ((polland '(and a b (or (and c d e)(and d e f g) 
				    (and x y z) (and y i l)))) 
	     '(and a b (or (and d e (or  c (and f g))) 
			   (and y (or (and x z) (and i l)))))))

(checkequal "(OR (AND ()..) (AND (..))" 
	    ((polland '(OR (AND a b (c) (f h) (d)) 
			   (AND x y (C) (J) (K L) (D) H) 
			   (AND (K A B) L (C) (D) J) 
			   (AND G (C) K L (J LL MM H) (D (H G F V))))) 
	     '(AND (c) (OR (AND A B (F H)) 
			   (AND X Y (J) (K L) H) 
			   (AND (K A B) L J) 
			   (AND G K L (J LL MM H) (D (H G F V)))))))

(checkequal "(OR (OR ) (OR (AND..) (AND..)))var1" 
	    ( (polland '(or (or ff hh jj )
			    (or (and b a)(and a d)(and b g) (and b h)))) 
	      '(or ff hh jj (and a (or b d)) (and b (or g h)))))

(checkequal "(OR (OR ) (OR (AND..) (AND..)))var2" 
	    ( (polland '(or (or ff hh jj )
			    (or (and b a)(and a d)(and b g) (and b h)))) 
	      '(or ff hh jj (and b (or a g h)) (and a d))))


(checkequal "(OR ..(and ..) (and ...))2" 
	    ((polland '(or (and a c d e)(and a c f g) 
			   (and a x y z) (and y a i l))) 
	     '(and a (or (and c (or (and d e) (and  f g))) 
			 (and y (or (and x z) (and i l)))))))
