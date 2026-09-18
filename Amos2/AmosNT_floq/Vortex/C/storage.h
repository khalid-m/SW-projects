/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1997 - 2006 Tore Risch, EDSLAB, UDBL
 * $RCSfile: storage.h,v $
 * $Revision: 1.102 $ $Date: 2013/10/27 16:05:12 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Kernel storage and CLisp include file
 ****************************************************************************/

#ifndef _storage_h_
#define _storage_h_

#include <setjmp.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <signal.h>
#include <limits.h>

#include "environ.h"

#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif
#define NULLH 0

/*** System Constants. Cannot be changed by user! ***/

#define MINSMALLNUM -100                     /* Lowest pre-allocated integer */
#define MAXSMALLNUM 1000                    /* Highest pre-allocated integer */
#define MAXTYPES 100                          /* Max # of physical datatypes */
#define PERMANENTREF 254    /* Reference counter value for permanent objects */
#define DEALLOCREF 255    /* Reference counter value for deallocated objects */
#define MAXARGS 100          /* max # arguments in a C or Lisp function call */
#define OBJECTSIZE sizeof(struct listcell)          /* Size of simple object */
#define MAX_LENGTH 65535U                        /* Max size of 2 bytes area */
#define WORD_SIZE sizeof(int)

/*** Basic error numbers ***/

#define NO_ERRNO_ASSIGNED 0
#define UNDEFINED_VARIABLE 1
#define ILLEGAL_CLOSURE 2
#define ARG_NOT_LIST 3
#define ILLEGAL_ARGUMENT 4
#define ARG_NOT_SYMBOL_OR_STRING 5
#define UNTRAPPED_THROW 6
#define MAXARGS_EXHAUSTED 7
#define ILLEGAL_SETQ 8
#define CANNOT_OPEN_FILE 9
#define ARG_NOT_NUMBER 10
#define ARG_NOT_STRING 11
#define ARG_NOT_ARRAY 12
#define ARRAY_BOUNDS 13
#define ZERO_DIVIDE 14
#define UNDEFINED_FUNCTION 15
#define TOO_FEW_ARGUMENTS 16
#define TOO_MANY_ARGUMENTS 17
#define TOO_MANY_SPREAD_ARGUMENTS 18
#define ILLEGAL_POINTER 19
#define ILLEGAL_VARIABLE 20
#define ARG_NOT_SYMBOL 21
#define TRAPPED_DEALLOCATION 22
#define ARG_NOT_REAL 23
#define ILLEGAL_ERRMSG 24
#define EMPTY_SYMBOL 25
#define ARRAY_TOO_LARGE 26
#define ARG_NOT_TEXTSTREAM 27
#define TOO_MANY_ERRMSGS 28
#define UNDEF_EXTFN 29
#define ARG_NOT_STREAM 30
#define ARG_NOT_ADJARRAY 31
#define ILLEGAL_GET_READ 32
#define ILLEGAL_TOKEN_TYPE 33
#define ILLEGAL_DISPATCH_CHAR 34
#define NO_READFUNCTION 35
#define ARG_NOT_INTEGER 36
#define TOO_DEEP_MACRO 37
#define TOO_MANY_C_ARGS 38
#define STRING_TOO_LONG 39
#define STACK_OVERFLOW 40
#define CANNOT_ROLLIN 41
#define AMOS_NOT_INITIALIZED 42
#define CANNOT_CLOSE_STREAM 43
#define NOT_SUPPORTED 44
#define SYSTEM_ERROR 45

extern char *a_errormsgs[]; /* Array of error strings */

/*** Basic physical data type identifiers ***/

#define LISTTYPE 0
#define SYMBOLTYPE 1
#define INTEGERTYPE 2
#define REALTYPE 3
#define EXTFNTYPE 4
#define CLOSURETYPE 5
#define STRINGTYPE 6
#define ARRAYTYPE 7
#define STREAMTYPE 8
#define TEXTSTREAMTYPE 9
#define HASHTYPE 10
#define HASHBUCKETTYPE 11
#define HASHARRAYTYPE 12
#define SURROGATETYPE 13
#define BINARYTYPE 14
#define COMPLEXTYPE 15
#define INDEXTYPE 16

