;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1993-2006 Jonas S Karlsson, Tore Risch, 
;;;             Timour Katchaounov EDSLAB,UDBL
;;; $RCSfile: trace.lsp,v $
;;; $Revision: 1.75 $ $Date: 2013/12/30 13:07:41 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: trace/break/debug/profiling system for ALisp functions
;;; =============================================================

; Globals to control debugging
(defglobal _BREAKPOINTS_ nil "Enables breakpoints by BP")
(defglobal _DEBUG_PRINT_ nil "Enables query compilation debug printing")

; This is a simple function tracer - it wraps the function to be traced
; With "(trace <funcname> )"  Remove the trace with "(untrace <funcname> )".
; 
;
; NOTE: *  Trace also uses property virginfn to store the originial function.
;       -> therefore untrace also removes break and vice versa. 
;       *  It is possible to both break and trace a function, but the result
;          depends upon the order they were traced or breaked.
;       *  (Trace on SETQ, CONS and other LISP functions used in the 
;          implementation of the wrap package itself is FORBIDDEN.)
;

(defvar _env_ nil "Holds current stack frame in breakloop")
(defvar *backtrace-depth* 500 "Number of frames printed in backtrace")
(defvar *exclude-bt* '(eval apply applyenv if rptq cond and or let let* flet
			    apply-frame int-while while loop dolist do do* 
			    intfuncall resetvar unwind-protect
			    catch setq progn *bottom* 
			    selectq int-apply)
  "Functions excluded from backtrace")
(defvar *broken-functions* nil "Currently broken Lisp functions")
(defvar *traced-functions* nil "Currently traced Lisp functions")
(defvar *trace-file* nil "File stream for trace printings")
(defvar *trace-file-distr* nil "File name for distributed trace print")

(defglobal _break-help_			
  "
You are in the break loop. Commands:

:help    print this text
?=       print variables bound by current frame 
:fp      print file position and documentation of function at current frame
:lvars   names of local variables bound at current frame
(:arg N) get N:th argument in current frame
:bt      print a backtrace of Lisp functions called below current frame
:bto     print a backtrace of ObjectLog calls below current frame     
:btv     print a detailed backtrace of the frames below the current frame
:btv*    print detailed backtrace including unevaluated and SUBR arguments
:eval    evaluate current frame
!value   variable bound to value of the evaluation of current frame 
:a       change current frame to previous broken frame or reset
:r       reset to ALisp top loop 
:c       continue from broken frame
(return x) return value x from broken frame
:nx      set new current frame one step up the stack 
:pr      set new current frame one step down the stack
(:f FN)  set current frame to first frame down the stack calling FN
:ub      unbreak the function at current frame
(:b VAR) enter new breakloop whenever VAR becomes bound

otherwise evaluate form in environment of current frame
"
  ":help in break loop")

(defvar *TRACE-INDENT* -2 "Current trace indentation level")

(defglobal _amosid_ nil "System identifier")

