;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2006 T.Risch, UDBL
;;; $RCSfile: stream.lsp,v $
;;; $Revision: 1.23 $ $Date: 2013/11/23 08:42:14 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Basic datatype STREAM
;;; =============================================================
;;; $Log: stream.lsp,v $
;;; Revision 1.23  2013/11/23 08:42:14  torer
;;; removed playbacks() and forever()
;;; kepr playback2()->Bag and forever2()->Bag, which are allowed only on the top level (no in())
;;;
;;; Revision 1.22  2013/11/22 14:52:39  torer
;;; forever(Stream) -> Stream with type inference
;;;
;;; Revision 1.21  2013/11/22 13:29:20  torer
;;; New function playbacks(Stream)->Stream
;;;
;;; Revision 1.20  2013/11/16 16:56:55  chexu484
;;; playback2
;;;
;;; Revision 1.19  2013/06/29 16:09:25  torer
;;; New file for CSV file access: lsp/CSV.osql
;;;
;;; Revision 1.18  2013/06/29 15:33:45  torer
;;; New function
;;; diota(Number freq, Number l, Number u) -> Stream of Number
;;; for delayed iota()
;;;
;;; Revision 1.17  2013/04/12 14:41:00  chexu484
;;; writecsvfile
;;;
;;; Revision 1.16  2013/04/09 17:26:54  torer
;;; writecsvfile(Charstring file, Bag of Vector b)->Boolean
;;;
;;; Revision 1.15  2012/11/09 11:05:11  torer
;;; *** empty log message ***
;;;
;;; Revision 1.14  2012/10/25 06:09:42  torer
;;; Roundoff error in heartbeat()
;;;
;;; Revision 1.13  2012/09/06 21:08:28  torer
;;; MAP-STREAM and STREAMTYPEP now in C
;;;
;;; Revision 1.12  2012/08/15 18:16:42  torer
;;; (MAPSTREAM S MAPPER) like MAPBAG but unfolds streams in streams
;;;
;;; Revision 1.11  2012/05/31 20:53:08  torer
;;; *** empty log message ***
;;;
;;; Revision 1.10  2012/05/31 20:36:02  torer
;;; Heartbeat function:
;;;   heartbeat(Number frequency)->Stream of Number
;;;
;;; Revision 1.9  2011/12/22 12:55:17  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.8  2011/01/09 16:43:48  torer
;;; Function 'in' now overloaded on only basic collection types
;;; (i.e. bag, vector, stream), not on all combinations of collection
;;; type constructor types as before.
;;; Instead 'in' uses type inference to determine result types
;;;
;;; Revision 1.7  2010/09/02 18:04:17  torer
;;; Function MEMO-FUNCTION replaces macro CACHE and function MEMO
;;;
;;; Revision 1.6  2009/10/03 11:06:37  torer
;;; in(Stream)->Bag of Object
;;;
;;; Revision 1.5  2009/05/28 13:27:02  torer
;;; *** empty log message ***
;;;
;;; Revision 1.4  2008/10/10 17:28:26  torer
;;; Print function for streams
;;;
;;; Revision 1.3  2008/09/17 12:18:18  zeitler
;;; Deferring execution of streams
;;;
;;; Revision 1.2  2008/08/13 07:58:08  torer
;;; Type STREAM separated from core Amos II
;;;
;;; Revision 1.1  2006/12/14 18:20:28  torer
;;; Moved all code to define type STREM to stream.lsp
;;; Moved all code to define type VECTOR to vector.lsp
;;;
;;; =============================================================

(setq _stream_ (createtype 'stream '(collection)))
  
(make-parameterized-type _stream_ (function make-streamtype))

(defun streamof (obj bag gen)
  "Implements ObjectLog predicate
        streamof(Bag)->Stream"
  (let ((g (make-generator (bag-streamtype bag)
			   (generator-function bag)
                           (generator-params bag))))
    (osql-result bag g)))

(defun bag-streamtype (gen)
  "Construct the stream type for a given bag type"
  (cond ((generatorp gen)
	 (make-streamtype (type-parameters (generator-type gen))))
        (t (error "Cannot convert to stream " gen))))

