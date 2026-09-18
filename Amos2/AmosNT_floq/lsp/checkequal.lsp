;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997 Tore Risch, EDSLAB
;;; $RCSfile: checkequal.lsp,v $
;;; $Revision: 1.2 $ $Date: 1999/08/04 11:56:01 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Regression tester
;;; =============================================================


(defmacro checkequal (tag &rest args)
   (list 'checkequal1 (kwote tag) (kwote args)))

(defun checkequal1 (tag args)
   (let ((ok t))
      (formatl t "[Testing " tag "...")
      (mapc
        (f/l (x)
          (let ((act (eval
                       (copy-tree
                         (car x))))
                (exp (eval
                       (copy-tree
                         (cadr x)))))
             (cond
                   ((equal act exp))
                   (t (setq ok nil)
                     (prin1
                       (car x)
                       t)
                     (princ " evaluates to " t)
                     (prin1 act t)
                     (princ ", expected " t)
                     (print exp t)
                     (help (car x))))))
        args)
      (if ok
         (formatl t "OK]" t)
         (formatl t "not OK]" t))
      t))