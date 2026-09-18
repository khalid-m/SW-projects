create table EUCOUNTRY(COUNTRY varchar(50) not null,
			CURRENCY varchar(20),
                       primary key (country));


create table LIFEEVENT(LID varchar(25) not null,
                       NAME varchar(25),
		       COUNTRY varchar(50),
		       LANG varchar(25),
		       DESCR varchar(250),
                       LAW varchar(25) DEFAULT NULL,
		       primary key (LID));



create table FORM(FID varchar(25) not null,
                  URL varchar(150),
                  CREATOR varchar(75),
                  NOFF integer,
                  LIFEEVENT varchar(25),
	          primary key (FID)
		);

                 

create table regress.SERVICE(SNR varchar(25) not null,
                     LIFEEVENT varchar(25) not null,
                     primary key (SNR,LIFEEVENT)  );



insert into eucountry
        (country,currency)
        values
        ('italy','euro');

insert into eucountry
        (country,currency)
        values
        ('germany',NULL);

insert into eucountry
        (country,currency)
        values
        ('france','euro');

insert into eucountry
        (country,currency)
        values
        ('spain','euro');

insert into eucountry
        (country,currency)
        values
        ('sweden','swedish crown');

insert into eucountry
        (country,currency)
        values
        ('bulgaria','lev');

insert into eucountry
        (country,currency)
        values
        ('hungary',NULL);		   

insert into LIFEEVENT (LID, NAME,country, LANG, DESCR) values ('movinghouse','Moving House','italy','EN','A citizen intends to move from one EU country to another.'); 
insert into LIFEEVENT (LID, NAME,country, LANG, DESCR, LAW) values ('eujob','Job','germany', 'EN','A citizen from one EU country intends to look for a job in another EU country .','JEU1023'); 
insert into LIFEEVENT (LID, NAME) values ('adaptpn','Adapt the personal number');

insert into FORM
	(FID,URL,CREATOR,NOFF,LIFEEVENT)
	values 
	('fid0','http://www.skatteverket.se/etjanster/skrivutpersonbevis.4.18e1b10334ebe8bc80001262.html','National Tax Board of Sweden',25,'movinghouse'); 

insert into FORM
	(FID,URL,CREATOR,NOFF,LIFEEVENT)
	values 
	('fid1','http://www.skatteverket.se/download/18.3dfca4f410f4fc63c86800010627/7665B5.pdf','National Tax Board of Sweden',129,'movinghouse'); 

insert into FORM
	(FID,URL,CREATOR,NOFF,LIFEEVENT)
	values 
	('fid2','http://www.workpermit.com/uk/employer_form.htm','http://www.workpermit.com',59,'movinghouse');

insert into SERVICE
        (SNR,LIFEEVENT)
        values
        ('fid0','movinghouse');






alter table form add constraint form_lifeevnt FOREIGN KEY (LIFEEVENT) REFERENCES LIFEEVENT(LID);

alter table lifeevent add constraint lifeevnt_contr FOREIGN KEY (COUNTRY) REFERENCES EUCOUNTRY(COUNTRY);

