

#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <mex.h> /* only needed because of mexFunction below and mexPrintf */

#include "callin.h" 
#include "callout.h" 
#include "msl.h"
#include "storage.h"
#include "a_time.h" 
#include "rdfstorage.h"
#include "ssdm.h"


/**********************************************************************************************/
/*                                      AMOS INTERFACE                                        */
/**********************************************************************************************/


////////////////////////////////////STRUCTS DEFINITION

typedef struct ConnectEntry
/*Connection Entry, contains a_connection, connection id and a pointer points to next CE*/
{
	a_connection Connection;
	int cid;
	char *peer;
	struct ConnectEntry * next;
	oidtype sparqlFn, rdfInsertFn;// objects hodling the sparqlFns for sparql functions initializeation
}CE,*cep;


typedef struct ScanEntry
/*ScanEntry: contains a_scan, a vectorized, a_tuple, and a pointer points to next ScanEntry*/
{
	a_scan scan;
	int sid;
	int vectorized;//amos:0; sparql:1; sparqlfn:2
	a_tuple tpl;// to hole the first row in a result
	struct ScanEntry *next;
}SE,*sep;





///////////////////////////////////////GLOBAL VARIABLES

int CE_COUNTER = 1;/*ConnectionEntry id*/
int SE_COUNTER = 1;/*SE_LIST_HEAD id*/

int AMOS_INIT = 0;//Amos initialization tag
int SPARQL_INIT=0;//SPARQL initialization tag

int SPARQL_MODE = 0;//SSDM tag

int AMOS_FUNCTION_INIT=0;
int SPARQL_FUNCTION_INIT=0;




cep CE_LIST_HEAD=NULL;/*a global ConnectionEntry*/
cep LAST_FOUND_CE =NULL;// CE pointer to the current CE
cep PRE_LAST_FOUND_CE=NULL;// the CE before the current CE

sep SE_LIST_HEAD=NULL;/*ScanEntry pointer points to the head of SE list*/
sep LAST_FOUND_SE=NULL;/*ScanEntry pointer points to the SE with specific scan id*/
sep PRE_LAST_FOUND_SE=NULL;/*SE pointer points to the previous SE of targeted SE*/


//////////////////////////////////////////MACROS
#define newScan new_scan->scan
#define newSID new_scan->sid
#define newTuple new_scan->tpl
#define newNext new_scan->next
#define newVect new_scan->vectorized
#define lastFoundTpl LAST_FOUND_SE->tpl

#define P_SE PRE_LAST_FOUND_SE
#define L_SE LAST_FOUND_SE

#define P_CE PRE_LAST_FOUND_CE
#define L_CE LAST_FOUND_CE


///////////////////////////////FUNCTIONS DECLARATIONS
DLL_EXPORT int amosExecute(int,mxArray* query);//execute Amoquery
int numberic_element_count(a_tuple tpl);// count the element number in a tuple

//////////////////functions objects initialization
int amos_init_fns(cep);//Amos functions
void sparql_init_fns(cep);// SPARQL functions
void sparqlFinalize_fns(cep);// finalize SPARQL functions
void callmatlab_bbf(a_callcontext cxt, a_tuple tpl);// foreign function to call matlab functions

/////////////////////SE functions
int SE_validation(sep);// validating a scan: if it's empty
void free_SE(sep);//free a SE at a specific Sid
sep dcl_ScanEnt();// decalring SE to allocate memory
sep dcl_ScanEnt();// declare a SE




/////////////////////CE functions
int CE_search(int);
int CE_check(char*);//check the connection too specific peer



////////////////////////////////ERROR TRAPPING
void errTrap()
{
	a_errno = 0;
	mexErrMsgTxt(a_errstr);		
}


////////////////////////////////CONNECTION FUNCTIONS

void setNameServerPort(int port)
{
    a_setf(globval(mksymbol("*nsp*")),mkinteger(port));
} 

/*Creating a new connection, and insert it to the CE_LIST_HEAD
* setting the peer, id and connect to the peer*/
int newCE(char* host, char* peerName) //AA: changed HOSTID to host
{
	cep new_ce;
	new_ce = (cep)malloc(sizeof(CE));
	new_ce->Connection = a_init_connection();
	new_ce->cid = CE_COUNTER;
	new_ce->peer = peerName;

	/*insert the CE to the head of list*/
	new_ce->next = CE_LIST_HEAD;
	CE_LIST_HEAD = new_ce;
	if(strlen(host)==0) a_connect(new_ce->Connection,peerName,TRUE);// connect to the local server  //AA
	else a_connectto(new_ce->Connection,peerName,host,TRUE);//connect to the remote name server //A
	if(a_errno) errTrap();
	CE_COUNTER+=1;
	return CE_LIST_HEAD->cid;
}

DLL_EXPORT void setRemotePort(int port) //AA
{
    a_setf(globval(mksymbol("*nsp*")),mkinteger(port)); //Setting standard name server port, when only one peer is available on remote host
} 

/*If the Hostid is specified by an empty string, the local host is connected*/
DLL_EXPORT int newConnection(mxArray *ahost, mxArray *apeer) //AA: changed HOSTID to host
{	
	/*create a connectionEntry to the specific peer*/
	char* host = mxArrayToString(ahost); //AA
	char* peerName=mxArrayToString(apeer);// convert the the peer name from mxArray string to C string array	
	if(strlen(peerName)==0 && strlen(host)!=0) mexErrMsgTxt("Peer name must be provided!"); //AA
	newCE(host, peerName);// call newCE to create a new connection
	amos_init_fns(CE_LIST_HEAD);//initializing the Amos function to current peer
	if(SPARQL_MODE==1) sparql_init_fns(CE_LIST_HEAD);// if the SPARQL_MODEL == 1, initialize the sparql functions as well.
	return CE_LIST_HEAD->cid;// return the connection id.
}


/*search the connection with specific id*/
int CE_search(int id)
{
	cep ce = CE_LIST_HEAD;
	cep last_ce = NULL;

	/*an invalid scan id*/
	if(id>CE_COUNTER || id<0) mexErrMsgTxt("Invalid connection ID!\n");

	else{
		/*if the id bigger than the desired id, keep searching*/
		while (ce && ce->cid>id){
			last_ce = ce;
			ce = last_ce->next;
		}
		/*find the specific id*/
		if (ce && ce->cid == id) {
			LAST_FOUND_CE = ce;
			PRE_LAST_FOUND_CE = last_ce;
			return 1;//found the CE
		} 
		else{
			/*no scan found, return an error message!*/
			mexErrMsgTxt("Connection does not exist!\n");
			return 0;// No CE found
		}
	}
		return 0;
}


/*target the connection to specific peer*/
int CE_check(char*peerName)
{
	int tag;
	cep ce;
	cep pre_ce;
	ce=CE_LIST_HEAD;
	while(ce){
		/*searching from SE_LIST_HEAD to the tail*/
		tag=strcmp(ce->peer,peerName);/*comapre the peer name*/
		if(tag==0) {//same peer 
			L_CE=ce;/*set the LAST_FOUND_SE pointer*/
			return tag;/*return tag*/
			/*tag==0  same peer*/
		}
		else {//forward the pointer, keep searching
			pre_ce=ce;
			ce=pre_ce->next;
		}
	}
	return tag;
}



