#include "visualize.h"
#include "strings.h"
#include "vi.h"

DWORD WINAPI visualize_handler(void *arg)
{
  VI vi = arg;
  VISUALIZE visualize = vi->visualize;
  int current = 0;

  while (!barrier_wait(visualize->barrier))
    {
      if (visualize->arity == 1)
	visualize->next(&vi->ref, visualize->data[current][0], visualize->numelems[0]);
      else if (visualize->arity == 2)
	visualize->next2(&vi->ref, visualize->data[current][0], visualize->numelems[0], 
			 visualize->data[current][1], visualize->numelems[1]);
      else
	visualize->next3(&vi->ref, visualize->data[current][0], visualize->numelems[0], 
			 visualize->data[current][1], visualize->numelems[1], 
			 visualize->data[current][2], visualize->numelems[2]);
      current = 1 - current;
    }

  barrier_wait(visualize->endbarrier);

  return 0;
}

oidtype call_visualize_mapper(a_callcontext cxt, int arity, oidtype *restpl, void *xa)
{
  struct numarraycell *dx;
  VISUALIZE visualize;
  int i, memsize;
  double *memcount;

  visualize = xa;

  if (visualize->initialized == FALSE)
    {
      visualize->arity = arity;
      memsize = 0;

      for (i = 0; i < arity; ++i)
	{
	  dx = dr(restpl[i], numarraycell);
	  visualize->numelems[i] = dx->numelems;
	  memsize += dx->numelems;
	}

      for (i = 0; i < arity; ++i)
	{
	  dx = dr(restpl[i], numarraycell);
	  if (i == 0)
	    visualize->data[0][0] = memcount = malloc(2 * memsize * sizeof(double));
	  else
	    visualize->data[0][i] = memcount;
	  memcount += (dx->numelems * sizeof(double));
	  visualize->data[1][i] = memcount;
	  memcount += (dx->numelems * sizeof(double));
	}
      visualize->current = 0;
      visualize->initialized = TRUE;
    }

  for (i = 0; i < arity; ++i)
    {
      dx = dr(restpl[i], numarraycell);
      memcpy(visualize->data[visualize->current][i], dx->cont, dx->numelems * sizeof(double));
    }

  barrier_wait(visualize->barrier);
  visualize->current = 1 - visualize->current;

  return nil;
}

oidtype call_visualize(a_callcontext cxt)
{
  oidtype b;
  VISUALIZE visualize;
  oidtype vi_array, vi;
  VI dv;
  int i;

  visualize = a_extpredparam(cxt);
  visualize->initialized = FALSE;
  vi_array = a_arg(cxt, 1);
  b = a_arg(cxt, 2);

  barrier_init(visualize->barrier, 1 + a_arraysize(vi_array));
  
  for (i = 0; i < a_arraysize(vi_array); ++i)
    {
      vi = a_elt(vi_array, i);
      dv = dr(vi, vicell);
      dv->visualize = visualize;
      vi_openfn(vi);

      if ((visualize->thread_id = CreateThread(NULL, 0, visualize_handler,
					       (void *) dv, 0, NULL)) == NULL)
	{
	  printf("Error! No thread!\n");
	  barrier_close(visualize->barrier);
	  return nil;
	}
    }

  {
    unwind_protect_begin;
    a_mapbag(cxt, b, call_visualize_mapper, visualize);
    unwind_protect_catch;
    barrier_close(visualize->barrier);
    barrier_wait(visualize->endbarrier);
    for (i = 0; i < a_arraysize(vi_array); ++i)
      vi_closefn(a_elt(vi_array, i));
    free(visualize->data[0][0]);
    unwind_protect_end;
  }

  return nil;
}

oidtype bind_visualizefn(bindtype env, oidtype val)
{
  char *str, **names, *functionname, *dllname;
  int size;
  HMODULE lib;
  VISUALIZE visualize;

  IntoString(val, str, env);
  functionname = malloc(strlen(str) + 1);
  strcpy(functionname, str);

  size = explode(&names, functionname, ':');
  dllname = names[1];

  if ((lib = LoadLibrary(dllname)) == NULL)
    {
      printf("visualize dll failed to load: %s\n", dllname);
      return nil;
    }

  visualize = malloc(sizeof(t_visualize));

  if ((visualize->next = (t_visualize_next) GetProcAddress(lib, "next")) == NULL ||
      (visualize->next2 = (t_visualize_next2) GetProcAddress(lib, "next2")) == NULL ||
      (visualize->next3 = (t_visualize_next3) GetProcAddress(lib, "next3")) == NULL)
    {
      printf("Failed to locate a dll function\n");
      free(visualize);
      return nil;
    }

  visualize->barrier = barrier_create();
  visualize->endbarrier = barrier_create();
  a_extimpl(functionname, call_visualize);
  a_setpredparam(functionname, visualize);

  free(names);
  return t;
}

oidtype visualize_enabledfn(bindtype env)
{
  return t;
}

void register_visualize()
{
  extfunction0("visualize-enabled", visualize_enabledfn);
  extfunction1("bind-visualize", bind_visualizefn);
  a_register_enabled("visualize", "visualize-enabled");
  a_register_loader("visualize", "bind-visualize");
}
