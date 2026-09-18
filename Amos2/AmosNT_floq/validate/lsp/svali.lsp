;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Cheng Xu, UDBL
;;; $RCSfile: svali.lsp,v $
;;; $Revision: 1.25 $ $Date: 2013/11/22 13:55:37 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Stream validation
;;; =============================================================
;;; $Log: svali.lsp,v $
;;; Revision 1.25  2013/11/22 13:55:37  chexu484
;;; playbackValidationStream
;;;
;;; Revision 1.24  2013/11/20 19:20:21  chexu484
;;; new function mapv
;;;
;;; Revision 1.23  2013/11/16 17:47:39  chexu484
;;; type inference for alertMsg
;;;
;;; Revision 1.22  2013/11/16 16:59:13  chexu484
;;; alertMsg
;;;
;;; Revision 1.21  2013/11/16 13:40:02  chexu484
;;; validation functions returns nil when everything is right
;;; function to construct alert messages
;;;
;;; Revision 1.20  2013/11/08 13:10:37  chexu484
;;; mapv
;;;
;;; Revision 1.19  2013/04/02 20:29:03  chexu484
;;; threshold out of scope
;;;
;;; Revision 1.18  2013/01/08 13:14:06  chexu484
;;; revert
;;;
;;; Revision 1.17  2013/01/08 12:49:45  chexu484
;;; model and validate returns stream of vector instead of stream of qua-tuple
;;;
;;; Revision 1.16  2013/01/04 13:27:22  chexu484
;;; *** empty log message ***
;;;
;;; Revision 1.15  2012/11/21 15:33:06  chexu484
;;; threshold as stored function
;;;
;;; Revision 1.14  2012/11/13 10:09:42  chexu484
;;; new function: validationFlagChanged
;;;
;;; Revision 1.13  2012/10/25 15:03:45  chexu484
;;; a little profile on validation
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(defglobal _validation-profile_ nil)
(defglobal _validation-profile-freq_ nil)

;; wall clock
(defglobal _validation-start-time_ 0.0)
(defglobal _validation-stop-time_ 0.0)
(defglobal _validation-count_ 0)

;; time stamp included in input stream tuple
(defglobal _validation-tuple-start-time_ 0.0)

(foreign-lispfn relative_ts () ((Number))
  (foreign-result
   (+ (- (rnow) _validation-start-time_)
      _validation-tuple-start-time_)))

(defun validation-profile (stat &optional freq)
  (if freq (setq _validation-profile-freq_ freq))
  (if (= stat 'FALSE)
      (setq _validation-profile_ nil)
    (setq _validation-profile_ 1)))

(foreign-lispfn validation_profile ((Boolean stat)) ((Boolean))
  (foreign-result (validation-profile stat)))

(defun init-validation-profile ()
  (setq _validation-start-time_ (rnow))
  (setq _validation-stop-time_ 0.0)
  (setq _validation-count_ 0)
  (setq _validation-tuple-start-time_ 0.0))

;; profiling these:
(defun validation-profile-report ()
  (setq _validation-stop-time_ (rnow))
  (formatl t "tuple start point: " _validation-tuple-start-time_ t
	     "start time: " _validation-start-time_ t
	     "finish time: " _validation-stop-time_ t
	     "overall process time: " (- _validation-stop-time_ _validation-start-time_) t
	     "processed: " _validation-count_ t)
  (init-validation-profile))

;; the reference can be either a single value
;; or a bag of values
(defun build-refn (model argl)
  (if (has-bagged-result model)
      (make-generator _bag_ model argl)
    (caar (getfunction model argl))))

(defun materialize-model (model)
  (let ((res (tconc)))
    (mapbag model (f/l (m)
		       (tconc res (car m))))
    (listtoarray (car res))))

(defun validate-one (inptl r model validate prev)
  (let ((res (car (getfunction-nocheck validate (list r model))))
	(m (if (generatorp model) (materialize-model model) model)))  ;; check if it is a bag
    (if res
	(apply 'osql-result
		      `(,@inptl ,(listtoarray (append2 res (list m)))))
      (if prev (apply 'osql-result `(,@inptl ,nil))))
    res))

;; receive one object and validate
(defun model-n-validate-one (fno o model validate)
  (let ((ref (build-refn model (list o)))
	(inptl (list o model validate)))
    (validate-one inptl o ref validate nil)))

