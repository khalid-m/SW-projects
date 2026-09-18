;;; ============================================================
;;; AMOS2
;;;
;;; Author: (c) 2009 Gyozo Gidofalvi, UDBL
;;; $RCSfile: stream_filter.lsp,v $
;;; $Revision: 1.1 $ $Date: 2009/04/09 10:20:11 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Lisp implementation of a function that filters
;;; the input stream istream based on the Boolean predicate 
;;; function predfn, i.e., those and only those istream elements 
;;; for which the predicate evaluates to TRUE are present in the 
;;; output stream. The function is also exposed as an OSQL fn:
;;; sfilter(istream, predfn)-> ostream
;;;
;;; =============================================================
;;; $Log: stream_filter.lsp,v $
;;; Revision 1.1  2009/04/09 10:20:11  gyogi445
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

;lisp definition of the stream filter function
(defun sfilter--+ (obj s predfn v) 
  (mapbag s ;for all elements of the stream
	  (f/l (row)
	       (if (getfunction predfn row) ;pred(row)==t -> emit row
		   (osql-result s predfn (car row)))))) 

;osql definition for the lisp foreign fn (returns a bag) 
(osql "
create function sfilter0(Stream s, Function predfn)-> Bag of Object
  as foreign 'sfilter--+';")

;osql fn to convert the filtered bag to a stream
(osql "
create function sfilter(Stream s, Function predfn)->Stream of Object
  as streamof(sfilter0(s, predfn));") 

