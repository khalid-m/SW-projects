# include <cmath>
# include <iostream>
# include <time.h>
# include "TLine.h"
# include "TFile.h"
# include "TVector3.h"
# include "TVector2.h"
# include "TTreeCut.h"
# include "TCanvas.h"
# include "Parameters.h"

TTreeCut::TTreeCut() {
  //Create a chain and say where to find the tree in the .root files
  m_theTreeChain = new TChain("ATLFAST/h51");
    
  m_parameters = Parameters::GetPointer();
  m_luminosity = 
    m_parameters->GetParameterAsDouble("Luminosity");
  m_typeOfProcess = 
    m_parameters->GetParameterAsInteger("TypeOfProcess");
  m_typeOfMCGenerator = 
    m_parameters->GetParameterAsInteger("TypeOfMCGenerator");
  m_nbrOfEventsToAnalyse = 
    m_parameters->GetParameterAsInteger("NbrOfEventsToAnalyse");
  m_minPtOfTheHardestLepton = 
    m_parameters->GetParameterAsDouble("MinPtOfTheHardestLepton");
  m_minPtOfAllThreeLeptons = 
    m_parameters->GetParameterAsDouble("MinPtOfAllThreeLeptons");
  m_etaRangeForAllThreeLeptons = 
    m_parameters->GetParameterAsDouble("EtaRangeForAllThreeLeptons");
  m_printEventNbr = 
    m_parameters->GetParameterAsInteger("PrintEventNbr");
  m_printEvery100000EventNbr = 
    m_parameters->GetParameterAsInteger("PrintEvery100000EventNbr");
  m_printNbrLeptons = 
    m_parameters->GetParameterAsInteger("PrintNbrLeptons");
  m_zMass =
    m_parameters->GetParameterAsDouble("ZMass");
  m_minimumZMassDiff =
    m_parameters->GetParameterAsDouble("MinimumZMassDiff");
  m_etaRangeForJets = 
    m_parameters->GetParameterAsDouble("EtaRangeForJets");
  m_minPtForJets =
    m_parameters->GetParameterAsDouble("MinPtForJets");
  m_topMass =
    m_parameters->GetParameterAsDouble("TopMass");
  m_allowedTopMassDiff =
    m_parameters->GetParameterAsDouble("AllowedTopMassDiff");
  m_wMass =
    m_parameters->GetParameterAsDouble("WMass");
  m_allowedWMassDiff =
    m_parameters->GetParameterAsDouble("AllowedWMassDiff");
  m_maxAllowedPtForOtherJets =
    m_parameters->GetParameterAsDouble("MaxAllowedPtForOtherJets");
  m_maxPtForAllThreeIsolatedLeptons =
    m_parameters->GetParameterAsDouble("MaxPtForAllThreeIsolatedLeptons");
  m_maxPtForTheSoftestIsolatedLepton =
    m_parameters->GetParameterAsDouble("MaxPtForTheSoftestIsolatedLepton");
  m_minMissingTransverseEnergy =
    m_parameters->GetParameterAsDouble("MinMissingTransverseEnergy");
  m_maxAllowedEffectiveMass =
    m_parameters->GetParameterAsDouble("MaxAllowedEffectiveMass");
  m_theIntegerForBTaggedJet = 
    m_parameters->GetParameterAsInteger("TheIntegerForBTaggedJet");
  m_topCutType = 
    m_parameters->GetParameterAsInteger("TopCutType");
  m_tanBeta =
    m_parameters->GetParameterAsDouble("TanBeta");
  m_mA =
    m_parameters->GetParameterAsDouble("MA");
  m_m2 =
    m_parameters->GetParameterAsDouble("M2");
  m_mu =
    m_parameters->GetParameterAsDouble("Mu");
  m_biggerStauMass = 
    m_parameters->GetParameterAsInteger("BiggerStauMass");

  if (m_typeOfMCGenerator == 1) {
    m_mcString = "PYTHIA";
  } else if (m_typeOfMCGenerator == 2) {
    m_mcString = "HERWIG";
  } else {
    cout<<"ERROR, Wrong type of generator, Exit!"<<endl;
    exit(1);
  }

  char location[60];
  m_partition=false;

  if (m_typeOfProcess == 0) {
    cout<<"Test file"<<endl;
    sprintf(location,"~/AmosNT/wrappers/ROOTWrap/t.root");
  } else if (m_typeOfProcess == 2) { // All bkg files
    cout<<"All bkgs together"<<endl;
    sprintf(location,"~/ALEHdata/bkg*.root");
    outfile.open("/home/ruslan/AmosNT/aleh/experiments/AllBkgs.2003.C.txt",ios::out|ios::trunc);
    if(!outfile)
      cout<<"AllBkgs.2003.C.txt is not opened"<<endl;
  } else if (m_typeOfProcess == 3) { // Signal file
    cout<<"The signal file"<<endl;
    sprintf(location,"~/ALEHdata/signal*.root");
    outfile.open("/home/ruslan/AmosNT/aleh/experiments/Signal.2003.C.txt",ios::out);
    if(!outfile)
      cout<<"Signal.2003.C.txt is not opened"<<endl;
  } else if (m_typeOfProcess == 1) {
    cout<<"All bkgs together"<<endl;
    sprintf(location,"~/ALEHdata/eventFiles1/bkg*.root");
    outfile.open("/home/ruslan/AmosNT/aleh/experiments/Cpp.Bkgs.2003.txt",ios::out|ios::app);
    if(!outfile)
      cout<<"Cpp.Bkgs.2003.txt is not opened"<<endl;
  } else if (m_typeOfProcess == 9) {
    cout<<"All bkgs together"<<endl;
    sprintf(location,"~/ALEHdata/eventFiles9/bkg*.root");
    outfile.open("/home/ruslan/AmosNT/aleh/experiments/Cpp.Bkgs.2003.txt",ios::out|ios::app);
    if(!outfile)
      cout<<"Cpp.Bkgs.2003.txt is not opened"<<endl;
  } else if (m_typeOfProcess == 17) {
    cout<<"All bkgs together"<<endl;
    sprintf(location,"~/ALEHdata/eventFiles17/bkg*.root");
    outfile.open("/home/ruslan/AmosNT/aleh/experiments/Cpp.Bkgs.2003.txt",ios::out|ios::app);
    if(!outfile)
      cout<<"Cpp.Bkgs.2003.txt is not opened"<<endl;
  } else if (m_typeOfProcess == 25) {
    cout<<"All bkgs together"<<endl;
    sprintf(location,"~/ALEHdata/eventFiles25/bkg*.root");
    outfile.open("/home/ruslan/AmosNT/aleh/experiments/Cpp.Bkgs.2003.txt",ios::out|ios::app);
    if(!outfile)
      cout<<"Cpp.Bkgs.2003.txt is not opened"<<endl;
  } else if (m_typeOfProcess == 33) {
    cout<<"All bkgs together"<<endl;
    sprintf(location,"~/ALEHdata/eventFiles33/bkg*.root");
    outfile.open("/home/ruslan/AmosNT/aleh/experiments/Cpp.Bkgs.2003.txt",ios::out|ios::app);
    if(!outfile)
      cout<<"Cpp.Bkgs.2003.txt is not opened"<<endl;
  } else if (m_typeOfProcess == 41) {
    cout<<"All bkgs together"<<endl;
    sprintf(location,"~/ALEHdata/eventFiles41/bkg*.root");
    outfile.open("/home/ruslan/AmosNT/aleh/experiments/Cpp.Bkgs.2003.txt",ios::out|ios::app);
    if(!outfile)
      cout<<"Cpp.Bkgs.2003.txt is not opened"<<endl;
  } else { //Bgk
    cout<<"Signal or Unknown type of process, i.e. file to run through: "<<m_typeOfProcess<<endl;
    m_partition=true;
    sprintf(location,"~/ALEHdata/signal*.root");
    outfile.open("/home/ruslan/AmosNT/aleh/experiments/Cpp.Signal.2003.txt",ios::out|ios::app);
    if(!outfile)
      cout<<"Signal.2003.C.txt is not opened"<<endl;
    //    exit(1);
  }

  m_theTreeChain->Add(location);
  cout<<"Location = "<<location<<endl;
  //Make a treeClass from the chain
  m_theTree = new TTreeClass(m_theTreeChain);

  gROOT->cd();  //make gROOT the current directory otherwice we get problem 
                //when trying to delete the histograms later
  m_anInvMassCalc = new TInvMassCalc();
}

