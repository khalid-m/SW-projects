;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2000 Tore Risch, UDBL
;;; $RCSfile: mbindex.lsp,v $
;;; $Revision: 1.10 $ $Date: 2012/08/22 15:04:27 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Main Memory BTree index
;;; =============================================================
;;; 

(defstruct mbtindex;; holder of main memory btree index of function
  pos;; argument/result position
  name;; name of position
  btree;; the btree
  )

(defglobal _notequal_) ; bound to AMOSQL function !=
(defglobal _mbt-select-range_) 
           ;;; bound to AmosQL functon MBT-SELECT-RANGE implementing
           ;;; B-tree search
(defun get-mbtindexes (ro)
  (subset (relation-indexes ro)(f/l(ix)(eq (index-type ix) 'mbtree))))

(defun get-mbtindex-at (ro pos)
  "Get the MBT index at position POS of core cluster function FNO"
  (dolist (i (get-mbtindexes ro))
    (if (eq (index-pos i) pos) (return i))))

(defstruct cc-comp 
  ;; holds information about variables indexes in core cluster function call
  var					; the compared variable
  pos					; indexed position
  low					; >= var ..
  high					; <= var ..
  ineqs					; inequality values of var
  rempred 
  ;; List of predicates in rest that would be removed if this index applies
  )

(defun get-cc-comp (var compl)
  "Get CC-COMP record in COMPL for specified variable"
  (car (isome compl (f/l (comp)(eq (cc-comp-var comp) var)))))

(defun rewrite-mbtindex (rw)
  (let* (compdata;; cc-comp structures for indexed variables in 
	 ;; this core MBT cluster
         (ro (car (rewrite-this rw)))
         (this (rewrite-this rw))
         (rest (rewrite-rest rw))
         (bnd (rewrite-bnd rw))
         (bpat (rewrite-bpat rw))
	 (pos 0)
	 match op comp ind)
    (cond ((or (null rest) (null (get-mbtindexes ro))) 
	   ;; no MBT index for this relation
           'substitute)
          ((dotimes (pos (length bpat))
	     ;; test for index on bound arguments in call
             (and (eq (nth pos bpat) '-);; bound pos
                  (getindex ro pos t);; indexed
                  (return t)));; then use index on bound position instead
	   'substitute)
	  (t (dolist (var (cdr this))
	       ;; Build compdata table of index props in call:
	       (and (neq var '*)
		    (symbolp var)
		    (setq ind (get-mbtindex-at ro pos))
		    (null (get-cc-comp var compdata))
		    (setq compdata (cons (make-cc-comp :var var :pos pos) 
					 compdata)))
	       (1++ pos))
	     
	     (dolist (p rest);; Go through rest to find indexed inequalities:
	       (cond ((not (and (eq (length p) 3)
				(memq (setq op (generic-fnname (car p)))
				      '(< <= > >=)))))
		     ;; suspect inequality pred
		     ((setq comp (get-cc-comp (second p) compdata)) 
		      (if (variable-is-bound (third p) bnd)
			  (rewrite-ccluster-ineq op p
						 (second p) (third p) comp)))
		     ((setq comp (get-cc-comp (third p) compdata))
		      ;; TT 2012-04-02 Inverse inequality rule : (x < y) <==> y >=x and y != x
		      (if (variable-is-bound (second p) bnd)
			  (rewrite-ccluster-ineq (inv-logop op) p
						 (third p) (second p) comp t)))))
	     (cond ((setq match (get-best-mbt-index compdata))
		    (setf (rewrite-translated rw)
			  ;; generic implementation handling varying width
			  (list* 'call 'mbt-select-range
				 _mbt-select-range_
				 ;; foreign function holding MBT-SELECT-RANGE
                                 ro;; the relation
				 (cc-comp-pos match);; index position
				 (cc-comp-low match);; low range >
 				 (cc-comp-high match);; high range <
				 (cdr this)));; remaining arguments
		    (setf (rewrite-rest rw)
			  (nconc 
			   (mapcar (f/l (ineq)
					(list _notequal_ 
					      (cc-comp-var match) ineq)) 
				   (cc-comp-ineqs match))
			   (subset 
			    rest 
			    (f/l (p)
				 (not (memq p 
					    (cc-comp-rempred match)))))))
		    'success)
		   (t 'substitute))))))

(putprop 'mbtree 'index-rewriter 'rewrite-mbtindex)

(defun get-best-mbt-index (compdata)
  "Get first index where some indexed variable is bound"
  (car (isome compdata 
	      (f/l (comp)(or (cc-comp-high comp)
			     (cc-comp-low comp))))))

;; TT 2012-04-02 Inverse inequality rule : (x < y) <==> y >=x and y != x
(defun rewrite-ccluster-ineq (op pred var val comp &optional neqtest)
  (selectq op
	   (<=  (set-high-bound comp val)
	       (if neqtest 
		   (add-cc-neq-test val comp)))	       
           (>= (set-low-bound comp val)
	       (if neqtest 
		   (add-cc-neq-test val comp)))	       	   
           (< (set-high-bound comp val)
              (add-cc-neq-test val comp))
           (> (set-low-bound comp val)
              (add-cc-neq-test val comp))               
	   nil) 
  (setf (cc-comp-rempred comp) (adjoin pred (cc-comp-rempred comp))))

(defun add-cc-neq-test (val comp)
  (setf (cc-comp-ineqs comp)(adjoin val (cc-comp-ineqs comp))))

;; TT 2012-08-20 Update low bound if needed
(defun set-low-bound (comp val)
  (let ((oldval (cc-comp-low comp)))
    (cond ((null oldval)
	   (setf (cc-comp-low comp) val))
	  ((= (compare val oldval) 1) ;; val > oldval
	   (setf (cc-comp-low comp) val)))))

;; TT 2012-08-20 Update high bound if needed
(defun set-high-bound (comp val)
  (let ((oldval (cc-comp-high comp)))
    (cond ((null oldval)
	   (setf (cc-comp-high comp) val))
	  ((= (compare val oldval) -1) ;; val < oldval
	   (setf (cc-comp-high comp) val)))))

;;; Index selection TBR function:

(defun mbt-select-range (obj fno pos lower upper &optional rest)
  (map-btree (index-rows 
	      (get-mbtindex-at fno pos)) 
	     lower upper
	     (f/l (key row)
		  (if (arrayp row)
		      (apply 'osql-result 
			     fno pos lower upper (arraytolist row))
		    (dolist (r row)
		      (apply 'osql-result 
			     fno pos lower upper (arraytolist r))))
		  t			; to get more rows!
		  )))

(defun init-mbtree()
  (setq _notequal_ (get-most-specific-resolvent '!= '(object object)))
  (setq _mbt-select-range_ 
	(create-function mbt-select-range 
			 ;; function to hold generic B-tree implementation 
			 ((function ro)	; indexed relation
			  (integer pos)	; indexed position
			  (object low)	; low range
			  (object high)	; high renge
			  )
			 ()		; result ignored
			 as foreign (mbt-select-range)))
  (create-function mbt-select-cost ((function)(vector)(vector))((real)(real))
		   as foreign (mbt-select-cost))

  (declarecosts _mbt-select-range_ '*any* 'mbt-select-cost)
  )


(defun mbt-select-cost (o fno bp args)
  (let ((ro (aref args 0)))
    (if (relationp ro)
	(let* ((rc (relation-cardinality ro))
	       (d (max 1 (* 4 (log rc 500)))))
	  (osql-result fno bp args d 4))
      (osql-result fno bp args 10 4))))

