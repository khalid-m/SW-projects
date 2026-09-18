;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009 Erik Zeitler, Tore Risch, UDBL
;;; $RCSfile: record.lsp,v $
;;; $Revision: 1.13 $ $Date: 2013/12/18 13:11:43 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Testing the many faces of a record
;;; =============================================================
;;; $Log: record.lsp,v $
;;; Revision 1.13  2013/12/18 13:11:43  torer
;;; removed function record(), replaced with make_record()
;;; New function empty_record()
;;;
;;; Revision 1.12  2013/10/28 19:52:18  torer
;;; Removed record type SSRC
;;;
;;; Revision 1.11  2011/05/31 14:56:12  torer
;;; Regression testing record comparisons
;;;
;;; Revision 1.10  2010/01/21 07:46:34  torer
;;; Records printed with JSON syntax
;;;
;;; Revision 1.9  2010/01/20 14:33:22  zeitler
;;; Header added
;;;
;;;
;;; =============================================================

(let ((rec (make-record #("attrib1" "value"))))
  (checkequal "record creation"
	      ((recordp rec)
	       t)
	      ((record-get rec "attrib1")
	       "value")
	      ((record-get rec "non-existing-attrib")
	       nil)))

(checkequal
 "Record comparison"
 ((make-record #("b1" 1 "a2" 2 "a3" 3))
  (make-record #("a3" 3 "a2" 2 "b1" 1)))
 )

(checkequal  
 "Record AmosQL functions"
 ((osql "set :r = make_record({'Name','Kalle','Age',10});") nil)
 ((osql "record_length(:r);") '((2)))
 ((osql ":r['Age'];") '((10)))
 ((osql "select p from Charstring p where :r[p]=10;") '(("Age")))
 ((osql "select p,v from Charstring p, Object v where :r[p]=v;")
  '(("Name" "Kalle") ("Age" 10)))
 ((osql "select v from Charstring p, Object v where :r[p]=v;")
  '(("Kalle") (10)))
 ((osql "select p from Charstring p, Object v where :r[p]=v;")
  '(("Name") ("Age")))
 )

(let (readrec (emptyrec (make-record))
	      (str (opentextstream)))
  (print emptyrec str)
  (closestream str)
  (setq readrec (read str))
  (checkequal "empty record read/write"
	      ((formatl t ": " readrec " ") nil)
	      ((recordp readrec)
	       t)
	      ((record-get readrec "attrib1")
	       nil)))

(let (amos_rr readrec (rec (make-record #("key1" "value1")))
	      (str (opentextstream)))
  (print rec str)
  (closestream str)
  (setq readrec (read str))
  (setq amos_rr readrec)
  (checkequal "record read/write"
	      ((formatl t ": " readrec " ") nil)
	      ((recordp readrec)
	       t)
	      ((osql "record_length(:rr);")
	       '((1)))
	      ((record-get readrec "key1")
	       "value1")))

(checkequal "print-record for records"
  ((osql "stringify(empty_record());") '(("empty_record()")))
  ((osql "stringify(make_record({'attr', 'val'}));") '(("{\"attr\":\"val\"}")))
  ((osql "stringify({'outer':{'nested':'value'}});")
    '(("{\"outer\":{\"nested\":\"value\"}}")))
)

