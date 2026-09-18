/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1998 Tore Risch, EDSLAB
 * $RCSfile: intstorage.h,v $
 * $Revision: 1.22 $ $Date: 2013/03/03 12:54:21 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Internal kernel storage include file
 * ===========================================================================
 * $Log: intstorage.h,v $
 * Revision 1.22  2013/03/03 12:54:21  torer
 * Moved a_load_extension() to callin.h
 *
 * Revision 1.21  2013/03/01 12:59:56  torer
 * Asserting return codes from calls
 *
 * Revision 1.20  2013/02/28 04:55:19  torer
 * Added line feed
 *
 * Revision 1.19  2013/02/28 04:43:27  torer
 * Better a_assert()
 *
 * Revision 1.18  2013/02/23 16:16:23  torer
 * interface to a_load_extension()
 *
 * Revision 1.17  2013/02/13 18:34:30  torer
 * macro a_assert(x) for run-time C assertions
 *
 * Revision 1.16  2013/01/26 16:59:39  torer
 * Checking for integer overflow
 *
 * Revision 1.14  2011/05/04 18:44:19  torer
 * Use declaration size_t for byte array sizes
 *
 * Revision 1.13  2011/03/09 12:33:54  torer
 * Amos as DLL!
 *
 ****************************************************************************/

#ifndef intstorage_h
#define intstorage_h

#include "storage.h"
#include "hooks.h"

#define a_assert(x)(x?1:(printf("System assertion failure on line %d in %s:\
\n %s\n",__LINE__,__FILE__,#x),exit(1)))

#define a_check_rc(x){int __rc=(x); if(__rc) {\
  printf("Error in call on line %d in %s\n %s raises\n Error %d: %s\n",\
          __LINE__,__FILE__,#x,__rc,strerror(__rc)); exit(1);}}

#define inittype0(typeid,oid,doid,rectype,freel,size) \
{if(!freel) freel = new_block(a_blocksize,size); \
   (oid) = freel; (doid) = dr(oid,rectype); \
     freel = ((struct listcell *)(doid))->head; \
	 typetag(doid) = (unsigned char)typeid;  \
	      ref(doid)=0; incalloccnt(oid,typeid);}  
                                        /* Internal object allocation macro */

#define inittype1(typeid,oid,doid,rectype) \
  inittype0(typeid,oid,doid,rectype,imhd.freeobjects1,imhd.osize1)
                             /* Allocate single sized object */

#define inittype2(typeid,oid,doid,rectype) \
  inittype0(typeid,oid,doid,rectype,imhd.freeobjects2,imhd.osize2)
                             /* Allocate double sized object */

#define inittype3(typeid,oid,doid,rectype) \
  inittype0(typeid,oid,doid,rectype,imhd.freeobjects3,imhd.osize3)
                             /* Allocate 32 size object */

extern int trace_alloc;
extern size_t a_blocksize;
extern void a_markcell(oidtype,int);

#define incalloccnt(x,typeid) {imhd.typedata[typeid].alloccnt++; \
                               if(trace_alloc) a_markcell(x,TRUE);}

#define decalloccnt(x,typeid) {imhd.typedata[typeid].dealloccnt++; \
                               if(trace_alloc)a_markcell(x,FALSE);}

#define inittypen(typeid,oid,doid,bytes,rectype) {\
       oid = allocbytes(bytes); doid = dr(oid,rectype); \
       typetag(doid)=(unsigned char)typeid; \
       ref(doid)=0; incalloccnt(oid,typeid);}
                             /* Allocate variable sized word aligned object */

#define free1(x,dx) {ref(dx)=DEALLOCREF; ((struct listcell *)dx)->head=\
       imhd.freeobjects1; imhd.freeobjects1=x;}

extern void dealloc1(oidtype x); /* Wraps free1 */
                             /* Free single sized object */

#define free2(x,dx) {ref(dx)=DEALLOCREF; ((struct listcell *)dx)->head=\
       imhd.freeobjects2; imhd.freeobjects2=x;}
                             /* Free double sized object */

#define free3(x,dx) {ref(dx)=DEALLOCREF; ((struct listcell *)dx)->head=\
       imhd.freeobjects3; imhd.freeobjects3=x;}
                             /* Free size 32 objects */

#define free4(x,dx) {ref(dx)=DEALLOCREF; ((struct listcell *)dx)->head=\
       imhd.freeobjects4; imhd.freeobjects4=x;}
                             /* Free size 40 objects */

EXTERN oidtype stdinstream, stdoutstream, stderrstream;

#define instream(str)(((str==t) | (str==nil)) ? stdinstream : \
                (a_streamp(str)?str:lerror(ARG_NOT_STREAM,str,env)))

#define outstream(env,str)((str==t)|(str==nil) ? stdoutstream: \
                (a_streamp(str)?str:lerror(ARG_NOT_STREAM,str,env)))

extern oidtype full_filenamefn(bindtype,oidtype);

extern int whitespace(int);

/*** Authorization ***/

extern int the_cap(int);
extern char *the_level_msg[]; 
#define AUTH_GETD 4
#define AUTH_LISP 3
#define AUTH_RUN  1
#define checkauth(level) if(the_cap(-1) < level) \
        {a_error(NOT_SUPPORTED,mkstring(the_level_msg[level-1]),FALSE); \
         resetfn(topframe());}

/*** The image ***/

struct imageheader /* Data about current image */
{
  size_t high_watermark, image_size;
  int tag;
  char release[30]; /* Release identifier checked at rollin */
  int version; /* Version number checked at rollin */
  size_t osize1, osize2, osize3, osize4;
  /* size of free lists */
  oidtype  freeobjects1, freeobjects2, freeobjects3,
    freeobjects4;  /* free lists */
  struct {unsigned int len; oidtype free;} freeobjects[80];
  int maxblocksize;
  int level; /* Authorization level */
  struct typedataslot typedata[MAXTYPES]; /* type table */
};

EXTERN struct imageheader imhd;

/*** Misc. functions ***/

EXTERN void init_storage(void);          /* Initialize storage manager only */
EXTERN int rollin(char*);
EXTERN int rollout(char*);
#define EnableInterrupt  /* Not used */
#define DisableInterrupt /* Not used */
extern char *mymalloc(size_t size);
extern char *myrealloc(char *old, size_t size);
extern char *mystrdup(char *str);
EXTERN void a_message(char *msg);
int a_isnumeric(char *str);
int a_isalnum(int x);

/******* Macros to check for integer overflow *****************/

#define PLUS_OVERFLOW(i,j) ((i>0 && LONG_MAX-i < j)||(i<0 && LONG_MIN-i > j))
/* Will i+j cause integer overflow? */
 
#define TIMES_OVERFLOW(i,j) ((i>0 && j<0 && j < LONG_MIN/i) ||\
                             (i<0 && j>0 && i < LONG_MIN/j) ||\
                             (i>0 && j>0 && i > LONG_MAX/j) ||\
                             (i<0 && j<0 && -i > LONG_MAX/-j))
/* Will i*j cause integer overflow? */


#endif

