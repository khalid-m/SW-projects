;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1998 Vanja Josifovski, Timour Katchaounov, Gundars Kulups
;;; $RCSfile: bulk.lsp,v $
;;; $Revision: 1.35 $ $Date: 2007/11/04 20:33:15 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Multidatabase query execution 
;;; =============================================================
;;; $Log: bulk.lsp,v $
;;; Revision 1.35  2007/11/04 20:33:15  torer
;;; Introduced function TRUE-RESULTP to test for result tuples returning (TRUE)
;;;
;;; Revision 1.34  2006/11/04 16:18:19  torer
;;; Systematically using GET-RESOLVENT-ARGTYPES and GET-RESOLVENT-RESTYPES
;;;
;;; =============================================================


;the number of tuples in the bulk, if changed functions should be recompiled
(defglobal _materialized_bags_ nil)
;this defines which ship-out algorithm will be used
(defglobal _sae_algorithm_ 'sae_sjma) ;either 'sae_sjma or 'sae_pc


;==============================================================================
; The structure containing run time control information passed to SAE 
;==============================================================================
(defstruct runInfo
  remotefn  ; the remote function to be called in DB
  db        ; remote database where ship-back is called
  input     ; input data coming from the bottom MB node
  vars      ; all variables of the SAE node (gNode-vars saeN)
  nParams   ; the number of parameters of the SAE node
  resTypes  ; types (objects) of the result variables of the SAE node
  shipInbpat ;A flag which tells if the sae is to be executed using the 
             ;ship-in method
)


;==============================================================================
; Server side of the SAE implementation, entry is ship-back 
;==============================================================================

(defun ship-back (calcfn data params)
  "Accepts a call form a sae executed at anothe amos.
   - CALCFN is the function to be executed
   - DATA is a bag of tuples: (TUP1 ... (EL1 ... ELk) ... TUPn)
   - PARAMS are parameters to calcfn that are the same for each call.
   Params are appended to each tuple and such a extended tuple represents 
   the arguments of calcfn.
   - RETURN bag of bags of tuples - same as the input/output of externalize"
  (let* ((atypes (get-resolvent-argtypes calcfn))
	 (rtypes (get-resolvent-restypes calcfn))
	 (loc-data   (localize data atypes))
	 (loc-params (car (localize (list params) atypes)))
	 (result
	  (if loc-data
	      (mapcar (f/l (tup) (getfunction calcfn (append tup loc-params)))
		      loc-data) ; returns bag of bags when there is an input
	      ; else returns a simple bag - the list is to make it bag of a bag
	      (list (getfunction calcfn loc-params)))))

    ; TODO: This part deletes the bags materialized when ODBC data sources are
    ; accessed. Crude mechanism, should be substitued with something better
    (mapcar (f/l (fno) (putobject fno 'matdata nil)) _materialized_bags_)
    (setq _materialized_bags_ nil)

    ;(mdb-event "<--" (length result) "")
    ;make integers of the OIDs and standadize the result (bag of bags of tuples)
    (if rtypes ; check for boolen func.
	(externalize_data result rtypes)
        result) ; boolean func
    ))


(defun localize (indata argtypes)
  "Check if numeric arguments are in fact local OIDs and if this is the case, 
   convert them to OIDs. This is done by checking the argument types of calcfn."
  (mapcar (f/l (tuple)
	       (do ((tp tuple (rest tp))
		    (at argtypes (rest at))
		    (result 'nil))
		   ((null tp) result)
		   (let ((elem (if (ut_p (car at))
				   (getobjectnumbered (car tp))
				   (car tp))))
		     (setq result (append result (list elem))))))
	  indata))

(defun externalize_data (data rtypes)
  "Convert OIDs to integers before sending them to another DB.
   DATA is of the form: (BAG1 ... ((EL1 ... ELn) ... TUPk) ... BAGn)"
  ; If there are no integers among the types, just return the original data
  (if (memq _integer_ rtypes)
      (mapcar (f/l (bag)
		   (mapcar (f/l (tup)
				(mapcar (f/l (el tp)
					     (if (and (eq tp _integer_) (oid-p el))
						 (if (proxy-p el)
						     (proxy-oid el)
						     (oid-idno el))
					         el))
					tup rtypes))
			   bag))
	      data)
      data))


;===============================================================================
; The generic sae function, calls the appropriate algorithm and returns result
;===============================================================================
(defun sae (obj data rInfo &rest args)
  "Ship-and-execute
   runInfo is used instead of 6 variables to reduce the number of args of SAE
   and therefore reduce the time needed to bind them during run-time.
   ARGS is a list of arguments where first are the parameters, and then the i/o variables"
  (let ((result 
	 (if (runInfo-shipinbpat rInfo)	 ;sae by shipin algorithm (described in the paper)
	     (sae_shipin data rInfo args) ;sae by one of the ship-out algorithms (thesis and paper)
	     (funcall _sae_algorithm_ data rInfo args)))
	(resHead (list data rInfo))
	(params (extract 1 (runInfo-nParams rInfo) args))) ;parameters to rfun
    (dolist (elem result)
      (apply (function osql-result) (append resHead params elem)))))


;===============================================================================
; Project-concat SAE implementation 
;===============================================================================

(defun sae_pc (data rInfo args)
  "SAE implemented by the project-concat algorithm.
   'runInfo' is used instead of 6 variables to reduce the number of args of
   SAE and therefore reduce the time needed to bind them during run-time.
   'args' is a list of arguments where first are the parameters, and then 
   the i/o variables."
  (if (equal data "cleanup") nil
           ; input data coming from the bottom MB node
    (let* ((input   (runInfo-input rInfo)) 
           ; result types. if NIL -> BOOLEAN function
	   (rtypes  (runInfo-resTypes rInfo)) 
	   (params (extract 1 (runInfo-nParams rInfo) args))
	   (callpat (mapcar (f/l (v) (if (memq v (runInfo-vars rInfo)) '- '+ ))
			    input))
	   (outdata (prepare-to-send data callpat))
	   (outparams (prepare-to-send (list params) (buildn (length params) '-)))

	   ; log to the nameserver who, how many tuples sent to whom
	   ;(dummy (mdb-event db (length outdata) ""))

	   (reval_res (remote-eval 
			(list 'ship-back
			      (kwote (runInfo-remotefn rInfo))
			      (kwote outdata)
			      (kwote (car outparams)))
		      (runInfo-db rInfo)))
	   
	   (rtypes_tag (mapcar (f/l (tp) (if (proxytype? tp) tp nil)) rtypes))
	   result)
      (if rtypes ; check for boolean func
	  (setq reval_res (set_proxy_type rtypes_tag reval_res)))

      (if (and outdata input)
	  (progn
	    (assert (= (length data)(length reval_res)) "PAIR wrong in SAE")
	    ;connected query graph --> concat
	    (mapc (f/l (o_r)
		       (setq result
			     (add_result_tuples (car o_r) (cdr o_r) rtypes result)))
		  (pair data reval_res)))

	;no data was sent out
	(setq result (sae_unusual_cases input rtypes data reval_res result)))
      (bp sae02)
      result)))

;===============================================================================
; The ship-in implementation of SAE
;===============================================================================
(defun sae_shipin (data rInfo args)
  "The ship-in implementation of SAE.
   'runInfo' - see the coments in the sae function"
  ;delete the tables, update the statistics
  (if (equal data "cleanup")
      (cleanup_after_sae_shipin rInfo)
    (let*  ((tIndex (ship_in_data rInfo args))
           ;input data coming from the bottom MB node
	   (input   (runInfo-input rInfo)) 
	   ;calling pattern in the standard amos format (+ - + + - ...)
	   (callpat (mapcar (f/l (v) 
				 (if (memq v (runInfo-vars rInfo)) '- '+ ))
			    input))
	 
	   ;project out only the columns that are actualy input to 
           ;the remote function and change proxy OIDs to integers representing
	   ;the OID of the external objs.
	   (outdata (prepare-to-send data callpat))

	   (rtypes (runInfo-resTypes rInfo))
	   result);end of let definitions
      (bp sjma0)
      (if (and outdata input)
	  (mapc (f/l (o d)
		     (setq result
			   (add_result_tuples d 
					      (gethash o tIndex)
					      rtypes 
					      result))) 
		outdata data)
	  (setq result (sae_unusual_cases input rtypes data NIL result))) ; reval_res is NIL here
      (bp sae02)
      result)))

(defun ship_in_data (rInfo args)
  "Generates the temporary index for the ship in algorithm."
  (let*  ((rtypes  (runInfo-resTypes rInfo))
	  ;result types. if NIL -> BOOLEAN func

	  (rtypes_tag (mapcar (f/l (tp) (if (proxytype? tp) tp nil)) rtypes))
	  ;result pattern the bound in the result should match the bound
	  ;in the input
; HACK: reverse is just to make this work with the test query for ICDE'2001
; TODO: find out why it works & where it gets reversed  
	  (respat (reverse (runInfo-shipInBpat rInfo)))
	  ;(respat (runInfo-shipInBpat rInfo))
	  (nils_to_add (buildn (- (length respat) (length rtypes)) NIL))
	  (alltypes_tag (append nils_to_add rtypes_tag))
	  (params (extract 1 (runInfo-nParams rInfo) args));parameters to rfun

	  ;proxy OID for the remote function that is 
	  ;called in the remote server
	  (rfun (runInfo-remotefn rInfo))
	  (db   (runInfo-db rInfo));remote server
	  (cached_Index (getobject rfun 'SaeTempIndex)))
    ; the temporary index used in the ship-in algorithm
    (if cached_Index
	cached_Index
        ; if there is none, then create it and fill it in with data
        (let* ((data_in_raw (remote-eval 
			     (list 'ship-back (kwote rfun) nil (kwote params)) db))
	       (data_in (if rtypes
			    (set_proxy_type alltypes_tag data_in_raw)
			    data_in_raw))
	       (new_Index (make-hash-table :test #'equal)))
	  (mapc (f/l (bag)
		     (mapc (f/l (tup)
				(let ((kv (separate_key_val tup respat)))
				  (puthash (car kv) new_Index 
					   (cons (cdr kv) (gethash (car kv) new_Index)))))
			   bag))
		data_in)
	  (putobject rfun 'SaeTempIndex new_Index)
	  new_Index))))

(defun separate_key_val (tuple pattern)
  (let (key value)
    (mapc (f/l (col pat)
	       (if (eq pat '-) 
		   (setq key (cons col key))
		   (setq value (cons col value))))
	  tuple
	  pattern)
    (cons (nreverse key) (nreverse value))))
	    

(defun cleanup_after_sae_shipin (rinfo)
  "Delete the temporary structures used in sae implemented by sjma."
  (let ((rfun (runInfo-remotefn rInfo)))
    (putobject rfun 'SaeTempIndex nil)))
		   
;===============================================================================
; The sjma implementation of SAE
;===============================================================================
(defun sae_sjma (data rInfo args)
  "Semi-Join with Materialized index Algorithm
   Described in the detail in the thesis pp 127-130
   runInfo -- see the coments in the sae function."
  ;delete the tables, update the statistics
  (if (equal data "cleanup")
      (cleanup_after_sae_sjma rInfo)
    (let* (
           ;input data coming from the bottom MB node
	   (input   (runInfo-input rInfo)) 
           ;result types. if NIL -> BOOLEAN function
	   (rtypes  (runInfo-resTypes rInfo))
	   (params (extract 1 (runInfo-nParams rInfo) args));parameters to rfun
	   ;calling pattern in the standard amos format (+ - + + - ...)
	   (callpat (mapcar (f/l (v) (if (memq v (runInfo-vars rInfo)) '- '+ ))
			    input))
	   ;proxy OID for the remote function that is 
	   ;called in the remote server
	   (rfun (runInfo-remotefn rInfo))
	 
	   ;the temporary index used in the Semi-Join with Materialized index
	   ;Algorithm
	   ;if there is none, and there is data coming in this operator
	   ;then create an empty  one
	   (tIndex (let ((htable (getobject rfun 'SaeTempIndex)))
		     (if (and (not htable) 
			      (not (eq data "")))
			 
			 (putobject rfun 'SaeTempIndex 
				    (make-hash-table :test (function equal))))
		     
		     (getobject rfun 'SaeTempIndex)))
	   
	 
	   ;project out only the columns that are actualy input to 
           ;the remote function and change proxy OIDs to integers representing
	   ;the OID of the external objs.
	   (outdata (prepare-to-send data callpat))
	   (outparams (prepare-to-send (list params) (buildn (length params) '-)))

	   ;filter the tuples that has no match in the temporary index
	   ;those matched are added to the result
	   ;filter the tuples already in the index (matched tuples)
	   ;and appends the result tuples to the results for each match
	   ;returns the rest of the tuples
	   (onm_od_r (filter_and_match outdata data tIndex rtypes nil))
	   (result (cdr onm_od_r))
	   (onm_od (car onm_od_r))
	   (outdata_not_matched (car onm_od)); this has duplicates removed
           ;pairs of data and outdata that are not matched
	   (outdata_data_nm (cdr onm_od))

	   ; log to the nameserver who, how many tuples sent to whom
	   ;(dummy (mdb-event db (length outdata_not_matched) ""))

	   (reval_res (if (or (not outdata) ;no shiping only execute
			       outdata_not_matched) 
			     ;if both false, then all tuples found in the index
			   (remote-eval 
			    (list 'ship-back
				  (kwote rfun) 
				  (kwote outdata_not_matched) (kwote (car outparams)))
			    (runInfo-db rInfo))))

	   (rtypes_tag (mapcar (f/l (tp) (if (proxytype? tp) tp nil)) rtypes))
	   (resHead (list data rInfo)));end of let definitions
      (bp sjma0)
      (if rtypes ; check for boolean func
	  (setq reval_res
		(set_proxy_type rtypes_tag reval_res)))
      (if (and outdata input)
	  (progn
	    ;connected query graph --> add to the index and to the result list
	    (mapc (f/l (o_r) 
		         ; add the result to the index
			 (puthash (car o_r) tIndex 
			          ;we cannot put nil in the hash table
			          ;nil means 'not present'
			          ;so we use (list nil) to indicate 'no matches'
				  (if (not (cdr o_r)) '(nil) (cdr o_r))))
		    (pair outdata_not_matched reval_res))	    
	    (mapc (f/l (o_d)
			 (setq result
			       (add_result_tuples (cdr o_d) 
						  (gethash (car o_d) tIndex) 
						  rtypes 
						  result)))
		  outdata_data_nm))
	  (setq result (sae_unusual_cases input rtypes data reval_res result)))
      (bp sae02)
      result)))


(defun filter_and_match (outdata data tIndex rtypes result)
  "This is a part of the sjma sae algorithm - duplicate removal and anti-join
   filter the tuples already in the index (matched tuples) & appends the result
   tuples to the results for each match, returns the remaining tuples. Returns 2 things
   1. a list of pairs (outdata data) where outdata is a portion of the data 
      tuple that should be shipped out (i.e. after the projection)
   2. the duplicate removed subset of outdata tuples that do not appear
      in the index. format of the result:  (cons outdata (pair outdata data))."
 (if (not tIndex)
     (cons outdata (pair outdata data))
   (let* (no_dupl
	  (dup_rem_ht (make-hash-table :test (function equal)))
	  (res
	   (mapfilter 
	    (f/l (o_d) 
		 (let* ((tuple (car o_d))
			(hres (gethash tuple tIndex))) ; check in temp. index if this tup
		                                      ; has alredy been processed
	           ;if the result is already in the index, and there are matches
		   (if (and hres (not (equal '(nil) hres)))
		       (progn 
		         ;the result is a concat of the original data and the matches!!
		         ;that is why I had to drag data all the way down to here
			 (setq result (add_result_tuples (cdr o_d) hres rtypes result))
			 nil) ;this tuple done, filter out
		     
		     (if (gethash tuple dup_rem_ht)
			 t ;filter out, already appended for shiping out, but keep 
		           ;for emitting results
		       (progn (puthash tuple dup_rem_ht 't) 
			      (setq no_dupl (cons tuple no_dupl))
			      t))))); ship out this tuple, has not been seen before
	    (pair outdata data))))
     (cons (cons no_dupl res) result))))



(defun cleanup_after_sae_sjma (rinfo)
  "Delete the temporary structures used in sae implemented by sjma."
  (let ((rfun (runInfo-remotefn rInfo)))
    (putobject rfun 'SaeTempIndex nil)))
		       


;===============================================================================
; Function used by more than one of the algorithms
;===============================================================================

(defun sae_unusual_cases (input rtypes data reval_res result)
  "The unusal cases for the both sae_pc, sae_sjma and sae_ship_in algorithms:
   cross product and only output cases."
  (if input                    
      ;unconnected query graph --> cross product
      (if rtypes  ;non-boolean result
	  (dolist (d data)
	    (dolist (bag reval_res)
	      (dolist (tup bag)
		(setq result (cons (append d tup) result)))))
	;boolean saefn + cross product = 1 copy 
	;of data for each TRUE
	(dolist (bag reval_res)
	  (dolist (tup bag)
	    (if (true-resultp tup)
		(setq result (append data result))))))
      ;no input - only output --> the output is the result, then
      ;concat all the bags of tuples to get a bag of tuples
      (setq result (mapcan #'nconc reval_res)))
  result)

(defun set_proxy_type (tags data)
  "- TAGS list of proxy types or NILs
   - DATA bag of bags of tuples
   - RETURN bag of bags of tuples where integers that represent remote OIDs
     are replaced by Proxy OIDs
   TODO: check if there are any surrogate types in the type list 'tags'"
  (mapcar (f/l (bag)
	       (mapcar  (f/l (tup)
			     (mapcar (f/l (value tag)
					  (assert (not (listp value)) "Non-atomic value")
					  (cond ((and tag
						      (not (memq tag (arg-types value))))
						 (if (integerp value) ; generate a proxy obj
						     (setq value (make-proxy-obj value (proxytype-origin tag))))
						 (/addtype value tag)
						 value)
						(t value)))
				  tup tags))
		     bag))
	       data))

(defun iter-bag (obj b &rest al)
  (dolist (tup (cdr b))
	  (osql-result (cons obj (cons b tup)))))

(defun prepare-to-send (alldata bpat)
  "select only bound data from tuple list alldata based on '-' positions in bpat and
   change OIDs of proxy objects to idno-s of corresponding remote OIDs.
   alldata is of the form ((...) ...)"
   (mapcan (f/l (tuple)
             (do ((tp tuple (rest tp))
                  (bp bpat (rest bp))
                  (result nil))
                 ((null tp) (if result (list result)))
                (let ((elem (first tp))
                      (flag (first bp)))
                   (if (equal flag '-)
		       (if (proxy-p elem)
			   (setq result (append result (list (proxy-oid elem))))
			   (setq result (append result (list elem))))))))
     alldata))


(defun add_result_tuples (tuple matches rtypes &optional result)
  "For each input tuple, and a list of matches appends to the result a resulting
   tuple that is a concatenation of the input and the matching tuple.
   If the func is boolean, then the result is only the input tuple."
 (if (not (equal matches '(nil)))  
     (mapcar (f/l (r) 
		  (if rtypes ; check for boolen func.
		      (setq result (cons  (append tuple r) result))
		      (if (eq (car r) 'TRUE) ; boolen func.
			  (setq result (cons tuple result)))))
	     matches))
     result)


(defun bulken-+ (obj bag bulk)
  "This is a foreign lisp function. Divides the whole bag into bulks for 
   streamed processing.
   Takes a bag, a var list and returns the bag containing the bulk.
   The bulk size can be changed at runtime."
  (let ((lst nil)
	(bulk-size (funcall _bulk_strategy_))
	(count 0))
   (if (not (eq bag ""))
       (mapbag bag (f/l (bgel)
			(assert (>= bulk-size 0) "Negative BULK_SIZE")
			(setq lst (cons bgel lst))
			(1++ count)
			(cond ((and (>= count bulk-size) ; we filled one bulk
				    (> bulk-size 0))     ; 0 means infinite bulk
			       (osql-result bag lst)
			       (setq lst nil)
			       (setq count 0)
			       (setq bulk-size (funcall _bulk_strategy_ bulk-size)))))))
   ; the whole bag fits in one bulk
   (if (> count 0)
       (osql-result bag lst))
   ; indicate that the processing is over
   ; sae should delete the temporary indexes
   (osql-result bag "cleanup")))

;===============================================================================
; Different strategies to change the bulk size during execution.
; All of them have the same interface:
; input: the old bulk size, NIL means request for initial bulk size
; output: new bulk size
;===============================================================================
(defun bulk-constant (old-bulk-size)
  "Keep a constant bulk size."
  1024)

(defun bulk-step-grow (old-bulk-size)
  "Grow the bulk size in several steps."
  (let ((new-bulk-size
	 (if (null old-bulk-size)
	     16
	     (cond ((< old-bulk-size 1024) 1024)
		   ((<= old-bulk-size 1024) 8192)
		   ((<= old-bulk-size 8192) 0)))))
    new-bulk-size))

(defun bulk-memory-aware (old-bulk-size)
  "Take into account memory requirements."
  ;TODO - work in progress
)
