create table RELATEDSERVICES(EID varchar(25) not null,
			SERVICENR integer not null,
			NAME varchar(50),
			primary key (EID,SERVICENR));

CREATE TABLE AUTHORS(
	AUTHOR_ID INTEGER NOT NULL, 
	NAME VARCHAR(50),
	SURNAME VARCHAR(50),
	PRIMARY KEY(AUTHOR_ID)
);


insert into RELATEDSERVICES  
	(EID, SERVICENR, NAME) 
	values
	('ABC1234H', 1, 'Issuing a birth certificate');


insert into RELATEDSERVICES  
	(EID, SERVICENR, NAME) 
	values
	('ABC1234H', 2, 'Online payment');

INSERT INTO AUTHORS(AUTHOR_ID,NAME, SURNAME) VALUES(1,'GREG', 'BARISH');
INSERT INTO AUTHORS(AUTHOR_ID,NAME,SURNAME) VALUES(2,'TIMOTHY', 'BUDD');