TTreeCut::~TTreeCut() {
  if (outfile)
    outfile.close();
  delete m_theTree;
}

/* Moving initialization code from Loop to here by Ruslan Fomkin */
void TTreeCut::InitLoop() {
  m_nbrOkSimEvents = 0;
  m_nbrSurvived3lCut = 0;
  m_nbrSurvivedZVetoCut = 0;
  m_nbrSurvivedHadrTopCut = 0;
  m_nbrSurvivedBTagCut = 0;
  m_nbrSurvivedJetCut = 0;
  m_totNbrSimEvents = int(m_theTree->fChain->GetEntries());
  if (m_partition)
    m_totNbrSimEvents = m_typeOfProcess;
}

void TTreeCut::Loop() {
  if (m_theTree->fChain == 0) {
    cout<<"ERROR in TTreeCut::Loop(), there was no tree"<<endl;
    return;
  }
  clock_t c1, c2;
  double cputime, sumtime, curtime, sqsum, avgtime, stdev;
  int rptAvg = 5;
  // Warming up
  InitLoop();
  for (Int_t jEntry=0; jEntry < m_totNbrSimEvents; jEntry++) {
    if (m_printEventNbr) cout<<"Event nbr "<<jEntry<<endl;
    if ((m_printEvery100000EventNbr)&&(jEntry%100000 == 0)) {
      cout<<"Event nbr "<<jEntry<<endl;
    }
    CutEvent(jEntry);
  }
    cout<<"Nbr simulated events that survived the 3l cut       = "<<m_nbrSurvived3lCut<<endl;
    cout<<"Nbr simulated events that survived the Z-Veto cut   = "<<m_nbrSurvivedZVetoCut<<endl;
    cout<<"Nbr simulated events that survived the Hadr Top cut = "<<m_nbrSurvivedHadrTopCut<<endl;
    if (m_topCutType == 1) {
      cout<<"Nbr simulated events that survived the BTag cut     = "<<m_nbrSurvivedBTagCut<<endl;
    }
    cout<<"Nbr simulated events that survived the Jet Veto cut = "<<m_nbrSurvivedJetCut<<endl;
    cout<<"Nbr Simulated Events that Survived all Cuts = "<<m_nbrOkSimEvents<<endl;
    cout<<"--------------------------------------------------------------"<<endl;
  // Loop over order written by Christian Hansen
  if (outfile.is_open()) {
    cout<<"Output to file"<<endl;
    sumtime = 0;
    sqsum = 0;
    for (int i=0; i<rptAvg; i++) {
      c1=clock();
      InitLoop();
      for (Int_t jEntry=0; jEntry < m_totNbrSimEvents; jEntry++) {
	if (m_printEventNbr) cout<<"Event nbr "<<jEntry<<endl;
	if ((m_printEvery100000EventNbr)&&(jEntry%100000 == 0)) {
	  cout<<"Event nbr "<<jEntry<<endl;
	}
	CutEvent(jEntry);
      }
      c2=clock();
      curtime = ((double)(c2-c1))/(CLOCKS_PER_SEC);
      sumtime += curtime;
      sqsum += curtime*curtime;
    }
    avgtime = sumtime/rptAvg;
    stdev = sqrt(sqsum/rptAvg - avgtime*avgtime);
    outfile<<"Christian's original order, "<<avgtime<<", ";
    outfile<<stdev<<", "<<sqsum<<", "<<m_nbrOkSimEvents<<", ";
    outfile<<m_totNbrSimEvents<<endl;
  } else {
    c1=clock();
    InitLoop();
    for (Int_t jEntry=0; jEntry < m_totNbrSimEvents; jEntry++) {
      if (m_printEventNbr) cout<<"Event nbr "<<jEntry<<endl;
      if ((m_printEvery100000EventNbr)&&(jEntry%100000 == 0)) {
	cout<<"Event nbr "<<jEntry<<endl;
      }
      CutEvent(jEntry);
    }
    c2=clock();
    cputime=((double)(c2-c1))/(CLOCKS_PER_SEC);
    cout << "*************** Original order of the file, by Christian Hansen *******" << endl;
    cout<<"Time of executing in seconds: "<<cputime<<endl;
    cout<<"Nbr simulated events that survived the 3l cut       = "<<m_nbrSurvived3lCut<<endl;
    cout<<"Nbr simulated events that survived the Z-Veto cut   = "<<m_nbrSurvivedZVetoCut<<endl;
    cout<<"Nbr simulated events that survived the Hadr Top cut = "<<m_nbrSurvivedHadrTopCut<<endl;
    if (m_topCutType == 1) {
      cout<<"Nbr simulated events that survived the BTag cut     = "<<m_nbrSurvivedBTagCut<<endl;
    }
    cout<<"Nbr simulated events that survived the Jet Veto cut = "<<m_nbrSurvivedJetCut<<endl;
    cout<<"Nbr Simulated Events that Survived all Cuts = "<<m_nbrOkSimEvents<<endl;
    cout<<"--------------------------------------------------------------"<<endl;
  }
  // Loop over original non-optimized order from the first paper
  if (outfile.is_open()) {
    cout<<"Output to file"<<endl;
    sumtime = 0;
    sqsum = 0;
    for (int i=0; i<rptAvg; i++) {
      c1=clock();
      InitLoop();
      for (Int_t jEntry=0; jEntry < m_totNbrSimEvents; jEntry++) {
	if (m_printEventNbr) cout<<"Event nbr "<<jEntry<<endl;
	if ((m_printEvery100000EventNbr)&&(jEntry%100000 == 0)) {
	  cout<<"Event nbr "<<jEntry<<endl;
	}
	OriginalCutEvent(jEntry);
      }
      c2=clock();
      curtime = ((double)(c2-c1))/(CLOCKS_PER_SEC);
      sumtime += curtime;
      sqsum += curtime*curtime;
    }
    avgtime = sumtime/rptAvg;
    stdev = sqrt(sqsum/rptAvg - avgtime*avgtime);
    outfile<<"Original paper order, "<<avgtime<<", ";
    outfile<<stdev<<", "<<sqsum<<", "<<m_nbrOkSimEvents<<", ";
    outfile<<m_totNbrSimEvents<<endl;
  } else {
    c1=clock();
    InitLoop();
    for (Int_t jEntry=0; jEntry < m_totNbrSimEvents; jEntry++) {
      if (m_printEventNbr) cout<<"Event nbr "<<jEntry<<endl;
      if ((m_printEvery100000EventNbr)&&(jEntry%100000 == 0)) {
	cout<<"Event nbr "<<jEntry<<endl;
      }
      OriginalCutEvent(jEntry);
    }
    c2=clock();
    cputime=((double)(c2-c1))/(CLOCKS_PER_SEC);
    cout << "*************** Non-optimized order from the first paper *******" << endl;
    cout<<"Time of executing in seconds: "<<cputime<<endl;
    cout<<"Nbr simulated events that survived the 3l cut       = "<<m_nbrSurvived3lCut<<endl;
    cout<<"Nbr simulated events that survived the Hadr Top cut = "<<m_nbrSurvivedHadrTopCut<<endl;
    if (m_topCutType == 1) {
      cout<<"Nbr simulated events that survived the BTag cut     = "<<m_nbrSurvivedBTagCut<<endl;
      cout<<"Nbr simulated events that survived the Z-Veto cut   = "<<m_nbrSurvivedZVetoCut<<endl;
    }
    cout<<"Nbr simulated events that survived the Jet Veto cut = "<<m_nbrSurvivedJetCut<<endl;
    cout<<"Nbr Simulated Events that Survived all Cuts = "<<m_nbrOkSimEvents<<endl;
    cout<<"--------------------------------------------------------------"<<endl;
  }
  // Loop over optimized order (best manual effort plan)
  if (outfile.is_open()) {
    cout<<"Output to file"<<endl;
    sumtime = 0;
    sqsum = 0;
    for (int i=0; i<rptAvg; i++) {
      c1=clock();
      InitLoop();
      for (Int_t jEntry=0; jEntry < m_totNbrSimEvents; jEntry++) {
	if (m_printEventNbr) cout<<"Event nbr "<<jEntry<<endl;
	if ((m_printEvery100000EventNbr)&&(jEntry%100000 == 0)) {
	  cout<<"Event nbr "<<jEntry<<endl;
	}
	OptimizedCutEvent(jEntry);
      }
      c2=clock();
      curtime = ((double)(c2-c1))/(CLOCKS_PER_SEC);
      sumtime += curtime;
      sqsum += curtime*curtime;
    }
    avgtime = sumtime/rptAvg;
    stdev = sqrt(sqsum/rptAvg - avgtime*avgtime);
    outfile<<"Best manual effort order, "<<avgtime<<", ";
    outfile<<stdev<<", "<<sqsum<<", "<<m_nbrSurvivedJetCut<<", ";
    outfile<<m_totNbrSimEvents<<endl;
  } else {
    c1=clock();
    InitLoop();
    for (Int_t jEntry=0; jEntry < m_totNbrSimEvents; jEntry++) {
      if (m_printEventNbr) cout<<"Event nbr "<<jEntry<<endl;
      if ((m_printEvery100000EventNbr)&&(jEntry%100000 == 0)) {
	cout<<"Event nbr "<<jEntry<<endl;
      }
      OptimizedCutEvent(jEntry);
    }
    c2=clock();
    cputime=((double)(c2-c1))/(CLOCKS_PER_SEC);
    cout << "*************** Optimized order from the first paper, by Ruslan Fomkin (from best effort) *******" << endl;
    cout<<"Time of executing in seconds: "<<cputime<<endl;
    cout<<"Nbr simulated events that survived the 3l cut       = "<<m_nbrSurvived3lCut<<endl;
    cout<<"Nbr simulated events that survived the Z-Veto cut   = "<<m_nbrSurvivedZVetoCut<<endl;
    cout<<"Nbr simulated events that survived the Hadr Top cut = "<<m_nbrSurvivedHadrTopCut<<endl;
    if (m_topCutType == 1) {
      cout<<"Nbr simulated events that survived the BTag cut     = "<<m_nbrSurvivedBTagCut<<endl;
    }
    cout<<"Nbr simulated events that survived the Jet Veto cut = "<<m_nbrSurvivedJetCut<<endl;
    cout<<"Nbr Simulated Events that Survived all Cuts = "<<m_nbrOkSimEvents<<endl;
    cout<<"--------------------------------------------------------------"<<endl;
  }
  if (outfile.is_open()) {
    cout<<"Output to file"<<endl;
    sumtime = 0;
    sqsum = 0;
    for (int i=0; i<rptAvg; i++) {
      c1=clock();
      InitLoop();
      for (Int_t jEntry=0; jEntry < m_totNbrSimEvents; jEntry++) {
	if (m_printEventNbr) cout<<"Event nbr "<<jEntry<<endl;
	if ((m_printEvery100000EventNbr)&&(jEntry%100000 == 0)) {
	  cout<<"Event nbr "<<jEntry<<endl;
	}
	ExpensiveCutEvent(jEntry);
      }
      c2=clock();
      curtime = ((double)(c2-c1))/(CLOCKS_PER_SEC);
      sumtime += curtime;
      sqsum += curtime*curtime;
    }
    avgtime = sumtime/rptAvg;
    stdev = sqrt(sqsum/rptAvg - avgtime*avgtime);
    outfile<<"Expensive order, "<<avgtime<<", ";
    outfile<<stdev<<", "<<sqsum<<", "<<m_nbrOkSimEvents<<", ";
    outfile<<m_totNbrSimEvents<<endl;
  } else {
    c1=clock();
    InitLoop();
    for (Int_t jEntry=0; jEntry < m_totNbrSimEvents; jEntry++) {
      if (m_printEventNbr) cout<<"Event nbr "<<jEntry<<endl;
      if ((m_printEvery100000EventNbr)&&(jEntry%100000 == 0)) {
	cout<<"Event nbr "<<jEntry<<endl;
      }
      ExpensiveCutEvent(jEntry);
    }
    c2=clock();
    cputime=((double)(c2-c1))/(CLOCKS_PER_SEC);
    cout << "*************** Expensive order, by Ruslan Fomkin *******" << endl;
    cout<<"Time of executing in seconds: "<<cputime<<endl;
    cout<<"Nbr simulated events that survived the Hadr Top cut = "<<m_nbrSurvivedHadrTopCut<<endl;
    if (m_topCutType == 1) {
      cout<<"Nbr simulated events that survived the BTag cut     = "<<m_nbrSurvivedBTagCut<<endl;
    }
    cout<<"Nbr simulated events that survived the Jet Veto cut = "<<m_nbrSurvivedJetCut<<endl;
    cout<<"Nbr simulated events that survived the Z-Veto cut   = "<<m_nbrSurvivedZVetoCut<<endl;
    cout<<"Nbr simulated events that survived the 3l cut       = "<<m_nbrSurvived3lCut<<endl;
    cout<<"Nbr Simulated Events that Survived all Cuts = "<<m_nbrOkSimEvents<<endl;
    cout<<"--------------------------------------------------------------"<<endl;
  }
}

