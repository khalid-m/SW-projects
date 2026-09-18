;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013 Silvia Stefanova, UDBL
;;; $RCSfile: rdf-fns.lsp,v $
;;; $Revision: 
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Extra functions for processing URI objects
;;; =============================================================
;;; 
;;; =============================================================


;; AmosQL CONSTRUCTORS & ACCESSORS

(defun URI-+ (fno s r)
  (osql-result s (uri s)))

(defun URI+- (fno s r)
  (when (eq (typename s) 'uri)
    (osql-result s (uri-id s) )))


(defun USTR--+ (fno str lang res)
  (osql-result str lang (ustr str lang)))

(defun USTR-+ (fno str res)
  (osql-result str (ustr str)))

(defun USTR-str-+ (fno x res)
  (when (eq (typename x) 'ustr)
    (osql-result x (ustr-str x))))

(defun USTR-literal-+ (fno x res)
  (when (or (eq (typename x) 'integer)
	    (eq (typename x) 'real)
	    (eq (typename x) 'time)
	    (eq (typename x) 'date))
    (osql-result x x)))


(defun USTR-literal+- (fno x res)
  (when (or (eq (typename res) 'integer)
	    (eq (typename res) 'real)
	    (eq (typename res) 'time)
	    (eq (typename res) 'date))
    (osql-result res res)))







