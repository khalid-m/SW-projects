create table CUSTOMER(CUSTID integer not null,
		      MKTSEGMENT varchar(10),
		      primary key (CUSTID));

create table ORDERS(ORDERID integer not null,
		    OCUSTID integer not null,
		    CLERK varchar(15),
                    foreign key (OCUSTID) references CUSTOMER(CUSTID),
	            primary key (ORDERID));

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
