;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2012 Thanh Truong, UDBL
;;; $RCSfile: num.lsp,v $
;;; $Revision: 1.1 $ $Date: 2012/05/27 09:52:56 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Test for numerical wrapper / translator
;;; =============================================================


(checkequal
 "Numerical SQL translator does not change results"
 ((osql "qn1();")
  '(("Ann")))
 ((osql "qn2();")
  '(("Ann")))
 ((osql "qn3();")
  '(("Ann")))
 ((osql "qn4();")
  '(("Ann")))
 ((osql "qn5();")
  '(("Ann")))
 ((osql "qn6();")
  '(("Ann")))
 ((osql "qn10();")
  '(("Robert") ("Bruce") ("Kim") ("Leslie") ("Phil") ("K. J.") ("Terri") ("Stewart") ("Katherine") ("Chris") ("Pete") ("Ann") ("Roger") ("Janet") ("Roger") ("Willie") ("Leslie") ("Ashok") ("Walter") ("Carol") ("Luke") ("Sue Anne") ("Jennifer M.") ("Claudia") ("Dana") ("Mary S.") ("Randy") ("Oliver H.") ("Kevin") ("Kelly") ("Yuki") ("Mary") ("Bill") ("Takashi") ("Roberto") ("Michael") ("Jacques") ("Scott") ("T.J.") ("Pierre") ("John") ("Mark")))
)

;;(break extract-sql)


(checkequal
"Numerical SQL translator pushes in numerical expression in SQL"
((contain-sql-pattern "*(SALARY + 1000) < 30000*" 'qn1) t)
((contain-sql-pattern "*44000 = SALARY + SALARY*" 'qn2) t)
((contain-sql-pattern "*((SALARY + 1000) + 12) < 30000*" 'qn3) t)
((contain-sql-pattern "* SALARY < (30000 + EMP_NO)*" 'qn4) t)
((contain-sql-pattern "*((SALARY - 1000) + 89) < 30000*" 'qn5) t)
((contain-sql-pattern "*(((SALARY - 100) / 2) + 50) < 30000*" 'qn6) t)
((contain-sql-pattern "*(SALARY * 2) > 15000*" 'qn10) t)
)


(checkequal
 "Numerical SQL translator pushes in Date"
 ((contain-sql-pattern "* > HIRE_DATE*" 'qn7) t)
 ((contain-sql-pattern "* > HIRE_DATE*" 'qn8) t))
