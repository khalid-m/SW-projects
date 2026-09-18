;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010-2013 Andrej Andrejev, UDBL
;;; $RCSfile: scisparql-fns.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/09/06 21:47:23 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Specific SciSPARQL functions
;;; =============================================================
;;; $Log: scisparql-fns.lsp,v $
;;; Revision 1.1  2013/09/06 21:47:23  andan342
;;; - Moved definitions of standard SPARQL functions to sparql-fns.lsp, SciSPARQL functions to scisparql-fns.lsp
;;; - Implemented all SPARQL 1.1 string functions (except REPLACE, ENCODE_FOR_URI, langMAtches)
;;; - Redefined rdf:regex() using Amos functions like() and like_i()
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

;; Depends on:
;; _sq_string_based_

;; --------------- 2ND-ORDER FUNCTIONS --------------------------------

(defun rdf-argmin-+ (fno bag)
  (let (resrow)
    (mapbag bag (f/l (row) (when (or (null resrow) (< (second row) (second resrow)))
			     (setq resrow row))))
    (when resrow
      (osql-result bag (first resrow)))))

(defun rdf-argmax-+ (fno bag)
  (let (resrow)
    (mapbag bag (f/l (row) (when (or (null resrow) (> (second row) (second resrow)))
			     (setq resrow row))))
    (when resrow
      (osql-result bag (first resrow)))))

(osql "
create function rdf:argmin(Bag b) -> Literal
  as foreign 'rdf-argmin-+';

create function rdf:argmax(Bag b) -> Literal
  as foreign 'rdf-argmax-+';
")