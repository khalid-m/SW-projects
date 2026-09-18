/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Lars Melander, UDBL
 * $RCSfile: fixstream.c,v $
 * $Revision: 1.2 $ $Date: 2011/11/01 15:31:59 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Functions for handling a stream that outputs a byte array
 *              with fixed types.
 * ===========================================================================
 * $Log: fixstream.c,v $
 * Revision 1.2  2011/11/01 15:31:59  larme597
 * Added headers.
 *
 ****************************************************************************/

#include "fixstream.h"
#include "strings.h"

void free_fixstream(oidtype f)
{
  FIXSTREAM df = dr(f, fixstreamcell);

  barrier_close(df->barrier);
  barrier_wait(df->endbarrier);
  if (fixstream_labview_close(&dr(df->vi, vicell)->ref))
    printf("Close returned error!\n");
  a_free(df->vi);
  free_types(&df->type);
  if (df->data != NULL)
    free(df->data);
  barrier_destroy(df->barrier);
  barrier_destroy(df->endbarrier);
  dealloc_object(f);
}

DWORD WINAPI fixstream_handler(void *arg)
{
  oidtype f = (oidtype) arg;
  FIXSTREAM df;
  int current = 0;

  do
    {
      df = dr(f, fixstreamcell);
      if (fixstream_labview_next(&dr(df->vi, vicell)->ref, df->data, df->type.datasize))
	printf("Next returned error!\n");
      build_data(&df->type, df->data, df->transdata[current]);
      current = 1 - current;
    }
  while (!barrier_wait(df->barrier));

  barrier_wait(dr(f, fixstreamcell)->endbarrier);

  return 0;
}

extern void co_enterbg0();
extern void co_leavebg0();

oidtype fixstream_callfn(bindtype env, oidtype f)
{
  FIXSTREAM df = dr(f, fixstreamcell);
  oidtype v = nil;

  co_enterbg0();
  barrier_wait(dr(f, fixstreamcell)->barrier);
  co_leavebg0();

  {
    unwind_protect_begin;
    unwind_protect_catch;
    a_let(v, new_array(dr(f, fixstreamcell)->type.count, nil));
    build_tuple(v, &dr(f, fixstreamcell)->type,
		dr(f, fixstreamcell)->transdata[dr(f, fixstreamcell)->current]);
    dr(f, fixstreamcell)->current = 1 - dr(f, fixstreamcell)->current;
    a_return(v);
    unwind_protect_end;
  }
  return nil;
}

oidtype fixstream_createfn(bindtype env, oidtype vi, oidtype typestring)
{
  oidtype f;
  FIXSTREAM df;

  OfType(vi, vitype, env);
  OfType(typestring, STRINGTYPE, env);
  a_let(f, new_object(sizeof (struct fixstreamcell), fixstreamtype));
  df = dr(f, fixstreamcell);

  df->barrier = barrier_create();
  df->endbarrier = barrier_create();
  df->data = NULL;
  a_let(df->vi, vi);

  // parse type string
  if (parse_types(getstring(typestring), &df->type) == -1)
    {
      printf("Failed to parse type string\n");
      barrier_close(df->endbarrier);
      lerror(fixstreamerror, f, env);
    }

  df->data = malloc(df->type.datasize + 2 * df->type.transdatasize);
  df->transdata[0] = &df->data[df->type.datasize];
  df->transdata[1] = &df->transdata[0][df->type.transdatasize];
  df->current = 0;

  if (fixstream_labview_open(&dr(vi, vicell)->ref))
    printf("Open returned error!\n");

  if (CreateThread(NULL, 0, fixstream_handler, (void *) f, 0, NULL) == NULL)
    {
      printf("Error! No thread!\n");
      barrier_close(df->endbarrier);
      lerror(fixstreamerror, f, env);
    }

  a_return(f);
}

void register_fixstream()
{
  fixstreamtype = a_definetype("fixstream", free_fixstream, NULL);
  fixstreamerror = a_register_error("Fixstream error");
  extfunction2("fixstream-create", fixstream_createfn);
  extfunction1("fixstream-call", fixstream_callfn);
}
