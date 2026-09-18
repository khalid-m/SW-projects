;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2000 Timour Katchaounov, UDBL
;;; $RCSfile: test-pq.lsp,v $
;;; $Revision: 1.2 $ $Date: 2001/02/16 12:28:07 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Test functions for the Priority Queue package
;;;              
;;; ===========================================================================


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Functions needed to perform the tests
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun permute-list (items)
  "Given a list of items, returns all possible permutations of the list.
   No duplicates allowed as they will be removed by 'remove'.
   To handle duplicates we need an array based version, where contents
   will not matter."
  (if (null items)
      '(nil)
      (let ((result nil))
        (dolist (item items)
          (dolist (permutation (permute-list (remove item items)))
            (push (cons item permutation) result)))
	result)))

(defvar *pq-type* 'heap)

(defun pq-pop-all-keys (pq)
  (case *pq-type*
    (heap (pq-pop-all pq 'key))
    (lst  (pql-pop-all pq 'key))))

(defun list-to-pq (ll)
    (case *pq-type*
      (heap
       (let ((pq (pq-make)))
	 (dolist (l ll)
	   (pq-push pq (first l) (second l)))
	 pq))
      (lst
       (let ((pql (pql-make)))
	 (dolist (l ll)
	   (pql-push pql (first l) (second l)))
	 pql))))

(defun parallel-nth (ll n)
  (let (result)
    (dolist (l ll)
      (setq result (cons (nth n l) result)))
    (nreverse result)))

(defun compare-all (ll)
  (let ((result T))
    (dotimes (i (length ll))
      (cond ((neq (length (unique (parallel-nth ll i))) 1)
	     (formatl t "error: i = " i " diff = " (parallel-nth ll i) t)
	     (setq result NIL))))
    result))

; test insertion of unique keys
(defun build-seq (start stop secondel &optional reverse)
  (let (res)
    (dotimes (i (- stop start))
      (push (list (+ 0.0 i start) secondel) res))
    (if reverse
	(nreverse res)
        res)))

(defun build-rand-seq (start stop secondel)
  (let (res)
    (dotimes (i (- stop start))
      (push (list (+ 0.0 (rand start stop)) secondel) res))
    (unique res)))

(defun time-push-all (lst type)
  (timer
   (let ((*pq-type* type))
     (list-to-pq lst)
    NIL)))

(defun test-pq (keys type &optional duplicates)
  "Very slow!"
  (let ((*pq-type* type)
	sorted-keys perms pqueues ordered-keys)
    (setq sorted-keys (sort (mapcar #'first keys) #'<))
    (if (null duplicates)
	(setq sorted-keys (unique sorted-keys)))
    (setq perms (permute-list keys))
    (formatl t "permutations ready" t)
    (setq pqueues (mapcar #'list-to-pq perms))
    (formatl t "pqs generated" t)
    (setq ordered-keys (mapcar #'pq-pop-all-keys pqueues))
    (setq ordered-keys (cons sorted-keys ordered-keys))
    (formatl t "ordered keys extracted" t)
    (compare-all ordered-keys)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generate test data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun gen-data ()
  (setq keys0 '((1 a) (3 b)))
  (setq keys1 '((1 a) (3 b) (3 c)))
  (setq keys2 '((1 a) (3 b) (3 c) (5 f)))
  (setq keys3 '((1 a) (3 b) (3 c) (5 f) (5 g)))
  (setq keys4 '((1 a) (3 b) (3 c) (3 d) (4 e) (5 f)))
  (setq keys5 '((1 a) (3 b) (3 c) (3 d) (4 e) (5 f) (5 g)))

  (setq fkeys1 '((1.0 a) (3.0 b) (3.0 c)))
  (setq fkeys4 '((1.0 a) (3.0 b) (4.0 c) (3.0 d) (4.0 e) (5.0 f)))

					; data to test insertion of duplicates
  (setq dup1 (buildn 10000 '(3.0 x)))
  (setq dup2 (buildn 10000 '(5.0 y)))
  (setq dup3 (buildn 10000 '(8.0 z)))
  (setq dup (append dup1 dup2 dup3))

  (setq forw1 (build-seq 1 100 'a NIL))
  (setq back1 (build-seq 1 100 'a T))
  (setq forw2 (build-seq 1 250 'a NIL))
  (setq back2 (build-seq 1 250 'a T))
  (setq forw3 (build-seq 1 500 'a NIL))
  (setq back3 (build-seq 1 500 'a T))
  (setq forw4 (build-seq 1 750 'a NIL))
  (setq back4 (build-seq 1 750 'a T))
  (setq forw5 (build-seq 1 1000 'a NIL))
  (setq back5 (build-seq 1 1000 'a T))
  (setq forw6 (build-seq 1 1250 'a NIL))
  (setq back6 (build-seq 1 1250 'a T))

  (setq rs1 (build-rand-seq 1 1000))
  (setq rs2 (build-rand-seq 1 2000))
  (setq rs3 (build-rand-seq 1 3000))
  (setq rs4 (build-rand-seq 1 4000))

  NIL)

(gen-data)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; tests for correctness
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(test-pq fkeys1 'heap)
(test-pq fkeys1 'lst)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; tests for performance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; mostly duplicate keys
(time-push-all dup 'heap) ;1.402 s
(time-push-all dup 'lst)  ;1.452 s

; keys sorted in increasing order
(time-push-all forw1 'heap) ;0.01 s
(time-push-all forw2 'heap) ;0.06 s
(time-push-all forw3 'heap) ;0.15 s
(time-push-all forw4 'heap) ;0.26 s
(time-push-all forw5 'heap) ;0.39 s
(time-push-all forw6 'heap) ;0.57 s

(time-push-all forw1 'lst) ;0.01 s
(time-push-all forw2 'lst) ;0.01 s
(time-push-all forw3 'lst) ;0.02 s
(time-push-all forw4 'lst) ;0.04 s
(time-push-all forw5 'lst) ;0.05 s
(time-push-all forw6 'lst) ;0.07 s

; keys sorted in decreasing order
(time-push-all back1 'heap) ;0.01 s
(time-push-all back2 'heap) ;0.04 s
(time-push-all back3 'heap) ;0.08 s
(time-push-all back4 'heap) ;0.13 s
(time-push-all back5 'heap) ;0.20 s
(time-push-all back6 'heap) ;0.27 s

(time-push-all back1 'lst) ;0.03 s
(time-push-all back2 'lst) ;0.21 s
(time-push-all back3 'lst) ;0.83 s
(time-push-all back4 'lst) ;1.87 s
(time-push-all back5 'lst) ;3.31 s
(time-push-all back6 'lst) ;5.17 s

; random keys (square distr)
(time-push-all rs1 'heap) ; 0.12 s
(time-push-all rs2 'heap) ; 0.37 s
(time-push-all rs3 'heap) ; 0.64 s
(time-push-all rs4 'heap) ; 0.921 s

(time-push-all rs1 'lst) ; 0.63 s
(time-push-all rs2 'lst) ; 2.54 s
(time-push-all rs3 'lst) ; 5.84 s
(time-push-all rs4 'lst) ; 10.46 s



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; simple 'manual' tests
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; HEAP-based PQ
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq pqh (pq-make :key-pred '< :data-pred 'equal :init-size 17 :grow-by 99))
(pq-push pqh 5.0 'a)
(pq-push pqh 3.0 'b)
(pq-push pqh 3.0 'c)
(pq-push pqh 2.0 'd)
(pq-push pqh 2.0 'e)
(pq-push pqh 2.0 'd)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LIST-based PQ
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq pql (pql-make))
(pql-push pql 5.0 'a)
(pql-push pql 3.0 'b)
(pql-push pql 3.0 'c)
(pql-push pql 2.0 'd)
(pql-push pql 2.0 'e)
(pql-push pql 2.0 'f)

(pql-peek pt)
(pql-pop pt)

(pql-push pt 2 'p2)
(pql-push pt 2 'p769)

(pql-pop-front pt 'data)
