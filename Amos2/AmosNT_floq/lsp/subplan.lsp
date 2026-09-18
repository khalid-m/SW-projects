;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Tore Risch, UDBL
;;; $RCSfile: subplan.lsp,v $
;;; $Revision: 1.7 $ $Date: 2012/01/28 10:34:48 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Plan partitioner
;;; =============================================================
;;; $Log: subplan.lsp,v $
;;; Revision 1.7  2012/01/28 10:34:48  torer
;;; olog utilities added
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


(defvar _planno_ 0)
(defun generate-plan-id ()
   "Generate transactionally unique identifier for plan functions"
   (/setglobal '_planno_ (1+ _planno_));; transactional to enable rollback
   (pack 'plan- _planno_))

(defun create-subplan (invars outvars pred)
  "Create an execution plan as a transient subfunction"
  (predicate-function invars outvars (predify-tbr pred)))

(defun predicate-function (invars outvars tr)
  "Generate ObjectLog function for TR-predicate and in/out parameters"
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

(defun section-subplan (andl from to argl resl)
  "Generate a TBR subplan between positions FROM and TO in ARGL.
   ARGL and RESL are inputs and outputs of ANDL, respectively"
  (let* ((first (andify (firstn (1- from) andl)));; before split
	 (middle (andify (firstn (1+ (- to from))
                                 (nthcdr (1- from) andl))))
         (last (andify (nthcdr to andl)));; last part
	 (excs (list 'CWO 'VREF-BBF 'VECTOR.IN));; excluding set
         (fvfirst (free-variables first nil))
         (fvmiddle (free-variables middle nil))
         (fvlast (free-variables last nil))
         (spargl (set-difference 
		  (union 
		   (union (intersection fvfirst fvmiddle)
			  (intersection argl fvmiddle))
                   (intersection argl fvlast))
		  excs))
	 
	 
	 (spresl (set-difference (set-difference 
				  (union (intersection fvmiddle fvlast)
					 (intersection fvmiddle resl))
				  spargl) 
				 excs)))
         
    (create-subplan spargl spresl middle)
    ))

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

