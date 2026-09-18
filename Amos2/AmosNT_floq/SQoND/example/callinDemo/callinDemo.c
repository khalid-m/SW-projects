/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2012 Andrej Andrejev, UDBL
 * $RCSfile: callinDemo.c,v $
 * $Revision: 1.7 $ $Date: 2014/01/16 13:15:34 $
 * $State: Exp $ $Locker:  $
 *
 * Description: SciSPARQL callin interface demo
 * ===========================================================================
 * $Log: callinDemo.c,v $
 * Revision 1.7  2014/01/16 13:15:34  andan342
 * Using new signature for rdf:insert() - first argument is 0 to denote default graph
 * Added example on storing and retrieving timezone information in TIMEVAL
 *
 * Revision 1.6  2013/01/22 16:34:43  andan342
 * Added example of catching errors
 * Added example of defining SciSPARQL functions in C
 *
 * Revision 1.5  2012/12/21 14:26:16  torer
 * NULL
 *
 * Revision 1.4  2012/12/19 13:55:08  andan342
 * Added 'parametrized query' example, further refined the code
 *
 * Revision 1.3  2012/12/18 16:52:24  andan342
 * Updated to use a_true, a_false and time_to_vector()
 *
 * Revision 1.2  2012/12/15 01:12:12  andan342
 * Self-contained callin example demonstrating the creation and access w.r.t. each RDF datatype
 *
 * Revision 1.1  2012/12/13 20:53:21  andan342
 * Demo C application using SSDM callin interface
 *
 *
 ****************************************************************************/


/* REQUIREMENTS:                                                           */
/* Uses amos2.lib and ssdm.lib in $(AMOS_HOME)/bin directory               */
/* Include directories are $(AMOS_HOME)/C and $(AMOS_HOME)/SQoND/include   */
/* System PATH variable should include $(AMOS_HOME)/bin                    */
/* Command line parameter should be $(AMOS_HOME)/bin/ssdm.dmp              */


#include "callin.h" 
#include "callout.h" //only for defining a SciSPARQL function in C
#include "a_time.h" 
#include "rdfstorage.h"
#include "ssdm.h"

////////////// AMOS FUNCTIONS TO BE USED

dcl_oid(sparqlFn);
dcl_oid(rdfInsertFn);

////////////// INITIALIZING AND FINALIZING THE DEMO

void init_fns(a_connection c) {
	a_setf(sparqlFn, a_getfunction(c, "charstring.sparql->vector", FALSE));
	a_setf(rdfInsertFn, a_getfunction(c, "integer.literal.literal.literal.rdf:insert->boolean", FALSE));
}

void finalize_fns() {
	free_oid(sparqlFn);
	free_oid(rdfInsertFn);
}

////////////////// POPULATING THE RDF DATASET

// Programmatically create data similar to $(AMOS_HOME)/SQoND/test/data/turtle/alltypes.ttl 

oidtype createSampleNMA() {
	int i = 1;
	oidtype res = make_nma0(2); //make a 2-dimensional array;

	nma_setdim(res, 0, 2); //dimensions 2 x 3
	nma_setdim(res, 1, 3); 
	nma_init(res, NMA_INTEGER, 0); //of integer elements
	
	nma_iter_reset(res); //populate elements using iterator
	do {
		*(int*)nma_iter2pointer(res) = i;
		i++;
	} while (nma_iter_next(res));

	return res;
}