void TTreeCut::CutEvent(Int_t eventNbr) {
  bool survivedThreeIsolatedLeptonsCut = false;
  bool survivedZVetoCut = false;
  bool survivedHadrTopCut = false;
  bool survivedBTagCut = false;
  bool survivedJetVetoCut = false;
  bool survivedOtherCuts = false;
  //Load this event
  m_theTree->GetEntry(eventNbr);
  //Do cuts on this event
  survivedThreeIsolatedLeptonsCut = ThreeLeptonCut();
  if (survivedThreeIsolatedLeptonsCut) {
    m_nbrSurvived3lCut++;
    survivedZVetoCut = ZVetoCut();
    if (survivedZVetoCut) {
      m_nbrSurvivedZVetoCut++;
      survivedHadrTopCut = HadrTopCut();
      if (survivedHadrTopCut) {
		m_nbrSurvivedHadrTopCut++;
		survivedBTagCut = BTagCut();
		if (survivedBTagCut) {
		  m_nbrSurvivedBTagCut++;
		  survivedJetVetoCut = JetVetoCut();
		  if (survivedJetVetoCut) {
			m_nbrSurvivedJetCut++;
			survivedOtherCuts = OtherCuts();
			if (survivedOtherCuts) {
			  m_nbrOkSimEvents++;
			}
		  }
		}
      }
    }
  }
}

