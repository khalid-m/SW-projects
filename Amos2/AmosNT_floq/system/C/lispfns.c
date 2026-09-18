/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2005 Tore Risch, UDBL
 * $RCSfile: lispfns.c,v $
 * $Revision: 1.96 $ $Date: 2014/01/14 21:25:16 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Utility Lisp functions 
 *
 * ===========================================================================
 * $Log: lispfns.c,v $
 * Revision 1.96  2014/01/14 21:25:16  torer
 * Dummy definition of (sig-bt) under Windows
 *
 * Revision 1.95  2014/01/14 21:03:18  torer
 * New function (sig-bt sig) to get C backtrace when interrupt sig occurs
 *
 * Revision 1.94  2014/01/12 16:52:25  torer
 * New function (C-BACKTRACE depth)
 *
 * Revision 1.93  2014/01/09 19:47:20  torer
 * C backtrace under OSX
 *
 * Revision 1.92  2013/10/31 21:38:29  chexu484
 * EXPORT C function: tconcfn
 *
 * Revision 1.91  2013/10/27 16:22:46  torer
 * New function (ERRORNUMBER MSG)
 *
 * Revision 1.90  2013/05/16 20:02:14  torer
 * Propagation of enter systen times for events added
 *
 * Revision 1.89  2013/03/23 12:01:23  torer
 * frand() using Mersenne Twister
 *
 * Revision 1.88  2013/03/20 21:39:32  torer
 * Error checks in random functions
 *
 * Revision 1.87  2013/03/14 15:01:19  torer
 * 32/64 bits neutral code
 *
 * Revision 1.86  2013/02/13 18:44:25  torer
 * System assertions + new Lisp function (TRAPDEALLOCA X)
 *
 * Revision 1.85  2012/11/01 15:36:53  torer
 * New function (INDICATE-ERROR ERRNO ERRSTR ERRFORM) to explicitly
 * incicate to kernel that error is raised without calling FAULTEVAL()
 *
 * Revision 1.84  2012/08/10 06:39:53  torer
 * (TRANSIENTP X) and (SYSTEM-OBJECTP X) in C
 *
 * Revision 1.83  2012/06/28 20:00:32  torer
 * Global variables EXPORTTO and IMPORTFROM removed
 * New stream headers in C
 *
 * Revision 1.82  2012/05/29 20:24:16  torer
 * Lisp registered errors now saved in image
 *
 * Revision 1.81  2012/05/23 17:43:40  torer
 * Exported error functions to Lisp
 * (REGISTER-ERROR MSG) -> NO
 * (RAISE-ERROR NO OBJ)
 *
 * Revision 1.80  2012/03/19 19:38:34  torer
 * read-token at eof bug
 *
 * Revision 1.79  2012/02/22 09:25:13  torer
 * No program database in released version
 *
 * Revision 1.78  2012/01/28 10:09:34  torer
 * Function EXTPRED-NAME added
 *
 * Revision 1.77  2012/01/24 12:33:16  torer
 * ungetc after readiing delimiter
 *
 * Revision 1.76  2012/01/16 10:02:29  torer
 * Implemented function-definedp and /defc in C
 *
 * Revision 1.75  2011/12/14 18:08:21  larme597
 * Bugfix in read_tokenfn().
 *
 * Revision 1.74  2011/07/06 20:23:55  torer
 * New function load_undef_extpred to signal undefined foreign function
 *
 * Revision 1.73  2011/04/13 15:03:13  torer
 * One off bug
 *
 * Revision 1.72  2011/03/09 12:33:42  torer
 * Amos as DLL!
 *
 * Revision 1.71  2010/12/29 20:31:08  torer
 * (BIND-UNDEFINED fndef) makes foreign function that is not yet executable
 *
 * Revision 1.70  2010/12/26 17:10:29  torer
 * 1. Not using a_global_callcontext
 * 2. Mappers now return oidtype
 *
 * Revision 1.69  2010/12/10 18:09:52  torer
 * TCONC in C
 *
 * Revision 1.68  2010/12/01 19:54:07  torer
 * Using alloca for better stack utilization
 *
 * Revision 1.67  2010/12/01 19:16:31  torer
 * Using a_mapfunctionC in system functions
 *
 * Revision 1.66  2010/12/01 07:40:15  torer
 * Optimized int-until
 *
 * Revision 1.65  2010/10/27 18:29:59  torer
 * (INT-UNTIL cond form1 .... formn)
 *
 * Revision 1.64  2010/09/11 03:07:44  torer
 * Byte buffer interface for JDBC strings
 *
 * Revision 1.63  2010/09/09 19:53:10  torer
 * Desctructive and scalable string concatenation: NCONCAT2
 *
 * Revision 1.62  2010/05/26 19:12:44  torer
 * Added the Mersenne Twister!
 *
 * Revision 1.61  2010/04/29 11:56:05  larme597
 * Improved random functions.
 *
 * Revision 1.60  2010/02/02 10:41:49  torer
 * (ENCODE-NUMERIC STR) converts string STR to number if it represents a number
 *
 * Revision 1.59  2009/10/20 21:20:51  zeitler
 * Memory leak fixed in read_tokenfn
 *
 * Revision 1.58  2009/10/09 13:53:01  torer
 * Tokenizer recognizes numbers by default
 *
 * Revision 1.57  2009/10/09 11:16:43  torer
 * read-token reads strings
 *
 * Revision 1.55  2009/09/30 18:53:46  torer
 * Moved definition of delimiters and break character to storage.h
 *
 * Revision 1.54  2009/09/30 18:10:24  torer
 * Lisp function to read a token for given delimiters and break characters
 *
 * Revision 1.53  2009/08/13 13:27:08  torer
 * ERROR? in C
 *
 * Revision 1.52  2009/05/28 19:12:46  torer
 * (REFCNT-AT addr) for memory leak debugging
 *
 * Revision 1.51  2009/04/29 15:46:08  torer
 * New function (PRINTWORDS ADDR SIZE) to dump image area
 *
 * Revision 1.50  2009/04/07 20:30:44  torer
 * Faster hashing on arrays and lists
 *
 * Revision 1.49  2008/11/23 17:04:34  torer
 * File position printed at errors
 *
 * Revision 1.48  2008/07/31 20:18:39  torer
 * (READLINE STR &OPTIONAL DELIM) takes optional character as delimiter. Default LF.
 *
 * Revision 1.47  2008/07/06 20:41:43  torer
 * New function (rename-file oldname newname)
 *
 * Revision 1.46  2008/02/08 10:14:00  torer
 * macros for default Lisp in and out streams
 *
 * Revision 1.45  2007/11/07 15:14:50  torer
 * Amos II version 10 with faster basic OjectLog interface to C
 * Aggregation operators can now be defined in C
 *
 ***************************************************************************/

