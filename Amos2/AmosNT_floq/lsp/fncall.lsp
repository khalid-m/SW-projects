;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1995-2004 Tore Risch, Martin Hansson EDSLAB, UDBL
;;; $RCSfile: fncall.lsp,v $
;;; $Revision: 1.105 $ $Date: 2013/12/30 23:51:48 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Compilation of AmosQL query and update statements
;;; =============================================================
;;; $Log: fncall.lsp,v $
;;; Revision 1.105  2013/12/30 23:51:48  torer
;;; Bug in setting functions with no arguments
;;;
;;; Revision 1.104  2013/12/30 13:35:54  torer
;;; Better support for tuples
;;;
;;; Revision 1.103  2013/11/19 08:36:11  torer
;;; (getfunction-nocheck fno argl) added
;;;
;;; Revision 1.102  2013/04/14 09:28:08  torer
;;; Much better compilation of stored procedures
;;;
;;; Revision 1.101  2013/04/13 14:24:23  torer
;;; if 5 then return 2; failed
;;;
;;; Revision 1.100  2013/04/13 13:35:42  torer
;;; Improved if-then-else compiler
;;;
;;; Revision 1.99  2013/04/13 12:52:51  torer
;;; Better compilation of if-then-else in stored procedures
;;;
;;; Revision 1.98  2012/11/04 12:43:21  torer
;;; Bug in if over null tuple
;;;
;;; Revision 1.97  2012/07/24 12:33:24  torer
;;; Make commands evaluated with evalv() return results
;;;
;;; Revision 1.96  2012/07/17 16:29:18  torer
;;; Generalized map-query() that handles statements and environment variables
;;;
;;; Revision 1.95  2012/05/23 20:22:52  torer
;;; (EXECUTE-STATEMENT STMT) executes amos statement immedieately
;;;                          ignoring the result
;;;
;;; Revision 1.94  2012/05/18 14:31:10  torer
;;; Errorneous warnings removed
;;;
;;; Revision 1.93  2012/05/07 17:35:10  torer
;;; prepare-query with select distinct did not work
;;;
;;; Revision 1.92  2012/05/03 19:34:30  torer
;;; pc("*select*"); now picks up the latest call to evalv()
;;;
;;; Revision 1.91  2012/04/25 18:38:00  torer
;;; New function (THESELECTBODY FN)
;;;
;;; Revision 1.90  2012/04/24 14:07:13  torer
;;; ANDORP -> COMPOUND-P for more generality
;;;
;;; Revision 1.89  2012/03/28 09:28:25  torer
;;; Streaming evalv()
;;;
;;; Revision 1.88  2012/03/13 15:03:48  torer
;;; (IS-QUERY Q) returns t if Q legal AMOSQL query
;;; PREPARE-QUERY bug fixed
;;;
;;; Revision 1.87  2012/02/21 07:45:56  torer
;;; More on-line documentation of function calls
;;;
;;; Revision 1.86  2012/02/21 07:29:37  torer
;;; Added some on-line documentation
;;;
;;; Revision 1.85  2011/12/23 16:15:06  torer
;;; minor
;;;
;;; Revision 1.84  2011/12/22 15:48:09  torer
;;; Mior core reorganization
;;;
;;; Revision 1.83  2011/12/22 13:55:35  torer
;;; Removed duplicated code
;;;
;;; Revision 1.82  2011/12/22 12:55:15  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.81  2011/04/01 17:56:48  torer
;;; Late bound update
;;;
;;; Revision 1.80  2011/02/13 15:57:29  torer
;;; leave now throws to label 'leave
;;;
;;; Revision 1.79  2011/01/31 06:52:40  torer
;;; New function
;;;   output_lines(Number)->Number
;;; to control # lines to print on terminal
;;;
;;; Revision 1.78  2011/01/30 18:54:58  torer
;;; Label LOOP-STATEMENT used for leaving 'loop' or 'while' statements
;;;
;;; Revision 1.77  2011/01/27 21:05:12  torer
;;; Added nomore(Scan)
;;; and the PSM control structures 'loop' and 'while'
;;;
;;; Revision 1.76  2011/01/27 15:44:53  torer
;;; Memory leak
;;;
;;; Revision 1.75  2011/01/26 20:50:02  torer
;;; Optimized variable assignment in procedures
;;;
;;; Revision 1.74  2010/09/14 14:59:48  andan342
;;; 'FOR EACH VECTOR OF ...' syntax bug fixed
;;;
;;;
;;; Revision 1.74  2010/09/14 16:57:18  andan342
;;; 'FOR EACH VECTOR OF' bug fixed in OSQL-EXPANDFOREACH
;;; 
;;; Revision 1.73  2010/08/27 07:49:56  torer
;;; Type inference of {} in function arguments
;;;
;;; Revision 1.72  2010/05/26 15:28:24  torer
;;; Documentation of global variables
;;;
;;; Revision 1.71  2009/11/16 20:05:50  torer
;;; Fewer reoptimizations
;;;
;;; Revision 1.70  2009/11/13 19:02:01  torer
;;; New function (check-optimized fno) to reoptimized fno is needed
;;;
;;; Revision 1.69  2009/10/30 18:52:19  torer
;;; Using TCONC to build long lists
;;;
;;; Revision 1.68  2009/03/28 16:03:15  torer
;;; Verification warning
;;;
;;; Revision 1.67  2008/11/17 20:27:56  torer
;;; Boolean expressions in select result
;;;
;;; Revision 1.66  2008/11/11 07:46:12  torer
;;; Stricter checking of conformance with result types in function definitions
;;; Can be turned off with
;;;    (setq _strict-resulttypes_ nil)
;;;
;;; Revision 1.65  2008/08/18 14:23:33  torer
;;; Setting bag values allowed
;;;
;;; Revision 1.64  2008/08/15 11:47:42  torer
;;; Transactional interface variables
;;;
;;; Revision 1.63  2007/11/20 10:00:15  torer
;;; Optionally reentrant MAP-SELECT
;;;
;;; Revision 1.62  2007/11/19 11:53:39  torer
;;; Using fast Lisp function to remove rows: REMFUNCTION0
;;;
;;; Revision 1.61  2007/11/05 16:47:30  torer
;;; New function REMOVE-TRUE-RESULT
;;;
;;; Revision 1.60  2007/11/04 20:33:15  torer
;;; Introduced function TRUE-RESULTP to test for result tuples returning (TRUE)
;;;
;;; Revision 1.59  2007/10/18 13:12:36  torer
;;; Now calling FUNCTION-ARGVARS and FUNCTION-RESVARS
;;;
;;; Revision 1.58  2007/09/16 10:36:31  torer
;;; Faster invocation of VREF from stored procedures
;;;
;;; Revision 1.57  2007/09/15 15:32:21  torer
;;; Bug when testing for dynamic result types in function call
;;;
;;; Revision 1.56  2007/09/14 18:02:12  torer
;;; Type inference did not work in fast-path calls
;;;
;;; Revision 1.55  2007/05/29 17:44:47  torer
;;; remove f(x)=<y,z> ... now works
;;;
;;; Revision 1.54  2007/03/11 17:11:04  torer
;;; Clear error message when doing illegal update
;;;
;;; Revision 1.53  2006/12/26 16:55:42  torer
;;; Coercion introduced
;;;
;;; Revision 1.52  2006/11/04 16:18:20  torer
;;; Systematically using GET-RESOLVENT-ARGTYPES and GET-RESOLVENT-RESTYPES
;;;
;;; Revision 1.51  2006/05/22 14:27:08  torer
;;; Too few parameters in call to FREE-VARIABLES
;;;
;;; Revision 1.50  2006/04/29 17:32:31  torer
;;; More general nested expressions in procedures
;;;
;;; Revision 1.49  2006/04/08 14:19:39  torer
;;; (GET-OC FNO) always used as accessor function for OID property ORGCODE
;;;
;;; =============================================================

