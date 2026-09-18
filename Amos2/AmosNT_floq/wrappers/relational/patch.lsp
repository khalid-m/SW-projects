(defun greater--+ (fn a b res)
  (osql-result a b (max a b)))

(defun lesser--+ (fn a b res)
  (osql-result a b (min a b)))

(osql " 

create function greater(Number a, Number b) -> Number as foreign 'greater--+';
 create function lesser(Number a, Number b) -> Number as foreign 'lesser--+';
create_wrapper_absorbability('relational','greater');
create_wrapper_absorbability('relational','lesser');


sqloperator('greater', 'dbo.greater', false, true, false);
sqloperator('lesser', 'dbo.lesser', false, true, false);

")


