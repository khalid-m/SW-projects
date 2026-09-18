;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1993 Tore Risch, EDSLAB
;;; $RCSfile: tclose.lsp,v $
;;; $Revision: 1.24 $ $Date: 2013/11/19 20:47:21 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description:
;;; General invertible transitive closure function.
;;; Handles the most common cases of recursion.
;;; Signature :
;;;   tclose(function f,object o,integer maxdepth)-> <object r,integer depth>
;;; Starting with object o construct the transitive closure by succesively
;;; applying f(o), f(f(o)) etc. down to level maxdepth.
;;; Returns the objects, r, in the closure and their distance, d, from o.
;;; f must be function of one argument and one result.
;;; Alt signature using name of function, rather the function object:
;;; General invertible transitive closure function. 
;;; Handles the most common cases of recursion.
;;; Signature :
;;;   tclose(function f,object o,integer maxdepth)-> <object r,integer depth>
;;; Starting with object o construct the transitive closure by succesively
;;; applying f(o), f(f(o)) etc. down to level maxdepth.
;;; Returns the objects, r, in the closure and their distance, d, from o.
;;; f must be function of one argument and one result.
;;; Alt signature using name of function, rather the function object:
;;; =============================================================
;;; $Log: tclose.lsp,v $
;;; Revision 1.24  2013/11/19 20:47:21  torer
;;; *** empty log message ***
;;;
;;; Revision 1.23  2013/11/09 16:51:58  torer
;;; Integer -> Number
;;;
;;; Revision 1.22  2011/12/22 12:55:17  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.21  2011/06/21 20:31:39  torer
;;; revert
;;;
;;; Revision 1.19  2011/01/29 11:04:39  torer
;;; Base system uses (...) tuple notation, 'return' statement, and systematic indentation
;;;
;;; Revision 1.18  2009/12/09 20:15:58  torer
;;; More readable error message
;;;
;;; Revision 1.17  2009/12/09 19:42:05  torer
;;; Relaxed test for closed function
;;;
;;; Revision 1.16  2009/11/12 18:02:22  torer
;;; Changed ttclose -> traverse
;;;
;;; Revision 1.15  2009/11/10 08:11:32  torer
;;; tclosed(function,object,maxdepth)->Bag of <Object,depth>
;;; for backward compatibility
;;;
;;; Revision 1.14  2009/11/07 13:04:37  torer
;;; Bug in CLOSED-FUNCTIONP
;;;
;;; Revision 1.13  2009/11/06 19:22:20  torer
;;; Wider interpretation of closed function
;;;
;;; Revision 1.12  2009/11/06 18:35:26  torer
;;; Generalized transition functions in tclose
;;;
;;; Revision 1.11  2009/10/30 07:53:01  torer
;;; argument error
;;;
;;; Revision 1.9  2008/11/25 19:24:47  torer
;;; TCLOSE not overloaded on strings since we now have functional constants
;;;
;;; Revision 1.8  2008/11/13 08:39:36  torer
;;; #'foo' now evaluated by parser.
;;; Enables computed result types for tclose(function,object)->object
;;;
;;; Revision 1.7  2007/03/09 16:39:35  zeitler
;;; *** empty log message ***
;;;
;;; Revision 1.6  2007/02/09 15:35:56  guestgyg
;;; Fixing bug in tclose definition
;;;
;;; Revision 1.5  2007/02/09 14:30:46  torer
;;; Error if functin named misspelled
;;;
;;; Revision 1.4  2006/11/04 17:04:42  torer
;;; Simplified INVERSE-OSQLFN
;;;
;;; =============================================================

;;;
;;; TCLOSE(function f, object o)-> object r 
;;;

(defun tclose--+ (o fn &rest args)
  (tclose-impl o fn args t nil))

(defun traverse--+ (o fn &rest args)
  (tclose-impl o fn args nil nil))

(defun tclose-+- (o fn &rest args)
  (tclose-impl o fn args t t))

(defun traverse-+- (o fn &rest args)
  (tclose-impl o fn args nil t))

(defun tclose-impl (o fn args mem inv)
  (let ((aw (length args)))
    (if (oddp aw) (error "Wrong arity and width in tclose" 
                         (function-signature fn)))
    (let* ((argl (if inv (nthcdr (/ aw 2) args)
		   (firstn (/ aw 2) args)))
	   (r (if inv (inverse-function (resolveargs fn argl nil))
		(resolveargs fn argl nil))))
      (if (closed-functionp r) nil
	(error "Not a closed function" (function-signature fn)))
      (build-full-tclosure r fn argl inv mem))))

(defun closed-functionp (fno &optional notbag)
  "The if FNO is a closed function"
  (let ((at (get-resolvent-argtypes fno))
        (rt (get-resolvent-restypes fno)))
    (and (= (length at)(length rt))
         (or (null notbag)(not (has-bagged-result fno)))
         (every (f/l (a r)(or (osql-subtypep a r t)
			      (osql-subtypep r a)
                              (and (null notbag)
                                   (bag-type? r)
                                   (equal (list a)
                                          (type-parameters r)))))
                at rt))))

