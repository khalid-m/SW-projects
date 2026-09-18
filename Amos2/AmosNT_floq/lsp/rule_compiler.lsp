;;; ============================================================
;;; AMOS
;;; 
;;; Author: (c) 1995 Salah-Eddine Machani, EDSLAB
;;; $RCSfile: rule_compiler.lsp,v $
;;; $Revision: 1.14 $ $Date: 2009/09/04 18:43:40 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description:  An extension of OSQL with rules of type ECA based 
;;;               on function monitoring. Compiles the created rule
;;;               to three functions: event-function, condition-function
;;;               and an action-procedure. CA rules are compiled to ECA 
;;;               rules. A condition-function returning always true is 
;;;               generated for rules of type EA. Delta-sets are generated
;;;               to record changes to functions and the event-function
;;;               is defined in termes of these delta-sets.  Rules when 
;;;               activated are inserted into a propagation network and an
;;;               incremental evaluation technique is used to propagate 
;;;               changes to derived functions.
;;;
;;; Requirements: rules_network
;;; =============================================================
;;; $Log: rule_compiler.lsp,v $
;;; Revision 1.14  2009/09/04 18:43:40  torer
;;; ECA rules removed
;;;
;;; Revision 1.13  2006/11/30 20:22:25  torer
;;; Function bag-functionp removed
;;;
;;; Revision 1.12  2005/09/14 18:38:50  torer
;;; Systematically using (RESOLVENTS fn) to get resolvents.
;;;
;;; Revision 1.11  2004/12/09 13:53:59  torer
;;; (verify-all) checks for undefined Lisp functions
;;;
;;; Revision 1.10  2004/12/08 18:38:06  torer
;;; 1. All Lisp code verified using (verfify-all)
;;; 2. Makefile amos.bpr now recompies bison/flex files only when needed
;;;
;;; Revision 1.9  2004/03/03 21:12:09  torer
;;; sagas removed since sick and not tested
;;;
;;; Revision 1.8  2002/06/05 10:02:14  torer
;;; UNIX compatibility
;;;
;;; Revision 1.7  2002/01/02 15:10:53  torer
;;; 1. Code for collection data types now in collections.lsp
;;; 2. flushing efter system error messages
;;;
;;; Revision 1.6  2001/12/27 16:24:57  torer
;;; 1. Modified ECA rules so that the net effect of events now computed correctly
;;; 2. Fixed severe memory leak in logger
;;;
;;; Revision 1.5  2000/10/24 12:44:16  torer
;;; ECA rules OK
;;;
;;; Revision 1.4  2000/09/05 08:46:11  evato
;;; Removed a lot of CA stuff from rule system. (This code has currently
;;; been commented, instead of being entirely deleted). No longer possible
;;; to use "CA-rule system".
;;;
;;; Revision 1.3  2000/08/24 09:21:33  evato
;;; Made new functions ruleCheck and rule-find-freevars in the ECA rule package,
;;; since it redefined check and find-freevars in a non-compatible way.
;;;
;;; Revision 1.2  2000/08/14 07:35:58  torer
;;; Patched rule system temporarily to be able to install system.
;;; The installer no longer tries to load non-existing files.
;;;
;;; Revision 1.1  2000/08/11 16:18:40  evato
;;; New files for ECA rule execution. Some are probably superfluous if CA rules
;;; are excluded, and then they should be removed later.
;;;
;; Revision 1.2  1997/10/29  16:47:08  vanja
;; Derived types support added
;;
;; Revision 1.1  1996/12/05  14:27:25  marsk
;; Added ECA-rule package that can be loaded on demand.
;; Deleted event manager (rewritten in C).
;;
;;;


;=====================================================================================
;;global-variable 'the-deferred-network'
;;
;;By default every activated rule is inserted into the-deferred-network
;;propagation network. When considering contexts different networks should 
;; be created for each context.
(defvar the-deferred-network)
(defvar _rule_)

;=====================================================================================
;;create-rule-eca
;;
;;create a new rule
;;arguments:
;;name - rule name
;;argl - rule's arguments list
;;tail - rule's body <for_each_clause + event clause + condition clause + action clause>
;;return:
;; rule

