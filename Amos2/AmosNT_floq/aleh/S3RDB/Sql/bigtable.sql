
CREATE Table events (
idevent INT IDENTITY(1,1) primary key,
id INT not null, 
PxMiss Real not null,
PyMiss Real not null,
filenames Varchar(50) not null);

GO

CREATE Table particle(
idap INT IDENTITY(0,1) primary key,
id INT not null,
eventid INT not null,
Px Real not null,
Py Real not null,
Pz Real not null,
Kf Real not null,
Ee Real not null,
typ int not null);

GO
alter table particle 
add constraint chk_typ 
check (typ in (1,2,3))

GO


Alter table particle
ADD Constraint particleId FOREIGN KEY (eventid)
REFERENCES events (idevent) ON DELETE CASCADE;

GO

create view jet
As
select idap,id,eventid,px,py,pz,kf,ee
from particle
where typ=1;

GO

create view lepton
As
select idap,id,eventid,px,py,pz,kf,ee
from particle
where typ=2 or typ=3;

GO

create view muon
As
select idap,id,eventid,px,py,pz,kf,ee
from particle
where typ=2;

GO

create view electron
As
select idap,id,eventid,px,py,pz,kf,ee
from particle
where typ=3;

GO








