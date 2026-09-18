;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2011 Lars Melander , UDBL
;;; $RCSfile: strings.lsp,v $
;;; $Revision: 1.7 $ $Date: 2014/01/16 00:40:52 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: extra string functions
;;; =============================================================
;;; $Log: strings.lsp,v $
;;; Revision 1.7  2014/01/16 00:40:52  andan342
;;; STRING-RIGHTPOS now takes search chars as a list, and an opional argument DOWNTO
;;;
;;; Revision 1.6  2014/01/03 15:59:06  andan342
;;; Fixed bug in string-substitute, added HTML streaming utilitites
;;;
;;; Revision 1.5  2013/01/10 13:10:46  andan342
;;; Disabled stacked substitutions in STRING-SUBSTITUTE, for multistep substitutions calls to STRING-SUBSTITUTE should be stacked explicitly
;;;
;;; Revision 1.4  2013/01/10 12:18:20  andan342
;;; Added string-remove-cont-duplicates & string-substitute
;;;
;;; Revision 1.3  2012/09/06 13:47:13  andan342
;;; Added escape-string function
;;;
;;; Revision 1.2  2012/02/09 23:07:20  andan342
;;; Since utils.lsp is not in use, moved STRING-REPLACE-CHAR, STRING-RIGHTPOS, LEFTPAD to strings.lsp
;;;
;;; Revision 1.1  2011/10/25 14:10:21  larme597
;;; Documentation for extra string functions.
;;;
;;; =============================================================

(document 
 (string-find string string-to-find)
 "Find the first occurence of \"string-to-find\" in \"string\",
  or nil if not found."
 (string-explode string delimiter)
 "Return a string list of \"string\" divided by \"delimiter\"."
)


(defun string-replace-char (str char new-char) 
  "Change all occurences of CHAR in STR to NEW-CHAR"
  (if (string= char new-char) str
    (do ((cp nil) (strlast nil)) (nil t) ;never return normally
      (setq cp (string-pos str char))
      (if cp (progn
	       (setq strlast (1- (length str)))
	       (setq str (concat (if (= cp 0) "" (substring 0 (1- cp) str)) new-char
				 (if (= cp strlast) "" (substring (1+ cp) strlast str)))))
	(return str)))))

(defun string-rightpos (str chars &optional downto)
  "Right-to-left version of string-pos"
  (do ((pos (1- (length str)) (1- pos)) (ch nil) (res nil))
      ((< pos (if downto downto 0)) nil)
    (setq ch (substring pos pos str))
    (setq res (dolist (c chars)
		(when (string= ch c)
		  (return pos))))
    (when res (return res))))

(defun leftpad (str padchar width)
  "Pad the string with chars on the left"
  (let ((res (with-string s (princ str s))))
    (dotimes (i (- width (length res)))
      (setq res (concat padchar res)))
    res))


(defun escape-string (str escaped-chars)
  "Add a backslash before each ESCAPED-CHARS character or backslash inside STR"
  (let* ((i (1- (length str))) cc)
    (while (>= i 0)
      (setq cc (substring i i str)) 
      (when (or (string-pos escaped-chars cc) (string= cc "\\"))
	(setq str (concat (if (= i 0) "" (substring 0 (1- i) str)) "\\"
			  (substring i (1- (length str)) str))))
      (decf i))
    str))


(defun string-remove-cont-duplicates (str char)
  "Remove continuous duplicate CHAR occurences from STR, leaving only 1 CHAR in each place"
  (let ((res str) (i 0) j)
    (while (< i (length res))
      (when (string= (substring i i res) char)
	(setq j (1+ i))
	(while (and (< j (length res)) 
		    (string= (substring j j res) char))
	  (incf j))
	(when (> (1- j) i)
	  (setq res (concat (substring 0 i res)
			    (substring j (1- (length res)) res)))))
      (incf i))
    res))

(defun string-substitute (str pairs)
  "Substitute all substrings A in STR to B, given priority-descending list PAIRS of (A . B)"
  (let ((res str) (i 0) plen
	(minplen (apply #'min (mapcar (f/l (pair) (length (car pair))) pairs))))
    (unless (> minplen 0)
      (error "Cannot substitute empty substrings!"))
    (while (<= i (- (length res) minplen))
      (unless (dolist (pair pairs)
		(setq plen (length (car pair)))
		(when (and (<= i (- (length res) plen))
			   (string= (substring i (+ i plen -1) res) (car pair)))
		  (setq res (concat (if (> i 0) (substring 0 (1- i) res) "")
				    (cdr pair)
				    (substring (+ i plen) (1- (length res)) res)))
		  (incf i (length (cdr pair)))
		  (return t)))
	(incf i)))
    res))


;;;;;;;;;;;;;;;;;;;;;;;;;;; HTML streaming utilities

(defun string-to-html-stream (str hs)
  "Escape < & >, whitespaces in the beginning of the line, translate line breaks to <br>"
  (do ((escape-pairs '(("<" . "&lt;") (">" . "&gt;") ("&" . "&amp;")))
       (state :default) (len (length str)) (i 0 (1+ i)) (ch nil) (escape-pair nil))
      ((> i len) nil)
    (setq ch (substring i i str))
    (cond ((member (char-int ch) '(10 13))
	   (when (eq state :default) 
	     (setq state :after-newline)
	     (formatl hs "<br>")))
	  ((string= ch " ")
	   (formatl hs (if (eq state :after-newline) "&nbsp;" " ")))
	  ((setq escape-pair (assoc ch escape-pairs))
	   (setq state :default)
	   (formatl hs (cdr escape-pair)))
	  (t
	   (setq state :default)
	   (formatl hs ch)))))
    
(defun row-to-html-stream (cells hs)
  "Write an HTML row of trimmed and escaped CELLS"
  (let ((trim-chars (concat (int-char 10) (int-char 13) " ")))
    (formatl hs "<tr>")
    (dolist (cell cells)
      (formatl hs "<td>")
      (string-to-html-stream (string-trim trim-chars cell) hs)
      (formatl hs "</td>"))
    (formatl hs "</tr>")))