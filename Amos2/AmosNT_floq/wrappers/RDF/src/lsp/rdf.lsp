;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2004 Johan Petrini, UDBL
;;; $RCSfile: rdf.lsp,v $
;;; $Revision: 1.5 $ $Date: 2010/01/20 20:15:54 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Representing the basic RDF model.
;;;              
;;; ===========================================================================

; Global variables
(defglobal _intid_ (getfunctionnamed 'rdf_resource.intid->charstring))
(defglobal _rdf_resource_ (gettypenamed 'rdf_resource))
(defglobal _new_persistent_ (getfunctionnamed 'vector.new_persistent->rdf_resource))

;Local variables
(defvar _id_ (getfunctionnamed 'rdf_resource.id->charstring))

(set-no-extent _rdf_resource_)

(defun materialized-resources+ (fno r)
  (mapextent _rdf_resource_ (function osql-result)))

(defun build-str (listofstr)
  "Builds a string from a list of strings"
  (let((tmp (car listofstr)))
    (cond ((null tmp)"")
	  (t (concat tmp (build-str (cdr listofstr)))))))

; AmosQL front functions
(defun sort-prep (fno li rest)
  "Prepares for the sorting of stmts in a collection c  by removing the '_' 
from  stmt predicate '_x' where x is an integer in c."
  (let ((str (explode li)))
    (cond((equal "_" (mkstring (car str))) (osql-result li (build-str(cdr str))))
	 (t (osql-result li li)))))

(defun extract-coll-objects (fno arrayofarray res)
  "Create a vector of stmt objects from collection of sorted stmts"
  (let ((arrayoflist (arraytolist arrayofarray)))
    (osql-result arrayofarray (listtoarray (mapcar (f/l (subarray)(elt subarray 2)) arrayoflist)))))

;(defun encode-transient (fno k transient)
;  "Create transient with encodes as key" 
;  (let ((transient (create-transient-object 'RDF_RESOURCE)))
;    (encode-resource transient k)
;    (if (stringp k) (let ((a (getfunction 'alias (list k)))) 
;		      (if (NOT(NOT a))(encode-resource transient a))))
;    (osql-result k transient)))

(defun encode-transient (fno k transient)
  "Create transient with encodes as key" 
  (let ((transient (create-transient-object 'RDF_RESOURCE)) (o (aref k 1)))
    (if (NOT (stringp k)(seta k 1 (mkstring o))))
    (encode-resource transient k)
    (osql-result k transient)))

(defun decode-transient (fno k resource)
  "Get resource key as encodes"
  (osql-result (decode-resource resource) resource))

(defun encode-persistent (fno amos_id r)
  "Encode persistent resource"
  (mapfunction _new_persistent_ (vector amos_id)
	       (f/l (row)(osql-result amos_id (car row)))))

(defun decode-persistent (fno k resource)
  "Decode persistent resource"
  (osql-result (decode-resource resource) resource))

(defun encode-resource (resource k)
 "Put encodes property for resource" 
(putobject resource 'encodes k))

(defun decode-resource (resource)
  "Get encodes property for resource"
  (getobject resource 'encodes))

(defun scan_pred (fno p)
(osql-result p))

(defun filter_pred (fno p) 
  (if (getfunction 'filter_pred (list p))(osql-result p)))

(defun scan_store (fno s p o i)
  (osql-result s p o i))

(defun filter_store (fno s p o i)
  (if (getfunction 'filter_store (list p))(osql-result s p o i)))


;(defun print-resource (r stream)
;  "Printer for RDF resources"
;  (let ((uri (and (null (oid-name r)) 
;		  (caar (getfunction _id_ (list r))))))
;    (cond (uri (princ "uri(" stream)
;	       (prin1 uri stream)
;	       (princ ")" stream))
;	  (t nil))))

(defun print-resource (r stream)
  "Printer for RDF resources"
  (let ((uri (and (null (oid-name r)) 
		  (caar (getfunction _id_ (list r))))))
    (cond (uri 
	       (princ uri stream))
	  (t nil))))


(defun get-rdf-name (o)
  (caar (getfunction 'get_nickname (list o))))

(defun get-rdf-resource (n)
  (caar (getfunction 'resource_named (list n))))

;;Skall flyttas!!!Funktion som kopplar printer till rdf resurs för att skriva ut object 
;;på format uri("http://....")
;(set-printfn 'rdf_resource (function print-resource))

(defun add-encodes (fno arg)
      (putobject arg 'encodes)
      (osql-result arg))

(defun set-encodes (fno resource extobj) 
	(/putobject resource 'encodes extobj)
	(osql-result resource extobj))