;; Renamed from create-rule-eca!!!!!
(defmacro create-rule (name argl &rest tail)
   "Parsed create rule <name> <argl> from <quant> on <event> when <condition> do <action>;"
   (let* ((param (if (eq (car (mklist (car tail))) 'FOREACH) (car tail)))
          (impl (if param (cdr tail) tail))
          
          (quant (cadr param))
          
          ;;event specification
          (event (if (eq (car impl) 'ON) (cadr impl)))
          
          ;;condition specification
          (condition (if event (if (eq (caddr impl) 'WHEN) (cadddr impl))
                        (if (eq (car impl) 'WHEN) (cadr impl))))
          
          ;;action specification
          (action (if (eq (caar (last impl)) 'proc-block) 
                     (car (last impl)) (list 'proc-block (car (last impl))))))
      (if event nil (error "Only ECA rules supported" name))
      (list 'createrule (kwote name) (kwote argl) 
        (kwote quant) (kwote event) (kwote condition) (kwote action))))

(defun createrule (name argl quant event condition action)
   "Create a new ECA rule"
   
   (resetgenvar (let* ((evtfnname (pack 'evt- name))
                       (cndfnname (pack 'cnd- name))
                       (procname (pack 'act- name))
                       (evt-specif (event-specification evtfnname event argl quant))
                       (evtrestypes (second evt-specif))
                       (cnd-act (condition-action cndfnname procname condition 
                                  action argl quant evtrestypes))
                       (rule (or (getobjectnamed name _rule_ t) 
                                 (/createobject 'rule name)))
                       (eventfn (car evt-specif))
                       (condfn (if cnd-act (car cnd-act)))
                       (procfn (if cnd-act (cadr cnd-act)))
                       )
                   (if (null (getobject eventfn 'delta-set)) 
                      (create-delta-set (generic-function-of eventfn) eventfn))	
                   (/putobject rule 'event-function eventfn)
                   (/putobject rule 'condition-function condfn)
                   (/putobject rule 'action-procedure procfn)
                   (/putobject eventfn 'rule rule) 
                   rule)))

;=====================================================================================
;;event-specification
;;
;;generates an event function for the specified event in the rule definition
;;The composite-event function or the simple-event function is invoked depending 
;;if the specified event is simple or composite.
;;arguments:
;;evtfname: event function name
;;event: the event as specified by the user
;;ruleargl: the argument list of the rule
;;foreachclause: the argument list in the for-each-clause
;;return:
;;eventfn: event function
;;evt-res-types: the result types of the event function
(defun event-specification (evtfnname event ruleargl foreachargl)
   (let* ((evt-specif (if (composite? event) (composite-event ruleargl foreachargl event)
                         (simple-event ruleargl foreachargl event)))	 
          (evt-type (first evt-specif))
          (evt-argl (second evt-specif))
          (evt-res-types (third evt-specif))
          (evt-res-vars (fourth evt-specif))
          (evt-quant (fifth evt-specif))
          (evt-pred (sixth evt-specif))
          (evt-deltaset (seventh evt-specif))
          (eventfn (createfunction evtfnname evt-argl evt-res-types evt-res-vars 
                     evt-quant evt-pred)))
      (list eventfn evt-res-types)))

;=====================================================================================
;;composite-event  
;;
;;builts an event function for a composite event. the simple-event function
;;is invoked for each simple event.
;;arguments:
;;ruleargl: the rule arguments list
;;foreachargl: the arguments list in the for-each-clause
;;event: the specified composite event
;;Return:
;;evttype: ADDED/REMOVED/UPDATED/CREATED/DELETED
;;evtargtypes: the event function arguments list
;;evtrestypes: the event function result types
;;evtresvars: the event function return variables
;;evtquant: the event function for-each-clause
;;evtpred: the event function body
;;evtdeltaset: the event function delta-set
(defun composite-event (ruleargl foreachargl event)
  (let* ((logop (car event)) 
         (events (cdr event))
         (event1 (car events))
         (event2 (cadr events))
         (evt1-specif (if (composite? event1) 
			  (composite-event ruleargl foreachargl event1)
			(simple-event ruleargl foreachargl event1)))
         (evt2-specif (if (composite? event2)
			  (composite-event ruleargl foreachargl event2)
			(simple-event ruleargl foreachargl event2)))
         (evttype (append (first evt1-specif)
			  (first evt2-specif)))
         (evtargtypes ruleargl)	   
         (evtrestypes (union (third evt1-specif)
			     (third evt2-specif)))
         (evtresvars (union (fourth evt1-specif) 
			    (fourth evt2-specif)))
         (evtquant (union (fifth evt1-specif)
			  (fifth evt2-specif)))
         (evtpred (list logop  
			(sixth evt1-specif)
			(sixth evt2-specif)))
         (evtdeltaset (append (seventh evt1-specif) 
			      (seventh  evt2-specif)))
	 )        
    (list  evttype evtargtypes evtrestypes evtresvars evtquant evtpred evtdeltaset)))

;=====================================================================================
;;simple-event
;;
;;generates element to create an event function.
;;Arguments:
;;ruleargl: the rule arguments list
;;foreachargl: the arguments list in the for-each-clause
;;event: the specified composite event
;;Return:
;;evttype: ADDED/REMOVED/UPDATED/CREATED/DELETED
;;evtargtypes: the event function arguments list
;;evtrestypes: the event function result types
;;evtresvars: the event function return variables
;;evtquant: the event function for-each-clause
;;evtpred: the event function body
;;evtdeltaset: the event function delta-set

(defun simple-event (ruleargl foreachargl event)
   (let* ((evttype (car event))
          (category (cond ((OR (eq evttype 'ADDED) (eq evttype 'REMOVED) (eq evttype 'UPDATED)) 
                           1) ;function update
                          ((OR (eq evttype 'CREATED) (eq evttype 'DELETED)) 
                           2))) ; object creation
          (evtattr (if (eq category 1) (car (second event)) 'ALLOBJECTS))
          (attrvar  (if (eq category 1) (cdr (second  event)) (last event))); to be checked  
          (attrvartype (mapcar (f/l (tp) (gettypenamed (car tp)))
                         (find-return-types attrvar (append ruleargl foreachargl))))
          
          (resolvent (get-most-specific-resolvent (getfunctionnamed evtattr) (if (eq category 1)
                                                                                attrvartype)))
          (complex-derivedfn? (if (eq category 1) (check-args resolvent))) DANGER! (TR)
          (attrestypes (getfunctionrestypes resolvent))  
          (evtargtypes ruleargl) ;to be modified
          ;(evtargtypes (get-pairs attrvar ruleargl))
          
          (evtresvars attrvar) 
          (evtrestypes (if foreachargl (get-pairs attrvar foreachargl)
                          (list attrvartype)))
          ;(evtrestypes (get-pairs attrvar foreachargl))
          
          (evtquant (getquant (append attrestypes (list 'timeval))))
          (genvars (mapcar (function second) evtquant))
          (tvar (car (last genvars)))
          (funname (generic-fnname resolvent))
          (evtdeltaset (if (and resolvent (getobject resolvent 'delta-set))
                          (getobject resolvent 'delta-set)
                          (create-delta-sets (getfunctionnamed funname) resolvent)))
          (evtdeltafn (cond ((OR (eq evttype 'ADDED) (eq evttype 'CREATED)) 
                             (get-delta-addedfn evtdeltaset))
                            ((OR (eq evttype 'REMOVED) (eq evttype 'DELETED))
                             (get-delta-removedfn evtdeltaset))
                            ((eq evttype 'UPDATED) (get-delta-updatedfn evtdeltaset))))  
          (evtpred (cond ((eq category 1) (if (> (length genvars) 2) 
                                             (list '= (cons 'tuple (butlast genvars)) 
                                               (append (list evtdeltafn tvar) attrvar))
                                             (list '= (car genvars) 
                                               (append (list evtdeltafn tvar) attrvar))))
                         ((eq category 2) (list '= (car attrvar) (list evtdeltafn tvar))))))
      (if (eq evttype 'DELETED) (amos-error "The 'deleted' triggering event is not currently handeled."))
      (list  evttype evtargtypes evtrestypes evtresvars evtquant evtpred evtdeltaset)))

;=====================================================================================
;;condition-action
;;
;;generates the condition function and the action procedure and 
;;invokes the event-generation function to generate an event function 
;;in case of CA rules
;;Arguments: 
;;cndfnname the condition function name
;;procname the action procedure name
;;condition the rule condition
;;action the rule action
;;ruleargl the rule argumnets list
;;foreachargl the arguments list in the rule for-each-clause
;;evtrestypes the event function result types
;;Return:
;;condfn the condition function
;;actproc the action function
(defun condition-action (cndfnname procname condition 
				   action ruleargl foreachargl evtrestypes)
  "Define condition and action functions for rule"
  (let* ((cndvarl (if condition (rule-find-freevars condition nil))) 
					; free variables in condition
	 (cndargl (append ruleargl evtrestypes)) 
					; arguments of condition function
	 (cndquant (if condition (find-pairs cndvarl 
					     (append ruleargl foreachargl))))
	 (actvarl (rule-find-freevars action nil)) 
					; free variables in action
	 (returnl (if condition (find-return-types 
				 actvarl 
				 (append ruleargl foreachargl))))
	 (pargl (if condition (find-pairs actvarl 
					  (append ruleargl foreachargl)) ; ECA
		  cndargl))		; EA
	 (condfn (if condition (createfunction 
				cndfnname cndargl 
				returnl  actvarl cndquant condition)))
	 (actproc (eval `(define-proc , procname , pargl () , action))))
    (list condfn actproc)))

(defun find-return-types (varl defl)
   (if (null varl) varl
      (cons (list (car (find-pair (car varl) defl))) (find-return-types (cdr varl) defl))))

(defun find-pairs (varl defl)
  (if (null varl) varl
    (cons (find-pair (car varl) defl) (find-pairs (cdr varl) defl))))

(defun find-pair (var defl)
  (if (null defl)
      (amos-error "Undefined variable: " var)
    (if (eq var (cadar defl))
	(car defl)
      (find-pair var (cdr defl)))))


;=====================================================================================
;;event-generation
;;
;;generates the triggering events from the condition for CA rules
;;Arguments:
;;evtfnname: the event function name
;;condition: the condition function name
;;ruleargl: the rule arguments list
;;foreacharg : the rule for-each-clause
;;Return:
;;evt-specif: the generated events
(defun event-generation (evtfnname condition ruleargl foreachargl)
  (let* ((cndpairs (find-functions condition nil))
	 (event (generate-event cndpairs))
	 (evt-specif (event-specification evtfnname event 
					  ruleargl foreachargl )))
    evt-specif))


;=====================================================================================
;;delete-rule-eca
;;
;; deletes a rule.
;;Arguments:
;;name: rule name
;;Return:

;; Renamed from delete-rule-eca!!!!!
(defmacro delete-rule (name) 
  (let* ((rule (getrulenamed name))
	 (network the-deferred-network)
	 (eventfn (getobject rule 'event-function))
	 (deltaset (getobject eventfn 'delta-set))
	 (condfn (getobject rule 'condition-function))
	 (actproc (getobject rule 'action-procedure))
	 (activations (getobject rule 'activations)))
    (if activations 
	(remove-from-network rule nil network))    
    (deleteobject (get-delta-addedfn deltaset))
    (deleteobject (get-delta-removedfn deltaset))
    (deleteobject (get-delta-updatedfn deltaset))
    (/putobject eventfn 'delta-set nil)
    (/putobject (un_pred_fn eventfn) 'delta-sets nil)
    (deleteobject eventfn)
    (deleteobject condfn)
    (deleteobject actproc)
    (deleteobject rule)))


;=====================================================================================
;; activate-rule-eca
;;
;;activates a rule and inserts it in the propagation network
;;Arguments:
;;name: rule name 
;;argl: the rule activation parameters
;;options: priority number, nervous.flg(not used), context(not used in the current impl)
;;Return:

;; Renamed from activate-rule-eca!!!!! 'activate-rule0-eca is used directly
;; instead of 'activate-rule-0.
(defmacro activate-rule (name argl &rest options)

		    (list 'activate-rule0-eca 
			  (kwote name)
			  (rule-compile-substosqlvars argl)
			  (rule-compile-substosqlvars (car options)) ; priority
			  (cadr options)) ; nervous_flg
   )
	
(defun activate-rule0-eca (name argl prio nervous_flg)
  (let* ((rule (getrulenamed name))
	 (network the-deferred-network)
	 (priority (if (not prio) 0 prio))
	 (activations (getobject rule 'activations))
	 (old (if activations
		  (car (mapcar (f/l (activa) (if (equal argl (car activa)) activa))
			       activations)))))
    (if (or (< priority 0) (> priority 5))
	(amos-error "Rule priorities can only be between 0 and 5: " priority)
      (let* ((new (list argl nervous_flg priority)))
	(if (null old)
	    (/putobject rule 'activations (append (list new) activations))
	  (/putobject rule 'activations (subst new old activations))) 
	(insert-into-network rule (getobject rule 'activations) network)))
    nil))

;=====================================================================================
;; deactivate-rule-eca
;;
;;deactivates a rule and removes it from the propagation network
;;Arguments:
;;name: rule name
;;argl: the rule arguments list
;;Return:

;; Moved from rules.lsp!!!!! Observe that it is the old deactivate-rule that 
;; is used (it doesn't work otherwise). It also seems that it is ALWAYS that 
;; one that has been used, regardless of the movd's made in eca_rules.lsp!
;; It is possible that this can be exchanged for the eca variant when 'context'
;; is removed (which it probably can be).
(defmacro deactivate-rule (name argl context)
  (list 'deactivate-rule0-eca
	(kwote name) 
	(rule-compile-substosqlvars argl) 
	(kwote context)))

(defun deactivate-rule0-eca (name argl)
   (let* ((rule (getrulenamed name))
          (network the-deferred-network)
          (oldactiva (getobject rule 'activations))
          (newactiva oldactiva))
      (mapc (f/l (activa) (if (equal argl (car activa)) 
                             (setq  newactiva (remove activa oldactiva)))) 
        oldactiva)
      (if (equal newactiva oldactiva)
         (amos-error "Rule is not activated for given argument!" rule argl)
         (/putobject rule 'activations newactiva))
      (remove-from-network rule newactiva network)
      nil))

;;; Does not work (TR)
(quote
(defun deactivate-rule0 (name argl cname)
  (let* ((rule (getrulenamed name))
	 (context (if cname (getobjectnamed cname _context_) _deferred_))
	 (activations (getobject rule 'activations))
	 (activation (if argl (assoc argl activations)
		       ;activations))
		       (cons (list (first (first activations)))
			     (cdr (first activations)))))
	 (prev (if argl (cdr activation) activation))
   	 (new
	  (if prev ; decrease ref count
	      (subst (1- (first (last activation))) (first (last activation))
		     activation)
	      ;(cons (car prev) (1- (cdr prev))) This must be wrong! 
	    (amos-error "Rule is not activated for given argument!" rule argl))))
    ; Added 'if not' to allow rules with no arguments.
    (if (> (third new) 0) ; Formerly (cdr new)
	(if argl
	    (/putobject rule 'activation 
			(cons argl
			      (cons new 
				    (remove activation activations))))
	  (/putobject rule 'activation new))
      (progn
	(if argl (deactivatemonitor (car (car new))))  ; Formerly (car new)
	(if argl
	    (/putobject rule 'activations (remove activation activations))
	  (/putobject rule 'activations nil))))
    (remove-from-context context (car new)))
  nil)
)
;;;

;;=====================================================================================
;;getfunctionrestypes
;;
;;returns the types of the result of a function
;;Arguments:
;;fno: the function
;;Return:
;;list of the result types
(defun getfunctionrestypes (fno)
  (let ((resl (delete fno (resolvents fno)))) 
    (if resl 
	(mapcar #'getfunctionrestypes resl) 
      (if (getobject fno 'restypes) 
	  (getobject fno 'restypes) 
	(list (gettypenamed 'boolean))))))


;;=====================================================================================
;;get-first-type
;;
;;returns the first type of an object
;;Arguments:
;;obj object
;;Return
;;the object's type
(defun get-first-type (obj)
  (car (oid-types obj)))

;;=====================================================================================
;;get-used-functions
;;
;;returns a list of the underlying functions of a given function
;;Arguments:
;;fno a function
;;Return:
;;list of the used objects of type function

; Changed to 'mapcan' from 'delete nil'.
(defun get-used-functions (fno)
   (let ((genfno (generic-function-of fno)))
      (mapcan 
        (f/l (fn) 
          (and  (eq (get-first-type fn) 
                  _function_) 
               (neq fn genfno)
               (list fn)))
        (getobject fno 'usesobjects))))


;;=====================================================================================
;;getquant
;;
;;assigns to each type in a list a generated variable
;;Arguments:
;;typesl: the list of types
;;Return:
(defun getquant (typesl)
  (mapcar (f/l (x) (list x (genvar))) typesl))


;;=====================================================================================
;;generate-event 
;;
;;generates the added and the updated events for a given function
;;Arguments:
;;pairs: the function with its arguments
;;Reurn:
;;evt : composite event (OR (updated pairs) (added pairs))
(defun generate-event(pairs)
  (let* ((evt (list 'or (list 'updated (list (caar pairs) (cadar pairs)))
		    (list 'added (list (caar pairs) (cadar pairs)))))
;		    (list 'removed (list (caar pairs) (cadar pairs)))))
	 (rest (cdr pairs)))
    (while rest
      (progn
	(setq evt (list 'or 
			evt 
			(list 'or 
			      (list 'updated (list (caar rest) (cadar rest))) 
			      (list 'added (list (caar rest) (cadar rest)))))) 
;			      (list 'removed (list (caar rest) (cadar rest))))))
	(setq rest (cdr rest))))
    evt))


;=====================================================================================
;; get-predicate
;;
;; returns the predicate of a function
;; arguments:
;; 'fno' the function object
;; return value:
;; the predicate object
(defun get-predicate (fno noerr)
  (getfunctionnamed (pack 'P_ (oid-name fno)) noerr))

;====================================================================================
;;get-pairs
;;
;;finds the corresponding type for a given variable in a list of pairs(type vars)
;;varl: list of variables
;;pairsl: list of pairs

(defun get-pairs (varl pairsl)
  (first (remove 'nil (mapcar (f/l (var) (get-pair var pairsl)) varl))))

; Formerly : (remove 'nil (mapcar (f/l (var) (get-pair var pairsl)) varl)))
; which returned a list '(((type var) (type var)...))
; '((type var) (type var)...) seems to agree better with the function
; fix_at_decl, used in createfunction, used in event-specification.

(defun get-pair (var pairsl)
  (remove 'nil (mapcar (f/l (p) (if (equal var (second p)) p)) pairsl)))

;====================================================================================
;;composite?
;;
;;checks if a given event is complex or simple
;;Arguments:
;;event: rule event
;; Return: 
;;t if composite nil if simple
(defun composite?(event)
    (if (memq (car event) '(OR AND BEFORE AFTER ANDNOT)) t nil))

;====================================================================================
;;check-args
;;
;;checks if a function is a complex derived function (a function having 
;;different arguments from the functions it is defined from since changes 
;;to these type of functions are not monitored).
;;Arguments:
;;fno: a function
;;Return:

(defun check-args (fno)
  "Test for necessary (but not sufficient) condition of FNO being monitorable"
  (let* ((sb (getselectbody fno))
	 (argl (selectbody-argl sb)))
    (mappred (selectbody-optpred sb)
	     (f/l (p)
		  (cond ((atom p) nil)	; OK
                        ((not (oid-p (car p)))) ; Filters foreign functions. Not sufficient!
			((and 
			  (object-typep (car p) _function_)
			  (eqstart argl (cdr p))) ; not sufficient!
			 nil)		; OK
			(t (error "Complex derived function cannot be monitored" fno)))))))

;=====================================================================================
;; AMOS-Warning
;;
;;prints out a AMOS Warning message
;;Arguments:
;;c: a charstring containing the message
;;Return:
(defun AMOS-Warning (c) 
 (princ (concat "AMOS Warning: " c)) (terpri) )


;;=====================================================================================
;;find-functions 
;;
;;finds all the specified function in the rule condition 
;;Arguments:
;;ls: the condition or a (nested) list of predicates 
;;p: nil
;;Return
;;retl: list of couple of functions and their parameters
(defun find-functions (ls p) 
  (let ((pairl (if p p)) retl)
      (remove 'nil (mapcar (f/l (s) 
				(cond  ((nested-listp s) ( find-functions s pairl))
				       ((and (listp s) (osql-functionp (getobjectnamed (car s)))) 
					(progn (setq pairl (if pairl (append pairl (list s)) (list s)))
					       (setq retl pairl)))))
			 ls))
    retl))
	      

(defun log-operatorp (fno)
    (if (memq fno '(or and)) t nil))

(defun nested-listp (ls)
    (if (listp ls) (cond  ((listp (car ls)) t)
			  (t (if (rest ls)(nested-listp (rest ls))))) nil))

;(defun remove-duplicates (lis)
;  ())

(defun add-nonkey (argl)
  (mapcar (f/l (p) (if (< (length p) 3) (append p (list 'nonkey)) p)) argl))

(defun rule-compile-substOSQLvars (s)
  (cond ((osql-interfacevarp s) (osql-interfacevar s))
	((osql-constantp s) 
	 (if (aggregatep s)
	     (cons (car s) (mapcar (function rule-compile-substOSQLvars) 
				   (aggregate-data s)))
	   (kwote s)))
	((atom s) (kwote s))
	((eq (car s) :eval) (cadr s))
	(t (cons 'list
		 (mapcar (function rule-compile-substOSQLvars) s)))))


(defun init-rule-compiler()
  (defvar the-deferred-network (create-network))
  (/putobject the-deferred-network 'top-level 0)
  )