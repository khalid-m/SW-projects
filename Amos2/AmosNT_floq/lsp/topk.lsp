;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009 Erik Zeitler, UDBL
;;; $RCSfile: topk.lsp,v $
;;; $Revision: 1.3 $ $Date: 2013/11/07 19:44:30 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: top-k and least-k functions implemented as bestK.
;;; =============================================================
;;; $Log: topk.lsp,v $
;;; Revision 1.3  2013/11/07 19:44:30  torer
;;; Integer -> Number in arguments
;;;
;;; Revision 1.2  2011/01/29 11:04:39  torer
;;; Base system uses (...) tuple notation, 'return' statement, and systematic indentation
;;;
;;; Revision 1.1  2009/09/29 21:16:50  zeitler
;;; topk, leastk (and bestk) added to system and tests
;;;
;;;
;;; =============================================================

(defun bestK (fno b k dir res)
  (let* (top (order-sym (sortorder-symbol dir))
	     (i 0)
	     (cf (f/l (x y)
		      (selectq order-sym
			       (dec (< (compare (car x) (car y)) 0))
			       (> (compare (car x) (car y)) 0)))))
    (mapbag b (f/l (tpl)
		   (cond ((< i k)(1++ i)
			  (setq top (dmerge (list tpl) top cf))) 
			 ((funcall cf (car top) tpl)
			  (setq top (dmerge (list tpl) (cdr top) cf))))))
    (mapc (f/l (x) (osql-result b k dir (first x) (second x)))
	  top)))

(osql "
create function bestK(Bag, Number k, Charstring dir)
                  -> Bag of (object, object)
  as foreign 'bestK';")

(osql "
create function topk(Bag x, Number k) -> Bag of (Object, Object)
  as bestK(x, k, 'dec');")

(osql "
create function leastk(Bag x, Number k) -> Bag of (Object, Object)
  as bestK(x, k, 'inc');")
