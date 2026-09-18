/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 1998 Tore Risch, EDSLAB
 * $RCSfile: callin.h,v $
 * $Revision: 1.38 $ $Date: 2014/01/05 12:32:50 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Amos2 C call-in interface
 ****************************************************************************/

#ifndef _callin_h
#define _callin_h

#include "storage.h"

/*** Amos system initialization ***/

EXTERN void init_amos(int argc, char**argv);
                                /* Initialize Amos database from command line*/
EXTERN int a_initclient(int catcherror);           /* Initialize Amos client */
EXTERN int a_initialize(char *image, int catcherror);
                                        /* Initialize embedded Amos database */


EXTERN int AmosInitialized(void);             /* TRUE is Amos II initialized */

EXTERN void amos_toploop(char *prompter);  
                             /* Enter console top loop for embedded database */

/*** Interface data structures ***/

typedef struct a_scan_rec
{
  int hasbeeninitialized;
  oidtype here;
  oidtype row;
  int stopafter;
  int status;
} *a_scan;

typedef struct a_connection_rec
{
  int hasbeeninitialized;
  char *name;
  oidtype servid;
  oidtype port;
  int status;
  oidtype result;
  a_scan primscan;
} *a_connection;

struct tuplerec
{
   int hasbeeninitialized;
   oidtype tpl;
};

typedef struct tuplerec *a_tuple;

struct blobrec
{
   int hasbeeninitialized;
   oidtype BLOB;
};

typedef struct blobrec *a_blob;

#define dcl_oid dcloid

/*** Connect to Amos ***/

#define dcl_connection(c) a_connection c = a_init_connection()

EXTERN a_connection a_init_connection(void);
EXTERN int a_connect(a_connection c,char *amosname,int catcherror);
EXTERN int a_connectto(a_connection c,char *amosname,char *host,
                       int catcherror);
EXTERN int a_disconnect(a_connection c,int catcherror);
EXTERN void free_connection(a_connection c);
EXTERN void a_freebytes(char *); /* Free bytes allocated by Amos II */

/*** Scan interface ***/

#define dcl_scan(s) a_scan s = a_init_scan()
EXTERN a_scan a_init_scan(void);
EXTERN void free_scan(a_scan s);
EXTERN int a_execute(a_connection c, a_scan s, char *string, int catcherror);
EXTERN int a_execute_custom(a_connection c, a_scan s, char *query,
			    char *options, int catcherror);
EXTERN int a_openstream(a_connection c, a_scan s, oidtype stream, int catcherror);
EXTERN int a_openstream_custom(a_connection c, a_scan s, oidtype stream,
			       char *options, int catcherror);
EXTERN int a_openmultiscan(a_connection c, a_scan s, char *query, int catcherror);
EXTERN int a_openmultiscan_custom(a_connection c, a_scan s, char *query, 
				  char *options, int catcherror);
EXTERN int a_init_singlescan(a_scan s, oidtype o, int catcherror);
EXTERN int amosql(char *stmt, int catcherror);
#define a_eos(s) (s->row == nil)
EXTERN int a_getrow(a_scan s, a_tuple row, int catcherror);
EXTERN int a_nextrow(a_scan s,int catcherror);
EXTERN int a_openscan(a_connection c,a_scan s, int catcherror);
EXTERN int a_closescan(a_scan s,int catcherror);
EXTERN int a_killscan(a_scan s, int catcherror);

/*** Basic Scan interface ***/

EXTERN int a_execute_basic(char *amosname, a_scan scan, char *query, 
			   char *options, int catcherror);
EXTERN int a_execute_update(char *amosname, char *query, int catcherror);
EXTERN int a_nextrow_basic(a_scan, a_tuple tpl, int catcherror);
EXTERN oidtype a_getelem_basic(oidtype,int pos, int catcherror);
EXTERN int a_getstringelem_basic(oidtype oid, int pos, char *str, int maxlen,
				 int catcherror);
EXTERN double a_getdoubleelem_basic(oidtype oid, int pos, int catcherror);
EXTERN int a_eos_basic(a_scan scan, int *eos, int catcherror);

/*** Tuple interface ***/

#define dcl_tuple(t) a_tuple t = a_init_tuple()
EXTERN a_tuple a_init_tuple(void);
EXTERN void free_tuple(a_tuple t);
EXTERN int a_newtuple(a_tuple t, int size, int catcherror);
#define a_setarity(tuple,size) a_newtuple(tuple,size,FALSE)
EXTERN int a_newtuple(a_tuple t, int size, int catcherror);
EXTERN int a_getarity(a_tuple t, int catcherror);
EXTERN int a_setelem(a_tuple t,int pos, oidtype val);
EXTERN oidtype a_getelem(a_tuple t,int pos, int catcherror);
#define a_getelemtype(tuple,pos,catcherror) \
        a_datatype(a_getelem(tuple,pos,catcherror))
