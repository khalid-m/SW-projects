#ifndef TTreeCut_h
#define TTreeCut_h
#include <vector>
#include <list>
#include <string>
#include <iostream>
#include <fstream>
#include "TH1.h"
#include "TH2.h"
#include "TChain.h"
#include "TLorentzVector.h"
#include "../COMMON/TTreeClass.h"
#include "../COMMON/TObjectClass.h"
#include "../COMMON/TInvMassCalc.h"
class Parameters;

using namespace std;

//A list of combinations  
typedef vector<vector<TObjectClass > > TCombinationCollection;


class TTreeCut {

 public:
  TTreeCut();
  ~TTreeCut();
  void Loop();
  
 private:
  void InitLoop();
  void CutEvent(Int_t eventNbr);
  void OriginalCutEvent(Int_t eventNbr);
  void OptimizedCutEvent(Int_t eventNbr);
  void ExpensiveCutEvent(Int_t eventNbr);
  bool ThreeLeptonCut();
  bool ZVetoCut();
  bool HadrTopCut();
  bool BTagCut();
  bool JetVetoCut();
  bool OtherCuts();
  
  bool SelectOkJets();

  //Nils' way:
  bool Select2WCombinations();
  bool SeperateBJets();
  bool SelectTopCombination();

  //Paper's way:
  bool Select3TopJets();
  bool Select2WJets();
  bool TestTheBJet();

  float AbsV(float x);

  TInvMassCalc* m_anInvMassCalc;

  TChain* m_testChain;

  TTreeClass* m_theTree;
  TChain* m_theTreeChain;
  vector<TObjectClass > m_isolatedLeptons;
  vector<TObjectClass > m_okJets;
  vector<TObjectClass > m_okBJets;
  vector<TObjectClass > m_okWJets;
  TCombinationCollection m_okWComb;
  TCombinationCollection m_okTopComb;
  vector<TObjectClass > m_theTopComb;
  vector<TObjectClass > m_theWComb;
  vector<TObjectClass > m_theLeftOverJets;
  TObjectClass m_theBJet;

  string m_mcString;
  float m_br;

  Parameters* m_parameters;
  int m_nbrOkSimEvents;
  int m_nbrSurvived3lCut;
  int m_nbrSurvivedZVetoCut;
  int m_nbrSurvivedHadrTopCut;
  int m_nbrSurvivedBTagCut;
  int m_nbrSurvivedJetCut;
  int m_typeOfProcess;
  int m_typeOfMCGenerator;
  int m_nbrOfEventsToAnalyse;
  float m_luminosity;
  float m_minPtOfTheHardestLepton;
  float m_minPtOfAllThreeLeptons;
  float m_etaRangeForAllThreeLeptons;
  int m_printEventNbr;
  int m_printEvery100000EventNbr;
  int m_printNbrLeptons;
  float m_eventWeight;
  int m_totNbrSimEvents;
  float m_totNbrObsEvents;
  float m_etaRangeForJets;
  float m_minPtForJets;
  float m_topMass;
  float m_allowedTopMassDiff;
  float m_wMass;
  float m_allowedWMassDiff;
  float m_zMass;
  float m_minimumZMassDiff;
  float m_maxAllowedPtForOtherJets;
  float m_maxPtForAllThreeIsolatedLeptons;
  float m_maxPtForTheSoftestIsolatedLepton;
  float m_minMissingTransverseEnergy;
  float m_maxAllowedEffectiveMass;
  int m_theIntegerForBTaggedJet;
  int m_topCutType;
  float m_tanBeta;
  float m_mA;
  float m_m2;
  float m_mu;
  int m_biggerStauMass;
  bool m_partition;
  
  ofstream outfile;
};

#endif // #ifdef TTreeCut_h
