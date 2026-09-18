;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: amos_translator.lsp,v $
;;; $Revision: 1.3 $ $Date: 2003/10/27 13:21:37 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: The translator for the data source Amos.
;;;              
;;; ===========================================================================
(defun amos-initialize (ds env)
  (make-remoteplan :datasource ds :environment env))

(defun amos-translate-type-core-cluster (ds cc-call env rplan)
  "Seeing the type core-cluster indicates that its remote type is being
   - instantiated (if the variable is free)
   - type-checked (if the variable is bound)"
  (let* ((fno (predicate-operator cc-call)) 
	 (arg (first (predicate-arguments cc-call)))
	 (type(first (get-resolvent-restypes fno)))
	 (remotetypename (getobject fno 'typename)))
    (cond ((bound arg env)
	   (remoteplan-add-input rplan arg)
	   (set-entity arg env (make-amosentity-type remotetypename)))
	  (t
	   (let ((amosent (make-amosentity-type remotetypename)))
	     (bind arg env :datasource ds :type type 
		   :orgtype remotetypename :entity amosent)
	     (remoteplan-add-result rplan arg)
	     (remoteplan-add-type rplan arg))))
    t))

(defun amos-translate-function-core-cluster (ds cc-call env rplan)
  (selectq (apply #'pack (bpat cc-call env))
    (++ (amos-translate-function-core-cluster-ff ds cc-call env rplan))
    (+- (amos-translate-function-core-cluster-fb ds cc-call env rplan))
    (-+ (amos-translate-function-core-cluster-bf ds cc-call env rplan))
    (-- (amos-translate-function-core-cluster-bb ds cc-call env rplan))
    (error "can't translate")))

(defun amos-translate-function-core-cluster-ff (ds cc-call env rplan)
  (let* ((fno  (predicate-operator cc-call))
	 (rfni (getobject fno 'remotefninfo))
	 (genname (remotefninfo-genname rfni))
	 (rtps (remotefninfo-typesignature rfni))
	 (tps  (get-resolvent-restypes fno))
	 (x    (predicate-argument 1 cc-call))
	 (y    (predicate-argument 2 cc-call))
	 (xrtp (first  rtps))
	 (yrtp (second rtps))
	 (xtp  (first tps))
	 (ytp  (second tps))
	 (xent (make-amosentity-type xrtp))
	 yent)
    (if (not (anonymous-varsymbolp x))
	(remoteplan-add-result rplan x)
      (putvar (setq x (genvar)) env))
    (setq yent (make-amosentity-function (list genname x)))
    (bind x env :datasource ds :type xtp :orgtype xrtp :entity xent)
    (bind y env :datasource ds :type ytp :orgtype yrtp :entity yent)
    (remoteplan-add-result rplan y)
    (remoteplan-add-type   rplan x))
  t)

(defun amos-translate-function-core-cluster-fb (ds cc-call env rplan)
  (let* ((fno  (predicate-operator cc-call))
	 (rfni (getobject fno 'remotefninfo))
	 (genname (remotefninfo-genname rfni))
	 (rtps (remotefninfo-typesignature rfni))
	 (tps  (get-resolvent-restypes fno))
	 (x    (predicate-argument 1 cc-call))
	 (y    (predicate-argument 2 cc-call))
	 (xrtp (first  rtps))
	 (yrtp (second rtps))
	 (xtp  (first tps))
	 (ytp  (second tps))
	 (xent (make-amosentity-type xrtp)))
    (if (not (anonymous-varsymbolp x))
	(remoteplan-add-result rplan x)
      (putvar (setq x (genvar)) env))
    (if (neq (datasource y env) ds)
	(progn (set-orgtypename y env yrtp) (remoteplan-add-input rplan y)))
    (bind x env :datasource ds :type xtp :orgtype xrtp :entity xent)
    (bind y env :datasource ds :type ytp :orgtype yrtp)
    (remoteplan-add-type   rplan x)
    (remoteplan-add-where-predicate rplan `(= (, genname , x) , y)))
  t)

(defun amos-translate-function-core-cluster-bf (ds cc-call env rplan)
  (let* ((fno  (predicate-operator cc-call))
	 (rfni (getobject fno 'remotefninfo))
	 (genname (remotefninfo-genname rfni))
	 (rtps (remotefninfo-typesignature rfni))
	 (tps  (get-resolvent-restypes fno))
	 (x    (predicate-argument 1 cc-call))
	 (y    (predicate-argument 2 cc-call))
	 (xrtp (first  rtps))
	 (yrtp (second rtps))
	 (xtp  (first tps))
	 (ytp  (second tps))
	 (yent (make-amosentity-function (list genname x)))
	 )
    (if (neq (datasource x env) ds)
	(progn ;is this ok? might have an orgtypename already...
	  (set-orgtypename x env xrtp)
	  (remoteplan-add-input rplan x)))
    (bind y env :datasource ds :type ytp :orgtype yrtp :entity yent)
    (remoteplan-add-result rplan y))
  t)

(defun amos-translate-function-core-cluster-bb (ds cc-call env rplan)
  (let* ((fno     (predicate-operator cc-call))
	 (x       (predicate-argument 1 cc-call))
	 (y       (predicate-argument 2 cc-call))
	 (tps     (get-resolvent-restypes fno))
	 (rfni    (getobject fno 'remotefninfo))
	 (rtps (remotefninfo-typesignature rfni))
	 (xrtp (first  rtps))
	 (yrtp (second rtps))
	 (xtp  (first tps))
	 (ytp  (second tps))
	 (genname (remotefninfo-genname rfni)))
    (if (neq (datasource x env) ds)
	(progn ;is this ok? might have an orgtypename already...
	  (set-orgtypename x env xrtp)
	  (remoteplan-add-input rplan x)))
    (if (neq (datasource y env) ds)
	(progn ;is this ok? might have an orgtypename already...
	  (set-orgtypename y env yrtp)
	  (remoteplan-add-input rplan y)))
    (remoteplan-add-where-predicate rplan `(= , y (, genname , x)))
    t))

(defun amos-finalize (ds env rplan)
  "Invokes remote compilation of the subquery contained in the remoteplan rplan
   and substitutes all absorbed predicates withh a call to the higher-order 
   function apply_remote which request the execution of the subquery on the 
   Amos node ds."
  (let ((fnproxy (remoteplan-compile-subquery-request rplan))
	(args (remoteplan-inputs  rplan))
	(res  (remoteplan-results rplan)))
    `((, _apply_remote_ , ds , fnproxy ,@ args ,@ res))))