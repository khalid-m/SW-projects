/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Cheng Xu, Robert Kajic, UDBL
 * $RCSfile: swin.c,v $
 * $Revision: 1.6 $ $Date: 2010/07/06 18:10:38 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Stream windowing. 
 * ===========================================================================
 * $Log: swin.c,v $
 * Revision 1.6  2010/07/06 18:10:38  roka4241
 * Added 'new-window' flag to stream windows. Generalized istream and dstream to work on more types of windows. Added istream and dstream regression tests for tuple windows (should also add tests for time windows). Fixed bug which  sometimes caused one additional, errornous, window to be created when applying any windowing operator on a stream.
 *
 * Revision 1.5  2010/07/03 02:47:01  roka4241
 * Now using correct versions of extfunction. Wrote regress tests for stream group by and fixed some bugs. Refactored stream window datatype.
 *
 * Revision 1.4  2010/07/02 03:57:15  roka4241
 * Added flags field to stream window.
 *
 * Revision 1.3  2010/06/09 12:24:57  roka4241
 * *** empty log message ***
 *
 * Revision 1.2  2010/06/09 12:21:53  roka4241
 * Added headers to swin.[ch].
 *
 ****************************************************************************/

#include "alisp.h"   /* Include Lisp Interfaces */
#include "callout.h"
#include "swin.h"

int swintype;

/* new external function (however a_extimpl doesn't seem to register
   the function so that it is avialable to alisp */

oidtype make_swin2fn(a_callcontext cxt)
{
    int sizec, timec, flags;
	oidtype res = nil;
	struct swincell *drres;
    
    oidtype o_sizec = a_arg(cxt, 1);
    oidtype o_timec = a_arg(cxt, 2); 
    oidtype incre = a_arg(cxt, 3); 
    oidtype headl = a_arg(cxt, 4); 
    oidtype taill = a_arg(cxt, 5);
    oidtype o_flags = a_arg(cxt, 6);
    
    IntoInteger(o_sizec, sizec, a_env(cxt));
    IntoInteger(o_timec, timec, a_env(cxt));
    IntoInteger(o_flags, flags, a_env(cxt));    

	res = new_object(sizeof(struct swincell), swintype);
	drres = dr(res, swincell);

	drres->sizeCounter = sizec;
	drres->timeCounter = timec;
    drres->flags = flags;

	//OfType(headl, LISTTYPE, env);
	//OfType(taill, LISTTYPE, env);

	a_let(drres->incre, incre);
	a_let(drres->headl, headl);
	a_let(drres->taill, taill);

	return res;
}

oidtype make_swinfn(bindtype args, bindtype env)
{
    oidtype o_sizec = nthargval(args, 1);
    oidtype o_timec = nthargval(args, 2);
    oidtype incre = nthargval(args, 3);
    oidtype headl = nthargval(args, 4);
    oidtype taill = nthargval(args, 5);
    oidtype o_flags = nthargval(args, 6);
    
    int sizec = 0, timec = -1, flags = 0;
	oidtype res = nil;
	struct swincell *drres;
    
    if (a_datatype(o_sizec) == INTEGERTYPE)
        IntoInteger(o_sizec, sizec, env);
    if (a_datatype(o_timec) == INTEGERTYPE)
        IntoInteger(o_timec, timec, env);
    if (a_datatype(o_flags) == INTEGERTYPE)
        IntoInteger(o_flags, flags, env);    

	res = new_object(sizeof(struct swincell), swintype);
	drres = dr(res, swincell);

	drres->sizeCounter = sizec;
	drres->timeCounter = timec;
    drres->flags = flags;

	//OfType(headl, LISTTYPE, env);
	//OfType(taill, LISTTYPE, env);

	a_let(drres->incre, incre);
	a_let(drres->headl, headl);
	a_let(drres->taill, taill);

	return res;
}

void free_swin(oidtype swin)
{
	struct swincell *drres = dr(swin, swincell);

	a_free(drres->incre);
	a_free(drres->headl);
	a_free(drres->taill);

	dealloc_object(swin);
}

oidtype swin_getincrefn(bindtype env, oidtype swin)
{
	OfType(swin, swintype, env);

	return dr(swin, swincell)->incre;
}

