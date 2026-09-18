;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Tore Risch, UDBL
;;; $RCSfile: sqlmap.lsp,v $
;;; $Revision: 1.3 $ $Date: 2013/05/01 15:31:09 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Mapping local SQL tables to external RDB
;;; =============================================================
;;; $Log: sqlmap.lsp,v $
;;; Revision 1.3  2013/05/01 15:31:09  minzh812
;;; add new test cases.
;;;
;;; Revision 1.2  2013/01/05 18:20:34  torer
;;; Another example
;;;
;;; Revision 1.1  2013/01/05 17:49:38  torer
;;; Added mapped SQL test
;;;
;;; =============================================================

(import-table amos_a nil nil 'employee 'employee_a nil nil)
(import-table amos_b nil nil 'employee 'employee_b nil nil)
(import-table amos_a nil nil 'department 'department_a nil nil)
(import-table amos_b nil nil 'department 'department_b nil nil)
(import-table amos_a nil nil 'country 'country_a nil nil)
(import-table amos_b nil nil 'country 'country_b nil nil)


(checkequal 
 "Mapping local SQL to external relations"
 ((length (sql "select * from employee_a")) 42)
 ((length (sql "select * from country_b")) 14)
 ((length (sql "select * from department_a")) 21)
 ((sql "select first_name from employee_a
        where salary > 15000 and salary < 30000 and first_name like 'A%'")
  '(("Ann")))
 ((plan-trail _select_) 'apply_pred)
 ((sorttuples (sql "select a.country from country_a a, country_a b
                    where a.currency = 'dollar' and b.currency='dollar' 
                    and a.country=b.country"))
  '(("australia") ("fiji") ("hong kong") ("usa")))
 ((plan-trail _select_) 'apply_pred); one SQL generated
 ((sorttuples (sql "select a.first_name
                    from employee_a a, employee_a b
                    where a.first_name=b.first_name and a.emp_no <> b.emp_no"))
  '(("Leslie") ("Leslie") ("Roger") ("Roger"))); 
 ((plan-trail _select_) 'apply_pred)
 ((sorttuples (sql "select a.first_name
                    from employee_a a, employee_a b
                    where a.first_name=b.first_name and a.emp_no <> b.emp_no 
                          and a.salary<50000"))
  '(("Roger"))) 
 ((plan-trail _select_) 'apply_pred)
 ((sql "select a.last_name, b.last_name
                    from employee_a a, employee_a b
                    where a.first_name=b.first_name and a.emp_no <> b.emp_no 
                          and a.salary<50000 and b.salary>60000")
  '(("Reeves" "De Souza")))
 ((plan-trail _select_) 'apply_pred)
 ((sorttuples (sql "select distinct a.first_name
                    from employee_a a, employee_a b
                    where a.first_name=b.first_name and a.emp_no <> b.emp_no"))
  '(("Leslie") ("Roger"))) 
 ((plan-trail _select_) 'apply_pred)
)

(checkequal 
  "Multidatabase queries"
 ((sorttuples (sql "select a.country from country_a a, country_b b
                    where a.currency = 'dollar' and b.currency='dollar' 
                    and a.country=b.country"))
  '(("australia") ("fiji") ("hong kong") ("usa")))
 ((plan-trail _select_) '(and apply_pred apply_pred))
 ((sorttuples (sql "select a.first_name
                    from employee_a a, employee_b b
                    where a.first_name=b.first_name and a.emp_no <> b.emp_no"))
  '(("Leslie") ("Leslie") ("Roger") ("Roger")))
 ((plan-trail _select_) '(and apply_pred apply_pred))
 ((sorttuples (sql "select distinct a.first_name
                    from employee_a a, employee_b b
                    where a.first_name=b.first_name and a.emp_no <> b.emp_no"))
  '(("Leslie") ("Roger"))) 
 ((plan-trail _select_) '(and apply_pred apply_pred))
 ((sorttuples (sql "select a.first_name
                    from employee_a a, employee_b b
                    where a.first_name=b.first_name and a.emp_no <> b.emp_no 
                          and a.salary<50000"))
  '(("Roger"))) 
 ((plan-trail _select_) '(and apply_pred apply_pred))
 ((sql "select a.last_name, b.last_name
                    from employee_a a, employee_b b
                    where a.first_name=b.first_name and a.emp_no <> b.emp_no 
                          and a.salary<50000 and b.salary>60000")
  '(("Reeves" "De Souza")))
 ((plan-trail _select_) '(and apply_pred apply_pred))
)

(checkequal 
  "Disjunctive queries"
 ((sorttuples (sql "select last_name from employee_a
                    where first_name = 'Janet' or first_name = 'Pete'"))
  '(("Baldwin")("Fisher")))
 ((plan-trail _select_) 'apply_pred)
 ((sorttuples (sql "select last_name from employee_a
                    where first_name = 'Janet' or last_name = 'Fisher'"))
  '(("Baldwin")("Fisher")))
 ((plan-trail _select_) '(OR APPLY_PRED (AND = APPLY_PRED)))
)

(let (*use-dnf*)
  (checkequal 
   "Disjunctive queries not using DNF"
   ((sorttuples (sql "select last_name from employee_a
                      where first_name = 'Janet' or first_name = 'Pete'"))
    '(("Baldwin")("Fisher")))
   ((plan-trail _select_) 'apply_pred)
   ((sorttuples (sql "select last_name from employee_a
                      where first_name = 'Janet' or last_name = 'Fisher'"))
    '(("Baldwin")("Fisher")))
   ((plan-trail _select_) 'apply_pred) ;;push or into sql string
   )
  )