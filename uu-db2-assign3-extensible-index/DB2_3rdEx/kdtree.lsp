;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Thanh Truong, UDBL
;;; $RCSfile: kdtree.lsp,v $
;;; $Revision: 1.10 $ $Date: 2013/02/19 05:58:49 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Utilities for KDtree search
;;; =============================================================
;;; $Log: kdtree.lsp,v $
;;; =============================================================

(osql "add_index_rewrite_rule('KDTREE', #'VECTOR-NUMBER.VECTOR-NUMBER.EUCLID->NUMBER', 
                                       #'INTEGER.VECTOR-NUMBER.NUMBER.KDTREEPROXIMITYSEARCH->OBJECT');")

(setq *enable-aqit* t)