oidtype swin_getheadlfn(bindtype env, oidtype swin)
{
	OfType(swin, swintype, env);

	return dr(swin, swincell)->headl;
}

oidtype swin_gettaillfn(bindtype env, oidtype swin)
{
	OfType(swin, swintype, env);

	return dr(swin, swincell)->taill;
}

oidtype swin_setincrefn(bindtype env, oidtype swin, oidtype incre)
{
	struct swincell *drres;

	OfType(swin, swintype, env);

	drres = dr(swin, swincell);

	a_setf(drres->incre, incre);

	return incre;
}

oidtype swin_setheadlfn(bindtype env, oidtype swin, oidtype head)
{
	struct swincell *drres;
	
	OfType(swin, swintype, env);
	
	drres = dr(swin, swincell);

	//OfType(head, LISTTYPE, env);

	a_setf(drres->headl, head);

	return head;
}

oidtype swin_settaillfn(bindtype env, oidtype swin, oidtype tail)
{
	struct swincell *drres;
	
	OfType(swin, swintype, env);
 
	drres = dr(swin, swincell);
	
	//OfType(tail, LISTTYPE, env);

	a_setf(drres->taill, tail);

	return tail;
}

oidtype swin_getsizeCounterfn(bindtype env, oidtype swin)
{
	OfType(swin, swintype, env);

	return mkinteger(dr(swin, swincell)->sizeCounter);
}

oidtype swin_gettimeCounterfn(bindtype env, oidtype swin)
{
	OfType(swin, swintype, env);

	return mkinteger(dr(swin, swincell)->timeCounter);
}

oidtype swin_increasesizefn(bindtype env, oidtype swin, oidtype c)
{
	int counter;
	struct swincell *drres;

	OfType(swin, swintype, env);
	IntoInteger(c, counter, env);

	drres = dr(swin, swincell);

	drres->sizeCounter += counter;

	return mkinteger(drres->sizeCounter);
}

oidtype swin_settimefn(bindtype env, oidtype swin, oidtype tc)
{
	int tcounter;
	struct swincell *drres;

	OfType(swin, swintype, env);
	IntoInteger(tc, tcounter, env);

	drres = dr(swin, swincell);

	drres->timeCounter = tcounter;

	return mkinteger(drres->timeCounter);
}

oidtype swin_set_flags(bindtype env, oidtype swin, oidtype o_flags)
{
	int flags;
	struct swincell *drres;

	OfType(swin, swintype, env);
	IntoInteger(o_flags, flags, env);

	drres = dr(swin, swincell);

	drres->flags = flags;

	return mkinteger(drres->flags);
}

oidtype swin_get_flags(bindtype env, oidtype swin)
{
	OfType(swin, swintype, env);

	return mkinteger(dr(swin, swincell)->flags);
}

void register_swincell(void)
{
	swintype = a_definetype("swin", free_swin, NULL);
	extfunctionn("make-swin-c", make_swinfn);
	extfunction1("swin-get-incre", swin_getincrefn);
	extfunction2("swin-set-incre", swin_setincrefn);
	extfunction1("swin-get-head", swin_getheadlfn);
	extfunction2("swin-set-head", swin_setheadlfn);
    extfunction1("swin-get-tail", swin_gettaillfn);
	extfunction2("swin-set-tail", swin_settaillfn);
	extfunction1("swin-get-sizec", swin_getsizeCounterfn);
	extfunction2("swin-inc-sizec", swin_increasesizefn);    
	extfunction1("swin-get-timec", swin_gettimeCounterfn);
	extfunction2("swin-set-timec", swin_settimefn);
    extfunction1("swin-get-flags", swin_get_flags);    
    extfunction2("swin-set-flags", swin_set_flags);
}

oidtype inwindowbf(a_callcontext cxt)
{
	oidtype swin = a_arg(cxt, 1);
	oidtype temp = nil;
	int i;
	struct swincell * drres;

	OfType(swin, swintype, a_env(cxt));

	drres = dr(swin, swincell);

	a_setf(temp, drres->headl);

	{
		unwind_protect_begin;
		for(i = 0; i < drres->sizeCounter; i++)
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

void register_swinfns(void)
{
	a_extimpl("swin-in", inwindowbf);
    a_extimpl("make-swin2", make_swin2fn);
}
