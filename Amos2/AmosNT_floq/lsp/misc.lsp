;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997 Tore Risch, EDSLAB
;;; $RCSfile: misc.lsp,v $
;;; $Revision: 1.100 $ $Date: 2013/12/30 13:35:54 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;; =============================================================
;;; $Log: misc.lsp,v $
;;; Revision 1.100  2013/12/30 13:35:54  torer
;;; Better support for tuples
;;;
;;; Revision 1.99  2013/04/13 14:24:24  torer
;;; if 5 then return 2; failed
;;;
;;; Revision 1.98  2013/03/25 21:57:36  torer
;;; Wrong width in tuples(Stream)
;;;
;;; Revision 1.97  2013/02/07 21:24:42  torer
;;; Restored old MAP-OVER-PRED
;;;
;;; Revision 1.96  2012/10/12 07:44:16  torer
;;; Rewrites over OPTIONAL eliminated
;;;
;;; Revision 1.95  2012/07/23 20:27:58  torer
;;; Errors can now be caught through coroutines
;;;
;;; Revision 1.94  2012/05/23 13:13:58  torer
;;; CONFIRM-PROMPT moved to basic.lsp
;;;
;;; Revision 1.93  2012/05/15 13:34:25  torer
;;; (IS-FALSE X) test if X is representing FALSE or NULL in ObjectLog
;;;
;;; Revision 1.92  2012/05/02 20:50:26  torer
;;; New function (tailp tl l)
;;;
;;; Revision 1.91  2012/05/02 17:16:47  torer
;;; optional() aware optimization of conjunctions and
;;; order preserving generation of conjunctive predicate
;;;
;;; Revision 1.90  2012/04/27 14:19:44  thatr500
;;; rewrite OR compound predicate by VECTOR.IN if applicable.
;;; It is for performance-wise
;;;
;;; Revision 1.89  2012/04/26 12:49:38  torer
;;; optional(pred) now supported in AmosQL
;;;
;;; Revision 1.88  2012/04/25 18:39:08  torer
;;; New function (CALL-P PRED)
;;;
;;; Revision 1.87  2012/04/24 14:59:52  torer
;;; Using COMPOUND-P
;;;
;;; Revision 1.86  2012/04/24 14:07:13  torer
;;; ANDORP -> COMPOUND-P for more generality
;;;
;;; Revision 1.85  2012/03/24 10:34:50  torer
;;; New functions IS-TRUE and INFIX-STRING
;;;
;;; Revision 1.84  2012/01/20 13:09:35  minzh812
;;; Adding one more optional variable preds to map-over-pred
;;;
;;; Revision 1.83  2011/12/22 15:48:10  torer
;;; Mior core reorganization
;;;
;;; Revision 1.82  2011/12/22 13:55:36  torer
;;; Removed duplicated code
;;;
;;; Revision 1.81  2011/12/22 12:55:16  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.80  2011/12/21 20:59:37  torer
;;; Better documentation of Lisp kernel code
;;;
;;; Revision 1.79  2011/12/20 19:54:32  torer
;;; Added comments
;;;
;;; Revision 1.78  2011/11/22 18:02:52  torer
;;; Refactoring kernel Lisp code
;;;
;;; Revision 1.77  2011/01/31 06:51:15  torer
;;; Function CONFIRM-PROMPT moved
;;;
;;; Revision 1.76  2011/01/21 07:05:21  torer
;;; New macro (AMOS-WARNING X Y ...) for warning messages
;;;
;;; Revision 1.75  2010/12/10 18:10:40  torer
;;; TCONC in C
;;;
;;; Revision 1.74  2010/12/09 18:54:42  torer
;;; New function (map-done result) to terminate map function
;;;
;;; Revision 1.73  2010/09/02 18:04:17  torer
;;; Function MEMO-FUNCTION replaces macro CACHE and function MEMO
;;;
;;; Revision 1.72  2010/05/13 14:05:18  torer
;;; More informative error messages
;;;
;;; Revision 1.71  2010/05/13 13:39:42  torer
;;; Undo effect of generating variable outside scope
;;;
;;; Revision 1.70  2009/12/30 19:37:18  torer
;;; (TCONC) creates head
;;;
;;; Revision 1.69  2009/10/30 19:03:25  torer
;;; error message in TCONC
;;;
;;; Revision 1.68  2009/10/30 18:52:19  torer
;;; Using TCONC to build long lists
;;;
;;; Revision 1.67  2009/10/30 12:07:06  torer
;;; bug in TCONC
;;;
;;; Revision 1.66  2009/10/22 21:03:23  torer
;;; Scalable less recursive EXTERNALIZE
;;;
;;; Revision 1.65  2009/10/22 18:19:48  torer
;;; Interlisp's TCONC to add at the end of headed list
;;;
;;; Revision 1.64  2009/04/22 17:35:45  torer
;;; ALisp now stand-alone sub-module
;;;
;;; Revision 1.63  2009/04/03 17:38:43  torer
;;; New macro (TIME-SPENT FORM)
;;;
;;; Revision 1.62  2008/12/25 19:21:36  torer
;;; Removed unused functions
;;;
;;; Revision 1.61  2008/11/23 17:04:32  torer
;;; File position printed at errors
;;;
;;; Revision 1.60  2008/11/23 15:00:26  torer
;;; Stricter type checking
;;;
;;; Revision 1.59  2008/08/21 13:59:05  torer
;;; New function GENSYMBOLS
;;;
;;; Revision 1.58  2008/08/18 14:23:33  torer
;;; Setting bag values allowed
;;;
;;; Revision 1.57  2008/05/25 14:03:50  torer
;;; Large multi-directional TBRs not in-lined.
;;; Controlled by *max-substitutable-size*
;;;
;;; Revision 1.56  2008/05/21 08:08:34  torer
;;; Bug in cost recomputation of TBRs
;;;
;;; Revision 1.55  2008/04/03 15:00:49  torer
;;; reopt.lsp depatched
;;;
;;; Revision 1.54  2008/01/02 02:43:25  msabesan
;;; empty list will be skipped
;;;
;;; Revision 1.53  2007/12/20 16:15:19  msabesan
;;; " * is skipped "
;;;
;;; Revision 1.52  2007/12/18 11:36:24  torer
;;; Named subplans
;;;
;;; Revision 1.51  2007/10/24 21:14:55  torer
;;; Code moved to make modules independent
;;;
;;; Revision 1.50  2007/10/18 12:19:40  torer
;;; Non-standard definition of EOF-P removed
;;;
;;; Revision 1.49  2007/09/24 13:46:19  torer
;;; Bug in ARGSOF
;;;
;;; Revision 1.48  2006/11/15 14:22:10  torer
;;; Short function names in PC
;;;
;;; Revision 1.47  2006/11/07 21:59:58  torer
;;; Added Interlisp's listp, ILISTP
;;;
;;; Revision 1.46  2006/08/01 14:16:53  petrini
;;; Moved mksymbol1 from ref.lisp.lsp to misc.lsp
;;;
;;; Revision 1.45  2006/06/02 14:18:14  torer
;;; SUBSET in C
;;;
;;; Revision 1.44  2006/05/22 17:54:15  torer
;;; Correct handling of free variables in CAST
;;;
;;; Revision 1.43  2006/05/16 14:54:04  torer
;;; inn operator
;;;
;;; Revision 1.42  2006/05/02 15:34:23  torer
;;; Fixed bug with subquery over vector of
;;;
;;; Revision 1.41  2006/04/29 17:32:32  torer
;;; More general nested expressions in procedures
;;;
;;; Revision 1.40  2006/04/27 19:18:27  torer
;;; Removed unused functions
;;;
;;; Revision 1.39  2006/04/27 13:18:18  petrini
;;; Add general function, memo, for applying advice-around to functions.
;;;
;;; Revision 1.37  2006/04/14 18:35:32  torer
;;; Added MAP-OVER-PRED and SORT-PREDICATE
;;;
;;; Revision 1.36  2006/04/08 14:18:34  torer
;;; Moved basic CommonLisp functions to orginit.lsp
;;;
;;; Revision 1.35  2006/03/27 09:20:15  torer
;;; Added function GET-FUNC
;;;
;;; Revision 1.34  2006/02/22 20:50:17  torer
;;; Added some missing functions
;;;
;;; Revision 1.33  2006/02/15 07:23:22  torer
;;; Added generic caching macro: (CACHE HT KEY VAL)
;;;
;;; =============================================================

