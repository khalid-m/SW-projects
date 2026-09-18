;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011, Andrej Andrejev, UDBL
;;; $RCSfile: converter.lsp,v $
;;; $Revision: 1.1 $ $Date: 2011/08/08 15:12:11 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Converter of DM data to Turtle
;;; =============================================================
;;; $Log: converter.lsp,v $
;;; Revision 1.1  2011/08/08 15:12:11  andan342
;;; Added data converter, measure implementation and script with basic SciSparQL query for KNN
;;;
;;; =============================================================

(defun convert-knn-glassdata (src-file tgt-file)
  "convert glassdata to separate blank subjects with :Class and :Data properties"
  (let ((outs (openstream tgt-file "w")) v vlast)
    (unwind-protect
	(progn
	  (formatl outs "@prefix : <http://udbl.uu.se/knn#> ." t)
	  (dolist (row (eval (list 'osql (concat "read_ntuples('" src-file "');"))))
	    (setq v (car row))
	    (setq vlast (1- (length v)))
	    (formatl outs t "[ :Class " (aref v vlast) " ;" t "  :Data (")
	    (dotimes (i vlast)
	      (formatl outs (if (= i 0) "" " ") (* (aref v i) 1.0))) ;always write real values
	    (formatl outs ") ] .")))
      (closestream outs))))

;;(convert-knn-glassdata (concat (getenv "AMOS_HOME") "/applications/datamining/amosMiner/data/glassdata.nt") "glassdata.ttl")

(defun convert-knn-testdata (src-file tgt-file)
  "convert testdata to single array property to :Test001 :Rows  where original vectors are rows"
  (let ((outs (openstream tgt-file "w")) v)
    (unwind-protect
	(progn
	  (formatl outs "@prefix : <http://udbl.uu.se/knn#> ." t t ":Test001 :Rows (")
	  (dolist (row (eval (list 'osql (concat "read_ntuples('" src-file "');"))))
	    (setq v (car row))
	    (formatl outs t "(")
	    (dotimes (i (length v))
	      (formatl outs (if (= i 0) "" " ") (* (aref v i) 1.0))) ;always write real values
	    (formatl outs ")"))
	  (formatl outs ") ."))
      (closestream outs))))

;;(convert-knn-testdata (concat (getenv "AMOS_HOME") "/applications/datamining/amosMiner/data/testdata.nt") "testdata.ttl")