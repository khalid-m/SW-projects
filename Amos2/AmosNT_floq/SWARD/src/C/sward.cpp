/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2007 Tore Risch, UDBL
 * $RCSfile: sward.cpp,v $
 * $Revision: 1.1 $ $Date: 2007/07/27 17:19:52 $
 * $State: Exp $ $Locker:  $
 *
 * Description: SWARD initializer
 * ===========================================================================
 * $Log: sward.cpp,v $
 * Revision 1.1  2007/07/27 17:19:52  torer
 * *** empty log message ***
 *
 ****************************************************************************/

#include <windows.h>
#include "hooks.h"
extern "C" void sparql_init(char *image);

BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
    switch (ul_reason_for_call)
	{
		case DLL_PROCESS_ATTACH:
		case DLL_THREAD_ATTACH:
                a_register_hook(sparql_init,AFTER_ROLLIN);
		case DLL_THREAD_DETACH:
		case DLL_PROCESS_DETACH:
			break;
    }
    return TRUE;
}
