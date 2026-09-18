;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1993 Martin Skold, CAELAB
;;; $RCSfile: sagas.lsp,v $
;;; $Revision: 1.7 $ $Date: 2004/11/20 11:55:58 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: An extension of AMOS transaction system with sagas.
;;;              Sagas are first class objects and can be used to chain
;;;              a sequence of committed transations with compensating
;;;              transactions. Abortion of a saga causes all the compensations
;;;              to be executed and the sagas (and sub-sagas) to be deleted.
;;;              Committing a saga just causes deletion (since the transactions
;;;              are already committed). Compensation of one saga is done in
;;;              one complete sequence (unless stopped). If an application
;;;              needs to schedule sagas (forward and backward) in
;;;              smaller steps it is possible to orchestrate many sagas 
;;;              through a saga layer (as part of the application)
;;;              outside AMOS. 
;;; =============================================================


;;; Syntax:
;;; set :s = create_saga(); (should be followed by a commit)
;;; or
;;; set s = create_sub_saga(); (only to be used within another saga)
;;; SAGA <saga>
;;;  <procedure stmt>;
;;; COMPENSATION
;;;  <procedure stmt>; (stop_compensation() stops compensation of current saga)
;;; commit_saga(:s);/abort_saga(:s);
;;; Rule contexts can be associated with sagas:
;;; set :c = create_context("saga_context");
;;; associate(:s, :c, <mode>);
;;; where <mode> :=
;;; "exit": context is checked when each transaction is committed 
;;; (saga is exited)
;;; "commit" context is checked when the saga is committed 
;;; "rollback" context is checked when the saga is aborted
;;; (during compensating transactions)

(defglobal _saga_)
(defvar *saga* nil)
(defvar *compensate* t)

