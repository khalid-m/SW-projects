;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Tore Risch, UDBL
;;; $RCSfile: subplan.lsp,v $
;;; $Revision: 1.18 $ $Date: 2010/11/14 09:57:31 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Plan partitioner
;;; =============================================================
;;; $Log: subplan.lsp,v $
;;; Revision 1.18  2010/11/14 09:57:31  msabesan
;;; *** empty log message ***
;;;
;;; Revision 1.17  2010/03/22 08:45:17  msabesan
;;; indpendent web service calls with differenet argument order is handled
;;;
;;; Revision 1.16  2010/02/05 17:47:24  msabesan
;;; minor change
;;;
;;; Revision 1.15  2008/10/20 06:33:46  msabesan
;;; *** empty log message ***
;;;
;;; Revision 1.14  2008/10/16 19:05:49  msabesan
;;; bugs fixed in the pass through variables
;;;
;;; Revision 1.13  2008/10/15 15:37:57  msabesan
;;; *** empty log message ***
;;;
;;; Revision 1.12  2008/10/14 16:43:55  msabesan
;;; *** empty log message ***
;;;
;;; Revision 1.11  2008/03/06 15:30:47  msabesan
;;; *** empty log message ***
;;;
;;; Revision 1.10  2008/01/22 18:10:38  msabesan
;;; *** empty log message ***
;;;
;;; Revision 1.9  2008/01/17 22:49:02  msabesan
;;; bug in peer allocation policy
;;;
;;; Revision 1.8  2008/01/16 17:37:42  msabesan
;;; peer selection policy placed
;;;
;;; Revision 1.7  2008/01/15 16:35:16  msabesan
;;; bugs fixed in the order of arguments
;;;
;;; Revision 1.6  2008/01/14 21:23:48  msabesan
;;; *** empty log message ***
;;;
;;; Revision 1.5  2008/01/14 17:46:08  msabesan
;;; *** empty log message ***
;;;
;;; Revision 1.4  2008/01/13 20:37:26  msabesan
;;; *** empty log message ***
;;;
;;; Revision 1.3  2008/01/11 17:39:24  msabesan
;;; *** empty log message ***
;;;
;;; Revision 1.2  2008/01/09 17:29:05  msabesan
;;; *** empty log message ***
;;;
;;; Revision 1.6  2008/01/09 08:22:15  msabesan
;;; "Consider pass through variables"
;;;
;;; Revision 1.5  2008/01/08 18:04:06  msabesan
;;; Exclude vref_bbf, cwo, vector.in in the argument list
;;;
;;; Revision 1.4  2007/12/18 16:25:09  torer
;;; Bugs when sending transients with constructor forms over sockets
;;;
;;; Revision 1.3  2007/12/18 11:36:24  torer
;;; Named subplans
;;;
;;; Revision 1.2  2007/12/18 07:36:58  torer
;;; Constructor forms on transient objects
;;;
;;; Revision 1.1  2007/10/18 12:22:54  torer
;;; Added code to split TBRs into transportable subplans
;;;
;;; =============================================================

