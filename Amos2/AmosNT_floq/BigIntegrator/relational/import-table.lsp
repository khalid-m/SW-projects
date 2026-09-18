;;; =============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: import-table.lsp,v $
;;; $Revision: 1.11 $ $Date: 2012/08/08 08:33:34 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Definition of the facilities provided by the relational 
;;;              datasource type. 
;;;              
;;; =============================================================
;;; $Log: import-table.lsp,v $
;;; Revision 1.11  2012/08/08 08:33:34  minzh812
;;; rename function name.
;;;
;;; Revision 1.10  2012/06/12 15:49:39  minzh812
;;; *** empty log message ***
;;;
;;; Revision 1.9  2012/05/31 09:12:54  minzh812
;;; refined data modeling.
;;;
;;; Revision 1.8  2012/04/09 15:46:26  minzh812
;;; *** empty log message ***
;;;
;;; Revision 1.7  2012/04/06 15:34:27  minzh812
;;; *** empty log message ***
;;;
;;; Revision 1.6  2012/04/04 14:51:46  minzh812
;;; *** empty log message ***
;;;
;;; Revision 1.5  2012/04/03 15:33:49  minzh812
;;; *** empty log message ***
;;;
;;; Revision 1.4  2012/04/03 07:14:34  minzh812
;;; *** empty log message ***
;;;
;;; Revision 1.3  2012/03/22 16:44:38  minzh812
;;; *** empty log message ***
;;;
;;; Revision 1.2  2012/03/22 08:16:28  minzh812
;;; replaced with new function implementations.
;;;
;;; Revision 1.1  2012/03/21 15:10:31  torer
;;; moved JDBC wrapper to BigIntegrator
;;;
;;; Revision 1.36  2012/01/10 07:31:21  torer
;;; New tuple format (...)
;;;
;;; Revision 1.35  2010/02/16 20:01:55  torer
;;; CommonLisp syntax
;;;
;;; Revision 1.34  2009/09/04 14:13:26  torer
;;; Bad declaration removed
;;;
;;; Revision 1.33  2009/08/17 15:08:26  silvias
;;; Use of mapfunction instead of getfunction in create-relational-core-cluster-fn
;;;
;;; Revision 1.32  2009/04/15 17:02:19  torer
;;; Correct declaration of mapped type over table with composite key
;;;
;;; Revision 1.31  2009/04/15 08:37:21  torer
;;; Incorrect CommonLisp syntax in backquote
;;;
;;; Revision 1.30  2008/11/23 14:48:47  torer
;;; Variable not declared
;;;
;;; Revision 1.29  2007/10/18 13:12:37  torer
;;; Now calling FUNCTION-ARGVARS and FUNCTION-RESVARS
;;;
;;; Revision 1.28  2006/12/06 22:05:05  torer
;;; Declaration error
;;;
;;; Revision 1.27  2006/12/06 21:50:55  torer
;;; Corrected type declarations. No more incorrect late bindings.
;;;
;;; =============================================================

;;; To do:

;;; What about remove functions? If subtypes use foreign keys and cascaded 
;;; deletes, then remove need only be defined for the topmost type in the 
;;; hierarchy, otherwise the cascading has to be done in Amos. Can cascading
;;; be checked for? In db2?

;;; OSQL front functions

