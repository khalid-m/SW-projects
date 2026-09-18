
#include "raptor.h"
#include "callout.h"
#include "rdf_reader.h"

/*Fields are filled and passed to the callback function*/
typedef struct {
	char *fn;			/* RDF source name */
	a_tuple tpl;		/* tuple, input from AmosQL */
	a_callcontext cxt;	/* callcontext */
}CallbackParam;

static void *amos_conn=NULL;

/* oidtype of AmosQL function 'RDF_TRIPLE_CACHE' 
   for caching RDF triple
*/
static oidtype fn_rdf_triple_cache=0;

/* oidtype of GET_LIT_ID
   for mapping data type URI to integer
*/
static oidtype fn_get_lit_id=0;

char *ltr_type[] = {
	"",
	"",
	"http://www.w3.org/2001/XMLSchema#integer",
	"http://www.w3.org/2001/XMLSchema#decimal",
	"http://www.w3.org/2001/XMLSchema#double",
	"http://www.w3.org/2001/XMLSchema#boolean",
	"http://www.w3.org/2001/XMLSchema#string",
};

/*****************************************
  extern from uri.c
  A C function to create 'Resource'
******************************************/
extern oidtype new_R(int, char*);

/***************************************************
  A callback function called by raptor when it 
  parses RDF resource and finds triples, 
  Input parameter raptor_statement *triple contains
  the information of the triples.

  raptor_statement is declared in raptor.h
****************************************************/

#define NUM_RETURN	(3)
#define FUNC_NAME	"CHARSTRING.RDF_TRIPLE_CACHE->RESOURCE.RESOURCE.RESOURCE"
#define IS_TRIPLE_CACHED fn_rdf_triple_cache!=0

/* Map data type URI to integer.
   uri is a C string of data type URI, which
   can be empty, indicating a plain literal
*/
int map_datatypeURI_to_int(char *uri)
{
	if (*uri == '\0')
		return 1; 
	else
	{
		int dtID;
		dcl_tuple(argl);dcl_tuple(row);
		dcl_scan(s);

		if (fn_get_lit_id==0)
			a_let(fn_get_lit_id,a_getfunction(amos_conn,"CHARSTRING.GETLITID->INTEGER",FALSE));

		a_newtuple(argl,1,FALSE); 
		a_setstringelem(argl,0,uri,FALSE);	

		/*Call 'GET_LIT_ID' to map data type URI to integer*/
		a_callfunction(amos_conn,s,fn_get_lit_id,argl,FALSE);

		a_getrow(s,row,FALSE);
		
		dtID = a_getintelem(row,0,FALSE);
		
		free_scan(s);
		free_tuple(argl);
		free_tuple(row);
		
		return dtID;
	}
}

oidtype create_new_literal(char *vs, char *dt)
{
	oidtype lit;
	int datatype_id=map_datatypeURI_to_int((char*)dt);

	if (datatype_id != 5) 
		lit = new_R(datatype_id,vs);
	else
	{	/* boolean, convert 1 to true, 0 to false */
		if (*vs=='1')
			lit = new_R(datatype_id,"true");
		else if (*vs=='0')
			lit = new_R(datatype_id,"false");
		else 
			lit = new_R(datatype_id,_strlwr(vs));
	}
	return lit;
}

/* Callback function invoked by Raptor
*/
void _rdf_triple_(void* param, const raptor_statement* triple) 
{
	char *sub, *pre, *obj;
	char *ptr;
	CallbackParam *cp = (CallbackParam*)param;
	dcl_scan(s);dcl_tuple(arg);dcl_tuple(resl);
	
	/*****************************************
	  rdf_triple_cache(location)=<sub,pre,obj>;
	  arg is a tuple of 1 element, 'location'
	  resl is a tuple of 3 elements, 
			namely 'sub', 'pre' and 'obj'
	******************************************/
	a_newtuple(arg,1,FALSE);
	a_newtuple(resl,NUM_RETURN,FALSE);

	a_setstringelem(arg,0,cp->fn,FALSE);
	
	/*****************************************
					Subject
	******************************************/
	sub = raptor_statement_part_as_string(	
		triple->subject,
		triple->subject_type,
		NULL, NULL); 
	ptr=sub;
	if (ptr[0]=='<') 
	{	
		/*****************************************
		  Raptor generates URI bracketed by '<' and '>'
		  e.g. <http://example.com>
		  Remove '<' and '>' if necessary
		******************************************/
		ptr++;	ptr[strlen(ptr)-1]='\0';
	}

	if (IS_TRIPLE_CACHED)
		a_setobjectelem(resl,0,new_R(0,ptr),FALSE);
	else
		a_setobjectelem(cp->tpl,1,new_R(0,ptr),FALSE);
		
	raptor_free_memory(sub);

	/*****************************************
					Predicate
	******************************************/
	pre = raptor_statement_part_as_string(	
		triple->predicate,
		triple->predicate_type,
		NULL, NULL);
	ptr=pre;
	if (ptr[0]=='<') 
	{	
		ptr++;	ptr[strlen(ptr)-1]='\0';
	}

	if (IS_TRIPLE_CACHED)
		a_setobjectelem(resl,1,new_R(0,ptr),FALSE);
	else
		a_setobjectelem(cp->tpl,2,new_R(0,ptr),FALSE);
		
	raptor_free_memory(pre);


	/*****************************************
					Object
	******************************************/
	obj = raptor_statement_part_as_counted_string(	
			triple->object,
			triple->object_type,
			triple->object_literal_datatype, 
			triple->object_literal_language,NULL);
	if (triple->object_type==RAPTOR_IDENTIFIER_TYPE_RESOURCE ||
		triple->object_type==RAPTOR_IDENTIFIER_TYPE_PREDICATE ||
		triple->object_type==RAPTOR_IDENTIFIER_TYPE_ANONYMOUS)
	{
		ptr=obj; 
		if (ptr[0]=='<') 
		{	
			ptr++;	ptr[strlen(ptr)-1]='\0';
		}

		if (IS_TRIPLE_CACHED)
			a_setobjectelem(resl,2,new_R(0,ptr),FALSE);
		else
			a_setobjectelem(cp->tpl,3,new_R(0,ptr),FALSE);
		
	}else if (triple->object_literal_datatype)
	{
		/*****************************************
		  typed literal
		******************************************/
		oidtype lit = create_new_literal((char*)triple->object,
			                             (char*)triple->object_literal_datatype);

		if (IS_TRIPLE_CACHED)
			a_setobjectelem(resl,2,lit,FALSE);
		else
			a_setobjectelem(cp->tpl,3,lit,FALSE);
	}else{
		/*****************************************
		  here are plain literal
		******************************************/
		if (triple->object_literal_language)
		{
			ptr=obj;
		}
		else
		{
			ptr=obj+1;
			ptr[strlen(ptr)-1]='\0';
		}
		if (IS_TRIPLE_CACHED)
			a_setobjectelem(resl,2,new_R(1,ptr),FALSE);
		else
			a_setobjectelem(cp->tpl,3,new_R(1,ptr),FALSE);
	}
	raptor_free_memory(obj);

	if (IS_TRIPLE_CACHED)
		/* Cache RDF triples */
		a_addfunction(amos_conn,fn_rdf_triple_cache,arg,resl,FALSE);
	else
		/* If cache is not need, just emit the result */
		a_emit(cp->cxt, cp->tpl, FALSE);

	free_scan(s);free_tuple(arg);free_tuple(resl);
} 

