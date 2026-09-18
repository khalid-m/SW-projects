/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2008 Tore Risch, Erik Zeitler, UDBL
 * $RCSfile: JavaSCSQ.cpp,v $
 * $Revision: 1.5 $ $Date: 2012/03/28 16:13:53 $
 * $State: Exp $ $Locker:  $
 *
 * Description: JavaSCSQ initializer
 * ===========================================================================
 * $Log: JavaSCSQ.cpp,v $
 * Revision 1.5  2012/03/28 16:13:53  zeitler
 * Correct signature of register_hook
 * #include <string.h>
 *
 * Revision 1.4  2011/01/27 16:15:43  zeitler
 * Linux JavaSCSQ: storage.h included, register_proctime eliminated
 *
 * Revision 1.3  2008/08/14 11:02:34  zeitler
 * cross platform javascsq
 *
 * Revision 1.2  2008/08/08 16:33:55  zeitler
 * Linux JavaSCSQ
 *
 * Revision 1.1  2007/08/21 09:56:18  zeitler
 * Converting JavaSCSQ
 *
 * Revision 1.1  2007/07/27 17:19:52  torer
 * *** empty log message ***
 *
 ****************************************************************************/

extern "C" void javascsq_init(void *image);
#include "storage.h"
#include "hooks.h"
#include <stdio.h>

void __attribute__ ((constructor)) my_load(void);
void __attribute__ ((destructor)) my_unload(void);

// Called when the library is loaded and before dlopen() returns
void my_load(void) {
  a_register_hook(javascsq_init,AFTER_ROLLIN);
}

// Called when the library is unloaded and before dlclose() returns
void my_unload(void) {
}
