;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Ruslan Fomkin, UDBL
;;; $RCSfile: structs.lsp,v $
;;; $Revision: 1.3 $ $Date: 2008/08/20 09:14:10 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;; ===========================================================================
;;; $Log: structs.lsp,v $
;;; Revision 1.3  2008/08/20 09:14:10  ruslan
;;; root wrapper returns stream, which is alias of bag
;;;
;;; Revision 1.2  2008/02/28 13:11:31  ruslan
;;; using sobject
;;;
;;; Revision 1.1  2007/11/03 10:10:10  ruslan
;;; returning structs
;;;
;;; ===========================================================================

(createliteraltype 'sobject '(literal) 'sobject nil 'sobject-type)
(set-alias-name 'STREAM 'BAG _type_)