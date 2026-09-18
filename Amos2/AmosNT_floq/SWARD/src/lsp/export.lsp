;;;Implemetation of foreign function applyTripleFn.
(defun applytriples (fno fn s p v)
  (mapfunction fn nil 
	       (f/l (row)
		    (osql-result fn (first row)(second row)(third row)))))

;;;Foreign fn that applies a function f representing the column 
;;;triple extent of a column in a relational database and returns 
;;;the result as a bag of RDF triples
(set-type-container (osql "create function applyTripleFn(Function fn) 
			-> <Charstring, Charstring, Charstring>
  			as foreign 'applytriples';"))

;;; Define TR rewrite rule:
(define-tr-rewriter 'FUNCTION.APPLYTRIPLEFN->CHARSTRING.CHARSTRING.CHARSTRING
  'applytriple-test 'applytriple-transform)

(defun applytriple-test (pred rest)
  "Tests in first argument of APPLYTRIPLES constant"
  (oid-p (cadr pred)))

(defun applytriple-transform (pred rest)
  "Generates rewritten conjunction"
  (let ((fno (cadr pred))
	(args (cddr pred)))
    (expand-predicate (cons fno args) nil)))

;;;Create a row identifier.
(set-type-container 
 (osql "
create function rowID(Charstring uri,Literal val)->Charstring rid 
  as multidirectional ('bbf' foreign 'cbbf' cost {1,1})
	              ('ffb' foreign 'cffb' cost {1,1});"))










