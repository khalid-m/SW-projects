 /****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Erik Zeitler, UDBL
 * $RCSfile: numarray.c,v $
 * $Revision: 1.64 $ $Date: 2013/11/08 06:23:35 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Management of binary repr numerical data
 * ===========================================================================
 * $Log: numarray.c,v $
 * Revision 1.64  2013/11/08 06:23:35  torer
 * Restored NUMOOB_ERROR used by SSDM and SARD
 *
 * Revision 1.63  2013/11/05 18:52:51  torer
 * numarray inde xout of bounds returns failure
 *
 * Revision 1.62  2013/06/25 15:49:46  larme597
 * Undo.
 *
 * Revision 1.61  2013/06/25 13:56:14  larme597
 * Changing NUMARRAYTYPE to fix compiler error.
 *
 * Revision 1.60  2013/05/30 13:02:18  torer
 * Exported entries
 *
 * Revision 1.59  2013/05/17 14:27:53  torer
 * Added CSV report time stamps
 *
 * Revision 1.58  2013/04/18 17:42:44  torer
 * Numarray CSV reader functions are now named:
 *
 * oidtype na_csv_double_readfn(bindtype env, oidtype str, oidtype delim);
 * oidtype na_csv_float_readfn(bindtype env, oidtype str, oidtype delim);
 *
 * Revision 1.57  2013/04/17 21:37:17  torer
 * Alignment bug
 *
 * Revision 1.56  2013/04/15 18:23:28  torer
 * Wrong size of farrays (factor 2 too large)
 *
 * Revision 1.55  2013/04/15 17:14:49  torer
 * Restored old na_csv_readfn() so that the debswrapper still works.
 * Added new function na_csv_freadfn() for new debs wrapper using single precision
 *
 * Revision 1.54  2013/04/15 16:58:56  torer
 * Single precision flotaing point numarrays introduced
 *
 * Revision 1.53  2013/04/13 08:27:03  torer
 * Exporting NUMARRAYTYPE and na_csv_readfn()
 *
 * Revision 1.52  2013/04/12 06:36:31  torer
 * New function (NA-CSV-READ STREAM DELIM)
 *
 * Revision 1.51  2013/04/10 16:30:06  torer
 * Super fast printing of 0.0
 *
 * Revision 1.50  2013/04/10 15:22:24  torer
 * Faster CSV writer
 *
 * Revision 1.49  2013/04/10 15:11:08  torer
 * Faster CSV printer
 *
 * Revision 1.48  2013/04/10 09:23:41  torer
 * CSV print
 *
 ***************************************************************************/

#include "amos.h"
#include "numarray.h"
#include "fftcomplex.h"
#include "complex.h"
#include "w.h"

//#define DEBUG

EXTERN double a_round(double x);
extern int read_word(oidtype str);
EXPORT int NUMARRAYTYPE;

int NUMOOB_ERROR, NUMNARR_ERROR, NUMDMIS_ERROR, NUMNOTIMP_ERROR,
  NUMUNKNOWN_ERROR, NUMTMISMATCH_ERROR, MAMISMATCH_ERROR;
int nannotator;

#ifndef max
#define max(a, b) ( (a) > (b) ? a : b)
#endif
#ifndef min
#define min(a, b) ( (a) < (b) ? a : b)
#endif

oidtype new_numarray(int size) {
  /* size is required size in bytes of cont area. */
  struct numarraycell *dres;
  oidtype res;

  /* Total o
bject size adjusted for word limits: */
  int i, bytes = size + sizeof(*dres) - sizeof(dres->cont);
  int words = size/WORD_SIZE;

  res = new_aligned_object(bytes, NUMARRAYTYPE);
  dres = dr(res, numarraycell);
  for(i=0; i < words; i++) {
    dres->cont[i]=0;
  }
  return res;
}

oidtype make_numarray(int numelems, int elemsize, int kind) {
  struct numarraycell *dres;
  oidtype res = new_numarray(numelems*elemsize);
  dres = dr(res, numarraycell);
  dres->kind = kind;
  dres->numelems = numelems;
  return res;
}

void inspect_numarray(oidtype x) {
  struct numarraycell *dx;
  dx = dr(x, numarraycell);
  printf(" inspect_numarray: kind=%d, bytes=%u, numelems=%d\n", dx->kind, 
	 dx->bytes, dx->numelems); fflush(stdout);
}

size_t numarray_elemsize(int kind) {
  size_t ret = 0;
  switch(kind) {
  case 0:
    ret = sizeof(int);
    break;
  case 1:
    ret = sizeof(double);
    break;
  case 2:
    ret = sizeof(COMPLEX);
    break;
  case 3:
    ret = sizeof(float);
  }
  return ret;
}

oidtype numarry_copyfn(bindtype env, oidtype x, oidtype newsize) 
{
  struct numarraycell *dx, *dres;
  oidtype res = nil;
  int numelems = 0, kind = 0;
  size_t sz;
  OfType(x, NUMARRAYTYPE, env);
  dx = dr(x, numarraycell);
  kind = dx->kind;
  if(newsize==nil) numelems = dx->numelems;
  else 
    {
      IntoInteger(newsize, numelems, env);
      if(numelems < dx->numelems) 
	return lerror(ILLEGAL_ARGUMENT, newsize, env);
    }
  switch(kind) 
    {
    case 0:
      sz = sizeof(int);
      break;
    case 1:
      sz = sizeof(double);
      break;
    case 2:
      sz = sizeof(COMPLEX);
      break;
    case 3:
      sz = sizeof(float);
      break;
    default:
      lerror(NUMUNKNOWN_ERROR, x, env);
      break;
    }
  res = make_numarray(numelems, sz, kind);
  dx = dr(x, numarraycell);
  dres = dr(res, numarraycell);
  memcpy(dres->cont, dx->cont, dx->numelems * sz);
  dres->kind = dx->kind;
  return res;
}

EXPORT oidtype na_new_iarray(int dim)
{
  return make_numarray(dim, sizeof(int), 0);
}

oidtype make_iarrayfn(bindtype env, oidtype numelems) 
{
  OfType(numelems, INTEGERTYPE, env);
  return na_new_iarray(getinteger(numelems));
}

EXPORT oidtype na_new_darray(int dim)
{
  return make_numarray(dim, sizeof(double), 1);
}

oidtype make_darrayfn(bindtype env, oidtype numelems) 
{
  OfType(numelems, INTEGERTYPE, env);
  return na_new_darray(getinteger(numelems));
}

oidtype make_carrayfn(bindtype env, oidtype numelems) 
{
  OfType(numelems, INTEGERTYPE, env);
  return make_numarray(getinteger(numelems), sizeof(COMPLEX), 2);
}

oidtype make_farrayfn(bindtype env, oidtype numelems) 
{
	OfType(numelems, INTEGERTYPE, env);
	return make_numarray(getinteger(numelems), sizeof(float), 3);
}

