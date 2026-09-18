;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Tore Risch, UDBL
;;; $RCSfile: wrapperQueryProcessor.lsp,v $
;;; $Revision: 1.1 $ $Date: 2011/01/12 17:04:08 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Generic wrapper query processor
;;; =============================================================
;;; $Log: wrapperQueryProcessor.lsp,v $
;;; Revision 1.1  2011/01/12 17:04:08  minzh812
;;; Hooks for pre and post processing the cost optimizer for each wrapper
;;;
;;; =============================================================

(defglobal _expression_ "Data type holding source query Expressions")

(setq _expression_ (createliteraltype 'expression '(literal) 'expression))

;;; Absorber mechanism

(defun absorb-predicates (l)
  "go through conjunctive list of tr and absorb the possible predicates
   for CCfn" 
  (let ((changed t))
    (while changed
      (setq changed nil)
      (dolist (pred l)
	(let ((absorber (get-absorber pred)))
	  (cond (absorber
		 (let ((transformed (funcall absorber pred (remove pred l))))
		   (cond ((null transformed))
			 (t (setq changed t)
			    (setq l transformed)
			    (return nil)))))))))
    l))

(defun get-absorber (tr)
  "get lisp function lfn to absorb preds for CCfn 
   and generate a list of absorbed predicates conjunction"
  (and (consp tr)(oid-p (car tr))
       (getobject (car tr) 'absorber))
  )

(defun put-absorber (fno lfn)
  "Put a absorber on Amos function FNO"
  (/putobject fno 'absorber lfn))

(defun put-absorber-- (o fno lfn)
  (put-absorber fno (pack 'absorb- lfn))
  (osql-result fno lfn))

(osql "
create function put_absorber(Function fno, Charstring tr)->Boolean
  as foreign 'put-absorber--';")

;;; Finalizer mechanism

(defun translate-tbr (l bnd)
  "Go through conjuctive list of TBR-calls and translate them"
  (let ((res (tconc)))
    (dolist (tbr l)
      (let* ((tr (predify-tbr tbr)) 
	     (translator (get-translator tr)))
	(cond (translator 
	       (let ((translated (funcall translator tr bnd)))
                 (cond ((equal translated tr) (tconc res tbr))
                       (t (tconc res (optimize-and-or translated bnd))
			  ))))
	      (t (tconc res tbr)))
	(setq bnd (binds-variables tr bnd))))
    (car res)))

(defun get-translator (tr)
  "Get Lisp function lfn to translate TBR-call t its final format.
   For example generating query strings from FILTER calls.
   (lfn filter variable bnd) -> list of TBR-calls"
  (and (consp tr)(oid-p (car tr))
       (getobject (car tr) 'translator)))

(defun put-translator (fno lfn)
  "Put a translator on Amos function FNO"
  (/putobject fno 'translator lfn))

(defun put-translator-- (o fno lfn)
  (put-translator fno (pack 'translate- lfn))
  (osql-result fno lfn))

(osql "
create function put_translator(Function fno, Charstring tr)->Boolean
  as foreign 'put-translator--';")

