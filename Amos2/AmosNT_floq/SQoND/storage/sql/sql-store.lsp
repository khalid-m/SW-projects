;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012-13, Andrej Andrejev, UDBL
;;; $RCSfile: sql-store.lsp,v $
;;; $Revision: 1.16 $ $Date: 2013/07/27 18:42:42 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: SQL-based RDF store implementation
;;; =============================================================
;;; $Log: sql-store.lsp,v $
;;; Revision 1.16  2013/07/27 18:42:42  andan342
;;; Bulk-loading binary chunks into MS SQL Server,
;;; no longer using isHex parameter to register-proxy-tag,
;;; no longer duplicating :sql_dialect and :isHex variables with stored functions
;;;
;;; Revision 1.15  2013/07/14 11:14:03  andan342
;;; Using Integer parameters to nma2chunks function, truly parametrized BINARY/HEX chunk storage
;;;
;;; Revision 1.14  2013/07/12 12:40:48  andan342
;;; Added hexadecimal string option to store binary data on SQL backend
;;;
;;; Revision 1.13  2013/06/17 15:29:20  andan342
;;; Added set_enable_rdf_cache() and rdf_cache_enabled() functions, to control the RDF triples cache
;;;
;;; Revision 1.12  2013/03/18 12:44:48  andan342
;;; Fixed bug with missing emits from AAPR
;;;
;;; Revision 1.11  2013/03/17 16:59:51  andan342
;;; Added MS SQL Server backend option, as described in readme_ms.txt
;;;
;;; Revision 1.10  2013/02/24 20:14:59  andan342
;;; Fixed bug when refreshing triples cache on rdf:load()
;;;
;;; Revision 1.9  2013/02/21 23:36:37  andan342
;;; Renamed NMA-PROXY-RESOLVE to APR, using AAPR for aggregated chunk retrieval, caching the triples on startup
;;;
;;; Revision 1.8  2013/02/13 14:52:47  andan342
;;; Fixed bugs in APR
;;;
;;; Revision 1.7  2013/02/13 09:56:59  andan342
;;; *** empty log message ***
;;;
;;; Revision 1.6  2013/02/12 23:49:44  andan342
;;; Added bag-valued 'combiner' definition of APR
;;;
;;; Revision 1.5  2013/02/08 00:51:44  andan342
;;; Completely removed Lisp implementation of NMA proxies and chunks
;;;
;;; Revision 1.4  2013/02/01 12:04:07  andan342
;;; Using same NMA descriptor objects as proxies
;;;
;;; Revision 1.3  2013/01/11 17:30:48  andan342
;;; Added bulk-loading and dumper functionality
;;;
;;; Revision 1.2  2012/11/19 23:58:10  andan342
;;; - using resolve-nma inside all array-processing functions as part of proxy-allowing polymorphic behavior,
;;; - moved _nma_proxy_threshold_ to core SSDM, setting this value in regression test return NMAs from queries,
;;; - added _nma_limit_ for a max NMA size to be retrieved, printing a warning if exceeded
;;;
;;; Revision 1.1  2012/09/06 14:13:52  andan342
;;; Complete SQL-based RDF storage backend, still without array support
;;;
;;; =============================================================

