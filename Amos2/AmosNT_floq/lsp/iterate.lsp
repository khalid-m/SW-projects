;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013 Tore Risch, UDBL
;;; $RCSfile: iterate.lsp,v $
;;; $Revision: 1.13 $ $Date: 2013/11/19 21:25:04 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Declarative iterator function
;;; =============================================================
;;; $Log: iterate.lsp,v $
;;; Revision 1.13  2013/11/19 21:25:04  torer
;;; *** empty log message ***
;;;
;;; Revision 1.12  2013/11/19 20:47:21  torer
;;; *** empty log message ***
;;;
;;; Revision 1.11  2013/11/19 07:59:42  torer
;;; Changed argument order in iterate()
;;;
;;; Revision 1.10  2013/11/18 19:50:28  torer
;;; *** empty log message ***
;;;
;;; =============================================================

(defun iterateit (fno fn maxdepth args res)
  (let ((nxt args) prev (depth 0))
    (loop (cond ((or (null nxt) (equal nxt prev)(> depth maxdepth))
		 (apply 'osql-result fn maxdepth (append args prev))
                 (return nil))
		(t (setq prev nxt)
                   (setq nxt (getfunction1 fno prev))
		   (1++ depth))))))

(defun iterate---+ (obj fn maxdepth &rest args)
  (let ((fno (getuniqueresolvent fn)) (arw (length args)))
    (cond ((not (closed-functionp fno t))
           (error "Not a closed function" (function-signature fno)))
          ((oddp arw) (error "Wrong number of arguments in iterate()" 
			     (+ 2(/ arw 2))))
          (t (let ((args0 (firstn (/ arw 2) args)))
	       (iterateit fno fn maxdepth args0 args0))))))       

(defun getfunction1 (fn args)
  (catch 'getfunction1 
    (mapfunction fn args (f/l (row)(throw 'getfunction1 row)))))

(defun iterate-resulttypes (fno args)
   (function-dynresulttypes (first args)(list (third args))))

(set-resulttypesfn
 (osql "
create function iterate(function fn, integer maxdepth, Object o)
                        -> object r
   as foreign 'iterate---+';")
 'iterate-resulttypes)

(set-resulttypesfn
 (osql "
create function iterate(function fn, integer maxdepth, Object, Object)
                        -> (Object, Object)
   as foreign 'iterate---+';")
 'iterate-resulttypes)
