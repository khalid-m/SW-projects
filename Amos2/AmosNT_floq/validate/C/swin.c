/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Cheng Xu, UDBL
 * $RCSfile: swin.c,v $
 *
 * Description: data type window
 * ===========================================================================
 * $Log: swin.c,v $
 * Revision 1.16  2013/11/20 19:06:07  chexu484
 * bug when image moves.
 * need to check the dereference for all the code
 *
 * Revision 1.15  2013/10/31 21:06:55  chexu484
 * window-add in C
 *
 * Revision 1.14  2013/10/29 15:27:07  chexu484
 * I don't have time for log because I need a glass of milk now!
 *
 * Revision 1.13  2013/01/07 15:57:38  chexu484
 * memory leak fix
 *
 * Revision 1.12  2013/01/04 13:44:30  chexu484
 * *** empty log message ***
 *
 * Revision 1.11  2012/08/22 14:36:18  chexu484
 * new field for register a list of aggregation functions
 *
 * Revision 1.10  2012/08/02 12:29:17  chexu484
 * lisp function swin-size
 *
 * Revision 1.9  2012/05/22 11:48:49  chexu484
 * new function window2list and bug fix
 *
 * Revision 1.8  2012/02/29 15:25:15  chexu484
 * amos functions to get statistics directly from window
 *
 * Revision 1.7  2012/02/28 18:14:53  chexu484
 * sum also added to data type window.
 * now window has the following statistics:
 * 1. actual size
 * 2. logical size
 * 3. sum
 *
 * Revision 1.6  2012/01/03 16:22:22  chexu484
 * 1. added new validation function
 *    STREAM.FUNCTION.FUNCTION.FUNCTION.INTEGER.FUNCTION.NUMBER.RECORD_N_VALIDATE
 * 							->STREAM-(INTEGER,VECTOR)
 * 2. added regression test for data type window
 * 3. added regression test for validation functions
 *
 *
 ****************************************************************************/

#include "alisp.h"   /* Include Lisp Interfaces */
#include "callout.h"

struct swincell
{
  objtags tags;
  HEADFILLER;
  oidtype tp;
  int size;  // the actually number of tuples
  double logicsize;  // the time length of the window
  oidtype ts;  // the time stamp of the window
  oidtype agg;  // the aggreation
  oidtype extent;  // the extent
};
int swintype;

int WINDOW_INDX_OUT_OF_BOUND;

EXTERN oidtype tconcfn(bindtype env, oidtype hder, oidtype x);

oidtype make_swinfn(bindtype env, oidtype tp, oidtype size, oidtype logicsize, oidtype extent)
{
  oidtype res = nil;
  struct swincell *drres;
  int sz = 0;
  double logicsz = 0;

  res = new_object(sizeof(struct swincell), swintype);
  drres = dr(res, swincell);

  if (size != nil)
    sz = dr(size, integercell)->integer;

  if (logicsize != nil)
    IntoDouble(logicsize, logicsz, env);

  drres->size = sz;
  drres->logicsize = logicsz;

  drres->ts = nil;
  drres->agg = nil;
  a_let(drres->extent, extent);
  a_let(drres->tp, tp);

  return res;
}

void free_swin(oidtype swin)
{
  struct swincell *drres = dr(swin, swincell);

  a_free(drres->tp);
  a_free(drres->ts);
  a_free(drres->agg);
  a_free(drres->extent);

  dealloc_object(swin);
}

oidtype copy_swinfn(bindtype env, oidtype swin)
{
  oidtype res = nil;
  struct swincell * this;
  struct swincell * drres;

  OfType(swin, swintype, env);
  this = dr(swin, swincell);

  res = new_object(sizeof(struct swincell), swintype);
  drres = dr(res, swincell);

  a_let(drres->tp, this->tp);
  drres->size = this->size;
  drres->logicsize = this->logicsize;
  a_let(drres->ts, this->ts);
  a_let(drres->agg, this->agg);
  a_let(drres->extent, this->extent);

  return res;
}

/*******************************************************************/
/************* a set of get and set function ***********************/
/*******************************************************************/

oidtype swin_setterfn(bindtype env, oidtype swin, oidtype size, oidtype logicsize, oidtype extent)
{
  struct swincell * drres;

  OfType(swin, swintype, env);
  drres = dr(swin, swincell);

  drres->size = dr(size, integercell)->integer;
  IntoDouble(logicsize, drres->logicsize, env);
  //drres->logicsize = dr(logicsize, integercell)->integer;

  a_setf(drres->extent, extent);

  return nil;
}

oidtype swin_typefn(bindtype env, oidtype swin)
{
  struct swincell * drres;
  OfType(swin, swintype, env);
  drres = dr(swin, swincell);

  return drres->tp;
}

