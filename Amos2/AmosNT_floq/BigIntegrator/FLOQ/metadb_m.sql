


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

/* 200 machineinstallations */
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

insert into MachineInstallation (mi, m, locatedat) values (101,1,1);
insert into MachineInstallation (mi, m, locatedat) values (102,2,2);
insert into MachineInstallation (mi, m, locatedat) values (103,3,3);
insert into MachineInstallation (mi, m, locatedat) values (104,4,4);
insert into MachineInstallation (mi, m, locatedat) values (105,5,5);
insert into MachineInstallation (mi, m, locatedat) values (106,6,1);
insert into MachineInstallation (mi, m, locatedat) values (107,7,2);
insert into MachineInstallation (mi, m, locatedat) values (108,8,3);
insert into MachineInstallation (mi, m, locatedat) values (109,9,4);
insert into MachineInstallation (mi, m, locatedat) values (110,10,5);

insert into MachineInstallation (mi, m, locatedat) values (111,1,1);
insert into MachineInstallation (mi, m, locatedat) values (112,2,2);
insert into MachineInstallation (mi, m, locatedat) values (113,3,3);
insert into MachineInstallation (mi, m, locatedat) values (114,4,4);
insert into MachineInstallation (mi, m, locatedat) values (115,5,5);
insert into MachineInstallation (mi, m, locatedat) values (116,6,1);
insert into MachineInstallation (mi, m, locatedat) values (117,7,2);
insert into MachineInstallation (mi, m, locatedat) values (118,8,3);
insert into MachineInstallation (mi, m, locatedat) values (119,9,4);
insert into MachineInstallation (mi, m, locatedat) values (120,10,5);

insert into MachineInstallation (mi, m, locatedat) values (121,1,1);
insert into MachineInstallation (mi, m, locatedat) values (122,2,2);
insert into MachineInstallation (mi, m, locatedat) values (123,3,3);
insert into MachineInstallation (mi, m, locatedat) values (124,4,4);
insert into MachineInstallation (mi, m, locatedat) values (125,5,5);
insert into MachineInstallation (mi, m, locatedat) values (126,6,1);
insert into MachineInstallation (mi, m, locatedat) values (127,7,2);
insert into MachineInstallation (mi, m, locatedat) values (128,8,3);
insert into MachineInstallation (mi, m, locatedat) values (129,9,4);
insert into MachineInstallation (mi, m, locatedat) values (130,10,5);

insert into MachineInstallation (mi, m, locatedat) values (131,1,1);
insert into MachineInstallation (mi, m, locatedat) values (132,2,2);
insert into MachineInstallation (mi, m, locatedat) values (133,3,3);
insert into MachineInstallation (mi, m, locatedat) values (134,4,4);
insert into MachineInstallation (mi, m, locatedat) values (135,5,5);
insert into MachineInstallation (mi, m, locatedat) values (136,6,1);
insert into MachineInstallation (mi, m, locatedat) values (137,7,2);
insert into MachineInstallation (mi, m, locatedat) values (138,8,3);
insert into MachineInstallation (mi, m, locatedat) values (139,9,4);
insert into MachineInstallation (mi, m, locatedat) values (140,10,5);

insert into MachineInstallation (mi, m, locatedat) values (141,1,1);
insert into MachineInstallation (mi, m, locatedat) values (142,2,2);
insert into MachineInstallation (mi, m, locatedat) values (143,3,3);
insert into MachineInstallation (mi, m, locatedat) values (144,4,4);
insert into MachineInstallation (mi, m, locatedat) values (145,5,5);
insert into MachineInstallation (mi, m, locatedat) values (146,6,1);
insert into MachineInstallation (mi, m, locatedat) values (147,7,2);
insert into MachineInstallation (mi, m, locatedat) values (148,8,3);
insert into MachineInstallation (mi, m, locatedat) values (149,9,4);
insert into MachineInstallation (mi, m, locatedat) values (150,10,5);


insert into MachineInstallation (mi, m, locatedat) values (151,1,1);
insert into MachineInstallation (mi, m, locatedat) values (152,2,2);
insert into MachineInstallation (mi, m, locatedat) values (153,3,3);
insert into MachineInstallation (mi, m, locatedat) values (154,4,4);
insert into MachineInstallation (mi, m, locatedat) values (155,5,5);
insert into MachineInstallation (mi, m, locatedat) values (156,6,1);
insert into MachineInstallation (mi, m, locatedat) values (157,7,2);
insert into MachineInstallation (mi, m, locatedat) values (158,8,3);
insert into MachineInstallation (mi, m, locatedat) values (159,9,4);
insert into MachineInstallation (mi, m, locatedat) values (160,10,5);

insert into MachineInstallation (mi, m, locatedat) values (161,1,1);
insert into MachineInstallation (mi, m, locatedat) values (162,2,2);
insert into MachineInstallation (mi, m, locatedat) values (163,3,3);
insert into MachineInstallation (mi, m, locatedat) values (164,4,4);
insert into MachineInstallation (mi, m, locatedat) values (165,5,5);
insert into MachineInstallation (mi, m, locatedat) values (166,6,1);
insert into MachineInstallation (mi, m, locatedat) values (167,7,2);
insert into MachineInstallation (mi, m, locatedat) values (168,8,3);
insert into MachineInstallation (mi, m, locatedat) values (169,9,4);
insert into MachineInstallation (mi, m, locatedat) values (170,10,5);


