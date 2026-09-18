/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1997 Tore Risch, EDSLAB; 2000 Timour Katchaounov, UDBL
 * $RCSfile: init.c,v $
 * $Revision: 1.178 $ $Date: 2014/01/05 15:29:37 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Initialization with command line processing
 * ==========================================================================
 * $Log: init.c,v $
 * Revision 1.178  2014/01/05 15:29:37  torer
 * support for pure client initialization
 *
 * Revision 1.177  2014/01/05 12:57:23  torer
 * Client error check
 *
 * Revision 1.176  2014/01/05 12:33:31  torer
 * Added entry a_initclient()
 *
 * Revision 1.175  2014/01/04 10:53:11  torer
 * OS-independent localization of the startup directory
 *
 * Revision 1.174  2014/01/01 14:45:13  torer
 * New version
 *
 * Revision 1.173  2013/12/31 11:27:03  torer
 * No call to free() when communication initialized!
 *
 * Revision 1.172  2013/06/29 14:26:07  torer
 * New version number
 *
 * Revision 1.171  2013/05/17 14:27:54  torer
 * Added CSV report time stamps
 *
 * Revision 1.170  2013/05/16 20:02:13  torer
 * Propagation of enter systen times for events added
 *
 * Revision 1.169  2013/04/14 09:35:49  torer
 * Version 7
 *
 * Revision 1.168  2013/04/13 16:12:36  torer
 * New version number
 *
 * Revision 1.167  2013/03/27 16:18:36  torer
 * CSV reader now in C and following EXCEL's format
 * 2.63 times faster
 *
 * Revision 1.166  2013/03/13 18:18:38  torer
 * (STARTUP-DIR) is now function
 *
 * Revision 1.165  2013/03/13 17:59:46  torer
 * (RELOAD-EXTENSIONS) did not use the correct startup directory
 *
 * Revision 1.164  2013/03/04 22:13:44  torer
 * AMOS_HOME not needed under Windows and OSX
 *
 * Revision 1.163  2013/03/04 20:39:59  torer
 * Automatically finding startupDir under OSX
 *
 * Revision 1.162  2013/03/03 12:55:14  torer
 * New version
 *
 * Revision 1.161  2013/02/24 16:44:25  torer
 * New version
 *
 *
 * Revision 1.159  2013/02/15 07:37:51  torer
 * Release name identical to downloadable version
 *
 * Revision 1.158  2013/02/13 18:44:24  torer
 * System assertions + new Lisp function (TRAPDEALLOCA X)
 *
 * Revision 1.157  2013/02/06 07:40:59  torer
 * new function
 *   csvstring(Vector v, Charstring d)->Charstring
 *
 * Revision 1.156  2013/02/05 18:47:52  torer
 * COMPLEXTYPE now type tag macro for complex numbers
 *
 * Revision 1.155  2013/01/25 18:01:09  torer
 * Convert very long read integers to double
 *
 * Revision 1.154  2012/11/09 11:05:49  torer
 * New generation
 *
 * Revision 1.153  2012/06/29 11:03:14  torer
 * New version
 *
 * Revision 1.152  2012/06/19 16:19:42  larme597
 * Adding SCANREMOTE type.
 *
 * Revision 1.151  2012/06/01 05:43:22  torer
 * Delayed emit off by default
 *
 * Revision 1.150  2012/05/24 06:26:25  torer
 * _startup-dir_ initialization moved
 *
 * Revision 1.149  2012/05/23 19:02:32  torer
 * Start bare bone aLisp by
 *    alisp -i NONE
 *
 * Revision 1.148  2012/03/13 16:14:20  torer
 * New release 15:
 *
 * 1. Major change:
 *   The external interfaces in C and Java now always uses Lars' coroutine
 *   scans rather than the old materialized scans
 *
 * 2. Secondary scans removed
 *
 * Revision 1.147  2012/03/05 14:25:35  torer
 * AFTER_INIT hook initialized at wrong place
 *
 * Revision 1.146  2012/02/22 09:25:13  torer
 * No program database in released version
 *
 * Revision 1.143  2012/01/18 08:09:41  torer
 * Storage fragmentation fixed
 *
 * Revision 1.142  2012/01/05 14:26:28  torer
 * New hooks: AFTER_IMAGE_WRITTEN AFTER_IMAGE_READ
 *
 * Revision 1.140  2011/12/13 10:17:07  thatr500
 * register Mexima
 *
 * Revision 1.138  2011/11/19 16:37:47  torer
 * Debug print statement removed
 *
 * Revision 1.137  2011/11/17 21:44:33  torer
 * A more modular C interface to parsers fro different languages
 *
 * Revision 1.136  2011/11/17 11:23:43  torer
 * SQL parser integrated
 * Try:  amos2 -q SQL
 *
 * Revision 1.135  2011/11/16 14:43:31  torer
 * Option to change initial query language by
 *   amos2 -q <language>
 *
 * Revision 1.134  2011/10/25 11:52:50  larme597
 * Adding extra string functions to system.
 *
 * Revision 1.133  2011/10/05 09:28:34  thatr500
 * added comments
 *
 * Revision 1.132  2011/06/23 09:00:18  thatr500
 * brought back (internal) XTREE index type
 *
 * Revision 1.131  2011/05/06 15:03:44  thatr500
 * remove XTREE from kernel. Now it comes as a dynamic loaded library
 *
 * Revision 1.130  2011/04/28 19:44:00  torer
 * Dynamic extender modules (DLLs and SOs)
 *
 * Revision 1.129  2011/04/28 11:39:25  torer
 * Consistent treatment of file names
 *
 * Revision 1.128  2011/04/13 20:11:47  andan342
 * Added more RDF-related storage types and readers
 *
 * Revision 1.126  2011/04/01 09:12:35  chexu484
 * non blocking print/read
 *
 * Revision 1.125  2011/03/31 06:44:28  torer
 * Release 14, v1
 *
 * Revision 1.124  2011/03/24 13:12:22  torer
 * LINUX -> UNIX
 *
 * Revision 1.123  2011/02/27 10:50:45  torer
 * Release 13, version 4
 *
 * Revision 1.121  2011/02/09 14:03:24  torer
 * New storage type URI
 *
 * Revision 1.120  2011/01/27 05:42:36  torer
 * Amos II Release 13 is born
 *
 * Revision 1.119  2011/01/26 20:43:41  torer
 * Bumping up the stack size
 *
 * Revision 1.118  2011/01/21 14:31:48  torer
 * New storage type SCAN
 *
 * Revision 1.116  2011/01/12 16:32:16  minzh812
 * New storage type EXPRESSION
 *
 * Revision 1.115  2010/12/30 13:02:43  zeitler
 * Linux CPU measurement
 *
 * Revision 1.114  2010/12/30 12:50:42  zeitler
 * Register windows proctime
 *
 * Revision 1.113  2010/12/29 20:34:41  torer
 * Removed Java related code
 *
 * Revision 1.112  2010/12/14 19:08:58  thatr500
 * adding flag _exinma-enabled_ to turn ON/OFF Exinma
 *
 * Revision 1.111  2010/12/14 17:17:24  torer
 * Checking illegal command line option
 *
 * Revision 1.110  2010/12/14 14:23:25  torer
 * Removed xtree initialization
 *
 * Revision 1.108  2010/12/01 19:23:07  thatr500
 * add External storage manager
 *
 * Revision 1.107  2010/11/02 08:26:05  thatr500
 * Make Xtree available on Unix
 *
 * Revision 1.105  2010/08/25 05:40:19  torer
 * Removed xtree from Linux version
 *
 * Revision 1.104  2010/08/23 14:27:41  thtr1663
 * add xtree package
 *
 * Revision 1.103  2010/08/23 12:40:28  torer
 * Xtree package not correctly checked in!
 *
 * Revision 1.102  2010/08/22 16:43:11  thtr1663
 * intialize xtree index
 *
 * Revision 1.100  2009/12/14 22:06:52  torer
 * Equality as foreign predicate in C
 *
 * Revision 1.98  2009/11/03 19:57:16  torer
 * Inferring types of materialized bags
 *
 * Revision 1.97  2009/10/22 19:02:39  zeitler
 * register_pca back in init.c
 *
 * Revision 1.96  2009/10/22 18:30:59  torer
 * a_capitalize(str) (C) and (STRING-CAPITALIZE STR)
 *
 * Revision 1.91  2009/09/02 07:48:37  torer
 * Moved a_printstring here
 *
 * Revision 1.90  2009/08/21 12:22:46  larme597
 * Adding buffer functions again
 *
 * Revision 1.88  2009/08/19 14:22:06  larme597
 * Adding buffer to compilation.
 *
 * Revision 1.87  2009/07/31 09:54:51  torer
 * Dynamic lexical ALisp closures supported
 *
 * Revision 1.85  2009/06/30 13:04:05  larme597
 * Modified to include coroutines.
 *
 * Revision 1.84  2009/05/02 17:17:37  torer
 * Customizable default image
 *
 * Revision 1.83  2009/05/02 13:54:48  torer
 * Documentation string in DEFGLOBAL
 *
 * Revision 1.82  2009/04/22 17:35:47  torer
 * ALisp now stand-alone sub-module
 *
 * Revision 1.81  2009/03/05 20:36:18  torer
 * Starting release 12
 *
 * Revision 1.79  2008/12/30 15:24:33  torer
 * New function to encode numeric S-expressions: a_encodeNumeric
 *
 * Revision 1.77  2008/11/28 14:23:48  torer
 * Changing \ to /
 *
 * Revision 1.76  2008/11/26 20:50:00  torer
 * Load init file unlocked
 *
 * Revision 1.75  2008/11/05 16:16:22  torer
 * select after 'as' optional
 *
 * Revision 1.73  2008/09/27 16:43:21  torer
 * 'Java-safe' (and thread-safe) coroutines
 *
 * Revision 1.72  2008/09/27 15:13:19  torer
 * coroutines did not work together with Java
 *
 * Revision 1.71  2008/09/23 21:05:06  torer
 * Added coroutines to ALisp. See regress/coroutines.lsp.
 *
 * Revision 1.69  2008/05/06 20:51:04  torer
 * Someone checked in with Unix EOL
 *
 * Revision 1.67  2008/01/25 19:06:30  torer
 * Correct executable path when starting from DLL
 *
 * Revision 1.66  2008/01/25 18:45:14  torer
 * Determining executable file name under Visual C++
 *
 * Revision 1.65  2007/12/18 07:37:00  torer
 * Constructor forms on transient objects
 *
 * Revision 1.62  2007/11/07 15:14:50  torer
 * Amos II version 10 with faster basic OjectLog interface to C
 * Aggregation operators can now be defined in C
 *
 * Revision 1.61  2007/10/30 12:08:03  torer
 * MAX_PATH not defined in Unix
 *
 * Revision 1.60  2007/10/24 21:39:23  torer
 * Error in splitting init file name
 *
 * Revision 1.59  2007/10/24 20:56:24  torer
 * -i option now takes Lisp file loading system
 *
 * Revision 1.56  2007/10/19 13:50:45  torer
 * Global system variables:
 *    _image-file_  The name of the database image
 *    _startup-dir_ The directory where selected DLL or .exe resides
 *
 * Revision 1.55  2007/10/19 10:54:41  torer
 * Bug in construction of startupDir
 *
 * Revision 1.54  2007/05/25 17:52:44  torer
 * Problem with changed include file and messed up project
 *
 * Revision 1.50  2006/10/20 17:39:29  torer
 * REDIRECT-BASIC-STDOUT opens with 'a' option for cumulative logging
 *
 * Revision 1.49  2006/10/08 20:40:13  torer
 * amos -s xxx does reregister instead of register
 * amos -p xxx does register
 * Allows robust server service
 *
 * Revision 1.46  2006/07/27 14:32:40  torer
 * top.c to repository
 *
 * Revision 1.45  2006/04/26 09:33:33  torer
 * Added new source file for definining storage types
 *
 * Revision 1.43  2006/02/07 07:33:13  torer
 * Removed annoying warnings
 *
 * Revision 1.42  2006/02/06 16:56:24  zeitler
 * File functions incorporation into Amos.
 *
 * Revision 1.41  2006/02/04 11:32:43  torer
 * Separated binary data management extensions into new file
 *    system/C/binary.c
 *
 ***************************************************************************/

