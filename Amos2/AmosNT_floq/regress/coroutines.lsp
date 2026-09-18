;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2008 Tore Risch, UDBL
;;; $RCSfile: coroutines.lsp,v $
;;; $Revision: 1.23 $ $Date: 2013/06/29 15:33:46 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Testing ALisp coroutines
;;; =============================================================
;;; $Log: coroutines.lsp,v $
;;; Revision 1.23  2013/06/29 15:33:46  torer
;;; New function
;;; diota(Number freq, Number l, Number u) -> Stream of Number
;;; for delayed iota()
;;;
;;; Revision 1.22  2013/06/26 17:45:26  torer
;;; Reverting (CO-SLEEP)
;;;
;;; Revision 1.20  2013/02/28 05:14:29  torer
;;; Now works with OSX
;;;
;;; Revision 1.19  2013/02/24 09:35:57  torer
;;; Added linefeed
;;;
;;; Revision 1.18  2013/02/23 13:32:53  torer
;;; Background coroutines seem not woring under OSX
;;;
;;; Revision 1.17  2012/07/23 20:27:59  torer
;;; Errors can now be caught through coroutines
;;;
;;; Revision 1.16  2011/10/18 12:46:29  larme597
;;; co-vresumev test crashes in Unix. Only tested in Windows for now.
;;;
;;; Revision 1.15  2011/09/19 13:46:16  larme597
;;; Changed co-vresumev regression.
;;;
;;; Revision 1.14  2011/08/23 12:10:58  larme597
;;; co-vresumev regression. co-terminatedv -> co-allterminatedv
;;;
;;; Revision 1.13  2010/05/01 16:38:38  torer
;;; Higher time limit in test for single processor
;;;
;;; Revision 1.12  2009/09/21 13:00:41  torer
;;; Extended tests of killing coroutines
;;;
;;; Revision 1.11  2009/09/02 18:19:21  torer
;;; Testing for memory leak
;;;
;;; Revision 1.10  2009/08/03 11:02:51  torer
;;; Testing combined coroutines and closures
;;;
;;; Revision 1.9  2009/06/30 13:56:13  larme597
;;; *** empty log message ***
;;;
;;; Revision 1.8  2009/06/16 15:00:41  larme597
;;; Two regression tests of co-resumev added.
;;;
;;; Revision 1.7  2009/04/03 17:39:34  torer
;;; TIME-SPENT to kernel
;;;
;;; Revision 1.6  2009/01/08 21:25:00  torer
;;; More regression
;;;
;;; Revision 1.5  2009/01/06 15:08:00  torer
;;; Time threshold increased
;;;
;;; Revision 1.4  2009/01/03 12:51:34  torer
;;; Testing CO-SLEEP in C
;;;
;;; Revision 1.3  2008/11/19 07:52:04  torer
;;; groupby not ready yet
;;;
;;; Revision 1.2  2008/09/29 17:14:23  torer
;;; Sleep that does not block main thread subqueries
;;;
;;; Revision 1.1  2008/09/23 21:05:04  torer
;;; Added coroutines to ALisp. See regress/coroutines.lsp.
;;;
;;; =============================================================

(defun ciota (l u)
  (cond ((> l u) nil)
        (t (ciota (+ l (co-yield l)) u) 0)))

(defun sum (fn args)
  (sum1 (coroutine fn args) 0))

(defun sum1 (co s)
  (let ((r (co-resume co 2)))
    (if (co-terminated co) s (sum1 co (+ s r)))))