EXTERN int a_getelemsize(a_tuple tp, int pos, int catcherror);
#define a_getobjectelem a_getelem
#define a_setobjectelem(tuple,n,val,catcherror) a_setelem(tuple,n,val)
EXTERN int a_getstringelem(a_tuple t,int pos, char *str, int maxlen,
                                                               int catcherror);
EXTERN int a_setstringelem(a_tuple t,int pos, char *str, int catcherror);
EXTERN int a_addstringelem(a_tuple t,int pos, char *str, int catcherror);
EXTERN int a_setbyteselem(a_tuple t,int pos, int len, char *str, 
                          int catcherror);
EXTERN int a_addbyteselem(a_tuple t,int pos, int len, char *str, 
                          int catcherror);
EXTERN int a_getintelem(a_tuple t,int pos, int catcherror);
EXTERN int a_setintelem(a_tuple t,int pos, int v, int catcherror);
EXTERN double a_getdoubleelem(a_tuple t,int pos,int catcherror);
EXTERN int a_setdoubleelem(a_tuple t,int pos, double v, int catcherror);
EXTERN int a_getseqelem(a_tuple t,int pos,a_tuple a, int catcherror);
EXTERN int a_setseqelem(a_tuple t,int pos,a_tuple a, int catcherror);

/*** OID interface ***/

EXTERN int a_getid(oidtype o, int catcherror);       /* idno of OID */
EXTERN oidtype a_getobjectno(a_connection c, int n, int catcherror);
                                                            /* OID with idno */
EXTERN oidtype a_typeof(oidtype o, int catcherror);/* get type OID of object */
EXTERN char *a_stringify(oidtype o); /* Make malloced C-string of o */
EXTERN oidtype a_mksymbol(char *pname, int catcherror);
EXTERN oidtype a_createobject(a_connection c,oidtype type,int catcherror);
EXTERN int a_deleteobject(a_connection c,oidtype o,int catcherror);
EXTERN oidtype a_getfunction(a_connection c, char *name, int catcherror);
EXTERN oidtype a_getfunctionnamed(char *name, int catcherror);
EXTERN oidtype a_gettype(a_connection c, char *name, int catcherror);
EXTERN oidtype a_gettypenamed(char *name, int catcherror);


/*** Constants ***/
EXTERN oidtype truesymbol, falsesymbol, starsymbol;
#define a_true truesymbol
#define a_false falsesymbol
#define a_star starsymbol
#define a_null nil

/*** BLOB interface ***/

EXTERN a_blob a_initBLOB(void);
#define dcl_BLOB(b) a_blob b = a_initBLOB()
EXTERN int a_newBLOB(a_blob b, int size, int catcherror);
EXTERN int a_freeBLOB(a_blob b, int catcherror);
EXTERN int a_getBLOBelem(a_tuple t, int pos, a_blob b, int catcherror);
EXTERN int a_putBLOBelem(a_tuple t, int pos, a_blob b, int catcherror);
EXTERN int a_getBLOBarea(a_blob b, int pos, int len, char **area, 
                         int chatcherror);
EXTERN int a_getBLOBsize(a_blob b, int *size, int catcherror);
EXTERN int a_getBLOBbytes(a_blob b, int pos, int len, char *buffer, 
                          int catcherror);
EXTERN int a_putBLOBbytes(a_blob b, int pos, int len, char *buffer, 
                          int catcherror);

/*** Fast-path function calling ***/

EXTERN int a_callfunction(a_connection c, a_scan s,
                          oidtype fn, a_tuple args,int catcherror);
EXTERN int a_callfunction_custom(a_connection c, a_scan s, oidtype fn,
				 a_tuple args, char *options, int catcherror);
EXTERN int a_addfunction(a_connection c, oidtype fn,
                         a_tuple argl, a_tuple resl, int catcherror);
         // Not logged function loading:
EXTERN void a_loadfunction(oidtype fn, oidtype argl, oidtype resl); 
EXTERN int a_setfunction(a_connection c,oidtype fn,
                         a_tuple argl, a_tuple resl, int catcherror);
EXTERN int a_remfunction(a_connection c,oidtype fn,
                         a_tuple argl, a_tuple resl, int catcherror);

/*** Transaction control ***/

EXTERN int a_commit(a_connection c,int catcherror);
EXTERN int a_rollback(a_connection c,int catcherror);

/*** Sanity checks ***/

#define INITBLOB 9896
#define CONNECTED 9897
#define INITSCAN 9898
#define INITTUPLE 9899

#endif

