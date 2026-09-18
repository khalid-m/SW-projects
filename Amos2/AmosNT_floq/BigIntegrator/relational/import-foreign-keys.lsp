;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: import-foreign-keys.lsp,v $
;;; $Revision: 1.1 $ $Date: 2012/03/21 15:10:31 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Functions for mapping foreign key references to mapped types.
;;;              
;;; ===========================================================================

; OSQL front functions

(defun import_foreign_keys---+ (fno ds ccfno bpat name newfun)
  (let ((newfun
	 (import-foreign-keys ds ccfno (xbpatlist bpat) name)))
    (osql-result ds ccfno bpat name newfun)))

(defun import_foreign_keys--+ (fno ds ccfno bpat newfun)
  (let ((newfun
	 (import-foreign-keys ds ccfno (xbpatlist bpat) (getobject ccfno 'tablename))))
    (osql-result ds ccfno bpat newfun)))

; public functions

(defun import-foreign-keys (ds ccfno xbpat fnname)
  "Defines a function on top of a core-cluster function with an indicated
   'direction' from xbpat, taking into accont foreign keys. For example if
   a core-cluster function person_names@ds returns
    <int ssn1, int ssn2, charstring first_name, charstring last_name>, xbpat is
   '(- - + *), and the table person_names in ds has foreign keys (ssn1 ssn2) 
   referencing a table person's primary key, a function with name 
   fnname=first_names is created as:
      create function first_names(person@ibds ssn1ssn2) -> 
         /* bag of */charstring first_name as
      select first_name
      from charstring first_name, charstring last_name
      where person_names@ds_cc=<vector(_decode_(ssn1ssn2))[0],
                                vector(_decode_(ssn1ssn2))[1],
                                charstring first_name, 
                                charstring last_name>;"
  (if (not (getobject ccfno 'cclusterfct?))
      (error "Not a core-cluster function" ccfno))
  (if (/= (length xbpat) (+ (length (get-resolvent-argtypes ccfno))
			   (length (getrestype ccfno))))
      (error "Adornment does not match tuple width"))
  (if (not (getobject ccfno 'tablename))
      (error "Core-cluster function not mapped to a table" ccfno))
  (let* ((table        (getobject ccfno 'tablename))
	 (tuple        (make-tuple-spec ccfno))
	 (adornedprops (pair xbpat tuple))
	 (cdrcl        (function cdr))
	 (untypedargs  (mapfilter(f/l (x) (eq (car x) '-)) adornedprops cdrcl))
	 (untypedres   (mapfilter(f/l (x) (eq (car x) '+)) adornedprops cdrcl))
	 (arguments    (typeitup ds table untypedargs))
	 (results      (typeitup ds table untypedres))
	 (skipped      (mapfilter(f/l (x) (eq (car x) '*)) adornedprops cdrcl))
	 (resv         (mapcar (function second) results))
	 (pred         (list '= (list ccfno) (match-tuple ds table tuple))))
    (createfunction fnname arguments results resv skipped pred)))

(defun typeitup (ds table columns)
  "Transforms foreign key references into the mapped type corresponding to the
   basetable:
   '((integer ssn1)(charstring name)(integer ssn2)(integer deptno))
       foreign keys are: - (ssn1, ssn2) references person (ssno1, ssno2)
                         - (deptno) references department (number)
   => '((person x)(charstring name)(department d))
   order is preserved and a foreign key may not be split."
  (let (res)
    (dolist (column columns)
      (let* ((basetable (get-referenced-table ds table (second column))))
	(if basetable
	    (let* ((mt (wrapped-to-amos-type ds basetable))
		   (key (getobject mt 'keys)))
	      (if (subsetp key columns)
		  (push (list mt (make-key-name mt)) res)
		(error "Foreign key split" key)))
	  (push column res))))
    (reverse (unique res))))

(defun reference-as-type (ds table column)
  "For a column represented as (<type> <name>) returns the mapped type OID
   corresponding to the referenced table (by import_table) if a foreign key is 
   defined. Otherwise the type is the literal amos type OID associated with 
   the SQL type. If the table is not imported, an error is thrown."
  (let ((basetable (get-referenced-table ds table (second column))))
    (if basetable
	(wrapped-to-amos-type ds basetable)
      (gettypenamed (first column)))))

(defun make-key-name (mtpo)
  "Makes an unambiguous name from the keys in a mapped type."
  (packlist (mapcar (function second) (getobject mtpo 'keys))))

(defun match-tuple (ds table tuple)
  "Matches a tuple with signature <ssn1, ssn2, dept_no, dept_size>
     to <vector(_decode_(ssn1ssn2))[0],
         vector(_decode_(ssn1ssn2))[1],
         _decode_(dept_no),
         dept_size>
   by considering foreign keys. In this case (ssn1,ssn2) and dept_size, 
   respectively."
  (cons 'tuple
	(mapcar (f/l (property) 
		  (let* ((tp (reference-as-type ds table property))
			 (tpo (gettypenamed tp))
			 (name (second property))
			 (type (first property)))
		    (if (surrogate-type? tpo)
			`(vref (vector (_decode_ , (make-key-name tpo))) 
			       , (getpos (list type name) (getobject tpo 'keys)))
		      name)))
		tuple)))
		    
(defun make-tuple-spec (fno)
  "Creates a specification of the metadata concerning the tuple of a function.
   Each argument (input and output arguments are treated equally) gives rise to
   a list consisting of: the type, the name of the formal parameter, and the 
   unique constraint of the argument, if any. It is then the symbol 'unique."
  (let* ((relation (get-relation fno))
	 (unique-indices (if relation
			     (mapcar (function index-pos)
				     (mapfilter (function index-unique)
						(relation-indexes
						 (functiontype fno) relation)))))
	(sb (getselectbody fno))
	spec
	(i 0)
	)
    (dolists ((tpo  (mapcar (function oid-name) (get-resolvent-argtypes fno)))
	      (name (selectbody-argl sb)))
      (push `(, tpo , name ,@ (if (memq (++1 i) unique-indICES) '(unique))) spec))
    (dolists ((tpo  (mapcar (function oid-name) (getrestype fno)))
	      (name (selectbody-resl sb)))
      (push `(, tpo , name ,@ (if (memq (++1 i) unique-indICES) '(unique))) spec))
  (reverse spec)))

(defun xbpatlist (bpatstring)
  "Transforms an extended bpat string into the list representation."
  (mapcar (f/l (x) (selectq x ("f" '+) ("b" '-) ("0" '*) 
		     (error "Illegal binding symbol" x)))
	  (explode bpatstring)))