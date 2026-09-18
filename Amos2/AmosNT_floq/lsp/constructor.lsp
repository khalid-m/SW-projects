;;; =============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: constructor.lsp,v $
;;; $Revision: 1.11 $ $Date: 2012/05/15 19:27:51 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Transparent constructors. Two functions enable you to create
;;;              custom constructors, or forbid the construction of objects
;;;              from AmosQL.  
;;;
;;;              * forbid-constructor(tpo &optional error-message)
;;;                forbids instantiation of the type from AmosQL.
;;;
;;;              * set-constructor(tpo constructor-fno)
;;;                declares that the resolvent constructor-fno should be called
;;;                when invoking a create object statement. If the constructor
;;;                takes any arguments it will not be possible to create an 
;;;                object without supplying these properties.
;;;              
;;; =============================================================
;;; $Log: constructor.lsp,v $
;;; Revision 1.11  2012/05/15 19:27:51  torer
;;; result -> return
;;;
;;; Revision 1.10  2008/08/15 11:47:41  torer
;;; Transactional interface variables
;;;
;;; Revision 1.9  2007/11/04 20:30:46  torer
;;; Mismatches in boolean foreign function result tuples
;;;
;;; =============================================================

; AmosQL front functions
(defun set_constructor--+ (fno tpo constructor-fno)
  (set-constructor tpo constructor-fno)
  (osql-result tpo constructor-fno))

(defun forbid_constructor-+ (fno tpo)
  (forbid-constructor tpo)
  (osql-result tpo))

(defun forbid_constructor--+ (fno tpo error-message)
  (forbid-constructor tpo error-message)
  (osql-result tpo error-message))


; public functions
(defun forbid-constructor (tpo &optional error-message)
  "Forbids construction of the type from user level. If a message string is
   supplied, it will display in the error, instead of the default message."
  (let* ((message (or error-message "Creation of this type is forbidden."))
	 (error-constructor (create-error-constructor tpo message)))
    (/putobject tpo 'constructor error-constructor)))

(defun set-constructor (tpo constructor-fno)
  "Declares a constructor that will be called when typing
   create person(ssn) instances (1);
   which will lead to a call to the constructor. If the constructor
   takes arguments, then all of these must be specified or an error will be
   raised."
  (let ((constructor-result (getrestype constructor-fno)))
    ;; check that the constructor indeed return the type
    (if (not (and (= 1 (length constructor-result)) 
		  (eq (first constructor-result) tpo)))
	(amos-error "Not a constructor. Does not return " tpo))
    ;; check that the arguments of the constructor correspond
    ;; to functions which exist
    (dolists 
     ((property-tpo (get-resolvent-argtypes constructor-fno))
      (property-name(function-argvars constructor-fno)))
     (if (not (getfunction 'get_property 
			   (list tpo (mkstring property-name)
				 property-tpo)))
	 (amos-error "Constructor references nonexistent type property:" 
		     (list property-name tpo))))
    (dolist (argname (function-argvars constructor-fno)))
    (/putobject tpo 'constructor constructor-fno)))

; private functions

(defun call-constructors (type constructor propfns settings)
  "Calls the <constructor> for <type>, setting the properties in <propfns>
   and assigs variables if present.
   propfns: list of names of properties, for example (SSN) 
   settings: list of variables and settings, for example 
             (:peter (12) :susan (13) ((14))),
             the semantics of which is: 
             :peter := create_person(12);
             :susan := create_person(13);
             create person(14);"
  ;; to do: It is now possible to write
  ;; create person(ssn, <anything>, ...) instances (12)
  ;; and the <anything>s are ignored but it is ugly that you don't get an
  ;; error.
  (let ((sl settings))
    (while (setq sl (pop settings))
      (if (listp sl)
	  (call-constructor type constructor propfns sl)
    ;; This does not work in procedures!! Macros should be used!! TR
	(set (osql-interfacevar sl) 
	     (call-constructor
	      type constructor propfns (pop settings)))))))

(defun call-constructor  (type constructor propfns setting)
  "Calls one single constructor. Arguments as in call-constructor, except
   setting is only one setting: (:peter (12)) or just ((12))"
  (let ((argsettings (pair propfns setting))
	(constructor-argnames (function-argvars constructor))
	constructor-args
	other-argsettings
	newobj)
    (dolist (argname constructor-argnames)
      (let ((argsetting (assoc argname argsettings)))
	(setq argsettings (delete argsetting argsettings))
	(if argsetting
	    (push (cdr argsetting) constructor-args)
	  (amos-error "Property must be set: " argname))))
    (setq other-argsettings argsettings)
    (setq constructor-args (reverse constructor-args))
    (setq newobj (caar (getfunction constructor constructor-args)))
    (dolist (argsetting other-argsettings)
      (addfunction (car argsetting) (list newobj) (list (cdr argsetting))))
    newobj))

(defun create-error-constructor (tpo error-message)
  "Creates a constructor that only returns the chosen error message and 
   does not create a new object."
  (let ((typename (oid-name tpo)))
    (amos-execute 
     (concat "create function create_"typename"()->"typename
	     " as begin "
	     "    select error('"error-message"');"
	     "    return nil"
	     "    end;"))))





	
      
	
  
