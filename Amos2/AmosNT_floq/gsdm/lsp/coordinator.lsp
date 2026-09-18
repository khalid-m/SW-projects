;;; ===========================================================================
;;; AMOS2 - GSDM project
;;; 
;;; Author: (c) 2004 Milena Koparanova, UDBL
;;; $RCSfile: coordinator.lsp,v $
;;; $Revision: 1.20 $ $Date: 2005/12/12 10:52:43 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Functionality of GSDM coordinator
;;;              Generator of query and working nodes ids
;;;              Query levels in the dataflow graph
;;; ===========================================================================

(defun result-str-namesfn (fno q vn)
(let (qs fncall fnname fnargs fr
	 res_str_def snames vn)
  (setq qs (caar (getfunction 'query_string (list q))))
  (setq fncall (cadr (parse qs)))
  (setq fnname (caar fncall))
  (setq fnargs (cdar fncall))
  (setq fr (GET-MOST-SPECIFIC-RESOLVENT fnname (mapcar 'arg-type fnargs)))
  ;;result stream definition
  (setq res_str_def (cadr (getobject fr 'orgcode)))

  (setq snames (mapcar 'cadr res_str_def))
  ;; vector of datafield names
  (setq vn (listtoarray (mapcar 'mkstring snames)))
  (osql-result q vn)))


(defun result-str-typesfn (fno q vt)
(let (qs fncall fr vt)
  (setq qs (caar (getfunction 'query_string (list q))))
  (setq fncall (caadr (parse qs)))
  (setq fr (get-most-specific-resolvent (car fncall) 
					 (mapcar 'arg-type (cdr fncall))))
 
  ;; vector of type names
  (setq vt (listtoarray (mapcar (f/l (x) (caar (getfunction 'name (list x))))
		     (getobject fr 'restypes))))
  (osql-result q vt)))

;; Deterrmine levels of nodes in a graph

(defun mymax (l)
"Maximum element among list of elements"
  (cond ((null l) nil)
	((eq 1 (length l)) (car l))
	(t (let ((m (car l)))
	     (dolist (el (cdr l))
	       (setq m (max m el))
	       )
	     m))
))


(defun my-get-node-level (n s)
"Recursive function to determine a node level. 
n has form of list (node inputnode1 ...)"

(cond ((null (cdr n)) 0)
      ((integerp (cdr n)) (cdr n)) ;; level is formed
      (t (1+ (mymax 
		    (mapcar (f/l (nid)
;				 (my-get-node-level (assoc nid s)))
				 (my-get-node-level (assoc nid s) s))
			    (cdr n)))))
))

(defun graph-node-levels (arcs)
"Graph definition as list of arcs: node pairs. Determine node levels, 
where node without input arc has level 0 and node with input arcs has 
level 1+ maximum level of its input nodes. Result is associative list
with elements (node . level)"
(let (s n2 inpl)
  ;; create associative list s of all nodes
  (dolist (arc arcs)
    (setq s (putassoc (car arc) nil s))
    (setq s (putassoc (cdr arc) nil s))
    )
  ;; form list of input nodes associated with the node
  (dolist (arc arcs)
    (setq n2 (assoc (cdr arc) s))
    (setq inpl (append (cdr n2) (list (car arc))))
    (setq s (putassoc (cdr arc) inpl s))
    )
  ;; calculate node levels
  (dolist (n s)
    (if (listp (cdr n))
	(setq s (putassoc (car n) (my-get-node-level n s) s)))
    )
  s))


;; Determine the levels of queries - nodes in the dataflow graph
(defun node-levels (d)
"d is the dataflow object"
  (let ((nodelist (mapcar 'car (getfunction 'nodes (list d))))
    ;; list of operators
	arcs qlevlist)
    ;; form list of arcs in the graph -> function consumers(query)-> query
    (dolist (nd nodelist)
      (setq arcs (append2 arcs
	  (mapcar (f/l (c) (if (eq (arg-type c) (gettypenamed 'NODE))
			       (cons c nd)))
		  (arraytolist (caar (getfunction 'inputs (list nd))))))))
    (setq arcs (remove nil arcs))
    (if arcs
	(setq qlevlist (graph-node-levels arcs)) ;;((qobj . lev)...)
        (setq qlevlist (list (cons (car nodelist) 0)))
	) 
    ;; set function level on all queries
    (dolist (qlev qlevlist)
      (setfunction 'level (list (car qlev)) (list (cdr qlev))))
))

(foreign-lispfn levels ((dataflow d)) ()
 (node-levels d))


(foreign-lispfn start_workingnode_ssh_org ((charstring nodename)
				       (charstring mappedname)) ()
	   (system (concat "start ssh " nodename 
		   " -l milena bash startgsdm " mappedname))
(foreign-result))

(foreign-lispfn start_workingnode_ssh ((charstring nodename)
				       (charstring mappedname)) ()
	   (system (concat "start ssh " nodename 
		   " -l " (caar (getfunction 'username nil))
		   " bash startgsdm " mappedname))
(foreign-result))

;; ../bin/amos2 gsdm.dmp -c "$1"@"$NAMESERVER_HOST" -o "listen_gsdm();"


(foreign-lispfn start_statsrv_ssh () ()
	(system (concat "start ssh " (getenv "NAMESERVER_HOST") 
		   " -l milena bash startstatsrv"))
(foreign-result))

(defmacro to-atom (fnname arg)
`(mkatom (caar (getfunction (quote , fnname) (list , arg)))))

;; OBS! In order coordinator to be able to derive the operator result type, 
; all function definitions must be known for it

(defun derive-amosqlop-result-type (op)
"Derive the type of the result stream of amosql operator op. Return atom - typename"
  (let ((fnname (to-atom fn op)) istr argtypes
	fnres restpnm outstr argtypes1)

    ;; get list of mstream objects -input streams
    
    (setq istr (arraytolist (caar (getfunction 'input_streams (list op)))))

    (setq argtypes 
	  (if (eq (length istr) 1)
	      (mapcar (f/l (s) 
		(gettypenamed (mkatom (caar (getfunction 'stype (list s))))))
			   istr)
	    (gettypenamed 'VECTOR)))


    (setq argtypes1 (mapcar 'arg-type
		    (arraytolist (caar (getfunction 'params (list op))))))
   

    (setq fnres (get-most-specific-resolvent fnname 
					     (append2 argtypes argtypes1)))

    (setq restpnm (getobject (car (getobject fnres 'restypes)) 'name))
;; From stream window type to stream type
    (setq outstr (packlist 
		  (reverse (nthcdr 6 (reverse (explode restpnm))))))

   outstr
))

(defun derive-amosqlop-result-typefn (fno op restype)
  (osql-result op (mkstring (derive-amosqlop-result-type op))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Communication to working nodes

(defun wnodes (d)
"Return list of site names on which a dataflow is installed"
(mapcar (f/l (lg) (caar (getfunction 'id lg)))
	     (getfunction 'sites (list d))))


(foreign-lispfn cq_servers_on ((dataflow d)) ()
(let ()
	(global-eval (list 'cq-server-on) (wnodes d))
;;	(global-eval 
;;	 (list 'profile-functions  'binary-to-complex)
;;	 (wnodes d))
	
(foreign-result))
)

(foreign-lispfn set_global_max_cnt ((dataflow d) (integer n)) ()
		(tcp-encoding-on)
	(global-eval (list 'set-max-cnt  n) (wnodes d))
(foreign-result)
)

;;; set scheduler period of the first node
(foreign-lispfn set_turn_around ((charstring gsdmname)(real r)) ()
	(remote-eval (list 'set-turn-around r) gsdmname )
(foreign-result)
)

(foreign-lispfn set_rep ((charstring gsdmname)(integer r)) ()
	(remote-eval (list 'set-rep r) gsdmname )
(foreign-result)
)

(foreign-lispfn set_stop ((charstring qid)(charstring kind)
			  (number val) (charstring gsdmname)) ()
(let (msg)			  
  (setq msg `(set-stop-condition  (quote , (mkatom qid))
				  (quote , (mkatom kind))
				  , val))
  (remote-eval msg gsdmname)
  (foreign-result)
))

(foreign-lispfn stop ((charstring qid) (charstring gsdmname)) ()
(let(msg)			  
  (setq msg `(set-stop-condition  (quote , (mkatom qid))
				  (quote UNC) 0))
				  
  (send-message msg gsdmname)
  (foreign-result)
))

(foreign-lispfn prof_fast ((dataflow d)) ()
		(global-eval 
 		 (list 'profile-functions 'encode-to-binary 'decode-from-binary 'printto 'flush 'readfrom) 
(wnodes d))
)
(foreign-lispfn prof ((dataflow d)) ()
		(global-eval 
		 (list 'profile-functions 'encode-testsignal 'decode-testsignal 'printto 'flush 'readfrom) 
(wnodes d))
)

(foreign-lispfn get_prof ((dataflow d)) ()
(global-eval (list 'trace-sockets) (wnodes d))
(global-eval (list 'print-function-profiles) (wnodes d))
)

;; settings at the end of instalation before activation
(foreign-lispfn set_globals ((dataflow d)(integer im)) ()
   (let ((wnlist (wnodes d)))
	   
     (global-eval (list 'tcp-encoding-on) wnlist)
     (global-eval (list 'prepare-check-descr) wnlist)
     (global-eval (list 'init-stat-period0) wnlist)
     (global-eval (list 'osql (concat "image_size(" im ");" )) wnlist)
     (global-eval (list 'osql 
			(concat "set_scenario('" 
				(caar (getfunction 'id (list d))) "');" )) wnlist)
     
     (foreign-result))
)

(foreign-lispfn report_to_statsrv ((dataflow d)) ()
	(global-eval (list 'report-period-stat) (wnodes d))
(foreign-result)
)


(defun wait-for-listening ()
  (let ((res))
    (setq res 
	  (remote-eval (list 'osql "all_listening();") 'statsrv))
    (while (eq (caar res) 0) 
      (sleep 1)
      (setq res 
	    (remote-eval (list 'osql "all_listening();") 'statsrv))
      )
))

(foreign-lispfn wait_for_listening () ()
	(wait-for-listening)
	(foreign-result))

(defun wait-for-listening-d (dfname)
  (let ((res))
    (setq res 
	  (remote-eval (list 'osql (concat "all_listening('" dfname "');"))
		       'statsrv))
    (while (eq (caar res) 0) 
      (sleep 1)
      (setq res 
	    (remote-eval (list 'osql (concat "all_listening('" dfname "');"))
			 'statsrv))
      )
))

(foreign-lispfn wait_for_listening ((dataflow d)) ()
	(wait-for-listening-d (caar (getfunction 'id (list d))))
	(foreign-result))


(defun wait-for-completion ()
  (let ((res))
    (setq res 
	  (remote-eval (list 'osql "all_completed();") 'statsrv))
    (while (eq (caar res) 0) 
      (sleep 1)
      (setq res 
	    (remote-eval (list 'osql "all_completed();") 'statsrv))
      )
))

(foreign-lispfn wait_for_completion () ()
	(wait-for-completion)
	(foreign-result))

(defun wait-for-completion-d (dfname)
  (let (res (cmd (concat "all_completed('"  dfname  "');")))
    (setq res 
	  (remote-eval (list 'osql cmd) 'statsrv))
    (while (eq (caar res) 0) 
      (sleep 1)
      (setq res 
	    (remote-eval (list 'osql cmd)   'statsrv))
      )
))

(foreign-lispfn wait_for_completion ((dataflow d)) ()
	(wait-for-completion-d (caar (getfunction 'id (list d))))
	(foreign-result))


(defun call_amos++ (fnname argvect)
(caar (getfunction fnname (arraytolist argvect)))
)

(foreign-lispfn call_amos ((charstring fnname)(vector args)) ((dataflow d))
(foreign-result (call_amos++ (mkatom fnname) args))
)

(defun activate-dataflow (d)
"Activation of a dataflow in decreasing order of operator levels"
  (let* ((oplist (mapcar 'car (getfunction 'nodes (list d))))
    ;; list of operators
	(opl (mapcar (f/l (op) (cons op
			   (caar (getfunction 'level (list op)))))
			  oplist))
	(suc 1) act curlev opl1)
  
    (setq curlev (mymax  (mapcar 'cdr opl)))

    (while (and (eq suc 1) (>= curlev 0))
      (dolist (q opl)   ; (#[OID] . 1)
	(if (and (eq suc 1)(eq (cdr q) curlev))
	    (setq suc (caar (getfunction 'activate_operator (list (car q))))))
	(if (eq suc 1) 
	    (setq act (append2 act (list q)))
	  (let ()
	    ;; deactivate back
	    (dolist (p act)
	      )
	    ))
	)
      (setq curlev (- curlev 1))
      )
    suc
))

(foreign-lispfn activate_dataflow ((dataflow d)) ((integer i))
 (foreign-result  (activate-dataflow d)))
