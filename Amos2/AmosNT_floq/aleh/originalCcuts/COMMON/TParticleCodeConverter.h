///////////////////////////////////////////////////////////
// # TParticleCodeConverter - can be any object red in from the Tree
// # like electron, muon, jet, parton ... and so on...
///////////////////////////////////////////////////////////
#ifndef TParticleCodeConverter_h
#define TParticleCodeConverter_h
#include <string>

using namespace std;

class TParticleCodeConverter {

 public:
  TParticleCodeConverter();
  ~TParticleCodeConverter();

  string GetNameFromPdg(int pdg);
  string GetNameFromHerwigCode(int herwigCode);
  string GetNameFromIsaCode(int isaCode);
  int GetPdgFromHerwigCode(int herwigCode);
  int GetPdgFromIsaCode(int isaCode);
  int GetPdgFromString(string s);
 
 private:
  
  
};

#endif // #ifdef TParticleCodeConverter_h