#define NUMERIC(xx) ((xx==INTEGERTYPE) | (xx==REALTYPE))

typedef size_t oidtype;                            /* Physical object handle */

/*** Physical object head ***/

typedef unsigned char objtype;                            /* Type identifier */
typedef unsigned char objrefcnt;                        /* Reference counter */
typedef struct objtags_rec{objtype ttag; objrefcnt rcnt;} objtags;

/*** Physical object templates ***/

#define HEADFILLER short int filler

struct listcell                      /* Also used as generic physical object */
{
  objtags tags;
  HEADFILLER;
  oidtype head;
  oidtype tail;
};

struct symbolcell                                           /* CLisp symbols */
{
  objtags tags;
  short int keywordp;                  /* keyword symbols beginning with ':' */
  oidtype value;                                             /* global value */
  oidtype propl;                                            /* property list */
  oidtype pname;                                               /* print name */
  oidtype fndef;                                      /* function definition */
  short int specialp;                  /* TRUE if dynamically bound variable */
  short int macroflg;              /* TRUE if function definition is a MACRO */
};

struct integercell
{
  objtags tags;
  HEADFILLER;
  int integer;
};

struct realcell
{
  objtags tags;
  HEADFILLER;
  char real[sizeof(double)];            /* 'double' alignment not guaranteed */
};

struct arraycell                                /* Fixed size small 1D array */
{
  objtags tags;
  unsigned short int size;
  oidtype cont[1];              /* Variable length object with array elements
                                   allocated starting here                   */
};

struct adjarraycell                            /* Growable or large 1D array */
{                                             /* Same type tag as arraycell! */
  objtags tags;
  unsigned short int small_size;                        /* Always MAX_LENGTH */
  int size;
  int top;                     /* position of last segment in segments array */
  oidtype init;                                             /* initial value */
  oidtype segments;                     /* pinter to array of array segments */
};
#define is_adjustable_array(x)(((struct arraycell *)x)->size == MAX_LENGTH)

struct streamheader
/* This struct must alway follow tags in any kind of stream cell */
{
  short int bytes;            /* Total size of object in bytes, incl. header */
  char autoflush;                      /* Flush after each item and new line */
  char systime;                                  /* Maintain current systime */
  char filler[2];                                            /* Unused flags */
  int line_num;                                       /* Current line number */
  oidtype logstream;                   /* Stream to copy input to if non-NIL */
  oidtype origin;                    /* ID of sender of data if known or nil */
  oidtype destination;             /* ID of receiver of data if known or nil */
};

EXTERN void init_streamheader(struct streamheader *sh);/* Initializing header*/
EXTERN void free_streamheader(struct streamheader *sh);  /* Finalizing header*/

struct streamcell                                         /* OS file streams */
{
  objtags tags;
  struct streamheader header;
  int opened;                                    /* TRUE while stream opened */
  FILE *fp;                                               /* OS file pointer */
};

struct textstreamcell                           /* stream over string buffer */
{
  objtags tags;
  struct streamheader header;
  int size;                                            /* The size of buffer */
  int pos;                              /* Current cursor position in buffer */
  int end;                                                   /* EOF position */
  oidtype buffer;                         /* Pointer to buffer as binarycell */
};
#define textstreambuffer(x)((char *)(dr(dr(x,textstreamcell)->buffer,binarycell)->cont))

struct stringcell                                      /* Fix length strings */
{
  objtags tags;
  unsigned short int shortlen;/* Length in bytes including terminating null
                                 character                                   */
  union {char string[sizeof(int)];
         int longlen;} cont;                    /* The string is padded here */
};

#define line_num_of(x) dr(x,streamcell)->header.line_num

struct pipecell {
  objtags tags;
  struct streamheader header;
  int opened;                                    /* TRUE while stream opened */
  FILE* fh[2];                                             /* OS file handle */
};

struct eventtag                                        /* Tag for log events */
{
  objtags tags;
  oidtype name;
  oidtype undofn;
  oidtype redofn;
  oidtype eventfns;
};
EXTERN int eventtagtype;               /* Type tag for storage type eventtag */

