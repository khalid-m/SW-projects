;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Tore Risch, UDBL
;;; $RCSfile: filepos.lsp,v $
;;; $Revision: 1.10 $ $Date: 2014/01/16 00:40:52 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Store file positions of function definitions
;;;
;;; =============================================================
;;; $Log: filepos.lsp,v $
;;; Revision 1.10  2014/01/16 00:40:52  andan342
;;; STRING-RIGHTPOS now takes search chars as a list, and an opional argument DOWNTO
;;;
;;; =============================================================

(defvar *current-loadfile* nil "Name of current file being loaded")
(defvar *current-loadstream* nil "Current stream being loaded")
(defvar *loaded-files* nil "List of all currently loaded files")

(defun full-file-name (file)
  "Make absolute path for FILE"
  (fullpath file))

(defun put-filepos(args)
  "Set file position of current function or macro definition"
  (and *current-loadfile* (null _release_)
      (putprop (car args) 'filepos (cons *current-loadfile* (define-line)))))
  
(advise-around 
 'load
 '(progn ((lambda (*current-loadfile* *current-loadstream*)
	    (setq *loaded-files* (adjoin *current-loadfile* *loaded-files*))
            *)
	  (full-file-name (car !args)) nil)))

(advise-around
  'openstream
  '(setq *current-loadstream* *))

(advise-around 
 'parse-file
 '(progn ((lambda (*current-loadfile*)
	    (setq *loaded-files* (adjoin *current-loadfile* *loaded-files*))
            *)
	  (full-file-name (car !args)))))

(advise-around 
 'defun
 '(progn (if (function-definedp (car !args))(putprop (car !args) 'redefined t))
	 (put-filepos !args) *))

(advise-around 
 'defmacro
 '(progn (if (function-definedp (car !args))(putprop (car !args) 'redefined t))
	 (put-filepos !args) *))

(defun folder-of (filename)
  "Get the folder of a file"
  (let* ((uf (full-file-name filename))
	 (sp (string-rightpos uf '("/"))))
    (substring 0 sp uf)))