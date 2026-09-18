;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; differetially chained hashtable
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(defstruct deltahash
;  pre  ;previous pointer
;  delta  ;delta hash
;)

(defglobal deltahtl nil
  "a global list of all the deta hashtables")

(defun clear-delta ()
  (setq deltahtl (list (make-hash-table :test 'equal))))

(defun map-deltahash (newht ht)
  (maphash (f/l (key value)
		(cond ((not (gethash key newht))
		       (setf (gethash key newht) value))))
	   ht))

(defun copy-deltahash (htl)
  "tranverse the delta list and generate an update-to-date hashtable"
  (let ((newht (make-hash-table :test 'equal)))
    (mapc (f/l (ht) (map-deltahash newht ht)) htl)
    (list newht)))

(defun add-delta (key value htl)
  "add new possible entry"
  (catch 'match
    (let ((hht (car htl)))
      (mapc (f/l (ht)
		 (cond ((gethash key ht)
			(setf (gethash key hht)
			      (+ (gethash key ht) value))
			(throw 'match htl))))
	    htl)
      (setf (gethash key hht) value))))

(defun remove-delta (key value htl)
  "remove entry"
  (catch 'match
    (let ((hht (car htl)))
      (mapc (f/l (ht)
		 (cond ((gethash key ht)
			(setf (gethash key hht)
			      (- (gethash key ht) value))
			(throw 'match htl))))
	    htl)
      (setf (gethash key hht) (- value)))))

(defun tranverse-deltahash (htl)
  "for testing use"
  (mapc (f/l (ht)
	     (maphash (f/l (key value) (print (list key value))) ht))
	htl)
  (maphash (f/l (key value) (print (list key value)))
	   (car (copy-deltahash htl))))