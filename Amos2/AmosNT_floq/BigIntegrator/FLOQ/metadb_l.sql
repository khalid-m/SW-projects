


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

/* 500 machineinstallations. 1 machineinstallation has 2 sensorinstallations. 1 location has 100 machines, 200 sensors */
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


insert into MachineInstallation (mi, m, locatedat) values (201,1,1);
insert into MachineInstallation (mi, m, locatedat) values (202,2,2);
insert into MachineInstallation (mi, m, locatedat) values (203,3,3);
insert into MachineInstallation (mi, m, locatedat) values (204,4,4);
insert into MachineInstallation (mi, m, locatedat) values (205,5,5);
insert into MachineInstallation (mi, m, locatedat) values (206,6,1);
insert into MachineInstallation (mi, m, locatedat) values (207,7,2);
insert into MachineInstallation (mi, m, locatedat) values (208,8,3);
insert into MachineInstallation (mi, m, locatedat) values (209,9,4);
insert into MachineInstallation (mi, m, locatedat) values (210,10,5);

insert into MachineInstallation (mi, m, locatedat) values (211,1,1);
insert into MachineInstallation (mi, m, locatedat) values (212,2,2);
insert into MachineInstallation (mi, m, locatedat) values (213,3,3);
insert into MachineInstallation (mi, m, locatedat) values (214,4,4);
insert into MachineInstallation (mi, m, locatedat) values (215,5,5);
insert into MachineInstallation (mi, m, locatedat) values (216,6,1);
insert into MachineInstallation (mi, m, locatedat) values (217,7,2);
insert into MachineInstallation (mi, m, locatedat) values (218,8,3);
insert into MachineInstallation (mi, m, locatedat) values (219,9,4);
insert into MachineInstallation (mi, m, locatedat) values (220,10,5);

insert into MachineInstallation (mi, m, locatedat) values (221,1,1);
insert into MachineInstallation (mi, m, locatedat) values (222,2,2);
insert into MachineInstallation (mi, m, locatedat) values (223,3,3);
insert into MachineInstallation (mi, m, locatedat) values (224,4,4);
insert into MachineInstallation (mi, m, locatedat) values (225,5,5);
insert into MachineInstallation (mi, m, locatedat) values (226,6,1);
insert into MachineInstallation (mi, m, locatedat) values (227,7,2);
insert into MachineInstallation (mi, m, locatedat) values (228,8,3);
insert into MachineInstallation (mi, m, locatedat) values (229,9,4);
insert into MachineInstallation (mi, m, locatedat) values (230,10,5);

insert into MachineInstallation (mi, m, locatedat) values (231,1,1);
insert into MachineInstallation (mi, m, locatedat) values (232,2,2);
insert into MachineInstallation (mi, m, locatedat) values (233,3,3);
insert into MachineInstallation (mi, m, locatedat) values (234,4,4);
insert into MachineInstallation (mi, m, locatedat) values (235,5,5);
insert into MachineInstallation (mi, m, locatedat) values (236,6,1);
insert into MachineInstallation (mi, m, locatedat) values (237,7,2);
insert into MachineInstallation (mi, m, locatedat) values (238,8,3);
insert into MachineInstallation (mi, m, locatedat) values (239,9,4);
insert into MachineInstallation (mi, m, locatedat) values (240,10,5);


insert into MachineInstallation (mi, m, locatedat) values (241,1,1);
insert into MachineInstallation (mi, m, locatedat) values (242,2,2);
insert into MachineInstallation (mi, m, locatedat) values (243,3,3);
insert into MachineInstallation (mi, m, locatedat) values (244,4,4);
insert into MachineInstallation (mi, m, locatedat) values (245,5,5);
insert into MachineInstallation (mi, m, locatedat) values (246,6,1);
insert into MachineInstallation (mi, m, locatedat) values (247,7,2);
insert into MachineInstallation (mi, m, locatedat) values (248,8,3);
insert into MachineInstallation (mi, m, locatedat) values (249,9,4);
insert into MachineInstallation (mi, m, locatedat) values (250,10,5);


