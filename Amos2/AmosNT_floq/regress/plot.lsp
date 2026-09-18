;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009 Erik Zeitler, UDBL
;;; $RCSfile: plot.lsp,v $
;;; $Revision: 1.4 $ $Date: 2009/11/03 21:06:04 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Test plotting facilities
;;; =============================================================
;;; $Log: plot.lsp,v $
;;; Revision 1.4  2009/11/03 21:06:04  zeitler
;;; Plot uses project() for projection
;;;
;;; Revision 1.3  2009/10/29 17:29:14  zeitler
;;; windows external plot
;;;
;;; Revision 1.2  2009/10/23 15:27:34  zeitler
;;; Ext plot tests
;;;
;;; =============================================================

(checkequal "extplotexport of bag of vector"
  ((osql "extplotexport({0,1}, 
            (select {i, 10-i}
             from integer i
             where i in iota(1, 5)));")
  '(("gnu-tmp")))
  ((osql "read_ntuples('gnu-tmp');")
  '((#(1 9)) (#(2 8)) (#(3 7)) (#(4 6)) (#(5 5)))))

(checkequal "extplotexportv of vector of vector"
  ((osql "extplotexportv({0,1}, {{1,2},{2,3},{1,0}});")
  '(("gnu-tmp")))
  ((osql "read_ntuples('gnu-tmp');")
   '((#(1 2)) (#(2 3)) (#(1 0)))))

(checkequal "winplotstring"
	    ((winplotstring "plot" "with lines")
	     (concat "echo plot 'gnu-tmp' with lines ; pause -1 "
		     "'Close window' | pgnuplot.exe"))
	    ((winplotstring "splot" "with points palette")
	     (concat "echo splot 'gnu-tmp' with points palette ; "
		     "pause -1 'Close window' | pgnuplot.exe")))

(checkequal "linuxplotstring"
	    ((linuxplotstring "plot" "with lines")
	     "echo \"set mouse
plot 'gnu-tmp' with lines
pause mouse\" | gnuplot")
	    ((linuxplotstring "splot" "with points palette")
	     "echo \"set mouse
splot 'gnu-tmp' with points palette
pause mouse\" | gnuplot"
))
