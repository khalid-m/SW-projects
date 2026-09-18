
(defglobal _source_ nil)
(defglobal _tollalert_ nil)
(defglobal _accident_ nil)
(defglobal _type2_ nil)
(defglobal _type3_ nil)

(foreign-lispfn
 socketconfig ((Charstring hostname) (Integer tollalert) (Integer accident) (Integer type2) (Integer type3)) ((Boolean))
  (setq _tollalert_ (open-socket hostname tollalert))
  (setq _accident_ (open-socket hostname accident))
  (setq _type2_ (open-socket hostname type2))
  (setq _type3_ (open-socket hostname type3)))

(foreign-lispfn
 sread ((Charstring hostname) (Integer source)) ((Vector of Integer))
 (let ((sock (open-socket hostname source)) r)
   (while (not (equal 'EOF (setq r (read sock))))
     (foreign-result r))
   (close-socket _tollalert_)
   (close-socket _accident_)
   (close-socket _type2_)
   (close-socket _type3_)
   (close-socket sock)))

(foreign-lispfn
 swaccident ((vector x)) ((boolean))
 (pf x _accident_))

(foreign-lispfn
 swtoll ((vector x)) ((boolean))
 (pf x _tollalert_))

(foreign-lispfn
 swtype2 ((vector x)) ((boolean))
 (pf x _type2_))

(foreign-lispfn
 swtype3 ((vector x)) ((boolean))
 (pf x _type3_))
			      
		