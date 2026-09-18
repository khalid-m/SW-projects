;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2006 Tore Risch, UDBL
;;; $RCSfile: uri.lsp,v $
;;; $Revision: 1.1 $ $Date: 2006/12/10 15:57:36 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Defining Amos II types URI and RLIT
;;; =============================================================
;;; $Log: uri.lsp,v $
;;; Revision 1.1  2006/12/10 15:57:36  torer
;;; 1. New file lsp/uri.lsp for basic URI management
;;; 2. Defined AmosQL print functions for types RESOURCE and RLIT
;;;
;;; =============================================================

(defglobal _resource_ 
  (createliteraltype 'resource (list _object_) 'resource nil))

(defglobal _rlit_ 
  (createliteraltype 'rlit (list _resource_) 'resource nil 
		     '(lambda (o)(if (is-rlit o) _rlit_ _resource_))))

(set-type-container (osql "
create function r(integer i,literal str)->resource uri as
	multidirectional ('bbf' foreign 'rbbf' cost {1,1})
			 ('ffb' foreign 'rffb' cost {1,1});"))

(defun print-resource (o str) 
  "Prints URI resources"
  (princ "uri(" str)
  (prin1 (resource-id o) str)
  (princ ")" str))

(defun print-literal (o str) 
  "Prints RDF literals"
  (princ "lit(" str)
  (prin1 (resource-id o) str)
  (princ ")" str))

(set-printfn 'resource 'print-resource)
(set-printfn 'rlit 'print-literal)