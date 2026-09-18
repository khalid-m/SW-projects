;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2003 Tore Risch, UDBL
;;;
;;; Description: Emacs function editing
;;; 1. Download gnuserver package from 
;;;    http://user.it.uu.se/~udbl/software/gnuserv.zip
;;; 2. Make sure command line command xemacs works (check PATH)
;;; 3. Before editing you must first be able to start xemacs server with
;;;       gnuserver  (check PATH if not)
;;; 4. You should now be able to edit from command line with 
;;;       gnuclientw <filename> (check PATH if not)
;;; 5. You can now finally find and edit Lisp function <fn> 
;;;    loaded into Amos II with
;;;       (ed <fn>)
;;; =============================================================

(defvar *current-loadfile* nil)
(defvar *loaded-files* nil)

(defun absolute-path (file)
  "Is FILE specified as an absolute file path?"
  (or (string-like file "?:/*")(string-like file "/*")))

(defun full-file-name (file)
  "Make absolute path for FILE"
  (fullpath file))

(defun subst-backslash (str)
  "Substitute \ for / in str"
  (apply 'concat (subst "/" "\\" (explode str))))

(defun put-filepos(args)
  "Set file position of current function or macro definition"
  (if *current-loadfile*
      (putprop (car args) 'filepos (cons *current-loadfile* (define-line)))))
  
(advise-around 
 'load
 '(progn ((lambda (*current-loadfile*)
	    (setq *loaded-files* (adjoin *current-loadfile* *loaded-files*))
            *)
	  (full-file-name (car !args)))))

(advise-around 
 'load-amosql
 '(progn ((lambda (*current-loadfile*)
	    (setq *loaded-files* (adjoin *current-loadfile* *loaded-files*))
            *)
	  (full-file-name (car !args)))))

(advise-around 
 'defun
 '(progn (put-filepos !args) *))

(advise-around 
 'defmacro
 '(progn (put-filepos !args) *))
