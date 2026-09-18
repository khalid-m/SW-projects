;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1998-2006 Tore Risch, EDSLAB, UDBL
;;; $RCSfile: coredef.lsp,v $
;;; $Revision: 1.38 $ $Date: 2013/12/30 13:35:54 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Core Amos II system definition 
;;; =============================================================
;;; $Log: coredef.lsp,v $
;;; Revision 1.38  2013/12/30 13:35:54  torer
;;; Better support for tuples
;;;
;;; Revision 1.37  2013/10/27 16:29:20  torer
;;; New Lisp function (GET-MY-IP)
;;; New Amos function get_my_ip()
;;;
;;; Revision 1.36  2013/05/01 15:23:14  minzh812
;;; load bigintegrator code up
;;;
;;; Revision 1.35  2013/01/30 16:49:44  minzh812
;;; remove flag _BigIntegrator-enabled_.
;;;
;;; Revision 1.34  2012/06/27 09:24:21  larme597
;;; New server functions.
;;;
;;; Revision 1.33  2012/06/18 19:27:35  torer
;;; Removed from aclient.lsp what is now in remote_scan.lsp
;;;
;;; Revision 1.32  2012/03/19 13:33:45  minzh812
;;; introduce _BigIntegrator-enabled_
;;;
;;; Revision 1.31  2012/02/24 11:37:31  torer
;;; More on-line documentation
;;;
;;; Revision 1.30  2012/01/28 10:34:48  torer
;;; olog utilities added
;;;
;;; Revision 1.29  2011/12/22 12:55:15  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.28  2011/12/17 16:24:22  torer
;;; Moved some declarations here
;;;
;;; Revision 1.27  2011/12/14 20:04:32  torer
;;; Moved here global variables _charstring_, _integer_, _real_
;;;
;;; Revision 1.26  2011/11/19 14:06:54  torer
;;; Choice between loading extensions transistently or persistently
;;;
;;; Revision 1.25  2011/11/18 18:13:54  torer
;;; Code validation turned on in alisp
;;;
;;; Revision 1.24  2011/01/26 20:54:49  torer
;;; New cursor mechanism using scans
;;;
;;; Revision 1.23  2011/01/09 16:43:48  torer
;;; Function 'in' now overloaded on only basic collection types
;;; (i.e. bag, vector, stream), not on all combinations of collection
;;; type constructor types as before.
;;; Instead 'in' uses type inference to determine result types
;;;
;;; Revision 1.22  2010/12/29 20:43:57  torer
;;; Removed javainterface.lsp
;;;
;;; Revision 1.21  2010/12/29 20:25:56  torer
;;; Include foreign.lsp in system
;;;
;;; Revision 1.20  2010/09/10 14:34:34  larme597
;;; Adding remote scans.
;;;
;;; Revision 1.19  2009/10/30 16:43:33  torer
;;; New function materialize(Bag of X)->Bag of X
;;;
;;; Revision 1.18  2009/08/21 12:28:50  larme597
;;; Including scan functions in lisp
;;;
;;; Revision 1.17  2009/05/05 18:57:04  torer
;;; Better documentation
;;;
;;; Revision 1.16  2009/05/02 18:20:56  torer
;;; Better documentation
;;;
;;; Revision 1.15  2009/04/22 17:35:45  torer
;;; ALisp now stand-alone sub-module
;;;
;;; Revision 1.14  2009/04/01 09:55:21  torer
;;; Remove type RESOURCE
;;;
;;; Revision 1.11  2008/12/25 19:24:56  torer
;;; Global variable _USE_DNF_ --> Special variable *use-dnf*
;;;
;;; Revision 1.9  2008/11/05 16:16:19  torer
;;; select after 'as' optional
;;;
;;; Revision 1.7  2008/04/03 15:00:49  torer
;;; reopt.lsp depatched
;;;
;;; Revision 1.6  2007/12/19 21:06:07  torer
;;; Added externalization of Amos II code for shipping between peers
;;;
;;; Revision 1.5  2007/12/18 07:36:58  torer
;;; Constructor forms on transient objects
;;;
;;; Revision 1.2  2007/11/07 15:14:45  torer
;;; Amos II version 10 with faster basic OjectLog interface to C
;;; Aggregation operators can now be defined in C
;;;
;;; Revision 1.1  2007/10/24 20:18:13  torer
;;; Definition of Amos II core
;;;
;;; =============================================================

(defglobal _lisp-mode_ nil "Start in Lisp toploop if T")

(load "lispdef.lsp");;Basic aLisp system loaded
(setq *verify-immediate* nil)

;flags to enable/disable some system features
(defglobal _AUTO_SAVE_ON_COMMIT_ nil "If T save image when committing")

(defvar *USE-DNF* T "Normalize to disjunctive normal form")
(defglobal _USE_DTR_ T "late binding by dynamic type resolver")

(defglobal _object_)
(defglobal _literal_)
(defglobal _collection_)
(defglobal _type_)
(defglobal _function_)
(defglobal _mappedtype_)		; external type wrapped in local AMOS. 
(defglobal _proxytype_)			; external AMOS type. 
(defglobal _derivedtype_)		; derived intersection types
(defglobal _storedtype_)		; explicitly stored in local database
(defglobal _iuttype_)			; derived reconciled of union of other
					; types
