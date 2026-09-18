;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2005 Tore Risch, UDBL
;;; $RCSfile: typeinf.lsp,v $
;;; $Revision: 1.4 $ $Date: 2007/02/18 10:22:38 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Testing type inference
;;; =============================================================
;;; $Log: typeinf.lsp,v $
;;; Revision 1.4  2007/02/18 10:22:38  torer
;;; SQRT(x) now returns only the positive root rather than both roots
;;;
;;; ===========================================================================

(set-resulttypesfn (osql "create function bg(Bag)->Object as foreign 'bg';")
		  'bg-resulttypes)

(defun bg (fno b &rest res)
  (mapbag b (f/l (row)
		 (apply 'osql-result (cons b row)))))

(defun bg-resulttypes (fno args)
  (type-parameters (arg-type (car args))))

(checkequal "Type inference"
	    ((osql "bg(1+2);") '((3)))
	    ((osql "1+bg(sqrt(4));") '((3.0)))
	    ((osql "count(select bg(iota(1,4)));") '((4)))
	    ((osql "sum(bg(iota(1,4)));") '((10)))
            ((osql "1+sum(bg(iota(1,bg(iota(1,3)))))+bg(3-2);") '((12)))
            ((osql "count(bg(argrestypes(functionnamed('NUMBER.NUMBER.PLUS->NUMBER'))));") '((3)))
	    )
(rollback)

