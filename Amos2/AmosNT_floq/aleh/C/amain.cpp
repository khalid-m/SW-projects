/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2004 Rouslan Fomkin, UDBL
 * $RCSfile: amain.cpp,v $
 * $Revision: 1.12 $ $Date: 2006/03/22 09:09:38 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Driver program for C functions for ALEH project. Loading data
 * from ROOT file to ALEH.
 *
 *****************************************************************************
 * $Log: amain.cpp,v $
 * Revision 1.12  2006/03/22 09:09:38  ruslan
 * schema is improved: events are defined over basic type. It gives good improvement in performance for materialized ontology loading entire file
 *
 * Revision 1.11  2006/03/21 11:02:30  ruslan
 * Updated instruction for compiling and running ALEH. Added scripts for compiling ALEH and for testing projects depending on ROOT library
 *
 * Revision 1.10  2006/03/20 07:50:24  ruslan
 * loading data are improved by using a_addfunction instead of a_setfunction
 *
 ****************************************************************************/

#include <iostream>
#include "../../C/callout.h"
#include <TChain.h>
#include "TTreeClass.h"

using namespace std;

int readAndFill(TTreeClass* ttree, int startElem, int lastElem, char location[70])
{
//	int treeSize=int(ttree->fChain->GetEntries());
	int eventcounter=0;
	dcl_connection(c);
	dcl_scan(s);
	a_connect(c,"",FALSE);
	a_execute(c,s,"logging off;",FALSE);

	/* AMOS function to update */
	dcl_oid(PxMiss);
	a_setf(PxMiss,a_getfunction(c,"EVENT.PXMISS->REAL",FALSE));
	dcl_oid(PyMiss);
	a_setf(PyMiss,a_getfunction(c,"EVENT.PYMISS->REAL",FALSE));
	dcl_oid(id);
	a_setf(id,a_getfunction(c,"EVENT.ID->INTEGER",FALSE));
	dcl_oid(filename);
	a_setf(filename,a_getfunction(c,"EVENT.FILENAME->CHARSTRING",FALSE));
	dcl_oid(muons);
	a_setf(muons,a_getfunction(c,"MUON.EVENT->EVENT",FALSE));
	dcl_oid(electrons);
	a_setf(electrons,a_getfunction(c,"ELECTRON.EVENT->EVENT",FALSE));
	dcl_oid(jetbs);
	a_setf(jetbs,a_getfunction(c,"JETB.EVENT->EVENT",FALSE));
	dcl_oid(idp);
	a_setf(idp,a_getfunction(c,"ABSTRACTPARTICLE.ID->INTEGER",FALSE));
	dcl_oid(Kf);
	a_setf(Kf,a_getfunction(c,"ABSTRACTPARTICLE.KF->INTEGER",FALSE));
	dcl_oid(Px);
	a_setf(Px,a_getfunction(c,"ABSTRACTPARTICLE.PX->REAL",FALSE));
	dcl_oid(Py);
	a_setf(Py,a_getfunction(c,"ABSTRACTPARTICLE.PY->REAL",FALSE));
	dcl_oid(Pz);
	a_setf(Pz,a_getfunction(c,"ABSTRACTPARTICLE.PZ->REAL",FALSE));
	dcl_oid(Ee);
	a_setf(Ee,a_getfunction(c,"ABSTRACTPARTICLE.EE->REAL",FALSE));

	dcl_oid(eventtype);
	dcl_oid(electrontype);
	dcl_oid(muontype);
	dcl_oid(jetbtype);
	dcl_oid(event);
	dcl_oid(electron);
	dcl_oid(muon);
	dcl_oid(jetb);
	dcl_tuple(ev);
	dcl_tuple(arg);
	dcl_tuple(res);
	a_setf(eventtype,a_gettype(c,"EVENT",FALSE));
	a_setf(electrontype,a_gettype(c,"ELECTRON",FALSE));
	a_setf(muontype,a_gettype(c,"MUON",FALSE));
	a_setf(jetbtype,a_gettype(c,"JETB",FALSE));
	/* Main part. Loop over all events. */
	for (int i=startElem; i<=lastElem; i++)
	{
		ttree->GetEntry(i);

		/* Create event */
		event=a_createobject(c,eventtype,FALSE);
		a_newtuple(ev,1,FALSE);
		a_setobjectelem(ev,0,event,FALSE);
		/* Set PxMiss value */
		a_newtuple(res,1,FALSE);
		a_setdoubleelem(res,0,double(ttree->Pxmiss),FALSE);
		a_addfunction(c,PxMiss,ev,res,FALSE);
		/* Set PyMiss value */
		a_newtuple(res,1,FALSE);
		a_setdoubleelem(res,0,double(ttree->Pymiss),FALSE);
		a_addfunction(c,PyMiss,ev,res,FALSE);
		/* Set id value */
		a_newtuple(res,1,FALSE);
		a_setintelem(res,0,i,FALSE);
		a_addfunction(c,id,ev,res,FALSE);
		/* Set filename value */
		a_newtuple(res,1,FALSE);
		a_setstringelem(res,0,location,FALSE);
		a_addfunction(c,filename,ev,res,FALSE);

		/* Create electrons and add to event */
		for (int elNbr=0; elNbr < ttree->Nele; elNbr++)
		{
			electron=a_createobject(c,electrontype,FALSE);
			a_newtuple(arg,1,FALSE);
			a_setobjectelem(arg,0,electron,FALSE);
			/* Set Id value */
			a_newtuple(res,1,FALSE);
			a_setintelem(res,0,elNbr,FALSE);
			a_addfunction(c,idp,arg,res,FALSE);
			/* Set Kf value */
			a_newtuple(res,1,FALSE);
			a_setintelem(res,0,int(ttree->Kfele[elNbr]),FALSE);
			a_addfunction(c,Kf,arg,res,FALSE);
			/* Set Px value */
			a_newtuple(res,1,FALSE);
			a_setdoubleelem(res,0,double(ttree->Pxele[elNbr]),FALSE);
			a_addfunction(c,Px,arg,res,FALSE);
			/* Set Py value */
			a_newtuple(res,1,FALSE);
			a_setdoubleelem(res,0,double(ttree->Pyele[elNbr]),FALSE);
			a_addfunction(c,Py,arg,res,FALSE);
			/* Set Pz value */
			a_newtuple(res,1,FALSE);
			a_setdoubleelem(res,0,double(ttree->Pzele[elNbr]),FALSE);
			a_addfunction(c,Pz,arg,res,FALSE);
			/* Set Ee value */
			a_newtuple(res,1,FALSE);
			a_setdoubleelem(res,0,double(ttree->Eeele[elNbr]),FALSE);
			a_addfunction(c,Ee,arg,res,FALSE);

			a_addfunction(c,electrons,arg,ev,FALSE);
		}

		/* Create muons and add to event */
		for (int muNbr=0; muNbr < ttree->Nmuo; muNbr++)
		{
			muon=a_createobject(c,muontype,FALSE);
			a_newtuple(arg,1,FALSE);
			a_setobjectelem(arg,0,muon,FALSE);
			/* Set Id value */
			a_newtuple(res,1,FALSE);
			a_setintelem(res,0,muNbr,FALSE);
			a_addfunction(c,idp,arg,res,FALSE);
			/* Set Kf value */
			a_newtuple(res,1,FALSE);
			a_setintelem(res,0,int(ttree->Kfmuo[muNbr]),FALSE);
			a_addfunction(c,Kf,arg,res,FALSE);
			/* Set Px value */
			a_newtuple(res,1,FALSE);
			a_setdoubleelem(res,0,double(ttree->Pxmuo[muNbr]),FALSE);
			a_addfunction(c,Px,arg,res,FALSE);
			/* Set Py value */
			a_newtuple(res,1,FALSE);
			a_setdoubleelem(res,0,double(ttree->Pymuo[muNbr]),FALSE);
			a_addfunction(c,Py,arg,res,FALSE);
			/* Set Pz value */
			a_newtuple(res,1,FALSE);
			a_setdoubleelem(res,0,double(ttree->Pzmuo[muNbr]),FALSE);
			a_addfunction(c,Pz,arg,res,FALSE);
			/* Set Ee value */
			a_newtuple(res,1,FALSE);
			a_setdoubleelem(res,0,double(ttree->Eemuo[muNbr]),FALSE);
			a_addfunction(c,Ee,arg,res,FALSE);

			a_addfunction(c,muons,arg,ev,FALSE);
		}

		/* Create jetbs and add to event */
		for (int jbNbr=0; jbNbr < ttree->Njetb; jbNbr++)
		{
			jetb=a_createobject(c,jetbtype,FALSE);
			a_newtuple(arg,1,FALSE);
			a_setobjectelem(arg,0,jetb,FALSE);
			/* Set Id value */
			a_newtuple(res,1,FALSE);
			a_setintelem(res,0,jbNbr,FALSE);
			a_addfunction(c,idp,arg,res,FALSE);
			/* Set Kf value */
			a_newtuple(res,1,FALSE);
			a_setintelem(res,0,int(ttree->Kfjetb[jbNbr]),FALSE);
			a_addfunction(c,Kf,arg,res,FALSE);
			/* Set Px value */
			a_newtuple(res,1,FALSE);
			a_setdoubleelem(res,0,double(ttree->Pxjetb[jbNbr]),FALSE);
			a_addfunction(c,Px,arg,res,FALSE);
			/* Set Py value */
			a_newtuple(res,1,FALSE);
			a_setdoubleelem(res,0,double(ttree->Pyjetb[jbNbr]),FALSE);
			a_addfunction(c,Py,arg,res,FALSE);
			/* Set Pz value */
			a_newtuple(res,1,FALSE);
			a_setdoubleelem(res,0,double(ttree->Pzjetb[jbNbr]),FALSE);
			a_addfunction(c,Pz,arg,res,FALSE);
			/* Set Ee value */
			a_newtuple(res,1,FALSE);
			a_setdoubleelem(res,0,double(ttree->Eejetb[jbNbr]),FALSE);
			a_addfunction(c,Ee,arg,res,FALSE);

			a_addfunction(c,jetbs,arg,ev,FALSE);
		}
		eventcounter++;

	}

	free_tuple(res);
	free_tuple(arg);
	free_tuple(ev);
	free_oid(jetb);
	free_oid(muon);
	free_oid(electron);
	free_oid(event);

	free_oid(jetbtype);
	free_oid(muontype);
	free_oid(electrontype);
	free_oid(eventtype);

	free_oid(Ee);
	free_oid(Pz);
	free_oid(Py);
	free_oid(Px);
	free_oid(Kf);
	free_oid(jetbs);
	free_oid(electrons);
	free_oid(muons);
	free_oid(PyMiss);
	free_oid(PxMiss);

	a_execute(c,s,"logging on;",FALSE);
	a_disconnect(c,FALSE);
	free_scan(s);
	free_connection(c);
	return eventcounter;
}

