/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Lars Melander, UDBL
 * $RCSfile: visualize.c,v $
 * $Revision: 1.4 $ $Date: 2011/12/14 18:19:43 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Wrapper for sending double numarrays to external 
 * visualization.
 * ===========================================================================
 * $Log: visualize.c,v $
 * Revision 1.4  2011/12/14 18:19:43  larme597
 * *** empty log message ***
 *
 * Revision 1.3  2011/11/05 11:47:00  larme597
 * Added reset functionality to virtual instruments.
 *
 * Revision 1.2  2011/11/01 15:31:59  larme597
 * Added headers.
 *
 ****************************************************************************/

#include "visualize.h"
#include "strings.h"
#include "vi.h"
#include "vsq_labview.h"

void free_visualize(oidtype v)
{
  VISUALIZE dv = dr(v, visualizecell);

  barrier_close(dv->barrier);
  barrier_wait(dv->endbarrier);
  barrier_destroy(dv->barrier);
  barrier_destroy(dv->endbarrier);
  if (dv->data[0][0] != NULL)
    free(dv->data[0][0]);

  dealloc_object(v);
}

DWORD WINAPI visualize_handler(void *arg)
{
  oidtype vi = (oidtype) arg;
  VI dv;
  oidtype v = (oidtype) dr(vi, vicell)->vi_data;
  VISUALIZE visualize;
  int current = 0;
  int reset;
  t_visualize_next next;
  t_visualize_next2 next2;
  t_visualize_next3 next3;

  if (dr(vi, vicell)->vi_lib != NULL)
    {
      if ((next = (t_visualize_next) GetProcAddress(dr(vi, vicell)->vi_lib, "next")) == NULL)
	{
	  a_error(vierror, vi, TRUE);
	  printf("Failed to locate a dll function\n");
	  barrier_close(dr(v, visualizecell)->barrier);
	  barrier_close(dr(v, visualizecell)->endbarrier);
	  return 0;
	}
      next2 = (t_visualize_next2) next;
      next3 = (t_visualize_next3) next;
    }

  while (!barrier_wait(dr(v, visualizecell)->barrier))
    {
      visualize = dr(v, visualizecell);
      dv = dr(vi, vicell);
      if (dv->vi_lib != NULL)
	{
	  if (visualize->arity == 1)
	    reset = next(visualize->data[current][0], visualize->numelems[0]);
	  else if (visualize->arity == 2)
	    reset = next2(visualize->data[current][0], visualize->numelems[0], 
			  visualize->data[current][1], visualize->numelems[1]);
	  else
	    reset = next3(visualize->data[current][0], visualize->numelems[0], 
			  visualize->data[current][1], visualize->numelems[1], 
			  visualize->data[current][2], visualize->numelems[2]);
	}
      else
	{
	  if (visualize->arity == 1)
	    reset = visualize_labview_next(&dv->ref,
					   visualize->data[current][0], visualize->numelems[0]);
	  else if (visualize->arity == 2)
	    reset = visualize_labview_next2(&dv->ref,
					    visualize->data[current][0], visualize->numelems[0], 
					    visualize->data[current][1], visualize->numelems[1]);
	  else
	    reset = visualize_labview_next3(&dv->ref,
					    visualize->data[current][0], visualize->numelems[0], 
					    visualize->data[current][1], visualize->numelems[1], 
					    visualize->data[current][2], visualize->numelems[2]);
	}
      current = 1 - current;
      if (reset)
	dr(v, visualizecell)->reset = 1;
    }

  barrier_wait(dr(v, visualizecell)->endbarrier);

  return 0;
}

oidtype visualize_callfn(bindtype env, oidtype v, oidtype x)
{
  oidtype lst, val;
  struct numarraycell *dx;
  //VISUALIZE visualize;
  int i, memsize;
  double *memcount;

  OfType(x, LISTTYPE, env);

  if (dr(v, visualizecell)->initialized == FALSE)
    {
      memsize = 0;
      for (i = 0, lst = x; listp(lst); ++i)
	{
	  val = fhd(lst);
	  lst = ftl(lst);
	  OfType(val, NUMARRAYTYPE, env);
	  dx = dr(val, numarraycell);
	  dr(v, visualizecell)->numelems[i] = dx->numelems;
	  ++dr(v, visualizecell)->arity;
	  memsize += dx->numelems;
	}
      for (i = 0, lst = x; listp(lst); ++i)
	{
	  val = fhd(lst);
	  lst = ftl(lst);
	  dx = dr(val, numarraycell);
	  if (i == 0)
	    dr(v, visualizecell)->data[0][0] = malloc(2 * memsize * sizeof(double));
	  else
	    dr(v, visualizecell)->data[0][i] = memcount;
	  memcount = &dr(v, visualizecell)->data[0][i][dx->numelems];
	  dr(v, visualizecell)->data[1][i] = memcount;
	  memcount = &dr(v, visualizecell)->data[1][i][dx->numelems];
	}
      dr(v, visualizecell)->initialized = TRUE;
    }

  for (i = 0, lst = x; listp(lst); ++i)
    {
      val = fhd(lst);
      lst = ftl(lst);
      dx = dr(val, numarraycell);
      memcpy(dr(v, visualizecell)->data[dr(v, visualizecell)->current][i],
	     dx->cont, dx->numelems * sizeof(double));
    }

  barrier_wait(dr(v, visualizecell)->barrier);
  dr(v, visualizecell)->current = 1 - dr(v, visualizecell)->current;
  if (dr(v, visualizecell)->reset)
    resetfn(env);

  return t;
}

oidtype visualize_createfn(bindtype env, oidtype vi_array)
{
  oidtype v;
  VISUALIZE dv;
  oidtype vi;
  int i;

  OfType(vi_array, ARRAYTYPE, env);
  OfType(a_elt(vi_array, 0), vitype, env);
  a_let(v, new_object(sizeof (struct visualizecell), visualizetype));
  dv = dr(v, visualizecell);
  dv->barrier = barrier_create();
  dv->endbarrier = barrier_create();
  dv->initialized = FALSE;
  dv->data[0][0] = NULL;
  dv->arity = 0;
  dv->current = 0;
  dv->reset = 0;

  barrier_init(dv->barrier, 1 + a_arraysize(vi_array));
  barrier_init(dv->endbarrier, 1 + a_arraysize(vi_array));
  
  for (i = 0; i < a_arraysize(vi_array); ++i)
    {
      vi = a_elt(vi_array, i);
      dr(vi, vicell)->vi_data = (void *) v;
      vi_openfn(vi);

      if (CreateThread(NULL, 0, visualize_handler, (void *) vi, 0, NULL) == NULL)
	{
	  printf("Error! No thread!\n");
	  barrier_close(dv->endbarrier);
	  lerror(visualizeerror, v, env);
	}
    }

  a_return(v);
}

void register_visualize()
{
  visualizetype = a_definetype("visualize", free_visualize, NULL);
  visualizeerror = a_register_error("Visualization error");
  extfunction1("visualize-create", visualize_createfn);
  extfunction2("visualize-call", visualize_callfn);
}