#include "amos.h"
double run_time(void);
#include "commands.h"
#include "getopt.h"
#include <ctype.h>
#ifdef NT
#include <direct.h>
#else
#include <unistd.h>
#endif
#include <assert.h>
#define TOUPPER(c)      toupper((unsigned char)c)
#define TOLOWER(c)      tolower((unsigned char) c)

#define DEFAULT_INIT_LISP_FILE "../lsp/init.lsp"
#define OPTIONS                "b:i:n:c:s:p:l:o:L:O:r:q:?:h"

/* file types recognized by AMOS */
#define FTYPE_UNKN -1
#define FTYPE_INIT  0
#define FTYPE_DUMP  1
#define FTYPE_OSQL  2
#define FTYPE_LISP  3

void print_usage(void);

EXPORT char *a_default_image =  "amos2.dmp";
EXPORT int image_loaded = FALSE; /* did we load the image? */
int amos_initialized = FALSE;
EXPORT int a_clientflg=FALSE;
oidtype _start_time_;
EXPORT char *a_startupdir=NULL;	/* Set to Amos II executable directory  */

oidtype init_file = NULLH; 
/* The AMOSQL file to load after system is initialized */

oidtype high_watermarkfn(bindtype env)
{
  return mkinteger(imhd.high_watermark);
}