#include "amos.h"
#include <sys/stat.h>
#include <limits.h>

oidtype _registered_errors_;

/***************************************************************************/
/*                    Lists                                                */
/***************************************************************************/

EXPORT oidtype tconcfn(bindtype env, oidtype hder, oidtype x)
{
  struct listcell *dhder;
  oidtype temp;

  if(hder==nil) return cons(nil,nil);
  dhder = dr(hder,listcell);
  if(typetag(dhder)!=LISTTYPE) return lerror(ARG_NOT_LIST, hder, env);
  if(dhder->tail==nil)
    {
      temp = cons(x,nil);
      dhder = dr(hder,listcell);
      a_setf(dhder->head, temp);
      a_setf(dhder->tail, dhder->head);
      return hder;
    }
  temp = cons(x,nil);
  dhder = dr(hder,listcell);
  a_setf(dr(dhder->tail,listcell)->tail, temp);
  a_setf(dhder->tail, temp);
  return hder;
}

/***************************************************************************/
/*                    Fast path interface                                  */
/***************************************************************************/
oidtype callfunction1_mapper(a_callcontext cxt, int arity, oidtype *restpl,
                          void *res)
{
  oidtype *r = (oidtype *)res;
  oidtype a = new_array(arity, nil);
  int i;

  for(i=0;i<arity;i++)
    {
      a_seta(a,i,restpl[i]);
    }
  *r = cons(a,*r);
  return nil;
}

EXPORT oidtype callfunction1fn(bindtype env, oidtype fno, oidtype args)
{
   oidtype res=nil;
   dcl_local_cxt(cxt, env);
   unwind_protect_begin;

   a_mapfunction(cxt, fno, args, callfunction1_mapper,(void *)&res);
   unwind_protect_catch;
   if(unwind_reset) release(res);
   unwind_protect_end;
   return(nreversefn(env,res));
}

/***************************************************************************/
/*                Register Amos function as undefined                      */
/***************************************************************************/
int undefined_extpred;
oidtype load_undef_extpred(a_callcontext cxt)
{
  a_error(undefined_extpred,dr(cxt->extp,extpredcell)->name,FALSE);
  return nil;
}

