;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Tore Risch, UDBL
;;; $RCSfile: json.lsp,v $
;;; $Revision: 1.3 $ $Date: 2011/10/17 09:33:15 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: JSON-reader/printer in Lisp
;;; =============================================================
;;; $Log: json.lsp,v $
;;; Revision 1.3  2011/10/17 09:33:15  chexu484
;;; bug fixed
;;;
;;; Revision 1.2  2011/10/10 17:40:34  torer
;;; bug
;;;
;;; Revision 1.1  2011/10/10 17:26:11  torer
;;; JSON reader and writer
;;;
;;; =============================================================

(defglobal _json-breakchars_ "{},[]:\"")

(defun json-read (stream)
  (let ((token (read-token stream nil _json-breakchars_)))
    (cond ((equal token "{")
	   (json-read-dict stream))
          ((equal token "[")
	   (json-read-sequence stream))
          ((json-nobreakchar))
          (t token))))

(defun json-illegal-token (token)
   (error "Illegal JSON token" token))

(defun json-skip (stream char)
  (let ((token (read-token stream nil _json-breakchars_)))
    (if (equal token char)nil
      (json-illegal-token token))))

(defun json-read-dict (stream)
  (let (token (pairs (tconc)))
    (loop
      (setq token (read-token stream nil _json-breakchars_))
      (cond ((equal token "}") 
	     (return (make-record (listtoarray (car pairs)))))
            ((equal token ",") )
            ((json-nobreakchar token ":"))
            (t (tconc pairs token)
	       (json-skip stream ":")
	       (tconc pairs (json-read stream)))))))

(defun json-nobreakchar (char &optional except)
  (and (stringp char)(string-pos _json-breakchars_ char)
       (not (equal char except))
       (json-illegal-token char)))

(defun json-read-sequence (stream)
  (let (token (l (tconc)))
    (loop
      (setq token (json-read stream))
      (cond ((equal token "]") 
	     (return (listtoarray (car l))))
            ((equal token ",") nil)
            ((json-nobreakchar token))
            (t (tconc l token))))))

(defun json-print (x stream)
   (json-prin1 x stream)(terpri stream) x)

(defun json-prin1 (x stream)
  (cond ((stringp x)(prin1 x stream))
	((numberp x)(prin1 x stream))
	((arrayp x)
	 (let ((first t))
           (princ "[" stream)
           (maparray x (f/l (e i) 
			    (if first (setq first nil)
			      (princ "," stream))
			    (json-prin1 e stream)))
           (princ "]" stream)))
	((recordp x)
         (let ((first t) colon)
           (princ "{" stream)
           (maparray (record-fields x)
		     (f/l (e i)
			  (if (or first colon) (setq first nil)
			    (princ "," stream))
			  (cond (colon (princ ":" stream)
				       (json-prin1 e stream)
				       (setq colon nil))
				((atom e) (json-prin1 e stream)
				 (setq colon t))
                                (t (error "Not a legal JSON structure" e)))))
	   (princ "}" stream)))
	(t (error "Not a legal JSON structure" x))))