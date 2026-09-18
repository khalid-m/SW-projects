;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Ruslan Fomkin, UDBL
;;; $RCSfile: dyngroups.stream.lsp,v $
;;; $Revision: 1.16 $ $Date: 2008/12/25 19:35:13 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Generates groups for a predicate during optimization for stream approach. 
;;; It is called
;;; during optimization of the predicate. To generate a plan for a function
;;; with the dynamic group cost model the flag grouping() should be set to 
;;; true before optimization. The flag should be set to false before any 
;;; execution, otherwise if execution requires optimization the dynamic group
;;; cost model generation will be called.
;;; For streams!!
;;; ===========================================================================
;;; $Log: dyngroups.stream.lsp,v $
;;; Revision 1.16  2008/12/25 19:35:13  torer
;;; (setq *old-decompose* t) since ALEH depends on old code that cannot handle non-DNF predicates
;;;
;;; Revision 1.15  2007/11/07 12:13:19  ruslan
;;; grouping algorithm is separated and improved
;;;
;;; Revision 1.14  2007/09/12 14:30:17  ruslan
;;; using t.root instead of local file
;;;
;;; Revision 1.13  2007/09/12 12:21:41  ruslan
;;; unnecessary type checks are removed from groups
;;;
;;; Revision 1.12  2007/09/11 08:16:04  ruslan
;;; clock profile is set to 1 in stream case.
;;;
;;; Revision 1.11  2007/07/27 07:20:33  ruslan
;;; now profiled grouping does always unwrapping in stream approach
;;;
;;; Revision 1.10  2007/06/20 07:37:16  ruslan
;;; minor improvement of the codes
;;;
;;; Revision 1.9  2007/06/20 07:10:50  ruslan
;;; minor improvement of the code
;;;
;;; Revision 1.8  2007/03/02 15:29:39  ruslan
;;; different levels for randomopt in profiled grouping on top and inside groups
;;;
;;; Revision 1.7  2007/03/01 10:01:51  ruslan
;;; since grouping algorithm reverses original order of input predicates, which is executable. the reverse back is added
;;;
;;; Revision 1.6  2007/02/28 13:33:25  ruslan
;;; different optimization methods for top and inside groups
;;;
;;; Revision 1.5  2007/02/28 12:48:18  ruslan
;;; grouping function to toggle grouping mode is moved to one place (grouping.lsp)
;;;
;;; Revision 1.4  2007/02/14 09:49:41  ruslan
;;; if result type of selectbody is nil then type boolean is returned
;;;
;;; Revision 1.3  2007/02/14 08:45:08  ruslan
;;; if result type of selectbody is nil then type boolean is returned
;;;
;;; Revision 1.2  2007/02/13 13:29:55  ruslan
;;; Grouping is implemented and working for stream
;;;
;;; Revision 1.1  2007/02/09 11:22:41  ruslan
;;; profiled grouping for stream approach with struct implementation. It generates correctly running plan. The efficiency of the plan should be examined
;;;
;;; ===========================================================================

; Flag for doing grouping. It is definded in grouping.lsp
;(defglobal *grouping* nil)
; Variable for which joins between groups are allowed
(defglobal *group-sample-size* 50)
(defglobal *group-source-fn* (getfunctionnamed 'CHARSTRING.ALEH_STREAM->EVENT))
(defglobal *group-source-arg* (list "../../wrappers/ROOTWrap/t.root"))
(setq _clock-profile_ 1.0)

(setq *old-decompose* t)

(load "../lsp/grouping.algorithm.stream.lsp")

(defun grouped-pred (groups)
  "Creates new predicate for the given groups"
  (let ((pred nil))
    (setq *agg-tocollect* t)
    (dolist (g groups)
      (let*
	  ((arglist (group-argv g))
	   (reslist (group-resv g))
	   (counter 0)
	   (mainoptmethod (aref (first 
				 (callfunction 
				  (getfunctionnamed 'optmethod)
				  (list *group-optimization-method*))) 0))
	   (old_ii _iino_) (old_sh _shno_)
	   group fno)
	(/setglobal '_iino_ (first *group-optlevel*))
	(/setglobal '_shno_ (second *group-optlevel*))
	(cond
	 ((group-iswrap g)
	  (setq pred (append2 pred (group-pred g))))
	 (t
	  (setq 
	   fno 
	   (createfunction '*TRANSIENT* arglist
			   '((BOOLEAN)) nil nil
			   (cons 'FLATTENED (cons 'AND (group-pred g)))))
	  (setq group 
		(cond
		 ((and (equal 1 (length reslist))(equal 0 (length arglist))
		       (equal 1 (length (group-groupv g))))
		  (list (getfunctionnamed 'FUNCTION.OBJECT.GROUP->BOOLEAN)
			fno (second (first reslist))))
		 ((and (equal 1 (length arglist))(equal 0 (length reslist))
		       (equal 1 (length (group-groupv g))))
		  (catch 'PROFILED
		    (mapfunction 
		     *group-source-fn* *group-source-arg*
		     (f/l (ev)
			  (if (equal counter *group-sample-size*)
			      (throw 'PROFILED T))
			  (1++ counter)
			  (mapfunction 
			   (the-tbr-function 
			    (getfunctionnamed 
			     'FUNCTION.OBJECT.GROUP->BOOLEAN)
			    '(- -)) 
			   (list fno (first ev)) (f/l (x) x)))))
		  (list (getfunctionnamed 'FUNCTION.OBJECT.GROUP->BOOLEAN)
			fno (second (first arglist))))
		 (t (error "Dyngroups undefined for groups with more than one
input or output variable and the only one variable should be grouped 
variable."))))
	  (setq pred (cons group pred)) ))
	(callfunction (getfunctionnamed 'optmethod) (list mainoptmethod))
	(/setglobal '_iino_ old_ii)
	(/setglobal '_shno_ old_sh)))
    (setq *agg-tocollect* nil)
    pred))
	       
(defun sortandpred0 (remaining sb)
  (cond 
   ((atom remaining) remaining)
   ;; Applies grouping algorithm to the given predicate if the flag is true
   (*grouping* 
    (let ((groups (grouping-algorithm remaining sb))
	  (old_ii _iino_) (old_sh _shno_)
	  mainoptmethod respred)
      (cond 
       ((> (length groups) 1)
	(setq *grouping* nil)
	(setq remaining (grouped-pred groups))
	(setq mainoptmethod (aref (first 
				   (callfunction 
				    (getfunctionnamed 'optmethod)
				    (list *top-optimization-method*))) 0))
	(/setglobal '_iino_ (first *top-optlevel*))
	(/setglobal '_shno_ (second *top-optlevel*))
	(setq respred (psort (purge remaining sb)
			     (selectbody-argl sb)))
	(callfunction (getfunctionnamed 'optmethod) (list mainoptmethod))
	(/setglobal '_iino_ old_ii)
	(/setglobal '_shno_ old_sh)
	(setq *grouping* t)
	(remove-group-wrap respred))
       (t
	(psort (purge remaining sb)
	       (selectbody-argl sb))))))
   (t
    (psort (purge remaining sb)
	   (selectbody-argl sb)))))