oidtype bind_undefinedfn(bindtype env, oidtype name)
     /* Define a foreign function that is now undefined */ 
{
  char *thename;
  oidtype res;

  IntoStackString(name,thename,env);

  /* Register foreignName as undefined */
  res = a_extimpl(thename, load_undef_extpred);

  return res;
}

oidtype extpred_namefn(bindtype env, oidtype ep)
{
  OfType(ep, extpredtype, env);
  return dr(ep, extpredcell)->name;
}

/***************************************************************************/
/*                    Plan invokation                                      */
/***************************************************************************/
oidtype _osql_result_;

struct invoke_plan_data
{
   int width;
   int arity;
   oidtype *emitTuple;
};

oidtype invoke_plan_mapper(a_callcontext cxt, int a, oidtype *restpl,
                        void *xa)
{
  struct invoke_plan_data *d = (struct invoke_plan_data *)xa;
  int i, arity = d->arity, width = d->width;

  for(i=arity; i<arity+width; i++)
  {
    d->emitTuple[i+2] = restpl[i-arity];
  }
  release(apply_lisp(_osql_result_, cxt->env, arity+width+2, d->emitTuple));
  return nil;
}

oidtype invoke_planfn(bindtype args, bindtype env)
{
  oidtype subfno = nthargval(args,2);
  oidtype arity = nthargval(args,3);
  int i;
  struct invoke_plan_data mapperinfo;
  oidtype *argl;
  dcl_local_cxt(cxt, env);

  IntoInteger(arity, mapperinfo.arity, env);
  argl = alloca(sizeof(oidtype)*mapperinfo.arity);
  mapperinfo.width = envarity(args) - mapperinfo.arity - 3;
  mapperinfo.emitTuple =
    alloca(sizeof(oidtype)*(mapperinfo.arity+mapperinfo.width+2));
  mapperinfo.emitTuple[0]=subfno;
  mapperinfo.emitTuple[1]=arity;
  for(i=0;i<mapperinfo.arity;i++)
    {
      argl[i] = nthargval(args,i+4);
      mapperinfo.emitTuple[i+2]= argl[i];
    }
  a_mapfunctionC(cxt, subfno, mapperinfo.arity, argl, 
                 invoke_plan_mapper, &mapperinfo);
  return nil;
}

oidtype OK_mapper(a_callcontext cxt, int arity, oidtype *restpl, void *xa)
{
  *((int *)xa)=TRUE;
  return nil;
}

oidtype proccallfn(bindtype env, oidtype fno, oidtype argl)
     /* Invoke stored procedure. Return T if any value returned */
{
  int OK=FALSE;
  dcl_local_cxt(cxt, env);

  a_mapfunction(cxt, fno, argl, OK_mapper, (void *)&OK);
  if(OK) return t;
  return nil;
}

/***************************************************************************/
/*                      type checking                                      */
/***************************************************************************/
extern oidtype type_allsupertypesfn(bindtype,oidtype);
extern oidtype arg_typesfn(bindtype, oidtype);
oidtype _vector_;

oidtype osql_subtypepfn(bindtype env, oidtype x, oidtype y, oidtype strict)
     /* Is type x <= type y? */
{
  if(memqfn(env, y, type_allsupertypesfn(env, x)) == nil) return nil;
  if(strict == nil) return t;
  if(x == y) return nil;
  return t;
}

oidtype transientpfn(bindtype env, oidtype x)
{
  if(a_datatype(x)==SURROGATETYPE && dr(x,oidcell)->idno == -2) return t;
  return nil; 
}

extern oidtype _system_watermark_;
oidtype system_objectpfn(bindtype env, oidtype x)
{
  int idno;

  if(a_datatype(x)!=SURROGATETYPE) return nil;
  idno = dr(x,oidcell)->idno;
  if(idno>=0 && idno<=getinteger(globval(_system_watermark_))) return t;
  return nil; 

}

oidtype matchargfn(bindtype env, oidtype a, oidtype tp)
     /* Does actual parameter a match type tp? */
{
  oidtype u, tpl;

  if(tp == globval(_vector_))
  {
     if(a_datatype(a)==ARRAYTYPE) return t;
     return nil;
  }
  a_let(tpl, arg_typesfn(env, a));
  for(u=tpl;listp(u);u=ftl(u))
    {
      if(osql_subtypepfn(env,fhd(u),tp,nil)!=nil)
	{
	  a_free(tpl);
	  return t;
	}
    }
  a_free(tpl);
  return nil;
}

