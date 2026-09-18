/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Johan Tysklind, Ruslan Fomkin
 * $RCSfile: amain.cpp,v $
 * $Revision: 1.32 $ $Date: 2008/05/15 15:27:06 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Implementation of wrapper for ROOT files of TTree objects and
 * providing it to AMOS through foreign functions.
 * Functions for accessing and navigating structure of ROOT files can be utilized
 * in wrapper of data stored in different objects than TTree in ROOT files.
 * 
 * The wrapper was originaly implemented by Johan Tysklind and then reimplemented
 * by Ruslan Fomkin. The code that left from Johan is accessing data inside TTree
 * objects.
 *
 * Data can be accessed through get, scan and get_interval functions. Three 
 * additional corresponding functions are defined that apply project during 
 * the scan or get.
 *
 * NOTE:Currently it has redundancy in storing information about attributes of 
 * wrapped objects. If two objects has same attributes info about the 
 * attributes will be stored twice. 
 * NEEDS TO BE IMPROVED IF SCALABILITY PROBLEM HAPPENDS.
 * ===========================================================================
 * $Log: amain.cpp,v $
 * Revision 1.32  2008/05/15 15:27:06  ruslan
 * multidirection particle-event relationship. interface of root_scan_project_addslots is improved
 *
 * Revision 1.31  2008/05/10 13:05:36  ruslan
 * wrapper returns only sobject without the key vector, names of wrapper functions in correspondance with the Thesis
 *
 * Revision 1.30  2008/04/11 10:01:56  ruslan
 * bug in error message is fixed
 *
 * Revision 1.29  2008/04/10 15:15:31  ruslan
 * one interface function for scan and get_interval
 *
 * Revision 1.28  2008/04/10 12:53:30  ruslan
 * bugs fixing
 *
 * Revision 1.27  2008/04/10 10:42:56  ruslan
 * get interval foreign function
 *
 * Revision 1.26  2008/03/01 10:05:23  ruslan
 * collecting cardinality statistics for vector slots
 *
 * Revision 1.25  2008/02/28 13:11:32  ruslan
 * using sobject
 *
 * Revision 1.24  2008/02/11 08:25:49  ruslan
 * removing unnecessary code from the loop over events. gives improvement in performance of scanning between 10 and 20 percents.
 *
 * Revision 1.23  2007/12/17 14:58:15  ruslan
 * current streaming function is rewritten with new fast interface
 *
 * Revision 1.22  2007/11/09 15:08:56  ruslan
 * C implementation of UDFs
 *
 * Revision 1.21  2007/11/03 10:10:11  ruslan
 * returning structs
 *
 * Revision 1.20  2006/05/02 20:46:59  torer
 * Storage leaks removed
 *
 * Revision 1.19  2006/05/02 20:20:46  torer
 * Now using storage interface correctly
 *
 * Revision 1.17  2006/04/28 18:17:27  torer
 * Changed root_scan_project to use storage manager interface (10% faster)
 *
 * Revision 1.16  2006/03/29 08:59:03  ruslan
 * Project scan is improved by accessing projection tuple only once. Scanning the entire file takes 2.3 seconds, while optallcuts execution takes 6.5 seconds now.
 *
 * Revision 1.15  2006/03/22 15:46:28  torer
 * Implemented project root scan using internal rather than 'dummy' C interface
 *
 * Revision 1.14  2006/03/21 16:53:11  torer
 * Memory leaks removed.
 *
 ****************************************************************************/

#pragma warning ( disable : 4786 4503)
#include "../helpfunction.h"


/**
 * Global mapping array to store information about all opened files by the 
 * wrapper.
 */
Files* files;

/**
 * Global vector to store correspondance between number corresponding to the 
 * attribute types and their names.
 */
string types[6] = {string("Vector"),string("Integer"),string("Real"),
		   string("Charstring"),string("Element"),string("Unknown")};

/********************************
 * Implementation of class File
 * (c) Ruslan Fomkin
 ********************************/
/**
 * Returns reference to TFile object corresponding to opened ROOT file.
 */
inline TFile* File::getFile() const {
  return file;
}

/** 
 * Returns mapped array of dirctories/pathes in the file .
 */
inline Directories* File::getDirs() const {
  return dirs;
}

/**
 * Creates new file object. It takes ROOT file name which should include path
 * to the file if it is not available localy. It creates ROOT file object,
 * which opens the ROOT file and saves reference to the ROOT file object.
 */
File::File(string filename) {
  file = new TFile(filename.c_str());
  if (file->IsZombie()){
    cout << "File " << filename << " does not exist!\n";
    delete file;
    file = NULL;
    dirs = NULL;
    return;
  }
  dirs = new Directories;
}

/**
 * Cleans memory when the object is deleted
 */
File::~File() {
  if (dirs != NULL)
    delete dirs;
  if (file != NULL)
    delete file;
}

/**********************************
 * Implementation of class Table
 * (c) Ruslan Fomkin
 **********************************/
/**
 * Returns reference to TTree object.
 */
inline TTree* Table::getTree() const {
  return tree;
}

/**
 * Returns vector of attributes containing names and types for the 
 * corresponding TTree object.
 */
inline Attributes* Table::getAttrs() const {
  return attrs;
}

/**
 * Returns number of key attribute in the vector of attributes
 */
inline int Table::getKey() const {
  return key_attr;
}

int Table::getAttrPosition(string name) {
  for (int i = 0; i < attrs->size(); i++)
    if (name == attrs->at(i).name)
      return i;
  return -1;
}

/**
 * Creates new table object. Takes ROOT file object, path name and the 
 * TTree object name. Finds the object in the file under given path and stores
 * reference to it. Reads attributes of the object and saves their names and 
 * types to the attribute vector. In current implementation it is not checked 
 * if other object known by the wrapper has the same attributes, thus 
 * redundancy.
 */
