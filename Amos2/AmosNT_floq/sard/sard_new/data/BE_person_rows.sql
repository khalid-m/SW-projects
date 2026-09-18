
SELECT u1.s,u2.v FROM per u1, per u2
WHERE u1.s=u2.s and u1.p='http://user.it.uu.se/~udbl/sard/person#person_name' and u1.v='Ivan' 
and u2.p='http://user.it.uu.se/~udbl/sard/person#person_age';



SELECT u1.s,u2.v FROM person.unpiv_rowview u1, person.unpiv_rowview u2
WHERE u1.s=u2.s and u1.p='http://user.it.uu.se/~udbl/sard/person#person_name' and u1.v='Ivan' 
and u2.p='http://user.it.uu.se/~udbl/sard/person#person_age';


select * from person.rowview;

create view person.person_rowview(s,p,v)
as		(select cm.classid +'/_'+ cast(p.sn as Varchar(25)), pm.propid, cast (p.sn as Varchar(25)) 
		FROM person.person p, person.cmap cm, person.pmap pm WHERE cm.tab='person' AND cm.upv='per' and cm.upv='per' AND pm.tab='person' and pm.col='sn' and pm.upv='per') 
		UNION 
		(select cm.classid +'/_'+ cast(p.sn as Varchar(25)),pm.propid, cast (p.name as Varchar(25)) 
		FROM person.person p, person.cmap cm,person.pmap pm WHERE cm.tab='person' AND cm.upv='per' and cm.upv='per' AND pm.tab='person' and pm.col='name' and pm.upv='per') 
		UNION
		(select cm.classid +'/_'+ cast(p.sn as Varchar(25)), pm.propid, cast (p.age as Varchar(25)) 
		FROM person.person p, person.cmap cm, person.pmap pm WHERE cm.tab='person' AND cm.upv='per' and cm.upv='per' AND pm.tab='person' and pm.col='age' and pm.upv='per');


create view person.tel_rowview(s,p,v)
as		(select cm.classid +'/_'+ cast(t.telsn as Varchar(25)),p.propid, cast (t.telsn as Varchar(25)) 
		FROM person.tel t, person.cmap cm,person.pmap p WHERE cm.tab='tel' AND cm.upv='per' AND p.tab='tel' and p.col='telsn' and p.upv='per') 
		UNION 
		(select cm.classid +'/_'+ cast(t.telsn as Varchar(25)), p.propid, cast (t.tel as Varchar(25)) 
		FROM person.tel t, person.cmap cm, person.pmap p WHERE cm.tab='tel' AND cm.upv='per' AND p.tab='tel' and p.col='telsn' and p.upv='per'); 



create view person.person_unpiv (sn,Property,Value)
as
SELECT   
  sn, tblPivot.Property, tblPivot.Value 
FROM   
  (SELECT sn,
	 CONVERT(sql_variant,name) AS name,
     CONVERT(sql_variant,age) AS age
   FROM person.person) Person
  UNPIVOT (Value For Property In (name, age)) as tblPivot;




create view person.tel_unpiv (sn,Property,Value)
as
SELECT   
  telsn, tblPivot.Property, tblPivot.Value 
FROM   
  (SELECT telsn,
	 CONVERT(sql_variant,tel) AS tel
  FROM person.tel) tel
  UNPIVOT (Value For Property In (tel)) as tblPivot;


create view person.person_row(s,p,v)
as
	(select cm.classid +'/_'+ cast(p.sn as Varchar(25)), +pm.propid, cast (p.Value as Varchar(25)) 
	FROM person.person_unpiv p, person.cmap cm, person.pmap pm WHERE cm.tab='person' 
	AND cm.upv='per' and pm.upv='per' and pm.tab='person' and 
	pm.col=cast(p.Property as Varchar(25)))
	UNION ALL
	(select cm.classid +'/_'+ cast(p.sn as Varchar(25)), pm.propid, cast (p.sn as Varchar(25)) 
	FROM person.person p, person.cmap cm, person.pmap pm WHERE cm.tab='person' AND cm.upv='per' 
	and cm.upv='per' AND pm.tab='person' and pm.col='sn' and pm.upv='per') ;


create view person.tel_row(s,p,v)
as
	(select cm.classid +'/_'+ cast(p.sn as Varchar(25)), +pm.propid, cast (p.Value as Varchar(25)) 
	FROM person.tel_unpiv p, person.cmap cm, person.pmap pm WHERE cm.tab='tel' 
	AND cm.upv='per' and pm.upv='per' and pm.tab='tel' and 
	pm.col=cast(p.Property as Varchar(25)))
	UNION ALL
	(select cm.classid +'/_'+ cast(p.telsn as Varchar(25)), pm.propid, cast (p.telsn as Varchar(25)) 
	FROM person.tel p, person.cmap cm, person.pmap pm WHERE cm.tab='tel' AND cm.upv='per' 
	and cm.upv='per' AND pm.tab='tel' and pm.col='telsn' and pm.upv='per') ;




create view person.unpiv_rowview(s,p,v)
as
(select s,p,v from person.person_row) UNION ALL
(select s,p,v from person.tel_row);


drop view person.person_unpiv2;

select * from person.person_unpiv2;


create view person_tel_tel(s,p,v)
as select cm.classid +'/'+ cast(t.telsn as Varchar(25)),
			pm.propid, cast(t.tel as Varchar(25))
	FROM person.tel t, person.cmap cm, person.pmap pm
	WHERE	pm.tab='tel' AND
			pm.col='tel' AND
			pm.upv='per' AND
			cm.tab='tel' AND
			cm.upv='per';

create view person_tel_telsn(s,p,v)
as select cm.classid +'/'+ cast(t.telsn as Varchar(25)),
			pm.propid, cast(t.telsn as Varchar(25))
	FROM person.tel t, person.cmap cm, person.pmap pm
	WHERE	pm.tab='tel' AND
			pm.col='telsn' AND
			pm.upv='per' AND
			cm.tab='tel' AND
			cm.upv='per';


create view per(s,p,v)
as	
	(select * from person_person_sn) UNION ALL
	(select * from person_person_name) UNION ALL
	(select * from person_person_age) UNION ALL
	(select * from person_tel_telsn) UNION ALL
	(select * from person_tel_tel) ;