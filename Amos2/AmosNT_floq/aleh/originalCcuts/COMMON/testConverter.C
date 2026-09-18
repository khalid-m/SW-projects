# include <iostream>
# include "TParticleCodeConverter.h"

using namespace std;

int main() {

  TParticleCodeConverter* aConverterTest = new TParticleCodeConverter();
    
  char* testChar = "s";
  
  int testPdg = aConverterTest->GetPdgFromString(testChar);

  cout<<"testChar "<<testChar<<" testPdg "<<testPdg<<endl;

  delete aConverterTest; 

  cout<<"DONE WITH CONVERTER TEST"<<endl;
}