void createSampleRDF(a_connection c) {
	dcl_scan(scan);
	dcl_tuple(arg);

	a_newtuple(arg, 4, FALSE); //arity of rdfInsertFn
	a_setintelem(arg, 0, 0, FALSE); //insert all triples into GRAPH(0)
	a_setobjectelem(arg, 2, make_uri("http://example.org/ns#p"), FALSE); // sampe predicate for all following triples

	a_setobjectelem(arg, 1, make_uri("http://example.org/ns#x1"), FALSE);
	a_setobjectelem(arg, 3, mkinteger(5), FALSE);  //integer
	a_callfunction(c, scan, rdfInsertFn, arg, FALSE);

	a_setobjectelem(arg, 1, make_uri("http://example.org/ns#x2"), FALSE);
	a_setobjectelem(arg, 3, mkreal(3.14), FALSE);  //real
	a_callfunction(c, scan, rdfInsertFn, arg, FALSE);

	a_setobjectelem(arg, 1, make_uri("http://example.org/ns#x3"), FALSE);
	a_setobjectelem(arg, 3, a_true, FALSE);  //boolean, as a_false
	a_callfunction(c, scan, rdfInsertFn, arg, FALSE);

	a_setobjectelem(arg, 1, make_uri("http://example.org/ns#x4"), FALSE);
	a_setobjectelem(arg, 3, make_timevalz(2012, 12, 14, 23, 55, 20, 123, 18000), FALSE);  //timeval, given in timezone UTC-5 (18k seconds West of Greenwich)
	a_callfunction(c, scan, rdfInsertFn, arg, FALSE);

	a_setobjectelem(arg, 1, make_uri("http://example.org/ns#x5"), FALSE);
	a_setobjectelem(arg, 3, make_unistring(mkstring("cat"), NULL), FALSE); //simple string
	a_callfunction(c, scan, rdfInsertFn, arg, FALSE);

	a_setobjectelem(arg, 1, make_uri("http://example.org/ns#x6"), FALSE);
	a_setobjectelem(arg, 3, make_unistring(mkstring("katt"), "sv"), FALSE); //langtagged string
	a_callfunction(c, scan, rdfInsertFn, arg, FALSE);

	a_setobjectelem(arg, 1, make_uri("http://example.org/ns#x7"), FALSE);
	a_setobjectelem(arg, 3, createSampleNMA(), FALSE); //langtagged string
	a_callfunction(c, scan, rdfInsertFn, arg, FALSE);

	a_setobjectelem(arg, 1, make_uri("http://example.org/ns#x11"), FALSE);
	a_setobjectelem(arg, 3, make_typedrdf(mkstring("chat"), 
		                                  make_uri("http://example.org/datatype#French")), FALSE); //typed rdf
	a_callfunction(c, scan, rdfInsertFn, arg, FALSE);

	free_tuple(arg);
	free_scan(scan);
}


///////////// ACCESSING TIME VALUES

void printTimeval(oidtype tv) 
{
	int year, month, day, hour, minute, second, usec;
	oidtype dt = timeval_to_vector(tv, t);  //project UTC time to the timezone stored in TIMEVAL
	int tz = timeval_timezone(tv);

	year = getinteger(a_elt(dt, 0));
	month = getinteger(a_elt(dt, 1));
	day = getinteger(a_elt(dt, 2));
	hour = getinteger(a_elt(dt, 3));
	minute = getinteger(a_elt(dt, 4));
	second = getinteger(a_elt(dt, 5));
	usec = getinteger(a_elt(dt, 6));

	a_free(dt);

	printf("\"%d-%02d-%02dT%02d:%02d:%f", year, month, day, hour, minute, second + 0.000001 * usec); 

	//print timezone: '[+|-]hh:mm', 'Z' for UTC or '' for unknown timezone
	if (tz == 0) printf("Z"); // Zulu time (UTC)
	else if (tz != TZ_RESERVED) { //timezone given in seconds West of Greenwitch
		if (tz > 0) printf("-");
		else printf("+");
		printf("%02d-%02d", abs(tz) / 3600, (abs(tz) % 3600) / 60); // print hours and minutes East of Greenwich
	}
	printf("\"^^xsd:dateTime");	
}

//////////// ACCESSING NMA METADATA AND ELEMENTS

void printNMA_rec(oidtype v, int level)
{ // recursive part of NMA printer
	int idx;
	printf("(");
	for (idx = 0; idx < nma_dim(v, level); idx++) {
		nma_iter_setidx(v, level, idx);
		if (idx>0) printf(" ");
		if (level+1 < nma_ndims(v)) printNMA_rec(v, level+1); // recursive call
		else switch (nma_kind(v)) {
			case NMA_INTEGER:				
				printf("%d", *(int*)nma_iter2pointer(v));
				break;
			case NMA_DOUBLE:				
				printf("%g", *(double*)nma_iter2pointer(v));
				break;
			case NMA_COMPLEX:				
				printf("COMPLEX!"); // not fully implemented yet
				break;
		}
	}
	printf(")");
}	

