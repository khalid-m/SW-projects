;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1998, 2003 Tore Risch, Johan Sandström, UDBL
;;;
;;; Description: Description: Amos II result printer
;;; =============================================================
;;; $Log: printer.lsp,v $
;;; Revision 1.23  2013/06/26 17:45:26  torer
;;; Reverting (CO-SLEEP)
;;;
;;; Revision 1.21  2013/03/23 12:38:25  torer
;;; Introducede delay between printing tuples of standard output so that emacs
;;; can handle CTRL-C for massive outputs. Variable _print-delay_
;;;
;;; Revision 1.20  2012/02/14 16:00:12  torer
;;; Could not delete functions
;;;
;;; Revision 1.19  2012/02/12 09:32:45  torer
;;; Tuples were printed incorrectly
;;;
;;; Revision 1.18  2012/01/14 14:30:03  torer
;;; Nicer error messages
;;;
;;; Revision 1.17  2011/12/29 07:37:15  torer
;;; Introduced tuple types
;;;
;;; Revision 1.16  2011/12/22 12:55:16  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.15  2011/01/31 06:52:40  torer
;;; New function
;;;   output_lines(Number)->Number
;;; to control # lines to print on terminal
;;;
;;; Revision 1.14  2011/01/27 12:49:30  torer
;;; Print tuples as (...)
;;;
;;; Revision 1.13  2009/12/30 19:35:35  torer
;;; Printer for tuples
;;;
;;; Revision 1.12  2009/12/12 11:13:45  torer
;;; Generalized CALL-PRINTFN
;;;
;;; =============================================================

(defglobal _print-delay_ 0.01 "Delay between printing tuples on stdout")

(defun print-amosql-result (qres stream) 
  "Print the result of AmosQL evaluation QRES on STREAM"
  (cond ((eq qres 'no-result) nil)
	((or (atom qres)(tuplep qres))
	 (print-tuple qres stream)
	 (terpri stream))
	((bag-p qres)
	 (mapbag qres 
		 (f/l (row)
		      (print-tuple row stream)
                      (terpri stream)
                      (co-sleep _print-delay_)))) 
	(t (dolist
	       (tpl qres)
	     (print-tuple tpl stream)
	     (terpri stream)
             (co-sleep _print-delay_)))))

(defun print-tuple (tpl &optional stream fn place ltype print-oid-var-flag)
  "Print AmosQL tuple result TPL on STREAM"
  (cond ((vector-p tpl) 
	 (print-tuple1 "{" "}"
		       (arraytolist tpl) 
		       stream fn ltype print-oid-var-flag))
	((oid-p tpl)
	 (if print-oid-var-flag (princ (generate-new-oid-var tpl) stream)
	   (amosql-print-oid tpl stream)))
        ((tuplep tpl)(print-tuple1 "(" ")" (cdr tpl) stream fn 
				      ltype print-oid-var-flag))
	((bag-p tpl)
	 (print-tuple1 "bag(" ")"
		       (cdr tpl)
		       stream  fn ltype print-oid-var-flag))
	((call-printfn tpl stream)) 
	((atom tpl)
	 (if (and print-oid-var-flag (not tpl))
	     (princ (generate-null-inst fn place ltype) stream)
	   (prin1 tpl stream)))
	(t (print-tuple-list tpl stream fn place ltype print-oid-var-flag))))

(defun print-top-bag (b stream fn ltype print-oid-var-flag)
  (let (tflg)
    (mapbag 
     b 
     (f/l (row)
	  (if tflg (terpri stream)
	    (setq tflg t))
	  (if (cdr row) (print-tuple1 "(" ")" row stream fn 
				      ltype print-oid-var-flag)
	    (print-tuple1 "" "" row stream fn ltype print-oid-var-flag))))))

(defun print-tuple1 (btag etag l stream &optional fn ltype print-oid-var-flag)
  (princ btag stream)
  (let ((i 0))
    (while (consp l)	
      (cond ((call-printfn (car l) stream)
			;;; call user printer if any. Cannot be tuple here!
             )
            (t (print-tuple (car l) stream  fn i ltype print-oid-var-flag)))
      (setq i (+ i 1))
      (if (cdr l) (princ "," stream))
      (setq l (cdr l))))
  (princ etag stream))

(defun print-tuple-list (tpl &optional stream fn place ltype 
			     print-oid-var-flag)
  (cond ((cdr tpl)
	 (print-tuple1 "(" ")" 
		       tpl stream fn ltype print-oid-var-flag))
	((bag-p (car tpl))
	 (print-top-bag (car tpl) stream fn ltype print-oid-var-flag))
	(t (print-tuple1 "" "" tpl stream fn 
			 ltype print-oid-var-flag))))

(defglobal _output-lines_ nil "No of lines to print before 'More?' prompt")
(defun print-tuple-line (tpl)
  (print-tuple-list tpl)
  (terpri)
  (co-sleep _print-delay_)
  (cond ((not (and _output-lines_ (>= (1++ *lineno*) _output-lines_))))
	((confirm-prompt "More?")(setq *lineno* 0))
	(t (throw 'print-done))))

(defun call-printfn (o str)
  "Call user printfn function for (super) type of object O if present.
   Result NIL => no user printfn and default printfn used instead"
  (and (not (symbolp o))		; skip variable names
       (not (deleted-object o))
       (dolist (tp (arg-types o))
	 (let ((prfn (getobject tp 'printfn)))
	   (if prfn (return (funcall prfn o str)))))
       ))

(defun set-printfn (type printfn)
  "Set user printfn function for a type"
  (/putobject (gettypenamed type) 'printfn printfn))

(defun amosql-print-oid(x &optional str)
  (if (call-printfn x str) nil
      (proid x str nil))) ; default printer for OIDs

(defun stringify-amos-object (o)
   "Convert object O to string"
   (let ((s (opentextstream)))
      (print-tuple o s)
      (textstreamstring s)))

(defun print-amos-object (o str)
  "Print any object O on stream STR"
  (print-tuple o str))

(setq *object-printer* 'print-amos-object)

