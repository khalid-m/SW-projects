/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 1998 Tore Risch, EDSLAB
 * $RCSfile: testcpp.cpp,v $
 * $Revision: 1.3 $ $Date: 2000/06/26 14:33:37 $
 * $State: Exp $ $Locker:  $
 *
 * Description: 
 ****************************************************************************/

//---------------------------------------------------------------------------
#include <vcl\vcl.h>
#pragma hdrstop
//---------------------------------------------------------------------------
USELIB("..\bin\amos.lib");
USEFILE("callin.h");
USEFILE("storage.h");
USEUNIT("democpp.cpp");
USEFILE("callout.h");
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
	Application->Initialize();
	Application->Run();

	return 0;
}
//---------------------------------------------------------------------
