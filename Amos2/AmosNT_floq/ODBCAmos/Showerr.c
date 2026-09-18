//////////////////////////////////////////////////////////////////////////
//
// FILE: SHOWERR.C
//

#include <windows.h>
#include <stdio.h>
#include "odbc_lib\sql.h"
#include "odbc_lib\sqlext.h"
#include "util.h"
#include <string.h>

/////////////////////////////////////////////////////////////////////////
//
// ShowError
//
// This function calls SQLError and pops all the errors off of the error
// stack.  It calls a stub function called show error to display the
// native error message to the user.  The function returns the upper
// most SQLSTATE to the calling function.
//        
void ShowError
(
	HENV 	henv,		// The application's environment handle
	HDBC 	hdbc,		// The hdbc the error happend on
	HSTMT 	hstmt,		// Statement handle the error happened on
	UCHAR 	*pszSqlState[6]	// The returning SQLSTATE (must be 6 bytes)
)
{
	UCHAR	szSqlState[6];
	SDWORD	fNativeError;
	UCHAR	szErrorMsg[SQL_MAX_MESSAGE_LENGTH + 1];
	SWORD	cbErrorMsg;
	RETCODE	rc;


// Call SQLError an retrieve the error information.  Do this in a loop just
// in case it returns more than one piece of information.  Set rc to
// SQL_SUCCESS and loop until SQLError returns SQL_NO_DATA_FOUND.

      //	rc = SQL_SUCCESS;

	rc = SQLError(henv, hdbc, hstmt, szSqlState, &fNativeError,
		szErrorMsg, sizeof(szErrorMsg), &cbErrorMsg);

// Copy the SQLSTATE to the returning buffer.

	memcpy(pszSqlState, szSqlState,sizeof(pszSqlState));

	while(rc != SQL_NO_DATA_FOUND) {

// Show the native error message to the user.

	printf("Error message :\n%s\n",szErrorMsg);


      //  DISPLAY_ERRROR_MESSAGE(szErrorMsg);

// Call SQLError again.

		rc = SQLError(henv, hdbc, hstmt, szSqlState, &fNativeError,
			szErrorMsg,
            sizeof(szErrorMsg),
            &cbErrorMsg);
    	}  
}