/*** Variable binding stack for CLisp and ObjectLog ***/

struct bindenv        /* A variable binding or a stack frame start indicator */
{
  oidtype var;                               /* Pointer to variable (symbol) */
  oidtype val;                       /* Pointer to value binding of variable */
  struct bindenv *env;     /* not NULL only in frame head. The dynamic link. */
  /* char *filler; */                           /* For cache line alignement */
};
typedef struct bindenv *bindtype;

EXTERN int a_stacksize;        /* Size of stack. Can be set before init_amos */
EXTERN struct bindenv *varstack;     /* Points to the current variable stack */
EXTERN int varstacksize;          /* The overflow point of the current stack */
EXTERN bindtype varstacktop;                            /* Current stack top */
EXTERN bindtype topframe(void);           /* The current binding environment */
EXTERN bindtype topenv;                              /* Internal. Do not use */
#define checkstackoverflow if(topenv >= varstacktop) \
                              reseterror("Stack overflow",form);
                                        /* Check if variable stack exhausted */

/*** Interrupt handling ***/
#define CheckInterrupt  if(InterruptHasOccurred) DoInterrupt()
                                       /* Check if an interrupt has occurred */
EXTERN int InterruptHasOccurred, InterruptEnabled;
EXTERN void DoInterrupt(void);                         /* Raise an interrupt */
EXTERN void (*a_interrupt_handler)(int);

/*** C function pointers ***/

typedef oidtype (*Lispfunction) ();
typedef void (*print_function) (oidtype,oidtype,int);        /* print object */
typedef void (*dealloc_function) (oidtype);                /* dealloc object */
typedef unsigned int(*hash_function)(oidtype);             /* hash on object */
typedef int (*equal_function)(oidtype,oidtype);                /* equal test */
typedef oidtype (*dispatch_function) (bindtype,oidtype);
                                            /* # character dispatch function */

typedef oidtype (*reader_function)(bindtype,oidtype tag,
                                   oidtype descr, oidtype stream);
                                                     /* type reader function */
EXTERN void type_reader_function(char *tpe, reader_function fn);

typedef oidtype(*error_handler)(bindtype,int ,char *,oidtype);
EXTERN error_handler a_error_handler;         /* Called after error detected */

typedef void(*expand_handler)(size_t,size_t);
EXTERN expand_handler expand_demon;/* Called when image high watermark grows */

typedef int (*event_handler)(bindtype,oidtype,oidtype,oidtype,oidtype,oidtype);
                        /* Hook for raising events before being added to log */
                                   /* FALSE result => event not added to log */
EXTERN event_handler raise_event;        /* Called before event added to log */

/*** Table for physical types ***/

struct typefnsslot                   /* Type functions, stored outside image */
{
   dealloc_function deallocfn;
                                          /* Called by GBC to deallocate obj */
   print_function printfn;                          /* Prints object on file */
   equal_function equalfn;                          /* returns TRUE or FALSE */
   equal_function comparefn;                          /* Returns -1, 0, or 1 */
   hash_function hashfn;                             /* Returns hash integer */
   int is_stream;                                     /* TRUE if stream type */
   char *name;                                          /* name of data type */
};

struct typedataslot                            /* Type data, stored in image */
{
   int alloccnt;                                       /* allocation counter */
   int dealloccnt;                                   /* deallocation counter */
   int total;                           /* total number of objects allocated */
};

EXTERN struct typefnsslot typefns[MAXTYPES];
                                       /* 'Methods' of physical object types */

EXTERN float image_expansion;
                       /* Factor to expand image with when full (dflt. 1.25) */
EXTERN int always_move_image;
                   /* TRUE => image always moves at expansions (dflt. FALSE) */
EXTERN char *begin_image;
                                          /* Start address of database image */

/*** Pointers to global system objects ***/

#define nil 2*OBJECTSIZE
                                                          /* Lisp symbol NIL */
EXTERN oidtype t, starsymbol, quotesymbol;        /* Symbols T, *, and QUOTE */

EXTERN oidtype __, ___; 
EXTERN struct stringcell *__str__;          /* Temporary variables in macros */

