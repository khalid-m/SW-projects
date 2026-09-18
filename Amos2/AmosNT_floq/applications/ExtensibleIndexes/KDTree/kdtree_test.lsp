(defun test-kdtree ()
  (checkequal
   "FULL SCAN KDTREE"
   ((osql "count(select s from WineSample s);")
    '((2939))))

  (checkequal
   "INDEX SCAN KDTREE"
   ((osql "getSampleID({7, 0.27, 0.36, 20.7, 0.045, 45, 170, 1.001, 3, 0.45, 8.8});")
    '((1))))

  (setq res (osql "set :ws = getSample(37);
                  closeWineSamples(:ws, 3);")) 
  (checkequal
   "Similarity when AQIT off"
   ((progn 
      (setq *enable-aqit* nil)
      (osql "recompile('closeWineSamples');")
      (osql "closeWineSamples(:ws, 3);"))
    res))

  (checkequal
   "Similarity when AQIT on"
   ((progn 
      (setq *enable-aqit* t)
      (osql "recompile('closeWineSamples');")
      (osql "closeWineSamples(:ws, 3);"))
    res)))

(test-kdtree)