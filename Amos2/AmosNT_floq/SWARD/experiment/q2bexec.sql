 /*-*-sql-*-*******************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Johan Petrini, UDBL
 * 
 * Description: Scalability experiment measuring execution time 
 * (defined as execution time - cost based optimization time) in MSSQL Server. 
 * with content query, Q2, over an increasing TPC-H database size. 
 * We measure execution time for strategy Back-End (BE).  
 * Analogous to (and compared with) example Q2 with END in SWARD.
 *
 * ID: Q2b
 *
 * Parameters: Database used is TPC-H (0.03125 GB - 2GB).
 * Size of UPV fixed to 5 columns from Customer and Orders 
 * (the UPV 'u', is analogous to the 'Company' database as defined in 
 * company.sql).
 *
 * As DBMS we use MSSQL Server 2005 SP2.
 * Buffer size is 100 MB.
 *
 * Interbase/Firebird is stopped.
 *****************************************************************************/

/* Define pMap and cMap tbls and set property and class mappings
 */
create table PMAP(TN varchar(25), CN varchar(25), ONT varchar(25), 
			PROPID varchar(50), 
                   primary key(TN,CN,ONT),unique(ONT,PROPID))

insert into PMAP values ('CUSTOMER','C_CUSTKEY','COMP',
				'http://upv.com/schemas/company#CustID')
insert into PMAP values ('CUSTOMER','C_MKTSEGMENT','COMP',
				'http://upv.com/schemas/company#Market')
insert into PMAP values ('ORDERS','O_ORDERKEY','COMP',
				'http://upv.com/schemas/company#OrderID')
insert into PMAP values ('ORDERS','O_CUSTKEY','COMP',
				'http://upv.com/schemas/company#OrderCustomer')
insert into PMAP values ('ORDERS','O_CLERK','COMP',
				'http://upv.com/schemas/company#Clerk')

create table CMAP(TN varchar(25), ONT varchar(25), CLASSID varchar(50),
                  primary key (TN,ONT),unique(ONT,CLASSID))

insert into CMAP values ('CUSTOMER','COMP',
				'http://upv.com/schemas/company#Customer')
insert into CMAP values ('ORDERS','COMP',
				'http://upv.com/schemas/company#Orders')

create view CUSTIDV(S,P,V) 
  as select CM.CLASSID + '/' + cast(C.C_CUSTKEY as varchar(25)), PM.PROPID, cast(C.C_CUSTKEY as varchar(25)) from CUSTOMER C, CMAP CM, PMAP PM 
     where PM.TN = 'CUSTOMER' and PM.CN = 'C_CUSTKEY' and PM.ONT = 'COMP' and CM.TN = 'CUSTOMER' and CM.ONT = 'COMP'

create view MKTSEGMENTV(S,P,V) 
  as select CM.CLASSID + '/' + cast(C.C_CUSTKEY as varchar(25)), PM.PROPID, cast(C.C_MKTSEGMENT as varchar(25)) from CUSTOMER C, CMAP CM, PMAP PM
     where PM.TN = 'CUSTOMER' and PM.CN = 'C_MKTSEGMENT' and PM.ONT = 'COMP' and CM.TN= 'CUSTOMER' and CM.ONT = 'COMP'

create view ORDERIDV(S,P,V) 
  as select CM.CLASSID + '/' + cast(O.O_ORDERKEY as varchar(25)), PM.PROPID, cast(O.O_ORDERKEY as varchar(25)) from ORDERS O, CMAP CM, PMAP PM
     where PM.TN = 'ORDERS' and PM.CN = 'O_ORDERKEY' and PM.ONT = 'COMP' and CM.TN = 'ORDERS' and CM.ONT = 'COMP'

create view OCUSTIDV(S,P,V) 
  as select CM.CLASSID + '/' + cast(O.O_ORDERKEY as varchar(25)), PM.PROPID, cast(O.O_CUSTKEY as varchar(25)) from ORDERS O, CMAP CM, PMAP PM
     where PM.TN = 'ORDERS' and PM.CN = 'O_CUSTKEY' and PM.ONT = 'COMP' and CM.TN= 'ORDERS' and CM.ONT = 'COMP'

create view CLERKV(S,P,V) 
  as select CM.CLASSID + '/' + cast(O.O_ORDERKEY as varchar(25)), PM.PROPID, cast(O.O_CLERK as varchar(25)) from ORDERS O, CMAP CM, PMAP PM
     where PM.TN = 'ORDERS' and PM.CN = 'O_CLERK' and PM.ONT = 'COMP' and CM.TN= 'ORDERS' and CM.ONT = 'COMP'