/***************************************************************************/
/*                      files and directories                              */
/***************************************************************************/

#ifdef NT
#define PATH_MAX MAX_PATH
#endif

oidtype line_numfn(bindtype env, oidtype stream)
{
  OfType(stream, STREAMTYPE, env);
  return mkinteger(dr(stream,streamcell)->header.line_num);
}

extern oidtype new_timeval(unsigned long seconds, long useconds);
oidtype file_write_datefn(bindtype env, oidtype file)
{
  char *filename;
  struct stat sbuff;
  time_t dt;

  IntoString(file, filename, env);
  if(stat(filename, &sbuff)) return nil;
  dt = sbuff.st_mtime;
  return new_timeval(dt,0);
}

oidtype directorypfn(bindtype env, oidtype file)
{  char *filename;
  struct stat sbuff;

  IntoString(file, filename, env);
  if(stat(filename, &sbuff)) return nil;
  if((sbuff.st_mode) & S_IFDIR) return t;
  return nil;
}

void substchar(char from, char to, char *str)
{
  while((str = strchr(str,from)) != NULL)
    *str=to;
}

oidtype fullpathfn(bindtype env, oidtype file)
{
  char *filename;
  char buffer[PATH_MAX];

  IntoString(file, filename, env);
#ifdef NT
  _fullpath(buffer, filename, sizeof(buffer));
  substchar('\\','/',buffer); // Always like in Unix
#else
  realpath(filename, buffer);
#endif
  return mkstring(buffer);
}

#ifdef NT

oidtype file_positionfn(bindtype env, oidtype fstream, oidtype newpos)
{
   struct streamcell *fstr;
   fpos_t pos;
   int r;
   FILE *fp;
   static oidtype startkeyw=NULLH, endkeyw=NULLH;

   if(startkeyw==NULLH)
     {
       startkeyw=mksymbol(":start");
       endkeyw=mksymbol(":end");
     }
   OfType(fstream, STREAMTYPE, env);
   fstr = dr(fstream,streamcell);
   fp = fstr->fp;
   if(newpos==endkeyw)
     {
       r=fseek(fp, 0, SEEK_END);
       if(r) return lerror(CANNOT_OPEN_FILE, fstream, env);
       r = fgetpos(fp, &pos);
       if(r) return lerror(CANNOT_OPEN_FILE, fstream, env);
       return mkinteger((int)pos);
     }
   if(newpos==startkeyw)newpos=mkinteger(0);
   if(newpos!=nil)
     {
      IntoInteger(newpos,pos,env);
      r = fsetpos(fp, &pos);
      if(r) return lerror(CANNOT_OPEN_FILE, fstream, env);
      return mkinteger((int)pos);
     }
   r = fgetpos(fp, &pos);
   if(r) return lerror(CANNOT_OPEN_FILE, fstream, env);
   return mkinteger((int)pos);
}
#endif

oidtype rename_filefn(bindtype env, oidtype oldname, oidtype newname)
{
  char *oldn, *newn;

  IntoString(oldname, oldn, env);
  IntoString(newname, newn, env);
  if(rename(oldn,newn)<0) return lerror(CANNOT_OPEN_FILE,oldname,env);
  return newname;
}

/***************************************************************************/
/*                      I/O streams                                        */
/***************************************************************************/

#define INITSIZE 1000
oidtype read_linefn(bindtype env, oidtype stream, oidtype delim)
   /* Read a line from stream */
{
  char buff[INITSIZE], *buffp=buff;
  int pos=-1, pmax=INITSIZE, ch, ready=FALSE;
  oidtype res, str=instream(stream);
  char *ds; char dc;

  if(delim != nil)
    {
      IntoString(delim, ds, env);
      dc = ds[0];
    }
  else dc = '\n';
  while (TRUE)
    {
      if(pos>=pmax-1)
      {
        pmax = 2*pmax;
        if(buffp!=buff)
            buffp=(char *)realloc(buffp,pmax);
        else
        {
           buffp=mymalloc(pmax);
           memcpy(buffp,buff,INITSIZE+1);
        }
      }
      if(ready)
      {
         ch = '\0';
         break;
      }
      else if((ch = a_getc(str))==EOF)
      {
         if(pos<0)return eofsymbol;
         ready=TRUE;
      }
      else if(ch==dc) ready=TRUE;
      else if(ch!='\r')
      {
        pos++;
        buffp[pos]=(char)ch;
      }
    }
  buffp[pos+1]='\0';
  res = mkstring(buffp);
  if(buffp!=buff)free(buffp);
  return res;
}