/* close and free a particular connection */
DLL_EXPORT void free_CE(int cid)
{
	int searchTag;
	cep last_ce;
	cep ce;
	searchTag = CE_search(cid);
	if(searchTag){
		ce = L_CE;
		last_ce = P_CE;
		/*if the connection is at the head of CE_LIST*/
		if(ce->cid == CE_LIST_HEAD->cid){	
			a_disconnect(ce->Connection,TRUE);
			if(a_errno) errTrap();
			CE_LIST_HEAD = ce->next;
		}
		else{
			/*The connectio is not in the head*/
			a_disconnect(ce->Connection,TRUE);
			if(a_errno) errTrap();
			last_ce->next = ce->next;
		}
		if(SPARQL_MODE==1){
			/*if the SPARQL_MODE is 1, free sparql functions objects*/
			free_oid(L_CE->sparqlFn);
			free_oid(L_CE->rdfInsertFn);
		}
		free_connection(ce->Connection);// free connection
		free(ce);
		L_CE = NULL;
		P_CE = NULL;
	}
	else mexErrMsgTxt("The targeted Connection does not exist!\n");
}


/*To free the connection list, usually called before existing MATLAB*/
DLL_EXPORT void free_CE_list(void)
{
	cep t_cep;
	t_cep = CE_LIST_HEAD;
	while(t_cep){
		CE_LIST_HEAD = t_cep->next;
		free_connection(t_cep->Connection);
		if (SPARQL_MODE)
			sparqlFinalize_fns(t_cep);
		free(t_cep);
		t_cep = CE_LIST_HEAD;
	}

}
////////////////////////////////////AMOS INITIALIZATIONS
/*Modification by Emily_He
* 2013-06-20*/

/*initializing AmosII system*/
int initialize(void)
{
	int error = 0;
	char* pAmosHome = getenv("AMOS_HOME");
	char *pAmosDmp;
	pAmosDmp=(char*)malloc(80*sizeof(char));
	if (!pAmosHome){ // throwing some kind of exception into MATLAB should be implemented!
		mexErrMsgTxt("Error: environment variable AMOS_HOME not set!"); 
	//	return 1;
	}
	else{
		//Initialize local Amos
		strcpy(pAmosDmp,pAmosHome);
		strcat(pAmosDmp,"/bin/ssdm.dmp");
		if (!AmosInitialized()) a_initialize(pAmosDmp,FALSE);	
		else error=a_initialize(pAmosDmp,TRUE);	
	}	
	AMOS_INIT=1;
	return error;	
}

/*Initializing Amos function object*/
int amos_init_fns(cep c)
{
	dcl_scan(t_scan);
	
	if (strcmp(c->peer,"")==0){// calling matlab functions is only available for embedded database
		a_extfunction("callmatlab--+", callmatlab_bbf);//binding
		//to create an amos foreign function so that amos can call matlab functions
		a_execute(c->Connection,t_scan,"create function callMatlab(Charstring fnName, Vector of Literal args) -> Literal as foreign 'callmatlab--+';",TRUE);
		if(a_errno){
			free_scan(t_scan);
			errTrap();
		}
	}
	free_scan(t_scan);
	return 1;
}

/*Amos initialization function
*input: hostid
*/
DLL_EXPORT void amosInit()
{
	int error = 0; //for error trapping
//	char* peerName=mxArrayToString(peer);
	
	if(AMOS_INIT !=0 ) mexErrMsgTxt("Amos system has been initialized!\n");// Amos system has been initialized
	else{	
		error = initialize(); // load driver and dump file
		if(!error|| error == -1){
		// creating a new connection to the peer		
		}
		else {
			mexErrMsgTxt("AmosII exception!\n");
		}
	}	
}


///////////////////////////////////////////AMOS QUERY

/*MARCOS*/
#define SEID SE_LIST_HEAD->sid
#define SETPL SE_LIST_HEAD->tpl
#define SEVEC SE_LIST_HEAD->vectorized
#define LFCE LAST_FOUND_CE
#define LFC LAST_FOUND_CE->Connection



/*validate the scan,if the scan is not empty
1) create a SE
2) insert the SE to the head of the SE list
3) set the scan in the SE
4) forward the first row of scan to the tuple of the SE
*/
int SE_insert(a_scan s)
{
	sep new_scan = dcl_ScanEnt();// decalring a new SE
	newSID = SE_COUNTER;// scan id =J;
	newScan = s;// decalre the scan in the SE
	new_scan->next = SE_LIST_HEAD;// insterting this SE to the head of SE_LIST
	SE_LIST_HEAD = new_scan;
	a_getrow( newScan , newTuple , TRUE );// get the first row in a scan and assign it to the tuple in SE
	if(a_errno){
		a_errno = 0;
		mexErrMsgTxt(a_errstr);
	}
	SE_COUNTER+=1;
	return newSID;
}


/*query execution, return the SE id*/
DLL_EXPORT int amosExecute(int Cid,mxArray* mx_query)
{
	int id;
	int tag;
	char* query=mxArrayToString(mx_query);// converting query from mxArray string to C string
	dcl_scan(t_scan);// secalring a tempory SE
	if(strlen(query)==0) mexErrMsgTxt("NO Query!\n");//checking if the query is empty
	tag = CE_search(Cid);// return the CE_search result
	if(tag==1){// the targeted scan is found
		a_execute(LAST_FOUND_CE->Connection,t_scan,query,TRUE);// executing the query
		if(a_errno){
			a_errno = 0;
			mexErrMsgTxt(a_errstr);
		}
		if(a_eos(t_scan)) {// checking if the result is empty, if it is, free the temporary scan
			free_scan(t_scan);
			id = 0;
		}
		else{//if it is not empty, forward the first row to the tuple in the SE
			id = SE_insert(t_scan);
			SEVEC = 0;// set the vectorize tag to 0; which means the result id from Amos query
		}		
	}
	else mexErrMsgTxt("No specific connection to AmosII system");
	return id;
}





///////////////////////////////////////////////AMOS SCAN MANIPULATION

/*ScanEntry Declaration: to allocate memory for a ScanEntry
*return: a pointer points to ScanEntry*/

/*decaring a SE*/
sep dcl_ScanEnt()
{
	sep new_scan;
	new_scan = (sep)malloc(sizeof(SE));
	newScan = a_init_scan();
	newTuple = a_init_tuple();//initialize a tuple in ScanEntry
	return new_scan;
}


/* ScanEntry Search: to search a ScanEntry with specific Scanid, and set the LAST_FOUND_SE to the specific ScanEntry
*input: a specific scan id
*return a boolean value
*1: found the specific SE, LAST_FOUND_SE points to the sep
*0: the specific scan is not found, LAST_FOUND_SE = NULL
*/

DLL_EXPORT int SE_search(int id)
{
	sep se = SE_LIST_HEAD;
	sep last_se = NULL;
	int search_done = 0; //tag to check id the SE exists or not
	if(id>SE_COUNTER || id<=0) mexErrMsgTxt("Non-existing SE!\n");// validating the id
	else{// searching the scan with particular id
		while (se && se->sid>id){
			last_se = se;
			se = last_se->next;
		}
		/*
		*if the targeted is found and is the head of SE_LIST, LAST_FOUND_SE points to the HEAD, and PRE_LAST_SE points to NULL
		*otherwise PRE_LAST_SE points to the previous SE of LAST_FOUND_SE
		*else return the LAST_FOUND_SE NULL 
		*/
		if (se && se->sid == id) {
			LAST_FOUND_SE = se;
			PRE_LAST_FOUND_SE = last_se;
			search_done = 1;
			return 1;
		} 
		else{
			LAST_FOUND_SE = NULL;
			PRE_LAST_FOUND_SE = NULL;
		//	mexErrMsgTxt("Non-existing SE!\n");
			search_done = 0;
			return 0;
		}
	}
	return search_done;
}

/*Checking if the end of scan is reached or not. If it is, free the scan automatically.
* input: scan id
* output: 1: end of scan is reached
* output: 0: not*/

DLL_EXPORT int scan_end(int id)
{
	int temp;
	if(id==0) return 1;
	if (!LAST_FOUND_SE || (LAST_FOUND_SE->sid!=id)) SE_search(id);
	if(LAST_FOUND_SE){
		temp = a_eos(LAST_FOUND_SE->scan);
		if(temp == 1){
			free_SE(LAST_FOUND_SE);
			return 1;
		}
		return 0;
	}	
	else return 0;
}

