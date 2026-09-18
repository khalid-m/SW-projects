;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2008 Tore Risch, UDBL
;;; $RCSfile: groupby.lsp,v $
;;; $Revision: 1.6 $ $Date: 2011/12/22 12:55:16 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: group by aggregate function
;;; =============================================================
;;; $Log: groupby.lsp,v $
;;; Revision 1.6  2011/12/22 12:55:16  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.5  2011/01/29 11:32:50  torer
;;; Forgot a few changes
;;;
;;; Revision 1.4  2009/05/07 14:53:54  zeitler
;;; SQL group_by
;;; readfiles returns object
;;;
;;; Revision 1.3  2008/11/28 13:53:33  torer
;;; Result type OBJECT if aggregate function not known at type checking time
;;;
;;; Revision 1.2  2008/11/25 17:13:36  torer
;;; Result type inference
;;;
;;; Revision 1.1  2008/11/25 16:38:06  torer
;;; Aggregate function
;;;   groupby(Bag of <Object gr, Object gv>, function aggop) -> Bag of <Object gr, Object agg>
;;;
;;; =============================================================

(set-resulttypesfn
 (foreign-lispfn
  groupby((bag b)(function grouper))((object grkey)(object grval))
  (let ((ht (make-hash-table :test 'equal)))
    (mapbag b
	    (f/l (row)
		 (setf (gethash (car row) ht)
		       (cons (cdr row) (gethash (car row)ht )))))
    (maphash (f/l (key bck)
		  (mapfunction grouper (vector (bagify bck))
			       (f/l (row)
				    (osql-result 
				     b grouper key (car row)))))
	     ht)))
 'groupby-resulttypes)

(defun groupby-resulttypes (fno args)
  (let ((tp (default-type-parameters (arg-type (car args))))
        (fr (if (function-p (cadr args))
		(function-resulttypes (cadr args) t)
	      (list _object_))))
    (list (car tp)(car fr))))


;example:
; select v[0], sql_count(a), sql_avg(a, ssn), sql_max(zip), sql_min(zip), 
;         sql_countd(a, 0)
; from Vector v, Vector a
; where (v, a) in group_by((select name, zip , ssn
;                           from Integer ssn, Charstring name, Integer zip
;                           where person(ssn)=(name, zip)), 2);

(defun group_by (fno data fcount v a)
  (let ((htable (make-hash-table :test (function equal))) (v nil) (href nil))
    (if (catch 'some (mapbag data (q/l (x) (throw 'some t))))
	(progn
	  (mapbag
	   data
	   #'(lambda (row)
	       (setq v (reverse (nthcdr (- (ilength row) fcount) 
					(reverse row))))
	       (setf (gethash v htable) (append (gethash v htable) 
						(list (nthcdr fcount row))))))
	  (maphash 
	   #'(lambda (key val)
	       (osql-result data fcount 
			    (listtoarray key) (recursivelisttoarray val)))
	   htable))
      (osql-result data fcount (mkarray 0) (mkarray 0)))))

(osql 
 "
create function group_by(Bag data, Integer fcount)
                     -> Bag of (vector v, vector a) 
  as foreign 'group_by';")

(defun recursivelisttoarray (lst)
  (if (or (not lst) (not (listp lst)))
      lst
    (listtoarray (mapcar (function recursivelisttoarray) lst))))
