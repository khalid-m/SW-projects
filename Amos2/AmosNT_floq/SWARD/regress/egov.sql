create table LIFEEVENT(LID varchar(25) not null,
                       NAME varchar(25),
		       LANG varchar(25),
		       DESCR varchar(250),
                       LAW varchar(25),
		       primary key (LID));

create table FORM(FID varchar(25) not null,
                  URL varchar(150),
                  CREATOR varchar(75),
                  NOFF varchar(25),
                  LIFEEVENT varchar(25),
	          primary key (FID),
                  foreign key (LIFEEVENT) references LIFEEVENT(LID));

create table SERVICE(SNR varchar(25) not null,
                     LIFEEVENT varchar(25) not null,
                     TITLE varchar(150),
	             primary key (SNR,LIFEEVENT),
                     foreign key (LIFEEVENT) references LIFEEVENT(LID));

insert into LIFEEVENT 
	(LID, NAME, LANG, DESCR, LAW) 
	values 
	('movinghouse','Moving House', 'EN','A citizen intends to move from one EU country to another.',''); 

insert into FORM
	(FID,URL,CREATOR,NOFF,LIFEEVENT)
	values 
	('fid_0','http://www.skatteverket.se/etjanster/skrivutpersonbevis.4.18e1b10334ebe8bc80001262.html','National Tax Board of Sweden','25','movinghouse'); 

insert into FORM
	(FID,URL,CREATOR,NOFF,LIFEEVENT)
	values 
	('fid_1','http://www.skatteverket.se/download/18.3dfca4f410f4fc63c86800010627/7665B5.pdf','National Tax Board of Sweden','129','movinghouse'); 

insert into FORM
	(FID,URL,CREATOR,NOFF,LIFEEVENT)
	values 
	('fid_2','http://www.workpermit.com/uk/employer_form.htm','http://www.workpermit.com','59','movinghouse');

insert into SERVICE
        (SNR,LIFEEVENT,TITLE)
        values
        ('0','movinghouse','Moving Service');