oidtype eof_pfn(bindtype env, oidtype stream)
{
   oidtype s = instream(stream);

   if(a_feof(s)) return t;
   return nil;
}

oidtype read_bytesfn(bindtype env, oidtype len, oidtype stream)
{
  oidtype s = instream(stream), res;
  unsigned int l;
  char buff[1024]; char *buffp = buff;

  IntoInteger(len, l, env);
  if(l+1>=sizeof(buff)) buffp = (char *)mymalloc(l+1);
  a_readbytes(s, buffp, l);
  buffp[l]='\0';
  res = mkstring(buffp);
  if(buffp!=buff)free(buffp);
  return res;
}

oidtype read_octfn(bindtype env, oidtype stream)
  /* Read an octal number from stream */
{
  char buff[sizeof(int)*8+1], ch;
  int i, res;
  oidtype str = instream(stream);

  for(i=0;i<sizeof(buff);i++)
  {
    ch = (char)a_getc(str);
    if(ch==EOF) return eofsymbol;
    if(strchr("1234567890abcdefABCDEF",ch)!=NULL) buff[i] = ch;
    else break;
  }
  buff[i]='\0';
  sscanf(buff,"%x",&res);
  return mkinteger(res);
}

oidtype encode_numericfn(bindtype env, oidtype s)
{
  char *str;
  oidtype r;

  IntoString(s,str,env);
  r = a_encodeNumeric(str);
  if(r==NULLH) return s;
  return r;
}

extern oidtype readstring(oidtype str);

oidtype read_tokenfn(bindtype env, oidtype str, oidtype delims, 
                     oidtype brchars, oidtype stringify_numbers,
                     oidtype nostrings)
     /* Read next token as a string, for given break characters
        and delimiters */
{
  int ch;
  char *brk, *delim, *p;
  oidtype stream = instream(str), res;
  char buff[50];  // most strings shorter
  char *buffp = buff;
  int buffsize = sizeof(buff);
  int buffpos = 0; 
  char cstr[2]; /* Character string buffer */
  
  cstr[1] = '\0';
  if(brchars==nil) brk = BREAKCHARS;
  else 
  {
    OfType(brchars, STRINGTYPE, env);
    IntoStackString(brchars, brk, env);
  }
  if(delims==nil) delim = DELIMITERS;
  else 
  {
    OfType(delims, STRINGTYPE, env);
    IntoStackString(delims, delim, env);
  }
  /* Skip delimiters: */
  while((p=strchr(delim,(ch = a_getc(stream))))!=NULL);
  if(ch==EOF) return eofsymbol;
  if(strchr(brk,ch)!=NULL) 
    { /* First non-delimiter was a break character */
      cstr[0] = ch;
      if(nostrings == nil && ch == '"') return readstring(stream);
      return mkstring(cstr);
    }
  for(;strchr(delim, ch)==NULL; ch = a_getc(stream))
    {
      if(ch==EOF) break; /* EOF is a break character */
      cstr[0] = ch;
      if(strchr(brk, ch)!=NULL)
        { /* break character not absorbed */
          break;
        }
      if(buffpos >= buffsize-1)
        {
          buffsize = 2*buffsize;
	  if(buffp == buff) 
	    {
              buffp = mymalloc(buffsize);
              memcpy(buffp, buff, sizeof(buff));
	    }
	  else buffp = myrealloc(buffp, buffsize);
        }
      buffp[buffpos] = ch;
      buffpos++;
    }
  if(ch!=EOF) a_ungetc(ch, stream);
  buffp[buffpos] = '\0';
  if (stringify_numbers != nil || (res = a_encodeNumeric(buffp))== NULLH)
    res = mkstring(buffp);
  if(buffp!=buff) free(buffp);
  return res;
}

oidtype systimestreamfn(bindtype env, oidtype stream, oidtype flag)
{
  if(!a_streamp(stream)) return lerror(ARG_NOT_STREAM, stream, env);
  dr(stream,streamcell)->header.systime = (flag!=nil);
  return flag;
}

oidtype systimestreampfn(bindtype env, oidtype stream)
{
  if(!a_streamp(stream)) return lerror(ARG_NOT_STREAM, stream, env);
  if(dr(stream,streamcell)->header.systime) return t;
  return nil;
}

