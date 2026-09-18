//////////////////////////////////////////////////////////////////////////
//
// FILE: DESCCOL.C
//
#include  <windows.h>
#include  "odbc_lib\sql.h"
#include  "odbc_lib\sqlext.h"
#include  <string.h>
#include  <stdlib.h>
#include  <stdio.h>
#include  "util.h"   

/////////////////////////////////////////////////////////////////////////////
//
// GetColDescriptors
//
// This function retrieves a ColumnDescriptor for each column within a 
// result.  The flag bExtendedAttrs tells the function if it should
// get the additional attributes available from SQLColAttributes.  If the
// flag is FALSE, then only SQLDescribeCol is called.
//
RETCODE GetColDescriptions
(
	HSTMT			hstmt,			// The statement to describe cols for
	BOOL			bExtendedAttrs,		// Return SQLColAttribute information
	SWORD			*piColCount,		// Returns the number of columns
	ColumnDescriptor	**ppColDescriptors	// Returns an array of column descriptors
)
{
	RETCODE			rc;
	ColumnDescriptor    	*pColDesc = NULL;
	SWORD			iColumn;
	SDWORD			iIntegerValue;
	SWORD			cbDesc;

// Get the number of columns in the result set.

	rc = SQLNumResultCols(hstmt, piColCount);

// Allocate an array of column descriptors, one for each column in the 
// the result set.

	if(RETCODE_IS_SUCCESSFUL(rc) && *piColCount > 0) {
		pColDesc = (ColumnDescriptor *)
			calloc(*piColCount, sizeof(ColumnDescriptor));
	}
	else {
		*piColCount = 0;
	}

// Fill in the descriptor for every column.

	for(iColumn = 0; 
		iColumn < *piColCount && RETCODE_IS_SUCCESSFUL(rc); 
		iColumn++) {

// Save the column number.
		
		pColDesc[iColumn].iCol = iColumn + 1;
		
// Call SQLDescribeCol to get the basic information.
		
		rc = SQLDescribeCol(hstmt, iColumn + 1, 
			pColDesc[iColumn].szColName,
			sizeof(pColDesc[iColumn].szColName),
			&cbDesc, &pColDesc[iColumn].fType,
			&pColDesc[iColumn].cbColDef,
			&pColDesc[iColumn].ibScale,
			&pColDesc[iColumn].fNullable);


// Did the caller request extended information also?

		if(RETCODE_IS_SUCCESSFUL(rc) && bExtendedAttrs) {

			pColDesc[iColumn].bExtendedInfo = TRUE;

// Call SQLColAttributes to get the aditional information

// Autoincrement
			rc = SQLColAttributes(hstmt, iColumn + 1,
				SQL_COLUMN_AUTO_INCREMENT, NULL, 0, NULL,
				&iIntegerValue);

		    if(RETCODE_IS_SUCCESSFUL(rc)) {
			    pColDesc[iColumn].bAutoIncrement =
				    (iIntegerValue == TRUE);
// Case sensitive
			    rc = SQLColAttributes(hstmt, iColumn + 1,
				    SQL_COLUMN_CASE_SENSITIVE, NULL, 0, NULL,
				    &iIntegerValue);
		    }

		    if(RETCODE_IS_SUCCESSFUL(rc)) {
			    pColDesc[iColumn].bCaseSensitive =
				    (iIntegerValue == TRUE);
// Display size
			    rc = SQLColAttributes(hstmt, iColumn + 1,
				    SQL_COLUMN_DISPLAY_SIZE, NULL, 0, NULL,
				    &pColDesc[iColumn].iDisplaySize);

		    }

		    if(RETCODE_IS_SUCCESSFUL(rc)) {

// Column Label

			    rc = SQLColAttributes(hstmt, iColumn + 1,
				    SQL_COLUMN_LABEL,
				    pColDesc[iColumn].szColumnLabel,
				    sizeof(pColDesc[iColumn].szColumnLabel),
				    &cbDesc, NULL);
		    }

		    if(RETCODE_IS_SUCCESSFUL(rc)) {
// Length
			    rc = SQLColAttributes(hstmt, iColumn + 1,
				    SQL_COLUMN_LENGTH, NULL, 0, NULL,
				    &pColDesc[iColumn].iLength);
		    }
// Money
		    if(RETCODE_IS_SUCCESSFUL(rc)) {
			    rc = SQLColAttributes(hstmt, iColumn + 1,
				    SQL_COLUMN_MONEY, NULL, 0, NULL,
				    &iIntegerValue);
		    }

		    if(RETCODE_IS_SUCCESSFUL(rc)) {
			    pColDesc[iColumn].bMoney = (iIntegerValue == TRUE);
// Owner name
			    rc = SQLColAttributes(hstmt, iColumn + 1,
				    SQL_COLUMN_OWNER_NAME,
				    pColDesc[iColumn].szOwnerName,
				    sizeof(pColDesc[iColumn].szOwnerName),
				    &cbDesc, NULL);
		    }
// Qualifier
		    if(RETCODE_IS_SUCCESSFUL(rc)) {
			    rc = SQLColAttributes(hstmt, iColumn + 1,
				    SQL_COLUMN_QUALIFIER_NAME,
				    pColDesc[iColumn].szQualifier,
				    sizeof(pColDesc[iColumn].szQualifier),
				    &cbDesc, NULL);
		    }
// Searchable
		    if(RETCODE_IS_SUCCESSFUL(rc)) {
			    rc = SQLColAttributes(hstmt, iColumn + 1,
				    SQL_COLUMN_SEARCHABLE,
				    NULL, 0, NULL, &pColDesc[iColumn].fSearchable);
		    }
// Table name
		    if(RETCODE_IS_SUCCESSFUL(rc)) {
			    rc = SQLColAttributes(hstmt, iColumn + 1,
				    SQL_COLUMN_TABLE_NAME,
				    pColDesc[iColumn].szTableName,
				    sizeof(pColDesc[iColumn].szTableName),
				    &cbDesc, NULL);
		    }
// Type name
		    if(RETCODE_IS_SUCCESSFUL(rc)) {
			    rc = SQLColAttributes(hstmt, iColumn + 1,
				    SQL_COLUMN_TYPE_NAME,
				    pColDesc[iColumn].szTypeName,
				    sizeof(pColDesc[iColumn].szTypeName),
				    &cbDesc, NULL);
		    }
// Unsigned
		    if(RETCODE_IS_SUCCESSFUL(rc)) {
			    rc = SQLColAttributes(hstmt, iColumn + 1,
				    SQL_COLUMN_UNSIGNED, NULL, 0, NULL,
				    &iIntegerValue);
		    }
// Updateable
		    if(RETCODE_IS_SUCCESSFUL(rc)) {

			    pColDesc[iColumn].bUnsigned =
				    (iIntegerValue == TRUE);

			    rc = SQLColAttributes(hstmt, iColumn + 1,
				    SQL_COLUMN_UPDATABLE,
				    NULL, 0, NULL,
				    &pColDesc[iColumn].fUpdatable);
		    }
	    }
	    else {
		    pColDesc[iColumn].bExtendedInfo = FALSE;
	    }
	 }

// Return the descriptor array.

	*ppColDescriptors = pColDesc;

	return rc;
}

