;;; ============================================================
;;; AMOS2
;;; 
;;; Author: (c) 2004 Markus Jägerskogh, UDBL
;;; $RCSfile: sql-testquery.lsp,v $
;;; $Revision: 1.11 $ $Date: 2012/02/04 17:14:19 $
;;; $State: Exp $ $Locker:  $
;;;
;;; Description: Regression test for SQLFront - insert data
;;; =============================================================

;** sql\flg005.sql
;**
;** 
(sql "SCHEMA HU;")
(sql "UPDATE STAFF SET GRADE = -GRADE;")
(checkequal "SQL Test suite\\\sql\\\flg005.sql"
  ((sql "SELECT COUNT(*) FROM STAFF WHERE GRADE IN (12.0, -12.0);") '((2)))
)
(sql "ROLLBACK WORK;")


;** sql\sdl026.sql
;**
;** Test schema definition language, Entry SQL
(sql "SCHEMA CANWEPARSELENGTH18;")
(sql "DELETE FROM CHARACTER18TABLE18;")
(sql "INSERT INTO CHARACTER18TABLE18 VALUES ('VALU');")
(checkequal "SQL Test suite\\\sql\\\sdl026.sql"
  ((sql "SELECT COUNT(*) FROM CHARACTER18TABLE18;") '((1)))
  ((sql "UPDATE CHARACTER18TABLE18 SET CHARS18NAME18CHARS = 'VAL4' WHERE CHARS18NAME18CHARS = 'VALU';") 'nil)
  ((sql "SELECT COUNT(*) FROM CHARACTER18TABLE18 
         WHERE CHARS18NAME18CHARS = 'VAL4';") '((1)))
  ((sql "SELECT CORRELATIONNAMES18.CHARS18NAME18CHARS 
         FROM CANWEPARSELENGTH18.CHARACTER18TABLE18 CORRELATIONNAMES18 
         WHERE CORRELATIONNAMES18.CHARS18NAME18CHARS = 'VAL4';") '(("VAL4")))
)
(sql "DELETE FROM CHARACTER18TABLE18;")
(sql "COMMIT WORK;")


;** sql\\sdl005.sql
;**
;** Test schema definition language, Entry SQL
(sql "SCHEMA CUGINI;")
(checkequal "SQL Test suite\\sql\\sdl005.sql"
 ((sql "SELECT EMPNUM,PNUM FROM HU.WORKS WHERE EMPNUM = 'E3';") 
  '(("E3" "P2")))
 ((sql "UPDATE HU.WORKS SET EMPNUM = 'E8',PNUM = 'P8' WHERE EMPNUM = 'E3';") 
  'nil)
 ((sql "SELECT EMPNUM,PNUM FROM HU.WORKS WHERE EMPNUM='E8';") 
  '(("E8" "P8")))
 )
(sql "ROLLBACK WORK;")


;** sql\\dml087.sql
;**
;** Test schema definition language, Entry SQL
(sql "SCHEMA FLATER;")
(checkequal 
 "SQL Test suite\\sql\\dml087.sql -- TEST:0520"
 ((sql "SELECT COUNT(*) FROM USIG WHERE C1 = 0;") '((1)))
 ((sql "SELECT COUNT(*) FROM USIG WHERE C1 = 2;") '((0)))
 ((sql "SELECT COUNT(*) FROM USIG WHERE C_1 = 0;") '((0)))
 ((sql "SELECT COUNT(*) FROM USIG WHERE C_1 = 2;") '((1)))
 ((sql "SELECT COUNT(*) FROM USIG WHERE C1 = 4;") '((0)))
 ((sql "SELECT COUNT(*) FROM U_SIG WHERE C1 = 0;") '((0)))
 ((sql "SELECT COUNT(*) FROM U_SIG WHERE C1 = 4;") '((1)))
 ((sql "SELECT COUNT(*) FROM HU.STAFF WHERE GRADE > 10;") '((4)))
 ((sql "SELECT COUNT(*) FROM HU.STAFF WHERE GRADE < 10;") '((0)))
 )
(sql "ROLLBACK WORK;")


;** sql\sdl032.sql
;**
;** Test schema definition language, Entry SQL
(sql "SCHEMA FLATER;")
;14: -- TEST:0472 Priv.violation: individual SELECT, column UPDATE!
(checkequal "SQL Test suite\\sql\\sdl032.sql -- TEST:0472"
  ((sql "SELECT EMPNUM, EMPNAME, GRADE, CITY FROM HU.STAFF3 WHERE EMPNUM = 'E1';") '(("E1" "Alice" 12.0 "Deale")))
  ((sql "UPDATE HU.STAFF3 SET EMPNUM = 'E0' WHERE EMPNUM = 'E1';") 'nil)
  ((sql "select count(*) from HU.STAFF3 where EMPNUM = 'E0'") '((1)))
  ((sql "UPDATE HU.STAFF3 SET EMPNAME = 'Larry' WHERE EMPNUM = 'E0';") 'nil)
  ((sql "select EMPNAME FROM HU.STAFF3 WHERE EMPNUM = 'E0';") '(("Larry")))
  ((sql "SELECT COUNT(*) FROM HU.STAFF3;") '((5)))
)
(sql "ROLLBACK WORK;")
; -- TEST:0484 Priv.violation: SELECT and column UPDATE on view!
(checkequal "SQL Test suite\\sql\\sdl032.sql -- TEST:0484"
  ((sql "SELECT EMPNUM, EMPNAME, GRADE, CITY FROM HU.VSTAFF3 WHERE EMPNUM = 'E1';") '(("E1" "Alice" 12.0 "Deale")))
  ((sql "UPDATE HU.VSTAFF3 SET EMPNUM = 'E0' WHERE EMPNUM = 'E1';") 'nil)
  ((sql "UPDATE HU.VSTAFF3 SET EMPNAME = 'Larry' WHERE EMPNUM = 'E0';") 'nil)
  ((sql "SELECT EMPNUM, EMPNAME, GRADE, CITY FROM HU.VSTAFF3 WHERE EMPNUM = 'E0';") '(("E0" "Larry" 12.0 "Deale")))
  ((sql "SELECT COUNT(*) FROM HU.VSTAFF3;") '((5)))
)
(sql "ROLLBACK WORK;")


;** sql\dml001.sql
;**
;** Test schema definition language, Entry SQL
(sql "SCHEMA HU;")
(checkequal "SQL Test suite\\sql\\dml001.sql -- TEST:0001"
  ((sql "SELECT EMPNUM,HOURS FROM WORKS WHERE PNUM='P2' ORDER BY EMPNUM DESC;") '((("E4" 20.0)) (("E3" 20.0)) (("E2" 80.0)) (("E1" 20.0))))
  ((sql "SELECT EMPNUM,HOURS FROM WORKS WHERE PNUM='P2' ORDER BY 2 ASC;") '((("E1" 20.0)) (("E4" 20.0)) (("E3" 20.0)) (("E2" 80.0))))
  ((sql "SELECT EMPNUM,HOURS FROM WORKS WHERE PNUM = 'P2' ORDER BY 2 DESC,EMPNUM DESC;") '((("E2" 80.0)) (("E4" 20.0)) (("E3" 20.0)) (("E1" 20.0))))
)


;** sql\dml008.sql
;**
;** Test schema definition language, Entry SQL
(sql "SCHEMA HU;")
(checkequal "SQL Test suite\\sql\\dml001.sql"
  ((sql "SELECT ALL EMPNUM FROM WORKS WHERE HOURS = 12.0;") '(("E1") ("E1")))
  ((sql "SELECT DISTINCT EMPNUM FROM WORKS WHERE HOURS = 12.0;") '(("E1")))
  ((sql "SELECT EMPNUM,PNUM FROM WORKS WHERE EMPNUM = 'E16';") 'nil)
  ((sql "SELECT EMPNUM,HOURS FROM WORKS WHERE EMPNUM = 'E1' AND PNUM = 'P4';") '(("E1" 20.0)))
)
(sql "ROLLBACK WORK;")


;** sql\dml009.sql
;**
;** Test schema definition language, Entry SQL
(sql "SCHEMA HU;")
(sql "DELETE FROM TEMP_S;")
(sql "COMMIT WORK;")
(sql "INSERT INTO TEMP_S(EMPNUM,GRADE,CITY) VALUES('E23',2323.4,'China');")
(checkequal "SQL Test suite\\sql\\dml009.sql"
  ((sql "SELECT COUNT(*) FROM TEMP_S;") '((1)))
  ((sql "INSERT INTO TEMP_S VALUES('E23',23234,'China');") 'nil)
  ((sql "SELECT COUNT(*) FROM TEMP_S;") '((2)))
  ((sql "ROLLBACK WORK;") 'nil)
  ((sql "SELECT COUNT(*) FROM STAFF;") '((5)))
)


;** sql\dml010.sql
;**
;** Test schema definition language, Entry SQL
(sql "SCHEMA HU;")
(sql "INSERT INTO TMP (T1, T2, T3) VALUES ('xxxxxxxxxx', 23,'xxxxxxxxxx'); ")
(checkequal "SQL Test suite\\sql\\dml010.sql"
  ((sql "SELECT * FROM TMP WHERE T2 = 23.0;") '(("xxxxxxxxxx" 23.0 "xxxxxxxxxx")))
)
(sql "ROLLBACK WORK;")


;** sql\dml013.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
(checkequal "SQL Test suite\\sql\\dml013.sql"
  ((sql "SELECT COUNT(DISTINCT HOURS) FROM WORKS;") '((4)))
  ((sql "SELECT SUM(ALL HOURS) FROM WORKS;") '((464.0)))
  ((sql "SELECT SUM(HOURS) FROM WORKS;") '((464.0)))
  ((sql "SELECT COUNT(*) FROM WORKS;") '((12)))
  ((sql "SELECT SUM(HOURS) FROM WORKS WHERE PNUM = 'P2';") '((140.0)))
  ((sql "SELECT SUM(DISTINCT HOURS) FROM WORKS WHERE PNUM = 'P2';") '((100.0)))
  ((sql "SELECT SUM(HOURS)+10 FROM WORKS WHERE PNUM = 'P2';") '((150.0)))
  ((sql "SELECT AVG(GRADE) FROM STAFF;") '((12.0)))
  ((sql "DELETE FROM TEMP_S;") 'nil)
  ((sql "SELECT AVG(GRADE) FROM TEMP_S;") '((NIL)))
)
(sql "ROLLBACK WORK;")


;** sql\dml014.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
(checkequal "SQL Test suite\\sql\\dml014.sql"
  ((sql "SELECT PNUM FROM PROJ WHERE BUDGET BETWEEN 40000 AND 60000;") '(("P6")))
  ((sql "SELECT PNUM FROM PROJ WHERE BUDGET >= 40000 AND BUDGET <= 60000;") '(("P6")))
  ((sql "SELECT CITY FROM STAFF WHERE GRADE NOT BETWEEN 12 AND 13;") '(("Vienna")))
  ((sql "SELECT CITY FROM STAFF WHERE NOT(GRADE BETWEEN 12 AND 13);") '(("Vienna")))
  ((sql "SELECT WORKS.HOURS FROM WORKS WHERE WORKS.PNUM NOT IN ('P1', 'P2', 'P3', 'P4', 'P5');") '((12.0)))
  ((sql "SELECT WORKS.HOURS FROM WORKS WHERE NOT (WORKS.PNUM IN ('P1', 'P2', 'P3', 'P4', 'P5'));") '((12.0)))
  ((sql "SELECT HOURS FROM WORKS WHERE PNUM NOT IN ('P1','P2','P4','P5','P6');") '((80.0)))
  ((sql "SELECT HOURS FROM WORKS WHERE NOT (PNUM IN ('P1','P2','P4','P5','P6'));") '((80.0)))
  ((sql "SELECT EMPNAME FROM STAFF WHERE EMPNAME LIKE 'Al%';") '(("Alice")))
  ((sql "SELECT CITY FROM STAFF WHERE EMPNAME LIKE 'B__t%';") '(("Vienna")))
  ((sql "INSERT INTO STAFF VALUES('E36','Huyan',36,'Xi_an%');") 'nil)
  ((sql "select count(*) from staff") '((6)))
  ((sql "SELECT COUNT(*) FROM STAFF WHERE EMPNUM NOT LIKE '_36';") '((5)))
  ((sql "SELECT COUNT(*) FROM STAFF WHERE NOT(EMPNUM LIKE '_36');") '((5)))
)
(sql "ROLLBACK WORK;")


;** sql\dml015.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
(sql "INSERT INTO TEMP_S VALUES ('E1', 12.0, 'Deale'), ('E2', 10.0, 'Vienna'), ('E3', 13.0, 'Vienna'), ('E4', 12.0, 'Deale'), ('E5', 13.0, 'Akron')")
(checkequal "SQL Test suite\\sql\\dml015.sql"
  ((sql "SELECT COUNT(*) FROM TEMP_S") '((5)))
  ((sql "COMMIT WORK;") 'nil)
  ((sql "ROLLBACK WORK;") 'nil)
  ((sql "SELECT COUNT(*) FROM TEMP_S;") '((5)))
  ((sql "DELETE FROM TEMP_S WHERE EMPNUM = 'E5';") 'nil)
  ((sql "SELECT COUNT(*) FROM TEMP_S;") '((4)))
  ((sql "ROLLBACK WORK;") 'nil)
  ((sql "SELECT COUNT(*) FROM TEMP_S;") '((5)))
)
(sql "DELETE FROM TEMP_S;")
(sql "COMMIT WORK;")


;** sql\dml018.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
(defun sort-result (l)(sort l (function list<)))

(checkequal "SQL Test suite\\sql\\dml018.sql"
  ((sql "SELECT PNUM FROM WORKS WHERE PNUM > 'P1' GROUP BY PNUM HAVING COUNT(*) > 1;") '(("P2") ("P4") ("P5")))
  ((sql "SELECT PNUM FROM WORKS GROUP BY PNUM HAVING COUNT(*) > 2;") '(("P2")))
  ((sort-result (sql "SELECT EMPNUM, PNUM, HOURS FROM WORKS GROUP BY PNUM, EMPNUM, HOURS HAVING MIN(HOURS) > 12 AND MAX(HOURS) < 80;"))
   '(("E1" "P1" 40.0) ("E1" "P2" 20.0) ("E1" "P4" 20.0) ("E2" "P1" 40.0) ("E3" "P2" 20.0)  ("E4" "P2" 20.0) ("E4" "P4" 40.0)))
  ((sql "SELECT SUM(HOURS) FROM WORKS HAVING MIN(PNUM) > 'P0';") '((464.0)))
)


;** sql\dml019.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
(checkequal "SQL Test suite\\sql\\dml019.sql"
  ((sql "SELECT PNUM, SUM(HOURS) FROM WORKS GROUP BY PNUM;") '(("P1" 80.0) ("P2" 140.0) ("P3" 80.0) ("P4" 60.0) ("P5" 92.0) ("P6" 12.0)))
  ((sql "SELECT EMPNUM FROM WORKS GROUP BY EMPNUM;") '(("E1") ("E2") ("E3") ("E4")))
  ((sql "SELECT EMPNUM,HOURS FROM WORKS GROUP BY EMPNUM,HOURS;") '(("E1" 40.0) ("E1" 80.0) ("E1" 20.0) ("E1" 12.0) ("E2" 40.0) ("E2" 80.0) ("E3" 20.0) ("E4" 20.0) ("E4" 40.0) ("E4" 80.0)))
  ((length (sql "SELECT * FROM WORKS GROUP BY PNUM,EMPNUM,HOURS;")) 12)
  ((length (sql "SELECT PNUM,EMPNUM FROM WORKS GROUP BY EMPNUM,PNUM,HOURS;")) 12)
)


;** sql\dml020.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
(checkequal "SQL Test suite\\sql\\dml020.sql"
  ((sorttuples (sql "SELECT EMPNUM,EMPNAME,GRADE,STAFF.CITY, PNAME, PROJ.CITY FROM STAFF, PROJ WHERE STAFF.CITY = PROJ.CITY;"))
   '(("E1" "Alice" 12.0 "Deale" "MXSS" "Deale")   ("E1" "Alice" 12.0 "Deale" "PAYR" "Deale")
     ("E1" "Alice" 12.0 "Deale" "SDP" "Deale")    ("E2" "Betty" 10.0 "Vienna" "CALM" "Vienna")
     ("E2" "Betty" 10.0 "Vienna" "IRM" "Vienna")  ("E3" "Carmen" 13.0 "Vienna" "CALM" "Vienna")
     ("E3" "Carmen" 13.0 "Vienna" "IRM" "Vienna") ("E4" "Don" 12.0 "Deale" "MXSS" "Deale")
     ("E4" "Don" 12.0 "Deale" "PAYR" "Deale")     ("E4" "Don" 12.0 "Deale" "SDP" "Deale")))
  ((sorttuples (sql "SELECT EMPNUM,EMPNAME,GRADE,STAFF.CITY,PNUM,PNAME,PTYPE,BUDGET,PROJ.CITY
         FROM STAFF, PROJ
         WHERE STAFF.CITY = PROJ.CITY AND GRADE <> 12.0;"))
   '(("E2" "Betty" 10.0 "Vienna" "P2" "CALM" "Code" 30000.0 "Vienna")
     ("E2" "Betty" 10.0 "Vienna" "P5" "IRM" "Test" 10000.0 "Vienna")
     ("E3" "Carmen" 13.0 "Vienna" "P2" "CALM" "Code" 30000.0 "Vienna")
     ("E3" "Carmen" 13.0 "Vienna" "P5" "IRM" "Test" 10000.0 "Vienna")))
  ((sorttuples (sql "SELECT DISTINCT STAFF.CITY, PROJ.CITY
         FROM STAFF, WORKS, PROJ
         WHERE STAFF.EMPNUM = WORKS.EMPNUM AND WORKS.PNUM = PROJ.PNUM
         GROUP BY STAFF.CITY, PROJ.CITY;"))
   '(("Deale" "Deale") ("Deale" "Tampa") ("Deale" "Vienna") ("Vienna" "Deale") ("Vienna" "Vienna")))
  ((sorttuples (sql "SELECT FIRST1.EMPNUM, SECOND2.EMPNUM
         FROM STAFF FIRST1, STAFF SECOND2 
         WHERE FIRST1.CITY = SECOND2.CITY AND FIRST1.EMPNUM < SECOND2.EMPNUM;"))
   '(("E1" "E4") ("E2" "E3")))
)


;** sql\dml021.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
(sql "INSERT INTO AA VALUES('abcdefghijklmnopqrst');")
(checkequal "SQL Test suite\\sql\\dml021.sql"
  ((sql "SELECT CHARTEST FROM AA;") '(("abcdefghijklmnopqrst")))
  ((sql "ROLLBACK WORK;") 'nil)
  ((sql "INSERT INTO BB VALUES('a');") 'nil)
  ((sql "SELECT CHARTEST FROM BB;") '(("a")))       ; CHAR
  ((sql "ROLLBACK WORK;") 'nil)
  ((sql "INSERT INTO CC VALUES('abcdefghijklmnopqrst');") 'nil)
  ((sql "SELECT CHARTEST FROM CC;") '(("abcdefghijklmnopqrst")))
  ((sql "ROLLBACK WORK;") 'nil)
  ((sql "INSERT INTO DD VALUES('a');") 'nil)
  ((sql "SELECT CHARTEST FROM DD;") '(("a")))
  ((sql "ROLLBACK WORK;") 'nil)
  ((sql "INSERT INTO EE VALUES(123456);") 'nil)
  ((sql "SELECT INTTEST FROM EE;") '((123456)))     ;* INT
  ((sql "ROLLBACK WORK;") 'nil)
  ((sql "INSERT INTO FF VALUES(123456);") 'nil)
  ((sql "SELECT INTTEST FROM FF;") '((123456)))
  ((sql "ROLLBACK WORK;") 'nil)
  ((sql "INSERT INTO HH VALUES(123);") 'nil)
  ((sql "SELECT * FROM HH; ") '((123)))             ;* SMALL INT
  ((sql "ROLLBACK WORK;") 'nil)
  ((sql "INSERT INTO MM VALUES(7);") 'nil)          ;* NUMERIC
  ((sql "SELECT * FROM MM;") '((7)))
  ((sql "ROLLBACK WORK;") 'nil)
  ((sql "DELETE FROM NN;") nil)                     ;* NUMERIC(9)
  ((sql "INSERT INTO NN VALUES(123456789);") 'nil)
  ((sql "SELECT * FROM NN;") '((123456789)))
  ((sql "ROLLBACK WORK;") 'nil)
  ((sql "INSERT INTO OO VALUES(123456789);") 'nil)
  ((sql "SELECT NUMTEST FROM OO;") '((123456789)))
  ((sql "ROLLBACK WORK;") 'nil)
  ((sql "INSERT INTO QQ VALUES(56);") 'nil)         ;* DECIMAL
  ((sql "SELECT * FROM QQ;") '((56.0)))
  ((sql "ROLLBACK WORK;") 'nil)
  ((sql "INSERT INTO RR VALUES(12345678);") 'nil)   ;* DECIMAL(8)
  ((sql "SELECT * FROM RR;") '((12345678.0)))
  ((sql "ROLLBACK WORK;") 'nil)
)


;** sql\dml023.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
(checkequal "SQL Test suite\\sql\\dml023.sql"
  ((sorttuples (sql "SELECT PNUM FROM PROJ WHERE CITY <> 'Deale';")) '(("P2") ("P3") ("P5")))
  ((sql "SELECT COUNT(*) FROM WORKS WHERE EMPNUM = 'E1';") '((6)))
  ((sql "UPDATE STAFF SET GRADE = 0.0 WHERE EMPNUM = 'E1' OR EMPNUM = 'E3' OR EMPNUM = 'E5';") 'nil)
  ((sql "SELECT COUNT(*) FROM HU.STAFF WHERE GRADE=0.0") '((3)))
  ((sql "SELECT EMPNUM,GRADE FROM STAFF ORDER BY GRADE,EMPNUM;")
   '((("E1" 0.0)) (("E3" 0.0)) (("E5" 0.0)) (("E2" 10.0)) (("E4" 12.0))))
)
(sql "ROLLBACK WORK;")


;** sql\dml024.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
(checkequal "SQL Test suite\\sql\\dml024.sql"
  ((sorttuples (sql "SELECT EMPNUM,CITY FROM STAFF WHERE EMPNUM='E1' OR NOT(EMPNUM='E1');"))
   '(("E1" "Deale") ("E2" "Vienna") ("E3" "Vienna") ("E4" "Deale") ("E5" "Akron")))
  ((sql "SELECT EMPNUM,CITY FROM STAFF WHERE EMPNUM='E1' AND NOT(EMPNUM='E1');") nil)
)
;27: -- PASS:0109 If 0 rows are selected ?
;29: -- END TEST >>> 0109 <<< END TEST
;30: -- **************************************************************
;32: -- TEST:0110 Search condition unknown OR NOT(unknown)!
;34: -- setup
;36:  ERROR: sql-parse: 'NULL'
;   INSERT INTO WORKS VALUES('E8','P8',NULL);
;
;37: -- PASS:0110 If 1 row is inserted?
;44:  ERROR: No object found named SQL-SELECT of type FUNCTION: NIL
;   SELECT EMPNUM,PNUM FROM WORKS WHERE HOURS < (SELECT HOURS FROM WORKS WHERE EMPNUM = 'E8') OR NOT(HOURS < (SELECT HOURS FROM WORKS WHERE EMPNUM = 'E8'))
;
;45: -- PASS:0110 If 0 rows are selected ?
;47: -- restore
;(sql "ROLLBACK WORK;")
;50: -- END TEST >>> 0110 <<< END TEST
;51: -- *************************************************************
;53: -- TEST:0111 Search condition unknown AND NOT(unknown)!
;55: -- setup
;57:  ERROR: sql-parse: 'NULL'
;   INSERT INTO WORKS VALUES('E8','P8',NULL);
;
;58: -- PASS:0111 If 1 row is inserted?
;65:  ERROR: No object found named SQL-SELECT of type FUNCTION: NIL
;   SELECT EMPNUM,PNUM FROM WORKS WHERE HOURS < (SELECT HOURS FROM WORKS WHERE EMPNUM = 'E8') AND NOT(HOURS< (SELECT HOURS FROM WORKS WHERE EMPNUM = 'E8'));
;
;67: -- PASS:0111 If 0 rows are selected?
;69: -- restore
;(sql "ROLLBACK WORK;")
;72: -- END TEST >>> 0111 <<< END TEST
;73: -- ***************************************************************
;75: -- TEST:0112 Search condition unknown AND true!
;77: -- setup
;79:  ERROR: sql-parse: 'NULL'
;   INSERT INTO WORKS VALUES('E8','P8',NULL);
;
;80: -- PASS:0112 If 1 row is inserted?
;86:  ERROR: sql-parse: 'SELECT'
;   SELECT EMPNUM,PNUM FROM WORKS WHERE HOURS < (SELECT HOURS FROM WORKS WHERE EMPNUM = 'E8') AND HOURS IN (SELECT HOURS FROM WORKS);
;
;88: -- PASS:0112 If 0 rows are selected?
;90: -- restore
;(sql "ROLLBACK WORK;")
;93: -- END TEST >>> 0112 <<< END TEST
;94: -- *************************************************************
;96: -- TEST:0113 Search condition unknown OR true!
;98: -- setup
;100:  ERROR: sql-parse: 'NULL'
;   INSERT INTO WORKS VALUES('E8','P8',NULL);
;
;101: -- PASS:0113 If 1 row is inserted?
;108:  ERROR: sql-parse: 'SELECT'
;   SELECT EMPNUM,PNUM FROM WORKS WHERE HOURS < (SELECT HOURS FROM WORKS WHERE EMPNUM = 'E8') OR HOURS IN (SELECT HOURS FROM WORKS) ORDER BY EMPNUM;
;
;110: -- PASS:0113 If 12 rows are selected?
;111: -- PASS:0113 If first EMPNUM = 'E1'?
;113: -- restore
;(sql "ROLLBACK WORK; ")
;116: -- END TEST >>> 0113 <<< END TEST
;117: -- *************************************************////END-OF-MODULE


;** sql\dml025.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
(checkequal "SQL Test suite\\sql\\dml025.sql"
  ((sql "SELECT SUM(HOURS),AVG(HOURS),MIN(HOURS),MAX(HOURS) FROM WORKS WHERE EMPNUM='E1';")
   (list (list 184.0 (/ 92 3.0) 12.0 80.0)))
  ((sql "SELECT PNUM,AVG(HOURS),MIN(HOURS),MAX(HOURS) FROM WORKS WHERE EMPNUM='E8' GROUP BY PNUM;") nil)
)
;32: -- ***********************************************************
;34: -- TEST:0116 GROUP BY set functions: zero groups returns empty table!
(checkequal "SQL Test suite\\sql\\dml025.sql"
  ((sql "SELECT SUM(HOURS),AVG(HOURS),MIN(HOURS),MAX(HOURS) FROM WORKS WHERE EMPNUM='E8' GROUP BY PNUM;")
   '((0 NIL NIL NIL)))
)
;39: -- PASS:0116 If 0 rows are selected?
;42: -- ***************************************************************
;44: -- TEST:0117 GROUP BY column, set functions with several groups!
(checkequal "SQL Test suite\\sql\\dml025.sql"
  ((sql "SELECT PNUM,AVG(HOURS),MIN(HOURS),MAX(HOURS)
         FROM WORKS
         GROUP BY PNUM
         ORDER BY PNUM;")
   '((("P1" 40.0 40.0 40.0)) (("P2" 35.0 20.0 80.0)) (("P3" 80.0 80.0 80.0))
     (("P4" 30.0 20.0 40.0)) (("P5" 46.0 12.0 80.0)) (("P6" 12.0 12.0 12.0))))
)


;** sql\dml026.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
(checkequal "SQL Test suite\\sql\\dml026.sql"
  ((sql "SELECT +MAX(DISTINCT HOURS) FROM WORKS;") '((80.0)))
  ((sql "SELECT -MAX(DISTINCT HOURS) FROM WORKS;") '((-80.0)))
)
;30: -- *********************************************************
;32: -- TEST:0120 Value expression with NULL primary IS NULL!
;34: -- setup
;37:  ERROR: sql-parse: 'SELECT'
;   INSERT INTO WORKS1 SELECT * FROM WORKS;
;
;38: -- PASS:0120 If 12 rows are inserted ?
;40: -- setup
;42:  ERROR: sql-parse: 'NULL'
;   INSERT INTO WORKS1 VALUES('E9','P1',NULL);
;
;43: -- PASS:0120 If 1 row is inserted?
;47:  ERROR: sql-parse: 'IS'
;   SELECT EMPNUM FROM WORKS1 WHERE HOURS IS NULL;
;
;48: -- PASS:0120 If EMPNUM = 'E9'?
;50: -- NOTE:0120 we insert into WORKS from WORKS1
;52: -- setup
;56:  ERROR: sql-parse: 'SELECT'
;   INSERT INTO WORKS SELECT EMPNUM,'P9',20+HOURS FROM WORKS1 WHERE EMPNUM='E9';
;
;57: -- PASS:0120 If 1 row is inserted?
;(checkequal "SQL Test suite\\sql\\dml026.sql"
;  ((sql "SELECT COUNT(*) FROM WORKS WHERE EMPNUM='E9';") '((0)))
;)
;62: -- PASS:0120 If count = 1 ?
;66:  ERROR: sql-parse: 'IS'
;   SELECT COUNT(*) FROM WORKS WHERE HOURS IS NULL;
;
;67: -- PASS:0120 If count = 1 ?
;69: -- restore
;(sql "ROLLBACK WORK;")
;72: -- END TEST >>> 0120 <<< END TEST
;73: -- **********************************************************
;75: -- TEST:0121 Dyadic operators +, -, *, /!
(checkequal "SQL Test suite\\sql\\dml026.sql"
  ((sql "SELECT COUNT(*) FROM VTABLE;") '((4)))
  ((sql "SELECT +COL1+COL2 - COL3*COL4/COL1 FROM VTABLE WHERE COL1=10;") '((-90)))
)
;87: -- *********************************************************
;89: -- TEST:0122 Divisor shall not be zero!
;(checkequal "SQL Test suite\\sql\\dml026.sql"
;  ((sql "SELECT COL2/COL1+COL3 FROM VTABLE WHERE COL4=3;") 'nil)
;)
;94: -- PASS:0122 If ERROR Number not Divisible by Zero?
;96: -- END TEST >>> 0122 <<< END TEST
;97: -- **********************************************************
;99: -- TEST:0123 Evaluation order of expression!
;103:  ERROR: sql-parse: 'IS'
;   SELECT (-COL2+COL1)*COL3 - COL3/COL1 FROM VTABLE WHERE COL4 IS NULL;
;** Row above replaced with this row (without NULL), corresponding change made in sql-testdataload.lsp:
(checkequal "SQL Test suite\\sql\\dml026.sql"
  ((sql "SELECT (-COL2+COL1)*COL3 - COL3/COL1 FROM VTABLE WHERE COL4=0;") '((8999997)))
)
;104: -- PASS:0123 If Answer is 8999997 (plus or minus 0.5)?


;** sql\dml027.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
(checkequal "SQL Test suite\\sql\\dml027.sql"
;14: -- TEST:0124 UPDATE UNIQUE column (key = key + 1) interim conflict!
  ((sql "UPDATE UPUNIQ SET NUMKEY = NUMKEY + 1;") nil)
  ((sql "SELECT COUNT(*),SUM(NUMKEY) FROM UPUNIQ;") '((6 30.0)))
  ((sql "ROLLBACK WORK;") nil)
;31: -- TEST:0125 UPDATE UNIQUE column (key = key + 1) no interim conflit!
  ((sql "UPDATE UPUNIQ SET NUMKEY = NUMKEY + 1 WHERE NUMKEY >= 4;") nil)
  ((sql "SELECT COUNT(*),SUM(NUMKEY) FROM UPUNIQ;") '((6 27.0)))
)
(sql "ROLLBACK WORK;")


;** sql\dml029.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
;14: -- TEST:0129 Double quote work in character string literal!
;16: -- setup
;18:  ERROR: sql-parse: ''an'
;   INSERT INTO STAFF VALUES('E8','Yang Ling',15,'Xi''an');;
;
;19: -- PASS:0129 If 1 row is inserted?
;(sql "SELECT GRADE,CITY FROM STAFF WHERE EMPNUM = 'E8';")
;24: -- PASS:0129 If GRADE = 15 and CITY = 'Xi'an'?
;26: -- restore
;(sql "ROLLBACK WORK;")
;29: -- END TEST >>> 0129 <<< END TEST
;30: -- ************************************************************
;32: -- TEST:0130 Approximate numeric literal <mantissa>E<exponent>!
;34: -- setup
(sql "INSERT INTO JJ VALUES(123.456E3);")
(checkequal "SQL Test suite\\sql\\dml029.sql"
  ((sql "SELECT COUNT(*) FROM JJ WHERE FLOATTEST > 123455 AND FLOATTEST < 123457;") '((1)))
  ((sql "ROLLBACK WORK;") nil)
;50: -- TEST:0131 Approximate numeric literal with negative exponent!
  ((sql "INSERT INTO JJ VALUES(123456E-3);") nil)
  ((sql "SELECT COUNT(*) FROM JJ WHERE FLOATTEST > 122 AND FLOATTEST < 124;") '((1)))
  ((sql "ROLLBACK WORK;") nil)
;68: -- TEST:0182 Approx numeric literal with negative mantissa & exponent!
  ((sql "INSERT INTO JJ VALUES(-123456E-3);") nil)
  ((sql "SELECT COUNT(*) FROM JJ WHERE FLOATTEST > -124 AND FLOATTEST < -122;") '((1)))
)
(sql "ROLLBACK WORK;")


;** sql\dml033.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml033.sql"
;14: -- TEST:0135 Upper and loer case letters are distinct!
  ((sql "INSERT INTO WORKS VALUES('UPP','low',100);") nil)
  ((sql "SELECT EMPNUM,PNUM FROM WORKS WHERE EMPNUM='UPP' AND PNUM='low';") '(("UPP" "low")))
;24: -- PASS:0135 If EMPNUM = 'UPP' and PNUM = 'low'?
  ((sql "SELECT EMPNUM,PNUM FROM WORKS WHERE EMPNUM='upp' OR PNUM='LOW';") nil)
)
(sql "ROLLBACK WORK;")


;** sql\dml034.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
;14: -- TEST:0088 Data type REAL!
(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml034.sql"
  ((sql "INSERT INTO GG VALUES(123.4567E-2);") nil)
  ((sql "SELECT REALTEST FROM GG;") '((1.234567)))
  ((sql "SELECT * FROM GG WHERE REALTEST > 1.234561 and REALTEST < 1.234573;") '((1.234567)))
  ((sql "ROLLBACK WORK;") nil)
;37: -- TEST:0090 Data type DOUBLE PRECISION!
  ((sql "INSERT INTO II VALUES(0.123456123456E6);") nil)
  ((sql "SELECT DOUBLETEST FROM II;") '((123456.123456)))
  ((sql "SELECT * FROM II WHERE DOUBLETEST > 123456.123450 and DOUBLETEST < 123456.123462;") '((123456.123456)))
  ((sql "ROLLBACK WORK;") nil)
;60: -- TEST:0091 Data type FLOAT!
  ((sql "INSERT INTO JJ VALUES(12.345678);") nil)
  ((sql "SELECT FLOATTEST FROM JJ;") '((12.345678)))
  ((sql "SELECT * FROM JJ WHERE FLOATTEST > 12.345672 and FLOATTEST < 12.345684;") '((12.345678)))
  ((sql "ROLLBACK WORK;") nil)
;83: -- TEST:0092 Data type FLOAT(32)!
  ((sql "INSERT INTO KK VALUES(123.456123456E+3);") nil)
  ((sql "SELECT FLOATTEST FROM KK;") '((123456.123456)))
  ((sql "SELECT * FROM KK WHERE FLOATTEST > 123456.123450 and FLOATTEST < 123456.123462;") '((123456.123456)))
  ((sql "ROLLBACK WORK; ") nil)
;106: -- TEST:0093 Data type NUMERIC(13,6)!
  ((sql "INSERT INTO LL VALUES(123456.123456);") nil)
  ((sql "SELECT * FROM LL;") '((123456.123456)))
  ((sql "SELECT * FROM LL WHERE NUMTEST > 123456.123450 and NUMTEST < 123456.123462;") '((123456.123456)))
  ((sql "ROLLBACK WORK;") nil)
;129: -- TEST:0094 Data type DECIMAL(13,6)!
  ((sql "INSERT INTO PP VALUES(123456.123456);") nil)
  ((sql "SELECT * FROM PP;") '((123456.123456)))
  ((sql "ROLLBACK WORK;") nil)
;147: -- TEST:0095 Data type DEC(13,6)!
  ((sql "INSERT INTO SS VALUES(123456.123456);") nil)
  ((sql "SELECT * FROM SS;") '((123456.123456)))
)
(sql "ROLLBACK WORK;")


;** sql\dml035.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
;14: -- TEST:0157 ORDER BY approximate numeric!
(sql "INSERT INTO JJ VALUES(66.2);")
(sql "INSERT INTO JJ VALUES(-44.5);")
(sql "INSERT INTO JJ VALUES(0.2222);")
(sql "INSERT INTO JJ VALUES(66.3);")
(sql "INSERT INTO JJ VALUES(-87);")
(sql "INSERT INTO JJ VALUES(-66.25);")
(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml035.sql"
  ((sql "SELECT FLOATTEST FROM JJ ORDER BY FLOATTEST DESC;")
   '(((66.3)) ((66.2)) ((0.2222)) ((-44.5)) ((-66.25)) ((-87.0))))
)
(sql "ROLLBACK WORK;")


;** sql\dml037.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
;1: -- MODULE DML037
;3: -- SQL Test Suite, V6.0, Interactive SQL, dml037.sql
;4: -- 59-byte ID
;5: -- TEd Version #
;7: -- AUTHORIZATION HU
;9:  ERROR: SQL-SELECT: Unable to resolve column name "USER".
;   SELECT USER FROM HU.ECCO;
;
;10: -- RERUN if USER value does not match preceding AUTHORIZATION comment
;12: -- date_time print
;14: -- NO_TEST:0202 Host variable names same as column name!
;16: -- Testing host identifier
;18: -- ***********************************************************
;20: -- TEST:0234 SQL-style comments with SQL statements!
;21: -- OPTIONAL TEST
;24:  ERROR: sql-parse: '-'
;   DELETE -- we empty the table
;   FROM TEXT240;
;
;29: -- SQL-style comments
;30:  ERROR: sql-parse: '-'
;   INSERT INTO TEXT240 -- This is the test for the rules
;   VALUES -- for the placement 
;      ('SQL-STYLE COMMENTS') -- of 
;    ; -- comments
;
;
;31: -- PASS:0234 If 1 row is inserted?
;(sql "SELECT * FROM TEXT240;")
;35: -- PASS:0234 If TEXXT = 'SQL-STYLE COMMENTS'?
;37: -- restore
;(sql "ROLLBACK WORK;")
;40: -- END TEST >>> 0234 <<< END TEST
;41: -- *************************************************////END-OF-MODULE


;** sql\dml038.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
;1: -- MODULE DML038
;3: -- SQL Test Suite, V6.0, Interactive SQL, dml038.sql
;4: -- 59-byte ID
;5: -- TEd Version #
;7: -- AUTHORIZATION HU
;9:  ERROR: SQL-SELECT: Unable to resolve column name "USER".
;   SELECT USER FROM HU.ECCO;
;
;10: -- RERUN if USER value does not match preceding AUTHORIZATION comment
;12: -- date_time print
;14: -- TEST:0205 Cartesian product is produced without WHERE clause!
(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml038.sql"
  ((length (sql "SELECT GRADE, HOURS, BUDGET FROM STAFF, WORKS, PROJ;")) 360)
)


;** sql\dml039.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
;14: -- TEST:0208 Upper and lower case in LIKE predicate!
(sql "INSERT INTO STAFF VALUES('E7', 'yanping',26,'China');")
(sql "INSERT INTO STAFF VALUES('E8','YANPING',30,'NIST');")
(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml039.sql"
  ((sql "SELECT CITY FROM STAFF WHERE EMPNAME LIKE 'yan____%';") '(("China")))
  ((sql "SELECT CITY FROM STAFF WHERE EMPNAME LIKE 'YAN____%';") '(("NIST")))
)
(sql "ROLLBACK WORK;")


;** sql\dml040.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
;14: -- TEST:0209 Join 2 tables from different schemas!
;16: -- setup
;19:  ERROR: sql-parse: 'SELECT'
;   INSERT INTO CUGINI.VTABLE SELECT * FROM VTABLE;
;** Instead of row above...
(sql "INSERT INTO CUGINI.VTABLE VALUES (10,+20,30,40,10.50), (0,1,2,3,4.25),
                       (100,200,300,400,500.01), (1000,-2000,3000,0,4000.00);")

;
(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml040.sql"
  ((sorttuples (sql "SELECT COL1, EMPNUM, GRADE FROM CUGINI.VTABLE, STAFF WHERE COL1 < 200 AND GRADE > 12;"))
   '((0 "E3" 13.0) (0 "E5" 13.0) (10 "E3" 13.0) (10 "E5" 13.0) (100 "E3" 13.0) (100 "E5" 13.0)))
)
(sql "ROLLBACK WORK;")


;** sql\dml041.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
;1: -- MODULE DML041
;3: -- SQL Test Suite, V6.0, Interactive SQL, dml041.sql
;4: -- 59-byte ID
;5: -- TEd Version #
;7: -- AUTHORIZATION HU
;9:  ERROR: SQL-SELECT: Unable to resolve column name "USER".
;   SELECT USER FROM HU.ECCO;
;
;10: -- RERUN if USER value does not match preceding AUTHORIZATION comment
;12: -- date_time print
;14: -- TEST:0212 Enforcement of CHECK clause in nested views!
;16: -- setup
;18:  ERROR: (internal) Not a list: NIL
;   INSERT INTO V_WORKS2 VALUES('E9','P7',13);
;
;19: -- PASS:0212 If ERROR, view check constraint, 0 rows inserted?
;22:  ERROR: (internal) Not a list: NIL
;   INSERT INTO V_WORKS2 VALUES('E7','P4',95);
;
;23: -- PASS:0212 If 1 row is inserted?
;26:  ERROR: (internal) Not a list: NIL
;   INSERT INTO V_WORKS3 VALUES('E8','P2',85);
;
;27: -- PASS:0212 If either 1 row is inserted OR ?
;28: -- PASS:0212 If ERROR, view check constraint, 0 rows inserted?
;29: -- NOTE:0212 Vendor interpretation follows
;30: -- NOTE:0212 Insertion of row means: outer check option does not imply
;31: -- NOTE:0212 inner check options
;33: -- NOTE:0212 Failure to insert means: outer check option implies
;34: -- NOTE:0212 inner check options
;37:  ERROR: (internal) Not a list: NIL
;   INSERT INTO V_WORKS3 VALUES('E1','P7',90);
;
;38: -- PASS:0212 If 1 row is inserted?
;41:  ERROR: (internal) Not a list: NIL
;   INSERT INTO V_WORKS3 VALUES('E9','P2',10);
;
;42: -- PASS:0212 If ERROR, view check constraint, 0 rows inserted?
(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml041.sql"
  ((sql "SELECT COUNT(*) FROM WORKS WHERE EMPNUM = 'E9';") '((0)))
)
;47: -- PASS:0212 If count = 0?
;(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml041.sql"
;  ((sql "SELECT COUNT(*) FROM WORKS WHERE HOURS > 85;") '((0)))
;)
;52: -- PASS:0212 If count = 2?
;54: -- restore
(sql "ROLLBACK WORK;")
;57: -- END TEST >>> 0212 <<< END TEST
;58: -- *************************************************////END-OF-MODULE


;** sql\dml051.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
;14: -- TEST:0227 BETWEEN predicate with character string values!
(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml051.sql"
  ((sql "SELECT PNUM FROM PROJ WHERE PNAME BETWEEN 'A' AND 'F';") '(("P2")))
  ((sql "SELECT PNUM FROM PROJ WHERE PNAME >= 'A' AND PNAME <= 'F';") '(("P2")))
;28: -- TEST:0228 NOT BETWEEN predicate with character string values!
  ((sql "SELECT CITY FROM STAFF WHERE EMPNAME NOT BETWEEN 'A' AND 'E';") '(("Akron")))
  ((sql "SELECT CITY FROM STAFF WHERE NOT( EMPNAME BETWEEN 'A' AND 'E' );") '(("Akron")))
)


;** sql\dml052.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
;14: -- TEST:0229 Case-sensitive LIKE predicate!
(sql "INSERT INTO STAFF VALUES('E6','ALICE',11,'Gaithersburg');")
(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml052.sql"
  ((sql "SELECT EMPNAME FROM STAFF WHERE EMPNAME LIKE 'Ali%';") '(("Alice")))
  ((sql "SELECT EMPNAME FROM STAFF WHERE EMPNAME LIKE 'ALI%';") '(("ALICE")))
)
(sql "ROLLBACK WORK;")


;** sql\dml053.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
;14: -- TEST:0233 Table as multiset of rows - INSERT duplicate VALUES()!
(sql "INSERT INTO TEMP_S VALUES('E1',11,'Deale');")
(sql "INSERT INTO TEMP_S VALUES('E1',11,'Deale');")
(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml053.sql"
  ((sql "SELECT COUNT(*) FROM TEMP_S WHERE EMPNUM='E1' AND GRADE=11.0 AND CITY='Deale';") '((2)))
)
(sql "ROLLBACK WORK;")


;** sql\dml059.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
;14: -- TEST:0257 SELECT MAX, MIN (COL1 + or - COL2)!
(sql "INSERT INTO VTABLE VALUES(10,11,12,13,15);")
(sql "INSERT INTO VTABLE VALUES(100,111,1112,113,115);")
(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml059.sql #1"
  ((sql "SELECT COL1, MAX(COL2 + COL3), MIN(COL3 - COL2)
         FROM VTABLE
         GROUP BY COL1
         ORDER BY COL1;")
   '(((0 3 1)) ((10 50 1)) ((100 1223 100)) ((1000 1000 5000))))
  ((sql "ROLLBACK WORK; ") nil)
;43: -- TEST:0258 SELECT SUM(2*COL1*COL2) in HAVING SUM(COL2*COL3)!
  ((sql "INSERT INTO VTABLE VALUES (10,11,12,13,15);") nil)
  ((sql "INSERT INTO VTABLE VALUES (100,111,1112,113,115);") nil)
  ((sql "SELECT COL1,SUM(2 * COL2 * COL3)
         FROM VTABLE
         GROUP BY COL1
         HAVING SUM(COL2 * COL3) > 2000 OR SUM(COL2 * COL3) < -2000
         ORDER BY COL1;")
    '(((100 366864)) ((1000 -12000000))))
)
(sql "ROLLBACK WORK;")
;72: -- *********************************************************************
;74: -- TEST:0259 SOME, ANY in HAVING clause!
;76: -- setup
;(sql "INSERT INTO VTABLE VALUES(10,11,12,13,15);")
;79: -- PASS:0259 If 1 row is inserted?
;81: -- setup
;(sql "INSERT INTO VTABLE VALUES(100,111,1112,113,115);")
;84: -- PASS:0259 If 1 row is inserted?
;91:  ERROR: sql-parse: '('
;   SELECT COL1, MAX(COL2) FROM VTABLE GROUP BY COL1 HAVING MAX(COL2) > ANY (SELECT GRADE FROM STAFF) AND MAX(COL2) < SOME (SELECT HOURS FROM WORKS) ORDER BY COL1;
;
;92: -- PASS:0259 If 1 row is selected and COL1 = 10 and MAX(COL2) = 20?
;94: -- restore
;(sql "ROLLBACK WORK;")
;97: -- END TEST >>> 0259 <<< END TEST
;99: -- *******************************************************************
;101: -- TEST:0260 EXISTS in HAVING clause!
;103: -- setup
;(sql "INSERT INTO VTABLE VALUES(10,11,12,13,15);")
;106: -- PASS:0260 If 1 row is inserted?
;108: -- setup
;(sql "INSERT INTO VTABLE VALUES(100,111,1112,113,115);")
;111: -- PASS:0260 If 1 row is inserted?
;120:  ERROR: sql-parse: '('
;   SELECT COL1, MAX(COL2) FROM VTABLE GROUP BY COL1 HAVING EXISTS (SELECT * FROM STAFF WHERE EMPNUM = 'E1') AND MAX(COL2) BETWEEN 10 AND 90 ORDER BY COL1;
;
;121: -- PASS:0260 If 1 row is selected and COL1 = 10 and MAX(COL2) = 20?
;123: -- restore
;(sql "ROLLBACK WORK;")
;126: -- END TEST >>> 0260 <<< END TEST
;128: -- ******************************************************************
;130: -- TEST:0264 WHERE, HAVING without GROUP BY!
(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml059.sql #2"
  ((sql "SELECT SUM(COL1) FROM VTABLE
         WHERE 10 + COL1 > COL2
         HAVING MAX(COL1) > 100;") '((1000)))
  ((sql "SELECT SUM(COL1)
         FROM VTABLE
         WHERE 1000 + COL1 >= COL2
         HAVING MAX(COL1) > 100;") '((1110)))
)


;** sql\dml060.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
;14: -- TEST:0261 WHERE (2 * (c1 - c2)) BETWEEN!
(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml060.sql #1"
  ((sql "SELECT COL1, COL2
         FROM VTABLE
         WHERE(2*(COL3 - COL2)) BETWEEN 5 AND 200
         ORDER BY COL1;") '(((10 20)) ((100 200))))
)
;26: -- ********************************************************************
;28: -- TEST:0262 WHERE clause with computation, ANY/ALL subqueries!
;(sql "UPDATE VTABLE SET COL1 = 1 WHERE COL1 = 0;")
;33: -- PASS:0262 If 1 row is updated?
;41:  ERROR: sql-parse: 'ALL'
;   SELECT COL1, COL2 FROM VTABLE WHERE (COL3 * COL2/COL1) > ALL (SELECT HOURS FROM WORKS) OR -(COL3 * COL2/COL1) > ANY (SELECT HOURS FROM WORKS) ORDER BY COL1;
;
;42: -- PASS:0262 If 2 rows are selected?
;43: -- PASS:0262 If first row is ( 100, 200)?
;44: -- PASS:0262 If second row is (1000, -2000)?
;46: -- restore
;(sql "ROLLBACK WORK;")
;49: -- END TEST >>> 0262 <<< END TEST
;51: -- ******************************************************************
;53: -- TEST:0263 Computed column in ORDER BY!
(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml060.sql #2"
  ((sql "SELECT COL1, (COL3 * COL2/COL1 - COL2 + 10)
         FROM VTABLE
         WHERE COL1 > 0
         ORDER BY 2;")
   '(((1000 -3990)) ((10 50)) ((100 410))))
;68: -- TEST:0265 Update:searched - view with check option!
  ((sql "INSERT INTO WORKS VALUES('E3','P4',50);") nil)
  ((sorttuples (sql "SELECT EMPNUM, PNUM, HOURS FROM SUBSP;"))
   '(("E3" "P2" 20.0) ("E3" "P4" 50.0)))
  ((sorttuples (sql "SELECT * FROM WORKS;"))
   '(("E1" "P1" 40.0) ("E1" "P2" 20.0) ("E1" "P3" 80.0) ("E1" "P4" 20.0)
     ("E1" "P5" 12.0) ("E1" "P6" 12.0) ("E2" "P1" 40.0) ("E2" "P2" 80.0)
     ("E3" "P2" 20.0) ("E3" "P4" 50.0) ("E4" "P2" 20.0) ("E4" "P4" 40.0) ("E4" "P5" 80.0)))
)
;84:  ERROR: Function not updatable: #[OID 1035 "CHARSTRING.CHARSTRING.REAL.HUsql:SUBSP->BOOLEAN"]
;   UPDATE SUBSP SET EMPNUM = 'E9' WHERE PNUM = 'P2';
;
;85: -- PASS:0265 If ERROR, view check constraint, 0 rows are updated?
(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml060.sql #3"
  ((sorttuples (sql "SELECT * FROM WORKS;"))
   '(("E1" "P1" 40.0) ("E1" "P2" 20.0) ("E1" "P3" 80.0) ("E1" "P4" 20.0)
     ("E1" "P5" 12.0) ("E1" "P6" 12.0) ("E2" "P1" 40.0) ("E2" "P2" 80.0)
     ("E3" "P2" 20.0) ("E3" "P4" 50.0) ("E4" "P2" 20.0) ("E4" "P4" 40.0) ("E4" "P5" 80.0)))
  ((sql "ROLLBACK WORK;") nil)
;97: -- TEST:0266 Update:searched - UNIQUE violation under view!
  ((sql "INSERT INTO WORKS VALUES('E3','P4',50);") nil)
  ((sorttuples (sql "SELECT EMPNUM, PNUM, HOURS FROM SUBSP;"))
   '(("E3" "P2" 20.0) ("E3" "P4" 50.0)))
  ((sorttuples (sql "SELECT * FROM WORKS WHERE EMPNUM = 'E3';"))
   '(("E3" "P2" 20.0) ("E3" "P4" 50.0)))
)
;113:  ERROR: Function not updatable: #[OID 1035 "CHARSTRING.CHARSTRING.REAL.HUsql:SUBSP->BOOLEAN"]
;   UPDATE SUBSP SET PNUM = 'P6' WHERE EMPNUM = 'E3';
;
;114: -- PASS:0266 If ERROR, unique constraint, 0 rows updated?
;(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml060.sql"
;  ((sql "SELECT EMPNUM, PNUM, HOURS FROM SUBSP;") '(("E3" "P4" 50.0) ("E3" "P2" 20.0)))
;)
;118: -- PASS:0266 If 2 rows are selected?
(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml060.sql #4"
  ((sorttuples (sql "SELECT * FROM WORKS WHERE EMPNUM = 'E3';"))
   '(("E3" "P2" 20.0) ("E3" "P4" 50.0)))
)
(sql "ROLLBACK WORK;")
(sql "DELETE FROM WORKS1;")
(sql "INSERT INTO WORKS1 VALUES ('P1','P6',1);")
(sql "INSERT INTO WORKS1 VALUES ('P2','P6',2);")
(sql "INSERT INTO WORKS1 VALUES ('P3','P6',3);")
(sql "INSERT INTO WORKS1 VALUES ('P4','P6',4);")
(sql "INSERT INTO WORKS1 VALUES ('P5','P6',5);")
(sql "INSERT INTO WORKS1 VALUES ('P6','P6',6);")
(sql "INSERT INTO WORKS1 VALUES ('P1','P5',7);")
(sql "INSERT INTO WORKS1 VALUES ('P2','P5',8);")
(sql "INSERT INTO WORKS1 VALUES ('P3','P5',9);")
(sql "INSERT INTO WORKS1 VALUES ('P4','P5',10);")
(sql "INSERT INTO WORKS1 VALUES ('P5','P5',11);")
(sql "INSERT INTO WORKS1 VALUES ('P6','P5',12);")
(sql "INSERT INTO WORKS1 VALUES ('P1','P4',13);")
(sql "INSERT INTO WORKS1 VALUES ('P2','P4',14);")
(sql "INSERT INTO WORKS1 VALUES ('P3','P4',15);")
(sql "INSERT INTO WORKS1 VALUES ('P4','P4',16);")
(sql "INSERT INTO WORKS1 VALUES ('P5','P4',17);")
(sql "INSERT INTO WORKS1 VALUES ('P6','P4',18);")
(sql "INSERT INTO WORKS1 VALUES ('P1','P3',19);")
(sql "INSERT INTO WORKS1 VALUES ('P2','P3',20);")
(sql "INSERT INTO WORKS1 VALUES ('P3','P3',21);")
(sql "INSERT INTO WORKS1 VALUES ('P4','P3',22);")
(sql "INSERT INTO WORKS1 VALUES ('P5','P3',23);")
(sql "INSERT INTO WORKS1 VALUES ('P6','P3',24);")
(sql "INSERT INTO WORKS1 VALUES ('P1','P2',25);")
(sql "INSERT INTO WORKS1 VALUES ('P2','P2',26);")
(sql "INSERT INTO WORKS1 VALUES ('P3','P2',27);")
(sql "INSERT INTO WORKS1 VALUES ('P4','P2',28);")
(sql "INSERT INTO WORKS1 VALUES ('P5','P2',29);")
(sql "INSERT INTO WORKS1 VALUES ('P6','P2',30);")
(sql "INSERT INTO WORKS1 VALUES ('P1','P1',31);")
(sql "INSERT INTO WORKS1 VALUES ('P2','P1',32);")
(sql "INSERT INTO WORKS1 VALUES ('P3','P1',33);")
(sql "INSERT INTO WORKS1 VALUES ('P4','P1',34);")
(sql "INSERT INTO WORKS1 VALUES ('P5','P1',35);")
(sql "INSERT INTO WORKS1 VALUES ('P6','P1',36);")
(sql "UPDATE WORKS1 SET PNUM = EMPNUM, EMPNUM = PNUM;")
;175: -- PASS:0267 If 36 rows are updated?
(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml060.sql #5"
  ((sql "SELECT COUNT(*) FROM WORKS1 WHERE EMPNUM = 'P1' AND HOURS > 30;") '((6)))
)
(sql "ROLLBACK WORK;")


;** sql\dml061.sql
;**
;** Entry SQL
(sql "SCHEMA HU;")
;14: -- TEST:0269 BETWEEN value expressions in wrong order!
(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml061.sql"
  ((sql "SELECT COUNT(*) FROM WORKS WHERE HOURS BETWEEN 80 AND 40;") '((0)))
  ((sql "INSERT INTO WORKS VALUES('E6','P6',-60);") nil)
  ((sql "SELECT COUNT(*) FROM WORKS WHERE HOURS BETWEEN -40 AND -80;") '((0)))
  ((sql "SELECT COUNT(*) FROM WORKS WHERE HOURS BETWEEN -80 AND -40;") '((1)))
  ((sql "ROLLBACK WORK;") nil)
  ((sql "SELECT COUNT(*) 
         FROM WORKS 
         WHERE HOURS BETWEEN 11.999 AND 12 OR HOURS BETWEEN 19.999 AND 2.001E1;") '((6)))
  ((sql "SELECT COUNT(*) FROM WORKS,STAFF WHERE WORKS.EMPNUM = 'E1';") '((30)))
)
;65: -- ****************************************************************
;68: -- TEST:0272 Statement rollback for integrity!
;(sql "UPDATE WORKS SET EMPNUM = 'E7' WHERE EMPNUM = 'E1' OR EMPNUM = 'E4';")
;72: -- PASS:0272 If ERROR, unique constraint, 0 rows updated?
;75:  ERROR: sql-parse: 'SELECT'
;   INSERT INTO WORKS SELECT 'E3',PNUM,17 FROM PROJ;
;
;76: -- PASS:0272 If ERROR, unique constraint, 0 rows inserted?
;79:  ERROR: Function not updatable: #[OID 1039 "CHARSTRING.CHARSTRING.REAL.HUsql:V_WORKS1->BOOLEAN"]
;   UPDATE V_WORKS1 SET HOURS = HOURS - 9;
;
;80: -- PASS:0272 If ERROR, view check constraint, 0 rows updated?
;(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml061.sql"
;  ((sql "SELECT COUNT(*) FROM WORKS WHERE EMPNUM = 'E7' OR HOURS = 31 OR HOURS = 17;") '((9)))
;)
;85: -- PASS:0272 If count = 0?
;87: -- restore
;(sql "ROLLBACK WORK;")
;90: -- END TEST >>> 0272 <<< END TEST
;92: -- ****************************************************************
;95: -- TEST:0273 SUM, MAX, MIN = NULL for empty arguments !
;98:  ERROR: sql-parse: 'NULL'
;   UPDATE WORKS SET HOURS = NULL;
;
;99: -- PASS:0273 If 12 rows updated?
;(checkequal "c:\\maja4141\\SQL Test suite\\sql\\dml061.sql"
;  ((sql "SELECT SUM(HOURS),MAX(HOURS),MIN(HOURS),MIN(EMPNUM) FROM WORKS;") '((464.0 80.0 12.0 "E1")))
;)
;103: -- PASS:0273 If 1 row is selected?
;104: -- PASS:0273 If SUM(HOURS), MAX(HOURS), and MIN(HOURS) are NULL?
;106: -- restore
;(sql "ROLLBACK WORK;")
;109: -- END TEST >>> 0273 <<< END TEST
;111: -- ****************************************************************
;114: -- TEST:0277 Computation with NULL value specification!
;117:  ERROR: sql-parse: 'NULL'
;   UPDATE WORKS SET HOURS = NULL WHERE EMPNUM = 'E1';
;
;118: -- PASS:0277 If 6 rows are updated?
;(sql "UPDATE WORKS SET HOURS = HOURS - (3 + -17);")
;122: -- PASS:0277 If 12 rows are updated?
;(sql "UPDATE WORKS SET HOURS = 3 / -17 * HOURS;")
;126: -- PASS:0277 If 12 rows are updated?
;(sql "UPDATE WORKS SET HOURS = HOURS + 5;")
;130: -- PASS:0277 If 12 rows are updated?
;134:  ERROR: sql-parse: 'IS'
;   SELECT COUNT(*) FROM WORKS WHERE HOURS IS NULL;
;
;135: -- PASS:0277 If count = 6?
;137: -- restore
;(sql "ROLLBACK WORK;")
;140: -- END TEST >>> 0277 <<< END TEST
;142: -- ****************************************************************
;145: -- TEST:0278 IN value list with USER, literal, variable spec.!
(sql "UPDATE STAFF SET EMPNAME = 'HU' WHERE EMPNAME = 'Ed';")
;150: -- PASS:0278 If 1 row is updated?
;154:  ERROR: SQL-SELECT: Unable to resolve column name "USER".
;   SELECT COUNT(*) FROM STAFF WHERE EMPNAME IN (USER,'Betty','Carmen');
;
;155: -- PASS:0278 If count = 3?
;157: -- restore
(sql "ROLLBACK WORK;")
;160: -- END TEST >>> 0278 <<< END TEST
;162: -- *************************************************////END-OF-MODULE




;(check 71)







;** sql\dml075.sql    (check 78)
;**
;** Entry SQL
(sql "SCHEMA HU;")
;14: -- TEST:0431 Redundant rows in IN subquery!
;18:  ERROR: sql-parse: 'SELECT'
;   SELECT COUNT (*) FROM STAFF WHERE EMPNUM IN (SELECT EMPNUM FROM WORKS);
;
;19: -- PASS:0431 If count = 4?
;22:  ERROR: sql-parse: 'SELECT'
;   INSERT INTO STAFF1 SELECT * FROM STAFF;
;
;26:  ERROR: sql-parse: 'SELECT'
;   SELECT COUNT (*) FROM STAFF1 WHERE EMPNUM IN (SELECT EMPNUM FROM WORKS);
;
;27: -- PASS:0431 If count = 4?
;(sql "ROLLBACK WORK;")
;31: -- END TEST >>> 0431 <<< END TEST
;32: -- *************************************************************
;34: -- TEST:0432 Unknown comparison predicate in ALL, SOME, ANY!
;36: -- setup
;39:  ERROR: sql-parse: 'NULL'
;   UPDATE PROJ SET CITY = NULL WHERE PNUM = 'P3';
;
;45:  ERROR: sql-parse: 'ALL'
;   SELECT COUNT(*) FROM STAFF WHERE CITY = ALL (SELECT CITY FROM PROJ WHERE PNAME = 'SDP');
;
;46: -- PASS:0432 If count = 0?
;52:  ERROR: sql-parse: 'ALL'
;   SELECT COUNT(*) FROM STAFF WHERE CITY <> ALL (SELECT CITY FROM PROJ WHERE PNAME = 'SDP');
;
;53: -- PASS:0432 If count = 0?
;59:  ERROR: sql-parse: '('
;   SELECT COUNT(*) FROM STAFF WHERE CITY = ANY (SELECT CITY FROM PROJ WHERE PNAME = 'SDP');
;
;60: -- PASS:0432 If count = 2?
;66:  ERROR: sql-parse: '('
;   SELECT COUNT(*) FROM STAFF WHERE CITY <> ANY (SELECT CITY FROM PROJ WHERE PNAME = 'SDP');
;
;67: -- PASS:0432 If count = 3?
;73:  ERROR: sql-parse: '('
;   SELECT COUNT(*) FROM STAFF WHERE CITY = SOME (SELECT CITY FROM PROJ WHERE PNAME = 'SDP');
;
;74: -- PASS:0432 If count = 2?
;80:  ERROR: sql-parse: '('
;   SELECT COUNT(*) FROM STAFF WHERE CITY <> SOME (SELECT CITY FROM PROJ WHERE PNAME = 'SDP');
;
;81: -- PASS:0432 If count = 3?
;(sql "ROLLBACK WORK;")
;85: -- END TEST >>> 0432 <<< END TEST
;86: -- *************************************************************
;88: -- TEST:0433 Empty subquery in ALL, SOME, ANY!
;92:  ERROR: sql-parse: 'ALL'
;   SELECT COUNT(*) FROM PROJ WHERE PNUM = ALL (SELECT PNUM FROM WORKS WHERE EMPNUM = 'E8');
;
;93: -- PASS:0433 If count = 6?
;97:  ERROR: sql-parse: 'ALL'
;   SELECT COUNT(*) FROM PROJ WHERE PNUM <> ALL (SELECT PNUM FROM WORKS WHERE EMPNUM = 'E8');
;
;98: -- PASS:0433 If count = 6?
;102:  ERROR: sql-parse: '('
;   SELECT COUNT(*) FROM PROJ WHERE PNUM = ANY (SELECT PNUM FROM WORKS WHERE EMPNUM = 'E8');
;
;103: -- PASS:0433 If count = 0?
;107:  ERROR: sql-parse: '('
;   SELECT COUNT(*) FROM PROJ WHERE PNUM <> ANY (SELECT PNUM FROM WORKS WHERE EMPNUM = 'E8');
;
;108: -- PASS:0433 If count = 0?
;112:  ERROR: sql-parse: '('
;   SELECT COUNT(*) FROM PROJ WHERE PNUM = SOME (SELECT PNUM FROM WORKS WHERE EMPNUM = 'E8');
;
;113: -- PASS:0433 If count = 0?
;117:  ERROR: sql-parse: '('
;   SELECT COUNT(*) FROM PROJ WHERE PNUM <> SOME (SELECT PNUM FROM WORKS WHERE EMPNUM = 'E8');
;
;118: -- PASS:0433 If count = 0?
;120: -- END TEST >>> 0433 <<< END TEST
;121: -- *************************************************************
;123: -- TEST:0434 GROUP BY with HAVING EXISTS-correlated set function!
;129:  ERROR: sql-parse: '('
;   SELECT PNUM, SUM(HOURS) FROM WORKS GROUP BY PNUM HAVING EXISTS (SELECT PNAME FROM PROJ WHERE PROJ.PNUM = WORKS.PNUM AND SUM(WORKS.HOURS) > PROJ.BUDGET / 200);
;
;131: -- PASS:0434 If 2 rows selected with values (in any order):?
;132: -- PASS:0434 PNUM = 'P1', SUM(HOURS) = 80?
;133: -- PASS:0434 PNUM = 'P5', SUM(HOURS) = 92?
;135: -- END TEST >>> 0434 <<< END TEST
;136: -- *************************************************************
;138: -- TEST:0442 DISTINCT with GROUP BY, HAVING!
(checkequal "SQL Test Suite\\sql\\dml075.sql - SELECT DISTINCT"
  ((sorttuples (sql "SELECT PTYPE, CITY FROM PROJ GROUP BY PTYPE, CITY HAVING AVG(BUDGET) > 21000;"))
   '(("Code" "Vienna") ("Design" "Deale") ("Test" "Tampa")))
  ((sorttuples (sql "SELECT DISTINCT PTYPE, CITY FROM PROJ GROUP BY PTYPE, CITY HAVING AVG(BUDGET) > 21000;"))
   '(("Code" "Vienna") ("Design" "Deale") ("Test" "Tampa")))
  ((sorttuples (sql "SELECT DISTINCT SUM(BUDGET) FROM PROJ GROUP BY PTYPE, CITY HAVING AVG(BUDGET) > 21000;"))
   '((30000.0) (80000.0)))
)







;** sql\cdr017.sql
;**
;** Picked only the JOIN query from the file...
(sql "SCHEMA SUN")
(checkequal "SQL Test Suite\\sql\\cdr017.sql"
  ((sql "SELECT COUNT(*)
         FROM SIZ3_F,SIZ3_P1,SIZ3_P2,SIZ3_P3,SIZ3_P4, SIZ3_P5,SIZ3_P6 
         WHERE P1 = SIZ3_P1.F1 AND P2 = SIZ3_P2.F1 AND P3 = SIZ3_P3.F1 AND 
               P4 = SIZ3_P4.F1 AND P5 = SIZ3_P5.F1 AND P6 = SIZ3_P6.F1 AND
               SIZ3_P3.F1 BETWEEN 1 AND 2;") '((4)))
)


;** Test of query on a derived function
;**
(sql "SCHEMA DEFAULT")
(osql "
  create type person;
  create function name(person)->charstring n;
  create function age(person)->integer a;
  create function id(person)->integer i;
  create person(id, name, age) instances :a(1, \"Markus\", 30), :b(2, \"Fredrik\", 33), 
      :c(3, \"Daniel\", 26), :d(4, \"Elin\", 26);
  create function sql:person2(integer id)-><charstring name, integer age> as
     select n, a 
     from charstring n, integer a, person p 
     where id=id(p) and n=name(p) and a=age(p);
")
(checkequal "Query on derrived function"
  ((sql "select * from person2 order by name;") '(((3 "Daniel" 26)) ((4 "Elin" 26)) ((2 "Fredrik" 33)) ((1 "Markus" 30))))
  ((sql "select p1.name, p2.name, p1.age-p2.age 
         from person2 p1 inner join
              person2 p2 on p1.age>p2.age
         order by 1, 3 desc, 2;") 
   '((("Fredrik" "Daniel" 7)) (("Fredrik" "Elin" 7)) (("Fredrik" "Markus" 3))
     (("Markus" "Daniel" 4)) (("Markus" "Elin" 4))))
  ((sorttuples (sql "select * from person2 where age*2 < 60")) '((3 "Daniel" 26) (4 "Elin" 26)))
)
(sql "ROLLBACK WORK")
(sql "CREATE TABLE PERSON (NAME CHAR(30), AGE int, CITY varchar(25));")
(sql "INSERT INTO PERSON VALUES('Markus',29,'Uppsala'), ('Fredrik', 33, 'Husby'), ('Daniel', 27, 'Årsta');")
(checkequal "Simple tests"
  ((sorttuples (sql "SELECT name, age, city FROM PERSON;")) '(("Daniel" 27 "Årsta") ("Fredrik" 33 "Husby") ("Markus" 29 "Uppsala")))
  ((sql "COMMIT WORK;") nil)
  ((sql "UPDATE PERSON SET AGE = AGE+1 WHERE Name LIKE 'Mark%';") nil)
  ((sorttuples (sql "SELECT name, age, city FROM PERSON ORDER BY AGE;")) '((("Daniel" 27 "Årsta")) (("Fredrik" 33 "Husby")) (("Markus" 30 "Uppsala"))))
  ((sql "ROLLBACK WORK;") nil)
  ((sql "SELECT name, age, city FROM PERSON ORDER BY AGE;") '((("Daniel" 27 "Årsta")) (("Markus" 29 "Uppsala")) (("Fredrik" 33 "Husby"))))
  ((sql "SELECT COUNT(*) FROM PERSON;") '((3)))
)
(sql "DROP TABLE PERSON;")
(sql "COMMIT WORK;")
(sql "SCHEMA UU;")
(sql "CREATE TABLE Persons (id_person INT PRIMARY KEY, name CHAR(40), age INT, id_group INT);")
(sql "CREATE TABLE Cards (id_card INT PRIMARY KEY, id_person INT, active BOOLEAN);")
(sql "CREATE TABLE Rooms (id_room INT PRIMARY KEY, description VARCHAR(100));")
(sql "CREATE TABLE Access (id_card INT PRIMARY KEY, id_room INT PRIMARY KEY,active BOOLEAN);")
(sql "CREATE TABLE Groups (id_group INT PRIMARY KEY, description CHAR(50));")
(sql "INSERT INTO Groups (id_group, description) VALUES (1, 'Students'), (2, 'Administrative'), (3, 'Teachers');")
(sql "INSERT INTO Persons (id_person, name, age, id_group) VALUES (1, 'Tore', 55, 3), (2, 'Markus', 29, 1), (3, 'Ulrika', 35, 2), (4, 'Fredrik', 33, 1);")
(sql "INSERT INTO Cards (id_card, id_person, active) VALUES (1001, 1, 1), (2052, 2, 1), (1375, 3, 1), (2832, 4, 0);")
(sql "INSERT INTO Rooms VALUES (1357, 'Group office for temporary visitors'), (1446, 'Staff lunch room'), (1356, 'Personal office'), (1515, 'Computer room (UNIX)');")
(sql "INSERT INTO Access (id_card, id_room, active) VALUES (1001, 1356, 1), (1001, 1446, 1), (1001, 1357, 1), (2052, 1357, 1), (2052, 1515, 1), (1375, 1356, 1), (2832, 1515, 1);")
(checkequal "complex JOINs"
  ((sql "SELECT COUNT(*), AVG(age)  FROM Persons;") '((4 38)))
  ((sql "SELECT Groups.description, COUNT(Persons.id_person) 
         FROM Groups INNER JOIN
              Persons ON Groups.id_group = Persons.id_group INNER JOIN
              Cards ON Persons.id_person = Cards.id_person INNER JOIN
              Access ON Cards.id_card = Access.id_card 
         WHERE Access.id_room = 1357 GROUP BY Groups.description;")
   '(("Teachers" 1) ("Students" 1)))
  ((sql "SELECT p.name, r.id_room, r.description
         FROM Persons p INNER JOIN 
              Cards ON p.id_person = Cards.id_person INNER JOIN
              Access ON Cards.id_card = Access.id_card INNER JOIN
              Rooms r ON Access.id_room = r.id_room
         WHERE Cards.active = 1 ORDER BY p.name;") 
    '((("Markus" 1357 "Group office for temporary visitors")) (("Markus" 1515 "Computer room (UNIX)")) (("Tore" 1357 "Group office for temporary visitors")) (("Tore" 1356 "Personal office")) (("Tore" 1446 "Staff lunch room")) (("Ulrika" 1356 "Personal office"))))
)
(sql "ROLLBACK WORK;")



(sql "SCHEMA DEFAULT;")

;************************************ END OF sql-testdataload.lsp ************************************