oidtype swin_extentfn(bindtype env, oidtype swin)
{
  struct swincell * drres;
  OfType(swin, swintype, env);
  drres = dr(swin, swincell);

  return drres->extent;
}
oidtype swin_setextentfn(bindtype env, oidtype swin, oidtype ext)
{
  struct swincell * drres;

  OfType(swin, swintype, env);
  drres = dr(swin, swincell);

  a_setf(drres->extent, ext);

  return nil;
}

oidtype swin_sizefn(bindtype env, oidtype swin)
{
  struct swincell * drres;
  
  OfType(swin, swintype, env);
  drres = dr(swin, swincell);

  return mkinteger(drres->size);

}
oidtype swin_setsizefn(bindtype env, oidtype swin, oidtype size)
{
  struct swincell * drres;

  OfType(swin, swintype, env);
  drres = dr(swin, swincell);

  drres->size = dr(size, integercell)->integer;

  return nil;
}

oidtype swin_logicsizefn(bindtype env, oidtype swin)
{
  struct swincell * drres;
  
  OfType(swin, swintype, env);
  drres = dr(swin, swincell);

  return mkreal(drres->logicsize);

}
oidtype swin_setlogicsizefn(bindtype env, oidtype swin, oidtype size)
{
  struct swincell * drres;

  OfType(swin, swintype, env);
  drres = dr(swin, swincell);

  IntoDouble(size, drres->logicsize, env);
  //drres->logicsize = dr(size, integercell)->integer;

  return nil;
}

oidtype swin_gettsfn(bindtype env, oidtype swin)
{
  struct swincell * drres;

  OfType(swin, swintype, env);
  drres = dr(swin, swincell);

  return drres->ts;
}
oidtype swin_settsfn(bindtype env, oidtype swin, oidtype ts)
{
  struct swincell *drres;

  OfType(swin, swintype, env);
  drres = dr(swin, swincell);

  a_setf(drres->ts, ts);
  return nil;
}

oidtype swin_getallaggsfn(bindtype env, oidtype swin)
{
  struct swincell * drres;

  OfType(swin, swintype, env);
  drres = dr(swin, swincell);

  return drres->agg;
}
oidtype swin_setallaggsfn(bindtype env, oidtype swin, oidtype agg)
{
  struct swincell *drres;

  OfType(swin, swintype, env);
  drres = dr(swin, swincell);

  a_setf(drres->agg, agg);
  return nil;
}
/* returns a list of:
   (name {innitfn addfn removefn value}) */
oidtype swin_getaggfn(bindtype env, oidtype swin, oidtype name)
{
  struct swincell * drres;
  oidtype agglist = nil;
  oidtype res = nil;

  OfType(swin, swintype, env);
  drres = dr(swin, swincell);

  a_setf(agglist, drres->agg);

  if(agglist == nil)
    {
      return nil;
    }
  else
    {
      a_setf(res, assocfn(env, name, agglist));
      a_free(agglist);
      a_return(res);
    }
}
/* add one aggregation function which is a list of:
   (name {innitfn addfn removefn value}) */
oidtype swin_addaggfn(bindtype env, oidtype swin, oidtype list)
{
  struct swincell * drres;
  oidtype agglist = nil;

  OfType(swin, swintype, env);
  drres = dr(swin, swincell);

  a_setf(agglist, drres->agg);
  a_setf(drres->agg, cons(list, agglist));
  a_free(agglist);

  return nil;
}

void register_swincell()
{
  swintype = a_definetype("swin", free_swin, NULL);
  extfunction4("make-swin", make_swinfn);
  extfunction1("copy-swin", copy_swinfn);
}


/*******************************************************************/
/****************** some window operator  **************************/
/*******************************************************************/

oidtype inwindowbf(a_callcontext cxt)
{
  oidtype swin = a_arg(cxt, 1);
  oidtype temp = nil;
  int i;
  struct swincell * drres;
  
  OfType(swin, swintype, a_env(cxt));
  
  drres = dr(swin, swincell);
  
  a_setf(temp, hd(drres->extent));
  
  {
    unwind_protect_begin;
    for(i = 0; i < dr(swin, swincell)->size; i++)
      {
	a_bind(cxt, 2, fhd(temp)); // use fhd instead of hd?
	a_result(cxt);
	a_setf(temp, ftl(temp));
      }
    unwind_protect_catch;
    a_free(temp);
    unwind_protect_end;
  }
  
  return nil;
}

oidtype wrefbbf(a_callcontext cxt)
{
  oidtype swin = a_arg(cxt, 1);
  oidtype ind = a_arg(cxt, 2);
  struct swincell * drres;
  oidtype temp = nil;

  int i, j;

  OfType(swin, swintype, a_env(cxt));
  drres = dr(swin, swincell);

  IntoInteger(ind, i, a_env(cxt));  // i is the index

  if ((i >= 0) && (i < drres->size))
    {
      a_setf(temp, hd(drres->extent));

      for (j = 0; j < i; j++)
	{
	  a_setf(temp, ftl(temp));
	}

      a_bind(cxt, 3, fhd(temp));
      a_result(cxt);

      a_free(temp);
    }
  else
    {
      a_error(WINDOW_INDX_OUT_OF_BOUND, ind, FALSE);
    }

  return nil;

}

