:osql
create type person;
create function name(person)->charstring n;
create function age(person)->integer a;
create function id(person)->integer i;
create person(id, name, age) instances :a(1, "Markus", 30), :b(2, "Fredrik", 33), 
    :c(3, "Daniel", 26), :d(4, "Elin", 26);
create function #person2(integer id)-><charstring name, integer age> as
   select n, a 
   from charstring n, integer a, person p 
   where id=id(p) and n=name(p) and a=age(p);

lisp;

(eval (sql-parse "select * from person2;"))
(eval (sql-parse "select p1.name, p2.name, p1.age-p2.age from person2 p1 inner join person2 p2 on p1.age>p2.age;"))


;(setq n (list 'OSQL-SELECT (list (pack "#PERSON2.SSN") (pack "#PERSON2.NAME") (pack "#PERSON2.AGE")) 
;      'FOREACH (list (list 'INTEGER (pack "#PERSON2.SSN"))
;                     (list 'CHARSTRING (pack "#PERSON2.NAME"))
;                     (list 'INTEGER (pack "#PERSON2.AGE"))) 
;      'WHERE (list 'AND (list '= (list (pack "#PERSON2") (pack "#PERSON2.SSN"))
;                                 (list 'TUPLE (pack "#PERSON2.NAME") (pack "#PERSON2.AGE"))))))