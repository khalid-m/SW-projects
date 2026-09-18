;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2000 Tore Risch, UDBL
;;; $RCSfile: hpt-rewrite.lsp,v $
;;; $Revision: 1.1 $ $Date: 2011/08/24 04:48:22 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Main Memory BTree index
;;; =============================================================
;;; 

(defstruct hptindex;; holder of main memory btree index of function
  pos;; argument/result position
  name;; name of position
  hptrie;; the btree
  )

(defglobal _notequal_) ; bound to AMOSQL function !=
(defglobal _hpt-select-range_) 
           ;;; bound to AmosQL functon MBT-SELECT-RANGE implementing
           ;;; B-tree search
(defun get-hptindexes (ro)
  (subset (relation-indexes ro)(f/l(ix)(eq (index-type ix) 'hptrie))))

(defun get-hptindex-at (ro pos)
  "Get the MBT index at position POS of core cluster function FNO"
  (dolist (i (get-hptindexes ro))
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

(defun rewrite-hptindex (rw)
  (let* (compdata;; cc-comp structures for indexed variables in 
	 ;; this core MBT cluster
         (ro (car (rewrite-this rw)))
         (this (rewrite-this rw))
         (rest (rewrite-rest rw))
         (bnd (rewrite-bnd rw))
         (bpat (rewrite-bpat rw))
	 (pos 0)
	 match op comp ind)
    (cond ((or (null rest) (null (get-hptindexes ro))) 
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
		    (setq ind (get-hptindex-at ro pos))
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
		      (if (variable-is-bound (second p) bnd)
			  (rewrite-ccluster-ineq (inv-logop op) p
						 (third p) (second p) comp)))))
	     (cond ((setq match (get-best-hpt-index compdata))
		    (setf (rewrite-translated rw)
			  ;; generic implementation handling varying width
			  (list* 'call 'hpt-select-range
				 _hpt-select-range_
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

(putprop 'hptrie 'index-rewriter 'rewrite-hptindex)

(defun get-best-hpt-index (compdata)
  "Get first index where some indexed variable is bound"
  (car (isome compdata 
	      (f/l (comp)(or (cc-comp-high comp)
			     (cc-comp-low comp))))))

(defun rewrite-ccluster-ineq (op pred var val comp)
  (selectq op
	   (<= (setf (cc-comp-high comp) val))
           (>= (setf (cc-comp-low comp) val))
           (< (setf (cc-comp-high comp) val)
              (add-cc-neq-test val comp))
           (> (setf (cc-comp-low comp) val)
              (add-cc-neq-test val comp))               
	   nil) 
  (setf (cc-comp-rempred comp) (adjoin pred (cc-comp-rempred comp))))

(defun add-cc-neq-test (val comp)
  (setf (cc-comp-ineqs comp)(adjoin val (cc-comp-ineqs comp))))

;;; Index selection TBR function:

(defun hpt-select-range (obj fno pos lower upper &optional rest)
  (map-hptrie 
             (get-index-identifier0 pos fno)
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

(defun init-hptrie()
  (setq _notequal_ (get-most-specific-resolvent '!= '(object object)))
  (setq _hpt-select-range_ 
	(create-function hpt-select-range 
			 ;; function to hold generic B-tree implementation 
			 ((function ro)	; indexed relation
			  (integer pos)	; indexed position
			  (object low)	; low range
			  (object high)	; high renge
			  )
			 ()		; result ignored
			 as foreign (hpt-select-range)))
  (create-function hpt-select-cost ((function)(vector)(vector))((real)(real))
		   as foreign (hpt-select-cost))

  (declarecosts _hpt-select-range_ '*any* 'hpt-select-cost)
  )


(defun hpt-select-cost (o fno bp args)
  (let ((ro (aref args 0)))
    (if (relationp ro)
	(let* ((rc (relation-cardinality ro))
	       (d (max 1 (* 4 (log rc 500)))))
	  (osql-result fno bp args d 4))
      (osql-result fno bp args 10 4))))

(init-hptrie)