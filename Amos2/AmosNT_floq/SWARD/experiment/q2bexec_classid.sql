/* Define pMap and cMap tbls and set property and class mappings
 */
create table PMAP(TN varchar(25), CN varchar(25), ONT varchar(25), 
			PROPID varchar(50), 
                   primary key(TN,CN,ONT),unique(ONT,PROPID))

insert into PMAP values ('CUSTOMER','CUSTID','COMP',
				'http://upv.com/schemas/company#CustID')
insert into PMAP values ('CUSTOMER','MKTSEGMENT','COMP',
				'http://upv.com/schemas/company#Market')
insert into PMAP values ('ORDERS','ORDERID','COMP',
				'http://upv.com/schemas/company#OrderID')
insert into PMAP values ('ORDERS','OCUSTID','COMP',
				'http://upv.com/schemas/company#OrderCustomer')
insert into PMAP values ('ORDERS','CLERK','COMP',
				'http://upv.com/schemas/company#Clerk')

create table CMAP(TN varchar(25), ONT varchar(25), CLASSID varchar(50),
                  primary key (TN,ONT),unique(ONT,CLASSID))

insert into CMAP values ('CUSTOMER','COMP',
				'http://upv.com/schemas/company#Customer')
insert into CMAP values ('ORDERS','COMP',
				'http://upv.com/schemas/company#Orders')

create view CUSTIDV(S,P,V) 
  as select KP.PROPID + '/' + cast(C.CUSTID as varchar(25)), KP.PROPID, cast(C.CUSTID as varchar(100)) from CUSTOMER C, PMAP KP
     where KP.TN = 'CUSTOMER' and KP.CN = 'CUSTID' and KP.ONT = 'COMP' 

create view MKTSEGMENTV(S,P,V) 
  as select KP.PROPID + '/' + cast(C.CUSTID as varchar(25)), P.PROPID, cast(C.MKTSEGMENT as varchar(100)) from CUSTOMER C, PMAP P, PMAP KP
     where KP.TN = 'CUSTOMER' and KP.CN = 'CUSTID' and KP.ONT = 'COMP' and P.TN= 'CUSTOMER' and P.CN = 'MKTSEGMENT' and P.ONT = 'COMP'

create view ORDERIDV(S,P,V) 
  as select KP.PROPID + '/' + cast(O.ORDERID as varchar(25)), KP.PROPID, cast(O.ORDERID as varchar(100)) from ORDERS O, PMAP KP
     where KP.TN = 'ORDERS' and KP.CN = 'ORDERID' and KP.ONT = 'COMP'

create view OCUSTIDV(S,P,V) 
  as select KP.PROPID + '/' + cast(O.ORDERID as varchar(25)), P.PROPID, cast(O.OCUSTID as varchar(100)) from ORDERS O, PMAP P, PMAP KP
     where KP.TN = 'ORDERS' and KP.CN = 'ORDERID' and KP.ONT = 'COMP' and P.TN= 'ORDERS' and P.CN = 'OCUSTID' and p.ont = 'COMP'

create view CLERKV(S,P,V) 
  as select KP.PROPID + '/' + cast(O.ORDERID as varchar(25)), P.PROPID, cast(O.CLERK as varchar(100)) from ORDERS O, PMAP P, PMAP KP
     where KP.TN = 'ORDERS' and KP.CN = 'ORDERID' and KP.ONT = 'COMP' and P.TN= 'ORDERS' and P.CN = 'CLERK' and P.ONT = 'COMP'

/* Define materialized Schema view S 
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
create view COMP(S,P,V)
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
 from COMP C1,
      COMP C2,
      COMP C3,
      COMP C4
 where C1.P = 'http://upv.com/schemas/company#OrderID' and
       C2.P = 'http://upv.com/schemas/company#OrderCustomer' and
       C3.P = 'http://upv.com/schemas/company#CustID' and       
       C4.P = 'http://upv.com/schemas/company#Market' and
       C1.V = '1' and
       C1.S = C2.S and
       C2.V = C3.V and
       C3.S = C4.S

SET STATISTICS TIME OFF