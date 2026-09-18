(defun next-divisible (divisible divisor)
; return the next number after DIVISIBLE which is divided by DIVISOR
  (loop
   (if (= (mod divisible divisor) 0)
       (return divisible)
       (setq divisible (+ divisible 1)))))

(defun make-isyemp (maxtuples)
  (setq maxtuples (next-divisible maxtuples 4))
  (let* ((isy1    (/ maxtuples 4))
	 (other1  (/ maxtuples 2))
	 (isy_ida (* 3 (/ maxtuples 4)))
	 (other2  maxtuples))
    (formatl t "Generating: " maxtuples " tuples." t)
    (osql-let ((charstring :name) (integer :wplace) (charstring :id) (integer :pay))
      (dotimes (i maxtuples)
	       (setq amos_name (concat "isyemp" (mkstring i)))
	       (setq amos_wplace
		     (cond ((< i isy1) 1)
			   ((and (>= i isy1) (< i other1)) 2)
			   ((and (>= i other1) (< i isy_ida)) 1)
			   ((> i isy_ida) 3)))
	       (setq amos_id (mkstring i))
	       (setq amos_pay (* 1 i))
	       (create-userobjects
		isyemp
		(     id       name       pay       wplace)
		((amos_id  amos_name  amos_pay  amos_wplace)))))))

(make-isyemp 8)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ID_TO_SSN
(defun id_to_ssn-+ (fno id ssn)
  (osql-result  id (mkatom id)))

(defun id_to_ssn+- (fno id ssn)
  (osql-result  (mkstring ssn) ssn))

(bind-foreign 'charstring.id_to_ssn->integer '(- +) 'id_to_ssn-+)
(bind-foreign 'charstring.id_to_ssn->integer '(+ -) 'id_to_ssn+-)
(create-function id_to_ssn ((charstring id))((integer ssn)) as foreign)
(declarecosts 'charstring.id_to_ssn->integer '(- +) '(1  1))
(declarecosts 'charstring.id_to_ssn->integer '(+ -) '(1  1))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; WPLACE_TO_DEPT
(defun wplace_to_dept-+ (fno wplace dept)
  (osql-result wplace (mkstring wplace)))

(defun wplace_to_dept+- (fno wplace dept)
  (osql-result (if (equal dept "IDA") 1 7)  dept))

(bind-foreign 'integer.wplace_to_dept->charstring '(- +) 'wplace_to_dept-+)
(bind-foreign 'integer.wplace_to_dept->charstring '(+ -) 'wplace_to_dept+-)
(create-function wplace_to_dept ((integer ssn)) ((charstring id)) as foreign)
(declarecosts 'integer.wplace_to_dept->charstring '(- +) '(1  1))
(declarecosts 'integer.wplace_to_dept->charstring '(+ -) '(1  1))
