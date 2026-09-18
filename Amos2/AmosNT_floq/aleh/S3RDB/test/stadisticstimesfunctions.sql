
SET STATISTICS TIME ON;

select * from events e where dbo.threeLeptonCut(e.idevent)=1;
select * from events e where dbo.zVetoCut(e.idevent)=1;
select * from events e where dbo.leptoncuts(e.idevent)=1;
select * from events e where dbo.Misseecuts(e.idevent,e.pxmiss,e.pymiss)=1;




select * from Allcuts;

select * from optAllcuts;

select * from events e where dbo.topcut(e.idevent)=1;
select * from events e where dbo.jetVetoCut(e.idevent)=1;
select * from expcuts;

SET STATISTICS TIME OFF;

;

