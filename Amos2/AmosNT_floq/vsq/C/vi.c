/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Lars Melander, UDBL
 * $RCSfile: vi.c,v $
 * $Revision: 1.2 $ $Date: 2011/11/01 15:31:59 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Wrapper for handling virtual instruments (labview).
 * ===========================================================================
 * $Log: vi.c,v $
 * Revision 1.2  2011/11/01 15:31:59  larme597
 * Added headers.
 *
 ****************************************************************************/

#include "vi.h"

void free_vi(oidtype d)
{
  a_free(dr(d, vicell)->name);
  if (dr(d, vicell)->vi_lib != NULL)
    FreeLibrary(dr(d, vicell)->vi_lib);
  else
    {
      if (dr(d, vicell)->isopen)
	vi_close(&dr(d, vicell)->ref);
      vi_delete(&dr(d, vicell)->ref);
    }
  dealloc_object(d);
}

oidtype vifn(a_callcontext cxt)
{
  oidtype vi;
  int error;
  char *name;
  HMODULE vi_lib = NULL;

  name = getstring(a_arg(cxt, 1));
  if (strstr(name, "dll") != NULL)
    {
      if ((vi_lib = LoadLibrary(name)) == NULL)
	{
	  a_error(vierror, nil, TRUE);
	  printf("Could not load dll: %s\n", name);
	  return nil;
	}
    }

  if (vi_lib == NULL && (error = vi_check(name)) != 0)
    {
      a_error(vierror, nil, TRUE);
      printf("Creating vi %s returned error %d!\n", getstring(a_arg(cxt, 1)), error);
      return nil;
    }
  vi = new_object(sizeof (struct vicell), vitype);
  a_let(dr(vi, vicell)->name, a_arg(cxt, 1));
  if ((dr(vi, vicell)->vi_lib = vi_lib) == NULL)
    vi_get_reference(getstring(dr(vi, vicell)->name), &dr(vi, vicell)->ref);
  dr(vi, vicell)->isopen = FALSE;
  a_bind(cxt, 2, vi);
  a_result(cxt);

  return t;
}

oidtype vi_openfn(oidtype vi)
{
  int error;

  if (dr(vi, vicell)->isopen)
    return nil;

  if (dr(vi, vicell)->vi_lib == NULL && (error = vi_open(&dr(vi, vicell)->ref)) != 0)
    {
      a_error(vierror, vi, TRUE);
      printf("Opening vi %s returned error %d!\n", getstring(dr(vi, vicell)->name), error);
      return nil;
    }
  dr(vi, vicell)->isopen = TRUE;

  return t;
}

oidtype openfn(a_callcontext cxt)
{
  return vi_openfn(a_arg(cxt, 1));
}

oidtype vi_closefn(oidtype vi)
{
  int error;

  if (!dr(vi, vicell)->isopen)
    return nil;

  if (dr(vi, vicell)->vi_lib == NULL && (error = vi_close(&dr(vi, vicell)->ref)) != 0)
    {
      a_error(vierror, vi, TRUE);
      printf("Closing vi %s returned error %d!\n", getstring(dr(vi, vicell)->name), error);
      return nil;
    }
  dr(vi, vicell)->isopen = FALSE;

  return t;
}

oidtype closefn(a_callcontext cxt)
{
  return vi_closefn(a_arg(cxt, 1));
}

oidtype vi_runfn(oidtype vi)
{
  int error;

  if (dr(vi, vicell)->vi_lib == NULL && (error = vi_run(&dr(vi, vicell)->ref)) != 0)
    {
      a_error(vierror, vi, TRUE);
      printf("Running vi %s returned error %d!\n", getstring(dr(vi, vicell)->name), error);
      return nil;
    }

  return t;
}

oidtype runfn(a_callcontext cxt)
{
  return vi_runfn(a_arg(cxt, 1));
}

void register_vi()
{
  vitype = a_definetype("vi", free_vi, NULL);
  vierror = a_register_error("VI error");
  a_extimpl("vi-+", vifn);
  a_extimpl("viopen-", openfn);
  a_extimpl("viclose-", closefn);
  a_extimpl("virun-", runfn);
}
