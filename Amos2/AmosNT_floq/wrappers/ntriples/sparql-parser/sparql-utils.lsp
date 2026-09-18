;;Utility functions used in AmosQL translations from SparQL queries

;; AREGEX
;; Substitute all .* to * (converting REGEX format)

(defun aregex (regex)
  (do ((buf "") (pos 0 (1+ pos)) (pos0 0) (ch2 nil))
      (nil nil)
    (setq ch2 (substring pos (1+ pos) regex))
    (when (member ch2 '(".*" ""))
      (when (< pos0 pos) 
	(setq buf (concat buf (substring pos0 (1- pos) regex))))
      (setq pos0 (1+ pos))
      (when (string= ch2 "") (return buf)))))

(foreign-lispfn aregex ((Charstring regex)) ((Charstring))
		(foreign-result (aregex regex)))

;; OPTIONAL

(osql "create function optional(Bag b, Object o) -> Object r as foreign 'optional--+';")

(foreign-lispfn nil1 () ((Object)) (foreign-result nil)) 

(defun optional--+ (fno b o r)
	(let ((bag-value nil))
	  (mapbag b (f/l (row) (setq bag-value t) (osql-result b o (car row))))
	  (unless bag-value (osql-result b o o))))

(defun optional-resulttypes (fno args)
	(let ((res-types (type-parameters (arg-type (car args)))))
		(unless res-types (setq res-types (list (gettypenamed 'object)))) ;;Treat bags as bags of objects
		(unless (osql-subtypep (arg-type (cadr args)) (car res-types))
			(raise-resolve-error fno (cons 'incompatible args)))
		res-types))

(set-resulttypesfn (theresolvent 'optional) 'optional-resulttypes)

;; RDFR

(osql "create function rdfr_iri(Charstring s) -> RDFResource as rdfr(0,s,'','');")

(foreign-lispfn rdfr_string ((Charstring s) (Charstring lang)) ((RDFResource))
		(foreign-result (rdfr-make 1 s lang nil))) 

;typed literals are made with rdfr(1,s,lang,type_iri)

(osql "create function rdfr_number(Number n) -> RDFResource as rdfr(3,n,'','');")

(foreign-lispfn rdfr_eq ((RDFResource a) (RDFResource b)) ((Boolean))
		(foreign-result (and (= (rdfr-kind a) (rdfr-kind b)) 
				     (equal (rdfr-data a) (rdfr-data b)) 
				     (equal (rdfr-lang a) (rdfr-lang b)) 
				     (equal (rdfr-datatype a) (rdfr-datatype b)))))

(osql "create function rdfr_neq(RDFResource a, RDFResource b) -> Boolean as select TRUE where notany(rdfr_eq(a,b));")

(foreign-lispfn rdfr_false ((RDFResource a)) ((Boolean))
		(foreign-result (selectq (rdfr-kind a)
					 ((0 1 2) (or (null (rdfr-data a)) (string= (rdfr-data a) "")))
					 (3 (or (null (rdfr-data a)) (= (rdfr-data a) 0)))
					 nil)))

(foreign-lispfn rdfr_nil () ((RDFResource))
		(foreign-result (rdfr-make 1 "" "" nil)))

;; RDFR Aggregates

(foreign-lispfn rdfr_sum((bag of RDFResource b)) ((RDFResource))
		(let ((sum 0))
		  (mapbag b (f/l (tpl)
				 (when (= (rdfr-kind (car tpl)) 3)
				   (setq sum (+ sum (rdfr-data (car tpl)))))))
		  (foreign-result (rdfr-make 3 sum "" nil))))

(foreign-lispfn rdfr_min((bag of RDFResource b)) ((RDFResource))
		(let ((min nil) val)
		  (mapbag b (f/l (tpl)
				 (when (= (rdfr-kind (car tpl)) 3)
				   (setq val (rdfr-data (car tpl)))
				   (when (or (null min) (< val min)) (setq min val)))))
		  (if min
		      (foreign-result (rdfr-make 3 min "" nil))
		    (foreign-result nil))))

(foreign-lispfn rdfr_max((bag of RDFResource b)) ((RDFResource))
		(let ((max nil) val)
		  (mapbag b (f/l (tpl)
				 (when (= (rdfr-kind (car tpl)) 3)
				   (setq val (rdfr-data (car tpl)))
				   (when (or (null max) (> val max)) (setq max val)))))
		  (if max
		      (foreign-result (rdfr-make 3 max "" nil))
		    (foreign-result nil))))

(foreign-lispfn rdfr_avg((bag of RDFResource b)) ((RDFResource))
		(let ((sum 0)
		      (count 0.0))
		  (mapbag b (f/l (tpl)
				 (when (= (rdfr-kind (car tpl)) 3)
				   (1++ count)
				   (setq sum (+ sum (rdfr-data (car tpl)))))))
		  (if (> count 0)
		      (foreign-result (rdfr-make 3 (/ sum count) "" nil))
		    (foreign-result nil))))