char *justnow(void)
{
  time_t t;
  char *ct;

  time(&t);
  ct = ctime(&t);
  ct[strlen(ct)-1] = '\0';
  return ct;
}

oidtype redirect_basic_stdoutfn(bindtype env, oidtype file)
{
  char *filename;

  IntoString(file,filename,env);

  if (freopen(filename, "a", stdout) == NULL ||
      freopen(filename, "a", stderr) == NULL)
    {
      a_message("Error redirecting standard output\n");
      return nil;
    }
  return file;
}
/* Test if Amos initialized */

EXPORT int AmosInitialized(){return amos_initialized;};

EXPORT void a_toupper(char *str)
{
  int c;
  while (*str) {
    c = *str;
    str[0] = (char)TOUPPER(c);
    ++str;
  }
}

EXPORT void a_tolower(char *str)
{
  int c;
  while (*str) {
    c = *str;
    str[0] = (char)TOLOWER(c);
    ++str;
  }
}

EXPORT void a_capitalize(char *str)
{
  int c, first=TRUE;
  while (*str) 
    {
      c = *str;
      if(first)
	{
	  first = FALSE;
	  str[0] = (char)TOUPPER(c);
	}
      else str[0] = (char)TOLOWER(c);
      ++str;
    }
}

int a_isnumeric(char *str)
     /* returns 1 if str is integer, 2 if it is real and 0 otherwise */
{
  int p=0; char c0=str[0];

  if(c0=='\0')return FALSE; /* empty string */
  if(c0=='+' || c0=='-') p++; /* skip sign */
  if(!isdigit(str[p])) return 0; /* first char after sign must be digit */
  while (isdigit(str[p])) p++; /* scan sequence of digits */
  if(str[p]=='\0') return 1; /* integer */
  if(str[p]=='.') /* Float with decimal */
    {
      p++;   /* skip decimal . */
      while (isdigit(str[p])) p++; /* skip sequence of digits */
      if(str[p]=='\0') return 2; /* float without exponent */
    }
  if(str[p]!='e' && str[p]!='E') return 0; 
  /* exponent 'e' must follow in float */
  p++;              /* skip exponent 'e' */
  if(str[p]=='+' || str[p]=='-') p++;  /* skip exponent sign */
  while (isdigit(str[p])) p++;     /* scan exponent digits */
  if(str[p]=='\0') return 2; /* Nothing after exponent */
  return 0;  /* junk after exponent => no float */
}