(unless (boundp 'rdf-store-utils.lsp)
  (load "sql-store-utils.lsp"))

;;; ----------------------- GENERAL ------------------------------

(setq _sq_storage_system_ :sql) 

(foreign-lispfn get_db_name ((Charstring x)) ((Charstring))
		(foreign-result (substring (1+ (string-rightpos x "/" "=")) (length x) x)))
		
(defun lookup-uri (id)
  (caar (getfunction (car (getobject (getfunctionnamed 'URI_cache) 'resolvents)) (list id))))

(defun lookup-or-add-uri (uri)
  (caar (getfunction (car (getobject (getfunctionnamed 'lookupOrAddURI) 'resolvents)) (list uri))))


;;; ----------------------- LOADING ------------------------------

(defun load-into-rdfstore (filename)
  "Loads triples from Turtle file into SQL-naive store mapped to TRIPLES_RDFTORE type"
  (let ((turtle-fn (car (getobject (getfunctionnamed 'turtle) 'resolvents)))
	(store-triple-fn (car (getobject (getfunctionnamed 'storeTriple) 'resolvents))))
    (mapfunction turtle-fn (list filename)
		 (f/l (row) 
		      (getfunction store-triple-fn row)))
    (osql "refresh_SDEF(true);")
    t))

    
(defun clear-rdfstore ()
  (when (string= _sq_default_triples_fn_ "SDEF()")
    (osql "refresh_SDEF(false);"))
  (osql "sql(rdfstore(),'DELETE FROM URITriples');")
  (osql "sql(rdfstore(),'DELETE FROM LiteralTriples');")
  (osql "sql(rdfstore(),'DELETE FROM LongStrings');")
  (osql "sql(rdfstore(),'DELETE FROM ArrayChunks');")
  (osql "sql(rdfstore(),'DELETE FROM ArrayTriples');")
  (osql "sql(rdfstore(),'DELETE FROM URI WHERE id > 7');")
  (osql "refresh_URI_cache(true);"))

(setq _sq_load_triples_ #'load-into-rdfstore)

(setq _sq_clear_triples_ #'clear-rdfstore)

;;; ----------------------- PROXY RESOLVING ----------------

(defglobal *getchunk-fn* nil)
(defglobal *getchunks-fn* nil)
(defglobal *getchunks-bypattern-fn* nil)

(foreign-lispfn InitSQLProxies () ((Boolean)) ; initialize the above variable
		(setq *getchunk-fn* (car (getobject (getfunctionnamed 'getArrayChunk) 'resolvents)))
		(setq *getchunks-fn* (car (getobject (getfunctionnamed 'getArrayChunks) 'resolvents)))		
		(setq *getchunks-bypattern-fn* (car (getobject (getfunctionnamed 'getArrayChunksByPattern) 'resolvents))))

(defun sql-nma-getchunk (arrayid chunkid)  ; callback from C
  (caar (getfunction *getchunk-fn* (list arrayid chunkid))))

(defparameter _sql_proxy_tag_ (nma-register-proxytag nil 'sql-nma-getchunk 'sql-nma-cache-chunks-by-pattern))

(defglobal _nma_proxy_threshold_ 256) ; max proxy size (in elements) to resolve instantly

(foreign-lispfn set_nma_proxy_threshold ((Integer x)) ((Boolean))
		(setq _nma_proxy_threshold_ x))

(defglobal *chunksize* 0)

(foreign-lispfn set_chunksize ((Integer x)) ((Boolean))
		(setq *chunksize* x)
		(nma-proxy-set-default-chunksize _sql_proxy_tag_ x))

(nma-proxy-setlimit 16384) ; max proxy size (in elements) ever to resolve

(nma-cache-setlimit 18000000) ; ~18Mb

(foreign-lispfn cr () ((Boolean)) ; clear chunk cache
		(nma-cache-reset))

;;; ----------------------- AGGREGATED CHUNK RETRIEVAL -----

(defglobal _spd_sample_size_ 5)

; SEQUENCE PATTERN DETECTOR
(defstruct spd (cnt 0) history pattern next first-ordinal prev-ordinal)

(defun addlast (e l)
  "Add element E to the end of list L (destructive)"
  (if l (progn 
	  (rplacd (last l) (list e))
	  l)
    (list e)))

(defun spd-push (spd e)
  "Push a sequence element E into detector SPD"  
  (if (equal e (car (spd-next spd)))
      (setf (spd-next spd) (if (cdr (spd-next spd)) ; either new element conforms with the pattern
			       (cdr (spd-next spd)) (spd-pattern spd))) 
    (progn
      (setf (spd-pattern spd) (nreverse (copy-tree (spd-history spd))))
      (if (and (cdr (spd-pattern spd)) (equal e (car (spd-pattern spd))))
	  (setf (spd-next spd) (cdr (spd-pattern spd))) ; or the whole history is the new pattern and the current element conforms with it
	(progn
	  (setf (spd-pattern spd) (addlast e (spd-pattern spd)))
	  (setf (spd-next spd) (spd-pattern spd)))))) ; or the whole history plus the current element is the new pattern
  (incf (spd-cnt spd))
  (push e (spd-history spd)))

(defun spd-push-ordinal (spd o)
  "Push offset of ordinal value O into detector SPD"
  (unless (= o (spd-prev-ordinal spd))
    (if (spd-prev-ordinal spd)
	(spd-push spd (- o (spd-prev-ordinal spd)))
      (setf (spd-first-ordinal spd) o))
    (setf (spd-prev-ordinal spd) o)))

(defun spd-get-divisor (spd)
  "Sum up pattern of offsets to get MOD divisor"
  (let ((res 0))
    (dolist (x (spd-pattern spd) res)
      (incf res x))))

(defun spd-get-modlist (spd)
  "Create a valid MOD list for the pattern of offsets"
  (strings-to-string (mapcar #'mkstring (cons 0 (butlast (spd-pattern spd)))) "" "," ""))

; TEST:
;(let ((spd (make-spd))) 
;  (dolist (o '(20 21 25 26 27 31 32 33 37 38 39 43 44 45))
;    (spd-push-ordinal spd o))
;  (print spd)
;  (print (concat "mod(id - " (spd-first-ordinal spd) ", " (spd-get-divisor spd) ") in (" (spd-get-modlist spd) ")")))

(defun aggregated-retrieve-chunks (x spd)
  "Retrieve and cache all the chunks of according to pattern in SPD,
   use X to access chunk cache and (NMA-S X) as array id"
  (if (spd-pattern spd) ; retrieve 2 or more chunks by pattern
      (mapfunction *getchunks-bypattern-fn* (list (nma-s x) (spd-first-ordinal spd) (spd-get-divisor spd) (spd-get-modlist spd))
		   (f/l (row)
			(nma-cache-put x (aref (car row) 0) (aref (car row) 1))))
    (nma-cache-put x (spd-first-ordinal spd) ; retrieve single chunk by chunkid
		   (caar (getfunction *getchunk-fn* (list (nma-s x) (spd-first-ordinal spd)))))))

(defun sql-nma-cache-chunks-by-pattern (x chunkids-sample) ; callback from C
  (if (eq chunkids-sample t); if all chunks are requested
      (mapfunction *getchunks-fn* (list (nma-s x)) ; retrive & cache all the chunks
		   (f/l (row)
			(nma-cache-put x (aref (car row) 0) (aref (car row) 1))))
    (let ((spd (make-spd))) ; else build pattern
      (dolist (chunkid (nreverse chunkids-sample))
	(spd-push-ordinal spd chunkid))
      (aggregated-retrieve-chunks x spd)))) ; retrive & cache by pattern


(defun aapr-+ (fno xs res)
  (let (x chunkids spds spd-entry spd)
    (mapbag xs (f/l (row)
		    (setq x (car row))
		    (if (and (eq (typename x) 'nma) (> (nma-proxytag x) 0)) ; if x is a NMA proxy
			(progn			
			  (setq chunkids (and (nma-proxy-has-cache x)
					      (nma-chunkid-list x _spd_sample_size_ t)))
			  (if chunkids ; if any required chunks are missing from a cache 
			      (progn
				(setq spd-entry (assoc (nma-s x) spds)) ; get or make SPD entry for this array
				(unless spd-entry
				  (setq spd-entry (list (nma-s x) (make-spd)))
				  (push spd-entry spds))				
				(setq spd (second spd-entry))
				(dolist (cid (nreverse chunkids)) ; push all chunkids into SPD
				  (spd-push-ordinal spd cid))
				(push x (cddr spd-entry)) ; push this proxy into proxy buffer
				(when (> (spd-cnt spd) _spd_sample_size_) ; if SPD has accumulated enough chunkids
				  (aggregated-retrieve-chunks x spd) ; retrieve all uncached chunks with one SQL call
				  (dolist (x1 (cddr spd-entry))
				    (osql-result xs (apr x1))) ; resolve and emit all accumulated proxies 
				  (setf (cdr spd-entry) (list (make-spd))))) ; re-create SPD and clear the buffer
			    (osql-result xs (apr x)))) ; if all chunks are in cache - resolve and emit immediately
		      (osql-result xs x)))) ; if not a proxy - emit immediately as is
    (dolist (spd-entry spds) 
      (when (cddr spd-entry) ; if there are proxies in any buffer
	(aggregated-retrieve-chunks (third spd-entry) (second spd-entry)) ; retrieve all uncached chunks with one SQL call
	(dolist (x1 (cddr spd-entry))
	  (osql-result xs (apr x1))))))) ; resolve and emit the proxies





(osql "
/* delete function aapr; */ /* an identity function by default */ 

create function aapr(Bag of Literal xs key) -> Bag of Literal
  as foreign 'aapr-+';
")

;;; ----------------------- ACCESSING ----------------------

(setq _sq_default_triples_fn_ "SDEF()")

(foreign-lispfn set_enable_rdf_cache_internal ((Boolean x)) ((Boolean))
  (setq _sq_default_triples_fn_ (if (eq x 'true) "SDEF()" "DEF()")))

(foreign-lispfn rdf_cache_enabled () ((Boolean))
  (when (string= _sq_default_triples_fn_ "SDEF()")
    (foreign-result 'true)))

(defun stored-langstring-to-rdf (str)
  (let ((i 0) (j 0) (base "") cc)
    (loop
      (setq cc (substring i i str))
      (when (string= cc "") 
	    (error (concat "Invalid stored langstring ('@' delimiter expected): " str)))
      (when (member cc '("@" "\\"))
	(when (> i j) 
	  (setq base (concat base (substring j (1- i) str))))
	(if (string= cc "@")
	    (return (ustr base (substring (1+ i) (1- (length str)) str)))
	  (progn (setq j (1+ i))
		 (incf i))))
      (incf i))))

(defun storeToRDF--+ (fno s ltype res)
  (osql-result s ltype
	       (selectq ltype
			(0 (uri s)) ;URI 
			((1 3) (read s)) ;int, boolean
			(2 (* (read s) 1.0)) ;real
			(4 (rdf-str-to-timeval s)) ;timeval
			(5 (ustr s)) ;string 
			(6 (stored-langstring-to-rdf s)) ;string with langtag
			(7 (let* ((proxy-data (mapcar #'read (string-explode s "|"))) ;NMA
				  (dims (firstn (third proxy-data) (cdddr proxy-data)))
				  (proxy (make-nmaproxy (first proxy-data) dims _sql_proxy_tag_ (second proxy-data))))
			     (if (or (null _nma_proxy_threshold_) ; if proxies are disabled
				     (and (> _nma_proxy_threshold_ 0) ; or NMA size is below threshold
					  (<= (lproduct dims) _nma_proxy_threshold_)))
				 (apr proxy) ; return NMA
			       (progn
				 (nma-proxy-startcache proxy)
				 proxy)))) ; otherwise return proxy
			(typedrdf s (lookup-uri ltype))))) ;typedrdf
  

(defun storeToRDF++- (fno s ltype res)
  (osql-result (rdf-to-store res) (rdf-storage-type res #'lookup-or-add-uri) res))

(osql "
create function storeToRdf(Charstring s, Integer ltype) -> Literal 
  as multidirectional
  ('bbf' key foreign 'storeToRDF--+')
  ('ffb' key foreign 'storeToRDF++-');

parteval('StoreToRDF');
")

;;; -------------------- BLANKS LOOKUP ----------------------------

(defun get-blank-in-store (x)
  (getfunction (car (getobject (getfunctionnamed 'URI_in_DEF) 'resolvents)) (list x)))

(setq _sq_get_blank_ #'get-blank-in-store)
