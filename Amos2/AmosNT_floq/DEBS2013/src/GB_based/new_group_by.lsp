;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013 Sobhan, UDBL
;;; $RCSfile: new_group_by.lsp,v $
;;; $Revision: 1.2 $ $Date: 2013/10/29 14:45:24 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: The extended group by that takes a set of aggregate functions
;;; =============================================================
;;; $Log: new_group_by.lsp,v $
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

;;(setq _system-watermark_ 0)

(defun new-group-by--++ (fno b groupfns grkey grval)
  (let ((ht (make-hash-table :test 'equal))
        (groupl (cond ((arrayp groupfns) (arraytolist groupfns))
                      (t (list groupfns)))))
    (cond ((every (function aggregatefunctionp) groupl))
          (t (error "Second argument of GROUPBY must be aggregate function(s)" groupfns)))
    (mapbag 
     b
     (f/l (row) 
	  (let ((bags (gethash (car row) ht)))
	    (cond ((null bags);; first time
		   (setf (gethash (car row) ht) 
			 (mapcar (f/l (col)
				      (tconc (tconc) (list col))) 
					; build bag headers
				 (cdr row))))
		  ;;second time, add columns to corresponding bags.
		  (t (mapc (f/l (hdr val)(tconc hdr (list val))) 
			   bags (cdr row)))))))
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
			   (mapcan (f/l (fn) (append (function-resulttypes fn)))
				   (arraytolist (second args)))))
		    ((aggregatefunctionp (second args))
		     (cons (or (car ptypes) _object_) (function-resulttypes (second args))))
                    (t nil)))))

(set-resulttypesfn
 (osql"
create function new_group_by(Bag b, Object groupfns) -> Object 
  as foreign 'new-group-by--++';")
 'newgroupby-resulttypes)

(osql "
set :bag1 = (select {floor(i/2),1},i,2
from Number i
where i in iota(1,10));

in(:bag1);

new_group_by(:bag1,{#'count',#'sum'});

select x from object x, object y, object z where (x,y,z) in new_group_by(:bag1, {#'count',#'sum'});

")
