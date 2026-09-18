;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Andrej Andrejev, UDBL
;;; $RCSfile: converterv2.lsp,v $
;;; $Revision: 1.2 $ $Date: 2013/04/16 13:03:13 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Creates Turtle data file from prepared parameter file and Chelonia array files
;;; =============================================================
;;; $Log: converterv2.lsp,v $
;;; Revision 1.2  2013/04/16 13:03:13  andan342
;;; Support for multiple realizations per occurrance
;;;
;;; Revision 1.1  2013/01/21 16:40:15  andan342
;;; Added "V2" converter to hierarchical schema and re-formulated queries.
;;; Added example script for bulk-loading
;;;
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

;; Should be run under ssdm -q Lisp

(load (concat (getenv "AMOS_HOME") "/SQoND/storage/matWrapper/master.lsp"))

(mat-set-omit-unary-dims nma_omit_all_unary_dims) ; read e.g. 1x201 "tspan" as 1d NMA of 201 element

(defparameter MSpecies 8)

(defparameter A 1)

(defparameter B 2)

(defparameter E_A 3)

(defparameter E_B 4)

(defparameter rel-count 10)

(defun array-filename (occ rel)
  (concat "realization_" (1+ occ) "_" (1+ rel) ".mat"))

(defparameter embed-arrays nil)

(defun create-bistab-ttl (tgtfile maxocc)
  (let* ((pars (mat-get-var "input.mat" "parameters"))
	 (nocc (min maxocc (nma-dim pars 1)))
	 (tspan (mat-get-var "input.mat" "tspan"))
	 (tlen (nma-dim tspan 0))
	 (ncells (mat-get-var "input.mat" "Ncells" nma_etype_int))
	 (outs (openstream tgtfile "w")) 
	 (tasknr 1) tasknr-str afn)
    (unwind-protect
	(progn
	  (formatl outs "@prefix : <http://udbl.uu.se/bistab#> ." t t)
	  (formatl outs ":Experiment1 :MSpecies " mspecies "; :NCells " ncells "; :A " A "; :B " B "; :E_A " E_A "; :E_B " E_B "; :tlen " tlen ";" t)
	  (formatl outs "             :tspan ")
	  (nma-dump tspan outs)
	  (formatl outs " ." t t)	  
	  (dotimes (occ nocc)
	    (dotimes (rel rel-count)	      	      
	      (setq tasknr-str (mkstring tasknr))
	      (incf tasknr)
	      (formatl outs ":Task" tasknr-str " :realization " (1+ rel) "; :inExperiment :Experiment1 ;" t)	      
	      (spaces (length tasknr-str) outs)
	      (formatl outs "      :k_1 " (nma-elt pars (list 0 occ)) "; :k_a " (nma-elt pars (list 1 occ)) 
		       "; :k_d " (nma-elt pars (list 2 occ)) "; :k_4 " (nma-elt pars (list 3 occ)) ";" t)
	      (spaces (length tasknr-str) outs)
	      (formatl outs "      :U ")
	      (setq afn (array-filename occ rel))
	      (if embed-arrays
		  (nma-dump (mat-get-var afn "U" nma_etype_int) outs)
		(formatl outs "<file://" afn ":matlab#U&0>"))
	      (formatl outs " ." t t))))
      (closestream outs))
    (formatl nil "Successfully converted " (* nocc rel-count) " realization(s) of BISTAB output to Turtle format." t)))	      

(with-directory "C:/DATA/bistab2" (create-bistab-ttl "bistab10k.ttl" 1000))
	




