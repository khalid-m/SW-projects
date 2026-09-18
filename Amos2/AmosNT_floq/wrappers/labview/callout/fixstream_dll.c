#include "fixstream.h"
#include "strings.h"

DWORD WINAPI fixstream_handler(void *arg)
{
  FIXSTREAM fixstream = arg;
  int current = 0;

  do
    {
      fixstream->next(fixstream->data, fixstream->type.datasize);
      build_data(&fixstream->type, fixstream->data, fixstream->transdata[current]);
      current = 1 - current;
    }
  while (!barrier_wait(fixstream->barrier));

  barrier_wait(fixstream->endbarrier);

  return 0;
}

oidtype call_fixstream(a_callcontext cxt)
{
  char *addr;
  FIXSTREAM fixstream;
  int current = 0;

  fixstream = a_extpredparam(cxt);
  barrier_init(fixstream->barrier, 2);

  fixstream->data = malloc(fixstream->type.datasize + 2 * fixstream->type.transdatasize);
  fixstream->transdata[0] = &fixstream->data[fixstream->type.datasize];
  fixstream->transdata[1] = &fixstream->transdata[0][fixstream->type.transdatasize];

  {
    unwind_protect_begin;
    IntoString(a_arg(cxt, 1), addr, cxt->env);
    fixstream->open(addr);

    if ((fixstream->thread_id = CreateThread(NULL, 0, fixstream_handler,
					     (void *) fixstream, 0, NULL)) == NULL)
      {
	printf("Error! No thread!\n");
      }
    else
      {
	while (1)
	  {
	    barrier_wait(fixstream->barrier);
	    build_tuple(cxt, &fixstream->type, fixstream->transdata[current]);
	    current = 1 - current;
	    a_result(cxt);
	  }
	unwind_protect_catch;
	barrier_close(fixstream->barrier);
	barrier_wait(fixstream->endbarrier);
      }
    fixstream->close();
    free(fixstream->data);
    unwind_protect_end;
  }

  return nil;
}

oidtype bind_fixstreamfn(bindtype env, oidtype val)
{
  char *str, **names, *functionname, *dllname, *typestr;
  int size;
  HMODULE lib;
  FIXSTREAM fixstream;

  IntoString(val, str, env);
  functionname = malloc(strlen(str) + 1);
  strcpy(functionname, str);

  size = explode(&names, functionname, ':');
  dllname = names[1];
  typestr = names[2];

  if ((lib = LoadLibrary(dllname)) == NULL)
    {
      printf("fixstream dll failed to load: %s\n", dllname);
      free(functionname);
      free(names);
      return nil;
    }

  fixstream = malloc(sizeof(t_fixstream));

  if ((fixstream->open = (t_fixstream_open) GetProcAddress(lib, "open")) == NULL ||
      (fixstream->next = (t_fixstream_next) GetProcAddress(lib, "next")) == NULL ||
      (fixstream->close = (t_fixstream_close) GetProcAddress(lib, "close")) == NULL)
    {
      printf("Failed to locate a dll function\n");
      free(fixstream);
      free(functionname);
      free(names);
      return nil;
    }

  // parse type string
  if (parse_types(typestr, &fixstream->type) == -1)
    {
      printf("Failed to parse type string\n");
      free(fixstream);
      free(functionname);
      free(names);
      return nil;
    }

  fixstream->barrier = barrier_create();
  fixstream->endbarrier = barrier_create();

  a_extimpl(functionname, call_fixstream);
  a_setpredparam(functionname, fixstream);

  free(names);
  return t;
}

oidtype fixstream_enabledfn(bindtype env)
{
  return t;
}

void register_fixstream()
{
  extfunction0("fixstream-enabled", fixstream_enabledfn);
  extfunction1("bind-fixstream", bind_fixstreamfn);
  a_register_enabled("fixstream", "fixstream-enabled");
  a_register_loader("fixstream", "bind-fixstream");
}
