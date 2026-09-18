;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Tore Risch, UDBL
;;; $RCSfile: lispfns.lsp,v $
;;; $Revision: 1.8 $ $Date: 2013/05/16 20:02:10 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Testin basic Lisp functionality
;;; =============================================================
;;; $Log: lispfns.lsp,v $
;;; Revision 1.8  2013/05/16 20:02:10  torer
;;; Propagation of enter systen times for events added
;;;
;;; Revision 1.7  2012/01/17 21:51:28  torer
;;; Closure testing to basic Lisp
;;;
;;; Revision 1.6  2012/01/06 13:14:54  torer
;;; Separate Lisp and mexima tests
;;;
;;; Revision 1.5  2011/12/28 16:10:54  torer
;;; Testing MEXIMA
;;;
;;; Revision 1.3  2011/12/24 11:45:13  thatr500
;;; added memory leak test
;;;
;;; Revision 1.2  2011/11/22 18:32:01  torer
;;; Careful testing of B-trees
;;;
;;; Revision 1.1  2011/11/22 18:04:55  torer
;;; Separated regression test of Lisp kernel
;;;
;;; =============================================================

(load "dynclosure.lsp")

(load "basic.lsp")

(load "time.lsp")

(load "systime.lsp")

(load "btree.lsp")

(if _mexima-enabled_ (load "mexi.lsp"))

(checkequal "Lisp code valid"
            ((verify-all) t)
	    )

(checkequal "rollout"
	    ((rollout "foo.dmp") t)
	    ((rollout "foo.dmp") t)
	    )

