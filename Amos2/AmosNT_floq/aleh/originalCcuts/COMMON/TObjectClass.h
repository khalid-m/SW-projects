///////////////////////////////////////////////////////////
// # TObjectClass - can be any object red in from the Tree
// # like electron, muon, jet, parton ... and so on...
///////////////////////////////////////////////////////////
#ifndef TObjectClass_h
#define TObjectClass_h
#include <string>
#include "TChain.h"
#include "TTreeClass.h"
#include "TLorentzVector.h"

using namespace std;

class TObjectClass {

 public:
  TObjectClass();
  TObjectClass(int id, int pdg, float px, float py, float pz, float energy);
  TObjectClass(int id, int pdg, float px, float py, float pz, float energy,
	       int bar, int status, int barMother, int pdgMother);
  ~TObjectClass();

  void SetAllValues(int id, int pdg, float px, float py, float pz, float energy);
  void SetAllValues(int id, int pdg, float px, float py, float pz, float energy,
		    int bar, int status, int barMother, int pdgMother);


  //TObjectClass & operator = (const TObjectClass &);
  //bool operator == (const TObjectClass &) const;

  float Px();
  float Py();
  float Pz();
  float E();
  float Pt();
  float Eta();
  float DeltaR(TObjectClass obj);

  TLorentzVector FourMom();

  int GetId();
  int GetPdg();
  int GetBarCode();
  int GetStatus();
  int GetBarCodeForMother();
  int GetPdgForMother();
  bool IsAStatus3Particle();
  void SetIdForOrigin(int id); //User can define 'origin'
  int GetIdForOrigin();
  void SetPdgForOrigin(int pdg);
  int GetPdgForOrigin();
  
  string GetName();  //Using Pdg to return a particle name e.g. -24 --> W- and so on...
  string GetMotherName(); 

 private:
  TLorentzVector m_fourMom;
  int m_id;
  int m_pdg;
  int m_bar;
  int m_status;
  int m_barMother;
  int m_pdgMother;
  int m_idOrigin;
  int m_pdgOrigin;
  bool m_isAStatus3Particle;
  bool m_idOriginDefined;
  bool m_pdgOriginDefined;
  string GetNameFromPdg(int pdg);
};

#endif // #ifdef TObjectClass_h
