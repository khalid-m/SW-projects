;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2006 Ruslan Fomkin, UDBL
;;; $RCSfile: stream.lsp,v $
;;; $Revision: 1.1 $ $Date: 2006/12/13 13:08:25 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Definition of type hierarchy for streaming impelmentation of ALEH with
;;; structs and foreign functions for creating and accessing structs.
;;; ===========================================================================
;;; $Log: stream.lsp,v $
;;; Revision 1.1  2006/12/13 13:08:25  ruslan
;;; stream implementation of ALEH with structs
;;;
;;; ===========================================================================

(set-type-container (getfunctionnamed 'bag.vectorof->vector))

;;; the type hierarchy
(createliteraltype 'struct '(literal) 'struct nil 'struct-type)
(createliteraltype 'event '(struct) 'struct)
;nil 		   (f/l (x) (gettypenamed 'event)))
(createliteraltype 'particle '(struct) 'struct)
;nil		   (f/l (x) (gettypenamed 'particle)))
(createliteraltype 'jetb '(particle) 'struct)
;nil		   (f/l (x) (gettypenamed 'jetb)))
(createliteraltype 'lepton '(particle) 'struct)
;nil		   (f/l (x) (gettypenamed 'lepton)))
(createliteraltype 'electron '(lepton) 'struct)
;nil		   (f/l (x) (gettypenamed 'electron)))
(createliteraltype 'muon '(lepton) 'struct)
;nil		   (f/l (x) (gettypenamed 'muon)))
 
;;; general functions to create and access structs
(defun new_structbbf (fno r cont s)
   (osql-result r cont (make-struct r cont)))
(defun get_slotbbf (fno s i o)
   (osql-result s i (struct-get s i)))
(defun struct_typebf (fno s tp)
   (osql-result s (struct-type s)))
