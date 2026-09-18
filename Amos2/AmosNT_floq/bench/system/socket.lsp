;;; ===========================================================================
;;; AMOS2
;;; 
;;; Authors: (c) 2005 Tore Risch and Erik Zeitler, UDBL
;;; $RCSfile: socket.lsp,v $
;;; $Revision: 1.16 $ $Date: 2010/12/18 15:11:23 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Measuring speed of basic TCP communication
;;;              
;;; ===========================================================================

;;; NOTICE: Start nameserver before running these tests!
;;; E.g. by command amos2 -n
;;; Then initialize test by (setup-tests (gethostname)) if nameserver is local
;;;                         (setup-tests "<hostid>") for remote tests
;;; The following is tested:
;;; 1000 very short round trip messages: (test1)
;;; 1000 very short sends + reply messages: (test1b)
;;; 1000 100 bytes round trip messages: (test100)
;;; 1000 100 bytes sends + reply messages: (test100b)
;;; 1000 1000 bytes round trip messages: (test1000)
;;; 1000 1000 bytes sends + reply messages: (test1000b)
;;; 1000 4000 bytes round trip messages: (test4000)
;;; 1000 4000 bytes sends + reply messages: (test4000b)
;;; 1000 10000 bytes round trip messages: (test10000)
;;; 1000 20000 bytes sends + reply messages: (test20000b)
;;; 1000 40000 bytes sends + reply messages: (test40000b)
;;; 1000 80000 bytes sends + reply messages: (test80000b)

(defglobal _nameserver-port_) ; The port for communicating with nameserver

(defglobal _testplatform_ nil)

  ;;; Build test strings and initialize connection to nameserver on HOST
