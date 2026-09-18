# include <cmath>
# include <iostream>
# include "TObjectClass.h"

TObjectClass::TObjectClass() {
  cout<<"TObjectClass::TObjectClass() called"<<endl;
  m_id = 0;
  m_pdg = 0;
  m_fourMom.SetPxPyPzE(1., 1., 1., 1.);
  m_isAStatus3Particle = false;
  m_idOriginDefined = false;
  m_pdgOriginDefined = false;
}


TObjectClass::TObjectClass(int id, int pdg, float px, float py, float pz, float energy) {
  m_id = id;
  m_pdg = pdg;
  m_fourMom.SetPxPyPzE(px, py, pz, energy);
  m_isAStatus3Particle = false;
}

TObjectClass::TObjectClass(int id, int pdg, float px, float py, float pz, float energy,
			   int bar, int status, int barMother, int pdgMother) {
  m_id = id;
  m_pdg = pdg;
  m_fourMom.SetPxPyPzE(px, py, pz, energy);
  m_isAStatus3Particle = true;
  m_bar = bar;
  m_status = status;
  m_barMother = barMother;
  m_pdgMother = pdgMother;
}

TObjectClass::~TObjectClass() {
}

void TObjectClass::SetAllValues(int id, int pdg, float px, float py, float pz, float energy) {
  m_id = id;
  m_pdg = pdg;
  m_fourMom.SetPxPyPzE(px, py, pz, energy);
  m_isAStatus3Particle = false;
}

void TObjectClass::SetAllValues(int id, int pdg, float px, float py, float pz, float energy,
				int bar, int status, int barMother, int pdgMother) {
  m_id = id;
  m_pdg = pdg;
  m_fourMom.SetPxPyPzE(px, py, pz, energy);
  m_isAStatus3Particle = true;
  m_bar = bar;
  m_status = status;
  m_barMother = barMother;
  m_pdgMother = pdgMother;
}

// TObjectClass & TObjectClass::operator = (const TObjectClass & obj) {
//   m_pdg = obj.GetPdg();
//   m_fourMom.SetPxPyPzE(obj.Px(), obj.Py(), obj.Pz(), obj.E());
//   m_isAStatus3Particle = obj.IsAStatus3Particle();
//   m_bar = obj.GetBarCode();
//   m_status = obj.GetStatus();
//   m_barMother = obj.GetBarCodeForMother();
//   m_pdgMother = obj.GetStatusForMother();
//   return *this;
// }

// bool TObjectClass::operator == (const TObjectClass & obj) const {
//   return ((GetId() == obj.GetId())&&(GetPdg() == obj.GetPdg()));
// }

float TObjectClass::Px() {
  return m_fourMom.Px();
}

float TObjectClass::Py() {
  return m_fourMom.Py();
}

float TObjectClass::Pz() {
  return m_fourMom.Pz();
}

float TObjectClass::E() {
  return m_fourMom.E();
}

float TObjectClass::Pt() {
  return m_fourMom.Pt();
}

float TObjectClass::Eta() {
  return m_fourMom.Eta();
}

float TObjectClass::DeltaR(TObjectClass obj) {
  return m_fourMom.DeltaR(obj.FourMom());
}

TLorentzVector TObjectClass:: FourMom() {
  return m_fourMom;
}

int TObjectClass::GetId() {
  return m_id;
};

int TObjectClass::GetPdg() {
  return m_pdg;
};

int TObjectClass::GetBarCode() {
  if (!m_isAStatus3Particle) {
    cout<<"ERROR in TObjectClass::GetBarCode, this "
	<<"is no 3Status particle, Exit!"<<endl;
    exit(1);
  }
  return m_bar;
};

int TObjectClass::GetStatus() {
  if (!m_isAStatus3Particle) {
    cout<<"ERROR in TObjectClass::GetBarCode, this "
	<<"is no 3Status particle, Exit!"<<endl;
    exit(1);
  }
  return m_status;
};


int TObjectClass::GetBarCodeForMother() {
  if (!m_isAStatus3Particle) {
    cout<<"ERROR in TObjectClass::GetBarCode, this "
	<<"is no 3Status particle, Exit!"<<endl;
    exit(1);
  }
  return m_barMother;
};

int TObjectClass::GetPdgForMother() {
  if (!m_isAStatus3Particle) {
    cout<<"ERROR in TObjectClass::GetBarCode, this "
	<<"is no 3Status particle, Exit!"<<endl;
    exit(1);
  }
  return m_pdgMother;
};

bool TObjectClass::IsAStatus3Particle() {
  return m_isAStatus3Particle;
}

void TObjectClass::SetIdForOrigin(int id) {
  m_idOriginDefined = true;
  m_idOrigin = id;
};

int TObjectClass::GetIdForOrigin() {
  if (!m_idOriginDefined) {
    cout<<"ERROR in TObjectClass::GetIdForOrigin, not def, Exit!"<<endl;
    exit(1);
  }
  return m_idOrigin;
};

void TObjectClass::SetPdgForOrigin(int pdg) {
  m_pdgOriginDefined = true;
  m_pdgOrigin = pdg;
};

int TObjectClass::GetPdgForOrigin() {
  if (!m_pdgOriginDefined) {
    cout<<"ERROR in TObjectClass::GetPdgForOrigin, not def, Exit!"<<endl;
    exit(1);
  }
  return m_pdgOrigin;
};