oidtype init_iarrayfn(bindtype env, oidtype init_array) {
  oidtype res = nil;
  int num, j;
  int* t;
  struct numarraycell *dres;

  if (!arrayp(init_array)) {
    return lerror(NUMNARR_ERROR, init_array, env);
  }
  num = a_arraysize(init_array);
  a_setf(res, make_numarray(num, sizeof(int), 0));
  dres = dr(res, numarraycell);
  t = (int*) dres->cont;
	
  for (j=0; j < num; j++) {
    t[j] = getinteger(a_elt(init_array, j));
  }
  a_return(res);
}

oidtype init_darrayfn(bindtype env, oidtype init_array) {
  oidtype res = nil;
  int num, j;
  double* t;
  struct numarraycell *dres;
	
  if (!arrayp(init_array)) {
    return lerror(NUMNARR_ERROR, init_array, env);
  }
  num = a_arraysize(init_array);
  a_setf(res, make_numarray(num, sizeof(double), 1));
  dres = dr(res, numarraycell);
  t = (double*) dres->cont;
	
  for (j=0; j < num; j++) {
    IntoDouble(a_elt(init_array, j), t[j], env);
  }
  a_return(res);
}

oidtype init_farrayfn(bindtype env, oidtype init_array) {
  oidtype res = nil;
  int num, j;
  float* t;
  struct numarraycell *dres;
	
  if (!arrayp(init_array)) {
    return lerror(NUMNARR_ERROR, init_array, env);
  }
  num = a_arraysize(init_array);
  a_setf(res, make_numarray(num, sizeof(float), 3));
  dres = dr(res, numarraycell);
  t = (float*) dres->cont;
	
  for (j=0; j < num; j++) {
    double temp;

    IntoDouble(a_elt(init_array, j), temp, env); 
    t[j] = (float)temp;
  }
  a_return(res);
}

oidtype init_carrayfn(bindtype env, oidtype init_re, oidtype init_im) {
  oidtype res = nil;
  int num, j;
  COMPLEX* t;
  struct numarraycell *dres;
	
  if (!arrayp(init_re)) {
    return lerror(NUMNARR_ERROR, init_re, env);
  }
  if (!arrayp(init_im)) {
    return lerror(NUMNARR_ERROR, init_im, env);
  }

  num = a_arraysize(init_re);
  if (a_arraysize(init_im) != num) {
    return lerror(NUMDMIS_ERROR, init_im, env);
  }
		
  a_setf(res, make_numarray(num, sizeof(COMPLEX), 2));
  dres = dr(res, numarraycell);
  t = (COMPLEX*) dres->cont;
	
  for (j=0; j<num; j++) {
    t[j].re = getreal(a_elt(init_re, j));
    t[j].im = getreal(a_elt(init_im, j));
  }
  a_return(res);
}

oidtype init_ccarrayfn(bindtype env, oidtype init_carray) {
  oidtype res;
  int num, j;
  struct numarraycell *dr, *dx;
  COMPLEX *x, *r;

  OfType(init_carray, NUMARRAYTYPE, env);
  dx = dr(init_carray, numarraycell);
  num = dx->numelems;
  res = make_carrayfn(env, mkinteger(num));
  dr = dr(res, numarraycell);
  r = (COMPLEX*) dr->cont;
  x = (COMPLEX*) dx->cont;
	
  for (j=0; j<num; j++) {
    r[j].re = x[j].re;
    r[j].im = x[j].im;
  }
  return res;
}

void bulkprint_numarray(oidtype x, oidtype stream, int princflg)
     /*** Bulk write numarray array to streams ***/
{
  if (stdoutstream == stream || stderrstream == stream) {
    numarray_hr_printer(x, stream);
    return;
  } else {
    struct numarraycell *dx = dr(x, numarraycell);
    unsigned int size = dx->bytes;        
    /* Content bytes */
    char *buff=(char *)dx;
    a_puts("#[NA ", stream);
    a_puts(IntegerToString(size), stream);
    a_puts("] ", stream);
    a_writebytes(stream, (void *)buff, size);
    a_putc(' ', stream); /* delimiter */
    return;
  }
}

oidtype bulkread_numarray(bindtype env, oidtype tag, oidtype x,
			  oidtype stream) {
  int bytes;
  oidtype res, size = hd(x);
  struct numarraycell *dres;
  char *buff;
  objtags tags;
	
  IntoInteger(size, bytes, env); // Total size in bytes
  res = new_aligned_object(bytes, NUMARRAYTYPE);
  dres = dr(res, numarraycell);
  tags = dres->tags;
  buff = (char *)dres;
  a_getc(stream); // Skip space after ]
  a_readbytes(stream, buff, bytes);
  a_getc(stream); // Skip space after binary
  dres = dr(res, numarraycell);
  dres->tags = tags; // Restore initialized tags
  return res;
}

void numarray_hr_printer(oidtype o, oidtype str) {
  int i, numelems, kind;
  struct numarraycell *dres;

  a_puts("{", str);

  dres = dr(o, numarraycell);
  numelems = dres->numelems;
  kind = dres->kind;

  if (numelems > 0) {
    switch(kind) {
    case 0:
      {
	int* ie;
	for (i = 0; i < numelems - 1; i++) {
	  dres = dr(o, numarraycell);
	  ie = (int*)dres->cont;
	  a_puts(IntegerToString(ie[i]), str);
	  a_puts(", ", str);
	}
	dres = dr(o, numarraycell);
	ie = (int*)dres->cont;
	a_puts(IntegerToString(ie[i]), str);
	break;
      }
    case 1:
      {
	double* de;
	for (i = 0; i < numelems - 1; i++) {
	  dres = dr(o, numarraycell);
	  de = (double*)dres->cont;
	  a_puts(a_stringify(mkreal(de[i])), str);
	  a_puts(", ", str);
	}
	dres = dr(o, numarraycell);
	de = (double*)dres->cont;
	a_puts(a_stringify(mkreal(de[i])), str);
	break;
      }
    case 2:
      {
	COMPLEX* ce;
	for (i = 0; i < numelems - 1; i++) {
	  dres = dr(o, numarraycell);
	  ce = (COMPLEX*)dres->cont;
	  a_puts(a_stringify(mkreal(ce[i].re)), str);
	  a_puts("+", str);
	  a_puts(a_stringify(mkreal(ce[i].im)), str);
	  a_puts("i, ", str);
	}
	dres = dr(o, numarraycell);
	ce = (COMPLEX*)dres->cont;
	a_puts(a_stringify(mkreal(ce[i].re)), str);
	a_puts("+", str);
	a_puts(a_stringify(mkreal(ce[i].im)), str);
	a_puts("i", str);
	break;
    case 3:
      {
	float* de;
	for (i = 0; i < numelems - 1; i++) {
	  dres = dr(o, numarraycell);
	  de = (float*)dres->cont;
	  a_puts(a_stringify(mkreal(de[i])), str);
	  a_puts(", ", str);
	}
	dres = dr(o, numarraycell);
	de = (float*)dres->cont;
	a_puts(a_stringify(mkreal(de[i])), str);
	break;
      }
      }
    default:
      break;
    }
  }
  a_puts("}", str);
  return;
}

