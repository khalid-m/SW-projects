create table CUSTOMER(CUSTID integer not null,
		      MKTSEGMENT varchar(10),
		      primary key (CUSTID));

create table ORDERS(ORDERID integer not null,
		    OCUSTID integer not null,
		    CLERK varchar(15),
                    foreign key (OCUSTID) references CUSTOMER(CUSTID),
	            primary key (ORDERID));

create table LINEITEM(LINENUMBER integer not null,
                      LORDERID integer not null,
                      PARTID varchar(30),
		      QUANTITY integer,
                      foreign key (LORDERID) references ORDERS(ORDERID),
	              primary key (LORDERID,LINENUMBER));


insert into CUSTOMER 
	(CUSTID, MKTSEGMENT) 
	values 
	(120,'AUTOMOBILE'); 

insert into ORDERS 
	(ORDERID, OCUSTID, CLERK) 
	values
	(1, 120, 'Wesson');

insert into ORDERS  
	(ORDERID, OCUSTID, CLERK) 
	values
	(2, 120, 'Doe');

insert into LINEITEM  
	(LINENUMBER, LORDERID, PARTID, QUANTITY) 
	values
	(12345,2,'Semiconductors',150);

