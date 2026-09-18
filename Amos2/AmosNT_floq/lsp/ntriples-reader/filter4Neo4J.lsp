;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010-11, Andrej Andrejev, UDBL
;;; $RCSfile: filter4Neo4J.lsp,v $
;;; $Revision: 1.1 $ $Date: 2011/04/11 13:55:07 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Utility to filter out triples problematic with Neo4J
;;; =============================================================
;;; $Log: filter4Neo4J.lsp,v $
;;; Revision 1.1  2011/04/11 13:55:07  andan342
;;; Restructured code, added headers and 1 custom triples filter script
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(load (concat (getenv "AMOS_HOME") "/lsp/ntriples-reader/turtle-syntax-parser.lsp"))

(defun 4neo4j-filter (s p o)
  (not (or (equal s o)
	   (eq (car s) 'blank)
	   (eq (car p) 'blank)
	   (eq (car o) 'blank))))

(defun turtle2ntriples (sourcefile targetfile)
  "Convert the triples from Turtle format to N-Triples"
  (let ((fr (fr-open sourcefile))
	(outs (openstream targetfile "w")) res)        
    (unwind-protect
	(progn
	  (setq res (turtle2ntriples-slr1-parser (f/l () (turtle-lexer fr outs)) (cons outs #'4neo4j-filter))) ; run SLR(1) parser routine
	  (when (and (listp res) (eq (car res) 'syntax-error)) 
	    (error (concat "Syntax error at " (fr-pos-string fr) ": Input: " (fourth res) " Expected: " (third res) " at state " (second res)))))
      (progn
	(fr-close fr)
	(closestream outs)))))

