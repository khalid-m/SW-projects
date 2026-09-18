;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1993 Joakim Naes, Ex-jobb, CAELAB
;;; $RCSfile: randomopt.lsp,v $
;;; $Revision: 1.18 $ $Date: 2010/04/17 10:34:17 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Randomized optimizer
;;; =============================================================
;;; $Log: randomopt.lsp,v $
;;; Revision 1.18  2010/04/17 10:34:17  torer
;;; Limitation removed for setting 1st arg of optlevel
;;;
;;; Revision 1.17  2008/12/27 21:01:08  torer
;;; Correct error message
;;;
;;; Revision 1.16  2007/09/27 11:49:16  ruslan
;;; randomization is improved. SH works better now.
;;;
;;; Revision 1.15  2007/02/27 16:43:33  ruslan
;;; one more bug is fixed. it was also about using the stacks. refreshtopall was impelemented and used.
;;;
;;; Revision 1.14  2007/02/22 16:31:51  torer
;;; Reentrant RANDOM-OPT
;;;
;;; Revision 1.13  2007/02/20 12:08:37  ruslan
;;; rollback the changes again
;;;
;;; Revision 1.9  2006/06/08 09:38:26  torer
;;; Slighly faster neighbour generation
;;;
;;; Revision 1.8  2006/06/07 20:24:55  torer
;;; Unbounded sequence heuristics now checked in
;;;
;;; Revision 1.7  2006/06/07 17:58:16  torer
;;; Unbounded sequence heuristics
;;; Trace messages for randomized optimization
;;;
;;; Revision 1.6  2006/06/07 14:22:40  torer
;;; Set seed to make randomized optimizer deterministic
;;;
;;; Revision 1.5  2006/06/07 13:46:21  torer
;;; Randomized optimization over foreign functions work
;;;
;;; Revision 1.4  2006/06/05 10:07:03  torer
;;; Randomized optimizer first tries initial predicate order
;;;
;;; =============================================================


(randominit 73267) ;initial seed of the random function


;;;**************** NEW FANOUT FUNCTIONS *************************                 

;; The Randomized optimization algorithm

(defglobal fanout-array  nil) ;store the  fanout for each predicate.
(defglobal cost-array    nil) ;store the cost of each predicate.
(defglobal bounded-array nil) ;store the bound variables for
                           ; each position in the ObjectLogprogram.
(defglobal _state_ nil)
(defglobal _minstate_ nil)
(defglobal _fanout-ht_ nil)

;;----------------------------------------------------------------------------
(defglobal fanout-array-stack  nil)
(defglobal cost-array-stack    nil)
(defglobal bounded-array-stack nil)
(defglobal _state_-stack nil)
(defglobal _minstate_-stack nil)
(defglobal _fanout-ht_-stack nil)
(defglobal _iino_ 5)
(defglobal _shno_ 5)

(defvar *error-state* nil)

