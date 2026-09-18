
CREATE Table events (
idevent INT IDENTITY(1,1) unique,
id INT not null, 
PxMiss Real not null,
PyMiss Real not null,
filenames Varchar(50) not null);

Alter table events
ADD Constraint pk_event Primary key(id,filenames);

GO

CREATE Table particle(
idap INT IDENTITY(0,1) primary key,
id INT not null,
eventid INT not null,
Px Real not null,
Py Real not null,
Pz Real not null,
Kf Real not null,
Ee Real not null);

GO

Alter table particle
ADD Constraint particleId FOREIGN KEY (eventid)
REFERENCES events (idevent) ON DELETE CASCADE;

GO

/*Aux tables only contains the id information*/


Create Table Leptonaux(
id INT not null);

GO

ALTER TABLE leptonaux 
ADD CONSTRAINT pk_leptonaux  PRIMARY KEY (id);

GO

Alter table leptonaux
ADD Constraint leptonId FOREIGN KEY (id)
REFERENCES particle (idap) ON DELETE CASCADE;

GO

Create Table Muonaux(id INT not null);

GO

ALTER TABLE Muonaux 
ADD CONSTRAINT pk_Muonaux  PRIMARY KEY (id);

GO

Alter table Muonaux
ADD Constraint muonId FOREIGN KEY (id)
REFERENCES particle (idap) ON DELETE CASCADE;

GO

Create Table electronaux(
id INT not null);

GO

ALTER TABLE electronaux
ADD CONSTRAINT pk_electronaux PRIMARY KEY (id);

GO

Alter table electronaux
ADD Constraint electronId FOREIGN KEY (id)
REFERENCES particle (idap) ON DELETE CASCADE;

GO

Create Table jetaux(
id INT not null);

GO

ALTER TABLE jetaux
ADD CONSTRAINT pk_jetaux PRIMARY KEY (id);

GO

Alter table jetaux
ADD Constraint jetId FOREIGN KEY (id)
REFERENCES particle (idap) ON DELETE CASCADE;

GO

/*views that have all the particles information*/

create view lepton AS
Select particle.*
From leptonaux
Inner JOIN particle
ON leptonaux.id = particle.idap;

GO

create view muon AS
Select particle.*
From muonaux
Inner JOIN particle
ON muonaux.id = particle.idap;

GO

create view electron AS
Select particle.*
From electronaux
Inner JOIN particle
ON electronaux.id = particle.idap;

GO

create view jet AS
Select particle.*
From jetaux
Inner JOIN particle
ON jetaux.id = particle.idap;

GO



