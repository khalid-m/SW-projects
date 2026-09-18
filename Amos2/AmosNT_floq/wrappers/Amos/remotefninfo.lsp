;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: remotefninfo.lsp,v $
;;; $Revision: 1.4 $ $Date: 2003/10/20 09:56:38 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Retrieves information about a function on another Amos node,
;;;              returned as a remotefninfo struct.
;;;              
;;; ===========================================================================
(defstruct remotefninfo
  kind; 'stored, 'derived, or 'foreign
  name
  genname
  inarity
  outarity
  typesignature
  )

; public functions

(defun remotefninfo-restypes (rfni)
  (let ((inarity (remotefninfo-inarity rfni))
	(typesig (remotefninfo-typesignature rfni)))
  (nthcdr inarity typesig)))

(defun get-remotefninfos-for-type (amosds typename &optional constraint)
  "Returns a list of remotefninfo structs that act upon the type named typename.
   constraint can be
     'first-argument only the functions that take the type as the first 
                     argument are considered
     'any-argument only the functions where the type appears as an argument 
                   are considered
   otherwise all functions where the type is either argument or result are 
   returned."
  (get-remotefninfos-request (oid-name amosds) typename constraint))

; private functions, not commented

(defun get-remotefninfos-request (peer typename &optional constraint)
  (remote-eval
   `(get-remotefninfos-response , (kwote typename) , (kwote constraint))
   peer))

(defun get-remotefninfos-response (typename &optional constraint)
  (let* ((tpo    (gettypenamed typename))
	 (allfns (allfunctionsfortype tpo)))
    (case constraint ; of
      (first-argument ; then return
       (mapfilter (f/l (fno) (eq (first (get-resolvent-argtypes fno)) tpo)) 
		  allfns
		  (function make-remotefninfo-for-function)))
      (any-argument  ; then return
       (mapfilter (f/l (fno) (memq tpo (get-resolvent-argtypes fno)))
		  allfns
		  (function make-remotefninfo-for-function)))
      (otherwise ; then return
       (mapcar (function make-remotefninfo-for-function) allfns)))))

(defun make-remotefninfo-for-function (fno)
  (let ((argtypes (mapcar #'oid-name (get-resolvent-argtypes fno)))
	(restypes (mapcar #'oid-name (get-resolvent-restypes fno))))
    (make-remotefninfo :kind (mksymbol (functiontype fno))
		       :name     (oid-name fno)
		       :genname  (generic-fnname fno)
		       :inarity  (length argtypes)
		       :outarity (length restypes)
		       :typesignature (append argtypes restypes))))
