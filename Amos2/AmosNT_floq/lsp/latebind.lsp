;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1998 Vanja Josifovski, EDSLAB
;;; $RCSfile: latebind.lsp,v $
;;; $Revision: 1.17 $ $Date: 2012/08/15 18:23:13 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Late binding by OR predicates: generation of the exec. funcs.
;;; =============================================================
;;; $Log: latebind.lsp,v $
;;; Revision 1.17  2012/08/15 18:23:13  torer
;;; New function
;;; (CREATE-TRANSIENT-FOREIGN-FUNCTION ARGTYPES RESTYPES DEF &OPTIONAL COST)
;;; to create transient foreign function which is garbage collected when
;;; no longer referenced
;;;
;;; Revision 1.16  2012/05/18 14:31:10  torer
;;; Errorneous warnings removed
;;;
;;; Revision 1.15  2009/09/04 15:41:39  torer
;;; Tougher unused variable test
;;;
;;; Revision 1.14  2008/08/13 09:01:49  torer
;;; Forgot to save file
;;;
;;; Revision 1.13  2008/08/13 07:58:07  torer
;;; Type STREAM separated from core Amos II
;;;
;;; Revision 1.12  2006/11/04 16:18:20  torer
;;; Systematically using GET-RESOLVENT-ARGTYPES and GET-RESOLVENT-RESTYPES
;;;
;;; =============================================================

(defglobal _shallow_extentS_)

(defun chain_set_lb (fno)     
  (mark_for_recompile fno)
  (mapc (f/l (rs) (set_lb rs t)) 
	(recomp-dependent-siblings fno)))

