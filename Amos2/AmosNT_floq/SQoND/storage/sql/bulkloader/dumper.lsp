;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013 Andrej Andrejev, UDBL
;;; $RCSfile: dumper.lsp,v $
;;; $Revision: 1.9 $ $Date: 2013/07/28 06:20:39 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Dump facility for bulk-loading into MySQL-based RDF store
;;; =============================================================
;;; $Log: dumper.lsp,v $
;;; Revision 1.9  2013/07/28 06:20:39  andan342
;;; Bulk-loading binary chunks into MS SQL Server,
;;; moved array chunk file generation from dumper.lsp to nma-filedump function in C
;;;
;;; Revision 1.8  2013/07/18 15:03:30  andan342
;;; Added bulk-load functionality for MS SQL Server backend (with hexadecimal chunk storage only)
;;;
;;; Revision 1.7  2013/07/14 11:15:48  andan342
;;; Using Integer parameters to nma2chunks function, truly parametrized BINARY/HEX chunk storage
;;;
;;; Revision 1.6  2013/07/12 12:40:00  andan342
;;; Added hexadecimal string option to store binary data on SQL backend
;;;
;;; Revision 1.5  2013/04/16 15:37:49  andan342
;;; Bug fix
;;;
;;; Revision 1.4  2013/04/16 13:00:07  andan342
;;; Enabled multi-volume dumping and bulk-loading, dump file size is limited to 8Gb
;;;
;;; Revision 1.3  2013/02/08 00:52:50  andan342
;;; Updated to use NMA proxies in C
;;;
;;; Revision 1.2  2013/01/21 16:49:21  andan342
;;; Storing chunksize in Parameter table inside RDF store, comes as a parameter to setup.cmd script
;;; Added test script for bulk-loading
;;;
;;; Revision 1.1  2013/01/11 17:30:49  andan342
;;; Added bulk-loading and dumper functionality
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(osql "< 'settings.osql';")

(defparameter _csv_max_filesize_ (* 2 1024 1024 1024)) ;2Gb