Table::Table(TFile* file, string dir,string name) {
  tree = (TTree*)file->Get((dir+'/'+name).c_str());
  if (tree == NULL) {
    cout << "Tree object " << dir << '/' << name << " doesn't exist!\n";
    delete tree;
    tree = NULL;
    attrs = NULL;
    return;
  }
  key_attr=0;
  attrs = new Attributes(tree->GetListOfLeaves()->GetEntries()+1);
  TIter myIt((tree->GetListOfLeaves())->MakeIterator());
  TLeaf * leaf;
  int noObj;
  attrs->at(0).name = string("ID");
  attrs->at(0).type = INTEGER;
  int cur_attr = 1;
  while ((leaf = (TLeaf *)myIt.Next())){
    noObj= leaf->GetLen();
    if(noObj != 1){
      attrs->at(cur_attr).name = leaf->GetName();
      attrs->at(cur_attr).type = VECTOR;
    }
    else if (leaf->IsA() == TLeafI::Class())
      {
	attrs->at(cur_attr).name = leaf->GetName();
	attrs->at(cur_attr).type = INTEGER;
      }else if(leaf->IsA() == TLeafF::Class()){
	attrs->at(cur_attr).name = leaf->GetName();
	attrs->at(cur_attr).type = REAL;
      }
    else if(leaf->IsA() == TLeafC::Class()){
      attrs->at(cur_attr).name = leaf->GetName();
      attrs->at(cur_attr).type = CHARSTRING;
    }
    else if (leaf->IsA() == TLeafElement::Class()){
      attrs->at(cur_attr).name = leaf->GetName();
      attrs->at(cur_attr).type = ELEMENT;
    }else{
      attrs->at(cur_attr).name = leaf->GetName();
      attrs->at(cur_attr).type = UNKNOWN;
    }
    cur_attr++;
  }
}

/**
 * Cleans memory when the object is deleted
 */
Table::~Table() {
  if (tree != NULL)
    delete tree;
  if (attrs != NULL)
    delete attrs;
}

/********************************
 * Non class members
 ********************************/
/**
 * Finds the file with given file name (including path) in the wrapper. 
 * If the wrapper does not contains it, the file object is created 
 * and returned.
 */
File* getFile(string filename) {
  File* file;
  Files::iterator i_file = files->find(filename);
  if (i_file != files->end()) {
    file = i_file->second;
  }
  else {
    file = new File(filename);
    if (file->getFile() == NULL) {
      delete file;
      return NULL;
    }
    files->insert(pair<string,File*> (filename,file));
  }
  return file;
}

/**
 * Finds the TTree object with the given name under given path in the given
 * file in the wrapper. If the wrapper does not contain it, it is created and 
 * returned.
 */
Table* getTable(string file, string dir, string table) {
  Files::iterator cur_file = files->find(file);
  if (cur_file != files->end()) {
    TFile* f = cur_file->second->getFile();
    Directories* dirs = cur_file->second->getDirs();
    Directories::iterator cur_dir = dirs->find(dir);
    if (cur_dir != dirs->end()) {
      Tables* tables = cur_dir->second;
      Tables::iterator cur_table = tables->find(table);
      if (cur_table != tables->end()) {
	return cur_table->second;
      }
      else {
	Table* temp_table = new Table(f, dir, table);
	if (temp_table->getTree() == NULL) {
	  delete temp_table;
	  return NULL;
	}
	tables->insert(pair<string,Table*> (table,temp_table));
	return temp_table;
      }
    }
    else {
      Tables* tables = new Tables;
      dirs->insert(pair<string,Tables*> (dir, tables));
      Table* temp_table = new Table(f, dir, table);
      if (temp_table->getTree() == NULL) {
	delete temp_table;
	return NULL;
      }
      tables->insert(pair<string,Table*> (table,temp_table));
      return temp_table;
    }
  }
  else {
    File* temp_file = new File(file);
    if (temp_file->getFile() == NULL) {
      delete temp_file;
      return NULL;
    }
    files->insert(pair<string,File*> (file,temp_file));
    Tables* tables = new Tables;
    temp_file->getDirs()->insert(pair<string,Tables*> (dir, tables));
    Table* temp_table = new Table(temp_file->getFile(), dir, table);
    if (temp_table->getTree() == NULL) {
      delete temp_table;
      return NULL;
    }
    tables->insert(pair<string,Table*> (table,temp_table));
    return temp_table;
  }
  return NULL;
}

/**
 * Returns the TDirectory object under the given path in the given file.
 */
TDirectory* getDir(TFile* file, string dirname) {
  string rest;
  TDirectory* curdir = file;
  if (dirname == "")
    return curdir;
  if (dirname[0] == '/')
    rest = dirname.substr(1);
  while (rest != "") {
    int pos = rest.find('/');
    string temp;
    if (pos = rest.length()) {
      temp = rest;
      rest = "";
    } 
    else {
      temp = rest.substr(0,pos-1);
      if (pos+1 == rest.length())
	rest = "";
      else
	rest = rest.substr(pos+1);
    }
    TKey* k= curdir->GetKey(temp.c_str());
    if (k == NULL) {
      cout << "ROOT subdirectory " << rest << " does not exist!\n";
      return NULL;
    }
    curdir = (TDirectory*)k->ReadObj();
    if (curdir == NULL) {
      cout << "ROOT subdirectory " << rest << " does not exist!\n";
      return NULL;
    }
  }
  return curdir;
}

/**
 * Iterates the all pathes existing in the given file. Updates the directory
 * mapping array.
 */
void help_dir(string name, Directories* dirs, TDirectory* dir){
  string path;
  TFile* file = dir->GetFile();
  TKey* key;
  TIter myIt(dir->GetListOfKeys());
  while ((key = (TKey *)myIt.Next())){
    int t;
    t = strcmp("TDirectory",key->GetClassName());	
    if (t==0){
      path = name+"/"+string(key->GetName());
      Tables* tbls = new Tables;
      dirs->insert(pair<string,Tables*> (path,tbls));
      help_dir(path,dirs,(TDirectory*)key->ReadObj());
    }
  }

}

