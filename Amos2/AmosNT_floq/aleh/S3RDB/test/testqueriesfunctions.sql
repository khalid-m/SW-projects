

SET SHOWPLAN_XML ON;
GO
select * from events e where dbo.threeLeptonCut(e.idevent)=1;

GO
SET SHOWPLAN_XML OFF;

GO
SET SHOWPLAN_XML ON;
GO
select * from events e where dbo.zVetoCut(e.idevent)=1;

GO
SET SHOWPLAN_XML OFF;

GO
SET SHOWPLAN_XML ON;
GO
select * from events e where dbo.topcut(e.idevent)=1;

GO
SET SHOWPLAN_XML OFF;
GO
SET SHOWPLAN_XML ON;
GO
select * from events e where dbo.jetVetoCut(e.idevent)=1;

GO
SET SHOWPLAN_XML OFF;

GO
SET SHOWPLAN_XML ON;
GO
select * from events e where dbo.leptoncuts(e.idevent)=1;

GO
SET SHOWPLAN_XML OFF;
GO
SET SHOWPLAN_XML ON;
GO
select * from events e where dbo.misseecuts(e.idevent,e.pxmiss,e.pymiss)=1;

GO
SET SHOWPLAN_XML OFF;
GO
SET SHOWPLAN_XML ON;
GO
select * from Allcuts;

GO
SET SHOWPLAN_XML OFF;
GO
SET SHOWPLAN_XML ON;
GO
select * from optAllcuts;

GO
SET SHOWPLAN_XML OFF;
GO
SET SHOWPLAN_XML ON;
GO
select * from expcuts;

GO
SET SHOWPLAN_XML OFF;










