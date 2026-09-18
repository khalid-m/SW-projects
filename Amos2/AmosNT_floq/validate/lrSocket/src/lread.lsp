; Reader fcn for LR data EZ/2007.06.27

(foreign-lispfn
 lrstream ((charstring filename)) ((vector))
 (let ((fh (openstream filename "r"))
       (c (+ 1 (clock)))
       (eof (mksymbol "*EOF*"))
       (trow 0)
       row)
   (while fh
     (setq row (read fh))
     (cond ((eq row eof)
	    (closestream fh)
	    (setq fh nil))
	   (t
	    (cond ((< trow (elt row 1))
		   (while (> c (clock))
		     (sleep 0.1))
		   (1++ trow)
		   (1++ c)))
	    (foreign-result row))))))
		      

(foreign-lispfn
 floor ((real x)) ((integer))
 (foreign-result (floor x)))

(defglobal _tollalert-fh_ nil)
(defglobal _acc-alert-fh_ nil)
(defglobal _type2-fh_ nil)
(defglobal _type3-fh_ nil)
(defglobal _stat-fh_ nil)

(foreign-lispfn
 init_fh () ((boolean))
 (setq _tollalert-fh_ (openstream "o-tollalert" "w"))
 (setq _acc-alert-fh_ (openstream "o-acc-alert" "w"))
 (setq _type2-fh_ (openstream "o-t2" "w"))
 (setq _type3-fh_ (openstream "o-t3" "w"))
 (setq _stat-fh_ (openstream "o-stat" "w")))

(foreign-lispfn
 close_fh () ((boolean))
 (closestream _tollalert-fh_)
 (closestream _acc-alert-fh_)
 (closestream _type2-fh_)
 (closestream _type3-fh_)
 (closestream _stat-fh_))

(foreign-lispfn
 wstat ((vector x)) ((boolean))
 (print x _stat-fh_))

(foreign-lispfn
 waccident ((vector x)) ((boolean))
 (print x _acc-alert-fh_))

(foreign-lispfn
 wtoll ((vector x)) ((boolean))
 (print x _tollalert-fh_))

(foreign-lispfn
 wtype2 ((vector x)) ((boolean))
 (print x _type2-fh_))

(foreign-lispfn
 wtype3 ((vector x)) ((boolean))
 (print x _type3-fh_))