oidtype type_of_numarrayfn(bindtype env, oidtype b) {
  /* Returns the subtype of numarray (as defined by kind) */
  struct numarraycell *dres;
  int kind;
  OfType(b, NUMARRAYTYPE, env);
  dres = dr(b, numarraycell);
  kind = dres->kind;
  switch(kind) {
  case 0:
    return globval(mksymbol("_iarray_"));
  case 1:
    return globval(mksymbol("_darray_"));
  case 2:
    return globval(mksymbol("_carray_"));
  case 3:
    return globval(mksymbol("_farray_"));
  default:
    return nil;
  }
}

EXPORT oidtype na_csv_float_readfn(bindtype env, oidtype str, oidtype delim)
{
  char *ddelim, cdelim, ch;
  oidtype stream, res;
  float realrow[MAXROW]; 
  char buff[FILEBUFFSIZE+2];
  int i=0, j=0;
  struct file_getch_state fs;

  stream = instream(str);
  if(delim==nil) cdelim=',';
  else
    {
      IntoString(delim, ddelim, env);
      cdelim = ddelim[0]; // list element delimiter
    }
  OfType(stream, STREAMTYPE, env);
  fs.fp = dr(stream,streamcell)->fp;
  fs.pos = FILEBUFFSIZE;
  for(;;)
    {
      ch = a_file_getch(&fs);
      if(ch==EOF) 
	{ 
	  if(i==0) return eofsymbol;
	  else break;
	}
      if(ch==' ') goto nxt; // skip spaces
      else if(ch=='\n') break; 
      else if(ch==cdelim) 
	{
          realrow[i++] = 0.0; // empty element
        }
      else if(ch=='"') 
        {
          j=0;
          for(;;)
	    {
	      ch = a_file_getch(&fs);
	      if(ch=='"') 
		{ 
                  unsigned int ch2=ch;

		  ch = a_file_getch(&fs);
		  if(ch=='"') // "" -> "
		    {
		      buff[j++] = '"';
		    }
		  else if((ch==cdelim)|(ch=='\n')|(ch==EOF)) goto addelem;
		  else // " followed by non-delimiter
                    {
                      buff[j++] = ch2;
                      buff[j++] = ch;
		    }
		}
	      else
                {
		  buff[j++] = ch;
		}
              if(j>=FILEBUFFSIZE) 
		return lerror(buffer_overflow, mkinteger(i), env);
	    }
	  a_assert(!"Shouldn't happen");
        }
      else // non-delimiter
        {
          buff[0] = ch;
          j = 1;
	  for(;;)
	    {
              ch = a_file_getch(&fs);
              if((ch==cdelim)|(ch=='\n')|(ch==EOF)) goto addelem;
              buff[j++] = ch;
	      if(j>=FILEBUFFSIZE) 
		return lerror(buffer_overflow, mkinteger(i), env);
            }
          a_assert(!"Shouldn't happen!");
	}
      goto nxt;
    addelem: 
      while(buff[j-1]==' ')j--;
      buff[j++] = '\0';
      realrow[i] = (float)atof(buff);
      i++;
      if(i>=MAXROW) return lerror(row_too_long, mkinteger(i), env);
      if((ch=='\n')|(ch==EOF)) break;
    nxt: ;
    }
  if(i==0) return nil;
  res = make_numarray(i, sizeof(float), 3);
  memcpy(dr(res,numarraycell)->cont, realrow, i*sizeof(*realrow));
  return res;
}

EXPORT oidtype na_csv_double_readfn(bindtype env, oidtype str, oidtype delim)
{
  char *ddelim, cdelim, ch;
  oidtype stream, res;
  double realrow[MAXROW]; 
  char buff[FILEBUFFSIZE+2];
  int i=0, j=0;
  struct file_getch_state fs;

  stream = instream(str);
  if(delim==nil) cdelim=',';
  else
    {
      IntoString(delim, ddelim, env);
      cdelim = ddelim[0]; // list element delimiter
    }
  OfType(stream, STREAMTYPE, env);
  fs.fp = dr(stream,streamcell)->fp;
  fs.pos = FILEBUFFSIZE;
  for(;;)
    {
      ch = a_file_getch(&fs);
      if(ch==EOF) 
	{ 
	  if(i==0) return eofsymbol;
	  else break;
	}
      if(ch==' ') goto nxt; // skip spaces
      else if(ch=='\n') break; 
      else if(ch==cdelim) 
	{
          realrow[i++] = 0.0; // empty element
        }
      else if(ch=='"') 
        {
          j=0;
          for(;;)
	    {
	      ch = a_file_getch(&fs);
	      if(ch=='"') 
		{ 
                  unsigned int ch2=ch;

		  ch = a_file_getch(&fs);
		  if(ch=='"') // "" -> "
		    {
		      buff[j++] = '"';
		    }
		  else if((ch==cdelim)|(ch=='\n')|(ch==EOF)) goto addelem;
		  else // " followed by non-delimiter
                    {
                      buff[j++] = ch2;
                      buff[j++] = ch;
		    }
		}
	      else
                {
		  buff[j++] = ch;
		}
              if(j>=FILEBUFFSIZE) 
		return lerror(buffer_overflow, mkinteger(i), env);
	    }
	  a_assert(!"Shouldn't happen");
        }
      else // non-delimiter
        {
          buff[0] = ch;
          j = 1;
	  for(;;)
	    {
              ch = a_file_getch(&fs);
              if((ch==cdelim)|(ch=='\n')|(ch==EOF)) goto addelem;
              buff[j++] = ch;
	      if(j>=FILEBUFFSIZE) 
		return lerror(buffer_overflow, mkinteger(i), env);
            }
          a_assert(!"Shouldn't happen!");
	}
      goto nxt;
    addelem: 
      while(buff[j-1]==' ')j--;
      buff[j++] = '\0';
      realrow[i] = atof(buff);
      i++;
      if(i>=MAXROW) return lerror(row_too_long, mkinteger(i), env);
      if((ch=='\n')|(ch==EOF)) break;
    nxt: ;
    }
  if(i==0) return nil;
  res = make_numarray(i, sizeof(double), 1);
  memcpy(dr(res,numarraycell)->cont, realrow, i*sizeof(*realrow));
  return res;
}

