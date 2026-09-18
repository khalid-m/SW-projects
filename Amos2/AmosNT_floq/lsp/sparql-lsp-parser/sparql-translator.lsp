;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2010-11 Andrej Andrejev, UDBL
;;; $RCSfile: sparql-translator.lsp,v $
;;; $Revision: 1.9 $ $Date: 2012/09/06 13:46:39 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Translator functionality based on sparql-lsp-parser
;;; =============================================================
;;; $Log: sparql-translator.lsp,v $
;;; Revision 1.9  2012/09/06 13:46:39  andan342
;;; *** empty log message ***
;;;
;;; Revision 1.8  2012/05/17 07:33:11  torer
;;; = -> in
;;;
;;; Revision 1.7  2012/04/25 18:43:13  torer
;;; Renamed function optional() into optional0()
;;;
;;; Revision 1.6  2012/04/22 19:01:18  torer
;;; Removed debug printing
;;;
;;; Revision 1.5  2012/02/28 21:25:05  andan342
;;; New Charsring-based parser with CONSTRUCT capable of handling OPTIONAL and UNION in WHERE-block
;;;
;;; Revision 1.4  2012/01/24 16:41:35  andan342
;;; Now correctly extracting all variables from filter expressions
;;;
;;; Revision 1.3  2012/01/24 11:51:36  andan342
;;; Stable version of String-based parser that allows expressions in filters
;;;
;;; Revision 1.2  2011/10/23 11:47:59  andan342
;;; Collected commonly used parsiong utility functions into parse-utils.lsp
;;;
;;; Revision 1.1  2011/04/06 13:34:35  andan342
;;; Separated translator functionality from parser, devised 2 wrappers:
;;; - vector-based (recommended)
;;; - tuple-based (compatible with rewrites in SARD)
;;;
;;; Revision 1.1  2006/02/12 20:01:09  torer
;;; Folder AmosNT/headers contains CVS header templates
;;;
;;; =============================================================

(load "sparql-lsp-parser.lsp")

(load "sparql-utils.lsp")

(load "uri-to-fn.lsp")

(defvar _sq_ub_ "'<DB NULL>'") ;; Compliant with SWARD/SARD output

(defvar _sq_always_return_vectors_ t)

(defun sparql-var-to-amosql (v substs)
  (let ((subst (assoc v substs))) ;substitute variable names inside OPTIONAL conditions
    (if subst (second subst) v)))

(defun sparql-object-to-amosql (o prefixes substs)
  (selectq (first o)
	   (var (sparql-var-to-amosql (cdr o) substs))
	   ((uri string) (concat "'" (cdr o) "'")) ;;TODO: should handle special characters with AmosQL escapes
	   (prefixed (concat "'" (cdr (assoc (second o) prefixes)) (third o) "'"))
	   "")) ;;default case: object not translated	 

