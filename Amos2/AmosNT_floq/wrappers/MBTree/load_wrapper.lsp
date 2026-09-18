;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: load_wrapper.lsp,v $
;;; $Revision: 1.3 $ $Date: 2003/07/14 07:11:43 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Loads the MBTree wrapper. Assumed current directory is 
;;;              AmosNT/bin
;;;              
;;; ===========================================================================

;(load "../wrappers/MBTree/abstractindex.lsp")
(load "../wrappers/MBTree/rangequery.lsp")
(load "../wrappers/MBTree/mbtree.lsp")
(load "../wrappers/MBTree/mbtree_translator.lsp")
(load-amosql "../wrappers/MBTree/mbtree.osql")
(load-amosql "../wrappers/MBTree/mbtree_capability.osql")