oidtype na_csv_printfn(bindtype env, oidtype o, oidtype stream, oidtype delim)
{
  register int i;
  register struct numarraycell *dres;
  oidtype str;
  char *ddelim, cdelim;
  char buff[20], row[1000];
  size_t len;
  register size_t pos;

  OfType(o, NUMARRAYTYPE, env);
  dres = dr(o,numarraycell);
  str = outstream(env,stream);
  if(delim==nil) cdelim=',';
  else
    {
      IntoString(delim, ddelim, env);
      cdelim = ddelim[0]; // list element delimiter
    }
  pos = 0;
  add_CSV_times(str);
  switch(dres->kind) 
    {
    case 0:
      {
	int* ie = (int*)dres->cont;; 

	for (i = 0; i < dres->numelems; i++) 
	  {
	    if(i>0) row[pos++] = cdelim;
            sprintf(buff,"%d",ie[i]);
            len = strlen(buff);
            memcpy(row+pos, buff, len);
            pos = pos + len;
	  }
	break;
      }
    case 1:
      {
        register double *de = (double*)dres->cont;

	for (i = 0; i < dres->numelems; i++) 
	  {
	    if(i>0) row[pos++] = cdelim;
            if(*de==0.0)
	      {
		row[pos++] = '0';
	      }
            else
              {
		//	    sprintf(buff,"%.15G",*de);
		sprintf(buff,"%g",*de);
		len = strlen(buff);
		memcpy(row+pos, buff, len);
		pos = pos + len;
              }
            de++;
	  }
	break;
      }
    case 3:
      {
	register float *de = (float*)dres->cont;

	for (i = 0; i < dres->numelems; i++) 
	  {
	    if(i>0) row[pos++] = cdelim;
	    if(*de==0.0) row[pos++] = '0';
	    else
	      {
		//	    sprintf(buff,"%.15G",*de);
		sprintf(buff,"%g",*de);
		len = strlen(buff);
		memcpy(row+pos, buff, len);
		pos = pos + len;
	      }
	    de++;
	  }
	break;
      }
    default:
      return lerror(ILLEGAL_ARGUMENT, o, env);
    }
  row[pos++] = '\n';
  row[pos++] = '\0';
  a_puts(row,str);
  return o;
}

oidtype numarray_sizefn(bindtype env, oidtype b) {
  struct numarraycell *db;
	
  OfType(b, NUMARRAYTYPE, env);
  db = dr(b, numarraycell);
  return mkinteger(numarray_size(db));
}

void dealloc_numarray(oidtype array) {
  dealloc_aligned_object(array);
}

oidtype numarray_dimfn(bindtype env, oidtype b) {
  struct numarraycell *dres;
  OfType(b, NUMARRAYTYPE, env);
  dres = dr(b, numarraycell);
  return mkinteger(dres->numelems);
}

oidtype a_numvrefbbf(a_callcontext cxt) {
  struct numarraycell *dx;
  oidtype x, ind, res;
  int i;

  x = a_arg(cxt, 1);
  ind = a_arg(cxt, 2);
  IntoInteger(ind, i, a_env(cxt));
  OfType(x, NUMARRAYTYPE, a_env(cxt));

  dx = dr(x, numarraycell);
  if (i >= dx->numelems || i<0) return nil;
#ifdef DEBUG
  printf("a_numvrefbbf: %d\n", i);
#endif

  switch(dx->kind) {
  case 0:
    res = mkinteger(dx->cont[i]);
    break;
  case 1:
    {
      double *c = (double*)dx->cont;
      res = mkreal(c[i]);        
      break;
    }
  case 2:
    {
      COMPLEX *c=(COMPLEX *)dx->cont;
      res = new_complex((float)c[i].re, (float)c[i].im);
      break;
    }
  case 3:
    {
      float *c = (float*)dx->cont;
      res = mkreal(c[i]);        
      break;
    }
  default:
    return nil;
  }
  a_bind(cxt, 3, res);
  a_result(cxt);
  return nil;
}

oidtype naeltfn(bindtype env, oidtype array, oidtype index) {
  struct numarraycell *dx;
  int i = getinteger(index);
	
  OfType(array, NUMARRAYTYPE, env);
  dx = dr(array, numarraycell);
  if (i >= dx->numelems || i<0) return nil;
  switch(dx->kind) {
  case 0:
    return mkinteger(dx->cont[i]);
    break;
  case 1:
    {
      double *c = (double*)dx->cont;
      return mkreal(c[i]);        
      break;
    }
  case 2:
    {
      COMPLEX *c=(COMPLEX *)dx->cont;
      return new_complex((float)c[i].re, (float)c[i].im);
      break;
    }
  case 3:
    {
      float *c = (float*)dx->cont;
      return mkreal(c[i]);        
      break;
    }
  default:
    return nil;
  }
  return nil;
}

oidtype naselt(bindtype env, oidtype array, oidtype index) {
	if (nil == array)
		return nil;
	return naeltfn(env, array, index);
}

int namin(int* indexes, oidtype tplv, int att) {
  int i, n, mindex, count = 0;
  struct numarraycell *dx;
  n = a_arraysize(tplv);

  for (i = 0; i < n; i++) {
    indexes[i] = 0;
  }
  // One pass to find a comparable (non-nil) value
  for (mindex = 0; mindex < n; mindex++) {
    if (nil != a_elt(tplv, mindex)) {
      break;
    }
  }

  if (mindex == n) // Give up
    return -1;

  dx = dr(a_elt(tplv, mindex), numarraycell);

  switch(dx->kind) {
  case 0:
    {
      int minval = ((int*)dx->cont)[att];
      for (i = mindex + 1; i < n; i++) {
	oidtype tpl = a_elt(tplv, i);
	if (nil != tpl) {
	  dx = dr(tpl, numarraycell);
	  if (((int*)dx->cont)[att] < minval) {
	    minval = ((int*)dx->cont)[att];
	    mindex = i;
	  }
	}
      }
      for (i = 0; i < n; i++) {
	oidtype tpl = a_elt(tplv, i);
	if (nil != tpl) {
	  dx = dr(tpl, numarraycell);
	  if (((int*)dx->cont)[att] == minval) {
	    indexes[i] = 1;
	    count++;
	  }
	}
      }
#ifdef DEBUG
      for (i = 0; i < n; i++) {
	printf("%d", indexes[i]);
      }
      printf(" ");
#endif
      break;
    }
  case 1:
    {
      double minval = ((double*)dx->cont)[att];
      for (i = mindex + 1; i < n; i++) {
	oidtype tpl = a_elt(tplv, i);
	if (nil != tpl) {
	  dx = dr(tpl, numarraycell);
	  if (((double*)dx->cont)[att] < minval) {
	    minval = ((double*)dx->cont)[att];
	    mindex = i;
	  }
	}
      }
      for (i = 0; i < n; i++) {
	oidtype tpl = a_elt(tplv, i);
	if (nil != tpl) {
	  dx = dr(tpl, numarraycell);
	  if (((double*)dx->cont)[att] == minval) {
	    indexes[i] = 1;
	    count++;
	  }
	}
      }
      break;
    }
  case 2:
    {
      a_error(NUMNOTIMP_ERROR, tplv, FALSE);
      break;
    }
  case 3:
    {
      float minval = ((float*)dx->cont)[att];
      for (i = mindex + 1; i < n; i++) {
	oidtype tpl = a_elt(tplv, i);
	if (nil != tpl) {
	  dx = dr(tpl, numarraycell);
	  if (((float*)dx->cont)[att] < minval) {
	    minval = ((float*)dx->cont)[att];
	    mindex = i;
	  }
	}
      }
      for (i = 0; i < n; i++) {
	oidtype tpl = a_elt(tplv, i);
	if (nil != tpl) {
	  dx = dr(tpl, numarraycell);
	  if (((float*)dx->cont)[att] == minval) {
	    indexes[i] = 1;
	    count++;
	  }
	}
      }
      break;
    }
  }
  return count;
}