insert into MachineInstallation (mi, m, locatedat) values (171,1,1);
insert into MachineInstallation (mi, m, locatedat) values (172,2,2);
insert into MachineInstallation (mi, m, locatedat) values (173,3,3);
insert into MachineInstallation (mi, m, locatedat) values (174,4,4);
insert into MachineInstallation (mi, m, locatedat) values (175,5,5);
insert into MachineInstallation (mi, m, locatedat) values (176,6,1);
insert into MachineInstallation (mi, m, locatedat) values (177,7,2);
insert into MachineInstallation (mi, m, locatedat) values (178,8,3);
insert into MachineInstallation (mi, m, locatedat) values (179,9,4);
insert into MachineInstallation (mi, m, locatedat) values (180,10,5);

insert into MachineInstallation (mi, m, locatedat) values (181,1,1);
insert into MachineInstallation (mi, m, locatedat) values (182,2,2);
insert into MachineInstallation (mi, m, locatedat) values (183,3,3);
insert into MachineInstallation (mi, m, locatedat) values (184,4,4);
insert into MachineInstallation (mi, m, locatedat) values (185,5,5);
insert into MachineInstallation (mi, m, locatedat) values (186,6,1);
insert into MachineInstallation (mi, m, locatedat) values (187,7,2);
insert into MachineInstallation (mi, m, locatedat) values (188,8,3);
insert into MachineInstallation (mi, m, locatedat) values (189,9,4);
insert into MachineInstallation (mi, m, locatedat) values (190,10,5);

insert into MachineInstallation (mi, m, locatedat) values (191,1,1);
insert into MachineInstallation (mi, m, locatedat) values (192,2,2);
insert into MachineInstallation (mi, m, locatedat) values (193,3,3);
insert into MachineInstallation (mi, m, locatedat) values (194,4,4);
insert into MachineInstallation (mi, m, locatedat) values (195,5,5);
insert into MachineInstallation (mi, m, locatedat) values (196,6,1);
insert into MachineInstallation (mi, m, locatedat) values (197,7,2);
insert into MachineInstallation (mi, m, locatedat) values (198,8,3);
insert into MachineInstallation (mi, m, locatedat) values (199,9,4);
insert into MachineInstallation (mi, m, locatedat) values (200,10,5);


/* end of 200 machineinstallations */


/* start of 400 sensor installations */
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


insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (201, 101, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (202, 102, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (203, 103, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (204, 104, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (205, 105, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (206, 108, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (207, 107, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (208, 106, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (209, 109, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (210, 110, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (211, 101, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (212, 102, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (213, 103, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (214, 104, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (215, 105, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (216, 108, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (217, 107, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (218, 106, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (219, 109, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (220, 110, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');


insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (221, 111, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (222, 112, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (223, 113, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (224, 114, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (225, 115, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (226, 118, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (227, 117, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (228, 116, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (229, 119, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (230, 120, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (231, 111, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (232, 112, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (233, 113, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (234, 114, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (235, 115, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (236, 118, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (237, 117, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (238, 116, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (239, 119, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (240, 120, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (241, 121, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (242, 122, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (243, 123, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (244, 124, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (245, 125, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (246, 128, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (247, 127, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (248, 126, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (249, 129, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (250, 130, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (251, 121, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (252, 122, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (253, 123, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (254, 124, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (255, 125, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (256, 128, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (257, 127, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (258, 126, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (259, 129, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (260, 130, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (261, 131, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (262, 132, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (263, 133, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (264, 134, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (265, 135, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (266, 138, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (267, 137, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (268, 136, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (269, 139, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (270, 140, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (271, 131, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (272, 132, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (273, 133, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (274, 134, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (275, 135, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (276, 138, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (277, 137, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (278, 136, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (279, 139, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (280, 140, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (281, 141, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (282, 142, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (283, 143, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (284, 144, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (285, 145, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (286, 148, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (287, 147, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (288, 146, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (289, 149, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (290, 150, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (291, 141, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (292, 142, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (293, 143, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (294, 144, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (295, 145, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (296, 148, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (297, 147, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (298, 146, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (299, 149, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (300, 150, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (301, 151, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (302, 152, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (303, 153, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (304, 154, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (305, 155, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (306, 158, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (307, 157, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (308, 156, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (309, 159, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (310, 160, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (311, 151, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (312, 152, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (313, 153, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (314, 154, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (315, 155, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (316, 158, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (317, 157, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (318, 156, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (319, 159, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (320, 160, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (321, 161, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (322, 162, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (323, 163, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (324, 164, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (325, 165, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (326, 168, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (327, 167, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (328, 166, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (329, 169, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (330, 170, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (331, 161, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (332, 162, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (333, 163, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (334, 164, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (335, 165, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (336, 168, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (337, 167, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (338, 166, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (339, 169, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (340, 170, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (341, 171, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (342, 172, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (343, 173, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (344, 174, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (345, 175, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (346, 178, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (347, 177, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (348, 176, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (349, 179, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (350, 180, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (351, 171, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (352, 172, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (353, 173, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (354, 174, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (355, 175, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (356, 178, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (357, 177, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (358, 176, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (359, 179, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (360, 180, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (361, 181, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (362, 182, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (363, 183, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (364, 184, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (365, 185, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (366, 188, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (367, 187, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (368, 186, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (369, 189, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (370, 190, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (371, 181, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (372, 182, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (373, 183, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (374, 184, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (375, 185, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (376, 188, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (377, 187, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (378, 186, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (379, 189, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (380, 190, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (381, 191, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (382, 192, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (383, 193, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (384, 194, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (385, 195, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (386, 198, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (387, 197, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (388, 196, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (389, 199, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (390, 200, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (391, 191, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (392, 192, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (393, 193, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (394, 194, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (395, 195, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (396, 198, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (397, 197, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (398, 196, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (399, 199, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (400, 200, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');


/* end of 400 sensor installations */


commit;

