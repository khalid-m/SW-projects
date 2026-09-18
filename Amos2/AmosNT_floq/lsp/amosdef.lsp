;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Tore Risch, UDBL
;;; $RCSfile: amosdef.lsp,v $
;;; $Revision: 1.75 $ $Date: 2013/11/18 20:15:15 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Minimal Amos II system
;;; =============================================================
;;; $Log: amosdef.lsp,v $
;;; Revision 1.75  2013/11/18 20:15:15  torer
;;; iterate(Function nxt, Object arg, Number max) -> Object
;;;
;;; Revision 1.74  2013/11/07 16:08:53  torer
;;; Generalized overloaded groupby()
;;;
;;; Revision 1.73  2013/06/29 16:09:25  torer
;;; New file for CSV file access: lsp/CSV.osql
;;;
;;; Revision 1.72  2013/03/27 16:18:35  torer
;;; CSV reader now in C and following EXCEL's format
;;; 2.63 times faster
;;;
;;; Revision 1.71  2013/03/23 16:17:12  torer
;;; Added CSV file reader
;;;
;;; Revision 1.70  2013/02/06 07:40:55  torer
;;; new function
;;;   csvstring(Vector v, Charstring d)->Charstring
;;;
;;; Revision 1.69  2012/02/22 09:25:12  torer
;;; No program database in released version
;;;
;;; Revision 1.68  2012/01/13 16:45:44  torer
;;; RECORD and unloadschema in released version
;;;
;;; Revision 1.67  2011/12/29 07:37:14  torer
;;; Introduced tuple types
;;;
;;; Revision 1.66  2011/12/22 12:55:14  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.65  2011/11/16 12:12:37  torer
;;; Support for multiple parsers
;;;
;;; Revision 1.64  2009/11/02 19:57:46  torer
;;; Conditional ifsome, documentation of quantifiers
;;;
;;; Revision 1.63  2009/11/02 17:27:20  zeitler
;;; took out old vsum definition
;;;
;;; Revision 1.62  2009/10/23 15:26:51  zeitler
;;; External plot functions in basic system
;;;
;;; Revision 1.61  2009/09/30 09:05:22  zeitler
;;; topk in release
;;;
;;; Revision 1.60  2009/09/29 21:16:50  zeitler
;;; topk, leastk (and bestk) added to system and tests
;;;
;;; Revision 1.59  2009/05/05 18:57:04  torer
;;; Better documentation
;;;
;;; Revision 1.58  2009/04/22 17:35:44  torer
;;; ALisp now stand-alone sub-module
;;;
;;; Revision 1.57  2009/04/01 09:55:21  torer
;;; Remove type RESOURCE
;;;
;;; Revision 1.56  2009/03/06 15:50:57  gyogi445
;;; bag.integer.integer.section->bag ==> stream.integer.integer.section->stream
;;;
;;; Revision 1.55  2008/11/25 16:38:06  torer
;;; Aggregate function
;;;   groupby(Bag of <Object gr, Object gv>, function aggop) -> Bag of <Object gr, Object agg>
;;;
;;; Revision 1.54  2008/10/31 15:19:38  zeitler
;;; Aggregate operators over bags of vectors
;;;
;;; Revision 1.53  2008/10/10 09:44:48  torer
;;; Unloader of user schema
;;;
;;; Revision 1.52  2008/10/03 15:48:53  torer
;;; Type RECORD in basic system (not in release)
;;;
;;; Revision 1.51  2008/08/13 09:33:35  torer
;;; Type STREAM not in released version
;;;
;;; Revision 1.50  2007/11/16 13:52:04  torer
;;; Vector access rewrites
;;;
;;; Revision 1.49  2007/10/24 20:19:40  torer
;;; Definition of basic Amos II system
;;;
;;; =============================================================

(load "coredef.lsp") ;; Load core system

(defun finalize-image()
  "Finalize image before saving it"
  (cond (_release_ 
	 (set-authority 3)
	 ;; Lisp debugging disallowed, source code not available
	 )))

(register-rollout-form '(finalize-image))

(defun load-amosql (file &optional loud)(parse-file file "AmosQL" loud))

(init-mapped-types)

(load "tuple.lsp")
(load "vector.lsp")
(initialize-tuple-type)
(load "amosfns.lsp") ;; System function definitions
(load "if.lsp") 
(load "tr-rewrites.lsp")

(init-mbtree)

(init-comm)

(load "temporal.lsp")
(load "tclose.lsp")
(load "iterate.lsp");
(load "topk.lsp")
(load "extplot.lsp")
(load "stream.lsp")
(load-amosql "CSV.osql") ; CSV file access
(load-amosql "functions.osql") ; System AMOSQL functions
(load-amosql "peer.osql") ; Peer functions
(load-amosql "goovi-servers.osql") ; Goovi peer functions

(load "compl.lsp")
(load-amosql "updates.osql")
(load "updates.lsp")
(load "abstract-function.lsp")
(load-amosql "constructor.osql")
;;(load "groupby.lsp")
(load "new_group_by.lsp")
(init-dt-subsystem)
(init-mdb-subsystem)
(setq _toploop-help_
"
You are in the ALisp top loop. 

:osql     return to AmosQL top loop
(quit)    quit Amos II
")
(load "record.lsp")
(load-amosql "record.osql")
(load-amosql "unloadschema.osql")
(load-amosql "RDF.osql")

