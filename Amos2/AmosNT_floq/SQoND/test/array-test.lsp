;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Andrej Andrejev, UDBL
;;; $RCSfile: array-test.lsp,v $
;;; $Revision: 1.11 $ $Date: 2013/07/23 14:57:16 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Testcases for the array functionality
;;; =============================================================
;;; $Log: array-test.lsp,v $
;;; Revision 1.11  2013/07/23 14:57:16  andan342
;;; Added hex argument to nma2chunks()
;;;
;;; Revision 1.10  2013/02/21 23:31:53  andan342
;;; Renamed NMA-PROXY-RESOLVE to APR
;;;
;;; Revision 1.9  2013/02/14 15:59:15  andan342
;;; Setting the chunk size once for proxy tag
;;;
;;; Revision 1.8  2013/02/08 00:49:23  andan342
;;; Added regression test for NMA-PROXY-RESOLVE and other fragment/chunk-related functionality
;;;
;;; Revision 1.7  2013/02/05 14:10:35  andan342
;;; Renamed nma-init to nma-fill, aggregate functions are now tolerant to incompatible values
;;;
;;; Revision 1.6  2012/03/27 14:02:20  andan342
;;; Made 'talk.sparql queries work
;;;
;;; Revision 1.5  2011/10/29 19:21:04  andan342
;;; Fixed test shell script, Python syntax in array-test.lsp comments
;;;
;;; Revision 1.4  2011/08/09 21:21:21  andan342
;;; Added new dereference-or-project functionality, AmosQL functions Aref and ASub to translate SciSparQL array expressions to
;;;
;;; Revision 1.3  2011/07/20 16:05:21  andan342
;;; Added Permute, Sub & Project array operations to SciSparql
;;; Added AmosQL testcases showing multidirectional array access
;;;
;;; Revision 1.2  2011/07/07 13:33:54  torer
;;; comments
;;;
;;; Revision 1.1  2011/07/06 16:19:23  andan342
;;; Added array transposition, projection and selection operations, changed printer and reader.
;;; Turtle reader now tries to read collections as arrays (if rectangular and type-consistent)
;;; Added Lisp testcases for this and one SparQL query with array variables
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(osql "set :c1 = inma({3,5});") ;; make array int[3,5]

(let ((x 0)) 		; populate the array			
  (dotimes (i (nma-dim amos_c1 0))
    (dotimes (j (nma-dim amos_c1 1))
      (nma-set amos_c1 (list i j) x)
      (incf x))))

(osql "set :d1 = inma({15});") ;; 1D integer array

(dotimes (i (nma-dim amos_d1 0)) ; populate
  (nma-set amos_d1 (list i) i))

