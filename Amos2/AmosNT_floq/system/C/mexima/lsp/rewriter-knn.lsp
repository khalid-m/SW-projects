;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010 Thanh Truong, UDBL
;;; $RCSfile: rewriter-knn.lsp,v $
;;; $Revision: 1.3 $ $Date: 2013/09/14 12:44:45 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Rewrite rules to utilize Xtree index.
;;   Similarity and K Nearest neighbour search are supported.
;;   It was originally in wrappers\Xtree\AmosXtree       
;;; =============================================================
;;; $Log: rewriter-knn.lsp,v $
;;; Revision 1.3  2013/09/14 12:44:45  thatr500
;;; - removed extra parameter when passing distance function
;;; - removed k_nearest naive implementation from AmosMiner
;;;
;;; Revision 1.2  2012/01/17 16:15:01  thatr500
;;; renamed variable _spatial-indexes_ to _aqit-supported-indexes_
;;;
;;; Revision 1.1  2011/12/02 12:50:57  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.2  2011/11/02 16:51:06  thatr500
;;; Use a new term "AQUIT" (Algebraic Query Inequality Transformation)
;;;
;;; Revision 1.1  2011/05/06 01:40:15  thatr500
;;; generalized rewrite code of Mexima
;;;
;;; Revision 1.19  2011/05/04 08:28:08  thatr500
;;; changed KNN rewrite code so that it applies to all index type on which
;;; KNN can be rewritten
;;;
;;; Revision 1.18  2011/04/11 07:32:16  thatr500
;;; add index rewrite rule (XTREE, Euclid, Xtree-distance-search)
;;;
;;; Revision 1.17  2011/04/05 11:11:17  thatr500
;;; moved away general code to mexima/lsp/sp-index-rewrite.lsp
;;;
;;; Revision 1.16  2011/03/29 17:18:18  thatr500
;;; Rewrite Euclidean is based on TR but not TBR
;;;
;;; Revision 1.15  2011/03/27 23:41:21  thatr500
;;; New version of "AQUIT" based on 4 simple rules
;;;
;;; Revision 1.14  2011/03/19 11:56:13  thatr500
;;; add simple inequality transformation to the Amos II
;;;
;;; Revision 1.13  2011/03/05 00:08:48  thatr500
;;; distance search can search on mutiple / unique index
;;;
;;; Revision 1.12  2011/02/26 19:49:01  thatr500
;;; rename function 'similarity' to 'distance'
;;;
;;; Revision 1.11  2011/02/26 18:25:57  thatr500
;;; rename function similarity to distance
;;;
;;; Revision 1.10  2011/01/25 12:24:52  thatr500
;;; supports EXINMA delivered as a DLL (Windows)
;;;
;;; Revision 1.9  2011/01/12 10:37:25  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.8  2010/12/01 19:20:01  thatr500
;;; use EXSTMA to integerate Xtree
;;;
;;; Revision 1.7  2010/11/02 08:10:14  thatr500
;;; get identifier of Xtree through a header (typeof XTREETYPE)
;;;
;;; Revision 1.6  2010/10/15 05:17:56  thatr500
;;; lookup xtree index from the given function.
;;;
;;; Revision 1.5  2010/10/07 13:27:57  thatr500
;;; call naive knn implementation if there is no Xtree index
;;;
;;; Revision 1.4  2010/09/29 15:15:52  thatr500
;;; Add comments
;;;
;;; Revision 1.3  2010/09/29 15:07:59  thatr500
;;; Utilize Knn search with Xtree index. The Knn search now can handle
;;; either function or a bag as input parameters.
;;;
;;; =============================================================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Rewrite similarity search using Xtree
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun emit-knn-results_ (lnn v k ib pos)
  "Emit each nearest neighbour in lnn"
  (mapc (f/l (nn)
	     ;; Emit each object found in nn
	     (osql-result v k ib 
			  ;; Either nn is a list of array or a list
			  ;; of others			   
			  (cond ((arrayp (car nn)) (aref (car nn) pos)) 
				(t (nth pos nn))))	      
	     );;end f/l
	lnn))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; KNN query which takes a function having xtree index on it 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun 	knnsearch_with_fn---+ (fname v k fn rb)
  "Implementation of function knn(Vector of Number , Integer k, 
   Bag of Object)-> Bag of Object"
  ;; If there is Xtree index in ib, then call xtree_knn_search_fn
  (let* ((ro (get-relation fn)) 
	 ;; xtree index from the function
	 xt executed lnn amfn
	 ;; position of expected object in
	 ;; a tuple of returned bags
	 (objPos -1))
    (dolist (idxtype  _aqit-supported-indexes_)
      (setq xt (car (indexes-of-kind ro idxtype t)))
      (setq amfn (mksymbol1 (get-knnamfn idxtype)))
      (cond ((and (neq xt nil) (null executed))
	     (let* ((argl (list (index-pos xt) fn v k)))
	       (setq executed t)
	       ;; call KNN implementation in C
	       ;; lrb contains list of results
	       (setq lnn (getfunction amfn argl))
	       (emit-knn-results_ lnn v k fn 0)))))

    (cond ((null executed) 	 
	   ;; TODO : modify naive knn to get the reversed list ?? 
	   (setq lnn (reverse 
		      (getfunction 
		       'K_NEAREST_WITH_FN (list v k _euclid_ fn))))
	   (emit-knn-results_ lnn v k fn 1)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Foregin function Knn which takes a bag of data type A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun 	knnsearch_with_bag---+ (fname v k ib rb)
  "Implementation of function knn(Vector of Number , Integer k, 
   Bag of Object)-> Bag of Object"
  ;; If there is Xtree index in ib, then call xtree_knn_search_fn
  (let* (;; struct SELECTBODY from generator ib
	 (genbd (getobject (generator-function ib) 'selectbody))
	 ;; rewriten predicate
	 (repred (selectbody-pred genbd))
	 ;; a function associated with repred
	 (ro (car repred))	 
	 xt lnn executed amfn)
	 ;; position of expected object in
	 ;; a tuple of returned bags

    (dolist (idxtype  _aqit-supported-indexes_)
      (setq xt (car (indexes-of-kind ro idxtype t)))
      (setq amfn (mksymbol1 (get-knnamfn idxtype)))
      (cond ((and (neq xt nil) (null executed))
	     (let* ((argl (list (index-pos xt) ro v k)))
	       (setq executed t)
	       ;; call KNN implementation in C
	       ;; lrb contains list of results
	       (setq lnn (getfunction amfn argl))
	       (emit-knn-results_ lnn v k ib 0)))))

    (cond ((null executed)	    
	   (setq lnn (reverse 
		      (getfunction 'K_NEAREST (list v k _euclid_ ib))))
	   ;; lnn is a bag of <Number, Object>	     
	   (emit-knn-results_ lnn v k ib 1)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
;; Example : creating a generator holding a bag of results 
;; (setq rb
;;     (make-generator 
;;      (arg-bagtype _xtree-knn-search-fn_) 
;;      _xtree-knn-search-fn_ argl)))))	       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



