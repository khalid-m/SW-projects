#include "TAssignment.h"

///////////////////////////////////////////////////////////////////////
//see: http://wwwasdoc.web.cern.ch/wwwasdoc/shortwrupsdir/h301/top.html
///////////////////////////////////////////////////////////////////////

TAssignment::TAssignment() {
}

TAssignment::~TAssignment() {
}

vector<int> TAssignment::AssignJetsToTwoPartons(vector<TObjectClass> partons, vector<TObjectClass> jets, float maxDeltaR) {
  int nbrPartons = partons.size();
  if (nbrPartons != 2) {
    cout<<"ERROR in TAssignment::AssignJetsToThreePartons, supposed to be 2 partons, Exit!"<<endl;
    exit(1);
  }
  FillDeltaRMatrix(partons, jets);
  vector<int> assignedJetsIds;
  assignedJetsIds.clear();
  int nbrJets = jets.size();
  //Minimize the sum of DeltaR for all parton-jet combinations
  float minDeltaRSumSoFar = 999999;
  for (int p1JetNbr = 0; p1JetNbr < nbrJets; p1JetNbr++) {
    for (int p2JetNbr = 0; p2JetNbr < nbrJets; p2JetNbr++) {
      if (p2JetNbr != p1JetNbr) {
	float deltaRSum = m_deltaRMatrix[0][p1JetNbr]+
	                  m_deltaRMatrix[1][p2JetNbr];
	if (deltaRSum < minDeltaRSumSoFar) {
	  minDeltaRSumSoFar = deltaRSum;
	  assignedJetsIds.clear();
	  assignedJetsIds.push_back(p1JetNbr);
	  assignedJetsIds.push_back(p2JetNbr);
	}
      }
    }
  }
  return assignedJetsIds;
}

vector<int> TAssignment::AssignJetsToThreePartons(vector<TObjectClass> partons, vector<TObjectClass> jets, float maxDeltaR) {
  int nbrPartons = partons.size();
  if (nbrPartons != 3) {
    cout<<"ERROR in TAssignment::AssignJetsToThreePartons, supposed to be 3 partons, Exit!"<<endl;
    exit(1);
  }
  FillDeltaRMatrix(partons, jets);
  vector<int> assignedJetsIds;
  assignedJetsIds.clear();
  int nbrJets = jets.size();
  //Minimize the sum of DeltaR for all parton-jet combinations
  float minDeltaRSumSoFar = 999999;
  for (int p1JetNbr = 0; p1JetNbr < nbrJets; p1JetNbr++) {
    for (int p2JetNbr = 0; p2JetNbr < nbrJets; p2JetNbr++) {
      if (p2JetNbr != p1JetNbr) {
	for (int p3JetNbr = 0; p3JetNbr < nbrJets; p3JetNbr++) {
	  if ((p3JetNbr != p1JetNbr)&&(p3JetNbr != p2JetNbr)) {
	    float deltaRSum = m_deltaRMatrix[0][p1JetNbr]+
	                      m_deltaRMatrix[1][p2JetNbr]+
	                      m_deltaRMatrix[2][p3JetNbr];
	    if (deltaRSum < minDeltaRSumSoFar) {
	      minDeltaRSumSoFar = deltaRSum;
	      assignedJetsIds.clear();
	      assignedJetsIds.push_back(p1JetNbr);
	      assignedJetsIds.push_back(p2JetNbr);
	      assignedJetsIds.push_back(p3JetNbr);
	    }
	  }
	}
      }
    }
  }
  return assignedJetsIds;
}

void TAssignment::FillDeltaRMatrix(vector<TObjectClass> partons, vector<TObjectClass> jets) {
  int nbrPartons = partons.size();
  int nbrJets = jets.size();
  if(nbrJets < nbrPartons){
    cout<<"ERROR in TAssignment::FillDeltaRMatrix, not enough jets, Exit!"<<endl;
    exit(1);
  }
  //Calculate a matrix with all DeltaR between all partons and all jets
  for (int partonNbr = 0; partonNbr < nbrPartons; partonNbr++) {
    vector<float> row;
    for (int jetNbr = 0; jetNbr < nbrJets; jetNbr++) {
      row.push_back(partons[partonNbr].DeltaR(jets[jetNbr]));
    }
    m_deltaRMatrix.push_back(row);    
  }
}
