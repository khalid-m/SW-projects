create table FORM(FID integer not null,
                  URL varchar(150),
                  CREATOR varchar(75),
                  NOFP integer,
	          primary key (FID));

create table LIFEEVENT(EID integer not null,
		       LANG varchar(25),
		       DESCR varchar(150),
                       LAW varchar(25),
		       FORM integer,
		       primary key (EID),
                       foreign key (FORM) references FORM(FID));

create table FAQLISTS(EID integer not null,
		      FAQNR integer not null,
		      QUESTION varchar(75),
		      ANSWER varchar(50),
		      primary key (EID,FAQNR));

create table RELATEDSERVICES(EID integer not null,
			     SERVICENR integer not null,
			     TITLE varchar(50),
			     primary key (EID,SERVICENR));

create table FP(FVID integer not null,
                FORM integer,
	        FIID integer,
                PROP varchar(75),
	        VAL varchar(150),
		primary key (FVID),
                foreign key (FORM) references FORM(FID));

insert into FORM
	(FID,URL,CREATOR,NOFP)
	values 
	(0,'http://www.skatteverket.se/etjanster/flyttanmalan.4.7459477810df5bccdd480004564.html','National Tax Board of Sweden',27);

insert into FORM
	(FID,URL,CREATOR,NOFP)
	values 
	(1,'http://www.skatteverket.se/etjanster/inkomstdeklaration.4.18e1b10334ebe8bc80005676.html','The Swedish Social Insurance Agency',46);

insert into FORM
	(FID,URL,CREATOR,NOFP)
	values 
	(2,'http://forsakringskassan.se/privatpers/foralder/komigang_it/anm_fp/?page=/privatpers/foralder/index.php','The Swedish Social Insurance Agency',20);

insert into FORM
	(FID,URL,CREATOR,NOFP)
	values 
	(3,'http://forsakringskassan.se/tjanster/ansokpension/?page=/privatpers/pensionar/index.php','The Swedish Social Insurance Agency',18);


insert into LIFEEVENT 
	(EID, LANG, DESCR, LAW, FORM) 
	values 
	(0,'SV','About moving withing Sweden','',0); 

insert into LIFEEVENT 
	(EID, LANG, DESCR, LAW, FORM) 
	values 
	(1,'SV','About paying tax','',1); 

insert into LIFEEVENT 
	(EID, LANG, DESCR, LAW, FORM) 
	values 
	(2,'SV','About becoming a parent','',2); 

insert into LIFEEVENT 
	(EID, LANG, DESCR, LAW, FORM) 
	values 
	(3,'SV','About retiring on a pension','',3); 

insert into FAQLISTS 
	(EID, FAQNR, QUESTION, ANSWER) 
	values
	(0, 1,'Possibillity to pay tax online','Yes');

insert into RELATEDSERVICES  
	(EID, SERVICENR, TITLE) 
	values
	(1, 0, 'Tax adjustment');


GO
create function getNOFP (@fid integer)
returns integer
as
begin
 declare @res as integer;
 set @res = (select nofp from FORM where fid = @fid);
 return @res;
end

GO
create procedure populateFP @nofi integer
as
declare @fvid as integer, 
        @fid as integer, 
        @fiid as integer, 
        @count as integer,
        @nofp as integer,
        @nof as integer;
set @fid = 0;
set @fvid = 0;
set @nof = (select count(FID) from FORM);
while(@fid < @nof)
begin
 set @fiid = 0;
 while(@fiid < @nofi)
 begin
  set @nofp = 0;
  set @count = 0;
  set @nofp =  (select nofp from FORM where fid = @fid);    
  while(@count < @nofp)
  begin
   insert into FP(FVID,FIID,FORM,PROP,VAL) values (@fvid,@fiid,@fid,'Property' + cast(@count as varchar(20)),'Value'+cast(@count as varchar(20)));
   set @count = @count + 1;
   set @fvid = @fvid + 1;
  end
  set @fiid = @fiid + 1;
 end
set @fid = @fid + 1;
end

GO
populateFP 2 /*Generates 115000 rows in FP table*/

