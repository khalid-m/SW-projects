;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2008 Manivasakan Sabesan, UDBL
;;; $RCSfile: record.lsp,v $
;;; $Revision: 1.13 $ $Date: 2013/12/18 13:11:42 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Record acccess functions
;;; =============================================================
;;; $Log: record.lsp,v $
;;; Revision 1.13  2013/12/18 13:11:42  torer
;;; removed function record(), replaced with make_record()
;;; New function empty_record()
;;;
;;; Revision 1.12  2013/10/28 19:52:16  torer
;;; Removed record type SSRC
;;;
;;; Revision 1.11  2012/09/06 20:49:18  torer
;;; (MERGE-RECORDS R1 R2) now applicative
;;;
;;; Revision 1.10  2010/01/21 07:46:32  torer
;;; Records printed with JSON syntax
;;;
;;; Revision 1.9  2010/01/20 09:19:18  torer
;;; record_length returns the number of key/value pairs
;;;
;;; Revision 1.8  2010/01/19 22:37:00  torer
;;; More robust VREF
;;;
;;; Revision 1.7  2009/12/15 17:14:58  zeitler
;;; record-keys obtains all keys from a record
;;; merge-records extends and replaces attributes of a default record
;;;
;;; Revision 1.6  2009/09/02 12:44:09  zeitler
;;; OSQL record/streamsrc printer
;;;
;;; Revision 1.5  2009/09/01 13:57:52  zeitler
;;; record and streamsrc types
;;;
;;; Revision 1.3  2009/08/20 17:41:10  zeitler
;;; - Record is extended with /kind/ attribute
;;; - kind 1 is used to carry stream source definitions
;;;
;;; Revision 1.2  2009/04/07 13:24:05  zeitler
;;; recordp
;;;
;;; Revision 1.1  2008/10/03 14:27:31  zeitler
;;; Added Sabesan's record access functions
;;;
;;; =============================================================

(defglobal _record_
  (createliteraltype 'Record (list(gettypenamed 'collection)) 
		     'Record #'print-record))

(defun recordp (o)
  (eq (typename o) 'RECORD))

(defun print-record (r str)
  (let ((kl (record-keys r)) (first t))
    (cond ((null kl)(princ "empty_record()" str))
	  (t (princ "{" str)
	     (dolist (k kl)
	       (if first (setq first nil) (princ "," str))
	       (print-amos-object k str)
	       (princ ":" str)
	       (print-amos-object (record-get r k) str))
	     (princ "}" str)))))

(defun record-keys (R)
  (let ((l (tconc)))
    (maparray (record-fields R)
	      (f/l (x i)
		   (and (eq 0 (mod i 2))
			(tconc l x))))
    (car l)))

(defun merge-records (r def)
  "Non-destructive merge of two records"
  (let ((new (make-record (copy-array (record-fields def)))))
    (mapc
     (f/l (key)
	  (record-put new key (record-get r key)))
     (record-keys r))
    new))

(defun makerecord(fno v r) 
  (osql-result v (make-record v)))

(defun put_record(fno v k val r) 
  (osql-result v k val (record-put v k val)))

(defun merge-records--+ (fno x y r)
  (osql-result x y (merge-records x y)))

(defun vref-bbf(fno H K R) 
  (if (recordp h) 
      (let ((R (record-get H K))) 
	(if R (osql-result H K R)))))

(defun vref-bff(fno H K R) 
  (if (recordp h)
      (do ((I 0 (+ 2 I)))
	  ((= I (Length (record-fields H))))
	(osql-result H (aref (record-fields H) I) 
		     (aref (record-fields H) (+ 1 I))))))

(defun vref_any_bbf(fno H I R) 
  (osql-result H I (aref (record-fields H) I)))

(defun vref_any_bff(fno H K R) 
  (do ((I 0 (+ 2 I)))
      ((= I (Length (record-fields H))))
    (osql-result H I (aref (record-fields H)(+ 1 I)))))

(defun all_value(fno H R) 
  (do ((I 0 (+ 1 I)))
      ((= I (Length (record-fields H))))
    (osql-result H (aref (record-fields H) I))))

(defun record-length(fno H R)
  (osql-result H  (/ (Length (record-fields H)) 2)))

;define sequence
(set-alias-name 'sequence 'vector  _type_)
(set-alias-name 'sequence 'vector  _function_)