/**
 * Foreign function that returns all pathes in the given file.
 */
void root_dirs(a_callcontext cxt, a_tuple tpl){
  char db_name[70];
  a_getstringelem(tpl,0,db_name,sizeof(db_name),FALSE);
  File* file = getFile(string(db_name));
  //cout << "I am here\n";
  if (file == NULL)
    return;
  help_dir(string(""),file->getDirs(),file->getFile());
  for (Directories::iterator i_dir = file->getDirs()->begin(); \
       i_dir != file->getDirs()->end(); ++i_dir) {
    char* temp = new char[i_dir->first.length()+1];
    sprintf(temp,i_dir->first.c_str());
    a_setstringelem(tpl,1,temp,FALSE);
    a_emit(cxt,tpl,FALSE);
  }
}

/**
 * Foreign function that returns all TTree objects stored under the
 * given path in the given file.
 */
void root_trees(a_callcontext cxt, a_tuple tpl){
  char db_name[70];
  char dir[150];
  a_getstringelem(tpl,0,db_name,sizeof(db_name),FALSE);
  a_getstringelem(tpl,1,dir,sizeof(dir),FALSE);
  File* file = getFile(string(db_name));
  if (file == NULL)
    return;
  TDirectory* curdir = getDir(file->getFile(), string(dir));
  if (curdir == NULL) {
    cout << "ROOT Directory " << dir << " does not exist.\n";
    return;
  }
  TKey* key;
  TIter myIt(curdir->GetListOfKeys());
  while ((key = (TKey *)myIt.Next())){
    int t;
    t = strcmp("TTree",key->GetClassName());	
    if (t==0){
      char* filename = new char[strlen(key->GetName())+1];
      sprintf(filename,"%s;%i",key->GetName(),key->GetCycle());
      a_setstringelem(tpl,2,filename,FALSE);
      a_emit(cxt,tpl,FALSE);
    }
  }
}

/**
 * Foreign function that returns all attribute/column names and types
 * without ID attributes, because it is not needed when key should be specified on
 * ID attribute
 */
void root_columns(a_callcontext cxt, a_tuple tpl) {
  char db_name[70];
  char dir_name[150];
  char tbl_name[70];
  a_getstringelem(tpl,0,db_name,sizeof(db_name),FALSE);
  a_getstringelem(tpl,1,dir_name,sizeof(dir_name),FALSE);
  a_getstringelem(tpl,2,tbl_name,sizeof(tbl_name),FALSE);
  Table* table = getTable(string(db_name),string(dir_name),string(tbl_name));
  if (table == NULL)
    return;
  for (int i = 1; i < table->getAttrs()->size(); i++) {
    char* name = new char[table->getAttrs()->at(i).name.length()];
    sprintf(name,table->getAttrs()->at(i).name.c_str());
    a_setstringelem(tpl,3,name,FALSE);
    if (table->getAttrs()->at(i).type < 5) {
      char* typ = new char[types[table->getAttrs()->at(i).type].length()];
      sprintf(typ,types[table->getAttrs()->at(i).type].c_str());
      a_setstringelem(tpl,4,typ,FALSE);
    }
    a_emit(cxt,tpl,FALSE);
  }
}

/**
 * Foreign function that returns all attribute/column names and types with
 * ID attribute.
 */
void root_columns_all(a_callcontext cxt, a_tuple tpl) {
  char db_name[70];
  char dir_name[150];
  char tbl_name[70];
  a_getstringelem(tpl,0,db_name,sizeof(db_name),FALSE);
  a_getstringelem(tpl,1,dir_name,sizeof(dir_name),FALSE);
  a_getstringelem(tpl,2,tbl_name,sizeof(tbl_name),FALSE);
  Table* table = getTable(string(db_name),string(dir_name),string(tbl_name));
  if (table == NULL)
    return;
  for (int i = 0; i < table->getAttrs()->size(); i++) {
    char* name = new char[table->getAttrs()->at(i).name.length()];
    sprintf(name,table->getAttrs()->at(i).name.c_str());
    a_setstringelem(tpl,3,name,FALSE);
    if (table->getAttrs()->at(i).type < 5) {
      char* typ = new char[types[table->getAttrs()->at(i).type].length()];
      sprintf(typ,types[table->getAttrs()->at(i).type].c_str());
      a_setstringelem(tpl,4,typ,FALSE);
    }
    a_emit(cxt,tpl,FALSE);
  }
}

/*********************************************
 * scanning and getting functions
 *********************************************/

/**
 * Foreign funciton that returns values of element of the specified TTree 
 * object with the given ID.
 */
