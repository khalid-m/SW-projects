/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Lars Melander, UDBL
 * $RCSfile: init_vsq.c,v $
 * $Revision: 1.2 $ $Date: 2011/12/14 18:19:42 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Library for VSQ.
 *              "stopafter", amos function for running a stream a set amount
 *              of seconds.
 *              "sink", amos function for running a stream and discard
 *              the return values.
 * ===========================================================================
 * $Log: init_vsq.c,v $
 * Revision 1.2  2011/12/14 18:19:42  larme597
 * *** empty log message ***
 *
 * Revision 1.1  2011/11/02 13:29:05  larme597
 * *** empty log message ***
 *
 * Revision 1.2  2011/11/01 15:31:59  larme597
 * Added headers.
 *
 ****************************************************************************/

#include "vi.h"
#include <sys/timeb.h>
#include <time.h>
#include "fixstream.h"
#include "visualize.h"
#include "visualize_stream.h"
#include "strings.h"

struct stopaftervars
{
  struct _timeb starttime;
  int stoptime;
};

oidtype stopaftermapper(a_callcontext cxt, int arity, oidtype *restpl, void *xa)
{
  struct stopaftervars *vars = xa;
  struct _timeb stoptime;
  int i;

  _ftime(&stoptime);
  for (i = 0; i < arity; ++i)
    a_bind(cxt, 3 + i, restpl[i]);
  a_result(cxt);
  if (vars->starttime.time + vars->stoptime < stoptime.time)
    a_map_done(cxt, t);

  return nil;
}

oidtype stopafterfn(a_callcontext cxt)
{
  oidtype b = a_arg(cxt, 1);
  oidtype time = a_arg(cxt, 2);
  struct stopaftervars vars;

  IntoInteger(time, vars.stoptime, cxt->env);
  _ftime(&vars.starttime);

  {
    unwind_protect_begin;
    a_mapbag(cxt, b, stopaftermapper, &vars);
    unwind_protect_catch;
    unwind_protect_end;
  }

  return nil;
}

void init_vsq_functions()
{
  register_fixstream();
  register_visualize();
  register_visualize_stream();
  register_vi();
  a_extimpl("stopafter--+", stopafterfn);
}

int vsq_initialize(char *path, int catcherror)
{
  int error;

  if ((error = scsq_initialize(path, catcherror)) == 0)
    init_vsq_functions();

  return error;
}

int init_vsq(int argc, char **argv)
{
  int error = 0;

  a_default_image = "vsq.dmp";
  error = init_scsq(argc, argv);

  if (error == 0)
    {
      init_vsq_functions();
    }
  else
    printf("Amos initialization failed!\n");

  return error;
}
