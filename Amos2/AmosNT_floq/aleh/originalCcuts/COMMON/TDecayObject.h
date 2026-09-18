///////////////////////////////////////////////////////////
// # TDecayObject - is a particle (identified by its PDG)
// # that knows all its decays and branching ratios
///////////////////////////////////////////////////////////
#ifndef TDecayObject_h
#define TDecayObject_h
#include <vector>
#include "TParticleCodeConverter.h"
#include "TDecayChannel.h"

using namespace std;

class TDecayObject {

 public:
  TDecayObject();
  TDecayObject(int pdg);
  ~TDecayObject();

  void SetPdg(int pdg);
  void AddDecayChannel(TDecayChannel newChannel);
  void AddDecayChannel(int pdg1, int pdg2, float br, float effBr);
  void AddDecayChannel(int pdg1, int pdg2, int pdg3, float br, float effBr);
  void AddProdPdg(int pdg);
  void Clear();
  void Replace(TDecayObject newObject);

  int GetPdg();
  int GetNbrDecayChannels();
  int GetNbrDifferentDecayProducts();
  TDecayChannel GetDecayChannelNbr(int channelNbr);
  int GetPdgOfDecayProductNbr(int prodNbr);

  bool IsASMParticle();
  bool IsStabile();
  void MakeStabile();
  bool OnePossibleDecayProduct(int pdg);  

 private:
  int m_pdg;
  vector<TDecayChannel > m_decayList;
  vector<int > m_diffProdPdgs;
  TParticleCodeConverter m_pdgConverter;
};

#endif // #ifdef TDecayObject_h
