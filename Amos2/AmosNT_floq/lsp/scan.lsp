;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009 Lars Melander, UDBL
;;; $RCSfile: scan.lsp,v $
;;; $Revision: 1.25 $ $Date: 2012/11/02 07:12:52 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Functions for handling buffered scans
;;; =============================================================
;;; $Log: scan.lsp,v $
;;; Revision 1.25  2012/11/02 07:12:52  torer
;;; The dispatch between command and query in client again temporarily
;;;
;;; Revision 1.24  2012/11/01 20:35:39  torer
;;; OPEN-QUERY-SCAN() now returns scans for queries and objects for commands
;;; This makes all commands be executed immediately.
;;;
;;; Revision 1.23  2012/08/23 13:00:31  larme597
;;; Buffer now takes timeout option when creating a scan.
;;;
;;; Revision 1.22  2012/08/22 16:06:43  larme597
;;; Fixed catching reset throw.
;;;
;;; Revision 1.21  2012/08/21 15:51:44  larme597
;;; Improved scan handler functions.
;;;
;;; Revision 1.20  2012/07/26 20:14:06  torer
;;; Error handling in remote scans
;;;
;;; Revision 1.19  2012/07/17 16:26:39  torer
;;; query-scan-handler using map-query
;;;
;;; Revision 1.18  2012/06/27 19:20:06  torer
;;; options in custom C functions passed as property list to scan functions
;;;
;;; Revision 1.17  2012/06/27 09:25:33  larme597
;;; Storing socket in scan object when using server-side scan.
;;;
;;; Revision 1.16  2012/06/08 17:00:47  larme597
;;; Better scans. Remote scans now send entire buffer.
;;;
;;; Revision 1.15  2012/05/04 09:16:06  larme597
;;; Buffer size now is correct, and not one less than stated.
;;;
;;; Revision 1.14  2012/03/13 15:00:39  torer
;;; Late binding allowed in OPEN-FUNCTION-SCAN
;;;
;;; Revision 1.13  2011/12/14 12:35:42  larme597
;;; Scans can now handle streams.
;;;
;;; Revision 1.12  2011/11/15 15:12:53  larme597
;;; New scan next() function that takes a timeout.
;;;
;;; Revision 1.11  2011/02/12 16:42:31  torer
;;; Scans allowed over materialized bags
;;;
;;; Revision 1.10  2011/02/01 13:22:01  larme597
;;; Adding amos functions "this" and "peek" to scans.
;;;
;;; Revision 1.9  2011/01/27 21:05:12  torer
;;; Added nomore(Scan)
;;; and the PSM control structures 'loop' and 'while'
;;;
;;; Revision 1.8  2011/01/26 20:52:38  torer
;;; Scan interface functions + modified interface to storage type SCAN
;;;
;;; Revision 1.7  2011/01/21 18:09:13  larme597
;;; Added scan-peek function, for looking at next tuple in scan.
;;;
;;; Revision 1.6  2011/01/21 15:55:03  torer
;;; Foreign functions for scans
;;;
;;; Revision 1.5  2011/01/21 14:31:48  torer
;;; New storage type SCAN
;;;
;;; Revision 1.4  2010/09/10 14:29:52  larme597
;;; Added comments.
;;;
;;; Revision 1.3  2009/09/02 12:48:01  torer
;;; Removed dynamic closure
;;;
;;; Revision 1.2  2009/09/02 11:16:38  larme597
;;; Remove circular reference in open-query-scan
;;;
;;; Revision 1.1  2009/08/21 12:26:29  larme597
;;; Adding scan functions
;;;
;;; =============================================================

(defglobal _scan-buffersize_ 20
  "Global variable holding the default buffer size for a scan")

(defun open-query-scan (query &optional options traperrors)
  "Return a new scan based on a query or command"
  (initialize-scan (function query-scan-handler) 
		   query nil options traperrors))

(defun open-function-scan (fno args &optional options traperrors)
  "Return a new scan based on result of applying Amos function fno on args."
  (initialize-scan (function function-scan-handler)
		   (resolvename fno args) args options traperrors))

(defun open-bag-scan (bag &optional options traperrors)
  "Return a new scan on a bag."
  (initialize-scan (function bag-scan-handler) bag nil options traperrors))

(defun initialize-scan (scan-handler fno args &optional options traperrors)
  "Return a new scan. The Lisp function scan-handler with parameters 
   fno and args is set up to yield one value at a time. 
   The scan is set up using a coroutine,
   and in order to speed things up a buffer is used. If buffersize is
   not set or is less than 2, the global variable _scan-buffersize_
   is used, the default value of which is 20."
  (let* ((b (make-buffer (or (getf options :buffersize) _scan-buffersize_)
			 (getf options :timeout)))
	 (co (coroutine (function apply-scan-handler)
			(list scan-handler fno args b traperrors))))
    (make-scan b co (getf options :timeout)
	       (and *client-port* (port-socket *client-port*)) ; Using sockets?
	       )))