/*** Object dereferencing ***/

#define dr(xx,cell) ((struct cell *)&begin_image[xx])
                                                /* Dereference object handle */

#define doid(oid) dr(oid,listcell)
                                                       /* List dereferencing */
/*** Object tag referencing macros ***/

#define typetag(xx) ((xx)->tags.ttag)      /* type id of dereferenced object */
#define a_datatype(o) typetag(doid(o))    /* get type tag of object handle o */
EXTERN short int a_typenameid(char *name);    /* get type tag for type named */
#define ref(xx) ((xx)->tags.rcnt) /* reference counter of dereferenced object*/
#define refcntp(xx)(ref(xx)!=PERMANENTREF)
                            /* TRUE if garbage collected dereferenced object */
#define allocated(xx)(ref(xx)!=DEALLOCREF)
                     /* TRUE is dereferenced object has not been deallocated */
#define incref(xx) (refcntp(xx) && ref(xx)++)  /* Increase reference counter */
#define decref(xx) (refcntp(xx) && ref(xx)--)  /* Decrease reference counter */
#define released(xx) {register struct listcell *_dx = doid(xx);\
			  if(refcntp(_dx) && ref(_dx)-- == 1) release(xx);}
                                /* Decrease reference counter of object handle
                                   and reclaim if counter becomes 0          */

/*** Physical objects access macros ***/

#define symbolp(xx) (a_datatype(xx)==SYMBOLTYPE)
                                                     /* TRUE if XX is symbol */
#define listp(xx) (a_datatype(xx)==LISTTYPE)
                                                                   /* etc... */
#define integerp(xx) (a_datatype(xx)==INTEGERTYPE)
#define realp(xx) (a_datatype(xx)==REALTYPE)
#define stringp(xx) (a_datatype(xx) == STRINGTYPE)
#define arrayp(xx) (a_datatype(xx) == ARRAYTYPE)
#define extfnp(xx) (a_datatype(xx)==EXTFNTYPE)
#define coroutinep(xx) (a_datatype(xx)==coroutinetype)
#define extfnaddr(xx) (*(dr(xx,extfncell)->fnaddr))
#define extfnevalargs(xx) (dr(xx,extfncell)->evalargs)
#define fhd(xx) (doid(xx)->head)               /* fast (unsafe) head of list */
#define ftl(xx) (doid(xx)->tail)               /* fast (unsafe) tail of list */
#define hd(xx) ((___=xx,listp(___))? fhd(___):interror(ARG_NOT_LIST,___))
                                                /* Head of list */
#define kar(xx) (xx== nil ? nil : hd(xx))
                                      /* as hd, but handles car(nil)=nil too */
#define globval(atm) dr(atm,symbolcell)->value
                                              /* Global value of Lisp symbol */
#define tl(xx) ((___=xx,listp(___))? ftl(___):interror(ARG_NOT_LIST,___))
#define kdr(xx) (xx == nil ? nil : tl(xx))
                               /* CDR(X), i.e. as tl(x) but cdr(nil)=nil too */
#define propl(atm)(dr(atm,symbolcell)->propl)
                                         /* Get property list of Lisp symbol */
#define keywordp(x) (dr(x,symbolcell)->keywordp)
                         /* TRUE if Lisp symbol is keyword (starts with ':') */
#define specialp(x) (dr(x,symbolcell)->specialp)
                      /* TRUE if Lisp symbol is declared as special variable */
#define mksymbol(xx) new_symbol(xx)
                                            /* Make new SYMBOL from sring XX */
#define mkinteger(xx) new_integer(xx)
                                              /* Make new INTEGER from C int */
#define mkreal(xx) new_real(0,xx)
                                              /* Make new REAL from C double */
EXTERN double coerce_real(bindtype env,oidtype x);
                                          /* Get C double from number object */
#define getinteger(x) dr(x,integercell)->integer
                                       /* Get C int of INTEGER object handle */
EXTERN double a_round(double x);           /* Round float to nearest integer */
#define a_roundi(x) (int)a_round(x)        /* Round float to nearest integer */
#define mkstring(xx) new_string(strlen(xx)+1,xx)
                                   /* Make new STRING object from C char* xx */
