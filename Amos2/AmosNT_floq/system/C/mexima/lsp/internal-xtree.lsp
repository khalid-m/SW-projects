;; Function returns bag of vector <Object obj, Number dist>. 
;; In which, "dis" is distance from given point to obj.
;; Having "dis" makes the rewrite EUCLID easily to handle 
;; other inequalities such as != , = >=, etc
;; It is handled by adding extra predicate known as post-filter
(osql "create function xtree_distance_search_fn(Integer, Function f, 
	     Vector of Number, Number)-> Bag of (Object, Number) 
         as multidirectional ('bbbbff' foreign 'xtree_distance_search_fn' cost {0.5, 0.5});")

;; Add an index (spatial)rewrite rule. It rewrites distance search 
;; pattern "d(x, y) < eps" to "xtree_distance_search" call.
(osql "add_index_rewrite_rule('XTREE', #'euclid',  #'XTREE_DISTANCE_SEARCH_FN');")
(osql "add_index_rewrite_rule('XTREE', #'manhattan', #'XTREE_DISTANCE_SEARCH_FN');")
(osql "add_index_rewrite_rule('XTREE', #'minkowski', #'XTREE_DISTANCE_SEARCH_FN');")
(osql "add_index_rewrite_rule('XTREE', #'intersection_distance', 
                                       #'XTREE_DISTANCE_SEARCH_FN');")

(osql "create function xtree_knn_search_fn(Integer xtId, Function fun,
	    Vector of Number f, Integer k) ->Bag of Object as foreign 'xtree_knn_search_fn';")

;; Add knn rewrite rule. Any call to built in knn operation
;; will be investigate and rewritten if there is such an spatial
;; index 
(osql "add_knn_rewrite_rule('XTREE', 'XTREE_KNN_SEARCH_FN');")