void root_get(a_callcontext cxt, a_tuple tpl) {
  char db_name[70];
  char dir_name[150];
  char tbl_name[70];
  dcl_tuple(key_v);

  a_getseqelem(tpl,3,key_v,FALSE);
  a_getstringelem(key_v,0,db_name,sizeof(db_name),FALSE);
  a_getstringelem(key_v,1,dir_name,sizeof(dir_name),FALSE);
  a_getstringelem(key_v,2,tbl_name,sizeof(tbl_name),FALSE);
  int id = a_getintelem(key_v,3,FALSE);
  free_tuple(key_v);

  Table* tbl = getTable(string(db_name),string(dir_name),string(tbl_name));
  if (tbl == NULL) return;
  TTree* t= tbl->getTree();
  // Johan's code with small adaptations to internal data structures
  TObjArray *leaves  = t->GetListOfLeaves();
  Int_t nleaves = leaves->GetEntriesFast();
  int noObj = t->GetEntries();
  if (id >= noObj) 
    {
      cout << "There is no element with such id!\n";
      return;
    }
  dcl_tuple(k_res);
  a_newtuple(k_res, nleaves, FALSE);
  t->GetEntry(id);
  for (Int_t i=0;i<t->GetNbranches();i++) {
	
    TLeaf * leaf = (TLeaf*)leaves->UncheckedAt(i);

    if (tbl->getAttrs()->at(i+1).type == INTEGER){
      Int_t *value = (Int_t*)leaf->GetValuePointer();
      a_setintelem(k_res, i, value[0], FALSE);
    }else if(tbl->getAttrs()->at(i+1).type == REAL){
      Float_t *value = (Float_t *)leaf->GetValuePointer();
      a_setdoubleelem(k_res, i,value[0], FALSE);
    }else if(tbl->getAttrs()->at(i+1).type == ELEMENT) {
      char val[50];
      sprintf(val,"%s","[#POOL OBJECT#]"); 
      a_setstringelem(k_res, i,val, FALSE);
    }else if(tbl->getAttrs()->at(i+1).type == VECTOR){
      dcl_tuple(temp);
      a_newtuple(temp, leaf->GetLen(), FALSE);
      for (Int_t t =0; t<leaf->GetLen();t++)
	{
	  if (leaf->IsA() == TLeafI::Class()){
	    Int_t *value = (Int_t*)leaf->GetValuePointer();
	    a_setintelem(temp, t, value[t], FALSE);}
	  else if (leaf->IsA() == TLeafF::Class()){
	    Float_t *value = (Float_t *)leaf->GetValuePointer();
	    a_setdoubleelem(temp, t,value[t], FALSE);
	  }
	}
      a_setseqelem(k_res, i, temp, FALSE);
      free_tuple(temp);}
	
  }
  a_setseqelem(tpl, 4, k_res, FALSE);
  a_emit(cxt, tpl, FALSE);
  free_tuple(k_res);
}

/**
 * Foreign function that returns values of all elements in the specified TTree
 * object.
 */
void root_scan(a_callcontext cxt, a_tuple tpl){
  char db_name[70];
  char dir_name[150];
  char tbl_name[70];

  a_getstringelem(tpl,0,db_name,sizeof(db_name),FALSE);
  a_getstringelem(tpl,1,dir_name,sizeof(dir_name),FALSE);
  a_getstringelem(tpl,2,tbl_name,sizeof(tbl_name),FALSE);
  Table* tbl = getTable(string(db_name),string(dir_name),string(tbl_name));
  if (tbl == NULL)
    return;
  TTree* t= tbl->getTree();
  // Johan's code with small adaptations to internal data structures
  int noObj;
  // dcl_tuple(d_res); NOT USED (TR)
  TObjArray *leaves  = t->GetListOfLeaves();
  Int_t nleaves = leaves->GetEntriesFast();

  noObj = t->GetEntries();
  //a_newtuple(d_res, 1, FALSE);
  for (Int_t s=0;s<noObj;s++){
	oidtype key_v = nil, temp = nil, k_res = nil;
    // Key vector, contains source (3 elements) and id

    a_setf(key_v,new_array(4, nil));
    a_seta(key_v,0,mkstring(db_name));
    a_seta(key_v,1,mkstring(dir_name));
    a_seta(key_v,2,mkstring(tbl_name));
    a_seta(key_v,3,mkinteger(s));
    a_seta(tpl->tpl, 3, key_v);
    a_free(key_v);

    // Non key vector
    a_setf(k_res,new_array(nleaves, nil));
    t->GetEntry(s);
    for (Int_t i=0;i<nleaves;i++) {
      TLeaf *leaf = (TLeaf*)leaves->UncheckedAt(i);
      if (tbl->getAttrs()->at(i+1).type == INTEGER){
	Int_t *value = (Int_t*)leaf->GetValuePointer();
	a_seta(k_res, i, mkinteger(value[0]));
      }else if(tbl->getAttrs()->at(i+1).type == REAL){
	Float_t *value = (Float_t *)leaf->GetValuePointer();
	a_seta(k_res, i,mkreal(value[0]));
      }else if(tbl->getAttrs()->at(i+1).type == ELEMENT){
	char val[50];
	sprintf(val,"%s","[#POOL OBJECT#]");  
	a_seta(k_res, i,mkstring(val));
      }else if(tbl->getAttrs()->at(i+1).type == VECTOR){
	a_setf(temp,new_array(leaf->GetLen(),nil));
	for (Int_t t =0; t<leaf->GetLen();t++) {
	  if (leaf->IsA() == TLeafI::Class()){
	    Int_t *value = (Int_t*)leaf->GetValuePointer();
		a_seta(temp,t,mkinteger(value[i]));
	  }
	  else if (leaf->IsA() == TLeafF::Class()){
	    Float_t *value = (Float_t *)leaf->GetValuePointer();
		a_seta(temp,t,mkreal(value[t]));
	  }
			
	}
	a_seta(k_res, i, temp);
	a_free(temp);
      }
	
    }
    a_seta(tpl->tpl, 4, k_res);
    a_free(k_res);
    
	a_emit(cxt, tpl, FALSE); 
  }
}

/**
 * Foreign function that returns all elements in the given interval of the
 * specified TTree object.
 */