(defun thrower (n)
  (throw 'foo (+ 1 n)))

(defun co-killtest (resumes)
  (let ((cr (coroutine 'ciota '(1000 100000))))
    (rptq resumes (co-resume cr 1))
    (co-terminated (co-kill cr))))

(storagestat t)

(checkequal "Coroutines"
            ((co-resume (coroutine '+ '(1 2))) 3)
	    ((sum 'ciota '(3005 3008)) 6012)
            ((catch 'foo (co-resume (coroutine 'throw '(foo 1)))) 1)
	    ((catch 'foo (co-resume (coroutine 'thrower '(1000)))) 1001)
            ((co-terminated (co-kill (coroutine 'ciota '(1000 3000)))) t)
            ((alloccnt 'coroutine '(coroutine '+ '(1 2))) 0) ;; leak test
            ((alloccnt 'coroutine '(co-resume (coroutine '+ '(1 2)))) 0)      
            ((co-killtest 0) t)
            ((co-killtest 1) t)
            ((co-killtest 10) t)
            ((alloccnt 'coroutine '(co-killtest 0)) 0)
            ((alloccnt 'coroutine '(co-killtest 1)) 0)
            ((alloccnt 'coroutine '(co-killtest 10)) 0)
            ((errstring (co-resume (coroutine '+ '(1 a)))) "Not a number")
	    )


(foreign-lispfn zip((bag b1)(bag b2))((object))
		(let ((co1 (coroutine 'mapbag (list b1 'co-yield)))
		      (co2 (coroutine 'mapbag (list b2 'co-yield))))
		  (while (not (and (co-terminated co1)(co-terminated co2)))
		    (if (not (co-terminated co1))
			(let ((r (co-resume co1)))
			  (if (consp r) (foreign-result (car r)))))
		    (if (not (co-terminated co2))
			(let ((r (co-resume co2)))
			  (if (consp r) (foreign-result (car r))))))))

(checkequal 
 "coroutine merge operator"
 ((osql "zip(iota(1,3),iota(10,13));") '((1) (10) (2) (11) (3) (12) (13)))
 ((osql "count(zip(zip(iota(1,1000),iota(1000,2000)),
                    zip(iota(1,1000),iota(1000,2000))));") '((4002)))
 )

(checkequal 
 "Non-blocking sleep in parallel"
 ((< (time-spent (osql "zip(diota(0.1,3,8),diota(0.1,9,14));")) 0.9) t)
 )

(foreign-lispfn 
 vunion ((vector v)) ((integer))
 (let ((m (make-array (array-total-size v))))
   (maparray v
	     (f/l (b i)
		  (seta m i (coroutine 'mapbag (list b 'co-yield)))))
   (do ((val))
       ((co-allterminatedv m))
       (setq val (co-resumev m))
       (if val
	   (foreign-result (car val))))))

(foreign-lispfn sliota ((integer low) (integer high) (number sleep)) ((number))
		(defun _random (x)
		  (/ (* (random 1000) 
			x)
		     1000.0))
		(dotimes (count (1+ (- high low)))
		  (foreign-result (+ count low))
		  (co-sleep (_random sleep))))

(checkequal 
 "Coroutine vector union"
 ((osql "sort(vunion({bagof(sliota(1,10,0.01)),bagof(sliota(11,20,0.01))}));")
  '((#(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20))))
 )

(defun checkbusy ()
  (let ((m (make-array 1)))
    (seta m 0 (coroutine (f/l () (co-sleep 0.3) (co-yield 'fail))))
    (co-resumev m 0.2)))

(cond ((not (equal (system-environment) "Apple"))
       ;; does not work on Mac:
       (checkequal "co-resumev timeout"
		   ((checkbusy) '*BUSY*)
		   )))

(defun coclosure1 ()
  (let ((y 2))
    (co-resume (coroutine (f/l (fn)
			       (funcall fn 1)) 
			  (list (f/l (x)(+ x y)))))
    ))

(defun coclosure2 ()
  (let (co)
    (let ((y 2))
      (setq co (coroutine (f/l (fn)
			       (funcall fn 1)) 
			  (list (f/l (x)(+ x y))))))
    (co-resume co)))

(defglobal _z_ 3)

(defun coclosure3 ()
  (let (co)
    (let ((y 2))
      (setq co (coroutine (f/l (fn)
			       (funcall fn 1)) 
			  (list (f/l (x)(+ x y _z_))))))
    (co-resume co)))

(defun coclosure4 ()
  (let ((y 2))
    (co-resume (coroutine (f/l (fn)
			       (funcall fn 1)) 
			  (list (f/l (x)(+ x y _z_)))))))


(checkequal "Coroutines with closures"
	    ((coclosure1) 3)
	    ((coclosure2) 3)
	    ((coclosure3) 6)
	    ((coclosure4) 6)
	    )


(foreign-lispfn sliota2 ((number sl)(integer from)(integer to))((integer))
                (do ((r from))
		    ((> r to))
		    (foreign-result r)
		    (co-sleep sl)
		    (1++ r)))

(defun co-vresumev-test ()
  (do* ((a (caar (osql "streamof(sliota2(0.02, 1, 5));")))
	(b (caar (osql "streamof(sliota2(0.03, 1, 5));")))
	(co1 (coroutine 'mapbag (list a 'co-yield)))
	(co2 (coroutine 'mapbag (list b 'co-yield)))
	(v nil)
	(lst nil))
       ((co-allterminatedv (vector co1 co2)) lst)
       (setq v (co-vresumev (vector co1 co2)))
       (if (not (null (aref v 0)))
	   (setq lst (cons (car (aref v 0)) lst)))
       (if (not (null (aref v 1)))
	   (setq lst (cons (car (aref v 1)) lst)))
       (sleep 0.01)))

(if (equal (system-environment) "VisualC++")
    (checkequal "co-vresumev"
		((sort (co-vresumev-test) '<) '(1 1 2 2 3 3 4 4 5 5))
		))

(rollback)
