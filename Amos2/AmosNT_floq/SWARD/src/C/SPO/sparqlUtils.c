/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Yu Cao, Tore Risch, UDBL
 * $RCSfile: sparqlUtils.c,v $
 * $Revision: 1.3 $ $Date: 2007/11/26 13:22:22 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Utility functions for stand-alone SparQL parser
 * ===========================================================================
 * $Log: sparqlUtils.c,v $
 * Revision 1.3  2007/11/26 13:22:22  petrini
 * Error message gpErrMsg is set only if it is not set before. I.e. the first error is reported.
 *
 * Revision 1.2  2007/11/23 13:50:15  petrini
 * Fn sparql_query now deletes allocated memory for every parse query.
 *
 * Revision 1.1  2007/11/22 14:58:21  petrini
 * Added functionality for:
 * 1. Running SparQL parser outside java for debugging purposes.
 * 2. Support for implicit 'FROM' clauses by SparQL parser.
 * 3. Regression testing of RDQL, original SparQL parser and SparQL parser.
 * 4. Handling of foreign and composite keys in SWARD.
 * 5. Handling of class instances in SWARD.
 * 6. Regression testing of foreign, composite keys and class instances.
 *
 * Revision 1.1  2007/07/24 05:55:38  petrini
 * *** empty log message ***
 *
 * Revision 1.3  2007/06/12 20:05:45  torer
 * Better syntax error messages
 *
 * Revision 1.2  2007/06/12 15:01:49  torer
 * Better syntax error messages
 *
 * Revision 1.1  2007/06/12 14:32:39  torer
 * Stand-alone SparQL parser in C
 *
 ****************************************************************************/

#include <string.h>
#include <memory.h>
#include "callout.h"
#include "sparqlMemory.h"
#include "sparqlUtils.h"

/*****************************************
			Extern
******************************************/
extern int SparQLparse(void);	/* Flex/Bison	*/
extern oidtype new_R(int, char*);/* uri.c		*/
oidtype create_new_literal(char *vs, char *dt);	/* rdf_reader.c	*/

/*****************************************
				Macro
******************************************/
#define MAX_NUM_VAR		16
#define MAX_VAR_LEN		31

#define MAX_TMP_LEN		1024

/*****************************************
				Structure
******************************************/
typedef struct{
	const char *name;
	const u32 size;
	u32	used;
	u32 *tbl;
}Table;

struct Triple{
	char *cntnt;	/* Pointer to C string */
	SparQLType var;	/* ID of T_STR*/
	int	group;
};

struct Filter{
	char *cntnt;
	int	group;
};

struct ListNode{
	SparQLType value;
	struct ListNode *next;	
};
struct ListHeadNode{
	struct ListNode *end;
	struct ListNode *next;
};

struct PrefixMapping{
	SparQLType name; /* prefix name				*/
	SparQLType URI;  /* mapped URI reference	*/
};

struct OrderByInfo{
	char name[MAX_VAR_LEN+1];
	int	index;
	char order[6];				
};

/*****************************************
		Global variables declaration
******************************************/
int parserErrorID;

SparQLType	gQueryVar;	/* A list of vars appeared after 'select' */
SparQLType  gDistinct;
SparQLType 	gComma;
SparQLType 	gCloseB;	/* Close Bracket */;
char *gRDF_src;		/* Hold the name of RDF source. Added by Johan Petrini*/

/*****************************************
		Static variables declaration
******************************************/
static void *sparql_amos_c=NULL;
static Table tblsAddr[]={
	/*			MAX		used	pool*/
	{"ERROR",	0,		0,		0},
	{"T_VAR",	32,		0,		0},
	{"T_BKV",	8,		0,		0},
	{"T_IRI",	32,		0,		0},
	{"T_LTR",	32,		0,		0},
	{"T_STR",	64,		0,		0},
	{"T_TPL",	32,		0,		0},
	{"T_LST",	32,		0,		0},
	{"T_PRF",	16,		0,		0},
	{"T_FLT",	8,		0,		0},
	{"ERROR",	0,		0,		0}
};

/* 
For 'sparql_input' usage
*/
static char *gpInput;	/* Input buffer, maximum is MAX_INPUT				*/
static char *gptr;		/* Position in gpInput, where the lexer has reached	*/
static int	gCharLeft;	/* How many unparsed charactors are left in gpInput	*/

/*Removed by Johan Petrini*/
/*static char *gRDF_src;*/		/* Hold the name of RDF source		*/

static char gRDF_parser[9];	/* RDF parser name, caching or not	*/

/*
For base IRI reference
*/
static char *gpBase;

/*
For 'ORDER BY' usage
*/
static oidtype	fn_cmp=nil;
static int		gNumOfOBI;
static char		gQueryVarName[MAX_NUM_VAR][MAX_VAR_LEN];
static struct OrderByInfo gOBI[MAX_NUM_VAR];

/*
For 'LIMIT' usage
*/
int  gLimit;

/*
For 'OFFSET' usage
*/
int  gOffset;

/*
For 'OPTIONAL' usage
*/
#define OPT_ROOT	1
int  gGroupCount;
int  gGroup;

/*
Others
*/
static char gpTmp1[MAX_TMP_LEN];
static char gpTmp2[MAX_TMP_LEN];
char *gpErrMsg=NULL;

static void *amos_conn;

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
	a_let(fn_get_lit_id,
	      a_getfunction(amos_conn,"CHARSTRING.GETLITID->INTEGER",FALSE));

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
    {/* boolean, convert 1 to true, 0 to false */
      if (*vs=='1')
	lit = new_R(datatype_id,"true");
      else if (*vs=='0')
	lit = new_R(datatype_id,"false");
      else 
	lit = new_R(datatype_id,_strlwr(vs));
    }
  return lit;
}

/*****************************************
				Functions
******************************************/
void dummy_print(char *in, ...)
{}
void error_reason(char *in)
{
	if (gpErrMsg == NULL)
	{
		gpErrMsg = sparql_new(strlen("'%s' not supported")
			+strlen(in)+1);
		sprintf(gpErrMsg, "'%s' not supported", in);
	}
}
/*****************************************
  sparql_input is used to redirect
  std input to a char buf in Lexer
******************************************/
int sparql_input(char *buf, int max_size)
{
	int n = 0;
	
	if (gCharLeft == -1) {gptr = gpInput; gCharLeft = strlen(gptr);}
	
	n = (max_size < gCharLeft) ?  max_size : gCharLeft;
	if(n > 0)
	{
		memcpy(buf, gptr, n);
		gptr += n;
		gCharLeft -=n;
	}
	else
	{
		*buf='\0';
	}
	
	return n;
}

