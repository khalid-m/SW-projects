;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: environment.lsp,v $
;;; $Revision: 1.15 $ $Date: 2013/05/01 15:23:47 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Functionality for storing and retrieving various information
;;;              about variables. See also variable.lsp 
;;;
;;; ===========================================================================

; The varInfo structure stores all information about a variable
(defstruct varinfo
  name       ; variable name
  type       ; variable type
  orgtype    ; variable original type
  bind       ; binding
  entity     ; For variables describing mapped types, this describes what
             ; foreign entities this variable maps to.
  boundby    ; the object binds the variable, e.g pred or user input(by MP).
  datasource ; if this variable is bound by a core-cluster function 
             ; of a foreign datasource, this is the sources' OID
)

(defun make-environment ()
  (let ((env (make-hash-table)))
    (puthash '* env (make-varinfo :name '* :type nil :bind '+))
    env))

; insertion

(defmacro putvar (v env &rest args)
  "Register a new variable, supplying optional info. Any older value 
   will be replaced."
  `(if (named-varsymbolp , v)
       (putvar-int , v , env ,@ (parsekeywordparams args '(:name
							   :type
							   :orgtype
							   :bind
							   :entity
							   :boundby
							   :datasource)))))

(defun putvar-int (v env name type orgtype bind entity obj 
		     datasource)
  (if (gethash v env)
      (error "Variable already present in environment" v)
    (puthash v env (make-varinfo :name name
				 :type type
				 :orgtype orgtype
				 :bind bind
				 :entity entity
				 :boundby obj
				 :datasource datasource))))
  
(defun exists (v env)
  "Returns true if this variable has ever been put in the environment."
  (gethash v env))

; binding / setting of all fields

(defun bound (v env &optional noerror)
  (if (constantsymbolp v) t
    (let ((vi (gethash v env)))
      (if vi (eq (varinfo-bind vi) '-)
	(if noerror nil (error "Variable does not exist" v))))))

(defun free (v env &optional noerror)
  (if (constantsymbolp v) nil
    (let ((vi (gethash v env)))
      (if vi (eq (varinfo-bind vi) '+)
	(if noerror nil (error "Variable does not exist" v))))))

(defun binding (v env &optional noerror)
  "Returns the binding of variable v in environment env. If noerror is
   set, the result is nil for nonexistent variables."
  (if (varsymbolp v)
      (let ((vi (gethash v env)))
	(if vi (varinfo-bind vi)
	  (if noerror nil (error "Variable does not exist" v))))
    '-))

(defmacro bind (v env &rest args)
  `(bind-int , v , env ,@ (parsekeywordparams args '(:name
						     :type
						     :orgtype
						     :entity
						     :boundby
						     :datasource))))
    
