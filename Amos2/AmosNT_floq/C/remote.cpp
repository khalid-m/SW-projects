/*****************************************************************************
 * AMOS
 * 
 * Author: (c) 1998 Tore Risch, EDSLAB
 * $RCSfile: remote.cpp,v $
 * $Revision: 1.1 $ $Date: 1999/02/24 15:00:20 $
 * $State: Exp $ $Locker:  $
 *
 * Description: 
 *
 * Requirements:
 * ===========================================================================
 * $Log: remote.cpp,v $
 * Revision 1.1  1999/02/24 15:00:20  torri
 * Added check for open connections in C interface.
 * Added regression test for remote connections from C.
 *
 * Revision 1.15  1998/09/14 12:54:53  torri
 * Changed project cpp file.
 * Fixed EXTERNAL declaration of stdoutstream in storage.h
 * Demo of external events in democpp.cpp
 *
// Revision 1.10  1998/04/05  19:11:46  torri
// dumy
//
// Revision 1.2  1998/01/22  14:01:23  gunku
// Added ^M
//
// Revision 1.1.1.1  1998/01/21  21:47:13  gunku
// Imported C and regress directories
//
 *
 */

//---------------------------------------------------------------------------
#include <vcl\vcl.h>
#pragma hdrstop
//---------------------------------------------------------------------------
USELIB("..\bin\amos.lib");
USEFILE("..\C\callin.h");
USEFILE("..\C\storage.h");
USEFILE("..\C\callout.h");
USEUNIT("testremote.c");
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
	Application->Initialize();
	Application->Run();

	return 0;
}
//---------------------------------------------------------------------
