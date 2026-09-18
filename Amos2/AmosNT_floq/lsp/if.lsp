

(set-resulttypesfn
 (osql "
create function ifsome(Bag c, Object th, Object el)->Object
  as foreign 'ifsome---+';")
 'ifsome-resulttypes)

(defun empty-bag (b)
  (not (catch 'empty-bag (mapbag b (f/l(r)(throw 'empty-bag t))))))

(defun ifsome---+ (fno c then else r)
  (if (empty-bag c) (osql-result c then else else)
    (osql-result c then else then)))

(defun ifsome-resulttypes (fno args)
  "The result type is the common type of the 2nd and 3rd arguments"
  (let ((t1 (arg-type (second args)))
        (t2 (arg-type (third args))))
    (list (common-ancestortype t1 t2))))
