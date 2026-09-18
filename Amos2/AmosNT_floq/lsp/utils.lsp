;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1999 Timour Katchaounov, EDSLAB
;;; $RCSfile: utils.lsp,v $
;;; $Revision: 1.33 $ $Date: 2012/02/09 23:07:20 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Different utility functions and macros.
;;; =============================================================


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Global constants
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defglobal _KB_ 1024)
(defglobal _MB_ (* _KB_ _KB_))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Running AMOS2 from inside AMOS2 in Windows (because of the "start" command)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun run-amos (opt)
  (let* ((amos_exe "amos2.exe")
	 (amos_dmp "amos2.dmp")
	 (options (if (null opt) "" opt)))
    (system (concat "start "
		    _AMOS_STARTUP_DIR_ "/" amos_exe
		    " -b " 
		    _AMOS_STARTUP_DIR_ "/" amos_dmp
		    " "
		    options))))

(defun boot-amos (opt)
  (let* ((amos_exe "amos2.exe")
	 (options (if (null opt) "" opt)))
    (system (concat "start "
		    _AMOS_STARTUP_DIR_ "/" amos_exe
		    " -i " 
		    options))))

(defun run-amos-ns (nsname &optional opt)
  (if (null nsname)
      (setq nsname "nameserv")) ; default name
  (run-amos (concat (if opt opt "") " -n " nsname)))

(defun run-amos-client (name &optional opt)
  (run-amos (concat (if opt opt "") " -c " name)))

(defun run-amos-server (name &optional opt)
  (run-amos (concat (if opt opt "") " -s " name)))

