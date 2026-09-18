;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Ruslan Fomkin, UDBL
;;; $RCSfile: udfs_exectime.lsp,v $
;;; $Revision: 1.15 $ $Date: 2008/03/17 10:28:53 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  To measure cost model for UDFs.
;;; ===========================================================================
;;; $Log: udfs_exectime.lsp,v $
;;; Revision 1.15  2008/03/17 10:28:53  ruslan
;;; experiment for measuring UDFs performance
;;;
;;; Revision 1.14  2008/03/16 10:09:23  ruslan
;;; bugs are fixed
;;;
;;; Revision 1.13  2008/03/14 08:19:59  ruslan
;;; bug is fixed
;;;
;;; Revision 1.12  2008/03/13 10:21:09  ruslan
;;; a bug is fixed
;;;
;;; Revision 1.11  2008/03/12 12:08:57  ruslan
;;; bug is fixed
;;;
;;; Revision 1.10  2008/03/10 15:58:59  ruslan
;;; type containers defined. this removes some type check, but not all of them, while they still can be removed somehow. missing cost models
;;;
;;; Revision 1.9  2007/12/14 10:20:41  ruslan
;;; sleep for 10 seconds only, since a node on Hagrid is fully available
;;;
;;; Revision 1.8  2007/12/08 14:05:26  ruslan
;;; as call to one function only
;;;
;;; Revision 1.7  2007/12/08 14:03:02  ruslan
;;; all udfs are there
;;;
;;; Revision 1.6  2007/12/08 11:15:00  ruslan
;;; measuring cost model for UDFs, except struct udfs, which are under writting
;;;
;;; Revision 1.5  2007/11/16 13:55:56  ruslan
;;; some aggregate functions
;;;
;;; Revision 1.4  2007/11/16 12:52:00  ruslan
;;; vector udfs
;;;
;;; Revision 1.3  2007/11/16 09:19:54  ruslan
;;; vector udfs
;;;
;;; Revision 1.2  2007/11/16 08:12:48  ruslan
;;; more functions
;;;
;;; Revision 1.1  2007/11/15 09:53:57  ruslan
;;; measuring execution time for UDFs
;;;
;;; ===========================================================================

(defglobal _rptavg_ 10) 
(defglobal _rptuntil_ 2.0) 
(defglobal _tosleep_ 10)