oidtype nasetafn(bindtype env, oidtype array, oidtype index, oidtype val) {
  struct numarraycell *dx;
  int i = getinteger(index), kind;
  OfType(array, NUMARRAYTYPE, env);
  dx = dr(array, numarraycell);
  kind = dx->kind;
  if (i >= dx->numelems || i<0) return nil;
  switch(kind) {
  case 0:
    {
      int naval = getinteger(val);
      dx->cont[i] = naval;
      return array;
      break;
    }
  case 1:
    {		
      double naval = (integerp(val))? getinteger(val) : getreal(val);
      double *c = (double*)dx->cont;
      c[i] = naval;
      return array;
      break;
    }
  case 2:
    {
      COMPLEX *c=(COMPLEX *)dx->cont;
      a_error(NUMNOTIMP_ERROR, val, FALSE);
      break;
    }
  case 3:
    {		
      float naval = (integerp(val))? getinteger(val) : getreal(val);
      float *c = (float*)dx->cont;
      c[i] = naval;
      return array;
      break;
    }
  default:
    return nil;
  }
  return nil;
}

oidtype nasmashfn(bindtype env, oidtype array, oidtype index, oidtype val) {
  struct numarraycell *dres, *dv;
  int i, sz;
  OfType(array, NUMARRAYTYPE, env);
  OfType(val, NUMARRAYTYPE, env);
	OfType(index, INTEGERTYPE, env);
  dres = dr(array, numarraycell);
	dv = dr(val, numarraycell);
	if (dres->kind != dv->kind) {
    return lerror(NUMTMISMATCH_ERROR, val, env);
	}

	i = getinteger(index);
	if (dv->numelems + i > dres->numelems || i < 0) return nil;
  switch(dres->kind) {
  case 0:
    sz = sizeof(int);
    break;
  case 1:
    sz = sizeof(double);
    break;
  case 2:
    sz = sizeof(COMPLEX);
    break;
  case 3:
    sz = sizeof(float);
    break;
  default:
    lerror(NUMUNKNOWN_ERROR, array, env);
    break;
  }
  memcpy(dres->cont + (i * sz / sizeof(int)), dv->cont, dv->numelems * sz);
  return array;
}


oidtype naprojectfn(bindtype env, oidtype x, oidtype begin, oidtype size) {
  struct numarraycell *dx, *dres;
  oidtype res = nil;
  int kind, b, s;
  size_t sz;
  OfType(x, NUMARRAYTYPE, env);
  OfType(begin, INTEGERTYPE, env);
  OfType(size, INTEGERTYPE, env);
  dx = dr(x, numarraycell);
  b = getinteger(begin);
  s = getinteger(size);
  if (b + s > dx->numelems || b < 0) return nil;
  kind = dx->kind;
  sz = numarray_elemsize(kind);
  a_setf(res, make_numarray(s, sz, kind));
  dx = dr(x, numarraycell);
  dres = dr(res, numarraycell);
  memcpy(dres->cont, dx->cont + b*sz/sizeof(int), s * sz);
  dres->kind = dx->kind;
  a_return(res);
}

oidtype enumerate_numarrayfn(bindtype env, oidtype array, oidtype index) {
  struct numarraycell *dx;
	oidtype ret = nil;
	int i = getinteger(index), kind;
  OfType(array, NUMARRAYTYPE, env);

	a_setf(ret, numarry_copyfn(env, array, nil));

  dx = dr(ret, numarraycell);
  kind = dx->kind;
  if (i >= dx->numelems || i < 0) return nil;
  switch(kind) {
  case 0:
    {
      dx->cont[i] = nannotator;
			nannotator++;
      a_return(ret);
      break;
    }
	default:
		{
      a_error(NUMNOTIMP_ERROR, array, FALSE);
		}
	}
	return nil;
}

oidtype na_enum_resetfn(bindtype env, oidtype num) {
	nannotator = getinteger(num);
	return t;
}

void a_numvrefbff(a_callcontext cxt, a_tuple params) {
  struct numarraycell *dx;
  oidtype x, res;
  int i;
  x = a_getobjectelem(params, 0, FALSE);
	
  if (a_datatype(x) != NUMARRAYTYPE) {
    a_error(ILLEGAL_ARGUMENT, x, FALSE);
  }
  dx = dr(x, numarraycell);

  switch(dx->kind) {
  case 0:
    for (i=0; i<dx->numelems; i++) {
      res = mkinteger(dx->cont[i]);
      a_setobjectelem(params, 1, res, FALSE);
      a_emit(cxt, params, FALSE);
    }
    break;
  case 1:
    {
      double *c = (double*)dx->cont;
      for (i=0; i<dx->numelems; i++) {
	a_setobjectelem(params, 2, mkreal(c[i]), FALSE);
	a_emit(cxt, params, FALSE);
      }
      break;
    }
  case 2:
    {
      COMPLEX *c=(COMPLEX *)dx->cont;
      for (i=0; i<dx->numelems; i++) {
	res = new_complex((float)c[i].re, (float)c[i].im);
	a_setobjectelem(params, 2, res, FALSE);
	a_emit(cxt, params, FALSE);
      }
      break;
    }
  case 3:
    {
      float *c = (float*)dx->cont;
      for (i=0; i<dx->numelems; i++) {
	a_setobjectelem(params, 2, mkreal(c[i]), FALSE);
	a_emit(cxt, params, FALSE);
      }
      break;
    }
  default:
    return;
  }
}

