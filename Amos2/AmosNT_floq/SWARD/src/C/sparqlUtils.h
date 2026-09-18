/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Yu Cao, Tore Risch, UDBL
 * $RCSfile: sparqlUtils.h,v $
 * $Revision: 1.4 $ $Date: 2007/07/27 17:13:21 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Declarations for stand-alone SparQL parser
 * ===========================================================================
 * $Log: sparqlUtils.h,v $
 * Revision 1.4  2007/07/27 17:13:21  torer
 * DLL initialization without modifying system source code
 *
 * Revision 1.3  2007/07/24 05:55:37  petrini
 * *** empty log message ***
 *
 * Revision 1.1  2007/07/23 20:24:16  petrini
 * *** empty log message ***
 *
 * Revision 1.2  2007/06/12 20:05:45  torer
 * Better syntax error messages
 *
 * Revision 1.1  2007/06/12 14:32:40  torer
 * Stand-alone SparQL parser in C
 *
 ****************************************************************************/

#ifndef _SPARQL_UTILS_H_
#define _SPARQL_UTILS_H_

#define ERR_PRT		printf

#if 0
/* Print debug message */
#define DBG_PRT		printf("\t\t>> "); printf
#define DBG_PRT1	printf
#else
#define DBG_PRT		dummy_print
#define DBG_PRT1	dummy_print
#endif

#if 1
/* Print information message*/
#define INFO_PRT	printf
#else
#define INFO_PRT	dummy_print
#endif

void dummy_print(char *in, ...);
void error_reason(char *in);

#define MAX_INPUT	(2048)

#define T_TYPE_MASK(a)		((a & 0xFFFF0000) >> 16)
#define T_VAL_MASK(a)		(a & 0x0000FFFF)		
#define T_MAKE_TYPE(a,b)	((a << 16) | ( b & 0x0000FFFF))

typedef unsigned int SparQLType;

#define T_LST_END			(0)
#define T_VAR				(1)
#define T_BKV				(2)
#define T_IRI				(3)
#define T_LTR				(4)
#define T_STR				(5)
#define T_TPL				(6)
#define T_LST				(7)
#define T_PRF				(8)
#define T_FLT				(9)
#define T_EMPTY				(0xFFFE0000)
#define T_UNKNOWN			(0xFFFF0000)

/*Map URI reference or typed literal's data type URI to Integer*/
#define L_RES			(0)		/* URI reference	*/
#define L_PLAIN			(1)		/* Plain literal	*/
#define L_INT			(2)		/* xsd:integer		*/
#define L_DEC			(3)		/* xsd:decimal		*/
#define L_DBL			(4)		/* xsd:double		*/
#define L_BOOL			(5)		/* xsd:boolean		*/
#define L_STR			(6)		/* xsd:string		*/

/*****************************************
  extern from uri.c
  A C function to create 'Resource'
******************************************/
extern oidtype new_R(int, char*);
extern char *ltr_type[];

extern SparQLType	gQueryVar;
extern SparQLType	gDistinct;
extern SparQLType 	gComma;
extern SparQLType 	gCloseB;
extern char *gRDF_src; /*Holds the name of RDF source. Added by Johan Petrini*/
extern char *gpErrMsg;


int		in_opt();
int		enter_opt();
int		leave_opt();
int		get_opt();

SparQLType 	get_prfx_uri(SparQLType id);
SparQLType 	insert_prefix(SparQLType name, SparQLType URI);
SparQLType	amos_query_var(void);
SparQLType 	insert_str(char* in, int bCpy);
SparQLType	mk_plain_ltr(SparQLType strID, const char* tag);
SparQLType 	insert_iri(char* in, int bCpy);
SparQLType 	insert_bkv();
SparQLType 	insert_ltr(char* in, const int op, const unsigned int type);
SparQLType 	map_prfx_uri(SparQLType src, const char* ncname);
SparQLType 	find_prfx(const char* in);
SparQLType 	insert_list(void);
SparQLType 	new_list_and_merge(SparQLType dst, ...);
SparQLType 	insert_var(char* in);

#define content(a)(void*)((Table*)(&tblsAddr[T_TYPE_MASK(a)])->tbl[T_VAL_MASK(a)])
void	mk_base(SparQLType uri);
#define mk_prfx(a,b)	(insert_prefix(a,b))
#define mk_str(a)	(insert_str(a, 1))
        /*content of 'a' will be copied and saved*/
#define mk_str2(a)(insert_str(a, 0))
        /*'a', as a pointer, will be saved*/
char* getstr(SparQLType id); 
        /* Extract content of an SparQL id. Added by Johan Petrini*/
#define mk_ordrinf(a,b)	(make_order_info(a,b))
#define mk_iri(a)(insert_iri(a, 1))/*content of 'a'' will be copied and saved*/
#define mk_iri2(a)(insert_iri(a, 0))/*'a', as a pointer, will be saved*/
#define mk_bkv()		(insert_bkv())
#define mk_ltr(a,b) (insert_ltr(a, T_UNKNOWN, b))	/*'a' is a C string*/
#define mk_ltr2(a,b)(insert_ltr(NULL, a, b))/*'a'' is a T_STR ID*/
#define mk_fltr(a,b)	(insert_filter(a,b))
#define mk_lst()		(insert_list())
#define mk_tpl(a,b,c)	(insert_triple(a,b,c))
#define mk_var(a)		(insert_var(a))

char*	output_query(void);

#define r_uri			(0)
#define r_plain_lit		(1)
#define r_xsd_integer	(2)
#define r_xsd_decimal	(3) 
#define r_xsd_double	(4)
#define r_xsd_boolean	(5)
#define r_xsd_string	(6)

int 		insert_triple(SparQLType subject, SparQLType lst, int group);
void 		insert_filter(SparQLType lst, int group);
void 		append_to_list_front(SparQLType dst, ...);
void		make_order_info(SparQLType name, char *order);

void	set_limit(const char *_limit);
void	set_offset(const char *_offset);

void init_help(void);

void sparql_init(char *image);
int	sparql_input(char *buf, int max_size);

#endif
