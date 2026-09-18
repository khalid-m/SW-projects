;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Tore Risch, UDBL
;;; $RCSfile: basic.lsp,v $
;;; $Revision: 1.3 $ $Date: 2013/01/26 17:27:07 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Basic Lisp functionality
;;; =============================================================
;;; $Log: basic.lsp,v $
;;; Revision 1.3  2013/01/26 17:27:07  torer
;;; Integer overflow handling
;;;
;;; Revision 1.2  2012/03/19 19:38:34  torer
;;; read-token at eof bug
;;;
;;; Revision 1.1  2012/01/06 13:14:54  torer
;;; Separate Lisp and mexima tests
;;;
;;; =============================================================

(defun bslash ()(let ((ts (maketextstream)))
		  (print "\\a" ts)
		  (closestream ts)
		  (read ts)))

(checkequal
 "Lisp reader"
					; dotted pairs
 ((read "6.17865E+06") 6.17865E+06)
 ((car (read "(1 . 2)")) 1)
 ((cdr (read "(1 . 2)")) 2)
 ((length (read "(. 2)")) 2)
 ((apply #'car '((1 2))) 1)		; read dispatches
 ((arraytolist (aref (read "#(1 #(2 3) 4)") 1)) '(2 3))
 ((eval (read "`(1 2 ,(+ 1 3))")) '(1 2 4))
 ((eval (read "`(1 2 ',(list 1 2 3))")) '(1 2 '(1 2 3)))
 ((eval (read "`(1 2 ',@ (list 1 2 3))")) '(1 2 (quote 1 2 3)))
 ((eval `(funcall #',(list 'lambda '(x) 'x) 1)) 1)
 ((bslash) "\\a")
 ((read "(") '*eof*)
 )

(checkequal "Read token"
            ((with-textstream s "12 1.23( \"a b c\""
			      (list (read-token s)(read-token s)(read-token s)
				    (read-token s)))
	     '(12 1.23 "(" "a b c"))
            ((with-textstream s "Andrej" 
		 (read-token s) (textstreamstring s)) "Andrej")
            )
       
(checkequal "equality"
	    ((equal 1 1.0) t)
	    ((equal #(1 1.0) #(1.0 1)) t)
	    )

(checkequal "Arrays"
	    ((equal (make-array 100000)(make-array 100000)) t)
            ((adjustable-array-p (adjust-array (vector) 50)) t)
	    )

(checkequal "macros"
	    ((subset '(1 2 3) '1+) '(1 2 3)) 
	    )

(checkequal "memory leaks"
	    ((alloccnt 'list '(subset '(1 2 3) 'cons)) 0)
	    ((alloccnt 'array 
		       '((lambda(bt)
			   (put-btree (vector 1) bt (vector 1))
			   ;;(put-btree (vector 1) bt (vector 1))
			   (get-btree (vector 12) bt)
			   nil)
			 (make-btree))) 0)
	    )

(let ((h1 (make-hash-table :size 10))
      (h2 (make-hash-table :size 10 :test (function eq)))
      (h3 (make-hash-table :size 10 :test (function equal)))
      (arr (make-array 3 :adjustable t))
      (k (list 1))
      )
  (setf (gethash (list 1) h1) 1)
  (setf (gethash k h2) 1)
  (setf (gethash (list 1) h3) 1)
  (setf (gethash 2 h1) 2)
  (setf (gethash 2 h2) 2)
  (setf (gethash 2 h3) 2)
  (setf (gethash arr h3) 12)
  (rplaca k 2) 
  (checkequal "Hash tables"
	      ((gethash (list 1) h1) nil)
	      ((gethash (list 2) h2) nil)
              ((gethash k h2) 1)
	      ((gethash (list 1) h3) 1)
	      ((gethash 2 h1) 2)
	      ((gethash 2 h2) 2)
	      ((gethash 2 h3) 2)
              ((gethash arr h3) 12)
	      )
  )

(defun bighash (n)
  (let ((ht (make-hash-table :test 'equal)))
    (dotimes (i n)(setf (gethash (vector i) ht) i))))

(defun bighash-vector (n)
  (let ((ht (make-hash-table :test 'equal)))
    (dotimes (i n)(setf (gethash (vector (random 100)(random 100)
                                         (random 100)(random 100)) 
				 ht) i))))

(checkequal "Hash scalability"
	    ((< (time-spent (bighash 10000)) 0.1) t)
	    )


(checkequal "Extra string functions"
	    ((string-explode "sen massa  strings" " ")
	     (list "sen" "massa" "" "strings"))
	    ((string-explode "sen massa  strings" "s")
	     (list "" "en ma" "" "a  " "tring" ""))
	    ((string-find "sen massa  strings" "massa")
	     4)
	    ((string-find "sen massa  strings" "masssa")
	     nil)
	    )

(defglobal _long-max_ 2147483646)

(checkequal "Overflow arithmetics"
	    ((round (- (+ _long-max_ 10000)10000)) _long-max_)
	    ((round (+ (+ (minus _long-max_) -1000)1000)) (minus _long-max_))
	    ((round (+ (- (minus _long-max_) 1000)1000)) (minus _long-max_))
	    ((round (+ (- _long-max_ -1000)-1000)) _long-max_)
	    ((round (/ (* _long-max_ 10)10)) _long-max_)
	    ((round (/ (* (minus _long-max_) -10)10)) _long-max_)
	    ((round (/ (* _long-max_ -10)-10)) _long-max_)
	    ((round (/ (* -10 _long-max_ )-10)) _long-max_)
	    )