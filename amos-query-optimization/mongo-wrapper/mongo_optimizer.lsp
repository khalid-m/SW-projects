;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2014 Tore Risch, UDBL
;;; $RCSfile: mongo_optimizer.lsp,v $
;;; $Revision: 1.1 $ $Date: 2014/02/07 11:28:57 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Oprimizer extensions for MongoDB data sources
;;; =============================================================
;;; $Log: mongo_optimizer.lsp,v $
;;; Revision 1.1  2014/02/07 11:28:57  torer
;;; MongoWrapper 1st version
;;;
;;; =============================================================

(defglobal _record-vref_ (theresolvent 'record.charstring.vref->object))
(defglobal _substv_ (theresolvent 'substv))

(defglobal _mongo-comparisons_
  (mapcar (f/l (pred op)
	       (cons (theresolvent pred) op))
	  '(< > <= >= != =) '("$lt" "$gt" "$lte" "$gte" "$ne" "$eq")))

;;;
;;; The extractor
;;;

(defun mongo-extractor (sp predl bnd)
  (let* ((rvar (third sp))
	 (attr-accesses (accessed-record-attributes rvar predl))
	 (attr-vars (accessed-record-values attr-accesses))
	 (known-vars (adjoin rvar (union attr-vars bnd)))
	 (comparisons (extractable-mongo-comparisons predl known-vars)) 
	 (extracted (append (list sp) attr-accesses comparisons))
	 (newrest (remove-predl extracted predl)))
    (make-extracted :preds extracted
		    :remaining newrest
		    :variables (variables-in-predl extracted))))
 
(defun accessed-record-values (predl)
  "The record value variables accessed in PREDL" 
  (mapcan (f/l (pred) 
	       (and (is-record-access pred)
		    (osql-variablep (fourth pred))
		    (list (fourth pred))))
	  predl))

(defun extractable-mongo-comparisons (predl bnd)
  "The predicates in PREDL being extractable MongoDB comparisons
   given that variables in BND are bound"
  (mapcan (f/l (pred)
	       (let ((p (getcalledpred pred)))
		 (and (leaf-predicate-p p)
		      (assq (first p) _mongo-comparisons_)
		      (and (variable-is-bound (second p) bnd)
			   (variable-is-bound (third p) bnd))
		      (list p))))
          predl))

(defun is-record-access (pred)
  "Is PRED a record access with known property?"
  (and (leaf-predicate-p pred)
       (eq (car pred) _record-vref_)
       (stringp (third pred))))

;;;
;;; The cost model
;;;

(defun mongo-costmodel (expression bnd)
  (let ((filter (expression-filter expression)))
    (cond ((null (cdr filter));; no Mongo filter
	   (list 100000 100000))
          ((not (is-executable (cons 'and filter) bnd)) nil)
          ((has-mongo-equality filter bnd)
	   (list 10 10))
          ((has-mongo-comparison filter bnd) 
	   (list 100 100))
          (t (list 1000 1000)))))

;;;
;;; The finalizer
;;;

(defun mongo-finalizer (ds predl sb bnd rest)
  "MongoDB finalizer"
  (let* ((sp (get-sourcepred predl))
         (reduced-predl (mongo-final-predl sp predl))
	 (rvar (third sp)))
    (if (or (null rvar) 
            (eq rvar '*)
            (osql-constantp rvar))
	predl;; No access variable, just skip finalization
      (let* ((known-vars (adjoin rvar bnd))
	     (accessed-attributes (accessed-record-attributes rvar 
							      reduced-predl))
	     (extracted (extractable-mongo-comparisons 
			 (getcalledpredl rest)
			 (union known-vars
				(accessed-record-values reduced-predl))))
	     (db (mongo-database (car sp)))
	     (coll (mongo-collection (car sp)))
	     (finalized (generate-mongo-query 
			 accessed-attributes 
			 (append extracted reduced-predl)
			 bnd))
	     (compl (car finalized))
	     (remaining (cdr finalized))
	     rvars ci)
        (if (and rest extracted);;does not work if filter is last in tbrl
	    (smash rest (remove-predl extracted rest)))
	(cond ((cdr compl)(setq compl (make-record1 "$and" 
						    (listtoarray compl))))
	      ((null compl) (setq compl (make-record (vector))))
	      (t (setq compl (car compl))))
	(setq rvars (variables-in-record compl))
	(setq ci (dt_genvar _integer_))
	(cond (rvars (let ((srec (dt_genvar _object_));;substituted record
			   (varvec (dt_genvar _vector_)))
		       `((,(get-relation (theresolvent 'mongo_connid)) 
			  ,ds ,ci)
			 (,_vector-constructor_ ,varvec ,@ rvars)
			 (,_substv_ ,(listtoarray rvars) ,varvec ,compl ,srec)
			 (,(theresolvent 'mongo_query) ,ci ,db ,coll
			  ,srec ,rvar)
			 ,@ remaining)))
	      (t `((,(get-relation (theresolvent 'mongo_connid)) ,ds ,ci)
		   (,(theresolvent 'mongo_query) ,ci ,db ,coll
		    ,compl ,rvar)
		   ,@ remaining)))
	))))

(defun accessed-record-attributes (var predl)
  "The attributes of VAR accessed in PREDL"
  (subset predl (f/l (pred)
		     (and (is-record-access pred)
                          (eq var (second pred))))))

(defun is-mongo-attribute-equality (pred bnd)
  (and (leaf-predicate-p pred)
       (eq (car pred) _record-vref_)
       (every (f/l (v)(variable-is-bound v bnd)) 
	      (cddr pred))))

(defun has-mongo-comparison (predl bnd)
  (isome predl (f/l (p)
		    (and (leaf-predicate-p p)
			 (cassoc (car p) _mongo-comparisons_)
                         (or (intersection (cdr p) bnd)
                             (isome (cdr p)(function osql-constantp)))))))

(defun has-mongo-unknown-comparison (predl bnd)
  (isome predl (f/l (p)
		    (and (leaf-predicate-p p)
			 (cassoc (car p) _mongo-comparisons_)
                         (or (intersection (cdr p) bnd)
                             (isome (cdr p)(function osql-constantp)))))))
   
(defun has-mongo-equality (predl bnd)
  (isome predl (f/l (pred)(is-mongo-attribute-equality pred bnd))))
   
(defun generate-mongo-query (accesses predl bnd)
  "Generate a pair (mq . remaining)
   where mq is a MongoDB query record extraced from PREDL
   and remaining are the predicates remaining in PREDL after the extraction"
  (let ((remaining predl) mq mcomp)
    (dolist (attr accesses)
      (let ((var (fourth attr))
	    (field (third attr)))
	(dolist (pred predl)
	  (cond ((not (leaf-predicate-p pred)) nil)
		((not(memq var (cdr pred))) nil)
		((is-mongo-attribute-equality pred bnd)
		 (push (make-record1 field var) mq)
                 (setq remaining (remove pred remaining)))
		((null (assoc (car pred) _mongo-comparisons_)) 
                 nil)
		((and (eq var (second pred));; (comp var val)
		      (variable-is-bound (third pred) bnd))
		 (push (make-record1 field 
				     (make-record1 
				      (cassoc (car pred) _mongo-comparisons_)
				      (third pred)))
		       mq)
		 (setq remaining (remove pred remaining)))
		((variable-is-bound (second pred) bnd);; (comp val var)
		 (push (make-record1 field 
				     (make-record1 
				      (cassoc (inverse-comp (car pred))
					      _mongo-comparisons_)
				      (second pred)))
		       mq)
		 (setq remaining (remove pred remaining)))))))
    (cons (nreverse mq)
	  remaining)))

(defun mongo-database (sp)
  "Get the database of a MongoDB source predicate"
  (caar (getfunction 'mongo_database (list sp))))

(defun mongo-collection (sp)
  "Get the collection of a MongoDB source predicate"
  (caar (getfunction 'mongo_collection (list sp))))

(defun mongo-final-predl (sp predl)
  (let ((rvar (third sp))
	(kval (second sp)))
    (if (and kval (neq kval '*))
	(cons (list _record-vref_ rvar "_id" kval) (remove sp predl))
      (remove sp predl))))
