;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Tore Risch, UDBL
;;; $RCSfile: oldsig.lsp,v $
;;; $Revision: 1.1 $ $Date: 2012/01/15 10:41:54 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Patch to restore old function signature format
;;;              for systems relying on parsing old signatures (e.g. WSMED)
;;; =============================================================
;;; $Log: oldsig.lsp,v $
;;; Revision 1.1  2012/01/15 10:41:54  torer
;;; Patch to restore old signature format
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(defun function-signature1 (fno argtypes restypes)
  "Construct function sigtnature given its arguments and results"
  (concat (generic-fnname fno)
	  "(" (if argtypes (stringify-typel argtypes "" "") "") ")"
	  (if (null restypes) ""
	    (concat "->"
		    (stringify-typel restypes)))))

(defun mkfunsig (fno delim argl resl)
  "Construct a function signature string"
  (let ((argl1 (or (listp (car argl))argl))
        (resl1 (if (listp (car resl)) nil resl)))
    (setq argl1 (externalize argl1))
    (setq resl1 (externalize resl1))
    (let ((str (opentextstream)))
      (cond ((and (null resl1) (eq fno _tupletag_))
	     (prinargl argl1 str t))
	    (t (princ (externalize fno) str)
	       (prinargl (key-list argl1) str)
	       (cond (resl (princ delim str)
			   (prinargl (key-list resl1) str t)))))
      (textstreamstring str))))

(defun stringify-decoded-type (dtpo)
  "Stringify decoded type description DTPO"
  (cond ((atom dtpo) dtpo)
        ((cddr dtpo)
	 (concat (stringify-decoded-type (car dtpo)) " of ("
		 (concatl (cdr dtpo) "," (function stringify-decoded-type))
		 ")")) 
        (t  (concat (stringify-decoded-type (car dtpo)) " of " 
		    (stringify-decoded-type (cadr dtpo))))))