(defun print-parameters (vars args str)
  "Prints an parameter-list, using the names in VARS and values in ARGS."
  (cond ((null vars))
	((atom vars)
	 (princ vars str)
         (princ "=" str)
         (prin1 args str)
         (princ " " str))
	((equal vars '(nil))
	 (cond (args
		(princ "<not used>=" str)
                (princ args str)
                (princ " " str))))
	((equal (cdr vars) nil)
	 (print-parameters (car vars) args str))
	(t
	 (print-parameters (car vars) (car args) str)
	 (print-parameters (cdr vars) (cdr args) str))))

(defun trace-enter (fn vars args)
  "Called by traces when entering a function"
  (if *trace-file-distr*
      (setq *trace-file* (openstream *trace-file-distr* "a")))
  (spaces *TRACE-INDENT* *trace-file*)
  (formatl *trace-file*
	   (if _amosid_ (concat _amosid_ " : --> ") "--> ")
	   fn " ( ")
  (print-parameters vars args *trace-file*)
  (formatl *trace-file* ")" t)
  (if *trace-file-distr* (closestream *trace-file*)))

(defun trace-return (fn val)
  "Called by tracer when leaving a function"
  (if *trace-file-distr*
      (setq *trace-file* (openstream *trace-file-distr* "a")))
  (spaces *TRACE-INDENT* *trace-file*)
  (formatl *trace-file*
	   (if _amosid_ (concat _amosid_ " : <-- ") "<-- ")
	   fn " = ")
  (prin1 val *trace-file*)
  (terpri *trace-file*)
  (if *trace-file-distr* (closestream *trace-file*))
  val)

; ================================
; TRACELOG
; -------

(defun tracelog (file)
  "Route trace printings to specified file.
   Close old routing first."
  (if *trace-file* (closestream *trace-file*))
  (cond (file (setq *trace-file* (openstream file "w")))
        (t (prog1 *trace-file* (setq *trace-file* nil)))))

(defun tracelog-distr (file)
  "Tracelog file for distributed tracing. We have to open and close it
   for each trace."
  (if *trace-file* (closestream *trace-file*))
  (setq *trace-file-distr* file)
					; rewrite the file
  (setq *trace-file* (openstream *trace-file-distr* "w"))
  (closestream *trace-file*))

; ================================
; MAKE-TRACE
; ----------
;

(defun make-trace (fn def params)
  "Wrap a traces around function FN with parameters FN and body DEF"
  (list (list 'let `((*TRACE-INDENT* (,(getd '+) 1 
				      (,(getd '+) 1 *TRACE-INDENT*))))
	      (list 'trace-enter  (kwote fn) 
		    (kwote (if (atom params) params (cdr params)))
		    params)
	      (list 'trace-return (kwote fn) def))))

(defun already-broken (fn)
  "Warning messages when double breaking or tracing"
  (cond ((null (getd fn))(list fn 'not-defined))
        ((member fn *traced-functions*) (list fn 'already-traced))
	((member fn *broken-functions*) (list fn 'already-broken))))
   
(defun tracefns (fns)
  "Trace functions in list FNS"
  (mapcar (f/l (brf)
	       (let ((fn (car (mklist brf))))
                 (cond ((member fn *broken-functions*)
                        (printl 'unbreaking fn)
                        (rembreak fn)))
		 (cond ((already-broken fn))
		       (t (prog1 (wrap-put brf 'make-trace)
			    (setq *traced-functions* 
				  (cons fn *traced-functions*))
			    )))))
	  fns))

(defmacro trace (&rest x) 
  "Macro interface to trace activation."
  (list 'tracefns (list 'quote x)))

(defmacro untrace (&rest x)
  "Macro interface to trace deactivation."
  (cond ((null x) '(rembreaks *traced-functions*))
	(t (cons 'unbreak x))))

      

; ================================================================
; --- BREAK help functions
; There is an advantage with the abstraction made and used above
; for the TRACe functions beq with help of these we can redefine
; the BREAK functions to use the same pattern and wrap-put function.

(defun make-break (fn def params)
  "Insert a break loop in a function body"
  (list (list 'open-breakloop (kwote fn) (kwote def)
	      params nil
	      (kwote (if (atom params) params (cdr params))))))

(defun debugging-enabled ()
  "Is Lisp debugging enabled?"
  (> (set-authority nil) 3))

(defun breakloop (_fn_ _bdy_ !args _env_ &optional _vars_)
  "Translate break loop commands to forms"
  (cond ((debugging-enabled)
	 (resetvars ((_debugging_ t)
	             (_catch-errors_ nil));; Don't trap errors inside loop
		    (let ((!value '!unevaluated)_frame-evaluated_
			  (_orgenv_ _env_)
			  *current-loadfile* (*within-lisp* t))
		      (selectq 
		       (setq 
			!value 
			(catch 'error
			  (catch 'breakloop
			    (loop (let ((*in-break* (if *in-break* t 1)))
				    (catch '*up* 
				      (eval (breaker _fn_ _bdy_ !value _env_
						     _frame-evaluated_))))))))
		       (*up* (tonextbreak))
		       !value))))
	(t (formatl t "Lisp debugging not supported" t)(reset))))


(defglobal _breakloop_ (getd 'breakloop) "Break loop command translator")

(defmacro open-breakloop (_fn_ _bdy_ !args _env_ &optional _vars_)
  "Translate break loop commands in current variable scoping"
  (if (null _fn_)
      (list (list 'lambda nil;; to indicate inside some function
		  (list _breakloop_ _fn_ _bdy_ !args '(frameno) _vars_)))
    (list _breakloop_ _fn_ _bdy_ !args '(frameno) _vars_)))

(defun evaluate-body? (fn)
  (or (null fn) (is-broken fn) (eq fn 'faulteval)))

(defun breaker (_fn_ _bdy_ !value _env_ _evframe_)
  (let (_rd_ temp)
    (cond (_evframe_ (print (list (prev-function-called _evframe_ nil) 
				  're-applied)))
	  (_fn_ 
	   (print (list _fn_ (if (eq !value '!unevaluated) 'broken 
			       'evaluated)))))
    (formatl t (prev-function-called _env_ t)" brk>")
    (setq _rd_ (read))
    (selectq 
     _rd_
     (:eval 
      `(cond ((and (equal _env_ _orgenv_)
                   (evaluate-body? (quote , _fn_)))
	      (setq !value , _bdy_))
	     (t (setq !value (apply-frame , _env_))
                (setq _frame-evaluated_ _env_))))
     (:c (cond (_evframe_ 
		(formatl t 
			 "Cannot continue after re-apply of " 
			 (prev-function-called _evframe_ nil) t)
			 nil)
	       (t `(cond ((neq !value '!unevaluated) 
			  (formatl t (quote , _fn_) " => ")
			  (print !value)
			  (throw 'breakloop !value))
			 ((evaluate-body? (quote , _fn_)) 
			  (setq !value , _bdy_)
			  (throw 'breakloop !value))
			 (t (throw 'breakloop (apply-frame _orgenv_)))))))
     (:a 
      `(cond ((null(equal _env_ _orgenv_))
              (formatl t "At broken frame" t)
	      (setq _env_ _orgenv_))
             ((or (eq *in-break* t)
		  (confirm-prompt "Really reset?"))
	      (throw 'breakloop '*up*))))
	 
     (:ub '(progn (formatl t "Unbreaking " _fn_ t)(rembreak _fn_)))
     (:su  `(progn (rembreak _fn_)
		   (storage-used (null , _bdy_) , _fn_)
		   (putbreak _fn_)))
     (:lvars '(print (frame-vars _env_)))
     (:bt '(bt _env_))
     (:bto '(ologbt))
     (:btv '(backtrace *backtrace-depth* _env_ t))
     (:btv* '(backtrace *backtrace-depth* _env_ nil))
     (:r (reset))
     (:pr '(setq _env_ (prevframe _env_)))
     (:nx '(setq _env_ (nextframe _env_)))
     ((?= :fr) '(printframe _env_))
     (:fp (if (getd 'doc) '(doc(prev-function-called _env_ nil))
            (formatl t "ALisp program database not loaded" t)))
     (:help '(progn (princ _break-help_)(terpri)))
     (or (and (listp _rd_)
	      (selectq (car _rd_)
		       (:b (setq temp (list 'boundp (kwote (cdr _rd_))))
			   (list 'if temp '(formatl t "Currently bound!" t)
				 (list 'setdemon (kwote temp))))
		       (:f  (list 
			     'setq '_env_
			     (list 'find-frame 
				   (kwote (second _rd_)) '_env_)))
                       (:e (list 'print (list 'setq '!value (second _rd_))))
		       nil))
	 `(print (evalenv '((lambda (!value) , _rd_) 
			    , (kwote !value)) , _env_))))))

(defun bt (env) 
  "Print a backtrace starting at stack position ENV"
  (mapstackfns (function(lambda (x)
			  (if (memq x *exclude-bt*) nil (print x)))) env))

(defun :arg (n)
  "Get value of n:th argument in current stack frame"
  (let ((env (eval '_env_)))
    (if (null env)(error ":ARG called outside break loop" n)
      (cdr(nth n (nreverse (getframe env)))))))

(defun find-frame (fn env) 
  "Find 1st stack frame calling FN starting with frame ENV"
  (let ((oenv env)(orgenv env))
    (setq env (prevframe env))
    (cond ((while (/= env oenv)
	     (if (equal fn (frame-function env))
		 (return env))
	     (setq oenv env)
	     (setq env (prevframe env))))
	  (t  (formatl t "Frame calling " fn " not found!" t t)
              orgenv)))) 

(defun prev-function-called (env mark)
  (let (fn nxt)
    (while (or (not (symbolp (setq fn (frame-function env))))
               (memq fn *exclude-bt*))
      (setq nxt t)
      (setq env (framecontext env))
      (cond ((= env 0)(setq fn '*bottom*)(return nil))))
    (if (null mark) fn
      (concat (if (or(not (symbolp fn))(not nxt)(eq fn '*bottom*)) "At "
		"Inside ")
              fn))))

(defun frame-function (env)
  (let ((fnframe (caar (last (getframe env)))))
    (cond ((atom fnframe) fnframe)
	  ((match-form '((lambda * ((lambda . *)
				    (quote *) (quote *) *
				    (frameno) (quote *))))
		       (list fnframe)) ;; Broken macro call pattern
	   (cadr (nth 1 (nth 2 fnframe))))
	  (t fnframe))))

(defun frame-vars (env)
  (let (res)
    (while (neq env 0)
      (let (lvars)
	(dolist (x (butlast (getframe env)))
	  (and (car x)
	       (setq lvars (adjoin (car x) lvars))))
	(setq res (nconc res lvars))
	(setq env (framecontext env))))
    res))

(defun function-with-rest (fn)
  (let ((def (if (symbolp fn)(getd fn) fn)))
    (and (lambdap def)(memq '&rest (cadr def)))))

(defun apply-frame (env)
  "Reapply the function call in stack frame ENV"
  (let* ((fr (nreverse(getframe env)))
	 (fn (caar fr)))
    (cond ((or (macro-function fn)
	       (special-operator-p fn))
	   (evalenv (cons fn (mapcar (function cdr)(cdr fr)))
		    env))
          ((function-with-rest fn)
	   (let* ((nfr (subset (cdr fr) (function car)))
                  (rest (last nfr)))
             (applyenv fn
		       (nconc (mapcar (function cdr) (ldiff nfr rest))
			      (cdar rest))
                       env)))
	  (t (applyenv fn
		       (mapcar (function cdr)(cdr fr)) env)))))

(defun tonextbreak ()
  "Reset to the next break loop or do global reset."
  (if *in-break* (throw '*up* nil)
    (reset)))

(defvar *in-break* nil "T if inside break loop")

(defun putbreak (brf)
  (let ((fn (car (mklist brf))))
    (cond ((member fn *traced-functions*)
           (printl 'untracing brf)
           (rembreak fn)))
    (cond ((already-broken fn))
	  (t (prog1 (wrap-put brf (function make-break))
	       (setq *broken-functions* (cons fn *broken-functions*)))))))

(defun rembreak (fn)
  "Remove the break wrapper for FN"
  (setq *broken-functions* (remove fn *broken-functions*))
  (setq *traced-functions* (remove fn *traced-functions*))
  (setq *profiled-fns* (remove fn *profiled-fns*))
  (unwrap-fn fn))

(defun is-broken (fn)
  (or (memq fn *broken-functions*)
      (memq fn *traced-functions*)
      (memq fn *profiled-fns*)))

(defun rembreaks (fns)
  "Remove break wrappers around functions FNS"
  (mapcar (function rembreak) fns))

(defmacro break(&rest args)
  "Interface macro for breaking functions"
  (kwote (mapcar (function putbreak) args)))

(defmacro unbreak (&rest args)
  "Interface macro for unbreaking functions"
  (cond ((null args) '(rembreaks *broken-functions*))
	(t (list 'rembreaks (kwote args)))))

(defun catchdemon (loc val)
  "Called when demon is becoming active"
  (if (integerp loc) (princ "Demon called when location ")
    (princ "Demon called when "))
  (prin1 loc) (princ " = ")(print val)
  (open-breakloop nil))

(defmacro help(x)
  "Put a break point in the code is current lexical scope"
  `(progn
     (formatl t "Help " (quote , (or x "")) "!" t)
     (open-breakloop nil nil nil nil)))

(defmacro bp (msg)
  "Put a breakpoint in the code if _BREAKPOINTS_ true"
  (if _BREAKPOINTS_ (list 'help msg)))

(defmacro assert (v &optional msg)
  "Make an error is V is NIL"
  (and msg (not (stringp msg)) (error "ASSERT message not string" msg))
  `(and  _debugging_ (not , v) 
         (error "Assertion violated" , msg)))

(defmacro breakwhenever (&rest args)
  "Set up a demon to break when in lexical scope of function :CALLED
   and variables :BOUND are bound
   and expression :WHEN returns non-NIL value"
  (let ((options (parsekeywordparams args '(:called :bound :when))))
    (list 'setdemon 
	  (kwote (list 'and 
		       (if (first options) 
			   (list 'is-called (kwote (first options)))t)
		       (if (second options) 
			   (list 'boundp (kwote (second options))) t)
		       (if (third options) 
			   (third options) t))))))

(defun trapdealloc (x)
  "Get a break when X is deallocated"
  (trapdealloca (loc x)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Unadvise broken function when redefining it
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun unbreak-first (fn)
  (cond ((is-broken fn) 
	 (rembreak fn)
	 (printl fn 'unbroken))))

(advise-around 'defun
	       '(list 'progn (list 'unbreak-first (kwote (car !args))) *))
(advise-around 'defmacro
	       '(list 'progn (list 'unbreak-first (kwote (car !args))) *))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                Function profiling by wrapping
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;   User interface:
;   (profile-functions fn1 fn2 ...)  wraps profiling around fn1 fn2 ...
;   do your tests
;   (print-function-profiles)        print statistics on profiled fns
;   (get-function-profiles)          return a list of lists with profile
;                                    info of the form:
;                                    ((fn-name time calls average time) ...)
;   (clear-function-profiles)        resets the profile for all profiled fns
;   (unprofile-functions)            unprofiles all profiled functions
;   (unprofile-functions fn1 ...)    unprofiles individual functions
;
;   Recursive calls are not counted as new calls!
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defglobal _profile-precision_ 3 
  "Number of digits when printing time spent in profiled function")


(defvar *profiled-fns* nil "Currently profiled functions")

(defun put-profile (fn)
  "Wrap FN for timing"
  (let ((thefn (car (mklist fn))))
    (cond ((already-broken thefn))
	  ((memq thefn *profiled-fns*) (list thefn 'already-profiled))
	  (t (setq *profiled-fns* (cons thefn *profiled-fns*))
	     (wrap-put fn #'make-profile)))))

(defun make-profile (fn def params)
  "Wrapper for measuring execution time for calls to FN"
  `((let ((**time** (getprop (quote , fn) 'time))
	  (**cnt** (getprop (quote , fn) 'calls))
	  **start** **elapsed**)
      (setq **start** (clock))
      (unwind-protect 
	  , def
	(progn
	  (setq **elapsed** (- (clock) **start**))
	  (putprop (quote , fn) 'time
		   (roundto (+ **elapsed** (or **time**  0)) 
			    _profile-precision_))
	  (putprop (quote , fn) 'calls
		   (1+ (or **cnt** 0))))))))

(defun profile-functions1 (fns)
  "Put wrapped profiling around function definitions in FNS"
  (mapcar (function put-profile) fns))       

(defmacro profile-functions (&rest fns)
  "Interface macro for wrapped profiling of functions"
  (list 'profile-functions1 (list 'quote fns)))

(defun print-function-profiles (file)
  "Print wrapped profiling statistics on FILE"
  (with-output-file str file
		    (dolist (f *profiled-fns*)
		      (let ((calls (or (getprop f 'calls) 0))
			    (tm (or (getprop f 'time) 0)))
			(formatl str f ": Time: " tm
				 " Calls: " calls ", Avg: " 
				 (if (eq tm 0) '- 
				   (roundto (/ tm calls) 
					    (1+ _profile-precision_)))
				 t)))))

(defun get-function-profiles ()
  "Return a list of lists with profile info of the form:
   ((fn-name time calls average_call_time) ...)"
  (let ((proflst))
    (dolist (f *profiled-fns*)
      (let ((calls (or (getprop f 'calls) 0))
	    (tm (or (getprop f 'time) 0)))
	(setq proflst (cons
		       (list f tm calls (if (eq tm 0) '- 
					  (roundto (/ tm calls) 
						   (1+ _profile-precision_))))
		       proflst))))
    proflst))

(defun clear-profiled-function (fn)
  "Clear wrapped profile statistics for FN"
  (remprop fn 'calls)
  (remprop fn 'time)
  fn)

(defun unprofile-functions1 (fns)
  "Remove profile wrappers for functions FNS"
  (mapcar (f/l (fn)
	       (clear-profiled-function fn)
	       (rembreak fn))
	  fns))

(defmacro unprofile-functions (&rest fns)
  "Interface macro to remove profile wrappers"
  (if (null fns)
      '(unprofile-functions1 *profiled-fns*)
    `(unprofile-functions1 (quote , fns))))

(defun clear-function-profiles1 (fns)
  "Clear wrapped profile statistics for functions FNS"
  (mapcar (function clear-profiled-function) fns))

(defmacro clear-function-profiles(&rest fns)
  "Interface macro to clear profile statistics"
  (if (null fns) '(clear-function-profiles1 *profiled-fns*)
    (list 'clear-function-profiles1 (kwote fns))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Storage profiling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defglobal _storagestat_ nil "Print storage statistics per command")

(defun storagestat (flag)
  "Turns on/off storage statistics printing"
  (setq _storagestat_ flag))