/*Getting the next row in a scan.
* input: the scan id
* output: 1: successfully done*/

DLL_EXPORT int scan_next_row(int id)
// to get the next row of a specific scan, if succeeds, return 0, else return 1
{
	if (!LAST_FOUND_SE || (LAST_FOUND_SE->sid!=id)) SE_search(id);
	if (LAST_FOUND_SE && !a_eos(LAST_FOUND_SE->scan)) 
	{
		a_nextrow(LAST_FOUND_SE->scan,TRUE); // Advance scan forward 
		if(a_errno) errTrap();
		if (!a_eos(LAST_FOUND_SE->scan)) {
			a_getrow(LAST_FOUND_SE->scan,LAST_FOUND_SE->tpl,FALSE); // Get current tuple in scan 	
			return 1;
		}
	}
	return 0;
}

/*Freeing a SE, simply freeing the memory allocated for the SE*/
void free_SE(sep free_se)
{
	if(P_SE){// checking the previous SE of the LAST_FOUND_SE, if it is NULL, the scan is the head of the SE_LIST
		P_SE->next = L_SE->next;
		free_scan(L_SE->scan);
		free_tuple(L_SE->tpl);
		free(L_SE);
		L_SE = NULL;
		P_SE = NULL;
	}
	else{// SE is not at the head of the SE_LIST
		SE_LIST_HEAD = L_SE->next;
		free_scan(L_SE->scan);
		free_tuple(L_SE->tpl);
		free(L_SE);
		L_SE = NULL;
		P_SE = NULL;
	}
}

/*freeing the particular SE*/
DLL_EXPORT void free_a_SE(int sid)
{
	SE_search(sid);
	free_SE(LAST_FOUND_SE);
}

/*freeing the entir SE_LIST, before existing MATLAB, in case of memory leak.*/
DLL_EXPORT void free_SE_list()
{
	sep t_sep;
	t_sep = SE_LIST_HEAD;
	while(SE_LIST_HEAD){
		SE_LIST_HEAD = t_sep->next;
		free_scan(t_sep->scan);
		free_tuple(t_sep->tpl);
		free(t_sep);
		t_sep = SE_LIST_HEAD;
	}
}


/*to validate a SE empty or not; 
*if the scan is empty, this function will free the ScanEntry automatically.*/

int SE_validation(sep new_scan)
{
	if(a_eos(newScan)){
		mexPrintf ("Scan is empty!\nScan ID 0!\n" );
		free_scan (newScan);
		free_tuple(newTuple);
		free(new_scan);
		return 0;
	}
	else{
		new_scan->sid = SE_COUNTER;
		a_getrow( newScan , newTuple , FALSE ); 
		new_scan->next = SE_LIST_HEAD;
		SE_LIST_HEAD = new_scan;
		SE_COUNTER+=1;
		return 1;
	}
}

/////////////////////////////////////////////////////GET AMOS_SCAN_ELEMENT


/////////////////////////////////////TUPLE INTERFACE
/*SCANTAG = 0 RETURN AMOSQL RESULT;
* SCANTAG = 1 RETURN SCISPARQL RESULT;
* SCANTAG = 2 RETURN SPARQLFUNCTION RESULT */

#define TYPE(tpl,pos) a_getelemtype(tpl,pos,FALSE)
#define TSIZE(tpl) a_getarity(tpl,FALSE)//tuple size
#define O_TYPE(o_data) a_datatype(o_data)
#define O_SIZE(o_data) a_arraysize(o_data)


mxArray *amos_getTplElement(a_tuple, int);
mxArray *amos_getTplSingleElement(a_tuple,int);
mxArray *amos_getTplSeqElement(a_tuple);
mxArray *amos_make_mx(oidtype);
mxArray *amos_make_mx_vector(a_tuple tpl);// a vector only contains numberic elements


/*Validating position is legal*/
int posCheck(a_tuple tpl,int pos)
{
	int size;
	size= TSIZE(tpl);
	if(pos<0 || pos>size) return 0;
	else return 1;
}

/*Counting the elements number of a tuple*/
int numberic_tplElement_count(a_tuple tpl)
{
	int counter,i, tag;
	tag = 0;
	i=a_getarity(tpl,TRUE);
	if(a_errno)	errTrap();
	for(counter=0;counter<i;counter++){
		if(TYPE(tpl,counter)==INTEGERTYPE||TYPE(tpl,counter)==REALTYPE){
		tag++;
		}
	}
		return tag;
}


/////////////////////////////Getting elements in tuples

/*Getting the element at a particular position in a tuple;
* output: data in amos regular type, e.g string, real, integer, time, boolean and a sequences*/
mxArray *amos_getTplElement(a_tuple tpl, int pos)
  {
	  mxArray *mx_elem=NULL;
	  int elemtype;//element type
	  a_tuple seq = a_init_tuple();

	  //to check if the position is valid
	  if (!posCheck(tpl,pos)){
		  mexWarnMsgTxt("Illegal position!\n");
	  }	
	  else{
		  // a single element, call amos_get_single_element.
		  elemtype=TYPE(tpl,pos);
		   if(elemtype!=ARRAYTYPE) mx_elem=amos_getTplSingleElement(tpl,pos);
		  else{
			  // a vector, call amos_getTplSeqElement function
			  a_getseqelem(tpl,pos,seq,TRUE);
			  if(a_errno) errTrap();
			  mx_elem=amos_getTplSeqElement(seq);
		  }
	  }
	  free_tuple(seq);
	  return mx_elem;
  }
  

/*to get amos type single element in a tuple*/
mxArray *amos_getTplSingleElement(a_tuple tpl,int pos)
{
	mxArray *single_elem;
	dcloid(o_data);
	a_setf(o_data, a_getelem(tpl,pos,TRUE));
	if(a_errno)	errTrap();
	single_elem = amos_make_mx(o_data);
	free_oid(o_data);
	return single_elem;
}

/*To get the sequence element*/
mxArray *amos_getTplSeqElement(a_tuple tpl)
/*Get every single element of a list recursively.*/
{
	mxArray *mx_seq;
	int i,counter,tag;
	i=a_getarity(tpl,TRUE);
	if(a_errno) errTrap();
	// Count how many numeric elements in a list
	tag = numberic_tplElement_count( tpl);

	//return a mxArray nnumeric matrix if all elements are numbers
	if(tag==i)	return amos_make_mx_vector(tpl);

	//return a cell holding differnt data types
	else{
		dcl_tuple(t_tpl);
		mx_seq=mxCreateCellMatrix(1,i);
		for(counter=0;counter<i;counter++){
			if(TYPE(tpl,counter)!=ARRAYTYPE){
				//get single element in a list
				mxSetCell (mx_seq,counter,amos_getTplSingleElement(tpl,counter) );	
			}
			else{
				//get a list in a list
				a_getseqelem(tpl,counter,t_tpl,FALSE );
				mxSetCell(mx_seq,counter,amos_getTplSeqElement(t_tpl));
			}
		}
		free_tuple(t_tpl);
		return mx_seq;
	}
}

/*Converting the tuple only holding numberic number to MATLAB vector*/
mxArray *amos_make_mx_vector(a_tuple tpl)
{/*a vector is only a vector contains numberic elements, which is only mapped to vector type in matlab
 This function is called from amos_getSeqElement.*/
	int i,counter;
	double *vector;
	mxArray *seqvec;
	i=a_getarity(tpl,FALSE);// to get the element number in a tuple
	seqvec=mxCreateDoubleMatrix(1,i,mxREAL);
	vector=mxGetPr(seqvec);
	//return a vector to matlab ws
	for(counter=0;counter<i;counter++){
		if(TYPE(tpl,counter)==INTEGERTYPE){
			*vector=a_getintelem(tpl,counter,TRUE);
			if(a_errno)	errTrap();
			vector++;
		}
		else{
			*vector=a_getdoubleelem(tpl,counter,TRUE);
			if(a_errno)	errTrap();
			vector++;
		}
	}
	return seqvec;
}



