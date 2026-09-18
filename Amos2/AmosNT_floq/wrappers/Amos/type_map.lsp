;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: type_map.lsp,v $
;;; $Revision: 1.3 $ $Date: 2003/09/29 14:25:57 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Provides the mapping between a remote mediator's types and
;;;              the local types.
;;;              
;;; ===========================================================================
;;; to do: This will potentially crash if we are connected to more than one 
;;;        Amos. Must hash on both typename AND node name.
(defvar *remote->local-types* (make-hash-table))

(defun insert-remote-type (remote-typename mtpo)
  (puthash remote-typename *remote->local-types* mtpo))

(defun get-local-type (amosds remote-typename &optional noerror)
  (let ((attempt (gettypenamed remote-typename 'noerror)))
    (if (and (neq attempt nil) (eq (arg-type attempt) _storedtype_))
	attempt
      (or (gethash remote-typename *remote->local-types*)
	  (if noerror nil
	    (error "no correponding mapped type found" remote-typename))))))

