/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2010 Lars Melander, UDBL
 * $RCSfile: crashex.c,v $
 * $Revision: 1.5 $ $Date: 2010/07/15 14:16:05 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Checking status of the result from running coroutine
 *              background check.
 * ===========================================================================
 * $Log: crashex.c,v $
 * Revision 1.5  2010/07/15 14:16:05  larme597
 * *** empty log message ***
 *
 * Revision 1.4  2010/06/25 15:53:39  larme597
 * *** empty log message ***
 *
 * Revision 1.3  2010/06/25 14:45:33  larme597
 * Coroutine background check test for Win32.
 *
 * Revision 1.2  2010/06/24 14:51:11  larme597
 * *** empty log message ***
 *
 * Revision 1.1  2010/06/23 17:53:28  larme597
 * Testing coroutine background check for Linux.
 *
 ****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv)
{
  FILE *f;
  int i, filecount = 0;
  char *str = NULL, *ret = NULL, *checkstring;

  if (argc != 2)
    {
      printf("Wrong number of arguments in call to crashex!\n");
      return 1;
    }
  checkstring = argv[1];

  printf("[Testing coroutine background check ...");

  if ((f = fopen("tmpfile", "r")) != NULL)
    {
      while (!feof(f))
	{
	  ++filecount;
	  fgetc(f);
	}
      rewind(f);
      str = malloc(filecount + 1);
      for (i = 0; i < filecount; ++i)
	str[i] = fgetc(f);
      str[filecount] = '\0';
      fclose(f);
      ret = strstr(str, checkstring);
    }
  else
    printf("ERROR! File missing!");
  if (ret == NULL)
    printf("\n------------------\nWARNING! Background check failed!\n------------------\n not ");
  printf("OK]\n");

  if (str != NULL)
    free(str);
  return 0;
}