(defglobal _amosid_)
(document _amosid_ "Logical name of the Amos server")
(defvar *genvar* 0 "Number of next query variable to generate") 
(defvar *locals* nil "List of current local query variables")
(defglobal _tupletag_ 'tuple "The symbol to indicate a tuple")
(defglobal _MAXINT_ 2147483647 "Largest possible integer")
(defglobal _MININT_ -2147483648 "Smallest possible integer")

(defglobal _compound-predicates_ '(and or optional)
  "Supported compound predicates")

(defstruct binding var val type notypecheck context)
;;; ObjectLog variable binding descriptor

(defun amos-error (&rest args)
  "Print message from ARGS and raise error"
  (error (apply (function concat) (externalize args))))

(defmacro amos-warning (&rest args)
  "Print warning message"
  `(formatl t t "WARNING: " ,@args (in-function)(in-file) t))

(defun in-function () 
  (if *compiled-fn* (concat " in function " (externalize *compiled-fn* t))
    ""))

(defun in-file ()
  (if *current-loadfile*
      (concat " when loading " *current-loadfile* " " 
	      (1+ (line-num *current-loadstream*)))
    ""))

(advise-around 'error ;; To inform where error occurred 
	       '(progn (and (not _catch-errors_)
                            (not *in-break*)
			    (or *compiled-fn* *current-loadfile*)
			    (formatl t "Error" (in-function)(in-file) ":" t))
		       *))

(defun id(x) x)

(defun list2 (&rest l)(list l))

(defun appendl (l)
  (cond ((atom l) l)
	((listp (car l)) (append (car l) (appendl (cdr l))))
	(t (cons (car l)(appendl (cdr l))))))

(defun ilistp (x)
  "Interlisp's listp"
  (and (listp x) x))

(defun inv-logop (op)
  (selectq op
	   (< '>=)
	   (<= '>)
	   (> '<=)
	   (>= '<)
	   (error "Not a logical comparison" op)))

(defun tailp (tl l)
  "Is TL a tail of list L?"
  (cond ((eq tl l))
        ((atom l) nil)
        (t (tailp tl (cdr l)))))

(defun mapc2 (fn l)
  (mapl (f/l (tail)(funcall fn (car tail)(cadr tail))) l))

(defmacro ++1 (var) `(prog1 , var (1++ , var)))

(defmacro --1 (var) `(prog1 , var (1-- , var)))

(defun dump-hash-table (ht)
  "Print conttents of hash table"
  (maphash (f/l (k v) (formatl t k " : " v t)) ht))

(defun buildn (n x)
  "Construct a list having N same elements X"
  (let (res)
    (dotimes (i n)
      (push x res))
    res))

(defmacro tolist (x)
  "Make argument list construction" 
  `(if (arrayp ,x) (setq ,x (arraytolist ,x))
     (setq ,x (untuplify ,x))))

(defun untuplify (l)(mapcan (f/l (x)(if (tuplep x)(append (cdr x) nil) 
				      (list x)))
                            l))

(defun oids-in (s tpe)
  "Get list of OIDs of type TPE in S-expression S"
  (cond ((oid-p s)(if (object-typep s tpe) (list s) nil))
        ((atom s) nil)
        (t (nconc (oids-in (car s) tpe)(oids-in (cdr s) tpe)))))

(defmacro catch-and-repair (tag form repairaction)
  `(let ((result nil)
	 (evaluated nil))
     (catch , tag (progn (setq result , form) (setq evaluated t)))
     (if (not evaluated)
	 , repairaction
       result)))


(movd 'sort 'csort)

(movd 'symbolp 'litatom)

(defun pdebug (x)
  (pprint x)
  x) 

(defun genvarname (id)
  (if id (pack "_v_" id "_" (1++ *genvar*))
    (pack "_v" (1++ *genvar*))))

(defun genvar ()
  "Generate unique variable name on current host"
  (let ((v (genvarname _amosid_)))
    (while (or (getbinding v t)(memq v *locals*))
      (setq v (genvarname _amosid_)))
    (setq *locals* (cons v *locals*))
    (cond ((consp (symbol-value '*locals*))
	   (setq *locals* (delete v *locals*))
	   (error "System error, generating variable outside RESETGENVAR" v)))
    v))

(defun addbinding (var val type)
  "Add variable binding to current binding environment"
  (setq *bindings*
	(cons
	 (make-binding :var var :val val :type type)
	 *bindings*))
  var)

(defun dt_genvar (tp)
  "defines a new temporary variable and adds type binding to scope"
  (let ((v (genvar)))
    (prog1 (addbinding v nil tp)
      (cond ((consp (symbol-value '*bindings*))
	     (setq *bindings* (delete v *bindings*))
	     (error "System error, adding binding outside variable scope"
		    v))))))

(defun genvars (types)
  "Genereate local variables with TYPES" 
  (mapcar (function dt_genvar) types))

(defun ilength (l)
  "Interlisp LENGTH"
  (cond ((atom l) 0)
	(t (length l))))

(defun sorttuples (l) (csort l 'list<))

(defun list< (x y) (< (compare x y) 0))

(defun list<= (x y)(not (list< y x)))

(defun eqstart (x y)
  "Is list Y the beginning of list X?"
  (cond ((atom x) t)
	((eq (car x)(car y))(eqstart (cdr x)(cdr y)))))

(defun smash (old new)
  (if (consp old)
      (if (consp new)
	  (rplaca
           (rplacd old
		   (cdr new))
           (car new)))))

(defun buildl (l x)
  (mapcar
   (function (lambda (y) x))
   l))

(movd 'eq 'eq?)

(defun extend (a b) (if (listp b) (cons a b)(list a b)))

(defun make-key (form)
  (cond ((atom form) form)
	((consp (cdr form)) form)
	(t (car form))))

(defun element-args (l n res)
  "make argument list to pick 1st N elements of L"
  (cond ((< n 1) res)
	(t  (element-args l (1- n) (cons (list (nthfn n) l)res)))))
		
(defun nthfn (n)
  "Returns the Lisp function to access Nth element of list"
  (selectq n
	   (1 'car)(2 'cadr)(3 'caddr)(4 'cadddr)
	   (list 'lambda '(x) (list 'nth (1- n) 'x))))

(defun argsof (fn form)
  (cond ((null form) nil)
        ((atom form) (list form))
	((eq (car form) fn) (cdr form))
	(t (list form))))

(defun funify (fn args)
  "Make function call of FN for ARGS if length(args)>1; otherwise car(args)"
  (cond
   ((atom args) args)
   ((atom (cdr args)) (car args))
   (t (cons fn args))))

(defun andp (fn)(eq fn 'and))

(defun andify (l)
  "Make a conjuction of predicates in L"
  (cond ((null l) 'true)
	((atom l) l)
	(t (let ((l1 (mapcan (f/l (p)
				  (cond ((eq p 'true) nil)
					((and (consp p)(andp (car p)))
					 (argsof 'and (andify (cdr p))))
					(t (list p))))
			     l)))
	     (cond ((null l1) 'true)
		   ((memq 'false l1) 'false)
		   (t (funify 'and l1)))))))

(defun unandify (predl)
   "Unnest all ANDs in conjunction of predicates in PREDL"
  (mapcan (f/l (p)(if (and-p p)(append (cdr p))(list p)))
          predl))

(defun orp (fn)(eq fn 'or))

(defun orify (l)
  "Make a disjunction of predicates in L"
  (if (atom l) l
    (let ((l1 (mapcan (f/l (p)
			   (cond ((eq p 'false) nil)
                                 ((null p) nil)
                                 ((and (consp p)(eq (car p) 'or))
				  (argsof 'or (orify (cdr p))))
				 (t (list p))))
		      l)))
      (cond ((null l1) 'false)
	    (t (funify 'or l1))))))

(defun compound-p (pred)
  "Is PRED a compound predicate?"
  (and (consp pred) (memq (car pred) _compound-predicates_)))

(defun optional-p (pred)
  "Is PRED and OPTIONAL compound predicate?"
  (and (consp pred)(eq (car pred) 'optional)))

(defun and-p (pred)
  "Is PRED and AND?"
  (and (consp pred)(eq (car pred) 'and)))

(defun call-p (pred)
  "Is PRED a foreign function call?"
  (and (consp pred)(eq (car pred) 'call)))
 
(defun make-optional (pred)
  "Make PRED OPTIONAL"
  (cons 'optional (andargs pred)))

(defun andargs (pred)
  "Regard PRED as argument list of AND"
  (argsof 'and pred))

(defun is-true (bool)
  "Is the Amos constant BOOL represting true?"
  (eq bool 'true))

(defun is-not-false (bool)
  "Is the Amos constant BOOL regarded as true in if-then-else?"
  (not (is-false bool)))

(defun is-false (bool)
  "Is the Amos constant BOOL represting false?"
  (or (null bool)(eq bool 'false)(eq bool '*)))

(defun mappred (pred fn)
  "Apply FN on each primitive predicate in PRED"
  (if (compound-p pred)(dolist (p (cdr pred))(mappred p fn))
    (funcall fn pred)))

(defun pred-size (pred)
  "Count the number of primitive predicates in PRED"
  (let ((cnt 0))
    (mappred pred (f/l (p)(1++ cnt)))
    cnt))

(defun map-over-pred (pred simpfunc compfunc)
  "Transform predicate PRED by applying (SIMPFUNC S) on very simple 
   predicate S in PRED and (COMPFUNC C) on every compound predicate"
  (cond ((compound-p pred)
	 (let ((bdy (mapcar (f/l (x)
				 (map-over-pred x simpfunc compfunc))
			    (cdr pred))))
	   (funcall compfunc (selectq (car pred)
                                 (and (andify bdy))
                                 (or (orify bdy))
                                 (cons (car pred) bdy)))))
	(t (funcall simpfunc pred))))

(defun sort-predicate (pred)
  "Sort predicate to make it canonical"
  (map-over-pred pred (function id)
		 (f/l (c)(cons (car c)(sort (cdr c) (function list<))))))

(defun select-get (select prop) 
  "Pick up property of parsed select expression"
  (cond ((eq prop 'distinct)(eq (cadr select) 'distinct))
	(t (if (eq (cadr select) 'distinct) (pop select))
	   (if (eq prop 'result) (cadr select)
	     (getf select prop)))))
                    
(defun mergel (x y fn) (merge x y fn))

(defun subsetp (x y)
  "Returns T if X is a subset of Y, NIL otherwise."
  (every (f/l (e)(member e y)) x))

(defun bpatlist (str)
  "Converts 'bbf' to (- - +)"
  (let ((cb (char-int "b"))(cf (char-int "f"))
	(txt (opentextstream)) res c)
    (princ str txt)
    (closestream txt)
    (loop
      (setq c (read-charcode txt))
      (cond ((eq c '*eof*) (return (nreverse res)))
	    ((eq c cb) (push '- res))
	    ((eq c cf) (push '+ res))
	    (t (amos-error "Not at legal binding pattern: " str))))))

(defun listbpat (bpat) 
  "Converts (- - +) to 'bbf'"
  (string-downcase (apply (function concat) 
			  (subst 'f '+  (subst 'b '- bpat)))))

(defmacro within-lisp (form)
  (list 'resetvar '*within-lisp* t form))

(defun toarray (x)
  (cond ((arrayp x) x)
        ((cdr x) (listtoarray x))
        ((arrayp (car x)) (car x))
        (t (listtoarray x))))

(defun heads (l) (mapcar (function car) l))

(defun pairlist (x y)(mapcar (function list) x y))

(defun substl (new old l)
  "Substitute any occurence of symbols in list old in l with new"
  (if (atom l) l
    (mapcar (f/l (x)(if (member x old) new x)) l)))

(defun subst-all (to from l)
  "Like SUBST but handles vectors too"
  (cond ((equal from l) to)
        ((arrayp l) (listtoarray (mapcar (f/l (x)(subst-all to from x)) 
					 (arraytolist l))))
        ((atom l) l)
        (t (cons (subst-all to from (car l))(subst-all to from (cdr l))))))

(defun pick-elem (path l)
  "Navigate along PATH into L"
  (cond ((null path) l)
	((listp l)(pick-elem (cdr path)
			     (nth (car path) l)))))

(defun make-string (size elem)
  "Make a new string of size 'size' initialized by 'elem'"
  (let ((stream (maketextstream size)))
    (rptq size (princ elem stream))
    (closestream stream)
    (textstreamstring stream)))

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

(defun concatl (l delimiter &optional transform-fn)
  "Turns a list into a string, transforming each element
   with transform-fn and inserting delimiter between each element."
  (let* ((fn (or transform-fn (function id)))
	 (s (or (and l (funcall fn (pop l))) "")))
    (dolist (token l)
      (setq s (concat s delimiter (funcall fn token))))
    s))

(defun infix-string (operator args)
  "Make an infix string for OPERATOR applied on ARGS"
  (let ((first t))
    (apply 'concat (mapcan (f/l (a)
				(cond (first (setq first nil) (list a))
				      (t (list " " operator " " a))))
			   args))))

;;; Efficient collection abstration. Implemented as hash tables.

(defun collection-member (x coll)(gethash x coll))

(defun collection-add (x coll)(setf (gethash x coll) t))

(defun collection-del (x coll)(remhash x coll))

(defun collection-map (fn coll)(maphash fn coll))

(defun make-collection ()(make-hash-table :test #'equal))

(defun collection-elements (coll)
  (let (res)
    (maphash (f/l (x y)(setq res (cons x res))) coll)
    res))

(defun memo-function (fn &optional args)
  "General function for making memo function from any function without 
   modifying it. Takes as arguments a function and optionally the arguments 
   of the function to be used as key in the cache (default all arguments)"
  (let ((cache (make-hash-table :test 'equal))
        (argl (or args (arglist fn))))
    (putprop fn 'cache cache)
    (advise-around fn 
		   `(or (gethash
			 , (cons 'list argl)
			 , cache)
			(setf (gethash
			       , (cons 'list argl)
			       , cache) *)))))

(defun clear-memo-function (fn)
  "Clear memo function cache"
  (clrhash (getprop fn 'cache)))

(defun getpos (x l)
  "Returns the position number for the first ocurrence of x in l. Uses equal."
  (let ((i 0))
    (dolist (el l)
      (if (equal x el) (return i))
      (1++ i))))

(defun list-positions (x l &optional start)
  "Compute positions of X in L"
  (if start nil (setq start 0))
  (cond ((null l) nil)
        ((equal x (car l)) 
	 (cons start (list-positions x (cdr l)(1+ start))))
        (t (list-positions x (cdr l)(1+ start)))))
 
(defun set-differencel (l ll)
  "Subtract elements in lists L1 from list L"
  (cond ((null ll) l)
	(t (set-differencel (set-difference l (car ll))
			    (cdr ll)))))

(defun minimum-element (lessthan l)
  "Returns the (first) minimum element in a list given a 'less than'
   function."
  (let ((minimum (first l)))
    (dolist (el (rest l))
      (if (funcall lessthan el minimum)
	  (setq minimum el)))
    minimum))

; Debugging macros
(defmacro debug_do (&rest rl)
  `(if _DEBUG_PRINT_ (progn ,@ rl)))

(defun debug_pt (text tree)
  (debug_do 
   (print "==============================================================" 
	  *trace-file*)
   (formatl *trace-file* text ":" t)
   (pps tree *trace-file*)))

(defun debugto (file)
  (tracelog file)
  (setq _DEBUG_PRINT_ t))

(defvar _in_ nil)
(defun rewrite-or-by-in-transformer (pred)    
  (let ((a (mapcar (f/l (p)
			(third p)) (cdr pred)))
	(v (second (second pred))))
    (list _in_ (listtoarray a) v)))

(defun rewrite-or-by-in-tester (pred)    
  "Test to replace (OR (= X 1) (= X 2) (= X 3)) by (IN (VECTOR 1 2 3) X)"
  (and 
   _in_
   (predicate-p pred)
   (compound-p pred)
   (listp pred)
   (eq (car pred) (second _compound-predicates_)) ;; OR
   (every (f/l (p) 
	       (and (predicate-p p) ;; (= X constant)
		    (eq (car p) _=_)
		    (eq (second p) (second (second pred)))
		    (constantp (third p))))
	  (cdr pred))))

