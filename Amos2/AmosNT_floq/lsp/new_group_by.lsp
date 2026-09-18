;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013 Sobhan, Tore Risch UDBL
;;; $RCSfile: new_group_by.lsp,v $
;;; $Revision: 1.3 $ $Date: 2014/02/16 16:38:09 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: The extended group by that takes a set of aggregate functions
;;; =============================================================
;;; $Log: new_group_by.lsp,v $
;;; Revision 1.3  2014/02/16 16:38:09  torer
;;; Wrong signatures in new groupby()
;;;
;;; Revision 1.2.2.1  2014/02/16 13:35:31  torer
;;; Wrong signatures in groupby()
;;;
;;; Revision 1.2  2013/11/07 18:07:54  torer
;;; renamed group_by() into groupby_pos()
;;;
;;; Revision 1.1  2013/11/07 16:08:53  torer
;;; Generalized overloaded groupby()
;;;
;;; Revision 1.2  2013/10/29 14:45:24  sobso953
;;; more type checking for the new_group_by
;;;
;;; Revision 1.1  2013/10/29 10:32:18  sobso953
;;; re-arranging the group-by-based version of DEBS
;;;
;;; Revision 1.3  2013/10/28 16:01:39  sobso953
;;; -more type checking: inffers exact data types
;;; -supports the signature of the "old"/"standard" groupsby() function
;;;
;;; Revision 1.2  2013/10/26 07:29:33  torer
;;; Correct result from type inference fucntion of new_group_by()
;;;
;;; Revision 1.1  2013/10/15 14:55:47  sobso953
;;; new_group_by function added to DEBS
;;;
;;; =============================================================

(defun new-group-by--++ (fno b groupfns grkey &rest grval)
  (let ((ht (make-hash-table :test 'equal))
        (width (length grval))
        (groupl (cond ((arrayp groupfns) (arraytolist groupfns))
                      (t (list groupfns)))))
    (cond ((not (every (function aggregatefunctionp) groupl))
	   (error 
	    "Second argument of group_by() must be aggregate function(s)"
	    groupfns))
	  ((= (length groupl) width)nil)
	  (t (error "Width does not match aggregate functions in group_by()"
		    groupfns)))
    (mapbag 
     b
     (f/l (row) 
	  (let ((bags (gethash (car row) ht)))
	    (cond ((null bags);; first time
		   (setf (gethash (car row) ht) 
			 (mapcar (f/l (col)
				      (tconc (tconc) (list col))) 
					; build bag headers
				 (or (cdr row)(buildn width (car row))))))
		  ;;second time, add columns to corresponding bags.
		  (t (mapc (f/l (hdr val)(tconc hdr (list val))) 
			   bags (or (cdr row) (buildn width (car row)))))))))
    (maphash (f/l (key bck)
		  ;;for every list in the bucket list, gl, apply 
		  ;; the corresponding groupfn, gfn
		  (apply (function osql-result)
			 b groupfns key
			 (mapcan 
			  (f/l (hdr gfn) 
			       (catch 'aggfn 
				 (mapfunction 
				  gfn 
				  (vector (bagify (car hdr)));;materialized bag
				  (f/l (row)(throw 'aggfn (append row))))))
			  bck groupl)))
	     ht)))

(defun newgroupby-resulttypes (fno args)
  (and args (let* ((bagtype (arg-type (car args)))
		   (ptypes (and bagtype (collection-parameters bagtype))))
	      (cond ((arrayp (second args))
		     (cons (or (car ptypes)_object_)
			   (mapcan (f/l (fn) (append (function-resulttypes fn))
					)
				   (arraytolist (second args)))))
		    ((aggregatefunctionp (second args))
		     (cons (or (car ptypes) _object_) 
			   (function-resulttypes (second args))))
                    (t nil)))))

(set-resulttypesfn
 (osql"
create function groupby(Bag kvp, Function aggfn) 
                      -> Bag of (Object k, Object v)
  /* Group key/value pairs kvp producing a bag of objects b for each k in kvp.
     Then build new key/value pairs (k, aggfn(b)) */
  as foreign 'new-group-by--++';")
 'newgroupby-resulttypes)

(set-resulttypesfn
 (osql"
create function groupby(Bag kvp, Vector of Function aggfns)
                      -> Bag of (Object k, Object v) 
  /* Group key/value pairs kvp producing a bag of objects b for each k in kvp.
     Then build new key/value tuples (k, aggfns[0](b), aggfns[1](b) ... */
  as foreign 'new-group-by--++';")
 'newgroupby-resulttypes)


;example:
; select v[0], sql_count(a), sql_avg(a, ssn), sql_max(zip), sql_min(zip), 
;         sql_countd(a, 0)
; from Vector v, Vector a
; where (v, a) in group_by((select name, zip , ssn
;                           from Integer ssn, Charstring name, Integer zip
;                           where person(ssn)=(name, zip)), 2);

(defun groupby-pos--++ (fno data fcount v a)
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
create function groupby_pos(Bag data, Number fcount)
                     -> Bag of (vector v, Vector a) 
  as foreign 'groupby-pos--++';")

(defun recursivelisttoarray (lst)
  (if (or (not lst) (not (listp lst)))
      lst
    (listtoarray (mapcar (function recursivelisttoarray) lst))))


(commit)
