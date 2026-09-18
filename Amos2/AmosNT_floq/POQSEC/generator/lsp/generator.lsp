;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2005 Ruslan Fomkin, UDBL
;;; $RCSfile: generator.lsp,v $
;;; $Revision: 1.2 $ $Date: 2005/03/10 09:09:45 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: 
;;;  Lisp code which neccessary for implementing generator in amosql.
;;;              
;;; ===========================================================================

(foreign-lispfn printfile((object o))() 
		(princ o *mystream*) (foreign-result))

(foreign-lispfn tosystem((charstring command))()
				(system command) (foreign-result))
