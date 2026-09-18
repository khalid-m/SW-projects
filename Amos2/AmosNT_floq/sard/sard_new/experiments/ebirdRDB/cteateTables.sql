/*---------------Darwin Core-designed RDBMS---------------------------*/

create table location(  lid int NOT NULL IDENTITY(0,1),
			locationID  varchar(255),
			continent varchar(32),
			waterBody varchar(255),
			islandGroup varchar(255),
			island varchar(255),
			country varchar(64),
			countryCode varchar(3),
			stateProvince varchar(255),
			county varchar(255),
			municipality varchar(255),
			locality varchar(100),
			decimalLatitude numeric(12,8),
			decimalLongitude numeric(12,8),
			primary key (lid));


create table event(	eid int NOT NULL IDENTITY(0,1),
		 	eventID varchar(255),
			samplingProtocol varchar(100),
			samplingEffort varchar(255),
			eventDate date,
			eventTime datetime,
			location int NOT NULL,
			primary key (eid));

create table occurrence(oid int NOT NULL IDENTITY(0,1),
			occurrenceID  varchar(255),
			recordNumber varchar(32),
			recordedBy varchar(255),
			individualID varchar(255),
			individualCount int,
			sex varchar(32),
			lifeStage varchar(32),
			event int NOT NULL,
			taxon int NOT NULL,
			primary key (oid));
	
create table taxon	(tid int NOT NULL IDENTITY(0,1),
			taxonID varchar(255),
			scientificNameID varchar(255),
			scientificName varchar(255),
			acceptedNameUsage varchar(255),
			kingdom varchar(32),
			phylum varchar(255),
			class varchar(255),
			taxon_order varchar(255),
			family varchar(255),
			genus varchar(255),
			primary key (tid));

alter table occurrence add constraint event_of_occ foreign key (event) references event(eid); 

alter table occurrence add constraint taxon_at_occ foreign key (taxon) references taxon(tid); 

alter table event add constraint location_of_event foreign key (location) references location(lid); 


/*Indexes necessary for quick insert */

CREATE UNIQUE INDEX location_ind 
     ON ebird2003.location (country, stateProvince,decimalLatitude,decimalLongitude)
     
     
CREATE UNIQUE INDEX event_ind 
     ON ebird2003.event (eventID, eventDate, location) ;
     
     
CREATE UNIQUE INDEX occurrence_ind 
     ON ebird2003.occurrence (event,taxon) ;
     
CREATE UNIQUE INDEX taxon_ind 
     ON ebird2003.taxon (scientificName) ;


/*------------Un-normalized eBird data in one big table------------------------------------*/

create table ebird2007.checklist(	
			SAMPLING_EVENT_ID varchar(25),
			LATITUDE  numeric(12,8),
			LONGITUDE numeric(12,8),
			YEAR integer,
			MONTH integer,
			DAY varchar(3),
			TIME varchar(10),
			COUNTRY varchar(50),
			STATE_PROVINCE varchar(50),
			COUNT_TYPE varchar(10),
			EFFORT_HRS varchar(10),
			EFFORT_DISTANCE_KM real,
			EFFORT_AREA_HA real,
			OBSERVER_ID varchar (100),
			NUMBER varchar(5),
			SPECIESLIST varchar(8000),
			primary key (SAMPLING_EVENT_ID));



/*-----3 NF normalized taxonomy-------------------------------------------*/
create table category(catid int NOT NULL IDENTITY,
                      category varchar(20),
		       primary key (catid));

create table ord(orderid int NOT NULL IDENTITY,
	           categ int,
                   order_name varchar(50),
 	       	   primary key (orderid));

create table family(familyid int NOT NULL IDENTITY,
	           ord int,
                   family_name varchar(50),
 	       	   primary key (familyid));


create table genus(gid int NOT NULL IDENTITY,
		   fam int,                  
                   genus_name varchar(50),
                   primary key (gid));


create table species(specie_id int NOT NULL IDENTITY,
                     sci_name varchar(50),
		     taxon_order int not null,
		     primary_com_name varchar(50) not null,  	              
                     genus int,
		     species_name varchar(25),
		     primary key (specie_id));


alter table ord add constraint cat_of_ord foreign key (categ) references category(catid);

alter table family add constraint ord_of_fam foreign key (ord) references ord(orderid);

alter table genus add constraint fam_of_gen foreign key (fam) references family(familyid);

alter table species add constraint genus_of_specie foreign key (genus) references genus(gid);


/************************************************/

/*SQL server function parsing strings like 
'Anous_stolidus:300 Calonectris_diomedea:3 Fregata_magnificens:21' 
and puttin the results in a temporary table*/ 
create function parseDocfun (@document varchar(1000))
RETURNS @tab TABLE
(spec varchar(30), 
 num varchar(3))
