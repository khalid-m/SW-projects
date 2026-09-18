;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997 Tore Risch, EDSLAB
;;; $RCSfile: relation.lsp,v $
;;; $Revision: 1.14 $ $Date: 2011/12/22 15:48:10 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Basic indexed tables
;;; =============================================================
;;; $Log: relation.lsp,v $
;;; Revision 1.14  2011/12/22 15:48:10  torer
;;; Mior core reorganization
;;;
;;; Revision 1.13  2009/11/12 22:08:50  torer
;;; Smarter cost uncaching
;;;
;;; Revision 1.12  2009/11/12 20:18:36  torer
;;; Improved cost caching
;;;
;;; Revision 1.11  2007/08/28 07:52:27  torer
;;; Moved DROPFUNCTION to file relation.lsp
;;; Simplified, generalized, and corrected DROPFUNCTION
;;;
;;; Revision 1.10  2006/11/04 16:18:21  torer
;;; Systematically using GET-RESOLVENT-ARGTYPES and GET-RESOLVENT-RESTYPES
;;;
;;; Revision 1.9  2006/04/08 14:19:40  torer
;;; (GET-OC FNO) always used as accessor function for OID property ORGCODE
;;;
;;; =============================================================


(defglobal _assertrelation_ 
  (new-event '/assertrelation 'undo-assertrelation nil)
  "History event for asserting/retracting main memory table rows")

(defglobal _addindex_ (new-event '/addindex 'undo-addindex nil)
  "History event for adding index to table")

(defglobal _default-indextype_ 'hash 
  "The default kind of index on stored functions")

(defmacro relationnamed (x errflg)
  "Get table with given name"
  (list 'getobjectnamed x '_relation_ errflg))