#define mkstream(xx) new_stream(xx)
#define getstream(xx) dr(xx, streamcell)->fp
#define getpname(xx) getstring(dr(xx,symbolcell)->pname)
                                          /* Get print name of SYMBOL handle */
#define getstring(xx) ((__str__=dr(xx,stringcell))->shortlen == MAX_LENGTH ? \
       __str__->cont.string+sizeof(__str__->cont.longlen): __str__->cont.string)
                                      /* Get contents of STRING object handle*/

#define dgetstring(s) ((s)->shortlen == MAX_LENGTH ? \
		       (s)->cont.string+sizeof((s)->cont.longlen): (s)->cont.string)


#define stringlen(xx) ((__str__=dr(xx,stringcell))->shortlen == MAX_LENGTH ? \
       __str__->cont.longlen : __str__->shortlen)
                                       /* get length of STRING object handle */

#define dstringlen(s) ((s)->shortlen == MAX_LENGTH ?	\
		       (s)->cont.longlen : (s)->shortlen)
                                            /* length of dereferenced string */
/*** C storage interface macros */

#define dcloid(x) oidtype x=nil
                                                  /* declare object location */
#define a_let(var,val) {register oidtype ____=val; (var) = ____, incref(doid(var));}
                                               /* initialize object location */
#define a_setf(dest,val){register oidtype __= dest;\
        a_let(dest,val); released(__);}
                                                   /* assign object location */
#define a_return(val) {decref(doid(val)); return(val);}
                 /* Decrease reference counter of object location and return */
#define a_free(dest) {released(dest);dest=nil;}
                                                  /* Release object location */

/* add (PUSH) an element to the front of a list: */
#define push(val, lst) a_setf((lst), cons((val), (lst)))
#define push_string(val, lst) a_setf((lst), cons((mkstring((char*)val)), (lst)))
#define push_integer(val, lst) a_setf((lst), cons(mkinteger(val), (lst)))
#define push_real(val, lst) a_setf((lst), cons(mkreal(val), (lst)))

/*** Storage allocation and deallocation ***/

EXTERN oidtype new_object(int size, int type);
/* Allocate new word aligned storage object with size BYTES and 
   type tag TYPE */
struct objectcell                /* Template for word aligned storage object */
{
   objtags tags;                                              /* System tags */
   short int bytes;           /* Total size of object in bytes, incl. header */
   char cont[sizeof(int)];                            /* Content padded here */
};

EXTERN void dealloc_object(oidtype x);
                                   /* Deallocate word aligned storage object */

EXTERN oidtype new_aligned_object(int size, int type);
                         /* Allocate new double word aligned storage object. */
struct aligned_objectcell /* Template for double word aligned storage object */
{
   objtags tags;                                              /* System tags */
   short int filler;                                   /* Not used by system */
   int bytes;                 /* Total size of object in bytes, incl. header */
   char cont[sizeof(int)];      /* Content padded here. Double word aligned. */
};

EXTERN void dealloc_aligned_object(oidtype x);
                            /* Deallocate double word aligned storage object */

/*** Physical memory management ***/

EXTERN void expand_image(size_t size);              /* Expand database image */
EXTERN short int a_definetype(char *name,dealloc_function,print_function);
 /* Define new physical object type with name, destructor and print function */
EXTERN oidtype new_block(size_t, size_t);                        /* Internal */
EXTERN oidtype allocbytes(size_t);                               /* Internal */
EXTERN void freebytes(oidtype x, size_t size);     /* Free x with size bytes */
EXTERN void release(oidtype);                 /* Frees object if refcnt == 0 */
EXTERN int loc(oidtype);          /* Gets address of the dereferenced object */

/*** Basic data types ***/

EXTERN int equal(oidtype,oidtype);                             /* Lisp equal */
EXTERN int a_compare(oidtype,oidtype); /* less => -1, equal => 0, greater => 1.
                                               argument * indicates infinity */
