/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2006 Erik Zeitler, UDBL
 * $RCSfile: filefns.c,v $
 * $Revision: 1.8 $ $Date: 2013/04/12 06:36:32 $
 * $State: Exp $ $Locker:  $
 *
 * Description: File system access primitives
 * ===========================================================================
 * $Log: filefns.c,v $
 * Revision 1.8  2013/04/12 06:36:32  torer
 * New function (NA-CSV-READ STREAM DELIM)
 *
 * Revision 1.7  2010/10/27 18:31:36  torer
 * readfile in C
 *
 ****************************************************************************/

#include "amos.h"

#ifdef _MSC_VER
#include "c0xdir.h"
#else
#include <dirent.h>
#endif

EXPORT oidtype eofsymbol;

#define DEBUG 0 /* 0 or 1 */

void dirbf(a_callcontext cxt, a_tuple tpl) {
  char* dirname = NULL;
  int dirnamelen = 0;
  struct dirent* direntry;
  DIR* dirp;

  {
    unwind_protect_begin;
    dirnamelen = a_getelemsize(tpl, 0, FALSE);
    if (1==dirnamelen) {
      /* empty string -> replace by period + terminator */
      dirname = malloc(2*sizeof(char));
      strcpy(dirname, ".");
    } else {
      dirname = malloc((dirnamelen)*sizeof(char));
      a_getstringelem(tpl, 0, dirname, dirnamelen, FALSE);
    }

    dirp = opendir(dirname);
    if (NULL != dirp) {
      while ((direntry=readdir(dirp)) != NULL && !cxt->done) {
	a_setstringelem(tpl, 1, direntry->d_name, FALSE);
	a_emit(cxt, tpl, FALSE);
      }
    }
    unwind_protect_catch;
    if (dirname != NULL) {
      free(dirname);
      closedir(dirp);
    }
    unwind_protect_end;
  }
}

#ifdef NT
#define popen _popen
#define pclose _pclose
#endif

void execbf(a_callcontext cxt, a_tuple tpl) 
     /* Ececute OS command and return output as stream of row strings */
{
  FILE* fptr;
  char cmd[BUFSIZ];
  char buf[BUFSIZ];

  /* Get command */
  a_getstringelem(tpl, 0, cmd, BUFSIZ, FALSE);

  if ((fptr = popen(cmd, "r")) != NULL) 
    {
      while (fgets(buf, BUFSIZ, fptr) != NULL && !cxt->done) 
	{
	  int len = strlen(buf);

	  if(len>0) buf[len-1]='\0';
	  a_setstringelem(tpl, 1, buf, FALSE);
	  a_emit(cxt, tpl, TRUE);
	}
      (void) pclose(fptr);
    }
}

/*
  (defun readfile-+ (fno filename res)
  (with-input-file s filename
  (let (row)
  (while (neq (setq row (read s)) '*EOF*)
  (osql-result filename row)))))
*/

oidtype readfileBF(a_callcontext cxt) 
{
  oidtype s=nil, r=nil;
  bindtype env = varstack;

  a_setf(s, call_lisp(mksymbol("openstream"), env, 2, a_arg(cxt,1), 
                      mkstring("r")));  
  {unwind_protect_begin;
  a_setf(r, readfn(env, s));
  while(r!=eofsymbol)
    {
      a_bind(cxt, 2, r);
      a_result(cxt);
      a_setf(r, readfn(env,s));
    }
  unwind_protect_catch;
  a_free(s); /* Will also close file */
  a_free(r);
  unwind_protect_end;
  }
  return nil;
}

void register_filefns(void) 
{
  a_extfunction("DIRBF", dirbf);
  a_extfunction("EXECBF", execbf);
  a_extimpl("readfile-+",readfileBF);
  eofsymbol = mksymbol("*eof*"); 
}
