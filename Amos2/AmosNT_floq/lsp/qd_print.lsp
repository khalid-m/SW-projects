;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997/8 Vanja Josifovski, EDSLAB
;;; $RCSfile: qd_print.lsp,v $
;;; $Revision: 1.7 $ $Date: 2005/01/04 14:15:22 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: prints graph and tree nodes used in the decomposition
;;; =============================================================


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Tree print functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun tnp (node &optional str ps)
  "Print a decomposition tree. Very rudimentary."
  (let ((ps (if ps ps "")))
    (formatl str ps "-----------------------------------------------------" t)
    (cond ((and (listp node) (eq (car node) 'OR))
	   (formatl str ps "OR" t)
	   (tnpl (cdr node) str (concat ps "     ")))
	  (t
	   (formatl str ps "mbl: " )
	   (if (tNode-mbl node) (formatl str t) (formatl str nil t))
	   (tnpl (tNode-mbl node) str (concat ps "     "))

	   (formatl str ps "sae: " )
	   (gnp (tNode-sae node) str (concat ps "     "))   

	   (formatl str ps "ppl: " )
	   (if (tNode-ppl node) (formatl str t) (formatl str nil t))
	   (gnpl (tNode-ppl node) str (concat ps "     "))

	   (formatl str
		    ps "db    : "     (tNode-db  node) t
		    ps "cost  : "     (tNode-cost node) t
		    ps "fanout: "     (tNode-fanout node) t
		    ps "params    : " (tNode-params node) t
		    ps "paramtypes: " (tNode-paramtypes node) t
		    ps "res     : " (tNode-res node) t
		    ps "restypes: " (tNode-restypes node) t
		    ;; ps "rem: "
		    )))
    ;;(if (tNode-rem node) (formatl str t) (formatl str nil t)) 
    ;;(mapcar (f/l (g) (gnp g (concat "    "  ps))) (tNode-rem node))
    (formatl str ps 
	     "-----------------------------------------------------" t)))

(defun gnp (node str &optional ps)
  (gnpstr node str ps))

(defun prnodes (nodes file)
  "Print NODES on FILE"
  (with-output-file str file
		    (dolist (n (mklist nodes))(gnp n str))))

(defun gnpstr (node str &optional ps)
  (if (not node) 
      (formatl str 'NIL t)
    (let ((pn (if ps ps "")))
      (formatl str t)
      (formatl str pn '----------------------------------------------------- t)
      (formatl str pn "predl: " t)
      (formatl str pn)
      (pps (gNode-predl node) str (length ps)) 
      (formatl str
	       pn "fno: "        (gNode-fno node) t
	       pn "db : "        (gNode-db  node) t
	       pn "vars      : " (gNode-vars node) t
	       pn "vartypes  : " (gNode-vartypes node) t
	       pn "org_vartypes : " (gNode-org_vartypes node) t
	       pn "params    : " (gNode-params node) t
	       pn "paramtypes: " (gNode-paramtypes node) t
	       pn "org_paramtypes: " (gNode-org_paramtypes node) t
	       pn "bpat      : " (gNode-bpat node) t
	       pn "cost  : "     (gNode-cost node) t
	       pn "fanout: "     (gNode-fanout node) t
	       pn "shipInFlag: " (if (gNode-shipinflag node) 'TRUE 'FALSE) t)
      (formatl str pn 
	       '----------------------------------------------------- t))))

;some debugging functions that print all plans in a list etc.
(defun pap   (l str &optional ps)
  (mapc (f/l (p) (tnp (second p) str ps)) l))

(defun tnpl  (l str &optional ps)
  (mapc (f/l (p) (tnp p str ps)) l))

(defun gnpl  (l str &optional ps)
  (mapc (f/l (p) (gnp p str ps)) l))
