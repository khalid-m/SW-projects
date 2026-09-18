;;; ===========================================================================
;;; AMOS2 - GSDM project
;;; 
;;; Author: (c) 2004 Milena Ivanova, UDBL
;;; $RCSfile: statsrv.lsp,v $
;;; $Revision: 1.1 $ $Date: 2004/09/27 11:49:58 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Functionality of GSDM statistical server
;;;              Generator of operations and streams ids
;;;              Reporting statistics
;;; ===========================================================================

;;; Generator for operation id
(defvar *genopid* 0)
(defun genopid () (pack 'Q (setq *genopid* (1+ *genopid*))))

(defun next_opid (fnobj qid)
	(osql-result (mkstring (genopid))))

;;; Generator for stream id
(defvar *gensid* 0)
(defun gensid () (pack 'S (setq *gensid* (1+ *gensid*))))

(defun next_sid (fnobj qid)
	(osql-result (mkstring (gensid))))

(defun report-stat (l)
 "From list l of stat data from a working node generates objects and
sets functions in AmosQL representing this data. The list has form of
(wnid ((box1id (cnt first last) time) ...)  ((str1id (cnt first
last))...))"


(let (g op st stl
	s )
  (setq g (createobject (gettypenamed 'gsdm)))
  (setfunction 'id (list g) (list (mkstring (car l))))

  (dolist (opl (second l)) ; list for 1 op
    (setq op (createobject (gettypenamed 'operation)))
    (setfunction 'time (list op) (last opl))

    (setq stl (second opl)) ; create stat object and set fns
    (setq st (createobject (gettypenamed 'stat)))
    (setfunction 'count (list st) (list (car stl)))
    (setfunction 'first (list st) (list (second stl)))
    (setfunction 'last (list st) (list (third stl)))

    (setfunction 'stat (list op) (list st)) ;set op fns
    (setfunction 'id (list op) (list (mkstring (genopid))))
    (setfunction 'lid (list op) (list (mkstring (car opl))))
    (setfunction 'installed_at (list op) (list g))
    )

   (dolist (sl (third l)) ; list for 1 stream
    (setq s (createobject (gettypenamed 'mstream)))
   
    (setq stl (second sl)) ; create stat object and set fns
    (setq st (createobject (gettypenamed 'stat)))
    (setfunction 'count (list st) (list (car stl)))
    (setfunction 'first (list st) (list (second stl)))
    (setfunction 'last (list st) (list (third stl)))

    (setfunction 'stat (list s) (list st)) ;set stream fns
    (setfunction 'id (list s) (list (mkstring (gensid))))
    (setfunction 'lname (list s) (list (mkstring (car sl))))
    (setfunction 'installed_at (list s) (list g))
    )

))


(setq l
(WN100 
((Q1 (10 #[TIMEVAL 1096219915 529000] #[TIMEVAL 1096219922 333000]) 1.234)
 (Q2 (100 #[TIMEVAL 1096219915 529000] #[TIMEVAL 1096219937 333000]) 11.234)) 
((P1 (10 #[TIMEVAL 1096219915 129000] #[TIMEVAL 1096219925 133000]))
 (P2 (100 #[TIMEVAL 1096219915 129000] #[TIMEVAL 1096219942 133000]))) 
)
)