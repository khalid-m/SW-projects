;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1993 Tore Risch, Staffan Flodin, EDSLAB
;;; $RCSfile: recompile.lsp,v $
;;; $Revision: 1.20 $ $Date: 2013/03/02 13:17:52 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Incrementail recompilation of Amos II functions
;;; =============================================================
;;; $Log: recompile.lsp,v $
;;; Revision 1.20  2013/03/02 13:17:52  torer
;;; Removed annoying redefinition warning
;;;
;;; Revision 1.19  2011/12/22 15:48:10  torer
;;; Mior core reorganization
;;;
;;; Revision 1.18  2011/12/22 12:55:17  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.17  2011/02/13 15:50:28  torer
;;; loop and while allowed as procedure body
;;;
;;; Revision 1.16  2009/12/12 11:14:34  torer
;;; Better SET-BAGGED
;;;
;;; Revision 1.15  2009/11/12 20:18:36  torer
;;; Improved cost caching
;;;
;;; Revision 1.14  2009/11/02 07:58:03  torer
;;; Incremental recompilation of derived functions with transient subplans now works
;;;
;;; Revision 1.13  2009/10/03 11:13:52  torer
;;; Function to test if bagged result (HAS-BAGGED-RESULT FNO)
;;;
;;; Revision 1.12  2007/10/16 17:28:58  torer
;;; Message printed when function recompiled
;;;
;;; Revision 1.11  2007/01/07 01:31:55  torer
;;; Bug in coerced function result
;;;
;;; Revision 1.10  2006/11/04 17:46:14  torer
;;; Removed calls (GETOBJECT x 'ARGTYPES)
;;;
;;; Revision 1.9  2006/11/04 16:18:21  torer
;;; Systematically using GET-RESOLVENT-ARGTYPES and GET-RESOLVENT-RESTYPES
;;;
;;; Revision 1.8  2006/04/27 19:18:27  torer
;;; Removed unused functions
;;;
;;; Revision 1.7  2006/04/15 18:48:23  torer
;;; Possibility to specify 'key' on multidirectional implementation
;;;
;;; Revision 1.6  2006/04/08 14:19:40  torer
;;; (GET-OC FNO) always used as accessor function for OID property ORGCODE
;;;
;;; Revision 1.5  2006/04/07 07:25:37  torer
;;; Derived multi-directional definitions supported
;;;
;;; Revision 1.4  2006/03/23 20:28:21  torer
;;; Error trapping added for generic-function-of
;;;
;;; Revision 1.3  2006/03/22 06:47:22  torer
;;; Caching the bag of result type of a function result type on function object
;;;
;;; =============================================================

(defvar *delayrecompile* nil) ;; Will delay recompilation if true

(defun recompilation? (newresolvent allresolvents) 
  "Siblings to recompile iff NEWRESOLVENT changed"
  (do ((newtype (car (get-resolvent-argtypes newresolvent)) newtype) ;type of new
       (resolvents allresolvents (cdr resolvents)) ;list of resolvents, decr
       (superfns (if (subtype-of (car (get-resolvent-argtypes newresolvent)) 
				 (car (get-resolvent-argtypes 
				       (car allresolvents))))
                     (list (car allresolvents)) nil)
		 (if (subtype-of newtype
				 (car (get-resolvent-argtypes
				       (car resolvents))))
		     (cons (car resolvents) superfns) 
		   superfns)))
      ((null (cdr resolvents)) superfns))) ;return all super resolvents

(defun insert-pred (b a) 
  "Is A to be compiled before B?"
  (let ((predfn (get-relation b)))
    (if (null predfn) t 
      (member a (getobject predfn 'usedbyfunction)))))

(defun filter-out (bad-ones candidates) ;remove bad-ones in candidates
  "Remove the resolvents from the list of 
   functions to be recompiled"
  (if (not (null candidates))
      (do ((cands candidates (cdr cands)) ;generics and stored fn out
           (res (if (or (memqual (car candidates) bad-ones)
                        (not (memqual (car candidates) 
				      (resolvents (car candidates))))
                        (object-typep (car candidates) _relation_)) nil 
		  (list (car candidates)))
		(if (or (memqual (car cands) bad-ones) 
			(not (memqual (car cands)
				      (resolvents (car cands))))
			(object-typep (car cands) _relation_)) res 
		  (append res (list (car cands))))))
          ((null (cdr cands)) (csort res (function insert-pred)))) nil))

(defun trans-clousure (initials &optional Iproperty)
  (let ((property (if Iproperty Iproperty 'usedbyfunction)))
    (if (not (null initials))		;retrieves the trans closr acc to 
	(do ((elems initials (cdr elems)) ;to the usedbyfunction relation
	     (elem (car initials) (car elems))
	     (clousure 
	      (if (memqual (car initials) 
			   (resolvents (car initials)))
		  (let ((addition 
			 (filter-out initials 
				     (getobject (car initials) property))))
		    (if (not (null addition)) 
			(append initials addition) initials)) initials)
	      (if (memqual elem (resolvents elem))
		  (let ((addition 
			 (filter-out clousure (getobject elem property))))
		    (if (not (null addition)) 
			(append clousure addition) clousure)) 
		clousure)))
	    ((or (null elems )(null (cdr elems))) clousure)))))

(defun get-functions-binding-late (specfn)
  (let* ((genfn (generic-function-of specfn))
	 ;;retrieve generic
	 ;;get the functions using the generic other than the resolvents. This
	 ;;is the set of functions that employ late binding on the fn
	 (ubf (set-difference (get-usbf genfn)(get-rsl genfn))))
    ubf))
	 
(defun get-pred-fn (tp resolvents)	;returns fns that neeeds recompilation
  (do ((resolvs resolvents (cdr resolvs)) ;iterate over all resolvents
       (preds (if (subtype-of tp (car (get-resolvent-argtypes
				       (car resolvents))))
                  (trans-clousure (getobject (car resolvents) 'usedbyfunction))
		nil)
	      (if (subtype-of tp (car (get-resolvent-argtypes (car resolvs))))
		  (append preds (trans-clousure (getobject (car resolvs) 
							   'usedbyfunction)))
		preds)))
      ((null (cdr resolvs)) 
       (let* ((fnsusingdtr (get-functions-binding-late (car resolvents)))
	      (preds1 (if (null fnsusingdtr) preds
			(if (null preds) fnsusingdtr 
			  (append fnsusingdtr preds)))))
	 (filter-out resolvents preds1)))))

(defun find-part (code keyw)
  (do ((rem code (cdr rem))
       (retval (if (eq (car code) keyw)
		   (cadr code) nil)
	       (if (eq (car rem) keyw) 
		   (cadr rem) retval)))
      ((or (null (cdr rem)) (not (null retval)))
       retval)))

(defun copy-selectbody (sb) (copy-array sb))

(defun recompile_depend (fnl)
  "Recompile functions depending on FNL somehow"
  (if *delayrecompile* nil
    (resetgenvar
     (let (fns-to-recompile)
       (dolist (fno (mklist fnl))
	 (setq fns-to-recompile 
	       (union fns-to-recompile
		      (let* ((gfno (generic-fnname fno))
			     (fns-to-recompile1      
			      (filter-out (list gfno)   
					  (trans-clousure 
					   (getobject fno 'usesobjects)
					   'usesobjects))))                
			(subset fns-to-recompile1 
				(f/l (f) (getobject f 'need_recomp))
				)))))
       (mapc (f/l (f) (recompile f)) fns-to-recompile)
       (dolist (fno (mklist fnl))
	 (recompile fno)       
	 (if (eq 'not_created (getobject fno 'late_b_exec_func))
	     (set_lb fno nil)))))))

(defun functions-to-recompile ()
  "Compute list of functions that currently needs to be recompiled"
  (let (res)
    (mapextent _function_
	       (f/l (fn)
		    (if (getobject fn 'need_recomp)
			(setq res (adjoin fn res)))))
    res))


(defun check-functions ()
  "Forces recompilation of all functions whose compilation was delayed."
  (let ((recompiled t)compiled)
    (while recompiled
      (setq recompiled nil)
      (dolist (fn (functions-to-recompile))
	(cond ((memq fn compiled)	; for circular function dependencies
	       (/putobject fn 'need_recomp nil)) ; don't compile again
	      (t (setq compiled (adjoin fn compiled))
		 (recompile fn)
		 (setq recompiled t))))) ; more functions might need 
					; recompilation after a recompilation
    compiled))

(defun recompile (fn) 
  "Incrementally recompiles a user function above the system watermark"
  (if (or (listp fn) (<= (oid-idno fn) _system-watermark_)) nil 
    (resetgenvar
     (let* ((orgcode (get-oc fn))	;fetch all necessary props from
	    (argtypes (car orgcode))	;the function object
	    (restypes (cadr orgcode))
	    (resv (find-part orgcode 'AS))
            (foreigndef (or (find-part orgcode 'FOREIGN)
                            (find-part orgcode 'MULTIDIRECTIONAL)))
	    (quant (find-part orgcode 'FOREACH))
	    (pred (find-part orgcode 'WHERE))
	    (proc (and (listp resv)
		       (procedure-body-p (car resv))
		       (car resv))))
       (putobject fn 'need_recomp nil) (bp 'recompile)
       (princ "Recompiling ") (amosql-print-oid fn)(terpri)
       (uncache-costs fn)
       (cond (proc (compile-procedure (oid-name(generic-function-of fn))
				      argtypes restypes resv t))
	     (t
              (cond ((eq (caar restypes) _bag_)
		     (setq restypes (third(car restypes)))
		     (set-bagged fn nil)))
	      (addresolvent fn fn argtypes restypes)
	      (createsimplefunction fn argtypes restypes resv (or foreigndef 
								  quant) pred)
	      fn))))))

(defun redefinefunction (gfno rfn argt rest resv quant pred bagres) 
  "Called by CREATEFUNCTION to recompile resolvent to be
    replaced by other resolvent
    GFNO is generic function, RFN is resolvent,
    ARGT is argument declarattions, REST is result declarations
    RESV is result tuple, QUANT is FROM declarations
    PRED is WHERE clause
    Notice RESV, QUANT and PRED are different for 
    foreign fns, stored fns, and procedures"
  (if (<= (oid-idno rfn) _system-watermark_)
      (amos-error "Cannot redefine system function " rfn))
  (resetgenvar
   (let* ((newname (make-resolventname-dcl (oid-name gfno) argt rest))
	  (relfno (get-relation rfn))
	  (noc1 (list argt (if bagres (list2 _bag_ 'of rest) rest)))
	  ;;noc1 = new orgcode1
	  (noc2 (if (null resv) noc1 (append noc1 (list 'as resv))))
	  (noc3 (if (null quant) noc2 (append noc2 (if (foreigntag resv) 
						       (list quant) 
						     (list 'foreach quant)))))
	  (noc4 (if (null pred) noc3 (append noc3 (list 'where pred))))
	  fns-to-recompile
	  (usobj (mapfilter (f/l (x)(or (object-typep x _relation_)
					(object-typep x _function_)))
			    (getobject rfn 'usesobjects))))
     (cond ((equal noc4 (get-oc rfn)) rfn) 
	   ;; old and new def the same
	   (t  (princ "Redefining ") (amosql-print-oid rfn) (terpri)
	       (/putobject rfn 'argtypes (gettypes argt))
	       (/putobject rfn 'restypes (gettypes rest))
	       (/putobject rfn 'orgcode noc4)
	       (/putobject rfn 'usesobjects nil)
	       (/putobject rfn 'bindings nil)
	       (/putobject rfn 'bagtype nil)
	       (/putobject rfn 'bagged-result nil)
	       (/putobject rfn 'keygroups nil)
	       (/renameobject rfn newname)
	       (setq fns-to-recompile (recomp-dependent rfn))   
	       (mapc (f/l (x) 
			  (/putobject x 'usedbyfunction 
				      (set-difference 
				       (getobject x 'usedbyfunction)
				       (list relfno gfno rfn))))
		     usobj)
	       (/putobject rfn 'usedbyfunction 
			   (remove relfno (getobject rfn 'usedbyfunction)))
	       (cond (relfno  
		      (/putobject relfno 'usedbyfunction NIL)
		      (/putobject relfno 'usesobjects NIL)
		      (deleteobject relfno) nil))
	       (mapc (function recompile) (sort fns-to-recompile
						(function recomp-order))))))))
(defvar *been*)

(defun recomp-order (f1 f2) 
  "true if F1 must be recompiled before F2"
  (let ((*been* (list f1)))
    (not (recomp-order1 f1 f2))))

(defun recomp-order1 (f1 f2)
  (cond ((memq f2 *been*) nil)
        (t (setq *been* (adjoin f2 *been*))
	   (isome (usedbyfunction f2) 
		  (f/l (fn) (or (memq f1 (resolvents fn))
				(isome (resolvents fn)
				       (f/l (r)(recomp-order1 f1 r)))))))))
                                                            

(defun recomp-dependent (fno)
  "The set of functions that need recompilation when
    function FNO has changed (including FNO)"
  (let ((been (make-collection)))
    (recomp-dependent1 fno been)
    (collection-elements been)))
  
(defun recomp-dependent1 (f been)
  "Collects transitive closure of dependent functions"
  (cond ((collection-member f been) nil)
	(t (collection-add f been)
           (dolist (f1 (recomp-dependent-direct f))
	     (recomp-dependent1 f1 been)))))

(defun subst-transients (l prop)
   (mapcan (f/l (x)(if (transientp x)
                       (subst-transients (getobject x prop) prop)
                       (list x)))
           l))

(defun usedbyfunction (fno)(subst-transients (getobject fno 'usedbyfunction)
                                             'usedbyfunction))
 
(defun recomp-dependent-direct (fno)
  "Functions immediately above FNO that might need recompilation
    when FNO changes"
  (subset (union (recomp-dependent-siblings fno)
		 (usedbyfunction fno))
          (function recomp-functiontype)))

(defun recomp-functiontype (fno)
  "Function types that might need recompilation when FNO changes"
  (and (member (functiontype fno)
	       '("derived" "procedure" "foreign"))
       (not (early-bound fno))
       (not (typecontainer-p fno))))

(defun recomp-dependent-siblings (fno)
  "Computes the sibling resolvents of FNO that need 
    recompilation if FNO changes"
  (let* ((gfn (generic-function-of fno))
	 (siblings (resolvents gfn))
	 (argtypes (get-resolvent-argtypes fno))
	 (restypes (get-resolvent-restypes fno)))
    (subset siblings 
	    (f/l (x) 
		 (let ((rst (get-resolvent-restypes x)))
		   (and x (neq x fno)
			(and (or (equal rst restypes)
				 (subtype-of restypes rst t))
			     (subtype-of argtypes (get-resolvent-argtypes x) 
					 t))
			))))))
