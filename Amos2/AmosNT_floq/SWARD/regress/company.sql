create table CUSTOMER(CUSTID varchar(10) not null,
		      MKTSEGMENT varchar(10),
		      primary key (CUSTID));

create table ORDERS(ORDERID varchar(10) not null,
		    OCUSTID varchar(10) not null,
		    CLERK varchar(15),
                    foreign key (OCUSTID) references CUSTOMER(CUSTID),
	            primary key (ORDERID));

create table LINEITEM(LINENUMBER varchar(10) not null,
                      LORDERID varchar(10) not null,
                      PARTID varchar(30),
		      QUANTITY varchar(15),
                      foreign key (LORDERID) references ORDERS(ORDERID),
	              primary key (LORDERID,LINENUMBER));


insert into CUSTOMER 
	(CUSTID, MKTSEGMENT) 
	values 
	('120','AUTOMOBILE'); 

insert into ORDERS 
	(ORDERID, OCUSTID, CLERK) 
	values
	('1', '120', 'Wesson');

insert into ORDERS  
	(ORDERID, OCUSTID, CLERK) 
	values
	('2', '120', 'Doe');

insert into LINEITEM  
	(LINENUMBER, LORDERID, PARTID, QUANTITY) 
	values
	('12345','2','Semiconductors','150');

