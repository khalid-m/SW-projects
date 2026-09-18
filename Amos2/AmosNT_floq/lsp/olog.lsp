;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Tore Risch, UDBL
;;; $RCSfile: olog.lsp,v $
;;; $Revision: 1.2 $ $Date: 2012/01/28 10:34:48 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: ObjectLog interface
;;; =============================================================
;;; $Log: olog.lsp,v $
;;; Revision 1.2  2012/01/28 10:34:48  torer
;;; olog utilities added
;;;
;;; Revision 1.1  2012/01/27 19:35:51  torer
;;; ObjectLog interface from Lisp
;;;
;;; =============================================================

(defun map-plan (fn resvars plan argvars argl)
  "Apply FN on each result tuple RESVARS of execution PLAN 
   with input variables ARGVARS bound to ARGL"
  (let ((sb (make-selectbody :optpred plan :argl argvars :resl resvars))
        (fno (createfunction1 '*transient*)))
    (putobject fno 'selectbody sb)
    (mapfunction-apply fno argl fn)))

(defun plan-tuples (resvars plan argvars argl)
  "Return list of tuples RESVARS of execution PLAN 
   with input variable ARGVARS bound to ARGL.
   E.g. (plan-tuples '(r) '(call sqrt-+ nil x r) '(x) '(4)) -> ((2.0))"
  (let ((tuples (tconc)))
    (map-plan (f/l (&rest tuple)(tconc tuples tuple))
	      resvars plan argvars argl)
    (car tuples)))

;; 


