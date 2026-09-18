;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Andrej Andrejev, UDBL
;;; $RCSfile: converter.lsp,v $
;;; $Revision: 1.4 $ $Date: 2012/12/17 23:32:04 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Creates Turtle data file from prepared parameter file and Chelonia array files
;;; =============================================================
;;; $Log: converter.lsp,v $
;;; Revision 1.4  2012/12/17 23:32:04  andan342
;;; Changed to using .MAT files as input
;;;
;;; Revision 1.3  2012/11/22 12:42:54  andan342
;;; Added extensible plug-in reader mechanism to resolve file-links in Turtle files
;;; Implemented CheloniaArray reader to load BISTAB data
;;;
;;; Revision 1.2  2012/11/20 22:34:08  andan342
;;; Using file pointer URIs in Turtle output to avoid parsing where bulk data reading is in order
;;;
;;; Revision 1.1  2012/11/20 14:12:43  andan342
;;; Converter for BISTAB data
;;;
;;; =============================================================

(load (concat (getenv "AMOS_HOME") "/SQoND/storage/matWrapper/master.lsp"))

(mat-set-omit-unary-dims nma_omit_all_unary_dims) ; read e.g. 1x201 "tspan" as 1d NMA of 201 element

(defparameter MSpecies 8)

(defparameter A 1)

(defparameter B 2)

(defparameter E_A 3)

(defparameter E_B 4)

(defparameter rel-count 1)

(defun array-filename (occ rel)
  (concat "realization_" occ "_" rel ".mat"))

(defparameter embed-arrays nil)

(defun create-bistab-ttl (tgtfile maxocc)
  (let* ((pars (mat-get-var "input.mat" "parameters"))
	 (nocc (min maxocc (nma-dim pars 1)))
	 (tspan (mat-get-var "input.mat" "tspan"))
	 (tlen (nma-dim tspan 0))
	 (ncells (mat-get-var "input.mat" "Ncells" nma_etype_int))
	 (outs (openstream tgtfile "w")) occ-str afn)
    (unwind-protect
	(progn
	  (formatl outs "@prefix : <http://udbl.uu.se/bistab#> ." t t)
	  (dotimes (occ nocc)
	    (setq occ-str (mkstring (1+ occ)))
	    (dotimes (rel rel-count)	      
	      (formatl outs ":Task" occ-str " :realization " (1+ rel) ";" t)	      
	      (spaces (length occ-str) outs)
	      (formatl outs "      :k_1 " (nma-elt pars (list 0 occ)) "; :k_a " (nma-elt pars (list 1 occ)) 
		       "; :k_d " (nma-elt pars (list 2 occ)) "; :k_4 " (nma-elt pars (list 3 occ)) ";" t)
	      (spaces (length occ-str) outs)
              ;TODO: Next 2 FORMATL lines should be normalized out!
	      (formatl outs "      :MSpecies " mspecies "; :NCells " ncells "; :A " A "; :B " B "; :E_A " E_A "; :E_B " E_B "; :tlen " tlen ";" t)
	      (spaces (length occ-str) outs)		       
	      (formatl outs "      :tspan ")
	      (nma-dump tspan outs)
	      (formatl outs ";" t)
	      (spaces (length occ-str) outs)
	      (formatl outs "      :U ")
	      (setq afn (array-filename occ-str (1+ rel)))
	      (if embed-arrays
		  (nma-dump (mat-get-var afn "U" nma_etype_int) outs)
		(formatl outs "<file://" afn ":matlab#U&0>"))
	      (formatl outs " ." t t))))
      (closestream outs))
    (formatl nil "Successfully converted " (* nocc rel-count) " realization(s) of BISTAB output to Turtle format." t)))	      

;; Test run:
;; (with-directory "C:/DATA/TESTCASES/SantaBarbara/bistab2" (create-bistab-ttl "bistab.ttl" 2))
	
;; Production run:
;; (with-directory "C:/DATA/TESTCASES/SantaBarbara/bistab2" (create-bistab-ttl "bistab100.ttl" 100))

;; (with-directory "C:/DATA/TESTCASES/SantaBarbara/bistab2" (create-bistab-ttl "bistab1000.ttl" 1000))