(defglobal _interface-variables_ nil 
  "list of assigned interface variables in transaction")

(defglobal _select-keywords_ '(distinct into foreach where)
  "List of properties in parsed select statement")

(defglobal _dummy-mapfn_ '(lambda (x) t) 
  "Map function ignoring emitted results")

(defvar *stopafter* -1 "max size of scan. -1 => no limit")

(document mapfunction
	  "(extfn MAPFUNCTION (FNO ARGL MAPFN)...)
   Efficient function to call the Lisp function MAPFN for each result bag row
   (represented as a list) of calling the resolvent FNO with arguments
   ARGL.  The function call is NOT type checked and FNO thus must be the
   correct resolvent"
          mapfunction-apply
          "(extfn MAPFUNCTION-APPLY (FNO ARGL MAPFN)...)
   As MAPFUNCTION but MAPFN is applied on the result tuple rather than
   passing the result tuple as a list, to save CONSes"
          mapfunction-DIST
          "(extfn MAPFUNCTION-DIST (FNO ARGL MAPFN)...)
   As MAPFUNCTION but duplicates are removed in the result set"
          callfunction
          "(extfn CALLFUNCTION (FN ARGL)...)
   As GETFUNCION, but result tuples are vectors and duplicates are not removed"
          proccall
          "(extfn PROCCALL (FNO ARGL)...)
   Call a stored amos procedures FNO with arguments ARGL. 
   Returns T if there was at least one row returned by the call"
          direct-call
          "(extfn DIRECT-CALL (FNO ARGS)...)
   Returns T if FNO can be unambigously applied on ARGS 
   without type resolution"
          resolve-setcall
          "(extfn RESOLVE-SETCALL (NAME ARGS RES)...)
   Resolve AMOSQL set(ARGS)=RES;"
          callfunction1
          "(extfn CALLFUNCTION1 (FNO ARGS)...)
   Efficient not type resolved version of CALLFUNCTION"
	  )
; some precompiled files still use this now redundant function,
; so this is only for "backward compatibiliy"...
(defun setfunction0 (name key res &optional nocheck)
  "Backward compatibility"
  (setfunction-dynamic name key res nocheck))

(defun stop-after? ()	
  "Used by emit functions that stops by *STOPAFTER* iterations"
  (cond ((or (null *stopafter*) (< *stopafter* 0)) nil)
	((= *stopafter* 0) t)
	(t (setq *stopafter* (1- *stopafter*))
           nil)))
;;;
;;; Basic Amos II interface variable management
;;;

(defun osql-interfacevarp (x)
  "Is X a legal interface variable in current scope?"
  (cond (*within-proc* (litatom x))
	(t (keywordp x))))

