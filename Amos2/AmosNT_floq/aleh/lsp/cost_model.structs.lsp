;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Ruslan Fomkin, UDBL
;;; $RCSfile: cost_model.structs.lsp,v $
;;; $Revision: 1.15 $ $Date: 2008/09/04 15:59:50 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;; ===========================================================================
;;; $Log: cost_model.structs.lsp,v $
;;; Revision 1.15  2008/09/04 15:59:50  ruslan
;;; cost model for sobject-transpose
;;;
;;; Revision 1.14  2008/05/12 15:42:35  ruslan
;;; cost model of closednf is improved
;;;
;;; Revision 1.13  2008/05/10 13:06:49  ruslan
;;; wrapper returns only sobject without the key vector, names of wrapper functions in correspondance with the Thesis, aleh_stream is used to stream events instead of filename
;;;
;;; Revision 1.12  2008/03/19 13:18:03  ruslan
;;; cost models
;;;
;;; Revision 1.11  2008/03/16 11:51:52  ruslan
;;; cost model generalized, when variable instead of funciton is given in closednf and cachefn
;;;
;;; Revision 1.10  2008/03/12 11:12:26  ruslan
;;; cost model for minagg2 is fixed
;;;
;;; Revision 1.9  2008/03/10 15:59:00  ruslan
;;; type containers defined. this removes some type check, but not all of them, while they still can be removed somehow. missing cost models
;;;
;;; Revision 1.8  2008/03/06 15:39:59  ruslan
;;; cost model for vector is done in more natural way. only fanout is passed from get_slot to vrefbff
;;;
;;; Revision 1.7  2008/03/05 14:22:17  ruslan
;;; cost model for vref is implemented as cost function with using bindings for vector varibles, which are set to statistics collected for sobject slots containing vectors
;;;
;;; Revision 1.6  2008/03/01 15:59:43  ruslan
;;; collecting cardinality statistics on slots and using in query optimization
;;;
;;; Revision 1.5  2008/03/01 10:07:55  ruslan
;;; dropping slot stat fucntion
;;;
;;; Revision 1.4  2008/02/28 13:12:11  ruslan
;;; bug in cost model for closednf is fixed
;;;
;;; Revision 1.3  2008/02/16 10:52:38  ruslan
;;; bug with cost model is fixed that cost model for operators used only in streamed version is defined only for them
;;;
;;; Revision 1.2  2008/02/12 10:58:53  ruslan
;;; cost model cachefn is defined by returning costs of input function
;;;
;;; Revision 1.1  2007/12/13 11:00:24  ruslan
;;; cost model for structs is moved to separarte file
;;;
;;; ===========================================================================

