;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Ruslan Fomkin, UDBL
;;; $RCSfile: profiling.structs.lsp,v $
;;; $Revision: 1.8 $ $Date: 2008/08/20 09:15:04 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  
;;; ===========================================================================
;;; $Log: profiling.structs.lsp,v $
;;; Revision 1.8  2008/08/20 09:15:04  ruslan
;;; aleh_stream is derived function, which returns event by iterating into wrapper access function
;;;
;;; Revision 1.7  2008/07/10 13:13:29  ruslan
;;; missing wrapper interval functions
;;;
;;; Revision 1.6  2008/05/21 11:53:18  ruslan
;;; bug is fixed by providing the wrapper function
;;;
;;; Revision 1.5  2008/05/10 13:06:49  ruslan
;;; wrapper returns only sobject without the key vector, names of wrapper functions in correspondance with the Thesis, aleh_stream is used to stream events instead of filename
;;;
;;; Revision 1.4  2008/05/05 07:36:01  ruslan
;;; the same view as in loading
;;;
;;; Revision 1.3  2008/05/01 10:47:17  ruslan
;;; specifying file makes call to the wrapper in streaming approach
;;;
;;; Revision 1.2  2008/04/14 15:02:31  ruslan
;;; generalization of grouping algorithm to handle list of wrapping functions
;;;
;;; Revision 1.1  2007/11/07 12:26:49  ruslan
;;; profiling is working for the current approach (streaming structs)
;;;
;;; ===========================================================================

(load "../lsp/profiling.lsp")

; used in grouping algorithm to find, which group accessing wrapper
(setq *wrapper-fn* 
      (list (getfunctionnamed 'CHARSTRING.ALEH_STREAM->EVENT)
	    (getfunctionnamed 
	     'CHARSTRING.INTEGER.INTEGER.ALEH_STREAM->EVENT)
	    (getfunctionnamed 
	     'FUNCTION.INTEGER.CHARSTRING.CLOSEDNF->EVENT)
	    (getfunctionnamed 
	     'FUNCTION.INTEGER.CHARSTRING.INTEGER.INTEGER.CLOSEDNF->EVENT)
	    (getfunctionnamed
	     'CHARSTRING.CHARSTRING.CHARSTRING.VECTOR.TYPE.INTEGER.ROOT_SCAN_PROJECT_ADDSLOTS->BAG-SOBJECT)
	    (getfunctionnamed
	     'CHARSTRING.CHARSTRING.CHARSTRING.VECTOR.TYPE.INTEGER.INTEGER.ROOT_GET_INTERVAL_SOBJECTS_PROJECT->BAG-SOBJECT)
	    (getfunctionnamed
	     'CHARSTRING.CHARSTRING.CHARSTRING.VECTOR.TYPE.INTEGER.INTEGER.INTEGER.ROOT_GET_INTERVAL_SOBJECTS_PROJECT->BAG-SOBJECT)))
