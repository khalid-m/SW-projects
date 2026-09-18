;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997/8 Vanja Josifovski, EDSLAB
;;; $RCSfile: qd_objectloggen.lsp,v $
;;; $Revision: 1.7 $ $Date: 2006/11/04 17:47:14 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Objectlog generation from decomposition tree
;;; =============================================================
;;; $Log: qd_objectloggen.lsp,v $
;;; Revision 1.7  2006/11/04 17:47:14  torer
;;; Removed calls (/PUTOBJECT x 'ARGTYPES y)
;;;
;;; =============================================================


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Generation of execution plan given a decomposition tree
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun gen_decomposed_fno (dTree)
  (let* ((fno (create-transient-object _function_))
	 (tpnms (tNode-restypes dTree))
	 (restypes (mapcar #'gettypenamed tpnms))
	 (sb (/putobject 
	      fno 'selectbody 
	      (make-selectbody 
	       :argl (tNode-params dTree)
	       :argt (mapcar (f/l (v) (type_of_var v *bindings*))
			     (tNode-params dTree))
	       :resl (tNode-res dTree)
	       :rest restypes))))
    (setf (selectbody-optpred sb) (funify 'and (gen_decomposed_pred dTree)))
    (/putobject fno 'resolvents (list fno))
    fno))

(defun gen_decomposed_pred (dTree)
  (let* ((saeN (tNode-sae dTree))
	 (pplN (tNode-ppl dTree))
	 (mbN  (car (tNode-mbl dTree)))   ; the bottom node, produces data
	 (mbres (if mbN (tNode-res mbN))) ; the result from the bottom node
	 (saeres (if saeN (gNode-vars saeN)))
	 (data_var "")
	 ret_lst)

    ;Nested tree as mb node. Note that at the moment we assume
    ;that only one node is present (i.e. left-deep decomposition trees only)
    (if mbN
	; if sae and mb node is present generate the support functions for shipping
	; of the materialized partial results from the MB node to the SAE node
	(if saeN
	    (let* ((mkbfno (gen_decomposed_fno mbN))
		   (params (tNode-params mbN))
		   (bag_var (dt_genvar _bag_))
		   (saevars (gNode-vars saeN))
		   (allvars (union mbres saevars))
		   (saeNB (set-difference saevars mbres))
		   (allvars (append mbres saeNB)))
	      (setq saeres allvars)
	      (setq data_var (dt_genvar _bag_))
	      (setq ret_lst 
		    (list 
		     (append (list 'call 'makebag (getfunctionnamed 'makebag) mkbfno)
			     params
			     (list bag_var))
		     (list 'call 'bulken-+
			   (getfunctionnamed 'bulken)
			   bag_var
			   data_var))))
	    ;mb, but no sae, do not create a new function, but open the
	    ;predicates from the nested tree
	    (setq ret_lst (gen_decomposed_pred mbN))))

    ; Code generation and processing the result of a SAE node
    (if saeN
	(let* ((saefn     (gNode-fno saeN))
	       (saedb     (gNode-db saeN))
	       (saeParams (gNode-params saeN))
	       (shipinbpat (if (gNode-shipinflag saeN) (gnode-bpat saeN)))
	       (saeResTypeNames1 (get-real-types (gNode-vartypes saeN)
						 (gNode-org_vartypes saeN)))
	       ; get the types of the result (unbound) variables of the SAE node
	       (saeResTypeNames (mapfilter (f/l (tn_b) (eq '+ (cdr tn_b)))
					   (pair saeResTypeNames1 (gNode-bpat saeN))
					   (function car)))
	       (saeResTypes (mapcar 
			     (f/l(tn) 
	  ; generate the call to SAE
				 (or (literal_or_proxy tn)
				     (gettypenamed (proxy_type_name tn saedb))))
			     saeResTypeNames)))
	  ; generate the call to SAE
	  ;(assert (and (= (length saeResTypes) (length saeres)))
          ;        "result types and vars have different lengths")
	  (setq ret_lst 
		(append ret_lst
			(list 
			 (append (list
				  'call 'sae (getfunctionnamed 'sae) data_var
				  (make-runInfo
				   :remotefn saefn
				   :db       (mkstring saedb)
				   :input    mbres
				   :vars     (gNode-vars saeN)
				   :nParams  (length saeParams)
				   :resTypes saeResTypes
				   :shipInbpat shipinbpat))
				 saeParams
				 saeres))))))

    (if pplN
	(setq ret_lst (append ret_lst (process_pplN pplN))))

    ret_lst))

(defun literal_or_proxy (tn)
  (let ((tp (gettypenamed tn T)))
    (if (and tp 
	     (or (is_system_type_name tn) (proxytype? tp)))
	(gettypenamed tn t))))

(defun process_pplN (pplN)
  (appendl (mapcar #'process_ppN pplN)))

(defun process_ppN (ppN)
  (let* ((fn (gNode-fno ppN))
	 (sb (getobject  fn 'selectbody))
;	 (allvars (append (selectbody-argl sb)(selectbody-resl sb)))
	 (optpred (selectbody-optpred sb)))
;	 (optpred (expandfn allvars fn sb nil))) 
    (if (eq (car optpred) 'AND)
	(cdr optpred)
      (list optpred))))

(defun is_system_type_name (name)
  (let ((tpo (gettypenamed name t)))
	(and tpo (<= (oid-idno tpo) _system-watermark_))))
