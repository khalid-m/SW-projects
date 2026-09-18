;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Andrej Andrejev, UDBL
;;; $RCSfile: converter.lsp,v $
;;; $Revision: 1.2 $ $Date: 2012/01/12 17:35:35 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Creates Turtle data file from Brian's "Processed data" collection of trajectory data files
;;; =============================================================
;;; $Log: converter.lsp,v $
;;; Revision 1.2  2012/01/12 17:35:35  andan342
;;; Fixed bug with UNIX EOLs
;;;
;;; Revision 1.1  2012/01/12 17:31:02  andan342
;;; Added converter from Brian's "Processed data" trajectory files to Turtle
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(load (concat (getenv "AMOS_HOME") "/lsp/grm/parse-utils.lsp"))

;; result of parsing the desicriptive filename
(defstruct sf model version algorithm input d tf tstep son km kon trajno)

(defun sf-same-experiment (a b)
  "Checks whether two trajectory data files belong to the same experiment, based on experiment properties"
  (and (sf-p a) (sf-p b)
       (string= (sf-model a) (sf-model b))
       (= (sf-version a) (sf-version b))
       (string= (sf-algorithm a) (sf-algorithm b))
       (string= (sf-input a) (sf-input b))
       (string= (sf-d a) (sf-d b))
       ;(= (sf-tf a) (sf-tf b))
       (= (sf-tstep a) (sf-tstep b))
       (string= (sf-son a) (sf-son b))))

(defun read-sf-token (stream)
  "Read a token from trajectory data filename: symbol, int, float or dash"
  (let ((token (read-token stream "_" "-")))
    (cond ((integerp token) (cons 'int token))
	  ((floatp token) (cons 'float token))
	  ((eq token '*eof*) nil)
	  ((and (stringp token) (string= token "-")) '(dash))
	  (t (cons (mksymbol token) nil)))))

;; use syntax parser
(load "brian-sf-slr1.lsp")

(defun brian2ttl (srcdir tgtfile)
  "Given a directory with trajectory data files, create a Turtle file"
  (let ((outs (openstream tgtfile "w"))
	(sfs (caar (eval (list 'osql (concat "sort(dir('" srcdir "'));")))))
	sfn sfn-stream sfdata sfdata0 sf-stream buf (exp-cnt 0) (traj-cnt 0))	
    (unwind-protect
	(progn
	  (formatl outs "@prefix : <http://udbl.uu.se/YeastPolarization#> ." t t)
	  (dotimes (i (length sfs))
	    (setq sfn (aref sfs i))
	    (unless (member sfn '("." ".."))
	      (setq sfn-stream (maketextstream))
	      (princ sfn sfn-stream)
	      (textstreampos sfn-stream 0)
	      (setq sfdata (brian-sf-slr1-parser #'(lambda () (read-sf-token sfn-stream)) nil))
	      (unless (sf-same-experiment sfdata sfdata0)
		(setq sfdata0 sfdata)
		(incf exp-cnt)
		(formatl outs ":Experiment" (leftpad exp-cnt "0" 3) " a :YeastPolarizationExperiment ;" t)
		(formatl outs "               :ModelName " (sf-model sfdata) " ;" t)
		(formatl outs "               :ModelVersion " (sf-version sfdata) " ;" t)
		(formatl outs "               :SimulationAlgorithm " (sf-algorithm sfdata) " ;" t)
		(formatl outs "               :InputType " (sf-input sfdata) " ;" t)
		(formatl outs "               :Diffusion " (sf-d sfdata) " ;" t)
		;(formatl outs "               :FinalTime_s " (sf-tf sfdata) " ;" t)
		(formatl outs "               :TimeStep_s " (sf-tstep sfdata) " ;" t)
		(formatl outs "               :Son " (sf-son sfdata) " ." t t))
	      (formatl outs "[] a :TrajectoryData ;" t)
	      (formatl outs "   :inExperiment :Experiment" (leftpad exp-cnt "0" 3) " ;" t)
	      (formatl outs "   :Km " (sf-km sfdata) " ;" t)
	      (formatl outs "   :kon " (sf-kon sfdata) " ;" t)
	      (formatl outs "   :TrajNo " (sf-trajno sfdata) " ;" t)
	      (setq sf-stream (openstream (concat srcdir "/" sfn) "r"))
	      (unwind-protect
		  (setq buf (read-line sf-stream))
		(closestream sf-stream))
	      (formatl outs "   :Width (" (substring 1 (- (length buf) 3) buf) ") ." t t)
	      (incf traj-cnt))))
      (closestream outs))
    (formatl nil "Successfully converted " traj-cnt " trajectories belonging to " exp-cnt " experiment(s) to Turtle format." t)
    t))

;; Test run:
;; (brian2ttl "C:/Temp/ProcData" "procdata.ttl")
	

