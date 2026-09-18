;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2005 Tore Risch, UDBL
;;; $RCSfile: readtest.lsp,v $
;;; $Revision: 1.2 $ $Date: 2006/02/03 19:30:28 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Measuring speed of reading/writing S-expressions
;;;              
;;; ===========================================================================

;;; NOTICE: Environment variable AMOS_NT must be set first!
;;;
;;; Run complete test with:             (readtest-all)
;;; Reading from disk:                  (fileread-test)
;;; Setting up main memory tests:       (readtest-init)
;;; S-expression reader only:           (reader-test)
;;; Reading, printing, allocating, GBC: (readerprint-test)

(defun readtest-all (n)
  (dotimes (i (or n 1))
    (fileread-test);; First time cold file cache
    (if (= i 0)(readtest-init));; Load files into main memory once
    (reader-test)
    (readerprint-test)
    ))

(defun readfilex (file)
  ;; Reads S-expressions in file and returns file its size
  (with-input-file str (fullname file)
		   (while (neq (read str) '*eof*)))
  (file-length (fullname file)))

(defun fullname (file)
  (concat (or (getenv "AMOS_HOME") 
	      (error "Set environment variable AMOS_HOME first!"))
	  "/lsp/" file))

;;; These are all files in $AMOS_HOME/lsp:
(defglobal _files_ '
("abstract-function.lsp"
"advise.lsp"
"amosdef.lsp"
"amosfns.lsp"
"arginfo.lsp"
"basicoid.lsp"
"TBR.lsp"
"DTR.lsp"
"boot.lsp"
"bulk.lsp"
"capability.lsp"
"checkequal.lsp"
"coerce.lsp"
"collections.lsp"
"comm.lsp"
"compl.lsp"
"comppred.lsp"
"constructor.lsp"
"contexts.lsp"
"createuobj.lsp"
"ctrlt.lsp"
"cursor.lsp"
"datasource.lsp"
"declarations.lsp"
"deletion.lsp"
"delta_sets.lsp"
"dt.lsp"
"dtcreate.lsp"
"dynprog.lsp"
"eca_rules.lsp"
"emacs_edit.lsp"
"environment.lsp"
"error.lsp"
"etemplates.lsp"
"event_manager.lsp"
"flatten.lsp"
"fncall.lsp"
"franzinit.lsp"
"franzload.lsp"
"function.lsp"
"gensql.lsp"
"gnuserv.lsp"
"graph.lsp"
"init.lsp"
"latebind.lsp"
"mapped.lsp"
"matbags.lsp"
"mbindex.lsp"
"mdbqueries.lsp"
"misc.lsp"
"new_object.lsp"
"normalize.lsp"
"optimizer.lsp"
"orginit.lsp"
"osql-let.lsp"
"plot.lsp"
"ppr.lsp"
"predicate_functions.lsp"
"printer.lsp"
"priority-queue.lsp"
"proc.lsp"
"profile.lsp"
"purge.lsp"
"qd.lsp"
"qd_cost.lsp"
"qd_deftmpfunc.lsp"
"qd_disp.lsp"
"qd_dsve.lsp"
"qd_dynprog.lsp"
"qd_entry.lsp"
"qd_heuristic.lsp"
"qd_misc.lsp"
"qd_objectloggen.lsp"
"qd_print.lsp"
"qd_treedistr.lsp"
"queues.lsp"
"randomopt.lsp"
"ref_lisp.lsp"
"relation.lsp"
"rewrite.lsp"
"rules.lsp"
"rules_network.lsp"
"rule_compiler.lsp"
"rule_processor.lsp"
"sagas.lsp"
"seqinit.lsp"
"sort.lsp"
"tclose.lsp"
"temporal.lsp"
"trace.lsp"
"translator.lsp"
"typecheck.lsp"
"typeimp.lsp"
"unload.lsp"
"updates.lsp"
"utils.lsp"
"variable.lsp"
"verify.lsp"
"verify_code.lsp"
))

(defun fileread-test ()
  ;; Measure speed to read S-expressions from disk files
  (let ((sz 0)(tm (clock)))
    (dolist (file _files_)
      (setq sz (+ sz (readfilex file))))
    (setq tm (- (clock) tm))
    (formatl t "Read S-expressions from file: " (/ sz (* 1000000 tm))
	     " MBytes/s" t)))

(defglobal _all-files-cont_ (opentextstream))
(defglobal _print-buff_ (opentextstream 1000))

(defun readtest-init()
  ;; Read all files into main memory text stream
  (dolist (f _files_)
    (princ (read-file (fullname f)) _all-files-cont_)
    (terpri _all-files-cont_)))

(defun reader-test()
  ;; Measure speed of S-expression reader, 
  ;; including memory allocation and GBC of read objects
  ;; Requires (readtest-init) first!
  (let ((cl (clock)))
    (closestream _all-files-cont_)	; rewinds text stream
    (while (neq (read _all-files-cont_) '*eof*))
    (setq cl (- (clock) cl))
    (formatl t "Read S-expressions from main memory: "
	     (/ (length (textstreamstring _all-files-cont_)) (* cl 1000000))
	     " MBytes/s" t)))

(defun readerprint-test()
  ;; Measure total time to read, allocate, print, and GBC S-expressions
  (let ((cl (clock)))
    (closestream _all-files-cont_)
    (while (neq (princ (read _all-files-cont_) _print-buff_) '*eof*)
      (closestream _print-buff_))
    (setq cl (- (clock) cl))
    (formatl t "Read/print S-expressions from main memory: "
	     (/ (length (textstreamstring _all-files-cont_)) (* cl 1000000))
	     " MBytes/s" t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Speed on IBM X40, 1.2 GHz:
;;;
;;; Borland C++ compiler (Best of 2 runs of (READTEST-ALL 4)):
;;; Read S-expressions from file: 4.13 MBytes/s (warm)
;;; Read S-expressions from main memory: 12.54 MBytes/s 
;;;    -"-   (new reader)                21.3 MBytes/s
;;; Read/print S-expressions from main memory: 10.94 MBytes/s 
;;;    -"-   (new reader)                      17.21 MBytes/s
;;;
;;; MicroSoft Visual C++ compiler (Best of 2 runs of (READTEST-ALL 4)):
;;; Read S-expressions from file: 1.91 MBytes/s (warm)
;;;   -"-  (new reader)           2.96 MBytes/s
;;; Read S-expressions from main memory: 17.53 MBytes/s
;;;   -"-  (new reader)                  28.56 MBytes/s
;;; Read/print S-expressions from main memory: 14.55 MBytes/s
;;;   -"-  (new reader)                        21.65 Mbytes/s
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Speed on Hagrid (Linux gcc) (Best of 2 runs of (READTEST-ALL 4)):
;;; Read S-expressions from file: 1.86 MBytes/s (cold)
;;; Read S-expressions from file: 3.72 MBytes/s (warm)
;;; Read S-expressions from main memory: 22.65 MBytes/s
;;; Read/print S-expressions from main memory: 17.76 MBytes/s
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
