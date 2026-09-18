/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2013 Tore Risch, UDBL
 * $RCSfile: CSV.c,v $
 * $Revision: 1.14 $ $Date: 2013/05/17 14:27:54 $
 * $State: Exp $ $Locker:  $
 *
 * Description: CSV reader
 * ===========================================================================
 * $Log: CSV.c,v $
 * Revision 1.14  2013/05/17 14:27:54  torer
 * Added CSV report time stamps
 *
 * Revision 1.13  2013/05/17 07:00:16  torer
 * Setting system time stamp after 1st char of CSV line read
 *
 * Revision 1.12  2013/04/13 08:19:20  torer
 * Exporting buffer_overflow and row_too_long
 *
 * Revision 1.11  2013/04/13 08:09:02  torer
 * Missing variables buffer_overflow, row_too_long
 *
 * Revision 1.10  2013/04/13 07:58:18  torer
 * Exporting read_csv_linefn()
 *
 * Revision 1.9  2013/04/12 06:36:32  torer
 * New function (NA-CSV-READ STREAM DELIM)
 *
 * Revision 1.8  2013/04/11 02:40:29  torer
 * Handling large integers
 *
 * Revision 1.7  2013/04/10 19:32:15  torer
 * Faster CSV reader
 *
 * Revision 1.6  2013/04/04 07:31:40  torer
 * Optional list delimiter for (WRITE-CSV-LINE VECTOR &optional STREAM DELIM)
 *
 * Revision 1.5  2013/04/04 05:43:52  torer
 * Reentrant fast CSV reader
 *
 * Revision 1.4  2013/04/03 20:34:17  torer
 * The CSV reader another 2.5 times faster
 *
 * Revision 1.3  2013/04/03 17:40:59  torer
 * CSV writer
 *
 * Revision 1.2  2013/03/27 19:51:02  torer
 * trailing spaces removed
 *
 * Revision 1.1  2013/03/27 16:18:36  torer
 * CSV reader now in C and following EXCEL's format
 * 2.63 times faster
 *
 ****************************************************************************/

#include "amos.h"
#include "systime.h"

EXPORT int buffer_overflow, row_too_long;
oidtype _report_CSV_times_;

EXPORT char a_file_getch(struct file_getch_state *f)
{
  if(f->pos > FILEBUFFSIZE) return EOF;
  if(f->pos == FILEBUFFSIZE) 
    {  
       if(fgets(f->buff, FILEBUFFSIZE, f->fp)==NULL) 
	 {
	   f->pos = FILEBUFFSIZE + 1;
           return EOF;
	 }
       f->pos = 0;
       a_set_systime(); // Set system time stamp after 1st char read
    }
  if(f->buff[f->pos] == '\n')
    {
      f->pos = FILEBUFFSIZE;
      return '\n';
    }
  if(f->buff[f->pos] == '\0')
    {
      f->pos = FILEBUFFSIZE + 1;
      return EOF;
    }
  return f->buff[(f->pos)++];
}

EXPORT oidtype read_csv_linefn(bindtype env, oidtype str, oidtype delim)
{
  char *ddelim, cdelim, ch;
  oidtype stream = instream(str), res;
  oidtype row[MAXROW]; 
  char buff[FILEBUFFSIZE+2];
  int i=0, j=0, firstc=FALSE;
  oidtype *acont;
  struct file_getch_state fs;

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
          row[i++] = nil; // empty element
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
      row[i] = a_encodeNumeric(buff);
      if(row[i]==NULLH) row[i] = mkstring(buff);
      i++;
      if(i>=MAXROW) return lerror(row_too_long, mkinteger(i), env);
      if((ch=='\n')|(ch==EOF)) break;
    nxt: ;
    }
  if(i==0) return nil;
  res = new_array(i,nil);
  acont = dr(res,arraycell)->cont;
  for(j=0; j<i; j++)
    a_let(acont[j],row[j]);
  return res;
}

#define EPOCH 1368797362
EXPORT void add_CSV_times(oidtype s)
{ 
  if(globval(_report_CSV_times_)!=nil)
    {
      char buffer[60];
      struct timeval now;
    
      sprintf(buffer, "%.15G,", a_enter_systime.tv_sec-EPOCH+
                             a_enter_systime.tv_usec/1000000.0);
      a_puts(buffer, s);
      gettimevalofday(&now);
      sprintf(buffer, "%.15G,", now.tv_sec-EPOCH+now.tv_usec/1000000.0);
      a_puts(buffer, s);
    }   
}
    
oidtype write_csv_linefn(bindtype env, oidtype vec, oidtype stream, 
                         oidtype delim)
{
  int i;
  size_t j;
  struct arraycell *dvec;
  char *str, *s1;
  oidtype s;
  char *ddelim, cdelim;

  if(delim==nil) cdelim=',';
  else
    {
      IntoString(delim, ddelim, env);
      cdelim = ddelim[0]; // list element delimiter
    }
  s = outstream(env,stream);
  OfType(vec, ARRAYTYPE, env);
  dvec = dr(vec,arraycell);
  add_CSV_times(s);
  for(i=0; i<dvec->size; i++)
    {
      if(i>0) a_putc(cdelim, s);
      dvec = dr(vec,arraycell);
      switch (a_datatype(dvec->cont[i]))
	{
	case STRINGTYPE:
	  str = getstring(dvec->cont[i]);
          s1 = alloca(1+strlen(str));
          strcpy(s1, str);
	  if(strchr(str,'"')==NULL)
            {
              a_putc('"', s);
              a_puts(s1, s);
              a_putc('"', s);
              break;
            }
          a_putc('"', s);
	  for(j=0; j<strlen(s1); j++)
	    {
	      if(s1[j] == '"')
		{ 
		  a_putc('"',s); 
		  a_putc('"',s); 
		}
	      else a_putc(s1[j], s);
	    }
          a_putc('"', s);
	  break;
	default: 
	  princfn(env, dvec->cont[i], s);
	  break;
	}
      dvec = dr(vec,arraycell);
    }
  a_putc('\n', s);
  return vec;
}

oidtype csv_file_tuplesBF(a_callcontext cxt)
{
  oidtype file = a_arg(cxt, 1);
  char *filename;
  oidtype str;

  IntoStackString(file, filename, cxt->env);
  str = a_fopen(filename, "r");
  {unwind_protect_begin;
  for(;;)
    {
      oidtype row = read_csv_linefn(cxt->env, str, nil);
      if(row==eofsymbol) break;
      if(row!=nil)
	{
	  a_bind(cxt,2,row);
	  a_result(cxt);
        }
    }
  unwind_protect_catch;
  a_fclose(str);
  unwind_protect_end;}
  return nil;
}

void register_csv(void)
{
  row_too_long = a_register_error("CSV row too long");
  buffer_overflow = a_register_error("CSV string too long");
  /* Put time stamps in front of CVS lines if true */
  _report_CSV_times_ = mksymbol("_report-CSV-times_");
  globval(_report_CSV_times_)=nil;
  extfunction2("read-csv-line", read_csv_linefn);
  extfunction3("write-csv-line", write_csv_linefn);

  a_extimpl("csv-file-tuples-+", csv_file_tuplesBF);
}