void root_get_interval(a_callcontext cxt, a_tuple tpl){
  char db_name[70];
  char dir_name[150];
  char tbl_name[70];
  a_getstringelem(tpl,0,db_name,sizeof(db_name),FALSE);
  a_getstringelem(tpl,1,dir_name,sizeof(dir_name),FALSE);
  a_getstringelem(tpl,2,tbl_name,sizeof(tbl_name),FALSE);
  int low = a_getintelem(tpl,3,FALSE);
  int high = a_getintelem(tpl,4,FALSE);
  Table* tbl = getTable(string(db_name),string(dir_name),string(tbl_name));
  if (tbl == NULL)
    return;
  TTree* t= tbl->getTree();
  // Johan's code with small adaptations to internal data structures
  int noObj;
  dcl_tuple(lowk_tpl);
  dcl_tuple(upk_tpl);
  dcl_tuple(d_res);
	
  TObjArray *leaves  = t->GetListOfLeaves();
  Int_t nleaves = leaves->GetEntriesFast();
  noObj = t->GetEntries();
	
  for (Int_t s=low;s<=high;s++){
    // Key vector, contains source (3 elements) and id
    dcl_tuple(key_v);
    a_newtuple(key_v,4, FALSE);
    a_setstringelem(key_v,0,db_name,FALSE);
    a_setstringelem(key_v,1,dir_name,FALSE);
    a_setstringelem(key_v,2,tbl_name,FALSE);
    a_setintelem(key_v,3,s,FALSE);

    a_setseqelem(tpl, 5, key_v, FALSE);
    free_tuple(key_v);
    // Non key vector
    dcl_tuple(k_res);
    a_newtuple(k_res, nleaves, FALSE);
    t->GetEntry(s);

    for (Int_t i=0;i<nleaves;i++) {
      TLeaf *leaf = (TLeaf*)leaves->UncheckedAt(i);
      if (tbl->getAttrs()->at(i).type == INTEGER){
	Int_t *value = (Int_t*)leaf->GetValuePointer();
	a_setintelem(k_res, i, value[0], FALSE);
      }else if(tbl->getAttrs()->at(i).type == REAL){
	Float_t *value = (Float_t *)leaf->GetValuePointer();
	a_setdoubleelem(k_res, i,value[0], FALSE);
      }else if(tbl->getAttrs()->at(i).type == ELEMENT){
	char val[50];
	sprintf(val,"%s","[#POOL OBJECT#]");  
	a_setstringelem(k_res, i,val, FALSE);
      }else if(tbl->getAttrs()->at(i).type == VECTOR){
	dcl_tuple(temp);
	a_newtuple(temp, leaf->GetLen(), FALSE);
	for (Int_t t =0; t<leaf->GetLen();t++) {
	  if (leaf->IsA() == TLeafI::Class()){
	    Int_t *value = (Int_t*)leaf->GetValuePointer();
	    a_setintelem(temp, t, value[t], FALSE);}
	  else if (leaf->IsA() == TLeafF::Class()){
	    Float_t *value = (Float_t *)leaf->GetValuePointer();
	    a_setdoubleelem(temp, t,value[t], FALSE);
	  }
	}
	a_setseqelem(k_res, i, temp, FALSE);
      }
    }
    a_setseqelem(tpl, 6, k_res, FALSE);
    a_emit(cxt, tpl, FALSE);
  }

}

/********************************
 * Functions where projection is pushed down.
 * (c) Ruslan Fomkin
 ********************************/

/**
 * Foreign funciton that returns values of element of the specified TTree 
 * object with the given ID with projection.
 */
void root_get_project(a_callcontext cxt, a_tuple tpl) {
	char db_name[70];
	char dir_name[150];
	char tbl_name[70];
	dcl_tuple(project);
	a_getseqelem(tpl,3,project,FALSE);
	dcl_tuple(key_v);
	a_getseqelem(tpl,4,key_v,FALSE);
	a_getstringelem(key_v,0,db_name,sizeof(db_name),FALSE);
	a_getstringelem(key_v,1,dir_name,sizeof(dir_name),FALSE);
	a_getstringelem(key_v,2,tbl_name,sizeof(tbl_name),FALSE);
	int id = a_getintelem(key_v,3,FALSE);
	free_tuple(key_v);
	Table* tbl = getTable(string(db_name),string(dir_name),string(tbl_name));
	if (tbl == NULL)
		return;
	TTree* t= tbl->getTree();
	// Johan's code with small adaptations to internal data structures
	TObjArray *leaves  = t->GetListOfLeaves();
	Int_t nleaves = leaves->GetEntriesFast();
	int noObj = t->GetEntries();
	if (id >= noObj) {
		cout << "Error: There is no element with such id!\n";
		return;
	}
	dcl_tuple(k_res);
	a_newtuple(k_res, a_getarity(project,FALSE), FALSE);
	t->GetEntry(id);
	for (int j=0;j<a_getarity(project,FALSE);j++) {
		char attr_name[70];
		a_getstringelem(project,j,attr_name,sizeof(attr_name),FALSE);
		Int_t i = tbl->getAttrPosition(string(attr_name));
		if (i<0) {
			cout << "Error: Attribute name in pojection is wrong. The name \
				of " << j << " attribute is: " << attr_name <<"\n";
			return;
		}
		if (i==0)
			a_setintelem(k_res,j,id,FALSE);
		else {
			
			TLeaf * leaf = (TLeaf*)leaves->UncheckedAt(i-1);
			
			if (tbl->getAttrs()->at(i).type == INTEGER){
				Int_t *value = (Int_t*)leaf->GetValuePointer();
				a_setintelem(k_res, j, value[0], FALSE);
			}else if(tbl->getAttrs()->at(i).type == REAL){
				Float_t *value = (Float_t *)leaf->GetValuePointer();
				a_setdoubleelem(k_res, j,value[0], FALSE);
			}else if(tbl->getAttrs()->at(i).type == ELEMENT) {
				char val[50];
				sprintf(val,"%s","[#POOL OBJECT#]"); 
				a_setstringelem(k_res, j,val, FALSE);
			}else if(tbl->getAttrs()->at(i).type == VECTOR){
				dcl_tuple(temp);
				a_newtuple(temp, leaf->GetLen(), FALSE);
				for (Int_t t =0; t<leaf->GetLen();t++)
				{
					if (leaf->IsA() == TLeafI::Class()){
						Int_t *value = (Int_t*)leaf->GetValuePointer();
						a_setintelem(temp, t, value[t], FALSE);}
					else if (leaf->IsA() == TLeafF::Class()){
						Float_t *value = (Float_t *)leaf->GetValuePointer();
						a_setdoubleelem(temp, t,value[t], FALSE);
					}
				}
				//a_setseqelem(k_res, j, temp, FALSE);
				a_seta(k_res->tpl,j,temp->tpl);
				free_tuple(temp);
			}
		}
		
	}
	a_setseqelem(tpl, 5, k_res, FALSE);
	a_emit(cxt, tpl, FALSE);
	free_tuple(k_res);
	free_tuple(project);
}

