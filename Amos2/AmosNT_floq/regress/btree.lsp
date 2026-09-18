;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Tore Risch, UDBL
;;; $RCSfile: btree.lsp,v $
;;; $Revision: 1.1 $ $Date: 2012/01/06 13:14:54 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Testing basic BTREE functionality
;;; =============================================================
;;; $Log: btree.lsp,v $
;;; Revision 1.1  2012/01/06 13:14:54  torer
;;; Separate Lisp and mexima tests
;;;
;;; =============================================================

(defglobal _btree_ (make-btree))

(defun populate-btree (bt)
  (dolist (row '(#(0 1 0 137372) #(11 1 0 137375)
		 #(24 1 0 137371) #(26 1 0 137373)
		 #(39 0 1 101) #(42 0 1 106)
		 #(50 1 0 138147) #(50 1 0 138149)
		 #(50 1 0 138150) #(52 1 0 137374) 
		 #(62 1 1 137377) #(65 0 1 102)
		 #(83 1 1 137376) #(89 1 1 137378)))
    (put-btree row bt t)))

(populate-btree _btree_)

(defun bt-rangemap (bt from to stopafter)
  (let ((cnt 0))
    (map-btree bt from to (f/l (x)
			       (1++ cnt)
			       (if (>= cnt stopafter) nil t)))
    cnt))

(defun bt-fullmap (bt stopafter)
  (bt-rangemap bt '* '* stopafter))
 
(defun all-kv-pairs (bt)
  (let ((kvs (tconc)))
    (map-btree bt '* '* (f/l (k v)
			     (tconc kvs (list k v))))
    (car kvs)))

(checkequal "B-tree search"
            ((get-btree #(24 1 0 137371) _btree_) t)
            ((bt-fullmap _btree_ 100) 14)
            ((bt-fullmap _btree_ 5) 5)
            ((bt-rangemap _btree_ #(24 * * *) #(50 1 0 138148) 100) 5)
            ((bt-rangemap _btree_ #(24 * * *) #(50 * * *) 100) 7)
            ((bt-rangemap _btree_ #(50 * * *) #(50 * * *) 100) 3)
            ((bt-rangemap _btree_ #(50 1 0 138149) '* 100) 7)
            ((bt-rangemap _btree_ '* #(50 1 0 138149) 100) 8)
            ((all-kv-pairs _btree_)
             '((#(0 1 0 137372) T) (#(11 1 0 137375) T) (#(24 1 0 137371) T) 
	       (#(26 1 0 137373) T) (#(39 0 1 101) T) (#(42 0 1 106) T) 
	       (#(50 1 0 138147) T) (#(50 1 0 138149) T) (#(50 1 0 138150) T) 
	       (#(52 1 0 137374) T) (#(62 1 1 137377) T) (#(65 0 1 102) T) 
	       (#(83 1 1 137376) T) (#(89 1 1 137378) T)))
	    )

(checkequal "B-tree deletion"
	    ((get-btree  #(39 0 1 101) _btree_) t)
	    ((delete-btree #(39 0 1 101) _btree_) t)
	    ((get-btree  #(39 0 1 101) _btree_) nil)
            ((bt-fullmap _btree_ 100) 13)
            ((all-kv-pairs _btree_)
             '((#(0 1 0 137372) T) (#(11 1 0 137375) T) (#(24 1 0 137371) T) 
	       (#(26 1 0 137373) T) (#(42 0 1 106) T) (#(50 1 0 138147) T) 
	       (#(50 1 0 138149) T) (#(50 1 0 138150) T) (#(52 1 0 137374) T) 
	       (#(62 1 1 137377) T) (#(65 0 1 102) T) (#(83 1 1 137376) T) 
	       (#(89 1 1 137378) T)))
	    )

(defun test-btree-rollin ()
  (checkequal "Rollin of B-tree"
	      ((all-kv-pairs _btree_)
               '((#(0 1 0 137372) T) (#(11 1 0 137375) T) (#(24 1 0 137371) T)
		 (#(26 1 0 137373) T) (#(42 0 1 106) T) (#(50 1 0 138147) T) 
		 (#(50 1 0 138149) T) (#(50 1 0 138150) T) (#(52 1 0 137374) T)
		 (#(62 1 1 137377) T) (#(65 0 1 102) T) (#(83 1 1 137376) T) 
		 (#(89 1 1 137378) T)))
              ))

(register-init-form '(test-btree-rollin))

