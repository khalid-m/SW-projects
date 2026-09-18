

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

/* 100 machineinstallations */
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

insert into MachineInstallation (mi, m, locatedat) values (11,1,1);
insert into MachineInstallation (mi, m, locatedat) values (12,2,2);
insert into MachineInstallation (mi, m, locatedat) values (13,3,3);
insert into MachineInstallation (mi, m, locatedat) values (14,4,4);
insert into MachineInstallation (mi, m, locatedat) values (15,5,5);
insert into MachineInstallation (mi, m, locatedat) values (16,6,1);
insert into MachineInstallation (mi, m, locatedat) values (17,7,2);
insert into MachineInstallation (mi, m, locatedat) values (18,8,3);
insert into MachineInstallation (mi, m, locatedat) values (19,9,4);
insert into MachineInstallation (mi, m, locatedat) values (20,10,5);

insert into MachineInstallation (mi, m, locatedat) values (21,1,1);
insert into MachineInstallation (mi, m, locatedat) values (22,2,2);
insert into MachineInstallation (mi, m, locatedat) values (23,3,3);
insert into MachineInstallation (mi, m, locatedat) values (24,4,4);
insert into MachineInstallation (mi, m, locatedat) values (25,5,5);
insert into MachineInstallation (mi, m, locatedat) values (26,6,1);
insert into MachineInstallation (mi, m, locatedat) values (27,7,2);
insert into MachineInstallation (mi, m, locatedat) values (28,8,3);
insert into MachineInstallation (mi, m, locatedat) values (29,9,4);
insert into MachineInstallation (mi, m, locatedat) values (30,10,5);

insert into MachineInstallation (mi, m, locatedat) values (31,1,1);
insert into MachineInstallation (mi, m, locatedat) values (32,2,2);
insert into MachineInstallation (mi, m, locatedat) values (33,3,3);
insert into MachineInstallation (mi, m, locatedat) values (34,4,4);
insert into MachineInstallation (mi, m, locatedat) values (35,5,5);
insert into MachineInstallation (mi, m, locatedat) values (36,6,1);
insert into MachineInstallation (mi, m, locatedat) values (37,7,2);
insert into MachineInstallation (mi, m, locatedat) values (38,8,3);
insert into MachineInstallation (mi, m, locatedat) values (39,9,4);
insert into MachineInstallation (mi, m, locatedat) values (40,10,5);

insert into MachineInstallation (mi, m, locatedat) values (41,1,1);
insert into MachineInstallation (mi, m, locatedat) values (42,2,2);
insert into MachineInstallation (mi, m, locatedat) values (43,3,3);
insert into MachineInstallation (mi, m, locatedat) values (44,4,4);
insert into MachineInstallation (mi, m, locatedat) values (45,5,5);
insert into MachineInstallation (mi, m, locatedat) values (46,6,1);
insert into MachineInstallation (mi, m, locatedat) values (47,7,2);
insert into MachineInstallation (mi, m, locatedat) values (48,8,3);
insert into MachineInstallation (mi, m, locatedat) values (49,9,4);
insert into MachineInstallation (mi, m, locatedat) values (50,10,5);

insert into MachineInstallation (mi, m, locatedat) values (51,1,1);
insert into MachineInstallation (mi, m, locatedat) values (52,2,2);
insert into MachineInstallation (mi, m, locatedat) values (53,3,3);
insert into MachineInstallation (mi, m, locatedat) values (54,4,4);
insert into MachineInstallation (mi, m, locatedat) values (55,5,5);
insert into MachineInstallation (mi, m, locatedat) values (56,6,1);
insert into MachineInstallation (mi, m, locatedat) values (57,7,2);
insert into MachineInstallation (mi, m, locatedat) values (58,8,3);
insert into MachineInstallation (mi, m, locatedat) values (59,9,4);
insert into MachineInstallation (mi, m, locatedat) values (60,10,5);

insert into MachineInstallation (mi, m, locatedat) values (61,1,1);
insert into MachineInstallation (mi, m, locatedat) values (62,2,2);
insert into MachineInstallation (mi, m, locatedat) values (63,3,3);
insert into MachineInstallation (mi, m, locatedat) values (64,4,4);
insert into MachineInstallation (mi, m, locatedat) values (65,5,5);
insert into MachineInstallation (mi, m, locatedat) values (66,6,1);
insert into MachineInstallation (mi, m, locatedat) values (67,7,2);
insert into MachineInstallation (mi, m, locatedat) values (68,8,3);
insert into MachineInstallation (mi, m, locatedat) values (69,9,4);
insert into MachineInstallation (mi, m, locatedat) values (70,10,5);

insert into MachineInstallation (mi, m, locatedat) values (71,1,1);
insert into MachineInstallation (mi, m, locatedat) values (72,2,2);
insert into MachineInstallation (mi, m, locatedat) values (73,3,3);
insert into MachineInstallation (mi, m, locatedat) values (74,4,4);
insert into MachineInstallation (mi, m, locatedat) values (75,5,5);
insert into MachineInstallation (mi, m, locatedat) values (76,6,1);
insert into MachineInstallation (mi, m, locatedat) values (77,7,2);
insert into MachineInstallation (mi, m, locatedat) values (78,8,3);
insert into MachineInstallation (mi, m, locatedat) values (79,9,4);
insert into MachineInstallation (mi, m, locatedat) values (80,10,5);


