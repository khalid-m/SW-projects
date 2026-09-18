
(defglobal _parallelcallstbl_  (make-hash-table :test 'equal))

(defun putvalue (key value)
  (puthash key _parallelcallstbl_ value))
(defun getvalue (key ) 
  (gethash key _parallelcallstbl_))

