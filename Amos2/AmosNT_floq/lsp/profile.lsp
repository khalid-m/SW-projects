;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2000 Timour Katchaounov, UDBL
;;; $RCSfile: profile.lsp,v $
;;; $Revision: 1.7 $ $Date: 2012/05/18 14:34:47 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Database-driven distributed profiling.
;;;              
;;; ===========================================================================

(foreign-lispfn init_profiler () ()
  (init-profiler)
  (foreign-result))

(foreign-lispfn init_profiler_reports () ()
  (init-profiler-reports)
  (foreign-result))

(defun init-profiler ()
  "Create all LISP and OSQL functions and types needed for distributed profiling."
; avoid re-initialization
(if (not (global-variable-p '_time-serving_))
(progn

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Network profiling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; The form of these variables is chosen for fast update.
; stores the accumulated history of serviced requests as
(defglobal _time-serving_ nil) ; form: ((dbname . time) ...)

; stores the accumulated history of the requests sent to servers in a list
(defglobal _time-requesting_ nil) ; form: ((dbname count . time) ...)

; stores the accumulated number of the number of bytes sent and received
; form: ((dbname bytes-sent packets-sent bytes-received packets-received) ...)
(defglobal _socket_stat_ nil)

; the overhead of wrapping remote calls, in bytes
(defglobal _socket_stat_overhead_ 0)


(defmacro time-serving (db form)
  "Execute form, store the time it took and return the result.
   On a 600 MHz PIII it introduces overhead of 1.5512e-05 sec. per call."
  `(let* ((start nil)
		  (end nil)
		  (res nil)
		  (info (assq , db _time-serving_)))
     (setq start (clock))
     (setq res , form)
     (setq end (clock))
	 (if info
		 (rplacd info (+ (cdr info) (- end start)))
	     (setq _time-serving_ (cons (cons , db (- end start)) _time-serving_)))
     res))

(defun replace-fn (fn-src fn-dest)
  "Replace the definition of the function fn-dest with the definition  of fn-src.
   Store the original definition of fn-dest under the property virginfn.
   Much simpler than wrap-put above."
  (let ((fn-def (getd fn-dest)))
    (putprop fn-dest 'virginfn fn-def)
    (movd fn-src fn-dest)))

(defun restore-fn (fn)
  (let ((ub (getprop fn 'virginfn)))
    (cond (ub (remprop fn 'virginfn)
	      (defc fn ub)
	      fn)
	  (t (list fn "not wrapped")))))

(defun update-socket-stat (peer socket)
  (let* ((stat (socketstat socket))
	 (profile_data (assoc peer _socket_stat_))
	 (total_bytes_out   (second profile_data))
	 (total_packets_out (third profile_data))
	 (total_bytes_in    (fourth profile_data))
	 (total_packets_in  (fifth profile_data))
	 (bytes_out (first stat))
	 (packets_out (second stat))
	 (bytes_in (third stat))
	 (packets_in (fourth stat))
	 new_profle_data)

    (setq new_profile_data (list (+ bytes_out (or total_bytes_out 0))
				 (+ packets_out (or total_packets_out 0))
				 (+ bytes_in (or total_bytes_in 0))
				 (+ packets_in (or total_packets_in 0))))
    (if profile_data
	(rplacd profile_data new_profile_data)
        (setq _socket_stat_ (cons (cons peer new_profile_data) _socket_stat_)))
    _socket_stat_))

(defun print&read-prf (form dbid socket portname)
  "Profiled version of 'print&read'.
   Stores the number of remote calls made and the total time spent waiting for each
   server to complete all requests from this client."
  (if (null portname)
      (error "print&read-prf: null port name"))
  (socketstat-clear socket) ; clear the socket statistics so far
  (let* (result net-time new_profile_data
	 (profile_data (assoc portname _time-requesting_))
	 (total-time (cddr profile_data))
	 (total-count (cadr profile_data))
	 start end)

    (setq start (clock))
    ; the original print&read code
    (printto `(time-serving , (kwote _amosid_) , form) socket dbid)
    (setq result (readfrom socket dbid))
    (setq end (clock))

    (setq net-time (roundto (- end start) _clock_resolution_))
    (setq new_profile_data (cons (+ 1 (or total-count 0)) 
				 (+ net-time (or total-time 0))))
    (update-socket-stat portname socket)
    (if profile_data
	(rplacd profile_data new_profile_data)
        (setq _time-requesting_ (cons (cons portname new_profile_data) _time-requesting_)))
    result))

(defun profile-network (&optional reset)
  (if (null _amosid_)
      (amos-error "No way to profile the network communication of unnamed AMOS.")
      (if (not (network-profiled?))
	       (replace-fn #'print&read-prf #'print&read))
      (if reset
	  (clear-network-profile))))

(defun unprofile-network ()
  (restore-fn #'print&read))

(defun clear-network-profile ()
  "Reset the global variables storing profile info."
  (setq _time-serving_ nil)
  (setq _time-requesting_ nil)
  (setq _socket_stat_ nil)
  (list _time-serving_ _time-requesting_ _socket_stat_))

(defun network-profiled? ()
  (if (getprop #'print&read 'virginfn)
      T))

(defmacro with-unprofiled-network (&rest forms)
  "Execute forms with the network being temporarily unprofiled,
   and restore network profiling to it's status before the call."
  `(let (result
	 (restore-profiling (network-profiled?)))
     ; we don't want to include profile collection itself in the statistics
     (unprofile-network)
     (setq result (progn ,@ forms))
     ; restore network profiling
     (if restore-profiling (profile-network))
     ; return this client profile
     result))

(defun get-network-profile ()
  "Collect profile information from all servers this client talked to, 
   and calculate real network time. Return a list of the form:
   ((server time calls bytes_out packets_out bytes_in packets_in) ...)"
  (with-unprofiled-network
   (let* ((served-times	; get the time that each server spent serving us
	   (mapcar (f/l (info)
			(remote-eval (list 'assq (kwote _amosid_) '_time-serving_) 
				     (car info)))
		   _time-requesting_)))

     (assert (= (length served-times) (length _time-requesting_))
	     "server and client statistics don't match")

     ; calculate the real time spent in network
     (mapcar (f/l (client server)
		  (let* ((db (car client))
			 (time (roundto (- (cdr (last client)) (cdr server)) _clock_resolution_))
			 (calls (second client))
			 (sock_stat (cdr (assoc (mkatom db) _socket_stat_))))
		    (assert (and db time calls sock_stat) "NIL element in network profile")
		    (append (list db time calls) sock_stat)))
	     _time-requesting_ served-times))))

(defun get-server-profile ()
  "Return time serving to clients in the form: ((client time) ...)"
  (mapcar (f/l (pair) (list (car pair) (cdr pair)))
	  _time-serving_))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Distributed profiling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun setup-profiling (profile-settings)
  "Clear all old profiling settings and start profiling the functions 
   described in 'profile-settings' of the form: ((FN1 DB1 DB2 ...) ...)
   It means profile function FN1 in databases DB1,DB2, etc.
   If no databases are mentioned after FN, then FN will be profiled in 
   all databases.
   NOTE: In order to profile the network comm. use a special FN - 'network'
         It is not possible to profile both the network and print&read."
  ; clear all profiling
  (global-eval '(unprofile-network))
  (global-eval '(clear-network-profile))
  (global-eval '(unprofile-functions))
  ; set up the functions to be profiled in each database
  (let (has_p&r (prf-net 'no))
    (mapcar (f/l (fnconfig)
		 (if (or (null fnconfig) (not (listp fnconfig)))
		     (error "Wrong entry in profile-settings:" fnconfig))
		 (let* ((fn (car fnconfig))
			(dblst (cdr fnconfig)))
		   (if (eq fn 'print&read)
		       (setq has_p&r T))
		   (if (and has_p&r (network-profiled?))
		       (error "This function can't be profiled together with the network" fnconfig)
		     (if (eq fn 'network) ; network profiling is a special case
			 (if has_p&r
			     (error "The network can't be profiled together with print&read" fnconfig)
			   (setq prf-net dblst))
		       (global-eval (list 'profile-functions fn) dblst)))))
	    profile-settings)
    ; if network profiling is to be done - set it last
    (if (neq prf-net 'no)
	(global-eval '(profile-network t) prf-net))
    ))

(defun set-globals (globals)
  "Set global variables as described in 'globals': ((varname value db1 db2 ...) ...) 
   This is done sequentially, so every entry will override the preceding one.
   If no DBs are given, then the variables will be set in all databases."
  (mapc (f/l (vv)
	     (let ((var (mkatom (first vv)))
		   (val (second vv))
		   (db  (cddr vv)))
	       (global-eval `(setq , var , val) db)))
	globals))

(defun collect-profiles ()
  (with-unprofiled-network
   (let ((network-profiles (mapfilter (f/l (x) (not (null (cadr x)))) ; remove NIL entries
				     (global-eval '(get-network-profile))))
	 (server-profiles (mapfilter (f/l (x) (not (null (cadr x)))) ; remove NIL entries
				     (global-eval '(get-server-profile))))
	 (func-profiles (mapfilter (f/l (x) (not (null (cadr x)))) ; remove NIL entries
				   (global-eval '(get-function-profiles)))))
     (list network-profiles server-profiles func-profiles))))

(defun exec-and-profile (exp-params globalvar-settings profile-settings executable-thing param-lst)
  "Execute and collect profiling information for 'executable-thing'.
   * 'exp-params' - describes the experimental setting (parameters and their values) 
     in a list: ((experiment-parameter param-value) ...)
   * 'profile-settings' is of the form: ((FN1 DBi ...) (FN2 DBj ...) ...)
     and it describes which functions are to be profiled in which database.
   * 'globalvar-settings' contains the values of a global variables in DBs.
   * 'executable-thing' can be one of these:
     - Lisp list => execute as LISP form
     - Lisp symbol => execute as LISP function with parameters 'param-lst'
     - string => execute as OSQL statement. Typically used to profile DDL statements.
     - OSQL function obj. => execute as OSQL function with parameters 'param-lst'
   * 'param-lst' - a list of parameters for the 'executable-thing'
   The result of the 'executable-thing' is stored only when it is not a list
   (i.e. it is assumed to be small), as normally it is not needed."
  (set-globals globalvar-settings)
  (setup-profiling profile-settings)
  (let* (start result time exec-profile)
    (setq start (clock))
    ; checking the kind of executable-thing is fast, so it does not matter 
    ; if we measure it as well
    (cond ((listp executable-thing)          ; execute as a LISP form
	    (setq result (eval executable-thing)))
	  ((symbolp executable-thing)        ; execute as a LISP function
	   (apply executable-thing param-lst))
	  ((stringp executable-thing)        ; execute as OSQL statement
	   (setq result (amos-execute executable-thing)))
	  ((oid-p executable-thing)          ; execute as OSQL function
	   (setq result (mapfunction executable-thing param-lst (f/l (x) ()))))
	  (t
	   (amos-error "Non-executable: " executable-thing)))
    (setq time (- (clock) start))
    (setq exec-profile (cons time (collect-profiles)))
    (if (listp result)
	(nconc1 exec-profile '(NIL))
        (nconc1 exec-profile (list result)))
    ; create a new 'execution_prf' object
    (create-execution-profile exec-profile exp-params)))

(defun exec-and-profile-osqlstmt------+ (fno name exp_param_vals sys_conf prf_conf generation osqlstmt)
  (mapfunction (getfunctionnamed 'SYSTEM_CONFIG.CONFIGURE->BOOLEAN) (list sys_conf))
  (setup-profiling (atomize-tuples (mapcar 'arraytolist (arraytolist prf_conf))))
  (let* (start result time exec_prf)
    (setq start (clock))
    (setq result (amos-execute osqlstmt))
    (setq time (- (clock) start))
    ; keep only single valued results
    (if (listp result)
	(setq result (caar result)))
    ; create a new 'execution_prf' object
    (setq exec_prf
	  (create-execution-profile (collect-profiles) exp_param_vals sys_conf time result generation name))
    (osql-result name exp_param_vals sys_conf prf_conf generation osqlstmt exec_prf)))

(defun exec-and-profile-osqlfno-------+ (fno name exp_param_vals sys_conf prf_conf generation osqlfno params)
  (mapfunction (getfunctionnamed 'SYSTEM_CONFIG.CONFIGURE->BOOLEAN) (list sys_conf))
  (setup-profiling (atomize-tuples (mapcar 'arraytolist (arraytolist prf_conf))))
  (let* ((param-lst (arraytolist params))
	 (osqlfno-resolvent (resolvename osqlfno param-lst nil))
	 (result 0)
	 start time exec_prf)
    (setq start (clock))
    (mapfunction osqlfno-resolvent param-lst (f/l (x) (1++ result)))
    (setq time (- (clock) start))
    ; create a new 'execution_prf' object
    (setq exec_prf
	  (create-execution-profile (collect-profiles) exp_param_vals sys_conf time result generation name))
    (osql-result name exp_param_vals sys_conf prf_conf generation osqlfno params exec_prf)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Profiler schema
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun set-global- (fno global_var_obj)
  "Given an object of type 'global_var' use it to set the global variable
   it represents in all relevant DBs."
  (let* ((var (get-func 'name global_var_obj))
	 (val (get-func 'value global_var_obj))
	 (exec (get-func 'evaluate global_var_obj))
	 (db  (get-func 'server_db global_var_obj)))
    (if (not (or (null var) (equal var "") (null val)))
	(if exec
	    (global-eval `(setq , (mkatom var) , (mkatom val)) db)
	    (global-eval `(setq , (mkatom var) , (kwote (mkatom val))) db)))))

(osql " /* AMOS global variable */

create type global_var properties (name charstring, value literal, evaluate boolean);

/* AMOS servers where this global is defined. NIL means everywhere */
create function server_db(global_var gv) -> bag of charstring;

create function global_var(charstring nm, literal val, boolean exec) -> global_var as
begin
  declare global_var gv;
  create global_var(name, value, evaluate) instances gv (nm, val, exec);
  return gv;
end;

create function global_var(charstring nm, literal val) -> global_var as
select global_var(nm, val, FALSE);

create function set_global(global_var gv) -> boolean as
foreign 'set-global-';
")

(osql " /* describes a named set of values for AMOS global varibles */

create type system_config properties (name charstring);

create function globals(system_config sc) -> bag of global_var;

create function system_config() -> system_config as
begin
  declare system_config sc;
  create system_config instances sc;
  return sc;
end;

create function system_config(charstring nm, charstring gnm, literal gval) -> system_config as
begin
  declare system_config sc,  global_var gv;
  set gv = global_var(gnm, gval);
  create system_config(name, globals) instances sc(nm, gv);
  return sc;
end;

create function system_config(charstring nm, vector gvar_vec) -> system_config as
begin
  declare system_config sc, vector var_val, global_var gv, integer maxidx,
          charstring var, literal val;
  create system_config(name) instances sc(nm);
  set maxidx = count(gvar_vec) - 1;
  for each integer i where i = iota(0, maxidx)
  begin
    set var_val = gvar_vec[i];
    set var = var_val[0];
    set val = var_val[1];
    set gv = global_var(var, val);
    add globals(sc) = gv;
  end;
  return sc;
end;

create function configure(system_config sc) -> boolean as
select set_global(globals(sc));
")

(osql "
/* Represents experimental configurations. Combined with one System Configuration 
   represents one experimental curve.
   Vectors of named parameter values are used instead of functions because 
   we need arbitrary number of parameters under type 'literal' which is hard 
   to model by inheritance/overloading. The names of the parameters are kept
   in the 'param_names' property of the containing 'experiment_family'. */

create type experiment_config properties (name charstring);

create function param_values(experiment_config ec nonkey) -> vector;

create function param_names(experiment_config ec) -> vector;

create function param_value(experiment_config ec, vector params, charstring param_name) -> object
as select param
   from object param, integer param_idx
   where param_name = param_names(ec)[param_idx] and
         param = params[param_idx];

create function experiment_config() -> experiment_config
as begin
  declare experiment_config ec;
  create experiment_config instances ec;
  return ec;
end;

create function experiment_config(charstring nm, vector pnm, bag valbag) -> experiment_config
as begin
  declare experiment_config ec;
  create experiment_config(name, param_names) instances ec(nm, pnm);
  add param_values(ec) = in(valbag);
  return ec;
end;
")

(osql " /* a set of experimental configurations with the same structure */

create type experiment_family properties (name charstring);

create function configurations(experiment_family ef) -> bag of experiment_config;

create function experiment_family(charstring nm, bag expconf) -> experiment_family as
begin
  declare experiment_family ef;
  create experiment_family(name) instances ef(nm);
  add configurations(ef) = in(expconf);
  return ef;
end;
")

(osql " /* Profiles */

/* base profile type */
create type profile properties(name charstring, exec_time real, generation integer);

/* network profiles - network statistics of the conversation between a client and a server */
create type network_prf under profile;
create function server_db(network_prf sp) -> charstring;
create function client_db(network_prf sp) -> charstring;
create function calls(network_prf sp) -> integer;
create function bytes_in(network_prf sp) -> integer;
create function packets_in(network_prf sp) -> integer;
create function bytes_out(network_prf sp) -> integer;
create function packets_out(network_prf sp) -> integer;

/* server profiles - how much a server served to each of its clients */
create type server_prf under profile;
create function server_db(server_prf sp) -> charstring;
create function client_db(server_prf sp) -> charstring;

/* function profiles */
create type function_prf under profile;
create function function_nm(function_prf fp) -> charstring;
create function host_db    (function_prf fp) -> charstring;
create function calls      (function_prf fp) -> integer;
create function time_per_call(function_prf fp) -> real;

/* execution profiles (store all profile information)
   Normally one instance of an exec. prof. describes one point in a graph */
create type execution_prf under profile;
create function experiment_params (execution_prf ep) -> vector;
create function system_config     (execution_prf ep) -> system_config;
create function exec_result       (execution_prf ep) -> object;
create function network_profiles  (execution_prf ep) -> bag of network_prf;
create function server_profiles   (execution_prf ep) -> bag of server_prf;
create function function_profiles (execution_prf ep) -> bag of function_prf;
")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OSQL interface to the profiling functions.
; These use the types created above, and must be after them.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(osql "
create function profile_osql(
         charstring name, vector exp_param_vals, system_config sc, vector prf_config,
         integer generation, charstring osqlstmt
       ) -> execution_prf as foreign 'exec-and-profile-osqlstmt------+';

create function profile_osql(
         charstring name, vector exp_param_vals, system_config sc, vector prf_config,
         integer generation, function osqlfn, vector params
       ) -> execution_prf as foreign 'exec-and-profile-osqlfno-------+';
")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Constructors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun create-network-profiles (prf-lst generation)
  "Take list of the form: ((client ((srv1 exec_time calls bi pi bo po) ...) ...)
   and create a new server_prf objects"
  (let (res-lst)
    (mapc (f/l (cprf)
	       (let ((client (mkstring (first cprf))))
		 (mapc (f/l (netp)
			    (let ((srv (mkstring (first netp)))
				  (exec_time   (second netp))
				  (calls  (third netp))
				  (bi     (fourth netp))
				  (pi     (fifth netp))
				  (bo     (sixth netp))
				  (po     (seventh netp))
				  (new-obj (createobject 'network_prf)))
			      (addfunction 'client_db   (list new-obj) (list client))
			      (addfunction 'server_db   (list new-obj) (list srv))
			      (addfunction 'exec_time   (list new-obj) (list exec_time))
			      (addfunction 'calls       (list new-obj) (list calls))
			      (addfunction 'bytes_in    (list new-obj) (list bi))
			      (addfunction 'packets_in  (list new-obj) (list pi))
			      (addfunction 'bytes_out   (list new-obj) (list bo))
			      (addfunction 'packets_out (list new-obj) (list po))
			      (addfunction 'generation  (list new-obj) (list generation))
			      (setq res-lst (cons new-obj res-lst))))
		       (second cprf))))
	  prf-lst)
    res-lst))

(defun create-server-profiles (prf-lst generation)
  "Take list of the form: ((srv ((cli1 exec_time) ...) ...)
   and create a new server_prf objects"
  (let (res-lst)
    (mapc (f/l (sprf)
	       (let ((srv (mkstring (first sprf))))
		 (mapc (f/l (clip)
			    (let ((client (mkstring (first clip)))
				  (exec_time   (second clip))
				  (new-obj (createobject 'server_prf)))
			      (addfunction 'server_db  (list new-obj) (list srv))
			      (addfunction 'client_db  (list new-obj) (list client))
			      (addfunction 'exec_time  (list new-obj) (list exec_time))
			      (addfunction 'generation (list new-obj) (list generation))
			      (setq res-lst (cons new-obj res-lst))))
		       (second sprf))))
	  prf-lst)
    res-lst))

(defun create-function-profiles (prf-lst generation)
  "Take list of the form: ((db ((fn exec_time calls tpc) ...) ...)
   and create a new server_prf objects"
  (let (res-lst)
    (mapc (f/l (dbprf)
	       (let ((host (mkstring (first dbprf))))
		 (mapc (f/l (fnp)
			    (let ((fn-nm (mkstring (first fnp)))
				  (exec_time   (second fnp))
				  (calls  (third fnp))
				  (time-pc (fourth fnp))
				  new-obj)
			      ; if the function was executed (and profiled) at all:
			      (cond ((not (or (= calls 0) (eq exec_time '-)))
				     (setq new-obj (createobject 'function_prf))
				     (addfunction 'function_nm   (list new-obj) (list fn-nm))
				     (addfunction 'host_db       (list new-obj) (list host))
				     (addfunction 'exec_time     (list new-obj) (list exec_time))
				     (addfunction 'calls         (list new-obj) (list calls))
				     (addfunction 'time_per_call (list new-obj) (list time-pc))
				     (addfunction 'generation    (list new-obj) (list generation))
				     (setq res-lst (cons new-obj res-lst))))))
		       (second dbprf))))
	  prf-lst)
    res-lst))

(defun add-bag-result (osqlfn ep-obj reslst)
  (let ((fno (getfunctionnamed osqlfn))
	(arglst (list ep-obj)))
    (dolist (res reslst)
      (addfunction fno arglst (list res)))))

(defun create-execution-profile (prf exp_param_vals sys_conf time result generation name)
  (let* ((ep-obj (createobject 'execution_prf))
	 (cli (first prf))
	 (srv (second prf))
	 (fun (third prf))
	 (ep-arg (list ep-obj)))
    (addfunction 'experiment_params ep-arg (list exp_param_vals))
    (addfunction 'system_config     ep-arg (list sys_conf))
    (addfunction 'exec_result       ep-arg (list result))
    (addfunction 'exec_time         ep-arg (list time))
    (addfunction 'generation        ep-arg (list generation))
    (if name
	(addfunction 'name          ep-arg (list name)))
    (add-bag-result 'network_profiles  ep-obj (create-network-profiles cli generation))
    (add-bag-result 'server_profiles   ep-obj (create-server-profiles srv generation))
    (add-bag-result 'function_profiles ep-obj (create-function-profiles fun generation))
    ep-obj))

)) ; end cond, progn
; end init-profiler
)

(defun init-profiler-reports ()
  "Profiler report generation."

(init-plot) ; Report generation depends on the plot module.

(osql "
create function prf2crv(
       charstring title, charstring prfnm, experiment_config ec, system_config sc,
       charstring xparam_name, integer min_gen, integer max_gen, charstring points_extract_fn)
       -> curve2d as
/* Create a 2D curve object from a set of execution profiles. */
begin
  declare curve2d c2d;
  set c2d = curve2d(title);
  for each vector point
  where point = call_function(points_extract_fn,
                              vector(prfnm, ec, sc, xparam_name, min_gen, max_gen))[0]
  begin
    add points(c2d) = point;
  end;
  return c2d;
end;

create function prf2crv(
       charstring title, charstring prfnm, vector ec, vector sc_desc_vec,
       integer min_gen, integer max_gen, charstring points_extract_fn)
       -> curve2d as
/* Create a 2D curve object from a set of execution profiles. */
begin
  declare curve2d c2d;
  set c2d = curve2d(title);
  for each vector point
  where point = call_function(points_extract_fn,
                              vector(prfnm, ec, sc_desc_vec, min_gen, max_gen))[0]
  begin
    add points(c2d) = point;
  end;
  return c2d;
end;

create function prf2crv(
       charstring title, charstring prfnm, vector ec, system_config sc,
       vector gen_desc, charstring points_extract_fn)
       -> curve2d as
/* Create a 2D curve object from a execution profiles for the same exp. point but varying generations */
begin
  declare curve2d c2d;
  set c2d = curve2d(title);
  for each vector point
  where point = call_function(points_extract_fn,
                              vector(prfnm, ec, sc, gen_desc))[0]
  begin
    add points(c2d) = point;
  end;
  return c2d;
end;

create function exec_profiles_named(charstring prfnm, integer min_gen, integer max_gen)
       -> execution_prf as
/* Get all profiles in a range of generarions */
  select ep
  from execution_prf ep
  where name(ep) = prfnm and
        generation(ep) >= min_gen and
        generation(ep) <= max_gen;

create function exec_profiles(charstring prfnm, vector exp_config, system_config sc, 
                              integer min_gen, integer max_gen)
       -> execution_prf as
/* Get all profiles from a range of generarions with the same experimental conditions 
   (i.e. same exp. point) */
  select ep
  from execution_prf ep
  where experiment_params(ep) = exp_config and
        system_config(ep) = sc and
        ep = exec_profiles_named(prfnm, min_gen, max_gen);

create function min_average_time(charstring prfnm, vector exp_config,
                                 integer min_gen, integer max_gen)
       -> real
/* Minimum time of all exec. times for all points with the same experimental config,
   averaged over a range of generations. */
as select
   minagg(
     select t
     from real t, bag of integer time_bag
     where time_bag = (select exec_time(ep)
                       from execution_prf ep, system_config sc
                       where ep = exec_profiles(prfnm, exp_config, sc, min_gen, max_gen))
           and
           t = average(time_bag)
   );

create function exp_points(charstring prfnm, experiment_config ec, system_config sc,
                           charstring  xparam_name, integer min_gen, integer max_gen)
       -> bag of vector
/* Retrieve the experimental points for a set of profiles from the same exepriment_config,
   and fixed system system configuration (i.e. same experimental curve), using one of the
   experimental parameters as the X-axis. The Y-axis contains the average execution time 
   for several experiment generations. Used in plot.osql. */
as select vector(xparam_value, exec_time)
   from number xparam_value, real exec_time, vector exp_config
   where exp_config = param_values(ec) and
         xparam_value = param_value(ec, exp_config, xparam_name) and
         exec_time = average(exec_time(exec_profiles(prfnm, exp_config, sc, min_gen, max_gen)));

create function exp_points_sum(charstring prf_pat, experiment_config ec, system_config sc,
                               charstring  xparam_name, integer min_gen, integer max_gen)
       -> bag of vector
/* Sum along the Y-axis all points of the exec. profiles with names in prf_names */
as select sum_points(bv)
   from bag of vector bv
   where bv = (select exp_points(prfnm, ec, sc, xparam_name, min_gen, max_gen)
               from charstring prfnm
               where prfnm = in((select distinct name(p) from execution_prf p)) and
                     like_i(prfnm, prf_pat));

create function exp_points_sc(charstring prfnm, vector ec, vector sc_desc_vec,
                              integer min_gen, integer max_gen)
       -> bag of vector
/* Retrieve the experimental points for a set of profiles from the same exepriment_config,
   and varying system system configurations. On the X-axis are different system configurations,
   on the Y-axis is the average execution time. Used in plot.osql. */
as select vector(xparam_value, exec_time)
   from number xparam_value, real exec_time, vector sc_desc, system_config sc, integer i
   where sc_desc = sc_desc_vec[i] and
         xparam_value = sc_desc[1] and
         sc = sc_desc[0] and
         exec_time = average(exec_time(exec_profiles(prfnm, ec, sc, min_gen, max_gen)));

create function exp_points_gen(charstring prfnm, vector ec, system_config sc,
                               vector gen_desc_vec)
       -> bag of vector
as select vector(xparam_value, exec_time)
   from number xparam_value, real exec_time, vector gen_desc, integer i, integer gen
   where gen_desc = gen_desc_vec[i] and
         gen = gen_desc[0] and
         xparam_value = gen_desc[1] and
         exec_time = exec_time(exec_profiles(prfnm, ec, sc, gen, gen));
")

; functions to classify all mediators into groups
(osql "
create function all_nodes(execution_prf ep) -> charstring
as select distinct db
   from charstring db, network_prf np
   where np = network_profiles(ep) and
         (db = client_db(np) or db = server_db(np));

create function nodes_like(execution_prf ep, charstring pat) -> charstring
as select distinct db
   from charstring db, network_prf np
   where np = network_profiles(ep) and
         db = all_nodes(ep) and
         like_i(db, pat);

create function all_servers(execution_prf ep) -> charstring
as select distinct db
   from charstring db, network_prf np
   where np = network_profiles(ep) and
         db = server_db(np);

create function all_clients(execution_prf ep) -> charstring
as select distinct db
   from charstring db, network_prf np
   where np = network_profiles(ep) and
         db = client_db(np);

create function all_client_servers(execution_prf ep) -> charstring
/* All servers that also acted as clients (the middle layer) */
as select distinct db
   from charstring db, network_prf np
   where np = network_profiles(ep) and
         db = all_clients(ep) and
         db = in(all_servers(ep));

create function all_pure_servers(execution_prf ep) -> charstring
/* All servers that did not act as clients */
as select distinct db
   from charstring db, network_prf np
   where np = network_profiles(ep) and
         db = server_db(np) and
         notany(select db1 from charstring db1 where db1 = all_clients(ep) and db = db1);

create function get_client(execution_prf ep) -> charstring
/* There always is one initiating client */
as select distinct db
   from charstring db, network_prf np
   where np = network_profiles(ep) and
         db = client_db(np) and
         notany(select db1 from charstring db1 where db1 = all_servers(ep) and db = db1);
")

; functions to extract time distribution
(osql "
create function servers_of(execution_prf ep, charstring client) -> bag of charstring
/* Return all servers accessed by a client */
as select server_db(np)
   from network_prf np, charstring client
   where np = network_profiles(ep) and
         client_db(np) = client;

create function time_between(execution_prf ep, charstring client, charstring server)
       -> bag of real
/* Return the total network time spent beween a client and a server */
as select exec_time(np)
   from network_prf np
   where np = network_profiles(ep) and
         client_db(np) = client and
         server_db(np) = server;

create function time_between_client_and_all_servers(execution_prf ep, charstring client)
       -> real
/* Total time spent on the network between a client and all its servers */
as select sum(
   time_between(ep, client, servers_of(ep, client))
   );

create function time_in_all_servers_of_client(execution_prf ep, charstring client)
       -> bag of real
/* Time all servers of a client spent serving requests from that client */
as select sum(
   select exec_time(sp)
   from server_prf sp
   where sp = server_profiles(ep) and
         client_db(sp) = client
   );

create function total_time_serving(execution_prf ep, charstring server)
       -> bag of real
/* Total time a server spent serving to all its clients */
as select sum(
   select exec_time(sp)
   from server_prf sp
   where sp = server_profiles(ep) and
         server_db(sp) = server
   );


create function time_in_odbc(execution_prf ep, charstring db) -> real as
select sum(select exec_time(fp)
           from function_prf fp
           where fp = function_profiles(ep) and
                 host_db(fp) = db and
                 like_i(function_nm(fp), 'odbc*'));

/* 
* The time spent in a node is:
* (time the node served to all its clients) -
* (time between the node and all its servers) -
* (time serving of all servers that served to this node)
* Function in Lisp because we need to handle NULL values.
*/
create function time_in_node(execution_prf ep, charstring client) -> real
as foreign 'time-in-node--+';
")

(defun time-in-node--+ (fno ep node)
  (let ((time-served (get-func 'total_time_serving ep node))
	(time-between (get-func 'time_between_client_and_all_servers ep node))
	(time-in-servers (get-func 'time_in_all_servers_of_client ep node))
	(time-in-odbc (get-func 'time_in_odbc ep node)))
    ; if this is a pure client node get the total time from the exec. profile
    (if (null time-served)
	(setq time-served (get-func 'exec_time ep)))
    ; if this is a pure server node it did not access other nodes
    ; do a consistency check
    (if (or (and (null time-between) time-in-servers)
	    (and time-between (null time-in-servers)))
	(error "Incosistent profiles"))
    ; set all external time to 0
    (if (null time-between)
	(setq time-in-servers (setq time-between 0)))
    (if (null time-in-odbc)
	(setq time-in-odbc 0))
    (osql-result ep node
		 (- time-served (+ time-between time-in-servers time-in-odbc)))))

(osql "
create function time_distr(execution_prf ep, integer precision)
       -> <real tot, real cli, real integr, real serv, real net, real odbc>
as select roundto(tot, precision),
          roundto(cli, precision),
          roundto(integr, precision),
          roundto(serv, precision),
          roundto(net, precision),
          roundto(odbc, precision)
   from real tot, real cli, real integr, real serv, real net, real odbc
   where tot = exec_time(ep) and
         cli = default((select time_in_node(ep, get_client(ep))), 0) and
         integr = default((select sum(time_in_node(ep, all_client_servers(ep)))), 0) and
         serv = default((select sum(time_in_node(ep, all_pure_servers(ep)))), 0) and
         net = default((select sum(exec_time(network_profiles(ep)))), 0) and
         odbc = default((select sum(time_in_odbc(ep, all_nodes(ep)))), 0);

create function rel_time_distr(execution_prf ep, integer precision)
       -> <real rel_cli, real rel_integr, real rel_serv, real rel_net, real rel_odbc>
as select roundto(100 * (cli_tm / tot_tm), precision),
          roundto(100 * (integr_tm / tot_tm), precision),
          roundto(100 * (serv_tm / tot_tm), precision),
          roundto(100 * (net_tm / tot_tm), precision),
          roundto(100 * (odbc_tm / tot_tm), precision)
   from real tot_tm, real cli_tm, real integr_tm, real serv_tm, real net_tm, real odbc_tm,
        integer prec
   where <tot_tm, cli_tm, integr_tm, serv_tm, net_tm, odbc_tm> = time_distr(ep, prec) and
         prec = precision + 1;


/* Statistics per profile */

create function node_stat(execution_prf ep) -> <charstring, real>
as select db, node_tm
   from charstring db, real node_tm
   where db = all_nodes(ep) and
         node_tm = time_in_node(ep, db);

create function network_stat(execution_prf ep) -> <charstring, charstring, real, integer>
as select client_db(np), server_db(np), exec_time(np), calls(np)
   from network_prf np
   where np = network_profiles(ep);

create function odbc_stat(execution_prf ep) -> <charstring, charstring, real, integer>
as select db, fnname, exec_time(fp), calls(fp)
   from charstring db, function_prf fp, charstring fnname
   where fp = function_profiles(ep) and
         host_db(fp) = db and
         fnname = function_nm(fp) and
         like_i(fnname, 'odbc*');

create function odbc_node_stat(execution_prf ep) -> <charstring, real>
as select db, time_in_odbc(ep, db)
   from charstring db
   where db = all_nodes(ep);

create function odbc_call_stat(execution_prf ep) -> <charstring, integer, integer>
as select db, calls(fp_in), calls(fp_out)
   from charstring db, function_prf fp_in, function_prf fp_out
   where fp_in = function_profiles(ep) and
         function_nm(fp_in) = 'ODBC-EXECUTE-QUERY' and
         fp_out = function_profiles(ep) and
         function_nm(fp_out) = 'ODBC-NEXT-ROW' and
         host_db(fp_in) = host_db(fp_out) and
         host_db(fp_in) = db and
         host_db(fp_out) = db;
")

(osql "
/* Summarize all function profiles of one execution profile, per DB */
create function function_stat(execution_prf ep, charstring db, vector fnvec)
       -> <charstring fnname, charstring db1, integer calls, real tm, real tpc>
as select fnname, db, calls(fp), roundto(exec_time(fp), 1), roundto(time_per_call(fp), 1)
   from function_prf fp, vector fnprf
   where fp = function_profiles(ep) and
         fnname = lower(function_nm(fp)) and fnprf = in(fnvec) and fnname = fnprf[0] and
         db = host_db(fp);

create function summarize_func_db(execution_prf ep, charstring db, charstring pat) -> real as
select sum(select tm
           from real tm, function_prf fp
           where fp = function_profiles(ep) and
                 host_db(fp) = db and
                 like_i(function_nm(fp), pat) and
                 tm = exec_time(fp));

create function summarize_func(execution_prf ep, charstring pat) -> <charstring, real> as
select db, tm
from charstring db, real tm
where db = in(select distinct host_db(function_profiles(ep))) and
      tm = summarize_func_db(ep, db, pat);
")

; end init-profiler-reports
)

(defun shutdown-profiler ()
; these types also get created, should we delete them? Others may use them.
;"BAG-VECTOR"
;"BAG-COLLECTION"
;"BAG-REAL"
;"BAG-CHARSTRING"
;"BAG-INTEGER"
;"BAG-OBJECT"
(osql "
delete type global_var;
delete type system_config;
delete type experiment_config;
delete type experiment_family;
delete type network_prf;
delete type server_prf;
delete type function_prf;
delete type execution_prf;
delete type profile;
")
)

*EOF*

; BUG:
;(osql "
;create function total_network_bytes(execution_prf ep) -> integer as
;select sum(bytes_in(network_profiles(ep)) + bytes_out(network_profiles(ep)));
;")