(checkequal 
 "array creation, size getter, element assignment, reader and equality"
 (amos_c1 #[NMA 0 (3 5) ((0 1 2 3 4) (5 6 7 8 9) (10 11 12 13 14))]))

(checkequal 
 "array transposition"
 ((nma-permute amos_c1 '(1 0)) #[NMA 0 (5 3) ((0 5 10) (1 6 11) (2 7 12) 
					   (3 8 13) (4 9 14))]))

(checkequal 
 "array subrange selection"
 ((nma-subset (nma-subset amos_c1 0 1 1 2) 1 0 2 4) ;;SparQL/Python c[1:3,0:5:2] 
  #[NMA 0 (2 3) ((5 7 9) (10 12 14))])
 ((nma-subset (nma-subset amos_c1 0 1 1 2) 1 1 3 4) #[NMA 0 (2 2) ((6 9) (11 14))]) ;;SparQL/Python c[1:3,1:3:4]
 ((nma-subset amos_d1 0 2 3 13) #[NMA 0 (4) (2 5 8 11)]) ;;SparQL/Python d[2:14:3]
 ((nma-subset (nma-subset amos_d1 0 2 3 13) 0 1 2 3) #[NMA 0 (2) (5 11)])) ;;SparQL/Python d[2:14:3][1:4:2]

(checkequal "array projection"
	    ((nma-project amos_c1 0 1);; dim 0, row 1, SparQL/Python c[1,:]
	     #[NMA 0 (5) (5 6 7 8 9)])
	    ((nma-project amos_c1 1 1);; dim 1, col 1, SparQL/Python c[:,1]
	     #[NMA 0 (3) (1 6 11)]))

(defvar *e1* (make-nma nma_etype_int '(2 3)))

(nma-fill *e1* '((1 2 3) (4 5 6))) ;;SparQL: ((1 2 3) (4 5 6))

(checkequal "bulk reader"
	    (*e1* #[NMA 0 (2 3) ((1 2 3) (4 5 6))]))

(checkequal "AmosQL array dereference"
	    ((osql "nmaref(:c1,{1,1});") '((6))) 
	    ((osql "nmaref(:c1,1);") nil) ; not an 1-dim array
	    ((osql "nmaref(:d1,1);") '((1))) ; 1-dim array with singular subscript
	    ((osql "nmaref(:d1,{1});") '((1)))
	    ((sorttuples (osql "select v, x from Vector of Integer v, Integer x where nmaref(:c1,v) = x;")) ; complete index walk
	     (sorttuples '((#(0 0) 0) (#(0 1) 1) (#(0 2) 2) (#(0 3) 3) (#(0 4) 4) (#(1 0) 5) (#(1 1) 6) (#(1 2) 7) (#(1 3) 8) 
			   (#(1 4) 9) (#(2 0) 10) (#(2 1) 11) (#(2 2) 12) (#(2 3) 13) (#(2 4) 14)))) 
	    ((sorttuples (osql "select j, x from Integer j, Integer x where nmaref(:c1,{1,j}) = x;")) ; select row 1, TODO: optimize!
	     (sorttuples '((0 5) (1 6) (2 7) (3 8) (4 9))))
	    )

(checkequal "AmosQL array dereference-or-projection & subsetting"
	    ((osql "aref(:d1,0,1);") '((1)))
	    ((osql "aref(:c1,0,1);") '((#[NMA 0 (5) (5 6 7 8 9)])))
	    ((osql "aref(:c1,1,1);") '((#[NMA 0 (3) (1 6 11)])))
	    ((sorttuples (osql "select i, aref(:c1,0,i) from Literal i;")) ; get array rows, SparQL c[?i,:]
	     (sorttuples '((0 #[NMA 0 (5) (0 1 2 3 4)]) (1 #[NMA 0 (5) (5 6 7 8 9)]) (2 #[NMA 0 (5) (10 11 12 13 14)]))))
	    ((sorttuples (osql "select i, asub(aref(:c1,0,i),0,1,1,3) from Literal i;")) ; get parts of array rows, SparQL c[?i,1:4]
	     (sorttuples '((0 #[NMA 0 (3) (1 2 3)]) (1 #[NMA 0 (3) (6 7 8)]) (2 #[NMA 0 (3) (11 12 13)]))))
	    )


;;;;;;;;;;;;;;;;;;;;;; CHUNK ACCESS, as shown in  http://user.it.uu.se/~andan342/Chunk_access.pdf

(osql "set :f = inma({5,5});")

(nma-fill amos_f '((1 2 3 4 5) (6 7 8 9 10) (11 12 13 14 15) (16 17 18 19 20) (21 22 23 24 25)))

(osql "set :chunksize = 16;")

(defvar *f-chunks* (osql "nma2chunks(:f, :chunksize, 0);"))

(defvar *f-chunks-accesscount* 0)

(defun get-f-chunk (arrayid chunkid)
  (when (equal arrayid "F")
    (incf *f-chunks-accesscount*)
    (second (assoc chunkid *f-chunks*))))

(defvar *proxytag* (nma-register-proxytag nil 'get-f-chunk nil))

(nma-proxy-set-default-chunksize *proxytag* amos_chunksize)

(osql "set :fp1 = 0;")

(setq amos_fp1 (make-nmaproxy nma_etype_int '(5 5) *proxytag* "F"))

(nma-cache-setlimit 64)

(nma-proxy-startcache amos_fp1)

(osql "set :fp2 = 0;")

(setq amos_fp2 (nma-subset amos_fp1 0 1 2 4))

(osql "set :fp3 = 0;")

(setq amos_fp3 (nma-subset amos_fp2 1 2 1 4))

(checkequal "Array proxies and chunk operations"
	    ((nma-subset (nma-subset amos_f 0 1 2 4) 1 2 1 4) #[NMA 0 (2 3) ((8 9 10) (18 19 20))])
	    ((mapcar #'car *f-chunks*) '(0 1 2 3 4 5 6))
	    (amos_fp1 #[NMA 0 (5 5) PROXY 1 "F"])
	    ((osql "NMA2FragmentSIs(:fp1);") '((0 100))) ; whole F as 1 fragment
	    ((osql "NMA2FragmentSIs(:fp2);") '((20 20) (60 20))) ; 2 fragments 5 elt each
	    ((osql "NMA2FragmentSIs(:fp3);") '((28 12) (68 12))) ; 2 fragments 3 elt each
	    ((nma-chunkid-list amos_fp3 0 t) '(4 2 1))
	    ((apr amos_fp3) #[NMA 0 (2 3) ((8 9 10) (18 19 20))])
	    (*f-chunks-accesscount* 3) ; retrieve only chunks 1,2,4
	    ((apr amos_fp2) #[NMA 0 (2 5) ((6 7 8 9 10) (16 17 18 19 20))])
	    (*f-chunks-accesscount* 4) ; retrieve only chunk 3, get 1,3,4 from cache
	    ((apr (nma-project (nma-project amos_fp1 0 2) 0 3)) 14) ; project down to single element
	    )
	    

	    
	    

	    

	     



