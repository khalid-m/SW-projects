;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Tore Risch, UDBL
;;; $RCSfile: index.lsp,v $
;;; $Revision: 1.13 $ $Date: 2012/01/05 14:26:28 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Benchmarking efficiency of index methods
;;; =============================================================
;;; $Log: index.lsp,v $
;;; Revision 1.13  2012/01/05 14:26:28  torer
;;; New hooks: AFTER_IMAGE_WRITTEN AFTER_IMAGE_READ
;;;
;;; Revision 1.12  2011/12/31 14:17:41  torer
;;; Scalability test for mexi. Slow rollout!
;;;
;;; Revision 1.11  2011/12/29 11:37:39  torer
;;; Added measurements of original MBT on HP 2.8 GHz
;;;
;;; Revision 1.10  2011/05/02 07:42:18  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.9  2011/05/02 07:34:47  thatr500
;;; do not supply dynamic library extension
;;;
;;; Revision 1.8  2011/04/27 15:57:24  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.7  2011/04/20 22:36:38  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.6  2011/04/20 00:09:01  thatr500
;;; added benchmarks for LinearHashing (dll) and BT(dll).
;;;
;;; Revision 1.5  2008/02/08 10:13:01  torer
;;; *** empty log message ***
;;;
;;; Revision 1.4  2007/12/28 14:51:05  torer
;;; Benchmarking MBT
;;;
;;; Revision 1.3  2007/11/28 22:08:31  torer
;;; Benchmark update
;;;
;;; Revision 1.2  2007/11/28 21:25:14  torer
;;; Added b-tree index benchmark
;;;
;;; Revision 1.1  2007/11/17 15:28:46  torer
;;; Benchmarking index efficiency
;;;
;;; =============================================================

;;; All measurements using Visual Studio C++ 6.0 compiler

(defglobal hw)

;;; Hashing

