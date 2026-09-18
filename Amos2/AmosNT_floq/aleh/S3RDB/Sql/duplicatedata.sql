
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
Ee Real not null);

GO

Alter table particle
ADD Constraint particleId FOREIGN KEY (eventid)
REFERENCES events (idevent) ON DELETE CASCADE;

CREATE Table Lepton (
idap INT  primary key,
id INT not null, 
eventid INT not null,
Px Real not null,
Py Real not null,
Pz Real not null,
Kf Real not null,
Ee Real not null);

GO

Alter table lepton
ADD Constraint leptonId FOREIGN KEY (idap)
REFERENCES particle (idap) ON DELETE CASCADE;


GO

CREATE Table Muon (
idap INT primary key,
id INT not null,
eventid INT not null,
Px Real not null,
Py Real not null,
Pz Real not null,
Kf Real not null,
Ee Real not null);

GO

Alter table muon
ADD Constraint muonId FOREIGN KEY (idap)
REFERENCES lepton (idap) ON DELETE CASCADE;

GO

CREATE Table Electron(
idap INT primary key,
id INT not null,
eventid INT not null,
Px Real not null,
Py Real not null,
Pz Real not null,
Kf Real not null,
Ee Real not null);

GO

Alter table electron
ADD Constraint electronId FOREIGN KEY (idap)
REFERENCES lepton (idap) ON DELETE CASCADE;

GO

CREATE Table Jet (
idap INT primary key,
id INT not null,
eventid INT not null,
Px Real not null,
Py Real not null,
Pz Real not null,
Kf Real not null,
Ee Real not null);

GO

Alter table jet
ADD Constraint jetId FOREIGN KEY (idap)
REFERENCES particle (idap) ON DELETE CASCADE;

GO