string TObjectClass::GetName() {
  return GetNameFromPdg(m_pdg);
}

string TObjectClass::GetMotherName() {
  if (m_pdgMother == 0) return "-";
  return GetNameFromPdg(m_pdgMother);
}

string TObjectClass::GetNameFromPdg(int pdg) {
  string s;
  if      (pdg ==  1)       { s = "d";}
  else if (pdg == -1)       { s = "dbar";}
  else if (pdg ==  2)       { s = "u";}
  else if (pdg == -2)       { s = "ubar";}
  else if (pdg ==  3)       { s = "s";}
  else if (pdg == -3)       { s = "sbar";}
  else if (pdg ==  4)       { s = "c";}
  else if (pdg == -4)       { s = "cbar";}
  else if (pdg ==  5)       { s = "b";}
  else if (pdg == -5)       { s = "bbar";}
  else if (pdg ==  6)       { s = "t";}
  else if (pdg == -6)       { s = "tbar";}
  else if (pdg ==  11)      { s = "e-";}
  else if (pdg == -11)      { s = "e+";}
  else if (pdg ==  12)      { s = "nye";}
  else if (pdg == -12)      { s = "nyebar";}
  else if (pdg ==  13)      { s = "my+";}
  else if (pdg == -13)      { s = "my-";}
  else if (pdg ==  14)      { s = "nymy";}
  else if (pdg == -14)      { s = "nymybar";}
  else if (pdg ==  15)      { s = "tau+";}
  else if (pdg == -15)      { s = "tau-";}
  else if (pdg ==  16)      { s = "nytau";}
  else if (pdg == -16)      { s = "nytaubar";}
  else if (pdg ==  21)      { s = "g";}
  else if (pdg ==  22)      { s = "gamma";}
  else if (pdg ==  23)      { s = "Z0";}
  else if (pdg ==  24)      { s = "W+";}
  else if (pdg == -24)      { s = "W-";}
  else if (pdg ==  25)      { s = "H0";}
  else if (pdg ==  37)      { s = "H+";}
  else if (pdg == -37)      { s = "H-";}
  else if (pdg ==  51)      { s = "??";}
  else if (pdg ==  441)     { s = "ETA_C";}
  else if (pdg ==  443)     { s = "JPSI";}
  else if (pdg ==  445)     { s = "CHI_C2";}
  else if (pdg ==  511)     { s = "B_D0";}
  else if (pdg == -511)     { s = "B_D0bar";}
  else if (pdg ==  521)     { s = "B+";}
  else if (pdg == -521)     { s = "B-";}
  else if (pdg ==  531)     { s = "B_S0";}
  else if (pdg == -531)     { s = "B_S0bar";}
  else if (pdg ==  2101)    { s = "ud0";}
  else if (pdg ==  2203)    { s = "uu1";}
  else if (pdg ==  2212)    { s = "p";}
  else if (pdg == -2212)    { s = "pbar";}
  else if (pdg ==  2112)    { s = "n";}
  else if (pdg == -2112)    { s = "nbar";}
  else if (pdg ==  5122)    { s = "lambda_b0";}
  else if (pdg ==  5222)    { s = "sigma_b+";}
  else if (pdg ==  10441)   { s = "CHI_C1";}
  else if (pdg ==  20433)   { s = "DH_S1+";}
  else if (pdg ==  20443)   { s = "PSID";}
  else if (pdg ==  100443)  { s = "PSI2S";}
  else if (pdg ==  1000011) { s = "seL-";}
  else if (pdg == -1000011) { s = "seL+";}
  else if (pdg ==  1000012) { s = "sneL";}
  else if (pdg == -1000012) { s = "sneLbar";}
  else if (pdg ==  1000013) { s = "smyL-";}
  else if (pdg == -1000013) { s = "smyL+";}
  else if (pdg ==  1000014) { s = "snmyL";}
  else if (pdg == -1000014) { s = "snmyLbar";}
  else if (pdg ==  1000015) { s = "stau1-";}
  else if (pdg == -1000015) { s = "stau1+";}
  else if (pdg ==  1000016) { s = "sntauL";}
  else if (pdg == -1000016) { s = "sntauLbar";}
  else if (pdg ==  2000011) { s = "seR-";}
  else if (pdg == -2000011) { s = "seR+";}
  else if (pdg ==  2000013) { s = "smyR-";}
  else if (pdg == -2000013) { s = "smyR+";}
  else if (pdg ==  2000015) { s = "stau2-";}
  else if (pdg == -2000015) { s = "stau2+";}
  else if (pdg ==  1000021) { s = "sg";}
  else if (pdg ==  1000022) { s = "chi01";}
  else if (pdg ==  1000023) { s = "chi02";}
  else if (pdg ==  1000024) { s = "chi+1";}
  else if (pdg == -1000024) { s = "chi-1";}
  else if (pdg ==  1000025) { s = "chi03";}
  else if (pdg ==  1000035) { s = "chi04";}
  else if (pdg ==  1000037) { s = "chi+2";}
  else if (pdg == -1000037) { s = "chi-2";}
  else { 
    cout<<"ERROR: TObjectClass::GetName(), This pdg code "<<pdg<<" was not implemented. Exit!"<<endl;
    exit(1);
  }
  return s;
}
