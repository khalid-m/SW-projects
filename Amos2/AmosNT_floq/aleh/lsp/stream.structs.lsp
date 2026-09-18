;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Ruslan Fomkin, UDBL
;;; $RCSfile: stream.structs.lsp,v $
;;; $Revision: 1.11 $ $Date: 2008/05/10 13:47:30 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;; ===========================================================================
;;; $Log: stream.structs.lsp,v $
;;; Revision 1.11  2008/05/10 13:47:30  ruslan
;;; jetb renamed in jet according the Thesis
;;;
;;; Revision 1.10  2008/05/10 13:06:49  ruslan
;;; wrapper returns only sobject without the key vector, names of wrapper functions in correspondance with the Thesis, aleh_stream is used to stream events instead of filename
;;;
;;; Revision 1.9  2008/05/09 06:52:25  ruslan
;;; more unnecessary attributes are projected away
;;;
;;; Revision 1.8  2008/03/01 15:59:43  ruslan
;;; collecting cardinality statistics on slots and using in query optimization
;;;
;;; Revision 1.7  2008/02/28 13:12:42  ruslan
;;; using sobject
;;;
;;; Revision 1.6  2007/12/17 15:54:34  ruslan
;;; types are used to store in structs. dynamic statistics collection. bug with types for structs is fixed
;;;
;;; Revision 1.5  2007/12/13 11:00:24  ruslan
;;; cost model for structs is moved to separarte file
;;;
;;; Revision 1.4  2007/12/05 09:23:14  ruslan
;;; cost model for closed dnf. cost model for get slot bag
;;;
;;; Revision 1.3  2007/11/24 08:40:36  ruslan
;;; cost model for closed dnf function is propogated from the predicate
;;;
;;; Revision 1.2  2007/11/23 11:08:09  ruslan
;;; bug in cost model of minagg2 is fixedcost_model.populated.lsp
;;;
;;; Revision 1.1  2007/11/03 14:10:56  ruslan
;;; implementation of streaming based on wrapper returning sturcts. some issues have to be done for performance and executablity
;;;
;;; ===========================================================================

;;; the type hierarchy
(createtype 'event '(sobject))
(createtype 'particle '(sobject))
(createtype 'jet '(particle))
(createtype 'lepton '(particle))
(createtype 'electron '(lepton))
(createtype 'muon '(lepton))
 
(defglobal *eventtype* (gettypenamed 'EVENT))
(defglobal *elslot* 17)
(defglobal *muslot* 18)
(defglobal *jbslot* 19)
(defglobal *elslotN* 2)
(defglobal *muslotN* 7)
(defglobal *jbslotN* 12)

(defun closednf1 (fno fn arity &rest args)
  (invoke-plan fno fn arity (car args) (cdr args)))
(defun closednf3 (fno fn arity &rest args)
  (invoke-plan fno fn arity (car args) (cadr args) (caddr args) (cdddr args)))

(osql "create function closednf(Function fn, integer arity, event e) ->
	particle as foreign 'closednf1';")
(osql "create function closednf(Function fn, integer arity, charstring f) ->
	event as foreign 'closednf1';")
(osql "create function closednf(Function fn, integer arity, charstring f, 
integer e1, integer e2) ->
	event as foreign 'closednf3';")
