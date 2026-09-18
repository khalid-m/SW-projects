/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2011 Tore Risch, UDBL
 * $RCSfile: hello.c,v $
 * $Revision: 1.7 $ $Date: 2012/01/12 07:48:35 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Example of extension module
 ****************************************************************************/

/****************************************************************************
   This file shows how to make a extension modules of Amos II as a 
   C library that is loaded at run time into the system by the Lisp call:
      (load-extention "hello")
   The module should be compiled as a DLL file named hello.dll under Windows
   and as a shared object file named hello.so under Linux.

   It is illustrated how to define in C a dynamically loaded Lisp function
      (hello)
   and a corresponding dynamically loaded Amos function
      hello();
****************************************************************************/

#include "alisp.h"   /* To be able to implement foreign Lisp functions */
#include "callout.h" /* To be able to implement foreign Amos functions */

oidtype hellofn(bindtype env)
     /* Hello world implemented as foreign Lisp function */
{
  return mkstring("Hello world!");
}

oidtype helloF(a_callcontext cxt)
     /* Hello world implemented as foreign Amos function */
{
  a_bind(cxt,1,mkstring("Hello world!"));
  a_result(cxt);
  return nil;
}

EXPORT void a_initialize_extension(void* xa)
     /* The C function with this name in an extension module will be
        called after the module is dynamically loaded into the system */
{
  /* Register Lisp function HELLO-WORLD: */
  extfunction0("hello", hellofn);
  /* Register foreign Amos function implementation HELLO-WORLD+: */
  a_extimpl("hello+", helloF);

  /* Define implementation of foreign function hello_world(): */
  amosql("create function hello()->Charstring as foreign 'hello+';",
	 FALSE);

  printf("Initialized Hello Worlds!\n");
}
