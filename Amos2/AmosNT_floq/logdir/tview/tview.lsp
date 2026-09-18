(defun baseuri ()
  (caar (getfunction 'baseuri nil)))

(defun from-relationalp (object &optional typenamep)
  "Does the object come from an rdbms, if typenamep=T object is a typename."
  (when (or (oid-p object) typenamep)
    (let* ((type (or (and typenamep (gettypenamed (mksymbol object)))
		     (first (oid-types object))))
	   (ccfn (getobject type 'cclusterfn)))
      (and ccfn 
	   (memq _relational_ 
		 (oid-types (car (getfunction-firsttuple 
				  (getfunctionnamed 
				   'function.datasource->datasource) 
				  (list (theresolvent ccfn)) 
				  t))))))))

(defun downcase-oidname (obj)
  (string-downcase (oid-name obj)))

(defun amos-to-subject-uri (object)
  "Create a uri for the subject part of an RDF triple from an amos object."
  (uri (concat (baseuri) 
	       (downcase-oidname (first (oid-types object))) 
	       "#oid" (oid-idno object))))

(defun amos-to-prop-uri (function)
  "Create a uri for the property part of an RDF triple from an amos function."
  (uri (concat (baseuri)
	       (concatl (append2 (mapcar #'downcase-oidname 
					 (get-resolvent-argtypes function))
				 (list (string-downcase 
					(generic-fnname function))))
			"/"))))

(defun keys-to-string (object)
  "Create a string represenation from the keys of an object from an rdbms."
  (let* ((type (first (oid-types object)))
	 (keys (getobject type 'keys)))
    (concatl (mapcar #'(lambda (key)
			 (concat (string-downcase (first key)) ":" 
				 (string-downcase (second key)) ":"
				 (car (getfunction-firsttuple 
				       (resolvename (second key) (list object))
				       (list object)))))
		     keys)
	     "/")))

(defun resource-+ (fno object)
  "Turn an object (literal, oid, or relational) into a resource URI."
  (cond ((from-relationalp object)
	 (osql-result object (uri (concat (baseuri)
					  (downcase-oidname 
					   (first (oid-types object)))
					  "#rel/" (keys-to-string object)))))
	((oid-p object) (osql-result object (if (function-p object) 
						(amos-to-prop-uri object)
					      (amos-to-subject-uri object))))
	(t (osql-result object object))))

(defun get-keys-from-string (uristr)
  "Extract the keys from a string (as produced by the keys-to-string function)"
  (let ((txt (maketextstream))
	(i 1)
	res)
    (formatl txt uristr)
    (textstreampos txt 0)
    (while (not (eof-p txt))
      (if (zerop (mod i 3))
	  (push (read-token txt ":/") res)
	(read-token txt ":/"))
      (incf i))
    (nreverse res)))

(defun uri-suffix (uristr)
  (car (getfunction-firsttuple
	(getfunctionnamed 'charstring.uri_suffix->charstring)
	(list uristr))))

(defun split-on-char (str char)
  "Split 'str' into a list of substrings around occurences of 'char'."
  (let ((pos (string-pos str char)))
    (if pos
	(cons (if (plusp pos) (substring 0 (1- pos) str) "")
	      (split-on-slashes (substring (1+ pos) (length str) str)))
      (list str))))

(defun resource+- (fno object literal)
  "Turn a resource URI back to an object."
  (if (eq (typename literal) 'uri)
      (let* ((uristr (uri-id literal))
	     (square-pos (string-pos uristr "#")))
	(if square-pos			; instance
	    (let ((instance-type (mksymbol (substring (1+ square-pos) 
						      (+ square-pos 3) 
						      uristr))))
	      (case instance-type
		(oid (let ((oidnr (mksymbol (substring (+ square-pos 4) 
						       (length uristr) 
						       uristr))))
		       (when (integerp oidnr)
			 (osql-result (getobjectnumbered oidnr) literal))))
		(rel (let* ((type (mksymbol (uri-suffix (substring 
							 0 (1- square-pos) 
							 uristr))))
			    (obj (create-transient-object type))
			    (keys (get-keys-from-string (substring 
							 (+ square-pos 4) 
							 (length uristr) 
							 uristr))))
		       (putobject obj 'encodes (if (= (length keys) 1) 
						   (car keys) keys))
		       (osql-result obj literal)))
		(otherwise (osql-result literal literal))))
	  (let* ((fnsig (uri-suffix uristr))
		 (last-slash-pos (or (string-rightpos fnsig "/") -1))
		 (fnname (mksymbol (substring (1+ last-slash-pos) 
					      (length fnsig) fnsig)))
		 (types (and (plusp last-slash-pos) 
			     (mapcar #'mksymbol
				     (split-on-char (substring 
						     0 (1- last-slash-pos) 
						     fnsig) "/")))))
	    (if types
		(let ((fn (catch-error (get-most-specific-resolvent fnname 
								    types))))
		  (osql-result (if (error? fn) literal fn) literal))
	      (let ((fn (getfunctionnamed fnname t)))
		(osql-result (if fn fn literal) literal))))))
    (osql-result literal literal)))

(defun make-attribute-getter (name type argtype restype &optional no-execute)
  "Create a function that selects all properties 'name' from 'type' as RDF 
   triples.
   If no-execute=T print the generated function instead of creating it."
  (setf name (string-downcase name))
  (setf type (string-downcase type))
  (setf argtype (string-downcase argtype))
  (setf restype (string-downcase restype))
  (let ((str (concat "create function " type "_" name 
		     "() -> bag of <uri,uri,literal> as select "
		     "resource(obj),resource(#'"argtype"."name"->"restype
		     "'),resource(" name "(obj)) "
		     "from " type " obj;")))
    (if no-execute
	(formatl t str t)
      (amos-execute str))
    (concat type "_" name)))

(defun make-type-getter (typename attr-fn-list &optional no-execute)
  "Create a function that selects all properties from 'typename' as RDF 
   triples.
   If no-execute=T print the generated function instead of creating it."
  (setf typename (string-downcase typename))
  (let ((str (concat "create function " typename 
		     "() -> bag of <uri s, uri p, literal o> as "
		     "select s,p,o where "
		     (concatl (mapcar #'(lambda (fnname)
					  (concat "<s,p,o> in " fnname "()"))
				      attr-fn-list)
			      " or ")
		     ";")))
    (if no-execute
	(formatl t str t)
      (amos-execute str))))

(defun find-if (testfn list)
  "Find the first element in list for which 'testfn' returns non-nil."
  (dolist (e list)
    (when (funcall testfn e)
      (return e))))

(defun rewrite-resource (rw)
  "Remove unneded calls to resource on literals.
   Eg. ((FOO.PROPERTY->CHARSTRING _V1- _V2+)
        (OBJECT.RESOURCE->LITERAL _V2- _V3+))
    ->
       (FOO.PROPERTY->CHARSTRING _V1- _V3+)"
  (let* ((this (rewrite-this rw))
	 (vars (predicate-variables this))
	 (rest (rewrite-rest rw)))
    (if (null (second vars))
	'substitute
      (let ((resource-pred (find-if #'(lambda (rp)
					(and (eq (predicate-operator rp)
						 (getfunctionnamed 
						  'object.resource->literal))
					     (eq (second vars) 
						 (first (predicate-variables 
							 rp)))))
				    rest)))
	(if resource-pred
	    (prog1 'success
	      (setf (rewrite-translated rw) (list (predicate-operator this) 
						  (first vars)
						  (second 
						   (predicate-variables 
						    resource-pred))))
	      (rewrite-retract resource-pred rw))
	  'substitute)))))

(defun get-functions-using-type (type &optional stoptype)
  (setf stoptype (or stoptype _userobject_))
  (mapcan #'(lambda (tp)
	      (copy-tree (getobject tp 'usedbyfunction)))
	  (subset (getobject type 'allsupertypes)
		  #'(lambda (tp)
		      (osql-subtypep tp stoptype t)))))

(defun triple-view (typename)
  "Create a triple view of the type named 'typename'. A triple view is a 
   function that selects all binary, stored attributes of a type and its 
   supertypes."
  (let ((tp (gettypenamed typename))
	attr-fn-list)
    (dolist (fn (get-functions-using-type tp))
      (let ((atl (append (get-resolvent-argtypes fn) 
			 (get-resolvent-restypes fn))))
	(when (and (relationp fn)
		   (osql-subtypep tp (first atl))
		   (= (length atl) 2))
	  (push (make-attribute-getter (generic-fnname fn) 
				       typename 
				       (oid-name (first atl))
				       (oid-name (second atl))) 
		attr-fn-list)
	  (when (and (neq (second atl) (gettypenamed 'uri))
		     (memq _literal_
			   (getobject (second atl) 'allsupertypes)))
	    (add-rewriter fn '(+ +) 'rewrite-resource)))))
    (when attr-fn-list
      (make-type-getter typename attr-fn-list))))

(defun string-subst-last (to from string)
  "Substitute the last occurence of a character in a string."
  (let ((pos (string-rightpos string from)))
    (concat (substring 0 (1- pos) string)
	    to
	    (substring (1+ pos) (length string) string))))

(defun make-rel-attribute-getter (name type &optional no-execute)
  "Create a function that selects all properties 'name' from 'type' 
   where 'type' is mapped to a relational database."
  (setf name (string-downcase name))
  (setf type (string-downcase type))
  (let* ((base (concat (baseuri) (substring 0 (1- (string-rightpos type "_"))
					    type) "/"))
	 (str (concat "create function " type "_" name 
		      "() -> bag of <uri,uri,literal> as select "
		      "resource(obj), uri('"base name"'), "name"(obj) "
		      "from " (string-subst-last "@" "_" type) " obj;")))
    (if no-execute
	(formatl t str t)
      (amos-execute str))
    (concat type "_" name)))

(defun rel-triple-view (typename)
  "Create a triple view of the relational mapped type named 'typename'."
  (let* ((tp (gettypenamed typename))
	 attr-fn-list)
    (dolist (attr (getobject tp 'properties))
      (let ((attr-type (first attr))
	    (attr-name (second attr)))
	(push (make-rel-attribute-getter attr-name typename) attr-fn-list)))
    (when attr-fn-list
      (make-type-getter typename attr-fn-list))))

(defun rewrite-resource2 (rw)
  "Remove even more unnecessary calls to resource on literals."
  (let* ((this (rewrite-this rw))
	 (vars (predicate-variables this))
	 (rest (rewrite-rest rw))
	 (fvar (first vars))
	 (svar (second vars)))
    (if (or (and svar (eq (binding-type (getbinding svar)) 
			  (gettypenamed 'uri)))
	    (null rest))
	'substitute
      (let (frobbed)
	(dolist (rp rest (or (and frobbed 'success) 'substitute))
	  (cond ((eq fvar (first (predicate-variables rp)))
		 (setf frobbed t)
		 (rewrite-retract rp rw)
		 (rewrite-assert (list (predicate-operator rp) svar 
				       (second (predicate-variables rp))) rw))
		((eq fvar (second (predicate-variables rp)))
		 (setf frobbed t)
		 (rewrite-retract rp rw)
		 (rewrite-assert (list (predicate-operator rp) 
				       (first (predicate-variables rp)) svar) 
				 rw)
		 )))))))

(add-rewriter (getfunctionnamed 'object.resource->literal) '(+ -) 
	      'rewrite-resource2)

(defun make-triple-view (fno typename)
  (if (from-relationalp typename t)
      (osql-result typename (not (null (rel-triple-view (mksymbol typename)))))
    (osql-result typename (not (null (triple-view (mksymbol typename)))))))