void a_numoddevenbbbf(a_callcontext cxt, a_tuple params) {
  struct numarraycell *dx, *dr;
  oidtype x, res;
  int i, pos, stride, newlen;
  x   = a_getobjectelem(params, 0, FALSE);
  pos    = a_getintelem(params, 1, FALSE);
  stride = a_getintelem(params, 2, FALSE);
	
  /*
    if (a_datatype(x) != NUMARRAYTYPE) {
    a_error(ILLEGAL_ARGUMENT, x, FALSE);
    }*/
  if(pos>=stride) {
    printf("pos>=stride\n");
    return;
  }

  dx = dr(x, numarraycell);
  newlen = dx->numelems/stride;

  switch(dx->kind) {
  case 0:
    {
      int *ie, *ir;
      res = make_iarrayfn(cxt->env, mkinteger(newlen));
      dr = dr(res, numarraycell);
      ie = dx->cont;
      ir = dr->cont;
      for (i=0; i<dr->numelems; i++) {
	ir[i] = ie[i*stride+pos];
      }
    }
    break;
  case 1:
    {
      double *ie, *ir;
      res = make_darrayfn(cxt->env, mkinteger(newlen));
      dr = dr(res, numarraycell);
      ie = (double*)dx->cont;
      ir = (double*)dr->cont;
      for (i=0; i<dr->numelems; i++) {
	ir[i] = ie[i*stride+pos];
      }
    }
    break;
  case 2:
    {
      COMPLEX *ie, *ir;
      res = make_carrayfn(cxt->env, mkinteger(newlen));
      dr = dr(res, numarraycell);
      ie = (COMPLEX*)dx->cont;
      ir = (COMPLEX*)dr->cont;
      for (i=0; i<dr->numelems; i++) {
	ir[i].re = ie[i*stride+pos].re;
	ir[i].im = ie[i*stride+pos].im;
      }
    }
    break;
  case 3:
    {
      float *ie, *ir;
      res = make_darrayfn(cxt->env, mkinteger(newlen));
      dr = dr(res, numarraycell);
      ie = (float*)dx->cont;
      ir = (float*)dr->cont;
      for (i=0; i<dr->numelems; i++) {
	ir[i] = ie[i*stride+pos];
      }
    }
    break;
  default:
    return;
  }
  a_setobjectelem(params, 3, res, FALSE);
  a_emit(cxt, params, FALSE);
}

void a_namaxbf(a_callcontext cxt, a_tuple params) {
	struct numarraycell *dx;
  oidtype x, resl;
  double res =.0, *de;
  float *fe;
  int i, *ie;
  COMPLEX *ce;
  x = a_getobjectelem(params, 0, FALSE);

  if (a_datatype(x) != NUMARRAYTYPE) {
    a_error(ILLEGAL_ARGUMENT, x, FALSE);
  }
  dx = dr(x, numarraycell);

  switch(dx->kind) {
  case 0:
    ie = (int*)dx->cont;
		res = ie[0];
    for (i=0; i<dx->numelems; i++) {
      res = max(res, ie[i]);
    }
    resl = mkreal(res);
    break;
  case 1:
    de = (double*)dx->cont;
		res = de[0];
    for (i=0; i<dx->numelems; i++) {
      res = max(res, de[i]);
    }
    resl = mkreal(res);
    break;
  case 2:
    ce = (COMPLEX*)dx->cont;
		res = sqrt(fabs(ce[0].im) + fabs(ce[0].re));
    for (i=0; i<dx->numelems; i++) {
      res += max(res, sqrt(fabs(ce[i].im) + fabs(ce[i].re)));
    }
    resl = mkreal(res);
    break;
  case 3:
    fe = (float*)dx->cont;
		res = fe[0];
    for (i=0; i<dx->numelems; i++) {
      res = max(res, fe[i]);
    }
    resl = mkreal(res);
    break;
  default:
    resl = nil;
    return;
  }
  a_setobjectelem(params, 1, resl, FALSE);
  a_emit(cxt, params, FALSE);
}


void a_enormbf(a_callcontext cxt, a_tuple params) {
  struct numarraycell *dx;
  oidtype x, resl;
  double res =.0, *de;
  float *fe;
  int i, *ie;
  COMPLEX *ce;
  x = a_getobjectelem(params, 0, FALSE);

  if (a_datatype(x) != NUMARRAYTYPE) {
    a_error(ILLEGAL_ARGUMENT, x, FALSE);
  }
  dx = dr(x, numarraycell);
	
  switch(dx->kind) {
  case 0:
    ie = (int*)dx->cont;
    for (i=0; i<dx->numelems; i++) {
      res += ie[i]*ie[i];
    }
    res = sqrt(res);
    resl = mkreal(res);
    break;
  case 1:
    de = (double*)dx->cont;
    for (i=0; i<dx->numelems; i++) {
      res += de[i]*de[i];
    }
    res = sqrt(res);
    resl = mkreal(res);
    break;
  case 2:
    ce = (COMPLEX*)dx->cont;
    for (i=0; i<dx->numelems; i++) {
      res += fabs(ce[i].im) + fabs(ce[i].re);
    }
    res = sqrt(res);
    resl = mkreal(res);
    break;
  case 3:
    fe = (float*)dx->cont;
    for (i=0; i<dx->numelems; i++) {
      res += fe[i]*fe[i];
    }
    res = sqrt(res);
    resl = mkreal(res);
    break;
  default:
    resl = nil;
    return;
  }
#ifdef DEBUG
  printf("enormbf: res = %d, resl = ", res);
  a_print(resl);
#endif
  a_setobjectelem(params, 1, resl, FALSE);
  a_emit(cxt, params, FALSE);
}

// odd and even are of the same size
void a_radix2combf(a_callcontext cxt, a_tuple params) {
  struct numarraycell *deven, *dodd, *dres;
  oidtype resl, v, odd, even;
  int i, len;
  COMPLEX *q, *t, *y;
  v = a_getobjectelem(params, 0, FALSE);
  even = a_elt(v, 0);
  odd  = a_elt(v, 1);
  if (a_datatype(even) != NUMARRAYTYPE) {
    a_error(ILLEGAL_ARGUMENT, even, FALSE);
  }
  deven = dr(even, numarraycell);
  dodd  = dr(odd, numarraycell);
  len = deven->numelems;
  W_init(2*len);
#ifdef DEBUG
  printf("== W ==\n");
  for(i=0; i<2*len;i++) {
    printf("%f + %fi\n", W_factors [i].re, W_factors[i].im);	
  }
#endif
  resl = make_carrayfn(cxt->env, mkinteger(2*len));
  dres = dr(resl, numarraycell);
  q = (COMPLEX*)deven->cont;
  t = (COMPLEX*)dodd->cont;
  y = (COMPLEX*)dres->cont;
  for (i=0; i<2*len; i++) {
    y[i].re = q[i%len].re;
    y[i].im = q[i%len].im;
    c_add_mul(y[i], W(2*len, i), t[i%len]);
  }
  for (i=0; i<2*len; i++) {
    c_conj (y[i]);
    c_realdiv (y[i], 2*len);
  }
#ifdef DEBUG
  printf("== Y ==\n");
  for (i=0; i<2*len; i++) {
    printf("%f + %fi\n", y[i].re, y[i].im);	
  }
#endif
  a_setobjectelem(params, 1, resl, FALSE);
  a_emit(cxt, params, FALSE);
}

