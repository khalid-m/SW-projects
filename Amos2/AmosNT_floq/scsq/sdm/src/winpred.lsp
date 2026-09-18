;;; ============================================================
;;; AMOS2
;;;
;;; Author: (c) 2009 Gyozo Gidofalvi, UDBL
;;; $RCSfile: winpred.lsp,v $
;;; $Revision: 1.3 $ $Date: 2009/08/03 13:26:47 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Lisp implementation of a function that forms 
;;; windows over a stream based on a Boolean predicate. When 
;;; the predicate applied on current element of the stream 
;;; evaluates to TRUE the current window is extended by the 
;;; current element of the stream; when it evaluates to false
;;; the current window is closed and emitted and a new empty 
;;; window is started. The function is exposed as an OSQL 
;;; function by the same name: 
;;; winpred(stream, function)-> bag of vector
;;;
;;; A streamed version of the functions producing a stream of 
;;; windows is also exposed as an OSQL function by the name: 
;;; swinpred(stream, function)-> stream of vector 
;;;
;;; =============================================================
;;; $Log: winpred.lsp,v $
;;; Revision 1.3  2009/08/03 13:26:47  gyogi445
;;; Novelty detection via independently trained "compression" neural networks
;;;
;;; Revision 1.2  2009/04/09 10:20:11  gyogi445
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

(defun winpred--+ (obj s predfn v)
  (let (win);;current window initially set to be empty 
    (mapbag s;;for all elements of the stream
	    (f/l (row)
		 (cond ((null win) (if (getfunction predfn row);;not win && pred==t -> start/expand win 
				       (setq win (list (car row)))))
		       ((getfunction predfn row);;pred==t && (win) -> extend win 
                        (setq win (cons (car row) win)));;extend the window
		       (t (osql-result s predfn (listtoarray (nreverse win)));;win && pred==nil -> emit win && win:=() 
			  (setq win nil)))))
    (if win (osql-result s predfn (listtoarray (reverse win))))));;at the end of the stream: win -> emit win 

(osql "
create function winpred(Stream s, Function predfn)-> Bag of Vector
  as foreign 'winpred--+';")

(osql "
create function swinpred(Stream s, Function predfn)-> Stream of Vector
  as streamof(winpred(s, predfn));")