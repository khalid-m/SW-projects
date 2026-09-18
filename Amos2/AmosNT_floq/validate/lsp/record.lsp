;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013 Cheng Xu, UDBL
;;; $RCSfile: record.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/10/20 18:38:27 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: some more record operations
;;; =============================================================
;;; $Log: record.lsp,v $
;;; Revision 1.1  2013/10/20 18:38:27  chexu484
;;; added numerical operators over/between records
;;;
;;; =============================================================

(defun add-records (r1 r2)
  "Non-destructive add two records"
  (let ((tl (tconc)))
    (mapc (f/l (key)
	       (tconc tl key)
	       (let ((r1val (record-get r1 key))
		     (r2val (record-get r2 key)))
		 (if r2val (tconc tl (+ r1val r2val))
		   (tconc tl r1val))))
	  (record-keys r1))
    (mapc (f/l (key)
	       (let ((r1val (record-get r1 key))
		     (r2val (record-get r2 key)))
		 (if (not r1val)
		     (progn (tconc tl key)
			    (tconc tl r2val)))))
	  (record-keys r2))
    (make-record (listtoarray (car tl)))))

(defun subtract-records (r1 r2)
  "Non-destructive minus, only subtract shared fileds"
  (let ((new (make-record (copy-array (record-fields r1)))))
    (mapc (f/l (key)
	       (let ((r1val (record-get r1 key))
		     (r2val (record-get r2 key)))
		 (if r2val (record-put new key (- r1val r2val)))))
	  (record-keys r1))
    new))

(defun record-plus (r n)
  "Non-destructive plus"
  (let ((new (make-record (copy-array (record-fields r)))))
    (mapc (f/l (key)
	       (record-put new key (+ (record-get r key) n)))
	  (record-keys r))
    new))

(defun record-multiply (r n)
  "Non-destructive multiply"
  (let ((new (make-record (copy-array (record-fields r)))))
    (mapc (f/l (key)
	       (record-put new key (* (record-get r key) n)))
	  (record-keys r))
    new))

(defun record-power (r n)
  "Non-destructive power"
  (let ((new (make-record (copy-array (record-fields r)))))
    (mapc (f/l (key)
	       (let ((val (record-get r key)))
		 (if (not (= val 0))
		     (record-put new key (expt val n)))))
	  (record-keys r))
    new))

(defun add-recordsbbf (fno r1 r2)
  (osql-result r1 r2 (add-records r1 r2)))

(defun subtract-recordsbbf (fno r1 r2)
  (osql-result r1 r2 (subtract-records r1 r2)))

(defun record-plusbbf (fno r n)
  (osql-result r n (record-plus r n)))

(defun record-multiplybbf (fno r n)
  (osql-result r n (record-multiply r n)))

(defun record-powerbbf (fno r n)
  (osql-result r n (record-power r n)))

(osql "create function add_records(Record r1, Record r2) -> Record
       as foreign 'add-recordsbbf';")

(osql "create function subtract_records(Record r1, Record r2) -> Record
       as foreign 'subtract-recordsbbf';")

(osql "create function record_plus(Record r, Number n) -> Record
       as foreign 'record-plusbbf';")

(osql "create function record_multiply(Record r, Number n) -> Record
       as foreign 'record-multiplybbf';")

(osql "create function record_power(Record r, Number n) -> Record
       as foreign 'record-powerbbf';")


(defun project-recordbbf (fno r variables)
  "project records based on the array of variables"
  (let ((tl (tconc)))
    (maparray variables (f/l (variable i)
			     (let ((val (record-get r variable)))
			       (if val
				   (progn (tconc tl variable)
					  (tconc tl val))))))
    (osql-result r variables (make-record (listtoarray (car tl))))))

(osql "create function project_record(Record r, Vector of Charstring variables) -> Record
       as foreign 'project-recordbbf';")