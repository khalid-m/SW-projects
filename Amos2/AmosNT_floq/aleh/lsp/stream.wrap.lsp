;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2006 Ruslan Fomkin, UDBL
;;; $RCSfile: stream.wrap.lsp,v $
;;; $Revision: 1.14 $ $Date: 2007/12/17 16:03:05 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Definition of type hierarchy for streaming impelmentation of ALEH with
;;; structs and foreign functions for creating and accessing structs. Function
;;; new_structbbf is wrapped to be able to collect statistics about each type
;;; of struct and every kind of property. The statistics is used for 
;;; calculating cost of get_slotbbf.
;;; ===========================================================================
;;; $Log: stream.wrap.lsp,v $
;;; Revision 1.14  2007/12/17 16:03:05  ruslan
;;; bug with types under structs is fixed
;;;
;;; Revision 1.13  2007/12/17 15:54:34  ruslan
;;; types are used to store in structs. dynamic statistics collection. bug with types for structs is fixed
;;;
;;; Revision 1.12  2007/11/03 14:09:19  ruslan
;;; type struct in wrapper already
;;;
;;; Revision 1.11  2007/10/01 08:59:57  ruslan
;;; sampling statistics on stored properties of event until it is confident
;;;
;;; Revision 1.10  2007/09/21 14:38:31  ruslan
;;; statistics on events collects sum of square also.
;;;
;;; Revision 1.9  2007/07/27 07:21:47  ruslan
;;; collectring sum of square for variance is removed
;;;
;;; Revision 1.8  2007/07/20 15:15:51  ruslan
;;; collecting statistics collects sum of squars. should be improved
;;;
;;; Revision 1.7  2007/06/19 14:51:39  ruslan
;;; bug fixed
;;;
;;; Revision 1.6  2007/06/19 08:42:29  ruslan
;;; typo
;;;
;;; Revision 1.5  2007/06/19 08:35:24  ruslan
;;; sampling function to get interval
;;;
;;; Revision 1.4  2007/02/14 14:10:29  ruslan
;;; comment of getstructstat is added
;;;
;;; Revision 1.3  2007/02/14 13:35:09  ruslan
;;; function to collect statistics on subset of stream is added
;;;
;;; Revision 1.2  2007/02/13 13:29:09  ruslan
;;; key is set on get_slot
;;;
;;; Revision 1.1  2006/12/18 14:45:11  ruslan
;;; stream approach with static cost model
;;;
;;; ===========================================================================

;; Cost model constants
(defglobal _default-struct-acces-cost_ 2.0)
(defglobal *elslot* 4)
(defglobal *muslot* 5)
(defglobal *jbslot* 6)

