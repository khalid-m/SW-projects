
;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Cheng Xu, UDBL
;;; $RCSfile: multi_variable.lsp,v $
;;;
;;; Description: multi variables for hagglund data
;;; =============================================================
;;; $Log: multi_variable.lsp,v $
;;; Revision 1.1  2012/10/17 19:52:18  chexu484
;;; multi variables are possible for hagglunds data
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================


; hash table is used to stored the latest value of the variable
(defun stream-tuple--+ (fno s v res)
  (let ((ht (make-hash-table :test (function equal)))
	(variables (arraytolist v)))
    (mapbag s (f/l (event)
		      (let* ((tuple (car event))
			     (ts (elt tuple 0)) ; time stamp
			     (variable (elt tuple 1)) ; variable name
			     (value (elt tuple 2))) ; value
			(if (some (f/l (v) (equal v variable)) variables)
			    (osql-result s v
				      (listtoarray
				       (cons ts
				       (mapcar (f/l (e)
						    (let ((val (cadr (gethash e ht))))
						      (cond ((equal e variable)
							     (setf (gethash e ht)
								   (list ts value))
							     value)
							    (t val))))
					       variables))))))))))

(osql "create function stream_tuple0(Stream s, Vector of Charstring variables)
                                                                -> Bag of Vector
       as foreign 'stream-tuple--+';")

(osql "create function stream_tuple(Stream s, Vector of Charstring variables)
                                                                -> Stream of Vector
       as streamof(stream_tuple0(s, variables));")

(osql "create logdirectory (name,folder,timeout,startseq) 
       instances ('d2',getenv('AMOS_HOME')+'logdir/hlund/realdata/',10,0);")

(osql
  "create function hlund_stream0(Charstring dirname) -> Bag of Vector
   as select {timestamp(e), variable(e), value(e)}
   from Logevent e where e in simlogeventstream(dirnamed(dirname));
   create function hlund_stream(Charstring dirname) -> Stream of Vector
   as streamof(hlund_stream0(dirname));")
