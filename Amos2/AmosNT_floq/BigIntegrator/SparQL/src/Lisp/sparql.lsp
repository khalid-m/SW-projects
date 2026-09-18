(defglobal _sparql_ (createtype 'sparql '(datasource)))

(osql "create function sparql_query(charstring query, charstring address)->vector as foreign 'JAVA:SparQLQuery/sparqlQuery';")

(defun lispify-name (name)
  (concatl (subst "-" "_" (explode name)) ""))

(defun delispify-name (name)
  (concatl (subst "_" "-" (explode name)) ""))

(defun sparql-cc-query (address)
  (mapfunction (resolvename 'sparql_query '("" ""))
	       (list "SELECT ?s ?p ?o WHERE {?s ?p ?o}" address)
	       #'(lambda (row)
		   (applyarray #'osql-result (car row)))))

(defun sparql (fno name address ds)
  (setf ds (/createobject 'sparql name))
  (/putobject ds 'sparql-address address)
  (let* ((fn-lisp-name (concat (lispify-name name) "-CC"))
	 (fn-amos-name (delispify-name fn-lisp-name))
	 (absorber (mksymbol (caar (getfunction 'get_absorber (list (arg-type ds))))))	 
	 )
    (defc (mksymbol fn-lisp-name)
	`(lambda (fno) (sparql-cc-query ,address)))
    (let ((cc-fno (createfunction fn-amos-name
				  nil
				  '((charstring s) (charstring p) (charstring o))
				  'multidirectional
				  `(("fff" foreign ,fn-lisp-name)))))
      (/putobject cc-fno 'tablename name)
      (/putobject cc-fno 'absorber absorber) ;;needed
      (/putobject cc-fno 'cclusterfct? t)
      (addfunction 'absorbability (list ds) (list cc-fno))
      (addfunction 'queryinfo_updater (list (arg-type ds) cc-fno) (list "sparql-translate-core-cluster"))
      (addfunction 'datasource (list cc-fno) (list ds)) 
      (addfunction 'extent_collection (list cc-fno) (list (mkstring name)))
      (create-mapped-type (mksymbol name)
			  nil
			  '((charstring s) (charstring p) (charstring o))
			  '((charstring s) (charstring p) (charstring o))
			  cc-fno)
      (osql-result name address ds))))

(osql "create function sparql(charstring name, charstring address)->sparql as foreign 'sparql';")

(defun print-hash-table (htab)
  (maphash #'(lambda (k v)
	       (formatl t "Key: " k " Val: " v t))
	   htab))
(quote
(defmacro my-defstruct (name short-name &rest slots)
  (let ((names (mapcar #'(lambda (slot)
			   (pack name '- slot))
		       slots))
	(short-names (mapcar #'(lambda (slot)
				 (pack short-name '- slot))
			     slots)))
    `(progn
       (defstruct ,name ,@slots)
       ,@(mapcar #'(lambda (n sn)
		     (list 'movd (kwote n) (kwote sn)))
		 names
		 short-names)
       ,@(mapcar #'(lambda (n sn)
		     (list 'put (kwote sn) ''setfmethod (list 'get (kwote n) ''setfmethod)))
		 names
		 short-names))))
)

(quote
(my-defstruct sparql-query sq
  where
  invars
  outvars
  environment
  bvar-count
  bvar-db
  filters)
)

(my-defstruct graph-fragment gf
  sub
  pred
  obj)

(defun gf-set (gf where what)
  (case where
    (sub (setf (gf-sub gf) what))
    (pred (setf (gf-pred gf) what))
    (obj (setf (gf-obj gf) what))))

(defmacro add-last (where what)
  `(setf ,where (nconc1 ,where ,what)))

(defun replace-chars-with-char (string char-list char)
  (packlist (sublis (pairlis char-list
			     (buildn (length char-list) char))
		    (explode string))))

(defun sparql-translate-core-cluster (ds pred env acc)
  (let ((gf (make-graph-fragment)))
    (mapc #'(lambda (arg entity)
	      (cond ((named-varsymbolp arg)
		     (cond ((bound arg env)
			    (unless (get-entity arg env t)
			      (set-entity arg env entity))
			    (unless (or (eq ds (datasource arg env))
					(memq arg (sq-invars acc)))
			      (add-last (sq-invars acc) arg)
			      (incf (sq-bvar-count acc))
			      (setf (gethash arg (sq-bvar-db acc)) (sq-bvar-count acc)))
			    (gf-set gf entity arg))
			   ((free arg env)
			    (bind arg env :entity entity :datasource ds)
			    (add-last (sq-outvars acc) arg)
			    (gf-set gf entity arg))
			   (t;;what better can i do with this?
			    (bind arg env :entity entity :datasource ds)
			    (add-last (sq-outvars acc) arg)
			    (gf-set gf entity arg))
			   ))
		    ((constantsymbolp arg)
		     (gf-set gf entity arg))))
	  (predicate-arguments pred)
	  '(sub pred obj))
    (add-last (sq-where acc) gf)
    acc))

(defmacro with-enclosing-characters (stream-and-char &rest body)
  (let* ((stream (first stream-and-char))
	 (char (second stream-and-char))
	 (end-char (case char
		     ("(" ")")
		     ("[" "]")
		     ("{" "}")
		     ("<" ">")
		     ("\"" "\"")
		     ("'" "'")
		     (error (formatl nil "Don't know how to close " char)))))
    `(progn
       (formatl ,stream ,char)
       ,@body
       (formatl ,stream ,end-char))))

(defun make-unique-var-emitter (basename)
  (let ((count 0))
    #'(lambda ()
	(incf count)
	(pack basename count))))

(defun create-query-string (acc)
  (with-string query-string
    (let ((var-emitter (make-unique-var-emitter 'x)))
      (labels ((emit (item)
		 (formatl query-string item " "))
	       (emit-var (var)
		 (formatl query-string "?" (replace-chars-with-char (mkstring var)
								    '("#" ".") "_") " "))
	       (emit-newline ()
		 (terpri query-string))
	       (emit-graph-part (part &optional quote)
		 (cond ((stringp part) (if quote
					   (formatl query-string " " quote part quote " ")
					   (formatl query-string part " ")))
		       ((symbolp part) (cond ((null part) (emit-var (funcall var-emitter)))
					     ((gethash part (sq-bvar-db acc))
					      (let ((bvar (gethash part (sq-bvar-db acc))))
						(if quote
						    (formatl query-string quote "$" bvar quote " ")
						    (formatl query-string "$" bvar " "))))
					     (t (emit-var part))))
		       (t (error "Dunno how to emit " part))))
	       (emit-graph-fragment (gf)
		 (emit-graph-part (gf-sub gf))
		 (emit-graph-part (gf-pred gf))
		 (emit-graph-part (gf-obj gf) "\"")
		 (formatl query-string "." t)))
	(emit 'select)
	(mapc #'emit-var (sq-outvars acc))
	(emit-newline)
	(emit 'where)
	(with-enclosing-characters (query-string "{")
	  (mapc #'emit-graph-fragment (sq-where acc))
	  (when (sq-filters acc)
	    (emit 'filter)
	    (with-enclosing-characters (query-string "(")
	      (let ((filter-strings (mapcar #'(lambda (filter)
						(case (first filter)
						  (regex (emit-regex-filter-string (rest filter)))
						  (cmp (emit-cmp-filter-string (rest filter)))))
					    (sq-filters acc))))
		(emit (concatl filter-strings " && "))))))
	query-string))))

(defun emit-regex-filter-string (filter)
  (with-string filter-string
    (let ((arg (first filter))
	  (pattern (second filter)))
      (princ "regex" filter-string)
      (with-enclosing-characters (filter-string "(")
	(formatl filter-string "?" arg ",")
	(with-enclosing-characters (filter-string "\"")
	  (princ pattern filter-string))))))

(defun emit-cmp-filter-string (filter)
  (concat "?" (concatl (mapcar #'mkstring filter) " ")))

(defun create-amos-query-function (ds query-string acc)
  (let ((address (getobject ds 'sparql-address))
	arg-types res-types vrefs)
    (dolist (ov (sq-outvars acc))
      (add-last res-types (list 'charstring ov)))
    (dotimes (i (length (sq-outvars acc)))
      (add-last vrefs (list 'vref 'v i)))
    (dolist (iv (sq-invars acc))
      (add-last arg-types (list 'charstring iv)))
    (createfunction '*transient*
		    arg-types
		    res-types
		    vrefs
		    '((vector v))
		    (if (sq-invars acc)
			(list '= 'v (list 'sparql_param_query 
					  query-string 
					  `(vector ,@(sq-invars acc))
					  address))
			(list '= 'v (list 'sparql_query 
					  query-string
					  address))))))

(osql "create function sparql_cost(function,vector,vector)-><integer,integer> as select 100,100;")

(defun minl (list &optional cmpfn)
  (maxl list (if (null cmpfn) 
		 #'< 
		 cmpfn)))

(defun pos-of-closest-char (string &rest chars)
  (minl (mapcar #'(lambda (char)
		    (or (string-pos string char) (1+ (length string))))
		chars)))

(defun split-string (string split-pos)
  (list (substring 0 split-pos string)
	(substring (1+ split-pos) (1- (length string)) string)))

(defun realize-bound-variables-aux (str i val res)
  (let ((pos (string-pos str "$")))
    (if pos
	(let ((strings (split-string str (1- pos))))
	  (push (first strings) res)
	  (let ((strings (split-string (second strings) 
				       (1- (pos-of-closest-char (second strings) "}" " " ">" "\"")))))
	    (if (= (mksymbol (substring 1 (1- (length (first strings))) (first strings))) i)
		(push val res)
		(push (first strings) res))
	    (realize-bound-variables-aux (second strings) i val res)))
	(progn
	  (push str res)
	  (concatl (nreverse res) "")))))

(defun realize-bound-variables (str i vals)
  (if (null vals)
      str
      (realize-bound-variables (realize-bound-variables-aux str i (car vals) "") (1+ i) (cdr vals))))

(defun sparql-param-query (fno query params address)
  (let  ((query-string (realize-bound-variables query 1 (arraytolist params))))
    (mapfunction (resolvename 'sparql_query '("" ""))
		 (list query-string address)
		 #'(lambda (row)
		     (osql-result query params address (car row))))))

(osql "create function sparql_param_query(charstring,vector,charstring)->vector as foreign 'sparql-param-query';")

(defun numbers (from to)
  (if (> from to)
      nil
      (cons from (numbers (1+ from) to))))

(defmacro with-predicate-arguments (vars-and-pred &rest body)
  (let ((vars (first vars-and-pred))
	(pred (second vars-and-pred))
	(pred-var (gensym)))
    `(let ((,pred-var ,pred))
       (let (,@(mapcar #'(lambda (var i)
			   (list var (list 'predicate-argument i pred-var)))
		       vars
		       (numbers 1 (length vars))))
	 ,@body))))

(defun sparql-translate-like (ds pred env acc)
  (with-predicate-arguments ((arg pattern) pred)
    (when (stringp pattern)
      (add-last (sq-filters acc) (list 'regex arg pattern))
      acc)))

(defun sparql-translate-comparison (ds pred env acc)
  (with-predicate-arguments ((arg1 arg2) pred)
    (let ((op (generic-fnname (predicate-operator pred))))
      (when (and (named-varsymbolp arg2) (or (stringp arg1) (numberp arg1)))
	(let ((temp arg1))
	  (setf arg1 arg2)
	  (setf arg2 temp))
	(setf op (case op
		   (< '>)
		   (> '<)
		   (<= '>=)
		   (>= '<=))))
      (when (and (named-varsymbolp arg1) (or (stringp arg2) (numberp arg2)))
	(when (stringp arg2)
	  (setf arg2 (concat "\"" arg2 "\"")))
	(add-last (sq-filters acc) (list 'cmp arg1 op arg2))
	acc))))

; just benchmark-related stuff below here

(defun sparql2-translate-core-cluster (ds pred env acc)
  nil)

(defun sparql2 (fno name address ds)
  (setf ds (/createobject 'sparql name))
  (/putobject ds 'sparql-address address)
  (let* ((fn-lisp-name (concat (lispify-name name) "-CC"))
	 (fn-amos-name (delispify-name fn-lisp-name)))
    (defc (mksymbol fn-lisp-name)
	`(lambda (fno) (sparql-cc-query ,address)))
    (let ((cc-fno (createfunction fn-amos-name
				  nil
				  '((charstring s) (charstring p) (charstring o))
				  'multidirectional
				  `(("fff" foreign ,fn-lisp-name)))))
      (/putobject cc-fno 'defaultabsorbent 'sparql2-translate-core-cluster)
      (/putobject cc-fno 'datasource ds)
      (create-mapped-type (mksymbol name)
			  nil
			  '((charstring s) (charstring p) (charstring o))
			  '((charstring s) (charstring p) (charstring o))
			  cc-fno)
      (add-rewriter cc-fno '(+ + +) 'rewrite-extent)
      (osql-result name address ds))))

(osql "create function sparql2(charstring name, charstring address)->sparql as foreign 'sparql2';")

(osql "create function sparql_query_cache(charstring)->bag of vector as stored;")

(osql "
create function sparql_cached_query(charstring query, charstring address) 
                                   -> bag of vector
as begin
 if notany(sparql_query_cache(address)) then
  for each charstring s, charstring p, charstring o
      where {s,p,o} = sparql_query(query,address)
    add sparql_query_cache(address) = {s,p,o};
  for each charstring s, charstring p, charstring o
      where {s,p,o} = sparql_query_cache(address)
    return {s,p,o};
end;
")

(defun sparql-cached-cc-query (address)
  (mapfunction (resolvename 'sparql_cached_query '("" ""))
	       (list "SELECT ?s ?p ?o WHERE {?s ?p ?o}" address)
	       #'(lambda (row)
		   (applyarray #'osql-result (car row)))))

(defun sparql3 (fno name address ds)
  (setf ds (/createobject 'sparql name))
  (/putobject ds 'sparql-address address)
  (let* ((fn-lisp-name (concat (lispify-name name) "-CC"))
	 (fn-amos-name (delispify-name fn-lisp-name)))
    (defc (mksymbol fn-lisp-name)
	`(lambda (fno) (sparql-cached-cc-query ,address)))
    (let ((cc-fno (createfunction fn-amos-name
				  nil
				  '((charstring s) (charstring p) (charstring o))
				  'multidirectional
				  `(("fff" foreign ,fn-lisp-name)))))
      (/putobject cc-fno 'defaultabsorbent 'sparql2-translate-core-cluster)
      (/putobject cc-fno 'datasource ds)
      (create-mapped-type (mksymbol name)
			  nil
			  '((charstring s) (charstring p) (charstring o))
			  '((charstring s) (charstring p) (charstring o))
			  cc-fno)
      (add-rewriter cc-fno '(+ + +) 'rewrite-extent)
      (osql-result name address ds))))

(osql "create function sparql3(charstring name, charstring address)->sparql as foreign 'sparql3';")