AS
 BEGIN
DECLARE @poss int,@spec varchar(30), @num varchar(3)
while LEN(@document)>0
 begin
 if (@document <>' ')
 begin
	set @poss= patindex('%:%',@document);
	if (@poss <> 0)
		begin
		 set @spec = SUBSTRING(@document,1,@poss-1) 
		 set @document= substring(@document,@poss+1,len(@document))
		 if (select patindex('% %',@document))<> 0 
		  begin
			set @num = SUBSTRING(@document,1,patindex('% %',@document));
			if ((select @num) ='?' or (select @num) ='X')  set @num=NULL;
			insert into @tab select @spec,@num;
			set @document= ltrim(substring(@document,patindex('% %',@document),len(@document)));			
		   end;
		 else
		   if (select patindex('% %',@document)) = 0 
		  begin
			set @num=SUBSTRING(@document,1,len(@document));
			if ((select @num) ='?' or (select @num) ='X')  set @num=NULL;
			insert into @tab select @spec, @num;
			set @document='';
		  end
	    end;
	else
       begin
		set @spec=@document;
		set @num=NULL;
		insert into @tab select @spec, @num;
		set @document=''; 
	  end;
  end;
 end;
 RETURN
END


/*Not needed*/

create procedure parseDoc
@document varchar(1000)
AS
 BEGIN
DECLARE @poss int
DECLARE @num varchar(3)
while LEN(@document)>0
 begin
 if (@document <>' ')
 begin
	set @poss= patindex('%:%',@document);
	if (@poss <> 0)
		begin
		 select SUBSTRING(@document,1,@poss-1) as spec
		 set @document= substring(@document,@poss+1,len(@document))
		 if (select patindex('% %',@document))<> 0 
		  begin
			set @num = SUBSTRING(@document,1,patindex('% %',@document));
			if (select @num) ='?' set @num=NULL;
			select @num as num;
			set @document= ltrim(substring(@document,patindex('% %',@document),len(@document)));			
		   end;
		 else
		   if (select patindex('% %',@document)) = 0 
		  begin
			set @num=SUBSTRING(@document,1,len(@document));
			if (select @num) ='?' set @num=NULL;
			select @num as num;
			set @document='';
		  end
	    end;
	else
       begin
		select @document as spec;
		select NULL as num;
		set @document=''; 
	  end;
  end;
 end;
END

/*Function to claculate the date from input  @yy, @mm,@dd*/
create function calculate_mon_day 
(@yy integer,@mm integer,@dd integer)
RETURNS Varchar(10)
AS
BEGIN
 declare @dat varchar(10);
 set @dat=NULL;
 if (@dd >= 1 or @dd<=365 or 
	 @mm >= 1 or @mm<=12 or
	 @yy >= 1900 or @yy <= 2012) 
  begin
	DECLARE @tab varchar(50),@tab_u varchar(50)
	SET @tab_u='31,28,31,30,31,30,31,31,30,30,30,31';
	DECLARE @tab_v varchar(50);
	SET @tab_v='31,29,31,30,31,30,31,31,30,30,30,31';
	DECLARE @i int,@poss int,@day_ofm varchar(50)
	if (select (@yy/4)*4) = @yy /*spec year*/
		set @tab=@tab_v
	else set @tab=@tab_u;		
	SET @i=1;
	while @i < @mm
	 begin
	   set @poss= patindex('%,%',@tab);
	   if (@poss <> 0)
		begin
		 set @day_ofm = SUBSTRING(@tab,1,@poss-1) 
		 set @tab= substring(@tab,@poss+1,len(@tab))
		end; 
	   set @dd=@dd - @day_ofm;
	   set @i=@i+1;
	 end;
	 if @dd >0 
		set @dd=@dd
	 else if @dd=0
	    set @dd=@day_ofm	
	 /*Check for correct result*/
	 if (@mm=1 and (@dd < 1 or @dd > 31)) set @dd=0
	 else if (@mm=2 and (@dd < 1 or @dd > 29)) set @dd=0
	 else if (@mm=3 and (@dd < 1 or @dd > 31)) set @dd=0
	 else if (@mm=4 and (@dd < 1 or @dd > 30)) set @dd=0
	 else if (@mm=5 and (@dd < 1 or @dd > 31)) set @dd=0
	 else if (@mm=6 and (@dd < 1 or @dd > 30)) set @dd=0
	 else if (@mm=7 and (@dd < 1 or @dd > 31)) set @dd=0
	 else if (@mm=8 and (@dd < 1 or @dd > 31)) set @dd=0
	 else if (@mm=9 and (@dd < 1 or @dd > 30)) set @dd=0
	 else if (@mm=10 and (@dd < 1 or @dd > 30)) set @dd=0
	 else if (@mm=11 and (@dd < 1 or @dd > 30)) set @dd=0
	 else if (@mm=12 and (@dd < 1 or @dd > 31)) set @dd=0;
         if (@dd <> 0) 
           set @dat=(select cast(@yy as varchar(4)) +'-'+cast(@mm as varchar(2))+'-'+cast (@dd as varchar(2)))
		else set @dat=NULL
   end
  RETURN(@dat)
