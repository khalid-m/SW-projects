///////////////////////////////////////////////////////////
// # TDecayChannel - is a channel that a TDecayObject can
// # decay with, and it knows the PDG codes of the decay
// # products, the branching ratio and its effective 
// # branching ratio
///////////////////////////////////////////////////////////
#ifndef TDecayChannel_h
#define TDecayChannel_h
#include <vector>

using namespace std;

class TDecayChannel {

 public:
  TDecayChannel();
  ~TDecayChannel();

  void AddProduct(int pdg);
  void AddBrAndEffBr(float br, float effBr);
  void SetBrAndEffBr(float br, float effBr);
  void AddProdBrAndEffBr(int pdg1, float br, float effBr);
  void AddProdBrAndEffBr(int pdg1, int pdg2, float br, float effBr);
  void AddProdBrAndEffBr(int pdg1, int pdg2, int pdg3, float br, float effBr);

  int GetNbrDecayProducts();
  int GetPDGOfDecayProductNbr(int nbr);
  float GetBr();
  float GetEffBr();

  bool IncludesProductWithPdg(int pdg);
 private:
  vector<int > m_decayProductsList; 
  float m_br;
  float m_effBr;
};

#endif // #ifdef TDecayChannel_h
