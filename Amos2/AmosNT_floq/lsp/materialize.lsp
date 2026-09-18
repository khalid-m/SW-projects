;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009 Tore Risch, UDBL
;;; $RCSfile: materialize.lsp,v $
;;; $Revision: 1.3 $ $Date: 2011/03/10 10:32:24 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Explicit materialization and function caching
;;; =============================================================
;;; $Log: materialize.lsp,v $
;;; Revision 1.3  2011/03/10 10:32:24  torer
;;; New function
;;; cacedApply(Function f, Vector argl, Function cfn)->Bag of Object
;;; for caced application of f on argl
;;;
;;; Revision 1.2  2009/10/30 16:43:34  torer
;;; New function materialize(Bag of X)->Bag of X
;;;
;;; =============================================================

(set-resulttypesfn
 (osql "
create function materialize(Bag b)->Bag r
  as foreign 'materialize-+';")
 'materialize-resulttypes)

(defun materialize-resulttypes (fno args)
  "The result type is the type parameters of the 1st bag argument"
  (list (make-bagtype (default-type-parameters (arg-type (car args))))))

(defun materialize-+ (fno b r)
  (let ((res (tconc nil)))
    (mapbag b (f/l (row) (tconc res row)))
    (osql-result b (cons 'aggr_bag (car res)))))

(osql "
create function cachedApply(Function f, Vector args, Function cf)
                        -> Bag of Object
  /* Cache result of applying function F on argument list ARGS
     in function CF without any logging */
  as foreign 'cachedApply---+';")

(defun addfunction-nolog (fno argl resl)
   "Fast and not logged addfunction"
   (resetvar _histflg_ nil (addfunction0 fno argl resl t)))

(defun cachedApply---+ (fno f args cfn r)
  (let (found)
    (mapfunction cfn args
		 (f/l (row)		      (setq found t)
		      (apply 'osql-result f args cfn row)))
    (if (not found)
	(mapfunction f args
		     (f/l (row)
			  (addfunction-nolog cfn args row)
			  (apply 'osql-result f args cfn row))))))

