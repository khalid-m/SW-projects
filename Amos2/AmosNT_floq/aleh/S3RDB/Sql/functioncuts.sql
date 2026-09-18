

/********************************************************************/
/**
 * Event should have exactly three isolated leptons with pt above
 * minPtOfAllThreeLeptons (7 GeV), one of them should have pt above
 * minPtOfTheHardestLepton (20 GeV), at the same time all of them
 * should have eta within etaRangeForAllThreeLeptons (2.4).
 */

/*
 * TTreeCut::ThreeLeptonCut, m_isolatedLeptons, allLeptonsWithinEtaRange
 * m_minPtOfAllThreeLeptons: minPtL
 * m_etaRangeForAllThreeLeptons: etaL
 */

create function isolatedLeptons
	(@idevent INT)
Returns TABLE
AS
Return select l.*
	   from Lepton as l
	   where @idevent = l.eventid and 
             dbo.pt(l.px,l.py) > 7.0  and 
			 abs(dbo.eta(l.px,l.py,l.pz))<2.4;

GO
/**
 * minPtOfAllThreeLeptons: minPtL
 * minPtOfTheHardestLepton: hardPtL
 * etaRangeForAllThreeLeptons: etaL
 */

create function threeLeptonCut
	(@idevent INT)
Returns bit
AS
BEGIN
if	(exists	(	select  a.*
				from isolatedleptons(@idevent) as a
				where dbo.pt(a.px,a.py)>20.0
			)and 
			(	(select count(i.id)
				 from isolatedleptons(@idevent) as i)=3
			)
	)
return 1

return 0		
END


GO

/**********************************************************************/
/**
 * the event which has two opposite charged leptons with invariant
 * mass closed to the Z mass should be cutted away.
 * Differences between invariant mass of any two opposite charged
 * leptons and m_zMass should be bigger or equal to m_minimumZMassDiff.
 * we should look to pairs electron - positron and muon - antimuon.
 */

create function oppositeLeptons
	(@idevent INT)
Returns TABLE
AS
Return select l1.px as l1px, l1.py as l1py, 
			  l1.pz as l1pz, l1.ee as l1ee,
			  l2.px as l2px, l2.py as l2py, 
			  l2.pz as l2pz, l2.ee as l2ee, l1.eventid
	   from Lepton as l1, lepton as l2
	   where l1.kf = -l2.kf and 
			 l1.eventid = @idevent and 
             l1.eventid=l2.eventid;

GO

/*
 * m_zMass: zMass
 * m_minimumZMassDiff: minZMass
 */

create function zVetoCut
	(@idevent INT)
Returns bit
As
Begin
if ( not exists
		(select *
		from oppositeleptons(@idevent) j
		where dbo.invmass(j.l1Ee + j.l2Ee,j.l1px + j.l2px,
						  j.l1py + j.l2py,j.l1pz + j.l2pz,
						  91.1882)<10))
return 1

return 0
ENd
		
GO

/************ HadronicTopCut ********************************************/
/**
 * Events must have at least three jets with pt > 20 GeV and eta within 4.5.
 * Three of them most likely to form the three-jet system and to come 
 * from the top quark, which means that invariant mass of the three-jet
 * system is close to 174.3 within 35. Two jets from the three-jet system
 * most likely to come from the W boson, which means that invariant mass 
 * of the two jets is close to 80.419 within 15. The third jet from the 
 * three-jet system has to be tagged as a b-jet.
 */

/*
 * TTreeCut::SelectOkJets, m_okJets
 * Selects jets (with AtlfastB to) which are ok
 * m_etaRangeForJets: etaJ
 * m_minPtForJets: minPtJ
 */


    create function okJets
        (@idevent INT)
    Returns Table
    AS RETURN
    (
    select *
      from jet
    where (	 select count(id)
             from jet
			 where eventid = @idevent and 
				   abs(dbo.eta(px,py,pz)) < 4.5 and 
				   dbo.pt(px,py) > 20.0
           ) >= 3
      and eventid = @idevent       
      and abs(dbo.eta(px,py,pz))<4.5
      and dbo.pt(px,py) > 20.0
    )

