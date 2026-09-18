/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 2000 Tore Risch, UDBL
 *
 * Description:  Basic event handler
 * Language:     C
 ****************************************************************************/

#include "alisp.h"   /* Include Lisp interfaces */

int lisp_event_handler(bindtype env, oidtype tag, oidtype obj, oidtype arg,
                     oidtype old, oidtype nw)
{
   oidtype evfns, p, lres=nil;
   int res=FALSE;
   /* Pick up registered event functions to location evfns.
      Tag points to an 'eventtag' record (in storage.h) */
   a_let(evfns,dr(tag,eventtag)->eventfns);
   if(evfns==nil) return TRUE; /* No events registered */

   {unwind_protect_begin;  /* Must protect against exceptions in Lisp call */
      for(p=evfns;listp(p);p=ftl(p))
      {
         a_setf(lres,call_lisp(fhd(p),env,4,obj,arg,old,nw));
         if(lres!=nil) res = TRUE; /* If ANY event function non-NIL result 
                                       then add to log */
       }
    unwind_protect_catch;
      a_free(evfns); /* Release held locations */
      a_free(lres);
    unwind_protect_end;}
    return res;  /* Add to log if flg == TRUE and call to Lisp suceeded */
}

/*********************************
 * subscribe_eventfn
 * ===============
 * Foreign function for subscribing to an 'event'.
 * Registers the function 'subscriber' to be called when
 * the event is raised.
 *
 */
oidtype subscribe_eventfn(bindtype env, oidtype event, oidtype subscriber)
{
    OfType(event,eventtagtype,env);
    if(subscriber!=nil) a_setf(dr(event,eventtag)->eventfns,
                               cons(subscriber,dr(event,eventtag)->eventfns));
    return dr(event,eventtag)->eventfns;
}

/*********************************
 * unsubscribe_eventfn
 * ===============
 * Foreign function for unsubscribing to an 'event'.
 * Unregisters the function 'subscriber' from the event.
 *
 */
oidtype unsubscribe_eventfn(bindtype env, oidtype event, oidtype subscriber)
{
    OfType(event,eventtagtype,env);
    a_setf(dr(event,eventtag)->eventfns,
           deletefn(env, subscriber, dr(event,eventtag)->eventfns));
    return dr(event,eventtag)->eventfns;
}

void register_event_manager(void)
{
  raise_event = lisp_event_handler;
  extfunction2("subscribe-event", subscribe_eventfn);
  extfunction2("unsubscribe-event", unsubscribe_eventfn);
}