oidtype wrefbff(a_callcontext cxt)
{
  oidtype swin = a_arg(cxt, 1);
  struct swincell * drres;
  oidtype temp = nil;

  int i;

  OfType(swin, swintype, a_env(cxt));
  drres = dr(swin, swincell);

  a_setf(temp, hd(drres->extent));
  
  {
    unwind_protect_begin;
    for(i = 0; i < drres->size; i++)
      {
	a_bind(cxt, 2, mkinteger(i));
	a_bind(cxt, 3, fhd(temp));
	a_result(cxt);
	a_setf(temp, ftl(temp));
      }
    unwind_protect_catch;
    a_free(temp);
    unwind_protect_end;
  }

  return nil;

}

oidtype windowcountbf(a_callcontext cxt)
{
  oidtype swin = a_arg(cxt, 1);
  struct swincell * drres;

  OfType(swin, swintype, a_env(cxt));
  drres = dr(swin, swincell);

  a_bind(cxt, 2, mkinteger(drres->size));
  a_result(cxt);

  return nil;
}

oidtype window2listfn(bindtype env, oidtype w)
{
  oidtype res = nil;

  struct swincell * dr;

  OfType(w, swintype, env);
  dr = dr(w, swincell);
  
  a_setf(res, dr->extent);

  a_return(res);

}

oidtype window2vectorfn(bindtype env, oidtype w)
{
  oidtype res = nil;
  
  struct swincell * dr;
  
  OfType(w, swintype, env);
  dr = dr(w, swincell);
  
  a_setf(res, listtoarrayfn(env, hd(dr->extent)));

  a_return(res);
}

/*******************************************************************/
/***************** window forming operator  ************************/
/*******************************************************************/

oidtype timefnMapper(a_callcontext cxt, int width, oidtype tpl[], void *xa)
{

  // NOTE: checking if tpl is null or not?
  if (tpl == NULL)
    a_map_done(cxt, nil);
  else
    a_map_done(cxt, tpl[0]);

  return nil;

}

oidtype list_swin_addfn(bindtype env, oidtype w, oidtype o, oidtype timefn)
{
  struct swincell * drres;

  OfType(w, swintype, env);
  drres = dr(w, swincell);

  tconcfn(env, drres->extent, o);  // add current object o
  drres->size++;  // increase the physical size

  // when the time function is provided
  if (timefn != nil)
    {

      oidtype start = nil, end = nil, first = nil, extent = nil;
      oidtype args[1];

      dcl_local_cxt(cxt, env);

      a_setf(extent, drres->extent);  // the extent of the window
      a_setf(first, hd(hd(extent)));  // the first element of the window

      {
	unwind_protect_begin;

	args[0] = first;
	start = a_mapfunctionC(cxt, timefn, 1, args, timefnMapper, NULL);

	args[0] = o;
	end = a_mapfunctionC(cxt, timefn, 1, args, timefnMapper, NULL);

	if (start != nil)
	  {
	    double startTime, endTime;
	    IntoDouble(start, startTime, env);
	    IntoDouble(end, endTime, env);
	    drres->logicsize = endTime - startTime;
	  }
	unwind_protect_catch;
	a_free(start);
	a_free(end);
	a_free(first);
	a_free(extent);
	unwind_protect_end;
      }
    }

  return w;
}



void register_swinfns()
{
  a_extimpl("inwindowbf", inwindowbf);
  a_extimpl("windowcountbf", windowcountbf);

  WINDOW_INDX_OUT_OF_BOUND = a_register_error("window index out of bound");

  a_extimpl("wrefbbf",wrefbbf);
  a_extimpl("wrefbff",wrefbff);


  extfunction4("swin-setter", swin_setterfn);

  extfunction1("window-type", swin_typefn);

  extfunction2("window-setextent", swin_setextentfn);
  extfunction1("window-extent", swin_extentfn);

  extfunction1("swin-size", swin_sizefn);
  extfunction2("set-phsize", swin_setsizefn);

  extfunction1("swin-logicsize", swin_logicsizefn);
  extfunction2("set-logicsize", swin_setlogicsizefn);

  extfunction2("swin-setts", swin_settsfn);
  extfunction1("swin-getts", swin_gettsfn);

  /* following functions are for aggregation incremental calculation */
  extfunction2("window-addagg", swin_addaggfn);  // register one aggregation
  extfunction2("window-getagg", swin_getaggfn);
  extfunction1("window-getallaggs", swin_getallaggsfn);
  extfunction2("window-setallaggs", swin_setallaggsfn);
  /* to do: should be possible to unregister the aggregation function */

  extfunction3("list-window-add", list_swin_addfn);
  
  extfunction1("window2vector", window2vectorfn);
  extfunction1("window2list", window2listfn);
}