(defun sparql-triples-vars (triples buf)
  (dolist (triple triples buf)
    (dolist (term triple)
      (when (eq (car term) 'var)
	(pushnew-equal (cdr term) buf)))))
    

(defun sparql-block-preprocess (b)
  (let (semibound partial! bound-in-union)
    (dolist (c (block-conds b))
      (setq partial! nil)
      (selectq (car c)
	       (triples (dolist (v (sparql-triples-vars (cdr c) nil))
			  (pushnew-equal v (block-bound b))
			  (pushnew-equal v (block-bound+ b))
			  (pushnew-equal v (block-ref+ b))
			  (pushnew-equal v partial!)))
	       (filter (setf (block-ref+ b) (collect-expr-vars (cdr c) (block-ref+ b) nil)))
	       (optional (sparql-block-preprocess (cdr c)) ; recursive
			 (setf (block-ref* b) (union-equal (block-ref* b) (block-ref* (cdr c))))
			 (setq partial! (block-partial (cdr c))))
	       (union (dolist (u (cdr c))
			(sparql-block-preprocess u) ; recursive
			(if (eq u (second c)) (setq bound-in-union (block-bound+ u))
			  (setq bound-in-union (intersection-equal bound-in-union (block-bound+ u))))
			(setf (block-ref+ b) (union-equal (block-ref+ b) (block-ref+ u)))
			(setq partial! (union-equal partial! (block-partial u))))
		      (setf (block-bound+ b) (union-equal (block-bound+ b) bound-in-union)))			
	       t)
      (dolist (v (intersection-equal semibound partial!))
	(block-inc-rebound b v))
      (setf (block-partial b) (union-equal (block-partial b) partial!))
      (setq semibound (set-difference-equal (block-partial b) (block-bound+ b))))
    (setf (block-ref* b) (union-equal (block-ref* b) (block-ref+ b)))
    b))
    
; (pps (preprocess-bloc (select-stat-where (second (sparql-parse amos_fi0)))))

(defun sparql-block-subblocks (b)
  (let (res)
    (dolist (c (block-conds b))
      (selectq (car c)
	       (optional (push (cdr c) res))
	       (union (dolist (u (cdr c))
			(setq res (append (sparql-block-subblocks u) res)))) ; recursive
	       t)) res))

(defun extend-substs (substs vars modifier)
  "Modify variable names with suffix '_' and either 'i','u' or 'o' modifier, remove trailing 'i' when adding 'o'"
  (let ((res (if vars (copy-tree substs) substs)) ac) 
    (dolist (v vars)
      (setq ac (assoc v res)) 
      (if ac (setf (cdr ac) (if (string= modifier "o") (list (concat (string-right-trim "iu" (second ac)) "o")) 
			      (cons (concat (second ac) modifier) (cdr ac))))
	(push (list v (concat v "_" modifier)) res)))
    res))

(defun noverride-substs (substs vars modifier)
  "Override last modifier of variables with the given one"
  (let (ac)
    (dolist (v vars)
      (setq ac (assoc v substs))
      (setf (cadr ac) (concat (substring 0 (- (length (cadr ac)) 2) (cadr ac)) modifier)))
    substs))

(defun nmerge-substs (base-substs top-substs)
  (let (base-ac)
    (dolist (top-ac top-substs)
      (setq base-ac (assoc (car top-ac) base-substs))
      (if base-ac (dolist (top-i (cdr top-ac))
		    (pushnew-equal top-i (cdr base-ac)))
	(setf base-substs (cons top-ac base-substs))))
    base-substs))

(defun sparql-link-conjunct (newv oldv)
  (concat "((" newv " = " oldv ")or(" oldv " = " _sq_ub_ "))")) ;TODO: sould use one-directional function for this


(defun sparql-to-amosql (query)
  (let* ((pq (sparql-parse query))
	 (stat (second pq)))
    (cond ((select-stat-p stat);;SELECT queries
	   (let ((triples-fn (uri-to-amos-function (select-stat-from stat)))
		 (basic-block (select-stat-where stat)))
	     (sparql-block-preprocess basic-block)	     
	     (concat (sparql-block-to-amosql (list basic-block) (select-stat-what stat) nil nil (first pq) triples-fn 0 stat) ";")))
          ((construct-stat-p stat)
	   (let ((triples-fn (uri-to-amos-function (construct-stat-from stat)))		 
		 (where-block (construct-stat-where stat)))
	     (dolist (c (block-conds (construct-stat-what stat))) ; all variables used in what-block 
	       (when (eq (car c) 'triples) ; are counted as REF+ and REF* in where-block
		 (setf (block-ref+ where-block) (sparql-triples-vars (cdr c) (block-ref+ where-block)))))
	     (setf (block-ref* where-block) (block-ref+ where-block))
	     ;;(pps where-block) ;DEBUG
	     (sparql-block-preprocess where-block)
	     ;;(pps where-block) ;DEBUG
	     ;TODO: add all variables from what-block to REF+ of where-block
	     (concat (sparql-block-to-amosql (list where-block) '("_ss_" "_pp_" "_oo_") nil nil (first pq) triples-fn 0 stat) 
		     (nl 5) " and (" (sparql-construct-disjunction (construct-stat-what stat) (block-bound+ where-block) 
								   (first pq) (block-substs where-block)) ");")
	   ))
	  (t ""))))

(defun sparql-construct-disjunction (b bound+ prefixes substs)
  (let (disjuncts)
    (dolist (c (block-conds b))
      (when (eq (car c) 'triples)
	(dolist (tr (cdr c))
	  (push (concat "(_ss_ = " (sparql-expr-to-amosql (first tr) prefixes substs 0) 
			" and _pp_ = " (sparql-expr-to-amosql (second tr) prefixes substs 0) 
			" and _oo_ = " (sparql-expr-to-amosql (third tr) prefixes substs 0) 
			(strings-to-string (mapcar (f/l (v) (concat " and NEQ(" (sparql-var-to-amosql v substs) 
								    "," _sq_ub_ ")"))
						   (set-difference-equal (sparql-triples-vars (list tr) nil) bound+)) 
					   "" "" "") 
			")") disjuncts))))
    (strings-to-string (nreverse disjuncts) "" (concat (nl 5) "   or ") "")))

(defun sparql-block-to-amosql (b-stack select in-bound in-semibound prefixes triples-fn offset stat)
  (let ((subblocks (sparql-block-subblocks (car b-stack))) tr 
	(ret-vector (if _sq_always_return_vectors_ (or (cdr select) stat) (and (cdr select) (not stat))))
	(declare (union-equal select (set-difference-equal (intersection-equal (block-partial (car b-stack)) (block-ref+ (car b-stack))) in-bound)))) ;1st part of formula for d2(o)
    (print (list 'declare= declare)) ;DEBUG
    (dolist (sb1 subblocks) ; 2nd part of formula for d2(o)
      (dolist (v (block-partial sb1))
	(unless (or (member v declare) (member v in-bound))
	  (dolist (sb2 subblocks) ; cycle terminates when 1st such SB2 found where V belongs to REF*
	    (when (and (not (eq sb2 sb1)) (member v (block-ref* sb2)))
	      (push v declare)
	      (return nil))))))
    (setq tr (sparql-conds-to-amosql b-stack declare in-bound in-semibound prefixes triples-fn offset nil)) ; m-recursive
    (when (or stat (null (third tr))) ; return NIL if conditions of a nested block are always false      
      (concat "select " (if (and (select-stat-p stat) (select-stat-distinct stat)) "distinct " "") 
	      (if ret-vector "{" "") ; if >1 variable returned or translating the basic block - enclose in { }
	      (strings-to-string (mapcar (f/l (v) (sparql-var-to-amosql v (second tr))) select) "" ", " "")
	      (if ret-vector "}" "") (nl offset)
	      "  from " (strings-to-string (nreverse (mapcan (f/l (v) (let ((ac (assoc v (second tr)))) ; TODO: now 'substs' are returned via stack
									(cond ((null ac) (list v)) ; declare all current block's incarnations of variables in DECLARE
									      (stat (append (cdr ac) (list v))) ; original variable also, if basic block
									      (t (cdr ac))))) declare))  "Charstring " ", " "") 
	      (nl offset) " where " (first tr)))))

(defparameter binding-check-skip-fns '((id . "bound"))) ; do not require direct arguments to these FNs to be bound 

(defun sparql-conds-to-amosql (b-stack declare in-bound in-semibound prefixes triples-fn offset u-linked)
  (let ((conjuncts nil) bound! semibound! never-flag (bound-delta in-bound) (semibound-delta in-semibound) new-substs merged merge-substs)
    (dolist (c (block-conds (car b-stack)))
      (setq new-substs nil)
      (selectq (car c)
	       (triples (dolist (triple (cdr c)) ; determine variables bound here
			  (dolist (o triple)
			    (when (eq (car o) 'var) 
			      (pushnew-equal (cdr o) bound!))))
			(setq bound! (set-difference-equal bound! bound-delta))
			(let ((tp-linked (intersection-equal bound! (block-cur-semibound (car b-stack)))) ac) ; only semibound in this block should be counted here (TODO)
			  (setf (block-substs (car b-stack)) (extend-substs (block-substs (car b-stack)) tp-linked "i"))
			  (dolist (triple (cdr c)) ; add triple pattern conjuncts
			    (push (concat "(" (strings-to-string (mapcar (f/l (o) (sparql-object-to-amosql o prefixes (block-substs (car b-stack))))
										       triple) "" ", " "") ") in " triples-fn "()") conjuncts))
			  (dolist (v (union-equal tp-linked (intersection-equal bound! u-linked)))
                            ; add link conjunts for all linked variables, also for semibound variables before (this) union in the parent block
			    (setq ac (assoc v (block-substs (car b-stack)))) ; link variables with their prevous incarnations
			    (push (sparql-link-conjunct (second ac) (if (third ac) (third ac) v)) conjuncts))))
	       (filter (push (sparql-expr-to-amosql (cdr c) prefixes (block-substs (car b-stack)) 0) conjuncts)		       		       
		       (dolist (v (collect-expr-vars (cdr c) nil nil binding-check-skip-fns))  ; add extra conditions for the used semibound variables (with exceptions) to be bound here
			 (cond ((member v semibound-delta) ;if variable is semibound - add extra condition
				(push (concat "NEQ(" (sparql-var-to-amosql v (block-substs (car b-stack))) "," _sq_ub_ ")") conjuncts))
			       ((or (member v in-bound) (member v (block-partial (car b-stack)))) t) ;if variable is neither in-bound nor partial here
			       (t (setq never-flag t))))) ; mark this translation as always false				 
	       (optional (let* ((o-select (set-difference-equal (intersection-equal (block-partial (cdr c)) declare) bound-delta))
					; ^ select variables (partially) bound in optional block, declared but not bound here 
				ret-str o-offset tr pad-arg (link-conjuncts nil))
;			   (print (list 'o-select= o-select 'block-partial= (block-partial (cdr c)) 'declare= declare)) ;DEBUG
			   (when o-select ; proceed only if at least 1 variable is to be selected
			     (setq new-substs (extend-substs (block-substs (car b-stack)) (intersection-equal o-select (block-cur-semibound (car b-stack))) "i")) 
			     (setq ret-str (strings-to-string (mapcar (f/l (v) (sparql-var-to-amosql v new-substs)) o-select)  "" "," ""))
			     (when (cdr o-select) (setq ret-str (concat "{" ret-str "}")))
			     (setq o-offset (+ offset (length ret-str) 18))
			     (setf (block-substs (cdr c)) (extend-substs (block-substs (car b-stack)) o-select "o")) ; substitutions used inside the optional block
			     (setq tr (sparql-block-to-amosql (cons (cdr c) b-stack) o-select bound-delta semibound-delta prefixes triples-fn o-offset nil)) ; m-recursive
			     (setq pad-arg (strings-to-string (mapcar (f/l (v) _sq_ub_) o-select) "" "," ""))
			     (when (cdr o-select) (setq pad-arg (concat "{" pad-arg "}")))
			     (if (null tr) (push (concat ret-str "=" pad-arg) conjuncts) ; optional block never binds
			       (progn ; optional block is translated into query TR
				 (dolist (v o-select)
				   (when (member v (block-bound (cdr c))) ; link only if variable is directly bound in this optional block
				     (dolist (b b-stack)
				       (when (member v (block-cur-semibound b)) ; link variable with incarnation from block where it is (currently) semibound
					 (push (if (cdr o-select) (sparql-link-conjunct (sparql-var-to-amosql v (block-substs (cdr c))) (sparql-var-to-amosql v (block-substs b))) 
						 (concat (sparql-var-to-amosql v (block-substs b)) " = " _sq_ub_)) link-conjuncts) ; simplified link if only 1 variable selected
					 (return t))))) ; do not look further in stack			     
					; add linking statements for semibound optional variables
				 (push (concat ret-str "=optional0(("  tr (strings-to-string link-conjuncts (concat (nl o-offset) "   and ") "" "") ")," pad-arg ")") conjuncts))) 
			     (setq semibound! o-select))))
	       (union (let (partial-in-union linked-in-union rebound-in-union final-substs disjuncts u-tr u-padded)
			(dolist (u (cdr c))
			  (setq partial-in-union (union-equal partial-in-union (block-partial u)))
			  (setq bound! (if (eq u (second c)) (block-bound+ u)
					 (intersection-equal bound! (block-bound+ u))))
			  (setq rebound-in-union (union-equal rebound-in-union (block-rebound u))))
			(setq partial-in-union (set-difference-equal partial-in-union bound-delta))
			(setq semibound! (set-difference-equal partial-in-union bound!))
			(setq linked-in-union (union-equal (intersection-equal (block-cur-semibound (car b-stack)) partial-in-union) rebound-in-union))
			(setq new-substs (extend-substs (block-substs (car b-stack)) (union-equal linked-in-union rebound-in-union) "u"))
			(dolist (u (cdr c))
			  (setf (block-substs u) (noverride-substs (extend-substs (block-substs (car b-stack)) (intersection-equal linked-in-union (block-partial u)) "u") 
								   (block-rebound u) "i"))
			  (setq u-tr (sparql-conds-to-amosql (cons u b-stack) declare bound-delta semibound-delta prefixes triples-fn (+ offset 2) 
							     (union-equal u-linked (block-cur-semibound (car b-stack))))) ; recursive
			  (unless (third u-tr) ; if branch was not marked as 'always false'
			    (setq u-padded (set-difference-equal partial-in-union (block-partial u))) ; add padding conjuncts
			    (when u-padded (setf (first u-tr) (concat (first u-tr) (nl (+ offset 5)) "and " 
								      (strings-to-string (mapcar (f/l (v) (concat (sparql-var-to-amosql v new-substs) 
														  " = " _sq_ub_)) u-padded) "" " and " ""))))
			    (when (block-rebound u) ; add finalizing conjuncts
			      (setf (first u-tr) (concat (first u-tr) (nl (+ offset 5)) "and " 
							 (strings-to-string (mapcar (f/l (v) (concat (sparql-var-to-amosql v new-substs) " = "
												     (sparql-var-to-amosql v (block-substs u)))) (block-rebound u)) "" " and " "")))
			      (unless final-substs (setq final-substs (copy-tree (block-substs (car b-stack))))) ; merge resulting substs into current block's substs
			      (setq final-substs (nmerge-substs final-substs (block-substs u))))
			    (push (first u-tr) disjuncts))) ; add the translated branch
			(push (concat "((" (strings-to-string (nreverse disjuncts) "" (concat ")" (nl (+ offset 4)) "or  (") "") "))") conjuncts) ; add union condition
			(when rebound-in-union (setq new-substs (nmerge-substs final-substs new-substs))))) ;merge new substs
	       t)
      (setq merged (intersection-equal (block-cur-semibound (car b-stack)) semibound!)) ; variales to merge
      (cond (merged ; new-substs was initialized, since semibound! can be non-empty only after OPTIONAL or UNION
	     (setq merge-substs (extend-substs new-substs merged "i"))
	     (dolist (v merged) ; merge variables, new-subst was initialized
	       (push (concat (sparql-var-to-amosql v merge-substs) "=either({" (sparql-var-to-amosql v new-substs) "," 
			     (sparql-var-to-amosql v (block-substs (car b-stack))) "}," _sq_ub_ ")") conjuncts))
	     (setf (block-substs (car b-stack)) merge-substs))
	    (new-substs ; TODO: seems to be redundant
	     (setf (block-substs (car b-stack)) new-substs)))
      (when bound! ; update current bound and semibound sets and their closures
	(setq semibound-delta (set-difference-equal semibound-delta bound!))
	(setf (block-cur-semibound (car b-stack)) (set-difference-equal (block-cur-semibound (car b-stack)) bound!))
	(setq bound-delta (union-equal bound-delta bound!))
	(setf (block-cur-bound (car b-stack)) (union-equal (block-cur-bound (car b-stack)) bound!))
	(setq bound! nil))
      (when semibound! ; update current semibound set and its closure
	(setq semibound-delta (union-equal semibound-delta semibound!))
	(setf (block-cur-semibound (car b-stack)) (union-equal (block-cur-semibound (car b-stack)) semibound!)) ; semibound = semibound + semibound!
	(setq semibound! nil)))
    (list (strings-to-string (nreverse conjuncts) "" (concat (nl offset) "   and ") "") (block-substs (car b-stack)) never-flag)))

(defun collect-expr-vars (e buf stat &optional skip-fns skipped)
  "collect variable names from expression E in BUF, 
   skip variables that are direct arguments to one of SKIP-FNS"  
  (cond ((eq (car e) 'var)
	 (unless (or skipped (member (cdr e) buf)) (pushnew-equal (cdr e) buf)))  
	((listp (cdr e)) ;; process subexpressions recursively
	 (dolist (sub-e (cdr e)) 
	   (when (consp sub-e) (setq buf (collect-expr-vars sub-e buf stat skip-fns 
							    (member (car e) skip-fns)))))))
  buf)

(defun sparql-expr-to-amosql (e prefixes substs base-prec)
  "Translate expression E using PREFIXES for URIs and SUBSTS substitutions for variables,
   put it into parentheses if its precedence is less than BASE-PREC"
  (let ((prec (sparql-expr-prec e)) res)
    (setq res
	  (cond ((atom (car e))
		 (selectq (car e)
			  (ub _sq_ub_)
			  ((string uri) (concat "'" (cdr e) "'"))
			  (var (sparql-var-to-amosql (cdr e) substs))
			  ((blank genblank) (sparql-blank-to-amosql e))
			  (prefixed (concat "'" (cdr (assoc (second e) prefixes)) (third e) "'"))
			  ((= != < > <= >= + and or)
			   (concat (sparql-expr-to-amosql (second e) prefixes substs prec) " " (string-downcase (mkstring (car e))) " "
				   (sparql-expr-to-amosql (third e) prefixes substs prec)))
			  (not (let ((opposite-op (cdr (assoc (caadr e) '((= . !=) (< . >=) (> . <=) (!= . =) (>= . <) (<= . >))))))
				 ;;since there is no 'not' in Amos, do rewrites:
				 (cond (opposite-op (sparql-expr-to-amosql (cons opposite-op (cdadr e)) prefixes substs base-prec))
				       ((equal (caadr e) '(id . "bound")) ; not(bound(x)) -> x = UB()
					(sparql-expr-to-amosql (list '= (car (cdadr e)) '(ub)) prefixes substs base-prec))
				       ((or (member (caadr e) '(+ - * / u- number)) (listp (caadr e))) ;; not(number) -> number = 0
					(sparql-expr-to-amosql (list '= (cadr e) '(number . 0)) prefixes substs base-prec))
				       ((eq (caadr e) 'var) (let ((v (sparql-var-to-amosql (cdadr e) substs)))
							      (setq prec (sparql-expr-prec '(or))) ; precedence value for OR
							      (concat "notany(" v ") or (" v " = 0) or (" v " = '')")))
				       (t "false")))) ;;the case for URIs and strings
			  (cdr e))) ; expect direct Amos representation in other cases 
		((and (listp (car e)) (eq (caar e) 'id)) ; FNCALL
		 (cond ((string= (cdar e) "regex") ; regex translation: preprocess arguments if constants provided
			(concat "like(" (sparql-expr-to-amosql (second e) prefixes substs 0) ", '" 
				(if (eq (car (third e)) 'string) (aregex (cdr (third e)))
				  (error "2nd argument to REGEX should be string!")) "')"))
		       (t (concat (cdar e) "(" (strings-to-string (mapcar (f/l (arg) (sparql-expr-to-amosql arg prefixes substs 0))
									  (cdr e)) "" ", " "") ")"))))))
    (if (> base-prec prec) (concat "(" res ")") res)))

(defun sparql-expr-prec (e)
  "Amos root precedence of translated SparQL expression"
  (selectq (car e)
	   (or 1)
	   (and 2)
	   ((= != < > >= <=) 3)
	   (+ 4)
	   (not 6)
	   7)) ; literals, variables, fncalls, arefs


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; WRAPPER ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(foreign-lispfn parse_sparql ((Charstring query)) ((Charstring))
		(foreign-result (sparql-to-amosql query)))