;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Andrej Andrejev, UDBL
;;; $RCSfile: chelonia-store.lsp,v $
;;; $Revision: 1.3 $ $Date: 2012/03/17 21:39:37 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Chelonia-based RDF storage implementation
;;; =============================================================
;;; $Log: chelonia-store.lsp,v $
;;; Revision 1.3  2012/03/17 21:39:37  andan342
;;; - Added debug functionality, including _chelonia_dub_results_ switch
;;;
;;; Revision 1.2  2012/02/23 19:10:32  andan342
;;; Chelonia to SPAQRQL connectivity with updates (except arrays)
;;;
;;; Revision 1.1  2012/02/21 11:03:48  andan342
;;; Amos-to-Chelonia interface with updates (except inserting arrays)
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(defun escape-string (str escaped-chars)
  "add backslash before each ESCAPED-CHARS character inside STR"
  (let* ((i (1- (length str))))
    (while (>= i 0)
      (when (string-pos escaped-chars (substring i i str))
	(setq str (concat (if (= i 0) "" (substring 0 (1- i) str)) "\\"
			  (substring i (1- (length str)) str))))
      (decf i))
    str))

(defun literal-to-chelonia-string (value)
  (selectq (typename value)
	   (ustr (with-string s (princ (escape-string (ustr-str value) "#<>") s))) ; support langtags
	   (uri (concat "<" value ">"))
	   (symbol (concat "#" value)) ; boolean
	   (with-string s (princ value s)))) ; datetime	  

(defun addValue---- (fno dbname taskId vName value)
  (getfunction (car (getobject (getfunctionnamed 'sendUpdate) 'resolvents))
	       (list dbname (concat "INSERT INTO " (selectq (typename value)
							    (integer "i")
							    (real "f")
							    (nma (error "Array updates not implemented yet"))
							    "s")
				    "Triples (taskId,vName,value) VALUES (" taskId ",'" vName "',"
				    (if (member (typename value) '(integer real)) value
				      (concat "'" (literal-to-chelonia-string value) "'")) ");"))))

(defun chelonia-string-to-literal (str)
  (let ((ln (length str)) b-found)
    (if (= ln 0) str ; empty string
      (selectq (substring 0 0 str)
	       ("#" (cond ((and (> ln 1) (string= (substring 1 1 str) "["))
			   (read str)) ; datetime
			  ((and (> ln 1) (setq b-found (member (string-downcase (substring 1 (1- ln) str)) 
							       '("true" "false"))))
			   (if (cdr b-found) 'true 'false)) ; boolean values
			  (t (error (concat "Invalid string stored in Chelonia: '" str "'")))))
	       ("<" (uri (substring 1 (- ln 2) str))) ; URI
	       (ustr (read (concat "\"" str "\""))))))) ; string (remove escapes)

(defun Chelonia_str_to_literal-+ (fno str res)
  (osql-result str (if (stringp str) ; if argument is not a string - return unchanged 
		       (chelonia-string-to-literal str) str)))

(defun Chelonia_str_to_literal+- (fno str res)
  (osql-result (literal-to-chelonia-string res) res))

(osql "
create function Chelonia_str_to_literal(Literal str) -> Literal
  as multidirectional
  ('bf' foreign 'Chelonia_str_to_literal-+')
  ('fb' foreign 'Chelonia_str_to_literal+-');
")

;; PROVIDING RDFSTORE INTERFACE 

(setq _sq_default_triples_fn_ "CT(:def_graph)")

(defun load-into-chelonia (filename)
  (getfunction (car (getobject (getfunctionnamed 'load_triples) 'resolvents))
	       (list amos_def_graph filename)))

(defun clear-chelonia ()
  (getfunction (car (getobject (getfunctionnamed 'clear_triples) 'resolvents))
	       (list amos_def_graph)))


(defun get-blank-in-chelonia (x)
  (getfunction (car (getobject (getfunctionnamed 'URI_in_Chelonia) 'resolvents))
     (list amos_def_graph (uri-id x))))

(setq _sq_load_triples_ #'load-into-chelonia)

(setq _sq_clear_triples_ #'clear-chelonia)

(setq _sq_get_blank_ #'get-blank-in-chelonia)
	       
						     


