;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1995 Tore Risch, EDSLAB
;;; $RCSfile: sort.lsp,v $
;;; $Revision: 1.3 $ $Date: 2011/12/21 20:59:37 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Merge sort
;;; =============================================================


(defun sort (x fn)
   "Iterative merge sort of X with FN as comparison operator"
   (cond ((atom x) x)
         (t (let (ll)
               (int-while (consp x)
                 (push (dmerge (list (pop x))
                         (if (consp x)(list (pop x))) 
                         fn) 
                   ll))
               (int-while (cdr ll)
                 (setq ll (mergepairs ll fn)))
               (car ll)))))

(defun mergepairs (l fn)
   "Merge lists in list L with FN as comparison function"
   (let ((tl l))
      (int-while
       (cond ((atom tl) nil)
             ((atom (cdr tl))
              nil)
             (t (rplaca tl (dmerge (car tl)(cadr tl) fn))
               (rplacd tl (cddr tl))
               (pop tl))))
      l)) 
   
(defun merge (x y fn)
   "Merge X and Y with FN as comparison function"
   (let* ((res (list nil)) (tl res))
      (int-while
       (cond ((atom x)(rplacd tl y) nil)
             ((atom y)(rplacd tl x) nil)
             ((funcall fn (car x)(car y)) 
              (rplacd tl (list (pop x))))
             (t (rplacd tl (list (pop y)))))
       (pop tl))
      (cdr res)))

(defun dmerge (x y fn)
   "Merge X and Y destructively with FN as comparison function"
   (cond ((null x) y)
         ((null y) x)
         ((funcall fn (car x)(car y))
          (dmerge1 x (cdr x) y fn) x)
         (t (dmerge1 y x (cdr y) fn) y)))

(defun dmerge1 (tl x y fn)
   (int-while
    (cond ((atom x)(rplacd tl y)  nil)
          ((atom y)(rplacd tl x) nil)
          ((funcall fn (car x)(car y))  
           (rplacd tl x)
           (pop x))
          (t (rplacd tl y) 
            (pop y)))
    (pop tl)
    (rplacd tl nil))
   )
