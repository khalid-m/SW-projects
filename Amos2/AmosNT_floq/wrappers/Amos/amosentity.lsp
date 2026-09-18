;;; ===========================================================================
;;; AMOS2
;;; 
;;; Author: (c) 2002 Martin Hansson, UDBL
;;; $RCSfile: amosentity.lsp,v $
;;; $Revision: 1.2 $ $Date: 2003/09/26 09:10:13 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: All variables participating in TR-predicates must, according 
;;;              to the wrapper API specification, have an entity, which can 
;;;              be either a type projection or a function call. In an absorbed
;;;              predicate of the kind 'type-core-cluster', i.e.
;;;
;;;              An object calculus expression such as
;;;              { person@amosds1_cc (p) } will cause the translator (see 
;;;              amos_translator.lsp) to grant p the entity
;;;              #(amosentity type person), where the symbol 'type tells the
;;;              remote compiler that the variable is a projection of the 
;;;              remote type person.
;;;
;;;              An object calculus expression such as
;;;              { person@amosds1_name_cc (p name) }
;;;              will grant the variable name the entity
;;;              #(amosentity function (name p)). p will always be bound and
;;;              given an entity in this cas.
;;;            
;;;              
;;; ===========================================================================
(defstruct amosentity
  type; the symbol 'function or 'type
  mapping;either a function call as an s-expression if type field is 'function,
         ;or the symbolic name of a remote type
)

(defun make-amosentity-type (value)
  "Creates an amosentity which represents a type projection in a from clause."
  (make-amosentity :type 'type :mapping value))

(defun make-amosentity-function (value)
  "Creates an amosentity which represents a function call in a select or where
   clause, depending on the binding of the variable.
   A function call is representen in the usual Lisp syntax with the generic 
   name of the function, for instance (= x y) or (name p)."
  (make-amosentity :type 'function :mapping value))
