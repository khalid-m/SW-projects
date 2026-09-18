create database lr;
grant select on lr.* to lr@'%.uppmax.uu.se' identified by 'lr';
grant select on lr.* to lr@localhost identified by 'lr';
grant select on lr.* to lr@'%.it.uu.se' identified by 'lr';
use lr;
create table hist (vid integer, day integer, xway integer, toll integer);
load data infile "/home/erikz/ezgen/h0" into table hist fields terminated by ',';
create index vidi using hash on hist (vid);
