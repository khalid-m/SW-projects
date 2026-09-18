;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010 Thanh Truong, UDBL
;;; $RCSfile: bench_xtree.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/08/01 13:04:13 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Benchmark for Xtree index
;;; =============================================================
;;; $Log: bench_xtree.lsp,v $
;;; Revision 1.1  2013/08/01 13:04:13  thatr500
;;; archived old benchmark scripts
;;;
;;; Revision 1.4  2010/11/02 08:07:47  thatr500
;;; add benchmark for similarity/knn search
;;;
;;; Revision 1.3  2010/10/28 11:13:36  thatr500
;;; measure the similarity search
;;;
;;; Revision 1.2  2010/10/27 15:07:10  thatr500
;;; parameterize the number of dimensions
;;;
;;; Revision 1.1  2010/10/27 14:37:34  thatr500
;;; Add benchmark for Xtree index
;;;
;;;
;;; =============================================================

(osql " create function pictureFeatures(Charstring pic)->Vector of Number features as stored;
        
        create_index('pictureFeatures','features', 'xtree','multiple');")

(osql "create function xtree_add_records(Number n, Number dim)-> Boolean as
       begin
          for each original Number i where i in iota(1,n)
             add pictureFeatures('X' + i ) = vectorof(i + iota(0, dim));
      end;")


(osql "create function bench_similarity(Number seed, Number dim) -> Bag of Charstring
       as select p from Charstring p
         where euclid(pictureFeatures(p), vectorof(seed + iota(0, dim))) < 10;")

(osql "create function bench_knn(Number seed, Number dim) -> Bag of Charstring
       as select p from Charstring p
       where p in knn(vectorof(seed + iota(0, dim)), 3, #'pictureFeatures');")

(osql "logging off;")

(defun bench_xtree(n ;; number of records 
		   dim) ;; number of dimensions
  (let ((wm (high-watermark)))
    (getfunction 'xtree_add_records (list n dim))
    (/ (- (high-watermark) wm) n)))

;Test adding to Xtree
(bench_xtree 1000000 15)
;;(osql "openwritefile('benchresult.csv');")
;;(osql "bench;")
;;(osql "closewritefile();")
