;;; ============================================================
;;; AMOS
;;; 
;;; Author: (c) 1995 Salah-Eddine Machani, EDSLAB
;;; $RCSfile: eca_rules.lsp,v $
;;; $Revision: 1.6 $ $Date: 2000/10/24 12:44:14 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: loads all the ECA rules files: 
;;;   event_manager.lsp, delta_sets.lsp, rules_network.lsp
;;;   rule_compiler, rule_processor.lsp
;;; Requirements: 
;;;   event_manager, delta_sets, rules_network, rule_compiler, rule_processor
;;; =============================================================
;;; $Log: eca_rules.lsp,v $
;;; Revision 1.6  2000/10/24 12:44:14  torer
;;; ECA rules OK
;;;
;;; Revision 1.5  2000/09/05 08:46:10  evato
;;; Removed a lot of CA stuff from rule system. (This code has currently
;;; been commented, instead of being entirely deleted). No longer possible
;;; to use "CA-rule system".
;;;
;;; Revision 1.4  2000/08/24 09:21:33  evato
;;; Made new functions ruleCheck and rule-find-freevars in the ECA rule package,
;;; since it redefined check and find-freevars in a non-compatible way.
;;;
;;; Revision 1.3  2000/08/21 09:33:50  evato
;;; Removed some of the new patches so that ECA rules will work. Also removed some functions
;;; that had to do with SAGAs in context.lsp.
;;;
;;;

;; Default trigger loop value
(defvar *max-trigger* 20)
(load "event_manager.lsp")
(load "delta_sets.lsp")
(load "rules_network.lsp")
(load "contexts.lsp")
(load "rule_compiler.lsp")
(load "rule_processor.lsp")
(load "rules.lsp")


