int a_isalnum(int x)
{
  return isalnum(x);
}

oidtype a_encodeNumeric(char *str)
{
  long i;
  switch(a_isnumeric(str)) 
    {
    case 0: break;
    case 1: 
      i = strtol(str,NULL,10);
      if(i==LONG_MAX || i==LONG_MIN) return mkreal(atof(str));
      return mkinteger(i);
    case 2: return mkreal(atof(str));
    }
  return NULLH;
}

extern string_puts(char *,oidtype,int);
void a_printstring(char *str, oidtype stream, int princflg)
     /* Print string str with escapes \ inserted */
{
  string_puts(str, stream, FALSE);
}

char *a_toUnixFileName(char *file)
     /******************************************
      * Convert Windows filename to Unix style *
      *****************************************/
{
  char *f;

  for(f=file;*f;f++) (*f=='\\' ? *f='/' : 0);
  for(f=file;*f;f++) ((*f=='/') & (*(f+1)=='/') ? strcpy(f,f+1) : 0);
  return file;
}

oidtype unixfilenamefn(bindtype env, oidtype file)
{
  char *filename; 
  oidtype res;

  IntoString(file, filename, env);
  res = mkstring(filename);
  a_toUnixFileName(getstring(res)); /* Destructive */
  return res;
}

oidtype a_fopen(char *filename, char *mode)
{
  return call_lisp(mksymbol("openstream"), topframe(), 2, mkstring(filename),
		   mkstring(mode));
}

