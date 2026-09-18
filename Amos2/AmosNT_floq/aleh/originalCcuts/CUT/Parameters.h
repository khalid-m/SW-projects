#ifndef Parameters_h
#define Parameters_h 
#include <iostream>
#include <string>
#include <fstream>
#include <map>

using namespace std;

class Parameters {
 public:
  ~Parameters();
  
  static Parameters* GetPointer() {
    if (!pParameters)
      pParameters = new Parameters();
    return pParameters;
  }
  
  int GetParameterAsInteger(string);
  double GetParameterAsDouble(string);
  
  void CheckParameterAsInteger(string, int);
  
  void ClearMultimapOfParameters();
  
 private:
  Parameters();
  
  void ReadInputFile(string);
  void PrintListOfParameters();
  
  multimap<string, double, less<string> > multimapOfParameters;
  typedef multimap<string, double, less<string> >::iterator
    multimapIterator;
  
  static Parameters* pParameters;
};

#endif