(defglobal _default-sobject-acces-cost_ 1.0)
(defglobal _default-vref-access-cost_ 1.0)
(defglobal 
  *sobject-stat-fn* (getfunctionnamed 
		     'TYPE.INTEGER.SOBJECT_STAT->INTEGER.INTEGER.INTEGER))

(setq *costfn*
      (foreign-lispfn closednf_costs ((function f)(vector bpat)(vector argl)) 
		      ((number cost)(number fanout))
		      (let
			  ((fno (aref argl 0)))
			(cond
			 ((and (oid-p fno)(osql-functionp fno))
			  (let*
			      ((cst (exec-cost-of-fn fno t)))
			    (osql-result f bpat argl (+ (first cst)
							(second cst))
					 (second cst))))
			 (t (osql-result f bpat argl 
					 _minimal-aggregation-cost_
					 _default-in-fanout_))))))

(declarecosts 'Function.integer.event.closednf->particle '(- - - +) *costfn*)
(declarecosts 'Function.integer.event.closednf->particle '(- - - -) *costfn*)
(declarecosts 'Function.integer.charstring.closednf->event '(- - - +) *costfn*)
(declarecosts 'Function.integer.charstring.closednf->event '(- - - -) *costfn*)
(declarecosts 'Function.integer.charstring.integer.integer.closednf->event 
	      '(- - - - - +) *costfn*)
(declarecosts 'Function.integer.charstring.integer.integer.closednf->event 
	      '(- - - - - -) *costfn*)

(setq *costfn*
      (foreign-lispfn
       get_slot_bag_costs ((function f)(vector bpat)(vector argl)) 
       ((number cost)(number fanout))
       (let
	   ((s (aref argl 0))		; struct
	    (i (aref argl 1))		; struct slot
	    s_b pair)
	 (cond 
	  ((and (setq s_b (getbinding s)) (integerp i))
	   (cond 
	    ((and *sobject-stat-fn* 
		  (setq pair 
			(getfunction *sobject-stat-fn*
				     (list (binding-type s_b) i))))
	     (let ((fnt (/ (float (cadar pair))(caar pair))))
	       (osql-result f bpat argl 
			    (* _default-sobject-acces-cost_ fnt)
			    fnt)))
	    (t (osql-result f bpat argl 
			    (* _default-in-fanout_ 
			       _default-sobject-acces-cost_)
			    _default-in-fanout_))))
	  (t (osql-result f bpat argl 
			  (* _default-in-fanout_ _default-sobject-acces-cost_)
			  _default-in-fanout_))))))

(declarecosts 'SOBJECT.INTEGER.GET_SLOT_BAG->OBJECT '(- - +) *costfn*)
(declarecosts 'SOBJECT.INTEGER.GET_SLOT_BAG->OBJECT '(- - -) *costfn*)

(setq *costfn*
      (foreign-lispfn
       get_slot_costs ((function f)(vector bpat)(vector argl)) 
       ((number cost)(number fanout))
       (let
	   ((s (aref argl 0))		; struct
	    (i (aref argl 1))		; struct slot
	    (bvar (aref argl 2))	; result variable
	    s_b pair)
	 (cond 
	  ((and (setq s_b (getbinding s t)) (integerp i))
	   (cond 
	    ((and *sobject-stat-fn*	; stat is stored, it returns vector
		  (setq pair 
			(getfunction *sobject-stat-fn*
				     (list (binding-type s_b) i))))
	     (let* ((fnt (/ (float (cadar pair))(caar pair)))
;		   (cst (* _default-sobject-acces-cost_ fnt))
		   (bnd (getbinding bvar t)))
	       (cond ((null bnd) 
		      (addbinding bvar nil _bag_)
		      (setq bnd (getbinding bvar))))
	       (setf (binding-context bnd) fnt)
	       (osql-result f bpat argl 
			    (* _default-foreign-fanout_ 
			       _default-sobject-acces-cost_)
			    _default-foreign-fanout_)))
	    (t (osql-result f bpat argl 
			    (* _default-foreign-fanout_ 
			       _default-sobject-acces-cost_)
			    _default-foreign-fanout_))))
	  (t (osql-result f bpat argl 
			  (* _default-foreign-fanout_ 
			     _default-sobject-acces-cost_)
			  _default-foreign-fanout_))))))

(declarecosts 'SOBJECT.INTEGER.GET_SLOT->OBJECT '(- - +) *costfn*)
(declarecosts 'SOBJECT.INTEGER.GET_SLOT->OBJECT '(- - -) *costfn*)

(setq *costfn*
      (foreign-lispfn
       get_slotbff_costs ((function f)(vector bpat)(vector argl)) 
       ((number cost)(number fanout))
       (osql-result f bpat argl 
		    (* _default-sobject-acces-cost_ _default-in-fanout_) 
		    _default-in-fanout_)))
(declarecosts 'SOBJECT.INTEGER.GET_SLOT->OBJECT '(- + +) *costfn*)

(setq *costfn*
      (foreign-lispfn
       vrefbff_costs ((function f)(vector bpat)(vector argl)) 
       ((number cost)(number fanout))
       (let
	   ((fnt (binding-context (getbinding (aref argl 0)))))
	 (cond
	  ((null fnt)
	   (osql-result f bpat argl 
			(* _default-vref-access-cost_ _default-in-fanout_) 
			_default-in-fanout_))
	  (t
	   (osql-result f bpat argl (* _default-foreign-cost_ fnt) fnt))))))

(declarecosts 'VECTOR-INTEGER.INTEGER.VREF->INTEGER '(- + +) *costfn*)
(declarecosts 'VECTOR-REAL.INTEGER.VREF->REAL '(- + +) *costfn*)
(declarecosts 'VECTOR.INTEGER.VREF->OBJECT '(- + +) *costfn*)

(setq *costfn*
      (foreign-lispfn
       vrefbbf_costs ((function f)(vector bpat)(vector argl)) 
       ((number cost)(number fanout))
       (osql-result f bpat argl 
		    (* _default-vref-access-cost_ _default-foreign-fanout_) 
		    _default-foreign-fanout_)))

(declarecosts 'VECTOR-INTEGER.INTEGER.VREF->INTEGER '(- - +) *costfn*)
(declarecosts 'VECTOR-REAL.INTEGER.VREF->REAL '(- - +) *costfn*)
(declarecosts 'VECTOR.INTEGER.VREF->OBJECT '(- - +) *costfn*)

(setq *costfn*
      (foreign-lispfn
       cachefn_costs ((function f)(vector bpat)(vector argl)) 
       ((number cost)(number fanout))
       (let
	   ((fno (aref argl 0))		; function
;	    (i (aref argl 1))		; struct slot
	    s_b pair)
	 (cond
	  ((null fno) t)
	  ((and (oid-p fno) (osql-functionp fno))
	   (let
	       ((cst (exec-cost-of-fn fno)))
	     (osql-result f bpat argl (first cst) (second cst))))
	  (t (osql-result f bpat argl 
			  _minimal-aggregation-cost_
			  _default-in-fanout_))))))

(declarecosts 'FUNCTION.INTEGER.SOBJECT.CACHEFN->OBJECT '(- - - +) *costfn*)
(declarecosts 'FUNCTION.INTEGER.SOBJECT.CACHEFN->OBJECT '(- - - -) *costfn*)

(declarecosts 'BAG.SOMEC->BOOLEAN '(-) 
	      (getfunctionnamed 
	       'FUNCTION.VECTOR.VECTOR.SOME_COSTS->NUMBER.NUMBER))

(declarecosts 'BAG.NOTANYC->BOOLEAN '(-) 
	      (getfunctionnamed
	       'FUNCTION.VECTOR.VECTOR.NOTANY_COSTS->NUMBER.NUMBER))

(setq *costfn*
      (foreign-lispfn 
       minagg2_costs ((function f)(vector bpat)(vector argl)) 
       ((number cost)(number fanout))
       (let
	   ((fno (binding-context (getbinding (aref argl 0)))))
	 (cond
	  ;; Bag generator is not bound
	  ((null fno)
	   (osql-result f bpat argl 
			minimal-aggregation-cost_ 
			(- 1.0 _default-count-fanout_)))
	  (t
	   (let
	       ((cst (exec-cost-of-fn fno)))
	     (osql-result f bpat argl 
			  (+ (first cst) 
			     (* (second cst) 
				_default-iteration-cost_))
			  (if (< (second cst) 1.0)
			      (/ (second cst) 2)
			    (- 1 (/ 1 (* 2 (second cst))))))))))))

(declarecosts 'BAG.MINAGG2->NUMBER.OBJECT '(- + +) *costfn*)
(declarecosts 'BAG.MINAGG4->NUMBER.OBJECT.OBJECT.OBJECT '(- + + + +) *costfn*)

(setq *costfn*
      (foreign-lispfn
       sobject_transpose_costs ((function f)(vector bpat)(vector argl)) 
       ((number cost)(number fanout))
       (let
	   ((v (aref argl 0))		; vector of attribute numbers
	    (s (aref argl 1))		; sobject
	    s_b pair i)
	 (cond 
	  ((and (setq s_b (getbinding s)) (arrayp v) 
		(setq i (aref v 0))(integerp i))
	   (cond 
	    ((and *sobject-stat-fn* 
		  (setq pair 
			(getfunction *sobject-stat-fn*
				     (list (binding-type s_b) i))))
	     (let ((fnt (/ (float (cadar pair))(caar pair))))
	       (osql-result f bpat argl 
			    (* _default-sobject-acces-cost_ fnt)
			    fnt)))
	    (t (osql-result f bpat argl 
			    (* _default-in-fanout_ 
			       _default-sobject-acces-cost_)
			    _default-in-fanout_))))
	  (t (osql-result f bpat argl 
			  (* _default-in-fanout_ _default-sobject-acces-cost_)
			  _default-in-fanout_))))))

(declarecosts 'VECTOR.SOBJECT.TYPE.SOBJECT_TRANSPOSE->SOBJECT
	      '(- - - +) *costfn*)
(declarecosts 'VECTOR.SOBJECT.TYPE.SOBJECT_TRANSPOSE->SOBJECT
	      '(- - - -) *costfn*)
