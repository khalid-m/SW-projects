/*****************************************************************************
 * AMOS2
 * 
 * Author: 2014 Tore Risch, UDBL
 *
 * Description: Example of application client program to Amos server
 ****************************************************************************/

/***************************************************************************
 * NOTICE:                                                                 *
 * Before you can run this program you have to:                            *
 * 1. Compile the program                                                  *
 *    Windows:                                                             *
 *       Use the MS Visual Studio project file 'amosclient.vcxproj'        *
 *    Linux:                                                               *
 *       Set environment variable:                                         *
 *          export ARCHITECTURE=Linux32                                    *
 *       Compile with:                                                     *
 *          make                                                           *
 *    OSX:                                                                 *
 *       Set environment variable:                                         *
 *          export ARCHITECTURE=Apple32                                    *
 *       Compile with:                                                     *
 *          make                                                           *
 * 2. Start amos2 server named 'wc' holding the 'world cup'                *
 *          database:                                                      *
 *    Windows:                                                             *
 *      start ..\bin\amos2 -O tutorial.amosql -n wc                        *
 *    Unix:                                                                *
 *      ../bin/amos2 -O tutorial.amosql -n wc&                             *
 * 3. Include path to folder with Amos binaries in system variable:        *
 *    Windows:                                                             *
 *      PATH                                                               *
 *    Linux:                                                               *
 *      LD_LIBRARY_PATH                                                    *
 *    OSX                                                                  *
 *      DYLD_LIBRARY_PATH                                                  *
 **************************************************************************/

#include "callin.h"
#include <math.h>

int main(int argc,char **argv)
{
  /*************************************/
  /*** Interface handle declarations ***/
  /*************************************/

  dcl_connection(c); /* To hold a connection to Amos database */
  dcl_scan(s);       /* To hold the result stream from AmosQL an query or 
                        function call */
  dcl_tuple(row);    /* To hold a row retrieved from database */
  dcl_tuple(argl);   /* To hold a function argument list */
  dcl_oid(fn);       /* To hold an object identifying a function */

  char *query;

  /****************************************/
  /*** Initialize and connect to server ***/
  /****************************************/

  /* Initialize Amos client interface: */
  a_initclient(FALSE);  

  /* Connect to the Amos database server named 'wc': */
  a_connect(c,"wc",FALSE); 

  printf("Connection to Amos server 'wc' OK\n");

  /*****************************************/
  /*** Execute query and scan the result ***/
  /*****************************************/

  query = 
    "select name(host(t)), year(t) from Tournament t where year(t) < 1940;";
  printf("Executing query:\n  %s\n", query);
  a_execute(c,s,query,FALSE); 
  /*        FALSE => no error trapping => will exit on failure */
  /* s is a 'scan' holding the result of the query */
  while(!a_eos(s))           /* While there are more rows in scan */
    {
      char host[50];
      int year;

      a_getrow(s,row,FALSE); /* Get current row in scan */
      /* Get 1st arg in row as string: */
      a_getstringelem(row,0,host,sizeof(host),FALSE); 
      /* Get 2nd arg in row as integer: */
      year = a_getintelem(row,1,FALSE); 
      printf("Host of year %d: %s\n",year,host);
      a_nextrow(s,FALSE);    /* Advance scan forward */
    }
  a_closescan(s,FALSE);            /* Close the scan */
  /* The call to a_closescan is actually not needed here since the scan is
     closed when free_scan() is called below. 
     The scans are also automatically closed when they are re-used.
     It is, however, good to close scans as soon as possible to release 
     resources. */

  /*****************************************/
  /*** Call function and scan the result ***/
  /*****************************************/

  printf("Calling function host_name(1930):\n");

  /* Get a handle to the function 'get_host': */
  a_assign(fn,a_getfunction(c,"host_name",FALSE));

  /* The argument tuple has one element: */
  a_newtuple(argl,1,FALSE);

  /* The single argument is the integer 1930: */
  a_setintelem(argl,0,1930,FALSE);

  /* Call the function: */
  a_callfunction(c,s,fn,argl,FALSE);

  /* Scan the result: */
  while(!a_eos(s))
    {
      char host[50];

      a_getrow(s,row,FALSE); 
      a_getstringelem(row,0,host,sizeof(host),FALSE); 
      printf("Host of year 1930: %s\n",host);
      a_nextrow(s,FALSE);    
    }
  a_closescan(s,FALSE);
  
  /****************/
  /*** Finalize ***/
  /****************/

  free_tuple(row);
  free_tuple(argl);
  free_scan(s);
  free_connection(c);
  free_oid(fn);
  return 0;
}
