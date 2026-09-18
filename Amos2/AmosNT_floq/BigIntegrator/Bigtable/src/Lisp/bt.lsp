;;generate bpat. e.g fff.
(defun generateBpat-+ (fno num res)
  (let ((res ""))
    (dotimes (i num)
      (setq res (concat res "f")))
    (osql-result num res)))


(defun put-tablename-- (o fno tbn)
  (/putobject fno 'tablename (mksymbol tbn))
  (osql-result fno tbn))

(defun put-datasource-- (o fno ds)
  (/putobject fno 'datasource ds)
  (osql-result fno ds))