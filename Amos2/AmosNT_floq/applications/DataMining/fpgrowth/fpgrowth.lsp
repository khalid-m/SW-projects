;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011, Andrej Andrejev, UDBL
;;; $RCSfile: fpgrowth.lsp,v $
;;; $Revision: 1.1 $ $Date: 2011/06/27 08:13:07 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Straightforward Lisp implementation of FP-Growth algorithm
;;; =============================================================
;;; $Log: fpgrowth.lsp,v $
;;; Revision 1.1  2011/06/27 08:13:07  andan342
;;; Moving FPGrowth to DataMining/ subfolder, where it should be
;;;
;;; Revision 1.1  2011/06/17 09:54:16  andan342
;;; Added reference implementations of FP-Growth algorithm
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

;; Test data
;; (defvar *data* (osql "read_ntuples('exam.nt');"))

(defstruct itemdata cnt order) ; Doesn't use 'horizontal' links of nodes in FP-Tree

(defstruct fpnode item cnt chld)
                                 
(defun count-items (data)
  "Build a hashtable of ITEMDATA, one for each item found"
  (let ((iht (make-hash-table :test #'equal)))
    (dolist (tr data)
      (dotimes (i (length (car tr)))
	(let* ((item (aref (car tr) i))
	       (idata (gethash item iht)))
	  (if idata (incf (itemdata-cnt idata))
	    (puthash item iht (make-itemdata :cnt 1))))))
    iht))

(defun sort-iht (iht)
  "Populate ORDER field of ITEMDATA records"
  (let (sis (o 0))
    (maphash (f/l (k v) (setf sis (cons k sis))) iht) ; extract items only
    (setq sis (sort sis (f/l (x y) (>= (itemdata-cnt (gethash x iht)) ; sort descending by CNT
				       (itemdata-cnt (gethash y iht))))))
    (dolist (item sis) ; enumerate HT items according to SIS, start with 1
      (setf (itemdata-order (gethash item iht)) (incf o)))))

(defun sort-tr (tr iht)
  "Sort transaction according items hashtable"
  (sort (arraytolist (car tr))
	(f/l (x y) (< (itemdata-order (gethash x iht))
		      (itemdata-order (gethash y iht))))))

(defun fptree-add (sorted-tr nodes iht)
  "Add a transaction to FP-Tree"
  (if (null sorted-tr) nodes ; (a) return subtree as is
    (let ((node (car (isome nodes (f/l (x tail) ; look for the node to contain the next item from TR
				       (= (fpnode-item x) (car sorted-tr)))))))
      (if node (progn (incf (fpnode-cnt node))
		      (setf (fpnode-chld node) 
			    (fptree-add (cdr sorted-tr) (fpnode-chld node) iht)) ;recursive
		      nodes) ; (b) update CNT and CHLD recursively
	(cons (make-fpnode :item (car sorted-tr) :cnt 1 ; (c) add new node on this level
			   :chld (fptree-add (cdr sorted-tr) nil iht)) nodes))))) ;recursive

(defun fptree-build (data)
  "Build FP-tree from the set of transactions"
  (let (iht fptree)
    (setq iht (count-items data)) ; 1st DATA pass
    (sort-iht iht)
    (dolist (tr data) ; 2nd DATA pass
      (setq fptree (fptree-add (sort-tr tr iht) fptree iht)))
    fptree))

(defun fptree-project (nodes item minsupp)
  "Project FP-tree to a given item, returning conditional FP-Tree"
  (let (res (cntsum 0) cnt-chld)
    (dolist (node nodes)
      (cond ((= (fpnode-item node) item) 
	     (setq cntsum (+ cntsum (fpnode-cnt node))))
	    (t (setq cnt-chld (fptree-project (fpnode-chld node) item minsupp)) ;recursive
	       (when (>= (car cnt-chld) minsupp)
		 (push (make-fpnode :item (fpnode-item node) :cnt (car cnt-chld) :chld (cdr cnt-chld)) res))
	       (setq cntsum (+ cntsum (car cnt-chld))))))
    (cons cntsum res))) ; return CNT sum and list of projected nodes with CNT >= MINSUPP

(defun fptree-get-items (nodes res) ; NODES is not NIL
  "Get all distinct items in FP-Tree"
  (dolist (node nodes res)
    (unless (member (fpnode-item node) res)
      (push (fpnode-item node) res))
    (setq res (fptree-get-items (fpnode-chld node) res)))) ;recursive

(defun fptree-mine-rec (nodes minsupp prefix res)
  "Recursively mine FP-Tree, given the prefix"
  (let (proj)
    (dolist (item (fptree-get-items nodes nil) res)
      (setq proj (fptree-project nodes item minsupp))
      (when (>= (car proj) minsupp)
	(push (cons (car proj) (cons item prefix)) res)
	(setq res (fptree-mine-rec (cdr proj) minsupp (cons item prefix) res)))))) ;recursive

(defun fptree-mine (data minsupp)
  "General FPGrowth driver"
  (fptree-mine-rec (fptree-build data) minsupp nil nil))

;; Test data
;; (defvar *data* (osql "read_ntuples('exam.nt');"))
;; Run
;; (fptree-mine *data* 2)

(defun fpgrowth--++ (fno data-bag minsupp supp itemset)
  "AmosQL wrapper"
  (let (data)
    (mapbag data-bag
	    (f/l (tr) (push tr data)))
    (dolist (res (fptree-mine data minsupp))
      (osql-result data-bag minsupp (car res) (listtoarray (cdr res))))))

(osql "
create function fpgrowth(Bag of Vector data, Integer minsupp) -> (Integer supp, Vector itemset)
  as foreign 'fpgrowth--++';
")

;; Run in Amos:
;; fpgrowth(read_ntuples('exam.nt'),2);

		    

	  