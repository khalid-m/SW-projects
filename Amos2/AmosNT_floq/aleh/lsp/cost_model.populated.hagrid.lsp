;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Ruslan Fomkin, UDBL
;;; $RCSfile: cost_model.populated.hagrid.lsp,v $
;;; $Revision: 1.4 $ $Date: 2008/03/19 13:18:03 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Cost model for ALEH. It is usefull only if data are populated. This file
;;; contains cost model for Hagrid.
;;;              
;;; ===========================================================================
;;; $Log: cost_model.populated.hagrid.lsp,v $
;;; Revision 1.4  2008/03/19 13:18:03  ruslan
;;; cost models
;;;
;;; Revision 1.3  2007/12/14 11:25:27  ruslan
;;; cost models revisited. For Hagrid it is based on current measurements
;;;
;;; Revision 1.2  2007/12/13 11:00:24  ruslan
;;; cost model for structs is moved to separarte file
;;;
;;; Revision 1.1  2007/12/12 09:46:19  ruslan
;;; constants for cost model for aggregates fro hagrid
;;;
;;; ===========================================================================

(load "../lsp/cost_model.populated.lsp")
(load "../lsp/cost_model.structs.lsp")

(setq _in_ (getfunctionnamed  'in))
(setq _default-in-fanout_ 9.0)
(setq _default-count-fanout_ 0.3)
(setq _default-some-fanout_ 0.5)
(setq _default-iteration-cost_ 1.0)
(setq _default-foreign-fanout_ 1.0)
(setq _default-foreign-cost_ 1.0)
(setq _default-sq-iteration-cost_ 2.0)
(setq _minimal-aggregation-cost_  ; cost of execution subquery
  (* _default-sq-iteration-cost_ _default-in-fanout_))
(setq _default-aggregate-fanout_ 1.0)
(setq _default-key-fanout_ 1.0)
(setq _lowest-priority_ '(0 1.0)) ; Cost to push predicate early
(setq _default-constructor-fanout_ 1.0)
(setq _lowest-fanout_ 0.001)
(setq _fanout-equal-one_ 0.99)
(setq _default-makebag-cost_ 1.1)
(setq _default-struct-acces-cost_ 1.1)
(setq _default-vref-access-cost_ 1.1)
