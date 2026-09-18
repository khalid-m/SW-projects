(osql "create function datapoints(Number i)->Bag of Vector of Number dp
        /* Function to store data points to be clustered as bag of coordinate vectors  */
        as stored;")
(osql "
	/* For fast search of values of function datapoints() */
	create_index('datapoints','dp','xtree','multiple');
        drop_index('datapoints', 'i');
")

(osql "
          for each Vector of Number v , Integer i 
          where v = {i, i+1, i+2}
          and i in iota(1, 150)
  	      add datapoints(i) = v;")

(checkequal 
 "Map and Count"
 ((osql "count(extent(#'datapoints'));")
  '((150)))) 

(checkequal 
 "First element"
 ((osql "first(extent(#'datapoints'));")
  '((#(1 #(1 2 3))))))

(checkequal 
 "Last element"
 ((osql "last(extent(#'datapoints'));")
  '((#(150 #(150 151 152))))))