/*****************************************
			Foreign Functions
******************************************/
void sparql_internal(char* query, a_callcontext cxt, a_tuple tpl)
{
  a_setstringelem(tpl, 3, query, FALSE);
  a_emit(cxt,tpl, FALSE);
};

/* Parser SPARQL statement
   Statement is inputted as Charstring
*/
void sparql_query(a_callcontext cxt, a_tuple tpl)
{
  char *q;
  static int first = TRUE;

  if(!first){
    delete_memory();
  }else{
    first = FALSE;
  }

  /*Allocate memory*/
  create_memory();
  init_help();
	
  /*Get RDF source name*/
  a_getstringelem(tpl, 0, gRDF_src+1, MAX_TMP_LEN-1, FALSE);
  gRDF_src[0] = '\"'; strcat(gRDF_src, "\""); 

  /*Cached or uncached RDF parser*/
  if (a_getintelem(tpl, 1, FALSE)==0)
    strcpy(gRDF_parser,"rdf_tr");
  else
    strcpy(gRDF_parser,"rdf_tr_c");
	
  /*SPARQL query statement*/
  a_getstringelem(tpl, 2, gpInput, MAX_INPUT, FALSE);
	
  DBG_PRT("Start Query\n");
	
  if (SparQLparse()==0)
    {
      /* Generate the AmosQL statement */
      q=output_query();

      if (gpErrMsg != NULL)
	{
	  a_error(parserErrorID, mkstring(gpErrMsg), FALSE);
	}
      /* Emit the AmosQL statement */
      sparql_internal(q, cxt, tpl);
    }
  else a_error(parserErrorID, mkstring((gpErrMsg?gpErrMsg:"unknown reason")), 
               FALSE);
}

/************************************/	
/* Retrieve the value string and 
   data type URI from literal
   in(in): literal
   pOp(out): value string
   pOpE(out): the end of value string
   pType(out): data type URI
*/
void op_and_type(char *in, char **pOp, char ** pOpE, char **pType)
{
	*pOpE = strpbrk(in, "\\^" );/* find the first \ or ^ */
	if (*pOpE != NULL)
	{
		/*Omit '<' '>' that delimits URI*/
		*pType = strrchr(in, (int)'^')+2;
		*(*pType+strlen(*pType)-1) = '\0';
		
		/*Omit quotation mark*/
		*pOp = in+1;
		*(*pOpE-1) = '\0';
	}else{
		*pOp = in;
		*pType = in+strlen(in);
	}
}

/************************************/
/* Create literal in Amos II from Charstring
   newLit(Charstring)->Rlit
*/
void sparql_new_lit(a_callcontext cxt, a_tuple tpl)
{
	char *op_str = NULL,*op_end=NULL,*type = NULL;
	int datatype_id = -1;
	oidtype lit=0;
	
	a_getstringelem(tpl, 0, gpTmp1, MAX_TMP_LEN, FALSE);
	op_and_type(gpTmp1, &op_str, &op_end, &type);
	
	lit=create_new_literal(op_str, type);

	a_setobjectelem(tpl, 1, lit, FALSE);
	a_emit(cxt, tpl, FALSE);
}

/************************************/
/* Map C BOOL to xsd:boolean
*/
oidtype new_literal_boolean_true(int bValue)
{
	return bValue ? new_R(r_xsd_boolean,"true") : new_R(r_xsd_boolean,"false");
}

/************************************/
/* Convert value string of numeric,
   xsd:integer, xsd:decimal, xsd:double
   to C double for comparison, arithmetic
*/
double cnvt_numeric_to_double(int dtID, char *vs)
{
	char *pOp;
	if (dtID==r_xsd_integer)
	{
		pOp = strpbrk(vs, "-+123456789");/* eliminate 0s in "001" */
		if (pOp == NULL) pOp = vs;
	}
	else
		pOp = strpbrk(vs, "-+Ee.0123456789");
	return atof(vs);
}

/************************************/
/* Implementation of EBV
*/
void sparql_ebv(a_callcontext cxt, a_tuple tpl)
{
	int dtID = a_getintelem(tpl, 0, FALSE);
	oidtype ret = 0;

	if (dtID==r_xsd_integer || dtID==r_xsd_decimal || dtID==r_xsd_double)
	{	//xsd:integer xsd:decimal xsd:double
		a_getstringelem(tpl,1,gpTmp2,64,FALSE);
		ret = new_literal_boolean_true(cnvt_numeric_to_double(dtID,gpTmp2)!=0);
	}
	else if (dtID == r_xsd_boolean)
	{
		a_getstringelem(tpl,1,gpTmp2,64,FALSE);
		ret = new_R(dtID,gpTmp2);
	}
	else if (dtID==r_xsd_string || dtID==r_plain_lit)
	{
		a_getstringelem(tpl,1,gpTmp2,64,FALSE);
		ret = new_literal_boolean_true(*gpTmp2!='\0');
	}

	a_setobjectelem(tpl, 2, ret, FALSE);
	a_emit(cxt, tpl, FALSE);
}

/************************************/	
int cmp_numeric(double op1, double op2, char *pOpt)
{
	if		(strcmp(pOpt,"EQ")==0)  return (op1 == op2);
	else if (strcmp(pOpt,"NEQ")==0) return (op1 != op2);
	else if (strcmp(pOpt,"LT")==0)  return (op1 <  op2);
	else if (strcmp(pOpt,"GT")==0)  return (op1 >  op2);
	else if (strcmp(pOpt,"LTE")==0) return (op1 <= op2);
	else if (strcmp(pOpt,"GTE")==0) return (op1 >= op2);
	else *(char*)(0) = 1;

	return 0;
}

/************************************/
int cmp_string(char *pOp1, char *pOp2, char *pOpt)
{
	if		(strcmp(pOpt,"EQ")==0)  return (strcmp(pOp1,pOp2)==0);
	else if (strcmp(pOpt,"NEQ")==0) return (strcmp(pOp1,pOp2)!=0);
	else if (strcmp(pOpt,"LT")==0)  return (strcmp(pOp1,pOp2) <0);
	else if (strcmp(pOpt,"GT")==0)  return (strcmp(pOp1,pOp2) >0);
	else if (strcmp(pOpt,"LTE")==0) return !(strcmp(pOp1,pOp2) >0);
	else if (strcmp(pOpt,"GTE")==0) return !(strcmp(pOp1,pOp2) <0);
	else *(char*)(0) = 1;

	return 0;
}

