;;   AMOS - 941019
;;   Martin Skold
;;   contexts.lsp
;;   Rule context related functions

(provide 'contexts)

(defvar _context_ ) ; rule context type

(defun create-context (name)
   (if (getobjectnamed name _context_ t) ; already exists
      (getobjectnamed name _context_ t)
      (/createobject 'context name)))

(defmacro delete-context (name)
  (let ((context (getobjectnamed name _context_ t)))
    (if context
	(if (getobject context 'activations)
	    (amos-error "Context contains active rules!")
	  (deleteobject context))
      (amos-error "Context does not exist!"))))

(defvar *contextnum* 0)

(defun gencontextname nil 
  (mkatom
   (concat 'context- 
	   (setq *contextnum* 
		 (1+ *contextnum*)))))

(defvar _deferred_ )   ; for constraints
(defvar _detached_ )   ; for trackers
(defvar _active-contexts_ nil) 

(defun activate-context (name)
   (let ((context (getobjectnamed name _context_)))
      (if context
         (progn
           (/putobject context 'activation-time (gettimeofday))
           ;(/globsetq _active-contexts_ (append _active-contexts_ 
           ; (list context)))))
           ))
; no effect (TR):      (ruleCheck context)
      context))

(defmacro deactivate-context (name)
   (let ((context (getobjectnamed name _context_)))
     (if context
	 (progn
	   (/putobject context 'activation-time nil)
	   ;(/globsetq _active-contexts_ (remove context _active-contexts_))))
	   ))
     context))

(defun add-to-context (context rule)
  (/putobject context 'activations 
	      (cons rule 
		    (remove rule (getobject context 'activations)))))

(defmacro get-context-activations (context)
   `(getobject , context 'activations))

(defun remove-from-context (context rule)
  (/putobject context 'activations 
	      (remove rule (getobject context 'activations))))

(defmacro context-starttime (context)
   `(getobject , context 'activation-time))

(setq _context_ (createtype 'context '(object))) ; rule context type
(defun init-contexts()
   (setq _deferred_ (create-context 'deferred))   ; for constraints
   (setq _detached_ (create-context 'detached))   ; for trackers
   (foreign-lispfn create_context((charstring name)) ((context))
     (foreign-result (create-context (mkatom name))))
   (foreign-lispfn create_context() ((context))
     (foreign-result (create-context (gencontextname))))
   (foreign-lispfn contextnamed ((charstring name)) ((context))
     (foreign-result (getobjectnamed (mkatom name) _context_ t)))
   (activate-context 'deferred)
   (activate-context 'detached)
   (commit)
   )