insert into MachineInstallation (mi, m, locatedat) values (251,1,1);
insert into MachineInstallation (mi, m, locatedat) values (252,2,2);
insert into MachineInstallation (mi, m, locatedat) values (253,3,3);
insert into MachineInstallation (mi, m, locatedat) values (254,4,4);
insert into MachineInstallation (mi, m, locatedat) values (255,5,5);
insert into MachineInstallation (mi, m, locatedat) values (256,6,1);
insert into MachineInstallation (mi, m, locatedat) values (257,7,2);
insert into MachineInstallation (mi, m, locatedat) values (258,8,3);
insert into MachineInstallation (mi, m, locatedat) values (259,9,4);
insert into MachineInstallation (mi, m, locatedat) values (260,10,5);

insert into MachineInstallation (mi, m, locatedat) values (261,1,1);
insert into MachineInstallation (mi, m, locatedat) values (262,2,2);
insert into MachineInstallation (mi, m, locatedat) values (263,3,3);
insert into MachineInstallation (mi, m, locatedat) values (264,4,4);
insert into MachineInstallation (mi, m, locatedat) values (265,5,5);
insert into MachineInstallation (mi, m, locatedat) values (266,6,1);
insert into MachineInstallation (mi, m, locatedat) values (267,7,2);
insert into MachineInstallation (mi, m, locatedat) values (268,8,3);
insert into MachineInstallation (mi, m, locatedat) values (269,9,4);
insert into MachineInstallation (mi, m, locatedat) values (270,10,5);


insert into MachineInstallation (mi, m, locatedat) values (271,1,1);
insert into MachineInstallation (mi, m, locatedat) values (272,2,2);
insert into MachineInstallation (mi, m, locatedat) values (273,3,3);
insert into MachineInstallation (mi, m, locatedat) values (274,4,4);
insert into MachineInstallation (mi, m, locatedat) values (275,5,5);
insert into MachineInstallation (mi, m, locatedat) values (276,6,1);
insert into MachineInstallation (mi, m, locatedat) values (277,7,2);
insert into MachineInstallation (mi, m, locatedat) values (278,8,3);
insert into MachineInstallation (mi, m, locatedat) values (279,9,4);
insert into MachineInstallation (mi, m, locatedat) values (280,10,5);

insert into MachineInstallation (mi, m, locatedat) values (281,1,1);
insert into MachineInstallation (mi, m, locatedat) values (282,2,2);
insert into MachineInstallation (mi, m, locatedat) values (283,3,3);
insert into MachineInstallation (mi, m, locatedat) values (284,4,4);
insert into MachineInstallation (mi, m, locatedat) values (285,5,5);
insert into MachineInstallation (mi, m, locatedat) values (286,6,1);
insert into MachineInstallation (mi, m, locatedat) values (287,7,2);
insert into MachineInstallation (mi, m, locatedat) values (288,8,3);
insert into MachineInstallation (mi, m, locatedat) values (289,9,4);
insert into MachineInstallation (mi, m, locatedat) values (290,10,5);

insert into MachineInstallation (mi, m, locatedat) values (291,1,1);
insert into MachineInstallation (mi, m, locatedat) values (292,2,2);
insert into MachineInstallation (mi, m, locatedat) values (293,3,3);
insert into MachineInstallation (mi, m, locatedat) values (294,4,4);
insert into MachineInstallation (mi, m, locatedat) values (295,5,5);
insert into MachineInstallation (mi, m, locatedat) values (296,6,1);
insert into MachineInstallation (mi, m, locatedat) values (297,7,2);
insert into MachineInstallation (mi, m, locatedat) values (298,8,3);
insert into MachineInstallation (mi, m, locatedat) values (299,9,4);
insert into MachineInstallation (mi, m, locatedat) values (300,10,5);

insert into MachineInstallation (mi, m, locatedat) values (301,1,1);
insert into MachineInstallation (mi, m, locatedat) values (302,2,2);
insert into MachineInstallation (mi, m, locatedat) values (303,3,3);
insert into MachineInstallation (mi, m, locatedat) values (304,4,4);
insert into MachineInstallation (mi, m, locatedat) values (305,5,5);
insert into MachineInstallation (mi, m, locatedat) values (306,6,1);
insert into MachineInstallation (mi, m, locatedat) values (307,7,2);
insert into MachineInstallation (mi, m, locatedat) values (308,8,3);
insert into MachineInstallation (mi, m, locatedat) values (309,9,4);
insert into MachineInstallation (mi, m, locatedat) values (310,10,5);


