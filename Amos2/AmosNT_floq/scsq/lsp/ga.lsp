; set :a = spv(vectorof(select streamof(select ga(id,10,10)) from integer id where id=iota(0,3)), "tcp");
; merge(:a);

(defstruct pop
  size
  minval
  maxval
  chromlen)

(defun load-ind (fname)
  (let ((fh (openstream fname "r")) (row))
    (setq row (read fh))
    (closestream fh)
    row))

(defun save-ind (fname ind)
  (let ((fh (openstream fname "w")))
    (print ind fh)
    (flush fh)
    (closestream fh)))

; <split files>
(defun subvector (v start end)
  (let* ((len (- end start)) (res (make-array len)))
    (dotimes (i len)
      (seta res i (elt v (+ start i))))
    res))

(defun splitvec (v nparts partnum)
  (let* ((partlen (/ (length v) nparts)))
    (subvector v (* partlen partnum) (* partlen (+ 1 partnum)))))

(defun splitfile (nparts)
  (let ((master (load-ind "mu/aqshort.lsp")))
    (dotimes (i nparts)
      (save-ind (concat "aq" i) (splitvec master nparts i)))))
; </split files>

(defglobal _c_)  ; objective
(defglobal _gc_) ; generation count
(defglobal _p_)  ; population data
(defglobal _pt_) ; population table
(defglobal _id_) ; my id

(foreign-lispfn
 ga ((integer id) (integer popsize) (integer maxgen)) ((vector))
 (setq _c_ (load-ind (concat "mu/aq" id)))
 (setq _p_ (make-pop :size popsize :minval -127 :maxval 117 :chromlen (length _c_)))
 (setq _id_ id)
 (print (concat "## my id is" id))
 (init-pt)
 (foreign-result (listtoarray (generation popsize maxgen))))

(defun posdiff (x y)
  (* (- x y) (- x y)))

(defun evc (chrom)
  (let ((sum 0.0))
    (dotimes (i (array-total-size chrom))
      (setf sum (+ sum (posdiff (aref chrom i) (aref _c_ i)))))))

(defun randvector (len)
  (let ((a (make-array len)) (c 0))
    (while (< c len)
      (seta a c (rand (pop-minval _p_) (pop-maxval _p_)))
      (1++ c))
    a))

(defun mutation (chrom)
  (seta chrom (random (pop-chromlen _p_)) (rand (pop-minval _p_) (pop-maxval _p_)))
  chrom)

(defun combine-chroms (chromcell)
  (let ((pos (rand 1 (array-total-size (car chromcell))))
	(a (copy-array (car chromcell))))
    (dotimes (i pos)
      (seta a i (elt (cdr chromcell) i)))
    a))

(defun select-ind (k cumul)
  (dotimes (i (length cumul))
    (cond ((< (nth i cumul) k) i)
	  (t (return i)))))

(defun printind (key val)
  (print (list key val)))

(defun sort-pt ()
  (setq _pt_ (sort _pt_ (f/l (a b) (< (car a) (car b))))))

(defun init-pt ()
  (setq _gc_ 0)
  (setq _pt_ nil)
  (dotimes (i (pop-size _p_))
    (let ((ind (randvector (pop-chromlen _p_))))
      (setq _pt_ (append _pt_ (list (list (evc ind) ind))))))
  (length (sort-pt)))

(defun birth (num)
  (let* ((max (caar (last _pt_)))
	 (fitlist (mapcar (f/l (i) (- max (car i))) _pt_))
	 (cumul (let ((cs 0.0)) (mapcar (f/l (f) (setq cs (+ cs f))) fitlist)))
	 (maxcumul (car (last cumul))))
    (dotimes (i num)
    (let ((i1 (select-ind (random (floor maxcumul)) cumul))
	  (i2 (select-ind (random (floor maxcumul)) cumul)))
      (let ((ind 
	     (mutation
	      (combine-chroms (cons (second (nth i1 _pt_)) (second (nth i2 _pt_)))))))
	(setq _pt_ (append _pt_ (list (list (evc ind) ind)))))))))

(defun popf ()
  (first _pt_))

(defun popl ()
  (car (last _pt_)))

(defun death2 (popsize)
  (setq _pt_ (ldiff _pt_ (nthcdr popsize _pt_))))

(defun purge-duplicates ()
  (setq _pt_ (unique _pt_))
  (dotimes (i (- (pop-size _p_) (length _pt_)))
    (let ((ind (randvector (pop-chromlen _p_))))
      (setq _pt_ (append _pt_ (list (list (evc ind) ind))))))
  (sort-pt))

(defun generation (popsize maxgen)
  (if (null _pt_) (init-pt))
  (dotimes (i (+ 1 maxgen))
    (birth popsize)
    (sort-pt)
    (death2 popsize)
    (cond ((equal 0 (mod _gc_ 100))
	   (save-ind (concat "mu/id" _id_ "-gen" _gc_) (popf))))
    (1++ _gc_)
    (if (= (car (popf)) (car (popl))) (purge-duplicates))
    (if (= (car (popf)) 0) (return 1 )))
  (list (car (popf)) (car (popl))))
