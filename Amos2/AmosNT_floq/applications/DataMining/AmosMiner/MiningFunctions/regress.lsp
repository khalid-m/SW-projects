;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CLASSIFICATION TEST
 
(load-amosql "a1.osql")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CLUSTERING TEST

(checkequal "functions defined"
  ((null (theresolvent 'disp_clustering3d)) nil)
)

;; LOAD THE DATA

(osql "create function datapoints()->Bag of Vector of Number dp as stored;")

(osql "set datapoints() = read_ntuples('data/clusterdata1.nt');")

(checkequal "Clustering: read data" 
	    ((osql "count(datapoints());") 
	     '((150))))

(osql "create function clustered_points(Number cid) -> Bag of Vector of Number dp as stored;")

;; TEST KMEANS

(osql "set :vic = {first(datapoints()),last(datapoints())};")

(osql "set :vfc = kmeans_fc(:vic, #'datapoints');")

(osql "set clustered_points(cid) = x
   from Vector of Number x, Number cid
  where cid = get_nearest_centroid_id(x, :vfc)
    and x in datapoints();")

(checkequal "kMeans clustering and SSE"
	    ((round (caar (osql "sse(select cid, clustered_points(cid) from Number cid);")))
	     449))

;; TEST DBSCAN 

(osql "create function ddrtab(Vector of Number p) -> Bag of Vector of Number q as stored;")

(osql "set :eps = 0.3;")

(osql "set :minpts = 5;")

(osql "set ddrtab(p) = neighbors
         from Vector of Number p, Bag of Vector of Number neighbors
         where p in datapoints()
         and neighbors = neighbors(p, datapoints(), :eps)
         and count(neighbors) >= :minpts;")

(osql "create function corepoints() -> Bag of Vector of Number;")

(osql "set corepoints() = (select distinct p
                             from Vector of Number p, Vector of Number q
                            where q in ddrtab(p));")

(osql "remove clustered_points(cid) = x from Vector of Number x, Number cid;")

(osql "dbscan(corepoints(), #'ddrtab', #'clustered_points');")

(checkequal "DBSCAN clustering"
	    ((caar (osql "count(corepoints());")) 47) ; number of core points
	    ((caar (osql "count(select distinct cid 
                                  from Number cid, Vector of Number x 
                                 where x in clustered_points(cid));")) 6) ; number of clusters
	    ((round (caar (osql "sse(select cid, clustered_points(cid) 
                                       from Number cid);"))) 8))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ARM TEST

(osql "create function transactions() -> Bag of Vector of Number as stored;")

(osql "set transactions() = read_ntuples('data/transactions1000.nt');")

(checkequal "ARM: read data" 
	    ((osql "count(transactions());") 
	     '((1000))))

(osql "create function frequent_itemsets()-> Bag of (Vector of Number fis, 
                                              Number supp) as stored;")

(osql "set :minsupp = 100;")

(osql "set frequent_itemsets() = propad(transactions(), :minsupp);")

(checkequal "frequent itemsets generated"
	    ((caar (osql "count(frequent_itemsets());")) 68))
	    
(osql "set :minconf = 0.7;")

(checkequal "association rules generated"
	    ((caar (osql "count(arm(frequent_itemsets(), :minconf));")) 210))


