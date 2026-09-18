;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Tore Risch, UDBL
;;; $RCSfile: remoteeval.lsp,v $
;;; $Revision: 1.9 $ $Date: 2013/10/27 18:43:56 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Testing bare bone remote evaluation
;;; =============================================================
;;; $Log: remoteeval.lsp,v $
;;; Revision 1.9  2013/10/27 18:43:56  torer
;;; opensocket retries now work under OSX too
;;;
;;; Revision 1.8  2013/08/07 16:43:08  torer
;;; *** empty log message ***
;;;
;;; Revision 1.7  2013/08/07 16:36:12  torer
;;; Measuring SOCKET-EVAL setup time
;;;
;;; Revision 1.6  2013/07/29 18:46:39  torer
;;; Added (sleep 0.1) to wait for nameserver to start
;;;
;;; Revision 1.5  2012/10/05 06:50:22  torer
;;; Timing error when shutting down nameserver
;;;
;;; Revision 1.4  2012/06/28 20:00:31  torer
;;; Global variables EXPORTTO and IMPORTFROM removed
;;; New stream headers in C
;;;
;;; Revision 1.3  2012/06/26 17:40:40  torer
;;; OS independent regression
;;;
;;; Revision 1.2  2012/06/22 13:38:00  torer
;;; Client server callin interface completely in terms of bare bone
;;; socket client interface
;;;
;;; Revision 1.1  2012/06/20 18:44:54  torer
;;; Testing bare bone remote evaluation
;;;
;;; =============================================================

(start-program "amos2" "-n") ;; start nameserver

(start-program "amos2" "-s a") ;; start peer named A

(start-program "amos2" "-s b") ;; start peer named B

(wait-until-started '(a b))

(defglobal _sa_ (open-socket-to 'a)) ;; Open socket to server A

(defglobal _sb_ (open-socket-to 'b)) ;; Open socket to server A


(checkequal 
 "Basic remote evaluation"
 ((socket-eval '(+ 1 2) _sa_)
  ;; remote evaluate on peer A
  3)

 ((socket-call _sb_ '+ (- 1 2) 3) 
  ;; remote function call to + 
  2)

 ((socket-send '(setq a 45) _sa_)
  ;; send for evaluation without waiting
  _sa_)

 ((socket-eval 'a _sa_) 
  ;; Pick up shipped setting 
  45)

 ((errstring (socket-eval 123 t)) 
  ;; Error caught in client
  "Not a socket")
 
 ((errstring (socket-eval '(+ 1 b) _sa_))
  ;; Error shipped from server to client
  "Unbound variable")

 ((socket-eval '_object_ _sa_) 
  ;; Test that local proxy for _object_ in A is unique
  (socket-eval '_object_ _sa_))
 
 ((socket-send '(setq _o_ (createobject _object_)) _sa_)
  ;; Create new object in A
  _sa_)
 
 ((socket-send '(setq _p_ (createobject _object_)) _sb_)
  ;; Create new object _p_ in B with same OID number as _o_ in A 
  _sb_)

 ((eq (socket-eval '_o_ _sa_) (socket-eval '_p_ _sb_)) 
  ;; _o_ in A is not same object as _p_ in B
  nil)

 ((socket-eval '(socket-eval '_o_ (open-socket-to 'a)) _sb_)
  (socket-eval '_o_ _sa_)))


(checkequal "100 dummy Lisp calls"
	    ((time (rptq 100 (socket-eval '(identity 1) _sa_))) 1)
	    )

(checkequal "Killing servers"
	    ((socket-send '(quit) _sa_)
	     ;; Kill server A 
	     _sa_)
  
	    ((socket-send '(quit) _sb_)
	     ;; Kill server B
	     _sb_)
  
	    ((close-socket _sa_) 
	     ;; Close socket to A
	     _sa_)

	    ((close-socket _sb_) 
	     ;; Close socket to B
	     _sb_))


(socket-send '(quit) (open-nameserver-socket)) ;; kill nameserver
(sleep 0.5) ;; Make sure message sent
(quit) ;; Kill me