void printNMA(oidtype v)
{ // basic part of NMA printer
	int i;
	switch (nma_kind(v)) { // print array type
		case NMA_INTEGER: 
			printf("I");
			break;
		case NMA_DOUBLE: 
			printf("D");
			break;
		case NMA_COMPLEX:
			printf("C");
			break;
	}
	printf("NMA[");
	for (i=0; i<nma_ndims(v); i++) { // print dimensions
		if (i>0) printf(",");
		printf("%d", nma_dim(v, i));
	}
	printf("]:");
	printNMA_rec(v, 0); // print elements (recursively)
}

/////////////// ACCESSING AMOS VECTORS

void printValue(oidtype v);

void printVector(oidtype v)
{
	int i;

	printf("{");
	for (i=0; i < a_arraysize(v); i++) {
		printf(" ");
		printValue(a_elt(v, i));
	}
	printf(" }");
}

/////////////// GENERIC PRINTER: USING a_datatype TO IDENTIFY OBJECT TYPE

void printValue(oidtype v)
{
	int vtype = a_datatype(v);

	if (v==nil) printf("NIL");
	else if (v==a_true) printf("TRUE");
	else if (v==a_false) printf("FALSE");
	else if (vtype==INTEGERTYPE) 
		printf("%d", getinteger(v));
	else if (vtype==REALTYPE) 
		printf("%g", getreal(v));
	else if (vtype==STRINGTYPE) 
		printf("\"%s\"", getstring(v)); //only possible in output of string-based SPARQL
	else if (vtype==TIMEVALTYPE) 
		printTimeval(v);
	else if (vtype==URITYPE) 
		printf("<%s>", uri_id(v));
	else if (vtype==UNISTRINGTYPE) 
		printf("\"%s\"@%s", getstring(unistring_str(v)), unistring_lang(v));
	else if (vtype==TYPEDRDFTYPE)
		printf("\"%s\"^^<%s>", getstring(typedrdf_str(v)), uri_id(typedrdf_typeuri(v)));
	else if (vtype==NMATYPE)
		printNMA(v);			
}

//////////////// EXECUTING SciSPARQL QUERIES AND DIRECTIVES

void printSparqlResults(a_scan scan)
{ // Process the scan: each row contains one sequence elemement filled with bindings of query variables
	dcl_tuple(row);
	dcl_tuple(v);
	int i;

	while (!a_eos(scan))
	{
		a_getrow(scan, row, FALSE);
		a_getseqelem(row, 0, v, FALSE);
		for (i=0; i < a_getarity(v, FALSE); i++) { // iterate through the elements of the sequence
			if (i>0) printf("  ");
			printValue(a_getobjectelem(v, i, FALSE)); // print each object with generic printer defined above
		}
		printf("\n");
		a_nextrow(scan,FALSE); // iterate to next result
	}

	free_tuple(row);
	free_tuple(v);
}

void execSparql(a_connection c, char* query, int doPrint) 
{ // Execute a SciSPARQL query
	dcl_scan(scan);
	dcl_tuple(arg);
		
	// Initialize argument tuple
	a_newtuple(arg, 1, FALSE); 
	a_setstringelem(arg, 0, query, FALSE);

	// Call SciSPARQL interpreter function
	a_callfunction(c, scan, sparqlFn, arg, TRUE);
	if (a_errno) { // catch all errors
		if (doPrint) printf("Error: %s\n", a_errstr);				
		a_errno = 0; // reset error flag			
	} else {	
		// Print results if asked to
		if (doPrint) printSparqlResults(scan);		
	}

	free_scan(scan);	
	free_tuple(arg);	
}


void printSparqlFnResults(a_scan scan)
{ // Process the scan: each row contains elements with bindings of query variables
	dcl_tuple(row);
	int i;

	while (!a_eos(scan))
	{
		a_getrow(scan, row, FALSE);
		for (i=0; i < a_getarity(row, FALSE); i++) { // iterate through the elements of the sequence
			if (i>0) printf("  ");
			printValue(a_getobjectelem(row, i, FALSE)); // print each object with generic printer defined above
		}
		printf("\n");
		a_nextrow(scan,FALSE); // iterate to next result
	}

	free_tuple(row);
}