(osql "
logging off;
create function tester1(integer)->integer;")

(defglobal fno (theresolvent 'tester1))


(setq hw (high-watermark))
(dotimes (i 1000000)(addfunction0 fno (list i)'(1) t))
(setq hw (- (high-watermark) hw))

;;; 2.93 s (X40)
;;; Space usage: 49.4 MB

(rptq 1000000 (proccall fno #(500000)))

;;; 1.41 s (X40)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Btrees

(setq _default-indextype_ 'mbtree)

(osql "
logging off;
create function tester2(integer)->integer;")

(defglobal fno2 (theresolvent 'tester2))

(defun test-build (size)
  (let ((bt (make-btree))(sz (* size 2)))
    (rptq size (put-btree (random sz) bt t))
    bt))

(defun build-and-free (size)
  (test-build size)
  nil)

(build-and-free 1000000)
;;: Dell E6320, no mexi: 2.02
;;; Dell E6320, mexi: 2.022


(setq hw (high-watermark))
(dotimes (i 1000000)(addfunction0 fno2 (list i)'(1) t))
(- (high-watermark) hw)


;;; 8.2s (X40) original MBTree implementation
;;; 5.0s (X40) improved MBTree implementation
;;: 4.83 (X40)
;;; Space usage: 48.9 MB
;;; 1.28 (HP Intel i7, 2.8 GHz)
;;; Space usage: 48.4 MB
;;; Dell E6320: 2.1 s, 48 MB
;;; Dell E6320, mexima: 1.86 s

(setq hw (high-watermark))
(rollout "foo.dmp")
(- (high-watermark) hw)
;;; Dell E6320, no mexima: 0.27
;;; Dell E6320, mexima: 0.90 + 36MB!

(rptq 1000000 (proccall fno2 #(500000)))

;;; 3.70 s (X40) original MBTree implementation
;;; 2.63 s (X40) improved MBTree implementation
;;; 0.82 s (HP Intel i7, 2.8 GHz)
;;; Dell E6320: 1.19s
;;; Dell E6320 mexima: 1.06 s 
;;;;;;;;;;;;;;;;;; testing B-tree population and removal

(defun populate-btree (n)
  (let ((btree (make-btree))(n2 (* 2 n)))
    (rptq n (put-btree (vector (random n2)1 2 3 4) btree t))
    nil))

(populate-btree 500000)

;;; Insert only B-tree:
;;; X40:
;;; f=2:  3.61
;;; f=10: 3.19
;;; f=18: 3.34
;;; f=32: 2.95
;;; f=52: 3.02
;;; f=86: 3.01
;;; f=140: 3.22
;;; f=226: 3.42
;;; 0.82 (HP Intel i7, 2.8 GHz)
;;; Dell E6320: 1.61 s
;;; Dell E6320 mexima: 1.58 s

(defun popaccess-btree (n)
  (let ((btree (make-btree))(n2 (* 2 n)))
    (rptq n (put-btree (vector (random n2)1 2 3 4) btree t))
    (rptq n2 (get-btree (vector (random n2)1 2 3 4) btree))
    nil))

(popaccess-btree 500000)
;;; Insert + 2 search b-tree:
;;; Linear seraching B-tree nodes:
;;; x40
;;; f=2:  ---
;;; f=10: 22.41
;;; f=18: 15.75
;;; f=32: 16.03
;;; f=52: 19.27
;;; f=86: 23.67
;;; f=140: 31.53
;;;;;;;  Binary searching B-tree nodes:
;;; f=10: 25.05
;;; f=18: 14.70
;;; f=32: 11.52
;;; f=52: 11.23
;;; f=86: 10.57
;;; f=140: 9.98
;;; f=226: 10.17
;;; 3.26 (HP Intel i7, 2.8 GHz)
;;; Dell E6320: 5.62
;;; Dell E6320 mexima: 5.33 s



;;----------------------------------------------------------------
;; Linear Hashing as a DLL
;;----------------------------------------------------------------
;;; All measurements using Visual Studio C++ 6.0 compiler
(osql "imagesize 1000000000;")
(defglobal hw)

(osql "
logging off;
register_exindextype('LINH', 'C:linh.dll', FALSE);
create function tester1(integer i)->integer j;
create function tester2(integer i)->Bag of Integer j;
")

(osql "create_index('tester1', 'i', 'LINH','multiple');")

(defglobal fno1 (theresolvent 'tester1))

(defglobal fno2 (theresolvent 'tester2))

(setq hw (high-watermark))

(defun populate (n fno)
  (dotimes (i n)(addfunction0 fno (list (random n)) '(1) t)))

(populate 10000000 fno1)

(populate 10000000 fno2)

(setq hw (- (high-watermark) hw))

(rptq 1000000 (proccall fno1 #(500000)))

(rptq 1000000 (proccall fno2 #(500000)))

;;---------------------------
;; Building index size = 10x7
;;---------------------------
;; Linh : 14.981 s
;;        14.774 s
;;        14.919 s 
;; Hash : 17.881 s
;;        17.88  s  
;;        17.935 s
;;--------------------------
;; Accessing index = 10 x 7
;;--------------------------
;; Linh : 0.561 s 
;;        0.558 s
;;        0.762 s
;; Hash : 0.664 s 
;;        0.64  s
;;        0.65  s
;;----------------------------------------------------------------
;; BTree as a DLL
;;----------------------------------------------------------------
;;; All measurements using Visual Studio C++ 6.0 compiler

(osql "imagesize 1000000000;")

(defglobal hw)

(osql "
logging off;
register_exindextype('BT', 'C:bt', FALSE);
create function tester1(integer i)->Integer j;
create function tester2(integer i)->Integer j;
")

(osql "create_index('tester1', 'i', 'BT','multiple');")

(osql "create_index('tester2', 'i', 'MBTree','multiple');")

(defglobal fno1 (theresolvent 'tester1))

(defglobal fno2 (theresolvent 'tester2))

(defun populate (n fno)
  (dotimes (i n)(addfunction0 fno (list (random n)) '(1) t)))

;; Aggressively remove elements
(defun remove-e (n fno)
  (dotimes (i n)(remfunction0 fno (list i) '(1) t)))

;; FNO1
(setq hw (high-watermark))

;; Insertion 1
(populate 10000000 fno1)

(rptq 1000000 (proccall fno1 #(500000)))

(remove-e 10000000 fno1)

;; Insertion 2
(populate 10000000 fno1)

(rptq 1000000 (proccall fno1 #(500000)))

(remove-e 10000000 fno1)

(setq hw (- (high-watermark) hw))

;;-------------FNO2-------------
(setq hw (high-watermark))
;; Insertion 1
(populate 10000000 fno2)

(rptq 1000000 (proccall fno2 #(500000)))

(remove-e 10000000 fno2)
;; Insertion 2
(populate 10000000 fno2)

(rptq 1000000 (proccall fno2 #(500000)))

(remove-e 10000000 fno2)

(setq hw (- (high-watermark) hw))

;;---------------------------
;; Building index size = 10x7
;;---------------------------
;; BT     : 21.247 s
;;          21.17  s 
;;          21.656 s
;; MBTREE : 31.752 s
;;          31.746 s
;;          32.409 s
;;--------------------------
;; Accessing index = 10 x 7
;;--------------------------
;; BT     : 0.795 s 
;;          0.805 s
;;          0.802 s
;; MBTREE : 1.02  s 
;;          1.026 s
;;          1.102 s
