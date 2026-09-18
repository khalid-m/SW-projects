;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: arginfo.lsp,v $
;;; $Revision: 1.5 $ $Date: 2008/04/03 15:00:48 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: The ADT arginfo is a detailed specification of a parameter to
;;;              any AmosQL function, containing the type of the parameter, the
;;;              name of the formal parameter and information on whether is is 
;;;              declared as 'unique' or not. arginfo:s are retrieved by 
;;;              calling get-arginfo with the function object, which returns a
;;;              a list of arginfo:s in the order they were declared, with 
;;;              input arguments preceeding output arguments.
;;;              
;;; ===========================================================================
(defstruct arginfo
  type
  name
  index)

(defun arginfo-typename (ai)
  (getobject (arginfo-type ai) 'name))

(defun arginfo-isunique (ai) (eq (arginfo-index ai) 'unique))

(defc 'arginfo-type '(lambda (ai)
		       "Redefine original ARGINFO-TYPE"
		       (let ((tpo (elt ai 1)))
			 (if (eq (arg-type tpo) _proxy_)
			     _proxy_
			   tpo))))
    
(defun get-arginfo (fn &optional peer)
  (if peer 
      (remote-eval `(get-arginfo-local (getfunctionnamed , (kwote fn))) peer)
    (get-arginfo-local fn)))

(defun get-arginfo-local (fn)
  "Creates a specification of the metadata concerning the tuple of a function.
   Each argument (input and output arguments are treated equally) gives rise to
   an arginfo structure."
  (let* ((fno (getfunctionnamed fn))
	 (sb (getselectbody fno))
	 (arg-types   (get-resolvent-argtypes fno))
	 (arg-symbols (selectbody-argl sb))
	 (res-types   (or (get-resolvent-restypes fno) (list _boolean_)))
	 (res-symbols (or (selectbody-resl sb) (list (genvar))))
	 (i 0)
	 ais)
    (dolists ((tpo arg-types) (name arg-symbols))
      (putlast ais (make-arginfo :type tpo :name name :index (get-index-type fno i)))
      (1++ i))
    (dolists ((tpo res-types) (name res-symbols))
      (putlast ais (make-arginfo :type tpo :name name :index (get-index-type fno i)))
      (++1 i))
    ais))

(defun get-index-type (fno pos)
  "Returns the index type of a 'position' in a function tuple. Returns 'unique
   'multiple, or NIL if no index exists."
  (let* ((relation (get-relation fno))
	 (all-indices (if (get-relation fno) (relation-indexes relation)))
	 (index (car (mapfilter (f/l(i)(eq(index-pos i)pos)) all-indices))))
    (if index (if (index-unique index) 'unique 'multiple))))