/***************************************************************************/
/*              Vector Functions                                           */
/***************************************************************************/
/*
 * The following code is public domain.
 * Algorithm by Torben Mogensen, based on implementation by N. Devillard.
 * This code in public domain.
 */
oidtype medianfn(bindtype env, oidtype m)
{
  int i, n, less, greater, equal;
  double min, max, guess, maxltguess, mingtguess;

  OfType(m,ARRAYTYPE,env);
  n = a_arraysize(m);
  if (n==0) return nil;
  min = max = coerce_real(env, a_elt(m,0));
  for (i=1 ; i<n ; i++)
    {
      double mr = coerce_real(env, a_elt(m,i));

      if(mr < min) min=mr;
      if(mr > max) max=mr;
    }
  while (TRUE)
    {
      guess = (min+max)/2;
      less = 0; greater = 0; equal = 0;
      maxltguess = min ;
      mingtguess = max ;
      for (i=0; i<n; i++)
	{
          double mr = coerce_real(env, a_elt(m,i));

	  if (mr<guess)
	    {
	      less++;
	      if (mr>maxltguess) maxltguess = mr;
	    }
	      else if (mr>guess)
	    {
	      greater++;
	      if (mr<mingtguess) mingtguess = mr;
	    }
	  else equal++;
	}
      if (less <= (n+1)/2 && greater <= (n+1)/2) break ;
      else if (less>greater) max = maxltguess ;
      else min = mingtguess;
    }
  if (less >= (n+1)/2) return mkreal(maxltguess);
  else if (less+equal >= (n+1)/2) return mkreal(guess);
  else return mkreal(mingtguess);
}

oidtype sxhashfn(bindtype env, oidtype x)
{
  return mkinteger(compute_hash_key(x));
}

/***************************************************************************/
/*                        random functions                                 */
/***************************************************************************/

extern int rand_int(int);
extern int srand_int(int);
extern double genrand_res53(void);

oidtype newrandomfn(bindtype env, oidtype num)
{
  int i;
  IntoInteger(num, i, env);
  if(i<=1) return mkinteger(0);
  return mkinteger(rand_int(i));
}

oidtype newrandominitfn(bindtype env, oidtype num)
{
  int i;

  IntoInteger(num, i, env);
  if(i<1) return lerror(ILLEGAL_ARGUMENT, num, env);
  srand_int(i);
  return num;
}

oidtype frandfn(bindtype env, oidtype lower, oidtype upper)
{
  double dlower, dupper;
  
  IntoDouble(lower, dlower, env);
  IntoDouble(upper, dupper, env);
  return mkreal(dlower + genrand_res53()*(dupper - dlower));
}

/***************************************************************************/
/*              Strings                                                    */
/***************************************************************************/
extern int next_blksize(int);

oidtype nconcat2c(bindtype env, int lx, char *sx, int ly, char *sy)
{
  char *buffer = mymalloc(lx + ly + 1);
  oidtype res;

  memcpy(buffer, sx, lx);
  memcpy(buffer+lx, sy, ly);
  buffer[lx + ly] = '\0';
  res = new_string(lx+ly+1, buffer);
  free(buffer);
  return res;
}

oidtype nconcat2(bindtype env, oidtype x, int ly, char *sy)
     /* descructively concatenate x with y if there is slack, 
        otherwise regular concat. 
        Use very carefully! */
{
  struct stringcell *dx;
  int lx;
  char *sx;

  IntoString(x, sx, env);
  lx = stringlen(x);//including \n
  dx = dr(x, stringcell);
  sx = (char *)&dx->cont;
  if(lx<MAX_LENGTH && lx + ly > MAX_LENGTH) 
    return nconcat2c(env, lx-1, sx, ly, sy);
  if(lx<MAX_LENGTH)
    {
      int curlen = sizeof(*dx)-sizeof(dx->cont.string)+lx;
      int nxtlen = next_blksize(curlen);

      if(curlen + ly <= nxtlen)
	{ 
	memcpy(sx+lx-1,sy,ly);
	sx[lx+ly-1] = '\0';
	dx->shortlen = lx + ly;
        return x;
        }
      return nconcat2c(env, lx-1, sx, ly, sy);
      }
  return nconcat2c(env, lx-1, sx, ly, sy);
}

oidtype nconcat2fn(bindtype env, oidtype x, oidtype y)
     /* descructively concatenate x with y if there is slack, 
        otherwise regular concat. 
        Use very carefully! */
{
  char *sx, *sy;

  IntoString(x,sx,env);
  IntoString(y,sy,env);
  return nconcat2(env, x, strlen(sy), sy);
}

