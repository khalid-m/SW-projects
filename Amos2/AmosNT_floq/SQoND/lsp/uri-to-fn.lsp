;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009-2010 Andrej Andrejev, UDBL
;;; $RCSfile: uri-to-fn.lsp,v $
;;; $Revision: 1.8 $ $Date: 2013/12/20 14:48:23 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: RDF datasource URI translation to Amos functions
;;; =============================================================

;; Depends on:
;; _sq_string_based_

(defun uri-to-amos-function (graphs)
  "Translate URI to Amos function storing the tripes"
  (let ((oid (and (getfunctionnamed 'upv t) 
		  (get-most-specific-resolvent 'upv '(Charstring))))
	restypenames res)
    (when (and oid (null (cdr graphs))) ;TODO: should be able to combine data from several views or stored graphs
      (setq restypenames (mapcar (f/l (type) (getobject type 'name)) (getobject oid 'restypes)))
      (cond ((equal restypenames '(charstring object)) ;; SWARD-specific mapping
	     (setq res (dolist (mapping (extent oid))
			 (when (string= (third mapping) (car graphs)) (return (concat (first mapping) "()"))))))

	    ((equal restypenames '(charstring)) ;; TopicMap-specific mapping
	     (setq res (dolist (mapping (extent oid))
			 (when (string= (first mapping) (car graphs)) (return (concat "#" (second mapping) "()")))))
	     (unless res (setq res "tm_rdf_triples_let()"))) ;;default mapping
	    ))
    (if res res (graphs-to-triples-fn (if _sq_string_based_ graphs (mapcar #'uri graphs)) nil)))) ; stored graph