(defun apply-scan-handler (scan-handler fno args b traperrors)
  (catch 'reset
    (cond ((null traperrors) (funcall scan-handler fno args b))
	  (t (let* ((savepoint _history_)
		    (res (catch-error (funcall scan-handler fno args b)
				      (rollback savepoint))))
	       (if (error? res) (scan-emit (annotate-form fno :error res) b) 
		 res)))))
  '*TERMINATED*)

(defun query-scan-handler (query dummy b)
  "Iterate over a scan over query or command on server"
  (map-query query (f/l (&rest row) (scan-mapper row b))))

(defun function-scan-handler (fno args b)
  "Iterate over a scan of applying amos function FNO on ARGS."
  (mapfunction fno args (f/l (row) (scan-mapper row b))))

(defun bag-scan-handler (bag dummy b)
  "Iterate over a scan of bag BAG."
  (mapbag bag (f/l (row) (scan-mapper row b))))

(defun scan-mapper (row b)
  (cond ((mapbag-able (car row))
	 (if (cdr row) (error "Cannot open scans over tuples of streams" row))
	 (mapbag (car row) (f/l (row2) (scan-mapper row2 b))))
	(t (scan-emit row b))))

(defun mapbag-able (x)
  (or (bag-p x) (generatorp x)))

(defun scan-emit (row b)
  "Emit row from scan."
  (buffer-push b row)
  (if (buffer-fullp b) (co-yield)))

(defun scan-nextrow (s)
  "Return the next row or tuple of the scan, or the string
   *terminated* if the scan has finished or closed. If the
   operation timed out and the buffer is empty, nil is
   returned."
  (scan-fillbuffer s)
  (cond ((not (buffer-emptyp (scan-buffer s)))
	 (scan-setcurrent s (buffer-pop (scan-buffer s))))
	((scan-terminated s)
	 (scan-setcurrent s (scan-terminated s)))
	(t nil)))

(defun scan-peek (s)
  "Have a look at what's next in the scan."
  (scan-fillbuffer s)
  (cond ((not (buffer-emptyp (scan-buffer s)))
	 (buffer-peek (scan-buffer s)))
	((scan-terminated s)
	 (scan-terminated s))
	(t nil)))

(defun scan-eos (s)
  "Have we retrieved the last available value from the scan?"
  (scan-fillbuffer s)
  (and (scan-terminated s)
       (buffer-emptyp (scan-buffer s))))

(defun scan-fillbuffer (s)
  (if (and (not (scan-terminated s))
	   (buffer-emptyp (scan-buffer s)))
      (scan-set-terminated s (co-resumet (scan-coroutine s)
					 (scan-timeout s)))))

(defun scan-set-terminated (s x)
;  (let ((co (scan-coroutine s)))
;    (if (co-terminated co)
;	(scan-terminate s))))
  (selectq x
	   (*terminated* (scan-terminate s) x)
	   x))

(defun scan-this (s)
  "Return the row or tuple that was retrieved by the previous
   scan-nextrow statement."
  (scan-getcurrent s))

(defun scan-close (s)
  "Close the scan. Further calls to scan-nextrow return
   the string *terminated*."
  (buffer-clear (scan-buffer s))
  (or (scan-terminated s)
      (scan-set-terminated s '*terminated*)))

(defun openscan-+ (fno b s)
  (osql-result b (open-bag-scan b)))

(defun scan.next-+ (fno s r)
  (let ((nxt (scan-nextrow s)))
    (selectq nxt
	     (*terminated* nil)
	     (osql-result s (listtoarray nxt)))))

(defun scan.next--+ (fno s r)
  (let ((nxt (scan-nextrow s)))
    (selectq nxt
	     (*terminated* nil)
	     (osql-result s (listtoarray nxt)))))

(defun scan.peek-+ (fno s r)
  (let ((nxt (scan-peek s)))
    (selectq nxt
	     (*terminated* nil)
	     (osql-result s (listtoarray nxt)))))

(defun scan.this-+ (fno s r)
  (let ((nxt (scan-this s)))
    (selectq nxt
	     (*terminated* nil)
	     (nil nil)
	     (osql-result s (listtoarray nxt)))))

(defun scan.more- (fno s)
  (if (scan-eos s)nil
    (osql-result s)))

(defun scan.nomore- (fno s)
  (if (scan-eos s) (osql-result s)))

(defun closescan- (fno s)
  (if (scan-close s)(osql-result s)))

(defun print-scan (x str)
  (princ "#scan#" str))

(defun init-scan-system ()
  (createliteraltype 'scan '(collection) 'scan 'print-scan)
  (osql "
create function openScan(Bag b)-> Scan
  as foreign 'openscan-+';

create function next(Scan s)-> Vector
  as foreign 'scan.next-+';

create function peek(Scan s)-> Vector
  as foreign 'scan.peek-+';

create function this(Scan s)-> Vector
  as foreign 'scan.this-+';

create function more(Scan s)->Boolean
  as foreign 'scan.more-';

create function nomore(Scan s)->Boolean
  as foreign 'scan.nomore-';

create function closeScan(Scan s)->Boolean
  as foreign 'closescan-';
")
  )
