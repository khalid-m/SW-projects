;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2004 Johan Petrini, UDBL
;;; $RCSfile: initrdfs.lsp,v $
;;; $Revision: 1.3 $ $Date: 2007/11/05 18:28:41 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Bootstrapping PSELO representation of RDFS.
;;;              
;;; =========================================================================== 

; (help)

; Global variables
(defvar _rdf-prefix_ "rdf_")

; Definiera variabel och skapa typen rdfsclass under local_resource och storedtype. 
; Allow multiple inheritance of RDFS classes from STOREDTYPE 
; since an RDFS resource is both a class and a user object.
(defvar _rdfsclass_ (createtype 'rdfsclass '(rdf_resource storedtype)))       

; Adding meta types to existing types in ontology for describing rdf schema
(/addtype _rdfsclass_ _rdfsclass_)
(/addtype _rdf_resource_ _rdfsclass_)

; Private functions

; Sätt object o till att vara rdf resurs
(defun set-uri (o uri)
   "Force O to be URI resource"
   (addfunction (getfunctionnamed 'rdf_resource.intid->charstring)
       (list o)
       (list uri)
       t))

(defun unique-type (nm)
  "Make unique Amos type from NM"
  (cond ((null (gettypenamed nm t)) nm)
        ((dotimes (i 100)
		  (let ((nm1 (pack nm '_ i)))
		    (if (null (gettypenamed nm1 t))(return nm1)))))
        (t (error "More than 100 RDFS types named" nm))))

; Should they be here?
(defun make-rdf-type (fno from to oid)
  "Forces rdf_resource FROM to become rdfsclass named NICKNAME under 
   existing rdf types in TO in user type hierarchy"
  (let ((supertypes (or (arraytolist to)(list _rdf_resource_)))
	(name (unique-type 
	       (pack _rdf-prefix_
		     (mksymbol (get-rdf-name from))))))
    (osql-result from to (createtype name supertypes  _rdfsclass_ nil from))))

(defun add-rdf-type (fno oid tpo)
  "Wrapper function of /addtype. Used to add tpo to types of oid"
  (/addtype oid tpo)
  (osql-result oid tpo))

; Sätt id(xxx). rdf_resource samt rdfsclass reflexiva dvs instanser av sig själva.
(set-uri _rdf_resource_ "http://www.w3.org/2000/01/rdf-schema#Resource")
(set-uri _rdfsclass_ "http://www.w3.org/2000/01/rdf-schema#Class")

; Sätt nickname(xxx). rdf_resource samt rdfsclass reflexiva dvs instanser av sig själva.
;(addfunction 'nickname (list _rdfsclass_)(list "Class"))
;(addfunction 'nickname (list _rdf_resource_)(list "Resource"))

(putobject _rdfsclass_ 'encodes (vector "http://www.w3.org/2000/01/rdf-schema#" "Class"))
(putobject _rdf_resource_ 'encodes (vector "http://www.w3.org/2000/01/rdf-schema#" "Resource"))

;(osql "set encodes(typenamed('RDF_RESOURCE')) = 'http://www.w3.org/2000/01/rdf-schema#Resource';")
;(osql "set encodes(typenamed('RDFSCLASS'))= 'http://www.w3.org/2000/01/rdf-schema#Class';")



