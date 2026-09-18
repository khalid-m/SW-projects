;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2013 Tore Risch, UDBL
;;; $RCSfile: systime.lsp,v $
;;; $Revision: 1.2 $ $Date: 2013/05/17 06:53:07 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: System time stamps testing
;;; =============================================================
;;; $Log: systime.lsp,v $
;;; Revision 1.2  2013/05/17 06:53:07  torer
;;; C interface to systime package.
;;; Changed name of SET-ENTER-SYSTIME to SET-SYSTIME
;;;
;;; Revision 1.1  2013/05/16 20:02:11  torer
;;; Propagation of enter systen times for events added
;;;
;;; =============================================================

(defglobal _s_ (maketextstream))
(defglobal _this-time_)
(defglobal _enter-time_)
(set-systime nil) ;; clear for reentrant test

(systimestream _s_ t) ; Enter system time stamps printed on stream

(print 12 _s_)
(sleep 0.001)
(print 13 _s_)
(sleep 0.001)
(textstreampos _s_ 0)

(checkequal 
    "Event system time stamps"
   ((enter-systime) nil); not set
   ((this-systime) nil) ; not set
   ((read _s_) 12)
   ((compare (setq _enter-time_ (enter-systime))
             (setq _this-time_ (this-systime))) -1);; enter systime before this
   ((sleep 0.001) 0.001)
   ((read _s_) 13)
   ((compare _enter-time_ (enter-systime)) -1) ;; new enter systime
   ((compare (enter-systime)(this-systime)) -1);; enter before this
   ((compare (enter-systime) _this-time_) -1);; entered before previous this
   ((compare _this-time_ (this-systime)) -1);; previous earlier than this
)
