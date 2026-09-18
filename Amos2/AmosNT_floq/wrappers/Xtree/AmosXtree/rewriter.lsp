;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) <year> <author>, UDBL
;;; $RCSfile: rewriter.lsp,v $
;;; $Revision: 1.12 $ $Date: 2010/08/14 20:05:06 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: <description>
;;; =============================================================
;;; $Log: rewriter.lsp,v $
;;; Revision 1.12  2010/08/14 20:05:06  thtr1663
;;; add xtree_dropper to deallocate xtree. It should be called when drop_index
;;; command is executed.
;;;
;;; Revision 1.11  2010/06/23 06:27:14  thtr1663
;;; update rewrite rule
;;;
;;; Revision 1.10  2010/06/22 05:58:35  thtr1663
;;; - compute index identifier at run time given index-pos and function object
;;;   having index on it.
;;; - add condition (rule) to rewrite euclid queries over xtree indexed stored
;;;   functions
;;;
;;; Revision 1.9  2010/06/22 05:48:15  thtr1663
;;; **empty log msg*
;;;
;;; Revision 1.8  2010/06/15 11:18:41  thtr1663
;;; rewriter for KNN
;;;
;;; Revision 1.7  2010/06/14 16:29:30  thtr1663
;;; add stub for rewrite-KNN search
;;;
;;; Revision 1.6  2010/06/14 08:59:50  thtr1663
;;; handle permutaion of arguments
;;;
;;; Revision 1.5  2010/06/14 08:26:09  thtr1663
;;; modify rewrite rule for inequality
;;;
;;; Revision 1.4  2010/06/14 05:55:12  thtr1663
;;; modify rewrite rule for similar search
;;;
;;; Revision 1.3  2010/06/11 07:54:03  thtr1663
;;; fix resolvent of Euclid function
;;;
;;; Revision 1.2  2010/06/08 14:09:50  torer
;;; Beginning of xtree rewriter
;;;
;;; Revision 1.1  2010/06/08 09:14:19  torer
;;; Added stub for XTREE rewriter
;;;
;;; =============================================================

(debugging t);; Into breakloop on error

;;; general index rewriter utility functions ;;;

(defun indexes-of-kind (fno kind &optional noerror)
  "Return a list of the indexes of a given kind associated with FNO"
  (cond ((relationp fno);; FNO must be a relation
	 (subset (relation-indexes fno);; All indexes of relation FNO
		 (f/l (i)(eq (index-type i);; INDEX-TYPE is kind of an index
			     kind))))
        (noerror nil);; return NIL if NOERROR flag true and no index found
        (t (amos-error fno " has no " kind " index"))))

