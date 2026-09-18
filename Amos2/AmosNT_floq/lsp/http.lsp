;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013 Tore Risch, UDBL
;;; $RCSfile: http.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/09/10 20:11:04 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: HTTP utilities
;;; =============================================================
;;; $Log: http.lsp,v $
;;; Revision 1.1  2013/09/10 20:11:04  torer
;;; Get current Internet IP address
;;;
;;; =============================================================

(defun parse-url (url)
  (let ((prefix (substring 0 6 url))
	(body (substring 7 (1- (length url)) url))
	delim)
    (cond ((not (equal prefix "http://"))
           (error "Not a legal HTTP address" url))
	  ((setq delim (string-pos body "/"))
	   (cons (substring 0 (1- delim) body)
		 (substring delim (1- (length body)) body))))))

(defun grab-url (url)
  "Get the document at a given url as a string"
  (let* ((p (parse-url url))
         (host (car p))
	 (file (cdr p))
	 (s (open-socket host 80))
         (res (opentextstream))
         temp)
    (formatl s "GET " file  " HTTP/1.1" t
             "Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/x-shockwave-flash, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*" t
	     "User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322; InfoPath.1)" t
             "Host: " host t t)
    (flush s)
    (catch-error (loop (selectq (setq temp (read-charcode s))
				(10 )
				(13 (terpri res))
				(princ-charcode temp res))))
    (textstreamstring res)))

(defun get-my-ip ()
  "What is the IP address of my computer?"
  (catch-error(let* ((str(grab-url "http://user.it.uu.se/~torer/ip.php"))
		     (pos (string-pos str "http://"))
		     (tail (substring (+ pos 7) (1-(length str)) str)))
		(substring 0 (- (string-pos tail ">") 1) tail))))