(unless (boundp 'rdf-store-utils.lsp)
  (load "../sql-store-utils.lsp"))

(defstruct csvdump ut-stream lt-stream at-stream ls-stream uri-dict chunksize isHex (last-uri-id 7) (last-array-id 0) (last-longstring-id 0) (acf-idx -1) saved-get-blank)

(defvar *default-csvdump* nil)

(defun csvdump-new (chunksize isHex)
  (let ((res (make-csvdump :ut-stream (openstream (concat amos_dumpfileprefix "_ut.csv") "wb")
			   :lt-stream (openstream (concat amos_dumpfileprefix "_lt.csv") "wb")
			   :at-stream (openstream (concat amos_dumpfileprefix "_at.csv") "wb")
			   :ls-stream (openstream (concat amos_dumpfileprefix "_ls.csv") "wb")
			   :uri-dict (make-hash-table :test #'equal)
			   :chunksize chunksize
			   :isHex isHex
			   :saved-get-blank _sq_get_blank_)))    
    (dolist (iu rdf-store-default-uris)
      (setf (gethash (cdr iu) (csvdump-uri-dict res)) (car iu)))
    (setq _sq_get_blank_ (f/l (x) (gethash x (csvdump-uri-dict res))))
    res))

(defun csvdump_start (fno chunksize isHex)
  (setq *default-csvdump* (csvdump-new chunksize isHex))
  (let ((i 0) acf) ; cleanup old array chunks
    (while t
      (setq acf (concat amos_dumpfileprefix "_ac" i (if (= isHex 1) ".csv" ".dat")))
      (if (file-exists-p acf) (delete-file acf)
	(return t))
      (incf i))))

;;TODO: add append() as an alternative initializer

(defun csvdump-lookup-or-add-uri (dump uri)
  (let ((pos (gethash uri (csvdump-uri-dict dump))))
    (if pos pos
      (progn
	(setq pos (incf (csvdump-last-uri-id dump)))
	(setf (gethash uri (csvdump-uri-dict dump)) pos)))))

(defun csvdump-store-triple (dump s p o)
  (let ((sid (csvdump-lookup-or-add-uri dump (uri-id s)))
	(pid (csvdump-lookup-or-add-uri dump (uri-id p)))
	(otype (rdf-storage-type o (f/l (x) (csvdump-lookup-or-add-uri dump (uri-id x)))))
	(nma2chunks-fn (car (getobject (getfunctionnamed 'nma2chunks) 'resolvents))))
    (selectq otype
	     (0 (formatl (csvdump-ut-stream dump) sid "," pid "," (csvdump-lookup-or-add-uri dump (uri-id o)) t)) ; URI triple
	     (7 (let ((ats (csvdump-at-stream dump)) ; array triple
		      (dims (nma-dims o))
		      (aid (incf (csvdump-last-array-id dump))))
		  (formatl ats sid "," pid "," (nma-kind o) "," aid "," (length dims))
		  (dotimes (i 4) (formatl ats "," (if (< i (length dims)) (aref dims i) "")))
		  (formatl ats t)
		  (nma-filedump o aid (csvdump-chunksize dump) (csvdump-isHex dump) _csv_max_filesize_
                            (f/l () (concat amos_dumpfileprefix "_ac" (incf (csvdump-acf-idx dump)) (if (= (csvdump-isHex dump) 1) ".csv" ".dat"))))))
	     (let ((ostr (escape-string (rdf-to-store o) "\"")) ; literal triple
		   (lts (csvdump-lt-stream dump)) lsid)
	       (formatl lts sid "," pid ",\"")
	       (if (> (length ostr) 32)
		   (progn
		     (setq lsid (incf (csvdump-last-longstring-id dump)))
		     (formatl (csvdump-ls-stream dump) lsid ",\"" ostr "\"" t)
		     (formatl lts "\"," otype "," lsid t))
		 (formatl lts ostr "\"," otype "," t))))))


(defun csvdump_store_triple--- (fno s p o)
  (csvdump-store-triple *default-csvdump* s p o))

(defun csvdump-save (dump)
  (let ((uri-stream (openstream (concat amos_dumpfileprefix "_uri.csv") "wb"))
	(par-stream (openstream (concat amos_dumpfileprefix "_par.csv") "wb")))
    (unwind-protect
	(progn
	  (closestream (csvdump-ut-stream dump))
	  (closestream (csvdump-lt-stream dump))
	  (closestream (csvdump-at-stream dump))
	  (nma-filedump-close)
	  (closestream (csvdump-ls-stream dump))
	  (maphash (f/l (k v) (formatl uri-stream v "," k t)) (csvdump-uri-dict dump))
	  (formatl par-stream "chunksize," (csvdump-chunksize dump) t))
      (progn
	(setq _sq_get_blank_ (csvdump-saved-get-blank dump))
	(closestream uri-stream)
	(closestream par-stream)))))
	  

(defun csvdump_save (fno)
  (csvdump-save *default-csvdump*))
	      
(osql "
create function csvdump_start(Integer chunksize, Integer isHex) -> Boolean as foreign 'csvdump_start';

create function csvdump_store_triple(Literal s, Literal p, Literal o) -> Boolean as foreign 'csvdump_store_triple---';

create function csvdump_save() -> Boolean as foreign 'csvdump_save';

create function csvdump_ttl(Integer chunksize, Integer isHex, Charstring filename) -> Boolean as
begin
  csvdump_start(chunksize, isHex);
  csvdump_store_triple(turtle(filename));
  csvdump_save();
end;
")

; USAGE:
; ssdm "dumper.lsp" -o "csvdump_ttl(20, 0, '../../../test/data/turtle/alltypes.ttl');" -o "quit;"  
