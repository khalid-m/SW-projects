/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Cheng Xu, UDBL
 * $RCSfile: nbprint.c,v $
 * $Revision: 1.2 $ $Date: 2011/12/12 11:33:22 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Non-blocking read/print
 * ===========================================================================
 * $Log: nbprint.c,v $
 * Revision 1.2  2011/12/12 11:33:22  larme597
 * Tweaks and bugfixes.
 *
 * Revision 1.1  2011/04/01 09:12:36  chexu484
 * non blocking print/read
 *
 * Revision 1.4  2006/02/13 07:37:48  torer
 * delete this log text
 *
 ****************************************************************************/

#include "alisp.h"
#include "binary.h"
#include "comm.h"

#ifndef LREADHSIZE
#define LREADHSIZE 4
#endif

int form_too_big;

oidtype busysymbol;

oidtype nb_printfn(bindtype env, oidtype x, oidtype str)
{
  static oidtype pb=nil;
  oidtype pbuff;
  int sz = 0;

  if(pb==nil) pb = mksymbol("_nb-printbuff_");

  if(a_datatype(globval(pb))!=TEXTSTREAMTYPE)
    a_setf(globval(pb),new_textstream(PACKET_SIZE));

  pbuff = globval(pb);

  dr(pbuff, textstreamcell) -> pos = 0; 
  a_writebytes(pbuff, &sz, LREADHSIZE);

  dr(pbuff, textstreamcell) -> pos = LREADHSIZE;
  printfn(env, x, pbuff);

  sz = dr(pbuff, textstreamcell) -> pos - 1 - LREADHSIZE;  
  // the actually size without the header

  if (sz > PACKET_SIZE) 
    return lerror(form_too_big, x, env);

  dr(pbuff, textstreamcell) -> pos = 0;
  a_writebytes(pbuff, &sz, LREADHSIZE);

  if (EOF == a_writebytes(str, textstreambuffer(pbuff), sz + LREADHSIZE + 1))   // atomic write
    return busysymbol;
  else
    return x;
}

oidtype nb_readfn(bindtype env, oidtype str)
{
  int formsize = 0;
  oidtype res;
  int c;

  if (a_datatype(str) == sockettype)
    {
      if (socket_peekbytes(str, &formsize, LREADHSIZE))
	{
	  if (socket_inbytes(dr(str, socketcell)) >= formsize + LREADHSIZE)
	    {
	      a_readbytes(str, &formsize, LREADHSIZE);
	      return a_read(str);
	    }
	}
      return busysymbol;
    } else {
      a_readbytes(str, &formsize, LREADHSIZE);
      res = a_read(str);
	  c = a_getc(str); 
	  if(c != '\n') a_ungetc(c,str);
	  return res;
    }
}


void register_nbprint(void) 
{

  form_too_big = a_register_error("The form is too big for the stream");

  busysymbol = mksymbol("*busy*");
  extfunction2("nb-print", nb_printfn);
  extfunction1("nb-read", nb_readfn);
}
