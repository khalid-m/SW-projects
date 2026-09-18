;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2004 Johan Petrini, UDBL
;;; $RCSfile: rdfs.lsp,v $
;;; $Revision: 1.2 $ $Date: 2005/05/18 13:29:18 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Representation of RDFS.
;;;              
;;; =========================================================================== 

; Public functions
;(defun make_rdf_type (fno from to)
;  "Forces rdf_resource FROM to become rdfsclass named NICKNAME under 
;   existing rdf types in TO in user type hierarchy"
;  (let ((supertypes (or (arraytolist to)(list _rdf_resource_)))
;	(name (unique-type 
;	       (pack _rdf-prefix_
;		     (mksymbol (get-rdf-name from))))))
;    (osql-result from (createtype name supertypes  _rdfsclass_ nil from))))

;(defun add_rdf_type (fno oid t)
;  "Wrapper function of /addtype. Used to add t to types of oid"
;  (/addtype oid t)
;  (osql-result oid t ))



