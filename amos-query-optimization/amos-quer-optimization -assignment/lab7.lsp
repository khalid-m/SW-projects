(setq _use_dnf_ t); make sure predicates are in disjunctive normal form before optimization!!!!
(defun dynprogsort (l bnd)
;;; L is an AND predicate to be optimized.
;;; BND is a list of the initially bound variables in L.
;;; Reorder L using dynamic programming:
  (if l
      (let (queue			; Priority queue of cost investigated (partial) plans.
	    bestplan oldplan oldbound oldrem oldcost oldfanout 
	    bpat predcost predfanout predcost-fanout newplaninfo)
	(setq queue ###### )		; Create queue and initialize it to contain
					; a node with cost 0 and fanout 1
	(while t
	  (cond 
	   ( ######			; If the queue is empty, then...
	    (amos-error "Query not executable" (andify l))))
	  (setq bestplan ######)	; The plan in the queue with lowest total cost
	  (setq queue ###### )		; Remove BESTPLAN from priority queue
	  ( ###### )			; If BESTPLAN is a complete plan, return that plan.
	  (setq oldplan (planinfo-plan bestplan))
	  (setq oldbound (planinfo-bound bestplan))
	  (setq oldrem (planinfo-rem bestplan))
	  (setq oldcost (planinfo-cost bestplan))
	  (setq oldfanout (planinfo-fanout bestplan))
	  (dolist (pred oldrem)		; for all the remaining predicates do ...
		  (setq bpat (bindadornpat pred oldbound)) ;PRED's binding pattern
                    ; e.g. from assignment description (page 81): 
                        ; pred:  => (#[OID 356 P_TOURNAMENT.YEAR->INTEGER] _V2 _V3)
                        ; oldbound: '(_v3)
                        ; bpat: (+ -)          
		  (setq predcost-fanout (simple-pred-cost pred bpat)); the cost of executing PRED
					; with the binding pattern (e.g., (+ -))
					; BPAT, NIL if not executable
                    ; e.g. page 81: (simple-pred-cost pred '(+ -))
                        ; (50 . 1.78571) => car takes 50
          (setq predcost (car predcost-fanout))  ; the cost of executing
		  (setq predfanout (cdr predcost-fanout)) ; the fanout of executing
					; PRED with the binding
					; pattern BPAT
                        ; (50 . 1.78571) => cdr takes 1.78571
		  (cond (predcost
			 (setq newplaninfo 
			       (make-planinfo
				:plan (append oldplan 
					      (list (substbindadorned 
						     pred bpat)))
					; the new, extended (partial) plan
				:bound (pred_binds pred oldbound)
					; the variables that are bound
					; after PRED has been executed
				:rem (removeeq pred oldrem) 
					; the remaining predicates
				:cost ( ###### )    
					; the cost after PRED 
					; has been executed
				:fanout ( ###### ) 
					; the fanout after PRED
					; has been executed
				))
			 (setq queue ( ###### newplaninfo queue))
					; put extended plan into queue
			 )))))))