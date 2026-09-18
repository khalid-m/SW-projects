;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010 Thanh Truong, UDBL
;;; $RCSfile: mexima.lsp,v $
;;; $Revision: 1.30 $ $Date: 2013/08/01 12:58:21 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Load order of Mexima extension
;;; =============================================================
;;; $Log: mexima.lsp,v $
;;; Revision 1.30  2013/08/01 12:58:21  thatr500
;;; refined code to save and restore mexima indexes as key value pairs
;;;
;;; Revision 1.29  2013/01/18 14:35:41  thatr500
;;; - removed printf
;;; - added commandline assignment3.cmd
;;;
;;; Revision 1.28  2013/01/09 15:07:32  thatr500
;;; removed load-index-extension, load-special-extension. Instead,
;;; function load-extension is used.
;;;
;;; Revision 1.27  2012/01/18 10:43:19  thatr500
;;; lookup shared objects in LD_LIBRARY_PATH when it is set
;;;
;;; Revision 1.26  2012/01/13 21:17:33  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.25  2012/01/12 13:04:11  thatr500
;;; Enable AQIT when MEXI is set
;;;
;;; Revision 1.24  2012/01/12 07:58:22  thatr500
;;; - changed signature a_initialize_extension
;;; - fixed "Loading Borland /VC++ dynamic dll" on Unix
;;;
;;; Revision 1.23  2012/01/09 09:13:26  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.22  2012/01/05 16:54:17  thatr500
;;; removed some old cold. To be added new code
;;;
;;; Revision 1.21  2012/01/04 14:50:27  thatr500
;;; - allowed to extend indexing through Foreign function
;;; - add XTree as built-in index
;;;
;;; Revision 1.20  2012/01/02 08:44:55  thatr500
;;; - used default extent if any
;;; - create one extent on a relation in case there are several MEXI indexes
;;;
;;; Revision 1.19  2011/12/28 10:04:21  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.18  2011/12/20 21:00:16  thatr500
;;; changed flag from _exinma-enabled_ to _mexima-enabled_
;;;
;;; Revision 1.17  2011/12/13 09:58:36  thatr500
;;; comment out rewriters
;;;
;;; Revision 1.16  2011/12/02 12:51:47  thatr500
;;; loading order of MEXIMA and its utilities
;;;
;;; Revision 1.15  2011/12/02 09:52:04  thatr500
;;; Removed old MEXIMA
;;;
;;; Revision 1.14  2011/11/15 10:07:49  thatr500
;;; hook AQIT up to the system
;;;
;;; Revision 1.13  2011/11/09 11:13:57  thatr500
;;; load new Lisp files
;;;
;;; Revision 1.12  2011/11/02 16:51:06  thatr500
;;; Use a new term "AQUIT" (Algebraic Query Inequality Transformation)
;;;
;;; Revision 1.11  2011/10/07 08:06:24  thatr500
;;; to support Euclidean on 1D (not yet)
;;;
;;; Revision 1.10  2011/08/17 08:29:31  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.9  2011/06/23 09:03:42  thatr500
;;; Load internal XTREE's scripts
;;;
;;; Revision 1.8  2011/06/11 11:08:13  thatr500
;;; change Euclid predicate to distance predicate. It is general to handle
;;; Euclid and Minkowski now
;;;
;;; Revision 1.7  2011/05/06 15:02:42  thatr500
;;; remove XTREE from kernel. Now it comes as a dynamic loaded library
;;;
;;; Revision 1.6  2011/05/06 01:40:15  thatr500
;;; generalized rewrite code of Mexima
;;;
;;; Revision 1.5  2011/05/04 08:26:08  thatr500
;;; added rewrite rule for KNN operator by add_knn_rewrite_rule.
;;;
;;; Revision 1.4  2011/05/02 12:05:58  torer
;;; Setting system watermark
;;;
;;; Revision 1.3  2011/04/05 11:06:15  thatr500
;;; update load order of Mexima supporting functions
;;;
;;; Revision 1.2  2011/03/29 17:19:23  thatr500
;;; Try AQUIT on distance-predicate
;;;
;;; Revision 1.1  2011/03/19 15:13:22  thatr500
;;; separated Mexima and Xtree code
;;;
;;; Revision 1.4  2011/03/19 11:56:13  thatr500
;;; add simple inequality transformation to the Amos II
;;;
;;; Revision 1.3  2011/03/05 00:06:52  thatr500
;;; add utilities
;;;
;;; Revision 1.2  2010/12/20 18:39:55  thatr500
;;; add condition to load EXINMA
;;;
;;; =============================================================
(cond (_mexima-enabled_
       (load "internal-xtree.lsp")
       ;;(register-indextype0 "XTREE" nil nil) 
       ;; KNN rewriter
       (load-amosql  "rewriter-knn.osql")
       (load  "rewriter-knn.lsp")
       ;;(set-watermark)
       ))

