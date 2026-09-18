(with-directory "../../../applications/DataMining/AmosMiner"
	(osql "create function datapoints()->Bag of Vector of Number dp
	  /* Function to store data points to be clustered as bag of 
          coordinate vectors  */
	  as stored;")
	(osql "
	/* For fast search of values of function datapoints() */
	create_index('datapoints','dp','xtree','unique');")

	(osql "
	set datapoints() =  read_ntuples('data/clusterdata1.nt');")

	(checkequal 
	  "Map and Count"
	  ((osql "count(datapoints());")
	   '((150)))) 
 
	(checkequal 
	 "First element"
	 ((osql "first(datapoints());")
	  '((#(-3.3032 0.057064 -0.024258 -0.14053)))))

	(checkequal 
	 "Last element"
	 ((osql "last(datapoints());")
	  '((#(1.0894 1.7271 -0.017615 0.65526))))))

