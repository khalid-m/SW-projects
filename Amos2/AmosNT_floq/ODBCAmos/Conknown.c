//////////////////////////////////////////////////////////////////////////
//
// FILE: CONKNOWN.C
//
#include  <windows.h>
#include  "odbc_lib\sql.h"
#include  "odbc_lib\sqlext.h"
#include  <string.h>
#include  <stdio.h>
#include  "util.h"

        
/////////////////////////////////////////////////////////////////////////
//
// LookForDSN
//
//	This function allows a user to select one of the data sources
//      opened with the function ODBCSOURCE
//                                  
// ///////////////////////////////////////////////////////////////////////////
BOOL LookForEntry
(
        queue *pTheQueue,               // Pointer to the queue of the data source opened
        char *szDSN,                    // the Data source name to connect to
        member **pActive                /* member of the queue with the informations of the
                                           data source we wish  to  connect to */
)
{
        BOOL tofind=TRUE;
        member *pMember;

   /* look for the DSN passed with the function(szDSN) in the queue */
   pMember=pTheQueue->front;
   while(pMember!=NULL && tofind) {
	if(strcmp((char*)szDSN,(char*)pMember->data->names[0]) == 0) {
                       tofind = FALSE;
        }
        else {
           pMember=pMember->next;
         }
   }



   if(!tofind) {  /* found the data source we wish to connect to */
                *pActive=pMember;
                 return(TRUE);

	}
	else {
                 //printf("DSN %s NOT OPENED\n",szDSN);

             return(FALSE);

	}
}
