;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013 Tore Risch, UDBL
;;; $RCSfile: logger.lsp,v $
;;; $Revision: 1.1 $ $Date: 2013/05/31 12:34:37 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Logging utilities
;;; =============================================================
;;; $Log: logger.lsp,v $
;;; Revision 1.1  2013/05/31 12:34:37  torer
;;; to add arrival time stamps + logger operator
;;;
;;; =============================================================

(defun writecsvfile--(fno file b)
  (with-output-file
   s file
   (mapbag b (f/l (row)
                  (selectq (typename (car row))
			   (array (write-csv-line (car row) s))
			   (numarray (na-csv-print (car row) s))
			   (error "Illegal CVS row" (car row)))))
   t))
(remprop ' writecsvfile-- 'redefined)
(defun logger--+ (fno file b r)  
  (with-output-file
   s file
   (mapbag b (f/l (row)
                  (selectq (typename (car row))
			   (array (write-csv-line (car row) s))
			   (numarray (na-csv-print (car row) s))
			   (error "Illegal CVS row" (car row)))
                  (osql-result file b (car row))))		  
	   
   t))

(osql "
create function baglogger(Charstring file, Bag rows) -> Bag of Object
  as foreign 'logger--+';

create function logger(Charstring file, Stream rows) -> Stream
  as streamof(baglogger(file,cast(rows as Bag)));

")

(defun log-csv-line-stdout-+ (fno v res)
  (if *mystream* 
      (write-csv-line v *mystream*)
    (print v))
  (osql-result v t))

(osql "
  create function log_csv_stdout(Vector v) -> Boolean 
  as foreign 'log-csv-line-stdout-+';
")

(set-resulttypesfn (theresolvent 'logger) 'logger-resulttypes)
(set-resulttypesfn (theresolvent 'baglogger) 'logger-resulttypes)

(defun logger-resulttypes (FNO ARGS)
  (list (arg-type (second args))))

(defun propagate-delays- (fno flg)
  (cond ((is-true flg)
         (add-sp-startform '(progn (setq _socket-systime_ t)
                                   (setq _report-csv-times_ t))))
        (t (add-sp-startform '(progn (setq _socket-systime_ nil)
				     (setq _report-csv-times_ nil))))))

(osql "
create function propagate_delays(Boolean) -> Boolean
  as foreign 'propagate-delays-';")
