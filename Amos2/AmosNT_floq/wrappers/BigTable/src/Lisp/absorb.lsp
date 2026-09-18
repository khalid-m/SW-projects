
(quote
(defun absorb-predicates (l)
  "go through conjunctive list of tr and absorb the possible predicates
   for CCfn" 
  (let ((changed t))
    (while changed
      (setq changed nil)
      (dolist (pred l)
	(let ((absorber (get-absorber pred)))
	  (cond (absorber  ;(help 1)
		 (let ((transformed (funcall absorber pred (remove pred l))))
		   (cond ((null transformed))
			 (t (setq changed t) 
			    (setq l transformed)  ;(help 2)
			    (return nil)))))))))
    l))
)

(defun absorb-predicates (l)
  "go through conjunctive list of tr and absorb the possible predicates
   for CCfn" 
  (let ((changed t)
	cleanp)
    (while changed
      (setq changed nil)
      (dolist (pred l)
	(let ((absorber (get-absorber pred)))
	  (cond (absorber 
		 (setq cleanp t)
		 (let ((transformed (funcall absorber pred (remove pred l))))
		   (cond ((null transformed))
			 (t (setq changed t) 
			    (setq l transformed)
			    (return nil)))))))))
    (if cleanp
	(remove-absorbedpreds (car _absorbedPredCollection_) l)
      l)
    ))


(defun findaccessfilter (pred gassolist)
  (let (accessfilterl)
    (setq accessfilterl (mapfilter (f/l (predl) (equal (car predl) pred))
				   gassolist))
    (cadar accessfilterl)))

(defun remove-absorbedpreds (absorbedPreds l)
  (let ((filteredl l)
	(absorbedPreds1 (unique absorbedPreds))
	op)
    (dolist (pred absorbedPreds1)
      (setq op (car pred))
      (cond ((compound-p pred))
	    ((eq op '=))
	    (t
	     (cond ((getobject (car pred) 'CCLUSTERFCT?)
		    (let ((accessfilter (findaccessfilter pred _gassolist_)))
		      (if accessfilter
			  (setq filteredl (remove accessfilter filteredl)))))
		   (t
		    (if (member pred l)
			(setq filteredl (remove pred filteredl))))))))
    (setq _absorbedPredCollection_ (tconc))
    (setq _gassolist_ nil)
    filteredl))

(defun get-absorber (tr)
  "get lisp function lfn to absorb preds for CCfn 
   and generate a list of absorbed predicates conjunction"
  (and (consp tr)(oid-p (car tr))
       (getobject (car tr) 'absorber))
  )

(defun put-absorber (fno lfn)
  "Put a absorber on Amos function FNO"
  (/putobject fno 'absorber lfn))


(defun put-absorber-- (o fno lfn)
  (put-absorber fno (pack 'absorb- lfn))
  (osql-result fno lfn))


(osql "
create function put_absorber(Function fno, Charstring tr)->Boolean
  as foreign 'put-absorber--';")




