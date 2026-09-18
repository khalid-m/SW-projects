;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 1997-2011, Tore Risch, UDBL
;;; $RCSfile: basicoid.lsp,v $
;;; $Revision: 1.32 $ $Date: 2013/02/23 16:27:18 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Basic Amos2 object and history initiation
;;; =============================================================
;;; $Log: basicoid.lsp,v $
;;; Revision 1.32  2013/02/23 16:27:18  torer
;;; _startup-dir_ now available also in alisp
;;;
;;; Revision 1.31  2012/08/10 06:40:30  torer
;;; TRANSIENTP now in C
;;;
;;; Revision 1.30  2012/05/24 06:28:57  torer
;;; Misspelling
;;;
;;; Revision 1.29  2012/02/24 11:37:30  torer
;;; More on-line documentation
;;;
;;; Revision 1.28  2012/02/24 08:20:10  torer
;;; On-line documenttation added
;;;
;;; Revision 1.26  2012/01/20 14:57:59  torer
;;; Wrong variable name declared
;;;
;;; Revision 1.25  2012/01/16 10:04:17  torer
;;; /defc now in C
;;;
;;; Revision 1.24  2011/12/22 12:55:15  torer
;;; Code cleanaup for Release 14
;;;
;;; Revision 1.23  2011/12/20 19:55:07  torer
;;; Transactional Lisp function definitions
;;;
;;; Revision 1.22  2011/12/17 17:52:44  torer
;;; DIFFOBJECT inverse of UNIONOBJECT
;;;
;;; =============================================================

(defglobal _oidno_ 0 "Last OID number") 
(defglobal _objects_)
(document 
 _objects_ 
 "array containing all surrogate objects in database indexed with OID number")