/************************************/
/* compare to typed literals
   return xsd:boolean
*/	
void sparql_cmp(a_callcontext cxt, a_tuple tpl)
{
	char opt[4];
	int xdtID = a_getintelem(tpl, 0, FALSE);
	int ydtID = a_getintelem(tpl, 2, FALSE);
	oidtype ret = 0;

	if ((xdtID==r_xsd_integer || xdtID==r_xsd_decimal || xdtID==r_xsd_double) &&
	    (ydtID==r_xsd_integer || ydtID==r_xsd_decimal || ydtID==r_xsd_double))
	{	//xsd:integer xsd:decimal xsd:double
		a_getstringelem(tpl,1,gpTmp1,32,FALSE);
		a_getstringelem(tpl,3,gpTmp2,32,FALSE);
		a_getstringelem(tpl,4,opt,4,FALSE);
		ret = new_literal_boolean_true(
				cmp_numeric(cnvt_numeric_to_double(xdtID,gpTmp1),
				            cnvt_numeric_to_double(ydtID,gpTmp2),opt));
	}else if (xdtID == ydtID)
	{
		a_getstringelem(tpl,1,gpTmp1,MAX_TMP_LEN,FALSE);
		a_getstringelem(tpl,3,gpTmp2,MAX_TMP_LEN,FALSE);
		a_getstringelem(tpl,4,opt,4,FALSE);
		ret = new_literal_boolean_true(cmp_string(gpTmp1,gpTmp2,opt));
	}else
	{
		ret = new_literal_boolean_true(0);
	}

	a_setobjectelem(tpl, 5, ret, FALSE);
	a_emit(cxt, tpl, FALSE);
}

/************************************/	
void sparql_neg(a_callcontext cxt, a_tuple tpl)
{
	int dtID = a_getintelem(tpl, 0, FALSE);
	oidtype ret = 0;
	double rslt;

	a_getstringelem(tpl,1,gpTmp1,64,FALSE);

	rslt = cnvt_numeric_to_double(dtID,gpTmp1)*(-1);

	if (dtID == r_xsd_integer)
	{
		sprintf(gpTmp2, "%i", (int)rslt);
		ret = new_R(r_xsd_integer, gpTmp2);
	}else
	if (dtID == r_xsd_decimal)
	{
		sprintf(gpTmp2, "%#g", rslt);
		ret = new_R(r_xsd_decimal, gpTmp2);
	}
	else
	if (dtID == r_xsd_double)
	{
		sprintf(gpTmp2, "%#e", rslt);
		ret = new_R(r_xsd_decimal, gpTmp2);
	}

	a_setobjectelem(tpl, 2, ret, FALSE);
	a_emit(cxt, tpl, FALSE);
}

/************************************/	
void sparql_div(a_callcontext cxt, a_tuple tpl)
{
	int xdtID = a_getintelem(tpl, 0, FALSE);
	int ydtID = a_getintelem(tpl, 2, FALSE);
	oidtype ret = 0;
	double rslt;

	a_getstringelem(tpl,1,gpTmp1,64,FALSE);
	a_getstringelem(tpl,3,gpTmp2,64,FALSE);

	rslt = cnvt_numeric_to_double(xdtID,gpTmp1)/cnvt_numeric_to_double(ydtID,gpTmp2);

	if (xdtID == r_xsd_integer && ydtID == r_xsd_integer)
	{
		sprintf(gpTmp2, "%#f", rslt);
		ret = new_R(r_xsd_decimal, gpTmp2);
	}else
	{
		sprintf(gpTmp2, "%#g", rslt);
		ret = new_R(r_xsd_double, gpTmp2);
	}

	a_setobjectelem(tpl, 4, ret, FALSE);
	a_emit(cxt, tpl, FALSE);
}

/************************************/
void sparql_times(a_callcontext cxt, a_tuple tpl)
{
	int xdtID = a_getintelem(tpl, 0, FALSE);
	int ydtID = a_getintelem(tpl, 2, FALSE);
	oidtype ret = 0;
	double rslt;

	a_getstringelem(tpl,1,gpTmp1,64,FALSE);
	a_getstringelem(tpl,3,gpTmp2,64,FALSE);

	rslt = cnvt_numeric_to_double(xdtID,gpTmp1)*cnvt_numeric_to_double(ydtID,gpTmp2);

	if (xdtID == r_xsd_integer && ydtID == r_xsd_integer)
	{
		sprintf(gpTmp2, "%i", (int)rslt);
		ret = new_R(r_xsd_integer, gpTmp2);
	}else
	{
		sprintf(gpTmp2, "%#g", rslt);
		ret = new_R(r_xsd_double, gpTmp2);
	}

	a_setobjectelem(tpl, 4, ret, FALSE);
	a_emit(cxt, tpl, FALSE);	
}

/************************************/
void sparql_plus(a_callcontext cxt, a_tuple tpl)
{
	int xdtID = a_getintelem(tpl, 0, FALSE);
	int ydtID = a_getintelem(tpl, 2, FALSE);
	oidtype ret = 0;
	double rslt;

	a_getstringelem(tpl,1,gpTmp1,64,FALSE);
	a_getstringelem(tpl,3,gpTmp2,64,FALSE);

	rslt = cnvt_numeric_to_double(xdtID,gpTmp1)+cnvt_numeric_to_double(ydtID,gpTmp2);

	if (xdtID == r_xsd_double || ydtID == r_xsd_double)
	{
		sprintf(gpTmp2, "%#e", rslt);
		ret = new_R(r_xsd_double, gpTmp2);
	}else
	if (xdtID == r_xsd_decimal || ydtID == r_xsd_decimal)
	{
		sprintf(gpTmp2, "%#g", rslt);
		ret = new_R(r_xsd_decimal, gpTmp2);
	}else
	{
		sprintf(gpTmp2, "%i", (int)rslt);
		ret = new_R(r_xsd_integer, gpTmp2);
	}

	a_setobjectelem(tpl, 4, ret, FALSE);
	a_emit(cxt, tpl, FALSE);	
}

/************************************/
void sparql_minus(a_callcontext cxt, a_tuple tpl)
{
	int xdtID = a_getintelem(tpl, 0, FALSE);
	int ydtID = a_getintelem(tpl, 2, FALSE);
	oidtype ret = 0;
	double rslt;

	a_getstringelem(tpl,1,gpTmp1,64,FALSE);
	a_getstringelem(tpl,3,gpTmp2,64,FALSE);

	rslt = cnvt_numeric_to_double(xdtID,gpTmp1)-cnvt_numeric_to_double(ydtID,gpTmp2);

	if (xdtID == r_xsd_double || ydtID == r_xsd_double)
	{
		sprintf(gpTmp2, "%#e", rslt);
		ret = new_R(r_xsd_double, gpTmp2);
	}else
	if (xdtID == r_xsd_decimal || ydtID == r_xsd_decimal)
	{
		sprintf(gpTmp2, "%#g", rslt);
		ret = new_R(r_xsd_decimal, gpTmp2);
	}else
	{
		sprintf(gpTmp2, "%i", (int)rslt);
		ret = new_R(r_xsd_integer, gpTmp2);
	}

	a_setobjectelem(tpl, 4, ret, FALSE);
	a_emit(cxt, tpl, FALSE);
}

