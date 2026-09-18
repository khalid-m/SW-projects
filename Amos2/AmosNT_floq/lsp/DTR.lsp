;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1993 Magnus Werner, Staffan Larsson, Tore Risch EDSLAB
;;; $RCSfile: DTR.lsp,v $
;;; $Revision: 1.9 $ $Date: 2009/04/11 15:47:34 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: DTR implementation
;;; =============================================================
;;; $Log: DTR.lsp,v $
;;; Revision 1.9  2009/04/11 15:47:34  torer
;;; More use of general APPLY
;;;
;;; Revision 1.8  2009/04/11 12:26:07  torer
;;; Use of CommonLisp's generalized APPLY simplifies dynamic calls to OSQL-RESULT
;;;
;;; Revision 1.7  2008/08/13 07:58:07  torer
;;; Type STREAM separated from core Amos II
;;;
;;; Revision 1.6  2007/11/05 16:48:14  torer
;;; Using REMOVE-TRUE-RESULT
;;;
;;; Revision 1.5  2007/11/04 20:32:08  torer
;;; Mismatch in boolean result tuples in DTR call
;;;
;;; Revision 1.4  2006/04/22 06:39:45  torer
;;; *** empty log message ***
;;;
;;; Revision 1.3  2006/04/12 19:17:44  torer
;;; Cost profile of predicate now always on format (COST FANOUT [pred])
;;;
;;; =============================================================

(defglobal *dtrdummyfndtr*)

;;----------------------------------------------------------------------------
;;
;; Creation of dtr foregn predicate
;; - denotes unbound, + denotes bound parameter
;; 
;;---------------------------------------------------------------------------

(defun extract (start end lst)
  "extracts sublist with elements at position start to end from lst
   function is called as (extract startno endno itemlist)"
  (cond ((null lst) nil)
	((< 1 start)(extract (- start 1)(- end 1)(cdr lst)))
	((>= end 1)(cons (car lst) (extract (- start 1)(- end 1)(cdr lst))))))

(defun extractelem (no l) (nth (1- no) l))

(defun extractelems (nol l) (mapcar (f/l (no) (extractelem no l)) nol))

