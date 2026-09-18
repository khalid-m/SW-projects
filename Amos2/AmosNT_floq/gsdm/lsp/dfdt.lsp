;;; ===========================================================================
;;; AMOS2 - GSDM project
;;; 
;;; Author: (c) 2004 Milena Koparanova, UDBL
;;; $RCSfile: dfdt.lsp,v $
;;; $Revision: 1.2 $ $Date: 2005/12/01 21:48:55 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Functionality of GSDM coordinator
;;;              Generator of query and working nodes ids
;;;              Query levels in the dataflow graph
;;; ===========================================================================

;;; Generator for node id
(defvar *gennodeid* 0)
(defun gennodeid () (pack 'SQF (setq *gennodeid* (1+ *gennodeid*))))

(defun next_node_id (fnobj qid)
	(osql-result (mkstring (gennodeid))))

;;; Generator for stream name
(defvar *gensid* 0)
(defun gensid () (pack 'S (setq *gensid* (1+ *gensid*))))

(defun next_sid (fnobj sid)
	(osql-result (mkstring (gensid))))

;;; Generator for site id
(defvar *gensiteid* 0)
(defun gensiteid () (pack 'WN (setq *gensiteid* (1+ *gensiteid*))))

(defun next_site_id (fnobj qid)
	(osql-result (mkstring (gensiteid))))

(foreign-lispfn initmap () ()
(defglobal _map_ (make-hash-table :test 'equal)))

(foreign-lispfn updatemap ((object k) (object val)) ()
 (puthash k _map_ val))

(foreign-lispfn getmap ((object k)) ((object val))
(foreign-result (gethash k _map_ )))