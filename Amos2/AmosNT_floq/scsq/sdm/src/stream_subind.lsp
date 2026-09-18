;;; ============================================================
;;; AMOS2
;;;
;;; Author: (c) 2009 Gyozo Gidofalvi, UDBL
;;; $RCSfile: stream_subind.lsp,v $
;;; $Revision: 1.2 $ $Date: 2009/08/03 13:26:46 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Lisp implementations of functions for returning 
;;; the subscript- and binary index streams of the input stream 
;;; based on the evaluation of the predicate function when 
;;; applied to the stream elements. Conversion between and 
;;; selection operators based on the two are also implemented. 
;;; The function are exposed as an OSQL functions by the same 
;;; names: 
;;; ssub(istream, function)-> sub_stream
;;; sind(istream, function)-> ind_stream
;;; sind2sub(ind_stream)-> sub_stream
;;; ssub2ind(sub_stream)-> ind_stream*
;;; sindsel(istream, ind_stream)-> ostream
;;; ssubsel(istream, sub_stream)-> ostream
;;;
;;; Functions ssubsel and sindsel need to simultaniously opperate (map)
;;; on two potentially indeffinite streams (source and reference stream).
;;; This is facilitated by couroutines. In case of high volume streams 
;;; this coroutine-based mechanism is not effective due to the costs
;;; incured through swithching between threads. To make the operators 
;;; more effective in this case, buffering of the streams is employed. 
;;; The respective buffered variants of the selections operators are
;;; exposed by the following OSQL functions:
;;; sindselbuf(istream, ind_stream, bsize)-> ostream
;;; ssubselbuf(istream, sub_stream, bsize)-> ostream      
;;;
;;; *Note: Because there is no exlicit reference to the end of the
;;; stream in the subscript notation ssub(s,pf), 
;;; ssub2ind(ssub(s,pf)) != sind(s,pf). 
;;;
;;; =============================================================
;;; $Log: stream_subind.lsp,v $
;;; Revision 1.2  2009/08/03 13:26:46  gyogi445
;;; Novelty detection via independently trained "compression" neural networks
;;;
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

; Implementation of ssub
(defun ssub0--+ (obj s predfn r)
  (let ((sub 0)) 
    (mapbag s;;for all elements of the stream
	    (f/l (row)
		 (if (getfunction predfn row);;pred(row)==t -> emit sub
		     (osql-result s predfn sub))
		 (setq sub (1+ sub))))))

(osql "
create function ssub0(Stream s, Function predfn)-> Bag of Integer
  as foreign 'ssub0--+';")

(osql "
create function ssub(Stream s, Function predfn)-> Stream of Integer
  as streamof(ssub0(s, predfn));")

; Implementation of sind
(defun sind0--+ (obj s predfn r) 
  (mapbag s;;for all elements of the stream
	  (f/l (row)
	       (if (getfunction predfn row);;pred(row)==t -> emit 1 else emit 0
		   (osql-result s predfn 1)
		 (osql-result s predfn 0)))))

(osql "
create function sind0(Stream s, Function predfn)-> Bag of Integer
  as foreign 'sind0--+';")

(osql "
create function sind(Stream s, Function predfn)-> Stream of Integer
  as streamof(sind0(s, predfn));")

; Implementation of sind2sub
(defun sind2sub0-+ (obj sind r)
  (let ((sub 0)) 
    (mapbag sind;;for all ind in the stream
	    (f/l (row)
		 (if (eq (car row) 1);;sind==1 -> emit sub
		     (osql-result sind sub))
		 (setq sub (1+ sub))))))

(osql "
create function sind2sub0(Stream sind)-> Bag of Integer
  as foreign 'sind2sub0-+';")

(osql "
create function sind2sub(Stream sind)-> Stream of Integer
  as streamof(sind2sub0(sind));")

; Implementation of ssub2ind
(defun ssub2ind0-+ (obj ssub r)
  (let ((prevsub -1)) 
    (mapbag ssub;;for all sub in the stream
	    (f/l (row)
		 (dotimes (cnt (1- (- (car row) prevsub))) 
		   (osql-result ssub 0))
		 (setq prevsub (car row))
		 (osql-result ssub 1)))))

(osql "
create function ssub2ind0(Stream ssub)-> Bag of Integer
  as foreign 'ssub2ind0-+';")

(osql "
create function ssub2ind(Stream ssub)-> Stream of Integer
  as streamof(ssub2ind0(ssub));")

; Implementation of sindsel
; simultanious iteration through two streams via co-routines, i.e., threads 
(defun sindsel0--+ (obj s sind r)
  (let ((cs (coroutine 'mapbag (list s 'co-yield)))
	(ci (coroutine 'mapbag (list sind 'co-yield))))
    (while (and (not (co-terminated cs)) (not (co-terminated ci)))
      (let ((ns (co-resume cs))
	    (ni (co-resume ci)))
	(if (and (eq (car ni) 1) (consp ns)) 
	    (osql-result s sind (car ns)))))))

(osql "
create function sindsel0(Stream s, Stream of Integer sind)-> Bag of Object
  as foreign 'sindsel0--+';")

(osql "
create function sindsel(Stream s, Stream of Integer sind)-> Stream of Object
  as streamof(sindsel0(s, sind));")

; Implementation of ssubsel via ssub2ind conversion
(osql "
create function ssubsel(Stream s, Stream of Integer ssub)-> Stream of Object
  as sindsel(s, ssub2ind(ssub));")

; Implementation of sindselbuf
; simultanious iteration through two BUFFERED streams via co-routines, i.e., threads 
; Coroutine to buffer a bag / stream into buffer lists of size bsize
(defun bufbag (b bufsize)
  (let ((buf ());;empty buffer and bufcount
	(bufcnt 0))
    (mapbag b
	    (f/l (row);;add rows from the bag / stream to the buffer
		 (setq bufcnt (1+ bufcnt))
		 (setq buf (cons (car row) buf))
		 (cond ((>= bufcnt bufsize);;if buffer full
			(co-yield (nreverse buf));;yield to caller with buffer contents
			(setq buf ());;empty buffer
			(setq bufcnt 0)))))
    (if buf (co-yield (nreverse buf)))));;yield to caller contents of last buffer if any

; Fn to perform the coroutine-based buffered sindsel 
(defun sindselbuf0--+ (obj s sind bsize r)
  (let ((cbs (coroutine 'bufbag (list s bsize 'co-yield))) ; start the buffering coroutines 
	(cbi (coroutine 'bufbag (list sind bsize 'co-yield))))
    (while (and (not (co-terminated cbs)) (not (co-terminated cbi))) ; while both coroutines are running
      (let ((nbs (co-resume cbs));;get next source buffer
	    (nbi (co-resume cbi)));;get next index buffer
	(mapc (f/l (se ie);;iterate through the buffers simultaniously and emit se where si==1  
		   (if (eq 1 ie) 
		       (osql-result s sind bsize se)))
	      nbs nbi)))))

(osql "
create function sindselbuf0(Stream s, Stream of Integer sind, Integer bsize)-> Bag of Object
  as foreign 'sindselbuf0--+';")

(osql "
create function sindselbuf(Stream s, Stream of Integer sind, Integer bsize)-> Stream of Object
  as streamof(sindselbuf0(s, sind, bsize));")

; Implementation of ssubselbuf via ssub2ind conversion
(osql "
create function ssubselbuf(Stream s, Stream of Integer ssub, Integer bsize)-> Stream of Object
  as sindselbuf(s, ssub2ind(ssub), bsize);")

(osql "
create function vi2si (Vector of integer v)->Stream of integer
  as streamof(in(v));")