///////////////////////////////////////////////OIDTYPE INTERFACE

/* functions converting oidtype to mxArray, not with a_tuple*/
mxArray *amos_getObjElement(oidtype);
mxArray *make_mx(oidtype);
mxArray *make_mx_list(oidtype);

/*Geting the element at the specific position of a scan
* input: scan id, position
* output: the mxArray data*/
DLL_EXPORT mxArray *amosGetElement(int id, int pos)
{
	mxArray *mx_element = NULL;
	dcl_oid(o_data);
	int seTag;
	if(!LAST_FOUND_SE || LAST_FOUND_SE->sid != id )  seTag = SE_search (id);// search the targeted scan
	else if (LAST_FOUND_SE->sid == id)	seTag = 1;// the scan is found 
	if(seTag){
		if(LAST_FOUND_SE->vectorized==0){// ensure the scan holding results from Amos query
				a_assign(o_data,a_getobjectelem(lastFoundTpl,pos, TRUE));
				if(a_errno)	errTrap();
				mx_element = amos_getObjElement(o_data);// calling amos_getObjElement to get the mxArray data
		}
	}
	free_oid(o_data);
	return mx_element;
}

/*function is used for counting how many single numeric elements in a amos list,
* for allocating memeory for the new created array*/
int numberic_objElement_count(oidtype o_vector)
{
	int counter,i, tag;
	tag = 0;
	i=O_SIZE(o_vector);
	for(counter=0;counter<i;counter++){
		if(O_TYPE(a_elt(o_vector,counter))==INTEGERTYPE||O_TYPE(a_elt(o_vector,counter))==REALTYPE){
		tag++;
		}
	}
	
	return tag;
}

/*Converting Amos oidtyoe data to mxArray;
* it maps Amos regular data type to MATLAB data type,
* e.g string, real, integer, time, boolean and a vector*/
mxArray *amos_getObjElement(oidtype o_data)
{
	int elemtype;//element type
	mxArray *mx_elem=NULL;
	elemtype = O_TYPE(o_data);// check the oidtype data type
	if(elemtype!=ARRAYTYPE) mx_elem=amos_make_mx(o_data);
	else mx_elem = make_mx_list(o_data);
	return mx_elem;
}
  


////////////////////////////////////////////////////////AMOS_MAKE_OID(MXARRAY) 

/*amos_make_oid_** functions convert a mxArray to an oidtyped data. 
* data should be in one of these type, time, real, integer, vector, boolean and string*/

oidtype amos_make_oid_real(mxArray*);
oidtype amos_make_oid_int(mxArray*);
oidtype amos_make_oid_string(mxArray*);
oidtype amos_make_oid_logic(mxArray*);
oidtype amos_make_oid_time(mxArray*);
oidtype amos_make_oid_list(mxArray*);


/*converting mxArray data to Amos oidtype data*/
oidtype amos_make_oid(mxArray *mx_arg)
{
	if(mxIsDouble(mx_arg))	return amos_make_oid_real(mx_arg);
	// integer data
	else if(mxIsInt64(mx_arg) || mxIsInt32(mx_arg) || mxIsInt16(mx_arg) || mxIsInt8(mx_arg))	return amos_make_oid_int(mx_arg);
	// making string_oid
	else if(mxIsChar(mx_arg))	return amos_make_oid_string(mx_arg);	
	// make logical_oid
	else if(mxIsLogical(mx_arg))	return amos_make_oid_logic(mx_arg);
	// make time_oid
	else if(mxIsClass(mx_arg, "TIMEVALTYPE"))	return amos_make_oid_time(mx_arg);
	//cell as a list
	else if(mxIsCell(mx_arg))	return amos_make_oid_list(mx_arg);
//	else if(mxIsEmpty(mx_arg)) return nil;
	else return 0;
}


/*Converting mxArray TIMEVALTYPE data to Amos time vector*/
oidtype amos_make_oid_time(mxArray* mx_arg)
{
	double p[6];
	double *elem_pointer;
	int counter;
	int second;
	int msecond;
	mxArray * mx_time;
	mx_time = mxGetProperty(mx_arg, 0, "TimeVector");
	counter = mxGetNumberOfElements(mx_time);
	if(counter !=6 )	mexErrMsgTxt("Invalid TimeVector!\n");

	elem_pointer = mxGetPr(mx_time);
	for( counter=0; counter<6; counter++){
		 p[counter] = *elem_pointer;
		 elem_pointer++;
	}//to get the first 5 elements in an amos time vector:year, month, day, hour, minute
	 second = (int)p[5];// to get matlab second
	 msecond = (int)((p[5] - (double)second)*1000);// to get millisecond.
	 return make_timeval((int)p[0], (int)p[1], (int)p[2], (int)p[3], (int)p[4], second, msecond);//return an amos time vector with 7 elements
}


/*make integer oidtype data*/
oidtype amos_make_oid_int(mxArray* mx_arg)
{
	int *arg_int;
	arg_int = mxGetData(mx_arg);
	return mkinteger(*arg_int);
}


/* make real oidtyped data*/
oidtype amos_make_oid_real(mxArray *mx_arg)
{
	double *arg_double;	
	arg_double = mxGetData(mx_arg);
	return mkreal(*arg_double);
}


/*make string oidtyped data*/
oidtype amos_make_oid_string(mxArray *mx_arg)
{
	char *arg_simple_str;
	arg_simple_str = mxArrayToString(mx_arg);
	return make_unistring(mkstring(arg_simple_str), NULL);
}

/* make logic oidtyped data*/
oidtype amos_make_oid_logic(mxArray *mx_logic)
{
	bool *logical;
	logical = mxGetLogicals(mx_logic);
	if(*logical) return a_true;
	else return a_false;
}

/*Constructing Amos list buy providing a mxArray cell*/
oidtype amos_make_oid_list(mxArray *mx_cell)
{
	dcl_oid(o_element);
	dcl_oid(o_list);
	mwSize counter;
	mxArray *i_elem;
	// checking the size of the mxArray cell
	mwSize list_size = mxGetNumberOfElements(mx_cell);
	for(counter=0; counter< list_size; counter++){
		// getting the element at each position
		i_elem = mxGetCell(mx_cell, counter);
		if(!mxIsCell(i_elem)){//if the element is a single element, call amos_make_oid function and assign an object handle
			a_assign(o_list,new_array(list_size,o_element));
			a_seta(o_list,counter,amos_make_oid(i_elem));
		}
		else{// recursively call itself to get all elements 
			a_assign(o_list,amos_make_oid_list(i_elem));
		}
	}
	free_oid(o_element);
	return o_list;
}




 //////////////////////////////////////////////////////AMOS MAKE_MX FUNCTIONS(OIDTYPE)

/*Constructing all oidtype elements to mxArray element*/
mxArray *amos_make_mx_real(oidtype);
mxArray *amos_make_mx_integer(oidtype);
mxArray *amos_make_mx_string(oidtype);
mxArray* amos_make_mx_timeval_obj(oidtype);
mxArray *amos_make_mx_objvector(oidtype);

/* All amos_make_mx_ functions except amos_make_mx_vector are called from amos_getSingleElement function.*/
mxArray *amos_make_mx(oidtype o_data)
{
	int data_type;
	mxArray *mx_true; //mx_boolean values
	mxArray *mx_false;
	mx_true = mxCreateLogicalScalar(1);
	mx_false = mxCreateLogicalScalar(0);
	data_type = a_datatype(o_data);
	//real data
	if(data_type==REALTYPE)	return amos_make_mx_real(o_data);
	//integer data
	else if(data_type==INTEGERTYPE)	return amos_make_mx_integer(o_data);
	//string data
	else if(data_type ==STRINGTYPE)	return amos_make_mx_string(o_data);
	//	TIMEVALTYPE
	else if (data_type == TIMEVALTYPE) return amos_make_mx_timeval_obj(o_data);	
	//boolean_true
	else if(o_data==a_true) return mx_true;
	else if(o_data==a_false) return mx_false;
	//NIL value
	else if(data_type==nil) return 0;
	else return 0;
}