/************************************/	
/* Retrieve the language tag from 
   a literal. If no language tag,
   return empty Charstring
*/
void sparql_LANG(a_callcontext cxt, a_tuple tpl)
{
	char *pAt = NULL;
	char *ret = gpTmp2;

	a_getstringelem(tpl, 0, gpTmp1, MAX_TMP_LEN, FALSE);
	
	pAt = strstr(gpTmp1, "@");

	if (pAt == NULL)
		a_setobjectelem(tpl, 1, new_R(1,""), FALSE);
	else
		a_setobjectelem(tpl, 1, new_R(1,(char*)(pAt+1)), FALSE);
	a_emit(cxt,tpl, FALSE);
}

/* Enter an optional graph pattern
*/
int enter_opt()
{
	gGroup = ++gGroupCount;
	return gGroup;
}
int	get_opt()
{
	return gGroup;
}
/* Check if parser is in optional graph pattern
*/
int in_opt()
{
	return gGroup!=OPT_ROOT;
}
/* Leave an optional graph pattern
*/
int leave_opt()
{
	gGroup = OPT_ROOT;
	return gGroup;
}

/************************************/	
/* Store relative IRI
*/
void mk_base(SparQLType uri)
{
	char *in = NULL;
	if (gpBase != NULL)
	{
		/* There can be only one 
		   relative IRI statement in one 
		   SPARQL statement
		*/
		ERR_PRT("Base URI already exists\n");
		return;
	}
	
	in = (char*)content(uri);
	gpBase = sparql_new(strlen(in)+1);
	strcpy(gpBase, in);
}

/************************************/	
void init_help(void)
{
	Table *t = NULL;
	DBG_PRT("SparQL --> init_help();\n");
	for (t = &tblsAddr[1]; t->size != 0; t++)
	{
		t->used = 0;
		t->tbl = (u32*)sparql_new(t->size*sizeof(u32));
	}
	
	/* Optional graph pattern */
	gGroupCount = OPT_ROOT;
	gGroup = OPT_ROOT;

	/* Relative IRI */
	gpBase = NULL;
	
	/* Queried variable */
	gQueryVar = T_UNKNOWN;

	/* Order query result */
	memset(gQueryVarName, 0, MAX_VAR_LEN*MAX_NUM_VAR);
	gNumOfOBI = 0;
	memset(gOBI, 0, sizeof(struct OrderByInfo)*MAX_NUM_VAR);
	
	/* RDF source name */
	gRDF_src = (char*)sparql_new(MAX_TMP_LEN);
	
	/* Buffer for SPARQL statement */
	gpInput = (char*)sparql_new(MAX_INPUT);
	gptr = NULL;
	gCharLeft = -1;

	/* Store error message */
	gpErrMsg = NULL;

	/* Limit the number of query result tuples */
	gLimit = 65535;

	/* Offset query result tuples */
	gOffset = 0;

	gComma = mk_str(",");
	gCloseB = mk_str(")");
}

/************************************/
/* A help function to display 
   the usage of resources
*/
void help_profile(void)
{
	Table *t = NULL;
	INFO_PRT("SparQL --> help_profile();\n");
	for (t = &tblsAddr[1]; t->size != 0; t++)
	{
		if (t->tbl == 0)
			t->tbl = (u32*)sparql_new(t->size*sizeof(u32));
		INFO_PRT("%s\t%d / %d\n", t->name, t->used, t->size);
	}
}

/************************************/
/* Create a new variable
*/
SparQLType insert_var(char* in)
{
	Table *t = &tblsAddr[T_VAR];
	SparQLType id = T_UNKNOWN;
	char *dst = NULL;
	
	/*Check if variable exists*/
	{
		u32 i;
		for (i = 0; i < t->used; i++)
		{
			id = T_MAKE_TYPE(T_VAR, i);
			if (strcmp(in, (char*)content(id)) == 0)
			{
				return id; /*Retrun the exsiting id*/
			}
		}
	}
	
	/* one extra byte is used to save group number 
	   to support optional graph pattern
	*/
	dst = sparql_new(strlen(in)+1+1);
	strcpy(dst, in);
	
	t->tbl[t->used] = (u32)dst;
	t->used++;
	if (t->used >= t->size) ERR_PRT("%s running out of memory\n", t->name);
	
	id = T_MAKE_TYPE(T_VAR, t->used-1);		
	DBG_PRT("Notice : new %s, '%s', id = 0x%.8X\n", t->name, in, id);
	
	return id;	
}

/************************************/
/* Create a new blank node
*/
SparQLType insert_bkv()
{
	Table *t = &tblsAddr[T_BKV];
	SparQLType id = T_UNKNOWN;
	char *dst = NULL;
	
	dst = sparql_new(4); /*make space for "_%.2d"*/
	sprintf(dst, "_%.2d", t->used);
	
	t->tbl[t->used] = (u32)dst;
	t->used++;
	if (t->used >= t->size) ERR_PRT("%s running out of memory\n", t->name);
	
	id = T_MAKE_TYPE(T_BKV, t->used-1);		
	DBG_PRT("Notice : new %s, id = 0x%.8X\n", t->name, id);
	
	return id;	
}

/************************************/
/* Create a new IRI
*/
SparQLType insert_iri(char* in, int bCpy)
{
	Table *t = &tblsAddr[T_IRI];
	SparQLType id = T_UNKNOWN;
	char *dst = in;
	
	if (strstr(in, "://") == NULL)
	{	/* This is a relative IRI
		   Append input to BASE IRI
		*/
		u32 l1 = 0, l2 = 0;
		if (gpBase == NULL)
		{
			DBG_PRT("Error : Fail to append %s to BASE IRI, which does not exist\n", in);
			return T_UNKNOWN;
		}
		l1=strlen(gpBase); l2=strlen(in);
		dst = sparql_new(l1 + l2 + 1);
		strncat(dst, gpBase, l1);strcat(dst, in);
	}else if (bCpy)
	{
		dst = sparql_new(strlen(in)+1);
		strcat(dst, in);
	}
	
	t->tbl[t->used] = (u32)dst;
	t->used++;
	if (t->used >= t->size) ERR_PRT("%s running out of memory\n", t->name);
	
	id = T_MAKE_TYPE(T_IRI, t->used-1);		
	DBG_PRT("Notice : new %s, '%s', id = 0x%.8X\n", t->name, in, id);
	
	return id;
}