insert into MachineInstallation (mi, m, locatedat) values (311,1,1);
insert into MachineInstallation (mi, m, locatedat) values (312,2,2);
insert into MachineInstallation (mi, m, locatedat) values (313,3,3);
insert into MachineInstallation (mi, m, locatedat) values (314,4,4);
insert into MachineInstallation (mi, m, locatedat) values (315,5,5);
insert into MachineInstallation (mi, m, locatedat) values (316,6,1);
insert into MachineInstallation (mi, m, locatedat) values (317,7,2);
insert into MachineInstallation (mi, m, locatedat) values (318,8,3);
insert into MachineInstallation (mi, m, locatedat) values (319,9,4);
insert into MachineInstallation (mi, m, locatedat) values (320,10,5);


insert into MachineInstallation (mi, m, locatedat) values (321,1,1);
insert into MachineInstallation (mi, m, locatedat) values (322,2,2);
insert into MachineInstallation (mi, m, locatedat) values (323,3,3);
insert into MachineInstallation (mi, m, locatedat) values (324,4,4);
insert into MachineInstallation (mi, m, locatedat) values (325,5,5);
insert into MachineInstallation (mi, m, locatedat) values (326,6,1);
insert into MachineInstallation (mi, m, locatedat) values (327,7,2);
insert into MachineInstallation (mi, m, locatedat) values (328,8,3);
insert into MachineInstallation (mi, m, locatedat) values (329,9,4);
insert into MachineInstallation (mi, m, locatedat) values (330,10,5);

insert into MachineInstallation (mi, m, locatedat) values (331,1,1);
insert into MachineInstallation (mi, m, locatedat) values (332,2,2);
insert into MachineInstallation (mi, m, locatedat) values (333,3,3);
insert into MachineInstallation (mi, m, locatedat) values (334,4,4);
insert into MachineInstallation (mi, m, locatedat) values (335,5,5);
insert into MachineInstallation (mi, m, locatedat) values (336,6,1);
insert into MachineInstallation (mi, m, locatedat) values (337,7,2);
insert into MachineInstallation (mi, m, locatedat) values (338,8,3);
insert into MachineInstallation (mi, m, locatedat) values (339,9,4);
insert into MachineInstallation (mi, m, locatedat) values (340,10,5);

insert into MachineInstallation (mi, m, locatedat) values (341,1,1);
insert into MachineInstallation (mi, m, locatedat) values (342,2,2);
insert into MachineInstallation (mi, m, locatedat) values (343,3,3);
insert into MachineInstallation (mi, m, locatedat) values (344,4,4);
insert into MachineInstallation (mi, m, locatedat) values (345,5,5);
insert into MachineInstallation (mi, m, locatedat) values (346,6,1);
insert into MachineInstallation (mi, m, locatedat) values (347,7,2);
insert into MachineInstallation (mi, m, locatedat) values (348,8,3);
insert into MachineInstallation (mi, m, locatedat) values (349,9,4);
insert into MachineInstallation (mi, m, locatedat) values (350,10,5);

insert into MachineInstallation (mi, m, locatedat) values (351,1,1);
insert into MachineInstallation (mi, m, locatedat) values (352,2,2);
insert into MachineInstallation (mi, m, locatedat) values (353,3,3);
insert into MachineInstallation (mi, m, locatedat) values (354,4,4);
insert into MachineInstallation (mi, m, locatedat) values (355,5,5);
insert into MachineInstallation (mi, m, locatedat) values (356,6,1);
insert into MachineInstallation (mi, m, locatedat) values (357,7,2);
insert into MachineInstallation (mi, m, locatedat) values (358,8,3);
insert into MachineInstallation (mi, m, locatedat) values (359,9,4);
insert into MachineInstallation (mi, m, locatedat) values (360,10,5);

insert into MachineInstallation (mi, m, locatedat) values (361,1,1);
insert into MachineInstallation (mi, m, locatedat) values (362,2,2);
insert into MachineInstallation (mi, m, locatedat) values (363,3,3);
insert into MachineInstallation (mi, m, locatedat) values (364,4,4);
insert into MachineInstallation (mi, m, locatedat) values (365,5,5);
insert into MachineInstallation (mi, m, locatedat) values (366,6,1);
insert into MachineInstallation (mi, m, locatedat) values (367,7,2);
insert into MachineInstallation (mi, m, locatedat) values (368,8,3);
insert into MachineInstallation (mi, m, locatedat) values (369,9,4);
insert into MachineInstallation (mi, m, locatedat) values (370,10,5);

