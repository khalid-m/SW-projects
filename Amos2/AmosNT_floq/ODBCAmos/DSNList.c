//////////////////////////////////////////////////////////////////////////
//
// FILE: DSNList.C
//


#include  <windows.h>
#include  <stdio.h>
#include  "odbc_lib\sql.h"
#include  "odbc_lib\sqlext.h"
#include  <string.h>

#include  "util.h"

///////////////////////////////////////////////////////////////////////
///       PrintDSN
//////////////////////////////////////////////////////////////////////
void PrintDSN
(
	 DataSourceInfo     *pstDSNArray,	// A pointer to return an array
	 SWORD		      ciDSN	        // Returned number of DSN
)
{
int i;
printf("         DSN                                  DESCRIPTION \n");
  for(i=0;i<ciDSN;i++) {
      printf("%-35s%30s\n",pstDSNArray[i].szDSN,pstDSNArray[i].szDescription);
  }
}
///////////////////////////////////////////////////////////////////////
///       IsThereDSN
//////////////////////////////////////////////////////////////////////
BOOL IsThereDSN
(
         DataSourceInfo     *pstDSNArray,	// A pointer to return an array
	 SWORD		      ciDSN,	        // The number of DSN
         char               *strin
)
{
int i;
BOOL find = TRUE;
for(i=0;i<ciDSN && find ;i++){
                printf("Strinfa : %s\n",strin);
                printf("Strinfa : %s\n",pstDSNArray[i].szDSN);
            if(strcmp((char*)pstDSNArray[i].szDSN, strin) == 0){
                     find = FALSE;
        }
     }
return TRUE;

}
//////////////////////////////////////////////////////////////////////
//
// BuildDSN
//
// This function builds an array of DSN info's, one for each
// data source returned by SQLDataSource.
//
BOOL BuildDSN
(
	HENV 		henv,            	// Application's environment
	DataSourceInfo     **ppstDSNArray,	// A pointer to return an array
	SWORD		*pciDSN	           	// Returned number of DSN
)
{
	RETCODE	rc;
	UWORD	fDirection;	// The direction to fetch flag
	UCHAR	szDSN[SQL_MAX_DSN_LENGTH+1];	// The DSN name
	UCHAR	szDescription[255];	// Description returned froom sqldatasources
	SWORD	cbDSN;	                // Number of bytes returned
	SWORD	cbDescription;		// Number of bytes returned

	*ppstDSNArray = NULL;
	*pciDSN = 0;

// Fetch the first DSN in the list.

	fDirection = SQL_FETCH_FIRST;

	do {

		rc = SQLDataSources(henv, fDirection, szDSN,sizeof(szDSN),
			&cbDSN, szDescription, sizeof(szDescription), &cbDescription);

// Did a driver name and attributes get returned?

		if(RETCODE_IS_SUCCESSFUL(rc)) {

// Add an entry to the array.

			*ppstDSNArray = realloc(*ppstDSNArray,
				++(*pciDSN) * sizeof(DataSourceInfo));

// Copy the name of DSN.

			strcpy((char*)((*ppstDSNArray)[(*pciDSN) - 1].szDSN),
				(char*)szDSN);

                         strcpy((char*)((*ppstDSNArray)[(*pciDSN) - 1].szDescription),
				(char*)szDescription);


// Fetch the next Driver.

			fDirection = SQL_FETCH_NEXT;
		}
		else if(rc != SQL_NO_DATA_FOUND){

// There was some type of error.

			return FALSE;
		}

	}
    	while(rc != SQL_NO_DATA_FOUND);

	return TRUE;
}


