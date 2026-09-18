;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2014, Andrej Andrejev, UDBL
;;; $RCSfile: sparql-translator-logger.lsp,v $
;;; $Revision: 1.3 $ $Date: 2014/01/10 12:11:20 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Logger utility for SciSPARQL translator
;;; =============================================================
;;; $Log: sparql-translator-logger.lsp,v $
;;; Revision 1.3  2014/01/10 12:11:20  andan342
;;; Added optional :mode argument to SPARQL-LOGGER-START to avoid diplicate output
;;; - either :lispfn (has access to ALisp symbols) or :amosfn (default)
;;;
;;; Revision 1.2  2014/01/03 16:37:27  andan342
;;; Extnded HTML logger to intercep sparql() amos function calls as well
;;;
;;; =============================================================

(defvar *sparql-html-log* nil)

(defvar *sparql-logger-mode* nil)

(defun sparql-logger-start (filename &key mode)
  (setq *sparql-html-log* (openstream filename "w"))
  (setq *sparql-logger-mode* (if mode mode :amosfn))
  (formatl *sparql-html-log* "<STYLE TYPE=\"text/css\"> <!-- BODY { font-family:\"Courier New\"; } --> </STYLE>"
	   t "<html>" t "<body> <table border=1>" t))

;; redefining SPARQL function

(defmacro sparql (str)
  (when (and *sparql-html-log* (eq *sparql-logger-mode* :lispfn))
    (row-to-html-stream (list (if (stringp str) "" str) (eval str) (sparql-translate (eval str)))
			*sparql-html-log*))
  `(within-lisp
    (eval (with-textstream s ,str 
			   (parse-stream s "SPARQL")))))

;; modify SPARQL-TRANSLATE function (no access to argument symbols)

(advise-around #'sparql-translate
	       `(let ((res *))		 
		  (when (and *sparql-html-log* (eq *sparql-logger-mode* :amosfn))
		   (row-to-html-stream (list "" query res) *sparql-html-log*))
		  res))

(defun sparql-logger-stop ()
  (formatl *sparql-html-log* "</table> </body> </html>")
  (closestream *sparql-html-log*)
  (setq *sparql-html-log* nil))
