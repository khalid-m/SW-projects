(defun server-edit-files-quickly (list &rest flags)
  (gnuserv-edit-files '(mswindows) list (or flags 'quick)))
(defun server-edit-files (list &rest flags)
  (gnuserv-edit-files '(mswindows) list))

;; start gnuserv on Windows 
(progn 
      (require 'gnuserv) 
      (setq server-done-function 'bury-buffer 
      gnuserv-frame (car (frame-list))) 
      (gnuserv-start) 
      ;;; open buffer in existing frame instead of creating new one... 
      (setq gnuserv-frame (selected-frame)) 
      (message "gnuserv started."))