(defun import_table-------+ (fno ds catalog-name schema-name table-name 
				 type-name updateable supertypes mtp)
  (let ((mt (import-table ds 
			  (convert catalog-name)
			  (convert schema-name)
			  (convert table-name)
			  (or (convert type-name) 
			      (make-mapped-typename ds table-name))
			  (convert updateable)
			  (mapcar #'gettypenamed (convert supertypes)))))
    (osql-result ds catalog-name schema-name table-name
		 type-name updateable supertypes mt)))

(defun import_relation------+ (fno ds catalog schema table argcolname
				   rescolname fnname updateable bagfno)
  (let ((mfno (import-table-as-function ds 
					(convert catalog)
					(convert schema)
					(convert table)
					(convert argcolname)
					(convert rescolname)
					(convert fnname)
					(convert updateable))))
    (osql-result
     ds catalog schema table argcolname rescolname fnname updateable bagfno)))

(defun import_foreign_keys-+ (fno bagfno)
  (let ((fkeyfns (import-foreign-keys bagfno nil nil nil)))
    (dolist (fkeyfn fkeyfns)
      (osql-result bagfno fkeyfn))))

;;; public lisp functions
(quote
(defun import-table (ds catalog schema table mtname updateable supertypes)
  (let* ((columns (get-columns-amos-typed ds table 'noerror))
	 (keycols (get-key-columns-amos-typed ds catalog schema table))
	 (cc-fno  (create-relational-core-cluster-fn
		   ds table columns keycols mtname))
	 (cc-name (generic-fnname cc-fno))
	 mt)
    (add-rewriter cc-fno (buildn (length columns) '+) 'rewrite-extent)
    (setq mt (create-mapped-type mtname 
				 supertypes
				 columns 
				 keycols
				 cc-name))
    (add-amos-type    ds :wrapped table :amos mt)
    (add-wrapped-type ds :wrapped table :amos mt)
    (if updateable (create-keyed-update-fns ds mt columns keycols))
    (if updateable
	(set-constructor mt (create-sql-constructor ds mt))
      (forbid-constructor mt "This mapped type is read-only"))
    mt))
)

;;changed by MP
(defun import-table (ds catalog schema table mtname updateable supertypes)
  (let* ((columns (get-columns-amos-typed ds table 'noerror))
	 (keycols (get-key-columns-amos-typed ds catalog schema table))
	 (cc-fno  (create-relational-core-cluster-fn
		   ds table columns keycols mtname))
	 (cc-name (generic-fnname cc-fno))
	 (absorber (mksymbol (caar (getfunction 'get_absorber (list (arg-type ds))))))
	 mt)
    (/putobject cc-fno 'absorber absorber)
    (/putobject cc-fno 'CCLUSTERFCT? t)
    (addfunction 'extent_collection (list cc-fno) (list (mkstring table)))
    (setq mt (create-mapped-type  mtname 
				  supertypes
				  columns 
				  keycols
				  cc-name))
    (add-amos-type    ds :wrapped table :amos mt)
    (add-wrapped-type ds :wrapped table :amos mt)
    (if updateable (create-keyed-update-fns ds mt columns keycols))
    (if updateable
	(set-constructor mt (create-sql-constructor ds mt))
      (forbid-constructor mt "This mapped type is read-only"))
    mt))

(quote
(defun import-table-as-function (ds catalog schema table argcolname rescolname
				    fnname updateable)
  (let* ((columns (get-columns-amos-typed ds table 'noerror))
	 (keycols (get-key-columns-amos-typed ds catalog schema table))
	 (argcol  (first
		   (mapfilter (f/l (column) (eq (second column) argcolname))
			      columns)))
	 (rescol  (first
		   (mapfilter (f/l (column) (eq (second column) rescolname)) 
			      columns)))
	 ccfno
	 fno)
    (if (not columns) (amos-error "Table has no columns " table))
    (setq ccfno (create-relational-core-cluster-fn ds table columns 
						   keycols fnname))
    (/putobject ccfno 'cclusterfct? t)
    (add-rewriter ccfno (buildn (length columns) '+) 'rewrite-extent)
    (setq fno
	  (create-bagged-prop-function ds ccfno argcol rescol fnname))
    (if updateable
	(create-bagged-update-fns ds fno table argcol rescol))
    fno))
)

;;changed by MP
(defun import-table-as-function (ds catalog schema table argcolname rescolname
				    fnname updateable)
  (let* ((columns (get-columns-amos-typed ds table 'noerror))
	 (keycols (get-key-columns-amos-typed ds catalog schema table))
	 (argcol  (first
		   (mapfilter (f/l (column) (eq (second column) argcolname))
			      columns)))
	 (rescol  (first
		   (mapfilter (f/l (column) (eq (second column) rescolname)) 
			      columns)))
	 (absorber (mksymbol (caar (getfunction 'get_absorber (list (arg-type ds))))))
	 ccfno fno
	 )
    (if (not columns) (amos-error "Table has no columns " table))
    (setq ccfno (create-relational-core-cluster-fn ds table columns 
						   keycols fnname))
    (/putobject ccfno 'absorber absorber)
    (/putobject ccfno 'CCLUSTERFCT? t)
    (setq fno
	  (create-bagged-prop-function ds ccfno argcol rescol fnname))
    (if updateable
	(create-bagged-update-fns ds fno table argcol rescol))
    fno))


;;; private functions
(quote
(defun create-relational-core-cluster-fn (ds table columns keys relation-name)
  (let*	((width        (length columns))
	 (name         (concat (make-core-cluster-fn-name relation-name)))
	 (fullname     (concat name (packlist (buildn width '+))))
	 (column-names (mapcar #'second columns))
	 (fbunch       (make-string width "f"))
	 (fno          (createfunction 
			name
					; the arguments; none
			nil
					; its result types
			columns
					; RESV
			'multidirectional
					; QUANT
			`(( , fbunch foreign , fullname))
					; PRED, whatever that is
			nil)))
    (declare-keys fno keys columns) 
    (getfunction 'create_capability
		 (list ds fno fbunch 
		       (mkstring 'relational-translate-core-cluster)))
    (defc (mksymbol fullname) 
      `(lambda , (cons 'fno column-names)
         (mapfunction , (resolvename 'sql (list ds ""))
			(vector , ds , (concat "select "
					       (concatl column-names","(function id))
					       " from "table))
			(f/l (row)
			     (applyarray (function osql-result) (car row))))))

    ;; This is something that should be on all mapped types of type 
    ;; relational.
    (/putobject fno 'tablename table)
    ;; Remember that the ds object holds the connection. It must be 
    ;; present on a core-cluster function. These props *should* be put on the 
    ;; generic function but the translator API cannot assume that every extent
    ;; function has a generic function.
    (/putobject fno 'datasource  ds)
    (/putobject fno 'defaultabsorbent 'relational-translate-core-cluster)
    fno))
)

;;changed by MP
(defun create-relational-core-cluster-fn (ds table columns keys relation-name)
  (let* ((width        (length columns))
	 (name         (concat (make-core-cluster-fn-name relation-name)))
	 (fullname     (concat name (packlist (buildn width '+))))
	 (column-names (mapcar #'second columns))
	 (fbunch       (make-string width "f"))
	 (fno          (createfunction 
			name
					; the arguments; none
			nil
					; its result types
			columns
					; RESV
			'multidirectional
					; QUANT
			`(( , fbunch foreign , fullname))
					; PRED, whatever that is
			nil)))
    (declare-keys fno keys columns)  
    (addfunction 'absorbability (list ds) (list fno))
    (addfunction 'queryinfo_updater (list (arg-type ds) fno) (list "relational-translate-core-cluster"))
    (defc (mksymbol fullname)
      `(lambda , (cons 'fno column-names)
	 (mapfunction , (resolvename 'sql (list ds ""))
			(vector , ds , (concat "select "
					       (concatl column-names","(function id))
					       " from "table))
			(f/l (row)
			     (applyarray (function osql-result) (car row))))))

    ;; This is something that should be on all mapped types of type 
    ;; relational.
    (/putobject fno 'tablename table)
    ;; Remember that the ds object holds the connection. It must be 
    ;; present on a core-cluster function. These props *should* be put on the 
    ;; generic function but the translator API cannot assume that every extent
    ;; function has a generic function.
    ;;(/putobject fno 'datasource  ds)
    (addfunction 'datasource (list fno) (list ds))
    ;;(/putobject fno 'defaultabsorbent 'relational-translate-core-cluster)
    fno))


(defun declare-keys (fno kdcl cdcl)
  (add-keygroup 
   fno 
   (mapcar 
    (f/l (kd)
	 (let ((kpl (list-positions kd cdcl)))
	   (cond ((or (null kpl)(cdr kpl))
		  (error "Key not among columns" kd))
		 (t (car kpl)))))
    kdcl)))      

;;; Creation of property functions for imported relations
(defun create-bagged-prop-function (ds ccfno argcol rescol fnname)
  (let ((argcolname (second argcol))
	(argcoltype (first argcol))
	(rescolname (second rescol))
	(rescoltype (first rescol))
	(ccresnames (function-resvars ccfno))
	)
    (amos-execute
     (concat
      "create function "fnname"("argcoltype" "argcolname")"
      "  -> bag of "rescoltype" "rescolname" as"
      "  select "rescolname
      "  where ("(concatl ccresnames ",")") in "(generic-fnname ccfno)"();"))))


;;; creation of update functions

;;; Keyed update functions
(defun create-keyed-update-fns (ds mt props keys)
  "Creates transparent update functions for property functions of the mapped 
   type mt in which the argument is 'key' in the Amos sense."
  (let ((mtname (getobject mt 'name)))
    (dolist (prop props)
      (let*  ((type (first prop))
	      (name (second prop))
	      (propfno (getfunctionnamed (pack mtname '. name '-> type))))
	(set-setfunction propfno (create-keyed-set-fn ds mt prop keys))
	(set-remfunction propfno (create-keyed-remove-fn ds mt prop keys))
	(set-addfunction propfno (create-keyed-add-fn ds mt prop keys))))))

(defun create-keyed-set-fn (ds mt column keys)
  "Creates a set function for a function of the type 
   'age(person p)->integer age'. The set function 
   created is defined as
      create function set_age(person@ds p, integer age) -> integer
      as select sqlu(ds, 'update person set age=? where pnr=?',
                     {age,_decode_(p)});
   where person is a relational table at the datasource ds, 
   and age is a column of that table."
  (let ((mtname    (getobject mt 'name))
	(coltype   (first column)) 
	(colname   (second column))
	(i 0))
    (createfunction 
     (pack 'set_ colname)             ;;; name
     (list (list mt 'x) column)       ;;; argument
     '((integer))                   ;;; result types
     '(res)                           ;;; RESV
     '((vector v)(integer res))         ;;; QUANT
     `(and (= v (vector (_decode_ x)));;; PRED
	   (= res 
	      (sqlu
	       , ds
	       , (concat
		  "update "(get-tablename mt)" set "colname"=? where "
		  (concatl keys" and "(f/l (key)(concat(second key) '=?))))
		 (vector ,@ (cons 
			     colname
			     (mapcar(f/l (key)(list 'vref 'v (++1 i)))keys))))
	      )
	   )
     )
    )
  )

(defun create-keyed-remove-fn (ds mt column keys)
  (let* 
      ((dsname (oid-name ds))
       (type (oid-name (arg-type ds)))
       (mtname    (getobject mt 'name))
       (coltype   (first column)) 
       (colname   (second column))
       (tablename (get-tablename mt))
       (fnname    (pack 'remove_ colname))
       ;; for compund primary keys it creates a string like
       ;; "ssn1=? and ssn2=? ..."
       (pkmatch   (concatl keys" and "(f/l(key)(concat(second key) '=?))))
       ;; for compund primary keys it creates a string like
       ;; "vector(_decode_(x))[0], vector(_decode(x))[1] ..."
       ;; it looks inefficient but the optimizer fixes it!
       (i 0)
       (decoding 
	(if (> (length keys) 1)
	    (concatl keys
		     ","
		     (f/l (key)
			  (concat "{_decode_(x)}["(++1 i)"]")))
	  "_decode_(x)")))
    (amos-execute
     (concat
      "create function "fnname (list* mtname "x," column)"->integer as "
      "select sqlu(ds, "
      "'update "tablename" set "colname"=null "
      "where "colname"=? and "pkmatch"', "
      "{"colname","decoding"}) from "type" ds where name(ds)='"dsname"';"))))
 
(defun create-keyed-add-fn (ds mt column keys)
  (let* ((dsname (oid-name ds))
         (type (oid-name (arg-type ds)))
	 (mtname    (getobject mt 'name))
	 (coltype   (first column)) 
	 (colname   (second column))
	 (tablename (get-tablename mt))
	 (fnname    (pack 'add_ colname))
	 ;; for compund primary keys it creates a string like
	 ;; "ssn1=? and ssn2=? ..."
	 (pkmatch   (concatl keys" and "(f/l(key)(concat(second key) '=?))))
	 ;; for compund primary keys it creates a string like
	 ;; "vector(_decode_(x))[0], vector(_decode(x))[1] ..."
	 ;; it looks inefficient but the optimizer fixes it!
	 (i 0)
	 (decoding 
	  (if (> (length keys) 1)
	      (concatl keys
		       ","
		       (f/l (key)
			    (concat "{_decode_(x)}["(++1 i)"]"))
		       ","
		       keys)
	    "_decode_(x)")))
    (amos-execute
     (concat
      "create function "fnname (list* mtname "x," column)"->integer res as "
      "begin "
      "declare "type" ds;"
      "set ds=relational_named('"dsname"');"
      "if some(sql(ds ,'select "colname" "
      "from "tablename" "
      "where "pkmatch" and "colname"!=?"
      "',{"decoding","colname"})) "
      "then error('error: Violating a unique index "
      "in colum "column" in table "tablename"') "
      "else set res=sqlu(ds,"
      "'update "tablename" set "colname"=? "
      "where "pkmatch"',{"colname","decoding"});"
      "end;"))))

;;; Bagged update functions

(defun create-bagged-update-fns (ds fno table argcol rescol)
  "Creates transparent update functions for property functions of the mapped 
   type mt in which the argument is 'nonkey' in the Amos sense. This implies 
   that the function is represented by a table."
  (set-addfunction fno (create-bagged-add-fn ds fno table argcol rescol))
  (set-setfunction fno (create-bagged-set-fn ds fno table argcol rescol))
  ;;(set-remfunction fno (create-bagged-remove-fn ds mt prop keys))
  )

(defun create-bagged-add-fn (ds fno table argcol rescol)
  (let* ((dsname (oid-name ds))
         (type (oid-name (arg-type ds)))
	 (fnname (generic-fnname fno))
	 (oid-idno ds)
	 (argtypename (oid-name (first (get-resolvent-argtypes fno))))
	 (restypename (oid-name (first (getrestype fno))))
	 (argcolname (second argcol))
	 (rescolname (second rescol))
	 (nr        (oid-idno ds)))
    (amos-execute
     (concat 
      "create function add_"fnname"("argtypename" x,"restypename" y)"
      "  -> integer as "
      "select sqlu(ds,"
      "'insert into "table" ("argcolname","rescolname") "
      "values (?,?)',{x, y})"
      "from "type" ds where name(ds)='"dsname"';"))))
  
(defun create-bagged-set-fn (ds fno table argcol rescol)
  (let* ((dsname (oid-name ds))
         (type (oid-name (arg-type ds)))
	 (fnname (generic-fnname fno))
	 (oid-idno ds)
	 (argtypename (oid-name (first (get-resolvent-argtypes fno))))
	 (restypename (oid-name (first (getrestype fno))))
	 (argcolname (second argcol))
	 (rescolname (second rescol))
	 (keycolname argcolname))
    (amos-execute
     (concat
      "create function set_"fnname"("argtypename" x,"restypename" y)"
      "  -> integer as "
      "begin declare "type" ds;"
      "set ds = relational_named('"dsname"');"
      "  sqlu(ds, "
      "'delete from "table" where "keycolname"=?',{x}); "
      "add_"fnname"(x,y); "
      "end;"))))

;;; utilities for writing foreign functions, don't really belong here.

(defun convert (amosval)
  "Converts and amos value to a correspoding lisp value
   - boolean: true => t false => nil
   - strings: symbols, nil if = ""
   - real and integer: itself
   - list: recurses 
   - * (unbound value): nil
  "
  (if amosval
      (cond ((oid-p amosval) amosval)
	    ((eq amosval '*) nil)
	    (t
	     (let ((tpo (arg-type amosval)))
	       (if tpo
		   (selectq (oid-name tpo)
			    (boolean (eq amosval 'true))
			    (integer amosval)
			    (real amosval)
			    (charstring (if (equal amosval "") 
					    nil
					  (mksymbol amosval)))
			    (vector (convert (arraytolist amosval)))
			    (error "no correspongding lisp type for" amosval))
		 ;; ok, so arg-type couldn't figure it out...
		 (cond ((listp amosval)
			(mapcar (function convert) amosval)))))))))
