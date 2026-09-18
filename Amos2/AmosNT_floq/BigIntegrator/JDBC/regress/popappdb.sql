create table EMPLOYEE2 (
  EID INT PRIMARY KEY,
  Name VARCHAR(100),
  Skill VARCHAR(100),
  Salary INT,
  MID INT);
  
create table LOGDATA (
  TID DATETIME,
  Variable VARCHAR(100),
  Value float);  

insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (1, 'John', 'Operation', 58000, 1);
insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (2, 'Oliver', 'Operation', 30000, 2);
insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (3, 'Bruce', 'Operation', 40000, 3);
insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (4, 'Carl', 'Operation', 56000, 4);
insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (5, 'Thomas', 'Operation', 70000, 5);
insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (6, 'Jens', 'Operation', 45000, 6);
insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (7, 'Lucas', 'Operation', 62000, 7);
insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (8, 'Alex', 'Operation', 85000, 8);
insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (9, 'Ryan', 'Operation', 33000, 9);
insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (10, 'Wes', 'Operation', 50000, 10);

insert into LOGDATA (TID, Variable, Value) values ('2012-05-11 11:40:40.000', 'DATALOSS', 1);
insert into LOGDATA (TID, Variable, Value) values ('2012-05-11 11:40:40.000', 'DATALOSS', 3);
insert into LOGDATA (TID, Variable, Value) values ('2012-05-11 11:40:40.000', 'EMOTOR2', 1);
insert into LOGDATA (TID, Variable, Value) values ('2012-05-11 11:40:40.000', 'EMOTOR3', 1);
insert into LOGDATA (TID, Variable, Value) values ('2012-05-11 11:40:40.000', 'DOUT01', 0);

commit;

