;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Tore Risch, Ruslan Fomkin, UDBL
;;; $RCSfile: ineqrewrite.lsp,v $
;;; $Revision: 1.1 $ $Date: 2007/09/12 06:57:39 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Rewrites several inequalities over the same variable with strongest
;;; constant.
;;;              
;;; ===========================================================================
;;; $Log: ineqrewrite.lsp,v $
;;; Revision 1.1  2007/09/12 06:57:39  ruslan
;;; rewrites inequalities
;;;
;;; ===========================================================================

(defun ineq-remove-test (pred conjunction fn)
  (and (numberp (third pred))
       (isome conjunction (f/l (p)(and (neq p pred) 
				       (eq (car p)(car pred))
				       (eq (cadr p)(cadr pred))
				       (numberp (third p))
				       (funcall fn (third p) 
						(third pred)))))))

(defun ineq-remove-rewrite (pred conjunction other) nil)

(define-tr-rewriter (getfunctionnamed 'object.object.<->boolean) 
  (q/l (this conjunction)(ineq-remove-test this conjunction '<))
  'ineq-remove-rewrite)

(define-tr-rewriter (getfunctionnamed 'object.object.>->boolean) 
  (q/l (this conjunction)(ineq-remove-test this conjunction '>))
  'ineq-remove-rewrite)

