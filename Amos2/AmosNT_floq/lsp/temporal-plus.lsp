;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Thanh Truong, UDBL
;;; $RCSfile: temporal-plus.lsp,v $
;;; $Revision: 1.7 $ $Date: 2013/05/01 15:25:00 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: PLUS (+) and MINUS (-) with Timeval and Date
;;; =============================================================
;;; $Log: temporal-plus.lsp,v $
;;; Revision 1.7  2013/05/01 15:25:00  minzh812
;;; remove parteval('Date->Date');
;;;
;;; Revision 1.6  2012/06/12 07:51:30  thatr500
;;; fixed bugs ! Now the following operations work
;;;  .timeval  + duration
;;;  .timeval  - duration
;;;
;;; Revision 1.5  2012/05/21 15:52:00  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.4  2012/04/27 14:22:48  thatr500
;;; added lisp function (date) to get the current day
;;;
;;; Revision 1.3  2012/04/11 08:00:05  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.2  2012/04/02 13:09:38  thatr500
;;; added 'timeval-to-string'
;;;
;;; Revision 1.1  2012/03/31 18:34:09  thatr500
;;; - supports Plus / Minus with Date and Timeval datatype
;;; - Example:
;;;    select tv from Timeval tv where tv = now() - 180.0; /*Previous 3 minutes*/
;;;    select d from  Date d where d = date() + 3.0;    /*Next 3 days*/
;;;
;;;
;;; =============================================================

;;------------------------------------------------------------------------------------------------------
;; + and - on Timeval datatype
;;------------------------------------------------------------------------------------------------------
(osql "create function plus(Number duration, Timeval tv) -> Timeval r
      as multidirectional
         ('bbf' foreign 'plus-dtv--+')
         ('bfb' foreign 'plus-dtv-+-');

      create function plus(Timeval tv, Number duration) -> Timeval r
      as multidirectional
         ('bbf' foreign 'plus-tvd--+')
         ('fbb' foreign 'plus-tvd+--');

      create function minus(Timeval tv, Number duration) -> Timeval r
       as multidirectional
           ('bbf' foreign 'minus-tvd--+');")


(defun plus-dtv--+ (fn duration tv res) 
  (if (and (timevalp tv) (numberp duration))
      (osql-result duration tv (timeval-add-duration tv (* 1.0 duration)))))


(defun plus-dtv-+- (fn duration tv res) 
  (if (and (timevalp res) (numberp duration))
      (osql-result duration (timeval-add-duration res (- 0.0 duration)) res)))


(defun plus-tvd--+ (fn tv duration res) 
  (if (and (timevalp tv) (numberp duration))
      (osql-result tv duration (timeval-add-duration tv (* 1.0 duration)))))

(defun plus-tvd+-- (fn tv duration res) 
  (if (and (timevalp res) (numberp duration))
      (osql-result (timeval-add-duration res (- 0.0 duration)) duration res)))


(defun minus-tvd--+ (fn tv duration res) 
  (if (and (timevalp tv) (numberp duration))
      (osql-result tv duration (timeval-add-duration tv (- 0.0 duration)))))


;;-----------------------------------------------------------------------------------------------
;; + and - on Date datatype
;;----------------------------------------------------------------------------------------------
(osql "create function plus(Number duration, Date dt) -> Date r
       as multidirectional
          ('bbf' foreign 'plus-ddt--+')
          ('bfb' foreign 'plus-ddt-+-');

       create function plus(Date dt, Number duration) -> Date r
       as multidirectional
          ('bbf' foreign 'plus-dtd--+')
          ('fbb' foreign 'plus-dtd+--');

       create function minus(Date dt, Number duration) -> Date r
       as multidirectional
           ('bbf' foreign 'minus-dtd--+');")


(defun date-in-vector (dt)
  (vector (date-year dt) (date-month dt) (date-day dt) 0 0 0 0))

;; This is a fishy calculation since a day is consider as 86400 seconds!!!
(defun date-add-duration (dt duration)
  (let ((d (timeval-to-date 
		  (timeval-add-duration (date-to-timeval (date-in-vector dt)) (* duration 86400.0)))))
    (mkdate (aref d 0)  (aref d 1)  (aref d 2))))


(defun plus-ddt--+ (fn duration dt res) 
  (if (and (datep dt) (numberp duration))
      (osql-result duration dt (date-add-duration dt duration))))

(defun plus-ddt-+- (fn duration dt res) 
  (if (and (datep res) (numberp duration))
      (osql-result duration (date-add-duration res (- 0 duration)) res)))

(defun plus-dtd--+ (fn dt duration res) 
  (if (and (datep dt) (numberp duration))
      (osql-result dt duration (date-add-duration dt duration))))

(defun plus-dtd+-- (fn dt duration res) 
  (if (and (datep res) (numberp duration))
      (osql-result (date-add-duration res (- 0 duration)) duration res)))


(defun minus-dtd--+ (fn dt duration res) 
  (if (and (datep dt) (numberp duration))
      (osql-result dt duration (date-add-duration dt (- 0 duration)))))



(osql "
       parteval('Number.Timeval.Plus->Timeval');
       parteval('Number.Timeval.Plus->Timeval');
       parteval('Timeval.Number.Minus->Timeval');

       parteval('Number.Date.Plus->Date');
       parteval('Date.Number.Plus->Date');
       parteval('Date.Number.Minus->Date');

")


;; The following format is compatiable with MySQL and SQLServer. It is a standard (time/date)
;; format
;;format 'yyyy-MM-dd hh:mm:ss.xxx'
;; y - year
;; M - month
;; d - day
;; ...
;; x - milisecond
(defun date-to-string (dt)
  (concat "'" (add-zero (date-year dt))"-"
	    (add-zero (date-month dt))"-"
	    (add-zero (date-day dt)) 
	    " 00:00:00.000"   
	    "'"))

(defun timeval-to-string (tv )
  (let ((dl (timeval-to-date tv)))
    (concat  "'" 
	     (add-zero (aref dl 0)) "-"
	     (add-zero (aref dl 1)) "-"
	     (add-zero (aref dl 2)) " "
	     (add-zero (aref dl 3)) ":"
	     (add-zero (aref dl 4)) ":"
	     (add-zero (aref dl 5)) "'")))


(defun  date () 
  (let ((today (timeval-to-date (gettimeofday))))
    (mkdate (aref today 0) ; year 
	    (aref today 1) ; month 
	    (aref today 2) ; day
	    )))