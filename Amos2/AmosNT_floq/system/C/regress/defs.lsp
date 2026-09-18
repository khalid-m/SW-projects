;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010 Lars Melander, UDBL
;;; $RCSfile: defs.lsp,v $
;;; $Revision: 1.2 $ $Date: 2010/06/21 16:58:48 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Test functions for localThreads
;;; =============================================================
;;; $Log: defs.lsp,v $
;;; Revision 1.2  2010/06/21 16:58:48  larme597
;;; Linux localThreads test.
;;;
;;; Revision 1.1  2010/06/16 17:16:24  larme597
;;; Copying defs from $(AMOS_HOME)/Java/javadefs.osql
;;;
;;; =============================================================

(defun coargs (low up size)
  "Form all intervals of given SIZE in interval (LOW UP)"
  (let (res (l low))
    (loop (cond ((< (- up l) size)
		 (push (list l up) res)
		 (return (reverse res)))
		((< size 1)
		 (push (list l up) res)
		 (return (reverse res)))
		(t
		 (push (list l (+ size -1 l))
		       res)
		 (setq l (+ size l)))))))

(defun diota (l u)
  (let ((i l))
    (while (<= i u)
      (co-yield i)
      (1++ i))))

(defun ciota (l u)
  (let ((col (mapcar (f/l (ca)
			  (coroutine 'diota
				     (list (first ca) (second ca))))
		     (coargs l u 5))))
    (while col
      (dolist (c col)
	(if (co-terminated c)
	    (setq col (remove c col))
	  (co-yield (co-resume c)))))))

(defun all-terminated (col)
  (every (function co-terminated)
	 col))

(foreign-lispfn ciota ((number n)) ((number))
		(let ((col (mapcar (f/l (ca)
					(coroutine 'ciota (list (first ca) (second ca))))
				   (coargs 1 n (/ n 5))))
		      res)
		  (while (not (all-terminated col))
		    (dolist (co col)
		      (and (not (co-terminated co))
			   (numberp (setq res
					  (co-resume co)))
			   (foreign-result res))))))

(foreign-lispfn zip ((bag b1) (bag b2)) ((object))
		(let ((col (list (coroutine 'mapbag
					    (list b1 'co-yield))
				 (coroutine 'mapbag
					    (list b2 'co-yield))))
                      res)
		  (while (not (all-terminated col))
		    (dolist (co col)
		      (and (not (co-terminated co))
			   (consp (setq res
					(co-resume co)))
			   (foreign-result (car res)))))))
