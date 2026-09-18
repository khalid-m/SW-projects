;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997/8 Vanja Josifovski, EDSLAB
;;; $RCSfile: qd_cost.lsp,v $
;;; $Revision: 1.16 $ $Date: 2006/04/22 06:39:46 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: cost calculation for the distributed cost based optimization
;;; =============================================================


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; cost function parameters and weight functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Holds the cost of transfer per byte among the nodes
(defglobal NetHt (make-hash-table :test 'equal))

; Holds the performance index of different amos servers
(defglobal CpuHt (make-hash-table :test 'equal))

;(defglobal DefaultN0 50)   ; Network initialization cost (CPU dependent)
;(defglobal DefaultNet 10)  ; Default cost of transfer per byte
;(defglobal DefaultCpu 1)

(defglobal DefaultN0 10)   ; Network initialization cost (CPU dependent)
(defglobal DefaultNet 1)  ; Default cost of transfer per byte
(defglobal DefaultCpu 0.1)

(defun get_cpu_weight (db) 
  (or (gethash db CPUHt) DefaultCPU))

(defun set_cpu_weight (db value)
  (setf (gethash db CPUHt) value))

(defun get_net_weight (db1 db2)
  (if (eq db1 db2) 
      0
    (or (gethash (concat db1 "->" db2) NetHt) DefaultNet)))

(defun set_net_weight (db1 db2 value)
  (setf (gethash (concat db1 "->" db2) NetHt) value))

(defun Net0 (flag db)
  (* DefaultN0 (if (> flag 0) 1 0) (get_cpu_weight db)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Decomposition tree cost calculation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun get_tNode_fanout (tree)
  (let* ((mbl (tNode-mbl tree))
	 (sae (tNode-sae tree))
	 (ppl (tNode-ppl tree))
	 ;Estimate the selectivity of joins by cross-products.
	 ;In reality this should be done by estimating the join sizes
	 ;of the joins among the results of the functions in a same list 
	 ;(mbl or ppl). For mbl this is if the tables are joined before they
	 ;are send in SAE. If not (only projection is done), 
         ;the duplicate removal should be accounted for. Note: (*) returns 1!
	 (mblFanout (apply #'* (mapcar #'tNode-fanout mbl)))
	 ;for ppl the fanout is correct since the functions in ppl do not have
	 ;common non-local variables 
	 (pplFanout (apply #'* (mapcar #'gNode-fanout ppl)))
	 (saeFanout (if sae (gNode-fanout sae) 1)))
    (* mblFanout saeFanout pplFanout)))

(defun get_tNode_res (tree)
  "Given a tree node calculates the tuple of result variables."
  (let* ((mbl (tNode-mbl tree))
	 (sae (tNode-sae tree))
	 (ppl (tNode-ppl tree))
	 (rem (tNode-rem tree))
	 (mblRes (unionl (mapcar (function tNode-res) mbl)))
	 (pplRes (unionl (mapcar (function gNode-vars) ppl)))
	 (saeRes (if sae (gNode-vars sae)))
	 (input *query_argl*)
	 (rest (union 
		(unionl (mapcar (function gNode-vars) rem))
		*query_resl*))
	 (allvars (unionl (list mblRes pplRes saeRes)))
	 (notBoundVars (set-difference allvars input))
	 (res (intersection notBoundVars rest)))
    res))

(defun get_tNode_cost (tree)
  "Given a tree node calcluates the cost of the execution."
  (let* ((db  (tNode-db tree))
	 (sae (tNode-sae tree))
	 (mbl (tNode-mbl tree))
	 (ppl (tNode-ppl tree))
	 (pplCost   (if ppl (tNode-pplCost tree) 0))
	 (saeDb     (if sae (gNode-db sae) db))
	 (saeArgs   (if sae (gNode-vars sae))) 
	 (saeFanout (if sae (gNode-fanout sae) 1))
	 (saeTsize  (if sae (tuple_size (gNode-vartypes sae)) 0))
	 (saeCost   (if sae (gNode-cost sae) 0))
	 (NetPSae   (get_net_weight saeDb db))
         (mblCost (apply #'+
			(mapcar (f/l (mb) (cost_mb_child mb db saeArgs saeDb))
				mbl)))
	 (mblFanout (apply #'* (mapcar #'tNode-fanout mbl)))
	 (saeShipCost (+ (* saeTsize mblFanout saeFanout NetPSae) 
			 (Net0 NetPsae db)))
	 (saeCpuCost  (* mblFanout saeCost (get_cpu_weight saeDb)))
	 (pplCpuCost  (* mblFanout saeFanout pplCost (get_cpu_weight 'LOCAL))))
    (+ mblCost saeShipCost SaeCpuCost pplCpuCost)))

(defun cost_mb_child (tree dbp args2 db2)
  "Calculate the cost induced by a single mb child."
  (if (not tree)
      0
    (let* ((dbT (tNode-db tree))
	   (costT (tNode-cost tree))
	   (fanoutT (tNode-fanout tree))
	   (resT (tNode-res tree))
	   (tsizeResT (tuple_size (tNode-restypes tree)))
	   (tsizeMb2 (tuple_size (mapcar (function tree_var_type) 
					(intersection resT args2))))
	   (NetP2 (get_net_weight dbP db2))
	   (NetTP (get_net_weight dbT dbP)))
      (+ costT ;cost of the subtree
	 ;cost of the shiping of the subtree result to the current tree node site
	 (* NetTP tsizeResT fanoutT) ;per shiped byte  
	 (Net0 NetTP dbT) ;initialization cost
	 ;cost of the shipping of the input to the SAE site
	 (* NetP2 tsizeMb2  fanoutT) ;per shiped byte
	 (Net0 NetP2 dbP))))) ;initialization cost 

(defun tuple_size (resl)
  "Given a list of type names calculates the size of a tuple with this types."
  (let ((reslist (mapcar (f/l (tp) (if (symbolp tp) 
				       (catch-error (gettypenamed tp)) tp)) 
			 resl)))
    (apply (function +)
	   (mapcar (f/l (tp)
			(cond ((ut_p tp) 4)
			      ((eq _integer_ tp) 4)
			      ((eq _charstring_ tp) 20)
			      ((eq _boolean_ tp) 1)
			      ((eq _real_ tp) 8)
			      ((eq _number_  tp) 8)
			      (t 10)))
		 reslist))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; execution cost of a function
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun get_cost (fn bpat db)
  "Compute the cost for a function and a binding pattern in the originating db"
  (if (extern_obj? fn);; handle external objects during View Expansion
      (remote-eval (list 'get_cost (kwote (second fn)) (kwote bpat) ''LOCAL)
		   (mkstring db))
    ;; the old case (no view expansion)
    (let ((fno (getfunctionnamed fn))
	  (*use_materialized_bags* t)
	  (*optmethod* _MDB_COST_ALG_)
	  (*DSVE-STRATEGY* 'dsve-none))
      (cond 
       ((eq db 'LOCAL)
	(obsolete-exec-cost-of-fn fno bpat))
       (t (let* ((oname (oid-origname fno))
		 (name (if oname oname (getobject fno 'name))))
	    (remote-eval (list 'get_cost 
			       (kwote name)
			       (kwote bpat)
			       ''LOCAL)
			 (mkstring db))))))))

(defun obsolete-exec-cost-of-fn (fn bpat)
  "Old code retained just to make QD work"
  (if (and (eq fn _makebag_) (all-butlast bpat))
      (list 5 1); Very ugly coding!! (TR)	
    (exec-cost-of-tbr fn bpat)))		