#define COMPARE(x,y) ((x)<(y)?-1:((x)>(y)?1:0))
EXTERN oidtype new_symbol(char *str);                            /* Internal */
EXTERN oidtype new_integer(int val);                             /* Internal */
EXTERN oidtype new_string(size_t len,char *str);                 /* Internal */
EXTERN char *a_to_string(oidtype x);
                                 /* Print X into C new malloced string buffer*/
EXTERN oidtype stringbuffer(char *str);
                                  /* move str to global string buffer object */
EXTERN oidtype new_real(int dummy,double x);                     /* Internal */
EXTERN double getreal(oidtype);        /* Get contents of REAL object handle */
EXTERN oidtype new_oid(int idno);                                 /* New OID */
EXTERN oidtype cons(oidtype,oidtype);             /* Classical Lisp function */
EXTERN int a_length(oidtype);                              /* Length of list */
EXTERN oidtype a_nth(oidtype l, int i);   /* Nth element in list, start w. 0 */
EXTERN void a_toupper(char *str);         /* Upper case string destructively */
EXTERN void a_tolower(char *str);         /* Lower case string destructively */
EXTERN void a_capitalize(char *str);      /* Capitalize string destructively */
EXTERN oidtype a_list(oidtype,...);             /* Make list, given elements */
EXTERN oidtype nconc(oidtype,...);        /* Destructively concatenate lists */

/*** Arrays ***/

EXTERN oidtype new_array(int len,oidtype init);     
  /* New fixed size ARRAY */
EXTERN int a_arraysize(oidtype arr);                    /* Get size of ARRAY */
EXTERN oidtype copy_arrayfn(bindtype env, oidtype a);          /* Copy array */
EXTERN oidtype copy_array(bindtype env, oidtype a, int newsize,
                          int adjustable);    /* Copy to bigger/smaller array*/
EXTERN oidtype new_adjarray(int size,oidtype init);  /* New adjustable array */
EXTERN int adjust_array(oidtype a, int newsize);
   /* Increase size of array in-place. Returns TRUE if adjustment successful */
EXTERN oidtype listtoarrayfn(bindtype, oidtype);    /* Convert list to array */
EXTERN oidtype arraytolistfn(bindtype,oidtype);     /* Convert array to list */
EXTERN oidtype a_elt(oidtype,int);                   /* Access array element */
EXTERN oidtype a_seta(oidtype,int,oidtype);             /* Set array element */
EXTERN oidtype a_vector(oidtype,...);              /* Make array of elements */
EXTERN oidtype push_vectorfn(bindtype env, oidtype a, oidtype x);
     /* Add x to end of array by adjusting it. Returns adjusted or new array */

/*** byte arrays ***/
EXTERN oidtype new_binary(size_t size, int init); /* Allocate new byte array */

/*** Hash tables in image ***/

EXTERN unsigned int compute_hash_key(oidtype key);
                                           /* Compute hash key of any object */
typedef int (*maphash_function)(bindtype,oidtype,oidtype,oidtype,void *);
EXTERN oidtype new_hashtable(unsigned int equalflag);
   /* Allocate new hash table. equalflg=TRUE => test with EQUAL otherwise EQ */
EXTERN int put_hashtable(oidtype ht, oidtype key, oidtype val);
                    /* Insert key with associated value val in hash table ht */
EXTERN oidtype get_hashtable(oidtype ht, oidtype key);
                             /* Get associated value of key in hash table ht */
EXTERN oidtype rem_hashtable(oidtype ht, oidtype key);
                   /* Remove key and its associated value from hash table ht */
EXTERN void map_hashtable(bindtype env, oidtype indhdr, oidtype ht,
                   maphash_function f, void *x);
    /* Iterate over keys in hash table ht applying C function fn(key,val,xa) */
EXTERN void clear_hashtable(oidtype ht);
                                /* Remove all keys/values from hash table ht */

/*** Error handling ***/

#define OfType(x,tpe,env) if(a_datatype(x) != (tpe))\
			 return lerror(4,x,env);
                                                   /* Test if x has type tpe */
#define IntoString(x,into,env) if(stringp(x)) into = getstring(x);\
       else if(symbolp(x)) into = getpname(x); \
       else return lerror(ARG_NOT_STRING,x,env)
                                             /* Dereference string or symbol.
                                                Returns pointer into image   */