(defun set-optlevel (iino shno)
  (/setglobal '_iino_ iino)
  (/setglobal '_shno_ shno))

;Stack operations
 (defun top (stack) (if (null stack) nil (car stack)))

(defun popall()
  (pop fanout-array-stack)
  (pop bounded-array-stack)
  (pop cost-array-stack)
  (pop _state_-stack)
  (pop _minstate_-stack)
  (pop _fanout-ht_-stack)
  (topall))

(defun pushall(l size)
  (push (make-array size) fanout-array-stack)
    (push (make-array size) bounded-array-stack)
    (push  (make-array size) cost-array-stack)
    (push  (listtoarray l) _state_-stack)
    (push (listtoarray l) _minstate_-stack)
    (push (make-hash-table :size (* 2 size):test (function equal))
       _fanout-ht_-stack))

(defun topall ()
  (setq fanout-array    (top fanout-array-stack))
    (setq bounded-array (top bounded-array-stack))
    (setq cost-array    (top cost-array-stack))
    (setq _state_       (top _state_-stack))
    (setq _minstate_    (top _minstate_-stack))
    (setq _fanout-ht_   (top _fanout-ht_-stack)))

(defun refreshtopall ()
  (pop fanout-array-stack)
  (pop bounded-array-stack)
  (pop cost-array-stack)
  (pop _state_-stack)
  (pop _minstate_-stack)
  (pop _fanout-ht_-stack)
  (push fanout-array    fanout-array-stack)
  (push bounded-array bounded-array-stack)
  (push cost-array    cost-array-stack)
  (push _state_       _state_-stack)
  (push _minstate_    _minstate_-stack)
  (push _fanout-ht_   _fanout-ht_-stack))



(defun simple-pred-cost (pred bpat)
   "compute cost and fanout of simple predicate"
   (if (or (and (eq? (car pred) 'call)(dtr? (cadr pred)))(dtr? (car pred)))
      (dtr-simple-pred-cost pred bpat)
      (let* ((cpred (getcalledpred pred)) fo lc 
             (pcost (getdeclaredcosts cpred bpat)))
         (cond ((eq pcost 'default)
                (setq fo (fanout cpred bpat))
                (if fo (cons (localcost cpred bpat) fo)))
               ((setq fo (cadr pcost)) (cons (car pcost) fo))
               (t nil)))))               ; costhint = NIL => illegal binding pattern
(defun random-opt (l bnd)
  (randominit 73267)
  (let ((size (length l))
        *error-state*)
    (pushall l size)
    (topall)
    (unwind-protect
	(if (valid _state_ 0 size bnd)
	    (if (= size 1)
		(fixl l bnd)
	      (progn
		(IISH bnd size _iino_ _shno_)
		(fixl (arraytolist _minstate_) bnd)))
	  (non-exec-error (getcalledpred (aref _state_ *error-state*)) 
			  (aref bounded-array *error-state*)))
      (popall);; makes code reentrant
      )))

;;; *************************ITERATIVE IMPROVEMENT *********************

(defun Iterative_Improvement (bnd size nr_lm)
  (let* ((mincost (maxreal)))
    (dotimes (x nr_lm)
      (and (init-arrays _state_ bnd size)
	   (let ((tcost (local_minimum size)))
             (printopt "Local minimim #" (1+ x) " in II: " tcost t)
	     (if (< tcost  mincost) 
		 (progn
		   (let ((temp _state_))
		     (setq _state_ _minstate_)
		     (setq _minstate_ temp)
		     (refreshtopall))
		   (setq mincost tcost)))))
      (if (/= x 0) (random_state _state_ bnd size)))
    mincost))

  
;;; ***************** SEQUENCE HEURISTIC ***************************


(defun IISH (bnd size nr_lm nr_walks)
  (let (( mincost (iterative_improvement bnd size nr_lm))
        lmincost)
    (printopt "Cost after Iterative Improvement:" mincost t) ;
    (array-copy _state_ _minstate_ size)
    (init-arrays _minstate_ bnd size)
    (refreshtopall)
    (dotimes (x nr_walks)
      (printopt "Random walk #" (1+ x) t)
      (random_walk size size bnd)
      (update size)
      (let ((lmincost (local_minimum size)))
	(printopt "Local Minimum #" (1+ x) ": " lmincost t) ;
	(cond
	 ((< lmincost mincost)
	  (setq mincost lmincost)                
	  (array-copy _minstate_ _state_ size)
	  (refreshtopall))
	 (t 
	  (array-copy _state_ _minstate_ size)
	  (init-arrays _state_ bnd size)
	  (refreshtopall)))))
    (printopt "cost:" mincost t)
    mincost))


(defun update (size)
;;; updates the arrays after random_walk
  (dotimes (x size)
     (let ((cst (fsimple-pcost (aref _state_ x)
                               (bindadornpat (aref _state_ x) 
                                                     (aref bounded-array x)))))
       (setf (aref cost-array x) (car cst))
       (setf (aref fanout-array x) (cdr cst)))))


;;; ******************* RANDOM WALK **************************

(defun random_walk (len size bnd)
;;; makes random walks in the state space
  (dotimes (x (1- len))
     (let ((neighbour (random_neighbour _state_ size)))
       (cond (neighbour
              (setf (aref bounded-array (1+ neighbour))        
                    (pred_binds 
                     (getcalledpred (aref _state_ (1+ neighbour)))
                     (aref bounded-array neighbour)))
              (swap _state_ neighbour (1+ neighbour)))))))


;;; ******************* LOCAL MINIMUM ************************

;(defun local_minimum(size)
;;; finds a local minimum
;  (let* ((nrloops (/ size 2))
;         (last1 (1- size))
;         (last2 (- size 2))
;         (move1 0)
;         (move2 last2)
;         (count 0))
;    (while (< count nrloops)    ;;; local optimization
;      (setq count (1+ count))
;      (cond
;       ((and (allowed (aref _state_ (1+ move1)) (aref bounded-array move1))
;             (better_cost move1 _state_))
;        (swap _state_  move1 (1+ move1))
;        (if (= move1 0) 
;            (setq move2 last2)
;          (setq move2 (1- move1)))
;        (setq count 0)))
;      (setq move1 (if (= move1 last2) 0 (1+ move1)))
;      (cond 
;       ((and (allowed (aref _state_ (1+ move2)) (aref bounded-array move2))
;              (better_cost move2 _state_))
;        (swap _state_  move2 (1+ move2))
;        (if (= move2 last2) 
;            (setq move1 0)
;          (setq move1 (1+ move2)))
;        (setq count 0)))
;      (setq move2 (if (= move2 0) last2 (1- move2))))
;    (totalcost size 0)))

(defun local_minimum (size)
"Peforms a local search to cheaper states. The first cheaper state is accepted
and the search is continued from that state until no more cheaper states can
be found in size steps. It does not swap preds in pos 1 and n"
  (let* ((nrloops size)
	 (modulo (- size 1)) 
	 (count 0) 
	 (pos (mod (random 1000) modulo))) ;a very random init pos
   (while (< count nrloops)
      (setq count (1+ count))
      (cond ((and (allowed  (aref _state_ (1+ pos))
			    (aref bounded-array pos))
		  (better_cost pos _state_))
	     (setq count 0)
	     (swap _state_ pos  (1+ pos)))
	    (t (setq pos (mod (1+ pos) modulo))))))
      (totalcost size 0))

(defun fsimple-pcost (pred bpat)
;;; calculates the fanout and the cost of a predicate  
  (or (gethash (cons pred bpat) _fanout-ht_)
      (setf (gethash (cons pred bpat) _fanout-ht_) 
            (simple-pred-cost (getcalledpred pred) bpat))))
 
(defun init-arrays (state bnd size)            
;;; initialize the arrays with values on C F and bound variables.
  (let ((bind bnd))
    (null (dotimes (x size)
	    (let  ((pc (fsimple-pcost (aref state x)
				      (bindadornpat (aref state x) bind))))
	      (if (null pc) (return t))
	      (write-arrays (car pc)(cdr pc) bind x)
	      (setq bind (pred_binds (getcalledpred (aref state x)) bind))
	      nil)))))


(defun write-arrays (c f b i)
;;; writes to the i:th position in the arrays
  (setf (aref fanout-array  i) (and f(float f)))
  (setf (aref cost-array    i) c)
  (setf (aref bounded-array i) b))

    
(defun valid (state x size bnd)
;;; checks if a state can be executed. if so 
;;; an executabe state is computed. 
  (cond 
   ((= x size) t)
   (t (let ((res (valid2 state x size bnd)))
        (cond 
         ((= res nil) (setq *error-state* x) nil)
         (t (swap state x res)
            (valid state (1+ x) size 
                   (pred_binds (getcalledpred (aref state x )) bnd))))))))

  
(defun valid2 (state x size bnd)
;;; checks if there is any executable predicate 
;;; for position x in the ObjectLog program.
  (cond
   ((= x size) nil)
   ((allowed (aref state x) bnd) x)
   (t (valid2 state (1+ x) size bnd))))


(defun get-allowed-pred (state bnd start size)
;;; finds a predicate that can be executed on place start in 
;;; the ObjectLog program
  (let ((counter (* 2 size)) 
	(r (+ start (random (- size start)))))
    (while (and (not (allowed (aref state r) bnd)) (> counter 0))
      (1-- counter)
      (setq r (+ start (random (- size start)))))
    r))


(defun random_state (state bnd size)
;;; calculates a random state
  (let ((bind bnd))
    (dotimes (x size)
             (let ((i (get-allowed-pred state bind x size)))
               (swap state x i)
               (let ((pc (fsimple-pcost (aref state x) 
                                        (bindadornpat (aref state x) bind))))
                 (write-arrays (car pc)(cdr pc) bind x)
                 (setq bind (pred_binds (getcalledpred (aref state x)) 
                                        bind)))))))

           
(defun totalcost (size count)
;;; computes the total cost of an ObjectLog program
  (cond ((= size count) 0.0)
        (t (+ (aref cost-array count)
              (* (aref fanout-array count)
                 (totalcost size (+ 1 count)))))))

                                    
(defun allowed (pred bnd)
;;; tests if the predicate is executable with the binding bnd.
  (or (relationp (car pred))
      (let ((bpat (bindadornpat pred bnd)))
	(and (moderesolvable pred bpat)
	     (getdeclaredcosts pred bpat)))))

(defun random_neighbour (state size)
;;; calculates a random neighbour of state.
  (let* ((modulo (- size 1))
	 (r (mod (random 1000) modulo))
	 (count 0))
    (while (and (not (allowed (aref state (1+ r)) (aref bounded-array r)))
                (< count 10))
      (setq count (1+ count))
      (setq r (mod (random 1000) modulo)))
    (if (= count 10) nil r)))


(defun swap (state element1 element2)
;;; swap places of two elements in an array.
  (let ((temp (aref state element1)))
    (setf (aref state element1) (aref state element2))
    (setf (aref state element2) temp)))


(defun array-copy (arr1 arr2 size)
;;; copies the elements in one array to another.
  (dotimes (x size)
           (setf (aref arr1 x) (aref arr2 x))))


(defun better_cost (nnr state)
;;; checks if a move to a neighbour improves the state.
;;; if it does the arrays are updated.
  (let* ((nnr1 (1+ nnr))
         (cst1 (fsimple-pcost (aref state nnr1)
                              (bindadornpat (aref state nnr1)
                                            (aref bounded-array nnr))))
         (b (pred_binds (getcalledpred (aref state nnr1))
                        (aref bounded-array nnr)))
         (cst2  (fsimple-pcost (aref state nnr) 
                               (bindadornpat (aref state nnr) b))))
    (and cst1 cst2
	 (cond ((< (+ (car cst1) (* (cdr cst1) (car cst2)))
		   (+ (aref cost-array nnr)
		      (* (aref fanout-array nnr)
			 (aref cost-array nnr1))))
		(setf (aref cost-array    nnr)  (car cst1))
		(setf (aref cost-array    nnr1) (car cst2))
		(setf (aref fanout-array  nnr)  (cdr cst1))
		(setf (aref fanout-array  nnr1) (cdr cst2))
		(setf (aref bounded-array nnr1)  b)
		t)))))

(defun maxreal () 9.9e99)
;;; defines the maximum real the system allows


(defun fixl (l  bnd) 
;;; add information to foreign predicates to the optimized ObjectLog program. 
  (cond ((null l) nil)
        (t (cons (substbindadorned (car l) (bindadornpat (car l) bnd))
                 (fixl (cdr l) (pred_binds (getcalledpred (car l)) bnd))))))












