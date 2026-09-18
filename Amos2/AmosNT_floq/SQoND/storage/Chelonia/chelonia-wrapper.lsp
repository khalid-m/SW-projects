;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Andrej Andrejev, UDBL
;;; $RCSfile: chelonia-wrapper.lsp,v $
;;; $Revision: 1.2 $ $Date: 2012/04/14 16:05:25 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Chelonia wrapper for SciSPARQL access
;;; =============================================================
;;; $Log: chelonia-wrapper.lsp,v $
;;; Revision 1.2  2012/04/14 16:05:25  andan342
;;; Array proxy objects now correctly accumulate STEP information and are completely transparent to array slicing/projection/dereference operations. Added workaraounds for Chelonia step-related bug.
;;;
;;; Revision 1.1  2012/03/18 13:16:07  andan342
;;; Created WRAPPER mode separate from TRIPLE-STORE mode
;;; Added NMA proxies to handle 'too large' arrays
;;;
;;;
;;; =============================================================

(defun uri-to-amos-function (uri)
  "Translate URI to Amos function accessing the tripes"
  (unless uri (setq uri ""))
  (concat "CW(graphToCWE('" uri "'))"))

(defun tid2uri--+ (fno ns tid res)
  (osql-result ns tid (uri (concat ns "Task" tid))))

(defun tid2uri-+- (fno ns tid res)
  (osql-result ns (read (substring (+ (length ns) 4) (1- (length (uri-id res))) (uri-id res))) res))

(osql "
create function tid2uri(Charstring ns, Integer tid) -> URI 
 as multidirectional
  ('bbf' foreign 'tid2uri--+')
  ('bfb' foreign 'tid2uri-+-');
")

(setq _sq_default_triples_fn_ "CW(graphToCWE(''))")