insert into MachineInstallation (mi, m, locatedat) values (371,1,1);
insert into MachineInstallation (mi, m, locatedat) values (372,2,2);
insert into MachineInstallation (mi, m, locatedat) values (373,3,3);
insert into MachineInstallation (mi, m, locatedat) values (374,4,4);
insert into MachineInstallation (mi, m, locatedat) values (375,5,5);
insert into MachineInstallation (mi, m, locatedat) values (376,6,1);
insert into MachineInstallation (mi, m, locatedat) values (377,7,2);
insert into MachineInstallation (mi, m, locatedat) values (378,8,3);
insert into MachineInstallation (mi, m, locatedat) values (379,9,4);
insert into MachineInstallation (mi, m, locatedat) values (380,10,5);

insert into MachineInstallation (mi, m, locatedat) values (381,1,1);
insert into MachineInstallation (mi, m, locatedat) values (382,2,2);
insert into MachineInstallation (mi, m, locatedat) values (383,3,3);
insert into MachineInstallation (mi, m, locatedat) values (384,4,4);
insert into MachineInstallation (mi, m, locatedat) values (385,5,5);
insert into MachineInstallation (mi, m, locatedat) values (386,6,1);
insert into MachineInstallation (mi, m, locatedat) values (387,7,2);
insert into MachineInstallation (mi, m, locatedat) values (388,8,3);
insert into MachineInstallation (mi, m, locatedat) values (389,9,4);
insert into MachineInstallation (mi, m, locatedat) values (390,10,5);

insert into MachineInstallation (mi, m, locatedat) values (391,1,1);
insert into MachineInstallation (mi, m, locatedat) values (392,2,2);
insert into MachineInstallation (mi, m, locatedat) values (393,3,3);
insert into MachineInstallation (mi, m, locatedat) values (394,4,4);
insert into MachineInstallation (mi, m, locatedat) values (395,5,5);
insert into MachineInstallation (mi, m, locatedat) values (396,6,1);
insert into MachineInstallation (mi, m, locatedat) values (397,7,2);
insert into MachineInstallation (mi, m, locatedat) values (398,8,3);
insert into MachineInstallation (mi, m, locatedat) values (399,9,4);
insert into MachineInstallation (mi, m, locatedat) values (400,10,5);

insert into MachineInstallation (mi, m, locatedat) values (401,1,1);
insert into MachineInstallation (mi, m, locatedat) values (402,2,2);
insert into MachineInstallation (mi, m, locatedat) values (403,3,3);
insert into MachineInstallation (mi, m, locatedat) values (404,4,4);
insert into MachineInstallation (mi, m, locatedat) values (405,5,5);
insert into MachineInstallation (mi, m, locatedat) values (406,6,1);
insert into MachineInstallation (mi, m, locatedat) values (407,7,2);
insert into MachineInstallation (mi, m, locatedat) values (408,8,3);
insert into MachineInstallation (mi, m, locatedat) values (409,9,4);
insert into MachineInstallation (mi, m, locatedat) values (410,10,5);


insert into MachineInstallation (mi, m, locatedat) values (411,1,1);
insert into MachineInstallation (mi, m, locatedat) values (412,2,2);
insert into MachineInstallation (mi, m, locatedat) values (413,3,3);
insert into MachineInstallation (mi, m, locatedat) values (414,4,4);
insert into MachineInstallation (mi, m, locatedat) values (415,5,5);
insert into MachineInstallation (mi, m, locatedat) values (416,6,1);
insert into MachineInstallation (mi, m, locatedat) values (417,7,2);
insert into MachineInstallation (mi, m, locatedat) values (418,8,3);
insert into MachineInstallation (mi, m, locatedat) values (419,9,4);
insert into MachineInstallation (mi, m, locatedat) values (420,10,5);

insert into MachineInstallation (mi, m, locatedat) values (421,1,1);
insert into MachineInstallation (mi, m, locatedat) values (422,2,2);
insert into MachineInstallation (mi, m, locatedat) values (423,3,3);
insert into MachineInstallation (mi, m, locatedat) values (424,4,4);
insert into MachineInstallation (mi, m, locatedat) values (425,5,5);
insert into MachineInstallation (mi, m, locatedat) values (426,6,1);
insert into MachineInstallation (mi, m, locatedat) values (427,7,2);
insert into MachineInstallation (mi, m, locatedat) values (428,8,3);
insert into MachineInstallation (mi, m, locatedat) values (429,9,4);
insert into MachineInstallation (mi, m, locatedat) values (430,10,5);

