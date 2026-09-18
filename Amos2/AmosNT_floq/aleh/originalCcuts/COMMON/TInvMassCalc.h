#ifndef TINVMASSCALC_H
#define TINVMASSCALC_H

#include <vector>
#include "TObjectClass.h"

class TInvMassCalc{
 public:
  TInvMassCalc();
  ~TInvMassCalc();
  float InvMass(TObjectClass obj);
  float InvMass(vector<TObjectClass > objs);
};

#endif
