/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 1997 Tore Risch, EDSLAB
 * $RCSfile: main.c,v $
 * $Revision: 1.8 $ $Date: 2013/03/13 17:58:07 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Minimal Amos2 driver program
 ****************************************************************************/

/* This driver program is provided as a template when you want to make
   your own Amos II based C project. For Visual Studio 6.0 there is a
   template project file in demo/amos2.dsw. There is a corresponding
   project file for Visual Studio 2010 in demo10/amos2.vcxproj. Start
   by making a new Visual Studio project with a copy of this main
   program as driver program. Make sure you have exactly the same
   settings in your own Visual Studio project as in the template
   project file by going through all settings and make sure you copy
   them all to your own project. Include all files except this main
   program, which should be replaced with your own new main
   program. Don't forget to include the winsock2 library (Ws2_32.lib)
   in the project as an additional library.
*/

#include "callin.h"

int main(int argc,char **argv)
{ 
  init_amos(argc,argv);
  amos_toploop(""); /* Default prompter */
  return 0;
}









