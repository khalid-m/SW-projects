;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2003 Tore Risch and Johan Sandström, UDBL
;;; $RCSfile: unload.lsp,v $
;;; $Revision: 1.14 $ $Date: 2011/05/02 12:54:10 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Amos II database unloader
;;; =============================================================
;;; $Log: unload.lsp,v $
;;; Revision 1.14  2011/05/02 12:54:10  torer
;;; New function to unload both schema and data:
;;;   unloadDatabase(Charstring file)-> Charstring
;;;
;;; =============================================================

(defvar *oid-instno* 0)
(defvar *oid-list* nil)
(defvar *mystream* nil)
(defvar *nullinst-list* nil)

(defun openwritefile- (fno filename)
  (setq *mystream* (openstream filename "w")))

(defun closewritefile- (fno)
  (closestream *mystream*)
  (setq *mystream* nil))

(defun withwritefile--+ (obj file fn)
  (with-output-file *mystream* file
		    (mapfunctionres fn (list file) nil
				    (f/l (row)(osql-result file fn 
							   (car row))))))

(defun getwatermark+ (fno)
  (osql-result  _system-watermark_))

(defun set-watermark ()
  "All OIDs with id up to last created OID are protected for change"
  (setq _system-watermark_ _oidno_))

(defun generate-new-oid-var(o)
  (setq *oid-instno* (+ *oid-instno* 1))
  (setq *oid-list* (cons (cons (concat ":i" *oid-instno*) o) *oid-list*))
  (caar *oid-list*))

(defun generate-null-inst(fn place ltype)
  (let ((typelist 
	  (if (= ltype "a")
	      (get-resolvent-argtypes fn) 
              (get-resolvent-restypes fn))))
    (if (and typelist (ut_p (nth place typelist)))
	(let ((tp (oid-name(nth place typelist)))
	      (tpname (concat ":" (oid-name(nth place typelist)) '_null)))
	  (cond ((null (member tpname *nullinst-list*))
		 (formatl *mystream* "declare " tp " "tpname ";" t)
		 (formatl *mystream* "set " tpname "= nil;" t )
		 (setq *nullinst-list* (cons tpname *nullinst-list*))))
	  tpname))))

(defun unload(fn)
  (let (nrofargs txtstream1)
    (cond ((= (functiontype fn) "stored")
	   (setq nrofargs (getarity fn))
	   (setq txtstream1 (maketextstream))
	   (dolist 
	       (row (extent fn))
	     (let ((arglist (firstn nrofargs row)) 
		   (reslist (nthcdr nrofargs row))
		   *oid-list* 
                   (*oid-instno* 0))
	       (formatl txtstream1 "add " (oid-name fn))
	       (print-tuple1 "(" ")" arglist txtstream1 fn "a" t)
	       (formatl txtstream1 "=")
               (if reslist
		   (print-tuple1 "(" ")" reslist txtstream1 fn "r" t)
		 (princ "TRUE" txtstream1)) ; boolean tuple
               (formatl txtstream1 ";" t)
	       (dolist (pair *oid-list*)
		 (princ (concat "set " (car pair) " = new_object(" 
				(oid-idno (cdr pair)) ",'"
				(oid-name (arg-type (cdr pair))) "');" ) 
			*mystream* )
		 (formatl *mystream* t))
	       (formatl *mystream* (textstreamstring txtstream1) t)
               (closestream txtstream1)))))))

(defun unloadFunction- (obj fno) (unload fno))