insert into MachineInstallation (mi, m, locatedat) values (431,1,1);
insert into MachineInstallation (mi, m, locatedat) values (432,2,2);
insert into MachineInstallation (mi, m, locatedat) values (433,3,3);
insert into MachineInstallation (mi, m, locatedat) values (434,4,4);
insert into MachineInstallation (mi, m, locatedat) values (435,5,5);
insert into MachineInstallation (mi, m, locatedat) values (436,6,1);
insert into MachineInstallation (mi, m, locatedat) values (437,7,2);
insert into MachineInstallation (mi, m, locatedat) values (438,8,3);
insert into MachineInstallation (mi, m, locatedat) values (439,9,4);
insert into MachineInstallation (mi, m, locatedat) values (440,10,5);

insert into MachineInstallation (mi, m, locatedat) values (441,1,1);
insert into MachineInstallation (mi, m, locatedat) values (442,2,2);
insert into MachineInstallation (mi, m, locatedat) values (443,3,3);
insert into MachineInstallation (mi, m, locatedat) values (444,4,4);
insert into MachineInstallation (mi, m, locatedat) values (445,5,5);
insert into MachineInstallation (mi, m, locatedat) values (446,6,1);
insert into MachineInstallation (mi, m, locatedat) values (447,7,2);
insert into MachineInstallation (mi, m, locatedat) values (448,8,3);
insert into MachineInstallation (mi, m, locatedat) values (449,9,4);
insert into MachineInstallation (mi, m, locatedat) values (450,10,5);

insert into MachineInstallation (mi, m, locatedat) values (451,1,1);
insert into MachineInstallation (mi, m, locatedat) values (452,2,2);
insert into MachineInstallation (mi, m, locatedat) values (453,3,3);
insert into MachineInstallation (mi, m, locatedat) values (454,4,4);
insert into MachineInstallation (mi, m, locatedat) values (455,5,5);
insert into MachineInstallation (mi, m, locatedat) values (456,6,1);
insert into MachineInstallation (mi, m, locatedat) values (457,7,2);
insert into MachineInstallation (mi, m, locatedat) values (458,8,3);
insert into MachineInstallation (mi, m, locatedat) values (459,9,4);
insert into MachineInstallation (mi, m, locatedat) values (460,10,5);

insert into MachineInstallation (mi, m, locatedat) values (461,1,1);
insert into MachineInstallation (mi, m, locatedat) values (462,2,2);
insert into MachineInstallation (mi, m, locatedat) values (463,3,3);
insert into MachineInstallation (mi, m, locatedat) values (464,4,4);
insert into MachineInstallation (mi, m, locatedat) values (465,5,5);
insert into MachineInstallation (mi, m, locatedat) values (466,6,1);
insert into MachineInstallation (mi, m, locatedat) values (467,7,2);
insert into MachineInstallation (mi, m, locatedat) values (468,8,3);
insert into MachineInstallation (mi, m, locatedat) values (469,9,4);
insert into MachineInstallation (mi, m, locatedat) values (470,10,5);

insert into MachineInstallation (mi, m, locatedat) values (471,1,1);
insert into MachineInstallation (mi, m, locatedat) values (472,2,2);
insert into MachineInstallation (mi, m, locatedat) values (473,3,3);
insert into MachineInstallation (mi, m, locatedat) values (474,4,4);
insert into MachineInstallation (mi, m, locatedat) values (475,5,5);
insert into MachineInstallation (mi, m, locatedat) values (476,6,1);
insert into MachineInstallation (mi, m, locatedat) values (477,7,2);
insert into MachineInstallation (mi, m, locatedat) values (478,8,3);
insert into MachineInstallation (mi, m, locatedat) values (479,9,4);
insert into MachineInstallation (mi, m, locatedat) values (480,10,5);

insert into MachineInstallation (mi, m, locatedat) values (481,1,1);
insert into MachineInstallation (mi, m, locatedat) values (482,2,2);
insert into MachineInstallation (mi, m, locatedat) values (483,3,3);
insert into MachineInstallation (mi, m, locatedat) values (484,4,4);
insert into MachineInstallation (mi, m, locatedat) values (485,5,5);
insert into MachineInstallation (mi, m, locatedat) values (486,6,1);
insert into MachineInstallation (mi, m, locatedat) values (487,7,2);
insert into MachineInstallation (mi, m, locatedat) values (488,8,3);
insert into MachineInstallation (mi, m, locatedat) values (489,9,4);
insert into MachineInstallation (mi, m, locatedat) values (490,10,5);


