;;; ============================================================
;;; AMOS
;;; 
;;; Author: (c) 1995 <author>, EDSLAB
;;; $RCSfile: rules_network.lsp,v $
;;; $Revision: 1.9 $ $Date: 2005/09/14 18:38:51 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;      handles creation, deletion and update of the 
;;;      propagation network
;;;
;;; Requirements: 
;;; =============================================================
;;; $Log: rules_network.lsp,v $
;;; Revision 1.9  2005/09/14 18:38:51  torer
;;; Systematically using (RESOLVENTS fn) to get resolvents.
;;;
;;; Revision 1.8  2005/04/25 20:59:05  torer
;;; 1. Uniform tratment of TBR descriptions in TBR.lsp
;;; 2. New files TBR.lsp, DTR.lsp, and recompile.lsp for natural module names
;;; 3. Files bindpatex.lsp and dynb.lsp obsoleted
;;; 4. New Lisp code search function to find functions containing code patterns:
;;;     (matching <pattern>) e.g. (matching '(resolvents *))
;;; 5. Some code cleanup possible by MATCHING
;;;
;;; Revision 1.7  2004/12/08 18:38:06  torer
;;; 1. All Lisp code verified using (verfify-all)
;;; 2. Makefile amos.bpr now recompies bison/flex files only when needed
;;;
;;; Revision 1.6  2004/11/20 11:55:57  torer
;;; 1. Entire system code now verified.
;;; 2. Bugs fixed. Duplicate and obsolete code removed
;;; 3. Verification does no longer check for undefined functions to allow for
;;;    quiet function forward definitions
;;;
;;; Revision 1.5  2002/06/05 10:02:15  torer
;;; UNIX compatibility
;;;
;;; Revision 1.4  2001/12/27 16:24:57  torer
;;; 1. Modified ECA rules so that the net effect of events now computed correctly
;;; 2. Fixed severe memory leak in logger
;;;
;;; Revision 1.3  2001/03/30 09:56:17  timka
;;;
;;; Moved the function (maxl list-of-integers) from 'rules_network.lsp' to
;;; 'utils.lsp' as it is used in other files as well.
;;;
;;; Revision 1.2  2000/10/24 12:44:16  torer
;;; ECA rules OK
;;;
;;; Revision 1.1  2000/08/19 06:47:04  evato
;;; rules_network.lsp is also included in the rule system.
;;;
;;;

(provide 'rules_network)
;;========================================================

(defglobal _addnet_ (new-event '/add-net 'rem-net nil))
(defglobal _remnet_ (new-event '/rem-net 'add-net nil))
(defglobal _setnode_ (new-event '/set-node 'set-node nil))

(defglobal _addupwardlink_ (new-event '/add-upward-link 'add-upward-link nil))
(defglobal _remupwardlink_ (new-event '/rem-upward-link 'rem-upward-link nil))

(defglobal _adddownwardlink_ 
  (new-event '/add-downward-link 'add-downward-link nil))
(defglobal _remdownwardlink_ 
  (new-event '/rem-downward-link 'rem-downward-link nil))

;;========================================================

;; create-network
;;
;; creates a new propagation network
;; arguments:
;; none
;; return value:
;; a network object
(defun create-network()
  (let ((o (/createobject 'userobject))) ; the external representation
    (/putobject o 'network  (list '*))      ; (* level0 level1 ...)
    o))
;;========================================================
;; internalize-network
;;
;; macro that fetches the actual network structure of a 
;; network object
;; arguments:
;; a network object
;; return value:
;; a network structure
(defmacro internalize-network (o)
  `(getobject , o 'network))

;;========================================================
;; level-existsp
;;
;; checks if a certain level exists in the network
;; arguments:
;; 'level' is the level number
;; 'network' is the network object
(defun level-existp (level network)
  (let ((net (internalize-network network)))
    (nth level (cdr net))))

;;========================================================
;; add-net
;;
;; destructively adds a node to a network
;; arguments:
;; 'network' is the network to be modified
;; 'level' is the level in the network to be modified
;; 'node' is the node to be added
;; 'addflg' specifies if a level should be added or not
;; return value:
;; none
(defun add-net (network level node addflg)
  (let* ((net (internalize-network network)))
    (if addflg
	(insert-level (list (internalize-node node)) level net)
      (if (nth (1+ level) net)
	  (modify-level (cons (internalize-node node) 
			      (nth (1+ level) net)) level net)))))

;;========================================================
;; /add-net
;;
;; the transactional version of add-net
;; arguments:
;; 'network' is the network to be modified
;; 'level' is the level in the network to be modified
;; 'node' is the node to be added
;; 'addflg' specifies if a level should be added or not
;; return value:
;; none
(defun /add-net (network level node addflg)
  (history-add _addnet_ network level node addflg)
  (add-net network level node addflg))

;;========================================================
;; rem-net
;;
;; destructively removes a node from a network
;; arguments:
;; 'network' is the network to be modified
;; 'level' is the level in the network to be modified
;; 'node' is the node to be removed
;; return value:
;; none
(defun rem-net (network level node)
  (let* ((net (internalize-network network))
	 (l (delete (internalize-node node) (nth (1+ level) net)))) 
    (if l (modify-level l level net)
      (remove-level level net))))

;;========================================================
;; /rem-net
;;
;; the transactional version of rem-net
;; arguments:
;; 'network' is the network to be modified
;; 'level' is the level in the network to be modified
;; 'node' is the node to be removed
;; return value:
;; none
(defun /rem-net (network level node)
  (let ((l (delete (internalize-node node) (nth (1+ level) (internalize-network network))))) 
    (if l
	(history-add _remnet_ network level node nil)
      (history-add _remnet_ network level node t)) ; level will be put back
    (rem-net network level node)))

;;========================================================
;; print-network
;;
;; pretty prints a network
;; arguments:
;; 'network' is the network to be printed
;; return value:
;; none
(defun print-network (network)
   (resetvar _deep-print_ nil
     (let* ((net (internalize-network network))
            (num 0))
        (dolist (level (cdr net))
           (print (pack "*** level " num " ***"))
           (setq num (1+ num))
           (dolist (node level)
              (print-node node))))))

(defstruct node object data next previous)


;;========================================================
;; make-node
;;
;; creates a new node object consisting of
;; a node structure
;; arguments:
;; none
;; return value:
;; the created node object
;;(defun make-node ()                        ; hide the original make-node
(defun make-rule-node ()                    ; This may be a mistake!
  (let ((n (makefn-node nil nil nil nil))       ; the internal representation
	(o (/createobject 'userobject))) ; the external representation
    (setf (node-object n) o)          
    (/putobject o 'node n)                  
    o))

;;========================================================
;; internalize-node
;;
;; macro that fetches the node structure
;; from a node object
;; arguments:
;; 'o' is a node object
;; return value:
;; a node structure
(defmacro internalize-node (o)
  `(getobject , o 'node))

;;========================================================
;; externalize-node
;;
;; macro that fetches the node object
;; associated with a node structure
;; arguments:
;; 'node' is a node structure
;; return value:
;; a node object
(defmacro externalize-node (node)
  `(node-object , node))

;;========================================================
;; print-node
;;
;; prints a node
;; arguments:
;; 'n' is a node structure or on externalized node structure

(defun print-node (n)
   (if (oid-p n)(setq n (internalize-node n)))
   (resetvar _deep-print_ nil 
     (formatl t "Node " n ": ") (nprint n 2)
     (formatl t "Event function: " (event-function-of-node n) t) 
     (princ "Node data: ") (nprint (node-data n) 2)
     (cond ((node-previous n)
            (princ "Node downward links: ")
            (nprint (node-previous n) 2)))
     (cond ((node-next n)
            (princ "Node upward links: ")
            (nprint (node-next n) 2)))))

(defun event-function-of-node (n)
   (getobject (get-delta-added (get-node-delta-set (externalize-node n)))
     'complete-function))


(defvar *indent* 0)

;;========================================================
;; nprint
;;
;; pretty prints indented data
;; arguments:
;; 'data' to be printed
;; 'level' level of indention
;; return value:
;; none
(defun nprint (data level)
  (let ((old-indent *indent*))
    (terpri)
    (dotimes (n level) 
      (princ " "))
    (setq *indent* level)
    (pps (if (arrayp data) (arraytolist data) data))
    (setq *indent* old-indent)))

;;========================================================
;; set-node
;;
;; destructively changes the data of a node
;; arguments:
;; 'o' the node object
;; 'data' to be inserted
;; return value:
;; none
(defun set-node (o data)
  (setf (node-data (internalize-node o)) data))

;;========================================================
;; /set-node
;;
;; the transactional version of set-node
;; arguments:
;; 'o' the node object
;; 'data' to be inserted
;; return value:
;; none
(defun /set-node (o data)
  (history-add _setnode_ o 
	       (node-data (internalize-node o)) data) ; log old state
  (set-node o data))


(defun get-node-data (o)
  (node-data (internalize-node o)))

;;========================================================
;; add-upward-link
;;
;; destructively adds a node to the list of upward links
;; arguments:
;; 'o1' the node object to be modified
;; 'o2' the node object in the upward link
;; return value:
;; none
(defun add-upward-link (o1 o2)
  (let ((to (internalize-node o1))
	(node (internalize-node o2)))
    (if (not (memq node (node-next to))); 
	(setf (node-next to) (append (node-next to) (list node))))))

;;========================================================
;; /add-upward-link
;;
;; the transactional version of add-upward-link
;; arguments:
;; 'o1' the node object to be modified
;; 'o2' the node object in the upward link
;; return value:
;; none
(defun /add-upward-link (o1 o2)
  (history-add _addupwardlink_ o1 o2)
  (add-upward-link o1 o2))

;;========================================================
;; rem-upward-link
;;
;; destructively removes a node from the list of upward links
;; arguments:
;; 'o1' the node object to be modified
;; 'o2' the node object in the upward link
;; return value:
;; none
(defun rem-upward-link (o1 o2)
  (let ((from (internalize-node o1))
	(node (internalize-node o2)))  
    (setf (node-next from) (delete node (node-next from)))))

;;========================================================
;; /rem-upward-link
;;
;; the transactional version of rem-upward-link
;; arguments:
;; 'o1' the node object to be modified
;; 'o2' the node object in the upward link
;; return value:
;; none
(defun /rem-upward-link (o1 o2)
  (history-add _remupwardlink_ o1 o2)
  (rem-upward-link o1 o2))


;;========================================================
;; add-downward-link
;;
;; destructively adds a node to the list of downward links
;; arguments:
;; 'o1' the node object to be modified
;; 'o2' the node object in the downward link
;; 'data' is data associated with the link
;; return value:
;; none

(defun add-downward-link (o1 o2 data)
  (let* ((to (internalize-node o1))
	 (node (internalize-node o2))
	 (link (assq node (node-previous to))))

    ;;(link (assoc (arraytolist-rec to)(arraytolist-rec node))))
    ;; This may not be the correct solution, but at least it removes the
    ;; circularity in the list!

    (if link				; link already exist, append data 
	(progn
	  (rem-downward-link o1 o2 nil)
	  (setf (node-previous to) 
		(append (node-previous to)
			(list (cons node (append (cdr link) data))))))
					; Otherwise:
      (setf (node-previous to) (append (node-previous to) 
				       (list (cons node (list data))))))))

;; arraytolist-rec
;;
;; Recursively changes all arrays in a list or array to lists.
;; The argument any-list can be either a list or an array.

(defun arraytolist-rec (any-list)
  "Converts all array elements in a list to lists."

  (let (new-list)

    (cond
     ((arrayp any-list) (arraytolist-rec (arraytolist any-list)))
     ((member t (mapcar #'(lambda(x) (cond ((arrayp x) t) (t nil))) any-list))

      (dolist (i any-list)
	(cond ((arrayp i)  
	       (setq new-list (append new-list (list (arraytolist i)))))
	      (t
	       (setq new-list (append new-list (list i))))))
      (arraytolist-rec new-list))
     ((atom any-list) any-list)
     
     (t (mapcar #'(lambda(x) (arraytolist-rec x)) any-list)))))


;;========================================================
;; /add-downward-link
;;
;; the transactional version of add-downward-link
;; arguments:
;; 'o1' the node object to be modified
;; 'o2' the node object in the downward link
;; return value:
;; none
(defun /add-downward-link (o1 o2 data)
  (history-add _adddownwardlink_ o1 o2 data)
  (add-downward-link o1 o2 data))

;;========================================================
;; rem-downward-link
;;
;; destructively removes a node from the list of downward links
;; arguments:
;; 'o1' the node object to be modified
;; 'o2' the node object in the downward link
;; 'data' link data, used for rollback purposes
;; return value:
;; none
(defun rem-downward-link (o1 o2 data)
  (let* ((from (internalize-node o1))
	 (node (internalize-node o2))
	 (link (assq node (node-previous from))))
    (if link
	(setf (node-previous from) (delete link (node-previous from))))))

;;========================================================
;; /rem-downward-link
;;
;; the transactional version of rem-downward-link
;; arguments:
;; 'o1' the node object to be modified
;; 'o2' the node object in the downward link
;; return value:
;; none
(defun /rem-downward-link (o1 o2)
  (history-add _remdownwardlink_ o1 o2)
  (rem-downward-link o1 o2 (assoc (internalize-node o2) ; the old value
				  (node-previous (internalize-node o1)))))

;;========================================================
;; insert-level
;;
;; insert data in a specific position in a list by creating a new level
;; arguments:
;; 'data' the data to be inserted
;; 'level' the level to create and in which to put the data
;; 'lst" the list to be modified
;; return value:
;; none
(defun insert-level (data level lst) ; insert data in position pos+1 in lst
   (if (= level 0)
       (rplacd lst (cons data (cdr lst)))
     (insert-level data (1- level) (cdr lst))))

;;========================================================
;; modify-data
;;
;; modifies a position in a list by appending a present level
;; arguments:
;; 'data' the data to be inserted
;; 'level' the level in which to put the data
;; 'lst' the list to modify
;; return value:
;; none
(defun modify-level (data level lst) ; modify position pos+1 in lst to data
  (if (= level 0)
      (rplaca (cdr lst) data)
    (modify-level data (1- level) (cdr lst))))

;;========================================================
;; remove-level
;;
;; remove a level from a list
;; arguments:
;; 'level' the level to remove
;; 'lst' the list to modify
;; return value:
;; none
(defun remove-level (level lst)
  (if (= level 0)
      (rplacd lst (cddr lst))
    (remove-level (1- level) (cdr lst))))


;;========================================================
;; insert-into-network
;;
;; insert a rule activation into a network
;; arguments:
;; 'rule' is the rule to be inserted
;; 'argl' is the actual argument list of the rule
;; 'network' is a propagation network
;; return value:
;; none
(defun insert-into-network (rule activations network)

  (let* ((evtfn (getobject rule 'event-function))
	 (node (getobject evtfn 'network-node)))

    (if (get-node-activation node)
	(set-node-activation node evtfn activations)
      (let* (
	     (com-funs (get-monitored-functions-called-by evtfn))
	     (level 
	      (mapcar 
	       (f/l (fun) 
		    (let* ((dw-link (getobject fun 'network-node)))

		      (/add-upward-link dw-link node)
		      (/add-downward-link node dw-link nil)
		      (let* 
			  ((lev 
			    (if (get-used-functions fun)
				(+ 1 (maxl (insert-nodes fun dw-link network)))
				  0))
			   (addflg (if (level-existp lev network) nil t)))
			(set-node-level dw-link lev)

			(if (not (node-existp dw-link network)) 
			    (/add-net network lev dw-link addflg))
			lev)))
	       com-funs))

	     (mlevel (+ 1 (maxl level)))
	     (addflg (if (level-existp mlevel network) nil t))
	     (top-level (getobject network 'top-level)))

	(set-node-activation node evtfn activations)

	(if (> mlevel top-level)
	    (progn (set-node-level node mlevel)
		   (/add-net network mlevel node addflg)
		   (/putobject network 'top-level mlevel) 
		   (shift-nodes-up network))
	  (progn (set-node-level node top-level)
		 (/add-net network top-level node nil)))))))

(defun get-monitored-functions-called-by (evtfn)
  (let (res)
    (dolist (fno (oids-in (selectbody-pred (getselectbody evtfn)) _function_))
	    (let ((cf (getobject fno 'complete-function)))
	      (if cf (setq res (adjoin cf res)))))
    res))


;;======================================================
;; insert-nodes
;;
;; inserts a function into a propagation network
;; arguments:
;; 'osqlfn' is the function to be inserted
;; 'activation' is the rule activation
;; 'network' is the propagation network
;; return value:
;; the network level number where the function was inserted
(defun insert-nodes (resolvent node net)
  (let* ((usedfunctions (get-used-functions resolvent)))
    (mapcar (f/l (fun) 
		 (let* ((dw-link (getobject fun 'network-node)))
		   (/add-upward-link dw-link node)
		   (/add-downward-link node dw-link nil)
		   (if (get-used-functions fun)
		       (let* 
			   ((level (+ 1 (maxl (insert-nodes fun dw-link net))))
			    (addflg (if (level-existp level net)  nil t)))
			 (set-node-level dw-link level)
			 (if (not (node-existp dw-link net))
			     (/add-net net level dw-link addflg))
			 level)
		     (let* ((level 0)
			    (addflg (if (level-existp level net) nil t)))
		       (set-node-level dw-link level)
		       (if (not (node-existp dw-link net))
			   (/add-net net level dw-link addflg))
		       level))))
	    usedfunctions)))

;;========================================================
;; remove-from-network
;;
;; removes a rule activation from a network
;; arguments:
;; 'rule' is the rule to be inserted
;; 'argl' is the actual argument list of the rule
;; 'network' is a propagation network
;; return value:
;; none
(defun remove-from-network (rule activations network)
  (let* ((evtfn (getobject rule 'event-function))
	 (cndfn (getobject rule 'condition-function))
	 (trigfn (if evtfn evtfn cndfn))
	 (resolvent (car (resolvents trigfn)))
	 (node (getobject resolvent 'network-node)))
    (if activations
	(set-node-activation node trigfn activations)
      (progn
	(remove-nodes network node)
	(shift-nodes-down network)))))

(defun remove-nodes (net node)
   (let* ((dependencies (mapcar (function car) 
                          (node-previous (internalize-node node)))))
      (/rem-net net (get-node-level node) node)
      (clear-node (internalize-node node))
      (mapc (f/l (n) (progn (/rem-upward-link (externalize-node n) node)
                       (if (null (node-next n)) 
                          (remove-nodes net (externalize-node n)))))
        dependencies)))


;;======================================================
;;shift-nodes-up 
;;
;;updates the topology of the network by moving the event-functions nodes 
;;to the top level of the network
;;Arguments:
;;network
;;Return
;;none
(defun  shift-nodes-up (network)
  (let* ((net (cdr (internalize-network network)))
	 (top-level (getobject network 'top-level)))
    (mapc (f/l (layer)
		 (mapc (f/l (n)
			      (let* ((n-ext (externalize-node n))
				     (n-level (get-node-level n-ext)))
				(if (and (null (node-next n)) (< n-level top-level))
				    (progn 
				      (/rem-net network n-level n-ext)
				      (set-node-level n-ext top-level)
				      (/add-net network top-level n-ext nil)))))
			 layer))
	    net)))

;;======================================================
;;shift-nodes-down
;;
;;updates the topology of the network by deleting the empty levels and updating
;;the top level.
;;Arguments:
;;network
;;Return
;;none
(defun  shift-nodes-down (network)
  (let* ((net (cdr (internalize-network network)))
	 (c-level 0))
    (mapc (f/l (layer)
		 (progn 
		   (if (> (get-node-level (externalize-node (car layer))) c-level)
		       (mapcar (f/l (n)
				    (let* ((n-ext (externalize-node n)))
				      (set-node-level n-ext c-level)))
			       layer))
		   (setq c-level (+ 1 c-level))))
	    net)
    (/putobject network 'top-level (if (eq c-level 0) 0 (- c-level 1)))))


;;======================================================
;; propagate
;;
;; propagates the network through a bottom-up, breadth-first algorithm
;; arguments:
;; 'network' is the network to propagate
;; return value:
;; none
(defun propagate (network) 
   ;;mark all changed nodes in the network first 
   (debug_do (formatl t t "Progagating network:" t) (print-network network))
   (dolist (layer (cdr (internalize-network network)))
      ;; check if the layer is changed
      (progn ;(print layer) 
        (mark-layer-changed layer))
      )
   ;;propagate data in the network starting from level 1
   (dolist (layer (cdr (butlast (internalize-network network))))
      ;; check if the layer is changed
      (progn ;(print layer) 
        (propagate-layer layer))
      ;; clear layer
      ))

(defun mark-layer-changed (layer)  
  (dolist (node  layer)
	  (mark-node-changed node)))

(defun mark-node-changed (node)
  (let ((n (externalize-node node)))
    (if (get-node-change-flag n)
	(let ((links (mapcar (f/l (link) (externalize-node link))
			     (node-next node))))
	  ;(print links)
	  (dolist (link links)
		  (progn
		    (set-node-change-flag link t)
		    (set-node-count link (+ (get-node-count link) 1))))))))

(defmacro propagate-layer (layer)
  `(dolist (node , layer)
	   (propagate-node node)))

(defun propagate-node (node)
   (let* ((n (externalize-node node)))
      (if (get-node-change-flag n)
         (let* ((delta-set (get-node-delta-set n))
                (links (mapcar (f/l (link) (externalize-node (car link)))
                         (node-previous node)))
                (deltasets (mapcar (f/l (n-prev) 
                                     (progn
                                       (set-node-change-flag n-prev nil) 
                                       (get-node-delta-set n-prev))) links)))
            (set-node-change-flag n nil)
            (if deltasets 
               (compute-deltas delta-set deltasets))))))
 

;;======================================================
;;compute-deltas
;;
;;computes delta-sets for derived functions
;;
;;Arguments
;;ds : delta-set to be computed
;;deltasets: downward deltaset links of ds 
;;Return
;;none
(defun compute-deltas (ds deltasets) 
  (let* ((delta-added (get-delta-added ds))
	 (delta-removed (get-delta-removed ds))
	 (fn (getobject delta-added 'complete-function))
	 (pat1 (get-pattern fn nil))
	 (pat2 (get-pattern fn t)))
    (mapc 
     (f/l 
      (dset) 
      (let* ((ds+ (get-delta-added dset))
	     (ds- (get-delta-removed dset))
	     (fno (getobject ds+ 'complete-function)) 
	     old- old+ old-+)
	(maprelation ds+ pat1 
		     (f/l (&rest x) (setq old+ (append old+ (list x)))))
	(maprelation ds- pat1 
		     (f/l (&rest x) (setq old- (append old- (list x)))))
	(if old+ (mapc (f/l (arg) 
			    (mapfunction 
			     fn (list (second arg))
			     (f/l (amos_x) 
                                  (/assertrelation 
				   delta-added 
				   (append (butlast arg) amos_x)))))
		       old+))
	(if old- (mapc (f/l (arg)
			    (mapfunction 
			     fn (list (second arg)) 
			     (f/l (amos_x)
                                  (/assertrelation 
				   delta-removed 
				   (append (butlast arg) amos_x)))))
		       old-))))
     deltasets)))

;;======================================================
;; get-pattern
;;
;;gets the pattern of a given function
;;Arguments:
;;fn function
;;double: boolean (t: pattren is doubled)
;;Return:
;; ret pattern of fno as a list of '*
(defun get-pattern (fn double)
  (let* ((l (if double 
		(+ (getarity fn) (* 2 (getwidth fn)))
	      (+ (getarity fn) (getwidth fn))))
	 (ret '(*)))
    (dotimes (i l) (setq ret (cons '* ret)))
    ret))
 
;;======================================================
;; changed-nodep
;;
;; predicate that checks if a node in the propagation network
;; has changed
;; arguments:
;; 'node' is the node to be checked
;; return value:
;; 'true' if the node is changed, otherwise nil
(defmacro changed-nodep (node)
  `(aref (node-data , node) 0))


;;======================================================
;; propagatep
;;
;; predicate that checks if a node in the propagation network
;; has changed
;; arguments:
;; 'node' is the node to be checked
;; return value:
;; 'true' if the node is changed, otherwise nil
;(defmacro propagatep (node)
;  `(> (aref (node-data , node) 1) 0))


;;======================================================
;; clear-node
;;
;; clears the the change flag and the count of a node
;; arguments:
;; 'node' is the node to be cleared
;; return value:
;; none
(defmacro clear-node (node)
  `(progn (setf (aref (node-data , node) 0) nil)
	  (setf (aref (node-data , node) 1) 0)
	  (setf (aref (node-data , node) 2) nil)
	  (setf (aref (node-data , node) 4) nil)))



;;======================================================
;; clear-top-nodes
;;
;; clears the the change flags of the top level nodes
(defun clear-top-nodes (net chg cnt)
  (let* ((trigfn-nodes (get-top-nodes net)))
    (if (not (equal trigfn-nodes '*)) 
	(mapcar (f/l (n) (progn
			   (if chg (setf (aref (node-data n) 0) nil))
			   (if cnt (setf (aref (node-data n) 1) 0))))
		trigfn-nodes))))
		 
;;======================================================
;; node-existp
;;
;; predicate that checks if a node is already in the propagation network
;; arguments:
;; node
;; network
;; return value:
;; boolean
(defun node-existp (node network)
  (let* ((nint (internalize-node node))
	 (netint (cdr (internalize-network network))) 
	 ret)
    (dolist (layer netint) 
	    (dolist (n layer) (if (eq n nint) (setq ret t))))
    ret))

;;======================================================
;; set-network-level
;;
;; associates a network level with a function
;; arguments:
;; 'fno' is the (condition) function
;; 'level' is the level number
;; return value:
;; none
(defun set-network-level (fno level)
  (/putobject fno 'network-level level))


;;======================================================
;; get-network-level
;;
;; fetches the network level associated with a function
;; arguments:
;; 'fno' is the (condition) function
;; return value:
;; the level number
(defun get-network-level (fno)
  (getobject fno 'network-level))

;;======================================================
;; set-network-node
;;
;; associates a network node with a function
;; arguments:
;; 'fno' is the (condition) function
;; 'node' is the network node
;; return value:
;; none
(defun set-network-node (fno node)
  (/putobject fno 'network-node node))

;;======================================================
;; get-network-node
;;
;; fetches a network node associated with a function
;; arguments:
;; 'fno' is the (condition) function
;; return value:
;; the network node
(defun get-network-node (fno)
  (getobject fno 'network-node))


;;======================================================
;; create-node
;;
;; creates a new node with an empty data field

(defun create-node()
;;  (let* ((node (make-node))
  (let* ((node (make-rule-node))  ; This may be a mistake!
	 (vec (make-array 5)))
    (/set-node node vec)
    (set-node-count node 0)
    node))

;;======================================================
;; set-node-fun
;;
;; creates a new node with an empty data field

(defun set-node-fun(node fn)
  (let ((n (internalize-node node)))
    (setf (aref (node-data n) 3) fn)))

;;======================================================
;; set-node-activation
;;
;; creates a new node with an empty data field

(defun set-node-activation(node fn activation)

  (let ((n (internalize-node node)))
    (setf (aref (node-data n) 4) (list fn activation))))

;;======================================================
;; get-node-change-flag

(defun get-node-change-flag (node)
  (let ((n (internalize-node node)))
    (aref (node-data n) 0)))

;;======================================================
;; get-node-count
(defun get-node-count (node)
 (let ((n (internalize-node node)))
    (aref (node-data n) 1)))

;;======================================================
;; get-node-level
(defun get-node-level (node)
  (let ((n (internalize-node node)))
    (aref (node-data n) 2)))


;;======================================================
;; get-node-delta-set
(defun get-node-delta-set (node)
  (let ((n (internalize-node node)))
    (aref (node-data n) 3)))

;;======================================================
;; get-node-activation
(defun get-node-activation (node)
  (let ((n (internalize-node node)))
    (aref (node-data n) 4)))


;;======================================================
;; get-node-fun
(defun get-node-fun (node)
  (let ((n (internalize-node node)))
    (aref (node-data n) 3)))

;;======================================================
;; set-node-change-flag
(defmacro set-node-change-flag(node flg)
    `(setf (aref (node-data (internalize-node , node)) 0) , flg))

;;======================================================
;; set-node-count
(defun set-node-count (node cnt)
 (let ((n (internalize-node node)))
    (setf (aref (node-data n) 1) cnt)))

;;======================================================
;; set-node-level
(defun set-node-level(node lev)
  (let ((n (internalize-node node)))
    (setf (aref (node-data n) 2) lev)))

;;======================================================
;; set-node-delta-set
(defun set-node-delta-set (node ds)
  (let ((n (internalize-node node)))
    (setf (aref (node-data n) 3) ds)))


;;======================================================
;; get-top-nodes 
;; returns all the nodes in the top level of the network
;;
;;
(defun get-top-nodes (network)
  (car (last (internalize-network network))))
