;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) <year> <author>, UDBL
;;; $RCSfile: sql_finalizer_new.lsp,v $
;;; $Revision: 1.2 $ $Date: 2013/09/10 11:51:58 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: <description>
;;; =============================================================

(defglobal _logdburi-js_ (getfunctionnamed 'object.logdburi_js->JDBC))

(defglobal _vectorof_ (getfunctionnamed 'BAG.VECTOROF->VECTOR))

(defvar *enable-parallel* nil "flag to turn on and off pallelisation")

(defvar *metadbcalloutputvarlist* nil 
  "store the output variables from metaDB call")

(defglobal _formargfrombag_ (getfunctionnamed 'bag.formargfrombag->vector))

(defglobal _vref_ (getfunctionnamed 'VECTOR.NUMBER.VREF->OBJECT))

(defglobal _multicastreceive3_ 
  (getfunctionnamed 'VECTOR.CHARSTRING.CHARSTRING.VECTOR.VECTOR-NUMBER.MULTICASTRECEIVE3->OBJECT))


(defglobal _transformvec_ (getfunctionnamed 'VECTOR.TRANSFORMVEC->OBJECT.VECTOR))

(defglobal _groupby_ (getfunctionnamed 'BAG.FUNCTION.GROUPBY->OBJECT.OBJECT))

(defglobal _bagin_ (getfunctionnamed 'BAG.IN->OBJECT))


;;{1,2,3,4,5}=>(1, {2,3,4,5})
(defun transinvec-++ (fno inputvec)
  (let* ((inputlist (arraytolist inputvec))
	 (inputlistlength (length inputlist))
	 logdburivar queryargvar
	 )
    (cond ((> inputlistlength 0)
	   (setq logdburivar (car inputlist))
	   (setq queryargvar (cdr inputlist)))
	  (t (error "input vector is null")))
    ;;(printl inputvec logdburivar (listtoarray queryargvar))(help)
    (osql-result inputvec logdburivar (listtoarray queryargvar))))

;;bag => {peervector, queryargumentvector}
(defun formargfrombag-+ (fno b)
  (let ((peervec (make-array 0 :adjustable t))
	(resvec (make-array 0 :adjustable t))
	)
    (mapbag b 
	    (f/l (x)
		 (push-vector peervec (car x))
		 (push-vector resvec (cadr x))))
    (osql-result b (vector peervec resvec))
    ))

(defun forminput (peervec argvec)
  (list (list _vector_ peervec) (list _vector_ argvec)))

(quote ;;original code
(defun formqueryargvec (invars)
  "receive invars and *metadbcalloutputvarlist* to construct query argument 
   vector e.g (vector (vref v- 4)(vref v- 5)(vref v- 3)(vref v- 2))"
  (let (vreflist)
    (mapc (f/l (invar)
	       (setq vreflist 
		     (append vreflist 
			     (list (list 'vref 'v- 
					 (getpos invar *metadbcalloutputvarlist*))))))
	  invars)
    (cons 'vector vreflist)))
)



(defun formqueryargvec (*metadbcalloutputvarlist*)
  "receive invars and *metadbcalloutputvarlist* to construct query argument 
   vector e.g (vector (vref v- 4)(vref v- 5)(vref v- 3)(vref v- 2))"
  (let* ((metadbcalloutputvarlist *metadbcalloutputvarlist*)
	 (metadbvarlength (length metadbcalloutputvarlist))
	vreflist)
    (dotimes (i metadbvarlength)
      (setq vreflist 
	    (append vreflist 
		    (list (list 'vref 'v- i)))))
    (cons 'vector vreflist)))   


(defun getinputvarpos  (l1 l2)
  "this function result an array with all positions of l2 appears in l1
   l1 is the long list and l2 is the short list, e.g the invars "
(let (poslist)
  (mapc (f/l (var)
	     (let ((pos (getpos var l1)))
	       (if pos
		   (setq poslist
			 (append poslist
				 (list pos))))))
	l2)
  (listtoarray poslist)))

;;create these transient function to make bag in (createfunction '*transient* .

(defun create-specialized-query-fn2 (ds sqlq bnd)
  (if *enable-parallel*
      (let* ((query     (generate-sql-string2 sqlq));;done first
	     (inparams  (rename-duplicate-variables (get-parameters
						     (sqlquery-input sqlq))))
	     (outparams (get-parameters (sqlquery-output sqlq)))
	     (outparams1 (list (list _object_) (list _vector_)))
	     (inputvars (sqlquery-input sqlq))
	     (outvars (sqlquery-output sqlq))
	     (logdb_URIvar (if (eq '* (car inputvars))
			       1
			     (car inputvars)))
	     ;;stop here, how do i get oriout from fn3
	     (logdb_urivarpos (getpos logdb_URIvar *metadbcalloutputvarlist*))
	     (metaDBoriout *metadbcalloutputvarlist*)
	     (arity2     (length metaDBoriout));;metaDB output vars
	     (invars    (cdr inputvars))
	     ;;(metavec (vector `,invars))
	     ;;(arity     (length outparams))
	     ;;get the sql call bag result from last param of bnd
	     (metabagres (car (last bnd)))
	     (bagres (dt_genvar _bag_))
	     (bagres2 (dt_genvar _bag_))
	     (mapbagres (dt_genvar _vector_))
	     (peerargvec (dt_genvar _vector_))
	     (queryargvec (dt_genvar _vector_))
	     ;;(dynqueryargvec (formqueryargvec invars))
	     (dynqueryargvec (formqueryargvec *metadbcalloutputvarlist*))
	     (metavrefout (dt_genvar _vector_))
	     (inputvarposvec (getinputvarpos *metadbcalloutputvarlist* invars))
	     (metadboutput (get-parameters *metadbcalloutputvarlist*))
	     (metaandlogdboutput (append metadboutput outparams))
	     (arity     (length metaandlogdboutput))
	     (metaandlogdboutvars (append *metadbcalloutputvarlist* outvars))
	     vrefs vrefs2)
	
	(setf (sqlquery-sqlstring sqlq) query)
	(dotimes (i arity)(push `(vref v- , (- arity (1+ i))) vrefs))
    ;;output the attribute values by (vref v pos vrefvar) from sql call
	(dotimes (i arity2)
	  (let* ((pos (- arity2 (1+ i)))
		 (vrefvar (nth pos metaDBoriout))
		 )
	    (push `(,_vref_ ,metavrefout ,pos ,vrefvar) vrefs2)))
	;;forming the execution plan
;;	(append 
	`(
      ;;form the (k, val) pair bag from previous sql call bag 
      ;;pattern (makebag fn fninput bag), fninput is not always in place
      (,_makebag_ 
	    ,(createfunction '*transient* (list (list _bag_ metabagres)) outparams1 
			    '(o- queryargv-)
			    '((vector v-)(object o-)(vector queryargv-)) 
			    `(and (= v- (in ,metabagres))
				  (= o- (vref v- ,logdb_urivarpos))
				  (= queryargv- ,dynqueryargvec)))
	    ,metabagres ,bagres)  
      ;;make bag result around the groupby function on (k, val) result bag
      (,_makebag_ ,_groupby_ ,bagres ,_vectorof_  ,bagres2)
      ;;produce mapbagres={peervector, queryargumentvector}
      (,_formargfrombag_ ,bagres2 ,mapbagres)
      (,_vref_ ,mapbagres 0 ,peerargvec);;produce the peervector
      (,_vref_ ,mapbagres 1 ,queryargvec);;produce the queryargumentvector
	  (, _apply_pred_ 
	       ,(createfunction '*transient* (forminput peerargvec queryargvec) metaandlogdboutput vrefs
			     `((vector v-)) `(= v- ,`(multicastreceive3 ,peerargvec "sql_myv2" ,query 
									  ,queryargvec ,inputvarposvec)))
	       ,peerargvec ,queryargvec ,@ metaandlogdboutvars)
	 ;; (,_bagin_ ,metabagres ,metavrefout)
)
;;	  vrefs2)
	  )
    (let* ((query     (generate-sql-string2 sqlq));;done first
	   (inparams  (rename-duplicate-variables (get-parameters
						   (sqlquery-input sqlq))))
	   (outparams (get-parameters (sqlquery-output sqlq)))
	   (inputvars (sqlquery-input sqlq))
	 
	   (logdb_URIvar (if (eq '* (car inputvars))
			     1
			   (car inputvars)))
	   (invars    (cdr inputvars))
	   (body      `(multi_sql_union , logdb_URIvar , query (vector ,@ invars)));;temp
	   (arity     (length outparams))
	   vrefs)
      (setf (sqlquery-sqlstring sqlq) query)
      (dotimes (i arity)(push `(vref v- , (- arity (1+ i))) vrefs))
      (createfunction '*transient* (purge-nullpar inparams) outparams vrefs
		      `((vector v-)) `(= v- , body)))))


(defun create-specialized-query-fn3 (ds sqlq bnd)
"to make a bag by transient function on top of this result"
  (let* ((query     (generate-sql-string sqlq));;done first
	 (inparams  (rename-duplicate-variables (get-parameters 
						 (sqlquery-input sqlq))))
	 ;;original outputs from metadb
	 (orioutparams (get-parameters (sqlquery-output sqlq)))
	 (oriout (sqlquery-output sqlq))
	 ;;(outparams (list (list _object_) (list _vector_)))
	 (invars    (sqlquery-input sqlq))
	 (body      `(sql , ds , query (vector ,@ invars)))
	 ;;(arity     (length orioutparams))
	 (metaout (list (list _vector_)))
	 (metabagres (dt_genvar _bag_))
	 ;;output the attribute value from metadb bag result
	 ;;(metavrefout (dt_genvar _vector_))
	 vrefs)
    (setf (sqlquery-sqlstring sqlq) query)
    ;;put peerargvec as the second last param in *bvars*
    ;;(setq *bvars* (append *bvars* (list peerargvec)))
    ;;put queryargvec as the last param in *bvars*
    ;;(setq *bvars* (append *bvars* (list queryargvec)))
    (setq *bvars* (append *bvars* (list metabagres)))
    (setq *metadbcalloutputvarlist* oriout)
    ;;output the attribute values by (vref v pos vrefvar) from sql call
    ;;(dotimes (i arity)
      ;;(let* ((pos (- arity (1+ i)))
	;;     (vrefvar (nth pos oriout))
	  ;;  )
	;;(push `(,_vref_ ,metavrefout ,pos ,vrefvar) vrefs)))
    ;;forming execution plan
;;    (append 
    `(
      ;;makebag result around sql call
      (,_makebag_
            ,(createfunction '*transient* inparams metaout
			     '(metavec-)
			     '((vector metavec-))
			     `(= metavec- ,body))
	    ,metabagres))
      ;;get each vector from the bag result of sql call
     ;; (,_bagin_ ,metabagres ,metavrefout))
    ;;append the vref function to output the attribute result of sql call
    ;;vrefs)
))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SQL finalizer;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun finalize-sql (dsinst translatablepreds sb bnd)
  "Each wrapper has a finalizer, which is a plug-in that translates
   each access filter in the plan to an algebra operator called an
   interface function, specific for each kind of source. The interface
   function sends a query to the data source (i.e. a SQL query)."
  (let* ((inputvar (selectbody-argl sb))
     (resl (selectbody-resl sb))
     (accessfiltervarlist (allsp-varlist translatablepreds))
     (varpredassnlst (predbindsintermvarp translatablepreds
                          accessfiltervarlist
                          inputvar))
     (querystruct (make-sqlquery :datasource dsinst
                     :accessfiltervarlist accessfiltervarlist
                     :varpredassnlst varpredassnlst))
     queryfn sqlquery invars outvars sql-algebra-op dsinstset fedqueryinput

    )
    ;;distribute absorbed pred into proper place in sqlquery
    (distribute-preds translatablepreds querystruct resl)
    (cond ((consp dsinst);;
       (setq queryfn (create-specialized-query-fn2 (car dsinst) querystruct bnd))
       (setq sqlquery (sqlquery-sqlstring querystruct))
       ;;fedqueryinput is with logdburi var as first arg
       (setq fedqueryinput (sqlquery-input querystruct))
       (setq invars    (cdr fedqueryinput))
       ;;(setq invars (sqlquery-input querystruct))
       (setq outvars (sqlquery-output querystruct))
       (setq dsinstset (car (last invars)))
       (declarecosts 'FUNCTION.APPLY_PRED->OBJECT '*any* '(10000 10000))
       ;;(declarecosts queryfn '*any* 'sqlq_cost)
       (cond (*enable-parallel* ;;execute in parallel
	 ;;  (/putobject
	 ;;   queryfn 'name
	 ;;   (concat "multicastreceive3:'" sqlquery "'" (or invars "()")
		;;    "->" (or outvars "()")))
	      (print "calling parallel query-fn2")
	      (setq sql-algebra-op queryfn))
	     (t ;;execute in sequence
	      (/putobject
	       queryfn 'name
	       (concat "multi_sql_union:'" sqlquery "'" (or invars "()")
		       "->" (or outvars "()")))
	      (/putobject queryfn 'sqlquery querystruct)
	      (setq sql-algebra-op
		    `((, _apply_pred_ , queryfn ,@ fedqueryinput ,@ outvars)))))

       )
      (t;;only a data source
       (cond (*enable-parallel* ;;execute in parallel
	      (setq queryfn (create-specialized-query-fn3 dsinst querystruct bnd))
	      (setq sqlquery (sqlquery-sqlstring querystruct))
	      (setq invars (sqlquery-input querystruct))
	      (setq outvars (sqlquery-output querystruct))
	      ;;(declarecosts queryfn '*any* 'sqlq_cost)
;;	      (/putobject
;;	       queryfn 'name
;;	       (concat "sql@" (oid-name dsinst) ":'" sqlquery "'" (or invars "()")
	;;	       "->" (or outvars "()")))
;;	      (/putobject queryfn 'sqlquery querystruct)
	      (print "calling parallel query-fn3")
	      (setq sql-algebra-op queryfn))
	;;	    `((, _apply_pred_ , queryfn ,@ invars ,@ outvars))))
	     (t ;;execute in sequence
       (setq queryfn (create-specialized-query-fn dsinst querystruct))
       (setq sqlquery (sqlquery-sqlstring querystruct))
       (setq invars (sqlquery-input querystruct))
       (setq outvars (sqlquery-output querystruct))
       (declarecosts queryfn '*any* 'sqlq_cost)
       (/putobject
        queryfn 'name
        (concat "sql@" (oid-name dsinst) ":'" sqlquery "'" (or invars "()")
            "->" (or outvars "()")))
       (/putobject queryfn 'sqlquery querystruct)
       (setq sql-algebra-op
         `((, _apply_pred_ , queryfn ,@ invars ,@ outvars)))))))
    ))

(defun predbindsintermvarp (absorbedpredl accessfiltervarlist inputvar)
  "traverse absorbed predicates absorbedpredl and build the association list
   with var and the arithmetic pred binds that var"
  (let ((boundvarlist (append accessfiltervarlist inputvar *bvars*))
    ;;get pred absorbed order from left to right by reverse absorbedpredl
    (reversepredl (reverse absorbedpredl));;needed
    ;;initial value
    (change t)
    varpredassnlst
    )
    (while change
      (setq change nil)
      (dolist (pred reversepredl)
    (cond ((numericalp pred)
           ;;check number of new bound intermediate var
           ;;new var = not ccvar and not inputvar
           (let (freevars)
         (mapc (f/l (arg)
                (if (not (variable-is-bound arg boundvarlist))
                    (push arg freevars)))
               (predicate-vars pred))
         (cond ((= (length freevars) 1)
            ;;in addition, two constant and one intermvar
            ;;or has no ccvar??
            (push (list (car freevars) '. pred) varpredassnlst)
            ;;(nconc1 boundvarlist (car freevars));;binds new var
	    ;;don't use nconc1 since it has side-effect to bnd
	    (setq boundvarlist (append boundvarlist (list (car freevars))))
            (setq change t)))))
          ((compound-p pred)
           (map-over-pred pred
                  (f/l (p)
                   (if (numericalp p)
                       (let (freevars)
                     (mapc (f/l (arg)
                            (if (not (variable-is-bound
                                  arg boundvarlist))
                              (push arg freevars)))
                           (predicate-vars p))
                     (cond ((= (length freevars) 1)
                        (push (list (car freevars) '.
                                p)
                              varpredassnlst)
;;                        (nconc1 boundvarlist
  ;;                          (car freevars))
	    (setq boundvarlist (append boundvarlist (list (car freevars))))
                        (setq change t))))))
                  (function id))
           ))))
    varpredassnlst))

(defun distribute-preds (translatablepreds querystruct resl)
  "distribute the translatable predicates to the holding place in sqlquery
   structure"
  (mapc (f/l (pred) (sqlquery-add-predicate querystruct pred resl))
    translatablepreds)
)








;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;temp not used code;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;this function makes multisqlunion works in sequence without peers
(quote "important backup"
(defun create-specialized-query-fn2 (ds sqlq)
  (let* ((query     (generate-sql-string2 sqlq));;done first
	 (inparams  (rename-duplicate-variables (get-parameters
						 (sqlquery-input sqlq))))
	 (outparams (get-parameters (sqlquery-output sqlq)))
	 (inputvars (sqlquery-input sqlq))
	 
	 (logdb_URIvar (if (eq '* (car inputvars))
			   1
			 (car inputvars)))
	 (invars    (cdr inputvars))
	 ;;hard coded with (car (last invars)) for ds
	 ;;(urivar    (car *bvars*));;try with (second *bvars*)
	 ;;(urivar "jdbc:microsoft:sqlserver://udblserver1.it.uu.se;DatabaseName=bm1GB")
	 ;;(urivar (second *bvars*))
	 ;;(jdbcds (caar (getfunction _logdburi-js_ `(,urivar)))) 
	 ;;(urivartype (arg-type urivar))
	 (body      `(multi_sql_union , logdb_URIvar , query (vector ,@ invars)));;temp
	 (arity     (length outparams))
	 vrefs)
    (setf (sqlquery-sqlstring sqlq) query)
    (dotimes (i arity)(push `(vref v- , (- arity (1+ i))) vrefs))
    (createfunction '*transient* (purge-nullpar inparams) outparams vrefs
		    `((vector v-)) `(= v- , body))))
)

(quote
(defun create-specialized-query-fn2 (ds sqlq)
  (let* ((query     (generate-sql-string sqlq));;done first
	 (inparams  (rename-duplicate-variables (get-parameters
						 (sqlquery-input sqlq))))
	 (outparams (get-parameters (sqlquery-output sqlq)))
	 (invars    (sqlquery-input sqlq))
	 ;;hard coded with (car (last invars)) for ds
	 (urivar    (first *bvars*))
	 ;(urivar "jdbc:microsoft:sqlserver://udblserver1.it.uu.se;DatabaseName=bm1GB")
	 (urivartype (arg-type urivar))
	 (urivarpair (list urivartype urivar))
	 (body      `(multi_sql_union , urivar , query (vector ,@ invars)));;temp
	 (arity     (length outparams))
	 vrefs)
    (setf (sqlquery-sqlstring sqlq) query)
    (dotimes (i arity)(push `(vref v- , (- arity (1+ i))) vrefs))
    (createfunction '*transient* (cons urivarpair inparams) outparams vrefs
		    '((vector v-)) `(= v- , body))))
)



(quote ;;backup
(defun makebagtransient (inputvars)
  (let ((inputvarsvec (listtoarray inputvars))
	(inputvarslen (length inputvars)) 
	)
  (CREATEFUNCTION '*TRANSIENT*
   '((Vector inputvarsvec));;(argtypes)--function input arguments
   '((OBJECT)(VECTOR)) ;;(restypes)--function output arguments
   '(o v)              ;;(resv)--result varable list
   '((vector metavec)(object o)(vector v));;quant--(like the from clause)
   '(and (= (vref inputvarsvec 0) o) ;;the part is about the where clause
	 ;;here need change
    (= v (VECTOR
      (VREF inputvarsvec 1)
      (VREF inputvarsvec 2)
      (VREF inputvarsvec 3)
;;      (VREF inputvarsvec (inputvarslen - 1))))
      (VREF inputvarsvec 4)))
    (= METAVEC inputvarsvec))) )
)
)

(quote
(defun makegroupby (b aggfn)
  (createfunction '*transient*
		  ;;(argtypes)--function input arguments
		  `((Bag ,b)(Function ,aggfn))
		  '((Object)) ;;(restypes)--function output arguments
		  `((groupby ,b ,aggfn))))
)


(quote
;;doesn't work
(defglobal _makebagtransient_ 
;;  (CREATEFUNCTION '*TRANSIENT*
  (createfunction 'myown1
   '((bag of ((Vector inputvarsvec))));;(argtypes)--function input arguments
   '((OBJECT)(VECTOR)) ;;(restypes)--function output arguments
   '(o v)              ;;(resv)--result varable list
   '((vector metavec)(object o)(vector v));;quant--(like the from clause)
   '(and (= (vref inputvarsvec 0) o) ;;the part is about the where clause
	 ;;here need change
    (= v (VECTOR
      (VREF inputvarsvec 1)
      (VREF inputvarsvec 2)
      (VREF inputvarsvec 3)
;;      (VREF inputvarsvec (inputvarslen - 1))))
      (VREF inputvarsvec 4)))
    (in METAVEC inputvarsvec))) )
)


(quote ;;old code
(defun create-specialized-query-fn2 (ds sqlq)
  (if *enable-parallel*
      (let* ((query     (generate-sql-string2 sqlq));;done first
	     (inparams  (rename-duplicate-variables (get-parameters
						     (sqlquery-input sqlq))))
	     (outparams (get-parameters (sqlquery-output sqlq)))
	     (inputvars (sqlquery-input sqlq))
		 
	     (logdb_URIvar (if (eq '* (car inputvars))
			       1
			     (car inputvars)))
	     (invars    (cdr inputvars))
	     (metavec (vector `,invars))
	     (inputvec (listtoarray inputvars))
	     ;;(makebagtrans `(,_makebagtransient_ (listtoarray ,inputvars)))
	     ;;(makebagtrans `(,_makebagtransient_ ,inputvec))
	     ;; (makebagtrans (list _makebagtransient_ inputvec))
	     bagtransient bagres groupres formarg peerarg peervec argparam argvec body
	     (arity     (length outparams))
	     vrefs)

	     (setq bagtransient (list _makebagtransient_ inputvec))
	     ;;not sure how to use makebag
	     ;;(bagres `(,_makebag_ (makebagtransient inputvars)))
	     ;;(bagres `(,_makebag_ (function ,makebagtrans)))
	     ;;stop here, problem here
	     ;;(makebagfun (car makebagtrans))
	     (setq bagres (list _makebag_ bagtrans))
	     ;;soemthing is wrong with this call
	     ;;(groupres (callfunction 'groupby (list bagres _vectorof_)))
	     (setq groupres (list _makegroupby_ bagres _vectorof_))
	     (setq formarg (list _mymapbag_ groupres))
	     (setq peerarg (list _vref_ formarg 0))
	     (setq peervec (list _vector_ peerarg))
	     (setq argparam (list _vref_ formarg 1))
	     (setq argvec (list _vector_ argparam))
	     (setq body      `(multicastreceive3 ,peervec "sql_myv2" ,query ,argvec))
	;;add a new vector packing the value from call1
	(setf (sqlquery-sqlstring sqlq) query)
	(dotimes (i arity)(push `(vref v- , (- arity (1+ i))) vrefs))
	(createfunction '*transient* (purge-nullpar inparams) outparams vrefs
			`((vector v-)) `(= v- , body)))
;;  (defun create-specialized-query-fn2 (ds sqlq)
    (let* ((query     (generate-sql-string2 sqlq));;done first
	   (inparams  (rename-duplicate-variables (get-parameters
						   (sqlquery-input sqlq))))
	   (outparams (get-parameters (sqlquery-output sqlq)))
	   (inputvars (sqlquery-input sqlq))
	 
	   (logdb_URIvar (if (eq '* (car inputvars))
			     1
			   (car inputvars)))
	   (invars    (cdr inputvars))
	   (body      `(multi_sql_union , logdb_URIvar , query (vector ,@ invars)));;temp
	   (arity     (length outparams))
	   vrefs)
      (setf (sqlquery-sqlstring sqlq) query)
      (dotimes (i arity)(push `(vref v- , (- arity (1+ i))) vrefs))
      (createfunction '*transient* (purge-nullpar inparams) outparams vrefs
		      `((vector v-)) `(= v- , body)))))
)

(quote ;;latest used code
(defglobal _makebagtransient_ 
  (CREATEFUNCTION '*TRANSIENT*
;;  (createfunction 'myown1
   '((Vector inputvarsvec));;(argtypes)--function input arguments
   '((OBJECT)(VECTOR)) ;;(restypes)--function output arguments
   '(o v)              ;;(resv)--result varable list
   '((vector metavec)(object o)(vector v));;quant--(like the from clause)
   '(and (= (vref inputvarsvec 0) o) ;;the part is about the where clause
	 ;;here need change
    (= v (VECTOR
      (VREF inputvarsvec 1)
      (VREF inputvarsvec 2)
      (VREF inputvarsvec 3)
;;      (VREF inputvarsvec (inputvarslen - 1))))
      (VREF inputvarsvec 4)))
    (= METAVEC inputvarsvec))))
)

(quote ;;latest used code
(defglobal _makegroupby_
  (createfunction '*transient*
  ;;(createfunction 'myown2
		  ;;(argtypes)--function input arguments
		  '((Bag b)(Function aggfn))
		  '((Object)) ;;(restypes)--function output arguments
		  '((groupby b aggfn))))
)

