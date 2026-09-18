;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Tore Risch, UDBL
;;; $RCSfile: server.lsp,v $
;;; $Revision: 1.1 $ $Date: 2009/12/03 15:59:03 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Lisp part of server creation script for 
;;;              Course Manager database
;;; =============================================================
;;; $Log: server.lsp,v $
;;; Revision 1.1  2009/12/03 15:59:03  silvias
;;; *** empty log message ***
;;;
;;; Revision 1.3  2008/12/05 15:18:18  udbl
;;; CourseManager fixes:
;;; _PERSISTENT-INTERFACE-VARIABLES_
;;; more files are copied
;;;
;;; Revision 1.2  2007/03/23 10:23:44  udbl
;;; - email is sent to students when assignment status is updated
;;; - all assignment status updates are logged in worksOn(student, assignment)-><status,timeval>
;;;
;;; Revision 1.1  2007/03/18 10:52:22  torer
;;; Created separate Lisp source file for CM server image creation script
;;;
;;; =============================================================

(defun println--- (fno string file mode)
  "Timours PRINTLN AmosQL function"
  (let ((stream
	 (if file
	     (openstream file mode))))
    (formatl stream string t)
    (closestream stream)))

(defun read-line (s)
  "Read until LF on stream S"
  (let ((res (opentextstream)) temp)
    (while (neq (setq temp (read-charcode s)) 10)
      (princ-charcode temp res))
    (textstreamstring res)))

(defun send-line (ret msg s)
  "Send message on stream then read line and check if begins with ret"
  (send-msg msg s)
  (let ((res (read-line s)))
    (cond ((equal ret (substring 0 (1- (length ret)) res)) 
           (sleep 0.01)			
           res))))

(defun send-msg (msg s)
  "Send message on stream"
  (prog1 (princ msg s)(princ-charcode 13 s) (terpri s)(flush s)))   

(defun smtp-sendmail (host from to subject message)
  "SMTP sendmail from Lisp"
  (let ((s (open-socket host 25)))
    (unwind-protect
	(and (send-line "220" "HELO somewhere.at" s)
	     (send-line "250" (concat "MAIL FROM: <" from ">") s)
	     (send-line "250" (concat "RCPT TO: <" to ">") s)
	     (send-msg "DATA " s)
	     (send-msg (concat "SUBJECT: " subject) s)
	     (send-msg message s)
	     (send-msg "." s)
	     (send-line "250" "QUIT" s)
	     to)
      (closestream s))))

(defun amosql-sendmail (fno host from to subject message conf_mess)
  "Implementation of foreign function SMTP_SENDMAIL"
  (smtp-sendmail host from to subject message)
  (osql-result host from to subject message 
	       "The message has been sent succsessfully"))

(defun generate-server (fno id home option)
  "Implements AmosQL function to generate server image for a given database ID"
  (let (image log)
    (setq image (concat home "/WEB-INF/" id "_server.dmp"))
    (setq log (concat home "/WEB-INF/" id "_server.log"))
    (if (equal option "recover")
	(load-amosql (concat home "/courses/" id "_unload.osql"))
      (load-amosql (concat home "/courses/" id ".osql")))
    (formatl t "Server log: " log t)
    (register-init-form `(progn (redirect-basic-stdout , log)
				(trace-packets t) 
				(cd , home)))
    (formatl t "Server image: " image t)
    (setfunction 'CourseId () (list id)) ; set current course id in server
    (saveimage image)
    (quit)))

(setq _PERSISTENT-INTERFACE-VARIABLES_ t)
(setq _batch_ t)