/**
 * Foreign function that returns values of all elements in the specified TTree
 * object with projection.
 */
void root_scan_project(a_callcontext cxt, a_tuple tpl){
	char db_name[70];
	char dir_name[150];
	char tbl_name[70];
	int *project_attrs;
	dcl_tuple(project);
	int arity;

	a_getstringelem(tpl,0,db_name,sizeof(db_name),FALSE);
	a_getstringelem(tpl,1,dir_name,sizeof(dir_name),FALSE);
	a_getstringelem(tpl,2,tbl_name,sizeof(tbl_name),FALSE);
	a_getseqelem(tpl,3,project,FALSE);
	arity = a_getarity(project, FALSE);
	Table* tbl = getTable(string(db_name),string(dir_name),string(tbl_name));
	if (tbl == NULL)
		return;
	TTree* t= tbl->getTree();
	
	// Reading projection
	int project_size=a_getarity(project,FALSE);
	project_attrs=new int[project_size];
	for (int j=0;j<project_size;j++) {
		char attr_name[70];
		a_getstringelem(project,j,attr_name,sizeof(attr_name),FALSE);
		project_attrs[j] = tbl->getAttrPosition(string(attr_name));
		if (project_attrs[j]<0) {
		cout << "Error: Attribute name in pojection is wrong. The name \
			of " << project_attrs[j] << " attribute is: " << attr_name <<"\n";
		return;
		}
	}
	
	// Johan's code with small adaptations to internal data structures
	int noObj;
	TObjArray *leaves  = t->GetListOfLeaves();
	Int_t nleaves = leaves->GetEntriesFast();
	noObj = t->GetEntries();
	for (Int_t s=0;s<noObj;s++){
		// Key vector, contains source (3 elements) and id
		//dcl_tuple(key_v);
		oidtype key_v=nil, k_res=nil;

		//a_newtuple(key_v,5, FALSE);
		a_setf(key_v,new_array(5,nil));
		//a_setstringelem(key_v,0,db_name,FALSE);
		a_seta(key_v, 0, mkstring(db_name));
		//a_setstringelem(key_v,1,dir_name,FALSE);
		a_seta(key_v, 1, mkstring(dir_name));
		//a_setstringelem(key_v,2,tbl_name,FALSE);
		a_seta(key_v, 2, mkstring(tbl_name));
		//a_setintelem(key_v,3,s,FALSE);
		a_seta(key_v, 3, mkinteger(s));
		//a_setseqelem(key_v,4,project,FALSE);
		a_seta(key_v, 4, project->tpl);
		
		//a_setseqelem(tpl, 4, key_v, FALSE);
		a_seta(tpl->tpl, 4, key_v);

		a_free(key_v);
		// Non key vector
		//dcl_tuple(k_res);
		//a_newtuple(k_res, a_getarity(project,FALSE), FALSE);
		a_setf(k_res, new_array(arity,nil));
		t->GetEntry(s);
		for (int i=0;i<project_size;i++) {
			if (project_attrs[i]==0)
				//a_setintelem(k_res,i,s,FALSE);
				a_seta(k_res, i, mkinteger(s));
			else {
				TLeaf *leaf = (TLeaf*)leaves->UncheckedAt(project_attrs[i]-1);
				if (tbl->getAttrs()->at(project_attrs[i]).type == INTEGER){
					Int_t *value = (Int_t*)leaf->GetValuePointer();
					//a_setintelem(k_res, i, value[0], FALSE);
					a_seta(k_res, i, mkinteger(value[0]));
				}else if(tbl->getAttrs()->at(project_attrs[i]).type == REAL){
					Float_t *value = (Float_t *)leaf->GetValuePointer();
					//a_setdoubleelem(k_res, i,value[0], FALSE);
					a_seta(k_res, i, mkreal(value[0]));
				}else if(tbl->getAttrs()->at(project_attrs[i]).type == ELEMENT){
					char val[50];
					sprintf(val,"%s","[#POOL OBJECT#]");  
					//a_setstringelem(k_res, i,val, FALSE);
					a_seta(k_res, i, mkstring(val));
				}else if(tbl->getAttrs()->at(project_attrs[i]).type == VECTOR){
					//dcl_tuple(temp);
					oidtype temp=nil;
					//a_newtuple(temp, leaf->GetLen(), FALSE);
					a_setf(temp, new_array(leaf->GetLen(),nil));
					for (Int_t t =0; t<leaf->GetLen();t++) {
						if (leaf->IsA() == TLeafI::Class()){
							Int_t *value = (Int_t*)leaf->GetValuePointer();
							//a_setintelem(temp, t, value[t], FALSE);
							a_seta(temp, t, mkinteger(value[t]));
						}
						else if (leaf->IsA() == TLeafF::Class()){
							Float_t *value = (Float_t *)leaf->GetValuePointer();
							//a_setdoubleelem(temp, t,value[t], FALSE);
							a_seta(temp, t, mkreal(value[t]));
						}
						
					}
					//a_setseqelem(k_res, i, temp, FALSE);
					a_seta(k_res, i, temp);
					//free_tuple(temp);
					a_free(temp);
				}
				
			}
		}
		//a_setseqelem(tpl, 5, k_res, FALSE);
		a_seta(tpl->tpl, 5, k_res);
		a_emit(cxt, tpl, FALSE);
		//free_tuple(k_res);
		a_free(k_res);
                if(cxt->done) break; // very important!
	}
	free_tuple(project);
}