/************************************/
/* Create a new string
*/
SparQLType insert_str(char* in, int bCpy)
{
	Table *t = &tblsAddr[T_STR];
	SparQLType id = T_UNKNOWN;
	char *dst = in;
	
	if (bCpy)
	{
		dst = sparql_new(strlen(in)+1);
		strcpy(dst, in);
	}
	
	t->tbl[t->used] = (u32)dst;
	t->used++;
	if (t->used >= t->size)
		ERR_PRT("%s running out of memory\n", t->name);
	
	id = T_MAKE_TYPE(T_STR, t->used-1);		
	DBG_PRT("Notice : new %s, '%s', id = 0x%.8X\n", t->name, in, id);
	
	return id;
}

/************************************/
/* Create a new literal
   if op==T_UNKNOWN, 'type' is 
   a mapped integer of data type URI; 
   if op==T_STR, 'type' is 
   a SparQL string;
*/
SparQLType insert_ltr(char* in, const int op, const unsigned int type)
{
	int i=0;
	Table *t = &tblsAddr[T_LTR];
	SparQLType id = T_UNKNOWN;
	char *tmp = NULL;
	
	if (op == T_UNKNOWN)
	{
		tmp = sparql_new(strlen(in)+16);
		if (type == L_INT || type == L_DEC || type == L_DBL)
			sprintf(tmp, "r(%i,\"%s\")", type, in);
		else
			sprintf(tmp, "r(%i,%s)", type, in);
	}else 
	{
		if (T_TYPE_MASK(op) == T_STR)
		{
			/* Retrieve the value string and 
			   data type URI
			*/
			char *op_str = (char*)content(op);
			char *type_str = (char*)content(type);
			for (i = L_PLAIN; i <= L_STR; ++i)
			{
				if (strcmp(type_str, ltr_type[i])==0)
				{
					tmp = sparql_new(strlen(op_str)+24);
					sprintf(tmp, "r(%i,%s)", i, op_str);
				}
			}
			
			if (tmp==NULL) //not known datatype URI
			{
				tmp = sparql_new(strlen(op_str)+strlen(type_str)+24);
				strcpy(gpTmp1, op_str);
				gpTmp1[strlen(op_str)-1]='\0';
				sprintf(tmp, "newLit(\"\\\"%s\\\"\\^\\^<%s>\")", gpTmp1+1, type_str);
			}
		}
	}
	
	if (tmp != NULL)
	{
		/*save input*/
		t->tbl[t->used] = (u32)tmp;
		t->used++;
		if (t->used >= t->size)
			ERR_PRT("%s running out of memory\n", t->name);
	
		id = T_MAKE_TYPE(T_LTR, t->used-1);		
		DBG_PRT("Notice : new %s, '%s', id = 0x%.8X\n", t->name, in, id);
	}else
		id = T_UNKNOWN;
	
	return id;	
}

/************************************/
SparQLType mk_plain_ltr(SparQLType strID, const char* tag)
{
	SparQLType id = T_UNKNOWN;
	char *tmp = NULL;
	char *str = (char*)content(strID);

	if ( tag != NULL )
	{
		tmp = sparql_new(strlen(str)+strlen(tag)+8);
		strcpy(tmp,str);
		str[strlen(str)-1]='\\';
		sprintf(tmp, "\"\\%s\"%s\"", str, tag);
	}else
	{
		tmp = sparql_new(strlen(str)+1);
		sprintf(tmp, "%s", str);
	}
	id = mk_ltr(tmp,1);

	return id;
}

/************************************/
/* Create a new empty list
   List node can be any type of SparQLType
*/
SparQLType insert_list(void)
{  
	/*src is the first element in the list*/
	
	Table *t = &tblsAddr[T_LST];
	SparQLType id = T_UNKNOWN;
	struct ListHeadNode *head = NULL;
	
	head = sparql_new(sizeof(struct ListHeadNode));
	head->next = T_LST_END;
	head->end = (struct ListNode*)head;
	
	t->tbl[t->used] = (u32)head;
	t->used++;
	if (t->used >= t->size)
		ERR_PRT("%s running out of memory\n", t->name);
	
	id = 	T_MAKE_TYPE(T_LST, t->used-1);
	DBG_PRT("Notice : new %s, id = 0x%.8X\n", t->name, id);
	
	return id ;
}

/************************************/
/* Create a mapping 
   from prefixed label to URI
*/
SparQLType insert_prefix(SparQLType name, SparQLType URI)
{
	SparQLType id = T_UNKNOWN;
	Table *t = &tblsAddr[T_PRF];
	struct PrefixMapping *prefix = NULL;
	
	prefix = (struct PrefixMapping*)sparql_new(sizeof(struct PrefixMapping));
	prefix->name = name;
	prefix->URI = URI;
	
	t->tbl[t->used] = (u32)prefix;
	t->used++;
	if (t->used >= t->size)
		ERR_PRT("%s running out of memory\n", t->name);
	
	id = T_MAKE_TYPE(T_PRF, t->used-1);
	DBG_PRT("Notice : new %s, id = 0x%.8X <-- 0x%.8X, 0x%.8X\n", t->name, id, name, URI);
	
	return id ;
}

/************************************/
/* Retrieve URI from
   a prefixed name mapping
   id(in): an existing PrefixMapping
*/
SparQLType get_prfx_uri(SparQLType id)
{
	struct PrefixMapping *prefix = (struct PrefixMapping*)content(id);
	return prefix->URI;
}	

/************************************/
/* Find a PrefixMapping by 
   a prefixed label
*/
SparQLType find_prfx(const char* in)
{
	u32 i;
	SparQLType id = T_UNKNOWN;
	Table *t = &tblsAddr[T_PRF];
	struct PrefixMapping *prefix = NULL;
	
	for (i = 0; i < t->used; i++)
	{
		id = T_MAKE_TYPE(T_PRF, i);
		prefix = (struct PrefixMapping*)content(id);
		if (strcmp(in, (char*)content(prefix->name)) == 0)
			return id; 
	}
	
	ERR_PRT("Unknown prefix name '%s'\n", in);
	return T_UNKNOWN;
}

/************************************/
/* Mapped to an IRI by concatenating 
   the local part to the IRI 
   corresponding to the prefix label
   src(in): a PrefixMapping
   ncname(in): local part
*/
SparQLType map_prfx_uri(SparQLType src, const char* ncname)
{
	struct PrefixMapping *prefix = (struct PrefixMapping*)content(src);
	const char *p = (char*)content(prefix->URI);
	char *uri = NULL;
	SparQLType id = T_UNKNOWN;
	
	if (T_TYPE_MASK(src) != T_PRF)
	{			
		DBG_PRT("Error : map_prfx_uri with wrong input 0x%.8X\n", src);
		return T_UNKNOWN;
	}
	
	uri = sparql_new(strlen(p)+strlen(ncname)+1);
	strncpy(uri, p, strlen(p));strcat(uri, ncname);
	
	id = mk_iri2(uri);
	
	return id;
}

