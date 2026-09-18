;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: abstract-function.lsp,v $
;;; $Revision: 1.3 $ $Date: 2010/01/20 07:27:43 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Facilitates the creation of 'abstract' functions. When it is
;;;              desired to have a function that cannot be run, but has to 
;;;              overloaded on a subtype.
;;; =============================================================
;;; $Log: abstract-function.lsp,v $
;;; Revision 1.3  2010/01/20 07:27:43  torer
;;; More informative error message for abstract functions
;;;
;;; Revision 1.2  2006/12/06 08:59:00  torer
;;; Informative error message for abstract functions
;;;
;;; =============================================================

(defun abstract-function (fno &rest args)
  "To be use when creating functions that cannot be directly run.
   for example:
     create function bark(dog d) -> charstring as foreign 'abstract-function';
     create function bark(Beagle d) -> charstring;
     create function bark(Poodle d) -> charstring;
     set bark(poodlenamed('Fido')) = 'yip yip';
     set bark(beaglenamed('Snoopy')) = 'arf arf';

     Now you can do select bark(d) from dog d;"
  (let ((real-args (ldiff args (memq '* args))))
    (amos-error 
     (function-signature fno) "
  is an abstract function requiring a more specific argument signature than
" 
     "  " (mapcar (function arg-type) real-args) " for arguments
  " (msg-argl real-args))))

(defun msg-argl (argl)
  (with-string stream (print-tuple1 "(" ")" argl stream)))  
