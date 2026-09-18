/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Johan Tysklind, Ruslan Fomkin
 * $RCSfile: helpfunction.h,v $
 * $Revision: 1.8 $ $Date: 2007/11/09 15:08:55 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Includes all files that is needed, and also the structures 
 * that are needed for implementing ROOT wrapper of data stored in TTree 
 * objects.
 ****************************************************************************/


#ifndef	_helpfunction_h_
#define	_helpfunction_h_


#include<sys/types.h>
#include<stdlib.h>
#include<string.h>
#include<stdio.h>
#include<errno.h>
#include<math.h>
#include<float.h>


#include <iostream>
#include <map>
#include <string>
#include <vector>

#include <TFile.h>
#include <TTree.h>
#include <TLeaf.h>
#include <TLeafObject.h>
#include <TObjArray.h>
#include <TObject.h>
#include <TKey.h>
#include <TDirectory.h>
#include <TLeafB.h>
#include <TLeafC.h>
#include <TLeafI.h>
#include <TLeafF.h>
#include <TLeafS.h>
#include <TLeafD.h>
#include <TLeafElement.h>

#include "../../C/callout.h"
#include "C/structs.h"
#include "C/aleh_udfs.h"

/**
 * Constants defining types of attributes
 */
#define MAX_ROOT_HANDLE  100
#define VECTOR 0
#define INTEGER 1
#define REAL 2
#define CHARSTRING 3
#define ELEMENT 4
#define UNKNOWN 5

using namespace std;

// all rest definitions are made by Ruslan Fomkin

/**
 * Structure for storing information about an attribute
 * such as its name and type defined by integer constants
 */
typedef struct{
	string name;
	int type;
} Attribute;

/**
 * Vector (array) for storing set of attributes belongs to the same
 * object (data).
 */
typedef vector<Attribute> Attributes;

/**
 * Class to store refernce to TTree object and vector of attributes of
 * the object.
 */
class Table{
	TTree* tree;
	Attributes* attrs;
	int key_attr;
public:
	TTree* getTree() const;
	Attributes* getAttrs() const;
	int getKey() const;
	int getAttrPosition(string);
	Table(TFile*,string,string);
	~Table();
};

/**
 * Mapping between name of a TTree object stored in particulaer file
 * under particular directory and the corresponding Table object.
 */
typedef map<string,Table*> Tables;

/**
 * Mapping between name of a path in particular file and
 * underling TTree objects.
 */
typedef map<string,Tables*> Directories;

/**
 * Class to store reference to opened ROOT file and underlying pathes.
 */
class File{
	TFile* file;
	Directories* dirs;
public:
	TFile* getFile() const;
	Directories* getDirs() const;
	File(string);
	~File();
};

/**
 * Mapping between file names and ROOT files.
 */
typedef map<string,File*> Files;


#endif /* _bk_helpfunc_h */
