;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997 Tore Risch, EDSLAB
;;; $RCSfile: init.lsp,v $
;;; $Revision: 1.190 $ $Date: 2013/12/30 19:53:30 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Master Amos II init file
;;; =============================================================
;;; $Log: init.lsp,v $
;;; Revision 1.190  2013/12/30 19:53:30  torer
;;; Extended function updates with 'set'
;;; optnull() option is select clauses
;;;
;;; Revision 1.189  2013/06/03 08:55:30  torer
;;; AQIT turned on by default
;;;
;;; Revision 1.188  2013/02/19 06:02:02  thatr500
;;; Added AQIT entry into compilephase2 and disabled it
;;;
;;; Revision 1.187  2013/01/30 16:49:44  minzh812
;;; remove flag _BigIntegrator-enabled_.
;;;
;;; Revision 1.186  2013/01/24 15:32:47  torer
;;; trace removed
;;;
;;; Revision 1.185  2013/01/24 00:21:07  thatr500
;;; revert
;;;
;;; Revision 1.184  2013/01/23 23:56:00  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.183  2013/01/23 23:31:05  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.182  2013/01/09 15:11:50  thatr500
;;; Removed load-index-extension, load-special-extension. Instead,
;;; load-extension is used.
;;;
;;; Revision 1.181  2012/10/22 20:14:09  torer
;;; Foreign language (e.g. Python) code automatically loaded when saved in image
;;;
;;; Revision 1.180  2012/05/23 07:57:22  thatr500
;;; Change loading scripts to be able switch back and forth (BigIntegrator vs
;;; Matin's translator)
;;;
;;; Revision 1.179  2012/04/27 14:21:48  thatr500
;;; introduce variable _arithmetic-date_ to allow do arithmetic operations
;;; with DATE/TIMEVAL. Now, it supports only PLUS, MINUS a duration
;;;
;;; Revision 1.178  2012/03/31 18:44:49  thatr500
;;; supports Plus / Minus with Date and Timeval datatype
;;;
;;; Revision 1.177  2012/03/30 11:40:00  thatr500
;;; added numerical wrapper for SQL. Enable by setting environment variable
;;; 'numwrapper'
;;;
;;; Revision 1.176  2012/03/21 10:42:37  minzh812
;;; don't load translator.lsp and capability related when BigIntegrator is ON.
;;;
;;; Revision 1.175  2012/03/19 13:33:45  minzh812
;;; introduce _BigIntegrator-enabled_
;;;
;;; Revision 1.174  2012/02/22 09:25:12  torer
;;; No program database in released version
;;;
;;; Revision 1.173  2012/01/18 10:40:36  thatr500
;;; lookup shared objects in LD_LIBRARY_PATH when it is set
;;;
;;; Revision 1.172  2012/01/16 10:05:28  torer
;;; Now possible to have image without Lisp source code
;;;
;;; Revision 1.171  2012/01/13 21:19:23  thatr500
;;; *** empty log message ***
;;;
;;; Revision 1.170  2012/01/12 13:03:36  thatr500
;;; Enable AQIT when MEXI is set
;;;
;;; Revision 1.169  2011/12/22 13:55:36  torer
;;; Removed duplicated code
;;;
;;; Revision 1.168  2011/12/22 12:55:16  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.167  2011/12/20 21:11:39  thatr500
;;; removed _exinma-enabled_
;;;
;;; Revision 1.166  2011/05/02 12:04:45  torer
;;; New function (SET-WATERMARK) to set system watermark
;;;
;;; Revision 1.165  2011/01/20 18:29:01  torer
;;; 1. bag variables can be bound to values of bag valued functions
;;; 2. The 'set f(..)=... ' now updates correctly
;;;
;;; Revision 1.164  2011/01/14 09:42:17  thatr500
;;; Enable EXINMA
;;;
;;; Revision 1.163  2011/01/02 15:32:14  torer
;;; No Lisp code validation by installer
;;;
;;; Revision 1.162  2010/12/31 06:54:46  torer
;;; Types in SQL wrapper must be consistent before SQL parser loaded
;;;
;;; Revision 1.161  2010/12/30 13:20:22  torer
;;; loading sql parser too
;;;
;;; Revision 1.160  2010/12/30 12:56:38  torer
;;; Code validated when loaded
;;;
;;; Revision 1.159  2010/12/14 19:07:54  thatr500
;;; adding a global flag _exinma-enabled_ to turn ON/OFF Exinma (including xtree)
;;;
;;; Revision 1.158  2010/12/14 14:20:01  torer
;;; disabled xtrees
;;;
;;; Revision 1.157  2010/12/11 16:18:04  torer
;;; Logging off during boostrap
;;;
;;; Revision 1.156  2010/12/03 15:10:25  thatr500
;;; change load order for exstma
;;;
;;; Revision 1.155  2010/12/01 19:24:35  thatr500
;;; add External Storage Manager
;;;
;;; Revision 1.154  2010/11/22 09:04:37  thatr500
;;; change order to load Xtree functions
;;;
;;; Revision 1.153  2010/08/22 16:51:27  thtr1663
;;; add xtree to amoslib
;;;
;;; Revision 1.152  2009/09/04 18:43:40  torer
;;; ECA rules removed
;;;
;;; Revision 1.151  2009/05/05 18:57:04  torer
;;; Better documentation
;;;
;;; Revision 1.150  2007/11/07 15:14:45  torer
;;; Amos II version 10 with faster basic OjectLog interface to C
;;; Aggregation operators can now be defined in C
;;;
;;; Revision 1.149  2007/10/24 20:20:22  torer
;;; Definition of full Amos II system
;;;
;;; Revision 1.147  2007/10/08 09:26:39  silvias
;;; OID_NR now invertible
;;;
;;; Revision 1.146  2007/08/27 19:19:11  torer
;;; Multicasting with result stream merging
;;;
;;; Revision 1.145  2007/05/25 17:52:38  torer
;;; Problem with changed include file and messed up project
;;;
;;; Revision 1.142  2006/12/14 18:20:28  torer
;;; Moved all code to define type STREM to stream.lsp
;;; Moved all code to define type VECTOR to vector.lsp
;;;
;;; Revision 1.141  2006/12/14 16:43:54  torer
;;; 1. Basic functions on type VECTOR into file lsp/vector.lsp
;;; 2. Comparisons on vectors element by element
;;;
;;; Revision 1.135  2006/08/01 12:43:38  torer
;;; Added loading of URI.amosql
;;;
;;; Revision 1.134  2006/04/13 07:30:18  torer
;;; New function enable_mdb(); sets all necessary flags for using MDB
;;;
;;; =============================================================

(load "amosdef.lsp");; Amos II fully runnable system 

(load "multicast.lsp")

(if _eca-enabled_ (load "eca_rules.lsp"))

(osql "
create function enable_mdb()->Boolean as foreign 'ENABLE-MDB';")

; wrapper definition API
(print "disable translator.lsp")


(init-ds-subsystem)

(print "BigIntegrator is enabled")
(with-directory "../BigIntegrator/src/AmosQL/"
		(load-amosql "master.amosql"))

; wrappers

(load "../wrappers/load_wrappers.lsp")
;;; Need to load ODBC wrapper here.Now removed!
;;; (if (getenv "odbc_wrapper")(load "../wrappers/odbc/load_wrapper.lsp"))

; Aliases for SQL-99 compatibility:

(setf (gethash 'character _symbtab_)(gethash 'charstring _symbtab_))
(setf (gethash 'char _symbtab_)(gethash 'charstring _symbtab_))

(check-functions) 

(with-directory "../SQL" ;; SQL parser
   (load "project/init.lsp"))

(cond (_mexima-enabled_       
       (with-directory "../system/C/mexima/lsp/" 
		       (load "mex-utilities.lsp")
		       (load "mex-amos-interfaces.lsp")
		       (load "mex-relation-save-restore.lsp"))
       ;; AQIT algorithm
       (with-directory "../aqit/lsp/" (load  "boot-aqit.lsp"))
       (if (load-extension "xt" t)
	   (with-directory "../system/C/mexima/lsp/" 
			   (load "mexima.lsp")))

       (setq *enable-aqit* t)))

(load "extract-sql.lsp")
(load "temporal-plus.lsp")


;;; Compile functions that are marked for recompilation 
;;; BEFORE setting watermark and saving image:
(check-functions) 
(load "optnull.lsp");; Patch for now
(set-watermark)
(setq *verify-immediate* t "Is Lisp code verification on?")
(register-init-form '(disable-all-foreign-languages) 'first)
(setq _histflg_ t)