oidtype startup_dirfn(bindtype env)
{
  return mkstring(a_startupdir);
}

/************************ Initialize AMOS subsystems *************************/

int init_subsystems(int catcherror) 
{
  extern char *getstartupdirectory(void);
  extern void register_eval(void);
  extern void register_nbprint(void);
  extern void register_lock(void);
  extern void register_coroutine(void);
  extern void register_buffer(void);
  extern void register_strings(void);
  extern void register_system_functions(void);
  extern void register_library_functions(void);
  extern void register_oid_functions(void);
  extern void register_misc_functions(void);
  extern void register_index_functions(void);
  extern void register_rel_functions(void);
  extern void register_hist_functions(void);
  extern void register_olog_functions(void);
  extern void register_typecheck_functions(void);
  extern void register_fncall_functions(void);
#ifndef NOCOMM
  extern void register_comm_functions(void);
#endif
  extern void register_files_functions(void);
  extern void register_cinterface(void);
  extern void register_time_functions(void);
  extern void register_btree(void);
  extern void register_top(void);
  extern void register_text_functions(void);
  extern void register_csv(void);
  /* Operating System dependent functions */
  extern void register_os_functions(void);
#ifdef NT
  extern void register_wproctime(void);
#else
  extern void register_lproctime(void);
#endif
  extern void register_event_manager(void);
  extern void register_math_functions(void);
  extern void register_complex_functions(void);
  extern void register_lispfns(void);
  extern void register_storagetypes(void);
  extern void register_binary(void);
  extern void register_filefns(void);
  extern void register_aggops(void);
  extern void register_amosfns(void);
  extern void register_winagg(void);
  extern void register_pca(void);
  extern void register_old_rdf(void);
  //extern void register_xtree(void);
  extern void register_mexima(void);
  extern void register_expression(void);
  extern void register_scan(void);
  extern void register_scanremote(void);
  extern void register_rdf(void);
  extern void register_extender(void);
  /* Compute the startup directory */
  a_startupdir = getstartupdirectory();
  if(strlen(a_startupdir) == 0)
    {
      fprintf(stderr, "Cound not compute the startup directory\n");
      exit(1);
    }
  if(amos_initialized)
    {
      int err = a_register_error("System already initialized");

      return a_error(err,nil,catcherror);
    }
  else amos_initialized = TRUE;

  /************************************************************************** 
   Define system version tag to match image and init.lsp 
   Should be updated when new symbol created during initialization!
   *************************************************************************/ 
  {
    extern char *a_release;
    extern int a_version;

    a_release = "Release 16";
    a_version = 11;
  }
  /************************* Initialize kernel ******************************/
  init_storage();
  a_stacksize = 5000; /* The aLisp/ObjectLog stack size */
  register_eval();
  register_lock();
  register_strings();
  register_system_functions();
  register_library_functions();
  register_oid_functions();
  register_misc_functions();
  register_math_functions();
  register_complex_functions();
  register_index_functions();
  register_lispfns();
  register_rel_functions();
  register_hist_functions();
  register_olog_functions();
  register_typecheck_functions();
  register_fncall_functions();
#ifndef NOCOMM
  register_comm_functions();
#endif
  register_files_functions();
  register_cinterface();
  register_time_functions();
  register_btree();
  register_top();
  register_text_functions();
  register_csv();
  register_os_functions();
#ifdef NT
  register_wproctime();
#else
  register_lproctime();
#endif
  register_event_manager();
  register_storagetypes();
  register_binary();
  register_filefns();
  register_coroutine();
  register_buffer();
  register_rdf();
  register_extender();
  register_nbprint();

  extfunction1("redirect-basic-stdout",redirect_basic_stdoutfn);
  extfunction0("high-watermark", high_watermarkfn);
  extfunction1("unixfilename", unixfilenamefn);
  extfunction0("startup-dir", startup_dirfn);

  a_let(_start_time_,mksymbol("_start-time_"));

  /****** Initialize foreign AmosQL functions ************/
  register_aggops();
  register_amosfns();
  register_winagg();
  register_pca();
  register_old_rdf();

  /* Hook command execution to be called after AMOS INIT  */
  a_register_hook(exec_commands, AFTER_INIT);

  /****** Initialize Meta External Storage Manager ************/
  // This flag is set in AmosNT\lsp\init.lsp
  if (globval(mksymbol("_mexima-enabled_"))) {
    register_mexima();
  }
  register_expression();
  register_scan();
  register_scanremote();
  assert(indextype==INDEXTYPE);
  delay_emit = FALSE; /* Delayed emits turned off by default */
  return 0; /* success */
}
#ifndef NT
#define MAX_PATH 500
#endif

