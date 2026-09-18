;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Tore Risch, UDBL
;;; $RCSfile: testsubplan.lsp,v $
;;; $Revision: 1.5 $ $Date: 2007/12/19 21:06:08 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Testing subplan partitioning
;;; =============================================================
;;; $Log: testsubplan.lsp,v $
;;; Revision 1.5  2007/12/19 21:06:08  torer
;;; Added externalization of Amos II code for shipping between peers
;;;
;;; Revision 1.4  2007/12/18 16:25:09  torer
;;; Bugs when sending transients with constructor forms over sockets
;;;
;;; Revision 1.3  2007/12/18 07:36:59  torer
;;; Constructor forms on transient objects
;;;
;;; Revision 1.2  2007/10/25 17:27:03  torer
;;; subplan transformation did not work for stored functions
;;;
;;; Revision 1.1  2007/10/18 12:24:16  torer
;;; Added tests for subplan partitioner
;;;
;;; =============================================================

(defglobal orgplan)

(osql "
create function test0(number)->Number;
set test0(1)=1;
create function test(Number x)->Number
as select test0(x)+1+x+2+x+3;
create function atest(Number x)->Integer 
as select sum(iota(1,x));")

(setq orgplan (selectbody-optpred (getselectbody 
				   (getfunctionnamed 'number.test->number))))

(defun splittest(from to orgplan)
  (let* ((sb (getselectbody (getfunctionnamed 'number.test->number)))
	 (andl (argsof 'and orgplan))
	 (sp (transform-section-subplan andl from to (selectbody-argl sb)
					(selectbody-resl sb))))
    (setf (selectbody-optpred sb) sp);;Replace old TBR
    (osql "test(1)			;")));; Should always be ((9))

;;; test all possible plan splittings

(checkequal "plan splitting"
	    ((splittest 1 1 orgplan) '((9)))
	    ((splittest 1 2 orgplan) '((9)))
	    ((splittest 1 3 orgplan) '((9)))
	    ((splittest 1 4 orgplan) '((9)))
	    ((splittest 1 5 orgplan) '((9)))
	    ((splittest 1 6 orgplan) '((9)))
	    ((splittest 2 2 orgplan) '((9)))
	    ((splittest 2 3 orgplan) '((9)))
	    ((splittest 2 4 orgplan) '((9)))
	    ((splittest 2 5 orgplan) '((9)))
	    ((splittest 2 6 orgplan) '((9)))
	    ((splittest 3 3 orgplan) '((9)))
	    ((splittest 3 4 orgplan) '((9)))
	    ((splittest 3 5 orgplan) '((9)))
	    ((splittest 3 6 orgplan) '((9)))
	    ((splittest 4 4 orgplan) '((9)))
	    ((splittest 4 5 orgplan) '((9)))
	    ((splittest 4 6 orgplan) '((9)))
	    ((splittest 5 5 orgplan) '((9)))
	    ((splittest 5 6 orgplan) '((9)))
	    ((splittest 6 6 orgplan) '((9)))
	    )

(checkequal "Using nested transients"
	    ((osql "atest(3);") '((6)))
            ((getfunction (predicate-definition (theresolvent 'test)) '(1))
             '((9)))
            ((getfunction (internalize-code (externalize-code
					     (predicate-definition 
					      (theresolvent 'atest))))
			  '(3))
             '((6)))
	    )


(rollback) ;; Undo all AmosQL definitions