/************************************/
void make_order_info(SparQLType name, char *order)
{
	strncpy(gOBI[gNumOfOBI].name, content(name), MAX_VAR_LEN);
	strcpy(gOBI[gNumOfOBI].order,order);
	gOBI[gNumOfOBI].index = -1;
	++gNumOfOBI;
}

/************************************/
void __list_internal__(SparQLType dst, SparQLType ii, va_list *pMarker, u8 bHead)
{
	struct ListHeadNode *head = NULL;
	struct ListNode *newNode = NULL;
	struct ListNode *endNode = NULL;
	SparQLType i = ii;
	
	if (T_TYPE_MASK(dst) != T_LST)
	{			
		DBG_PRT("Error : __list_internal__ with wrong input 0x%.8X\n", dst);
		return;
	}
	DBG_PRT("Notice : __list_internal__ 0x%.8X <-- ", dst);
	
	head = (struct ListHeadNode*)content(dst);
	
	while( i != T_LST_END )
	{
		if (i != T_EMPTY)
		{
			newNode = (struct ListNode*)sparql_new(sizeof(struct ListNode));
			
			if (bHead)
			{	/*push head*/
				newNode->next = head->next; 
				newNode->value = i;
				
				head->next = newNode;
			}else
			{	/*push tail*/
				newNode->next = T_LST_END; 
				newNode->value = i;
				
				endNode = head->end;
				endNode->next = newNode;
				head->end = newNode;
			}
			
			DBG_PRT1("0x%.8X ", i);
		}
		
		i = va_arg( *pMarker, SparQLType);
	}
	
	DBG_PRT1("\n");
	return;	
}

/************************************/
/* Append elements to an existing list
   The first input argument should be a
   list
*/
void append_to_list_back(SparQLType dst, ...)
{
	SparQLType i = dst;
	va_list marker;
	
	va_start( marker, dst );     /* Initialize variable arguments. */
	i = va_arg( marker, SparQLType);	 
	__list_internal__(dst, i, &marker, 0);
	va_end( marker );            /* Reset variable arguments.      */
	
	return;
}

/************************************/
/* Create a new list and store
   The first input argument is
   the first element in the list
*/
SparQLType new_list_and_merge(SparQLType first, ...)
{
	va_list marker;
	SparQLType dst = mk_lst();
	
	va_start( marker, first );     /* Initialize variable arguments. */
	__list_internal__(dst, first, &marker, 0);
	va_end( marker );              /* Reset variable arguments.      */
	
	return dst;	
}

/* Append elements to an existing list
   The first input argument should be a
   list
   
   !! Notice !!
   append_to_list_front(lst, a, b, c, T_LST_END)
   will an existing list [a] to [c b a ...]  
*/
void append_to_list_front(SparQLType dst, ...)
{
	SparQLType i = dst;
	va_list marker;
	
	va_start( marker, dst );     /* Initialize variable arguments. */
	i = va_arg( marker, SparQLType);	 
	__list_internal__(dst, i, &marker, 1);
	va_end( marker );              /* Reset variable arguments.      */
	
	return;
}

/************************************/
u32 traverse_list_internal(SparQLType lst, char *buf, int *num_of_elem)
{
	u32 len = 0;
	struct ListHeadNode *head = NULL;
	struct ListNode *node = NULL;
	
	head = (struct ListHeadNode*)content(lst);
	node = head->next;
	
	while (node != T_LST_END)
	{
		if (T_TYPE_MASK(node->value) == T_LST)
		{
			len += traverse_list_internal(node->value, buf, num_of_elem);
		}
		else if (T_TYPE_MASK(node->value) == T_TPL)
		{
			struct Triple *t = content(node->value);
			if (num_of_elem != NULL) (*num_of_elem)++;
			len += strlen(t->cntnt)+1;/*one space character*/
			if (buf != NULL) {strcat(buf, t->cntnt);	/*strcat(buf, " ");*/}
		}else if (T_TYPE_MASK(node->value) == T_FLT)
		{
			struct Filter *t = content(node->value);
			if (num_of_elem != NULL) (*num_of_elem)++;
			len += strlen(t->cntnt)+1;/*one space character*/
			if (buf != NULL) {strcat(buf, t->cntnt);	/*strcat(buf, " ");*/}
		}else if (T_TYPE_MASK(node->value) >= T_VAR && 
			T_TYPE_MASK(node->value) <= T_STR)
		{
			if (num_of_elem != NULL) (*num_of_elem)++;
			len += strlen((char*)content(node->value))+1;/*one space character*/
			if (buf != NULL) {strcat(buf, (char*)content(node->value));	/*strcat(buf, " ");*/}
		}
		node = node->next;
	}
	
	return len;
}
/* Traverse a list, store the content of its
   elements in a T_STR
*/
SparQLType traverse_list(SparQLType lst)
{
	char *dst = NULL;
	SparQLType id = T_UNKNOWN;
	
	u32 len = traverse_list_internal(lst, NULL, NULL);
	
	/*insert a new T_STR*/
	dst = sparql_new(len+1);
	traverse_list_internal(lst, dst, NULL);
	
	/*in case len == 0*/
	strcat(dst, "");
	
	id = mk_str2(dst);	
	DBG_PRT("Notice : traverse_list result = '%s', id = 0x%.8X\n", dst, id);
	
	return id;
}