/*convert oidtype list to mxArray cell/vector
* 1) if the oidtype data is a list holding different datatype, a cell is created
* 2) if the oidtype is a list with only single numbers, a vector is made*/
mxArray *amos_make_mx_list(oidtype o_data)
{
	mxArray *mx_seq;// a sequence to hold input array
	int i,counter,tag;
	i=O_SIZE(o_data);// size of the array
	mexPrintf("the size of the vector is %d\n",i);
	tag = numberic_objElement_count(o_data);// to check how many numeric element in a list
	if(tag==i)	return amos_make_mx_objvector(o_data);// if the number is as the same as element number, return a numeric vector to matlab.

	else{//else return a mxCell which contains data in different types
		dcloid(o_element); // declare an object handle
		mx_seq=mxCreateCellMatrix(1,i); // allocate memory for mxArray cell
		for(counter=0;counter<i;counter++){// check every single element in an array
			a_setf(o_element, a_elt(o_data, counter));
			if(O_TYPE(o_element)!=ARRAYTYPE) mxSetCell(mx_seq,counter,amos_make_mx(o_element));//if the single element is not an array
			else mxSetCell(mx_seq,counter,amos_make_mx_list(o_element));// recursively call itself 
		}
		free_oid(o_element);
		return mx_seq;
	}
}


/*convert a list with single numbers to a matalb native vector. 
* input: oidtype
* output: mxArray vector*/
mxArray *amos_make_mx_objvector(oidtype o_vector)
{
	int i,counter;
	double *vector;
	mxArray *seqvec;
	dcloid(o_element);
	i=O_SIZE(o_vector);// to get the element number in a tuple
	seqvec=mxCreateDoubleMatrix(1,i,mxREAL);
	vector=mxGetPr(seqvec);
	for(counter=0;counter<i;counter++){
		a_setf(o_element,a_elt(o_vector,counter));
		if(O_TYPE(o_element)==INTEGERTYPE){
			*vector=(double) getinteger(o_element);
			vector++;
		}
		else{
			*vector=getreal(o_element);
			vector++;
		}
	}
	free_oid(o_element);
	return seqvec;
}

/*return a matlab mxArray string*/
mxArray *amos_make_mx_string(oidtype o_string)
{
	char *string;
	mxArray *new_mx_string;
	string = getstring(o_string);
	new_mx_string = mxCreateString(string);
	return new_mx_string;
}

/*both oidtyped real and integer data will be returned as double to matlab workspace*/
mxArray *amos_make_mx_integer(oidtype o_real)
{
	double *d;
	mxArray *mx_scalar;
	mx_scalar = mxCreateDoubleMatrix(1,1,mxREAL);
	d = mxGetPr(mx_scalar);
	*d = (double)getinteger(o_real);
	return mx_scalar;
}

/*make a real number*/
mxArray *amos_make_mx_real(oidtype o_real)
{
	double *d;
	mxArray *mx_scalar;
	mx_scalar = mxCreateDoubleMatrix(1,1,mxREAL);
	d = mxGetPr(mx_scalar);
	*d = getreal(o_real);
	return mx_scalar;
}

/* construct matlab time vector, in which there are six elements in double type*/
mxArray* amos_make_mx_timeval_obj(oidtype o_time)
{
	double *time=NULL;
	int i;
	mxArray *new_mx_time;
	mxArray *new_mx_time_obj;
	dcl_oid(oid_time);

	a_setf(oid_time,timeval_to_vector(o_time)); 
	// calling matlab function "TIMEVALTYPE" to create a time object in matlab workspace, and this object
	mexCallMATLAB(1, &new_mx_time_obj, 0, NULL, "TIMEVALTYPE");
	new_mx_time = mxCreateDoubleMatrix(1,6, mxREAL);// allocate memeory for time vector
	time=mxGetPr(new_mx_time); // set the time point to mxArray

	for( i=0 ; i<5 ; i++){
		time[i] =(double) getinteger(a_elt(oid_time, i));
	}// to get year, month, day, hour, minutes
	time[5] = (double)getinteger(a_elt(oid_time, 6))/1000 + (double)getinteger(a_elt(oid_time, 5));// to get matlab second with millisecond
	mxSetProperty(new_mx_time_obj, 0 , "TimeVector", new_mx_time);// to set the property of new created "TIMEVALTYPE" object with new_mx_time

	free_oid(oid_time);
	return new_mx_time_obj;
}







/********************************************************************************************/
/*                                               SPARQL INTERFACE                           */
/********************************************************************************************/
oidtype make_oid(mxArray *);
oidtype make_oid_uri(mxArray*);


/////////////////////////////////////////////////////SPARQL INITIALIZATION AND FINZALIZATION
/*sparql functions initialization.*/
/*
* Modified by Emily_He 2013-06-20
*/
void sparql_init_fns(cep c) 
{
		c->sparqlFn = a_getfunction(c->Connection, "charstring.sparql->vector", TRUE);// initializing a function for sparql query
		c->rdfInsertFn = a_getfunction(c->Connection, "literal.literal.literal.rdf:insert->boolean", TRUE);//initializing a function for creating rdf data
		//to initializing a function to call matlab
		if (strcmp(c->peer,"")==0) 
			eval_forms(varstacktop, "(sparql-add-extender-engine \"matlab\" (f/l (fnname args) (concat \"select callmatlab('\" fnname \"', {\" (strings-to-string args \"\" \", \" \"\") \"})\")))");
		if(a_errno){
			mexErrMsgTxt(a_errstr);
			a_errno = 0;
		}
}

/*Amos initialization, sparql functions initialization
* create a new connection and insert it to the head of connection list*/

/*The initialization function is used for initializing system and specifying host*/
DLL_EXPORT void sparqlInit() 
{
	if(SPARQL_INIT==1) mexErrMsgTxt("SSDM has been initialized! Want to create a new connection?\n");
	amosInit();
	SPARQL_INIT = 1;
	SPARQL_MODE = 1;
}

/*Free the SPARQL function handles*/
void sparqlFinalize_fns(cep c)
{
	free_oid(c->sparqlFn);
	free_oid(c->rdfInsertFn);
}

DLL_EXPORT void systemFinalize()
{
	free_SE_list();
	free_CE_list();
	AMOS_INIT=0;
	SPARQL_INIT=0;
	SPARQL_MODE=0;
}
/////////////////////////////////////////////////////////RDFINSERT FUNCTION

/*to create rdf data, first two data must be URI type*/	
DLL_EXPORT void sparqlRdfInsertFn(int id,mxArray *mx_arg0, mxArray *mx_arg1, mxArray *mx_arg2)
{
	dcl_scan(tscan);
	dcl_tuple(arg);
	mwSize arg2_dim;// for nmatype
	arg2_dim = mxGetNumberOfDimensions(mx_arg2);	
	a_newtuple(arg,3, TRUE);
	CE_search(id);
	if(a_errno)	{
		free_scan(tscan);
		free_tuple(arg);
		errTrap();
	}
	
	//check if the first 2 args are URI type
	if(mxIsClass(mx_arg0,"URITYPE") && mxIsClass(mx_arg1,"URITYPE")){
		oidtype a_new_uri0;
		oidtype a_new_uri1;
		a_new_uri0 = make_oid_uri(mx_arg0);
		a_new_uri1 = make_oid_uri(mx_arg1);
		a_setobjectelem(arg, 0, a_new_uri0, TRUE);
		if(a_errno)	{
			free_scan(tscan);
			free_tuple(arg);
			errTrap();
		}
		a_setobjectelem(arg, 1, a_new_uri1, TRUE);
		if(a_errno)	{
			free_tuple(arg);
			free_scan(tscan);
			errTrap();
		}
	}
	else mexErrMsgTxt("First two arguements have to be URITYPE!\n");
	a_setobjectelem(arg, 2, make_oid(mx_arg2),TRUE);	
	if(a_errno)	{
		free_tuple(arg);
		free_scan(tscan);
		errTrap();
	}

	if(CE_LIST_HEAD){
		a_callfunction(L_CE->Connection, tscan, L_CE->rdfInsertFn, arg, TRUE);
		if(a_errno)	{
			free_tuple(arg);
			free_scan(tscan);
			errTrap();
		}
	}
	free_scan(tscan);
	free_tuple(arg);

}

