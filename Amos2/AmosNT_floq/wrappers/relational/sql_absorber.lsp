(defvar *temppredlist* nil)

(defvar *varpredassnlst* nil "the association list 
   with var and the arithmetic pred binds that var")

(defvar *boundvarlist* nil "it is bound variable list with value of 
                           accessfilter")

(defvar *numwrapper* t "flag to turn on off the num wrapper")

(defstruct absorberresult
  absorbedpreds ;;absorbed predicates 
  newrest ;;predicates left after sql absorbation
  accessfiltervarlist ;;list of all absorbed source predicates variables
)


(defun absorb-sql (sp predl) 
  "Do fixed point iteration to absorb the predicates that the relational 
   datasource instance is capable to handle.
   Source predicate (SP) is earlier called core cluster function." 
  (let* ((rest predl);;used in local fixed point iteration
	 (newrest predl);;be updated and passed to absorber manager
         (change t)
	 (dsinst (datasource-of sp));;ds instance
	 (accessfiltervarlist (predicate-vars sp))
	 (*boundvarlist* accessfiltervarlist)
	 ;;(capabilitylist (dsinst-capable dsinst));wrapper and dsinst capable
	 (absorbedpreds (list sp))
	 capabilitylist
	 varpredassnlst
	 )
    ;;wrapper and dsinst capable
    (if (consp dsinst)
	(setq capabilitylist (dsinst-capable (car dsinst)))
      (setq capabilitylist (dsinst-capable dsinst)))
   ;; (if (null *numwrapper*) (setq capabilitylist nil))
    (while change 
      (setq change nil)
      (dolist (p rest)
	(cond ((and (compound-p p) 
		    (all-absorbablep p capabilitylist dsinst absorbedpreds
				     accessfiltervarlist))
	       (setq rest (remove p rest));;absorb p just once
	       (push p absorbedpreds);;push p into absorbedpreds
	       (setq change t))
	      ((osql-variablep p))
	      ((osql-constantp p))
	      ((leafpred-absorbablep dsinst p capabilitylist absorbedpreds)
	       (setq rest (remove p rest));;absorb p just once
	       (push p absorbedpreds);;push p into absorbedpreds
	       (cond ((sourcepred? p)
		      (setq accessfiltervarlist (append accessfiltervarlist 
							(predicate-vars p)))
		      (setq *boundvarlist* (append *boundvarlist* 
						   (predicate-vars p)))
		      (setq newrest (remove p newrest))));;newrest removes SP
	       (setq change t)))))

    
    (if (null *numwrapper*)
	(progn 
	  ;;build association list with num pred binds var
	  (setq varpredassnlst (numpredbindsvar newrest))
	  ;;stop here
	  (mapc (f/l (pred)
		     (if (and (not (sourcepred? pred))
			      (some (f/l (var) 
					 (assq var varpredassnlst)
					 ;;if needed, one can add one more 
					 ;;condition the common var is not SP 
					 ;;var
					 )
				    (predicate-vars pred)))
			 (setq absorbedpreds (remove pred absorbedpreds))))
		absorbedpreds)))

    (make-absorberresult :absorbedpreds (nreverse absorbedpreds)
			 :newrest newrest
			 :accessfiltervarlist (unique accessfiltervarlist))
    ))

(defun numpredbindsvar (newrest)
  "return a association list with ((v1 . (+ v1 th v3)) ...) format"
  (let ((boundvarlist *allSPsvarlist*)
	(change t)
	varpredassnlst)
    (while change
      (setq change nil)
      (dolist (pred newrest) 
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
			;;binds new var
			(setq boundvarlist (append boundvarlist freevars))
			(setq change t))))))))
    varpredassnlst))

(defun leafpred-absorbablep (dsinst pred capabilitylist absorbedpreds)
  "leaf pred can be a source predicate or non source predicate. Non source
   predicate is absorbable if dsinst is capable to handle and share a common
   variable with absorbedpreds. Source predicate is absorbable if its refered
   data source instance is the same as dsinst and share a common variable with
   absorbedpreds."
  ;;the above is temp code
  (and (or (supported-by-dsinst pred capabilitylist)
	   (eq dsinst (datasource-of pred)))
       (joins-with pred absorbedpreds)))

(defun allpredsabsorbablep (preds)
  (map-over-pred preds 
		 (f/l (pred)
		      ;;pred is like (predicate + t or nil)
		      (second pred);;return t or nil
		      )
		 (f/l (preds)
		      ;;preds is compound structure e.g (OR T T). 
		      ;;returns nil if simpfunc return NIL for a simple pred 
		      ;;and return T if simpfunc return t for all simple preds
		      (cond ((listp preds)
			     (apply 'and (cdr preds)))
			    (t
			     nil)))))

(defun all-absorbablep (preds capabilitylist dsinst absorbedpreds
			      accessfiltervarlist)
  "preds is compound predicates, e.g (OR (and p1 p2) (and p3 p4)). 
   Return true if every simple pred inside is absorbable."
  (let ((*temppredlist* nil);;hold absorbed pred when step into preds to absorb
	(change t)	
	(absorbedpredl absorbedpreds)
	temppreds init
	)
    (setq init (map-over-pred preds 
			      (f/l (pred) (list pred nil)) 
			      (function id)))
    ;;need a loop to compare each preds1 with result after apply map-over-pred
    ;;if they are not equal, that means some pred inside or is absorbed
    ;;otherwise, no more pred is absorbable
    ;;init vs preds1, preds1 vs preds2, preds2 vs preds3, etc
    (while change
      (setq temppreds 
	    (map-over-pred preds 
			   (f/l (pred)
				(cond ((leafpred-absorbablep dsinst pred 
							     capabilitylist 
							     absorbedpredl)
				       (push pred *temppredlist*)
				       (list pred t))
				      (t
				       (list pred nil))))
			   (function id)))

      (cond ((not (equal init temppreds))
	     (setq init temppreds) ;;some preds inside preds is absorbed
	     ;;add the new absorbed pred into absorbedpredl
	     (setq absorbedpredl (append absorbedpredl *temppredlist*))
	     )
	    (t ;;no more pred is absorbed
	     (setq change nil))))
    ;;check if all predicates in OR is absorbable
    (allpredsabsorbablep temppreds)))
	   












