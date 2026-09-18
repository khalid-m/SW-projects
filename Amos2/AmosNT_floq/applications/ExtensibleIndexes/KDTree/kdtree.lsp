;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Thanh Truong, UDBL
;;; $RCSfile: kdtree.lsp,v $
;;; $Revision: 1.9 $ $Date: 2012/01/04 14:54:41 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Utilities for KDtree search
;;; =============================================================
;;; $Log: kdtree.lsp,v $
;;; Revision 1.9  2012/01/04 14:54:41  thatr500
;;; fixed regression test
;;;
;;; Revision 1.8  2011/11/02 16:56:28  thatr500
;;; Use a new term "AQUIT" (Algebraic Query Inequality Transformation)
;;;
;;; Revision 1.7  2011/04/11 07:40:42  thatr500
;;; adapted to new Transformation on inequality (AQUIT) + rewrite Euclid
;;;
;;; Revision 1.6  2011/03/02 08:49:55  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.6  2011/02/27 10:07:14  torer
;;; Updated lab. Use term 'proximity search'
;;;
;;; Revision 1.5  2011/02/26 19:36:58  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.4  2011/02/25 18:51:22  thatr500
;;; add stubs
;;;
;;; Revision 1.4  2011/02/25 02:48:57  thatr500
;;; change to kdtreeSimilaritySearch
;;;
;;; Revision 1.3  2011/02/24 17:32:20  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.2  2011/02/24 08:38:30  thatr500
;;; remove KNN and add similarity search
;;;
;;; Revision 1.1  2011/02/22 21:58:42  thatr500
;;; Unite all extensible indexes and their tests at one place.
;;;
;;; Revision 1.1  2011/02/15 02:23:29  thatr500
;;; KDTree -another extension of index
;;;
;;; =============================================================
;;(osql "create function kdtreeProximitySearch(Integer xtId, 
 ;;          Vector of Number x, Number distance)-> Bag of Object
  ;;as foreign 'not-yet-implfn';")

(osql "add_index_rewrite_rule('KDTREE', #'VECTOR-NUMBER.VECTOR-NUMBER.EUCLID->NUMBER', 
                                       #'INTEGER.VECTOR-NUMBER.NUMBER.KDTREEPROXIMITYSEARCH->OBJECT');")

(setq *enable-aqit* t)