///////////////////////////////////////////////////////////////////SPARQL QUERY

/*execute a SPARQL query
* 1)CE is checked
* 2)check the scan holding the result is empty or not
*	1.yes, free the scan
*	2.no, create a SE and insert the SE to the head of the list*/
int exeSparql(cep c, char* query) 
{ 
	dcl_tuple(arg);
	int id;
	dcl_scan(t_scan);
	/*create a new tuple for holding one element*/
	a_newtuple(arg, 1, FALSE); 
	a_setstringelem(arg, 0, query, FALSE);
	a_callfunction(c->Connection, t_scan, c->sparqlFn, arg, TRUE);
	if(a_errno){
		free_tuple(arg);
		free_scan(t_scan);
		errTrap();
	}
	if(a_eos(t_scan)) {
		free_scan(t_scan);
		id = 0;
	}
	else {
		id = SE_insert(t_scan);
		SEVEC = 1;
		}		
	
	free_tuple(arg);
	return id;
}

DLL_EXPORT int sparqlExecute(int cid, mxArray *mx_query)
//to call exeSparql without pass a_connection as an arguement
{
	char* query;
	query=mxArrayToString(mx_query);
	if(CE_search(cid)==1) return exeSparql(L_CE, query);
	else {
		mexErrMsgTxt("No connection!\n");	
		return 0;
	}
}



/////////////////////////////////////////////////CALL SPARQL FUNCTIONS

DLL_EXPORT int sparqlFnExe(int cid,const char* fnname, mxArray *mx_arg_cell) 
{
	char* amosFnName;
	int id;
	mwSize counter;
	mxArray *i_arg;
	dcl_tuple(arg);
	dcl_oid(fn);
	dcl_scan(t_scan);
	// check connection
	if(CE_search(cid)){
	// Obtain function pointer
		amosFnName = malloc(5 + strlen(fnname));
		strcpy(amosFnName, "rdf:");
		strcat(amosFnName, fnname);
		a_setf(fn, a_getfunction(L_CE->Connection,amosFnName,TRUE));
		if(a_errno){
			mexErrMsgTxt(a_errstr);
			a_errno = 0;
		}
		if(mxIsCell(mx_arg_cell)){
			mwSize arg_size = mxGetNumberOfElements(mx_arg_cell);
			a_newtuple(arg, arg_size, FALSE);
			for(counter=0; counter< arg_size; counter++){
				i_arg = mxGetCell(mx_arg_cell, counter);
				a_setobjectelem(arg, counter, make_oid(i_arg), FALSE);
			}
			a_callfunction(L_CE->Connection, t_scan, fn, arg, TRUE); // call a_callfunction to execute the sparql function
			if(a_errno){
				a_errno = 0;
				mexErrMsgTxt(a_errstr);
			}
			if(a_eos(t_scan)) {
				free_scan(t_scan);
				id = 0;
			}
			else {
				id = SE_insert(t_scan);
				SEVEC = 0;
				id = SEID;
			}
		}
		else {
			id = 0;
			mexErrMsgTxt("Wrong input format or SPARQL has not been initialized!\n");
		}
	}
	free_tuple(arg);
	free_oid(fn);
	return id;
}


////////////////////////////////////////////SPARQL_GET_ELEMENT FUNCTIONS//////////////////////////////////////////////


////////////////////////////////////////////TUPLE INTERFACE
mxArray *sparql_getTplElement(a_tuple, int);
mxArray *sparql_getTplSingleElement(a_tuple,int);
mxArray *sparql_getTplSeqElement(a_tuple);
mxArray *make_mx(oidtype);
mxArray *amos_make_mx_vector(a_tuple tpl);



mxArray *sparql_getTplElement(a_tuple tpl, int pos)
 {// this function beheaves like amos_get_element, except it calls sparql_getSeqElement and sparql_getSingleElement to get SSDM defined data

	  mxArray *mx_elem=NULL;
	  int elemtype;//element type
	  dcl_tuple(seq);
	  elemtype=TYPE(tpl,pos);
		if(elemtype!=ARRAYTYPE) mx_elem=sparql_getTplSingleElement(tpl,pos);
		else{
			a_getseqelem(tpl,pos,seq,TRUE);
			if(a_errno){
				free_tuple(seq);
				errTrap();
			}
			mx_elem=sparql_getTplSeqElement(seq);
		}

	  free_tuple(seq);
	  return mx_elem;
  }
  



mxArray *sparql_getTplSingleElement(a_tuple tpl,int pos)
// this function can be considered as a extension of amos_getSingleElement by call make_mx function, so that this function can map all the amos data type
{
	dcl_oid(o_data);
	mxArray *mx_element;
	a_setf(o_data,a_getelem(tpl,pos,TRUE));
	if(a_errno){
		free_oid(o_data);
		errTrap();
	}
	mx_element = make_mx(o_data);
	free_oid(o_data);
	return mx_element;
}


/*this function deals with both AmosII regular data and SSDM defined data type*/
mxArray *sparql_getTplSeqElement(a_tuple tpl)
{
	int i,counter,tag;
	i=a_getarity(tpl,FALSE);// to get the element number in a tuple
	tag = numberic_tplElement_count(tpl);// call this function to see how many single numeric elements in a list

	if(tag==i)	return amos_make_mx_vector(tpl);//if all elements in a tuple are numberic elements, return a numberic vector
	else{
		mxArray *mx_seq;
		a_tuple t_tpl;
		t_tpl=a_init_tuple();
		mx_seq=mxCreateCellMatrix(1,i);
		for(counter=0;counter<i;counter++){
			if(TYPE(tpl,counter)!=ARRAYTYPE){
				mxSetCell (mx_seq,counter,sparql_getTplSingleElement(tpl,counter ) );	// to get single sparql tyoed data
			}
			else{
				a_getseqelem(tpl,counter,t_tpl,TRUE);
				if(a_errno){
					free_tuple(t_tpl);
					errTrap();
				}
				mxSetCell(mx_seq,counter,sparql_getTplSeqElement(t_tpl));// recursively calling the sparql_getSeqElement function
			}
		}
		free_tuple(t_tpl);
		return mx_seq;
	}
}


////////////////////////////////////////////////// OIDTYPE INTERFACE
mxArray *sparql_getObjElement(oidtype);
mxArray *make_mx(oidtype);
mxArray *make_mx_list(oidtype);


