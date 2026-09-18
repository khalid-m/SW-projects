;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010-11 Andrej Andrejev, UDBL
;;; $RCSfile: sparql-tools.lsp,v $
;;; $Revision: 1.2 $ $Date: 2011/05/06 06:33:46 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Parser-based SparQL tools
;;; =============================================================
;;; $Log: sparql-tools.lsp,v $
;;; Revision 1.2  2011/05/06 06:33:46  andan342
;;; Now allowing prefixes same as keywords
;;;
;;; Revision 1.1  2011/04/04 12:23:34  andan342
;;; Separated translator code from the parser code,
;;; added "SparQL tools"
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(with-directory (concat (getenv "AMOS_HOME") "/SQoND/lsp/")
		(load "sparql-lsp-parser.lsp"))

(defun sparql-get-vars-+ (fno query r) 
 (let* ((pq (sparql-parse query))
	 (stat (second pq)))
    (cond ((select-stat-p stat) ;;SELECT queries
	   (osql-result query (listtoarray (sellist-to-vars (select-stat-what stat)))))
	  (t nil))))

(osql "
create function sparql_get_vars (Charstring query) -> Vector of Charstring 
  as foreign 'sparql-get-vars-+';
")
  