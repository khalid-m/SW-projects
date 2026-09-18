;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010 Tore Risch, UDBL
;;; $RCSfile: cursor.lsp,v $
;;; $Revision: 1.4 $ $Date: 2011/01/26 20:54:49 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Cursors on bags
;;; =============================================================
;;; $Log: cursor.lsp,v $
;;; Revision 1.4  2011/01/26 20:54:49  torer
;;; New cursor mechanism using scans
;;;
;;; =============================================================

(defmacro open-dbcursor (var form)
  "open c for expr;"
  `(set-amosql-variable ,var (openscan ,form)))  

(defmacro fetch-dbcursor (var resvars)
  "fetch c into resvars;"
  (if resvars `(set-amosql-variables 
		,resvars 
		(vectorTuple (next ,var) ,(length resvars)))
    `(osql-select ((next ,var)) into flat)))

(defmacro close-dbcursor (var)
  "close c;"
  `(osql-select ((closescan ,var))))