(defun gen-dir-list-of-resolvents (direction bpat resolvs)
  (if (eq direction 'backwards) 
      (mapcar (f/l (x) (tbr-selbody (getbpatfn x bpat))) resolvs) resolvs))

(defun dtrinverse-filtering (tp1 lot)
  (let* ((tp (if (listp lot) (extract 1 (length (car lot)) tp1) tp1)))
    (mapfilter (f/l (x) (or (equal tp x) (subtype-of tp x))) lot)))

(defun dtr+-exec (invar utvar resolvs resol bpat currfn types)
  (mapfunction currfn invar 
	       (function (lambda (x) 
			   (if (not (dtrinverse-filtering 
				     (mapcar (f/l (o)(arg-type o)) 
					     x) 
				     types))               
			       (build-emit-expr resolvs invar x bpat))))))

(defun getunboundpos (bpat no res)
  (cond ((null bpat) (reverse res))
	((eq (car bpat) '+) (getunboundpos (cdr bpat) (+ 1 no) (cons no res)))
	(t (getunboundpos (cdr bpat) (+ 1 no) res))))

(defun dtr-+- (obj resolvs resol invars utvar bpat)
  "selectbodys is a list of selectbodys for backward exec. The selectbody of 
   the resolvent is copied and the selectbody for backward exec is replacing
   the original in the function. After execution the original selectbody is
   restored. The original is copied into tempselbody"
  (let* ((idi *dtrdummyfndtr*)
	 (selectbodys (gen-dir-list-of-resolvents 'backwards bpat resol)))
    (do* ((ress resol (cdr ress))
	  (currfn1 (car ress)(car ress))
	  (noofargs (getarity currfn1) noofargs)
	  (parambpat (extract 1 noofargs bpat) parambpat)
	  (unbpos (getunboundpos parambpat 1 nil) unbpos)
	  (selbodys selectbodys (cdr selbodys))
	  (types nil (cons (extractelems unbpos 
					 (get-resolvent-argtypes currfn)) 
			   types))
	  (currfn (car ress)(car ress))
	  (currselb (car selbodys)(car selbodys))
	  (cpselbody (putobject *dtrdummyfndtr* 'selectbody currselb)
		     (putobject *dtrdummyfndtr*  'selectbody currselb))
	  (exec (dtr+-exec invars utvar 
			   resolvs resol bpat *dtrdummyfndtr* types)
		(dtr+-exec invars utvar 
			   resolvs resol bpat *dtrdummyfndtr* types)))
	((null (cdr ress)) t))))

(defun applicable_arg? (actargtype formargtype)
  (or (equal actargtype formargtype)
      (subtype-of actargtype formargtype)))

(defun applicable? (resolvent argl) 
  ;; All that is normally needed (c.f. applicable*? below!
  (do* ((resargs (get-resolvent-argtypes resolvent) (cdr resargs))
	(actarg argl (cdr actarg))
	(typeofactarg (arg-type (car actarg))(arg-type (car actarg)))
	(appl? (applicable_arg? typeofactarg (car resargs))
	       (applicable_arg? typeofactarg (car resargs))))
      ((or (null (cdr resargs))(null (cdr actarg)) (not appl?)) appl?)))

(defun applicable*? (resolvent argl) 
  ;; Staffan's original needed for DTR. Needs to be cleaned up.
  (do* ((appl? t appl?)
	(resargs (append (get-resolvent-argtypes resolvent)
			 (get-resolvent-restypes resolvent)) (cdr resargs))
	(actarg argl (cdr actarg))
	(typeofactarg (if (eq (car actarg) '*) NIL 
			(arg-type (car actarg)))
		      (if (eq (car actarg) '*) NIL
			(arg-type (car actarg))))
	(idi (if (eq (car actarg) '*) NIL
	       (if (and (not (equal typeofactarg (car resargs)))
			(not (subtype-of typeofactarg (car resargs)))) 
		   (setq appl? NIL) 
		 NIL));; If the actual arg is a supertype to the declared
	     ;; then the resolvent is inapplicable
	     (if (eq (car actarg) '*) NIL
	       (if  (and (not (equal typeofactarg (car resargs)))
			 (not (subtype-of typeofactarg (car resargs))))
		   (setq appl? NIL) 
                 NIL))))
      ((or (null (cdr resargs))(null (cdr actarg)) (not appl?)) appl?)))

(defun match-args-to-resolvents (args resolvents)
  (do* ((resolvs resolvents (cdr resolvs))
	(resolvent (car resolvs) (car resolvs))
	(appl? (applicable*? resolvent args)(applicable*? resolvent args))
	(result (if appl? (list resolvent) NIL)
		(if appl? (append result (list resolvent)) result)))
      ((null (cdr resolvs)) result)))

(defun build-emit-expr (resolvs invars outvars bpat)
  (apply 
   'osql-result
   resolvs
   (let ((boundno 1)(unbno 1))
     (mapcar (f/l (x) 
		  (if (eq? x '-)
		      (prog1 (extractelem boundno invars)(1++ boundno))
		    (prog1 (extractelem unbno outvars) (1++ unbno))))
	     bpat))))

(defun dtr--+ (obj resolvs &Rest vars)
  "Executes late bound function calls in forward or backward direction"
  (let* ((resol (match-args-to-resolvents vars resolvs))
					; Applicable resolvents
	 (sb (getobject (car resol) 'selectbody))
					; The selectbody to use
	 (bpat (mapcar (f/l (x) (if (eq? x '*) '+ '-)) vars))
					; binding pattern for resolvent
	 (incard (length (selectbody-argl sb)))
					; arity of resolvent
	 (outcard (length (selectbody-resl sb)))
					; width of resolvent
	 (invars1 (extract 0 incard vars))
					; arguments of resolvent
	 (utvar1 (extract (+ 1 incard) (+ incard outcard) vars))
					; result tuple of resolvent
	 (invar (mapcan (f/l (iv bp) 
			     (if (eq? bp '-) (list iv) nil)) 
			(append invars1 utvar1) bpat))
					; bound arguments of resolvent
	 (isForward (subsetp invars1 invar)))
    (if isForward
	(mapfunction 
	 (car resol) invars1		;forward call
	 (f/l (x)
	      (apply 'osql-result 
		     resolvs 
		     (append invars1 (remove-true-result x)))))
      (let ((utvar (mapcan (f/l (iv bp) 
				(if (eq? bp '+) (list iv) nil)) 
			   (append invars1 utvar1) bpat))) ; bound results
	(dtr-+- obj resolvs resol invar utvar bpat))))) ;backward execution

(defun most-spec-resolvnt (reslist)
  "From a list of resolvents the most specific resolvent is extracted. The
   resolvent is in a tree without branches otherwise there would be conflict
   in which branch to descend through the tree"
  (do* ((resolvents reslist (cdr resolvents))
        (resolvent (car resolvents) (car resolvents))
        (type-of-resolvent (get-resolvent-argtypes resolvent))
        (m-s-r resolvent (if (subtype-of type-of-resolvent type-of-m-s-r)
                             resolvent m-s-r))
        (type-of-m-s-r (get-resolvent-argtypes m-s-r)))
      ((null (cdr resolvents)) m-s-r)))
  
;;----------------------------------------------------------------------------
;;
;;        Optimizer changes to handle dtr predicates
;;
;;----------------------------------------------------------------------------
;;

;; Definition of some DTR primitives

(defun first-function-in-dtr (pred)
  (car (cadr pred)))

(defun dtrpred-in-dtr (pred) (car pred))

(defun fnlist-in-dtr (pred) (cadr pred))

(defun arglist-in-dtr (pred) (cddr pred))

(defun inarglist-in-dtr (pred)
  (let* ((fn (first-function-in-dtr pred))
	 (sb (getobject fn 'selectbody))
	 (argle (length (selectbody-argl sb)))
	 (args (arglist-in-dtr pred)))
    (extract 0 argle args)))

(defun outarglist-in-dtr (pred)
  (let* ((fn (first-function-in-dtr pred))
	 (sb (getobject fn 'selectbody))
	 (argle (length (selectbody-argl sb)))
	 (args (arglist-in-dtr pred)))
    (extract (+ 1 argle) (length args) args))) 

(defun first-function-in-dtr-with-args (pred)
  (cons (first-function-in-dtr pred) (append (inarglist-in-dtr pred) 
					     (outarglist-in-dtr pred))))

;; Firstly let dtr predicates be specially treated in bindadornpat. It is
;; not function.dtr that binds but rather an arbitrary function in its
;; argument list of functions. All functions binds same variables.

(defun dtr-bindadornpat (pred bound)
  (bindadornpat (first-function-in-dtr-with-args pred) bound))

(defun bindadornpat (pred bound)
  (if (dtr?
       (car pred))
      (dtr-bindadornpat pred bound)
    (argsbpat (cdr (getcalledpred pred)) bound)))

;; It is not the cost of function.dtr but the cost of the functions in its 
;; argument list.

(defun tcost (x) 
  (cond ((null x) nil)
        ((numberp x) x)
        (t (* (first x) (second x)))))

(defun cost_cmp (c_f1 c_f2)
  (let ((c1 (tcost c_f1))
	(c2 (tcost c_f2)))
    (> c1 c2)))
        
(defun dtr-simple-pred-cost (pred bpat)
  (catch-exec-error
   (let* ((forward (forward? (car pred) bpat))
	  (costsL
	   (if forward
	       (mapfilter 
		(f/l (x) x) 
		(fnlist-in-dtr pred)
		(f/l (x) (exec-cost-of-tbr x bpat)))
	     (mapfilter 
	      (f/l (x) x) 
	      (fnlist-in-dtr pred)
	      (f/l (x) (let ((c (exec-cost-of-tbr x bpat)))
			 (if (null c) (exec-cost-of-tbr x bpat) c))))))
	  (maxcost (if (memq nil costsL)
		       nil 
		     (car (sort costsL #'cost_cmp)))))
     (if maxcost 
	 (list (first maxcost) (second maxcost) pred)
       nil))))
