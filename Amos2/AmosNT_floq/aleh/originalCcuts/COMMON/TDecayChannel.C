# include <iostream>
# include "TDecayChannel.h"

TDecayChannel::TDecayChannel() {
  m_br    = 0;
  m_effBr = 0;
  m_decayProductsList.clear();
}

TDecayChannel::~TDecayChannel() {
  m_decayProductsList.clear();
}

void TDecayChannel::AddProduct(int pdg) {
  m_decayProductsList.push_back(pdg);
}

void TDecayChannel::AddBrAndEffBr(float br, float effBr) { 
  m_br += br;
  m_effBr += effBr;
}
  
void TDecayChannel::SetBrAndEffBr(float br, float effBr) {
  m_br = br;
  m_effBr = effBr;
}

void TDecayChannel::AddProdBrAndEffBr(int pdg1, float br, float effBr) {
  m_decayProductsList.push_back(pdg1);
  m_br += br;
  m_effBr += effBr;
}

void TDecayChannel::AddProdBrAndEffBr(int pdg1, int pdg2, float br, float effBr) {
  m_decayProductsList.push_back(pdg1);
  m_decayProductsList.push_back(pdg2);
  m_br += br;
  m_effBr += effBr;
}

void TDecayChannel::AddProdBrAndEffBr(int pdg1, int pdg2, int pdg3, float br, float effBr) {
  m_decayProductsList.push_back(pdg1);
  m_decayProductsList.push_back(pdg2);
  m_decayProductsList.push_back(pdg3);
  m_br += br;
  m_effBr += effBr;
}


int TDecayChannel::GetNbrDecayProducts() {
  return m_decayProductsList.size();
}

int TDecayChannel::GetPDGOfDecayProductNbr(int nbr) {
  if ((nbr < 0)||(nbr >= int(m_decayProductsList.size()))) {
    cout<<"ERROR in TDecayChannel::GetPDGOfDecayProductNbr, nbr is exceeding size, Exit!"<<endl;
    cout<<"nbr "<<nbr<<" m_decayProductsList.size() "<<m_decayProductsList.size()<<endl;
    exit(1);
  }
  return m_decayProductsList[nbr];
}

float TDecayChannel::GetBr() {
  return m_br;
}

float TDecayChannel::GetEffBr() {
  return m_effBr;
}

bool TDecayChannel::IncludesProductWithPdg(int pdg) {
  for (int i = 0; i < int(m_decayProductsList.size()); i++) {
    if (m_decayProductsList[i] == pdg) return true; 
  }
  return false;
}
