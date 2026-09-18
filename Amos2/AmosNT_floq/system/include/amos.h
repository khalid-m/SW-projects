/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1997 Tore Risch
 * $Revision:
 * $State:
 *
 * Description: Exported Amos2 declarations
 *
 * Requirements:
 * ===========================================================================
 * $Log:
 */
#ifndef _amos_h_
#define _amos_h_

#include "intstorage.h"
#include "kernel.h"
#include "index.h"
#include "a_time.h"
#include "amosfns.h"


/*** Physical object templates ***/

struct oidcell       /* Amos OID */
{
  objtags tags;
  char proxyflg;     /* TRUE if proxy object */
  char traceflg;     /* TRUE if traced */
  int idno;          /* OID number */
  oidtype types;     /* List of types. Most specific type MST first */
  oidtype propl;     /* Property list */
  oidtype next;      /* next OID of the MST */
  oidtype prev;      /* previous OID of the MST */
};


/*** Parsers ***/

typedef struct
{
  FILE filedesc;     /* What flex believes is the stream to parse from */
  oidtype stream;    /* The Amos stream from which to parse */
  int char_num;      /* Current position in line being parsed */
  int function_flg;  /* TRUE if non-procedure is being parsed */
  int key_pos;       /* Position of start of interesting keyword */
  int language;      /* Tag inficating language parsed in file */
  oidtype logstream; /* The stream used for logging input */
  int filestream;    /* TRUE is parsing from file */
  char *buffer;      /* Pointer to flex buffer state record */
} flexstream;

EXTERN int a_flexstream_getc(flexstream *fs,char* buf); /* Called from flex*/
EXTERN void a_parse_error(flexstream *fs,char *s); /* Called from flex */
EXTERN oidtype a_language_object(char *language); /* The symbol representing 
						     a language */
EXTERN int a_language_parser_id(char *language); /* The id# for the parser
						    of a language */
EXTERN int a_define_parser(char *language, 
                           oidtype(*parser)(bindtype, flexstream *),
                           void(*result_printer)(oidtype),
                           void(*initializer)(flexstream *),/* change to */
                           void(*finalizer)(flexstream *));/* change from */
EXTERN oidtype a_parse_filefn(bindtype env, oidtype filep, oidtype language,
                              oidtype loudflg); /* Parse file with statements*/
EXTERN int a_query_language; /* The initial query language parser id# */

/*** Kernel interfaces ***/

EXTERN int generatortype;

extern oidtype amos_error, throw_label, global_reset;
extern oidtype history_addfn(bindtype env, oidtype event, oidtype obj, 
			     oidtype arg,
			     oidtype old, oidtype nw);
extern oidtype history_rollbackfn(bindtype,oidtype);
extern oidtype commitfn(bindtype env);
extern oidtype rollbackfn(bindtype env, oidtype savepoint);

extern oidtype addfunction0fn(bindtype env, oidtype name, oidtype key,
			      oidtype res, oidtype nocheck);
extern oidtype maprelation(bindtype env, oidtype rel, oidtype pat,
			   index_mapfn fn, void *xa);
typedef void(*result_function)(bindtype env, bindtype eenv, oidtype resvars,
                               void *xa);
extern oidtype make_reslist(int arity, oidtype *restpl, int allownil);
EXTERN oidtype callfunction(bindtype env, oidtype fno, oidtype args,
                            int stopafter);
EXTERN oidtype resolvenamefn(bindtype env, oidtype fno, oidtype argl, 
                             oidtype resl);
extern oidtype relationpfn(bindtype env,oidtype x);
extern oidtype allsupertypessymbol;
extern oidtype booleanpfn(bindtype,oidtype);
#define most_specific_type(x) (x==nil ? nil : hd(x))
#define oid_types(x) dr(x,oidcell)->types
#define get_allsupertypes(x) getobjectfn(env,x,allsupertypessymbol)

extern oidtype getobjectfn(bindtype env,oidtype o, oidtype prop);
extern oidtype putobjectfn(bindtype env,oidtype o, oidtype prop, oidtype val);
extern oidtype getobjectnamedfn(bindtype env,oidtype name,oidtype type,
                                oidtype noerror);
extern oidtype oid_namefn(bindtype,oidtype o);
extern oidtype object_typepfn(bindtype env, oidtype o, oidtype tp);
extern oidtype createobject_tfn(bindtype env,oidtype type, oidtype name);
extern oidtype getobjectnumbered(int no);
extern oidtype oid_internalize(bindtype env, oidtype descr);
extern oidtype arg_typefn(bindtype env, oidtype x);
EXTERN int is_bag(oidtype x);

EXTERN int delay_emit;              /* Delay emit from Lisp with OSQL-RESULT */
extern oidtype make_restuple(bindtype benv, oidtype params, int allownil);
extern oidtype param_value(const oidtype param, const bindtype env);
extern oidtype failsymbol;

EXTERN int buffer_overflow, row_too_long;
#define MAXROW 200
#define FILEBUFFSIZE 1000
struct file_getch_state
{
  FILE *fp;
  char buff[FILEBUFFSIZE];
  size_t pos;
};

EXTERN char a_file_getch(struct file_getch_state *f);
EXTERN oidtype read_csv_linefn(bindtype env, oidtype str, oidtype delim);
EXTERN void add_CSV_times(oidtype s);
extern void gettimevalofday(struct timeval *res);

#include "callout.h"

extern oidtype extpredundef(a_callcontext cxt);
void check_initfile(void);

EXTERN int a_clientflg;

#endif


