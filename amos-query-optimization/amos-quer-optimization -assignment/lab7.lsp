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
                        ; run as:  (bindadornpat '(#[OID 1516 "P_TOURNAMENT.YEAR->INTEGER"] _V2 _V3) '(_V3))        
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
		  (cond (predcost ; Only proceed to build/enqueue an extended plan 
                          ; if predcost is non-nil — i.e. pred is actually 
                          ; executable under this binding pattern. This is the guard that discards impossible orderings instead of ever pricing them.
			 (setq newplaninfo 
			       (make-planinfo
				:plan (append oldplan 
					      (list (substbindadorned 
						     pred bpat)))
					; the new, extended (partial) plan
                    ; For example:
                    ; if pred = (#[OID 1516 "P_TOURNAMENT.YEAR->INTEGER"] _V2 _V3)
                    ; bpat = (+ -) 
                    ; (list (substbindadorned  pred bpat)))) will be:
                        ;(#[OID 1516 "P_TOURNAMENT.YEAR->INTEGER"] _V2 _V3) 
				:bound (pred_binds pred oldbound)
					; the variables that are bound
					; after PRED has been executed
                    ; if pred = (#[OID 1516 "P_TOURNAMENT.YEAR->INTEGER"] _V2 _V3)
                    ; and  = '(_V3)
                    ; so the output of  (pred_binds pred oldbound) will be:
                        ; this: (_V2 _V3), meaning both of _V2 and _V3 is bound becomes => oldbound
                        ; This is because before running year(_V2) = _V3, only _V3 = 1950 is bound
                        ; but after running both _V3(1950) and _V2(a specific tournamnet) is bound
                    ; NOTE: passing the full, accumulated oldbound (e.g. (_V2 _V3), everything 
                        ; bound by every predicate placed so far) is always safe — you never need to trim it down
				:rem (removeeq pred oldrem) ; removeeq presumably removes pred from the list by eq identity,
					; the remaining predicates
				:cost (+ oldcost (* oldfanout predcost))    
					; the cost after PRED 
					; has been executed
				:fanout (* oldfanout predfanout) 
					; the fanout after PRED
					; has been executed
				))
			 (setq queue ( cons newplaninfo queue))
					; put extended plan into queue
			 )))))))