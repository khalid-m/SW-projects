;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Andrej Andrejev, UDBL
;;; $RCSfile: string-based-wrapper.lsp,v $
;;; $Revision: 1.4 $ $Date: 2013/12/20 14:48:23 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Running SSDM in Charstring-based mode
;;; =============================================================
;;; $Log: string-based-wrapper.lsp,v $
;;; Revision 1.4  2013/12/20 14:48:23  andan342
;;; Supporting multiple stored graphs:
;;; - added GRAPH and FROM NAMED syntax
;;; - LOAD() and CLEAR() functions now take a graph URI as the last argument
;;; - default stored graph is now in GRAPH(0)
;;;
;;; Revision 1.3  2013/02/24 10:42:48  andan342
;;; Added (nma-proxy-enabled) into string-based version
;;;
;;; Revision 1.2  2012/12/14 14:02:04  andan342
;;; Added rdf:insert and rdf:clear Amos functions, callable from SciSPARQL
;;;
;;; Revision 1.1  2012/06/13 15:05:13  andan342
;;; String-based mode added for compliance with SWARD/SARD tests. 'string-based-wrapper.lsp' file should be loaded on topof Amos2.exe - no separate executable required, no SPARQL console enabled.
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(defvar _sq_string_based_ t)

(with-directory (concat (getenv "AMOS_HOME") "/SQoND/lsp/readers")
		(load "turtle-reader.lsp")) ; not loading nma.lsp

(setq _sq_emit_nmas_ nil) ;; emit Turtle collections as RDF collection (no arrays!)

(defvar _nma_proxy_resolve_ nil) ; variable from nma.lsp referred in sparql-translator

(with-directory (concat (getenv "AMOS_HOME") "/SQoND/lsp")
		(load "in-memory-storage.lsp")
		(load "sparql-wrapper.lsp"))

(defun sparql (str) ;MAYBE: within-lisp
  (getfunction (car (getobject (getfunctionnamed 'evalv) 'resolvents)) 
	       (list (sparql-translate str nil))))

(defun nma-proxy-enabled () nil)

