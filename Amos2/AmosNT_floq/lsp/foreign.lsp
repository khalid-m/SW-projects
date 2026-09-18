;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010 Tore Risch, UDBL
;;; $RCSfile: foreign.lsp,v $
;;; $Revision: 1.9 $ $Date: 2012/10/22 20:14:09 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Registration of foreign languages and their functions
;;; =============================================================
;;; $Log: foreign.lsp,v $
;;; Revision 1.9  2012/10/22 20:14:09  torer
;;; Foreign language (e.g. Python) code automatically loaded when saved in image
;;;
;;; Revision 1.8  2012/01/28 10:34:48  torer
;;; olog utilities added
;;;
;;; Revision 1.7  2012/01/28 10:08:48  torer
;;; Functions DEFINE-EXTERNAL-PREDICATE and LOAD-EXTERNAL-PREDICATE
;;;
;;; Revision 1.6  2012/01/16 10:05:28  torer
;;; Now possible to have image without Lisp source code
;;;
;;; Revision 1.5  2011/08/08 20:17:51  torer
;;; Binding pattern passed to foreign TBR definition
;;;
;;; Revision 1.4  2011/07/06 20:36:00  torer
;;; FNO + bpat passed to foreign function loader
;;;
;;; Revision 1.3  2011/05/04 18:51:19  torer
;;; Bad indentation + too many parantheses
;;;
;;; Revision 1.2  2011/04/20 17:16:29  roka4241
;;; Returning of scans from amos to python. Calling and mapping over amos functions from python.
;;;
;;; Revision 1.1  2010/12/29 20:18:29  torer
;;; Registration of foreign language functions
;;;
;;; =============================================================

(defglobal _loaded-foreign-functions_ (make-hash-table)
  "Table of foreign functions in image per language")

(defun register-loader (language fn)
  "Register loader function FN for foreign functions in LANGUAGE"
  (putprop language 'loader fn))

(defun get-loader (language)
  "Get the function to dynamically load Amos function for a language"
  (let ((loader (getprop language 'loader)))
    (cond ((function-definedp loader) loader) 
	  (t (error "Cannot dynamically load foreign functions in language" 
		    language)))))

(defun register-enabled (language fn)
  "Register function to test if LANGUAGE enabled"
  (putprop language 'enabled fn))

(defun language-enabled-p (language)
  "True if LANGUAGE is enabled"
  (let ((enabled (getprop language 'enabled)))
    (and (function-definedp enabled)(funcall enabled language))))

(defun get-extpred (pname)
  "Get the system object representing forrein predicate named PNAME"
  (getprop (mksymbol pname) 'extpred))

(defun define-external-predicate (pname)
  "Create the system object representing the external predicate PNAME"
  (cond ((get-extpred pname))
        (t (bind-undefined pname))))

(defun load-external-predicate (ep &optional bpat)
  "Load the external predicate EP optionally associated with FNO and
   binding pattern BPAT"
  (load-foreign-function (extpred-name ep) bpat))
 
(defun load-foreign-function (fname bpat)
  "Load foreign Amos function in external language if possible"
  (and fname 
       (let ((lang (external-language-of fname))
	     (tbr (cons fname (and bpat (listbpat bpat)))))
	 (cond ((null lang) nil)	; no language specified in FNAME
	       ((member tbr (gethash lang ; already loaded 
				     _loaded-foreign-functions_)))
               ((null (language-enabled-p lang))
                (bind-undefined fname)	; error message if FF called
                (push tbr (gethash lang	; register function
				   _loaded-foreign-functions_)))
               ((funcall (get-loader lang) fname (cdr tbr))
					; load function
		(push tbr (gethash lang	; register function
				   _loaded-foreign-functions_)))
	       (t (amos-error "Failed to load foreign function" 
			      fname))))))

(defun external-language-of (fname)
  "Get the language part of a foreign function implementation string"
  (let ((pos (string-pos fname ":")))
    (cond ((null pos) nil)
	  (t (mksymbol (substring 0 (1- pos) fname))))))

(defun disable-all-foreign-languages ()
  "Unenable foregn functions in external language.
   Called just after rollin since the foreign language may have been
   enabled when image saved but not any more"
  (maphash (f/l (language fdefs)(remprop language 'enabled))
           _loaded-foreign-functions_))

(defun load-all-foreign-language-functions () ; se also function (boot)
  "Load foreign functions for enabled languages after rollin"
  (maphash (f/l (language fns)
		(if (language-enabled-p language)
		    (let ((loader (get-loader language)))
		      (dolist (fn fns)(funcall loader (car fn)(cdr fn))))
		  ))
	   _loaded-foreign-functions_))
