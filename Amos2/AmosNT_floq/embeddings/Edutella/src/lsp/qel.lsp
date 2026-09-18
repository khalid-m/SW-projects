;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2004 Johan Petrini, UDBL
;;; $RCSfile: qel.lsp,v $
;;; $Revision: 1.2 $ $Date: 2005/05/18 13:35:05 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: <>.
;;;              
;;; ===========================================================================

(defun oid-string (fno obj str)
  "Print OID-string of object o." 
  (if (oid-p obj)(osql-result obj (concat "#[OID " (oid-idno obj) "]"))))

(defun oid-symbol (fno obj symb)
  "Return OID-symbol of object o." 
  (if (oid-p obj)(osql-result obj (oid-name obj))))

(defun map-to-fn (fno fn ql res)
  "Function used to dynamically build a function call depending on arguments fn and ql. Not generalized!"
  (osql-result fn ql (mkstring (caar (getfunction (getfunctionnamed (mkatom fn)) (list ql))))))	