(defun build-full-tclosure (r fno argl inverse memory)
  "Computes order preserving full transitive closure iteratively by applying
   f(f(f(x,..),..),..) until search exhausted"
  (let ((been (if memory 
		  (make-hash-table :test (function equal))));; visited nodes
        (front (list argl)))		; front line arg tuples
    (if memory (setf (gethash (car argl) been) t));; root always visited
    (while front
      (let ((nxt (pop front))
            children)
	(if inverse (apply 'osql-result fno (append nxt argl))
	  (apply 'osql-result fno (append argl nxt))) ; emit
	(mapfunction			; get not visited children to front
	 r nxt
	 (f/l (key)
	      (cond ((and memory (gethash (car key) been))
					; already visited
		     nil) 
		    (t (if memory (setf (gethash (car key) been) t))
		       (push key children)))))
	(dolist (x children)(push x front))) ; add to front 
      )))

(defun tclose-resulttypes (fno args)
  (cond ((osql-constantp (car args))(function-resulttypes (car args)))
        (t (function-resulttypes fno))))

(set-resulttypesfn
 (osql "
create function tclose(Function fn, Object o) -> Bag of Object
  as multidirectional
     ('bbf' foreign 'tclose--+')
     ('bfb' foreign 'tclose-+-');")
 'tclose-resulttypes)

(set-resulttypesfn
 (osql "
create function traverse(Function fn, Object o) -> Bag of Object
  as multidirectional
     ('bbf' foreign 'traverse--+')
     ('bfb' foreign 'traverse-+-');")
 'tclose-resulttypes)

(set-resulttypesfn
 (osql "
create function tclose(Function fn, Object, Object) 
                   -> Bag of (Object,Object)
  as multidirectional
     ('bbbff' foreign 'tclose--+')
     ('bffbb' foreign 'tclose-+-');")
 'tclose-resulttypes)

(set-resulttypesfn
 (osql "
create function traverse(Function fn, Object, Object) 
                     -> Bag of (Object,Object)
  as multidirectional
     ('bbbff' foreign 'traverse--+')
     ('bffbb' foreign 'traverse-+-');")
 'tclose-resulttypes)

(set-resulttypesfn
 (osql "
create function tclose(Function fn, Object, Object, Object) 
                   -> Bag of (Object,Object,Object)
  as multidirectional
     ('bbbbfff' foreign 'tclose--+')
     ('bfffbbb' foreign 'tclose-+-');")
 'tclose-resulttypes)

(set-resulttypesfn
 (osql "
create function traverse(Function fn, Object, Object, Object) 
                     -> Bag of (Object,Object,Object)
  as multidirectional
     ('bbbbfff' foreign 'traverse--+')
     ('bfffbbb' foreign 'traverse-+-');")
 'tclose-resulttypes)

(set-resulttypesfn
 (osql "
create function tclose(Function fn, Object, Object, Object, Object) 
                   -> Bag of (Object,Object,Object,Object)
  as multidirectional
     ('bbbbbffff' foreign 'tclose--+')
     ('bffffbbbb' foreign 'tclose-+-');")
 'tclose-resulttypes)

(set-resulttypesfn
 (osql "
create function traverse(Function fn, Object, Object, Object, Object) 
                     -> Bag of (Object,Object,Object,Object)
  as multidirectional
     ('bbbbbffff' foreign 'traverse--+')
     ('bffffbbbb' foreign 'traverse-+-');")
 'tclose-resulttypes)


;;;
;;; TCLOSE(function f, object o,integer maxd)-> <object r, integer d>
;;;

(defun build-tclosure (tcres fno fn o maxdepth r depth inverse)
   ;;; Traverses transitive closure by f(f(...(o))) if inverse = nil
   ;;; or by invf(invf(...(o))) if inverse = t
   ;;; Full recursive version that maintains depths
  (cond ((> depth maxdepth) nil)
	((and tcres (gethash r tcres)) nil)
	(t (and tcres (setf (gethash r tcres) t))
           (if inverse (osql-result fn r maxdepth o depth)
	     (osql-result fn o maxdepth r depth))
           (mapfunction (if inverse (getobject fno 'inversefn) fno)
			(list r)
			(f/l (key)
			     (build-tclosure tcres fno fn o maxdepth
					     (car key) (1+ depth) inverse))))))

(defun tclosed---++ (obj fn o maxdepth r depth)
  (let ((fno (getuniqueresolvent fn)))
    (build-tclosure (make-hash-table :test (function equal)) 
		    fno fn o maxdepth o 0 nil)))

(defun tclosed-+--+ (obj fn o maxdepth r depth)
   ;;; Inverse of tclose that applies invf(invf(...(o)))
  (let ((fno (getuniqueresolvent fn nil)))
    (inverse-osqlfn fno)		; Make sure inverse defined
    (build-tclosure (make-hash-table :test (function equal)) 
		    fno fn r maxdepth r 0 t)))

(defun inverse-osqlfn (fno)
  "Get the inverse of amosql function FNO"
  (cond ((and (= 1 (getarity fno))
              (= 1 (getwidth fno)))
         (the-tbr-function fno '(+ -)))
        (t (amos-error 
	    "Can only invert functions with one argument and one result "))))

(osql
"
create function tclosed(Function fn, Object o, Number maxdepth)
                    -> (Object r, Integer depth) 
  /* Get the transitive closure of applying the function fn on the
   argument o recursively until no more results produced or maxdepth reached.
   The result pairs contain the produced objects and their distances 
   from the root o. */
   as multidirectional ('bbbff' foreign 'tclosed---++')
		       ('bfbbf' foreign 'tclosed-+--+');

")