GO

/*
 * TTreeCut::SeperateBJets, m_okBJets
 * Select b jets from jets (with AtlfastB to) of event
 * function getPdg is Kfjetb from TTreeClass here
 * m_theIntegerForBTaggedJet: forBJet
 */



create function bjets
        (@idevent INT)
Returns Table
as
return	select j.*
		from okjets(@idevent) as j
		where j.kf = 5 and 
              j.eventid = @idevent

GO

/*
 * TTreeCut::SeperateBJets, m_okWJets
 * Select wJets from jets (with AtlfastB to) of event. 
 * They are ok and not bJets.
 */


create function wjets
        (@idevent INT)
Returns Table
as
return	select j.*
		from okjets(@idevent) as j
		where j.kf != 5 and 
              j.eventid = @idevent

GO

/*
 * TTreeCut::Select2WCombinations, m_okWComb
 * select 2W combinations
 * returns vectors of two wJets which satisfy invariant mass condition
 * m_wMass: wMass
 * m_allowedWMassDiff: allowedWMass
 */

create function wPairs
        (@idevent INT)
Returns Table
as
Return	
select  j1.eventid as jid, j1.idap as j1idap, j1.id as j1id, 
		j1.Ee as j1Ee, j1.Px as j1Px, j1.Py as j1Py, 
		j1.pz as j1pz, j2.idap as j2idap, j2.id as j2id, 
		j2.Ee as j2Ee, j2.Px as j2Px, j2.Py as j2Py, 
		j2.pz as j2pz
from wJets(@idevent) as j1, wJets(@idevent) as j2
where 	dbo.invmass(j1.Ee + j2.Ee, j1.px + j2.px,
					j1.py + j2.py, j1.pz + j2.pz,
					80.419)<15.0 
		and j1.id > j2.id; 

GO

/*
 * TTreeCut::SelectTopCombination, m_okTopComb
 * m_topMass: tMass
 * m_allowedTopMassDiff: allowedTMass
 */


create function topComb
	(@idevent INT)
returns table
As
Return
select  j.*, b.*
from wPairs(@idevent) as j, bJets(@idevent) as b
where dbo.invmass(j.j1Ee + j.j2Ee + b.Ee,
				  j.j1px + j.j2px + b.px,
				  j.j1py + j.j2py + b.py,
				  j.j1pz + j.j2pz + b.pz,174.3)<35.0




GO

/**
 * Hardronic Top Cut 2 (see management file)
 *** OBS!do not forget that it should be at least 3 ok jets
 */


create function topcut
	(@idevent INT)
Returns bit
AS
BEGIN
if	(exists	(	select *
				from topComb(@idevent)				
			)
	)
return 1

return 0		
END

GO

/**********************************************************************/
/* Jet Veto Cut 2
 * leftJets jetbs should have Pt not bigger then maxAllowedPtForOtherJets
 * see Hadronic Top Cut 2
 * m_maxAllowedPtForOtherJets: ptOJets
 */
/*
 * TTreeCut::SelectTopCombination, m_theTopComb
 * min of m_okTopComb
 */


create function mTopComb
	(@idevent INT)
returns table
As
Return	select j.*
		from topComb(@idevent) as j
		where (abs(sqrt(abs((j.j1Ee+j.j2Ee + j.Ee)*(j.j1Ee+j.j2Ee +j.Ee) - 
				((j.j1px +j.j2px + j.px)*(j.j1px +j.j2px + j.px) +
				(j.j1py +j.j2py + j.py)*(j.j1py +j.j2py + j.py) +
				(j.j1pz +j.j2pz + j.pz)*(j.j1pz +j.j2pz + j.pz))))
				- 174.3))
						=
				(select min(abs(sqrt(abs((t.j1Ee+t.j2Ee + t.Ee)*(t.j1Ee+t.j2Ee +t.Ee) - 
				((t.j1px +t.j2px + t.px)*(t.j1px +t.j2px + t.px) +
				(t.j1py +t.j2py + t.py)*(t.j1py +t.j2py + t.py) +
				(t.j1pz +t.j2pz + t.pz)*(t.j1pz +t.j2pz + t.pz))))
				- 174.3))
				from topComb(@idevent) as t)

