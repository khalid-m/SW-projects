/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Lars Melander, UDBL
 * $RCSfile: visualize_stream.c,v $
 * $Revision: 1.1 $ $Date: 2011/12/14 18:19:43 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Wrapper for sending double numarrays to external 
 * visualization.
 * ===========================================================================
 * $Log: visualize_stream.c,v $
 * Revision 1.1  2011/12/14 18:19:43  larme597
 * *** empty log message ***
 *
 * Revision 1.3  2011/11/05 11:47:00  larme597
 * Added reset functionality to virtual instruments.
 *
 * Revision 1.2  2011/11/01 15:31:59  larme597
 * Added headers.
 *
 ****************************************************************************/

#include "visualize_stream.h"
#include "vsq_labview.h"
#include "vi.h"
#include "numarray.h"

DWORD WINAPI visualize_stream_handler(void *arg)
{
  oidtype vi = (oidtype) arg;
  VI dv;
  VISUALIZE_STREAM visualize = dr(vi, vicell)->vi_data;
  int current = 0;
  int reset = 0;
  t_visualize_stream_next next;

  if (dr(vi, vicell)->vi_lib != NULL)
    {
      if ((next = (t_visualize_stream_next) GetProcAddress(dr(vi, vicell)->vi_lib, "next")) == NULL)
	{
	  printf("Failed to locate a dll function\n");
	  barrier_close(visualize->barrier);
	  barrier_close(visualize->endbarrier);
	  return 0;
	}
    }

  while (!barrier_wait(visualize->barrier))
    {
      dv = dr(vi, vicell);
      if (dv->vi_lib != NULL)
	{
	  next(visualize->data[current], visualize->arity);
	}
      else
	{
	  reset = visualize_labview_stream(&dv->ref, visualize->data[current], visualize->arity);
	}
      current = 1 - current;
      if (reset)
	visualize->reset = 1;
    }

  barrier_wait(visualize->endbarrier);

  return 0;
}

oidtype visualize_stream_mapper(a_callcontext cxt, int arity, oidtype *restpl, void *xa)
{
  VISUALIZE_STREAM visualize = xa;
  int i, cnt;

  for (i = 0; i < arity; ++i)
    {
      if (a_datatype(restpl[i]) == NUMARRAYTYPE)
	{
	  visualize->stored_value[visualize->current][i].arr1DD =
	    (TD1Hdl) DSNewHandle(sizeof(int) +
				 sizeof(double) * dr(restpl[i], numarraycell)->numelems);
	  (*visualize->stored_value[visualize->current][i].arr1DD)->dimSize =
	    dr(restpl[i], numarraycell)->numelems;
	  memcpy((*visualize->stored_value[visualize->current][i].arr1DD)->elt,
		 dr(restpl[i], numarraycell)->cont,
		 sizeof(double) * dr(restpl[i], numarraycell)->numelems);
	}
      else switch (a_datatype(restpl[i]))
	{
	case REALTYPE:
	  visualize->stored_value[visualize->current][i].d = getreal(restpl[i]);
	  break;
	case INTEGERTYPE:
	  visualize->stored_value[visualize->current][i].i = getinteger(restpl[i]);
	  break;
	case STRINGTYPE:
	  visualize->stored_value[visualize->current][i].str =
	    (LStrHandle) DSNewHClr(strlen(getstring(restpl[i])) * sizeof(char));
	  LStrPrintf(visualize->stored_value[visualize->current][i].str,
		     "%s", getstring(restpl[i]));
	  break;
	case ARRAYTYPE:
	  visualize->stored_value[visualize->current][i].arr1DD =
	    (TD1Hdl) DSNewHandle(sizeof(int) +
				 sizeof(double) * a_arraysize(restpl[i]));
	  (*visualize->stored_value[visualize->current][i].arr1DD)->dimSize =
	    a_arraysize(restpl[i]);
	  for (cnt = 0; cnt < a_arraysize(restpl[i]); ++cnt)
	    IntoDouble(a_elt(restpl[i], cnt),
		       (*visualize->stored_value[visualize->current][i].arr1DD)->elt[cnt],
		       cxt->env);
	  break;
	default:
	  printf("Error: Invalid stream type!\n");
	  resetfn(cxt->env);
	}
    }

  barrier_wait(visualize->barrier);
  visualize->current = 1 - visualize->current;

  if (visualize->reset)
    resetfn(cxt->env);

  a_result(cxt);

  return nil;
}

oidtype visualize_streamfn(a_callcontext cxt)
{
  VISUALIZE_STREAM visualize;
  int i;
  oidtype vi = a_arg(cxt, 1);
  oidtype stream = a_arg(cxt, 2);
  oidtype length;

  visualize = malloc(sizeof (t_visualize_stream));
  visualize->barrier = barrier_create();
  visualize->endbarrier = barrier_create();

  a_let(length, call_lisp(mksymbol("get-stream-arity"), cxt->env, 1, stream));
  visualize->arity = getinteger(length);
  a_free(length);
  visualize->data[0] = malloc(2 * visualize->arity * sizeof(unsigned int));
  visualize->data[1] = &visualize->data[0][visualize->arity];
  visualize->stored_value[0] = malloc(2 * visualize->arity * sizeof(t_stored_value));
  visualize->stored_value[1] = &visualize->stored_value[0][visualize->arity];

  for (i = 0; i < visualize->arity; ++i)
    {
      visualize->data[0][i] = (unsigned int) &visualize->stored_value[0][i];
      visualize->data[1][i] = (unsigned int) &visualize->stored_value[1][i];
    }

  visualize->current = 0;
  visualize->error = 0;
  visualize->reset = 0;
  visualize->callback = 0;
  visualize->callback_value = 0;

  dr(vi, vicell)->vi_data = visualize;
  vi_openfn(vi);

  {
    unwind_protect_begin;
    if (CreateThread(NULL, 0, visualize_stream_handler, (void *) vi, 0, NULL) == NULL)
      {
	printf("Error! No thread!\n");
	barrier_close(visualize->endbarrier);
	resetfn(cxt->env);
      }

    a_mapbag(cxt, stream, visualize_stream_mapper, visualize);
    unwind_protect_catch;

    barrier_close(visualize->barrier);
    barrier_wait(visualize->endbarrier);
    barrier_destroy(visualize->barrier);
    barrier_destroy(visualize->endbarrier);
    free(visualize->stored_value[0]);
    free(visualize->data[0]);
    free(visualize);

    unwind_protect_end;
  }

  return nil;
}

void register_visualize_stream()
{
  a_extimpl("visualize-stream--", visualize_streamfn);
}