/************************************/
int _new_triple_(SparQLType s, SparQLType p, SparQLType o, int iOptional)
{
	u32 len;
	char *dst = NULL;
	SparQLType id = T_UNKNOWN;
	char *ss=NULL,*pp=NULL,*oo=NULL;
	Table *t = &tblsAddr[T_TPL];
	struct Triple *pTrpl = NULL;

	pTrpl = sparql_new(sizeof(struct Triple));
	pTrpl->var = T_UNKNOWN;

	ss = (char*)content(s);	pp = (char*)content(p);	oo = (char*)content(o);

	if (T_TYPE_MASK(s)==T_VAR)
	{
		unsigned char *pGroup = ss+strlen(ss)+1;
		if (*pGroup == 0)
		{
			*pGroup = iOptional;
			if (*pGroup > OPT_ROOT)
				pTrpl->var = s;
		}
		else if (*pGroup > 1) return *pGroup;
	}
	if (T_TYPE_MASK(p)==T_VAR)
	{
		unsigned char *pGroup = pp+strlen(pp)+1;
		if (*pGroup == 0) 
		{
			*pGroup = iOptional;
			if (*pGroup > OPT_ROOT)
				pTrpl->var = p;
		}
		else if (*pGroup > 1) return *pGroup;
	}
	if (T_TYPE_MASK(o)==T_VAR)
	{
		unsigned char *pGroup = oo+strlen(oo)+1;
		if (*pGroup == 0) 
		{
			*pGroup = iOptional;
			if (*pGroup > OPT_ROOT)
				pTrpl->var = o;			
		}
		else if (*pGroup > 1) return *pGroup;
	}
		
	pTrpl->group = iOptional;

	if (T_TYPE_MASK(o)==T_LTR)
	{
		/*Calculating the maximum length*/
		len = strlen(ss)+strlen(pp)+strlen(oo)+strlen(gRDF_parser)+
					strlen("(,)=<uri(\"\"),uri(\"\")>")+strlen(gRDF_src)+1;
		dst = sparql_new(len+1);
		
		/*subject: IRI or blank node; predicate: IRI or blank node; object: literal*/
		sprintf(dst, "%s(%s,%s)=<", gRDF_parser, gRDF_src, oo);
		
		if (strcmp(pp, "http://example.org/things#p")==0)
			len=1;

		if (T_TYPE_MASK(s)==T_IRI)
			sprintf(dst+strlen(dst), "uri(\"%s\"),", ss);
		else
			sprintf(dst+strlen(dst), "%s,", ss);
		if (T_TYPE_MASK(p)==T_IRI)
			sprintf(dst+strlen(dst), "uri(\"%s\")>", pp);
		else
			sprintf(dst+strlen(dst), "%s>", pp);
	}else{
		/*assume the possible maximum length is <uri(s),uri(p),uri(o)>*/
		len = strlen(ss) + strlen(pp) + strlen(oo) + strlen(gRDF_parser) +
				strlen("()=<uri(\"\"),uri(\"\"),uri(\"\")>")+strlen(gRDF_src)+1;
		dst = sparql_new(len+1);
		
		sprintf(dst, "%s(%s)=<", gRDF_parser, gRDF_src);
		if (T_TYPE_MASK(s)==T_IRI) 
			sprintf((char*)(dst+strlen(dst)), "uri(\"%s\"),", ss);
		else 
			sprintf((char*)(dst+strlen(dst)), "%s,", ss);
		
		if (T_TYPE_MASK(p)==T_IRI) 
			sprintf((char*)(dst+strlen(dst)), "uri(\"%s\"),", pp);
		else 
			sprintf((char*)(dst+strlen(dst)), "%s,", pp);
		
		if (T_TYPE_MASK(o)==T_IRI) 
			sprintf((char*)(dst+strlen(dst)), "uri(\"%s\")", oo);
		else if (T_TYPE_MASK(o)==T_VAR || T_TYPE_MASK(o)==T_BKV) 
			sprintf((char*)(dst+strlen(dst)), "%s", oo);
		else 
			*(char*)(0) = 1;
		strcat(dst,">");
	}

	pTrpl->cntnt = dst;

	/*save input*/
	t->tbl[t->used] = (u32)pTrpl;
	t->used++;
	if (t->used >= t->size)
		ERR_PRT("%s running out of memory\n", t->name);
	
	id = T_MAKE_TYPE(T_TPL, t->used-1);		
	DBG_PRT("Notice : new %s, id = 0x%.8X, '%s'\n", t->name, id, dst);

	return 0;
}
int _object_list_(SparQLType s, SparQLType p, SparQLType objLst, int iOptional)
{
	struct ListHeadNode *head = NULL;
	struct ListNode *node = NULL;
	
	head = (struct ListHeadNode*)content(objLst);
	node = head->next;
	
	while (node != T_LST_END)
	{
		if (_new_triple_(s, p, node->value, iOptional)!=0)
			return 1;
		node = node->next;
	}
	
	return 0;
}

/* Extract content from SparQLType id.
 * Added by Johan Petrini
 */
char* getstr(SparQLType id)
{
  return (char*)content(id);
}


/* Create a new triple
*/
int insert_triple(SparQLType subject, SparQLType lst, int iOptional)
{
	struct ListHeadNode *head = NULL;
	struct ListNode *node = NULL;

	head = (struct ListHeadNode*)content(lst);
	node = head->next;
	
	while (node != T_LST_END)
	{
		if (node->next == T_LST_END)
			ERR_PRT("insert_triple, missing verb or object list\n");
		
		/*There might be several objects in the syntax like:
		subject predicate obj1, obj2, which is equal to
		subject predicate obj1 and subject predicate obj2*/
		if (_object_list_(subject, node->value, (node->next)->value, iOptional)!=0)
			return 1;
		
		node = (node->next)->next;
	}
	
	return 0;
}

/************************************/
/* Create a new filter
*/
void insert_filter(SparQLType lst, int group)
{
	Table *t = &tblsAddr[T_FLT];
	struct Filter *f = sparql_new(sizeof(struct Filter));
	SparQLType id = traverse_list(lst);
	
	f->cntnt = content(id);
	f->group = group;
	
	t->tbl[t->used] = (u32)f;
	t->used++;
	if (t->used >= t->size)
		ERR_PRT("%s running out of memory\n", t->name);
	
	id = T_MAKE_TYPE(T_FLT, t->used-1);		
	DBG_PRT("Notice : new %s, id = 0x%.8X\n", t->name, id);
}

/************************************/
/* Generates the from_clause
   in AmosQL
*/
SparQLType amos_decl_var(void)
{
	SparQLType var_decl_lst = T_UNKNOWN;
	SparQLType var_decl = T_UNKNOWN;
	SparQLType tmp = T_UNKNOWN;
	Table *t = &tblsAddr[T_VAR];
	u32 i;
	
	if (t->used == 0) return T_UNKNOWN;	/*no variable*/
	
	tmp = mk_str("\nfrom Resource ");
	var_decl = T_MAKE_TYPE(T_VAR, 0);
	var_decl_lst = new_list_and_merge(tmp, var_decl, T_LST_END);
	
	tmp = mk_str(",Resource ");
	for (i = 1; i < t->used; i++) 
	{ 
		var_decl = T_MAKE_TYPE(T_VAR, i);
		append_to_list_back(var_decl_lst, tmp, var_decl, T_LST_END);
	}
	
	t = &tblsAddr[T_BKV];
	for (i = 0; i < t->used; i++) 
	{ 
		var_decl = T_MAKE_TYPE(T_BKV, i);
		append_to_list_back(var_decl_lst, tmp, var_decl, T_LST_END);
	}

	return var_decl_lst;
}

