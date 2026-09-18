;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Tore Risch & Andrej Andrejev, UDBL
;;; $RCSfile: grab.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/08/09 14:26:34 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: HTTP protocol support
;;; =============================================================
;;; $Log: grab.lsp,v $
;;; Revision 1.1  2013/08/09 14:26:34  silvias
;;; *** empty log message ***
;;;
;;; Revision 1.4  2012/11/05 23:10:42  andan342
;;; LOAD() functition now reads remote Turtle files via HTTP
;;;
;;; Revision 1.3  2012/03/19 22:02:52  andan342
;;; Fixed memory leaks, excessive calls, configurability
;;;
;;; Revision 1.2  2012/02/23 19:15:38  andan342
;;; - Using _sq_ prefix for all SSDM switches, changed how _sq_default_triples_fn_ is used,
;;; - _sq_load_triples_ doesn't have to check for file existance,
;;; - URI-id function made reversible
;;;
;;; Revision 1.1  2012/02/18 00:25:20  andan342
;;; Chelonia-to-Amos connectivity: read-only
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(unless (boundp 'nl_cr)
;  (load "../../lsp/grm/chunked-read-token.lsp"))
  (load "chunked-read-token.lsp"))

(defvar _http_buffer_size_ 4096)

(defun parse-url (url)
  (let ((prefix (substring 0 6 url))
	(body (substring 7 (1- (length url)) url))
	delim host port file)
    (cond ((not (equal prefix "http://"))
           (error "Not a legal HTTP address" url))
	  ((setq delim (string-pos body "/"))
	   (setq host (substring 0 (1- delim) body))
	   (setq file (substring delim (1- (length body)) body))
	   (if (setq delim (string-pos host ":"))
	       (list (substring 0 (1- delim) host)
		     (read (substring (1+ delim) (1- (length host)) host))
		     file)
	     (list host 80 file)))
	  (t (list body 80 "/")))))

(defun send-url-get (url)
  (let* ((p (parse-url url))
         (host (first p))
	 (port (second p))
	 (file (third p))
	 (s (open-socket host port)))
    (formatl s "GET " file  " HTTP/1.1" t
	     "User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322; InfoPath.1)" t
             "Host: " host ":" port t t)
    (flush s)
    s))

(defun ping-url (url)
  (let ((s (catch-error (send-url-get url))))
    (when (and (not (error? s)) (poll-socket s 5)) s)))


(defun dump-http (url)
  (let ((s (send-url-get url)) ln)
    (while (not (eq (setq ln (read-line s)) '*eof*))
      (print ln))))


(defun get-url-chunked-stream (url)
  "Returns CHUNKED-STREAM if URI is available for download"
  (let ((s (send-url-get url)) ln chunked length end-of-chunks)
    (setq ln (read-line s))
    (if (equal (read (substring 9 11 ln)) 200) ; HTTP response OK, return NIL otherwise
	(while (not (equal (setq ln (read-line s)) ""))
	  (cond ((string-like ln "Transfer-Encoding:*chunked")
		 (setq chunked t)) ; TODO: not tested with chunked transfer
		((string-like ln "Content-Length: *")
		 (setq length (read (substring (length "Content-Length: ")
					   (length ln) ln))))))
      (setq s nil)) ; no result, return first line of response
    (cond ((null s) ln)
	  (chunked (make-chunked-stream :next-fn (f/l () (let ((clen (if end-of-chunks 0 (read-oct s))) ts)
							   (setq end-of-chunks (= clen 0))
							   (unless end-of-chunks
							     (setq ts (opentextstream))
							     (read-line s)
							     (princ (read-bytes clen s) ts)
							     (read-line s)
							     (textstreampos ts 0)
							     ts)))))
	  (length (make-chunked-stream :next-fn (f/l () (let ((clen (min length _http_buffer_size_)) ts)
							  (when (> length 0)
							    (setq ts (opentextstream))
							    (princ (read-bytes (1- clen) s) ts) ; last byte problem
							    (princ (int-char (read-charcode s)) ts) ; workaround
							    (setq length (- length clen)) 
							    (textstreampos ts 0)
							    ts)))))
	  (t (error "Invalid response to HTTP GET")))))


								   
						
