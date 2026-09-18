# include <iostream>
# include "TDecayObject.h"

TDecayObject::TDecayObject() {
  m_decayList.clear();
  m_diffProdPdgs.clear();
}

TDecayObject::TDecayObject(int pdg) {
  m_pdg = pdg;
  m_decayList.clear();
  m_diffProdPdgs.clear();
}

TDecayObject::~TDecayObject() {
  m_pdg = 0;
  m_decayList.clear();
  m_diffProdPdgs.clear();
}

void TDecayObject::SetPdg(int pdg) {
  m_pdg = pdg;
}

void TDecayObject::AddDecayChannel(TDecayChannel newChannel) {
  m_decayList.push_back(newChannel);
  for (int i = 0; i < newChannel.GetNbrDecayProducts(); i++) {
    AddProdPdg(newChannel.GetPDGOfDecayProductNbr(i));
  }
}

void TDecayObject::AddDecayChannel(int pdg1, int pdg2, float br, float effBr) {
  TDecayChannel aChannel;
  aChannel.AddProdBrAndEffBr(pdg1, pdg2, br, effBr);
  m_decayList.push_back(aChannel);
  AddProdPdg(pdg1);
  AddProdPdg(pdg2);
}

void TDecayObject::AddDecayChannel(int pdg1, int pdg2, int pdg3, float br, float effBr) {
  TDecayChannel aChannel;
  aChannel.AddProdBrAndEffBr(pdg1, pdg2, pdg3, br, effBr);
  m_decayList.push_back(aChannel);
  AddProdPdg(pdg1);
  AddProdPdg(pdg2);
  AddProdPdg(pdg3);
}

void TDecayObject::AddProdPdg(int pdg) {
  if (!OnePossibleDecayProduct(pdg)) {
    m_diffProdPdgs.push_back(pdg);
  }
}

int TDecayObject::GetPdg() {
  return m_pdg;
}

int TDecayObject::GetNbrDecayChannels() {
  return m_decayList.size();
}

int TDecayObject::GetNbrDifferentDecayProducts() {
  return m_diffProdPdgs.size();
}

TDecayChannel TDecayObject::GetDecayChannelNbr(int nbr) {
  if ((nbr < 0)||(nbr >= int(m_decayList.size()))) {
    cout<<"ERROR in TDecayChannel::GetDecayChannelNbr, nbr is exceeding size, Exit!"<<endl;
    exit(1);
  }
  return m_decayList[nbr];
}

int TDecayObject::GetPdgOfDecayProductNbr(int nbr) {
  if ((nbr < 0)||(nbr >= int(m_diffProdPdgs.size()))) {
    cout<<"ERROR in TDecayChannel::GetDecayProductNbr, nbr is exceeding size, Exit!"<<endl;
    exit(1);
  }
  return m_diffProdPdgs[nbr];
}

bool TDecayObject::IsStabile() {
  return (m_decayList.size() == 0);
}

void TDecayObject::MakeStabile() {
  m_decayList.clear();
  m_diffProdPdgs.clear();
}

void TDecayObject::Clear() {
  m_pdg = 0;
  m_decayList.clear();
  m_diffProdPdgs.clear();
}

void TDecayObject::Replace(TDecayObject newObject) {
  this->Clear();
  m_pdg = newObject.GetPdg();
  for (int i = 0; i < newObject.GetNbrDecayChannels(); i++) {
    this->AddDecayChannel(newObject.GetDecayChannelNbr(i));
  }
}

bool TDecayObject::OnePossibleDecayProduct(int pdg) {
  for (unsigned int i = 0; i < m_diffProdPdgs.size(); i++) {
    if (pdg == m_diffProdPdgs[i]) return true; 
  }
  return false;
}

bool TDecayObject::IsASMParticle() {
  return ((abs(m_pdg) == m_pdgConverter.GetPdgFromString("d"))||
      	  (abs(m_pdg) == m_pdgConverter.GetPdgFromString("u"))||
      	  (abs(m_pdg) == m_pdgConverter.GetPdgFromString("s"))||
	  (abs(m_pdg) == m_pdgConverter.GetPdgFromString("c"))||
      	  (abs(m_pdg) == m_pdgConverter.GetPdgFromString("b"))||
      	  (abs(m_pdg) == m_pdgConverter.GetPdgFromString("t"))||
	  (abs(m_pdg) == m_pdgConverter.GetPdgFromString("e-"))||
      	  (abs(m_pdg) == m_pdgConverter.GetPdgFromString("nu_e"))||
      	  (abs(m_pdg) == m_pdgConverter.GetPdgFromString("mu-"))||
	  (abs(m_pdg) == m_pdgConverter.GetPdgFromString("nu_mu"))||
      	  (abs(m_pdg) == m_pdgConverter.GetPdgFromString("tau-"))||
      	  (abs(m_pdg) == m_pdgConverter.GetPdgFromString("nu_tau"))||
	  (abs(m_pdg) == m_pdgConverter.GetPdgFromString("g"))||
	  (abs(m_pdg) == m_pdgConverter.GetPdgFromString("gamma"))|
	  (abs(m_pdg) == m_pdgConverter.GetPdgFromString("pi0"))||
	  (abs(m_pdg) == m_pdgConverter.GetPdgFromString("pi+"))||
	  (abs(m_pdg) == m_pdgConverter.GetPdgFromString("H+"))||
      	  (abs(m_pdg) == m_pdgConverter.GetPdgFromString("Z0"))||
      	  (abs(m_pdg) == m_pdgConverter.GetPdgFromString("W+")));
}