/************************************/
/* Generates the queried variables
   in AmosQL
*/
SparQLType amos_query_var(void)
{
	SparQLType var_lst = T_UNKNOWN;
	SparQLType var = T_UNKNOWN;
	SparQLType tmp = T_UNKNOWN;
	Table *t = &tblsAddr[T_VAR];
	u32 i;
	
	if (t->used == 0) return T_UNKNOWN;	/*no variable*/
	
	var = T_MAKE_TYPE(T_VAR, 0);
	var_lst = new_list_and_merge(var, T_LST_END);
	
	tmp = mk_str(",");
	for (i = 1; i < t->used; i++) 
	{ 
		var = T_MAKE_TYPE(T_VAR, i);
		append_to_list_back(var_lst, tmp, var, T_LST_END);
	}
	
	return var_lst;
}

/************************************/
/* Generates the where_clause 
   in AmosQL
*/
int _amos_condition_internal_(int group, SparQLType condition_lst, SparQLType and)
{
	u32 i;
	Table *t = NULL;
	struct Triple *trpl = NULL;
	struct Filter *fltr = NULL;
	int bOptional = group > OPT_ROOT;
	SparQLType varID = T_UNKNOWN;

	if (bOptional)
		append_to_list_back(condition_lst, mk_str("and\n"), T_LST_END);
	
	/*Make condition from triples*/
	t = &tblsAddr[T_TPL];
	if (t->used != 0) 
	{
		for (i = 0; i < t->used; i++) 
		{
			trpl = content(T_MAKE_TYPE(T_TPL, i));
			if (trpl->group == group)
			{
				if (trpl->var!=T_UNKNOWN)
					varID = trpl->var;
				append_to_list_back(condition_lst, T_MAKE_TYPE(T_TPL, i), T_LST_END);	
				break;
			}
		}
		
		for (i=i+1; i < t->used; i++) 
		{
			trpl = content(T_MAKE_TYPE(T_TPL, i));
			if (trpl->group == group)
			{
				if (trpl->var!=T_UNKNOWN)
					varID = trpl->var;
				append_to_list_back(condition_lst, and, T_MAKE_TYPE(T_TPL, i),  T_LST_END);	
			}
		}
	}
	
	/*Make condition from FILTER*/
	t = &tblsAddr[T_FLT];
	for (i = 0; i < t->used; i++) 
	{
		fltr = content(T_MAKE_TYPE(T_FLT, i));
		if (fltr->group == group)
			append_to_list_back(condition_lst, and, 
				mk_str("FLTR("),T_MAKE_TYPE(T_FLT, i),gCloseB,T_LST_END);	
	}	

	return 0;
}
SparQLType amos_condition(void)
{
	SparQLType condition_lst = T_UNKNOWN;
	SparQLType and = T_UNKNOWN;
	int j;
	
	and = mk_str("and\n");
	
	condition_lst=mk_lst();
	
	for (j = 1; j <= gGroupCount; ++j)
	{
		_amos_condition_internal_(j, condition_lst, and);
	}
	
	return condition_lst;	
}

/***************************************/
/* Produces the AmosQL statement
*/
char* output_query(void)
{
	char *pQuery;
	int i,j;
	struct ListHeadNode *head = NULL;
	struct ListNode *node = NULL;
	SparQLType AmosQLLst = T_UNKNOWN;
	SparQLType AmosQL = T_UNKNOWN;
	SparQLType vecofPos = T_UNKNOWN;
	SparQLType vecofOrder = T_UNKNOWN;

	AmosQLLst = mk_lst();
	append_to_list_back(AmosQLLst, 
		mk_str("select"),gDistinct,mk_str("{"),gQueryVar,mk_str("}"),amos_decl_var(),T_LST_END);
	append_to_list_back(AmosQLLst, 
		/*DatasetClause_S,*/mk_str("\nwhere "),amos_condition(),/*SolutionModifier,*/ 
		T_LST_END);

	/*****************************************
				Fill gQueryVarName
	******************************************/
	head = (struct ListHeadNode*)content(gQueryVar);
	node = head->next;
	for (j = 0; ; ++j)
	{
		strcpy(gQueryVarName[j],(char*)content(node->value));
		for (i = 0; i < gNumOfOBI; ++i)
		{
			if (strcmp(gOBI[i].name,gQueryVarName[j])==0)
				gOBI[i].index = j+1;
		}
		node = node->next;
		if (node==T_LST_END) break;
		/*Now, content of this node should be ',', so advance one more node*/
		node = node->next;
	}

	/*Solution Modifier*/
	if (gNumOfOBI != 0)
	{
		char buffer[5];
		itoa(gOBI[0].index,buffer,10);
		vecofPos = new_list_and_merge(mk_str("{"),mk_str(buffer),T_LST_END);
		vecofOrder = new_list_and_merge(mk_str("{"),mk_str(gOBI[0].order),T_LST_END);
		for (i = 1; i < gNumOfOBI; ++i)
		{
			itoa(gOBI[i].index,buffer,10);
			append_to_list_back(vecofPos,gComma,mk_str(buffer),T_LST_END);
			append_to_list_back(vecofOrder,gComma,mk_str(gOBI[i].order),T_LST_END);
		}
		append_to_list_back(vecofPos,mk_str("}"),T_LST_END);
		append_to_list_back(vecofOrder,mk_str("}"),T_LST_END);

		append_to_list_front(AmosQLLst,mk_str("sortbagby(("),T_LST_END);
		append_to_list_back(AmosQLLst,gCloseB,gComma,vecofPos,gComma,vecofOrder,gCloseB,T_LST_END);
	}
	
	append_to_list_back(AmosQLLst,mk_str(";"),T_LST_END);
	AmosQL = traverse_list(AmosQLLst);
	pQuery = (char*)content(AmosQL);
	
	/*INFO_PRT("\n%s\n\n", pQuery);*/
	
	return pQuery;
}

void set_limit(const char * _limit)
{
	gLimit = atoi(_limit);
	if (gLimit < 0) gLimit = 0;
}

void set_offset(const char * _offset)
{
	gOffset = atoi(_offset);
	if (gOffset < 0) gOffset = 0;
}

/************************************/	
void sparql_init(void)
{
	a_extfunction("sparql_query", sparql_query);

	a_extfunction("sparql_new_lit", sparql_new_lit);
	a_extfunction("sparql_ebv", sparql_ebv);
	a_extfunction("sparql_cmp", sparql_cmp);

	a_extfunction("sparql_neg", sparql_neg);	
	
	a_extfunction("sparql_div", sparql_div);
	a_extfunction("sparql_times", sparql_times);
	a_extfunction("sparql_plus", sparql_plus);
	a_extfunction("sparql_minus", sparql_minus);
	
	a_extfunction("sparql_LANG", sparql_LANG);

	/*
        sparql_amos_c = a_init_connection();
        a_connect(sparql_amos_c,"",FALSE);
	*/
        parserErrorID = a_register_error("SparQL syntax error");
}

/************************************/