(osql "create function vectortest()->vector as select {3.4,2.1,-5.4};")
(osql "create function simpletest()->real as select -3.4;")
(osql "create function closednffn(event e) -> particle as select 
get_slot(e,0);")

(defun exectime-udfs (filename)
  (setq *mystream* (openstream filename "w"))
  (let (argl fno)
    (setq argl (list 4.3 -64.1))
    (print-list 
     (cons "NUMBER.NUMBER.PLUS->NUMBER"
	   (udf-exectime 'NUMBER.NUMBER.PLUS->NUMBER argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "NUMBER.NUMBER.TIMES->NUMBER"
	   (udf-exectime 'NUMBER.NUMBER.TIMES->NUMBER argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list
     (cons "NUMBER.NUMBER.ATAN2->REAL"
	   (udf-exectime 'NUMBER.NUMBER.ATAN2->REAL argl
			 _rptavg_ _rptuntil_ _tosleep_)))	 
    (print-list
     (cons "NUMBER.NUMBER.PT->REAL"
	   (udf-exectime 'NUMBER.NUMBER.PT->REAL argl
			 _rptavg_ _rptuntil_ _tosleep_)))	 
    (print-list
     (cons "NUMBER.NUMBER.MODULO->REAL"
	   (udf-exectime 'NUMBER.NUMBER.MODULO->REAL argl
			 _rptavg_ _rptuntil_ _tosleep_)))	 
    (setq argl (list 4.3))
    (print-list 
     (cons "NUMBER.ABS->NUMBER"
	   (udf-exectime 'NUMBER.ABS->NUMBER argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "NUMBER.SQRT_POS->REAL"
	   (udf-exectime 'NUMBER.SQRT_POS->REAL argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "NUMBER.LOG->REAL"
	   (udf-exectime 'NUMBER.LOG->REAL argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "NUMBER.CEILING->INTEGER"
	   (udf-exectime 'NUMBER.CEILING->INTEGER argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "NUMBER.COS->REAL"
	   (udf-exectime 'NUMBER.COS->REAL argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list 4.3 -64.1 0.32))
    (print-list 
     (cons "NUMBER.NUMBER.NUMBER.MAGNITUDE->REAL"
	   (udf-exectime 'NUMBER.NUMBER.NUMBER.MAGNITUDE->REAL argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "NUMBER.NUMBER.NUMBER.ETA->REAL"
	   (udf-exectime 'NUMBER.NUMBER.NUMBER.ETA->REAL argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "NUMBER.NUMBER.NUMBER.PLUS->NUMBER"
	   (udf-exectime 'NUMBER.NUMBER.NUMBER.PLUS->NUMBER argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "OBJECT.OBJECT.OBJECT.NOT_IN->BOOLEAN"
	   (udf-exectime 'OBJECT.OBJECT.OBJECT.NOT_IN->BOOLEAN argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list 4.3 -64.1 0.32 54.3))
    (print-list 
     (cons "NUMBER.NUMBER.NUMBER.NUMBER.EFFECTIVEMASS->REAL"
	   (udf-exectime 'NUMBER.NUMBER.NUMBER.NUMBER.EFFECTIVEMASS->REAL argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "OBJECT.OBJECT.OBJECT.OBJECT.NOT_IN->BOOLEAN"
	   (udf-exectime 'OBJECT.OBJECT.OBJECT.OBJECT.NOT_IN->BOOLEAN argl 
			 _rptavg_ _rptuntil_ _tosleep_)))

;;; Charstring operators

    (setq argl (list "event.leptonsfn->lepton"))
    (print-list 
     (cons "CHARSTRING.UPPER->CHARSTRING"
	   (udf-exectime 'CHARSTRING.UPPER->CHARSTRING argl 
			 _rptavg_ _rptuntil_ _tosleep_)))

;;; Cost model for vector operators

    (setq argl (list (vector 4.3 -64.1 0.32) 1))
    (print-list 
     (cons "VECTOR.INTEGER.VREF->OBJECT bbf"
	   (udf-exectime 'VECTOR.INTEGER.VREF->OBJECT argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (vector 4.3 -64.1 0.32) (vector 54.3 24.1 -40.32)))
    (print-list 
     (cons "VECTOR.VECTOR.TIMES->NUMBER"
	   (udf-exectime 'VECTOR.VECTOR.TIMES->NUMBER argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "VECTOR.VECTOR.PLUS->VECTOR"
	   (udf-exectime 'VECTOR.VECTOR.PLUS->VECTOR argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (vector 4.3 -64.1 0.32) (vector 54.3 24.1 -40.32)
		     (vector 3.2 3.5 21.1)))
    (print-list 
     (cons "VECTOR.VECTOR.VECTOR.PLUS->VECTOR"
	   (udf-exectime 'VECTOR.VECTOR.VECTOR.PLUS->VECTOR argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list 3.54 (vector 4.3 -64.1 0.32)))
    (print-list 
     (cons "OBJECT.VECTOR.NOT_IN->BOOLEAN"
	   (udf-exectime 'OBJECT.VECTOR.NOT_IN->BOOLEAN argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (vector 4.3 -64.1) (vector 54.3 24.1)))
    (print-list 
     (cons "VECTOR.VECTOR.EFFECTIVEMASS->REAL"
	   (udf-exectime 'VECTOR.VECTOR.EFFECTIVEMASS->REAL argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (vector 4.3 -64.1)))
    (print-list 
     (cons "VECTOR.MOD->REAL"
	   (udf-exectime 'VECTOR.MOD->REAL argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (vector 4.3 -64.1 0.32)))
    (setq fno (getfunctionnamed 'vectortest->vector))
    (print-list 
     (cons "CONSTRUCT-VECTORC"
	   (udf-exectime fno nil
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq fno (getfunctionnamed 'simpletest->real))
    (print-list 
     (cons "SIMPLE FUNCTION"
	   (udf-exectime fno nil
			 _rptavg_ _rptuntil_ _tosleep_)))
; vector.in is not used in aleh queries
;    (print-list 
;     (cons "VECTOR.IN->OBJECT"
;	   (udf-exectime 'VECTOR.IN->OBJECT argl 
;			 _rptavg_ _rptuntil_ _tosleep_))))
    (setq argl (list 24.1 40.32))
    (print-list 
     (cons "OBJECT.OBJECT.<=->BOOLEAN"
	   (udf-exectime 'OBJECT.OBJECT.<=->BOOLEAN argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "OBJECT.OBJECT.>=->BOOLEAN"
	   (udf-exectime 'OBJECT.OBJECT.>=->BOOLEAN argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "OBJECT.OBJECT.<->BOOLEAN"
	   (udf-exectime 'OBJECT.OBJECT.<->BOOLEAN argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "OBJECT.OBJECT.>->BOOLEAN"
	   (udf-exectime 'OBJECT.OBJECT.>->BOOLEAN argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "OBJECT.OBJECT.!=->BOOLEAN"
	   (udf-exectime 'OBJECT.OBJECT.!=->BOOLEAN argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "OBJECT.OBJECT.=->BOOLEAN"
	   (udf-exectime 'OBJECT.OBJECT.=->BOOLEAN argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq fno (getfunctionnamed 'object.typesof->type))
    (setq fno (the-tbr-function fno '(- -)))
    (setq argl (list (caar (osql "{23.4,53.1,43.0};")) 
		     (gettypenamed 'VECTOR)))
    (print-list 
     (cons "OBJECT.TYPESOF->TYPE BB"
	   (udf-exectime fno argl 
			 _rptavg_ _rptuntil_ _tosleep_)))

;;; Cost model for aggregation operators

    (setq argl (list (aggr_bag (vector 4.3 -64.1 0.32) 
			       (vector 54.3 24.1 -40.32))))
    (print-list 
     (cons "BAG-VECTOR.SUM->VECTOR-NUMBER 2 elements"
	   (udf-exectime 'BAG-VECTOR.SUM->VECTOR-NUMBER argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (aggr_bag (vector 4.3 -64.1 0.32) 
			       (vector 54.3 24.1 -40.32)
			       (vector 3.2 6.4 -3.0)
			       (vector 3.4 -2.1 45.3))))
    (print-list 
     (cons "BAG-VECTOR.SUM->VECTOR-NUMBER 4 elements"
	   (udf-exectime 'BAG-VECTOR.SUM->VECTOR-NUMBER argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (aggr_bag 5.4 2.1 -54 6.2)))
    (print-list 
     (cons "BAG-NUMBER.SUM->NUMBER 4 elements"
	   (udf-exectime 'BAG-NUMBER.SUM->NUMBER argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (aggr_bag 5.4 53.04)))
    (print-list 
     (cons "BAG-NUMBER.SUM->NUMBER 2 elements"
	   (udf-exectime 'BAG-NUMBER.SUM->NUMBER argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "BAG.COUNT->INTEGER 2 elements"
	   (udf-exectime 'BAG.COUNT->INTEGER argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (aggr_bag 5.4 2.1 -54 6.2)))
    (print-list 
     (cons "BAG.COUNT->INTEGER 4 elements"
	   (udf-exectime 'BAG.COUNT->INTEGER argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "BAG.NOTANYC->BOOLEAN 4 elements"
	   (udf-exectime 'BAG.NOTANYC->BOOLEAN argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (aggr_bag 5.4)))
    (print-list 
     (cons "BAG.NOTANYC->BOOLEAN 1 element"
	   (udf-exectime 'BAG.NOTANYC->BOOLEAN argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "BAG.SOMEC->BOOLEAN 1 element"
	   (udf-exectime 'BAG.SOMEC->BOOLEAN argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (aggr_bag 5.4 2.1 -54 6.2)))
    (print-list 
     (cons "BAG.SOMEC->BOOLEAN 4 elements"
	   (udf-exectime 'BAG.SOMEC->BOOLEAN argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq fno (getfunctionnamed 'BAG.COUNT->INTEGER))
    (setq fno (the-tbr-function fno '(- -)))
    (setq argl (list (first argl) 2))
    (print-list 
     (cons "BAG.COUNT->INTEGER BB 4 elements"
	   (udf-exectime 'BAG.COUNT->INTEGER argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (aggr_bag 5.4 2.1) 2))
    (print-list 
     (cons "BAG.COUNT->INTEGER BB 2 elements"
	   (udf-exectime 'BAG.COUNT->INTEGER argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list 2 (aggr_bag 5.4 2.1)))
    (print-list 
     (cons "INTEGER.BAG.ATLEAST->BOOLEAN 2 elements"
	   (udf-exectime 'INTEGER.BAG.ATLEAST->BOOLEAN argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list 2 (aggr_bag 5.4 2.1 -32.1 4.3)))
    (print-list 
     (cons "INTEGER.BAG.ATLEAST->BOOLEAN 4 elements"
	   (udf-exectime 'INTEGER.BAG.ATLEAST->BOOLEAN argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (aggr_bag (list 3 5.4)(list 2 2.1)(list 5 -32.1)
			       (list 0 4.3))))
    (print-list 
     (cons "BAG.MINAGG2->NUMBER.OBJECT 4 elements"
	   (udf-exectime 'BAG.MINAGG2->NUMBER.OBJECT argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (aggr_bag (list 3 5.4)(list 2 2.1))))
    (print-list 
     (cons "BAG.MINAGG2->NUMBER.OBJECT 2 elements"
	   (udf-exectime 'BAG.MINAGG2->NUMBER.OBJECT argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "BAG.SUM2->NUMBER.NUMBER 2 elements"
	   (udf-exectime 'BAG.SUM2->NUMBER.NUMBER argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (aggr_bag (list 3 5.4)(list 2 2.1)(list 5 -32.1)
			       (list 0 4.3))))
    (print-list 
     (cons "BAG.SUM2->NUMBER.NUMBER 4 elements"
	   (udf-exectime 'BAG.SUM2->NUMBER.NUMBER argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (aggr_bag (list 3 5.4 43.2 -3.2)(list 2 2.1 43 5.4)
			       (list 5 -32.1 23.3 45)(list 0 4.3 -43 -32.2))))
    (print-list 
     (cons "BAG.MINAGG4->NUMBER.OBJECT.OBJECT.OBJECT 4 elements"
	   (udf-exectime 'BAG.MINAGG4->NUMBER.OBJECT.OBJECT.OBJECT argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (aggr_bag (list 3 5.4 43.2 -3.2)(list 2 2.1 43 5.4))))
    (print-list 
     (cons "BAG.MINAGG4->NUMBER.OBJECT.OBJECT.OBJECT 2 elements"
	   (udf-exectime 'BAG.MINAGG4->NUMBER.OBJECT.OBJECT.OBJECT argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (getfunctionnamed 'integer.integer.iota->integer)))
    (print-list 
     (cons "FUNCTION.MAKEBAG->BAG"
	   (udf-exectime 'FUNCTION.MAKEBAG->BAG argl 
			 _rptavg_ _rptuntil_ _tosleep_)))

;;; creating sobjects

    (setq argl (list (caar (osql "select typenamed('MUON');"))
		     12
		     (vector 34 4 3.2 -45.2 3.56 23.1 5)))
    (print-list 
     (cons "TYPE.OBJECT.VECTOR.NEW_SOBJECT->SOBJECT"
	   (udf-exectime 'TYPE.OBJECT.VECTOR.NEW_SOBJECT->SOBJECT argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (caar (osql "select typenamed('MUON');"))
		     12 "myfile"
		     (vector 34 4 3.2 -45.2 3.56 23.1 5)))
    (print-list 
     (cons "TYPE.OBJECT.OBJECT.VECTOR.NEW_SOBJECT->SOBJECT"
	   (udf-exectime 'TYPE.OBJECT.OBJECT.VECTOR.NEW_SOBJECT->SOBJECT argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (vector 3 4 5 6 7)
		     (caar (osql "new_event(typenamed('EVENT'),'filename',12,
{3,23,-3.2,{3,2,5,4},{3.2,4.3,0.1,5.4},{1.6,5.3,-32.1,54.2},{3.2,4.3,0.1,5.4},
{1.6,5.3,-32.1,54.2},534,{34,32,-4,3.3},2.3});"))
		     (caar (osql "typenamed('MUON');")) 1))
    (print-list 
     (cons "VECTOR.SOBJECT.TYPE.INTEGER.TRANSPOSE->BOOLEAN"
	   (udf-exectime 'VECTOR.SOBJECT.TYPE.INTEGER.TRANSPOSE->BOOLEAN argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (vector 3 4 5 6 7)
		     (caar (osql "new_event(typenamed('EVENT'),'filename',12,
{3,23,-3.2,{3,2,5,4},{3.2,4.3,0.1,5.4},{1.6,5.3,-32.1,54.2},{3.2,4.3,0.1,5.4},
{1.6,5.3,-32.1,54.2},534,{34,32,-4,3.3},2.3});"))
		     (caar (osql "typenamed('MUON');")) 1 2))
    (print-list 
     (cons "VECTOR.SOBJECT.TYPE.INTEGER.INTEGER.TRANSPOSE->BOOLEAN"
	   (udf-exectime 
	    'VECTOR.SOBJECT.TYPE.INTEGER.INTEGER.TRANSPOSE->BOOLEAN argl 
	    _rptavg_ _rptuntil_ _tosleep_)))

;;; vector transpose

    (setq argl (list (vector (vector 3 2 5 4)(vector 3.2 4.3 0.1 5.4)
			     (vector 1.6 5.3 -32.1 54.2)
			     (vector 3.2 4.3 0.1 5.4)
			     (vector 1.6 5.3 -32.1 54.2))))
    (print-list 
     (cons "VECTOR.TRANSPOSE->VECTOR"
	   (udf-exectime 'VECTOR.TRANSPOSE->VECTOR argl 
			 _rptavg_ _rptuntil_ _tosleep_)))

;;; functions operated on sobjects

    (setq argl (list (caar (osql "new_event(typenamed('EVENT'),'filename',12,
{3,23,-3.2,{3,2,5,4},{3.2,4.3,0.1,5.4},{1.6,5.3,-32.1,54.2},{3.2,4.3,0.1,5.4},
{1.6,5.3,-32.1,54.2},534,{34,32,-4,3.3},2.3});")) 6))
    (print-list 
     (cons "SOBJECT.INTEGER.GET_SLOT->OBJECT"
	   (udf-exectime 'SOBJECT.INTEGER.GET_SLOT->OBJECT argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "SOBJECT.INTEGER.GET_SLOT_BAG->OBJECT"
	   (udf-exectime 'SOBJECT.INTEGER.GET_SLOT_BAG->OBJECT argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (caar (osql "new_event(typenamed('EVENT'),'filename',12,
{3,23,-3.2,{3,2,5,4},{3.2,4.3,0.1,5.4},{1.6,5.3,-32.1,54.2},{3.2,4.3,0.1,5.4},
{1.6,5.3,-32.1,54.2},534,{34,32,-4,3.3},2.3});")) 7 32.3))
    (print-list 
     (cons "SOBJECT.INTEGER.OBJECT.SET_SLOT->BOOLEAN"
	   (udf-exectime 'SOBJECT.INTEGER.OBJECT.SET_SLOT->BOOLEAN argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (caar (osql "new_event(typenamed('EVENT'),'filename',12,
{3,23,-3.2,{3,2,5,4},{3.2,4.3,0.1,5.4},{1.6,5.3,-32.1,54.2},{3.2,4.3,0.1,5.4},
{1.6,5.3,-32.1,54.2},534,{34,32,-4,3.3},2.3});")) 7 
(vector 3.2 -43.2 32.1 4.3)))
    (print-list 
     (cons "SOBJECT.INTEGER.VECTOR.SET_SLOTVECTOR->BOOLEAN"
	   (udf-exectime 'SOBJECT.INTEGER.VECTOR.SET_SLOTVECTOR->BOOLEAN argl 
			 _rptavg_ _rptuntil_ _tosleep_)))
    (setq argl (list (caar (osql "new_event(typenamed('EVENT'),'filename',12,
{3,23,-3.2,{3,2,5,4},{3.2,4.3,0.1,5.4},{1.6,5.3,-32.1,54.2},{3.2,4.3,0.1,5.4},
{1.6,5.3,-32.1,54.2},534,{34,32,-4,3.3},2.3});")) 7 (vector 3.2 -43.2 32.1 4.3)
(getfunctionnamed 'TYPE.INTEGER.INTEGER.SET_SOBJECTSTAT->BOOLEAN)))
    (print-list 
     (cons "SOBJECT.INTEGER.VECTOR.FUNCTION.SET_SLOTVECTOR->BOOLEAN"
	   (udf-exectime 
	    'SOBJECT.INTEGER.VECTOR.FUNCTION.SET_SLOTVECTOR->BOOLEAN argl 
	    _rptavg_ _rptuntil_ _tosleep_)))
    (print-list 
     (cons "SOBJECT.INTEGER.VECTOR.FUNCTION.SET_SLOTVECTOR->BOOLEAN"
	   (udf-exectime 
	    'SOBJECT.INTEGER.VECTOR.FUNCTION.SET_SLOTVECTOR->BOOLEAN argl 
	    _rptavg_ _rptuntil_ _tosleep_)))
)
;;; Closing DNF

;    (setq fno (getfunctionnamed 'EVENT.CLOSEDNFFN->PARTICLE))
;    (setq argl (list (caar (osql "select new_event(e,{{m1,m2},23,-3.2,
;2.32,5.4,3,{3,23,0.2},3,534,{34,32,-4,3.3},2.3}) from struct_type e, 
;struct_type m, muon m1, muon m2 where name(m)='MUON' and name(e)='EVENT' and
;m1=new_muon(m,{2,3,3,2,1.4}) and m2=new_muon(m,{4,3,2.3,1,-3.2});"))))
;    (print-list 
;     (cons "EVENT.CLOSEDNFFN->LEPTON 2 particles"
	;   (udf-exectime fno argl 
;			 _rptavg_ _rptuntil_ _tosleep_)))
;    (setq argl (list fno 1 (caar (osql "select new_event(e,{{m1,m2},23,-3.2,
;2.32,5.4,3,{3,23,0.2},3,534,{34,32,-4,3.3},2.3}) from struct_type e, 
;struct_type m, muon m1, muon m2 where name(m)='MUON' and name(e)='EVENT' and
;m1=new_muon(m,{2,3,3,2,1.4}) and m2=new_muon(m,{4,3,2.3,1,-3.2});"))))
;    (print-list 
;     (cons "FUNCTION.INTEGER.EVENT.CLOSEDNF->PARTICLE 2 particles"
;	   (udf-exectime 'FUNCTION.INTEGER.EVENT.CLOSEDNF->PARTICLE argl 
;			 _rptavg_ _rptuntil_ _tosleep_)))
;    (setq argl (list (caar (osql "select new_event(e,{{m1,m2,m3,m4},23,-3.2,
;2.32,5.4,3,{3,23,0.2},3,534,{34,32,-4,3.3},2.3}) from struct_type e, 
;struct_type m, muon m1, muon m2, muon m3, muon m4 where name(m)='MUON' and name(e)='EVENT' and
;m1=new_muon(m,{2,3,3,2,1.4}) and m2=new_muon(m,{4,3,2.3,1,-3.2}) and
;m3=new_muon(m,{2,3,3,2,1.4}) and m4=new_muon(m,{4,3,2.3,1,-3.2});"))))
;    (print-list 
 ;    (cons "EVENT.CLOSEDNFFN->LEPTON 4 particles"
;	   (udf-exectime fno argl 
;			 _rptavg_ _rptuntil_ _tosleep_)))
;    (setq argl (list fno 1 (caar (osql "select new_event(e,{{m1,m2,m3,m4},23,-3.2,
;2.32,5.4,3,{3,23,0.2},3,534,{34,32,-4,3.3},2.3}) from struct_type e, 
;struct_type m, muon m1, muon m2, muon m3, muon m4 where name(m)='MUON' and name(e)='EVENT' and
;m1=new_muon(m,{2,3,3,2,1.4}) and m2=new_muon(m,{4,3,2.3,1,-3.2}) and
;m3=new_muon(m,{2,3,3,2,1.4}) and m4=new_muon(m,{4,3,2.3,1,-3.2});"))))
;    (print-list 
;     (cons "FUNCTION.INTEGER.EVENT.CLOSEDNF->PARTICLE 4 particles"
;	   (udf-exectime 'FUNCTION.INTEGER.EVENT.CLOSEDNF->PARTICLE argl 
;			 _rptavg_ _rptuntil_ _tosleep_))))
  (closestream *mystream*)
  (setq *mystream* nil))

(foreign-lispfn exectime_udfs ((charstring fileout))()
		(exectime-udfs fileout))