(checkequal ".MAT files interface"
	    ; A is dense array of type double
	    ((mat-get-var "test.mat" "A" nma_etype_int)
	     #[NMA 0 (2 3) ((1 2 3) (4 5 6))])
	    ; B is sparse array of type double, as in http://www.mathworks.se/help/matlab/apiref/mxsetjc.html
	    ((mat-get-var "test.mat" "B" nma_etype_int)
	     #[NMA 0 (7 3) ((0 0 0) (1 0 2) (0 1 0) (0 0 0) (1 0 1) (0 0 1) (0 0 0))])
	    ((mat-get-var "test.mat" "C" nma_etype_auto) 3.14)
	    ((mat-get-var "test.mat" "C" nma_etype_int) 3)
	    ((mat-set-omit-unary-dims nma_omit_no_unary_dims) 0)
	    ((mat-get-var "test.mat" "C" nma_etype_int)
	     #[NMA 0 (1 1) ((3))])
	    )
	    
	    