(defun mark_for_recompile (fno)
  "Mark all functions dependent on FNO for recompilation"
  (let ((fntoMark (recomp-dependent fno)))
    (mapc (f/l (f) (and (neq f fno)
			(putobject f 'need_recomp t))) fnToMark)))

(defun needs-recomp? (fn)
  "Does function FN or function in list FN need recompilation?"
  (cond ((oid-p fn)(getobject fn 'need_recomp))
	((listp fn)(some (function needs-recomp?) fn))
	(t (error "Illegal argument" fn))))

(defun set_lb (fno detectOnlyFlag)
  "Entry function. Generates/regenerates the late binding execution 
   function for a given function.
   If detectOnlyFlag is T than only detects if a (re)compilation is needed"
  (if (not (early-bound (generic-function-of fno)))
      (let* ((argtypes (get-resolvent-argtypes fno))
	     (restypes (get-resolvent-restypes fno))
	     (gfno (generic-function-of fno))
	     (rl (mapfilter (f/l (f) 
				 (let ((rst (getobject f 'restypes)))
				   (or (equal rst restypes)
				       (subtype-of rst restypes t))))
			    (generate-resolvent-list gfno argtypes)))
	     (lbfoid1 (getobject  fno  'late_b_exec_func))
	     (lbfoid  (if (eq lbfoid1 'not_created) nil lbfoid1)))
					;(bp sb_lb)
	(if (> (length rl) 1)
	    (cond (detectOnlyFlag
		   (if lbfoid
		       (putobject lbfoid 'need_recomp t)
		     (putobject fno 'late_b_exec_func 'not_created)))
		  (t
		   (debug_do
		    (if lbfoid (formatl t "Regenerating ")
		      (formatl t "Generating  "))
		    (formatl t " the late binding exec func. for " fno t))
		   (let* ((srl (sort-resolvent-list rl))
			  (dep_fn_recomp 
			   (mapfilter (f/l (f) (getobject f 'need_recomp)) 
				      srl))
			  ntfunc)
					;(addfunctionsusing fno ntfunc)
		     (mapc (function recompile_depend) dep_fn_recomp)
		     (setq ntfunc (gen_lb_exec_func srl argtypes lbfoid))
		     (addfunctionsusing ntfunc fno)
		     (putobject fno 'need_recomp nil)
		     (putobject fno 'late_b_exec_func ntfunc))))))))

(defun gen_lb_exec_func (fnl MGargTypes &optional recomp_foid)
  "generates the lateb. function. Takes a list of resolvents and the
   most general type of the arguments. optional is an oid for recompilation"
  (if (some (f/l (tp) (and (dt_p tp) (not (i_type? tp)))) MGargTypes)
      (car fnl);;This is not implemented yet: a general lb mechanism
    ;;for DTs which are not integration types
    (resetgenvar 
     (let* ((ftList (mapcar (f/l (resFn) 
				 (cons resFn (get-resolvent-argtypes resFn)))
			    fnl))
	    ;;not overl. on result
	    (restypes     (get-resolvent-restypes (car fnl)))
	    *bindings* *locals*
	    (resl      (mapcar (function dt_genvar) restypes))
	    (restuple (maketuple resl))
	    (fno (if recomp_foid recomp_foid (createfunction1 '*transient*)))
	    (*CURRENT-COMPILE-FN* (cons fno *CURRENT-COMPILE-FN*))
	    (arg (mapcar (function dt_genvar) MGargTypes))
	    (tList    (mapcar (function cdr) ftList))
	    (ttList   (transpose tList))
	    (uttList  (mapcar (function unique) ttList))
	    (suttList (mapcar (f/l (tl) (nreverse 
					 (csort tl (function subtype-of))))
			      uttList))
	    (estrL   (mapcar (f/l (s a) (gen-tpc-code-list s a fno)) 
			     suttList arg))
					;(dummy (bp here))
	    (fpred (let ((*no_lb* t))
		     (flattenpredicate 
		       (gen-lb-pred ftList estrL arg nil restuple fno))))
	    (sb (/putobject fno 'selectbody 
			    (make-selectbody :argl arg 
					     :resl (mklist resl)))))
       (compile_phase2 (car fpred) resl arg nil nil fno sb)
       (/putobject fno 'restypes restypes)
       (/putobject fno 'argtypes MGargTypes)
       (/putobject fno 'resolvents (list fno))
       fno))))

(defun gen-lb-pred (fList estrL arg types_in restuple fno)
  (cond 
   ;;one function left (that must be the highest), so do that
   ((eq 1 (length fList))
    ;;(append '(FLATTENED) (cons (caar Flist) arg) restuple))
    (if restuple 
	(list 'FLATTENED _=_ restuple (cons (caar Flist) arg))
      (cons 'FLATTENED (cons (caar Flist) arg)))) ;boolean func.
   ;;no more arguments
   ((not estrL)
    (if (some (f/l (fn) (not (subtype-of (get-resolvent-argtypes (caar fList))
					 (get-resolvent-argtypes (car fn)) T)))
	      (cdr fList))
	(amos-error "Cannot find non-ambigous resolvent among: " 
		    (heads fList)
		    " for instances of type(s):" 
		    (nreverse (mapcar (f/l (tp) (getobject tp 'name)) 
				      types_in)))
      (if restuple 
	  (list 'FLATTENED _=_ restuple (cons (caar Flist) arg))
	(cons 'FLATTENED  (cons (caar Flist) arg))))) ;boolean func.
   ((not (cadar estrL))
    (gen-lb-pred (mapcar (f/l (fn_a) (cons (car fn_a) (cddr fn_a))) fList)
		 (cdr estrL)
		 arg
		 (cons (caar estrL) types_in)
		 restuple
		 fno))
   ;;reduce functions and arguments and generate some code
   (t
    (let (code)
      (dolist (rType_tcheck (car estrL))
	(let* ((rType (car rType_tcheck))
	       (tcheck (second rType_tcheck)) 
	       (new_fList (mapfilter 
			   (f/l (fn_a) 
				(or (eq (second fn_a) rType)
				    (subtype-of rType (second fn_a))))
			   fList
			   (f/l (fn_a) (cons (car fn_a) (cddr fn_a))))))
;	  (bp GGGG)
	  (setq code 
		(cons 
		 (andify 
		  (list tcheck 
			(gen-lb-pred new_Flist (cdr estrL) 
				     arg 
				     (cons rType types_in)
				     restuple
				     fno)))
		 code))))
      (orify code)))))
	      
(defun gen-tpc-code-list (stpl var fno)
  (if (not (cdr stpl)) 
      (list (car stpl) nil)
    (mapcar (f/l (tp) (list tp (gen-tpc-code tp stpl var fno)))
	    stpl)))

(defun gen-tpc-code (tp stplH var fno)
  (let* ((allsubtps1 
	  (cons tp (csort (getallsubtypes tp) (function supertype-of))))
	 (stpl (remove tp stplH))
	 (loc_ndt (mapfilter 
		   (f/l (tp1) (not 
			       (or (proxytype? tp1) 
				   (dt_p tp1)
				   (some (f/l (restp) (subtype-of tp1 restp T))
					 stpl))))
		   allsubtps1))
	 (llen (length loc_ndt))
	 (allsubtps (if (> llen 1) 
			(set-difference allsubtps1 loc_ndt) 
		      allsubtps1))
	 (code (if (> llen 1) (list (gen-tpchk loc_ndt var t))))) 
    (while allsubtps
      (let* ((iterTp (car allsubtps))
	     (itersubtps (getallsubtypes iterTp))
	     (commonsubtps (intersection  stpl itersubtps)))
					;(bp whloop)
	(setq allsubtps
	      (if (or (and (memq iterTp stpl) (not (eq tp iterTp))) 
		      (not commonsubtps))
		  (set-difference (cdr allsubtps) itersubtps)
		(cdr allsubtps)))
	(if (not (memq iterTp stpl))
	    (setq code (cons (gen-tpchk iterTp var commonsubtps) code)))))
    (orify code)))

(defun gen-tpchk (type var shallowFlag)
  (let* ((prefix (if shallowFlag 'shallow_extent 'typesof))
	 extf
	 (extent_pred 
	  (cond ((listp type)
		 (list '= var (list 'FLATTENED _shallow_extentS_ 
				    (listtoarray (reduce_type_list type)))))
		;;This still does not work, until shallow_extent_DTNAME func 
		;;are not declared
		(shallowFlag
		 ;;(and shallowFlag (ut_p type) (not (proxyType? type)))
		 (list '= var (list 'in (list 'shallow_extent type))))
		((setq extf (get-extent-function type))
		 (list '= var (list 'in (list extf))))
		(t (list '= type (list 'in (list 'typesof var)))))))
    extent_pred))

(defun reduce_type_list (tl)
  (if tl
      (let* ((ft (car tl))
	     (ftast (getallsubtypes ft))
	     (lenast (length ftast))
	     (commonast (intersection ftast tl))
	     (lenCast (length commonast)))
;	(bp dddd)
	(if (eq lenCast lenast)
	    (cons (cons ft T) (reduce_type_list 
			       (set-difference (cdr tl) ftast)))
	  (cons (cons ft nil) (reduce_type_list (cdr tl)))))))

(defun latebound? (fno)
  (getobject fno 'late_b_exec_func))

(defun get_lbex_func (fno)
  "Create late binding resolution function if needed"
  (if (eq 'not_created (getobject fno 'late_b_exec_func))
      (set_lb fno nil))
  (getobject fno 'late_b_exec_func))
 
(defun supertype-of (tp1 tp2)
  (memq tp1 (getobject tp2 'allsupertypes)))

(defun transpose (mtrx)
  (if (and mtrx (listp mtrx) (car mtrx))
      (let ((nrow (heads mtrx))
	    (nrest (mapcar (function cdr) mtrx)))
	(cons nrow (transpose nrest)))))