(defglobal _symbtab_)
(document 
 _symbtab_  "Hash table for named system objects. (GETHASH <name> _SYMBTAB_)
   returns a list of the system objects named <name>.")

(defglobal _bootflg_)
(document _bootflg_ "True while booting Amos")

(defglobal _history_ nil)

(defglobal _prompter_ nil "Prompter in toploop")

;;; Basic representation of OIDs

(defmacro oid-idno (o)
  "OID number of surrogate object"
  (list 'getobject o ''idno))

(putprop 'oid-idno 'setfmethod 
	 '(lambda (place val)(list 'putobject (cadr place) ''idno val)))

(defmacro oid-types (o)
  "The list of types of an OID. The most specific type is first
   in the list. This list is stored directly in the OID struct.  Same as
   (GETOBJECT O 'TYPES)."
  (list 'getobject o ''types))

(putprop 'oid-types 'setfmethod 
	 '(lambda (place val)
	    (list 'putobject (cadr place) ''types val)))

(defmacro oid-propl (o)
  "returns the property list of OID, not including properties stored
   directly in the OID struct. Same as (GETOBJECT O 'PROPL)"
  (list 'getobject o ''propl))

(putprop 'oid-propl 'setfmethod 
	 '(lambda (place val) (list 'putobject (cadr place) ''propl val)))

(document 
          createobject
          "(extfn CREATEOBJECT (TP NAME)...)
   Non-transactionsl /CREATEOBJECT" 
          /createobject
          "(extfn /CREATEOBJECT (TP NAME)...)
   Creates an Amos object whose type is specified by TP. 
   NAME is an optional name for the object specified as a Lisp symbol.
   Transactional."
          oid-p
          "(extfn OID-P (X)...)
   Returns X if X is a surrogate object"
          getobject 
	  "(extfn GETOBJECT (O PROP)...)
   Retrieves property PROP of OID O"
          putobject
          "(extfn PUTOBJECT (O PROP VAL)...)
   Non-transactional /PUTOBJECT"
          /putobject
          "(extfn /PUTOBJECT (O PROP VAL)...)
   Sets property PROP of OID O to VAL. Also properties stored directly in
   the OID struct are updatable using PUTOBJECT"
          addobject
          "(ADDOBJECT O PROP VAL)
   Non-transactional /ADDOBJECT"
          /addobject
          "(extfn /ADDOBJECT (O PROP VAL)...)
   Adds VAL to end of a list under (GETOBJECT O PROP). Transactional"
          differenceobject
          "(extfn DIFFERENCEOBJECT (O PROP L)...)
   Transactional removal of elements in list L from list 
   in (GETOBJECT O PROP)"
          unionobject
          "(extfn UNIONOBJECT (O PROP L)...)
   Sets property PROP of surrogate object O to union of old PROERTY and L.
   Transactional."
          /purgeobject
          "(extfn /PURGEOBJECT (O)...)
   Delete object O. Transactional."
          purgeobject
          "(extfn PURGEOBJECT (O)...)
   Non-transactional /PURGEOBJECT"
          oid-name
          "(extfn OID-NAME (O)...)
   The name of OID O or NIL if unnamed. Same as (GETOBJECT O 'NAME)"
          getobjectnamed
          "(extfn GETOBJECTNAMED (NAME TPO &optional NOERROR)...)
   Retrieves the object named NAME (a symbol) of type TPO (an OID).
   If no such object found an error is raised, unless NOERROR!=NIL"
          getobjectnumbered
          "(extfn GETOBJECTNUMBERED (NO)...)
   Gets the OID having the ID number NO.
   Raises an error if no such object found"
          create-transient-object
          "(extfn CREATE-TRANSIENT-OBJECT (TPO)...)
   Constructs a new transient object of type TPO"
          make-persistent
          "(extfn MAKE-PERSISTENT (O)...)
   A transient object can be made into a persistent object by calling
   MAKE-PERSISTENT.  It assigns a new unique ID number for O and adds O
   to the extent of its type"
          arg-type
          "(extfn ARG-TYPE (X)...)
   same as (MOST-SPECIFIC-TYPE (ARG-TYPES X))"
          arg-types
          "(extfn ARG-TYPES (X)...)
   Returns the type list of an expression X. See also (ARG-TYPE X)"
          mapextent
          "(extfn MAPEXTENT (TPO LISPFN)...)
   Applies Lisp function LISPFN on each element of surrogate type TPO.
   Does not include the elements of the subtypes of TPO"
          osql-constantp
          "(extfn OSQL-CONSTANTP (X)...)
   Tests is X is an ObjectLog constant, 
   i.e. string, number, OID, tuple, bag, or vector"
          osql-subtypep
          "(extfn OSQL-SUBTYPEP (X Y &OPTIONAL STRICT)...)
   Tests if a type object X is a subtype of another type object Y.
   STRICT=NIL => Test if X<=Y, otherwise X<Y"
          type-supertype
          "(extfn TYPE-SUPERTYPES (TPO)...)
   List of immediate supertypes of type TPO"
          type-allsupertypes
          "(extfn TYPE-ALLSUPERTYPES (TPO)...)
   Returns the property ALLSUPERTYPES of a type TPO.  ALLSUPERTYPES is
   the list of types above TPO in type hiearchy with TPO added first"
          type-cardinality
	  "(extfn TYPE-CARDINALITY (TPO)...)
   Returns the number of objects in the extent of surrogate type TPO,
   including all subtypes"
          new-event
	  "(extfn NEW-EVENT (NAME ROLLBACKFN &OPTIONAL ROLLFORWARDFN)...) 
   This function creates a new kind of event and returns its 'event
   descriptor'.

   The 'rollback function', ROLLBACKFN, is called when a transaction
   rollback has been issued to undo the effect of the event. It is called
   with the arguments OBJ, ARG, OLD, and NEW, the attributes of the
   event.

   The optional 'rollforward function', ROLLFORWARDFN, redoes the effect
   of the event. This happens when recovering databases and in some other
   situations. The default for the rollforward function is the 'inverse'
   of the rollback function, i.e. the default
   ROLLFORWARDFN(OBJ,ARG,OLD,NEW) == ROLLBACKFN(OBJ,ARG,NEW,OLD). The
   rollforward function needs to be specified only in the unusual cases
   when the rollforward action is assymetric from the rollback action"
          geteventfns
          "(extfn GETEVENTFNS (EVT)...)
   Get list of event functions registered with event type EVT"
          seteventfns
          "(extfn SETEVENTFNS (EVT EVENTFNS)...)
   Set event functions of event type EVT to list of event functions"
          _history_
          "Amos II contains a subsystem for managing transactions.  
   So called 'write ahead logging' is used which means that just before a 
   database object is to be modified (updated) the system will log the old
   (i.e. current) and the new (i.e. updated) state of the database
   object. The state change, called an 'event', is saved in a linked list
   called the 'history list' bound to the global Lisp variable _HISTORY_.
   The events in _HISTORY_ are in reverse order of when they happened."
          history-add
	  "(extfn HISTORY-ADD (EVT OBJ ARG OLD NEW)...) 
   EVT is an event descriptor and OBJ, ARG, OLD, NEW are as in NEW-EVENT.
   Notice that the events should be raised just before the update
   is to take place"  
          prhist
	  "(extfn PRHIST (HISTORY)...)
   prints all events in the history list HISTORY (the latest first).
   Usually called as (PRHIST _HISTORY_)"
	  subscribe-event
	  "(extfn SUBSCRIBE-EVENT (EVT EVENTFN)...)
   The Lisp function EVENTFN is called whenever an event of type EVT is
   raised. There can be several event handlers associated with each event type.
   The arguments of EVENTFN OBJ, ARG, OLD, and NEW as for NEW-EVENT.

   If the event handler of an event returns a non-NIL value, the event
   will be logged in the history list, otherwise no logging takes place.
   Thus event functions can be used for controlling whether logging of a
   certain event should be done or not"
	  unsubscribe-event
	  "(extfn UNSUBSCRIBE-EVENT (EVT EVENTFN)...)
   Unsubscribe the event handler EVENTFN for EVENT type EVT"
	  history-rollback
	  "(extfn HISTORY-ROLLBACK (SAVEPOINT)...) 
   If SAVEPOINT is NIL the history list is traversed in reverse order to
   undo all state changes and then deallocate the history list.
   SAVEPOINT can also be some nil-NIL binding of _HISTORY_ in which case
   the rollback will be done until that point (the savepoint) is reached"
          commit
          "(extfn COMMIT ()...)
   Make all changes permanent by setting _HISTORY_ to nil"
	  rollback
	  "(extfn ROLLBACK (N)...)
   The Amos II prompter for AmosQL prints a 'savepoint
   number' before each statement. Whenever a database update occurred
   during an evaluation this savepoint number is incremented. The system
   remembers the history list for each savepoint number.  ROLLBACK rolls
   the current transaction back to savepoint number N. 
   The global savepoint history is in variable _HISTORY_"
          object-typep
          "(extfn OBJECT_TYPEP (O TP)...)
   Is type TP in the type list of surrogate object O?"
	  trace-cinterface
	  "(extfn TRACE-CINTERFACE (FLG)...)
   By setting FLG the interface calls between C and the Amos II
   kernel are traced"
	  _parsetrace_
	  "(SETQ _PARSETRACE_ T) 
   prints the parsed Lisp representation of each parsed AmosQL
   expression"
	  trace-packets
	  "(extnf TRACE-PACKETS (FLG)...)
   Turns on/off printing of all communication messages form/to this
    Amos II peer"
	  )

(putprop 'getobject 'setfmethod 
	 '(lambda (place val) (list 'putobject (cadr place) 
				    (caddr place) val)))

(defmacro make-oid (&rest args)
  "Construct new OID"
  (cons 'makefn-oid
	(parsekeywordparams args '(:idno :types :propl))))

(defglobal _putobject_ (new-event '/putobject 'undo-putobject nil)
  "History event for /PUTOBJECT")

(defglobal _createobject_ (new-event '/createobject 'undo-createobject nil)
  "History event for /CREATEOBJECT")

(defmacro gettypenamed (nm &optional noerr)
  "Get type with symbolic name NM. 
Identity function if NM is OID.
NOERR=NIL=>error if not found."
  `(getobjectnamed , nm _type_ , noerr))

(defun the-object-named (nm tp)
  "Get the object NM of type TP or create new one"
  (or (getobjectnamed nm tp t)
      (/createobject tp nm)))

(defun gettypesnamed (l &optional noerr)
  "Get names of types in list L of symbolic type names or OIDs. 
NOERR=NIL=>error if not found." 
  (mapcar (f/l (x)(gettypenamed x noerr)) l))
   
;;; Get properties of OIDs

(defun all-oid-props (tp)
  "Find all properties used by OID of type TPO or under it"
  (let (props)
    (mapextent (gettypenamed tp) 
	       (f/l (o)
		    (dolist (p (oid-properties o))
		      (setq props (adjoin p props)))))
    props))

(defun oid-properties (o)
  "Returns a list of all property keys of an OID"
  (let ((props '(idno types)))
    (do ((p (oid-propl o) (cddr p)))
	((null p) nil)
      (setq props (adjoin (car p) props)))
    props))

(defun diffobject (o prop l)
  (putobject o prop (set-difference (getobject o prop) l)))

;;; Transactional property lists

(defglobal _putprop_ (new-event '/putprop '/putprop-undo nil)
  "History event for /PUTPROP")

(defun /putprop (a i v)
  "Transactional PUTPROP"
  (history-add _putprop_ a i (getprop a i) v)
  (putprop a i v))
(defun /putprop-undo (obj arg old new)
  "Rollback of /PUTPROP"
  (if old (putprop obj arg old)
    (remprop obj arg)))

(defun /addprop (a i v &optional flg)
  "Transactional ADDPROP"
  (/putprop a i (if flg (append (getprop a i) (list v))
		  (cons v (getprop a i)))))

(defun /remprop (a i)
  "Transactional REMPROP"
  (let ((old (getprop a i)))
    (cond (old (history-add _putprop_ a i old nil)
	       (remprop a i)))))

;;; renaming oids

(defglobal _rename_ (new-event '/rename 'undo-rename nil)
  "History event for /RENAMEOBJECT")

(defun /renameobject (oid newname)
  "Rename named object OID to NEWNAME. Transactional."
  (let ((oldname (getobject oid 'name)))
    (cond ((eq oldname newname) oid)
	  (t (history-add _rename_ oid nil oldname newname)
	     (renameobject oid newname)
	     oid))))

(defun renameobject (oid newname)
  "Non-transactional /RENAMEOBJECT"
  (let ((oldname (getobject oid 'name)))
    (cond ((eq newname oldname) oid)
	  (t
	   (setf (gethash oldname _symbtab_) ; remove old name
		 (delete oid (gethash oldname _symbtab_)))
	   (set-oid-name oid newname)
	   ))))

(defun undo-rename (oid arg old new)
  "Rollback of /RENAMEOBJECT"
  (renameobject oid old))

(defun set-alias-name (newname oldname tp)
  "Make an alias name NEWNAME of an system object named OLDNAME of type TP.
   Not transactional!"
  (let ((oid (getobjectnamed oldname (gettypenamed tp))))
    (setf (gethash newname _symbtab_)
	  (adjoin oid (gethash newname _symbtab_)))))



;;; Transactional Lisp function definition

(defglobal _defc_ (new-event '/defc '/defc-undo nil)
  "History event for /defc")

(defun /defc-undo (fn dummy old new)
  (defc fn old))

;;; Transactional global variable assignment

(defglobal _setglobal_ (new-event '/setglobal '/setglobal-undo nil)
  "Histrory event for /SETGLOBAL")

(defun /setglobal (v val)
  "Transactional setting of global variable V to VAL"
  (history-add _setglobal_ v nil (symbol-value v) val)
  (set v val))

(defun /setglobal-undo (var dummy old new)
  "Rollback of /SETGLOBAL"
  (and (symbolp var) (set var old)))

;;; Basic relational tables
(defun type-extent (tpo)
  "Returns the list of objects in the extent of TPO. Notice that
   MAPEXTENT should be used when possible as it does not build a long
   list"
  (let (res)
    (mapextent (gettypenamed tpo)
	       (f/l (o)(setq res (cons o res))))
    res))

(defun allrelations ()
  "Get list of all relations in database"
  (type-extent _relation_))

(defmacro make-index (&rest args)
  "Construct new index"
  (cons 'makefn-index
	(parsekeywordparams args '(:pos :unique :rows :owner :type))))

;;; proxies

(defglobal _proxy_)
(defglobal _proxytable_) 

(document _proxy_ "OID of type PROXY"
          _proxytable "Hash table of proxy objects")

(defun proxy-p (x)
  "Is X a proxy object?"
  (and (oid-p x)			; is it an object at all?
       (getobject x 'exportto)))

(defun proxy-oid (x)
  "Get the foreign OID number of a proxy X"
  (assert (proxy-p x) "Non-proxy argument")
  (getobject x 'xoidno))

(defun proxy-database (x)
  "Get the database of a proxy X"
  (assert (proxy-p x) "Non-proxy argument")
  (getobject x 'exportto))

(defun proxies-from (database)
  "Get all proxies imported from DATABASE"
  (let (res)
    (mapextent _proxy_ 
	       (f/l (x)
		    (if (eq (proxy-database x) database)
			(setq res (cons x res)))))
    res))

;;; Transients

(setq *no-constructor-print* t)

