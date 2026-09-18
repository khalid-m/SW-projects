/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2014 Tore Risch, UDBL
 * $RCSfile: startupdirectory.c,v $
 * $Revision: 1.2 $ $Date: 2014/01/04 11:08:37 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Locating the Amos II startup directory 
 * ===========================================================================
 * $Log: startupdirectory.c,v $
 * Revision 1.2  2014/01/04 11:08:37  torer
 * *** empty log message ***
 *
 * Revision 1.1  2014/01/04 10:53:11  torer
 * OS-independent localization of the startup directory
 *
 ****************************************************************************/

#include <stdlib.h>
#include <string.h>

char startupdirbuff[1000];
char ender = '\0';

#if defined(_MSC_VER)
#include <windows.h>
extern void a_toUnixFileName(char *);
char *getstartupdirectory(void)
{
  HANDLE hModule;
  hModule= GetModuleHandle("amos2.dll");
  GetModuleFileName((HINSTANCE)hModule, startupdirbuff, sizeof(startupdirbuff));
  a_toUnixFileName(startupdirbuff);
#elif defined(__APPLE__)
#include <dlfcn.h>
char *getstartupdirectory(void)
{
  Dl_info dls;
  dladdr((void *)getstartupdirectory, &dls);
  strncpy(startupdirbuff, dls.dli_fname, sizeof(startupdirbuff));
#else
#define _GNU_SOURCE
#include <dlfcn.h>
typedef struct {
  const char *dli_fname;  /* Pathname of shared object that
                             contains address */
  void       *dli_fbase;  /* Address at which shared object
                             is loaded */
  const char *dli_sname;  /* Name of nearest symbol with address
                             lower than addr */
  void       *dli_saddr;  /* Exact address of symbol named
                             in dli_sname */
} Dl_info;
char *getstartupdirectory(void)
{
  Dl_info dls;
  dladdr((void *)getstartupdirectory, &dls);
  strncpy(startupdirbuff, dls.dli_fname, sizeof(startupdirbuff));
#endif
 { 
   char *end = strrchr(startupdirbuff, '/');
   if (end != NULL) startupdirbuff[end-startupdirbuff]='\0';
   else startupdirbuff[0]='\0';
   return startupdirbuff;
 }
}