(defun define-index-rewriter (index-kind index-rewritefn)
  "Associate function (index-rewriter this indl rest rw) with all stored
   functions having an index of kind INDEX-KIND.
   THIS: The predicate having the index
   INDL: List if indexes of the kind for THIS
   REST: The other predicates in the conjunction where THIS appeared
   RW: The full rewriter record (see rewrite.txt)"
  (putprop 
   index-kind ;;; The system puts the rewrite rule on all stored functions 
              ;;; having index of this kind
   'index-rewriter 
   `(lambda (rw);; put anonymous wrapper function in property INDEX-REWRITER
      (let* ((this (rewrite-this rw));; The called predicate having rule
             (rest (rewrite-rest rw));; The other predicates in conjunction 
	     (indl (indexes-of-kind (car this);; get list of index of kind
				    (quote , index-kind) t)))
	(if (and indl rest) (, index-rewritefn this indl;; call the rewriter
					       rest
					       rw)
	  'substitute)))));; default do nothing 

;;; rewriter for XTREE indexes ;;;

(defglobal _euclid_ 
  (getfunctionnamed 'VECTOR-NUMBER.VECTOR-NUMBER.EUCLID->NUMBER)
  "The resolvent euclid(Vector, Vector)->Number")

(defglobal _euclid-comparisons_
  (mapcar (function getfunctionnamed)
	  '(object.object.<->boolean object.object.<=->boolean))
  "The comparisons over xtree + euclid that are rewritten")

(defglobal _euclid-other-comparisons_
  (mapcar (function getfunctionnamed)
	  '(object.object.>->boolean object.object.=->boolean object.object.>=->boolean  object.object.!=->boolean))
  "The other comparisons over xtree + euclid that are rewritten")

(defglobal _notequal_)			; bound to AMOSQL function !=

(defglobal _xtree-similarity-search-objdist-fn_
  (getfunctionnamed 'INTEGER.FUNCTION.VECTOR-NUMBER.NUMBER.XTREE_SIMILARITY_SEARCH_OBJDIST_FN->OBJECT.NUMBER)
  "Special similarity search")

(defglobal _xtree-knn-search-fn_
  (getfunctionnamed 'INTEGER.FUNCTION.VECTOR-NUMBER.INTEGER.XTREE_KNN_SEARCH_FN->OBJECT)
  "Knn search")

;; This function differs from the Alisp built-in variable-is-bound function
;; This function determines a variable is bound based on binding pattern
;; - bound
;; + free
;; while the built-in one use later binding.
(defun _variable-is-bound-before_ (var	;variable
				   listVar ;list of variables
				   bpat	;binding pattern
				   )
; "Variable is bound if it is constant or its binding pattern is -"
  (let* ((bound '-)
	 (pos (car (list-positions var listVar)))
	 )
    (or (osql-constantp var) 
	(= (nth pos bpat) bound))))



(defun xtree-index-rewriter (this indxl rest rw)
  (let* ((bnd (rewrite-bnd rw))
	 (xind (car;;only one xtree index per table supported
		indxl))	
	 (pos (index-pos xind));; Position of index in THIS
	 (var (nth pos (cdr this)));; Variable or constant at index position
         (eucall;; call to euclid binding indexed variable in REST 
	  (car 
	   (isome 
	    rest 
	    (f/l (pred)
		 (and (consp pred);; skip variables in REST
		      (eq (car pred) _euclid_);; call found
		      (memq var (cdr pred)))))));; must bind indexed variable
         (compcall;;call to comparison with EUCLID
	  (car
	   (isome 
	    rest
	    (f/l (pred)
		 (and (consp pred)
		      (memq (car pred) _euclid-comparisons_)
		      (intersection (cdr eucall) 
				    (cdr pred));;comparison connected to eucall
		      )))))

	 (list-other-compcall;;get other comparisions  
	  (subset
	   rest
	   (f/l (pred)
		(and (consp pred)
		     (memq (car pred) _euclid-other-comparisons_)
		     (intersection (cdr eucall) 
				   (cdr pred));;comparison connected to eucall
		     ))))
	 (ig (dt_genvar _vector_))
	 );;end of let
    
    (cond ((null eucall) 'substitute);; rule ignored
          ((null compcall) 'substitute);; rule ignored
          (t 
           (let* ( (second_eucall (second eucall))
		   (third_eucall (third eucall))
		   (rv (dt_genvar _vector_)) 
		   (dt (dt_genvar _vector_))
		   (params (set-difference (cdr eucall) (cdr this))))
	     (cond ( (and 
		      (or
		       ;; one of Eucall input must be bound
		       (and (in second_eucall bnd)(in third_eucall bnd))
		       (osql-constantp second_eucall)
		       (osql-constantp third_eucall)
		       )
		      ;; right-hand-side of compcall must be bound
		      (variable-is-bound (third compcall) bnd))

		     (rewrite-retract eucall rw)
		     (rewrite-retract compcall rw)
		     ;; First, retract other comparisions
		     (dolist (comp list-other-compcall) (rewrite-retract comp rw))
		    
		     ;;Above retractions removed other bound variables
		     ;;It below attempts to add needed variables
		     ;;(setf (rewrite-bnd rw) (adjoin (fourth eucall) (rewrite-bnd rw))))
		     ;;(if (not (variable-is-bound rv rw))
		     ;; (setf (rewrite-bnd rw) (adjoin rv (rewrite-bnd rw))))
	     
		     (rewrite-assert (list _xtree-similarity-search-objdist-fn_ 
					   (index-pos xind)
					   (nth 0 this);; get the function
					   ;;Q: Take the second or the third argument? 
					   ;;A: One is bound
					   (cond ((osql-constantp second_eucall) second_eucall)
						 ((osql-constantp third_eucall) third_eucall)
						 (t (car params)))
					   (third compcall)  rv dt) rw)
		    
		     (rewrite-assert (list* _vector-constructor_  rv (cdr this)) rw)
		    
		     ;;Note that, arguments of other compcalls are based on the result
		     ;; of eucall. However, we did retract eucall meaning that those
		     ;; arguments ( of other compcalls) are unbound. Therefore, we 
		     ;; substitue those arguments by distance returned from a search
		     ;; with Xtree
		     (if (and (not (null list-other-compcall)) 
			      (listp list-other-compcall))		 
			 (setf list-other-compcall 
			       (subst dt (fourth eucall) list-other-compcall)))
		    
		     ;;Adds other compcalls to post-filter
		     (if (not (null list-other-compcall))
			 (dolist (comp list-other-compcall) (rewrite-assert comp rw)))
		     ;;(rewrite-assert list-other-compcall rw))
		    
		     ;;By default, xtree_similarity_search_objdist_fn searches with 
		     ;;less-or-equal-than operator
		     ;;Hence, it attempts to add a filter(inequality) if necessary
		     (if (eq (generic-fnname (car compcall)) '<)
			 (rewrite-assert (list _notequal_ dt (third compcall)) rw))
		    
		     ;;(help 2)		    
		     'success) (t 'substitute)))))))


(define-index-rewriter 'xtree 'xtree-index-rewriter)


;; TBR rewrite rule is invoked when the function
;; knn is called. The rewrite rule replaces the call knn by
;; xtree_knn_search_fn (ID, Vector of Number,Integer k)
(defun rewrite-knnsearch (rw)
  (let* ((this (rewrite-this rw)) 
	 (rest (rewrite-rest rw))
	 (ro  (cond ((variable-is-bound (second this) rw)
		     (get-relation (second this))) 
		    (t nil)))
	 (xt (car (indexes-of-kind ro 'xtree t)))
	 (rv (dt_genvar _vector_))
	 (ig (dt_genvar _vector_)))
    ;;(help knnnn)
    (cond ((null xt) 'substitute );;no indexes found->rule is ignored
	  (t (rewrite-assert 
	      (list _xtree-knn-search-fn_ 
		    (index-pos xt)
		    (nth 1 this);; Function indexed by Xtree
		    (third this) 
		    (fourth this) 
		    rv) rw)
	     (rewrite-assert (list _vector-constructor_ rv 
				   (car (last this)) ig) rw)
	     ;;(help 55)
	     'success ))))




;; Compute index identifier given index postion
;; and function object having index on
(defun get-index-identifier--+ (fno pos;; position of index
				    fname xtid);; function name having index on
  "Get index identifier from given position on given function"
  (let* ((ro (get-relation fname)) 
	 (indxl (cond ((null ro) (relation-indexes fname))
		      (t (relation-indexes ro)))(relation-indexes ro)) 
	 (xt (nth pos indxl)))
    (osql-result pos fname (cond ((null xt) -1) (t (index-rows xt))))))


;; AmosQL function to compute index identifier
(osql "
create function get_index_identifier(Integer pos, Function fname) -> Integer xtid
   as multidirectional
      ('bbf' key foreign 'get-index-identifier--+');")