void TTreeCut::OriginalCutEvent(Int_t eventNbr) {
  bool survivedThreeIsolatedLeptonsCut = false;
  bool survivedZVetoCut = false;
  bool survivedHadrTopCut = false;
  bool survivedBTagCut = false;
  bool survivedJetVetoCut = false;
  bool survivedOtherCuts = false;
  //Load this event
  m_theTree->GetEntry(eventNbr);
  //Do cuts on this event
  survivedThreeIsolatedLeptonsCut = ThreeLeptonCut();
  if (survivedThreeIsolatedLeptonsCut) {
    m_nbrSurvived3lCut++;
    survivedHadrTopCut = HadrTopCut();
    if (survivedHadrTopCut) {
      m_nbrSurvivedHadrTopCut++;
      survivedBTagCut = BTagCut();
      if (survivedBTagCut) {
	m_nbrSurvivedBTagCut++;
	survivedZVetoCut = ZVetoCut();
	if (survivedZVetoCut) {
	  m_nbrSurvivedZVetoCut++;
	  survivedJetVetoCut = JetVetoCut();
	  if (survivedJetVetoCut) {
	    m_nbrSurvivedJetCut++;
	    survivedOtherCuts = OtherCuts();
	    if (survivedOtherCuts) {
	      m_nbrOkSimEvents++;
	    }
	  }
	}
      }
    }
  }
}


