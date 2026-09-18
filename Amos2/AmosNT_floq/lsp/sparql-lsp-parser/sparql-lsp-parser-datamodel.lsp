;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009-2010 Andrej Andrejev, UDBL
;;; $RCSfile: sparql-lsp-parser-datamodel.lsp,v $
;;; $Revision: 1.6 $ $Date: 2012/02/28 21:25:05 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description:  Common definitions for sparql-grammar.lsp and sparql-lsp-parser.lsp
;;; =============================================================

;; Common definitions for slr1-grammar.lsp and sparql-lsp-parser.lsp

(defstruct select-stat what from where distinct)

(defstruct construct-stat what from where)

(defstruct block conds bound bound+ ref+ ref* partial rebindings (cur-bound nil) (cur-semibound nil) (substs nil))

(defun block-inc-rebound (b v)
  (let ((r (assoc v (block-rebindings b))))
    (if r (incf (cdr r))
      (push (cons v 1) (block-rebindings b)))))

(defun block-dec-rebound (b v)
  (decf (cdr (assoc v (block-rebindings b)))))

(defun block-rebound (b)
  (mapcar #'car (block-rebindings b)))
