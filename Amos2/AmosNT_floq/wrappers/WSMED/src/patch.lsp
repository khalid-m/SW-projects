(setq _system-watermark_ 0)

(foreign-lispfn  
 create_mapped_type 
 ((charstring name)(vector keys)(vector attributes)(charstring ccfn)) 
 ((type))
 "Creates mapped type, given name, keys, attributes, and Core Cluster Function"
 (let ((ccfn (resolvents (getfunctionnamed (mksymbol ccfn))))
       rt attrs pos)
   (if (cdr ccfn) 
       (error "More than one resolvent for Core Cluster Function" ccfn)
     (setq ccfn (car ccfn)))
   (if (get-resolvent-argtypes ccfn)
       (error "Core Cluster Function cannot have arguments" ccfn))
   (setq rt (get-resolvent-restypes ccfn))
   (if (not (= (length rt)(length attributes)))
       (error "Width of Core Cluster Function different from # attributes" 
	      name))
   (setq attrs (mapcar (f/l (tpe an)(list (oid-name tpe) (mksymbol an))) 
		       rt (arraytolist attributes)))
   (setq keys (mapcar (function mksymbol) (arraytolist keys)))
   (cond ((null keys)(error "No key specified in mapped type" name))
         ((cdr keys))
         ((null (member (functiontype ccfn) '("stored" "foreign"))))
         ((setq pos (getpos (searchdcl (car keys) attrs) attrs))))
   (create-mapped-type (mksymbol name) nil
		       attrs
		       (mapcar (f/l (k)
				    (or (searchdcl (mksymbol k) attrs)
					(error "Undefined mapped type key" k)))
			       keys)
		       (oid-name ccfn))
   ))
