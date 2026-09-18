/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 1998 Tore Risch, EDSLAB
 * $RCSfile: callout.cpp,v $
 * $Revision: 1.2 $ $Date: 1999/04/07 12:53:36 $
 * $State: Exp $ $Locker:  $
 *
 * Description: 
 ****************************************************************************/

//---------------------------------------------------------------------------
#include <vcl\vcl.h>
#pragma hdrstop
//---------------------------------------------------------------------------
USELIB("../bin/amos.lib");
USEFILE("callin.h");
USEFILE("storage.h");
USEUNIT("calloutdemo.c");
USEFILE("callout.h");
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
	Application->Initialize();
	Application->Run();

	return 0;
}
//---------------------------------------------------------------------