/***************************************************************************/
/*              Debugging                                                  */
/***************************************************************************/

void trapdeallocfn_trapper(oidtype x)
{
  printf("Deallocating location %zu: ", x);
  printf("Enter any character to raise error >"); fgetc(stdin); fgetc(stdin);
  lerror(TRAPPED_DEALLOCATION, x, topframe());
}

oidtype trapdeallocafn(bindtype env, oidtype x)
{
  int loc;
  IntoInteger(x, loc, env);
  a_trap_dealloc(loc, trapdeallocfn_trapper);
  return x;
}

oidtype printwordsfn(bindtype env, oidtype pos, oidtype words)
{
  int addr, len, i;
  char *p;

  IntoInteger(pos, addr, env);
  IntoInteger(words, len, env);
  p = begin_image + addr;
  for(i=0; i<len; i++)
    {
       printf("%d ", *(int *) p);
       p = p + sizeof(int);
    }
  printf("\n");
  return nil; 
}

extern oidtype refcntfn(bindtype, oidtype);
oidtype refcnt_atfn(bindtype env, oidtype addr)
{ /* Return reference counter for object at address addr */
  oidtype o;
 
  IntoInteger(addr, o, env);
  return refcntfn(env, o);
}

/***************************************************************************/
/*              Error management                                           */
/***************************************************************************/
extern oidtype memberfn(bindtype, oidtype, oidtype);
oidtype register_errorfn(bindtype env, oidtype msg)
{
  char *dmsg;

  IntoString(msg, dmsg, env);
  if(memberfn(env, msg, globval(_registered_errors_))== nil)
    {a_setf(globval(_registered_errors_), 
            cons(msg, globval(_registered_errors_)));}
  return mkinteger(a_register_error(dmsg));
}

oidtype errornumberfn(bindtype env, oidtype msg)
{
  char *dmsg;
  int res;

  IntoString(msg, dmsg, env);
  res = a_errornumber(dmsg);
  if(res) return mkinteger(res);
  return nil;
}

oidtype raise_errorxfn(bindtype env, oidtype err, oidtype x)
{
  int derr;

  IntoInteger(err, derr, env);
  return lerror(derr, x, env);
}

oidtype indicate_errorfn(bindtype env, oidtype eno, oidtype errmsg,
                         oidtype errform)
     /* Explicitly indicate to core C error handling 
	that error has occurred */
{
  IntoInteger(eno, a_errno, env);
  IntoString(errmsg, a_errstr, env);
  a_setf(a_errform, errform);
  return t;
}

oidtype errcond_key;
EXPORT oidtype error_qfn(bindtype env, oidtype form)
{
  if(!listp(form)) return nil;
  return getffn(env, form, errcond_key);
}

/***************************************************************************/
/*              Control structures                                         */
/***************************************************************************/

oidtype int_untilfn(bindtype newenv, bindtype env)
{
  oidtype cond = nthargval(newenv,1), v = nil, stop=nil;
  bindtype a;

  for(;;)
    {
      arg_start(a,newenv + 1); /* evaluate forms in body */
      while(arg_varp(a))
	{
	  release(v); /* To dealloc in case of error */
	  CheckInterrupt;
	  v = evalfn(env,arg_nextval(a));
	}
      stop = evalfn(env,cond); /* Evaluate condition */
      if(stop != nil)
        {
	   release(stop);
           return v;
        }
    }
}

oidtype function_definedpfn(bindtype env, oidtype fn)
{
  if(symbolp(fn) && dr(fn,symbolcell)->fndef!= nil) return t;
  return nil;
}

oidtype _defc_;
oidtype t_defcfn(bindtype env, oidtype fn, oidtype def)
{
  OfType(fn, SYMBOLTYPE, env);
  history_addfn(env, globval(_defc_), fn, nil, dr(fn,symbolcell)->fndef, def);
  a_setf(dr(fn,symbolcell)->fndef, def);
  return fn;
}

oidtype remove_master_commentfn(bindtype env, oidtype fn)
{
  oidtype def, comm;

  OfType(fn, SYMBOLTYPE, env);
  def = dr(fn,symbolcell)->fndef;
  if(!listp(def)) return nil;
  if(!listp(tl(def))) return nil;
  def = tl(def);
  if(!listp(tl(def))) return nil;
  comm = hd(tl(def));
  if(!listp(tl(tl(def))) || !stringp(comm)) return nil;
  a_setf(ftl(def), tl(tl(def)));
  return t;
}