#define StackString(s,p)(p = alloca(strlen(s)+1), strcpy(p,s), p)
#define IntoStackString(x,into,env) \
       if(stringp(x)) StackString(getstring(x),into); \
       else if(symbolp(x)) StackString(getpname(x),into); \
       else return lerror(ARG_NOT_STRING,x,env)
                                             /* Copy string in image into
                                                string on stack   */
#define IntoString0(x,into,env) if (stringp(x)) \
		into = getstring(x);\
    else \
		return lerror(ARG_NOT_STRING,x,env)
                /* Dereference string, without converting symbols to strings.
                   Returns pointer into image                                */

#define IntoInteger(x,into,env) if(integerp(x)) into = getinteger(x);\
       else if(realp(x)) into = a_roundi(getreal(x));\
       else return lerror(ARG_NOT_INTEGER,x,env)
                                                   /* Dereference an integer */

#define IntoDouble(x,into,env) if(realp(x)) into = getreal(x);\
       else if(integerp(x)) into = getinteger(x)+0.0;\
       else return lerror(ARG_NOT_REAL,x,env)
                                                       /* Dereference a real */

EXTERN jmp_buf *resetlabelp;                         /* Current reset point */
EXTERN oidtype the_evaluated_form;                    /* Last evaluated form */
EXTERN int a_errorflag;                         /* TRUE after error occurred */
EXTERN int a_errno;                                   /* Latest error number */
EXTERN char *a_errstr;                               /* Latest error message */
EXTERN oidtype a_errform;                   /* Latest error message argument */
EXTERN oidtype lerror(int no, oidtype form, bindtype env);
                   /* Raise an error from in a specified binding environment */
EXTERN int a_error(int no,oidtype form,int catcherror);    /* Raise an error */
#define a_error_str(no, str, catcherror) a_error(no, mkstring(str), catcherror)
EXTERN int a_register_error(char *msg);      /* Register a new error message */
EXTERN int a_errornumber(char *msg);   /* Get the number of an error message */
EXTERN void fatalexit(int);                        /* Error that causes exit */
EXTERN void a_lock(void);                   /* Lock Amos II for other threads*/
EXTERN void a_unlock(void);                                /* Unlock Amos II */
EXTERN int a_locked;                         /* True when interpreter locked */
EXTERN void a_sleep(double t);                            /* Sleep t seconds */
EXTERN void free_oid(oidtype o);                       /* Thread safe a_free */
#define a_assign(lhs,rhs) a_intassign(&(lhs),rhs)      /* Thread safe a_setf */
EXTERN void a_intassign(oidtype *lhs,oidtype rhs);               /* Internal */
EXTERN oidtype resetfn(bindtype);                      /* Throw an exception */
EXTERN void clearstack(bindtype);                                /* Internal */

/*** Unwind protect ***/

#define unwind_protect_begin0(label) bindtype thisenv = topenv;\
   jmp_buf *oldresetlabelp=resetlabelp; int unwind_reset = FALSE; \
    jmp_buf newresetlabel; resetlabelp=&newresetlabel;\
	 if(setjmp(newresetlabel)) {clearstack(thisenv);\
         unwind_reset = TRUE; goto label;}
#define unwind_protect_catch0(label) label: resetlabelp = oldresetlabelp
                                                          /* Internal macros */

#define unwind_protect_begin unwind_protect_begin0(unwind_protect_catchpoint)
                                               /* Start unwind-protect block */
#define unwind_protect_catch unwind_protect_catch0(unwind_protect_catchpoint)
                                    /* Start the unconditional catch section */
#define unwind_protect_end if(unwind_reset) resetfn(thisenv);
                                                 /* End unwind-protect block */

/*** I/O ***/

#define a_streamp(o) typefns[a_datatype(o)].is_stream
                                                    /* TRUE is o is a stream */
EXTERN oidtype new_stream(FILE *fp);                 /* Open new file stream */
EXTERN oidtype a_fopen(char *filename, char *mode);      /* Open file stream */
EXTERN int a_fclose(oidtype stream);                         /* Close stream */
EXTERN oidtype stdoutstream,                       /* standard output stream */
               stdinstream;                         /* standard input stream */
