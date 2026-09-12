(setq _use_dnf_ t); make sure predicates are in disjunctive normal form before optimization!!!!
(defstruct planinfo plan bound rem cost fanout)
(defun dynprogsort (l bnd)
;;; L is an AND predicate to be optimized.
;;; BND is a list of the initially bound variables in L.
;;; Reorder L using dynamic programming:
  (if l
      (let (queue			; Priority queue of cost investigated (partial) plans.
	    bestplan oldplan oldbound oldrem oldcost oldfanout 
	    bpat predcost predfanout predcost-fanout newplaninfo)
    (setq queue (list (make-planinfo :plan nil  ; Create queue and initialize it to contain
                                  :bound bnd
                                  :rem (if (eq (car l) 'AND) (cdr l) l)
                                                ; NOTE: on this build l arrives as a BARE list
                                                ; of predicates, with no leading AND tag —
                                                ; proven by a real run where a planinfo dump
                                                ; showed plan=1 + rem=3 = exactly the query's
                                                ; 4 predicates and no AND symbol anywhere.
                                                ; So a plain (cdr l), as the PDF's l1 example
                                                ; would suggest, silently dropped the first
                                                ; real predicate on every call. The eq check
                                                ; strips the tag only if one is actually
                                                ; present, so both shapes work — see
                                                ; run-log.md.
                                  :cost 0       ; a node with cost 0 and fanout 1
                                  :fanout 1)))					
	(while t
	  (cond 
	   ( (null queue)			; If the queue is empty, then...
	    (amos-error "Query not executable" (andify l))))
	  ; NOTE: ALisp's `sort` does not honor the `:key` keyword the way
	  ; CommonLisp's does — a prior version here, (sort queue '< :key
	  ; 'planinfo-cost), ended up calling `<` directly on raw planinfo
	  ; STRUCTS instead of their extracted cost fields, producing
	  ; "Error 10, Not a number: #(PLANINFO ...)" as soon as the queue
	  ; held more than one element. Fixed with a manual linear scan,
	  ; extracting (planinfo-cost p) explicitly at each comparison
	  ; instead of relying on :key — see run-log.md.
	  (setq bestplan (car queue))	; The plan in the queue with lowest total cost
	  (dolist (p (cdr queue))
	    (if (< (planinfo-cost p) (planinfo-cost bestplan))
		(setq bestplan p)))
	  (setq queue (removeeq bestplan queue) )		; Remove BESTPLAN from priority queue
	  (if (null (planinfo-rem bestplan)) ; If BESTPLAN is a complete plan, return that plan.
          (return (planinfo-plan bestplan)))
	  ; NOTE: return the BARE predicate list, not (andify ...). The PDF's
	  ; l1 -> l2 example shows both wrapped in AND, but on this build the
	  ; optimizer passes l in as a bare list of predicates (proven by a real
	  ; run: a planinfo dump showed plan=1 + rem=3 = exactly the query's 4
	  ; predicates, no AND symbol anywhere) and expects a bare list back.
	  ; Wrapping the result in AND made the caller walk the returned list,
	  ; treat the leading AND symbol as a predicate, and fail with
	  ; "Error 3, Not a list: AND" — see run-log.md.
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
                        ; => (50 . 1.78571), a dotted pair: (car ...) is 50
          (setq predcost (car predcost-fanout))  ; the cost of executing
		  (setq predfanout (cdr predcost-fanout)) ; the fanout of executing
					; PRED with the binding
					; pattern BPAT
                        ; (cdr ...) on the same (50 . 1.78571) pair is 1.78571
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
                    ; and bpat = (+ -)
                    ; then (substbindadorned pred bpat) will be:
                        ; (#[OID 1516 "P_TOURNAMENT.YEAR->INTEGER"] _V2 _V3)
                    ; (unchanged here since year->integer needs no physical
                    ; rewrite for this binding pattern; contrast with `>`,
                    ; which substbindadorned rewrites into (CALL GT-- ...)
                    ; once its binding pattern is known — see run-log.md)
				:bound (pred_binds pred oldbound)
					; the variables that are bound
					; after PRED has been executed
                    ; if pred = (#[OID 1516 "P_TOURNAMENT.YEAR->INTEGER"] _V2 _V3)
                    ; and oldbound = '(_V3)
                    ; then (pred_binds pred oldbound) will be:
                        ; (_V2 _V3) — meaning _V2 and _V3 are both bound now;
                        ; this becomes the new oldbound for the next iteration.
                        ; Before running year(_V2) = _V3, only _V3 (= 1950) was
                        ; bound; after running it, _V2 (a specific tournament)
                        ; becomes bound too, so both are now known.
                    ; Confirmed by a real run: (pred_binds pred '(_V3)) => (_V2 _V3)
                    ; (see run-log.md).
                    ; NOTE: passing the full, accumulated oldbound (e.g. (_V2 _V3),
                        ; everything bound by every predicate placed so far) is
                        ; always safe — you never need to trim it down.
				:rem (removeeq pred oldrem) ; removeeq removes pred from oldrem
					; by eq identity, leaving the remaining predicates
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