/**
 * Foreign function that returns values of all elements in the specified TTree
 * object with projection as struct.
**/
 oidtype root_scan_sobjects_project(a_callcontext cxt){
	 int interval_shift = 0;
	 oidtype db_name_obj = a_arg(cxt,1);
	 oidtype dir_name_obj = a_arg(cxt, 2);
	 oidtype tbl_name_obj = a_arg(cxt, 3);
	 oidtype project = a_arg(cxt, 4);
	 oidtype sobjects_type = a_arg(cxt, 5);
	 oidtype add_arity_obj = a_arg(cxt, 6);
	 char *db_name, *dir_name, *tbl_name;
	 int *project_attrs;
	 short *project_types;
	 int add_arity;
	 int arity;
	 int firstEvent, lastEvent;
	 
	 IntoString(db_name_obj,db_name,a_env(cxt));
	 IntoString(dir_name_obj,dir_name,a_env(cxt));
	 IntoString(tbl_name_obj,tbl_name,a_env(cxt));
	 OfType(project,ARRAYTYPE,a_env(cxt));
	 add_arity=getinteger(add_arity_obj);
	 arity = a_arraysize(project);
	 Table* tbl = getTable(string(db_name),string(dir_name),string(tbl_name));
	 if (tbl == NULL)
		 return nil;
	 TTree* t= tbl->getTree();
	 
	 TObjArray *leaves  = t->GetListOfLeaves();
	 Int_t nleaves = leaves->GetEntriesFast();
	 firstEvent = 0;
	 lastEvent = t->GetEntries() - 1;
	 if (a_arity(cxt)==9) {
		 int first = getinteger(a_arg(cxt, 7));
		 int last = getinteger(a_arg(cxt, 8));
		 interval_shift = 2;

		 if (first < firstEvent) {
			 a_error(ARRAY_BOUNDS,a_arg(cxt,7),FALSE);
			 return nil;
		 }
		 if (last > lastEvent) {
			 a_error(ARRAY_BOUNDS,a_arg(cxt,8),FALSE);
			 return nil;
		 }
		 firstEvent = first;
		 lastEvent = last;
	 }
	 
	 // Reading projection
	 project_attrs=new int[arity];
	 project_types=new short[arity];
	 for (int j=0;j<arity;j++) {
		 char *attr_name;
		 IntoString(a_elt(project,j),attr_name,a_env(cxt));
		 project_attrs[j] = tbl->getAttrPosition(string(attr_name));
		 if (project_attrs[j]<0) {
		 cout << "Error: Attribute name in pojection is wrong. The name \
			 of " << project_attrs[j] << " attribute is: " << attr_name <<"\n";
		 return nil;
		 }
		 project_types[j] = tbl->getAttrs()->at(project_attrs[j]).type;
	 }
	 
	 // Johan's code with small adaptations to internal data structures
	 for (Int_t s=firstEvent;s<=lastEvent;s++){
		 oidtype s_obj = mkinteger(s);
		 oidtype k_res = make_sobject(sobjects_type,db_name_obj,s_obj,(arity+add_arity));
		 
		 t->GetEntry(s);
		 for (int i=0;i<arity;i++) {
			 if (project_attrs[i]==0)
				 sobject_set(k_res, i, s_obj);
			 else {
				 TLeaf *leaf = (TLeaf*)leaves->UncheckedAt(project_attrs[i]-1);
				 if (project_types[i] == INTEGER){
					 Int_t *value = (Int_t*)leaf->GetValuePointer();
					 sobject_set(k_res, i, mkinteger(value[0]));
				 }else if(project_types[i] == REAL){
					 Float_t *value = (Float_t *)leaf->GetValuePointer();
					 sobject_set(k_res, i, mkreal(value[0]));
				 }else if(project_types[i] == ELEMENT){
					 char val[50];
					 sprintf(val,"%s","[#POOL OBJECT#]");  
					 sobject_set(k_res, i, mkstring(val));
				 }else if(project_types[i] == VECTOR){
					 oidtype temp=nil;
					 temp=new_array(leaf->GetLen(),nil);
					 for (Int_t t =0; t<leaf->GetLen();t++) {
						 if (leaf->IsA() == TLeafI::Class()){
							 Int_t *value = (Int_t*)leaf->GetValuePointer();
							 a_seta(temp, t, mkinteger(value[t]));
						 }
						 else if (leaf->IsA() == TLeafF::Class()){
							 Float_t *value = (Float_t *)leaf->GetValuePointer();
							 a_seta(temp, t, mkreal(value[t]));
						 }
						 
					 }
					 sobject_set_stat(cxt,k_res, i, temp);
				 }
				 
			 }
		 }
		 a_bind(cxt, 7+interval_shift, k_res);
		 a_result(cxt);
		 //		 if(cxt->done) break; // very important!
	 }
	 return nil;
}


/**
 * Foreign function that returns all elements in the given interval of the
 * specified TTree object with projection.
 * NOT MANTAINED!!!! Iterating over projection should be implemented as for
 * root_scan_project.
 */
