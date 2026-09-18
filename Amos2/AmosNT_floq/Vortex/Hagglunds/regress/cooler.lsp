;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013 Cheng Xu, UDBL
;;; $RCSfile: cooler.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/10/21 15:03:08 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: regression for the hagglunds cooler
;;; =============================================================
;;; $Log: cooler.lsp,v $
;;; Revision 1.1  2013/10/21 15:03:08  chexu484
;;; regression test for cooler validation
;;;
;;;
;;; =============================================================

(osql "set :s = hagglundsRecords('hsCOOLER');
       set :mas = movingAverage(:s, 15, 0.1);")

(checkequal
 "Test the hagglunds stream generator"
 ((osql "count(in(first_N(:s, 10)));")
  '((10))))

(checkequal
 "Test the hagglunds record by record validation"
 ((osql "count(in(first_N(learn_n_validate(:s, #'buildStats', 2000, #'validateCOOLER'), 10)));")
  '((10))))

(checkequal
 "Test the hagglunds moving average stream"
 ((osql "count(in(first_N(:mas, 10)));")
  '((10))))

(checkequal
 "Test the hagglunds moving average validation"
 ((osql "count(in(first_N(learn_n_validate(:mas, #'buildStats', 2000, #'validateCOOLER'), 10)));")
  '((10))))

(quit)