/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 1993-2008 Jonas S Karlsson, Tore Risch, Magnus Werner,  UDBL
 * $RCSfile: files.c,v $
 * $Revision: 1.8 $ $Date: 2013/05/16 20:02:13 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Implements basic file I/O library
 *
 * Requirements: 
 * ===========================================================================
 * $Log: files.c,v $
 * Revision 1.8  2013/05/16 20:02:13  torer
 * Propagation of enter systen times for events added
 *
 * Revision 1.7  2013/04/13 11:21:52  torer
 * Added writefile dribble
 *
 * Revision 1.6  2013/04/12 13:48:33  torer
 * Added Writebytes() method for file streams
 *
 * Revision 1.5  2012/06/28 20:00:32  torer
 * Global variables EXPORTTO and IMPORTFROM removed
 * New stream headers in C
 *
 * Revision 1.4  2011/03/09 12:33:41  torer
 * Amos as DLL!
 *
 * Revision 1.3  2009/09/08 20:39:19  torer
 * dribble input
 *
 * Revision 1.2  2009/09/08 20:15:44  torer
 * (dribble file) defined
 *
 * Revision 1.1  2008/12/30 12:47:19  torer
 * Basic I/O now in files.c
 *
 ****************************************************************************/

#include "kernel.h"
#include "comm.h"
#include <stdio.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>

extern void (*a_exit_handler)(int);
 

/*********************************
 * filesizefn
 * ==========
 * Returns size of file NAME (string),
 * -1 if file does not exist.
 *
 */

oidtype file_lengthfn(bindtype env, oidtype name)
{
    struct stat buff;
    int ret;
    
    if (stringp(name))
	ret = stat(getstring(name), &buff);
    else return nil;
    if (ret == -1) return nil;
    else return mkinteger(buff.st_size);
}


/*********************************
 * fileexistsfn
 * ============
 * Returns True if file NAME exists.
 * Otherwise NIL
 */

oidtype file_exists_pfn(bindtype env, oidtype name)
{
    oidtype size;

    size = file_lengthfn(env, name);
    if (size == nil) return nil;
    release(size);
    return t;
}

/********************************
 * deletefilefn
 * ============
 * Deletes fileNAME returning non-nil
 * on sucess.
 */

oidtype delete_filefn(bindtype env, oidtype name)
{
    OfType(name, STRINGTYPE, env);
    if (-1 == unlink(getstring(name)))
	return nil;
    else
	return name;
}

/*************************** File streams ************************************/

oidtype dribblestream = nil;

int close_file_stream(oidtype stream)
{
  int rc;

  if(!dr(stream,streamcell)->opened) return -1;
  signal(SIGINT,SIG_IGN);
  rc = fclose(dr(stream,streamcell)->fp);
  signal(SIGINT,a_interrupt_handler);
  dr(stream,streamcell)->opened = FALSE;
  return rc;
}

int fflush_file_stream(oidtype stream)
{
  return fflush(dr(stream,streamcell)->fp);
}

#ifdef AIX
int myfeof(FILE *fp)
{
  signed char c = fgetc(fp);
  int ic=c;

  if(c==EOF)
    return TRUE;
  ungetc(c,fp);
  return FALSE;
}
#else
#define myfeof feof
#endif

int feof_file_stream(oidtype stream)
{
  FILE *f;

  f = dr(stream,streamcell)->fp;
  if (myfeof(f))
    {
      clearerr(f);
      return TRUE;
    }
  return FALSE;
}

int file_getc(oidtype o)
{
  struct streamcell *s=dr(o,streamcell);
  oidtype logstream = s->header.logstream;
  int res;
  static int eofcnt=100;

  res = getc(s->fp);
  if(o == stdinstream)
    {
      if(res==EOF)
	{
	  if(!eofcnt--)(*a_exit_handler)(0); /* To avoid looping under Emacs */
	}
      else eofcnt=100;
      if(dribblestream!=nil) a_putc(res, dribblestream);
    }
  if(res=='\n')
    s->header.line_num++; 
  if(logstream!=nil)a_putc(res,logstream);
  return res;
}

int file_ungetc(int c, oidtype o)
{
  struct streamcell *s=dr(o,streamcell);
  int res = ungetc(c, s->fp);

  if(c=='\n') s->header.line_num--;
  return res;
}

int file_readbytes(oidtype o, void *buff, unsigned int len)
{
  struct streamcell *s=dr(o,streamcell);
  int res;

  res = fread(buff,1,len,s->fp);
  if(dribblestream!=nil && o == stdinstream) 
    a_writebytes(dribblestream, buff, len);
  return res;
}

int file_writebytes(oidtype o, void *buff, unsigned int len)
{
  struct streamcell *s=dr(o,streamcell);
  int res;

  if(dribblestream!=nil && o == stdoutstream) 
    a_writebytes(dribblestream, buff, len);
  res = fwrite(buff,1,len,s->fp);
  return res;
}

int file_puts(char *str, oidtype stream)
{
  if(dribblestream!=nil && stream == stdoutstream)
    { 
      file_puts(str, dribblestream);
      fflush_file_stream(dribblestream);
    }
  return fputs(str,dr(stream,streamcell)->fp);
}

int file_putc(int c, oidtype stream)
{
  if(dribblestream!=nil && stream == stdoutstream)
    { 
      file_putc(c, dribblestream);
      fflush_file_stream(dribblestream);
    }
  return fputc(c,dr(stream,streamcell)->fp);
}

oidtype dribblefn(bindtype env, oidtype file)
{
  if(file==nil)
    {
      closestreamfn(env, dribblestream);
      a_free(dribblestream);
      return nil;
    }
  a_setf(dribblestream, call_lisp(mksymbol("openstream"), 
                                  env, 2, file, mkstring("w")));
  return file;
}

/********************************
 * register_files_functions
 * ========================
 * registers functions in aLisp.
 */

void register_files_functions()
{
    a_setf(globval(mksymbol("stdinstream")), stdinstream);
    a_setf(globval(mksymbol("stdoutstream")), stdoutstream);
    a_setf(globval(mksymbol("stderrstream")), stderrstream);

    extfunction1("file-length", file_lengthfn);
    extfunction1("file-exists-p", file_exists_pfn);
    extfunction1("delete-file", delete_filefn);
    extfunction1("dribble", dribblefn);
    stream_implementations[STREAMTYPE].writebytes = file_writebytes;
    return;
}

    