(defun create-saga(&optional sub-saga name)
  (let ((saga (/createobject 'saga name)))
    (if (and sub-saga *saga*) ; create-sub-saga
	(/saga-log *saga* 
		   (list 'create-saga) 
		   (list 'commit-saga saga)
		   (list 'abort-saga saga)))
    ; (if (not (and sub-saga *saga*)) (export saga)) ; export top sagas
    saga))

(defun getsaganamed (name)
  (getobjectnamed (mkatom name) _saga_))

(defun /saga-log(saga trans ok comp)
   (/putobject saga
	      'log (cons (list trans ok comp) (getobject saga 'log))))

(defmacro exec-saga(saga trans comp)
  (let* ((s (genvar))
	 (saganame (let ((ivar (if
				   (and (symbolp saga)(osql-interfacevar-p saga))
				   (osql-interfacevar saga))))
		     (if ivar
			 (progn
			   (make-global-variable ivar)
			   ivar) ; use internal lisp name
		       (if (stringp saga)
			   (list 'getsaganamed saga)
			 saga))))
	 (varl (find-freevars comp))
	 (decl (build-declare-variables-list varl))
	 (cpyl (build-copy-value-list varl)))
    `(proc-block
      (osql-let ((saga , s))
		(setq , s , saganame)
		(let ((*saga* , s)
		      (*compensate* *compensate*)) ; inherit from parent
		  ;; macroexpand forward transaction
		  (proc-block 
		   , trans 
		     (call-procedure check_saga_contexts (, s "exit"))))
		(let ((__decl (list ,@ decl))
		      (__cpyl (list ,@ cpyl)))
		  (store-saga , s (quote , trans) 
				(list 'proc-block
				      (list 'osql-dcl __decl 
					    (cons
					     'progn
					     __cpyl)
					    (quote 
					     ;; macroexpand backward transaction
					     , (list 'proc-block comp))))))))))

(defun osql-interfacevar-p (var)
  (getprop var 'interfacevar))

(defun make-global-variable (var)
  (putprop var 'global t))

; (defun getnameoftypeof(x)
;   (object-name (arg-type x)))

(defun build-declare-variables-list(varl)
  (mapcar 
   (f/l (var) (list 'list (list 'getnameoftypeof var) 
		    (list 'quote var)))
	  varl))

(defun build-copy-value-list(varl)
  (mapcar (f/l (var) (list 'list  (list 'quote 'osql-select) 
			   (list 'list var)
			   (list 'quote 'into)
			   (list 'list (list 'quote var))))
	  varl))

(defun store-saga(saga trans comp)
  (/saga-log  saga trans nil comp)
  (commit)) ; always commit saga transactions

(defun commit-saga(saga)
  (if (not (deletedobjectp  saga)) ; check if not already commited
      (progn
	;; execute commit-actions for sub-sagas
	(mapc (q/l (pair) (eval (cadr pair))) 
	      (getobject saga 'log))
	; (check-saga-contexts saga "commit")
	(deleteobject saga)
	(commit))))

(defun abort-saga(saga)
  (if (not (deletedobjectp  saga)) ; check if not already aborted
      (let ((*saga* saga)
	    (*compensate* *compensate*)) ; inherit form parent	
	;; execute abort-actions for sub-sagas
	(mapc (q/l (pair) 
		   (if *compensate*
		       (progn
			 ;; evaluate compensating transaction
			 (eval (caddr pair))
			 ; (check-saga-contexts *saga* "rollback")
			 (commit))))
	      (getobject saga 'log))
	(deleteobject saga)
	(commit))))

(defun deletedobjectp (o)
  (eq (getobject o 'name) '*deleted*))

(defun associate(amos_context amos_saga amos_mode)
  (if (member amos_mode '("exit" "commit" "rollback"))
      (amosql "add saga_contexts(:saga, :mode) = :context;")
    (amos-error "Illegal mode in associate:" amos_mode)))

(defun disassociate(amos_context amos_saga amos_mode)
  (if (member amos_mode '("exit" "commit" "rollback"))
      (amosql "remove saga_contexts(:saga, :mode) = :context;")
    (amos-error "Illegal mode in disassociate:" amos_mode)))

(defun check-saga-contexts(amos_saga amos_mode)
  (amosql "check_saga_contexts(:saga, :mode);"))

(if (not (gettypenamed 'saga t))
      (setq _saga_ (createtype 'saga '(object))))

(defun setup-sagas()
  (foreign-lispfn create_saga () ((saga s))
		  (foreign-result (create-saga)))
  
  (foreign-lispfn create_saga ((charstring name)) ((saga s))
		  (foreign-result (create-saga nil (mkatom name))))
  
  (foreign-lispfn create_sub_saga () ((saga s))
		  (foreign-result (create-saga t)))
  
  (foreign-lispfn create_sub_saga ((charstring name)) ((saga s))
		  (foreign-result (create-saga t (mkatom name))))
  
  (foreign-lispfn saganamed ((charstring name)) ((saga))
		  (foreign-result (getsaganamed name)))
  
  (foreign-lispfn commit_saga ((saga s)) ()
		  (commit-saga s))
  
  (foreign-lispfn commit_saga ((charstring name)) ()
		  (commit-saga (getobjectnamed (mkatom name) _saga_)))
  
  (foreign-lispfn abort_saga ((saga s)) ()
		  (abort-saga s))
  
  (foreign-lispfn abort_saga ((charstring name)) ()
		  (abort-saga (getobjectnamed (mkatom name) _saga_)))
  
  (foreign-lispfn stop_compensation () ()
		  (setq *compensate* nil))
  
  (foreign-lispfn current_saga () ((saga s))
		  (foreign-result *saga*))
  
  (foreign-lispfn check_saga_contexts ((saga s) (charstring c)) ()
					; dummy declared for now
		  )
  )

;; Utility functions

(defun find-freevars (expr shadow)
  (cond	((proc-blockp expr) nil)
	((osql-constantp expr)
	 (if (aggregatep expr)
	     (find-freevars-in-list (aggregate-data expr) shadow)
	   nil))
	((symbolp expr)
	 (if (some (f/l (pair) (eq (cadr pair) expr)) shadow)
	     nil
	   (list expr)))
	((listp expr)
	 (case (car expr)
	       (osql-select
		(cond ((= (length expr) 3) ; simple select
		       (find-freevars-in-list (nth 1 expr) shadow))
		      ((and (= (length expr) 4) ; foreach without where
			    (eq (nth 2 expr) 'foreach)) 
		       (find-freevars-in-list (nth 1 expr) (append (nth 3 expr) shadow)))
		      ((and (= (length expr) 4) ; select into
			    (eq (nth 2 expr) 'into)) 
		       (find-freevars-in-list (nth 1 expr) shadow))
		      ((and (= (length expr) 4) ; select where
			    (eq (nth 2 expr) 'where)) 
		       (append-sets
			(find-freevars-in-list (nth 1 expr) shadow)
			(find-freevars (nth 3 expr) shadow)))	
		      ((and (= (length expr) 6) ; foreach where
			    (eq (nth 2 expr) 'foreach)
			    (eq (nth 4 expr) 'where)) 
		       (append-sets
			(find-freevars-in-list (nth 1 expr) (append (nth 3 expr) shadow))
			(find-freevars (nth 5 expr) (append (nth 3 expr) shadow))))
		      (t (amos-error "Illegal select expression: " expr))))
	       ((osql-foreach)
		(find-freevars-in-list (nth 4 expr) (append (nth 1 expr) shadow)))
	       ((call-function call-procedure)
		(find-freevars-in-list (caddr expr) shadow))
	       ((set-function add-function rem-function)
		(append-sets
		 (find-freevars-in-list (caddr expr) shadow)
		 (find-freevars-in-list (cadddr expr) shadow)))
	       ((osql-dcl osql-let)
		(find-freevars-in-list (cddr expr) 
				       (append (cadr expr) shadow)))
	       ((create-rule delete-rule))
	       ((activate-rule deactivate-rule)
		(find-freevars-in-list (caddr expr) shadow))		
	       (otherwise (find-freevars-in-list (cdr expr) shadow))))
	(t nil)))

(defun find-freevars-in-list (exprl shadow)
  (if (null exprl) exprl
    (append-sets (find-freevars (car exprl) shadow)
	   (find-freevars-in-list (cdr exprl) shadow))))

(defun filter (l fn)
  (if (null l) l
    (if (funcall fn (car l)) (cons (car l) (filter (cdr l) fn))
      (filter (cdr l) fn))))

(defun proc-blockp (x)
  (eq x 'proc-block))



