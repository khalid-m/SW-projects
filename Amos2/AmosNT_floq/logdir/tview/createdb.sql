drop table if exists sensorinstallation;
drop table if exists machineinstallation;
drop table if exists sensor;
drop table if exists machine;
drop table if exists location;


create table location (
 id integer primary key,
 country varchar(32),
 continent varchar(32));

create table machine (
 id integer primary key,
 name varchar(32),
 manufacturer varchar(32));

create table machineinstallation (
 id integer primary key,
 locatedAtID integer,
 machineTypeID integer);

create table sensor (
 id integer primary key,
 name varchar(16),
 manufacturer varchar(40),
 version varchar(8),
 hystereses double,
 sensorprecision double);

create table sensorinstallation (
 id integer primary key,
 calibrationTime datetime,
 sampleFrequency double,
 serialNumber varchar(16),
 onMachineID integer,
 sensorTypeID integer);


alter table machineinstallation add constraint fk_location
foreign key (locatedAtID) references location (id);

alter table machineinstallation add constraint fk_machine
foreign key (machineTypeID) references machine (id);

alter table sensorinstallation add constraint fk_onmachine
foreign key (onMachineID) references machineinstallation (id);

alter table sensorinstallation add constraint fk_sensor
foreign key (sensorTypeID) references sensor (id);


insert into machine (id,name,manufacturer) values
(1,'Water Boiler','Boils R Us');
insert into machine (id,name,manufacturer) values
(2,'Air Freshener','EasyBreathe Inc');

insert into sensor (id,name,manufacturer,version,hystereses,sensorprecision)
values (1,'Water Sensor','AquaSens Technologies','1.1e',1,0.1);
insert into sensor (id,name,manufacturer,version,hystereses,sensorprecision)
values (2,'Water Sensor','AquaSens Technologies, Korea Division','0.2b',1,0.5);
insert into sensor (id,name,manufacturer,version,hystereses,sensorprecision)
values (3,'Air Sensor','Zephyr Ltd','1.0a',2,1);

insert into location (id,country,continent) 
values (1,'Sweden','Europe');
insert into location (id,country,continent) 
values (2,'France','Europe');
insert into location (id,country,continent) 
values (3,'Atlantis','Pangea');

insert into machineinstallation (id,locatedatid,machinetypeid)
values (1,1,1);
insert into machineinstallation (id,locatedatid,machinetypeid)
values (2,1,1);
insert into machineinstallation (id,locatedatid,machinetypeid)
values (3,2,1);
insert into machineinstallation (id,locatedatid,machinetypeid)
values (4,3,2);

insert into sensorinstallation (id,sampleFrequency,serialNumber,onMachineID,sensorTypeID)
values (1,0.2,'WS1ABC',1,1);
insert into sensorinstallation (id,sampleFrequency,serialNumber,onMachineID,sensorTypeID)
values (2,0.4,'WS2ABC',2,2);
insert into sensorinstallation (id,sampleFrequency,serialNumber,onMachineID,sensorTypeID)
values (3,0.6,'WS3ABC',3,1);
insert into sensorinstallation (id,sampleFrequency,serialNumber,onMachineID,sensorTypeID)
values (4,0.8,'AS1ABC',4,3);