;; Hash table to store calls to get_slot.
(defglobal *struct-stat-fn* (osql "create function struct_stat(type t, 
integer i)-> <integer calls, integer results, integer sqsum> as stored;"))

(defun add-struct-stat (tps i card &optional calls)
  "Update statistics about calls to get_slot in the hash table"
  (let*
      ((old_triple (getfunction *struct-stat-fn* (list tps i)))
       (old_calls (if old_triple (first (car old_triple)) 0))
       (old_card (if old_triple (second (car old_triple)) 0))
       (old_sqsum (if old_triple (third (car old_triple)) 0))
       (new_calls (if calls (+ old_calls calls) (1+ old_calls)))
       (new_card (+ old_card card))
       (new_sqsum (+ old_sqsum (* card card))))
    (setfunction *struct-stat-fn* (list tps i)
		 (list new_calls new_card new_sqsum))))

;; Flag for collecting statistics of calls to get_slot
(defglobal *struct-stat* nil)
(foreign-lispfn structstat ((boolean flg))()
		"To toggle collecting statistics about calls to crete 
new struct"
		(if (eq flg 'false)(setq flg nil))
		(/setglobal '*struct-stat* flg)
		(if flg (foreign-result)))


;; to remove some type checks (does not really help)
(set-type-container (getfunctionnamed 'bag.vectorof->vector))

;;; the type hierarchy
;(createliteraltype 'struct '(literal) 'struct nil 'struct-type)
(createtype 'event '(struct))
(createtype 'particle '(struct))
(createtype 'jetb '(particle))
(createtype 'lepton '(particle))
(createtype 'electron '(lepton))
(createtype 'muon '(lepton))
 
(defglobal *eventtype* (gettypenamed 'EVENT))

;;; general functions to create and access structs
(defun new_structbbf (fno r cont s)
  "create new struct. if flag is true statistics is collected."
  (if *struct-stat*
      (dotimes (i (array-total-size cont))
	(add-struct-stat r i (if (arrayp (aref cont i))
				 (array-total-size (aref cont i)) 1))))
  (osql-result r cont (make-struct r cont)))

(defun struct_typebf (fno s tp)
  "Returns type of struct s"
   (osql-result s (struct-type s)))

(defun get_slotbbf (fno s i o)
  "Returns property i of struct s"
  (osql-result s i (struct-get s i)))

(osql "create function get_slot(struct ev, integer i)-> object o as
	foreign 'get_slotbbf';")
(osql "declare_key(functionnamed('get_slot'),{'ev','i'});")

;; Cost function for get_slot based on statistics collected during creating new
;; structs.
(setq *costfn*
      (foreign-lispfn
       get_slot_costs ((function f)(vector bpat)(vector argl)) 
       ((number cost)(number fanout))
       (let
	   ((s (aref argl 0))		; struct
	    (i (aref argl 1))		; struct slot
	    s_b pair)
	 (cond 
	  ((and (setq s_b (getbinding s)) (integerp i))
	   (cond 
	    ((setq pair (getfunction *struct-stat-fn* 
				     (list (binding-type s_b) i)))
	     (let ((fanout (/ (float (cadar pair))(caar pair))))
	       (osql-result f bpat argl 
			    (* _default-struct-acces-cost_ fanout)
			    fanout)))
	    (t (osql-result f bpat argl 2.0 1.0))))
	  (t (osql-result f bpat argl 2.0 1.0))))))

(declarecosts 'STRUCT.INTEGER.GET_SLOT->OBJECT '(- - +) *costfn*)
(declarecosts 'STRUCT.INTEGER.GET_SLOT->OBJECT '(- - -) *costfn*)

;; Help functions to collect statistics
(defun getstructstat (fno filename n counter)
  "Stream data from file by using wrapper function aleh_stream until n tuples 
are emitted from the wrapper function. It returns number of emitted tuples."
  (let ((counter 0)(structstat *struct-stat*))
    (setq *struct-stat* t)
    (catch 'getstructstat
      (mapfunction 
       (getfunctionnamed 'charstring.aleh_stream->event)
       (list filename) (f/l (x) (1++ counter)
			    (if (equal counter n) (throw 'getstructstat t)))))
    (setq *struct-stat* structstat)
    (osql-result filename n counter)))

(osql "create function getstructstat(charstring filename, integer n)->integer
counted as foreign 'getstructstat';")

(defun getstructstat_start (fno filename start n counter)
  "Stream data from file by using wrapper function aleh_stream starting from 
tuple with number start until n tuples are emitted from the wrapper function. 
It returns number of emitted tuples."
  (if (<= n 0) (osql-result filename start n 0)
    (let ((counter 0)(structstat *struct-stat*))
      (setq *struct-stat* t)
      (mapfunction 
       (getfunctionnamed 'charstring.integer.integer.aleh_stream->event)
       (list filename start (- (+ start n) 1)) 
       (f/l (x) (1++ counter))))
    (setq *struct-stat* structstat)
    (osql-result filename start n counter)))

(osql "create function getstructstat(charstring filename, integer start, 
integer n)->integer counted as foreign 'getstructstat_start';")

