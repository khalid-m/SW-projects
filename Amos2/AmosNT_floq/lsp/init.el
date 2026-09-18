
;;; =======================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2004 Tore Risch, UDBL
;;; $RCSfile: init.el,v $
;;; $Revision: 1.14 $ $Date: 2013/10/30 19:29:21 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Emacs extensions for avoiding mouse arm 
;;; when working with Alisp
;;;              
;;; =======================================================================

;;; Make this your EMACS init file.

;;; Make EMACS save 4 generations of each file:

(setq version-control t)
(setq dired-kept-versions 4)

(load "ffap")

;;; The infamous ' bug fixed:
(setq 
 comint-mode-hook
 #'(lambda ()
     (defun comint-arguments (string nth mth)
       "Return from STRING the NTH to MTH arguments.
NTH and/or MTH can be nil, which means the last argument.
Returned arguments are separated by single spaces.
We assume whitespace separates arguments, except within quotes.
Also, a run of one or more of a single character
in `comint-delimiter-argument-list' is a separate argument.
Argument 0 is the command name."
       (let ((arg-regexp "\\(?:[^ \n\t\"`]+\\|\"[^\"]*\"\\|`[^`]*`\\)+")
	     (args nil)
	     (pos 0)
	     (count 0))
	 (when comint-delimiter-argument-list
	   (setq arg-regexp
		 (format "[%s]\\|%s"
			 (regexp-quote (concat 
					comint-delimiter-argument-list))
			 arg-regexp)))
	 (while (and (string-match arg-regexp string pos)
		     (or (null mth) (<= count mth)))
	   (when (or (null nth) (<= nth count))
	     (push (substring string (match-beginning 0) (match-end 0)) 
		   args))
	   (setq pos (match-end 0))
	   (incf count))
	 (if (null nth)
	     (or (car args) "")
	   (mapconcat 'identity (nreverse args) " "))))
     ))

(defun after: (str)
  (and str (let ((pos (string-match ":" str)))
	     (if pos (substring str (1+ pos))))))

(defun before: (str)
  (substring str 0 (string-match ":" str)))

(defun goto-file-at-point ()
  (interactive)
  (let ((str (ffap-string-at-point))
	(reg ffap-string-at-point-region)
	pos)
    (cond ((and str (not (equal str ""))(file-exists-p str)) 
	   (forward-char (- (cadr reg)(point) -1))
           (if (equal (ffap-string-at-point) "")
	       (forward-char 1))
	   (setq pos (string-to-number(ffap-string-at-point)))
	   (find-file-other-window str)
	   (goto-line pos)
	   pos
           )
          (t 
	   (let* ((s1 (after: str))
		  (pos (after: s1))
		  (file (and s1 pos (concat (before: str) ":" 
					    (before: s1)))))
	     (cond ((and file (file-exists-p file))
		    (find-file-other-window file)
		    (goto-line (string-to-number pos)))
		   (t (princ (concat "Error: '" str 
				     "' is not a file")))))))))

;;; F1: Jump to file position printed by Amos II's APROPOS, FP, etc.
;;; F2: send Lisp form at cursor for evaluation in other window
;;;     that must be Amos II shell in Lisp mode
;;; F3: set mark
;;; F4: undo

(cond ((null (functionp 'execute-command))
       (defun execute-command (x)(eval (list x)))))


(cond ((functionp 'copy-primary-selection)
       (font-lock-mode)
       (defun send-current-form-for-eval ()
	 (interactive)
	 (execute-kbd-macro "\C- \M-E")
	 (copy-primary-selection)
	 (execute-kbd-macro "\C-Xo\M-Xshell
\M->\C-Y\C-m\C-Xo")
	 ))
      (t (defun send-current-form-for-eval ()
	   (interactive)
	   (set-mark-command nil)
	   (execute-kbd-macro "\M-E")
           (command-execute 'copy-region-as-kill)
           (execute-kbd-macro "\C-Xo")
           (command-execute 'shell)
           (execute-kbd-macro "\C-Y")
           (command-execute 'comint-send-input)
           (execute-kbd-macro "\C-Xo")
	   ) 
	 ;;
	 ;; Highlight syntax:
	 (if (null global-font-lock-mode) 
	     (execute-command 'global-font-lock-mode))
	 ))

(global-set-key [f1] 'goto-file-at-point) 
(global-set-key [f2] 'send-current-form-for-eval)
(global-set-key [f3] 'set-mark-command)
(global-set-key [f4] 'undo)

;;; Windows only:
;;; Make files created by EMACS use NOTEPAD CR-conventions:

(cond ((functionp 'set-default-buffer-file-coding-system)
       (set-buffer-file-coding-system 'no-conversion-dos)
       (set-default-buffer-file-c
oding-system 'no-conversion-dos))) 

;;; MacHack:
(setq emulate-mac-finnish-keyboard-mode t)
(setq mac-option-key-is-meta nil)
(setq mac-command-key-is-meta t)
(setq mac-command-modifier 'meta)
(setq mac-option-modifier nil)
