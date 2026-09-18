;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012, Andrej Andrejev, UDBL
;;; $RCSfile: reader-utils.lsp,v $
;;; $Revision: 1.4 $ $Date: 2014/01/16 00:41:30 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Common reader functions
;;; =============================================================
;;; $Log: reader-utils.lsp,v $
;;; Revision 1.4  2014/01/16 00:41:30  andan342
;;; STRING-RIGHTPOS now takes search chars as a list, and an opional argument DOWNTO
;;;
;;; Revision 1.3  2012/12/17 23:40:53  andan342
;;; *** empty log message ***
;;;
;;; Revision 1.2  2012/12/17 23:30:58  andan342
;;; Enabling file-links with parameters, always resolving in same dir as .TTL file
;;;
;;; Revision 1.1  2012/11/22 12:41:55  andan342
;;; Added extensible plug-in reader mechanism to resolve file-links in Turtle files
;;; Implemented CheloniaArray reader to load BISTAB data
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

;; Should be loaded after grab.lsp

(defun lproduct (l)
  "Product of list elements"
  (let ((res 1))
    (dolist (e l res)
      (setq res (* res e)))))

(defun open-filename-or-url (filename-or-url)
  "Open a stream or chunked-stream, produce errors if not accessible. 
   Return (<stream> . <printable-name>), the latter is needed for error reporting.
   Normal stream needs to be closed afterwards."
  (let* ((printable
	  (selectq (typename filename-or-url)
		   (uri (concat "<" (uri-id filename-or-url) ">"))
		   (ustr (ustr-str filename-or-url))
		   filename-or-url)) ; if string
	 (str (if (eq (typename filename-or-url) 'uri)
		  (get-url-chunked-stream (uri-id filename-or-url))
		(if (file-exists-p printable)
		    (openstream printable "r")
		  (error (concat "Error: file " printable " does not exist!"))))))				       
    (when (stringp str) ; can only happen in URL case
      (error (concat "Error: resource " printable " is not accessible, server response: " str)))
    (cons str printable)))

(defun read-number-list (str delim term)
  "Read list of numbers separated by DELIM and ended by TERM from stream or chunked-stream STR"
  (let (res token)
    (loop
      (setq token (if (chunked-stream-p str) (chunked-read-token str delim term nil t)
		    (read-token str delim term nil t)))
      (if (numberp token)
	  (push token res)
	(return (nreverse res)))))) 

(defun read-string-list (str delim term)
  "Read list of numbers separated by DELIM and ended by TERM from stream or chunked-stream STR"
  (let (res token)
    (loop
      (setq token (if (chunked-stream-p str) (chunked-read-token str delim term t t)
		    (read-token str delim term nil t)))
      (if (or (eq token '*eof*) (string-pos term token))
	  (return (nreverse res))
	(push token res)))))

(defun filename-dir (fn)
  (let* ((fs-pos (string-rightpos fn '("/")))
	 (bs-pos (string-rightpos fn '("\\")))
	 (pos (cond ((and fs-pos bs-pos) (max fs-pos bs-pos))
			   (fs-pos fs-pos)
			   (bs-pos bs-pos))))
    (if pos (substring 0 (1- pos) fn)
      "."))) ; return current dir if not specified

(defun filename-or-url-dir (filename-or-url)
  (selectq (typename filename-or-url)
	   (ustr (filename-dir (ustr-str filename-or-url))) ; return string
	   (string (filename-dir filename-or-url))
	   (uri (uri (filename-dir (uri-id filename-or-url)))) ; or URI
	   nil)) ; error here
		 
