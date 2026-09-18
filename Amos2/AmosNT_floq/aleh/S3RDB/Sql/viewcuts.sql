

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


create view isolatedLeptons
AS
	select l.*
	from Lepton as l
	where dbo.pt(l.px,l.py) > 7.0  and 
	abs(dbo.eta(l.px,l.py,l.pz))<2.4;

GO
/**
 * minPtOfAllThreeLeptons: minPtL
 * minPtOfTheHardestLepton: hardPtL
 * etaRangeForAllThreeLeptons: etaL
 */


create view threeLeptonCut
AS
select  e.*
from events e
where exists (
	select i.*
	from isolatedleptons i
	where	i.eventid = e.idevent  and 
			dbo.pt(i.px,i.py)>20.0 and
			e.idevent in
				(select l.eventid
				 from isolatedleptons l
				 group by l.eventid
				 having count(l.id)=3));



GO

/**********************************************************************/
/**
 * the event which has two opposite charged leptons with invariant
 * mass closed to the Z mass should be cutted away.
 * Differences between invariant mass of any two opposite charged
 * leptons and m_zMass should be bigger or equal to m_minimumZMassDiff.
 * we should look to pairs electron - positron and muon - antimuon.
 */


create view oppositeLeptons
AS
select distinct l1.px as l1px, l1.py as l1py, 
	   l1.pz as l1pz, l1.ee as l1ee,
       l2.px as l2px, l2.py as l2py, 
       l2.pz as l2pz, l2.ee as l2ee, 
       l1.eventid
	   from Lepton as l1, lepton as l2
	   where l1.kf = -l2.kf and l1.eventid = l2.eventid;

GO

/*
 * m_zMass: zMass
 * m_minimumZMassDiff: minZMass
 */

create view EvInvMass
As
select j.eventid
from oppositeleptons j
where dbo.invmass(j.l1Ee + j.l2Ee,j.l1px + j.l2px,
				  j.l1py + j.l2py,j.l1pz + j.l2pz,
				  91.1882)<10;

GO



create view zvetocut
AS
select *
from events
where idevent not in (select eventid from evInvMass); 





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

create view okJets
AS 
select *
from jet as j1
where ( select count(j2.id)
        from jet as j2
        where abs(dbo.eta(j2.px,j2.py,j2.px)) < 4.5
              and dbo.pt(j2.px,j2.py) > 20.0
			  and j1.eventid=j2.eventid
           ) >= 3      
      and abs(dbo.eta(j1.px,j1.py,j1.px))<4.5
      and dbo.pt(j1.px,j1.py) > 20.0;

GO

/*
 * TTreeCut::SeperateBJets, m_okBJets
 * Select b jets from jets (with AtlfastB to) of event
 * function getPdg is Kfjetb from TTreeClass here
 * m_theIntegerForBTaggedJet: forBJet
 */

create view bjets
as
	select j.*
		from okjets as j
		where j.kf = 5

GO

/*
 * TTreeCut::SeperateBJets, m_okWJets
 * Select wJets from jets (with AtlfastB to) of event. 
 * They are ok and not bJets.
 */


create view wjets
AS
select j.*
		from okjets as j
		where j.kf != 5

GO

/*
 * TTreeCut::Select2WCombinations, m_okWComb
 * select 2W combinations
 * returns vectors of two wJets which satisfy invariant mass condition
 * m_wMass: wMass
 * m_allowedWMassDiff: allowedWMass
 */

create view wPairs
as
select  j1.eventid as jid, j1.idap as j1idap, j1.id as j1id, 
		j1.Ee as j1Ee, j1.Px as j1Px, j1.Py as j1Py, 
		j1.pz as j1pz, j2.idap as j2idap, j2.id as j2id, 
		j2.Ee as j2Ee, j2.Px as j2Px, j2.Py as j2Py, 
		j2.pz as j2pz
