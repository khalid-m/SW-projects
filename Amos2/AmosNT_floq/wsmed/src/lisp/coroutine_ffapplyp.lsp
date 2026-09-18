

(foreign-lispfn testfun((number delay)(integer arg))((integer))
 (co-sleep delay)
 (dotimes (i arg)
   (foreign-result (1+ i))))