void TTreeCut::OptimizedCutEvent(Int_t eventNbr) {
  bool survivedThreeIsolatedLeptonsCut = false;
  bool survivedZVetoCut = false;
  bool survivedHadrTopCut = false;
  bool survivedBTagCut = false;
  bool survivedJetVetoCut = false;
  bool survivedOtherCuts = false;
  //Load this event
  m_theTree->GetEntry(eventNbr);
  //Do cuts on this event
  survivedThreeIsolatedLeptonsCut = ThreeLeptonCut();
  if (survivedThreeIsolatedLeptonsCut) {
    m_nbrSurvived3lCut++;
    survivedOtherCuts = OtherCuts();
    if (survivedOtherCuts) {
      m_nbrOkSimEvents++;
      survivedZVetoCut = ZVetoCut();
      if (survivedZVetoCut) {
	m_nbrSurvivedZVetoCut++;
	survivedHadrTopCut = HadrTopCut();
	if (survivedHadrTopCut) {
	  m_nbrSurvivedHadrTopCut++;
	  survivedBTagCut = BTagCut();
	  if (survivedBTagCut) {
	    m_nbrSurvivedBTagCut++;
	    survivedJetVetoCut = JetVetoCut();
	    if (survivedJetVetoCut) {
	      m_nbrSurvivedJetCut++;

	    }
	  }
	}
      }
    }
  }
}

void TTreeCut::ExpensiveCutEvent(Int_t eventNbr) {
  bool survivedThreeIsolatedLeptonsCut = false;
  bool survivedZVetoCut = false;
  bool survivedHadrTopCut = false;
  bool survivedBTagCut = false;
  bool survivedJetVetoCut = false;
  bool survivedOtherCuts = false;
  //Load this event
  m_theTree->GetEntry(eventNbr);
  //Do cuts on this event
  survivedHadrTopCut = HadrTopCut();
  if (survivedHadrTopCut) {
    m_nbrSurvivedHadrTopCut++;
    survivedBTagCut = BTagCut();
    if (survivedBTagCut) {
      m_nbrSurvivedBTagCut++;
      survivedJetVetoCut = JetVetoCut();
      if (survivedJetVetoCut) {
	m_nbrSurvivedJetCut++;
	survivedZVetoCut = ZVetoCut();
	if (survivedZVetoCut) {
	  m_nbrSurvivedZVetoCut++;
	  survivedThreeIsolatedLeptonsCut = ThreeLeptonCut();
	  if (survivedThreeIsolatedLeptonsCut) {
	    m_nbrSurvived3lCut++;
	    survivedOtherCuts = OtherCuts();
	    if (survivedOtherCuts) {
	      m_nbrOkSimEvents++;
	    }
	  }
	}
      }
    }
  }
}

bool TTreeCut::ThreeLeptonCut() {   //New  
  m_isolatedLeptons.clear();
  int nbrEl = m_theTree->Nele;  //Nbr Isolated Electrons in this event
  int nbrMu = m_theTree->Nmuo;  //Nbr Isolated Muons in this event

  //If less than 3 isolated leptons, failed!
  if (nbrEl + nbrMu < 3) return false;

  vector<TObjectClass> allLeptonsWithinEtaRange;
  allLeptonsWithinEtaRange.clear();

  //Loop over all isolated electrons in this event 
  for (int jEl = 0; jEl < nbrEl; jEl++) {
    TObjectClass tempEl(jEl, m_theTree->Kfele[jEl], m_theTree->Pxele[jEl], 
			m_theTree->Pyele[jEl], m_theTree->Pzele[jEl], m_theTree->Eeele[jEl]);
    //Save if within the eta range
    if (fabs(tempEl.Eta()) < m_etaRangeForAllThreeLeptons) {
      allLeptonsWithinEtaRange.push_back(tempEl);
    }
  }
  //Loop over all isolated muons in this event 
  for (int jMu = 0; jMu < nbrMu; jMu++) {
    TObjectClass tempMu(jMu, m_theTree->Kfmuo[jMu], m_theTree->Pxmuo[jMu], 
			m_theTree->Pymuo[jMu], m_theTree->Pzmuo[jMu], m_theTree->Eemuo[jMu]);
    //Save if within the eta range
    if (fabs(tempMu.Eta()) < m_etaRangeForAllThreeLeptons) {
      allLeptonsWithinEtaRange.push_back(tempMu);
    }
  }
  
  int nbrLeptonsAboveFirstPtLimit = 0;
  int nbrLeptonsAboveSecondPtLimit = 0;
  int nbrLeptonsWithinEta = allLeptonsWithinEtaRange.size();
  //Loop over all leptons within eta range 
  for (int jLe = 0; jLe < nbrLeptonsWithinEta; jLe++) {
    //Check if this lepton is hard enough to be one of the three
    if (allLeptonsWithinEtaRange[jLe].Pt() > m_minPtOfAllThreeLeptons) {
      nbrLeptonsAboveFirstPtLimit++;
      m_isolatedLeptons.push_back(allLeptonsWithinEtaRange[jLe]);
    }
    //Check if this lepton is hard enough to be the hardest lepton
    if (allLeptonsWithinEtaRange[jLe].Pt() > m_minPtOfTheHardestLepton) {
      nbrLeptonsAboveSecondPtLimit++;
    }
  }
  
  //Events should have exactly three isolated leptons with pt > 20,7,7 GeV
  return ((nbrLeptonsAboveFirstPtLimit == 3)&&(nbrLeptonsAboveSecondPtLimit >= 1));
}