EXTERN oidtype logstream;            /* Text stream for logging AmosQL input */

EXTERN oidtype eofsymbol;                /* Object returned when EOF reached */
EXTERN int a_getc(oidtype stream);                     /* read one character */
EXTERN int a_ungetc(int c, oidtype stream);          /* Unread one character */
EXTERN int a_puts(char *str,oidtype stream);                 /* Write string */
EXTERN size_t a_writebytes(oidtype stream, void *buff, size_t len);
                                                             /* Write buffer */
EXTERN int a_putc(int c, oidtype stream);               /* Write a character */
EXTERN size_t a_readbytes(oidtype stream, void *buff, size_t len);
                                                              /* Read buffer */
EXTERN int a_feof(oidtype stream);                   /* Test for end-of-file */
EXTERN int a_fflush(oidtype stream);                  /* Flush stream buffer */

EXTERN oidtype a_read(oidtype stream);                  /* Read S-expression */
EXTERN oidtype a_read_from_buffer(void *buffer, unsigned int len);
                                            /* Read S-expression from buffer */
EXTERN oidtype a_read_from_string(char *str);
                                          /* Read S-expression from C string */
EXTERN oidtype a_print(oidtype s);  /* Print S-expression CR on stdoutstream */
EXTERN oidtype a_printobj(oidtype s, oidtype stream);
                              /* Print S-expression followed by CR on stream */
EXTERN oidtype a_prin1(oidtype s, oidtype stream, int flag);
                                   /* Print S-expression. flag=TRUE => PRINC */
EXTERN void a_printstring(char *str,oidtype stream,int princflg); 
                                                  /* print C string as prin1 */
EXTERN char IntegerToStringBuff[30];
EXTERN oidtype a_terpri(oidtype stream);                         /* Print CR */
EXTERN oidtype load_amosqlfn(bindtype env, oidtype filep, oidtype loudflg);
                                         /* Load file with AMOSQL statements */

#define DELIMITERS " \t\n\r"
#define BREAKCHARS "()[]\"';`,"

oidtype a_encodeNumeric(char *str);

/*** Text streams ***/

EXTERN oidtype new_textstream(int len);
EXTERN oidtype a_textstreamread(oidtype stream, int from);
                                                        /* Read S-expression */
#define IntegerToString(x) (sprintf(IntegerToStringBuff,"%d",(int)x),\
                                    IntegerToStringBuff)

/*** Stream implementations ***/

struct stream_implementation
{
  int(*getc)(oidtype);
  int(*ungetc)(int,oidtype);
  int(*puts)(char*,oidtype);                      /* NULL => writebytes used */
  int(*putc)(int,oidtype); 
  int(*fclose)(oidtype);
  int(*feof)(oidtype);
  int(*fflush)(oidtype);
  size_t(*writebytes)(oidtype,void *,size_t);           /* NULL => putc used */
  size_t(*readbytes)(oidtype,void *,size_t);            /* NULL => getc used */
};

extern struct stream_implementation stream_implementations[MAXTYPES];
#define get_stream_implementation(ds) stream_implementations[typetag(ds)]

EXTERN int a_define_stream_implementation(int tag, /* Storage type */
                                      int(*getc)(oidtype),
				      int(*ungetc)(int,oidtype),
				      int(*feof)(oidtype),
				      int(*puts)(char*,oidtype),
				      int(*putc)(int,oidtype),
				      int(*fflush)(oidtype),
				      int(*fclose)(oidtype));

/*** Debugging ***/

EXTERN void a_printstat(void);        /* Prints storage used since last call */
EXTERN int refcnt(oidtype x);         /* Returns reference counter of object */
EXTERN void a_dumpbytes(oidtype,int);         /* Prints a piece of the image */
EXTERN void a_trap_dealloc(oidtype x, void(*trapper)(oidtype));
                                 /* Call trapper when x is to be deallocated */

/*** Configuration variables ***/
EXTERN char *a_default_image;              /* Name of default database image */

#endif
