;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2009-2010 Andrej Andrejev, UDBL
;;; $RCSfile: sparql-utils.lsp,v $
;;; $Revision: 1.6 $ $Date: 2012/04/25 18:43:13 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Utility functions used in AmosQL translations of SparQL queries
;;; =============================================================

;; Copied from excluded file: SWARD/src/AmosQL/sparql:amosql 
;; Fn overriding inequality fn neq called in parsed SparQL queries.
(osql "create function neq(Charstring c1, Charstring c2)->Boolean as select true where c1 != c2;")

;; AREGEX
;; Substiture all .* to * (converting REGEX format)

(defun aregex (regex)
  (do ((buf "") (pos 0 (1+ pos)) (pos0 0) (ch2 nil))
      (nil nil)
    (setq ch2 (substring pos (1+ pos) regex))
    (when (member ch2 '(".*" ""))
      (when (< pos0 pos) 
	(setq buf (concat buf (substring pos0 (1- pos) regex))))
      (setq pos0 (1+ pos))
      (when (string= ch2 "") (return buf)))))

(foreign-lispfn aregex ((Charstring regex)) ((Charstring))
		(foreign-result (aregex regex)))

;; OPTIONAL

(osql "create function optional0(Bag b, Object o) -> Object r as foreign 'optional--+';")

(foreign-lispfn nil1 () ((Object)) (foreign-result nil)) 

(defun optional--+ (fno b o r)
	(let ((bag-value nil))
	  (mapbag b (f/l (row) (setq bag-value t) (osql-result b o (car row))))
	  (unless bag-value (osql-result b o o))))

(defun optional-resulttypes (fno args)
	(let ((res-types (type-parameters (arg-type (car args)))))
		(unless res-types (setq res-types (list (gettypenamed 'object)))) ;;Treat bags as bags of objects
		(unless (osql-subtypep (arg-type (cadr args)) (car res-types))
			(raise-resolve-error fno (cons 'incompatible args)))
		res-types))

(set-resulttypesfn (theresolvent 'optional0) 'optional-resulttypes)

;; EITHER

(osql "create function either(Vector v, Object ub) -> Object r as foreign 'either--+';")

(defun either--+ (fno v ub r)
  (when
      (dotimes (i (length v) t)
	(unless (equal (aref v i) ub)
	  (osql-result v ub (aref v i))
	  (return nil)))
    (osql-result v ub ub)))

(defun either-resulttypes (fno args)  
  (list (arg-type (cadr args))))

(set-resulttypesfn (theresolvent 'either) 'either-resulttypes)
  

;; PARTIAL LEFT JOIN - not currently in use

(osql "create function PLJ(Bag of Vector lb, Bag of Vector rb, Object ub) -> Vector r as foreign 'PLJ---+';")

(defun PLJ---+ (fno lb rb ub r)
  (let ((leftlen nil))
    (mapbag lb (f/l (row-l) ; cycle through left bag
		    (unless leftlen
		      (setq leftlen (length (car row-l))))
		    (let ((joined nil) (res (make-array leftlen)) lv rv)		      
		      (mapbag rb (f/l (row-r) ; cycle through right bag
				      (when
					  (dotimes (i leftlen t) ; cycle through left bag columns, return T on completion
					    (setq lv (aref (car row-l) i))
					    (setq rv (aref (car row-r) i))
					    (setf (aref res i)
						  (cond ((equal lv ub) rv) ; get 'coalesced' value from lv & rv
							((equal rv ub) lv)
							((equal lv rv) lv) ; or get common value
							(t (return nil))))) ; return NIL on conflict
					(setq joined t)
					(osql-result lb rb ub res))))
		      (unless joined
			(osql-result lb rb ub (car row-l))))))))