(defun createrelation0 (name indexes permanent width)
  "Internal function to create main memory tables"
  (assert width "No WIDTH specified in relation definition")
  (let ((o (cond ((eq name '*transient*)
		  (setq permanent t)
		  (create-transient-object _relation_)
		  )  
		 (t (createobject0 _relation_ name permanent)))))
    (if permanent (putobject o 'width width)
      (/putobject o 'width width))
    (if (null indexes) (addindex0 o 0 _default-indextype_ nil permanent))
    (if indexes 
	(dolist (i indexes)
	  (addindex0 o (car i) (cadr i) (caddr i) permanent)))
    o))

(defun addindex0 (ro pos type unique permanent)
  "Internal function to add index to table"
  (let (old indx ind temp)
    (selectq unique 
	     ((t nil))
	     (amos-error "Unique tag must be T or NIL " unique)) 
    (setq indx (make-index :pos pos :owner ro :unique unique :type type))
    (buildindex ro indx)
    (cond (permanent)
	  (t (setq ind (getindex ro pos t))
	     (if ind (setq old (index-params ind)))
	     (history-add _addindex_ ro pos old (cons type unique))))
    (putobject ro 'indexes
	       (addindex1 ro (relation-indexes ro t) indx))
    (if (setq temp (getprop (index-type indx) 'index-rewriter))
        (add-rewriter ro (buildn (getobject ro 'width) '+)
		      temp))
    (cons ro pos)))

(defun index-source (ind &optional noerror)
  "The table of an index"
  (cond ((getobject ind 'source))
        (noerror nil)
        (t (error "Index has no source" ind))))

(defun index-params (indx)
  "Type and uniqueness of index"
  (cons (index-type indx)(index-unique indx)))

(defun un_pred_fn (fno)
  "Get predicate function of table"
  (if (relationp fno) (getobject fno 'predof)
    fno))

(defun getindex (ro pos &optional noerror)
  "Get index of table RO at tuple position POS"
  (cond ((dolist (i (relation-indexes ro t))
	   (if (eq (index-pos i) pos)(return i))))
	(noerror nil)
	(t (amos-error "No index for " (un_pred_fn ro) " in position " pos))))

(defun addindex1 (ro indxl indx)
  "Internal function" 
  (cond ((null indxl)(list indx))
	((= (index-pos (car indxl)) (index-pos indx))
	 (cons indx (cdr indxl)))
	(t (cons (car indxl) (addindex1 ro (cdr indxl) indx)))))

(defun dropindex0 (ro pos permanent notlast)
  "Internal function to drop index"
  (let ((index (getindex ro pos nil))
	(il (relation-indexes ro t))
	)
    (if (null index) (amos-error "No index of " (un_pred_fn ro)
				 " to drop at position " pos))
    (and notlast (null(cdr il)) (amos-error "Trying to remove last index on " 
					    (un_pred_fn ro)))
    (if (not permanent) 
	(history-add _addindex_ ro pos (index-params index) nil))
    (putobject ro 'indexes (delete index il))
    (uncache-costs ro)
    ))

(defun undo-addindex (ro pos old new)
  "Rollback of addindex"
  (if new (dropindex0 ro pos t nil))
  (if old (addindex0 ro pos (car old)(cdr old) t)))

;;; External interface

(defun createrelation (name indexes width)
  "Create table with specified indexes and name"
  (createrelation0 name indexes t width))

(defun /createrelation (name indexes width)
  "Transactionsal CREATERELATION"
  (createrelation0 name indexes nil width))

(defun addindex (rel pos indxtype unique)
  "Add index of given type, uniqueness, and tuple position"
  (addindex0 rel pos indxtype unique t))

(defun /addindex (rel pos indxtype unique) 
  "Transactional ADDINDEX"
  (addindex0 rel pos indxtype unique nil))

(defun dropindex (ro pos)
  "Drop index at tuple position"
  (dropindex0 ro pos t t))

(defun /dropindex (ro pos)
  "Transactional DROPINDEX"
  (dropindex0 ro pos nil t))

(defun relation-rows (name pat) 
  "Build list of rows in table matching PAT"
  (let (res)
    (maprelation0 (relationnamed name nil) pat 
		  (f/l(row)(setq res (cons (externalize row) res))))
    (nreverse res)))

(defun printrelation (rr)
  "Print rows in table"
  (maprelation0 (relationnamed rr nil) '* (f/l (x) (print (externalize x)))))

(defun /purgerelation (name)
  "Transactional removal of a table"
  (let ((ro (relationnamed name nil)))
    (/clearrelation ro)
    (dolist (i (relation-indexes ro nil))
      (dropindex0 ro (index-pos i) nil nil))
    (/purgeobject ro)
    name))

(defun clearrelation (rno)
  "Remove all rows from a table without logging"
  (let ((oldindexes (relation-indexes rno))) 
    (putobject rno 'indexes nil)	; remove old indexes
    (dolist (i oldindexes)		; Build new empty indexes
      (addindex0 rno (index-pos i)
		 (index-type i)
		 (index-unique i)
		 t))))

(defun /clearrelation (rno)
  "Transactional CLEARRELATION"
  (maprelation0 rno '*			; remove the rows
		(f/l (row)
		     (/retractrelation rno row))))

(defun dropfunction (fn) 
  "Clear contents of stored function without logging"
  (droprelation (delpredfunction fn)))

(defun createindex (fno id type unique &optional permanent)
  "Add index of AMOSQL function FNO, parameter ID, index type TYPE, 
   uniqueness UNIQUE. PERMANENT=T => no logging"
  (let (sb dp pos)
    (setq fno (getuniqueresolvent fno nil))
    (setq sb (getselectbody fno))
    (setq dp (selectbody-delpred sb))
    (setq pos
	  (get-function-indexpos fno id))
    (addindex0 (car dp) pos type unique permanent)
    (uncache-costs fno)
    ))

(defun get-function-indexpos (fno id)
  "Get the arg or res position of FNO identified by variable or type name ID"
  (setq fno (getuniqueresolvent fno))
  (delpredfunction fno)			; check if updatable
  (let ((dp (selectbody-delpred (getselectbody fno)))
	(i 0))
    (or (dolist
	    (p (cdr dp))
	  (if (eq id p)
	      (return i))
	  (1++ i))
	(progn
	  (setq i 0)
	  (dolist
	      (tp (append
		   (get-resolvent-argtypes fno)
		   (get-resolvent-restypes fno)))
	    (if (eq (oid-name tp) id)
		(return i))
	    (1++ i)))                                                
	(amos-error "No parameter of " fno " named " id))))

(defun get-relation (fno)
  "Get the relational table object for a stored function FNO"
  (car (isome (getobject fno 'usedbyfunction)
	      (f/l (f)(eq fno (getobject f 'predof))))))

     
   