insert into MachineInstallation (mi, m, locatedat) values (491,1,1);
insert into MachineInstallation (mi, m, locatedat) values (492,2,2);
insert into MachineInstallation (mi, m, locatedat) values (493,3,3);
insert into MachineInstallation (mi, m, locatedat) values (494,4,4);
insert into MachineInstallation (mi, m, locatedat) values (495,5,5);
insert into MachineInstallation (mi, m, locatedat) values (496,6,1);
insert into MachineInstallation (mi, m, locatedat) values (497,7,2);
insert into MachineInstallation (mi, m, locatedat) values (498,8,3);
insert into MachineInstallation (mi, m, locatedat) values (499,9,4);
insert into MachineInstallation (mi, m, locatedat) values (500,10,5);

/* end of 500 machineinstallations */


/* start of 1000 sensor installations */
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


insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (401, 201, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (402, 202, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (403, 203, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (404, 204, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (405, 205, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (406, 208, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (407, 207, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (408, 206, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (409, 209, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (410, 210, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (411, 201, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (412, 202, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (413, 203, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (414, 204, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (415, 205, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (416, 208, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (417, 207, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (418, 206, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (419, 209, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (420, 210, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (421, 211, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (422, 212, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (423, 213, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (424, 214, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (425, 215, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (426, 218, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (427, 217, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (428, 216, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (429, 219, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (430, 220, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (431, 211, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (432, 212, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (433, 213, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (434, 214, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (435, 215, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (436, 218, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (437, 217, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (438, 216, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (439, 219, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (440, 220, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (441, 221, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (442, 222, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (443, 223, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (444, 224, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (445, 225, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (446, 228, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (447, 227, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (448, 226, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (449, 229, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (450, 230, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (451, 221, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (452, 222, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (453, 223, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (454, 224, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (455, 225, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (456, 228, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (457, 227, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (458, 226, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (459, 229, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (460, 230, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (461, 231, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (462, 232, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (463, 233, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (464, 234, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (465, 235, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (466, 238, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (467, 237, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (468, 236, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (469, 239, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (470, 240, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (471, 231, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (472, 232, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (473, 233, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (474, 234, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (475, 235, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (476, 238, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (477, 237, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (478, 236, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (479, 239, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (480, 240, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (481, 241, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (482, 242, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (483, 243, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (484, 244, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (485, 245, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (486, 248, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (487, 247, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (488, 246, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (489, 249, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (490, 250, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (491, 241, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (492, 242, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (493, 243, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (494, 244, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (495, 245, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (496, 248, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (497, 247, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (498, 246, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (499, 249, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (500, 250, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');


insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (501, 251, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (502, 252, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (503, 253, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (504, 254, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (505, 255, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (506, 258, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (507, 257, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (508, 256, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (509, 259, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (510, 260, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (511, 251, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (512, 252, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (513, 253, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (514, 254, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (515, 255, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (516, 258, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (517, 257, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (518, 256, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (519, 259, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (520, 260, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (521, 261, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (522, 262, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (523, 263, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (524, 264, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (525, 265, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (526, 268, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (527, 267, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (528, 266, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (529, 269, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (530, 270, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (531, 261, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (532, 262, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (533, 263, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (534, 264, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (535, 265, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (536, 268, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (537, 267, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (538, 266, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (539, 269, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (540, 270, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (541, 271, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (542, 272, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (543, 273, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (544, 274, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (545, 275, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (546, 278, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (547, 277, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (548, 276, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (549, 279, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (550, 280, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (551, 271, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (552, 272, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (553, 273, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (554, 274, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (555, 275, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (556, 278, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (557, 277, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (558, 276, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (559, 279, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (560, 280, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (561, 281, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (562, 282, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (563, 283, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (564, 284, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (565, 285, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (566, 288, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (567, 287, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (568, 286, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (569, 289, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (570, 290, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (571, 281, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (572, 282, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (573, 283, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (574, 284, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (575, 285, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (576, 288, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (577, 287, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (578, 286, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (579, 289, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (580, 290, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (581, 291, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (582, 292, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (583, 293, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (584, 294, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (585, 295, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (586, 298, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (587, 297, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (588, 296, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (589, 299, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (590, 300, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (591, 291, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (592, 292, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (593, 293, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (594, 294, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (595, 295, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (596, 298, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (597, 297, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (598, 296, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (599, 299, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (600, 300, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (601, 301, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (602, 302, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (603, 303, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (604, 304, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (605, 305, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (606, 308, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (607, 307, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (608, 306, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (609, 309, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (610, 310, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (611, 301, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (612, 302, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (613, 303, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (614, 304, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (615, 305, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (616, 308, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (617, 307, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (618, 306, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (619, 309, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (620, 310, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (621, 311, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (622, 312, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (623, 313, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (624, 314, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (625, 315, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (626, 318, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (627, 317, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (628, 316, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (629, 319, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (630, 320, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (631, 311, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (632, 312, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (633, 313, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (634, 314, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (635, 315, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (636, 318, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (637, 317, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (638, 316, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (639, 319, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (640, 320, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (641, 321, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (642, 322, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (643, 323, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (644, 324, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (645, 325, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (646, 328, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (647, 327, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (648, 326, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (649, 329, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (650, 330, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (651, 321, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (652, 322, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (653, 323, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (654, 324, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (655, 325, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (656, 328, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (657, 327, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (658, 326, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (659, 329, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (660, 330, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (661, 331, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (662, 332, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (663, 333, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (664, 334, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (665, 335, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (666, 338, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (667, 337, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (668, 336, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (669, 339, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (670, 340, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (671, 331, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (672, 332, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (673, 333, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (674, 334, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (675, 335, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (676, 338, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (677, 337, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (678, 336, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (679, 339, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (680, 340, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (681, 341, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (682, 342, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (683, 343, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (684, 344, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (685, 345, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (686, 348, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (687, 347, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (688, 346, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (689, 349, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (690, 350, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (691, 341, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (692, 342, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (693, 343, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (694, 344, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (695, 345, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (696, 348, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (697, 347, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (698, 346, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (699, 349, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (700, 350, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (701, 351, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (702, 352, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (703, 353, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (704, 354, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (705, 355, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (706, 358, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (707, 357, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (708, 356, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (709, 359, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (710, 360, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (711, 351, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (712, 352, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (713, 353, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (714, 354, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (715, 355, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (716, 358, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (717, 357, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (718, 356, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (719, 359, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (720, 360, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (721, 361, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (722, 362, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (723, 363, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (724, 364, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (725, 365, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (726, 368, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (727, 367, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (728, 366, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (729, 369, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (730, 370, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (731, 361, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (732, 362, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (733, 363, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (734, 364, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (735, 365, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (736, 368, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (737, 367, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (738, 366, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (739, 369, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (740, 370, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (741, 371, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (742, 372, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (743, 373, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (744, 374, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (745, 375, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (746, 378, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (747, 377, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (748, 376, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (749, 379, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (750, 380, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (751, 371, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (752, 372, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (753, 373, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (754, 374, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (755, 375, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (756, 378, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (757, 377, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (758, 376, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (759, 379, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (760, 380, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (761, 381, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (762, 382, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (763, 383, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (764, 384, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (765, 385, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (766, 388, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (767, 387, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (768, 386, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (769, 389, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (770, 390, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (771, 381, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (772, 382, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (773, 383, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (774, 384, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (775, 385, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (776, 388, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (777, 387, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (778, 386, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (779, 389, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (780, 390, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (781, 391, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (782, 392, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (783, 393, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (784, 394, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (785, 395, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (786, 398, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (787, 397, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (788, 396, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (789, 399, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (790, 400, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (791, 391, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (792, 392, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (793, 393, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (794, 394, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (795, 395, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (796, 398, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (797, 397, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (798, 396, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (799, 399, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (800, 400, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (801, 401, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (802, 402, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (803, 403, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (804, 404, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (805, 405, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (806, 408, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (807, 407, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (808, 406, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (809, 409, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (810, 410, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (811, 401, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (812, 402, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (813, 403, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (814, 404, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (815, 405, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (816, 408, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (817, 407, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (818, 406, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (819, 409, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (820, 410, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (821, 411, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (822, 412, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (823, 413, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (824, 414, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (825, 415, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (826, 418, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (827, 417, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (828, 416, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (829, 419, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (830, 420, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (831, 411, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (832, 412, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (833, 413, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (834, 414, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (835, 415, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (836, 418, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (837, 417, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (838, 416, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (839, 419, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (840, 420, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (841, 421, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (842, 422, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (843, 423, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (844, 424, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (845, 425, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (846, 428, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (847, 427, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (848, 426, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (849, 429, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (850, 430, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (851, 421, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (852, 422, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (853, 423, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (854, 424, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (855, 425, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (856, 428, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (857, 427, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (858, 426, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (859, 429, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (860, 430, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (861, 431, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (862, 432, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (863, 433, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (864, 434, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (865, 435, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (866, 438, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (867, 437, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (868, 436, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (869, 439, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (870, 440, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (871, 431, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (872, 432, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (873, 433, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (874, 434, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (875, 435, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (876, 438, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (877, 437, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (878, 436, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (879, 439, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (880, 440, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (881, 441, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (882, 442, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (883, 443, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (884, 444, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (885, 445, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (886, 448, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (887, 447, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (888, 446, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (889, 449, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (890, 450, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (891, 441, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (892, 442, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (893, 443, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (894, 444, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (895, 445, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (896, 448, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (897, 447, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (898, 446, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (899, 449, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (900, 450, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (901, 451, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (902, 452, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (903, 453, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (904, 454, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (905, 455, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (906, 458, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (907, 457, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (908, 456, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (909, 459, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (910, 460, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (911, 451, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (912, 452, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (913, 453, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (914, 454, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (915, 455, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (916, 458, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (917, 457, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (918, 456, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (919, 459, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (920, 460, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (921, 461, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (922, 462, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (923, 463, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (924, 464, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (925, 465, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (926, 468, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (927, 467, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (928, 466, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (929, 469, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (930, 470, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (931, 461, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (932, 462, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (933, 463, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (934, 464, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (935, 465, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (936, 468, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (937, 467, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (938, 466, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (939, 469, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (940, 470, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (941, 471, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (942, 472, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (943, 473, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (944, 474, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (945, 475, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (946, 478, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (947, 477, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (948, 476, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (949, 479, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (950, 480, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (951, 471, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (952, 472, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (953, 473, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (954, 474, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (955, 475, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (956, 478, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (957, 477, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (958, 476, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (959, 479, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (960, 480, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (961, 481, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (962, 482, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (963, 483, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (964, 484, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (965, 485, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (966, 488, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (967, 487, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (968, 486, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (969, 489, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (970, 490, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (971, 481, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (972, 482, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (973, 483, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (974, 484, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (975, 485, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (976, 488, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (977, 487, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (978, 486, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (979, 489, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (980, 490, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (981, 491, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (982, 492, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (983, 493, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (984, 494, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (985, 495, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (986, 498, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (987, 497, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (988, 496, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (989, 499, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (990, 500, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');

insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (991, 491, 1, 50, 10, 'name1', '2012-12-11 11:40:40.000', 1, 25, 'middle', 'ga123'); 
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (992, 492, 2, 20, 10, 'name2', '2012-12-11 11:40:40.000', 2, 25, 'middle', 'vh456');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (993, 493, 3, 10, 10, 'name3', '2012-12-11 11:40:40.000', 3, 25, 'up', 'jkga123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (994, 494, 4, 50, 10, 'name4', '2012-12-11 11:40:40.000', 4, 25, 'down', 'uv45123');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (995, 495, 5, 20, 10, 'name5', '2012-12-11 11:40:40.000', 5, 25, 'down', 'gh33');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (996, 498, 6, 10, 10, 'name6', '2012-12-11 11:40:40.000', 6, 25, 'down', 'cd56');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (997, 497, 1, 20, 10, 'name7', '2012-12-11 11:40:40.000', 7, 25, 'right', 'hj234');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (998, 496, 2, 348, 10, 'name8', '2012-12-11 11:40:40.000', 8, 25, 'left', 'gb567');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (999, 499, 3, 20, 10, 'name9', '2012-12-11 11:40:40.000', 9, 25, 'left', 'gh789');
insert into SensorInstallation (si, mi, sm, ev, th, name, calibrationtime, producerds, samplefrequency, sensorplace, serialnumber) values (1000, 500, 4, 20, 10, 'name10', '2012-12-11 11:40:40.000', 10, 25, 'right', 'kj432');



/* end of 1000 sensor installations */


commit;