END
GO


create function ebird2007.time_calc 
(@time varchar(10))
RETURNS Varchar(10)
AS
BEGIN
	declare @digtime real, @res varchar(10)
	if @time ='?' set @digtime=NULL
	  else
		set @digtime=cast(@time as real);
	if (@digtime <= 24.0 and @digtime>=0.0)
	 begin
		if round(@digtime,0) > @digtime
		   set @res= (select cast((round(@digtime,0) -1) as varchar(2)) +
					':' +
					cast(round(( (@digtime - (round(@digtime,0)-1))*60),0) as varchar(2)));
		else
		  set @res = (select cast(round(@digtime,0) as varchar(2)) +
					':' +
					cast(round(((@digtime-round(@digtime,0))*60),0) as varchar(2))	)
	 end
	 else set @res=NULL	 
	RETURN (@res)
END

/*Stored procedure to insert values from big table checklist into the 3
table: event, location and occurrence*/
create procedure sepTables
	@ccode varchar(3)
		AS
		  begin
			DECLARE @location int;
			DECLARE @event int;	
			DECLARE @occurr int;
			DECLARE @val0 varchar(255),@val1 numeric(12,8),@val2 numeric(12,8),
			@val3 int ,@val4 int,@val5 varchar(3),@val6 varchar(10),
			@val7 varchar(50),@val8 varchar(50),@val9 varchar(10),
			@val10 varchar(10),@val13 varchar(100),
			@val15 varchar(8000);
			declare @spec varchar(30),@num int,@date varchar(10),@time varchar(10)
			declare bigtable cursor for (select SAMPLING_EVENT_ID,
					LATITUDE,LONGITUDE,YEAR,MONTH,DAY,
					TIME,COUNTRY,STATE_PROVINCE,COUNT_TYPE,
					EFFORT_HRS,OBSERVER_ID,SPECIESLIST from ebird2007.checklist);	
			open bigtable;	
			FETCH NEXT FROM bigtable INTO @val0, @val1,@val2,@val3,
					@val4,@val5,@val6,@val7,@val8,@val9,@val10,
					@val13,@val15;
 			WHILE @@FETCH_STATUS = 0
   			 begin
			   SET @location = (SELECT lid FROM location WHERE country=@val7 and stateProvince=@val8 
					and decimalLatitude=@val1 and decimalLongitude=@val2);
			if @location is null 
			   begin
	  	   		INSERT INTO location(decimalLatitude,decimalLongitude,country,countryCode,stateProvince) VALUES(@val1,@val2,@val7,@ccode,@val8);	
				SET @location = (SELECT lid from location WHERE country=@val7 and stateProvince=@val8 
					and decimalLatitude=@val1 and decimalLongitude=@val2); 
			   end;
			   set @date=ebird2007.calculate_mon_day(cast(@val3 as int),cast(@val4 as int),cast(@val5 as int));
			   set @time=ebird2007.time_calc(@val6);
			   SET @event = (SELECT eid FROM event WHERE eventID=@val0 and eventDate=@date and location=@location );
			if @event is NULL
			   begin
	  	   		INSERT INTO event(eventID,eventDate,eventTime,samplingProtocol,samplingEffort,location) 
					VALUES(@val0,cast(@date as date),cast(@time as time),@val9,@val10,@location);		
				SET @event = (SELECT eid FROM event WHERE eventID=@val0 and eventDate=@date and location=@location);
			   end;
			declare specnum cursor for select spec,num from parseDocfun(@val15) ;
			open specnum; 
 			FETCH NEXT FROM specnum INTO @spec, @num;
 			WHILE @@FETCH_STATUS = 0
   			 begin
  			 /* FETCH NEXT from specnum INTO @spec, @num;*/
				SET @occurr=(select oid from occurrence,taxon where event=@event and taxon=tid and scientificName=@spec);
				if @occurr is NULL 
  					INSERT INTO occurrence(recordedBy,event,taxon,individualCount) select @val13,@event,tid,@num from taxon where scientificName=@spec;
  				FETCH NEXT from specnum INTO @spec, @num;
   			 end
 			close specnum; 
 			DEALLOCATE specnum 	
 			FETCH NEXT FROM bigtable INTO @val0, @val1,@val2,@val3,
					@val4,@val5,@val6,@val7,@val8,@val9,@val10,
					@val13,@val15;
			end	
			close bigtable;
			DEALLOCATE bigtable	 
            end;

GO
