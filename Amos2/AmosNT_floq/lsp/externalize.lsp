;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2007 Tore Risch, UDBL
;;; $RCSfile: externalize.lsp,v $
;;; $Revision: 1.2 $ $Date: 2007/12/19 21:24:49 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Encoding Amos II code for shipping
;;; =============================================================
;;; $Log: externalize.lsp,v $
;;; Revision 1.2  2007/12/19 21:24:49  torer
;;; External function representation uniformed
;;;
;;; =============================================================

(defun externalize-fndef (fno)
  "Externalize definition of FNO into shippable format"
  (if (transientp fno) (cons '*lambda* (externalize-code (get-oc fno)))
    (list* '*function* (generic-fnname fno)
	   (externalize-code (get-oc fno)))))

(defun externalize-code (x)
  "Externalize expression X"
  (cond ((oid-p x) (cond ((function-p x) (externalize-fno x))
			 ((type-p x) (externalize-tpo x))
			 (t;; This can be relaxed!
			  (error "OID cannot be externalized" x))))
	((osql-constantp x) x)
	((arrayp x) 
	 (listtoarray (mapcar (function externalize-code) 
			      (arraytolist x))))
	((consp x) (cons (externalize-code (car x))
			 (externalize-code (cdr x))))
        ((symbolp x) x)
        (t (error (concat "Cannot externalize ALisp objects of type" 
			  (typename x)) x))))


(defun function-p (o)
  "True if O is an Amos II function"
  (and (oid-p o)(memq _function_ (oid-types o))))

(defun type-p (o)
  "True if O is an Amos II type" 
  (and (oid-p o)(memq _type_ (oid-types o))))

(defun externalize-fno (fno)
  "Externalize function object FNO"
  (cond ((transientp fno) (externalize-fndef fno))
        (t (list '*function* (oid-name fno)))))

(defun externalize-tpo (tpo)
  "Externalize type object TPO"
  (list '*type* (decode-type tpo)))

(defun internalize-code (x)
  "Internalize externalized expression X"
  (cond ((atom x) x)
        ((osql-constantp x) x)
        (t (selectq (car x)
		    (*lambda* (eval (list* 'create-function '*transient*  
					   (internalize-code (cdr x)))))
		    (*type* (encode-type (second x)))
		    (*function* (cond ((cddr x);; Function definition
                                       (eval (cons 'create-function
						   (internalize-code (cdr x)))))
                                      (t (getfunctionnamed (second x)))))
		    (cons (internalize-code (car x))
			  (internalize-code (cdr x)))))))
