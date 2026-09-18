


create table Machine (
  m INT primary key, /* machine model id */
  mmname varchar(100),      /* machine model name */
  description varchar(200),
  manufacturer varchar(100));
  
  
create table Sensor (
  sm INT primary key,  /* sensor model id*/
  sname varchar(100),  /* sensor model name */
  maxv float,
  minv float,
  manufacturer varchar(100),
  version varchar(100),
  hysteresis float,
  sensorprecision float);
  
create table Location (
  lid INT primary key,  /* location id */
  name varchar(100),
  country varchar(100),
  region varchar(100),
  latitude float,
  longitude float,
  climatezone varchar(100),
  continent varchar(100),
  uri varchar(2000)      /* log database uri */
  );  
  
create table MachineInstallation (
  mi INT primary key,    /* machine installation id */
  m INT,                 /* machine model id, foreign key to Machine table */
  locatedat INT               /* location id, foreign key to Location table */
  );
  
  alter table MachineInstallation
  add foreign key (m) references Machine(m);
  
  alter table MachineInstallation
  add foreign key (locatedat) references Location(lid);
  
create table SensorInstallation (
  si INT primary key,
  mi INT,              /* machine installation id, foreign key to machineinstallation table */
  sm INT,              /* sensor model id, foreign key to sensor table */
  ev float,
  th float,
  name varchar(100),   
  calibrationtime Datetime,
  producerds INT,      /* produce raw data stream */
  samplefrequency INT,
  sensorplace varchar(100),
  serialnumber varchar(100)
  );

alter table SensorInstallation
add foreign key (mi) references MachineInstallation(mi);

alter table SensorInstallation
add foreign key (sm) references Sensor(sm);
  

insert into Machine (m, mmname, description, manufacturer) values (1, 'MoriSeiki 5000', 'milling machine', 'ABB');
insert into Machine (m, mmname, description, manufacturer) values (2, 'MoriSeiki 5005', 'milling machine', 'ABB');
insert into Machine (m, mmname, description, manufacturer) values (3, 'MoriSeiki 5105', 'milling machine', 'ABB');
insert into Machine (m, mmname, description, manufacturer) values (4, 'MoriSeiki 5205', 'milling machine', 'Zephyr Ltd');
insert into Machine (m, mmname, description, manufacturer) values (5, 'MoriSeiki 5305', 'milling machine', 'Zephyr Ltd');
insert into Machine (m, mmname, description, manufacturer) values (6, 'MoriSeiki 5405', 'other machine', 'Zephyr Ltd');
insert into Machine (m, mmname, description, manufacturer) values (7, 'MoriSeiki 5505', 'other machine', 'Zephyr Ltd');
insert into Machine (m, mmname, description, manufacturer) values (8, 'MoriSeiki 5605', 'other machine', 'ABB');
insert into Machine (m, mmname, description, manufacturer) values (9, 'MoriSeiki 5705', 'other machine', 'ABB');
insert into Machine (m, mmname, description, manufacturer) values (10, 'MoriSeiki 5805', 'other machine', 'ABB');

insert into Sensor (sm, sname, maxv, minv, manufacturer, version, hysteresis, sensorprecision) values (1, 'Power usage', 80.0, 0, 'ABB', '1.0a', 4.5, 1.2);
insert into Sensor (sm, sname, maxv, minv, manufacturer, version, hysteresis, sensorprecision) values (2, 'Cutting depth', 35.0, 0, 'Zephyr Ltd', '2.0a', 5.5, 1.1);
insert into Sensor (sm, sname, maxv, minv, manufacturer, version, hysteresis, sensorprecision) values (3, 'Cutting diameter', 20.0, 0, 'Zephyr Ltd', '3.0a', 6.1, 0.9);
insert into Sensor (sm, sname, maxv, minv, manufacturer, version, hysteresis, sensorprecision) values (4, 'ae sensor', 100.0, 0, 'ABB', '3.4', 3.4, 1.3);
insert into Sensor (sm, sname, maxv, minv, manufacturer, version, hysteresis, sensorprecision) values (5, 'POWER', 100.0, 0, 'ABB', '3.4', 3.4, 1.3);
insert into Sensor (sm, sname, maxv, minv, manufacturer, version, hysteresis, sensorprecision) values (6, 'TEMP', 100.0, 0, 'ABB', '3.4', 3.4, 1.3);

insert into Location (lid, name, country, region, latitude, longitude, climatezone, continent, uri) values (1, 'Uppsala', 'Sweden', 'Uppland', 112, 134, 'Cold', 'European', "jdbc:microsoft:sqlserver://udblserver1.it.uu.se;DatabaseName=bm1GB");
insert into Location (lid, name, country, region, latitude, longitude, climatezone, continent, uri) values (2, 'Campinas', 'Brazil', 'Sao Paulo', 45, 67, 'Tropical', 'America', "jdbc:microsoft:sqlserver://udblserver3;DatabaseName=bm1GB");
insert into Location (lid, name, country, region, latitude, longitude, climatezone, continent, uri) values (3, 'Chapaevsk', 'Russia', 'Samara', 113, 56, 'Cold', 'European', "unknown yet");
insert into Location (lid, name, country, region, latitude, longitude, climatezone, continent, uri) values (4, 'Monki', 'Poland', 'Bialystok', 90, 78, 'Tropical', 'European', "unknown yet");
insert into Location (lid, name, country, region, latitude, longitude, climatezone, continent, uri) values (5, 'Chengdu', 'China', 'Si Chuan', 67, 89, 'Tropical', 'Asia', "unknown yet");

insert into MachineInstallation (mi, m, locatedat) values (1,1,1);
insert into MachineInstallation (mi, m, locatedat) values (2,2,2);
insert into MachineInstallation (mi, m, locatedat) values (3,3,3);
insert into MachineInstallation (mi, m, locatedat) values (4,4,4);
insert into MachineInstallation (mi, m, locatedat) values (5,5,5);
insert into MachineInstallation (mi, m, locatedat) values (6,6,1);
insert into MachineInstallation (mi, m, locatedat) values (7,7,2);
insert into MachineInstallation (mi, m, locatedat) values (8,8,3);
insert into MachineInstallation (mi, m, locatedat) values (9,9,4);
insert into MachineInstallation (mi, m, locatedat) values (10,10,5);

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (1, 1, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (2, 2, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (3, 3, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (4, 4, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (5, 5, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (6, 8, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (7, 7, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (8, 6, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (9, 9, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (10, 10, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');





commit;

