;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Ruslan Fomkin, UDBL
;;; $RCSfile: profile.lsp,v $
;;; $Revision: 1.2 $ $Date: 2007/09/11 08:31:36 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  
;;; ===========================================================================
;;; $Log: profile.lsp,v $
;;; Revision 1.2  2007/09/11 08:31:36  ruslan
;;; header is added
;;;
;;; ===========================================================================

(foreign-lispfn getchange ((function fn))((real change))
		(foreign-result (isorder _new-pred-order_
					 _old-pred-order_)))

(foreign-lispfn execute ()((real extime))
		(foreign-result (test)))

(foreign-lispfn plancost ()((real cst))
		(foreign-result (first _cost-before-unwrap_)))

(foreign-lispfn plancard ()((real card))
		(foreign-result (second _cost-before-unwrap_)))

(foreign-lispfn unprofile ((charstring fn))()
		(let* 
		    ((tfn 
		      (first (selectbody-groups-fns 
			      (getselectbody 
			       (getfunctionnamed (mksymbol fn)))))))
		  (print-plan tfn)
		  (setq _new-pred-order_ 
			(cdr (selectbody-optpred (getselectbody tfn))))
		  (setq _cost-before-unwrap_ (exec-cost-of-fn tfn))
		  (let* ((sb (getselectbody tfn))
			 (ungrouped (remove-group-wrap 
				     (selectbody-optpred sb))))
		    (if ungrouped 
			(setf (selectbody-optpred sb) ungrouped)))))

(defun wrapped-control-pred (pred)
  "Checks if the given predicate is wrapped by profile-controller"
  (eq (second pred) 'PROFILE-CONTROLLER))

(defun remove-controller-wrap (controlled-pred)
  (cond
   ((null controlled-pred) '())
   ((conjunctionp controlled-pred)
    (cons 'and (remove-controller-wrap (cdr controlled-pred))))
   ((disjunctionp controlled-pred)
    (cons 'or (remove-controller-wrap (cdr controlled-pred))))
   ((wrapped-control-pred (car controlled-pred))
    (append2 (get-preds (fourth (car controlled-pred)))
	     (remove-controller-wrap (cdr controlled-pred))))
   (t (cons (car controlled-pred) (remove-controller-wrap 
				   (cdr controlled-pred))))))
	       
(foreign-lispfn unprofileall ((charstring fn))()
		(let* 
		    ((mainsb (getselectbody 
			      (getfunctionnamed (mksymbol fn))))
		     (tfn 
		      (first (selectbody-groups-fns mainsb)))
		     (sb (getselectbody tfn)))
;		  (print-plan tfn)
		  (setq _new-pred-order_ 
			(cdr (selectbody-optpred (getselectbody tfn))))
		  (setq _cost-before-unwrap_ (exec-cost-of-fn tfn))
		  (let ((ungrouped (remove-group-wrap 
				    (selectbody-optpred sb))))
		    (if ungrouped 
			(setf (selectbody-optpred sb) ungrouped)))
		  (let ((ungrouped (remove-controller-wrap
				    (selectbody-optpred mainsb))))
		    (if ungrouped
			(setf (selectbody-optpred mainsb) ungrouped)))))

(foreign-lispfn create_struct_stat () ()
		(osql "delete function struct_stat;")
		(setq *struct-stat-fn* 
		      (osql "create function struct_stat(type t, 
integer i)-> <integer calls, integer results> as stored;")))

(foreign-lispfn clean_structstat () ()
	(dropfunction 'type.integer.struct_stat->integer.integer))

(foreign-lispfn profile ((function f)(charstring lf)) ((real ptime))
	(foreign-result (timer2 (callfunction f (list lf)))))

(foreign-lispfn print_newplan () ()
	(print-newplan))

(foreign-lispfn execute ((function fn)(charstring lf)) ((real etime))
  (let (extnew ext)
    (sleep 60)
    (setq ext (timer2 (callfunction fn (list lf))))
    (sleep 20)
    (setq extnew (timer2 (callfunction fn (list lf))))
    (setq ext (min ext extnew))
    (sleep 20)
    (setq extnew (timer2 (callfunction fn (list lf))))
    (foreign-result (min ext extnew))))

(foreign-lispfn stop_nochange ()()
	(setq *stop-profiling* 'stopNoChanges))

(foreign-lispfn stop_nevents ()()
	(setq *stop-profiling* 'fullyprofileNfirstevents))