(defglobal l1 (buildn 100 t))		; list of 100 T
(setq l1 (apply 'concat l1))		; string with 100 T
(defglobal l2 (concat l1 l1))		; string with 200 T
(setq l2 (concat l2 l2))		; string with 400 T
(setq l2 (concat l2 l2))		; string with 800 T
(setq l2 (concat l2 l1 l1))		; length 1000
(defglobal l3 (concat l2 l2))		; 2000
(setq l3 (concat l3 l3))		; 4000
(defglobal l4 (concat l3 l3))		; 8000
(setq l4 (concat l4 l2 l2))		; 10000
(defglobal l4bin (make-binary 10000))	; 10000 binary
(defglobal l5 (concat l4 l4))		; 20000
(defglobal l6 (concat l5 l5))		; 40000
(defglobal l7 (concat l6 l6))		; 80000
(defglobal l8 (concat l7 l7 l6))             ; 200000
(defglobal l9 (concat l8 l8))                ; 400000
(defglobal l10 (concat l9 l9))                ; 800000

;(defglobal _testplatform_ 'bg)
(defglobal _mpi-receiver_ 1)
(defglobal _commstack_ 'tcp)

(defun setup-tests()
  ;;; Initilialize connection to nameserver on HOST:
  (if (neq _testplatform_ 'bg)
      (set-nameserverhost (gethostname)))
  (cond ((eq _commstack_ 'tcp)
	 (reval@nameserver 1)			; ping
	 (setq _nameserver-port_ (open-nameserver-port)))))	; port for NS communication

;(setup-tests) ; sets up test against nameserver on this host 

(defun sendtest (l)
  (selectq _commstack_
	   (tcp (send-form l _nameserver-port_))
	   (mpi (mpi-send-form l _mpi-receiver_))
	   (error "Illegal commstack" _commstack_)))

(defun revaltest (l)
  (selectq _commstack_
	   (tcp (reval@nameserver l))
	   (mpi (mpi-reval l _mpi-receiver_))
	   (error "Illegal commstack" _commstack_)))

(defun test1 ()(rptq 1000 (revaltest 1))) ; Short msg round trip 
; IBM X40 local (best of 4): 0.297
; Dual 3.2G Xeon (best of 4): 0.071335
; Hagrid (16K buffer): 0.076
; Dual IBM PPC970FX @ 2.2GHz: 0.058693
; Lenovo x300: 0.16

(defun test1b ()(rptq 1000 (sendtest 1))(revaltest 1))
; IBM X40 local (best of 4): 0.078
; Dual 3.2G Xeon (best of 4): 0.048
; Hagrid (16K buffer): 0.045
; Dual IBM PPC970FX @ 2.2GHz: 0.052303
; Lenovo x300: 0.02

(defun test100 ()(null(rptq 1000 (revaltest l1))))
; IBM X40 local (best of 4): 0.328
; Dual 3.2G Xeon (best of 4): 0.07983
; Hagrid (16K buffer): 0.082
; Dual IBM PPC970FX @ 2.2GHz: 0.069654
; lenovo x300: 0.16

(defun test100b ()(rptq 1000 (sendtest l1))(revaltest 1))
; IBM X40 local (best of 4): 0.078
; Dual 3.2G Xeon (best of 4): 0.022302
; Hagrid (16K buffer): 0.033
; Dual IBM PPC970FX @ 2.2GHz: 0.055519
; Lenovo x300: 0.035

(defun test1000 ()(null(rptq 1000 (revaltest l2))))
; IBM X40 local (best of 4): 0.547
; Dual 3.2G Xeon (best of 4): 0.182104
; Hagrid (16K buffer): 0.17
; Dual IBM PPC970FX @ 2.2GHz: 0.182016
; Lenovo x300: 0.27

(defun test1000b ()(rptq 1000 (sendtest l2))(revaltest 1))
; IBM X40 local (best of 4): 0.329
; Dual 3.2G Xeon (best of 4): 0.052435
; Hagrid (16K buffer): 0.041
; Dual IBM PPC970FX @ 2.2GHz: 0.093005
; Lenovo x300: 0.093

(defun test4000()(null(rptq 1000(revaltest l3))))
; IBM X40 local (best of 4): 1.297
; Dual 3.2G Xeon (best of 4): 
; Hagrid (2K buffer): 80s !
; Hagrid (16K buffer): 0.50 !
; Dual IBM PPC970FX @ 2.2GHz: 80s !
; Lenovo x300: 0.58

(defun test4000b ()(rptq 1000 (sendtest l3))(revaltest 1))
; IBM X40 local (best of 4): 0.75
; Dual 3.2G Xeon (best of 4): 0.13101
; Hagrid (16K buffer): 0.15
; Dual IBM PPC970FX @ 2.2GHz: 0.213826
; Lenovo x300: 0.16

(defun test10000()(null(rptq 1000(revaltest l4))))
; IBM X40 local (best of 4): 2.843
; Dual 3.2G Xeon (best of 4): 
; Hagrid (2K buffer): 80s !
; Hagrid (16K buffer): 0.95
; Dual IBM PPC970FX @ 2.2GHz: 80s !
; Levovo x300: 1.11

(defun test10000bin()(null(rptq 1000(revaltest l4bin))))
; IBM X40 local (best of 4): 2.62
; IBM X40 bulk write/read, byte read: 0.75
; Dual 3.2G Xeon (best of 4): 
; Hagrid (2K buffer) : 80s !
; Hagrid (16K buffer): 0.14
; Dual IBM PPC970FX @ 2.2GHz: 80s !
; Lenovo x300: 0.281

(defun test10000b ()(rptq 1000 (sendtest l4))(revaltest 1))
; IBM X40 local (best of 4): 1.328
; Dual 3.2G Xeon (best of 4): 0.353681
; Hagrid (16K buffer): 0.29
; Dual IBM PPC970FX @ 2.2GHz: 0.456616
; Lenovo x300: 0.33

(defun test10000binb ()(rptq 1000 (sendtest l4bin))(revaltest 1))
; IBM X40 local (best of 4): 1.42
; IBM X40 bulk write: 0.484
; Dual 3.2G Xeon (best of 4): 0.055911
; Hagrid (16K buffer): 0.052
; Dual IBM PPC970FX @ 2.2GHz: 0.07572
; Lenovo x300: 0.11

(defun test20000b ()(rptq 1000 (sendtest l5))(revaltest 1))
; IBM X40 local (best of 4): 2.907
; Dual 3.2G Xeon (best of 4): 0.801129
; Hagrid (16K buffer): 0.50
; Dual IBM PPC970FX @ 2.2GHz: 0.863569
; Lenovo x300: 0.66

(defun test40000b ()(rptq 1000 (sendtest l6))(revaltest 1))
; IBM X40 local (best of 4): 5.484
; Dual 3.2G Xeon (best of 4): 1.71147
; Hagrid (16K buffer): 0.97
; Dual IBM PPC970FX @ 2.2GHz: 1.66839
; Lenovo x300: 1.19

(defun test80000b ()(rptq 1000 (sendtest l7))(revaltest 1))
; IBM X40 local (best of 4): 10.84
; Dual 3.2G Xeon (best of 4): 3.58887
; Hagrid (16K buffer): 1.98
; Dual IBM PPC970FX @ 2.2GHz: 3.28995
; Lenovo x300: 2.49

(defun test200kb ()(rptq 1000 (sendtest l8))(revaltest 1))
; Hagrid (16K buffer): 5.56
; IBM X40 local (best of 4): 27.36
; Lenovo x300: 6.01

(defun test400kb ()(rptq 1000 (sendtest l9))(revaltest 1))
; Hagrid (16K buffer): 11.7
; IBM X40 local (best of 4): 52.11
; Lenovo x300: 13.3

(defun test800kb ()(rptq 1000 (sendtest l10))(revaltest 1))
; Hagrid (16K buffer): 22.8
; IBM X40 local : 105.1
; Lenovo x300: 27.5


;;;;;;;;;;;;;;;; Scaling sending binary arrays ;;;;;;;;;;;;;;;;;;;

(defun binrt (bytes num)
  "Measuring time for num number of synchronous
   (round trip) messages and bandwidth in Mbit/s"
  (let ((ti (clock)) delta)
    (rptq num (revaltest (make-binary bytes)))
    (setq delta (- (clock) ti))
    (cons (* 8 num (/ bytes (* 0.5 1000000 delta))) delta))) ; RT = 2 messages

; NB: For correct measurements of asynchronous messages,
; the synchronization time must be subtracted.
; Hence time is subtracted for an extra revaltest.

(defun binst (bytes num)
  "Measuring time for num number of outbound
   asynchronous messages and bandwidth in Mbit/s"
  (let ((ti (clock)) delta)
    (rptq num (sendtest (make-binary bytes)))
    (revaltest 1);; synchronize
    (setq delta (- (clock) ti))
    (let ((c (clock)))
      (revaltest 1);; subtract turnover time for synchronization
      (setq delta (- delta (- (clock) c))))
    (cons (* 8 num (/ bytes (* 1000000 delta))) delta)))

(defun binibst (bytes num)
  "Measuring time for num number of inbound
   asynchronous messages and bandwidth in Mbit/s"
  (let ((ti (clock)) delta)
    (rptq num (sendtest (bquote (make-binary , bytes))))
    (revaltest 1);; synchronize
    (setq delta (- (clock) ti))
    (let ((c (clock)))
      (revaltest 1);; subtract turnover time for synchronization
      (setq delta (- delta (- (clock) c))))
    (cons (* 8 num (/ bytes (* 1000000 delta))) delta)))

; Bytes    Hagrid-st  Hagrid-rt  BGFront-st  BGFront-rt
; 10         0.20       0.23        0.18       0.25
; 100        2.20       2.14        1.83       2.45
; 1000      38.7       20.7        37.0       23.1
; 10000    202.2      132.1       204        145
; 100000   263.3      240.7       309        292
; 1000000  164.0      177.2       216        234
