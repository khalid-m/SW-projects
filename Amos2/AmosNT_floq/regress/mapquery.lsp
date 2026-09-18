;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Tore Risch, UDBL
;;; $RCSfile: mapquery.lsp,v $
;;; $Revision: 1.2 $ $Date: 2012/07/24 18:39:37 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Mapper over AmosQL query string
;;; =============================================================
;;; $Log: mapquery.lsp,v $
;;; Revision 1.2  2012/07/24 18:39:37  torer
;;; Command result materialized
;;;
;;; Revision 1.1  2012/07/17 16:32:36  torer
;;; Regression testing map-query()
;;;
;;; =============================================================

(checkequal 
 "MAP-QUERY and MATERIALIZE-QUERY"
 ((materialize-query "1+2;") '((3)))
 ((materialize-query "1+iota(1,3);") '((2) (3) (4)))
 ((materialize-query "select distinct n from number n where n in {1,3,1,2};")
  '((1)(3)(2)))
 ((materialize-query "1;") '((1)))
 ((materialize-query "{1,2,3};") '((#(1 2 3))))
 ;;bug((materialize-query "bag(1,2,3);") '((1)(2)(3)))
 ((materialize-query "set :a=2;") '((2)))
 ((materialize-query ":a+1;") '((3)))
 ((materialize-query "set :b=2*3;") nil)
 ((materialize-query ":b;") '((6)))
 ((materialize-query "set :c=iota(1,4);") nil)
 ;; bug((materialize-query ":c;") '((1)(2)(3)(4)))
 ((materialize-query "begin return 1; return (1,2); end;") '((1)(1 2)))
 ((materialize-query "begin return iota(1,3); end;") '((1)(2)(3)))
 ((materialize-query "begin return (iota(1,2),iota(2,3)); end;") 
  '((1 2) (1 3) (2 2) (2 3)))
 ;;bug ((materialize-query "begin return :a; end;") '((2)))
 ) 

(rollback)
