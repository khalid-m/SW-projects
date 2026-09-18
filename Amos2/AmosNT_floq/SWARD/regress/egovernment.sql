create table LIFEEVENT(LID integer not null,
		       LANG varchar(25),
		       DESCR varchar(150),
                       LAW varchar(25),
		       primary key (LID));

create table FORM(FID integer not null,
                  URL varchar(150),
                  CREATOR varchar(75),
                  NOFP integer,
                  LIFEEVENT integer,
	          primary key (FID),
                  foreign key (LIFEEVENT) references LIFEEVENT(LID));

create table FI(FID integer not null,
                FIID integer not null,
                PID varchar(25) not null,
                VAL varchar(50),
	        primary key (FID,FIID,PID),
                foreign key (FID) references FORM(FID));

create table FAQLISTS(LID integer not null,
		      FAQNR integer not null,
		      QUESTION varchar(75),
		      ANSWER varchar(50),
		      primary key (LID,FAQNR));

create table RELATEDSERVICES(LID integer not null,
			     SERVICENR integer not null,
			     TITLE varchar(50),
			     primary key (LID,SERVICENR));


insert into LIFEEVENT 
	(LID, LANG, DESCR, LAW) 
	values 
	(0,'SV','About moving withing Sweden',''); 

insert into LIFEEVENT 
	(LID, LANG, DESCR, LAW) 
	values 
	(1,'SV','About paying tax',''); 

insert into LIFEEVENT 
	(LID, LANG, DESCR, LAW) 
	values 
	(2,'SV','About becoming a parent',''); 

insert into LIFEEVENT 
	(LID, LANG, DESCR, LAW) 
	values 
	(3,'SV','About retiring on a pension',''); 

insert into FORM
	(FID,URL,CREATOR,NOFP,LIFEEVENT)
	values 
	(0,'http://www.skatteverket.se/etjanster/flyttanmalan.4.7459477810df5bccdd480004564.html','National Tax Board of Sweden',1,0);

insert into FORM
        (FID,URL,CREATOR,NOFP,LIFEEVENT)
        values
       (1,'http://www.skatteverket.se/etjanster/inkomstdeklaration.4.18e1b10334ebe8bc80005676.html','The Swedish Social Insurance Agency',0,1);

insert into FORM
	(FID,URL,CREATOR,NOFP,LIFEEVENT)
	values 
	(2,'http://forsakringskassan.se/privatpers/foralder/komigang_it/anm_fp/?page=/privatpers/foralder/index.php','The Swedish Social Insurance Agency',0,2);

insert into FORM
	(FID,URL,CREATOR,NOFP,LIFEEVENT)
	values 
	(3,'http://forsakringskassan.se/tjanster/ansokpension/?page=/privatpers/pensionar/index.php','The Swedish Social Insurance Agency',0,3);

insert into FI
	(FID,FIID,PID,VAL) 
	values 
	(0, 0, 'Age', '24'); 

insert into FAQLISTS 
	(LID, FAQNR, QUESTION, ANSWER) 
	values
	(0, 1,'Possibillity to pay tax online','Yes');

insert into RELATEDSERVICES  
	(LID, SERVICENR, TITLE) 
	values
	(1, 0, 'Tax adjustment');
