;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009-2010 Andrej Andrejev, UDBL
;;; $RCSfile: uri-to-fn.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/08/09 14:26:44 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: RDF datasource URI translation to Amos functions
;;; =============================================================

;; Depends on:
;; _sq_default_triples_fn_

(defun uri-to-amos-function (uri)
  "Translate URI to Amos function storing the tripes"
  (let ((oid (and (getfunctionnamed 'upv t) 
		  (get-most-specific-resolvent 'upv '(Charstring))))
	restypenames (res nil))
    (when oid
      (setq restypenames (mapcar (f/l (type) (getobject type 'name)) (getobject oid 'restypes)))
      (cond ((equal restypenames '(charstring object)) ;; SWARD-specific mapping
	     (setq res (dolist (mapping (extent oid))
			 (when (string= (third mapping) uri) (return (concat (first mapping) "()"))))))

	    ((equal restypenames '(charstring)) ;; TopicMap-specific mapping
	     (setq res (dolist (mapping (extent oid))
			 (when (string= (first mapping) uri) (return (concat "#" (second mapping) "()")))))
	     (unless res (setq res "tm_rdf_triples_let()"))) ;;default value 
	    ))
    (if res res _sq_default_triples_fn_)))