/* Boot system image from LISP*/
int init_from_lisp(char* lisp_init_file, char* startup_dir, int catcherror)
{
  char lisp_dir[MAX_PATH];
  char init_buff[MAX_PATH];
  char *end, *init_file=init_buff;
  double cl;
  double diff;
  char buffer[100];

  if(lisp_init_file == NULL) lisp_init_file=DEFAULT_INIT_LISP_FILE;
  strcpy(init_buff, lisp_init_file);
  a_toUnixFileName(init_buff);
  end = strrchr(init_buff, '/');
  if(end==NULL) strcpy(lisp_dir,".");
  else
    {
      memcpy(lisp_dir,init_buff,end-init_buff);
      lisp_dir[end-init_buff]='\0';
      init_file = end+1;
    }
  printf("init file: %s init dir %s\n", init_file, lisp_dir);
  a_let(globval(_start_time_), mkstring(justnow()));
  cl = run_time();

  a_execute_hooks(AFTER_ROLLIN,""); /* System functions defined here */

  eval_forms(varstack,"(defmacro with-directory(dir &rest forms)\
(list(list 'lambda(list 'pushed)(list 'unwind-protect(list* 'progn(list\
'pushd dir)(list 'setq 'pushed t)forms)(list 'if 'pushed(list 'popd))))\
nil))(defmacro defglobal (var &rest val) (if (and val (or (special-variable-p \
var)(getprop var 'global)))(print (list var 'reset)))(putprop var 'global t) \
(if (cdr val)(putprop var 'documentation (cadr val)))\
(if val (list 'setq var (car val))))(movd 'natom 'consp)");

  /* System functions in Lisp */

  a_setf(globval(mksymbol("_lisp-dir_")), mkstring(lisp_dir));
  a_setf(globval(mksymbol("_lisp-init-file_")), mkstring(init_file));

  a_setf(globval(mksymbol("_lisp-mode_")),t);

  if(strcmp(init_file,"NONE")!=0)
    eval_forms(varstack,"(with-directory _lisp-dir_ (load _lisp-init-file_))");

  diff = run_time() - cl;
  sprintf(buffer,"%g s\n",diff);
  a_message(buffer);

  image_loaded = TRUE;
  return 0;
}

/* Read specified system image file */
int init_from_image(char *image, char *startup_dir, int catcherror)
{
  FILE* f_image;
  int rc, allocflg = FALSE;
  char *full_image;
  oidtype img;

  a_clientflg = (image == NULL || strlen(image) == 0);

  /* do nothing if already an image was loaded  */
  if (image_loaded)
    {
      return 0;
    }

  if(a_clientflg) image = "amos2.dmp";

  /* test if the image file exists in the current directory */
  f_image = fopen(image, "r");
  if (f_image != NULL)
    {
      fclose(f_image);
      full_image = image;
    }
  else
    {
      /* Look for the image in the same dir where system is started */

      full_image = mymalloc(strlen(startup_dir)+strlen(image)+2);
      sprintf(full_image, "%s/%s", startup_dir, image);
      allocflg = TRUE;
    }
  rc = rollin(full_image);
  img = mkstring(full_image);
  if(rc != 0)
    {
      if(allocflg) free(full_image);
      return a_error(CANNOT_ROLLIN, img, catcherror);
    }
  if(allocflg) free(full_image);
  if(globval(_start_time_) == nil)
    {
      a_let(globval(_start_time_), mkstring(justnow()));
    }

  a_setf(globval(mksymbol("_IMAGE-FILE_")), 
         call_lisp(mksymbol("fullpath"),varstack, 1, img));
  
  image_loaded = TRUE; 
  run_time();
  return 0;
}

