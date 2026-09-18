;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: exportlog.lsp,v $
;;; $Revision: 1.5 $ $Date: 2006/04/05 10:53:32 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: The exportlog records information about export of one or
;;;              many types. This particular implementation of exportlog 
;;;              happens to write amos code for reimporting the created tables
;;;              back into Amos to the file *default-exportlog*
;;;              
;;; ===========================================================================
;;; $Log: exportlog.lsp,v $
;;; Revision 1.5  2006/04/05 10:53:32  torer
;;; Changed name of function LOG to not collide with CommonLisp standard
;;;
;;; ===========================================================================

(defvar *default-exportlog* "log.osql")
(defvar *export-stream*)
(defvar *altered-function-names*)
(defvar *deleted-types* '())
(defvar *endangered-stored-functions* '())
(defvar *endangered-foreign-functions* '())
(defvar *endangered-derived-functions* '())
(defvar *endangered-functions*)

(defun open-exportlog ()
  (let ((name *default-exportlog*))
    (setq *export-stream* (openstream name "w"))
    (setq *deleted-types* '())
    (setq *endangered-functions* '())
    (setq *endangered-stored-functions* '())
    (setq *endangered-foreign-functions* '())
    (setq *endangered-derived-functions* '())))

(defun close-exportlog ()
;  (redefine-endangered-fns *endangered-stored-functions*)
;  (redefine-endangered-fns *endangered-derived-functions*)
;  (redefine-endangered-fns *endangered-foreign-functions*)
  (redefine-fns *endangered-functions*)
  (closestream *export-stream*))

(defun redefine-fns (fnos)
  (dolist (fno (sort fnos (f/l (o1 o2) (< (oid-idno o1) (oid-idno o2)))))
    (let ((source (getobject fno 'source_text)))
      (cond (source
	     (log-print source)
	     ;; A derived function may be updateable, in which case we have to
	     ;; create a new set of update functions for it.
	     (if (and (equal (functiontype fno) "derived")
		      (selectbody-delpred (getselectbody fno)))	;ie updateable
		 (create-extra-update-fns fno)))
	    (t
	     ;; it's been declared via 'properties'...
	     (if (equal (functiontype fno) "stored")
		 (let ((sb (getselectbody fno)))
		   (log-print 
		    "create function "(generic-fnname fno)
		    "("(oid-name (car (get-resolvent-argtypes fno)))") -> "
		    (oid-name (car (getrestype fno)))";"))))))
    (log-terpri)))

(defun exportlog-report-type (tpo)
  (let ((supertpos (type-supertypes tpo))
	(already-deleted nil))
    (dolist (stpo supertpos)
      (if (member stpo *deleted-types*)
	  (setq already-deleted t)))
    (if (not already-deleted) (log-print "delete type "(oid-name tpo)";"))
    (push tpo *deleted-types*)
    (log-print "import_table(:a,'"(make-table-name tpo)"',"
	       "'"(oid-name tpo)"',"
	       "true,"
	       "{"(quote-types  supertpos)"});")))

(defun quote-types (tpos)
  (concatl tpos 
	   "," 
	   (f/l (tpo)
		(let* ((name   (oid-name tpo))
		       (tpname (if (eq name 'userobject) 
				   'userobject_ibds name)))
		  (concat "'"tpname"'")))))

(defun exportlog-report-keyedfn (fno)
  (log-print "/* Nu importerar vi "fno"*/")
  (log-terpri)
  (let* ((fnname  (generic-fnname fno))
	 (colname (make-column-name fnname)))
    (if (neq colname fnname)
	(restore-fnname fno fnname colname))
    (if (subtype-of (first (getrestype fno)) _userobject_)
	(restore-fntype fno))))

(defun exportlog-report-bagfn (fno)
  (let* ((table (make-table-name fno))
	 (sb (getselectbody fno))
	 (argname (first (selectbody-argl sb)))
	 (resname (first (selectbody-resl sb)))
	 (argtype (first (get-resolvent-argtypes fno)))
	 (restype (first (getrestype fno)))
	 (argtypename (oid-name argtype))
	 (restypename (oid-name restype))
	 (fnname  (generic-fnname fno))
	 (argcolname (make-column-name argname))
	 (resisusertype (subtype-of restype _userobject_))
	 (argisusertype (subtype-of argtype _userobject_))
	 (rescolname (make-column-name 
		      (pack (if argisusertype 'i_ "") fnname)))
	 (fullname (oid-name fno))
	 )
    (if (> (length (selectbody-argl sb)) 1) (error "det hära funkar ente!"))
    (if (> (length (selectbody-resl sb)) 1) (error "det hära funkar ente!"))
    (if (not argisusertype)
	(error "Can't export functions that belong to literal types"))
    (log-print "import_relation(:a,'"table"','"argcolname"','"rescolname"','"
	       table"',true);")
    (cond (resisusertype
	   (log-print "create function "fnname"("argtypename" x)"
		      " -> "restypename" y as")
	   (log-print "  select y")
	   (log-print "  from "restypename" y")
	   (log-print "  where _decode_(y) = "table"(_decode_(x));")

	   (log-print "/* Restoring types for the add function */")
	   (log-print "create function add_"fnname"("argtypename" x,"
		      restypename" y)")
	   (log-print "  -> integer as")
	   (log-print "  select add_"table"(_decode_(x),_decode_(y));")

	   (log-print "set add_function(functionnamed('"fullname"')) =")
	   (log-print "  functionnamed('"argtypename"."restypename".ADD_"
		      fnname"->INTEGER');")

	   (log-print "/* Restoring types for the set function */")
	   (log-print "create function set_"fnname"("argtypename" x,"
		      restypename" y)")
	   (log-print "  -> integer as")
	   (log-print "  select set_"table"(_decode_(x),_decode_(y));")
	   (log-print "set set_function(functionnamed('"fullname"')) =")
	   (log-print "  functionnamed('"argtypename"."restypename".SET_"
		      fnname"->INTEGER');")
	   )
	  
	  (t
	   (log-print "/* This function will not be 'updatable' */")
	   (log-print "create function "fnname"("argtypename" x)"
		      " -> "restypename" y as")
	   (log-print "  select "table"(_decode_(x));")))))

(defun exportlog-report-endangeredfn (fno)
  (if (equal (functiontype fno) "derived")
      (push fno *endangered-derived-functions*))
  (push fno *endangered-functions*))

(defun exportlog-report-skippped-fn (fno)
  (log-print "/* Function "(oid-name fno)" will stay in Amos */")
  (log-print (getobject fno 'source_text)))
  
(defun create-extra-update-fns (fno)
  (let* ((sb     (getselectbody fno))
	 (dp     (selectbody-delpred sb))
	 (rel    (predicate-operator dp))
	 (predof (getobject rel 'predof))
	 (predofname (generic-fnname predof))
	 (ai       (get-arginfo fno))
	 (fnname   (generic-fnname fno))
	 (fullname (oid-name fno)))
    (log-print "create function set_"fnname"("
	       (concatl ai ", " (f/l (ai) (concat (arginfo-typename ai)" "
						  (arginfo-name ai))))
	       ") -> integer as")
    (log-print "  select set_"predofname"("(concatl (predicate-arguments dp) 
						    ", ")");")
    (log-print "set set_function(functionnamed('"fullname"')) = ")
    (log-print "  functionnamed('"(concatl ai"."(function arginfo-typename))
	       ".SET_"fnname"->INTEGER');")
    (log-terpri)))

(defun restore-fnname (fno fnname colname)
  "When column name and function name are different"
  (let* ((argtypes (get-resolvent-argtypes fno))
	 (restypes (getrestype fno)) 
	 (fullname (oid-name fno))
	 (argtypename (oid-name (first argtypes)))
	 (restypename (oid-name (first restypes))))
    (if (> (length argtypes) 1) (error "det hära funkar ente!"))
    (if (> (length restypes) 1) (error "det hära funkar ente!"))
    (log-print "/*")
    (log-print " * restoring the function name to "fnname
	       " because we had to name the ")
    (log-print " * column "colname" when exporting.")	   
    (log-print " */")
    (log-print "create function "fnname"("(oid-name (first argtypes))" x)->"
	       (oid-name (first restypes)))
    (log-print "  as select "colname"(x);")
    (log-print "set add_function(functionnamed('"fullname"')) =")
    (log-print "  functionnamed('"argtypename"."restypename".ADD_"colname
	       "->INTEGER');")
    (log-print "set set_function(functionnamed('"fullname"')) =")
    (log-print "  functionnamed('"argtypename"."restypename".SET_"colname
	       "->INTEGER');")
    (log-print "set remove_function(functionnamed('"fullname"')) =")
    (log-print "  functionnamed('"argtypename"."restypename".REMOVE_"colname
	       "->INTEGER');")
    (log-terpri)))

(defun restore-fntype (fno)
  "When a function resturns an object but the column contains a number."
  (let* ((argtypes (get-resolvent-argtypes fno))
	 (restypes (getrestype fno))
	 (argtypename (oid-name (first argtypes)))
	 (restypename (oid-name (first restypes)))
	 (fullname (oid-name fno))
	 (fnname (generic-fnname fno))
	 )
    (if (> (length argtypes) 1) (error "det hära funkar ente!"))
    (if (> (length restypes) 1) (error "det hära funkar ente!"))
    (log-print "/*")
    (log-print " * Restoring the return type of the function "fnname" to "
	       restypename)
    (log-print " * Because the automatically created function i_"fnname
	       " returns integer.")
    (log-print " */")
    (log-print "create function "fnname"("argtypename" x)->"restypename" y ")
    (log-print "as select y where _decode_(y) = i_"fnname"(x);")
    (log-terpri)
    (log-print "create function add_"fnname"("argtypename" x, "restypename
	       " y) -> integer ")
    (log-print "as select add_i_"fnname"(x, _decode_(y));")
    (log-print "set add_function(functionnamed('"fullname"')) =")
    (log-print "  functionnamed('"argtypename"."restypename".ADD_"fnname
	       "->INTEGER');")
    (log-terpri)
    (log-print "create function set_"fnname"("argtypename" x, "restypename
	       " y) -> integer ")
    (log-print "as select set_i_"fnname"(x, _decode_(y));")
    (log-print "set set_function(functionnamed('"fullname"')) =")
    (log-print "  functionnamed('"argtypename"."restypename".SET_"fnname
	       "->INTEGER');")
    (log-terpri)
    (log-print "create function remove_"fnname"("argtypename" x, "
	       restypename" y) -> integer ")
    (log-print "as select remove_i_"fnname"(x, _decode_(y));")
    (log-print "set remove_function(functionnamed('"fullname"')) =")
    (log-print "  functionnamed('"argtypename"."restypename".REMOVE_"fnname
	       "->INTEGER');")
    (log-terpri)
    ))

(defun must-be-declared-before (fno1 fno2)
  (memq fno2 (functions-used-by fno1)))

(defun functions-used-by (fno)
  (mapfilter (f/l (obj) (and (or (osql-functionp obj)(foreign-functionp obj))
			     (not (getobject obj 'generic))))
	     (getobject fno 'usesobjects)))

(defun log-princ (&rest args)
  (princ (apply (function concat) args) *export-stream*))

(defun log-print (&rest args)
  (princ (apply (function concat) args) *export-stream*)
  (log-terpri))

(defun log-terpri ()
  (terpri *export-stream*))

