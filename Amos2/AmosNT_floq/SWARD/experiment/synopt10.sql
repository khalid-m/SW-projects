create table T1(K varchar(20) not null,
		C2 varchar(20),
		C3 varchar(20),
		C4 varchar(20),
		C5 varchar(20),
		C6 varchar(20),
		C7 varchar(20),
		C8 varchar(20),
		C9 varchar(20),
		C10 varchar(20),
		primary key (K));

create table T2(K varchar(20) not null,
		C2 varchar(20),
		C3 varchar(20),
		C4 varchar(20),
		C5 varchar(20),
		C6 varchar(20),
		C7 varchar(20),
		C8 varchar(20),
		C9 varchar(20),
		C10 varchar(20),
        foreign key (C2) references T1(K),		
		primary key (K));

create table T3(K varchar(20) not null,
		C2 varchar(20),
		C3 varchar(20),
		C4 varchar(20),
		C5 varchar(20),
		C6 varchar(20),
		C7 varchar(20),
		C8 varchar(20),
		C9 varchar(20),
		C10 varchar(20),
        foreign key (C2) references T2(K),		
		primary key (K));

create table T4(K varchar(20) not null,
		C2 varchar(20),
		C3 varchar(20),
		C4 varchar(20),
		C5 varchar(20),
		C6 varchar(20),
		C7 varchar(20),
		C8 varchar(20),
		C9 varchar(20),
		C10 varchar(20),
        foreign key (C2) references T3(K),		
		primary key (K));

create table T5(K varchar(20) not null,
		C2 varchar(20),
		C3 varchar(20),
		C4 varchar(20),
		C5 varchar(20),
		C6 varchar(20),
		C7 varchar(20),
		C8 varchar(20),
		C9 varchar(20),
		C10 varchar(20),
        foreign key (C2) references T4(K),		
		primary key (K));

create table T6(K varchar(20) not null,
		C2 varchar(20),
		C3 varchar(20),
		C4 varchar(20),
		C5 varchar(20),
		C6 varchar(20),
		C7 varchar(20),
		C8 varchar(20),
		C9 varchar(20),
		C10 varchar(20),
        foreign key (C2) references T5(K),		
		primary key (K));

create table T7(K varchar(20) not null,
		C2 varchar(20),
		C3 varchar(20),
		C4 varchar(20),
		C5 varchar(20),
		C6 varchar(20),
		C7 varchar(20),
		C8 varchar(20),
		C9 varchar(20),
		C10 varchar(20),
        foreign key (C2) references T6(K),		
		primary key (K));

create table T8(K varchar(20) not null,
		C2 varchar(20),
		C3 varchar(20),
		C4 varchar(20),
		C5 varchar(20),
		C6 varchar(20),
		C7 varchar(20),
		C8 varchar(20),
		C9 varchar(20),
		C10 varchar(20),
        foreign key (C2) references T7(K),		
		primary key (K));

insert into T1 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('0','0','0','0','0','0','0','0','0','0'); 


insert into T2 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('0','0','0','0','0','0','0','0','0','0'); 

insert into T2 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('1','0','0','0','0','0','0','0','0','0'); 

insert into T3 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('0','0','0','0','0','0','0','0','0','0'); 

insert into T3 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('1','0','0','0','0','0','0','0','0','0'); 

insert into T3 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('2','0','0','0','0','0','0','0','0','0'); 

insert into T4 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('0','0','0','0','0','0','0','0','0','0'); 

insert into T4 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('1','0','0','0','0','0','0','0','0','0'); 

insert into T4 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('2','0','0','0','0','0','0','0','0','0'); 

insert into T4 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('3','0','0','0','0','0','0','0','0','0'); 

insert into T5 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('0','0','0','0','0','0','0','0','0','0'); 

insert into T5 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('1','0','0','0','0','0','0','0','0','0'); 

insert into T5 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('2','0','0','0','0','0','0','0','0','0'); 

insert into T5 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('3','0','0','0','0','0','0','0','0','0'); 

insert into T5 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('4','0','0','0','0','0','0','0','0','0'); 

insert into T6 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('0','0','0','0','0','0','0','0','0','0'); 

insert into T6 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('1','0','0','0','0','0','0','0','0','0'); 

insert into T6 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('2','0','0','0','0','0','0','0','0','0'); 

insert into T6 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('3','0','0','0','0','0','0','0','0','0'); 

insert into T6 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('4','0','0','0','0','0','0','0','0','0'); 

insert into T6 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('5','0','0','0','0','0','0','0','0','0'); 

insert into T7 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('0','0','0','0','0','0','0','0','0','0'); 

insert into T7 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('1','0','0','0','0','0','0','0','0','0'); 

insert into T7 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('2','0','0','0','0','0','0','0','0','0'); 

insert into T7 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('3','0','0','0','0','0','0','0','0','0'); 

insert into T7 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('4','0','0','0','0','0','0','0','0','0'); 

insert into T7 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('5','0','0','0','0','0','0','0','0','0'); 

insert into T7 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('6','0','0','0','0','0','0','0','0','0'); 

insert into T8 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('0','0','0','0','0','0','0','0','0','0'); 

insert into T8 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('1','0','0','0','0','0','0','0','0','0'); 

insert into T8 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('2','0','0','0','0','0','0','0','0','0'); 

insert into T8 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('3','0','0','0','0','0','0','0','0','0'); 

insert into T8 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('4','0','0','0','0','0','0','0','0','0'); 

insert into T8 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('5','0','0','0','0','0','0','0','0','0'); 

insert into T8 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('6','0','0','0','0','0','0','0','0','0'); 

insert into T8 
	(K,C2,C3,C4,C5,C6,C7,C8,C9,C10) 
	values 
	('7','0','0','0','0','0','0','0','0','0'); 


