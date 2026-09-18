

create table EMPLOYEE2 (
  EID INT PRIMARY KEY,
  Name VARCHAR(100),
  Skill VARCHAR(100),
  Salary INT,
  MID INT);

create table EquipmentModel (
  e INT primary key,
  ename varchar(100),
  description varchar(200),
  manufacturer varchar(100));
  
  
create table SensorModel (
  sm INT primary key,
  sname varchar(100),
  maxv float,
  minv float,
  manufacturer varchar(100),
  version varchar(100),
  hysteresis float,
  sensorprecision float);
  
create table Site (
  site INT primary key,
  location varchar(100),
  country varchar(100),
  region varchar(100),
  latitude float,
  longitude float,
  climatezone varchar(100),
  continent varchar(100),
  logdbid INT);  
  
create table InstalledEquipment (
  ie INT primary key,
  e INT,
  site INT);
  
create table SensorInstallation (
  si INT primary key,
  ie INT,
  sm INT,
  ev float,
  th float,
  calibrationtime Datetime,
  producerds INT,
  samplefrequency INT,
  sensorplace varchar(100),
  serialnumber varchar(100));
  
create table Measured (
  si INT,
  ts float,
  mv float,
  Logdbid INT);  
  

/* this is mysql syntax for auto increment key defined, and 
   it is different in SQL server */  
create table Measurement (
  id INT NOT NULL AUTO_INCREMENT,
  si INT,
  ts float,
  mv float,
  Logdbid INT,
  primary key (id)
  ); 

insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (1, 'John', 'Operation', 58000, 1);
insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (2, 'Oliver', 'Operation', 30000, 2);
insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (3, 'Bruce', 'Operation', 40000, 3);
insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (4, 'Carl', 'Operation', 56000, 4);
insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (5, 'Thomas', 'Operation', 70000, 5);
insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (6, 'Jens', 'Operation', 45000, 6);
insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (7, 'Lucas', 'Operation', 62000, 7);
insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (8, 'Alex', 'Operation', 85000, 8);
insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (9, 'Ryan', 'Operation', 33000, 9);
insert into EMPLOYEE2 (EID, Name, Skill, Salary, MID) values (10, 'Wes', 'Operation', 50000, 10);

insert into EquipmentModel (e, ename, description, manufacturer) values (1, 'MoriSeiki 5000', 'milling machine', 'ABB');
insert into EquipmentModel (e, ename, description, manufacturer) values (2, 'MoriSeiki 5005', 'milling machine', 'ABB');
insert into EquipmentModel (e, ename, description, manufacturer) values (3, 'MoriSeiki 5105', 'milling machine', 'ABB');
insert into EquipmentModel (e, ename, description, manufacturer) values (4, 'MoriSeiki 5205', 'milling machine', 'Zephyr Ltd');
insert into EquipmentModel (e, ename, description, manufacturer) values (5, 'MoriSeiki 5305', 'milling machine', 'Zephyr Ltd');
insert into EquipmentModel (e, ename, description, manufacturer) values (6, 'MoriSeiki 5405', 'other machine', 'Zephyr Ltd');
insert into EquipmentModel (e, ename, description, manufacturer) values (7, 'MoriSeiki 5505', 'other machine', 'Zephyr Ltd');
insert into EquipmentModel (e, ename, description, manufacturer) values (8, 'MoriSeiki 5605', 'other machine', 'ABB');
insert into EquipmentModel (e, ename, description, manufacturer) values (9, 'MoriSeiki 5705', 'other machine', 'ABB');
insert into EquipmentModel (e, ename, description, manufacturer) values (10, 'MoriSeiki 5805', 'other machine', 'ABB');

insert into SensorModel (sm, sname, maxv, minv, manufacturer, version, hysteresis, sensorprecision) values (1, 'Power usage', 80.0, 0, 'ABB', '1.0a', 4.5, 1.2);
insert into SensorModel (sm, sname, maxv, minv, manufacturer, version, hysteresis, sensorprecision) values (2, 'Cutting depth', 35.0, 0, 'Zephyr Ltd', '2.0a', 5.5, 1.1);
insert into SensorModel (sm, sname, maxv, minv, manufacturer, version, hysteresis, sensorprecision) values (3, 'Cutting diameter', 20.0, 0, 'Zephyr Ltd', '3.0a', 6.1, 0.9);
insert into SensorModel (sm, sname, maxv, minv, manufacturer, version, hysteresis, sensorprecision) values (4, 'ae sensor', 100.0, 0, 'ABB', '3.4', 3.4, 1.3);
insert into SensorModel (sm, sname, maxv, minv, manufacturer, version, hysteresis, sensorprecision) values (5, 'POWER', 100.0, 0, 'ABB', '3.4', 3.4, 1.3);
insert into SensorModel (sm, sname, maxv, minv, manufacturer, version, hysteresis, sensorprecision) values (6, 'TEMP', 100.0, 0, 'ABB', '3.4', 3.4, 1.3);


insert into Site (site, location, country, region, latitude, longitude, climatezone, continent, logdbid) values (1, 'Uppsala', 'Sweden', 'Uppland', 112, 134, 'Cold', 'European', 1);
insert into Site (site, location, country, region, latitude, longitude, climatezone, continent, logdbid) values (2, 'Campinas', 'Brazil', 'Sao Paulo', 45, 67, 'Tropical', 'America', 2);
insert into Site (site, location, country, region, latitude, longitude, climatezone, continent, logdbid) values (3, 'Chapaevsk', 'Russia', 'Samara', 113, 56, 'Cold', 'European', 3);
insert into Site (site, location, country, region, latitude, longitude, climatezone, continent, logdbid) values (4, 'Monki', 'Poland', 'Bialystok', 90, 78, 'Tropical', 'European', 4);
insert into Site (site, location, country, region, latitude, longitude, climatezone, continent, logdbid) values (5, 'Chengdu', 'China', 'Si Chuan', 67, 89, 'Tropical', 'Asia', 5);