(osql "create function model_n_validate_one(Object o, Function modelfn, Function validatefn)
                                                  -> Vector /*(Number ts, Object m, Object e)*/
       as foreign 'model-n-validate-one';")

(defun model_n_validate---+ (fno s model validate)
  (let ((inptl (list s model validate))
	(firsttime T) prev)
    (mapbag s
	    (f/l (o)
		 (if firsttime (progn (setq firsttime nil)
				      (if _validation-profile_ (init-validation-profile))
				      (let ((_ts (if (windowp (car o))
						     (swin-getts (car o))
						   (ts o))))
					(if (numberp _ts)
					    (setq _validation-tuple-start-time_ _ts)))))
		 (if _validation-profile_ (1++ _validation-count_))
		 (let ((ref (build-refn model o)))
		   (setq prev (validate-one inptl (car o) ref validate prev))))))
  (if _validation-profile_ (validation-profile-report)))

(osql "create function model_n_validate_b(Stream s, Function modelfn, Function validatefn)
                                              -> Bag of Vector /*(Number ts, Object m, Object e)*/
       as foreign 'model_n_validate---+';")

(defun learn-n-validate----+ (fno s learnfn n validatefn)
  (let ((counter 0) (hasrecorded nil)
	(inptl (list s learnfn n validatefn))
	(recorded (make-array n)) th ref prev)
    (if _validation-profile_ (init-validation-profile))
    (mapbag s
	    (f/l (o)
		 (if hasrecorded
		     (progn (if _validation-profile_ (1++ _validation-count_))
			    (setq prev (validate-one inptl (car o) ref validatefn prev)))
		   (cond ((< counter n)
			  (seta recorded counter (car o))
			  (if (= (1++ counter) n)
			      (progn
				(setq ref (build-refn learnfn (list recorded)))
				(setq hasrecorded T)				
				(setq counter 0)))))))) ;; also reset counter so that later you can re-record
    (if _validation-profile_ (validation-profile-report))))

(osql "create function learn_n_validate_b(Stream s, Function learnfn, Integer n, Function validatefn)
                                                       -> Bag of Vector /*(Number ts, Object m, Object e)*/
       as foreign 'learn-n-validate----+';")


;; TO DO: check if the alert function returns a bag
;; iterate throught the bag and return alert messages
;; Cheng Xu 2013.11.16
(defun alert---+ (fno s alertfn args)
  (let (msg)
    (mapbag s
	    (f/l (o)
		 (cond ((car o)
			(setq msg (car (getfunction-nocheck alertfn (append o (arraytolist args)))))
			(apply 'osql-result s alertfn args msg))
		       (t
			(apply 'osql-result s alertfn args
			       (mapcar (f/l (e) "") (get-resolvent-restypes alertfn)))))))))

(defun alertMsgResulttype (fno args)
  (let ((alertfn (second args)))
    (get-resolvent-restypes alertfn)))

(set-resulttypesfn
 (osql "create function alertMsg(Stream s, Function alertfn, Vector args) -> Object as foreign 'alert---+';")
 'alertMsgResulttype)

;; equality should be passed as a second order function
;; however on the other hand, the euqality of two tuples
;; can't be defined in amosql right now (2012.11.13)
;; this checks if the fourth element in qua-tuples is changed
'(defun validationFlagChanged-+ (fno s r)
  (let (previous)
    (mapbag s (f/l (current)
		   (cond ((not (equal (fourth previous) (fourth current)))
			  (apply 'osql-result s current)
			  (setq previous current)))))))

(set-resulttypesfn
 (osql "create function validationFlagChanged(Stream s) -> Bag of Object
  as foreign 'validationFlagChanged-+';")
 'transparent-collection-resulttypes)


(defun relevant-variable (pred accfn)
  (let (res)
    (cond ((null pred) nil)
	  ((atom pred) nil)
	  ((or (andp (car pred))
	       (orp (car pred)))
	   (mapc (f/l (p)
		      (setq res (append (relevant-variable p accfn) res)))
		 pred))
	  (t
	   (if (list-in accfn pred)
	       (mapc (f/l (p)
			  (cond ((stringp p)
				 (setq res (list p)))))
		     pred))))
    res))


(defun validatefn-variable-+ (fno vfn accfn res)
  (let* ((vfnsb (getselectbody vfn))
	 (vfnpred (selectbody-orgpred vfnsb)))
    (mapc (f/l (r)
	       (osql-result vfn accfn r))
	  (relevant-variable vfnpred accfn)))) 

(osql "create function vfn_variable(Function vfn, Function accfn) -> Bag of Charstring
       as foreign 'validatefn-variable-+';")

(defun mapv--+ (fno b mapfnv)
  (let ((res (make-array (length mapfnv))))
    (mapbag b (f/l (event)
		   (let (r)
		     (maparray mapfnv (f/l (mapfn i)
					   (assignfunction mapfn event '(r))
					   (seta res i r)))
		     (osql-result b mapfnv res))))))

(osql "create function mapv(Bag of Object b, Vector of Function mapfnv) -> Bag of Vector
       as foreign 'mapv--+';")

(defun mapv0--+ (fno o mapfnv)
  (let ((res (make-array (length mapfnv))) r)
    (maparray mapfnv (f/l (mapfn i)
			  (assignfunction mapfn (list o) '(r))
			  (seta res i r)))
    (osql-result o mapfnv res)))

(osql "create function mapv(Object b, Vector of Function mapfnv) -> Vector
       as foreign 'mapv0--+';")

(defun playbackValidationStream-+++ (fno s)
  (let ((tick 0.0) (firsttime T))
    (map-stream s (f/l (row)
		       (let* ((_ts (car row))
		       	      (ts (if (numberp _ts) _ts (+ 0.01 tick))))
			 (if firsttime
			     (setq firsttime nil)
			   (co-sleep (- ts tick)))
			 (setq tick ts)
			 (apply 'osql-result s row))))))

(osql "create function playbackValidationStream0(Stream s)
                           -> Bag of (Number, Number, Number) as foreign 'playbackValidationStream-+++';")

(osql "create function playbackValidationStream(Stream s)
                           -> Stream of (Number, Number, Number) as streamof(playbackValidationStream0(s));")