bool TTreeCut::ZVetoCut() {
  Int_t nbrEl = m_theTree->Nele;  //Nbr Electrons/Positrons in this event
  //loop over all electrons/positrons in this event
  for (Int_t iEl = 0; iEl < nbrEl; iEl++) {
    for (Int_t jEl = iEl + 1; jEl < nbrEl; jEl++) {
      //Check if they have opposite charge
      if (m_theTree->Kfele[iEl] == - m_theTree->Kfele[jEl]) {
	//Check if their invariant mass is close to the Z mass
	vector<TObjectClass > tempLeptons;
	TObjectClass tempEl1(iEl, m_theTree->Kfele[iEl], m_theTree->Pxele[iEl], 
			     m_theTree->Pyele[iEl], m_theTree->Pzele[iEl], m_theTree->Eeele[iEl]);
	tempLeptons.push_back(tempEl1);
	TObjectClass tempEl2(jEl, m_theTree->Kfele[jEl], m_theTree->Pxele[jEl], 
			     m_theTree->Pyele[jEl], m_theTree->Pzele[jEl], m_theTree->Eeele[jEl]);
	tempLeptons.push_back(tempEl2);
	if ((fabs(m_anInvMassCalc->InvMass(tempLeptons) - m_zMass) < m_minimumZMassDiff)) {
	  return false;  //This event did not survive the Z-Veto cut
	}
      }
    }
  }
  Int_t nbrMu = m_theTree->Nmuo;  //Nbr Muons/Antimuons in this event
  //loop over all muons/antimuons in this event
  for (Int_t iMu = 0; iMu < nbrMu; iMu++) {
    for (Int_t jMu = iMu + 1; jMu < nbrMu; jMu++) {
      //Check if they have opposite charge
      if (m_theTree->Kfmuo[iMu] == - m_theTree->Kfmuo[jMu]) {
	//Check if their invariant mass is close to the Z mass
	vector<TObjectClass > tempLeptons;
	TObjectClass tempMu1(iMu, m_theTree->Kfmuo[iMu], m_theTree->Pxmuo[iMu], 
			     m_theTree->Pymuo[iMu], m_theTree->Pzmuo[iMu], m_theTree->Eemuo[iMu]);
	tempLeptons.push_back(tempMu1);
	TObjectClass tempMu2(jMu, m_theTree->Kfmuo[jMu], m_theTree->Pxmuo[jMu], 
			     m_theTree->Pymuo[jMu], m_theTree->Pzmuo[jMu], m_theTree->Eemuo[jMu]);
	tempLeptons.push_back(tempMu2);
	if ((fabs(m_anInvMassCalc->InvMass(tempLeptons) - m_zMass) < m_minimumZMassDiff)) {
	  return false;  //This event did not survive the Z-Veto cut
	}
      }
    }
  }
  return true;
}

bool TTreeCut::HadrTopCut() {
  //Check all jets in this event and save those who's Eta and Pt are ok
  if (!SelectOkJets()) return false; //Failed cut if not 3 or more ok jets

  if (m_topCutType == 1) {
    ////////////////////////////////////////////////////////////////
    ///// The paper suggests to do it this way : ///////////////////
    ////////////////////////////////////////////////////////////////
    //Out of the ok jets select 3 jets likely to come from top quark 
    if (!Select3TopJets()) return false;
    
    //Out of the 3 top jets select 2 jets likely to come from W boson 
    if (!Select2WJets()) return false;
    
    //Then check if the third jet is b-tagged will be done later in BTagCut
    /////////////////////////////////////////////////////////////////
  }
  
  if (m_topCutType == 2) {
    ////////////////////////////////////////////////////////////////
    ///// Nils suggests to do it this way :     ////////////////////
    ////////////////////////////////////////////////////////////////
    ////Seperate the ok jets in b-tagged and none b-tagged
    if (!SeperateBJets()) return false; //Failed if not at least one b-tagged
    
    ////Out of the ok W jets pick out all possible 2-Jet-W combinations
    if (!Select2WCombinations()) return false; //Failed if not at least one 2-Jet-W combi
    
    ////Pick out the best 2W-Jets-B-Jet combination
    if (!SelectTopCombination()) return false; //Failed if not at least one 3Top-Jet combi
    
    ////This way will combine the top and b cut (one less column)
    /////////////////////////////////////////////////////////////////
  }
  
 
  return true;
}

bool TTreeCut::BTagCut() {
  if (m_topCutType == 1) {
    ///////////////////////////////////////////////////////////
    // For paper's way only, with Nils' way, do nothing here...
    ///////////////////////////////////////////////////////////
    //Check if the third of the 3 top jets is b-tagged
    if (m_theTree->Kfjetb[m_theBJet.GetId()] != m_theIntegerForBTaggedJet) {
      return false;  //then failed this cut
    }
  }
  return true;
}