void a_nascalarmulbbf(a_callcontext cxt, a_tuple params) {
  oidtype factor;
  double lambda;
  struct numarraycell *dx, *dr;
  oidtype x, res;
  int i;
  factor = a_getelem(params, 0, FALSE);
  if (a_datatype(factor) == INTEGERTYPE) {
    lambda = getinteger(factor);
  }	else {
    lambda = getreal(factor);
  }
  x      = a_getobjectelem(params, 1, FALSE);
  dx = dr(x, numarraycell);

  switch(dx->kind) {
  case 0:
    {
      int *ie, *ir;
      res = make_iarrayfn(cxt->env, mkinteger(dx->numelems));
      dr = dr(res, numarraycell);
      ie = dx->cont;
      ir = dr->cont;
      for (i=0; i<dr->numelems; i++) {
	ir[i] = (int)a_round(lambda*ie[i]);
      }
    }
    break;
  case 1:
    {
      double *ie, *ir;
      res = make_darrayfn(cxt->env, mkinteger(dx->numelems));
      dr = dr(res, numarraycell);
      ie = (double*)dx->cont;
      ir = (double*)dr->cont;
      for (i=0; i<dr->numelems; i++) {
	ir[i] = lambda*ie[i];
      }
    }
    break;
  case 2:
    {
      COMPLEX *ie, *ir;
      res = make_carrayfn(cxt->env, mkinteger(dx->numelems));
      dr = dr(res, numarraycell);
      ie = (COMPLEX*)dx->cont;
      ir = (COMPLEX*)dr->cont;
      for (i=0; i<dr->numelems; i++) {
	ir[i].re = lambda*ie[i].re;
	ir[i].im = lambda*ie[i].im;
      }
    }
    break;
  case 3:
    {
      float *ie, *ir;
      res = make_darrayfn(cxt->env, mkinteger(dx->numelems));
      dr = dr(res, numarraycell);
      ie = (float*)dx->cont;
      ir = (float*)dr->cont;
      for (i=0; i<dr->numelems; i++) {
	ir[i] = (float)lambda*ie[i];
      }
    }
    break;
  default:
    return;
  }
  a_setobjectelem(params, 2, res, FALSE);
  a_emit(cxt, params, FALSE);
}

void a_navplusbf(a_callcontext cxt, a_tuple params) {
  struct numarraycell *dx, *dr;
  oidtype v, x, res;
  int i, j, dim, numv;
  v  = a_getobjectelem(params, 0, FALSE);
  numv = a_arraysize(v);
  x = a_elt(v, 0);
  dx = dr(x, numarraycell);
  dim = dx->numelems;
  switch(dx->kind) {
  case 0:
    {
      int *ie, *ir;
      res = make_iarrayfn(cxt->env, mkinteger(dim));
      dr = dr(res, numarraycell);
      ir = dr->cont;
      for (j=0; j<numv; j++) {
	x = a_elt(v, j);
	dx = dr(x, numarraycell);
	ie = dx->cont;
	for (i=0; i<dim; i++) {
	  ir[i] += ie[i];
	}
      }
    }
    break;
  case 1:
    {
      double *ie, *ir;
      res = make_darrayfn(cxt->env, mkinteger(dim));
      dr = dr(res, numarraycell);
      ir = (double*)dr->cont;
      for (j=0; j<numv; j++) {
	x = a_elt(v, j);
	dx = dr(x, numarraycell);
	ie = (double*)dx->cont;
	for (i=0; i<dim; i++) {					
	  ir[i] += ie[i];
	}
      }
    }
    break;
  case 2:
    {
      COMPLEX *ie, *ir;
      res = make_carrayfn(cxt->env, mkinteger(dim));
      dr = dr(res, numarraycell);
      ir = (COMPLEX*)dr->cont;
      for (j=0; j<numv; j++) {
	x = a_elt(v, j);
	dx = dr(x, numarraycell);
	ie = (COMPLEX*)dx->cont;
	for (i=0; i<dr->numelems; i++) {
	  ir[i].re += ie[i].re;
	  ir[i].im += ie[i].im;
	}
#ifdef DEBUG
	printf("[ ");
	for (i=0; i<dr->numelems; i++) {
	  printf("(%f %f)", ir[i].re, ir[i].im);
	}
	printf(" ]\n");
#endif
      }
    }
    break;
  case 3:
    {
      float *ie, *ir;
      res = make_darrayfn(cxt->env, mkinteger(dim));
      dr = dr(res, numarraycell);
      ir = (float*)dr->cont;
      for (j=0; j<numv; j++) {
	x = a_elt(v, j);
	dx = dr(x, numarraycell);
	ie = (float*)dx->cont;
	for (i=0; i<dim; i++) {					
	  ir[i] += ie[i];
	}
      }
    }
    break;
  default:
    a_setobjectelem(params, 1, nil, FALSE);
    a_emit(cxt, params, FALSE);
    return;
  }
  a_setobjectelem(params, 1, res, FALSE);
  a_emit(cxt, params, FALSE);
}

int equal_numarrayfn(oidtype x, oidtype y) {
  int dim, i;
  struct numarraycell *dx, *dy;

  dx = dr(x, numarraycell);
  dy = dr(y, numarraycell);
  dim = (dx->numelems);
  if (dx->kind == dy->kind) {
    if (dim == (dy->numelems)) {
      for (i = 0; i < dim; i++) {
				if (dx->cont[i] != dy->cont[i]) {
					return FALSE;
				}
			}
			return TRUE;
    }
  }
  return FALSE;
}

oidtype numarray_absfn(a_callcontext cxt)
{
  struct numarraycell *darr, *dnewarr;
  oidtype arr, newarr;
  COMPLEX *c;
  double *d;
  int i;

  arr = a_arg(cxt, 1);
  darr = dr(arr, numarraycell);
  if (darr->kind != 2) // not complex?
    lerror(NUMTMISMATCH_ERROR, arr, cxt->env);

  newarr = make_darrayfn(cxt->env, mkinteger(darr->numelems));
  dnewarr = dr(newarr, numarraycell);
  c = (COMPLEX *) darr->cont;
  d = (double *) dnewarr->cont;

  for (i = 0; i < darr->numelems; ++i)
    d[i] = sqrt(c[i].re * c[i].re + c[i].im * c[i].im);

  a_bind(cxt, 2, newarr);
  a_result(cxt);

  return nil;
}

oidtype numarray_refn(a_callcontext cxt)
{
  struct numarraycell *darr, *dnewarr;
  oidtype arr, newarr;
  COMPLEX *c;
  double *d;
  int i;

  arr = a_arg(cxt, 1);
  darr = dr(arr, numarraycell);
  if (darr->kind != 2) // not complex?
    lerror(NUMTMISMATCH_ERROR, arr, cxt->env);

  newarr = make_darrayfn(cxt->env, mkinteger(darr->numelems));
  dnewarr = dr(newarr, numarraycell);
  c = (COMPLEX *) darr->cont;
  d = (double *) dnewarr->cont;

  for (i = 0; i < darr->numelems; ++i)
    d[i] = c[i].re;

  a_bind(cxt, 2, newarr);
  a_result(cxt);

  return nil;
}

