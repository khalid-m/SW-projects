/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Tore Risch, UDBL
 * $RCSfile: extender.c,v $
 * $Revision: 1.13 $ $Date: 2013/04/29 17:04:40 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Dynamic system extension loader
 * ===========================================================================
 * $Log: extender.c,v $
 * Revision 1.13  2013/04/29 17:04:40  torer
 * Removed trace printings
 *
 * Revision 1.12  2013/04/29 14:11:16  torer
 * 1. AMOS_HOME must be exported under Linux
 * 2. LD_LIBRARY_PATH muste be set to $(AMOS_HOME)/bin under Linux
 * 3. libamos.so is now a shared object ubnder Linux
 * 4. $(AMOS_HOME)/bin/libamos.a is no longer used. Delete it!
 *
 * Revision 1.11  2013/03/06 21:10:23  torer
 * Incorrect error message
 *
 * Revision 1.10  2013/02/23 16:13:29  torer
 * LD_LIBARARY_PATH not needed any more
 *
 * Revision 1.9  2012/01/12 07:52:56  thatr500
 * changed signature a_initialize_extension
 *
 * Revision 1.8  2011/11/19 17:30:19  torer
 * Optional error trap in load-extension
 *
 * Revision 1.7  2011/11/18 16:25:44  torer
 * Automatic realoding of extenders after rollin
 *
 * Revision 1.6  2011/04/29 18:23:03  torer
 * Eliminated redundant code
 *
 ****************************************************************************/

#include "alisp.h"

typedef void(*VOIDFN)();

#ifdef NT

#include <windows.h> 
#include <stdio.h> 

#define LOADLIBRARY(x) LoadLibrary(TEXT(x))
#define GETPROCADDR(l,f) GetProcAddress(l,f)
#define EXTN ".dll"

#elif defined(LINUX)

#define LOADLIBRARY(x) (dlopen(x,RTLD_NOW|RTLD_GLOBAL))
#define GETPROCADDR(l,f) dlsym(l,f)
#define EXTN ".so"

#include <dlfcn.h>

#endif

#if defined(NT) || defined(LINUX)
EXPORT int a_load_extension(char *extensionName, char *dpath)
{
  void *handle; 
  VOIDFN initFn; 
  char *fullName;
  char *ext = EXTN;

  fullName = (char *)alloca(strlen(extensionName)+strlen(ext)+1);
  strcpy(fullName, extensionName);
  strcat(fullName,ext);
 
  // Get a handle to the module.
  //printf("Loading %s\n", fullName);
  handle = LOADLIBRARY(fullName); 
  // If the handle is valid, try to get the initialization function address.
  if(handle == NULL && dpath!=NULL)
    {
      char *dfltpath = alloca(strlen(dpath)+strlen(fullName)+2);

      strcpy(dfltpath, dpath);
      strcat(dfltpath, "/");
      strcat(dfltpath, fullName);
      //printf("Loading %s\n", dfltpath);
      handle = LOADLIBRARY(dfltpath);
    }
  if (handle != NULL) 
    { 
      
      initFn = (VOIDFN) GETPROCADDR(handle,"a_initialize_extension"); 
      // If the function address is valid, call the function.

      if (NULL != initFn) 
        {
	  (initFn) ();
	  return 0;
        }
      else return 1; /* No initialization function found */
    } 
  else 
    {
#ifdef LINUX 
      fprintf (stderr, "%s\n", dlerror());
#endif
      return -1; /* Library could not be loaded */
    }
}
#else 
EXPORT int a_load_extension(char *extensionName)
{
  fprintf(stderr, "Extension modules not implemented.\n");
  return -1;
}
#endif

int cannot_load_extension;

oidtype load_extension0fn(bindtype env, oidtype name, oidtype dpath, 
                          oidtype noerror)
{
  char *ename;
  int rc;
  char *defaultpath=NULL;
  
  IntoString(name, ename, env);
  if(dpath!=nil)
    { 
      IntoString(dpath, defaultpath, env);
    }
  rc = a_load_extension(ename, defaultpath);
  if(rc==1) return nil;
  if(rc==0) return t;
  if(noerror != nil) return nil;
  return lerror(cannot_load_extension, name, env);
}

void register_extender(void)
{
  cannot_load_extension = a_register_error("Cannot load extension");
  extfunction3("load-extension0", load_extension0fn);
  //dlopen(NULL,RTLD_NOW|RTLD_GLOBAL);
}