DLL_EXPORT mxArray* sparqlGetElement(int id, int pos)//sparql
{ 
	mxArray *mx_element = NULL;
	dcl_oid(o_data);
	int seTag;

	if(!LAST_FOUND_SE || LAST_FOUND_SE->sid != id )  seTag = SE_search (id);

	else if (LAST_FOUND_SE->sid = id)	seTag = 1;

	if (seTag){
		if(LAST_FOUND_SE->vectorized == 1){
			/* result of sparql query is only returned as a list, which is the only one element in a tuple. 
			So that to get the element with a specific position, the list should be reassigned to a tuple*/
		
			dcl_tuple(temp_tpl);
			a_getseqelem( LAST_FOUND_SE->tpl,0, temp_tpl, TRUE);// to get the first element as a tuple. 
			if(a_errno){
				free_tuple(temp_tpl);
				errTrap();
			}
			a_assign(o_data,a_getobjectelem( temp_tpl,pos, TRUE));// get the element at pos as an object
			if(a_errno)	{
				free_oid(o_data);
				free_tuple(temp_tpl);
				errTrap();
			}
			mx_element = sparql_getObjElement(o_data);
			free_tuple(temp_tpl);	
		}

		else{// results are generated from Amos query or SciSPARQL function, ina list form with separated elements
			/*
			if(LAST_FOUND_SE->vectorized==0){
				a_assign(o_data,a_getobjectelem( lastFoundTpl,pos,TRUE));
				if(a_errno) {
					free_oid(o_data);
					errTrap();
				}
				mx_element = amos_getObjElement(o_data);	
			}
			*/
			//else if(LAST_FOUND_SE->vectorized==2){
				a_assign(o_data,a_getobjectelem(lastFoundTpl,pos, TRUE));
				if(a_errno)	{
					free_oid(o_data);
					errTrap();
				}
				mx_element = sparql_getObjElement(o_data);
			}	
		}
//	}
	free_oid(o_data);
	return mx_element;
}



mxArray *sparql_getObjElement(oidtype o_data)
 {// this function beheaves like amos_get_element, except it calls sparql_getSeqElement and sparql_getSingleElement to get SSDM defined data

	  mxArray *mx_elem=NULL;
	  int elemtype;//element type
	  elemtype = O_TYPE(o_data);
	  if(elemtype!=ARRAYTYPE) mx_elem=make_mx(o_data);
	  else mx_elem = make_mx_list(o_data);
	  return mx_elem;
  }
  


///////////////////////////////////////////////////////////////////MAKE OIDTYP DATA
oidtype make_oid_nma(mxArray*);	
oidtype make_oid_uri(mxArray*);
oidtype make_oid_typedRdf(mxArray*);
oidtype make_oid_unistring(mxArray*);
oidtype make_oid_list(mxArray*);
oidtype amos_make_oid(mxArray*);




oidtype make_oid(mxArray* mx_arg)
// wrapping all make_oid_ functions together
{	
	if(mxIsDouble(mx_arg)){
		mwSize elem_number;
		elem_number = mxGetNumberOfElements(mx_arg);
		if(elem_number == 1)	return amos_make_oid(mx_arg);	// only a single numeric element, mapping it to amosII numeric number
		else{			
			
			return make_oid_nma(mx_arg);
		}// otherwise, make_oid_nma data type
	}
	else if(mxIsClass(mx_arg,"URITYPE")) return make_oid_uri(mx_arg);

	else if(mxIsClass(mx_arg,"TYPEDRDFTYPE")) return make_oid_typedRdf(mx_arg);

	else if(mxIsClass(mx_arg,"UNISTRINGTYPE")) return make_oid_unistring(mx_arg);
	
	else if(mxIsCell(mx_arg)) return make_oid_list(mx_arg);
	
	else return amos_make_oid(mx_arg);// if the mxArray data is amosII type, call amos_make_oid
}




oidtype make_oid_list(mxArray *mx_cell)
{
	dcl_oid(o_element);
	dcl_oid(o_list);
	mwSize counter;
	mxArray *i_elem;
	
	mwSize list_size = mxGetNumberOfElements(mx_cell);
	
	for(counter=0; counter< list_size; counter++){
		i_elem = mxGetCell(mx_cell, counter);
		if(!mxIsCell(i_elem)){
			a_assign(o_list,new_array(list_size,o_element));
			a_seta(o_list,counter, make_oid(i_elem));
		}
		else{
			a_assign(o_list, make_oid_list(i_elem));
		}
	}
	free_oid(o_element);
	return o_list;
}


oidtype make_oid_typedRdf(mxArray *mx_arg)
// create typedRDF data
{
	char * rdf_literal;
	char * rdf_datatype;

	mxArray *mx_rdf_literal=NULL;
	mxArray *mx_rdf_datatype=NULL;

	mx_rdf_literal = mxGetProperty(mx_arg, 0, "Literal");
	mx_rdf_datatype = mxGetProperty(mx_arg, 0,"DataType");

	if(!mxIsChar(mx_rdf_literal)||!mxIsChar(mx_rdf_datatype)) mexErrMsgTxt("Properties of TYPEDRDFTYPE should be string!\n");

	rdf_literal = mxArrayToString(mx_rdf_literal);
	rdf_datatype = mxArrayToString(mx_rdf_datatype);
	return make_typedrdf(mkstring(rdf_literal), make_uri(rdf_datatype));				
}



oidtype make_oid_unistring(mxArray *mx_arg)
//create unistring data 
{
	char *unistr_str;
	char *unistr_langtag;

	mxArray *mx_unistr_str = NULL;
	mxArray *mx_unistr_langtag = NULL;

	mx_unistr_str =mxGetProperty(mx_arg, 0, "String");
	mx_unistr_langtag = mxGetProperty(mx_arg, 0, "LangTag");

	if(!mxIsChar(mx_unistr_str)||!mxIsChar(mx_unistr_langtag))	mexErrMsgTxt("Properties of UNISTRING should be string!\n");

	unistr_str = mxArrayToString(mx_unistr_str);
	unistr_langtag = mxArrayToString(mx_unistr_langtag);
	return make_unistring(mkstring(unistr_str), unistr_langtag);
}




oidtype make_oid_uri(mxArray *mx_arg)
//create uri data
{
	char *uri_id;
	mxArray *mx_uri_id;
	mx_uri_id = mxGetProperty(mx_arg, 0, "UriID");

	if(!mxIsChar(mx_uri_id)) mexErrMsgTxt("UriID should be string!\n");
	
	uri_id = mxArrayToString(mx_uri_id);
	return make_uri(uri_id);
}




oidtype make_oid_nma(mxArray *mx_arg)
//make oidtype nma data, input is a mxArray
{
	dcl_oid(new_oid_nma); 
	mwSize 	d, page, elements_per_page, total_number_of_pages;
	mwSize ndims = mxGetNumberOfDimensions(mx_arg);
	const mwSize *dims_array = mxGetDimensions(mx_arg);	
	double * elem;
	elem = mxGetPr(mx_arg);// to get the pointer of the first element in the mxArray
	new_oid_nma = make_nma0(ndims);//set dimension of bma
	total_number_of_pages = 1;
	elements_per_page = dims_array[0]*dims_array[1];// to get the number of elements in one page

	for(d = 0; d<ndims; d++){
		nma_setdim(new_oid_nma, d, dims_array[d]);
		if(d!=0 && d!=1) total_number_of_pages *= dims_array[d];
	}// to get the number of pages

	nma_init(new_oid_nma, NMA_DOUBLE, 0);
	nma_iter_reset(new_oid_nma);
	//to access every page in a multiple dimension array
	for (page=0; page < total_number_of_pages; page++) {
		mwSize row;
      // On each page, walk through each row. 
	for (row=0; row<dims_array[0]; row++) {
			mwSize column;     
			mwSize index = (page * elements_per_page) + row;
		// Walk along each column in the current row, and access every element
		for (column=0; column<dims_array[1]; column++) {
				*(double*)nma_iter2pointer(new_oid_nma) = elem[index];
				nma_iter_next(new_oid_nma);
				index += dims_array[0];
			}
		}
	}
	return new_oid_nma;
}



/////////////////////////////////////////////MAKE MXARRAY DATA
mxArray *amos_make_mx(oidtype);
mxArray *make_mx_unistring_obj(oidtype);
mxArray * make_mx_uri_obj(oidtype);
mxArray * make_mx_typedRdf_obj(oidtype);
mxArray * make_mx_nma(oidtype);
mxArray *amos_make_mx_objvector(oidtype);



