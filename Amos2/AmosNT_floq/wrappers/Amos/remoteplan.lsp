;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: remoteplan.lsp,v $
;;; $Revision: 1.5 $ $Date: 2004/11/20 11:55:59 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: The absorbent for a subquery to be compiled at a remote Amos
;;;              node. The absorbent is updated as new predicates are inserted
;;;              by the translator (see amos_translator.lsp), and finally the
;;;              translator will call remoteplan-compile-subquery-request which
;;;              induces the remote amos compilation of the function.
;;;              
;;; ===========================================================================
(defvar remoteplan-printing nil)

(defstruct remoteplan
  datasource; the datasource object
  environment; the variable environment
  results; list of variables or constants
  inputs;  list of (bound) variables or constants
  types;   list of amosentity:s
  wherepreds; implicit conjunction
  )

(defun remoteplan-add-result (rplan arg)
  "Adds the argument to the result that the remoteplan will produce when
   compiled."
  (if (not (anonymous-varsymbolp arg))
      (setf (remoteplan-results rplan) (nconc1 (remoteplan-results rplan) arg))))

(defun remoteplan-add-input (rplan arg)
  (setf (remoteplan-inputs rplan)
	(nconc1 (remoteplan-inputs rplan) arg)))

(defun remoteplan-add-type (rplan tpo)
  "Adds a type to the types that the selection is done from, i.e. the type will
   appear in the from... clause of the remote query."
  (setf (remoteplan-types rplan) (nconc1 (remoteplan-types rplan) tpo)))

(defun remoteplan-add-where-predicate (rplan pred)
  (let ((preds (remoteplan-wherepreds rplan)))
    (cond ((eq preds nil)
	   (setf (remoteplan-wherepreds rplan) pred))
	  ((neq (first preds) 'and)
	   (setf (remoteplan-wherepreds rplan) (list 'and pred preds)))
	  (t
	   (nconc1 (remoteplan-wherepreds rplan) pred)))))

(defun remoteplan-compile-subquery-request (rplan) 
  "Asks the remote amos to compile a subquery contained in the remoteplan and
   returns an opaque_proxy that can later be invoked via apply_remote 
   (see amos_functions.lsp). The function is compiled via a call to 
   createfunction so it will be locally optimized."
  (let* ((ds        (remoteplan-datasource rplan))
	 (peer      (oid-name ds))
	 (env       (remoteplan-environment rplan))
	 (results   (remoteplan-results rplan))
	 (inputs    (remoteplan-inputs rplan))
	 (typedresults (remoteplan-deproxify-parameters results env))
	 (typedinputs  (remoteplan-deproxify-parameters inputs env))
	 (selection (remoteplan-make-select-list results env))
	 (from  (remoteplan-deproxify-parameters (remoteplan-types rplan) env))
	 (where     (remoteplan-wherepreds rplan))
	 remoteform
	 remotefnproxy
	 remote-selectbody
	 remotefnoidno)
    (setq remoteform `(remoteplan-compile-subquery-response 
		    , (kwote typedinputs)
		    , (kwote typedresults)
		    , (kwote selection)
		    , (kwote from)
		    , (kwote where)))
    (if remoteplan-printing
	(progn (print-remoteplan rplan) (ppe env) (ppremform remoteform)))
    (setq remotefnproxy (remote-eval remoteform peer))
    (setq remotefnoidno (getobject remotefnproxy 'xoidno))
    (setq remote-selectbody 
	  (remote-eval `(getselectbody(getobjectnumbered , remotefnoidno))peer))
    (/putobject remotefnproxy 'remote-selectbody remote-selectbody)
    remotefnproxy))

(defun remoteplan-make-subquery-compilation-form (rplan)
  (let* ((env       (remoteplan-environment rplan))
	 (results   (remoteplan-results rplan))
	 (inputs    (remoteplan-inputs rplan))
	 (typedresults (remoteplan-deproxify-parameters results env))
	 (typedinputs  (remoteplan-deproxify-parameters inputs env))
	 (selection (remoteplan-make-select-list results env))
	 (from  (remoteplan-deproxify-parameters (remoteplan-types rplan) env))
	 (where     (remoteplan-wherepreds rplan)))
    `( , (kwote typedinputs)
       , (kwote typedresults)
       , (kwote selection)
       , (kwote from)
       , (kwote where))))

;private functions
(defun remoteplan-deproxify-parameters (params env)
  "For a list of parameters, returns for each variable a list:
  (<rtype>, <param>), where rtype is the name of the remote type if it is an
  opaque_proxy, otherwise the name of the type. In the latter case it is 
  assumed that the type is present in both the local and remote node."
  (mapcar (f/l (arg) (list (get-orgtypename arg env) arg)) params))

(defun remoteplan-make-select-list (args env)
  "Makes a select clause as an s-expression from a list of variables by
   considering their entities in the environment.
   (remoteplan-make-selection '(v1 v2 1)) -> (v1 (name v1) 1)
   if the variables map to the following entities: 
   { v1->person, v2->name(v1), v3->1 }"
  (mapcar (f/l (arg)
	    (let ((ent (get-entity arg env)))
	      (cond ((amosentity-p ent)
		     (selectq (amosentity-type ent)
		       (type arg)
		       (function (amosentity-mapping ent)) args)) 
		    (t ent))))
	  args))

(defun remoteplan-compile-subquery-response (argtypes restypes resv quant pred)
  "Executed on the 'server', or remote node node where the mapped types are 
   stored as real types."
  (let ((fno
	 (createfunction '*transient* argtypes restypes resv quant pred nil)))
    fno))

(defun ppremform (remform)
  (formatl t "'(" (car remform) "  args  :" (second remform)
	   "  res   :" (third  remform) "  select:" (fourth remform)
	   "  from  :" (fifth  remform) "  where :" (sixth  remform) ")" t))