GO

/*
 * TTreeCut::SelectTopCombination, m_theLeftOverJets
 * select m_okJets which are not contained in m_theTopComb
 */




create function leftjets
	(@idevent INT)
returns table
As
return
select distinct o.*
from okJets(@idevent) as o
where not exists (	select o.idap 
					from mtopcomb(@idevent) as j 
					where j.idap=o.idap or 
						  j.j1idap=o.idap or
						  j.j2idap=o.idap);



GO
create function jetVetoCut
	(@idevent INT)
Returns bit
AS
BEGIN
if	( not exists	(select * 
					 from leftjets(@idevent) j 
					 where dbo.pt(j.px,j.py)>70			
			)
	)
return 1

return 0		
END

GO

/**********************************************************************/
/*
 * Other cuts
 * 1. All isolated leptons should has Pt not bigger then maxPtAll
 * 2. Isolated lepton which has smallest Pt should have Pt not bigger
 *    then maxPtSoft
 * m_isolatedLeptons: isolatedLeptons(event,parameters)->leptons
 * m_maxPtForAllThreeIsolatedLeptons: maxPtAll
 * m_maxPtForTheSoftestIsolatedLepton: maxPtSoft
 */


create function leptonCuts
	(@idevent INT)
Returns bit
AS
BEGIN
if	(	not exists	(	select j.*
				        from isolatedLeptons(@idevent) as j
						where dbo.pt(j.px,j.py)>150.0			
			)
		and
		exists (	select *
					from isolatedLeptons(@idevent) as i
					where dbo.pt(i.px,i.py)<=40) 
	)
return 1

return 0		
END

GO

/*
 * Other cuts, continue*
 * 1. Missing traverse energy (mod(PtMiss)) should be not smaller
 *    then minTransEe
 * 2. Effective mass should be not bigger then maxEfMass
 * m_minMissingTransverseEnergy: minTransEe
 * m_maxAllowedEffectiveMass: maxEfMass
 * ptMiss={PxMiss,PyMiss}
 * pt31=sum(Px(isolated lepton),Py(isolated lepton))
 */

create function missEeCuts
	(@idevent real,@pxm real,@pym real)
Returns bit
AS
BEGIN
if exists (
	select l.eventid
	from isolatedLeptons(@idevent) l
	group by l.eventid
	having
		dbo.module(@PxM,@PyM)>=40 AND
		dbo.effectiveMass(@PxM,@pyM,sum(l.px),
						  sum(l.py))<= 150.0
	)

return 1

return 0		
END


GO

/*******************************************************************/
/**
 * All cuts together!
 */


create view allcuts
AS
select ev.*
from events ev
where	dbo.threeLeptonCut(ev.idevent)=1 and dbo.zVetoCut(ev.idevent)=1
		and dbo.topCut(ev.idevent)=1 and dbo.jetVetoCut(ev.idevent) = 1
		and dbo.leptonCuts(ev.idevent)=1 and dbo.missEeCuts(ev.idevent,ev.pxmiss,ev.pymiss)=1;

GO


create view optallcuts
AS
select ev.*
from events ev
where	dbo.threeLeptonCut(ev.idevent)=1 and dbo.leptonCuts(ev.idevent)=1 
		and dbo.missEeCuts(ev.idevent,ev.pxmiss,ev.pymiss)=1 and dbo.zVetoCut(ev.idevent)=1
		and dbo.topCut(ev.idevent)=1 and dbo.jetVetoCut(ev.idevent) = 1;

GO

create view expcuts
AS
select ev.*
from events ev
where	dbo.topCut(ev.idevent)=1 and dbo.jetVetoCut(ev.idevent) = 1
		and dbo.missEeCuts(ev.idevent,ev.pxmiss,ev.pymiss)=1 and dbo.zVetoCut(ev.idevent)=1
		and dbo.threeLeptonCut(ev.idevent)=1 and dbo.leptonCuts(ev.idevent)=1;

GO



















