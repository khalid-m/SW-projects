create table CUSTOMER(C_CUSTKEY integer not null,
	              C_NAME varchar(25),
                      C_ADDRESS varchar(25),
                      C_NATIONKEY integer,
                      C_PHONE varchar(25),
                      C_ACCTBAL integer,
                      C_MKTSEGMENT varchar(25),
                      C_COMMENT varchar(25),
                      primary key (C_CUSTKEY));


create table ORDERS(O_ORDERKEY integer not null,
	            O_CUSTKEY integer not null,
		    O_ORDERSTATUS varchar(25),
		    O_TOTALPRICE integer,
		    O_ORDERDATE varchar(25),
		    O_ORDERPRIORITY varchar(25),	
		    O_CLERK varchar(25),
		    O_SHIPPRIORITY integer,
	            O_COMMENT varchar(25),
                    foreign key (O_CUSTKEY) references CUSTOMER(C_CUSTKEY),
	            primary key (O_ORDERKEY));

insert into CUSTOMER 
	(C_CUSTKEY, C_NAME, C_ADDRESS, C_NATIONKEY, C_PHONE, C_ACCTBAL, C_MKTSEGMENT, C_COMMENT) 
	values 
	(120,'Jim','Street 4',7,'12345',56000,'AUTOMOBILE','nice guy'); 

insert into ORDERS 
	(O_ORDERKEY, O_CUSTKEY, O_ORDERSTATUS, O_TOTALPRICE, O_ORDERDATE, O_ORDERPRIORITY, O_CLERK, O_SHIPPRIORITY, O_COMMENT) 
	values
	(1,120,'OK',23000,'25-07-07','Important','Wesson',2,'Revolver');

insert into ORDERS  
	(O_ORDERKEY, O_CUSTKEY, O_ORDERSTATUS, O_TOTALPRICE, O_ORDERDATE, O_ORDERPRIORITY, O_CLERK, O_SHIPPRIORITY, O_COMMENT) 
	values
	(2, 120,'NO',45000,'26-07-07','Unimportant','Doe',1,'Glock');
