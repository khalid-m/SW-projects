;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: translator.lsp,v $
;;; $Revision: 1.30 $ $Date: 2012/04/24 14:07:13 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: The translator API, built on top of the rewrite system.
;;;              
;;; ===========================================================================
  
(quote ; New version that does not work:
(defun rewrite-extent (rw)
  (let* ((this      (rewrite-this rw))
	 (rest      (rewrite-rest rw))
	 (bpat      (rewrite-bpat rw))
	 (extentfno (predicate-operator this))
	 (ds        (getobject extentfno 'datasource))
	 (defabs    (getobject extentfno 'defaultabsorbent))
	 initfn
	 finfn
        ;;;
	 (env       (make-environment))
	 acc untranslated result bnd)
    (if (not ds) (error "extent function has no datasource" extentfno))
    (if(not defabs)(error"extent function has no default absorbent."extentfno))
    (setq initfn (get-initializer ds))
    (setq finfn (get-finalizer ds))
    (if (not initfn)(error "no initializer for datasource's translator." ds))
    (if (not finfn) (error "no finalizer for datasource's translator." ds))

    ;; Call the datasource's initializer. Returns the accumulator.
    (setq acc (funcall initfn ds env))
    (update-environment this env bpat rest)

    ;; Remove variables that belong to <this>. Their binding is inferred w/bpat
    (setq bnd (set-difference (rewrite-bnd rw) (predicate-variables this)))

    ;; Try running the default absorbent w/o resorting to capabilities
    (if (not (translate ds this env acc defabs)) (push this untranslated))

    ;; Vars in bnd that don't belong to <this> are bound by some previous pred.
    (dolist (v bnd) (putvar v env :bind '- :entity v))

    ;; Then try to translate those that ds is capable of
    (setq untranslated (translate-and-prune rest ds env acc))
    (setq result (funcall finfn ds env acc))
    (cond (result 
	   (setf (rewrite-rest rw) untranslated)
           (setf (rewrite-translated rw) result)
	   ;; replace rest with translated conjunction
	   'success)			; successful rewrite
	  (t 'substitute))))
)

(defvar _translator-produces_ 'tr)

(defparameter *enable-num-exp-trans* nil)
(defglobal _initiates_ (make-hash-table))
(defun filter-out-untranslated-preds0 (untranslated env) untranslated)


(defun rewrite-extent (rw)
  (let* ((this      (rewrite-this rw))
	 (rest      (rewrite-rest rw))
	 (bpat      (rewrite-bpat rw))
	 (extentfno (predicate-operator this))
	 (ds        (getobject extentfno 'datasource))
	 (defabs    (getobject extentfno 'defaultabsorbent))
	 initfn
	 finfn
        ;;;
	 (env       (make-environment))
	 acc untranslated result bnd)
    (if (not ds) (error "extent function has no datasource" extentfno))
    (if(not defabs)(error"extent function has no default absorbent."extentfno))
    (setq initfn (get-initializer ds))
    (setq finfn (get-finalizer ds))
    (if (not initfn)(error "no initializer for datasource's translator." ds))
    (if (not finfn) (error "no finalizer for datasource's translator." ds))

    ; Call the datasource's initializer. Returns the accumulator.
    (setq acc (funcall initfn ds env))
    (update-environment this env bpat rest)

    ; Remove variables that belong to <this>. Their binding is inferred w/bpat
    (setq bnd (set-difference (rewrite-bnd rw) (predicate-variables this)))

    ; Try running the default absorbent w/o resorting to capabilities
    (if (not (translate ds this env acc defabs)) (push this untranslated))

    ; Vars in bnd that don't belong to <this> are bound by some previous pred.
    (dolist (v bnd) (putvar v env :bind '- :entity v))

    ; Then try to translate those that ds is capable of
    (setq untranslated (translate-and-prune rest ds env acc))
    (if *enable-num-exp-trans* (inference-origin-preds rest env))

    ;; If any untranslated pred is not used in post-processing, it
    ;; should be left out
    (if *enable-num-exp-trans*
	(setq untranslated (filter-out-untranslated-preds0 untranslated env)))

    (setq result (funcall finfn ds env acc))
    (if result
	(selectq _translator-produces_
		 (tbr (progn
			(setf (rewrite-bnd rw)
			      (union bnd (bound-variables env)))
			(setf (rewrite-rest rw)  untranslated)
			(setf (rewrite-translated rw) result )
			'success))
		 (tr  (progn
			(setq result (nconc2 result untranslated))
			(setf (rewrite-this rw) (first result))
			(setf (rewrite-bpat rw); (bpat (first result) env))
			      (bindadornpat (first result) nil)) ; fishy! (TR)
			(setf (rewrite-bnd rw)
			      (union(predicate-variables(first result))
				    bnd rw))
			(setf (rewrite-rest rw) (rest result))
			'substitute))
		 (error "Translator must produce TBR or TR"))
      (progn (setf (rewrite-bnd rw)
		   (union(predicate-variables(rewrite-this rw))
			 (rewrite-bnd rw)))
	     'substitute))))


(defun capable (ds pred env)
  "Returns true if datasource ds is capable of translating predicate 
   pred in variable environment env."
  (let* ((op (predicate-operator pred))
	 (bpat  (bpat pred env)))
    (if (get-best-cover ds op bpat) t nil)))

(defun translate-and-prune (preds ds env acc)
  "Translates and removes the predicates that are connected to the default 
   absorbent by common variables. Performs a fix-point iteration in order to 
   find all connected predicates. Returns the pruned list of predicates.
   Equijoins are the only joins pushed."
  (let ((change t)
	untranslated)
    (while change
      (setq untranslated nil)
      (setq change nil)
      (dolist (pred preds)
	(cond ((compound-p pred) (push pred untranslated))
	      (t (update-environment pred env nil preds)
		 (if (and (capable ds pred env)
			  (eligible ds pred env)
			  (translate ds pred env acc))
		     (setq change t)
		   (push pred untranslated)))))
      (setq preds untranslated))
    untranslated))

(defun eligible (ds pred env)
  "True if the predicate is either not a core-cluster function, or if the 
   core-cluster function shares variables with core-cluster function absorbed 
   by the default absorbent."
  (or (not (core-cluster-fn? (predicate-operator pred)))
      (some (f/l (v) (eq ds (datasource v env)))
	    (predicate-variables pred))))

(defun update-environment (pred env &optional bpat preds) 
  "Updates an environment env by inserting the variables in predicate pred. If
  a bpat is supplied this will affect the bindings so that a variable whose 
  corresponding bpat symbol is - will be marked as bound from the start. 

  The function attempts to infer the type of the variable by looking at the 
  type signature of the first function where the variable is discovered. If no
  such information is available the type will be Object. A possible future 
  modification might be to further specify if the variable appears as argument
  to a function which takes a more specific type (subtype) of the variable. 
  This approach has still to be investigated. *

  The updated environment is returned.
  ----------------------------
  * The way types are inferred and variables bound
  in Martin's code needs to be better integrated using *bindings*!!! (TR)"

  (let* ((op      (predicate-operator pred))
	 typesig typesiglength
	 (arglistlength (length (predicate-arguments pred))))
    ;; Lack of personal communication shown in this ugly hack (TR)!!!:
    (cond ((getobject op 'dynconstructor)
           (setq typesiglength 0)
	   (setq typesig (append typesig 
				 (buildn (- arglistlength typesiglength) 
					 _object_))))
	  (t (setq typesig (append (get-resolvent-argtypes op)
				   (get-resolvent-restypes op)))
	     (setq typesiglength (length typesig))
	     (if (< typesiglength arglistlength)
		 (setq typesig
; Awful!!! (TR):       (nconc2 typesig (buildn (- arglistlength typesiglength)
		       (append typesig (buildn (- arglistlength typesiglength)
					       _object_))))))

    (if (not bpat) (setq bpat (buildl typesig '+)))
    (dolists ((var (predicate-arguments pred)) (b bpat) (tpo typesig))
	     (if (exists var env)
; if the variable had no type before, the best we can do is
; assume that its type matches this function signature.
; What about using *bindings* (TR)? Would have removed the ugly hack!!! 
		 (if (eq nil (get-type var env)) 
		     (set-type var env tpo))
	       (putvar var env :bind b  :origin pred :type tpo)))))


(defun inference-origin-preds (preds env))



(defun translate (ds pred env acc &optional absorbent)
  "The function will query ds' capabilities in order to find an absorbent,
   unless explicitly given, in order to translate pred for ds. Returns 
   t if successful, otherwise nil."
  ;; can be optimized
  (resetgenvar (let* ((op (predicate-operator pred))
		      (wpat (get-best-cover
			     ds op (bpat pred env))))
		 (if absorbent
		     (funcall absorbent ds pred env acc)
		   (funcall (find-absorbent ds op wpat) ds pred env acc)))))

(defun get-best-cover (ds op bpat)
  "If there exists, within the capabilty database, a translator that 
   can translate the predicate operator op for the datasource ds under 
   a binding patterns that is the most specific binding pattern that 
   covers bpat, then this binding pattern is returned."
  (let ((bpats
	 (reverse (sort
		   (mapcar (function bpatlist)
			   (mapcar (function first)
				   (getfunction 'adornments (list ds op))))
		   (function covers)))))
    (while (not (or (eq bpats nil) (covers (first bpats) bpat)))
      (pop bpats))
    (first bpats)))

(defun find-absorbent (ds fno bpat)
  (mksymbol (caar (getfunction 'absorbent (list ds fno (listbpat bpat))))))