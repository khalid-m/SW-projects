#ifndef TASSIGNMENT_H
#define TASSIGNMENT_H
#include <iostream>
#include <vector>
#include "TLorentzVector.h"
#include "TObjectClass.h"

class TAssignment{
 public:
  TAssignment();
  ~TAssignment();
  vector<int> AssignJetsToTwoPartons(vector<TObjectClass> partons, vector<TObjectClass> jets, float maxDeltaR);
  vector<int> AssignJetsToThreePartons(vector<TObjectClass> partons, vector<TObjectClass> jets, float maxDeltaR);
  
 private:
  void FillDeltaRMatrix(vector<TObjectClass> partons, vector<TObjectClass> jets);
  vector<vector<float> > m_deltaRMatrix;
};

#endif
