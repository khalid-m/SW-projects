;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997 , EDSLAB
;;; $RCSfile: mdbqueries.lsp,v $
;;; $Revision: 1.4 $ $Date: 2005/09/14 18:38:50 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;; =============================================================


;;; =============================================================
;;; General comments:
;;; flattenfuncall has ben modified to include a call to 
;;; flattenremotequery.
;;; =============================================================

;;; =============================================================
;;; Misc. Section
;;; =============================================================

(defglobal _fnname_ 0)
(defun generate-unique-fnname (site)
  "Generates unique function names."
   (pack (gethostname) "-" site (1++ _fnname_)))
 

;;; =============================================================
;;; Functions creating client and server subquery functions
;;; =============================================================

(defun construct-result-type (arity)
  "Given an integer ARITY, returns a list ((OBJECT) ...) 
   where (OBJECT) occurs ARITY times."
  (let ((decl-lst nil))
    (rptq arity
	  (push '(object) decl-lst))))

(defun create-server-selectfn (fnname argtypes resv quant pred)
  "Creates a function at the sever that corresponds to a remote
   subquery at the client."
  ;;We have to find out the result width. We compile the query as select
  ;;statement to find this out. This is inefficent as we then compile the
  ;;query again below in the createfunction call.
  (generate-select resv (append argtypes quant) pred)
  (let* ((res-arity (length 
		     (selectbody-resl 
		      (getobject _select_ 'selectbody))))
	 (fno (createfunction 
	      fnname argtypes 
	      (construct-result-type res-arity)
	      resv
	      quant pred)))
    ;;Return the result arity as it is not known at the client
    res-arity))

(defun build-remote-form (fnname &rest args)
  "Utility function used by the foreign lisp function created by
   CREATE-CLIENT-FUNCTION. FNNAME should be an atom and ARGS a
   list of argument values."
  (list 'within-lisp	
	(list 'osql-select
	      (list (cons fnname args)))))

(defun create-client-function (site remote-fnname argtypes result-arity)
  "This function creates a foreign lisp function that corresponds to a 
   remote query. The function created will be substitued for the remote
   query form. This is done by flattenfuncall."
  (flet ((get-arg-vars (decl-lst)
		       (let ((vars nil))
			 (dolist (decl decl-lst)
				 (push (second decl) vars))
			 (reverse vars)))
	 )
	(let ((local-fnname (generate-unique-fnname site))
					;Get a name for the client side
					;function.
	      (args (get-arg-vars argtypes))
	      )
	  (eval
	   (bquote
	    (foreign-lispfn
	     , local-fnname
	     , argtypes 
	     , (construct-result-type result-arity)
	     (let ((answer
					;Will hold the answer
		    (remote-eval
		     (build-remote-form (quote , remote-fnname) ,@ args)
		     , site)))
	       (dolist (tup answer)
		       (apply (function osql-result)
			      (append (list ,@ args)
				      tup)))))))
	  (getfunctionnamed local-fnname))))

(defun create-remote-selectfn (site argtypes resv quant pred)
   "Tries to compile a select on site SITE. If successful an function object is
returned. The function will have ARGTYPES arguments and RESV results.
At the moment the results will be of type OBJECT."
   
   (let* ((fnname (generate-unique-fnname site))
          ;Generate a function name universally
          ;unique
          (result-arity
            ;The width of the result
            (remote-eval 
             (list 'create-server-selectfn (kwote fnname)
               (kwote argtypes)
               (kwote resv)
               (kwote quant)
               (kwote pred))
             site))
          )
      
      ;;Now we have a remote function named REMOTE-FNNAME at SITE that
      ;;executes the remote part of the queriy for us. Now create a local
      ;;function that calls the remote function.
      
      ;;Assign cost to the local function!!
      
      (create-client-function site fnname argtypes result-arity)))

(defmacro remote-query (&rest xpr)
  ;;Top loop remote query
  (bquote (osql-select ((remote-query ,@ xpr)))))

;;; =============================================================
;;; Remote Query Compilation Section
;;; =============================================================

(defvar _simple-types_ (list (gettypenamed 'number)
			     (gettypenamed 'integer)
			     (gettypenamed 'real)
			     (gettypenamed 'boolean)
			     (gettypenamed 'charstring)))
(defun simple-type? (tp)
  (member tp _simple-types_))

(defun convert-types (dcl-lst)
  "Converts (typeobject variable)-pairs to (typename variabel)-pairs."
  ;;dcl-lst is a list of (type variable)-pairs
  (mapcar (f/l (decl)
	       (if (not (simple-type? (first decl)))
		   (amos-error
		    "Remote query using free variables of complex type:"
		    decl)
		 (list (oid-name (first decl)) (second decl))))
	  dcl-lst))

(defun flattenremotequery (xpr)
  "XPR = (REMOTE-QUERY db OSQL-SELECT res FOREACH vars WHERE cond"
  (let ((fv nil)			;Free variable declaration list
	(rfno nil)			;Remote function object
	(resolvent nil) 
	(sb nil)			;Selectbody of RFNO
	)
    (apply
     (f/l (distinct resl into quant pred)
	  (setq fv 
		(dclfreevars resl pred *bindings*))
	  (setq fv (convert-types fv))
	  
	  (setq rfno
		;;Create a function on the server. OK? if not ERROR!
		(create-remote-selectfn
		 (second xpr)		;Site
		 fv			;Arguments
		 resl
		 quant
		 pred))
	  )
     (parseselect 
      (cdddr xpr)			;Drop REMOTE-QUERY db OSQL-SELECT
      '(foreach where)))

    ;;Build the result of the flattening
    (setq resolvent (car (resolvents rfno)))
					;There should be only ONE resolvent
					;since we created a uniqely named
					;function.
    (setq sb (getobject resolvent 'selectbody))
    (cons resolvent (selectbody-argl sb))
    ))