/* Read RDF source
*/
int rdf_from_file_using_raptor(CallbackParam cp)
{
	char *fn=cp.fn;
	raptor_parser* rdf_parser=NULL;
	unsigned char *uri_string;
	raptor_uri *uri, *base_uri;
	int ret;

	/*****************************************
	  Remove '<' and '>' if necessary
	******************************************/
	if (fn[0]=='<') 
	{	
		fn++;
		fn[strlen(fn)-1]='\0';
	}
	/*****************************************
	  Remove "file:///" if necessary
	******************************************/
	if (memcmp(fn, "file:///", strlen("file:///"))==0) 
	{
		fn += 8;
	}

	/*****************************************
	  Raptor support several syntaxes inlcuding
	  RDF/XML, N-Triples, Turtle, 
	  RSS tag soup including Atom 1.0 and 0.3, 
	  GRDDL for XHTML and XML

	  Let it guess input file format here
	******************************************/
	rdf_parser=raptor_new_parser("guess");
	
	uri_string=raptor_uri_filename_to_uri_string(fn);
	uri=raptor_new_uri(uri_string);
	base_uri=raptor_uri_copy(uri);

	/*****************************************
	  Register the callback funtion
	******************************************/
	raptor_set_statement_handler(rdf_parser, &cp, _rdf_triple_);
	
	/*****************************************
	  Start parsing the RDF resource
	******************************************/
	ret=raptor_parse_file(rdf_parser, uri, base_uri);
	
	raptor_free_parser(rdf_parser);
	raptor_free_uri(base_uri);
	raptor_free_uri(uri);
	
	return ret;
}

/* Amos II foreign function
   'parseRDF(Charstring)-><Resource,Resource,Resource>'
   Cache RDF triples
*/
void parseRDF(a_callcontext cxt, a_tuple tpl)
{
	char filename[260];
	CallbackParam cp;

	cp.fn = filename;
	cp.tpl = tpl;
	cp.cxt = cxt;
		
	fn_rdf_triple_cache=0;
	fn_get_lit_id=0;
	
	a_getstringelem(tpl, 0, filename, 260, FALSE);

	if (rdf_from_file_using_raptor(cp)!=0)
	{
		printf("Fail to parse RDF file : '%s'.\n", filename);
	}
}

/* Amos II foreign function 
   'parseRDF_cache(Charstring)->Boolean'
   Cache RDF triples
*/
void parseRDF_cache(a_callcontext cxt, a_tuple tpl)
{  
	char filename[260];
	CallbackParam cp;

	cp.fn = filename;
	cp.tpl = tpl;
	cp.cxt = cxt;
	
	a_let(fn_rdf_triple_cache,a_getfunction(amos_conn, FUNC_NAME, FALSE));

	a_getstringelem(tpl, 0, filename, 260, FALSE);

	if (rdf_from_file_using_raptor(cp)!=0)
	{
		printf("Fail to parse RDF file : '%s'.\n", filename);
	}

	a_free(fn_rdf_triple_cache);
}	

/* This function must be invoked before
   parseRDF_cache or parseRDF can work properly.
*/
void rdf_set_amos_connection(void* c)
{
	a_extfunction("parseRDF", parseRDF);
	a_extfunction("parseRDF_cache", parseRDF_cache);

	amos_conn = c;
	raptor_init();
}

/* Release Raptor */
void rdf_raptor_finish(void)
{
	a_free(fn_get_lit_id);
	fn_get_lit_id = 0;
	raptor_finish();
}
