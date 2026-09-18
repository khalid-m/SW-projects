;;; ============================================================
;;; AMOS2
;;;
;;; Author: (c) 2009 Gyozo Gidofalvi, UDBL
;;; $RCSfile: stream_apply.lsp,v $
;;; $Revision: 1.2 $ $Date: 2009/05/09 06:18:38 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Lisp implementation of a function  that applies 
;;; the function fn to all elements of the input stream istream.
;;; The function is exposed as an OSQL function as:
;;; sapply(istream, fn)-> ostream
;;;
;;; =============================================================
;;; $Log: stream_apply.lsp,v $
;;; Revision 1.2  2009/05/09 06:18:38  gyogi445
;;; Updated stream_transducer code, vectorized stream aggregators, spectrum monitoring
;;;
;;; Revision 1.1  2009/04/09 10:20:10  gyogi445
;;; Basic stream operators
;;;
;;; Revision 1.1  2009/03/05 18:18:49  guestgyg
;;; Initial SDM checkin with install, run and test commands
;;; Initial winpred.lps and random.lsp checkin
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

;lisp definition of the stream apply function
(defun sapply--+ (obj s fn r) 
  (mapbag s;;for all elements of the stream
	  (f/l (row)
               (mapfunction fn row (f/l (tpl)
					(osql-result s fn (car tpl)))))))

;osql definition for the lisp foreign fn (returns a bag) 
(defun sapply-resulttypes (fno args)
  "result type of sapply"
  (if (function-p (second args)) 
      (list (make-streamtype
	     (function-resulttypes (second args))))))

(osql "
create function sapply0(Stream s, Function fn)-> Bag of Object
  as foreign 'sapply--+';")

;osql fn to convert the bag to a stream
(set-resulttypesfn
 (osql "
create function sapply(Stream s, Function fn)->Stream of Object
  as streamof(sapply0(s, fn));") 
 'sapply-resulttypes)






