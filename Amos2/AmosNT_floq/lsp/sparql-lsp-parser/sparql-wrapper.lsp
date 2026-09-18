;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010-11 Andrej Andrejev, UDBL
;;; $RCSfile: sparql-wrapper.lsp,v $
;;; $Revision: 1.1 $ $Date: 2011/04/06 13:34:35 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: SparQL processor (vector-based)
;;; =============================================================
;;; $Log: sparql-wrapper.lsp,v $
;;; Revision 1.1  2011/04/06 13:34:35  andan342
;;; Separated translator functionality from parser, devised 2 wrappers:
;;; - vector-based (recommended)
;;; - tuple-based (compatible with rewrites in SARD)
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================


(with-directory (concat (getenv "AMOS_HOME") "/lsp/sparql-lsp-parser/")
		(load "sparql-translator.lsp"))

(osql "create function sparql(Charstring sparql)->Vector as select eval(parse_sparql(sparql));")