mxArray *make_mx(oidtype o_data)
// wrapping all make_mx_ functions together, including amos_make_mx_ to map all the data type
{	
	int data_type;
	data_type = a_datatype(o_data);

	 if(data_type==UNISTRINGTYPE) return make_mx_unistring_obj(o_data);
	//URI TYPE
	else if (data_type==URITYPE) return make_mx_uri_obj(o_data);
	// TYPEDRDFTYPE
	else if (data_type==TYPEDRDFTYPE) return make_mx_typedRdf_obj(o_data);
	//NMATYPE
	else if(data_type==NMATYPE) return make_mx_nma(o_data);
	//AMOS REGULAR
	else return amos_make_mx(o_data); // else data are considered as amos default data type,call amos_make_mx, input is an oidtype data
}


mxArray *make_mx_list(oidtype o_data)
{
	mxArray *mx_seq=NULL;
	int i,counter,tag;
	i=O_SIZE(o_data);
	
	tag = numberic_objElement_count(o_data);// to check how many numeric element in a list
	if(tag==i)	return amos_make_mx_objvector(o_data);// if the number is as the same as element number, return a numeric vector to matlab.

	else{//else return a mxCell which contains data in different types
		
		mx_seq=mxCreateCellMatrix(1,i);
		for(counter=0;counter<i;counter++){
			dcl_oid(o_element);
			a_assign(o_element, a_elt(o_data, counter));
			if(O_TYPE(o_element)!=ARRAYTYPE) mxSetCell (mx_seq,counter,make_mx(o_element));	
			else mxSetCell(mx_seq,counter,make_mx_list(o_element));	
			free_oid(o_element);
		}
	}
	return mx_seq;
}




mxArray *make_mx_unistring_obj(oidtype o_unistr)
// making mx_unistring data, which is a matlab struct. Whenever calling this function, a new matlab struct object is created
{
	char *unistring_string;
	char *unistring_langtag;

	mxArray *new_mx_unistring_str=NULL;
	mxArray *new_mx_unistring_langtag=NULL;
	mxArray *new_mx_unistr_obj=NULL;
	mxArray *input=NULL;

	unistring_string = getstring(unistring_str(o_unistr));
	unistring_langtag = unistring_lang(o_unistr);
	
	new_mx_unistring_str = mxCreateString(unistring_string);

	if(strlen(unistring_langtag) == 0) return new_mx_unistring_str;// if the langTag is empty, return a simple string to matlab
	else{
		//otherwise, return a "UNISTRINGTYPE" object which contains a simple string and a language tag to matlab
		new_mx_unistring_langtag = mxCreateString(unistring_lang(o_unistr));
		mexCallMATLAB(1, &new_mx_unistr_obj, 0, &input, "UNISTRINGTYPE");// calling "UNISTRINGTYPE" to create a matlab structure object
		mxSetProperty(new_mx_unistr_obj, 0 , "String", new_mx_unistring_str);//set the property
		mxSetProperty(new_mx_unistr_obj, 0 , "LangTag", new_mx_unistring_langtag);// set the property
		return new_mx_unistr_obj;
	}
}

mxArray * make_mx_uri_obj(oidtype o_uri)
//making matlab uri data, which is a matlab structure object with one property named "UriID"
{
	char *new_uri;
	mxArray *new_mx_uri=NULL;
	mxArray *new_mx_uri_obj=NULL;
	mxArray *input=NULL;
	new_uri = uri_id(o_uri);
	new_mx_uri = mxCreateString(new_uri);
	mexCallMATLAB(1, &new_mx_uri_obj, 0, &input,"URITYPE");
	mxSetProperty(new_mx_uri_obj, 0 , "UriID" , new_mx_uri);
	return new_mx_uri_obj;
}


mxArray * make_mx_typedRdf_obj(oidtype o_rdf)
// create matlab typedRdf structure object which has two properties, namely, "Literal" and "DataType"
{
	char *rdf_literal;
	char *rdf_datatype;
	mxArray *new_mx_rdf_literal=NULL;
	mxArray *new_mx_rdf_datatype=NULL;
	mxArray *new_mx_rdf_obj=NULL;
	mxArray *input = NULL;

	rdf_literal = getstring(typedrdf_str (o_rdf));
	rdf_datatype = uri_id(typedrdf_typeuri(o_rdf));
	
	new_mx_rdf_literal = mxCreateString(rdf_literal);
	new_mx_rdf_datatype = mxCreateString(rdf_datatype);

	mexCallMATLAB(1,&new_mx_rdf_obj,0,&input,"TYPEDRDFTYPE");

	mxSetProperty(new_mx_rdf_obj, 0, "Literal", new_mx_rdf_literal);
	mxSetProperty(new_mx_rdf_obj, 0, "DataType", new_mx_rdf_datatype);
   
	return new_mx_rdf_obj;
}

// still have data copying

double* nma_rec(oidtype nma_data, double *nma, int level)
//access NMA element recurively
{
	int level_dim = nma_dim(nma_data,level);
	int idx;
	for (idx = 0; idx < level_dim; idx++) 
	{
		nma_iter_setidx(nma_data, level, idx);
		if (level+1 < nma_ndims(nma_data)) nma = nma_rec(nma_data,nma,level+1); // recursive call	
		else 
		{
			switch (nma_kind(nma_data)) 
			{
			case NMA_INTEGER:				
				*nma = *(int*)nma_iter2pointer(nma_data);
				break;
			case NMA_DOUBLE:				
				*nma = *(double*)nma_iter2pointer(nma_data);	
				break;
			}
			nma++;	
		}		
	}
	return nma;
}



mxArray *make_mx_nma(oidtype o_nma)
//to create mxArray nma data
{
	size_t dims[20];
	size_t count;
	size_t ndim = nma_ndims(o_nma); // dimension of data
	double *nma;
	double* nma_rec(oidtype,double*,int);
	mxArray * new_mx_nma=NULL;
	mxArray * temp_mx_nma=NULL;

	for(count=0 ; count < ndim; count++){
		dims[count] = nma_dim(o_nma, count);
	}

	temp_mx_nma = mxCreateNumericArray(ndim, dims, mxDOUBLE_CLASS, mxREAL);
	nma = mxGetData(temp_mx_nma);
	nma_rec(o_nma,nma,0);// to get oid_nma data recursively as a mxArray

	new_mx_nma = convert_to_column_nma(temp_mx_nma);
	mxDestroyArray(temp_mx_nma);
	return new_mx_nma;
	
}





/////////////////////////////////////////CALL MATLAB

#define MAX_FNNAME_LENGTH 64
//callout function implementation
void callmatlab_bbf(a_callcontext cxt, a_tuple tpl)
{
	int i, nargs;
	mxArray *lhs;//to hold the output element from the matlab function
	mxArray **rhs;// to hold the input argument for MATLAB function
	char fnName[MAX_FNNAME_LENGTH+1];
	dcl_tuple(args);

	a_getseqelem(tpl, 1, args, FALSE);// pass the 1st element in tpl to args
	nargs = a_getarity(args, FALSE);//get the args number

	rhs = (mxArray**)malloc(nargs * sizeof(mxArray*));//allocate the memory for mxArray**

	for (i=0; i < nargs; i++)
		rhs[i] = make_mx(a_getobjectelem(args, i, FALSE)); // convert the arguments

	a_getstringelem(tpl, 0, fnName, MAX_FNNAME_LENGTH, FALSE);

	mexCallMATLAB(1, &lhs, nargs, rhs, fnName); // call MATLAB

	a_setobjectelem(tpl, 2, make_oid(lhs), FALSE); // convert the result

	a_emit(cxt, tpl, FALSE); // emit the result	
}