/*****************************************************************************
 * Determine the type of file supplied on the command line.
 *****************************************************************************/
int file_type(char* file_name) 
{
  char* ext;
  int ftype = FTYPE_UNKN;

  if (file_name != NULL) 
    {
      ext = strrchr(file_name, '.');
      if (ext != NULL)
	{
	  ++ext;
	  if (strcmp(ext, "dmp") == 0) ftype = FTYPE_DUMP;
	  else if (strcmp(ext, "osql") == 0 ||
		   strcmp(ext, "amosql") == 0) ftype = FTYPE_OSQL;
	  else if (strcmp(ext, "lsp") == 0) ftype = FTYPE_LISP;
	}
    }
  return ftype;
}

/*****************************************************************************
 * Retrieve the name of the client and the host for the nameserver from
 * 'pszParam'  and then compose the argument for the register() AmosQL
 * function in the provided character buffer 'buf'.
 *****************************************************************************/
void get_srv_and_namesrv(char* buf, char* pszParam) {
  char *pszNamesrv;
  strtok(pszParam, "@"); /* skip the name of the client  */
  if(pszParam[0]=='@') /* No name, only host */
    {
      pszNamesrv = pszParam+1;
      pszParam = "";
    }
  else pszNamesrv = strtok(NULL, "@"); /* get the token after the '@'   */
  if (pszNamesrv) {
    sprintf(buf, "'%s', '%s'", pszParam, pszNamesrv);
  } else {
    sprintf(buf, "'%s'", pszParam);
  }
}

/*****************************************************************************
 * Process command line options by using the getopt module.
 * - Some options are executed immediately
 * - Other options are stored for later execution in the pCommands array as
 *   OSQL or LISP statements.
 *
 * NOTE: This is the function where the image is initialized!
 *****************************************************************************/