from wJets as j1, wJets as j2
where 	dbo.invmass(j1.Ee + j2.Ee, j1.px + j2.px,
					j1.py + j2.py, j1.pz + j2.pz,
					80.419)<15.0 
		and j1.eventid = j2.eventid
		and j1.id > j2.id; 

GO

/*
 * TTreeCut::SelectTopCombination, m_okTopComb
 * m_topMass: tMass
 * m_allowedTopMassDiff: allowedTMass
 */


create view topComb
As
select  j.*, b.*
		from wPairs as j, bJets as b
		where dbo.invmass(j.j1Ee + j.j2Ee + b.Ee,
						   j.j1px + j.j2px + b.px,
				           j.j1py + j.j2py + b.py,
						   j.j1pz + j.j2pz + b.pz,174.3)<35.0
			  and j.jid=b.eventid;




GO

/**
 * Hardronic Top Cut 2 (see management file)
 *** OBS!do not forget that it should be at least 3 ok jets
 */


create view topcut
AS
select distinct e.*
from topComb t, events e
where e.idevent=t.eventid;	

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


create view mTopComb
As
	select j.*
		from topComb as j
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
						from topComb as t
						where t.eventid=j.eventid)

GO

/*
 * TTreeCut::SelectTopCombination, m_theLeftOverJets
 * select m_okJets which are not contained in m_theTopComb
 */

create view leftjets
As
select distinct o.*
from okJets as o
where not exists (select o.idap 
				  from mtopcomb as j 
                  where j.idap=o.idap or 
						j.j1idap=o.idap or
						j.j2idap=o.idap);

GO

create view jetVetoCut
AS
select distinct e.*
from events e
where not exists (select * 
				  from leftjets j 
				  where e.idevent=j.eventid and 
				  dbo.pt(j.px,j.py)>70);


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


create view leptonCuts
AS
select q.*
from events q
where (	not exists	(	select j.eventid
				        from isolatedLeptons as j
						where dbo.pt(j.px,j.py)>150.0 and 
					          q.idevent=j.eventid		
			)
		and
		exists (	select i.eventid
					from isolatedLeptons as i
					where dbo.pt(i.px,i.py)<=40 and 
						 q.idevent=i.eventid) 
	);

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

create view missEeCuts
  as
       select distinct e.*
       from events e
       where exists (
             select l.eventid
             from isolatedLeptons l
			 where e.idevent=l.eventid
             group by l.eventid
			 having
                  dbo.module(e.PxMiss,e.PyMiss)>=40 AND
                  dbo.effectiveMass(e.PxMiss,e.PyMiss,sum(l.px),sum(l.py))<= 150.0);

GO

/*******************************************************************/
/**
 * All cuts together!
 */


create view allcuts
AS
select	th.idevent, th.filenames, th.id
from	threeLeptonCut th, zVetoCut z, topcut tp,
		jetVetoCut j, leptoncuts l, Misseecuts m
where	th.idevent=z.idevent and 
		z.idevent=tp.idevent and
		tp.idevent=j.idevent and
		j.idevent=l.idevent and
		l.idevent=m.idevent;
GO

create view optallcuts
AS
select	th.idevent,th.filenames,th.id
from	threeLeptonCut th,leptoncuts l,Misseecuts m,
		zVetoCut z, topcut tp,jetVetoCut j
where	th.idevent=l.idevent and
		l.idevent=m.idevent and
		m.idevent=z.idevent and
		z.idevent=tp.idevent and
		tp.idevent=j.idevent;
GO


create  view expcuts
AS
select	tp.idevent,tp.filenames,tp.id
from	topcut tp, jetVetoCut j, Misseecuts m,
		zVetoCut z, threeLeptonCut th,leptoncuts l
where	tp.idevent=j.idevent and
		j.idevent=m.idevent and
		m.idevent=z.idevent and
		z.idevent=th.idevent and
		th.idevent=l.idevent;
GO





















