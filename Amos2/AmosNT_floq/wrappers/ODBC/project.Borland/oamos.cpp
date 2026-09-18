//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop

//---------------------------------------------------------------------------
USEUNIT("..\src\OdbcFunctions.cpp");
USEUNIT("..\src\AmosTypes.cpp");
USERES("oamos.res");
USEFILE("..\..\..\C\storage.h");
USEFILE("..\..\..\C\callout.h");
USEFILE("..\..\..\C\alisp.h");
USELIB("libodbc_bc.lib");
USELIB("..\..\..\bin\amos.lib");
//---------------------------------------------------------------------------
using namespace std;

#include <iostream>

void odbc_bind();

int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*) {
    switch( reason ) {
        case DLL_PROCESS_ATTACH: // Initialize once for each new process.
            // Return FALSE to fail DLL load.
            odbc_bind();
            break;

        case DLL_THREAD_ATTACH:  // Do thread-specific initialization.
            break;

        case DLL_THREAD_DETACH:  // Do thread-specific cleanup.
            break;

        case DLL_PROCESS_DETACH: // Perform any necessary cleanup.
            break;
    }

    return TRUE;  // Successful DLL_PROCESS_ATTACH.
}
//---------------------------------------------------------------------------


