;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Ruslan Fomkin, UDBL
;;; $RCSfile: grouping.algorithm.stream.lsp,v $
;;; $Revision: 1.2 $ $Date: 2008/04/14 15:02:30 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Generates groups for stream approach. 
;;; ===========================================================================
;;; $Log: grouping.algorithm.stream.lsp,v $
;;; Revision 1.2  2008/04/14 15:02:30  ruslan
;;; generalization of grouping algorithm to handle list of wrapping functions
;;;
;;; Revision 1.1  2007/11/07 12:19:54  ruslan
;;; grouping algorithm is separated and improved
;;;
;;; ===========================================================================

(load "../lsp/grouping.lsp")

; used in grouping algorithm to exclude event variable (join variable)
(defglobal *group_variabletype* (gettypenamed 'EVENT))
; used in grouping algorithm to find, which group accessing wrapper
(defglobal *wrapper-fn* 
  (list 
   (getfunctionnamed 
    'CHARSTRING.CHARSTRING.CHARSTRING.VECTOR.ROOT_ACCESS_PROJECT->VECTOR.VECTOR)))

; The structure to store all information about created group
(defstruct group pred groupv localv argv resv iswrap) 

(defun type-of-variable (var sb)
  "For the given variable findes its type in one of the variable lists of the
given selectbody"
  (let (type)
    (cond
     ((setq type (do ((vs (selectbody-argl sb))(ts (selectbody-argt sb))) 
		     ((null vs))
		   (cond ((equal var (car vs))
			  (return (car ts)))
			 (t 
			  (setq vs (cdr vs))(setq ts (cdr ts))))))
      type)
     ((setq type (do ((vs (selectbody-resl sb))(ts (selectbody-rest sb))) 
		     ((null vs))
		   (cond ((equal var (car vs))
			  (if ts
			      (return (car ts))
			    (return (gettypenamed 'BOOLEAN))))
			 (t 
			  (setq vs (cdr vs))(setq ts (cdr ts))))))
      type)
     ((setq type (do ((vs (selectbody-locals sb))(ts (selectbody-loct sb))) 
		     ((null vs))
		   (cond ((equal var (car vs))
			  (return (car ts)))
			 (t 
			  (setq vs (cdr vs))(setq ts (cdr ts))))))
      type)
     (t (error 
	 "Variable expected to be in some variable list of select body" 
	 var)))))
		  
(defun variablelist (variables var- sb group)
  "For the given list of arguments of a predicate finds, which of them are
variables and stores them in the given group together with their types."
  (let ((vs nil) (gr (make-group :pred (group-pred group) 
				 :groupv (group-groupv group)
				 :localv (group-localv group)
				 :argv (group-argv group)
				 :resv (group-resv group))))
    (mapc (f/l (v)
	       (cond
		((not (named-varsymbolp v)) nil)
		((equal (car variables) var-) nil)
		((equal (type-of-variable v sb) *group_variabletype*)
		 (setf (group-groupv gr)
		       (adjoin
			(list (oid-name *group_variabletype*) v) 
			(group-groupv group))))
		((member v (selectbody-argl sb))
		 (setf (group-argv gr)
		       (adjoin
			(list (oid-name (type-of-variable v sb)) v) 
			(group-argv group)))
		 (setq vs (adjoin v vs)))
		((member v (selectbody-resl sb))
		 (setf (group-resv gr)
		       (adjoin
			(list (oid-name (type-of-variable v sb)) v) 
			(group-resv group)))
		 (setq vs (adjoin v vs)))
		(t 
		 (setf (group-localv gr)
		       (adjoin
			(list (oid-name (type-of-variable v sb)) v) 
			(group-localv group)))
		 (setq vs (adjoin v vs))))) 
	  variables)
    (list vs gr)))

(defun variables (pred var- sb group)
  "variables of the given predicate from selectbody sb excluding variable of
type *group_variabletype* and variable var-"
  (cond
   ((equal (car pred) (getfunctionnamed 'FUNCTION.MAKEBAG->BAG))
    (variablelist (cddr pred) var- sb group))
   (t
    (variablelist (cdr pred) var- sb group))))

(defun wrapper-access (q)
  (member (car q) *wrapper-fn*))

(defun grouping-algorithm (predl sb)
  "Implementation of the grouping algorithm, which generates groups for the 
given predicate in terms of the group structure"
  (let ((groups nil))
    (do ((S predl)) ((null S))
      (let (p (G nil) (vs nil) vars (isWrap nil)
	      (group (make-group :groupv nil :localv nil
				 :argv nil :resv nil :iswrap nil)))
	; choosing first predicate of group
	(setq p (car S))
	(setq S (cdr S))
	(setq G (cons p G))
	(setq vars (variables p nil sb group))
	(setq vs (first vars))
	(setq group (second vars))
	(if (wrapper-access p) (setq isWrap t))
	(do ((v nil)) ((null vs)) ; finding all predicates having variables 
					; in common
	  (setq v (car vs))
	  (setq vs (cdr vs))
	  (setq S 
		(mapfilter 
		 (f/l (q)
		      (setq vars (variables q nil sb group))
		      (if (wrapper-access q) (setq isWrap t))
		      (cond 
		       ((null (first vars))
			(setq G (cons q G))
			(setq group (second vars))
			nil)
		       ((member v (first vars))
			(setq G (cons q G))
			(mapcar (f/l (qvar) 
				     (setq vs (adjoin qvar vs)))
				(remove v (first vars)))
			(setq group (second vars))
			nil)
		       (t q)))
		 S)))
	(cond ((and (not isWrap) (group-groupv group))
	       (setf (group-argv group) 
		     (adjoin (car (group-groupv group)) (group-argv group)))))
	(setf (group-iswrap group) isWrap)
	(setf (group-pred group) (reverse G))
	(setq groups (cons group groups))))
    groups))