#ifdef NT
oidtype C_backtracefn(bindtype env, oidtype depth)
{
  return nil; // dummy for now
}

oidtype sig_btfn(bindtype env, oidtype signo)
{
  printf("(SIG-BT) not implemented under Windows\n"); fflush(stdout);
  return nil;
}
#else
#include <execinfo.h>


#define MAX_BACKTRACE_DEPTH 4000
oidtype C_backtracefn(bindtype env, oidtype depth)
{
  int d;
  void* callstack;
  int i, frames, first=TRUE;
  char** strs;
  oidtype res=nil;

  if(depth==nil) d = MAX_BACKTRACE_DEPTH-1;
  else IntoInteger(depth, d, env);
  if(d<=0 | d>=MAX_BACKTRACE_DEPTH) 
   return lerror(ILLEGAL_ARGUMENT, depth, env);
  d++;
  callstack = malloc(d*sizeof(void *));
  frames = backtrace(callstack, d);
  strs = backtrace_symbols(callstack, frames);
  for (i = 0; i < frames; ++i) 
    {
      if(first) first = FALSE; // skip this fn
      else
	{
          printf("%s\n", strs[i]);
	}
    }
  free(strs);
  free(callstack);
  return depth;
}

void a_btC(int signo)
{
  printf("Interrupt no %d\n", signo);
  C_backtracefn(varstack, nil);
  exit(1);
}

oidtype sig_btfn(bindtype env, oidtype sigint)
{
  int intno;

  if(sigint==nil) intno = SIGSEGV;
  else {IntoInteger(sigint, intno, env);}
  signal(intno, a_btC);
  return nil;
}

#endif

/***************************************************************************/
/*              Register new Lisp functions                                */
/***************************************************************************/

void register_lispfns(void)
{
  extfunction2("tconc", tconcfn);

  extfunction2("callfunction1", callfunction1fn);

  extfunction1("bind-undefined",bind_undefinedfn);
  undefined_extpred = a_register_error("External predicate is undefined");
  extfunction1("extpred-name", extpred_namefn);
  extfunctionn("invoke-plan",invoke_planfn);
  _osql_result_ = mksymbol("osql-result");
  extfunction2("proccall",proccallfn);

  extfunction3("osql-subtypep",osql_subtypepfn);
  extfunction1("transientp", transientpfn);
  extfunction1("system-objectp",system_objectpfn);
  extfunction2("matcharg",matchargfn);

  extfunction1("line-num", line_numfn);
  extfunction1("file-write-date",file_write_datefn);
  extfunction1("directoryp",directorypfn);
  extfunction1("fullpath",fullpathfn);
  extfunction2("rename-file", rename_filefn);
#ifdef NT
  extfunction2("file-position",file_positionfn);
#endif

  extfunction2("read-line",read_linefn);
  extfunction1("eof-p",eof_pfn);
  extfunction2("read-bytes",read_bytesfn);
  extfunction1("read-oct",read_octfn);
  extfunction5("read-token",read_tokenfn);
  extfunction1("encode-numeric", encode_numericfn);
  extfunction2("systimestream", systimestreamfn);
  extfunction1("systimestreamp", systimestreampfn);

  extfunction1("median", medianfn);
  extfunction1("sxhash", sxhashfn);

  extfunction1("trapdealloca", trapdeallocafn);
  extfunction2("printwords", printwordsfn);
  extfunction1("refcnt-at", refcnt_atfn);

  extfunction1("random", newrandomfn);
  extfunction1("randominit", newrandominitfn);
  extfunction2("frand", frandfn);

  extfunction2("nconcat2", nconcat2fn);
  
  extfunction1("register-error", register_errorfn);
  _registered_errors_ = mksymbol("_registered-errors_");
  globval(_registered_errors_) = nil;
  extfunction1("errornumber", errornumberfn);
  extfunction2("raise-error", raise_errorxfn);
  extfunction3("indicate-error", indicate_errorfn);
  extfunction1("error?", error_qfn);
  errcond_key = mksymbol(":errcond");

  extfunctionq("int-until",int_untilfn);

  extfunction1("function-definedp", function_definedpfn);
  _defc_ = mksymbol("_defc_");
  extfunction2("/defc",t_defcfn);
  extfunction1("remove-master-comment",remove_master_commentfn);
  _vector_ = mksymbol("_vector_");
  extfunction1("c-backtrace",C_backtracefn);
  extfunction1("sig-bt", sig_btfn);
}
