;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2005 Tore Risch, UDBL
;;; $RCSfile: binary.lsp,v $
;;; $Revision: 1.1 $ $Date: 2005/09/16 12:00:01 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Measuring speed of binary data
;;;              
;;; ===========================================================================

(defvar stream (opentextstream 10000000))
(defun test-write-binary (size textual)
  (let (c1 c2 b sz)
    (closestream stream)		; rewind
    (setq b (if textual (make-array (/ size 4) :initial-element 1.2)
	      (make-binary size)))
    (setq c1 (clock))
    (print b stream)
    (setq c2 (clock))
    (setq sz (if textual (textstreampos stream)
	       (+ size 13)))
    (formatl t "Time to write " sz " bytes: " 
	     (/ (/ sz 1000000.0)
		(- c2 c1)) " MB/s" t)
    ))

;;; X40:
;;; Binary: 8.0 MB/s (old impl. moving 1 byte at the time)
;;; Textual: 2.55 MB/s
;;; Bulk write: 513 MB/s
