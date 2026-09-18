(defun build-test (size)
  (let ((bt (make-btree))(sz (* size 2)))
    (rptq size (put-btree (random sz) bt t))
    bt))

(defglobal _hw_ (high-watermark))

(defglobal _bt_ (build-test 1000000))

(setq _hw_ (high-watermark))

(rollout "foo.dmp")

(defglobal _hw2_ (high-watermark))

(defglobal _diff_ (- _hw2_ _hw_))

(rollout "foo.dmp")

(checkequal "Leak on rollout"
  ((= _hw2_ (high-watermark)) t)
)