(defun osql-interfacevar (x)
  "Get the symbol holding the interface variable X in current scope"
  (cond (*local-scoping*
	 (if (keywordp x)
	     (error "Interface variables disallowed in functions" x)
	   x))
        ((not (keywordp x))
         (error "Local variables disallowed in top loop" x))
        ((getprop x 'lispvar))
	(t (make-interfacevar x))))

(defun make-interfacevar (x)
  "Construct a symbol to hold interface variable X"
  (let ((var(pack "amos_" (mkstring (keyword-to-atom x)))))
    (putprop x 'lispvar var)
    (putprop var 'interfacevar x)
    (putprop var 'global t)
    var))

(defmacro assign-variable (var val)
  "Transactional SETQ for AmosQL variables"
  (cond ((or *within-proc* 
	     (not (getprop var 'interfacevar)));; Not interface variable
	 (list 'setq var val))
	(t `(if (boundp (quote , var) t)(setq , var , val);;local
	      (assign-global (quote , var), val)))))

(defun assign-global (var val)
  "Assign global interface variable transactional"
  (if (memq var _interface-variables_) nil
    (/setglobal '_interface-variables_ (cons var _interface-variables_))) 
  (/setglobal var val))

(defun unbind-interface-variables ()
  "Unbind permanently all global interface variables transactionally"
  (cond ( _persistent-interface-variables_)
        (t (prog1 _interface-variables_
	     (dolist (var _interface-variables_)
	       (set var 'nobind))
	     (set '_interface-variables_ nil)))))

;;;
;;; Compilation of AMOSQL ADD/SET/REMOVE/SELECT/FOREACH
;;;  (by Lisp macro expansion)
;;;

(defmacro set-function (fn argl &rest tail)
  "Compile parsed set function-name(...)=... [from ... where...];"
;;; (parse "set foo(x,y)=<a,b> from t1 a, t2 b where a>2 and foo(b);")
;;; (SET-FUNCTION FOO (X Y) (A B) 
;;;               FOREACH ((T1 A) (T2 B)) 
;;;               WHERE (AND (> A 2) (FOO B)))
  (compile-syscall-where 'setfunction fn argl tail *enclfn* nil t))

(defmacro add-function (fn argl &rest tail)
  "Compile parsed 'add function-name(...)=... [from ... where...]'"
;;; (parse "add foo(x,y)=<a,b> from t1 a, t2 b where a>2 and foo(b);")
;;; (ADD-FUNCTION FOO (X Y) (A B) 
;;;               FOREACH ((T1 A) (T2 B)) 
;;;               WHERE (AND (> A 2) (FOO B)))
  (compile-syscall-where 'addfunction fn argl tail *enclfn*))

(defmacro rem-function (fn argl &rest tail)
  "Compile parsed 'remove function-name(...)=... [from ... where...]'"
;;; (parse "remove foo(x,y)=<a,b> from t1 a, t2 b where a>2 and foo(b);")
;;; (REM-FUNCTION FOO (X Y) (A B) 
;;;               FOREACH ((T1 A) (T2 B)) 
;;;               WHERE (AND (> A 2) (FOO B)))

  (compile-syscall-where 'remfunction fn argl tail *enclfn* t))

(defmacro osql-foreach (&rest args)
  "Compile parsed 'foreach declarations where-clause do'"
;;; (parse "for each t1 a, t2 b where a=2 and foo(b) print(a);")
;;; (OSQL-FOREACH ((T1 A) (T2 B)) 
;;;               (AND (= A 2) (FOO B)) 
;;;               NIL 
;;;               (CALL-PROCEDURE PRINT (A)))
  (apply (function osql-expandforeach) args))

(defmacro call-function (fn argl &optional distinct)
  "Backward compatibility. Used only in ECA rules"
  (compile-syscall 'getfunction fn argl distinct))

(defmacro osql (string) 
  "Embedded AmosQL string in ALisp"
  (list 'within-lisp (parse string)))

(defmacro osql-select (&rest args)
  "Compile general AmosQL query statement"
;;; For example:
;;; (parse "select a,b,c from tpe x, tpe y where x=2 and y<5 and foo(a);")
;;; (OSQL-SELECT (A B C) 
;;;      FOREACH ((TPE X) (TPE Y)) 
;;;      WHERE (AND (AND (= X 2) (< Y 5)) (FOO A)))
  (cond (*within-proc*			; in stored procedure
	 (compile-procselect '_dummy-mapfn_ args)) 
	(*within-lisp*  (compile-callselect args)) ; in call from ALisp
	(t (compile-printselect args))) ; interactive stream print query
  )

(defun interface-variable-name (var)
  "Change :x to AMOS_X"
  (let ((*local-scoping* *within-proc*))
    (osql-interfacevar var)))

(defun subst-osqlvars (s)
  "Substitute all environment variable values in S"
  (cond ((osql-constantp  s) s)
	((osql-interfacevarp s)
           (let ((iv (osql-interfacevar s)))
             (if (boundp iv) (eval iv) iv)))
	((atom s) s)
	(t (mapcar (function subst-osqlvars x) s))))

(defmacro set-amosql-variable (var expr)
  "Parsed form of 'set var = expr;'"
  (cond 
   ((osql-constantp expr);; set var = 1; etc.
    (list 'assign-variable (interface-variable-name var) (kwote expr)))
   ((osql-variablep expr);; set var = x;
    (list 'assign-variable (interface-variable-name var)
	  (interface-variable-name expr)))
   (t;; set var = f(...);
    (let* ((sexpr (subst-osqlvars expr))
	   (type (type-of-expression sexpr t))
	   (vt (type-of-expression var t)))
      (cond 
       ((osql-constantp sexpr) 
	;; Happens only if TYPE-OF-EXPRESSION has smashed EXPR to constant
	(list 'assign-variable (interface-variable-name var) (kwote sexpr)))
       ((bag-type? type);; bag valued f(...) 
	(cond 
	 ((or (null vt) (bag-type? vt))
	  (if (subquery-p sexpr)
	      `(osql-select (,sexpr) into (,var))
	    `(osql-select ((bagof ,sexpr)) into (,var))))
	 (t (amos-warning "Not bag-declared variable " var 
			  " assigned bag valued call to function "
			  (car sexpr))
	    `(osql-select (,sexpr) into (,var)))))
       ((and vt (bag-type? vt))
	(error "Cannot assign atomic value to bag" var))
       (t `(osql-select (,sexpr) into (,var))))))))

(defmacro set-amosql-variables (varl expr)
  "Parsed 'set (v1,v2,...) = expr'"
  (cond ((null (cdr varl))(list 'set-amosql-variable (car varl) expr))
        ((or (osql-constantp expr)(osql-variablep expr)
             (eq (car expr) 'bagof))
         (error "Illegal multiple assignment to" varl))
        (t (let* ((expr (subst-osqlvars expr))
		  (typel (argsof 'tuple (type-of-expression expr)))
		  (vtl (mapcar (function type-of-expression v) varl)))
	     (cond 
	      ((not (= (length varl)(length typel)))
	       (error "Multiple assignment of single value to" varl))
	      (t `(osql-select (,expr) into ,varl)))))))

(defglobal _throw-true_ 'throw-true-test "mapper for TEST-QUERY")

(defun throw-true-test (tpl)
  (if (not (every (function is-false) tpl)) 
      (throw 'test-query t)))

(defun test-query-catch (selectexpr)
  (let ((bdy (macroexpand(compile-procselect '_throw-true_ selectexpr))))
    (cond ((eq (car bdy) 'mapfunction)
	   (list 'testfunction (second bdy)(third bdy)))
          ((match-form '(intfuncall _throw-true_ (list . *)) bdy) 
           (orify (mapcar (f/l (x) (list 'is-not-false x))
                          (cdr (third bdy)))))
	  (t (list 'catch ''test-query bdy)))))

(defmacro test-query (form) 
  "For testing conditional AMOSQL statements"
  ;; E.g. if a < b then result foo(a) else result foo(b);
  ;; is parsed into
  ;; (IF (TEST-QUERY (OSQL-SELECT ((< A B)))) 
  ;;     (OSQL-RETURN (FOO A)) 
  ;;     (OSQL-RETURN (FOO B)))
  (let ((*within-proc* t))
    (selectq (car form)
	     (osql-select
	      (test-query-catch (cdr form)))
	     (list 'let '((*within-proc* t)) 
		   form))))

(defmacro amosql-while (condition statements) 
  "PSM's while statement:
   'while condition do statements end while;'"
  `(catch 'leave
     (int-while (test-query (osql-select (,condition))) ,@statements)))

(defmacro amosql-loop (statements) 
  "PSM's while statement:
   'while condition do statements end while;'"
  `(catch 'leave (int-while t ,@statements)))

(defmacro amosql-leave()
   '(throw 'leave 'no-result))

(defvar *lineno* 0 "Used by PRINT-TUPLE-LINE to control terminal printing")
(defun compile-printselect (args)
  "Compile query statement that prints result streamed"
  `(catch 'print-done (let ((*lineno* 0))
			,(compile-procselect '(function print-tuple-line) args)
			'no-result)))

(defun tuplify (l)(cond ((osql-constantp l) l)
                        ((osql-variablep l) l)
                        ((tuplep l) l)
                        (t (funify _tupletag_ l))))

(defun map-grouped-bags (fno args keyl lfn)
  "Apply Lisp function LFN on result of FNO(ARGS) 
   with KEYL first values as key"
  (cond ((= keyl 0)
	 (let (res)
	   (mapfunction fno args
			(f/l (row)(push row res)))
	   (funcall lfn nil (list (bagify res)))))    
	(t (let ((kvb (make-hash-table :test (function equal))))
	     (mapfunction fno args
			  ;; compute new key/value bags
			  (f/l (row)
			       (let ((k (firstn keyl row)))
				 (push (nthcdr keyl row)
				       (gethash k kvb)))))
	     (maphash (f/l (key values)
			   (if (cdr values)(funcall lfn key 
						    (list (bagify values)));; bag
			     (funcall lfn key (car values))));; singleton 
		      kvb)))))

(defun update-where (lfn osqlfn arity resl foreach where)
  "Execute dynamic update statement with from or where clause"
  (cond ((and (null foreach)
              (null where)
	      (every-simplep resl))
         ;; trivial call
	 (funcall lfn osqlfn 
		  (firstn arity resl)
		  (nthcdr arity resl)))
	(t (let (fno)
	     (map-grouped-bags 
	      (generate-select resl foreach where)
	      nil
	      arity
	      (f/l (k v)
		   (if (null fno);; resolve on first encountered key
		       (setq fno (resolvename osqlfn k nil)))
		   (funcall lfn fno k v t)))))))

(defun compile-query (query)
  "Compile AMOSQL query string into transient function"
  (prepare-query query 0))

(defun parse-query (q)
  "Returns parsed query if Q is select expreesion and nil otherwise" 
  (let ((form (parse q)))
    (selectq (car form)
	     (osql-select form) 
	     nil)))

(defun is-query (q)
  "Returns T if Q is a select expression"
  (not (null (parse-query q))))

(defun prepare-query (query params)
  "Compile query string into AMOSQL function with parameters ?1,?2, etc."
  (let ((form (subst-osqlvars (parse-query query)))
        (ptypes (and params
		     (substdeclarations (declare-as-objects 
					 (genqvars params))))))
    (cond (form (selectq (cadr form)
			 (distinct 
			  (createsimplederivedfunction
			   _select_ ptypes nil
			   `((unique 
			      (select ,(caddr form) foreach 
				      ,(substdeclarations (getf (cdr form) 
								'foreach)) 
                                      where
				      ,(getf (cdr form) 'where))))
			   nil nil t))
			 (createsimplederivedfunction 
			  _select_ ptypes nil
			  (cadr form) 
			  (substdeclarations(getf form 'foreach))
			  (getf form 'where) 
			  t)))
	  (t (amos-error "Not a SELECT expression: " query)))))

(defmacro map-query (query fn) 
  "Immediately evaluate AmosQL statement QUERY and apply FN on result tuples"
  `(cond ((is-query , query)
	  (mapfunction-apply (prepare-query , query 0)
			     nil , fn))
	 (t (stmt-result , fn (within-lisp (eval (parse , query)))))))

(defun stmt-result (fn res)
  "Apply mapper on materialized AmosQL statement result"
  (cond ((eq res 'no-result) nil)
        (t (dolist (row (mklist res))
	     (cond ((consp row) (apply fn row))
		   (t (funcall fn row)))))))

(defun materialize-query (__query__)
  "Materialize result of execting AmosQL statement QUERY"
  (let ((__res__ (tconc)))
    (map-query __query__ (f/l (&rest row)(tconc __res__ row)))
    (car __res__)))

(defun execute-statement (stmt)
  "Execute amos statement while ignoring result"
  (map-query stmt (f/l (x) t)))

(defun generate-select (resl quant pred &optional fno) 
  "Generate query plan on the fly"
  (resetgenvar
   (let ((quant 
	  (substdeclarations quant))
         (fno (or fno _select_)))
     (createsimplederivedfunction fno nil nil resl quant pred t)
     (set-orgcode fno nil nil resl quant pred)
     fno)))

(defmacro compiled-update-where (lfn osqlfn arity resl foreach where distinct)
  "Fully compilable update statement with from or where clause"
  (cond
   ((if (null (or foreach where))
	(every-simplep resl))
    (list 'funcall (kwote lfn) (kwote osqlfn) (kwote (firstn arity resl))
	  (kwote (nthcdr arity resl))))
   ((numberp distinct)
    `(osql-mapselect 
      ,resl ,foreach ,where ,distinct
      (f/l (k v)(funcall (function ,lfn) ,(kwote osqlfn) k v))))
   (t `(osql-mapselect 
	,resl ,foreach ,where ,distinct
	(f/l (row)
	     (funcall (function ,lfn) ,(kwote osqlfn)
		      (firstn ,arity row) (nthcdr ,arity row)))))))

(defun compile-syscall (lfn fn argl resl)
  "Compile update-op fn(argl)=resl 
   where update-op can be e.g. addfunction, setfunction, or delfunction"
  (let (resvnt nocheck)
    (cond ((not (every-simplep argl))
	   (amos-error "Illegal function argument list of " fn)))
    (list lfn 
	  (cond ((keywordp fn) (compile-substosqlvars fn))
		((not (symbolp fn))(amos-error "illegal osql function " fn))
		((setq resvnt 
		       (car (combine-signatures 
			     (getfunctionnamed fn)
			     (procdcll argl)
			     (procdcll resl)
			     (resolvents (getfunctionnamed fn))
			     argl
			     nil)))
		 (setq nocheck t)
		 resvnt)
		(t (kwote fn))) 
	  (compile-substosqlvars argl)
	  (compile-substosqlvars resl)
	  nocheck)))

(defun compile-syscall-where (lfn fn argl rest enclfn &optional remflg group)
  "Compile general add/set/remove with from or where clause"
  (if (and (null (cdr rest))
           (every-simplep argl)
           (every-simplep (car rest)))
      (compile-syscall lfn fn argl (car rest))
    (apply 
     (function 
      (lambda (distinct resl into foreach where)
	(let ((where+ 
	       (cond ((or (not remflg)(null(cdr rest))) where)
					;no updates with quantified variables
		     ((null where) `(= ,(tuplify (car rest))
                                       (in (bagof,(cons fn argl)))
				       ))
		     (t `(and ,where 
			      (= ,(tuplify (car rest))
                                 (in (bagof ,(cons fn argl)))
				 ))))))
	  (if *within-proc* 
	      (let ((*vardeclarations* (append (substdeclarations foreach)
					       *vardeclarations*)))
		(list 'compiled-update-where lfn 
		      (resolve-callinproc 
		       (list (cons fn argl))
		       nil enclfn)
		      (length argl)
		      (append argl resl)
		      foreach where+
                      (if group (length argl) 'copy))) 
	    `(update-where 
	      (function , (interpreted-updatefn lfn))
	      ,(kwote fn)
	      ,(length argl)
	      ,(compile-substosqlvars 
		(append argl resl))
	      ,(kwote foreach)
	      ,(compile-substosqlvars where+))))))
     (parseselect rest '(foreach where)))))

(defun osql-expandforeach (resl pred distinct &rest body)
  "Macro expand parsed 'for each' expression"
  (let ((resv (getvars (substdeclarations resl)))) ;;added SUBSTDECLARATIONS call here - andan342
    (list 
     'proc-block
     (list 'osql-let resl 
	   (list 'osql-mapselect resv resl pred distinct
		 (list 'f/l 
		       (list '_key_) 
		       (list 'apply 
			     (list* 'f/l 
				    (append resv '(&optional -dummy-)) body) 
			     '_key_)))))))

(defun osql-mapselectexpand 
  (reslvars quant pred distinct dofn &optional enclfn restypes)
  "Compile (macroexpand) parsed query statement"
  (cond ((osql-trivialcallp reslvars quant pred)
	 (list 'funcall dofn (compile-substosqlvars reslvars)))
	((osql-callp reslvars quant pred) ; Call preoptimized OSQL function
	 (let ((aggfn (getprop (caar reslvars) 'aggfn)))
	   (cond (aggfn 
		  (list 'funcall dofn 
			(list 'list
			      (cons aggfn
				    (mapcar (function compile-substosqlvars)
					    (cdar reslvars))))))
		 (t			
		  ;; Build call to preoptimized OSQL function
		  (list 'invoke-function 
			(kwote (resolve-callinproc reslvars t enclfn))
			(compile-substosqlvars (cdar reslvars))
			distinct dofn)
		  ))))
	((not *within-proc*)
	 `
	 (map-select , 
	  (compile-substosqlvars reslvars)
	  (quote , quant)
	  , 
	  (compile-substosqlvars pred)
	  , 
	  distinct
	  , dofn))
	(t (let ((locvars (getvars quant))
		 argl argvars resl fno rem
		 (globdcl *vardeclarations*))
	     (setq argvars (free-variables (list 'select reslvars 
                                                 'foreach quant
                                                 'where pred)
                                           nil))
	     (cond ((null(setq rem 
			       (subset argvars 
				       (f/l (v) (null(searchdcl v globdcl))))))
		    (setq argl 
			  (mapcar 
			   (f/l (v) (list (dcl-type (searchdcl v globdcl)) v))
			   argvars))
		    (if restypes (setq resl (mapcar (function list) restypes))
		      (setq resl 
			    (mapcar 
			     (f/l (v)
				  (let ((tp (dcl-type (searchdcl v globdcl))))
				    (if tp (list tp)(list _object_))))
			     reslvars)))
		    (setq fno 
			  (createfunction 
			   '*transient*
			   argl resl reslvars quant pred nil t))
		    (list 'invoke-function (kwote fno) (cons 'list argvars)
			  distinct dofn))
		   (t (amos-error "Undeclared variables: " rem)))))))

(defmacro invoke-function (fn args distinct dofn)
  "Apply DOFN on result of calling Amos II function FN with ARGS.
   DISTINCT = T => remove duplicates first.
   DISTINCT = COPY => apply DOFN on copy of result.
   DISTINCT N => group result by N first elements in result tuples"
  (cond ((numberp distinct) ;; grouped invoke, e.g. setfunction
          (list 'map-grouped-bags fn args distinct dofn))
        ((or (not (known-call fn args))(generic? fn))
	 ;; This happens at very late binding
	 ;; when FN cannot be resolved at compile time based on
	 ;; static types of ARGS
	 (list 'mapfunctionres fn args distinct dofn))
	((eq dofn '_dummy-mapfn_)	
	 ;; Generate very efficient code to
	 ;; directly call procedures when FN has been fully resolved
	 (list 'proccall fn (vectorify args)))
	((eq distinct 'copy)		; Iterate over copy of rows
	 (list 'mapfunction-copy fn (vectorify args) dofn))
	(distinct
	 ;; Iterate over distinct values of function values
	 (list 'mapfunction-dist fn (vectorify args) t dofn))
	(t (list 'mapfunction		; Iterate of original rows
		 fn (vectorify args) dofn))))

(defun latebinding-reqdinproc? (gfno fargs)
  "Is late binding needed when calling GFNO(FARGS) in procedure?"
  (selectq fargs 
	   (late t)			; explicit late binding
	   (and (not (early-bound gfno))
		(subtype-of (type-of-most-spec-resolvntl 
			     fargs
			     (resolvents gfno)) 
			    ;;type sign of most spec resolvnt
			    fargs))))

(defun resolve-callinproc  (reslvars lbreq enclfn)
  "Type resolution of function call in procedure"
  (let* ((argtypelist (procdcll (cdar reslvars)))
	 (genfn (getfunctionnamed (caar reslvars)))
	 (late? (and lbreq (latebinding-reqdinproc? genfn argtypelist)))
	 (resultfn (if late? NIL 
		     (get-most-specific-resolvent genfn argtypelist))))
    (if (and (not late?)(not (null enclfn)))
	(addfunctionsusing enclfn resultfn))
      ;;;maintain dependencies between procedures and functions it uses
    (if late? (caar reslvars) resultfn)))

(defun procdcll (l)
  "Compute variable types of arguments in procedure call"
  (catch 'procdcll 
    (mapcar (f/l (arg)(let ((ta (type-of-expression arg)))
			(cond ((null ta) (throw 'procdcll 'late))
                              ((tuplep ta) ta)
			      ((not (consp ta)) ta)
			      (t (error "Illegal type" ta)))))
	    l)))

(defun instantiates-to (x)
  "Search *BINDINGS* to get what value X represents"
  (let (bnd val)
    (cond ((osql-constantp x) x)
          ((tuplep x)
           (cond ((null (setq bnd (get-tuple-binding x))) x)
                 ((setq val (binding-val bnd)) (instantiates-to val)) 
                 (t x)))
	  ((not (osql-variablep x)) x)
	  ((null (setq bnd (getbinding x))) x)
	  ((setq val (binding-val bnd)) (instantiates-to val))
	  (t x))))

(defun get-tuple-binding (tpl)
  (car (isome *bindings* (f/l (b)(equal (binding-var b) tpl)))))

(defun type-of-expression(v &optional smash)
  "Get the type(s) of an expression in a stored procedure"
  (let*((i (if (osql-interfacevarp v) (osql-interfacevar v) v))
	(r (searchdcl i *vardeclarations*)))
    (cond (r (car r))			; declared variable
	  ((osql-constantp i) (arg-type i))
          ((atom (setq i (subst-osqlvars i))) nil) ; not declared variable
          ((eq (car i) 'cast)
	   (cast-to-type i))
	  (t (let* ((*bindings* 
		     (nconc (vardeclarations-to-bindings *vardeclarations*)
			    *bindings*))
                    (*this-resolvent* _select_)
		    *locals*
		    (var (resetgenvar (flattenform i)))
		    (val (instantiates-to var))
		    (rtl (cond ((osql-constantp val)
				(if smash (smash v val)) 
				(list (arg-type val)))
                               ((tuplep val)(mapcar (function arg-type)
                                                    (cdr val)))
                               ((osql-variablep val) (list (arg-type val)))
                               (t (function-exactresulttypes (car val) 
							     (cdr val))))))
	       (tuplify rtl))))))

(defun vardeclarations-to-bindings (vardeclarations)
  "Convert *vardeclarations* to *bindings* (should really be same format)"
  (mapcar (f/l (vd)(make-binding :var (second vd) :type (first vd)))
          vardeclarations))

;;; Code to compile reasonably efficient OSQL calls embedded in Lisp

(defmacro call-procedure (fn args)
  "Used only in ECA rules. Backward compatibility"
  `(osql-select ((, fn ,@ args))))

(defun array-to-list (x)
  (if (arrayp x) (arraytolist x) x))

(defun compile-procselect (actionfn args)
  "Compile select expression embedded in stored procedure"
  (cond ((null (cdr args))
	 ;; Fast compilation of (nested) OSQL function calls
	 (list 'osql-mapselect (car args) nil nil nil actionfn))
	(t (apply 
	    (f/l (distinct resl into quant pred)
		 (cond ((eq into 'flat)
                        `(osql-mapselect
			  ,resl ,quant ,pred ,distinct
			  (f/l (-row-)
			       (,(unfunction actionfn)
				(array-to-list (car -row-))))))
                       (into (compile-select-into resl into quant pred 
                                                  distinct))
		       (t (list 'osql-mapselect 
				resl quant pred distinct actionfn))))
	    (parseselect args _select-keywords_)))))

(defun full-compile-select-into (resl into quant pred distinct)
  `(let (-notempty-)
     (catch 'osql-mapselect
       (osql-mapselect 
	,resl ,quant ,pred ,distinct 
	(f/l (-key-)
	     ;; if there is only one interface variable
	     ;; and there is more than one result, 
	     ;; make a tuple
	     ,@(cond ((and (= (length into) 1)
			   (> (length resl) 1))
		      `((assign-variable 
			 ,(osql-interfacevar (car into))
			 (listtoarray -key-))))
		     (t  (build-setinterfacevars into)))
	     (setq -notempty- 1)
	     (throw 'osql-mapselect nil))))
     (if -notempty- nil ,(nil-interfacevars into))))

(defun compile-select-into (resl into quant pred distinct)
  (let ((bdy (macroexpand `(osql-mapselect ,resl ,quant 
					   ,pred ,distinct dummy)))
        (tupleres (and (= (length into) 1)
		       (> (length resl) 1))))
    (cond ((and (eq (car bdy) 'mapfunction) *local-scoping*)
	   (list 'assignfunction (second bdy) (third bdy)
                 (kwote (mapcar (function osql-interfacevar) into))
		 tupleres))
          ((match-form '(intfuncall dummy (list . *)) bdy)
           (if tupleres (list 'assign-varieble (car into)
			      (cons 'vector (cdr (third bdy))))
             (prognify (mapcar (f/l (var val)
				    (list 'assign-variable var val))
			       into (cdr (third bdy))))))
	  (t (full-compile-select-into resl into quant pred distinct)))))

(defun nil-interfacevars (l)
  "Initialize interface variables in 'into xxx' in select to nil"
  (cond ((null l) nil)
	(t (list 'assign-variable (osql-interfacevar (car l)) 
		 (nil-interfacevars (cdr l))))))

(defun build-setinterfacevars (vars) 
  "Build list of SETQs from INTO clause of OSQL-SELECT"
  (cond ((null vars) nil)
	((null (cdr vars))
	 (list2 'assign-variable (osql-interfacevar (car vars)) '(car -key-)))
	(t (cons (list 'assign-variable (osql-interfacevar (car vars)) 
		       '(pop -key-))
		 (build-setinterfacevars (cdr vars))))))

(defmacro osql-mapselect (reslvars quant pred distinct dofn)
  "General compilation of OSQL-SELECT"
  (osql-mapselectexpand reslvars quant pred distinct dofn))

(defun osql-trivialcallp (argl quant pred)
  "Returns TRUE if a SELECT statement degenerates to application of DOFN"
  (and (null (or quant pred))
       (every (f/l (x)(or (osql-constantp x)
			  (osql-interfacevarp x)
			  )) argl)))

(defun osql-callp (argl quant pred)
  "Returns TRUE if a SELECT statement is a straight OSQL function call
   not needing any type checking or query processing"
  (and (null quant)(null pred)
       (null (cdr argl))
       (listp(car argl))
       (not (compound-p (car argl)))
       (not (function-with-dynamic-resulttypes (caar argl)))
       (every (f/l (a)(or (osql-constantp a)(osql-interfacevarp a)))
	      (cdar argl))))

(defun function-with-dynamic-resulttypes (x)
  "Test if X is a function having dynamic result types"
  (isome (resolvents (getfunctionnamed x t))
	 (function function-resulttypesfn)))

(defun every-simplep (argl)
  "Is no element in argument list function call?"
  (and (neq (procdcll argl) 'late)
       (let (notsimple)
	 (mapl (f/l (tl)
		    (let ((c (aggr-constant (car tl)))) 
		      ;; make constant if possible
		      (cond ((neq c (car tl))
			     (rplaca tl c)) ; argument made constant
			    ((osql-constantp c))
			    ((atom c))	; variable
			    (t (setq notsimple t))))) ; fn call
	       argl)
	 (not notsimple))))
  
(defun thrownotnull ()
  "For select execution where only first tuple needed"
  (throw 'select t))

(defun resolvename1 (name key res)
   "Called from C for complex function call resolutions"
   (resolveargs (getfunctionnamed name)
     (key-list key)
     (arglist-types (key-list res))))

(defun catch-resolve-setcall (name key res)
  "Wrapper for calling complex function call resolutions from C"
  (resolvename name key res))

(defun listed-arglist (argl)
  "Is AmosQL argument list expressed using LIST?"
  (or (null argl) (and (listp argl) (eq (car argl) 'list))))

(defun known-call (fn key)
  "Is this function call fully resolvable by compiler?"
  (and (oid-p fn) (listed-arglist key)))

(defun known-set (fn key res)
  "Is this function update fully resolvable by compiler?"
  (and (known-call fn key)(listed-arglist res)
       (cond ((eq (function-resulttype fn) _boolean_)
	      (or (equal res '(list true))(equal res '(list false))))
	     ((is-bag (cadr res)) nil)
	     (t t))))

(defun vectorify (argl)
  "Make a VECTOR call"
  (cons 'vector (cdr argl)))

(defun interpreted-updatefn (fn)
  "Get the dynamic update functions for ALisp function implementing 
   an simple update statement"
  (selectq fn
	   (addfunction 'addfunction-dynamic)
	   (remfunction 'remfunction-dynamic)
	   (delfunction 'delfunction0)
	   (setfunction 'setfunction-dynamic)
	   fn))

(defun getfunction (name argl &optional distinct)
  "Call AmosQL function NAME with ARGL. Result returned as list of rows.
   DISTINCT => remove duplicates."
  (let ((res (tconc nil)))
    (mapfunctionres name argl distinct
		    (function(lambda (x)(tconc res x))))
    (first res)))

(defun getfunction-nocheck (fno argl)
  "Call AmosQL function NAME with ARGL without type checking"
  (let ((res (tconc nil)))
    (mapfunction fno argl
		 (function(lambda (x)(tconc res x))))
    (first res)))

(defun getfunction-firsttuple (name argl &optional fastflg)
   "Get 1st tuple from calling AmosQL resolvent NAME with argument ARGL.
    No type resolution"
   (catch 'getfunction-firsttuple
     (mapfunction (if fastflg name (resolvename name argl nil)) argl
       (function
         (lambda (x)
           (throw 'getfunction-firsttuple x))))))

(defun mapfunction-copy (fno argl fn)
  "Call FN for each result row of calling AmosQL function FNO with ARGL.
   No type resolution"
  (let ((rows (tconc nil)))
    (mapfunction fno argl
		 (f/l (row)(tconc rows row)))
    (dolist (row (first rows)) 
      (funcall fn row))))

(defun mapfunctionres (name argl distinct fn)
  "Apply FN on result of calling Amos function NAME for ARGL.
   NAME is type resolved. DISTINCT => remove duplicates"
  (tolist argl)
  (setq name 
	(resolvename name argl nil))
  (if (getobject name 'need_recomp)
      (recompile_depend name))
  (mapfunction-dist name argl distinct fn))

(defmacro addfunction (name key res &optional nocheck)
  "Compiles set name(key)=res; NOCHECK => No type resolution"
  (if (and nocheck (known-set name key res))
      (parteval-addfunction name (cdr key) (cdr res))
    `(let* ((fnct (getfunctionnamed , name))
	    (nkey (dynamic-coerce (get-resolvent-argtypes fnct) , key))
	    (nres (dynamic-coerce (get-resolvent-restypes fnct) , res)))
       (addfunction-dynamic , name nkey nres , nocheck))))

(defmacro remfunction (name key res &optional nocheck)
  "Compiles remove name(key)=res; NOCHECK => no type resolution"
  (cond ((and nocheck (known-set name key res))
	 (parteval-remfunction name (cdr key) (cdr res)))
	(t (list 'remfunction-dynamic name key res nocheck))))

(defmacro delfunction (name key &optional nocheck)
  "Removed value of name(key). NOCHECK => no type resolution"
  (if (and nocheck (known-call name key))
      (parteval-delfunction name key)
    (list 'delfunction0 name key nocheck)))

(defun parteval-delfunction (name key)
  "Compile time expansion of DELFUNCTION when possible"
  (let ((rpat  (buildn (ilength (function-resvars name)) ''*)))
    (list 'remfunction name key (cons 'list rpat) t)))

(defun clearfunction (fno transactional)
  "Removes the extent of a stored function"
  (let ((r (get-relation fno)))
    (cond ((null r)(error "Can only clear stored functions" fno))
	  (transactional (/clearrelation r) fno)
	  (t (clearrelation r) fno))))

(defun getselectbody (fn)
  "Get selectbody of Amos function FN"
  (getobject (if (atom fn)(getfunctionnamed fn) fn) 'selectbody))

(defun theselectbody (fn)
  "Get the unique resolvent selectbody of function FN"
  (getselectbody (theresolvent fn)))

(defun delfunction0 (name key nocheck)
  "Delete all values in AmosQL function name(key). 
   No type resolution if NOCHECK != nil"
  (or nocheck (setq name (resolvename name key nil)))
  (let ((sb (getselectbody name)))
    (remfunction name key
 		 (buildn (ilength (selectbody-resl sb)) '*)
 		 t)))

(defun delpredfunction (fno)
  "The (unique) predicate function used when deleting instances of FNO"
  (or (car (selectbody-delpred (getselectbody fno)))
      (error "Function not updatable" fno)))
     
(defun compile-callselect (args)
  "Compile (macroexpand) select statement embedded in ALisp"
  (cond
   ((and (select-get args 'into)
         (neq (select-get args 'into) 'flat))
    (compile-procselect nil args))
   (t `(prog-let ((-res- (tconc nil)) (*stopafter* *stopafter*))
		 ,(compile-procselect 
		   '(f/l (-key-)
			 (if (stop-after?) (return (first -res-))
			   (tconc -res- -key-))) 
		   args)
		 (first -res-)))))

(defun map-select (resl quant pred distinct dofn &optional createfno)
  "Iterate over result from dynamic SELECT expression"
  (let ((fno (if createfno (create-transient-object _function_) 
	       _select_)))
    (cond
     ((and (null (or quant pred))
	   (every (function osql-constantp)
		  resl))
      (funcall dofn resl))
     (t (generate-select resl quant pred fno)
	(mapfunctionres fno nil distinct dofn)))))

(defun extent (fn &optional type)
  "Compute extent of Amos function as list of tuple lists"
  (let ((res (tconc nil)))
    (map-function-extent (getuniqueresolvent fn type)
			 (f/l (row)(tconc res row)))
    (first res)
    ))

(defun map-function-extent (fno lfn)
  "Iterate over the extent of Amos function FNO"
  (map-matching-function-extent fno '* lfn))

(defvar *cmd*) ; currently executed AmosQL string

(defun amos-execute (*cmd* &optional *stopafter*)
  "Dynamic execution of AMOSQL command CMD"
  (within-lisp
   (eval(parse *cmd*))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; User-defined update functions. It is possible to declare a user-
; defined update function for a given function by using
; Martin Hansson
;
; set-addfunction (fn addfn)
; set-remfunction (fn addfn)
; set-setfunction (fn addfn)
;
; a user-defined add-function can be a function or procedure taking
; as as arguments the 'full tuple' e.g/ for a function 
; foo(integer)->integer the set function will be 
; set_foo(integer, integer), any return value ignored.
;
; set_foo is registered with 
; (set-setfunction 'foo 'integer.integer.set_foo->boolean)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun set-addfunction (fn addfn)
  "Declares a set function for a particular resolvent."
  (let ((fno (getfunctionnamed fn)))
    (/putobject fno 'addfn addfn)))

(defun set-remfunction (fn remfn)
  "Declares a remove function for a particular resolvent."
  (let ((fno (getfunctionnamed fn)))
    (/putobject fno 'remfn remfn)))

(defun set-setfunction (fn setfn)
  "Declares an add function for a particular resolvent."
  (let ((fno (getfunctionnamed fn)))
    (/putobject fno 'setfn setfn)))

(defun get-addfunction (fn)
  "Retrieves a custom add function for the resolvent, if any is declared."
  (let ((fno (getfunctionnamed fn)))
    (getobject fno 'addfn)))

(defun get-remfunction (fn)
  "Retrieves a custom remove function for the resolvent, if any is declared."
  (let ((fno (getfunctionnamed fn)))
    (getobject fno 'remfn)))

(defun get-setfunction (fn)
  "Retrieves a custom set function for the resolvent, if any is declared."
  (let ((fno (getfunctionnamed fn)))
    (getobject fno 'setfn)))

;;; Find the update function in the static case (resolvent known in advance)


(defun true-resultp (x)
  "Is boolean function returning value TRUE?"
  (equal x '(true)))

(defun remove-true-result (result)
  "Single boolean result tuple replaced with nil"
  (if (true-resultp result) nil result))

(defun parteval-addfunction (fno key res)
  "Partial evaluation of ADDFUNCTION when function constant"
  (let ((diy-addfn (get-addfunction fno))) ;is a DIY add function declared?
    (cond ((member res '((false) (nil))) nil) 
                                     ;;;add foo(...)=false or nil; is dummy
	  (diy-addfn `(proccall , diy-addfn (list ,@ (append key res))))
	  (t (if (true-resultp res)(setq res nil))
	     (list '/assertrelation (delpredfunction fno)
		   (cons 'vector (substdelpred fno key res t)))))))

(defun parteval-remfunction (obj key res)
  "Partial evaluation of REMFUNCTION when function constant"
  (let ((diy-remfn (get-remfunction obj)))
    (cond (diy-remfn `(proccall , diy-remfn (list ,@ (append key res))))
	  (t (if (or (true-resultp (cdr res))(equal (cdr res) 'false))
		 (setq res nil))
	     (list '/retractrelation (delpredfunction obj)
		   (cons 'vector
			 (substdelpred obj key res t)))))))

(defmacro setfunction (name key res &optional nocheck)
  "Compiles: set fn(key)=res;"
  (let ((diy-setfn))
    (if (and nocheck (known-set name key res))
	(if (setq diy-setfn (get-setfunction (getfunctionnamed name)))
	    `(proccall , diy-setfn (list ,@ (append (rest key)(rest res))))
	  `(progn (delfunction , name , key , nocheck)
		  (addfunction , name , key , res , nocheck)))
      `(setfunction-dynamic , name , key , res , nocheck))))


;;; Find the update function in the dynamic case, only generic name known

(defun addfunction-dynamic (name key res nocheck)
  "interprets add(key)=res;"
  (let (custom-addfn)
    (if nocheck nil (setq name (resolve-setcall name key res)))
    (tolist key)(tolist res)
    (if (true-resultp res)
	(setq res nil))
    (cond ((is-bag (car res))
           (mapbag (car res) (f/l (row)
			    (addfunction-dynamic name key row nocheck))))
	  (t (setq custom-addfn (get-addfunction name))
	     (cond (custom-addfn(mapfunction custom-addfn 
					     (append key res) 
					     (function id)))
		   ((delpredfunction name)
		    (addfunction0 name key res t)))))))

(defun remfunction-dynamic (name key res nocheck)
  "interprets remove(key)=res;"
  (let (xpr custom-remfn)
    (if nocheck nil (setq name (resolve-setcall name key res)))
    (tolist key)(tolist res)
    (if (true-resultp res)
	(setq res nil))
    (cond ((is-bag (car res))
           (mapbag (car res) (f/l (row)
				  (remfunction-dynamic name key row nocheck))))
	  (t    (setq custom-remfn (get-remfunction name))
		(cond (custom-remfn (mapfunction custom-remfn 
						 (append key res) 
						 (function id)))
		      ((delpredfunction name)
		       (remfunction0 name key res t)))))))

(defun setfunction-dynamic (name key res &optional nocheck)
  "Interprets set f(key)=res;"
  (let (custom-setfn)
    (if nocheck nil (setq name (resolve-setcall name key res)))
    (tolist key)(tolist res)
    (if (true-resultp res)
	(setq res nil))
    (setq custom-setfn (get-setfunction name))
    (cond (custom-setfn
	   (mapfunction custom-setfn 
			(append key res) 
			(function id)))
	  (t (delfunction name key t)
	     (addfunction name key res t)))))
