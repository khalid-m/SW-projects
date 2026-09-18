#include <windows.h>
#include <sys/timeb.h>
#include <time.h>
#include "fixstream.h"
#include "visualize.h"
//#include "visualize_extract.h"
#include "strings.h"
#include "vi.h"

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

oidtype sinkmapper(a_callcontext cxt, int arity, oidtype *restpl, void *xa)
{
  return nil;
}

oidtype sinkfn(a_callcontext cxt)
{
  oidtype b = a_arg(cxt, 1);

  {
    unwind_protect_begin;
    a_mapbag(cxt, b, sinkmapper, NULL);
    unwind_protect_catch;
    unwind_protect_end;
  }

  return nil;
}

int main(int argc, char **argv)
{
  int error = 0;

  error = init_scsq(argc, argv);
  if (error == 0)
    {
      register_fixstream();
      register_visualize();
      //register_visualize_extract();
      register_strings();
      register_vi();
      a_extimpl("stopafter--+", stopafterfn);
      a_extimpl("sink-", sinkfn);

      amos_toploop("Amos");
    }
  else
    printf("Amos initialization failed!\n");

  return error;
}
