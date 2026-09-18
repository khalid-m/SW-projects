;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) <year> 2013 <author>Minpeng Zhu, UDBL
;;; $RCSfile: misc.lsp,v $
;;; $Revision: 1.4 $ $Date: 2013/09/05 15:27:01 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: misc functions
;;; =============================================================


(defun expression-p (x)(eq (typename x) 'expression))

;;silvia regress has a var that not in *bindings*, that is why i add the new
;;binding for that var in *bindings*
(defun addbinding2 (var val type)
  "Add variable binding to current binding environment"
  (let ((varbind (make-binding :var var :val val :type type))
	)
  (setq *bindings*
	(cons varbind *bindings*))
  varbind))

(defun getvarbinding (var)
  "get the binding frame for var"
  (let ((varbinding (car 
		     (isome *bindings* 
			     (f/l (binding) (eq var (binding-var binding))))))
	)
    (if (null varbinding)
	;(error "var binding is not found")
	(addbinding2 var nil nil)
      varbinding)))

(defun getvarbindingcontext (var)
  "get the binding context for var"
  (let* ((varbinding (getvarbinding var))
	 (varbindingcontext (binding-context varbinding))
	 )
    (if (null varbindingcontext)
	(setq varbindingcontext (setf (binding-context varbinding)
				      (make-varinfo))))
    varbindingcontext))

(defun get-varentity (var)
  "varentity is column information"
  (if (constantsymbolp var) var
    (let ((varbindingcontext (getvarbindingcontext var))
	   ;;varbindingcontext = vi
	  )
      (varinfo-entity varbindingcontext)
  )))

(defun set-varentity (var entity)
  (if (not (osql-variablep var))
      (error "Not a variable" var)
    (let ((varbindingcontext (getvarbindingcontext var))
	  )
      (setf (varinfo-entity varbindingcontext) entity)
)))

(defun get-vards (var)
  (if (constantsymbolp var) var
    (let ((varbindingcontext (getvarbindingcontext var))
	  )
	  (varinfo-datasource varbindingcontext)
  )))

(defun set-vards (var ds)
  (if (not (osql-variablep var))
      (error "Not a variable" var)
    (let ((varbindingcontext (getvarbindingcontext var))
	  )
      (setf (varinfo-datasource varbindingcontext) ds)
)))

(defun get-varboundby (var)
  "varentity is column information"
  (if (constantsymbolp var) var
    (let ((varbindingcontext (getvarbindingcontext var))
	   ;;varbindingcontext = vi
	  )
      (varinfo-boundby varbindingcontext)
  )))

(defun set-varboundby (var obj)
  "a var can be bound by a pred or is input var"
  (if (not (osql-variablep var))
      (error "Not a variable" var)
    (let ((varbindingcontext (getvarbindingcontext var))
	  )
      (setf (varinfo-boundby varbindingcontext) obj)
)))

(defun varboundp (var)
  (if (constantsymbolp var) t
    (let ((varbindingcontext (getvarbindingcontext var))
	  )
      (eq (varinfo-bind varbindingcontext) '-))))


(defun dsinst-capable (dsinst)
  "return a list of absorbable predicate for data source instance. The result
   contains the predicates that the relational wrapper is capable to handle 
   and the source predicate that the data source instance can handle."
  (mapcar (f/l (l) (getobject (car l) 'name))
			  (get-absorbability dsinst)))



(defun supported-by-dsinst (pred capabilitylist)
  "Return true if pred is supported by data source, e.g relational.
   supported by data source contains predicates supported by data source 
   and specific source predicates supported by specific data source instance"
  (and (leaf-predicate-p pred)
       (allowed-pred pred capabilitylist)))


(defun allowed-pred (pred capabilitylist)
  "Return true if pred is allowed according to the user define table"
  (let* ((op (predicate-operator pred))
	 (opname (oid-name op))
	 )
    (member opname capabilitylist)
    ))

(defun joins-with (pred predl)
  "Returns true if there are common variables between pred and some predicates
   in PREDL."
  (and (leaf-predicate-p pred)
     (let ((pv (predicate-vars pred)))
       (some (f/l (p) (intersection-p pv (predicate-arguments p)))
             predl))))

(defun intersection-p (x y) 
  (some (f/l (z)
	     (member z y))
	x))

(defun predicate-vars (pred)
  "The variables of a primitive predicate"
  (unique (subset (predicate-arguments pred) (function osql-variablep))))

(defun allsp-varlist (absorbedpreds)
  "get all source predicate vars"
  (let (allspvarlist)
    (mapc (f/l (pred) 
	       (if (sourcepred? pred)
		   (setq allspvarlist (append allspvarlist 
					      (predicate-vars pred)))))
	  absorbedpreds)
    allspvarlist))

(defun eqjoinvarlist (absorbedpreds)
  "return the join(duplicate) var from accessfiltervarlist,
   list of equal join variables, used to take out (= v5 v6) in regress1.osql"
  (let ((allspvarlist (allsp-varlist absorbedpreds))
	been)
    (subset allspvarlist (f/l (var) (cond ((member var been)
						  t)
						 (t;;no duplicate var
						  (push var been) nil))))))

(defun prefix-string (fno args)
  "Make an prefix string for OPERATOR applied on ARGS"
  (let* ((arity (getarity fno));;num of input for fno
	(sqlopinfor (getfunction-firsttuple _sqlop_ (list fno)))
	(operator (car sqlopinfor))
	)
    (cond ((> arity 1)
	   (concat operator "(" (infix-string "," args) ")"))
	  ((= arity 1)
	   (if (stringp (car args))
	       ;;e.g argument can be ("(salary + 1000)")
	       (concat operator (car args))
	     (concat operator args));;e.g argument can be (salary)
	   )
	  (t;;other cases
	   (error "arity is less than one" fno)))
))

(defun translatable-numpred-p (numpred boundvarlist)
  "If every var in numpred is in boundvarlist, then return true"
  (and (numericalp numpred)
       (every (f/l (var) (memq var boundvarlist))
	      (predicate-vars numpred))))


(defun update-varboundby (boundvars tbr inputvar)
  ""
  (mapc (f/l (var)
	     (if (and (osql-variablep var)
		      (null (get-varboundby var)))
		 ;;update var boundby if var is not bound by anything
		 (if (memq var inputvar)
		     (set-varboundby var var)
		   (set-varboundby var tbr))))
	boundvars)
)

(defun or-p (pred)
  "Is PRED an OR compound predicate?"
  (and (consp pred)(eq (car pred) 'or)))