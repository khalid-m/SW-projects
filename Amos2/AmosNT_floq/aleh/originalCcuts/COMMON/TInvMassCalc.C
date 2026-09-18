#include "TInvMassCalc.h"
#include "TVector3.h"
#include <algorithm>
#include <cmath>

TInvMassCalc::TInvMassCalc() {
}

TInvMassCalc::~TInvMassCalc() {
}

float TInvMassCalc::InvMass(TObjectClass obj) {
  float energy = obj.E();
  TVector3 momentum(obj.Px(),obj.Py(),obj.Pz());
  return sqrt(energy*energy - momentum*momentum); //inv mass
}

float TInvMassCalc::InvMass(vector<TObjectClass > objs) {
  float totEnergy = 0.;
  TVector3 totMomentum(0.,0.,0.);
  int nbrObjs = objs.size();
  for (int objNbr = 0; objNbr < nbrObjs; objNbr++) {
    totEnergy += objs[objNbr].E();
    TVector3 tempMomentum(objs[objNbr].Px(),objs[objNbr].Py(),objs[objNbr].Pz());
    totMomentum += tempMomentum;
  }
  return sqrt(totEnergy*totEnergy - totMomentum*totMomentum); //inv mass
}