oidtype numarray_imfn(a_callcontext cxt)
{
  struct numarraycell *darr, *dnewarr;
  oidtype arr, newarr;
  COMPLEX *c;
  double *d;
  int i;

  arr = a_arg(cxt, 1);
  darr = dr(arr, numarraycell);
  if (darr->kind != 2) // not complex?
    lerror(NUMTMISMATCH_ERROR, arr, cxt->env);

  newarr = make_darrayfn(cxt->env, mkinteger(darr->numelems));
  dnewarr = dr(newarr, numarraycell);
  c = (COMPLEX *) darr->cont;
  d = (double *) dnewarr->cont;

  for (i = 0; i < darr->numelems; ++i)
    d[i] = c[i].im;

  a_bind(cxt, 2, newarr);
  a_result(cxt);

  return nil;
}

// Numarray interleave function
oidtype numarray_ilfn(a_callcontext cxt)
{
  struct numarraycell *darr, *dnewarr;
  int offset;
  int multiple;
  int newsize;
  oidtype arr, newarr;
  COMPLEX *cin, *cout;
  double *din, *dout;
  float *fin, *fout;
  int *iin, *iout;
  int i;

  arr = a_arg(cxt, 1);
  darr = dr(arr, numarraycell);
  offset = getinteger(a_arg(cxt, 2));
  multiple = getinteger(a_arg(cxt, 3));

  if (offset < 0 || multiple < 1 || darr->numelems <= offset)
    newsize = 0; // Invalid numbers? Make empty numarray
  else
    newsize = (darr->numelems - offset) / multiple +
      ((darr->numelems - offset) % multiple? 1: 0);

  switch (darr->kind)
    {
    case 0:
      newarr = make_iarrayfn(cxt->env, mkinteger(newsize));
      dnewarr = dr(newarr, numarraycell);
      iin = (int *) darr->cont;
      iout = (int *) dnewarr->cont;
      for (i = 0; i < newsize; ++i)
	iout[i] = iin[offset + i * multiple];
      break;
    case 1:
      newarr = make_darrayfn(cxt->env, mkinteger(newsize));
      dnewarr = dr(newarr, numarraycell);
      din = (double *) darr->cont;
      dout = (double *) dnewarr->cont;
      for (i = 0; i < newsize; ++i)
	dout[i] = din[offset + i * multiple];
      break;
    case 2:
      newarr = make_carrayfn(cxt->env, mkinteger(newsize));
      dnewarr = dr(newarr, numarraycell);
      cin = (COMPLEX *) darr->cont;
      cout = (COMPLEX *) dnewarr->cont;
      for (i = 0; i < newsize; ++i)
	cout[i] = cin[offset + i * multiple];
      break;
    case 3:
      newarr = make_darrayfn(cxt->env, mkinteger(newsize));
      dnewarr = dr(newarr, numarraycell);
      fin = (float *) darr->cont;
      fout = (float *) dnewarr->cont;
      for (i = 0; i < newsize; ++i)
	fout[i] = fin[offset + i * multiple];
      break;
    default:
      return nil;
    }

  a_bind(cxt, 4, newarr);
  a_result(cxt);

  return nil;
}

#define hash_add(x, old) (old + old + old + x)

unsigned int numarray_hash(oidtype key) {
  int i, mx = 10;
  unsigned int sum = 0;
  int sz;
  struct numarraycell *arr = dr(key, numarraycell);
	
	sz = arr->bytes - 1;
  if(sz < mx)
		mx = sz;
  for(i = 0; i <= mx; i++) {
	  sum = hash_add(arr->cont[i], sum);
  }
  return sum;
}

void register_numarray(void) {
  extfunction1("numarray-size", numarray_sizefn);
  NUMARRAYTYPE = a_definetype("numarray", dealloc_numarray, NULL);
  typefns[NUMARRAYTYPE].printfn = bulkprint_numarray;
  typefns[NUMARRAYTYPE].equalfn = equal_numarrayfn;
  typefns[NUMARRAYTYPE].hashfn = numarray_hash;
  type_reader_function("NA", bulkread_numarray);
  type_reader_function("NUMARRAY", bulkread_numarray);
  NUMOOB_ERROR = a_register_error("Numarray index out of bounds");
  NUMNARR_ERROR = a_register_error("Argument is not an array");
  NUMDMIS_ERROR = a_register_error("Real-imaginary dimensionality mismatch");
  NUMNOTIMP_ERROR = a_register_error("Not implemented yet");
  NUMUNKNOWN_ERROR = a_register_error("Unknown numarray type");
  NUMTMISMATCH_ERROR = a_register_error("Numarray type mismatch");
  extfunction2("copy-numarray", numarry_copyfn);
  extfunction1("make-darray", make_darrayfn);
  extfunction1("make-carray", make_carrayfn);
  extfunction1("make-iarray", make_iarrayfn);
  extfunction1("make-farray", make_farrayfn);
  extfunction1("type-of-numarray", type_of_numarrayfn);
  extfunction1("dim-numarray", numarray_dimfn);
  extfunction1("init-iarray", init_iarrayfn);
  extfunction1("init-darray", init_darrayfn);
  extfunction1("init-ccarray", init_ccarrayfn);
  extfunction2("init-carray", init_carrayfn);
  extfunction1("init-farray", init_farrayfn);
  extfunction2("na-elt", naeltfn);
  extfunction3("na-seta", nasetafn); 
  extfunction3("na-smash", nasmashfn);
  extfunction3("na-project", naprojectfn);
  extfunction2("na-enum", enumerate_numarrayfn);
  extfunction1("na-enum-reset", na_enum_resetfn);
  extfunction2("na-csv-double-read", na_csv_double_readfn);
  extfunction2("na-csv-float-read", na_csv_float_readfn);
  extfunction3("na-csv-print", na_csv_printfn);
  a_extfunction("ENORMBF", a_enormbf);
  a_extimpl("NUMVREFBBF", a_numvrefbbf);
  a_extfunction("NUMVREFBFF", a_numvrefbff);
  a_extfunction("NUMODDEVENBBBF", a_numoddevenbbbf);
  a_extfunction("RADIX2COMBINEBF", a_radix2combf);
  a_extfunction("NASMULBBF", a_nascalarmulbbf);
  a_extfunction("NAVPLUSBF", a_navplusbf);
  a_extfunction("NAMAXBF", a_namaxbf);
  a_extimpl("numarray_abs-+", numarray_absfn);
  a_extimpl("numarray_re-+", numarray_refn);
  a_extimpl("numarray_im-+", numarray_imfn);
  a_extimpl("numarray_il-+", numarray_ilfn);
  nannotator = 0;
}
