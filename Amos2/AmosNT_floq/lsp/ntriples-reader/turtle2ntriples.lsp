;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010-11, Andrej Andrejev, UDBL
;;; $RCSfile: turtle2ntriples.lsp,v $
;;; $Revision: 1.2 $ $Date: 2011/04/11 13:55:08 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Turtle to NTriples converter
;;; =============================================================
;;; $Log: turtle2ntriples.lsp,v $
;;; Revision 1.2  2011/04/11 13:55:08  andan342
;;; Restructured code, added headers and 1 custom triples filter script
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(load (concat (getenv "AMOS_HOME") "/lsp/ntriples-reader/turtle-syntax-parser.lsp"))

(defun no-filter (s p o) t)

(defun turtle2ntriples (sourcefile targetfile)
  "Convert the triples from Turtle format to N-Triples"
  (let ((fr (fr-open sourcefile))
	(outs (openstream targetfile "w")) res)        
    (unwind-protect
	(progn
	  (setq res (turtle2ntriples-slr1-parser (f/l () (turtle-lexer fr outs)) (cons outs #'no-filter))) ; run SLR(1) parser routine
	  (when (and (listp res) (eq (car res) 'syntax-error)) 
	    (error (concat "Syntax error at " (fr-pos-string fr) ": Input: " (fourth res) " Expected: " (third res) " at state " (second res)))))
      (progn
	(fr-close fr)
	(closestream outs)))))

