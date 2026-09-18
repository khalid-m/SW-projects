;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Andrej Andrejev, UDBL
;;; $RCSfile: chunked-read-token.lsp,v $
;;; $Revision: 1.4 $ $Date: 2012/11/05 23:10:42 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: READ-TOKEN wrapper for chunked streams
;;; =============================================================
;;; $Log: chunked-read-token.lsp,v $
;;; Revision 1.4  2012/11/05 23:10:42  andan342
;;; LOAD() functition now reads remote Turtle files via HTTP
;;;
;;; Revision 1.3  2012/03/17 21:39:36  andan342
;;; - Added debug functionality, including _chelonia_dub_results_ switch
;;;
;;; Revision 1.2  2012/02/21 11:03:47  andan342
;;; Amos-to-Chelonia interface with updates (except inserting arrays)
;;;
;;; Revision 1.1  2012/02/18 00:25:20  andan342
;;; Chelonia-to-Amos connectivity: read-only
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(defparameter nl_cr (concat (int-char 13) (int-char 10))) ; 0x0D0A

(defparameter lisp_reader_ws (concat nl_cr (int-char 9) (int-char 32))) ; + space + tab

(defparameter lisp_reader_breaks "()[]{}\\\"', ;~") 
;;characters disallowed in lisp symbols

(defstruct chunked-stream s next-fn dubbed)

(defun dub-stream (ts)
  "Print contents of a text stream before processing it"
  (formatl nil "DUB:" (read-token ts "" "" t t) t)
  (textstreampos ts 0))

(defun chunked-stream-dub (cs)
  "Start dubbing a chunked stream"
  (when (chunked-stream-s cs) (dub-stream (chunked-stream-s cs)))
  (setf (chunked-stream-dubbed cs) t))

(defun chunked-stream-flip (cs)
  "Advance to the next chunk in a stream"
  (setf (chunked-stream-s cs) (funcall (chunked-stream-next-fn cs)))
  (when (and (chunked-stream-s cs) (chunked-stream-dubbed cs))
    (dub-stream (chunked-stream-s cs)))
  (chunked-stream-s cs))

(defun print-chunks (cs limit)
  "Print up to LIMIT chunks from CS as strings, return either NIL or *EOF*"
  (let (chunk)
    (dotimes (i limit)
      (unless (or (chunked-stream-s cs) (chunked-stream-flip cs))
	(return nil))
      (setq chunk (read-token (chunked-stream-s cs) "" "" t t)) ;read everything till *EOF*
      (print chunk)
      (when (eq chunk '*eof*) 
	(return chunk))
      (setf (chunked-stream-s cs) nil))))

(defun chunked-read-charcode (cs)
  (let ((res (when (chunked-stream-s cs)
	       (read-charcode (chunked-stream-s cs)))))
    (if (and res (not (eq res '*eof*))) res
      (if (chunked-stream-flip cs) ; read second time if EOF was encountered
	  (read-charcode (chunked-stream-s cs)) 
	'*eof*)))) ; end of all streams

(defun chunked-unread-charcode (x cs) ; TODO: might fail if the new chunk stream was just created
  (if (chunked-stream-s cs)
      (unread-charcode x (chunked-stream-s cs)) ; do conventional unread-charcode on the current stream
    (progn ; create a new stream just to store this char
      (setf (chunked-stream-s cs) (opentextstream))
      (princ (int-char x) (chunked-stream-s cs))
      (textstreampos (chunked-stream-s cs) 0)
      x)))

(defun number-or-id (token strnum)
  "Unless STRNUM attempt to convert TOKEN to a number, return string otherwise"
  (let ((res (and (not strnum) (read token)))) ; NIL or READ result
    (if (numberp res) res token)))

(defun chunked-read-token (cs &optional ws brks strnum nostrings)
  "READ-TOKEN equivalent for CHUNKED-STREAM,
   NEXT-FN should return NIL or empty stream for *EOF*, might be called 1 extra time after NIL"
  (unless ws (setq ws lisp_reader_ws)) ; default values
  (unless brks (setq brks lisp_reader_breaks))
  (let ((outside-brks (concat ws brks (if nostrings "" "\"")))
	flip cc token1 token2 (res "") (state :outside))	     
    (while t
      (setq flip (null (chunked-stream-s cs)))
      (when flip ; try to get a stream on next chunk
	(unless (chunked-stream-flip cs) ; if no next chunk ->
	  (return (if token2 (number-or-id token2 strnum) ; return previous token if pending
		    '*eof*)))) ; END of all chunks
      (setq token1 (selectq state
			    (:outside (read-token (chunked-stream-s cs) "" outside-brks t t))
			    (:inside (read-token (chunked-stream-s cs) "" "\"\\" t t))
			    (if (eq (setq cc (read-charcode (chunked-stream-s cs))) '*eof*) 
				cc (int-char cc)))) ; escape states
      (cond ((eq token1 '*eof*) 
	     (if flip ; if just flipped -> 
		 (return (if token2 (number-or-id token2 strnum) ; return previous token if pending
			   '*eof*)) ; END of all chunks
	       (setf (chunked-stream-s cs) nil))) ; end of this chunk -> flip	    
	    ((eq state :inside)
	     (cond ((string= token1 "\\") (setq state :esc1)) ; beginning of escape sequence
		   ((string= token1 "\"") (return res)) ; return string 
		   (t (setq res (concat res token1))))) ; unfinished string - store in RES
	    ((eq state :esc1) 
	     (setq state :esc2)) ; ignore token
	    ((eq state :esc2) 
	     (setq res (concat res token1))) ; store escaped char in RES
	    ; :outside state assumed
	    ((and (not nostrings) (string= token1 "\"")) ; if beginning of string ->
	     (if token2 (progn (unread-charcode (char-int token1) (chunked-stream-s cs))
			       (return (number-or-id token2 strnum))) ; return previous token
	       (setq state :inside))) ; start reading string
	    ((and (= (length token1) 1) (string-pos ws token1)) ; if WS -> return previous token
	     (when token2 (progn (unread-charcode (char-int token1) (chunked-stream-s cs))
			    (return (number-or-id token2 strnum)))))
	    ((and (= (length token1) 1) (string-pos brks token1)) ; if BRKS-token ->
	     (if token2 (progn (unread-charcode (char-int token1) (chunked-stream-s cs))
			       (return (number-or-id token2 strnum))) ; return previous token
	       (return token1))) ; return BRKS-token
	    (t ; merge simple tokens, return at WS, BRKS, ", or final '*EOF*
	     (setq token2 (if token2 (concat token2 token1) token1)))))))

(defun chunked-read-line (cs)
  "READ-LINE equivalent for CHUNKED-STREAM"
  (chunked-read-token cs nl_cr "" t t))
