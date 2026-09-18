
(defun test-init ()
  (let ((bt (mexima-make "MBTREE")))
    (mexima-put 1 bt 2)
    (mexima-put 3 bt 4)
    (mexima-put 5 bt 6)
    (mexima-put 7 bt 8)
    (mexima-put 9 bt 10)
    (mexima-put 11 bt 12)
    bt))

(defun test1 (bt)
  (checkequal 
   "Mexima get"
   ((mexima-get 1 bt) '2)))

(defun test2 (bt)
  (checkequal 
   "Mexima get"
   ((mexima-get 1 bt) nil)))
 
(setq bt (test-init))