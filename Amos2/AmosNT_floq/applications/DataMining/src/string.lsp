;;; ============================================================
;;; Description: Lisp implementation of some useful string 
;;; functions: replace, explode, explodeon, infront, back   
  

(defun replace (str x y)
  "Replaces all occurances of string x in string str with string y."
  (if (> (length x) 0)
      (let ((p (string-pos str x)))
	(cond (p
	       (concat (if (> p 0) (substring 0 (- p 1) str) "")
		       y
		       (if (<= (+ p (length x)) (- (length str) 1))
			   (replace (substring (+ p (length x)) (- (length str) 1) str) x y)
			 (replace "" x y))))
	      (t str)))
    str))


(defun replace---+ (fno str x y)
  (osql-result str x y (replace str x y))) 

(osql "
create function replace(Charstring str, Charstring x, Charstring y)
                        -> Charstring
/* Replaces all occurances of string x in string str with string y. */
  as foreign 'replace---+';  
")


; There is already a lisp function called explode that tokenizes 
; a string into its characters. Expose it in Amos.

(defun explode-+ (fno str)
  (osql-result str (listtoarray (explode str)))) 

(osql "
create function explode(Charstring str)
                        -> Vector of Charstring
/* Explodes string str into its characters */   
  as foreign 'explode-+';  
")

(defun explodeon (str x)
  "Explodes string str on string x." 
  (if (> (length x) 0)
      (let ((p (string-pos str x)))
	(cond (p
	       (cons (if (> p 0) (substring 0 (- p 1) str) "")
		     (if (<= (+ p (length x)) (- (length str) 1))
			 (explodeon (substring (+ p (length x)) (- (length str) 1) str) x)
		       (explodeon "" x))))
	      (t (list str))))
    NIL))

(defun explodeon--+ (fno str x)
  (osql-result str x (listtoarray (explodeon str x)))) 

(osql "
create function explodeon(Charstring str, Charstring x)
                        -> Vector of Charstring
/* Explodes string str on string x. */
  as foreign 'explodeon--+';  
")

(defun infront (str x)
  "Returns the substring of string str that is before string x."
  (if (> (length x) 0)
      (let ((p (string-pos str x)))
	(cond (p (if (> p 0) (substring 0 (- p 1) str) ""))
	      (t str)))
      NIL))

(defun infront--+ (fno str x)
  (osql-result str x (infront str x))) 

(osql "
create function infront(Charstring str, Charstring x)
                       -> Charstring
/* Returns the substring of string str that is before string x. */
  as foreign 'infront--+';  
")

(defun back (str x)
  "Returns the substring of string str that is after string x."
  (if (> (length x) 0)
      (let ((p (string-pos str x)))
	(cond (p (if (<= (+ p (length x)) (- (length str) 1))
		     (substring (+ p (length x)) (- (length str) 1) str)
		   ""))
	      (t str)))
    NIL))

(defun back--+ (fno str x)
  (osql-result str x (back str x))) 

(osql "
create function back(Charstring str, Charstring x)
                       -> Charstring
/* Returns the substring of string str that is after string x. */
  as foreign 'back--+';  
")
