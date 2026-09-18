;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2001 Timour Katchaounov, UDBL
;;; $RCSfile: graph.lsp,v $
;;; $Revision: 1.8 $ $Date: 2003/05/28 07:52:18 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Visualize distributed execution plans.
;;;              Interface to the ATT GraphVis DOT tool for graph visualization.
;;; ===========================================================================

(foreign-lispfn init_graph () ()
  (init-graph)
  (foreign-result))

(defun init-graph ()

; depends on the profiler
(init-profiler)

(defstruct dfg
  ; A data-flow graph
  name
  newln ; symbol to represent new lines '\n' (there is a problem when transmitting it remotely)
  edge-count ; total number of edges in the graph
  nodes ; list of all nodes
  edges ; list of all edges
)

(defstruct dfgnode
  id ; unique ID of the node (symbol)
  label ; assoc. list of labels: ((key val) ...)
  rank ; nodes with same rank can be alinged easily
  type ; Amos or ODBC
)

(defstruct dfgedge
  src ; source node id
  dst ; destination node id
  label ; assoc. list of labels: ((key val) ...)
)

(defun add-edge-label (dfg src1 dst1 key val)
  (let ((edge-lst (dfg-edges dfg))
	(src (mksymbol src1))
	(dst (mksymbol dst1))
	cur-edge edge)
    ; find the edge between src/dst nodes
    (while (and (null edge) edge-lst)
      (setq cur-edge (car edge-lst))
      (if (and (eq src (dfgedge-src cur-edge))
	       (eq dst (dfgedge-dst cur-edge)))
	  (setq edge cur-edge)
	  (setq edge-lst (cdr edge-lst))))
    ; add the new label to this edge
    (if edge
	(setf (dfgedge-label edge) (nconc1 (dfgedge-label edge) (list key val))))
    edge))

(defun add-node-label (dfg nid1 key val)
  (let ((node-lst (dfg-nodes dfg))
	(nid (mksymbol nid1))
	cur-node node)
    ; find the node
    (while (and (null node) node-lst)
      (setq cur-node (car node-lst))
      (if (eq (dfgnode-id cur-node) nid)
	  (setq node cur-node)
	  (setq node-lst (cdr node-lst))))
    ; add a new label
    (if node
	(setf (dfgnode-label node) (nconc1 (dfgnode-label node) (list key val))))
    node))

(defun get-dataflow-graph-distr (fno edge-count rank)
  "Extract a dataflow graph (DFG) from a distributed OSQL function."
  (let* ((sb (getselectbody fno))
	 (dtree (selectbody-decomptree sb))
	 (dfg-nodes (list (make-dfgnode :id _amosid_ :rank rank :type 'amos
					:label (list (list 'node-name _amosid_)))))
	 (newln ";")
	 dfg-edges)
    (map-dtree
     dtree
     NIL
     (f/l (tn)
	  (let* ((sae-node (tnode-sae tn))
		 (ppl (tnode-ppl tn)))			
	    (if sae-node
		(let (preds rmt-db rmt-fno rmt-dfg in-vars out-vars)
		   (1++ edge-count)
		   (setq rmt-db (gnode-db sae-node))
		   (setq rmt-fno (gnode-fno sae-node))
		   (setq preds (mapcar (f/l (p) (if (oid-p (car p))
						    (cons (oid-name (car p) (cdr p)))
						    p))
				       (gnode-predl sae-node)))
		   (setq in-vars (append (gnode-params sae-node)
					 (filter_bnd (gnode-vars sae-node)
						     (gnode-bpat sae-node) '-)))
		   (setq out-vars (filter_bnd (gnode-vars sae-node)
					      (gnode-bpat sae-node) '+))
		   ; add an outgoing edge from this DB to the remote DB
		   (setq dfg-edges
			 (nconc1 dfg-edges
				 (make-dfgedge :src _amosid_ :dst rmt-db
					       :label (list (list 'edge-count edge-count)
							    (list 'in-vars (concatl in-vars newln #'mkstring))
							    (list 'preds (concatl preds newln #'mkstring))))))
		   ; remote-recursive call to retrieve the rest of the graph
		   (setq rmt-dfg
			 (remote-eval (list 'get-dataflow-graph-distr rmt-fno edge-count (1+ rank))
				      rmt-db))
		   (nconc dfg-nodes (dfg-nodes rmt-dfg))
		   (setq edge-count (1+ (dfg-edge-count rmt-dfg)))
		   ; add an incoming edge from the remote DB to this one
		   (setq dfg-edges
			 (nconc1 dfg-edges
				 (make-dfgedge :src rmt-db :dst _amosid_
					       :label (list (list 'edge-count edge-count)
							    (list 'out-vars (concat out-vars newln #'mkstring))))))
		   ; if the remote fn was iself MDB
		   (cond ((dfg-edges rmt-dfg) ; more nodes&edges were added
			  (nconc dfg-edges (dfg-edges rmt-dfg))))))
	    ; Add PPL nodes if any. Because they are POST-processing nodes, data flows to them AFTER
	    ; it came from eventual external sources.
	    (mapc
	     (f/l (node)
		  (let ((db (gnode-db node)))
		    (cond ((eq (sourcetype? db) 'odbc)
			   ; concat the AMOS name with the ODBC source name to make a globally
			   ; unique name for the source as the same logical name may exist in
			   ; more than one mediators.
			   (let ((node-id (mksymbol (concat _amosid_ "_" db))))
			     (nconc1 dfg-nodes
				     (make-dfgnode :id node-id
						   :rank (1+ rank)
						   :type 'odbc
						   :label (list (list 'node-name db))))
			     (1++ edge-count)
			     (setq dfg-edges
				   (nconc1 dfg-edges
					   (make-dfgedge :src _amosid_ :dst node-id
							 :label (list (list 'edge-count edge-count)))))
			     (1++ edge-count)
			     (setq dfg-edges
				   (nconc1 dfg-edges
					   (make-dfgedge :src node-id :dst _amosid_
							 :label (list (list 'edge-count edge-count)))))))
			  ((eq db 'LOCAL)
			   (1++ edge-count)
			   (setq dfg-edges
				 (nconc1 dfg-edges
					 (make-dfgedge :src _amosid_ :dst _amosid_
						       :label (list (list 'edge-count edge-count))))))
			  (t
			   (amos-error "Don't know how to hanlde this PPL node: " db))
			  )))
	     ppl)
	    )))
    (make-dfg
     :newln newln
     :name (oid-name fno)
     :edge-count edge-count
     :nodes dfg-nodes
     :edges dfg-edges)
    ))

(defun remove-duplicate-nodes (node-lst)
  "Remove nodes with the same ID by keeping the node with maximal rank."
  (let (ranked-nodes node-lst-rest cur-max)
    (while node-lst
      (setq cur-max (car node-lst))
      (dolist (node (cdr node-lst))
	(if (equal (dfgnode-id node) (dfgnode-id cur-max))
	    (if (> (dfgnode-rank node) (dfgnode-rank cur-max))
		(setq cur-max node))
	    (setq node-lst-rest (nconc1 node-lst-rest node))))
      (setq ranked-nodes (nconc1 ranked-nodes cur-max))
      (setq node-lst node-lst-rest)
      (setq node-lst-rest NIL))
    ranked-nodes))

(defun group-nodes-by-rank (node-lst)
  "Group nodes with the same rank into one list. Return list-of-lists:
   ((rank node1 node2 ...) ...)"
  (let (grouped-nodes node-lst-rest cur-group cur-node cur-rank)
    (while node-lst
      (setq cur-node (car node-lst))
      (setq cur-rank (dfgnode-rank cur-node))
      (setq cur-group (list cur-rank cur-node))
      (dolist (node (cdr node-lst))
	(if (= cur-rank (dfgnode-rank node))
	    (nconc1 cur-group node)
	    (setq node-lst-rest (nconc1 node-lst-rest node))))
      (setq grouped-nodes (nconc1 grouped-nodes cur-group))
      (setq node-lst node-lst-rest)
      (setq node-lst-rest NIL))
    (sort grouped-nodes (f/l (rl1 rl2) (< (first rl1) (first rl2))))
    (mapcar #'cdr grouped-nodes)))

(defun get-dataflow-graph (fno)
  (let ((dfg (get-dataflow-graph-distr fno 0 0)))
    (setf (dfg-nodes dfg) (remove-duplicate-nodes (dfg-nodes dfg)))
    dfg))

(defun print-visible-labels (str label-lst labels newln)
  (mapc (f/l (l)
	     (let ((label-name (first l))
		   (label-text (second l)))
	       (if (memq label-name labels)
		   (formatl str (string-replace label-text `((, newln "\\n"))) "\\n"))))
	label-lst))

(defun dot-gen-graph (graph visible-labels)
  "Generate a graph in DOT format as a string from an internal representation 
   in the form of a 'dfg' structure."
  (let* ((str (opentextstream))
	 (graphname (dfg-name graph))
	 (newln (dfg-newln graph))
	 (ranked-subgraphs (group-nodes-by-rank (dfg-nodes graph))))
    ; header
    (formatl str "digraph " (concat "\"" graphname "\"")  " { " t)
    (formatl str
	     ;"page = \"11.69,8.27\"" t
	     "rotate = 90" t
	     "size = \"10.5,7.2\"" t
	     ;"ratio = compress" t
	     "center = true" t
	     "nodesep = 0.5" t
	     "ranksep = 0.75" t
	     "ordering = out;" t
	     "graph [ fontname = \"Arial\", fontsize = 12, label = \"\\n\\n" graphname "\" ];" t
	     "node [ fontname = \"Arial\", fontsize = 10 ];" t
	     "edge [ fontname = \"Arial\", fontsize = 8 ];" t
	     "mclimit = 10" t
	     "nslimit = 10" t
	     t)
    ; add sub-graphs with ranked nodes
    (mapc (f/l (nodelst)
	       (formatl str "{ rank = same; " t)
	       (mapc (f/l (node)
			  (let ((shape (case (dfgnode-type node) ('amos "ellipse") ('odbc "box"))))
			    (formatl str (dfgnode-id node))
			    (formatl str " [label=\"")
			    (print-visible-labels str (dfgnode-label node) visible-labels newln)
			    (formatl str "\",")
			    (formatl str "shape=" shape "]" t)
			  ))
		     nodelst)
	       (formatl str "}" t))
	  ranked-subgraphs)
    (formatl str t)

    ; add edges to the graph
    (mapc (f/l (e)
	       (formatl str (dfgedge-src e) " -> " (dfgedge-dst e))
	       (formatl str " [label=\"")
	       (print-visible-labels str (dfgedge-label e) visible-labels newln)
	       (formatl str "\"];" t))
	  (dfg-edges graph))

    ; close the graph description
    (formatl str "}")
    (textstreamstring str)))

(defun dot-print-graph (dot-graph file-name out-dir file-type)
  "Save the graph into a file and generate the graphic file for that graph."
  (let* ((amos-temp-dir (concat _AMOS_STARTUP_DIR_ "/../tmp"))
	 (dot-in-file-name (concat amos-temp-dir "/" file-name ".dot"))
	 (dot-in-file (openstream dot-in-file-name "w"))
	 (dot-out-file-name (concat (if out-dir out-dir amos-temp-dir)
				    "/" file-name "." file-type))
	 dot-result)
    ; write the graph to a DOT file
    (formatl dot-in-file dot-graph)
    (closestream dot-in-file)
    ; call DOT with the graph file to generate the visual graph
    (setq dot-result
	  (system (concat "dot.exe -Tps -o " dot-out-file-name " " dot-in-file-name)))))

(defun add-exec-profile-info (dfg ep)
  "Add info extracted from the execution profile 'ep' as labels to 
   either 'dfg's nodes or edges. Destructive."
  (let ((node-stat (getfunction 'node_stat (list ep)))
	(net-stat (getfunction 'network_stat (list ep)))
	(odbc-node-stat (getfunction 'odbc_node_stat (list ep)))
	(odbc-call-stat (getfunction 'odbc_call_stat (list ep))))
    (mapc (f/l (node-stat)
	       (add-node-label dfg (first node-stat) 'node-stat
			       (concat (second node-stat) " s.")))
	  node-stat)
    (mapc (f/l (net-stat)
	       (add-edge-label dfg (first net-stat) (second net-stat) 'network-stat
			       (concat (third net-stat) " s. / " (fourth net-stat))))
	  net-stat)
    ; ODBC statistics
    ; TODO: this is a hack! Currently logical ODBC source names are not stored
    ; in the profile info. It is assumed that there is no more than one ODBC source
    ; per wrapper.
    (mapc (f/l (o-node-stat)
	       (let ((wrapper (first o-node-stat))
		     odbc-src)
		 (setq odbc-src
		       (caar (remote-eval '(osql "select name(s) from odbc_ds s;") wrapper)))
		 (add-node-label dfg (concat wrapper "_" odbc-src)
				 'odbc-node-stat
				 (concat (second o-node-stat) " s."))))
	  odbc-node-stat)
    (mapc (f/l (o-call-stat)
	       (let ((wrapper (first o-call-stat))
		     odbc-src)
		 (setq odbc-src
		       (concat wrapper "_"
			       (caar (remote-eval '(osql "select name(s) from odbc_ds s;")
						  wrapper))))
		 (add-edge-label dfg wrapper odbc-src
				 'odbc-call-stat (second o-call-stat))
		 (add-edge-label dfg odbc-src wrapper
				 'odbc-call-stat (third o-call-stat))))
	  odbc-call-stat)))

(defun print-osqlfn-dfg (osql-fno dfg file-prefix out-dir visible-labels)
  "Create a PS file with the DFG of the OSQL function 'osql-fno'."
  (let* (labels-lst file-name dot-graph dot-result)
    (setq file-name (concat file-prefix
			    (string-replace (oid-name osql-fno) '(("." "_") ("-" "_") (">" "_")))))
    (setq labels-lst (unique (append '(edge-count node-name) ; defaults
				     (mapcar #'mksymbol (arraytolist visible-labels)))))
    (setq dot-graph (dot-gen-graph dfg labels-lst))
    (setq dot-result (dot-print-graph dot-graph file-name out-dir "ps"))
    (if (neq dot-result 0)
        (amos-error "Unable to generate DFG graph for " osql-fno ". Reason: " dot-result)
        (concat out-dir "/" file-name ".ps"))))

(defun dfg-osqlfno----+ (fno osql-fno file-prefix out-dir visible-labels)
  (let ((dfg (get-dataflow-graph osql-fno))
	print-res)
    (setq print-res
	  (print-osqlfn-dfg osql-fno dfg file-prefix out-dir visible-labels))
    (osql-result osql-fno file-prefix out-dir visible-labels print-res)))

(defun dfg-compprf----+ (fno exec-prf file-prefix out-dir visible-labels)
  (if (not (equal (get-func 'name exec-prf) "comp"))
      (amos-error "This is not an execution profile of AMOSQL compilation: " exec-prf))
  (let* ((osql-fno (get-func 'exec_result exec-prf))
	 (dfg (get-dataflow-graph osql-fno))
	 print-res)
    (setq print-res
	  (print-osqlfn-dfg osql-fno dfg file-prefix out-dir visible-labels))
    (osql-result exec-prf file-prefix out-dir visible-labels print-res)))

(defun dfg-execprf-----+ (fno osql-fno exec-prf file-prefix out-dir visible-labels)
  "Generate a DFG for the OSQL function 'osql-fno' in a PS file tagged with exec.
   profile information from the query execution stage"
  (if (not (equal (get-func 'name exec-prf) "exec"))
      (amos-error "This is not an execution profile of AMOSQL execution: " exec-prf))
  (let ((dfg (get-dataflow-graph osql-fno))
	print-res)
    (add-exec-profile-info dfg exec-prf)
    (setq print-res
	  (print-osqlfn-dfg osql-fno dfg file-prefix out-dir visible-labels))
    (osql-result osql-fno exec-prf file-prefix out-dir visible-labels print-res)))

(osql "
create function dfg(function fno, charstring prefix, charstring out_dir, vector visible_labels)
       -> charstring
as foreign 'dfg-osqlfno----+';

create function dfg(execution_prf ep, charstring prefix, charstring out_dir, vector visible_labels)
       -> charstring
as foreign 'dfg-compprf----+';

create function dfg(function fno, execution_prf ep, charstring prefix,
                    charstring out_dir, vector visible_labels)
       -> charstring
as foreign 'dfg-execprf-----+';

create function dfg(function fno, charstring out_dir) -> charstring
as select dfg(fno, '', out_dir, {});
")
)

*EOF*
dfg(#[OID 1259], 'test-', 'e:/tmp',
    {'edge-count', 'node-name', 'node-stat', 'network-stat', 'odbc-node-stat', 'odbc-call-stat'});