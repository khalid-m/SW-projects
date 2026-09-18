# include <iostream>
# include "TTreeCut.h"

using namespace std;

int main() {
  //gROOT->Reset();

  TTreeCut* aCut = new TTreeCut();
    
  aCut->Loop();

  delete aCut; 

  cout<<"DONE WITH TREE CUT"<<endl;
}