insert into InstalledEquipment (ie, e, site) values (1,1,1);
insert into InstalledEquipment (ie, e, site) values (2,2,2);
insert into InstalledEquipment (ie, e, site) values (3,3,3);
insert into InstalledEquipment (ie, e, site) values (4,4,4);
insert into InstalledEquipment (ie, e, site) values (5,5,5);
insert into InstalledEquipment (ie, e, site) values (6,6,1);
insert into InstalledEquipment (ie, e, site) values (7,7,2);
insert into InstalledEquipment (ie, e, site) values (8,8,3);
insert into InstalledEquipment (ie, e, site) values (9,9,4);
insert into InstalledEquipment (ie, e, site) values (10,10,5);

insert into SensorInstallation (si, ie, sm, ev, th, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (1, 1, 1, 50, 10, '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, ie, sm, ev, th, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (2, 2, 2, 20, 10, '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, ie, sm, ev, th, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (3, 3, 3, 10, 10, '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, ie, sm, ev, th, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (4, 4, 4, 50, 10, '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, ie, sm, ev, th, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (5, 5, 5, 20, 10, '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, ie, sm, ev, th, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (6, 8, 6, 10, 10, '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, ie, sm, ev, th, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (7, 7, 1, 20, 10, '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, ie, sm, ev, th, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (8, 6, 2, 348, 10, '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, ie, sm, ev, th, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (9, 9, 3, 20, 10, '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, ie, sm, ev, th, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (10, 10, 4, 20, 10, '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');


/*logdb1 data*/
insert into Measurement (si, ts, mv, Logdbid) values (1, 20000000001.1, 71, 1);
insert into Measurement (si, ts, mv, Logdbid) values (1, 20000000002.2, 91, 1);
insert into Measurement (si, ts, mv, Logdbid) values (6, 20000000003.3, 81, 1);
insert into Measurement (si, ts, mv, Logdbid) values (1, 20000000004.4, 91, 1);
insert into Measurement (si, ts, mv, Logdbid) values (6, 30000000005.5, 101, 1);
insert into Measurement (si, ts, mv, Logdbid) values (6, 40000000006.6, 121, 1); 

/*logdb2 data*/
insert into Measurement (si, ts, mv, Logdbid) values (2, 20000000001.1, 72, 2);
insert into Measurement (si, ts, mv, Logdbid) values (2, 20000000002.2, 92, 2);
insert into Measurement (si, ts, mv, Logdbid) values (7, 20000000003.3, 82, 2);
insert into Measurement (si, ts, mv, Logdbid) values (2, 20000000004.4, 92, 2);
insert into Measurement (si, ts, mv, Logdbid) values (7, 30000000005.5, 102, 2);
insert into Measurement (si, ts, mv, Logdbid) values (7, 40000000006.6, 122, 2); 

insert into Measured (si, ts, mv, Logdbid) values (1, 20000000001.1, 70, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000002.2, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 20000000003.3, 80, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000004.4, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 30000000005.5, 100, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 40000000006.6, 120, 1); 


insert into Measured (si, ts, mv, Logdbid) values (1, 20000000001.1, 70, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000002.2, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 20000000003.3, 80, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000004.4, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 30000000005.5, 100, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 40000000006.6, 120, 1); 
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000001.1, 70, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000002.2, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 20000000003.3, 80, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000004.4, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 30000000005.5, 100, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 40000000006.6, 120, 1); 
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000001.1, 70, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000002.2, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 20000000003.3, 80, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000004.4, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 30000000005.5, 100, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 40000000006.6, 120, 1); 
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000001.1, 70, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000002.2, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 20000000003.3, 80, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000004.4, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 30000000005.5, 100, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 40000000006.6, 120, 1); 
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000001.1, 70, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000002.2, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 20000000003.3, 80, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000004.4, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 30000000005.5, 100, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 40000000006.6, 120, 1); 
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000001.1, 70, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000002.2, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 20000000003.3, 80, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000004.4, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 30000000005.5, 100, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 40000000006.6, 120, 1); 
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000001.1, 70, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000002.2, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 20000000003.3, 80, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000004.4, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 30000000005.5, 100, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 40000000006.6, 120, 1); 
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000001.1, 70, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000002.2, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 20000000003.3, 80, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000004.4, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 30000000005.5, 100, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 40000000006.6, 120, 1); 
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000001.1, 70, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000002.2, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 20000000003.3, 80, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000004.4, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 30000000005.5, 100, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 40000000006.6, 120, 1); 
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000001.1, 70, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000002.2, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 20000000003.3, 80, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000004.4, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 30000000005.5, 100, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 40000000006.6, 120, 1); 
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000001.1, 70, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000002.2, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 20000000003.3, 80, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000004.4, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 30000000005.5, 100, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 40000000006.6, 120, 1); 
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000001.1, 70, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000002.2, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 20000000003.3, 80, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000004.4, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 30000000005.5, 100, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 40000000006.6, 120, 1); 
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000001.1, 70, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000002.2, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 20000000003.3, 80, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000004.4, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 30000000005.5, 100, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 40000000006.6, 120, 1); 
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000001.1, 70, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000002.2, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 20000000003.3, 80, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000004.4, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 30000000005.5, 100, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 40000000006.6, 120, 1); 
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000001.1, 70, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000002.2, 90, 1);
insert into Measured (si, ts, mv, Logdbid) values (6, 20000000003.3, 80, 1);
insert into Measured (si, ts, mv, Logdbid) values (1, 20000000004.4, 90, 1);




commit;

