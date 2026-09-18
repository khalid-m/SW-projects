;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: import.lsp,v $
;;; $Revision: 1.7 $ $Date: 2004/12/08 18:38:08 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Import of a type defined at another Amos node as mapped type.
;;;              
;;; ===========================================================================

    
; belongs elsewhere
(defun type-allsubtypes (tp)
  "Returns level-order traversal of the type hierarchy rooted in tp, discarding
   duplicates."
  (let* ((tpo (gettypenamed tp))
	 (immediate-subtypes (subtypes tpo)))
    (if (neq nil immediate-subtypes)
	(unique (append immediate-subtypes 
			(mapcan #'type-allsubtypes immediate-subtypes))))))

(defun mappedtypep (tpo) (eq (arg-type tpo) _mappedtype_))

; belongs in amosfns
(defun get-remote-supertypenames-response (tp)
  "Returns the names of all immediate supertypes of tp as a response to a 
   request from another amos."
  (let ((tpo (gettypenamed tp)))
    (mapcar #'oid-name (type-supertypes tpo))))

; belongs in amosfns
(defun get-remote-supertypenames-request (peer tp)
  "Retrieves the type names of the immediate supertypes of type tp at amos 
   named peer."
  (remote-eval `(get-remote-supertypenames-response , (kwote tp)) peer))

; AmosQL front functions

(defun import--+ (fno amosds remote_type_name mt)
  (osql-result amosds remote_type_name (import amosds (convert remote_type_name))))

(defun import---+ (fno amosds remote_type_name mapped_type_name mt)
  (let* ((remote-type-name (convert remote_type_name))
	 (mapped-type-name (convert mapped_type_name))
	 (mtpo (import amosds remote-type-name mapped-type-name)))
    (osql-result amosds remote_type_name mapped_type_name mtpo)))

; public functions

(defun import (amosds typename &optional desired-mtname)
  "Imports a type on another amos and creates a mapped type and a core-cluster
   function for the type and all stored functions on the type. After this 
   queries to the type are transparently divided into subqueries that get 
   compiled and executed on the other amos node."
  (let* ((mtname (or desired-mtname (make-mapped-typename amosds typename)))
	 (supertpos (get-local-supertypes amosds typename))
	 (mapped-supertpos (mapfilter #'mappedtypep supertpos))
	 ; the function returning the key propery has this naming convention
	 ; to include the typename in order to avoid DTR.
	 (propl `((opaque_proxy , (pack 'o '_ typename)   key)))
	 (ccfno
	  (create-amos-type-core-cluster-fn amosds typename propl mtname))
	 (ccname (getobject ccfno 'name))
	 (mt (create-mapped-type mtname 
				 supertpos
				 propl ; propl
				 propl ; keys
				 ccname)))
    (add-rewriter ccfno (buildn (length propl) '+) 'rewrite-extent)
    (add-amos-type amosds :amos mt :wrapped typename)
    ; create a core-cluster function for each stored relation
    (create-amos-property-core-cluster-fns amosds typename mtname ccfno)
    ; create the property functions in terms of the core-cluster functions
    (create-remote-property-fns amosds typename)
    ; When creating a subtype of a mapped type, all supertypes must have a
    ; decode function that handles polymorphism
    (mapcar #'create-amos-decode-function mapped-supertpos)
    mt))

(defun get-local-supertypes (amosds remote-tp)
  "Checks that all the supertypes of remote-tp at amos named peer have local
   counterparts. Note that stored types (system types) are always present on 
   any Amos."
  (let* ((peer (oid-name amosds))
	 (remote-super-tps (get-remote-supertypenames-request peer remote-tp)))
    (mapcar (f/l (rtp) (wrapped-to-amos-type amosds rtp)) remote-super-tps)))

; private functions

(defun create-amos-type-core-cluster-fn (amosds typename resultprops mtname)
  "Creates a type core-cluster for the type named typename at amos node amosds.
   A type core-cluster function has no arguments and has one result: a bag of 
   proxified objects which correspond to instances of the type at node amosds."
  (let* ((name   (make-core-cluster-fn-name mtname))
	 (mtname (make-mapped-typename amosds typename))
	 (dsname (oid-name amosds))
	 (ccfno   
	  (declare-amosql 
	   "create function "name"() -> opaque_proxy as "
	   "begin "
	   "result ship('"dsname"','select x from "typename" x "
	   "where typeof(x)=typenamed(\""typename"\");')[0] "
	   "end;")))
    (/putobject ccfno 'typename typename)
    (/putobject ccfno 'cclusterfct? t)
    (/putobject ccfno 'datasource  amosds)
    (/putobject ccfno 'defaultabsorbent 'amos-translate-type-core-cluster)
    ccfno))

(defun create-amos-property-core-cluster-fns (amosds typename mtname typeccfno)
  "Creates propery core-cluster functions for all stored functions on the type
   named typename at amos node amosds. The core-cluster functions return the 
   same tuple as the stored relation, and all types which are belong to amosds
   are proxified and declared as opaque_proxy."
  (let* ((dsname (oid-name amosds))
	 (rfnis  (get-remotefninfos-for-type amosds typename 'any-argument)))
    (dolist (rfni rfnis)
      (let* ((name     (remotefninfo-name rfni))
	     (genname  (remotefninfo-genname rfni))
	     (inarity  (remotefninfo-inarity rfni))
	     (outarity (remotefninfo-outarity rfni))
	     (ais      (get-arginfo name (oid-name amosds)))
	     (ccname   (make-core-cluster-fn-name mtname genname))
	     (rettypes (mapcar (function arginfo-type) ais))
	     (params    (make-paramater-declarations ais))
	     (expr-commalist (arginfo-make-expr-commalist ais))
	     (paramnames (mapcar (function arginfo-name) ais))
	     (selection   (make-amosql-function-applications 'x genname))
	     (vectorpreds (make-amosql-vector-predicates 'v paramnames))
	     (vectoracc(make-amosql-vector-accesses 'v 0 (length paramnames)))
	     ccfno)
	(setq ccfno
	      (declare-amosql
	       "create function "ccname"()-><"params">"
	       "as for each "expr-commalist",vector v "
	       "where v=ship('"dsname"','select x,"selection
	       " from "typename" x;') and "
	       vectorpreds" "
	       "result <"vectoracc">;"))
	; add the capabilities to our translator
	(/putobject ccfno 'remotefninfo rfni)
	(/putobject ccfno 'cclusterfct? t)
	(/putobject ccfno 'datasource amosds)
	(/putobject ccfno 'defaultabsorbent 'amos-translate-function-core-cluster)
	(/putobject ccfno 'typecc typeccfno)
	(if (and (= inarity 1) (= outarity 1))
	    ; we translate only these functions currently
	  (amos-execute
	   (concat
	    "create_capability("amosds","ccfno",'ff',"
	    "'amos-translate-function-core-cluster-bb');"
	    "create_capability("amosds","ccfno",'fb','"
	    "amos-translate-function-core-cluster-fb');"
	    "create_capability("amosds","ccfno",'bf','"
	    "amos-translate-function-core-cluster-bf');"
	    "create_capability("amosds","ccfno",'bb','"
	    "amos-translate-function-core-cluster-bb');")))
	(set-costhint ccfno (make-string (length ais) "f")
		      "amos_core_cluster_cost")
	(add-rewriter ccfno (buildn (length ais) '+) 'rewrite-extent)))))

(defun create-remote-property-fns (amosds typename)
  "Creates functions for each propery function of the type named typename at
   amos node amosds. Warnings are assigned when the importer sees foreign or
   derived functions defined on the type at amosds."
  (let ((rfnis (get-remotefninfos-for-type amosds typename 'any-argument)))
    (dolist (rfni rfnis)
      (case (remotefninfo-kind rfni)
	    (stored
	     (if (and (= 1 (remotefninfo-inarity  rfni))
		      (= 1 (remotefninfo-outarity rfni)))
		 (create-remote-stored-property-fn amosds typename rfni)
	       (progn 
		 (princ "Warning, function with multiple input/output not imported:")
		 (print (remotefninfo-name rfni)))))
	    (foreign (progn
		       (princ "Warning, foreign function not imported:")
		       (print (remotefninfo-name rfni))))
	    (derived (progn
		       (princ "Warning, derived function not imported:")
		       (print (remotefninfo-name rfni))))))))

(defun create-remote-stored-property-fn (amosds typename rfni)
  ; to do: property functions should be declared in terms of an
  ; extent function rather than the core-cluster function directly.
  (let* ((fullname (remotefninfo-name rfni))
	 (genname  (remotefninfo-genname rfni))
	 (ainfos   (get-arginfo fullname (oid-name amosds)))
	 (mt       (wrapped-to-amos-type amosds typename))
	 (mtname   (oid-name mt))
	 (mtccfn   (getobject mt 'cclusterfn))
	 (mtccfnname (generic-fnname mtccfn))
	 (rettype  (oid-name (arginfo-type (second ainfos))))
	 (ccname   (make-core-cluster-fn-name mtname genname)))
    (if (eq genname 'teaches) (debugging t))
    (declare-amosql
     "create function "genname"("mtname" m)->"rettype" r "
     "as select r where " ;mtccfnname"()=_decode_(m) and "
     ccname"()=<_decode_(m),r>;")))
	
(defun create-amos-decode-function (mtpo)
  (let* ((typename (oid-name mtpo))
	 (decodefn 
	  (createfunction '_decode_
			  `((, typename , typename key))
			  `((, _proxy_ , (genvar) key))
			  'multidirectional
			  '(("bf" foreign "mapped-to-external")
			    ("fb" foreign "amos-external-to-mapped")
			    ("bb" foreign "amos-decoded-ok")))))
    (set-type-container decodefn) ; Decode is always type container!!!
    (/putobject mtpo 'decodefn decodefn)
    (set-early-bound decodefn)
    (set-early-bound (generic-function-of decodefn))))

(defun amos-external-to-mapped (fno o proxy)
  (let* ((xoidno    (getobject proxy 'xoidno))
	 (peer      (getobject proxy 'exportto))
	 (amosds    (getobjectnamed peer _amos_))
	 (remotetp  (remote-eval `(oid-name (arg-type , proxy)) peer))
	 (localtpo  (wrapped-to-amos-type amosds remotetp 'noerror))
	 (mappedobj (encode-mapped-object proxy localtpo)))
    (osql-result mappedobj proxy)))

(defun amos-decoded-ok (fno o &rest decodedtuple)
  "Check that O is encoding of decodedtuple with most specific type
   given by type of FNO"
  (let ((mapped-type (first (getobject fno 'argtypes))) ; the type of O
	res)
;    (princ "o:")(print o)
;    (princ "decodedtuple")(print decodedtuple)
;    (princ "(arg-type o)")(print (arg-type o))
;    (princ "Allsubtypes")(print (type-allsubtypes mapped-type))
    (if (and o
	     (or (eq (arg-type o) mapped-type)
		 (memq (arg-type o) (type-allsubtypes mapped-type)))
	 (equal (mklist (decode-mapped-object o)) decodedtuple))
	(apply 'osql-result (cons o decodedtuple)))))
    
    
