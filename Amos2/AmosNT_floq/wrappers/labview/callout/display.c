#include "display.h"
#include <windows.h>
#include "scsq.h"

int displaytype;
int id = 1;

typedef struct displaycell
{
  objtags tags;
  oidtype name;
  oidtype peer;
  oidtype vi;
  oidtype stream;
} *DISPLAY;

void free_display(oidtype d)
{
  a_free(dr(d, displaycell)->name);
  a_free(dr(d, displaycell)->peer);
  a_free(dr(d, displaycell)->vi);
  a_free(dr(d, displaycell)->stream);
  dealloc_object(d);
}

oidtype displayfn(a_callcontext cxt)
{
  oidtype d;
  char comm[2048];
  int i = 0;
  char aid[10];
  char *create = "(osql \"create function ",
    name[128] = "visualize",
    *var = "(charstring, stream) -> boolean as foreign '",
    *function,
    *end = "';\")";

  a_let(d, new_object(sizeof (struct displaycell), displaytype));
  sprintf(aid, "%d", id++);
  strcat(name, aid);
  function = getstring(a_arg(cxt, 1));
  a_let(dr(d, displaycell)->name, mkstring(name));
  a_let(dr(d, displaycell)->peer, a_arg(cxt, 2));
  a_let(dr(d, displaycell)->vi, a_arg(cxt, 3));
  a_let(dr(d, displaycell)->stream, a_arg(cxt, 4));

  strcpy(comm, create);
  i += strlen(create);
  strcpy(&comm[i], name);
  i += strlen(name);
  strcpy(&comm[i], var);
  i += strlen(var);
  strcpy(&comm[i], function);
  i += strlen(function);
  strcpy(&comm[i], end);
  printf("String: %s\n", comm);

  release(call_lisp(mksymbol("remote-eval"),
		    topframe(), 2, mkstring(comm), dr(d, displaycell)->peer));

  a_bind(cxt, 5, d);
  a_result(cxt);

  return nil;
}

oidtype runfn(a_callcontext cxt)
{
  return nil;
}

void register_display()
{
  displaytype = a_definetype("display", free_display, NULL);
  a_extimpl("display----+", displayfn);
  a_extimpl("run-", runfn);
}
