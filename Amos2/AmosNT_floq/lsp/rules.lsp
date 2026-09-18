;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1993 Martin Sköld, CAELAB
;;; $RCSfile: rules.lsp,v $
;;; $Revision: 1.15 $ $Date: 2007/08/28 07:52:27 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: An extension of OSQL with rules based on function monitoring. 
;;;              Uses a naive evaluation method, i.e. no incremental evaluation
;;;              of rule conditions.
;;; =============================================================
;;; $Log: rules.lsp,v $
;;; Revision 1.15  2007/08/28 07:52:27  torer
;;; Moved DROPFUNCTION to file relation.lsp
;;; Simplified, generalized, and corrected DROPFUNCTION
;;;
;;; ============================================================

(defvar _events_ )

(defun logical-merge (last new)
  (let ((change (if last last)))
    (setq change
	  (if new
	      (case change
		(nil 1)
		(0 nil) ; should never occur
		(1 1))
	    (case change
	      (nil 0)
	      (0 0)
	      (1 nil)))) ; should never occur
    change))

(defun add-event (event obj argl old new)
  (let* ((key (list event obj argl))
	 (last (gethash key (getobject _events_ 'hashtab))))
    (puthash 
     key
     _events_ 
     (logical-merge last new))))

(defun no-triggered-rulesp () 
   (not (firsthash (getobject _events_ 'hashtab))))

(defun firsthash (ht)
   (catch 'firsthash (maphash (f/l(k v)(throw 'firsthash v)) ht)))

;;; Does not work (TR):
(quote
(defun checkrules (context)
  (let ((ht (getobject _events_ 'hashtab)))
     (maphash (f/l (key change)
		   (if (integerp change) ; 0 or 1
		       (case (car key)
			   (/SETRELATION 
			    (markaschanged (cadr key) (caddr key)))
			   (otherwise nil))))
	      ht)
)
;;;

     ;; clear logical event logg since they have 
     ;; been registered by markaschanged
     (clrhash ht) 
     ))

;;; ================================
;;; RULECHECK
;;; check all activated rules
;;; called from commit

;;; No effect (TR):
(quote
(defun ruleCheck (context)
  (if (not context) (setq context _deferred_))
  (loop 
   (if (not (context-starttime context)) ; context is not active
       (return nil)) 
   (checkrules context)
   (if (no-triggered-rulesp) (return nil))) 
  nil)
)
;;;

;;; OSQL interface to RULECHECK:
;;; called from master.lsp

;;  Replaced calls to checkRules with calls to check-eca here:
(defun definecheckrules()
  (foreign-lispfn ruleCheck() ()
		  (check-eca _deferred_))
  (foreign-lispfn ruleCheck((integer n)) ()
		  (let ((*max-trigger* n))
		    (check-eca _deferred_ )))
  ;; (amosql "create function check_saga_contexts(saga s, charstring mode) -> boolean as
  ;;          for each context c where c = saga_contexts(s, mode) check(c);"))

;; Added a backquote to make this work:
  `(define_ipl check_saga_contexts ((saga s) (charstring mode)) ((boolean)) 
     (osql-foreach ((context c)) (= c (saga_contexts s mode)) nil 
		   (call-procedure chec-eca (c)))))


(defun catch-setrelation (obj arg old new)
  (let ((o (getobjectnamed obj _relation_)))
    (if (getobject o 'dependencies)
	(add-event '/setrelation o arg old new)))) 

(defmacro getrulenamed (name &optional errflg)
  `(getobjectnamed , name _rule_ , errflg nil))

; Nervous rule condition monitoring   
(defmacro create-condition-tracker (cachefn actionproc)
   `(q/l (mi fn argl)
      ;; evaluate condition and apply action on the action-tuples
      (mapfunction fn argl
        (f/l (amos_args)
          ;; execute action
          (call-function , actionproc :args)))))

(defun rule-find-freevars (expr shadow)
   (cond	((ipl-blockp expr) nil)
         ((osql-constantp expr)
          (if (aggregatep expr)
             (rule-find-freevars-in-list (aggregate-data expr) shadow)
             nil))
         ((symbolp expr)
          (if (some (f/l (pair) (eq (cadr pair) expr)) shadow)
             nil
             (list expr)))
         ((listp expr)
          (case (car expr)
            (osql-select
              (cond ((= (length expr) 3) ; simple select
                     (rule-find-freevars-in-list (nth 1 expr) shadow))
                    ((and (= (length expr) 4) ; foreach without where
                          (eq (nth 2 expr) 'foreach)) 
                     (rule-find-freevars-in-list (nth 1 expr) (append (nth 3 expr) shadow)))
                    ((and (= (length expr) 4) ; select into
                          (eq (nth 2 expr) 'into)) 
                     (rule-find-freevars-in-list (nth 1 expr) shadow))
                    ((and (= (length expr) 4) ; select where
                          (eq (nth 2 expr) 'where)) 
                     (append-sets
                       (rule-find-freevars-in-list (nth 1 expr) shadow)
                       (rule-find-freevars (nth 3 expr) shadow)))	
                    ((and (= (length expr) 6) ; foreach where
                          (eq (nth 2 expr) 'foreach)
                          (eq (nth 4 expr) 'where)) 
                     (append-sets
                       (rule-find-freevars-in-list (nth 1 expr) (append (nth 3 expr) shadow))
                       (rule-find-freevars (nth 5 expr) (append (nth 3 expr) shadow))))
                    (t (amos-error "Illegal select expression: " expr))))
            ((osql-foreach)
             (append-sets
               (rule-find-freevars (nth 2 expr) (append (nth 1 expr) shadow))
               (rule-find-freevars (nth 4 expr) (append (nth 1 expr) shadow))))
            ((call-function call-procedure)
             (rule-find-freevars-in-list (caddr expr) shadow))
            ((set-function add-function rem-function)
             (append-sets
               (rule-find-freevars-in-list (caddr expr) shadow)
               (rule-find-freevars-in-list (cadddr expr) shadow)))
            (osql-let
              (rule-find-freevars-in-list (cddr expr) 
               (append (cadr expr) shadow)))
            ((create-rule delete-rule))
            ((activate-rule deactivate-rule)
             (rule-find-freevars-in-list (caddr expr) shadow))		
            (otherwise (rule-find-freevars-in-list (cdr expr) shadow))))
         (t nil)))

(defun rule-find-freevars-in-list (exprl shadow)
  (if (null exprl) exprl
    (append-sets (rule-find-freevars (car exprl) shadow)
	   (rule-find-freevars-in-list (cdr exprl) shadow))))

(defun append-sets (s1 s2)
  (if (null s1) s2
    (let ((s (append-sets (cdr s1) s2)))
      (if (member (car s1) s) s
	(cons (car s1) s)))))

(defun ipl-blockp (x)
  (eq x 'proc-block))

(defglobal _enable-ecaflg_ nil)

(defun enable_ecaf (fno res)
   (cond (_enable-ecaflg_ (osql-result "Already enabled"))
         (t (init-rules)
            (setq _enable-ecaflg_ t)
            (osql-result "Enabled"))))

(osql "create function enable_eca()->Charstring
as foreign 'enable_ecaf';")

(defun init-rules ()
   (setq _events_ (/createobject 'userobject))
   (putobject _events_ 'hashtab (make-hash-table :size 512))
   (init-event-manager)
   (init-contexts)
   (init-rule-compiler)
   (if (not (gettypenamed 'rule t))
      (progn
        (defvar _rule_ (createtype 'rule '(object))) ; OSQL rule
        (createtype 'ruleinstance '(rule)))) ; an activated rule
   (subscribe-event _assertrelation_ (function catch-setrelation))
   (definecheckrules)     ; define check rules functions; from master.lisp    
   (subscribe-events)
   (foreign-lispfn trace_rules((integer level))((integer))
      (if (and (>= level 0)(<= level 3))
          (setq *ruletracelevel* level)
       (error "Illegal rule trace level" level))
     (foreign-result *ruletracelevel*))
   (commit))