/*
create view CUSTIDV(S,P,V) 
  as select CM.CLASSID + '/' + C.C_CUSTKEY, PM.PROPID, C.C_CUSTKEY from CUSTOMER C, CMAP CM, PMAP PM 
     where PM.TN = 'CUSTOMER' and PM.CN = 'C_CUSTKEY' and PM.ONT = 'COMP' and CM.TN = 'CUSTOMER' and CM.ONT = 'COMP'

create view MKTSEGMENTV(S,P,V) 
  as select CM.CLASSID + '/' + C.C_CUSTKEY, PM.PROPID, C.C_MKTSEGMENT from CUSTOMER C, CMAP CM, PMAP PM
     where PM.TN = 'CUSTOMER' and PM.CN = 'C_MKTSEGMENT' and PM.ONT = 'COMP' and CM.TN= 'CUSTOMER' and CM.ONT = 'COMP'

create view ORDERIDV(S,P,V) 
  as select CM.CLASSID + '/' + O.O_ORDERKEY, PM.PROPID, O.O_ORDERKEY from ORDERS O, CMAP CM, PMAP PM
     where PM.TN = 'ORDERS' and PM.CN = 'O_ORDERKEY' and PM.ONT = 'COMP' and CM.TN = 'ORDERS' and CM.ONT = 'COMP'

create view OCUSTIDV(S,P,V) 
  as select CM.CLASSID + '/' + O.O_ORDERKEY, PM.PROPID, O.O_CUSTKEY from ORDERS O, CMAP CM, PMAP PM
     where PM.TN = 'ORDERS' and PM.CN = 'O_CUSTKEY' and PM.ONT = 'COMP' and CM.TN= 'ORDERS' and CM.ONT = 'COMP'

create view CLERKV(S,P,V) 
  as select CM.CLASSID + '/' + O.O_ORDERKEY, PM.PROPID, O.O_CLERK from ORDERS O, CMAP CM, PMAP PM
     where PM.TN = 'ORDERS' and PM.CN = 'O_CLERK' and PM.ONT = 'COMP' and CM.TN= 'ORDERS' and CM.ONT = 'COMP'

*/

/* Define materialized schema view S 
 */
create table S(S varchar(75),P varchar(75),V varchar(75),
			primary key (S,P,V))

insert into S values ('http://upv.com/schemas/company#CustID','http://www.w3.org/2000/01/rdf-schema#range','http://www.w3.org/2000/01/rdf-schema#Literal')  
insert into S values ('http://upv.com/schemas/company#CustID','http://www.w3.org/2000/01/rdf-schema#domain','http://upv.com/schemas/company#Customer')
insert into S values ('http://upv.com/schemas/company#CustID','http://www.w3.org/1999/02/22-rdf-syntax-ns#type','http://www.w3.org/1999/02/22-rdf-syntax-ns#Property')
insert into S values ('http://upv.com/schemas/company#Orders','http://www.w3.org/1999/02/22-rdf-syntax-ns#type','http://www.w3.org/2000/01/rdf-schema#Class')
insert into S values ('http://upv.com/schemas/company#OrderID','http://www.w3.org/2000/01/rdf-schema#range','http://www.w3.org/2000/01/rdf-schema#Literal')
insert into S values ('http://upv.com/schemas/company#OrderID','http://www.w3.org/2000/01/rdf-schema#domain','http://upv.com/schemas/company#Orders')
insert into S values ('http://upv.com/schemas/company#OrderID','http://www.w3.org/1999/02/22-rdf-syntax-ns#type','http://www.w3.org/1999/02/22-rdf-syntax-ns#Property')
insert into S values ('http://upv.com/schemas/company#Customer','http://www.w3.org/1999/02/22-rdf-syntax-ns#type','http://www.w3.org/2000/01/rdf-schema#Class')
insert into S values ('http://upv.com/schemas/company#OrderCustomer','http://www.w3.org/2000/01/rdf-schema#range','http://www.w3.org/2000/01/rdf-schema#Literal')
insert into S values ('http://upv.com/schemas/company#OrderCustomer','http://www.w3.org/2000/01/rdf-schema#domain','http://upv.com/schemas/company#Orders')
insert into S values ('http://upv.com/schemas/company#OrderCustomer','http://www.w3.org/1999/02/22-rdf-syntax-ns#type','http://www.w3.org/1999/02/22-rdf-syntax-ns#Property')
insert into S values ('http://upv.com/schemas/company#Clerk','http://www.w3.org/2000/01/rdf-schema#range','http://www.w3.org/2000/01/rdf-schema#Literal')
insert into S values ('http://upv.com/schemas/company#Clerk','http://www.w3.org/2000/01/rdf-schema#domain','http://upv.com/schemas/company#Orders')
insert into S values ('http://upv.com/schemas/company#Clerk','http://www.w3.org/1999/02/22-rdf-syntax-ns#type','http://www.w3.org/1999/02/22-rdf-syntax-ns#Property')
insert into S values ('http://upv.com/schemas/company#Market','http://www.w3.org/2000/01/rdf-schema#range','http://www.w3.org/2000/01/rdf-schema#Literal')
insert into S values ('http://upv.com/schemas/company#Market','http://www.w3.org/2000/01/rdf-schema#domain','http://upv.com/schemas/company#Customer')
insert into S values ('http://upv.com/schemas/company#Market','http://www.w3.org/1999/02/22-rdf-syntax-ns#type','http://www.w3.org/1999/02/22-rdf-syntax-ns#Property')

/* Defining the UPV
 */
create view U(S,P,V)
  as (select * from CUSTIDV)     union all
     (select * from MKTSEGMENTV) union all
     (select * from ORDERIDV)    union all
     (select * from OCUSTIDV)    union all
     (select * from CLERKV)      union all
     (select * from S)     

/* Measure compilation (optimization) and execution time in MSSQL Server
 */
SET STATISTICS TIME ON

/* Define example content query Q2
 */ 
 select C4.V, C4.S
 from U C1,
      U C2,
      U C3,
      U C4
 where C1.P = 'http://upv.com/schemas/company#OrderID' and
       C2.P = 'http://upv.com/schemas/company#OrderCustomer' and
       C3.P = 'http://upv.com/schemas/company#CustID' and       
       C4.P = 'http://upv.com/schemas/company#Market' and
       C1.V = '1' and
       C1.S = C2.S and
       C2.V = C3.V and
       C3.S = C4.S

SET STATISTICS TIME OFF