bool TTreeCut::JetVetoCut() {
  int nbrLeftOverJets =  m_theLeftOverJets.size();
  for (int i = 0; i < nbrLeftOverJets; i++) {
    //Loop over all left over jets (that is all jets with pt > 20
    //and eta < 4.5 except the top jets) and if they have pt > 70 
    //this event failed the cut
    if (m_theLeftOverJets[i].Pt() > m_maxAllowedPtForOtherJets) return false; 
  }
  return true;
}

float TTreeCut::AbsV(float x) {
  if (x<0)
    return -x;
  else
    return x;
}

bool TTreeCut::OtherCuts() {  
  int nbrLeptons = m_isolatedLeptons.size();
  double ptForSoftestLepton = 9000000000.0;
  for (int i = 0; i < nbrLeptons; i++) {
    //Check if any lepton is too hard
    if (m_isolatedLeptons[i].Pt() > m_maxPtForAllThreeIsolatedLeptons) {
      return false;  //then, failed the cut
    }
    //Save the lowest pt for all three leptons
    if (m_isolatedLeptons[i].Pt() < ptForSoftestLepton) {
      ptForSoftestLepton = m_isolatedLeptons[i].Pt();
    }
  }
  //Check if the softest lepton is too hard
  if (ptForSoftestLepton > m_maxPtForTheSoftestIsolatedLepton) {
    return false; //then, failed the cut
  }
  TVector2 ptMiss(m_theTree->Pxmiss,m_theTree->Pymiss);
  //Check if the missing transverse energy is not large enough
  if (ptMiss.Mod() < m_minMissingTransverseEnergy) {
    return false;  //then, failed the cut
  }

  //Get the Pt vector of the isolated leptons
  TVector2 pt3l(0.,0.);
  for (int i = 0; i < nbrLeptons; i++) {
    TVector2 tempPt(m_isolatedLeptons[i].Px(),m_isolatedLeptons[i].Py());
    pt3l += tempPt;
  }
  //Check if the effective mass is bigger than allowed
  float mEff = sqrt(AbsV(2*pt3l*ptMiss*(1-cos(pt3l.DeltaPhi(ptMiss)))));
  if (mEff > m_maxAllowedEffectiveMass) {
    return false;  //then, failed the cut
  }
  return true;
}

bool TTreeCut::SelectOkJets() {
  m_okJets.clear();
  Int_t nbrJets = m_theTree->Njetb;  //Nbr jets (with AtlfastB to) in this event
  if (nbrJets < 3) return false; //Failed cut if less than 3 jets
  //loop over all jets in this event
  for (Int_t jJet = 0; jJet < nbrJets; jJet++) {
    TObjectClass tempJet(jJet, m_theTree->Kfjetb[jJet], m_theTree->Pxjetb[jJet], 
			 m_theTree->Pyjetb[jJet], m_theTree->Pzjetb[jJet], m_theTree->Eejetb[jJet]);
    //Check if this jet is within the eta range
    if (fabs(tempJet.Eta()) < m_etaRangeForJets) {
      //Check if this jet has Pt > 20GeV
      if (tempJet.Pt() > m_minPtForJets) {
	m_okJets.push_back(tempJet);
      }
    }
  }
  //The event must have at least three ok jets
  if (m_okJets.size() < 3) return false;  //Failed cut
  return true;
}

bool TTreeCut::SeperateBJets() {
  m_okBJets.clear();
  m_okWJets.clear();  
  int nbrOkJets = m_okJets.size();
  //Loop over all ok jets
  for (int i = 0; i < nbrOkJets; i++) {
    //If b-tagged then save into okBJets
    if (m_okJets[i].GetPdg() == m_theIntegerForBTaggedJet) {
      m_okBJets.push_back(m_okJets[i]);
    } else {
      //Save into okWJets
      m_okWJets.push_back(m_okJets[i]);
    }
  }
  return (m_okBJets.size() > 0); //Have to be at least one b-jet
}

bool TTreeCut::Select2WCombinations() {
  m_okWComb.clear();
  int nbrOkWJets = m_okWJets.size();
  //Loop over all ok W-Jets and make 2WJet-combinations
  for (int iWJet = 0; iWJet < nbrOkWJets; iWJet++) {
    for (int jWJet = iWJet + 1; jWJet < nbrOkWJets; jWJet++) {
      vector<TObjectClass > temp2WComb;
      temp2WComb.push_back(m_okWJets[iWJet]);
      temp2WComb.push_back(m_okWJets[jWJet]);
      //If the inv mass of this 2WCombination is ok, save it
      if (fabs(m_anInvMassCalc->InvMass(temp2WComb) - m_wMass) < m_allowedWMassDiff) {
	m_okWComb.push_back(temp2WComb);
      }
    }
  }
  return (m_okWComb.size() > 0);
}

