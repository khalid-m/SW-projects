;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: apply_remote.lsp,v $
;;; $Revision: 1.1 $ $Date: 2003/09/08 13:04:41 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: The function apply_remote which calls a function on another
;;;              Amos node with the possibility to add any number of arguments
;;;               on top of the explicit arguments. Explicit arguments are: 
;;;                amosds  - the datasource representing the Amos norde
;;;                fnproxy - the locally proxified function object
;;;              If the 'implicit' arguemnts are mapped types imported from the
;;;              other Amos, or if they are proxies from the same node, they
;;;              will automatically be 'deproxified' in the local call on the
;;;              other side.
;;;              
;;; ===========================================================================

(defvar _apply_remote_
 (getfunctionnamed 'AMOS.OPAQUE_PROXY.APPLY_REMOTE->OBJECT))

(putobject 
 _apply_remote_ 'bindings '(#(TBR *any* NIL APPLY_REMOTE--* NIL NIL)))

(defun apply_remote--* (fno amosds fnproxy &rest all-arguments)
  (let ((inarity (getobject fnproxy 'inarity))
	inputargs)
    (if (eq nil inarity)
	(setq inarity
	      (/putobject fnproxy 'inarity (get-remote-fn-inarity-request amosds fnproxy))))
    (setq inputargs (firstn inarity all-arguments))
    (if (some #'anonymous-varsymbolp inputargs)
	(error "Remote function can only run forwards" fnproxy))
    (dolist (result (apply-remote-fn-request amosds fnproxy inputargs))
      (apply #'osql-result `(, amosds , fnproxy ,@ inputargs ,@ result)))))

(defun get-remote-fn-inarity-request (amosds fnproxy)
  "Returns the number of input arguments (free) of a function which is 
   proxified and defined at the Amos node amosds."
  (let ((peer (oid-name amosds))
	(xoidno (getobject fnproxy 'xoidno)))
    (remote-eval `(get-remote-fn-inarity-response , xoidno) peer)))

(defun get-remote-fn-inarity-response (fnoidno)
  "Returns the number of input arguments (free) of a locally stored function 
   as a response to a request from another Amos node."
  (length (get-resolvent-argtypes (getobjectnumbered fnoidno))))

(defun apply-remote-fn-request (amosds fnproxy args)
  "amosds - the amos node
   fnproxy - the proxy object for the remote function
   args - list of arguments. If the argument is a proxy belonging to the node
           amosds, it is marked as proxy and fetched by the the node amosds"
  (let ((peer     (oid-name amosds))
	(fnoidno (getobject fnproxy 'xoidno))
	deproxifiedarglist)
    (dolist (argsym args)
      (putlast deproxifiedarglist (make-deproxification-form argsym peer)))
    (remote-eval `(apply-remote-fn-response , fnoidno , (kwote deproxifiedarglist)) peer)))

(defun apply-remote-fn-response (fnoidno argform)
  "Calls a function as a response from another amos with arguments argform.
   If any arguments is a list of '(proxy n) then the object numbered n will be
   fetched and used as argument, otherwise the argument alone will suffice."
  (let ((arglist (mapcar #'fetch-proxified-argument argform)))
    (getfunction (getobjectnumbered fnoidno) arglist)))

(defun make-deproxification-form (arg peer)
  "When a function is declared to take a mapped type as agument, for instance
   foo(person@ds1 p)->integer, the function foo will be split in two parts
   where one part will be compiled on the node ds1 and the other will be 
   locally compiled with a call to apply_remote(ds1, proxy, p') where proxy is
   the proxy object for the remotely compiled subquery and p' is *the actual 
   object on the node*. Now this is a problem: how to call a remote function 
   with an argument only present on the remote node.
   There are three scenarios:
   1) the argument is a primitive type present on both nodes.
   2) the argument is proxified, this happens if the object has been directly
      requested on a low-level.
   3) the argument is a mapped type in this node.

   The solution here is based on the assumption that the object is persistent
   on the node that we are calling. In case 1 nothing needs to be done. In 
   case 2 we can get the original number by looking at the xoidno property. In 
   case 3 we can look at the encodes property of the mapped type an we will get
   the same object as in 2 and can proceed from there on."
  (cond ((and (eq (arg-type arg) _proxy_) (eq (getobject arg 'exportto) peer))
	 `(proxy , (getobject arg 'xoidno)))
	; double type-checking gives us the metatype 
	((eq (arg-type (arg-type arg)) _mappedtype_)
	 `(proxy , (getobject (getobject arg 'encodes) 'xoidno)))
	(t
	 arg)))

(defun fetch-proxified-argument (arg)
  "Arguments that were proxies in a call to apply_remote were represented by a
   list consisting of (proxy n) where n is the number of the OID in the node 
   where the function is executed. This function fetches that object and 
   substitutes it in the local function call."
  (if (and (listp arg) (eq (first arg) 'proxy) (numberp (second arg)))
      (getobjectnumbered (second arg))
    arg))