insert into MachineInstallation (mi, m, locatedat) values (81,1,1);
insert into MachineInstallation (mi, m, locatedat) values (82,2,2);
insert into MachineInstallation (mi, m, locatedat) values (83,3,3);
insert into MachineInstallation (mi, m, locatedat) values (84,4,4);
insert into MachineInstallation (mi, m, locatedat) values (85,5,5);
insert into MachineInstallation (mi, m, locatedat) values (86,6,1);
insert into MachineInstallation (mi, m, locatedat) values (87,7,2);
insert into MachineInstallation (mi, m, locatedat) values (88,8,3);
insert into MachineInstallation (mi, m, locatedat) values (89,9,4);
insert into MachineInstallation (mi, m, locatedat) values (90,10,5);

insert into MachineInstallation (mi, m, locatedat) values (91,1,1);
insert into MachineInstallation (mi, m, locatedat) values (92,2,2);
insert into MachineInstallation (mi, m, locatedat) values (93,3,3);
insert into MachineInstallation (mi, m, locatedat) values (94,4,4);
insert into MachineInstallation (mi, m, locatedat) values (95,5,5);
insert into MachineInstallation (mi, m, locatedat) values (96,6,1);
insert into MachineInstallation (mi, m, locatedat) values (97,7,2);
insert into MachineInstallation (mi, m, locatedat) values (98,8,3);
insert into MachineInstallation (mi, m, locatedat) values (99,9,4);
insert into MachineInstallation (mi, m, locatedat) values (100,10,5);


/* end of 100 machineinstallations */


/* start of 200 sensor installations */
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

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (11, 1, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (12, 2, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (13, 3, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (14, 4, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (15, 5, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (16, 8, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (17, 7, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (18, 6, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (19, 9, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (20, 10, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (21, 11, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (22, 12, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (23, 13, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (24, 14, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (25, 15, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (26, 18, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (27, 17, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (28, 16, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (29, 19, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (30, 20, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (31, 11, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (32, 12, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (33, 13, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (34, 14, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (35, 15, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (36, 18, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (37, 17, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (38, 16, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (39, 19, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (40, 20, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (41, 21, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (42, 22, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (43, 23, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (44, 24, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (45, 25, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (46, 28, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (47, 27, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (48, 26, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (49, 29, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (50, 30, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');


insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (51, 21, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (52, 22, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (53, 23, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (54, 24, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (55, 25, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (56, 28, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (57, 27, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (58, 26, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (59, 29, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (60, 30, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');


insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (61, 31, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (62, 32, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (63, 33, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (64, 34, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (65, 35, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (66, 38, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (67, 37, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (68, 36, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (69, 39, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (70, 40, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (71, 31, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (72, 32, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (73, 33, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (74, 34, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (75, 35, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (76, 38, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (77, 37, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (78, 36, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (79, 39, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (80, 40, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');


insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (81, 41, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (82, 42, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (83, 43, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (84, 44, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (85, 45, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (86, 48, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (87, 47, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (88, 46, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (89, 49, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (90, 50, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (91, 41, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (92, 42, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (93, 43, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (94, 44, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (95, 45, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (96, 48, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (97, 47, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (98, 46, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (99, 49, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (100, 50, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');


insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (101, 51, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (102, 52, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (103, 53, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (104, 54, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (105, 55, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (106, 58, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (107, 57, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (108, 56, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (109, 59, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (110, 60, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (111, 51, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (112, 52, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (113, 53, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (114, 54, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (115, 55, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (116, 58, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (117, 57, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (118, 56, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (119, 59, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (120, 60, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (121, 61, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (122, 62, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (123, 63, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (124, 64, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (125, 65, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (126, 68, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (127, 67, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (128, 66, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (129, 69, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (130, 70, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (131, 61, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (132, 62, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (133, 63, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (134, 64, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (135, 65, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (136, 68, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (137, 67, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (138, 66, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (139, 69, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (140, 70, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');


insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (141, 71, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (142, 72, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (143, 73, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (144, 74, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (145, 75, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (146, 78, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (147, 77, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (148, 76, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (149, 79, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (150, 80, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');


insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (151, 71, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (152, 72, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (153, 73, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (154, 74, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (155, 75, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (156, 78, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (157, 77, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (158, 76, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (159, 79, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (160, 80, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (161, 81, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (162, 82, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (163, 83, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (164, 84, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (165, 85, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (166, 88, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (167, 87, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (168, 86, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (169, 89, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (170, 90, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');


insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (171, 81, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (172, 82, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (173, 83, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (174, 84, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (175, 85, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (176, 88, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (177, 87, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (178, 86, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (179, 89, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (180, 90, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (181, 91, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (182, 92, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (183, 93, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (184, 94, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (185, 95, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (186, 98, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (187, 97, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (188, 96, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (189, 99, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (190, 100, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (191, 91, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (192, 92, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (193, 93, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (194, 94, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (195, 95, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (196, 98, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (197, 97, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (198, 96, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (199, 99, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (200, 100, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');


/* end of 200 sensor installations */


commit;