(defglobal _userobject_)		; root type of user defined types

(defglobal _charstring_) 
(defglobal _integer_)
(defglobal _real_)

(defglobal _relation_)

(defglobal _bag_)
(defglobal _vector_) 
(defglobal _stream_)			; stream represented as generators
(defglobal _datasource_)
(defglobal _amos_)

(defglobal _amosinfo_)
(defvar _static_funcs_)
(defglobal _typesof_)

(document 
 _object_ "OID of type OBJECT"
 _literal_ "OID of type LITERAL"
 _collection_ "OID of type COLLECTION"
 _type_ "OID of type TYPE"
 _function_ "OID of type FUNCTION"
 _mappedtype_ "OID of type MAPPEDTYPE"
 _proxytype_ "OID of type PROXYTYPE"
 _derivedtype_ "OID of type DERIVEDTYPE"
 _storedtype_ "OID of type STOREDTYPE"
 _iuttype_ "OID of type IUT"
 _userobject_ "OID of type USEROBJECT"
 _charstring_ "OID of type CHARSTRING"
 _integer_ "OID of type INTEGER"
 _real_ "OID of type REAL"
 _relation_ "OID of type RELATION"
 _bag_ "OID of type BAG"
 _vector_ "OID of type VECTOR"
 _stream_ "OID of type STREAM"
 _datasource_ "OID of type DATASOURCE"
 _amos_ "OID of type AMOS"
 _amosinfo_ "OID of function amosinfo(Amos)"
 _static_funcs_ "OID of function static_funcs(Function)->Boolean"
 _typesof_ "OID of function typesof(Object)->Bag of Type"
 )

(defglobal _histflg_ nil "Logging enabled when true")

(defglobal _vector-constructor_ "VECTOR constructor function") 
(defglobal _tuple-constructor_ "TUPLE constructor function")

(defvar *no-constructor-print*);; set in kernel to nil
(document *no-constructor-print* "Don't print OID constructor forms")

(defvar _eca-enabled_ nil "ECA rules included in system")

;;;; Compiler variables:
(defvar *bindings* nil 
  "List of ObjectLog variables in current scope of compilation")
(defvar *compiled-fn* nil "Function being compiled")


;;;; Parameters for old distributed multi-database system
(defglobal _ENABLE_DT_FLAG_ nil "Enable derived types")
(defglobal _ENABLE_MDB_FLAG_ nil "Enable multidatabase query processor")

; strategy for Distributed Selective View Expansion
; this has to be a defvar because althogh it is disabled here
; there can be a call from other amos that requests view opening
(defvar *DSVE-STRATEGY* 'dsve-none) 
;; "dsve-none", "dsve-full", "dsve-tnsm", "dsve-csm", "dsve-depth"

(defvar *DSVE-BUDGET* NIL)
(defvar *USE_MATERIALIZED_BAGS* nil)
(defglobal _ENABLE_SHIPIN_ nil)
(defglobal _MDB_COST_ALG_ 'ranksort) 
; the algorithm used to compile functions  getting cost info

(defglobal _DISTRIBUTE-TREE_ nil) 
; enables Tree Distribution (qd_treedistr.lsp)

;;;; End of distributed multi-database system

(load "misc.lsp")
(load "basicoid.lsp")
(load "relation.lsp")
(load "function.lsp")
(load "foreign.lsp")
(load "typecheck.lsp")
(load "variable.lsp")			; Martin Hansson
(load "predicate_functions.lsp")	; Martin Hansson 020619
(load "environment.lsp")		;Martin Hansson 020902
(load "flatten.lsp")
(load "latebind.lsp")
(load "comppred.lsp")
(load "recompile.lsp")
(load "optimizer.lsp")
(load "olog.lsp")
(load "subplan.lsp")
(load "purge.lsp")			; added by Martin Hansson 020619
(load "rewrite.lsp")
(load "TBR.lsp")
(load "DTR.lsp")
(load "priority-queue.lsp")
(load "dynprog.lsp")
(load "randomopt.lsp")
(load "normalize.lsp")
(load "collections.lsp")
(load "externalize.lsp")
(load "osql-let.lsp")
(load "proc.lsp")
(load "fncall.lsp")
(load "cursor.lsp")
(load "createuobj.lsp")
(load "constructor.lsp")
(load "deletion.lsp")
(load "printer.lsp")


(with-directory "../BigIntegrator/src/Lisp/"
		(load "absorbmng.lsp")
		(load "misc.lsp")
		(load "finalizermng.lsp")
		)


(load "scan.lsp")
(load "aclient.lsp")
(load "server.lsp")
(load "scan_remote.lsp")
(load "boot.lsp")

(create-root-types);; Make system root types

(load "qd.lsp")
(load "dt.lsp")
(load "coerce.lsp")
(load "dtcreate.lsp")
(load "etemplates.lsp")
(load "typeimp.lsp")
(load "bulk.lsp")
(load "mapped.lsp") 
(load "mbindex.lsp")
(load "new_object.lsp")
(load "declarations.lsp")
(load "arginfo.lsp")
(load "datasource.lsp")
(load "unload.lsp")
(load "materialize.lsp")
(load "comm.lsp")
(load "http.lsp")
(boot);;Boot basic system types
(init-collections);; Initialize collection data types
(init-scan-system);; Initialise scan implementation
