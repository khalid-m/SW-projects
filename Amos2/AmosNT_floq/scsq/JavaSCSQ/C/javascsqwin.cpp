/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2008 Tore Risch, Erik Zeitler, UDBL
 * $RCSfile: javascsqwin.cpp,v $
 * $Revision: 1.3 $ $Date: 2012/01/06 13:08:31 $
 * $State: Exp $ $Locker:  $
 *
 * Description: JavaSCSQ initializer
 * ===========================================================================
 * $Log: javascsqwin.cpp,v $
 * Revision 1.3  2012/01/06 13:08:31  torer
 * Changed hook signature
 *
 * Revision 1.2  2011/01/27 15:59:08  torer
 * Must include storage.h to define EXTERN
 *
 * Revision 1.1  2008/08/14 11:02:34  zeitler
 * cross platform javascsq
 *
 ****************************************************************************/
#include "storage.h"
#include "hooks.h"
EXTERN void javascsq_init(void *);
#include <stdio.h>

#include <windows.h>

BOOL APIENTRY DllMain(HANDLE hModule, DWORD ul_reason_for_call,
                      LPVOID lpReserved) {
  switch (ul_reason_for_call) {
  case DLL_PROCESS_ATTACH:
  case DLL_THREAD_ATTACH:
    a_register_hook(javascsq_init,AFTER_ROLLIN);
  case DLL_THREAD_DETACH:
  case DLL_PROCESS_DETACH:
    break;
  }
  return TRUE;
}
