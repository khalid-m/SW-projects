(osql "create function datapoints(Vector of Number dp)->Number i
        /* Function to store data points to be clustered as bag of coordinate vectors  */
        as stored;")
(osql "
	/* For fast search of values of function datapoints() */
	create_index('datapoints','dp','xtree','unique');")

(osql "
          for each Vector of Number v , Integer i 
           where v = {i, i+1, i+2}
           and i in iota(1, 150)
         	 add datapoints(v) = i;

")

(checkequal 
 "Map and Count"
 ((osql "count(extent(#'datapoints'));")
  '((150)))) 

(checkequal 
 "First element"
 ((osql "first(extent(#'datapoints'));")
  '((#(#(1 2 3) 1)))))

(checkequal 
 "Last element"
 ((osql "last(extent(#'datapoints'));")
  '((#(#(150 151 152) 150)))))

