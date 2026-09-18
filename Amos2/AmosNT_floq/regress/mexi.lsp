;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Tore Risch, Thanh Truong, UDBL
;;; $RCSfile: mexi.lsp,v $
;;; $Revision: 1.1 $ $Date: 2012/01/06 13:14:54 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Basic Mexima functionality
;;; =============================================================
;;; $Log: mexi.lsp,v $
;;; Revision 1.1  2012/01/06 13:14:54  torer
;;; Separate Lisp and mexima tests
;;;
;;; =============================================================

(defglobal _mexbt_ (make-btree))

(populate-btree _mexbt_)

(defun bite-my-tail (key bt)
  (let ((newkey (copy-array key)))
    (delete-btree key bt)
    (setf (aref newkey 0)(+ 100 (aref newkey 0)))
    (put-btree newkey bt 'x)))

(defun bite-all-tails (bt)
  (let ((cnt 0))
    (map-btree bt '* '* (f/l (k v)
			     (bite-my-tail k bt)
			     (1++ cnt)))
    cnt))

(checkequal "Bite the tail"
	    ((all-kv-pairs _mexbt_)
             '((#(0 1 0 137372) T) (#(11 1 0 137375) T) (#(24 1 0 137371) T) 
	       (#(26 1 0 137373) T) (#(39 0 1 101) T) (#(42 0 1 106) T) 
	       (#(50 1 0 138147) T) (#(50 1 0 138149) T) (#(50 1 0 138150) T) 
	       (#(52 1 0 137374) T) (#(62 1 1 137377) T) (#(65 0 1 102) T) 
	       (#(83 1 1 137376) T) (#(89 1 1 137378) T)))
	    ((bite-all-tails _mexbt_) 14);; 14 deletions
	    ((bt-fullmap _mexbt_ 100) 14);; still 14 elements in bt
	    ((get-btree #(0 1 0 137372) _mexbt_) nil);;now deleted...
	    ((get-btree #(100 1 0 137372) _mexbt_) 'x);; and replace with this
            ((get-btree #(11 1 0 137375) _mexbt_) nil);;Should be deleted...
            ((get-btree #(111 1 0 137375) _mexbt_) 'x);; and replace with this
            ((all-kv-pairs _mexbt_)
             '((#(100 1 0 137372) X) (#(111 1 0 137375) X) 
	       (#(124 1 0 137371) X) (#(126 1 0 137373) X) (#(139 0 1 101) X) 
	       (#(142 0 1 106) X) (#(150 1 0 138147) X) (#(150 1 0 138149) X) 
	       (#(150 1 0 138150) X) (#(152 1 0 137374) X) 
	       (#(162 1 1 137377) X) (#(165 0 1 102) X) (#(183 1 1 137376) X) 
	       (#(189 1 1 137378) X)))
	    )

(checkequal "memory leaks 2"
	    ((alloccnt 'list '(subset '(1 2 3) 'cons)) 0)
	    ((alloccnt 'string 
		       '((lambda(bt)
			   (put-btree (list (vector "A") (vector 1)) 
				      bt (vector "B" 1 2))
			   (put-btree (list (vector "A") (vector 1)) 
				      bt (vector "C" 1 3))
			   (get-btree (list (vector "A") (vector 1)) bt)
			   (delete-btree (vector "A") bt)
			   (delete-btree (list (vector "A") (vector 1))
					 bt)
			   (get-btree (list (vector "A") (vector 1)) bt)
			   nil)
			 (make-btree))) 0))

