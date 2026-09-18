;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011, Andrej Andrejev, UDBL
;;; $RCSfile: extfns.lsp,v $
;;; $Revision: 1.1 $ $Date: 2011/08/08 15:12:11 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: SciSparql foreign founctions for KNN application
;;; =============================================================
;;; $Log: extfns.lsp,v $
;;; Revision 1.1  2011/08/08 15:12:11  andan342
;;; Added data converter, measure implementation and script with basic SciSparQL query for KNN
;;;
;;; =============================================================

(defun euclid--+ (fno x y res) ;TODO: iterator needed to faciliate any-dimensional comparisons
  (when (and (eq (typename x) 'nma) (eq (typename y) 'nma) 
	     (= (nma-dims x) (nma-dims y)) (= (nma-ndims x) 1))
    (setq res 0.0)
    (dotimes (i (nma-dim x 0))
      (setq res (+ res (expt (- (nma-elt x (list i)) (nma-elt y (list i))) 2))))
    (osql-result x y res)))

(osql "create function euclid(Literal x, Literal y) -> Real as foreign 'euclid--+';")