void process_options(int argc, char** argv, int catcherror,
		     command_array* pCommands)
{
  int     option;      /* gotten option character */
  char*   pszParam="";   /* gotten parameter */
  char buffer[100];

  /* No parameters => load deafault image */
  if (argc < 2)
    {
      init_from_image(a_default_image, a_startupdir, catcherror);
      return;
    }

  /* we have some options to process */
  while (TRUE)
    {
      option = GetOption(argc, argv, OPTIONS, &pszParam);

      /* option is valid argument */
      if (option > 0)
        {
          switch (option) 
            {
            case 1:
	      {    /* this option will be treated as a filename */
                int ftype;

                a_toUnixFileName(pszParam);
                ftype = file_type(pszParam);

                switch (ftype)
		  {
		  case FTYPE_DUMP:
                    init_from_image(pszParam, a_startupdir, catcherror);
                    break;
		  case FTYPE_INIT:
                    init_from_lisp(pszParam, a_startupdir, catcherror);
                    break;
		  case FTYPE_OSQL:
                    add_command(pCommands, 'o', "< '%s';", pszParam);
                    break;
		  case FTYPE_LISP: 
                    add_command(pCommands, 'l', "(load \"%s\")", pszParam);
                    break;
		  case FTYPE_UNKN:
                    /* just skip unknown file types */
                    sprintf(buffer,"Unknown type of file: %s\n", pszParam);
                    a_message(buffer);
                    break;
		  }

                break;
	      }
            case 'b':   /* load database image */
	      if (pszParam == NULL)
                { /* use default */
		  init_from_image(a_default_image, a_startupdir, catcherror);
                }
	      else
                {
		  init_from_image(pszParam, a_startupdir, catcherror);
                }
	      break;
            case 'i':   /* initialize from Lisp sources */
	      init_from_lisp(pszParam, a_startupdir, catcherror);
	      break;
            case 'n':   /* Start nameserver */
	      if (pszParam == NULL) pszParam = "";
	      add_command(pCommands, 'o', "nameserver('%s'); listen();",
			  pszParam);
	      break;
            case 'c':   /* Start client */
	      if (pszParam != NULL) {
		char* register_args = malloc(strlen(pszParam) + 7);
		get_srv_and_namesrv(register_args, pszParam);
		add_command(pCommands, 'o', "register(%s);",
			    register_args);
		free(register_args);
	      }
	      break;
            case 's':   /* Start server named */
            case 'p':   /* Start new peer */
	      if (pszParam != NULL) {
		char* register_args = malloc(strlen(pszParam) + 7);
		get_srv_and_namesrv(register_args, pszParam);
                if(option=='s')
		  add_command(pCommands, 'o', "reregister(%s); listen();",
			      register_args);
                else add_command(pCommands, 'o', "register(%s); listen();",
			         register_args);
		free(register_args);
	      }
	      break;
            case 'l':   /* execute lisp code */
	      if (pszParam != NULL) { 
		add_command(pCommands, 'l', "%s", pszParam);
	      }
	      break;
            case 'o':   /* exec osql statement */
	      if (pszParam != NULL) {
		add_command(pCommands, 'o', "%s", pszParam);
	      }
	      break;
            case 'L':   /* load lisp file */
	      if (pszParam != NULL) {
		a_toUnixFileName(pszParam);
                add_command(pCommands, 'l', "(load \"%s\")", pszParam);
	      }
	      break;
            case 'O':   /* load osql file */
	      if (pszParam != NULL) {
                a_toUnixFileName(pszParam);
		add_command(pCommands, 'l', "(load-amosql \"%s\")", pszParam);
	      }
	      break;
            case 'r': {  /* redirect standard output and error streams */
	      char outfile[PATH_MAX];
	      if (pszParam == NULL) {
		pszParam = "amos"; /* default name for output file  */
	      }
	      sprintf(outfile, "%s", pszParam);
	      if (freopen(outfile, "a", stdout) == NULL) {
		fprintf(stderr, "Error redirecting standard output\n");
	      }
	      break;
            }
            case 'q': /* query language */
	      if (pszParam != NULL) 
                a_query_language = a_language_parser_id(pszParam);
              break;
            case 'h':   /* help text */
            case '?':
	      print_usage();
	      break;
            }
        }
      /* end of argument list */
      if (option == 0)
        {
	  /* end of commands */
	  if (image_loaded == FALSE)
            {
	      init_from_image(a_default_image, a_startupdir, catcherror);
            }
	  break;
        }
      /* standalone param or error */
      if (option == -1)
        {
          fprintf(stderr, "Illegal option: %s\n",pszParam);
	  exit(1);
	  break;
        }
    }
}

/* To initialize Amos II from the command line */
EXPORT void init_amos(int argc, char **argv)
{
  char buffer[100];

  init_subsystems(FALSE);

  /* no more than (argc - 1) commands will be processed, */
  g_commands = new_command_array(argc - 1);
  /* process command line options  */
  process_options(argc, argv, FALSE, g_commands);


  sprintf(buffer,"%s, v%d\n", imhd.release, imhd.version);
  a_message(buffer);
 }

EXPORT int a_initialize(char *image, int catcherror)
     /* Initialize embedded Amos II with specified image */
{
  int err;

  err = init_subsystems(catcherror);
  if (err != 0) return err;
  err = init_from_image(image, a_startupdir, catcherror);
  return err;
}

EXPORT int a_initclient(int catcherror)
{
  return a_initialize(NULL, catcherror);
}

void print_usage(void) {
  a_message("Usage:\n");
  a_message("-------------------------------------------------------\n");
  a_message("amos2 [image_file osql_file | [-b image_file | -i [lsp_file]]\n");
  a_message("      [-n [nsrv_name] | -c [cli_name][@nsrv_host] | -p peer_name[@nsrv_host]]\n");
  a_message("      [-l lisp] [-o osql] [-L lisp_file] [-O osql_file] \n");
  a_message("      [-q query_language] [-r out_file] [-h | -?]\n");
  a_message("-------------------------------------------------------\n");

  exit(0);
}
