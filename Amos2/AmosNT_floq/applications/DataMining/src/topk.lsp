(defun bestK (fno b k dir res)
  (let* (top (order-sym (sortorder-symbol dir))
	     (i 0)
	     (cf (f/l (x y)
		      (selectq order-sym
			       (dec (< (compare (car x) (car y)) 0))
			       (> (compare (car x) (car y)) 0)))))
    (mapbag b (f/l (tpl)
		   (cond ((< i k)(1++ i)
			  (setq top (dmerge (list tpl) top cf))) 
			 ((funcall cf (car top) tpl)
			  (setq top (dmerge (list tpl) (cdr top) cf))))))
    (mapc (f/l (x) (osql-result b k dir (first x) (second x)))
	  top)))

(osql "create function bestK(bag, Integer k, 
Charstring dir)->bag of <object, object> as foreign 'bestK';")

(osql "create function topk(bag x, Integer k)
->bag of <object, object> as bestK(x, k, 'dec');")

(osql "create function leastk(bag x, Integer k)
->bag of <object, object> as bestK(x, k, 'inc');")
