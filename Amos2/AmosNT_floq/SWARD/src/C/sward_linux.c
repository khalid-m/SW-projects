/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Fredrik Edemar, UDBL
 ****************************************************************************/

#include "hooks.h"
// extern "C" void sparql_init(char *image);
extern void sparql_init(char *image);
static void execute_sward() __attribute__((__constructor__));
static void execute_sward()
{
  a_register_hook(sparql_init,AFTER_ROLLIN);
}
