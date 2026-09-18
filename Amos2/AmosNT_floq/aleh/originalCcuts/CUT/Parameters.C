
# include "Parameters.h"

Parameters* Parameters::pParameters = NULL;

Parameters::Parameters() {
  ReadInputFile("management");
  
  if (GetParameterAsInteger("PrintListOfParameters"))
    PrintListOfParameters();
}


Parameters::~Parameters() {
}

void Parameters::ReadInputFile(string fileName) {
  ifstream inputFile(fileName.c_str(), ios::in);
  
  if (!inputFile) {
    cerr << endl;
    cerr << "***** TRTParameters::ReadInputFile *****" << endl;
    cerr << "Cannot open input file '" << fileName << "'. Exit!" << endl;
    exit(1);
  }
  
  int inputState = 0;
  string inputString;
  string parameterName;
  double parameterValue;

  while (inputFile >> inputString) {
    if (inputState == 0) {
      if (inputString == "<")
        inputState = 1;
    }
    else if (inputState == 1) {
      parameterName = inputString;
      inputState = 2;
    }
    else if (inputState == 2) {
      if (inputString == "=")
        inputState = 3;
      else {
        cerr << endl;
        cerr << "***** TRTParameters::ReadInputFile *****" << endl;
        cerr << "Input file '" << fileName << "'. Last parameter '"
	     << parameterName << "'." << endl;
        cerr << "Cannot find symbol '='. Exit!" << endl << endl;
        exit(1);
      }
    }
    else if (inputState == 3) {
      if (inputString == ">")
        inputState = 0;
      else if (inputString == "<") {
        cerr << endl;
        cerr << "***** TRTParameters::ReadInputFile *****" << endl;
        cerr << "Input file '" << fileName << "'. Last parameter '"
	     << parameterName << "'." << endl;
        cerr << "Unexpected symbol '<'. Exit!" << endl << endl;
        exit(1);
      }
      else {
        parameterValue = atof(inputString.c_str());
        multimapOfParameters.insert(make_pair(parameterName, parameterValue));
      }
    }
  }
  
  if (inputState != 0) {
    cerr << endl;
    cerr << "***** TRTParameters::ReadInputFile *****" << endl;
    cerr << "Input file '" << fileName << "'. Last parameter '"
	 << parameterName << "'." << endl;
    cerr << "Cannot find symbol '>' at the end of file. Exit!" << endl;    
    exit(1);
  }  
  inputFile.close();
}


void Parameters::PrintListOfParameters() {
  cout << endl;
  cout << "***** TRTParameters::PrintListOfParameters *****" << endl;
  cout << "List of parameters:" << endl;
  
  for (multimapIterator i = multimapOfParameters.begin();
       i != multimapOfParameters.end(); i++)
    cout << "  " << (*i).first << " = " << (*i).second << endl;
  cout << endl;
}


int Parameters::GetParameterAsInteger(string parameterName) {
  int numberOfItems = multimapOfParameters.count(parameterName);
  
  if (numberOfItems == 1) {
    multimapIterator i = multimapOfParameters.find(parameterName);
    int parameterValue = (int) ((*i).second);
    return parameterValue;
  }
  else if (numberOfItems == 0) {
    cerr << endl;
    cerr << "***** TRTParameters::GetParameterAsInteger *****" << endl;
    cerr << "Cannot find parameter '" << parameterName << "'. Exit!"
	 << endl << endl;
    exit(1);
  }
  else {
    cerr << endl;
    cerr << "***** TRTParameters::GetParameterAsInteger *****" << endl;
    cerr << "Parameter '" << parameterName << "' has " << numberOfItems
	 << " copies. Exit!" << endl << endl;
    exit(1);
  }
}


double Parameters::GetParameterAsDouble(string parameterName) {
  int numberOfItems = multimapOfParameters.count(parameterName);
  
  if (numberOfItems == 1) {
    multimapIterator i = multimapOfParameters.find(parameterName);
    double parameterValue = (*i).second;
    return parameterValue;
  }
  else if (numberOfItems == 0) {
    cerr << endl;
    cerr << "***** TRTParameters::GetParameterAsDouble *****" << endl;
    cerr << "Cannot find parameter '" << parameterName << "'. Exit!"
	 << endl << endl;
    exit(1);
  }
  else {
    cerr << endl;
    cerr << "***** TRTParameters::GetParameterAsDouble *****" << endl;
    cerr << "Parameter '" << parameterName << "' has " << numberOfItems
	 << " copies. Exit!" << endl << endl;
    exit(1);
  }
}

void Parameters::ClearMultimapOfParameters() {
  multimapOfParameters.clear();
  multimapOfParameters.~multimap();
}