void root_get_interval_project(a_callcontext cxt, a_tuple tpl){
  char db_name[70];
  char dir_name[150];
  char tbl_name[70];
  dcl_tuple(project);
  a_getstringelem(tpl,0,db_name,sizeof(db_name),FALSE);
  a_getstringelem(tpl,1,dir_name,sizeof(dir_name),FALSE);
  a_getstringelem(tpl,2,tbl_name,sizeof(tbl_name),FALSE);
  a_getseqelem(tpl,3,project,FALSE);
  int low = a_getintelem(tpl,4,FALSE);
  int high = a_getintelem(tpl,5,FALSE);
  Table* tbl = getTable(string(db_name),string(dir_name),string(tbl_name));
  if (tbl == NULL)
    return;
  TTree* t= tbl->getTree();
  // Johan's code with small adaptations to internal data structures
  int noObj;
  dcl_tuple(lowk_tpl);
  dcl_tuple(upk_tpl);
  dcl_tuple(d_res);
	
  TObjArray *leaves  = t->GetListOfLeaves();
  Int_t nleaves = leaves->GetEntriesFast();
  noObj = t->GetEntries();
  //	a_newtuple(d_res, 1, FALSE);
	
  for (Int_t s=low;s<=high;s++){
    // Key vector, contains source (3 elements) and id
    dcl_tuple(key_v);
    a_newtuple(key_v,5, FALSE);
    a_setstringelem(key_v,0,db_name,FALSE);
    a_setstringelem(key_v,1,dir_name,FALSE);
    a_setstringelem(key_v,2,tbl_name,FALSE);
    a_setintelem(key_v,3,s,FALSE);
    a_setseqelem(key_v,4,project,FALSE);

    a_setseqelem(tpl, 6, key_v, FALSE);
    free_tuple(key_v);
    // Non key vector
    dcl_tuple(k_res);
    a_newtuple(k_res, a_getarity(project,FALSE), FALSE);
    t->GetEntry(s);

    for (int j=0;j<a_getarity(project,FALSE);j++) {
      char attr_name[70];
      a_getstringelem(project,j,attr_name,sizeof(attr_name),FALSE);
      Int_t i = tbl->getAttrPosition(string(attr_name));
      if (i<0) {
	cout << "Error: Attribute name in pojection is wrong. The name \
				of " << j << " attribute is: " << attr_name <<"\n";
	return;
      }
      if (i==0)
	a_setintelem(k_res,j,s,FALSE);
      else {
	TLeaf *leaf = (TLeaf*)leaves->UncheckedAt(i-1);
	if (tbl->getAttrs()->at(i).type == INTEGER){
	  Int_t *value = (Int_t*)leaf->GetValuePointer();
	  a_setintelem(k_res, j, value[0], FALSE);
	}else if(tbl->getAttrs()->at(i).type == REAL){
	  Float_t *value = (Float_t *)leaf->GetValuePointer();
	  a_setdoubleelem(k_res, j,value[0], FALSE);
	}else if(tbl->getAttrs()->at(i).type == ELEMENT){
	  char val[50];
	  sprintf(val,"%s","[#POOL OBJECT#]");  
	  a_setstringelem(k_res, j,val, FALSE);
	}else if(tbl->getAttrs()->at(i).type == VECTOR){
	  dcl_tuple(temp);
	  a_newtuple(temp, leaf->GetLen(), FALSE);
	  for (Int_t t =0; t<leaf->GetLen();t++) {
	    if (leaf->IsA() == TLeafI::Class()){
	      Int_t *value = (Int_t*)leaf->GetValuePointer();
	      a_setintelem(temp, t, value[t], FALSE);}
	    else if (leaf->IsA() == TLeafF::Class()){
	      Float_t *value = (Float_t *)leaf->GetValuePointer();
	      a_setdoubleelem(temp, t,value[t], FALSE);
	    }
	  }
	  a_setseqelem(k_res, j, temp, FALSE);
	}
      }
    }
    //		a_setintelem(d_res, 0, s, FALSE);
    //		a_setseqelem(tpl, 6, d_res, FALSE);
    a_setseqelem(tpl, 7, k_res, FALSE);
    a_emit(cxt, tpl, FALSE);
  }

}

/**
 * Returns position of an attribute in the result vector of general scan.
 */
void root_attr_i(a_callcontext cxt, a_tuple tpl){
  char db_name[70];
  char dir_name[150];
  char tbl_name[70];
  char attr_name[70];
  a_getstringelem(tpl,0,db_name,sizeof(db_name),FALSE);
  a_getstringelem(tpl,1,dir_name,sizeof(dir_name),FALSE);
  a_getstringelem(tpl,2,tbl_name,sizeof(tbl_name),FALSE);
  a_getstringelem(tpl,3,attr_name,sizeof(attr_name),FALSE);
  Table* tbl = getTable(string(db_name),string(dir_name),string(tbl_name));
  if (tbl == NULL)
    return;
  Attributes* attrs = tbl->getAttrs();
  for (int i = 0; i < tbl->getAttrs()->size(); i++)
    if (tbl->getAttrs()->at(i).name == string(attr_name)) {
      a_setintelem(tpl, 4, i, FALSE);
      a_emit(cxt, tpl, FALSE);
      return;
    }
}

/********************************************************************
 * Main function
 ********************************************************************/


/**
 * Main function that provides all foreign functions to the AMOS and 
 * starts AMOS loop.
 */
int main (int argc, char** argv)
{
  files = new Files;
  dcl_connection(c);
  dcl_scan(s);
  init_amos(argc, argv);
  register_structsfns();
  register_udffns();
  a_extfunction("root_dirs",root_dirs);
  a_extfunction("root_files",root_trees);
  a_extfunction("root_columns",root_columns);
  a_extfunction("root_columns_all",root_columns_all);
  a_extfunction("root_scan",root_scan);
  a_extfunction("root_get",root_get);
  a_extfunction("root_get_interval",root_get_interval);
  a_extfunction("root_scan_project",root_scan_project);
  a_extfunction("root_get_project",root_get_project);
  a_extfunction("root_get_interval_project",root_get_interval_project);
  a_extfunction("root_attr_i",root_attr_i);
  a_extimpl("root_scan_sobjects_project",root_scan_sobjects_project);
  a_connect(c,"",FALSE);
  amos_toploop("ROOTWrap");
  a_disconnect(c,FALSE);
  free_scan(s);
  free_connection(c);

  delete files;
  return 0;
}