//	load_root_file("signal50000Events_000.root");
void loadRootFile(a_callcontext cxt, a_tuple tpl)
{
	char location[70];
	int no;
	int res;
	a_getstringelem(tpl,0,location,sizeof(location),FALSE);
	TChain* tchain= new TChain("ATLFAST/h51");
	tchain->Add(location);
	TTreeClass* ttree= new TTreeClass(tchain);
	no=int(ttree->fChain->GetEntries());
	if (a_getarity(tpl,FALSE)==2) {
		res=readAndFill(ttree,0,no-1,location);
		a_setintelem(tpl,1,res,FALSE);
	} else {
		res=readAndFill(ttree,a_getintelem(tpl,1,FALSE),a_getintelem(tpl,2,FALSE)<no?a_getintelem(tpl,2,FALSE):no-1,location);
		a_setintelem(tpl,3,res,FALSE);
	}
	a_emit(cxt,tpl,FALSE);
}

void numberRootObjects(a_callcontext cxt, a_tuple tpl)
{
	char location[70];
	a_getstringelem(tpl,0,location,sizeof(location),FALSE);
	TChain* tchain= new TChain("ATLFAST/h51");
	tchain->Add(location);
	TTreeClass* ttree= new TTreeClass(tchain);
	a_setintelem(tpl,1,int(ttree->fChain->GetEntries()),FALSE);
	a_emit(cxt,tpl,FALSE);
}

int main (int argc, char** argv)
{
	dcl_connection(c);
	dcl_scan(s);
	init_amos(argc, argv);
	a_extfunction("load_root_file",loadRootFile);
	a_extfunction("no_root_objects",numberRootObjects);
	a_connect(c,"",FALSE);
	a_execute(c,s,"create function load_root_file(charstring)->integer\
		as foreign 'load_root_file';",FALSE);
	a_execute(c,s,"create function load_root_file(charstring,integer,integer)->integer\
		as foreign 'load_root_file';",FALSE);
	a_execute(c,s,"create function no_root_objects(charstring)->integer\
		as foreign 'no_root_objects';",FALSE);

	amos_toploop("ALEH");
	a_disconnect(c,FALSE);
	free_scan(s);
	free_connection(c);
	exit(0);
}
