;;; ============================================================
;;; AMOS
;;; 
;;; Author: (c) 1995 Martin Sköld, EDSLAB
;;; $RCSfile: delta_sets.lsp,v $
;;; $Revision: 1.8 $ $Date: 2009/04/10 15:12:55 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;         Handels delta-sets: creates, deletes and clears 
;;;         delta-sets
;;; Requirements: 
;;; =============================================================
;;; $Log: delta_sets.lsp,v $
;;; Revision 1.8  2009/04/10 15:12:55  torer
;;; Retagging time
;;;
;;; Revision 1.7  2009/03/29 13:34:43  torer
;;; Wrong call to HELP
;;;
;;; Revision 1.6  2006/04/08 14:19:39  torer
;;; (GET-OC FNO) always used as accessor function for OID property ORGCODE
;;;
;;; Revision 1.5  2004/12/08 18:38:05  torer
;;; 1. All Lisp code verified using (verfify-all)
;;; 2. Makefile amos.bpr now recompies bison/flex files only when needed
;;;
;;; Revision 1.4  2002/12/12 21:02:32  torer
;;; Change needed in addindex0: Indexes are not always MBTREE!
;;;
;;; Revision 1.3  2001/12/27 16:24:56  torer
;;; 1. Modified ECA rules so that the net effect of events now computed correctly
;;; 2. Fixed severe memory leak in logger
;;;
;;; Revision 1.2  2000/10/24 12:44:14  torer
;;; ECA rules OK
;;;
;;; Revision 1.1  2000/08/11 16:18:38  evato
;;; New files for ECA rule execution. Some are probably superfluous if CA rules
;;; are excluded, and then they should be removed later.
;;;
;; Revision 2.0  1997/10/29  16:46:00  vanja
;; Derived types support added
;;
;; Revision 1.1  1996/12/05  14:27:13  marsk
;; Added ECA-rule package that can be loaded on demand.
;; Deleted event manager (rewritten in C).
;;
;;;

(provide 'delta_sets)
;=====================================================================================
;; create-delta-set
;;
;; creates the delta set of a function
;; arguments:
;; fno is the function object
;; resolvent: resolvent of fno
;; return:
;; the delta set
(defun create-delta-set (fno resolvent) 
  (let* ((name (generic-fnname (oid-name fno)))
	 (orgcode (let ((oc (if resolvent (get-oc resolvent))))
		    (if oc oc
		      (get-oc (generic-function-of fno)
				 ))))
	 (argl (add-nonkey (append (list (list (gettypenamed 'timeval) 
					       '_ts)) ;fnoargl)))
				   (car orgcode))))
         (arglvars (getvars argl))
	 (resl (append (add-nonkey (cadr orgcode))))
         (reslvars (getvars resl))
	 (dset (cond 
		((and resolvent (getobject resolvent 'delta-set))
		 (getobject resolvent 'delta-set))
		((and (null resolvent) (getobject fno 'delta-sets)) 
		 (car (getobject fno 'delta-sets)))
		(t  (let* ((dso+  (createfunction (pack name '_ADDED) 
						  argl resl))
                           (ds+ (get-predicate dso+ nil))
			   (dso-(createfunction (pack name '_REMOVED) 
						argl resl))
                           (ds- (get-predicate dso- nil))
			   (dso-+ (createfunction 
				   (pack name '_UPDATED) 
				   argl resl reslvars nil
				   (list 'or (list '= (cons dso+ arglvars) 
						   (maketuple reslvars))
					 (list '= (cons dso- arglvars)
					       (maketuple reslvars)))))
			   (ds (vector ds+ ds- 
				       'no-delta-set-update-function-available 
				       dso+ dso-
				       dso-+))
			   (node (create-node)))
                      (addindex0 ds+ 1 _default-indextype_ nil nil)
                      (addindex0 ds- 1 _default-indextype_ nil nil)
		      (/putobject ds+ 'complete-function resolvent)
		      (/putobject ds- 'complete-function resolvent)
		      (/putobject resolvent 'delta-set ds)
		      (/putobject fno 'delta-sets 
				  (append (getobject fno 'delta-sets) 
					  (list ds)))
		      (/putobject resolvent 'network-node node)
		      (set-node-delta-set node ds)
		      ds)))))
    dset))

;=====================================================================================
;; create-delta-sets
;;
;;create delta-sets for all the underlying functions of a given function
;;Arguments:
;;fno function
;;resolvent : resolvent of the function
;;Return:
(defun create-delta-sets (fno resolvent)
   (let* ((usedfunctions (get-used-functions resolvent)))
      (mapc (f/l (fun-reso) (if (null (get-delta-set fun-reso))
                               (let ((fun-com (generic-function-of fun-reso)))
                                  (if (get-used-functions fun-reso) 
                                     (create-delta-sets fun-com fun-reso))
                                  (if (not (get-delta-set fun-reso))
                                     (create-delta-set fun-com fun-reso)))))
        usedfunctions)
      (create-delta-set fno resolvent)))

;=====================================================================================
;; get-delta-sets
;;
;; returns the set of deltas associated with a function
;; arguments:
;; fno is the function object
;; return:
;; the list of delta relations

(defun get-delta-sets (fno)
  (and (oid-p fno)
       (getobject fno 'delta-sets)))

(defmacro get-delta-set (fno)
   (list 'getobject fno ''delta-set))
;  (and (oid-p fno)
;       (getobject fno 'delta-set)))

(defmacro get-delta-added (delta-set)
    `(aref , delta-set 0))

(defmacro get-delta-removed (delta-set)    
  `(aref , delta-set 1))

(defmacro get-delta-updated (delta-set)
  `(aref , delta-set 2))

(defmacro get-delta-addedfn (delta-set)
  `(aref , delta-set 3))

(defmacro get-delta-removedfn (delta-set)
  `(aref , delta-set 4))

(defmacro get-delta-updatedfn (delta-set)
  `(aref , delta-set 5))

;=====================================================================================
;; clear-delta-sets
;;
;; clears the delta-sets used by the actived rules
;; of a delta set
;; arguments:
;; network
;; return value:
;; none

(defun clear-delta-sets (network)
   (mapc
     (f/l (layer) (mapc 
                    (f/l (node)
                      (let* ((deltaset (get-node-delta-set (externalize-node node)))
                             (p_delta-added (get-delta-added deltaset))
                             (p_delta-removed (get-delta-removed deltaset)))
                         (droprelation p_delta-added)
                         (droprelation p_delta-removed)))
                    layer))
     (cdr (internalize-network network))))