void execSparqlFn(a_connection c, const char* fnname, oidtype argvector, 
		  int doPrint) 
{	// Exectute a SciSPARQL function named 'fnname' with arguments stored 
        // in 'argvector'
  dcl_scan(scan);
  dcl_tuple(arg);
  dcl_oid(fn);	
  char* amosFnName;
  int i;

  // Obtain function pointer
  amosFnName = malloc(5 + strlen(fnname));
  strcpy(amosFnName, "rdf:");
  strcat(amosFnName, fnname);
  fn = a_getfunction(c, amosFnName, TRUE); // catch an error here
	if (a_errno) {
		if (doPrint) printf("Error: no function named '%s'\n", fnname);
		a_errno = 0; // reset error flag	
	} else {
		// Initialize argument tuple
		a_newtuple(arg, a_arraysize(argvector), FALSE); 
		for (i=0; i < a_arraysize(argvector); i++)
	    a_setobjectelem(arg, i, a_elt(argvector, i), FALSE);
	
	  // Call SciSPARQL interpreter function
	  a_callfunction(c, scan, fn, arg, FALSE);
	
		// Print results if asked to
		if (doPrint) printSparqlFnResults(scan);
	}

  // Argument vector is used only once (in this setting!)
  free_oid(argvector);

  free_oid(fn);
  free_tuple(arg);
  free_scan(scan);
}


void mySum(a_callcontext cxt, a_tuple tpl)
{
	double res = 0;
	int i, nargs = a_getarity(tpl, FALSE) - 1;
	for (i=0; i < nargs; i++) 
		switch (a_getelemtype(tpl, i, FALSE)) {
			case INTEGERTYPE:
				res += a_getintelem(tpl, i, FALSE);
				break;
			case REALTYPE:
				res += a_getdoubleelem(tpl, i, FALSE);
				break;
			default:
				return; //do not emit a result if arguments are invalid
	}
	a_setdoubleelem(tpl, nargs, res, FALSE);
	a_emit(cxt, tpl, FALSE); // emit the result
}


main(int argc, char **argv) //Similar to Amos callin Demo
{ 
  dcl_connection(c); /* c is a connection handle */
	
  init_amos(argc,argv); 
  /* Initialize embedded Amos II with command line parameters */
	
  a_connect(c,"",FALSE); 
  /* Connect to Amos II peer or to embedded Amos II database (name ""): */


  init_fns(c);
  createSampleRDF(c);
	
  //	execSparql(c,"LOAD('C:\\AmosNT\\SQoND\\test\\data\\turtle\\alltypes.ttl',true)"); //load the data file
  printf(" Query returning complete dataset:\n");
  execSparql(c, "SELECT ?s ?o  WHERE { ?s ?p ?o}", TRUE);	 
  // run a query returning objects of different types	

  execSparql(c, "DEFINE FUNCTION f(?x) AS SELECT ?s WHERE { ?s ?p ?x }",
	     FALSE); //do not print the result
	
  printf("\n calling SPARQL-defined F(5):\n");
  execSparqlFn(c, "f", a_vector(mkinteger(5),NULL), TRUE); 
  // the way to invoke 'parametrized queries'

	printf("\n calling G(5) (undefined):\n");
  execSparqlFn(c, "g", a_vector(mkinteger(5),NULL), TRUE);  //will print an error

	// define a SciSPARQL function in C:
	a_extfunction("mysum--+",mySum);
	execSparql(c, "DEFINE FUNCTION MySum(?x ?y) AS C 'mysum--+'", FALSE);

	// run a query using MySum:
	printf("\n calling C-impemented MySum(?o 10) from inside SPARQL query:\n");
	execSparql(c, "SELECT (MySum(?o, 10) AS ?res) WHERE {?s ?p ?o}", TRUE);
	
  finalize_fns();

  a_disconnect(c,FALSE); /* Close the connection */	
  free_connection(c); /* Free connection handle */
};