(defun make-streamtype  (typel)
  "Construct the stream type which elements have types in TYPEL"
  (if (null typel) _stream_
    (make-param-type typel 
		     (function make-streamtypename)	
		     (function null)
		     _stream_)))

(memo-function (defun make-streamtypename(names)
		 (pack 'stream- (if (cdr names)
				    (make-tupletypename names)
				  (car names)))))

(defun stream-type? (tp)
  "Test if type TP under type Stream"
  (and (oid-p tp) (osql-subtypep tp _stream_)))

(defun stream.in (obj b &rest resl)
  "Iterate over elements in stream"
  (map-stream b (f/l (row)
		     (apply 'osql-result b row))))

(set-resulttypesfn
 (osql "create function streamof(Bag)-> Stream 
as foreign 'streamof';")
 'streamof-resulttypes)

(defun transparent-stream-resulttypes (fno args)
   (list (make-streamtype (transparent-collection-resulttypes fno args))))

(defun streamof-resulttypes (fno args)
  "The result type is stream type with the type parameters 
   of the 1st bag argument"
  (list (make-streamtype (default-type-parameters (arg-type (car args))))))

;;; Extract elements from stream:

(set-resulttypesfn
 (create-function in((stream))((object)) as foreign (stream.in))
 'transparent-collection-resulttypes)

(set-early-bound 'in)
(set-iterator _stream_ 'stream.in)
(set-printfn _stream_ 'bag-printfn)

;;; Stream utility function implementations
;;; AmosQL definitions in streams.osql

(defun diota---+ (fno freq from to res)
  (let ((r from))
    (while (<= r to)
      (osql-result freq from to r)
      (co-sleep freq)
      (1++ r))))

(defun heartbeat0-+(fno freq r)
  (let ((tick 0))
    (while t
      (osql-result freq tick)
      (setq tick (+ tick freq))
      (co-sleep freq))))

(defun heartbeat0--++ (fno s freq ts r)
  (let ((tick 0))
    (map-stream s (f/l (row)
		       (apply 'osql-result s freq tick row)
                       (setq tick (+ tick freq))
		       (co-sleep freq)))))

(defun replay0--+ (fno s fn r)
  (let ((tick 0.0) (firsttime t))
    (map-stream s (f/l (row)
		       (let ((ts (caar (getfunction fn row))))
			 (if firsttime
			     (setq firsttime nil)
			   (co-sleep (- ts tick)))
			 (setq tick ts)
			 (apply 'osql-result s fn row))))))

(defun ts (row)
  (let ((_ts (if (listp row) (car row) row)))
    (cond ((numberp _ts)
	   _ts)
	  ((arrayp _ts)
	   (if (numberp (elt _ts 0))
	       (elt _ts 0))))))

(defun playback0-+ (fno s r)
  (let ((tick 0.0) (firsttime T))
    (map-stream s (f/l (row)
		       (let* ((_ts (ts row))
		       	      (ts (if (numberp _ts) _ts (+ 0.01 tick))))
			 (if firsttime
			     (setq firsttime nil)
			   (co-sleep (- ts tick)))
			 (setq tick ts)
			 (apply 'osql-result s row))))))

(defun playback2-+ (fno s r)
  (let ((tick 0.0) (firsttime T))
    (map-stream s (f/l (row)
		       (let* ((_ts (car row))
		       	      (ts (if (numberp _ts) _ts (+ 0.01 tick))))
			 (if firsttime
			     (setq firsttime nil)
			   (co-sleep (- ts tick)))
			 (setq tick ts)
			 (apply 'osql-result s row))))))

(set-resulttypesfn
  (osql "
create function playback2(Stream s) -> Bag of Object
  as foreign 'playback2-+';")
  'transparent-collection-resulttypes)

(defun forever-+ (fno s r)
  (loop (map-stream s (f/l (row)(apply 'osql-result s row)))))

(set-resulttypesfn
 (osql "
create function forever2(Stream s) -> Bag of Object
  as foreign 'forever-+';")
 'transparent-collection-resulttypes)

(defun stream.tuples-+ (fno s r)
  (map-stream s (f/l (row)(osql-result s (toarray row)))))