(defun bind-int (v env name type orgtype entity obj datasource)
  (if (named-varsymbolp v)
      (let ((vi (gethash v env)))
	(if vi
	    (progn
	      (setf (varinfo-name vi)       name)
	      (setf (varinfo-type vi)       type)
	      (setf (varinfo-orgtype vi)    orgtype)
	      (setf (varinfo-bind vi)       '-)
	      (setf (varinfo-entity vi)     entity)
	      (setf (varinfo-boundby vi)     obj)
	      (setf (varinfo-datasource vi) datasource))
	  (error "Variable does not exist" v)))))

; datasource field

(defun datasource (v env &optional noerror)
  "Returns the datasource that variable v maps to. If noerror is 
   set, the result is nil for nonexistent variables."
  (let ((vi (gethash v env)))
    (if vi (varinfo-datasource vi)
      (if noerror nil (error "Variable does not exist" v)))))

(defun set-datasource (v env ds)
  (if (not (varsymbolp v))
      (error "Not a variable" v)
    (let ((vi (gethash v env)))
      (if vi 
	  (setf (varinfo-datasource vi) ds)
	(error "Variable does not exist" v)))))

; entity field

(defun entity (v env &optional noerror)
  "DEPRECATED. Use get-entity instead.
   Returns the entity of variable v in environment env. If noerror is
   set, the result is nil for nonexistent variables."
  (if (constantsymbolp v) v
    (let ((vi (gethash v env)))
      (if vi (varinfo-entity vi)
	(if noerror nil (error "Variable does not exist" v))))))

(defun get-entity (v env &optional noerror)
  "Returns the entity of variable v in environment env. If noerror is
   set, the result is nil for nonexistent variables."
  (if (constantsymbolp v) v
    (let ((vi (gethash v env)))
      (if vi (varinfo-entity vi)
	(if noerror nil (error "Variable does not exist" v))))))	

(defun set-entity (v env tp)
  "Sets the entity of variable v in environment env."
  (if (not (varsymbolp v))
      (error "Not a variable" v)
    (let ((vi (gethash v env)))
      (if vi 
	  (setf (varinfo-entity vi) tp)
	(error "Variable does not exist" v)))))


(defun get-type (v env &optional noerror)
  "Returns the type oid of variable v in environment env. If noerror is
   set, the result is nil for nonexistent variables."
  (if (constantsymbolp v) (arg-type v)
    (let ((vi (gethash v env)))
      (if vi (varinfo-type vi)
	(if noerror nil (error "Variable does not exist" v))))))

(defun get-typename (v env &optional noerror)
  "Returns the symbolic type name of variable v in environment env. If noerror
   is set, the result is nil for nonexistent variables."
  (if (constantsymbolp v) (arg-type v)
    (let ((vi (gethash v env)))
      (if vi (oid-name (varinfo-type vi))
	(if noerror nil (error "Variable does not exist" v))))))

(defun set-type (v env tp)
  (if (not (varsymbolp v))
      (error "Not a variable" v)
    (let ((vi (gethash v env)))
      (if vi 
	  (setf (varinfo-type vi) tp)
	(error "Variable does not exist" v)))))

(defun get-orgtypename (v env &optional noerror)
  "Returns the symbolic 'original' type name of the variable v in environment
   env. The meaning of original type is somewhat loosely specified, in the end
   it is up to the user to decide. Intuitively it should only have a meaning 
   for wrappers, the orgtype being wrapped datasource's meaning of type name. 
   If noerror is set, the result is nil for nonexistent variables."
  (if (constantsymbolp v) (arg-type v)
    (let ((vi (gethash v env)))
      (if vi (varinfo-orgtype vi)
	(if noerror nil (error "Variable does not exist" v))))))

(defun set-orgtypename (v env tp)
  (if (not (varsymbolp v))
      (error "Not a variable" v)
    (let ((vi (gethash v env)))
      (if vi 
	  (setf (varinfo-orgtype vi) tp)
	(error "Variable does not exist" v)))))

; compatibility w/rest of Amos


(defun bpat (pred env)
  "Creates a binding pattern from the predicate's arguments: list of
    -:es +:es used throughout Amos."
  (mapcar (f/l (arg) (binding arg env)) 
	  (predicate-arguments pred)))

(defun assign (v1 v2 env &optional noerror)
  "Assigns v1 to v2, ie all info about v2 is copied to v1."
  (puthash v1 env (copy-varinfo (gethash v2 env))))

(defun bound-variables (environment)
  "Returns a list of the variables that are bound in the environment."
  (let ((res nil))
    (maphash (f/l (key val v)
	       (if (eq (varinfo-bind val) '-)
		   (setq res (nconc1 res key))))
	     environment)
    res)
  )

; pretty printing

(defun ppe (env &optional str)
  "Pretty-prints an environment."
  (formatl str "environment:v|data source|binding|entity|type|orgtype" t)
  (maphash (f/l (key val v)
		(formatl str key "|" (varinfo-datasource val)
			 "|" (varinfo-bind val) "|" (varinfo-entity val)
			 "|" (varinfo-type val) "|" (varinfo-orgtype val) 
			 "." t)
		)
	   env)
  nil)