(defglobal lookupl nil);; list of renamed variables
(defglobal addl nil);;list of new predicates need to added
(defglobal rnl nil)
(defglobal bgresl nil)
(defglobal _chkfn_  (theresolvent '=))
(defglobal _lastplan_ nil)

(defvar _planno_ 0)


(defun generate-plan-id ()
   "Generate transactionally unique identifier for plan functions"
   (/setglobal '_planno_ (1+ _planno_));; transactional to enable rollback
   (pack 'plan- _planno_))

(defun create-subplan (invars outvars pred)
  "Create an execution plan as a transient subfunction"
  (predicate-function invars outvars pred))

(quote(defun predicate-function (invars outvars tr)
  "Generate ObjectLog functioion for TR-predicate and in/out parameters"
  (createfunction (generate-plan-id)
		  (declare-as-objects invars)
		  (declare-as-objects outvars)
		  outvars 
		  (declare-as-objects 
		   (free-variables tr (union invars outvars)))
		  (cons 'flattened tr))))

(defun predicate-function (invars outvars tr)
  "Generate ObjectLog functioion for TR-predicate and in/out parameters"
  (let ((fno (createfunction '*transient*
		  (declare-as-objects invars)
		  (declare-as-objects outvars)
		  outvars 
		  (declare-as-objects 
		   (free-variables tr (union invars outvars)))
		  (cons 'flattened tr))))
   (set-object-constructor fno (get-orgcode fno t))
   fno))

(defun set-object-constructor (to form)
  "The value of FORM is the object representing transient object TO"
  (if (transientp to) (putobject to 'name form)
    (error "Not a transient object" to)))

(defun predicate-definition (fno)
  "Geneate the flattened ObjectLog function for FNO"
  (let ((sb (getselectbody fno)))
    (predicate-function (selectbody-argl sb)
                        (selectbody-resl sb)
                        (selectbody-pred sb))))

(quote (defun rename-arg (andl argl)
  "Renaming pass-through arguments 
and build additional predicates for pass-through"
  (setq addl nil)
  (setq rnl nil)
  (dolist (x andl)
    (let* ((temp  `( , _=_  , x , (mksymbol (concat '_  x  '_1)) )))
      (if argl (check-lookupl andl argl)
	(setq lookupl (adjoin (list x (mksymbol (concat '_ x '_1))) lookupl)))
      (setq rnl (adjoin (mksymbol (concat '_ x '_1)) rnl))
      (setq addl (adjoin temp addl))))
  (setq rnl (reverse rnl))))

(defun edit-lookupl (y)
  "adding new values to lookup list"
  (setq rnl (adjoin (mksymbol (concat '_ y '_1)) rnl))
  (setq addl (adjoin `( , _=_  , y , (mksymbol (concat '_  y  '_1)))  addl)))

(defun rename-arg (andl secflg)
  "Renaming pass-through arguments 
and build additional predicates for pass-through
secflg is T means bag section otherwise means the rest of the section"
  (setq addl nil)
  (setq rnl nil)
  (dolist (y  andl)
    (if lookupl
	(let (exist)
	  (dolist (x lookupl)
	    (if (= (first x) y)(setq exist t))
	    (if (and (= (first x) y) secflg)
		(progn  (setq lookupl (subst (subst (mksymbol (concat '_ (second x) '_1)) (second x) x) x lookupl))
			(setq y (second x))
			(edit-lookupl y)
			(return t))))
	    
	  (if (not exist)
	      (progn (setq lookupl (adjoin (list y (mksymbol (concat '_ y '_1))) lookupl))
		     (edit-lookupl y))))
      (progn (setq lookupl (adjoin (list y (mksymbol (concat '_ y '_1))) lookupl))
	     (edit-lookupl y))))
  (setq rnl (reverse rnl)))
 
(defun add-pred (predl tr)
  "add addtional predicates for TR for pass-through arguments"
  (let (temp exist)   
    (dolist (x predl)
      (setq exist nil)
      (if lookupl 
	  (progn 
	    (dolist (y lookupl)
	      (cond ((= (first y) x) 
		     (setq exist t)
		     (setq temp (cons `( , _=_  , x , (mksymbol (concat '_  (second y)  '_1))) temp))
		     (return t))))
	    (if (not exist )
		(progn
		  (setq lookupl (cons (list x (mksymbol (concat '_  x  '_1))) lookupl))
		  (setq temp (cons `( , _=_   , (mksymbol (concat '_  x  '_1)) , x) temp))))))
      (progn
	(setq lookupl (cons (list x (mksymbol (concat '_  x  '_1))) lookupl))
	(setq temp (cons `( , _=_  , (mksymbol (concat '_  x  '_1)) , x) temp))))
		 
	 
    (setq tr (union (reverse tr) temp))
    ))

(defun find-passthr-arg (resl)
  "Find the pass-through arguments for resultlist resl"
  (let (temp)   
    (dolist (x resl)
      (dolist (y lookupl)
	(cond ((= (first y) x)
	       (if temp
		   (setq temp (cons (second y) temp))
		 (setq temp (list (second y))))
	       (return t)))))
    temp
    ))


(defun replace-arg (argl)
  "Renaming the pass-through arg"
  (let (trans) 
    (dolist (x lookupl)
      (setq trans nil)
      (if (member (first x) argl)
	  (progn 
	    (dolist (z lookupl)
	      (if (= (second x) (first z)) (progn (setq trans 1) (return trans))))
	    (if (not trans)
		(setq argl (subst (second x) (first x) argl))))))
    argl))

(defun aux-replace-pred(andl xl yl)
  "Auxilary function for replace-pred"
  (let (trans nil)
    (if (member (first xl) yl)
	(progn
	  (dolist (z lookupl);; checking the transitive replacement of arguments in lookupl
	    (if (= (second xl) (first z)) (progn (setq trans 1) (return trans))))
	  (if (not trans)
	      (setq andl (subst (subst (second xl) (first xl) yl) yl andl)))))
    andl))

(defun replace-pred (andl)
  "Renaming the pass-through arg in andl"
  (dolist (x lookupl)
    (if (equal (car andl) 'and)
	(dolist (y andl)
	  (setq andl (aux-replace-pred andl x y)))
      (setq andl (aux-replace-pred andl x andl))))
  andl)

(defun section-subplan (andl from to argl resl independent)
  "Generate a TBR subplan between positions FROM and TO in ARGL.
   ARGL and RESL are inputs and outputs of ANDL, respectively"
  (let* ((tr (predify-tbr andl))
	 (first (andify (firstn (1- from) tr)));; before split
	 (middle (andify (firstn (1+ (- to from))
                                 (nthcdr (1- from) tr))))
         (last (andify (nthcdr to tr)));; last part
	 (fvfirst (free-variables first nil))
         (fvmiddle (free-variables middle nil))
         (fvlast (free-variables last nil))
	 (spargl  (union (reverse (intersection fvfirst fvmiddle))
			 (intersection argl fvmiddle) ))
	 spresl  
	 templ rrl ml)
    

    
    (if (not fvlast)
	(setq spresl (set-difference (intersection  resl fvmiddle) spargl))
      (setq spresl (set-difference (union (reverse (intersection fvmiddle fvlast))
					  (intersection  resl fvmiddle))
				   spargl)))
    (if _lastplan_;; for  last plan of independent groups
	(progn
	  (setq _lastplan_ nil)
	  (setq middle (add-pred (set-difference resl spresl) tr))
	  (setq spargl (union (reverse argl) (find-passthr-arg resl)))
	  (setq spresl resl)
	  ))
	
    ;; pass filter arguments
    
    (if  (not fvlast) (progn  (setq rrl (intersection fvmiddle (intersection fvfirst resl)))
			      (if (and (not rrl)(not independent))
				  (progn  (setq spresl (replace-arg spresl))
						    
					  (setq spresl (union (reverse spresl)  (intersection fvfirst resl)))
					  (dolist (l (intersection fvfirst resl))
					    (setq spargl (adjoin l spargl)))
						    
					  (rename-arg (intersection fvfirst resl) nil)
								 
					  (setq spargl (replace-arg spargl)) ;renaming the pass-through arg
					  (setq middle (replace-pred middle))
						    
					  (dolist (l (intersection fvfirst resl))
					    (setq templ (mksymbol (concat '_ l '_1)))
					    (dolist (x lookupl)
					      (if (= (first x) l)
						  (progn (setq templ (second x))
							 (return t))))
					    (setq templ  `( , _=_  , templ , l))
					    (setq ml  (cons templ ml)))
					  (setq middle (union (reverse middle) ml))
						   
					  )))
      (if (and (intersection spresl resl) (not independent))
	  (progn (rename-arg (intersection  spresl resl) t)
		 (setq spresl (replace-arg spresl)) ;renaming the pass-through arg
		 (quote (setq spargl (replace-arg spargl)))
		 (setq middle (replace-pred middle)))))
     
    (if (not independent) 
	(setq templ (intersection argl fvlast)));;only for bag section
    
    (if templ
	(progn
	  (rename-arg templ t)
	  (setq spargl (union (reverse templ) spargl))
	  
	  (if (neq (car middle) 'AND) 
	      (setq middle (andify (union (list middle) addl)))
	    (setq middle (union (reverse middle) addl)))
	  
	  (setq spargl (union (reverse templ) spargl))
	  (setq spresl (union (reverse spresl) rnl))))


    
    ;; To keep up the order
    (if  (not fvlast) (progn 
			(if bgresl 
			    (setq spargl (intersection bgresl spargl))) ;to keep same order as the make-bag results
			(setq spresl (intersection resl spresl)))
      (progn 
	(if (not independent)
	    (setq bgresl spresl)
	  (setq bgresl argl))
	(setq spargl (intersection argl spargl))))
    
    (create-subplan spargl spresl middle)))

(defun transform-section-subplan (andl from to argl resl)
  "Modyfy TBR conjuction ANDL by replacing section of ANDL between positions 
   FROM and TO with invocation of a subplan. 
   ARGL and RESL are inputs and outputs of ANDL, respectively"
  (let* ((sp (section-subplan andl from to argl resl))
	 (spargl(function-argvars sp)))
    (andify `(,(andify (firstn (1- from) andl))
	      (call invoke-plan , _invoke-plan_ 
		    , sp , (length spargl)
		    ,@ spargl ,@ (function-resvars sp))
	      ,(andify (nthcdr to andl))))))

