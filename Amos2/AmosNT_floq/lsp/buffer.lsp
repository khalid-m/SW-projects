;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009 Lars Melander, UDBL
;;; $RCSfile: buffer.lsp,v $
;;; $Revision: 1.1 $ $Date: 2009/08/21 12:34:37 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: A simple, array-based FIFO buffer
;;; =============================================================
;;; $Log: buffer.lsp,v $
;;; Revision 1.1  2009/08/21 12:34:37  larme597
;;; Buffer documentation
;;;
;;; =============================================================

(document 
 (make-buffer size)
 "Return a buffer of size <size>. The buffer is light-weight and simple,
  with minimal error-checking"
 (buffer-emptyp buffer)
 "Is the buffer empty?" 
 (buffer-onep buffer)
 "Does buffer contain zero or one elements?"
 (buffer-fullp buffer)
 "Is buffer full?"
 (buffer-push buffer element)
 "Put an element in the buffer. If the buffer is already full, the buffer's
  behaviour becomes erroneous"
 (buffer-pop buffer)
 "Retrieve the first element in buffer. If the buffer is already empty,
  the buffer's behaviour becomes erroneous"
 (buffer-peek buffer)
 "Get the first element from buffer without removing it"
)
