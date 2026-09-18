(defun ccompare (x y)
  "Compare x and y using their first elements as subjects to be compared"
  (cond ((zerop (compare (first x) (first y))) 
	 (compare (second x) (second y)))
	(t (compare (first x) (first y)))))



(checkequal 
 "Full scan MYMAP"
 ((length (osql "q();"))
  (length '(("Ansders" 795909542) ("Johan" 795909542) ("Hanna" 765805544) 
	  ("Julia" 795729542) ("Alex" 765809542) ("Diego" 765809542)))))

(checkequal 
 "Index scan MYMAP"
 ((length (osql "q1(795909542);"))
  (length '(("Ansders") ("Johan")))
))
:osql