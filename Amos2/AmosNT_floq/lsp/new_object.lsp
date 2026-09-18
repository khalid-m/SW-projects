(defun new_object--+ (obj ooid tp)
  (osql-result ooid tp (/createobject (mksymbol tp) NIL)))


