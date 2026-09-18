;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: core-cluster.lsp,v $
;;; $Revision: 1.3 $ $Date: 2009/04/15 17:02:17 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Aid functions for writing core-cluster functions
;;;              
;;; ===========================================================================
(defun make-core-cluster-fn-name (entity-name &optional fnname)
  "Makes a standardized core cluster function name out of the typename and the
   name of a propery function if one is specified.
   The argument, relation-name, can be the name of a mapped type or a mapped 
   property function."
  (let ((suffix '_cc))
    (if fnname
	(pack entity-name '_ fnname  suffix)
    (pack entity-name suffix))))

(defun make-mapped-typename (ds typename) (pack typename '_ (oid-name ds)))

(defun core-cluster-fn?(fno)(getobject(generic-function-of fno)'cclusterfct?))

(defun create-core-cluster-function (ds container-name properties 
				     key-properties &optional foreign-impl)
  "Creates a core-cluster function for a named container whose properties and
   keys are given.
   The core-cluster function can be non-executable or executable (for testing 
   purposes.) if a foreign implementation is supplied. In this case the name
   must be supplied as a string which is the name of a Lisp function.
   ds - the datasource where the data container is stored.
   properties - the containers' properties in its native context
   ((<type> <name)...)"
  (let* ((name       (make-core-cluster-fn-name container-name))
	 (no-args nil)
	 (results properties)
	 (resv    (if foreign-impl 'foreign))
	 (quant   (if foreign-impl (list foreign-impl)))
	 (pred    nil)
	 (ccfno   (createfunction name no-args results resv quant pred)))
    (declare-keys ccfno key-properties properties)
    ; renders the function unexecutable
    (if (not foreign-impl)(set-costhint ccfno(make-string(length results) "f")
					"core_cluster_cost"))
    (/putobject ccfno 'cclusterfct? t)
    (/putobject ccfno 'datasource ds)
    (/putobject ccfno 'defaultabsorbent 'amos-translate-type-core-cluster)
    (/putobject ccfno 'container-name container-name)
    (/putobject ccfno 'native-properties properties)

    (add-rewriter ccfno (buildn (length results) '+) 'rewrite-extent)
    ccfno))