(foreign-lispfn image_size ((integer mb)) ((integer))
	(foreign-result (imagesize (* mb _MB_))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Random numbers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun rand (low high)
  "Generate random number r, such that: low <= r < high"
  (let* ((range (- high low))
	 (r (random range)))
    (+ r low)))

(foreign-lispfn rand ((number low) (number high)) ((number r))
	(foreign-result (rand low high)))


(foreign-lispfn rand ((number limit)) ((number r))
	(foreign-result (random limit)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; String functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun make-string (size elem)
  "Make a new string of size 'size' initialized by 'elem'"
  (let ((stream (maketextstream size)))
    (rptq size (princ elem stream))
    (closestream stream)
    (textstreamstring stream)))

(foreign-lispfn make_string ((integer size) (charstring elem)) ((charstring res))
	(foreign-result (make-string size elem)))

(defun maxl (lst &optional cmpfn)
  "Return the maximum number in a list of numbers."
  (if (null cmpfn)
      (setq cmpfn #'>))
   (cond ((null lst) nil)
         ((null (cdr lst)) (car lst))
         (t
	  (let ((max-el (car lst)))
	    (dolist (el lst)
	      (if (funcall cmpfn el max-el)
		  (setq max-el el)))
	    max-el))))

;replaces itemize-list AND cramlist
(defun concatl (l delimiter &optional transform-fn)
  "Turns a list into a string, transforming each element
   with transform-fn and inserting delimiter between each element."
  (let* ((fn (or transform-fn (function id)))
	 (s (or (and l (funcall fn (pop l))) "")))
    (dolist (token l)
      (setq s (concat s delimiter (funcall fn token))))
      s))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Misc macros and functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro evenp (num)
  `(if (= (mod , num 2) 0) T NIL))

(defmacro oddp (num)
  `(not (evenp , num)))

(defun roundto (num digits)
  "Round the real number 'num' to 'digits' digits after the 0."
  (if (< digits 0) (amos-error "Negative number of digits to round"))
  (let* ((scale (expt 10.0 digits))
	 (rounded (round (* num scale))))
    (/ rounded scale)))

(foreign-lispfn round ((number n)) ((number r))
	(foreign-result (round n)))

(foreign-lispfn roundto ((number num) (integer digits)) ((number r))
	(foreign-result (roundto num digits)))

(defun avrg (intlst)
  "Calculate the average of a list of numbers 'intlist'."
  (let ((result 0)
	(count 0))
    (mapcar (f/l (x)
		 (setq result (+ result x))
		 (setq count (+ 1 count)))
	    intlst)
    (if (> count 0)
	(/ result count)
        0)))

(defmacro disable (&rest forms)
  "Useful macro to comment out regions of LISP code."
  (list 'if 'nil (list 'progn forms)))

(defun dump-hash-table (ht)
  (maphash (f/l (k v) (formatl t k " : " v t)) ht))

(defun print--- (fno string file mode)
  (let ((stream (if file (openstream file mode))))
    (formatl stream string)
    (closestream stream)))

(osql "
create function print(charstring str, charstring file, charstring mode) -> boolean b
as foreign 'print---';
")

(defun println--- (fno string file mode)
  (let ((stream (if file (openstream file mode))))
    (formatl stream string t)
    (closestream stream)))

(osql "
create function println(charstring str, charstring file, charstring mode) -> boolean b
as foreign 'println---';
")

(defun get-func (func &rest args)
  "Get a func (property) of an object and maximally unnest the result.
   Purpose: to make life easier when calling OSQL from Lisp."
  (let (res)
    (setq res (getfunction (mkatom func) args))
    (cond ((null res)
	   nil)
	  ((= (length res) 1)
	   (if (= (length (car res)) 1)
	       (caar res)
	       (car res)))
	  ((= (length (car res)) 1)
	   (mapcar 'car res))
	  (t
	   res))))

; Workaround the lack of outer join
(defun default--+ (fno b d o)
  (let (has-elements)
    (mapbag  b
	     (f/l (x)
		  (setq has-elements T)
		  (osql-result b d (if (listp x) (car x) x))))
    (if (null has-elements)
	(osql-result b d d))))
(osql "
create function default(bag b, object d) -> object
as foreign 'default--+';
")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Export collections to tables stored as files.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;<table BORDER COLS=2 WIDTH="100%" >
;<tr><td></td><td></td></tr>
;</table>
;tbl-pref tbl-suff row-pref row-suff field-pref field-suff recursive stop-after

(defun bag-to-string-+ (obj b str)
    (mapbag b
	    (f/l (tpl)
		 (let ((stream (opentextstream)))
		   (print-tuple tpl stream)
		   (osql-result b (textstreamstring stream))
		   (closestream stream)))))

(osql "
create function bag_to_string(bag b) -> bag of charstring s
as foreign 'bag-to-string-+';
")
  
(defun collection-to-table (coll &optional filename fs rs)
  "Print a collection of tuples to a file with optional field and row separators."
  (let ((field-sep (if fs fs " "))
	(row-sep (if rs rs T))
	(file (if (and (neq filename t) filename) (openstream filename "w") T))
	(rows 0)
	first-tpl max-idx mapfn)

    (cond ((arrayp coll)
	   (setq first-tpl (aref coll 0))
	   (setq mapfn 'maparray1))
	  ((listp coll)
	   (setq first-tpl (car coll))
	   (setq mapfn 'mapc)
	   (setq coll (kwote coll))))
    (setq max-idx
	  (cond ((arrayp first-tpl)
		 (- (array-total-size first-tpl) 1))
		((listp first-tpl)
		 (- (length first-tpl) 1))
		(t 0)))
    ; funcall does not work here, so use eval
    (eval (list
	   mapfn
	   (f/l (tpl)
		(1++ rows)
		(cond ((arrayp tpl)
		       (dotimes (idx max-idx)
			 (formatl file (aref tpl idx) field-sep))
		       (formatl file (aref tpl max-idx) row-sep))
		      ((listp tpl)
		       (dotimes (idx max-idx)
			 (formatl file (car tpl) field-sep)
			 (setq tpl (cdr tpl)))
		       (formatl file (car tpl) row-sep))
		      (t
		       (formatl file tpl row-sep))))
	   coll))
    (if (neq file T)
	(closestream file))
    rows))

(defun bag-to-table----+ (obj bag filename field-sep row-sep rows)
  (let ((fn (if (equal filename "") T filename))
	(fs (if (equal field-sep "") NIL field-sep))
	(rs (if (equal row-sep "") NIL row-sep))
	mat-bag res)
    (mapbag bag (f/l (x) (setq mat-bag (cons x mat-bag))))
    (setq res
	  (collection-to-table mat-bag fn fs rs))
    (osql-result bag filename field-sep row-sep res)))

(defun vector-to-table----+ (obj vec filename field-sep row-sep rows)
  (let ((fn (if (equal filename "") T filename))
	(fs (if (equal field-sep "") NIL field-sep))
	(rs (if (equal row-sep "") NIL row-sep))
	res)
    (setq res
	  (collection-to-table vec fn fs rs))
    (osql-result vec filename field-sep row-sep res)))


(osql "
create function bag_to_table(bag b, charstring file,
                             charstring colsep, charstring rowsep) -> integer
as foreign 'bag-to-table----+';

create function vector_to_table(vector v, charstring file,
                                charstring colsep, charstring rowsep) -> integer
as foreign 'vector-to-table----+';

create function bag_to_table(bag b, charstring file, charstring colsep) -> integer
as select bag_to_table(b, file, colsep, '');

create function vector_to_table(vector v, charstring file, charstring colsep) -> integer
as select vector_to_table(v, file, colsep, '');

create function bag_to_table(bag b) -> integer
as select bag_to_table(b, '', ' ');

create function vector_to_table(vector v) -> integer
as select vector_to_table(v, '', ' ');
")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aliases
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun maparray1 (fn arr)
  (maparray arr fn))

(defun q () (quit))