bool TTreeCut::SelectTopCombination() {
  m_okTopComb.clear();
  m_theTopComb.clear();
  float minMassDiffSoFar = 9999999;
  int nbrWComb = m_okWComb.size();
  int nbrBJets = m_okBJets.size();
  //Loop over all WCombinations
  for (int iWComb = 0; iWComb < nbrWComb; iWComb++) {
    //For all WCombination loop over all BJets and make combinations
    for (int iBJets = 0; iBJets < nbrBJets; iBJets++) {
      vector<TObjectClass > tempB2WComb = m_okWComb[iWComb];
      tempB2WComb.push_back(m_okBJets[iBJets]);
      float currentMassDiff = fabs(m_anInvMassCalc->InvMass(tempB2WComb) - m_topMass);
      //If the inv mass of this B2WCombination is ok, save it
      if (currentMassDiff < m_allowedTopMassDiff) {
	m_okTopComb.push_back(tempB2WComb);
	//In Jet Veto cut we need to know all left over jets,
	//i.e. those that was not in the Top Combination, that's
	//why we need to decide THE Top Combination
	if (currentMassDiff < minMassDiffSoFar) {
	  minMassDiffSoFar = currentMassDiff;
	  m_theTopComb = tempB2WComb;
	}
      }
    }
  }
  if (m_okTopComb.size() > 0) {
    //Save all the left over jets to use in the jetCut later
    m_theLeftOverJets.clear();
    int nbrOkJets = m_okJets.size();
    for (int i = 0; i < nbrOkJets; i++) {
      if ((m_okJets[i].GetId() != m_theTopComb[0].GetId())&&
	  (m_okJets[i].GetId() != m_theTopComb[1].GetId())&&
	  (m_okJets[i].GetId() != m_theTopComb[2].GetId())) {
 	m_theLeftOverJets.push_back(m_okJets[i]);
      }
    }
  }
  return (m_okTopComb.size() > 0);
}

bool TTreeCut::Select3TopJets() {
  m_theTopComb.clear();
  int nbrOkJets = m_okJets.size();
  //If there are exactly 3 jets then these are the top jets
  if (nbrOkJets == 3) {
    m_theTopComb = m_okJets;
    return (fabs(m_anInvMassCalc->InvMass(m_theTopComb) - m_topMass) < m_allowedTopMassDiff);
  }
  float lowestMassDiffSoFar = 100000000.;
  int choosedFirstJet = -1;
  int choosedSecondJet = -1;
  int choosedThirdJet= -1;
  //Otherwice minimice m_jjj - m_top by trying all possible 3jets compositions
  for (int i = 0; i < nbrOkJets; i++) {
    for (int j = i+1; j < nbrOkJets; j++) {
      for (int k = j+1; k < nbrOkJets; k++) {
	vector<TObjectClass > temp3TComb;
	temp3TComb.push_back(m_okJets[i]);
	temp3TComb.push_back(m_okJets[j]);
	temp3TComb.push_back(m_okJets[k]);
	//If the inv mass of this 3TCombination is the best so far, save it
	if (fabs(m_anInvMassCalc->InvMass(temp3TComb) - m_topMass) < lowestMassDiffSoFar) {
	  m_theTopComb.clear();
	  m_theTopComb = temp3TComb;
	  lowestMassDiffSoFar = fabs(m_anInvMassCalc->InvMass(m_theTopComb) - m_topMass);
	  //Save the choosed jets to not be saved in leftOver jets later
	  choosedFirstJet = i;
	  choosedSecondJet = j;
	  choosedThirdJet = k;
	}
      }
    }
  }
  if (lowestMassDiffSoFar < m_allowedTopMassDiff) {
    //Save all the left over jets to use in the jetCut later
    m_theLeftOverJets.clear();
    for (int i = 0; i < nbrOkJets; i++) {
      if ((i != choosedFirstJet)&&(i != choosedSecondJet)&&(i != choosedThirdJet)) {
	m_theLeftOverJets.push_back(m_okJets[i]);
      }
    }
  }

  //Temp
  //An extra test to check that no Top Jets are among the Left Over jets
  if (lowestMassDiffSoFar < m_allowedTopMassDiff) {
    int nbrLeftOverJets = m_theLeftOverJets.size();
    for (int i = 0; i < nbrLeftOverJets; i++) {
      if ((m_theLeftOverJets[i].GetId() == m_theTopComb[0].GetId())||
	  (m_theLeftOverJets[i].GetId() == m_theTopComb[1].GetId())||
	  (m_theLeftOverJets[i].GetId() == m_theTopComb[2].GetId())) {
	cout<<"ERROR in TTreeCut::Select3TopJets, Top jets among Left overs, Exit!"<<endl;
	cout<<"left over jet id = "<<m_theLeftOverJets[i].GetId()
	    <<" first top jet id = "<<m_theTopComb[0].GetId()
	    <<" second top jet id = "<<m_theTopComb[1].GetId()
	    <<" third top jet id = "<<m_theTopComb[2].GetId()<<endl;
	exit(0);
      }
    }
  }

  //Test if the invariant mass of the three found jets are close enough to the top mass
  return (lowestMassDiffSoFar < m_allowedTopMassDiff);
}

bool TTreeCut::Select2WJets() {
  m_theWComb.clear();
  int nbrTopJets = m_theTopComb.size();
  float lowestMassDiffSoFar = 100000000.;
  int choosedFirstJet = -1;
  int choosedSecondJet = -1;
  //Minimice m_jj - m_W by trying all possible 2jets compositions
  for (int i = 0; i < nbrTopJets; i++) {
    for (int j = i+1; j < nbrTopJets; j++) {
      vector<TObjectClass > temp2WComb;
      temp2WComb.push_back(m_theTopComb[i]);
      temp2WComb.push_back(m_theTopComb[j]);
      if (fabs(m_anInvMassCalc->InvMass(temp2WComb) - m_wMass) < lowestMassDiffSoFar) {
	m_theWComb.clear();
	m_theWComb = temp2WComb;
	lowestMassDiffSoFar = fabs(m_anInvMassCalc->InvMass(m_theWComb) - m_wMass);
	//Save the choosed jets to not be saved as a b jet later
	choosedFirstJet = i;
	choosedSecondJet = j;
      }  
    }
  }
  //The third jet could be the B-jet. Save this in m_theBJet 
  for (int i = 0; i < nbrTopJets; i++) {
    if ((i != choosedFirstJet)&&(i != choosedSecondJet)) {
      m_theBJet = m_theTopComb[i];
    }
  }
  
  //Test if the invariant mass of the two found jets are close enough to the W mass
  return (lowestMassDiffSoFar < m_allowedWMassDiff);
}
