//////////////////////////////////////////////////////////////////////////
//
// FILE: BINDCOLS.C
//
#include  <windows.h>
#include  "odbc_lib\sql.h"
#include  "odbc_lib\sqlext.h"
#include  <string.h>
#include  <stdlib.h>
#include  "util.h"   

///////////////////////////////////////////////////////////////////////////
//
// BindAllCols
//
// This function binds all the columns within a result set.  As input
// the function takes an array of ColumnDescriptors.  It will bind the
// columns based an the descriptor information.  The bound buffers are
// returned in an array of pointers.
//
RETCODE BindAllCols
(
	HSTMT			hstmt,		// Statement to bind
	SWORD			iNumCols,	// Number of columns in the descriptor array
	ColumnDescriptor	*pColumns,	// Column descriptors
	BoundColumn		**ppBound	// Returns bound column descriptors
)
{
	RETCODE		rc = SQL_SUCCESS;
	SWORD		iColumn;
	BoundColumn	*pBoundCol;
	SDWORD		cbValueMax;
	
// Allocate a bound column descriptor for each column.

	if(iNumCols > 0) {
		pBoundCol = (BoundColumn *)calloc(iNumCols, sizeof(BoundColumn));
	}

// Bind every described column.

	for(iColumn = 0;
		iColumn < iNumCols && RETCODE_IS_SUCCESSFUL(rc);
		iColumn++) {

// Save the bound colum column number.

		pBoundCol[iColumn].iCol = pColumns[iColumn].iCol;	

// Get the SQL_C type and the length of the data buffer.

		switch(pColumns[iColumn].fType) {
		case SQL_LONGVARCHAR:
		case SQL_VARCHAR:
		case SQL_CHAR:
		case SQL_NUMERIC:
		case SQL_DECIMAL:
		case SQL_BIGINT:
                case SQL_DATE:
               // case SQL_TIMESTAMP:
			pBoundCol[iColumn].fSqlCType = SQL_C_CHAR;
			cbValueMax =min( pColumns[iColumn].iLength +2,
                                     SQL_MAX_BUFFER_LEN);
                                 /* min(
				((pColumns[iColumn].bExtendedInfo) ?
					pColumns[iColumn].iLength :
					(pColumns[iColumn].cbColDef + 2) + 1),
				SQL_MAX_BUFFER_LEN); */
                 	break;

		case SQL_INTEGER:
			if(pColumns[iColumn].bUnsigned) {
				pBoundCol[iColumn].fSqlCType = SQL_C_ULONG;
				cbValueMax = sizeof(UDWORD);
			}
			else {
				pBoundCol[iColumn].fSqlCType = SQL_C_SLONG;
				cbValueMax = sizeof(SDWORD);
			}
			break;

		case SQL_SMALLINT:
			if(pColumns[iColumn].bUnsigned) {
				pBoundCol[iColumn].fSqlCType = SQL_C_USHORT;
				cbValueMax = sizeof(UWORD);
			}
			else {
				pBoundCol[iColumn].fSqlCType = SQL_C_SSHORT;
				cbValueMax = sizeof(SWORD);
			}
			break;

		case SQL_FLOAT:
		case SQL_DOUBLE:
			pBoundCol[iColumn].fSqlCType = SQL_C_DOUBLE;
			cbValueMax = sizeof(SDOUBLE);
			break;

		case SQL_REAL:
			pBoundCol[iColumn].fSqlCType = SQL_C_FLOAT;
			cbValueMax = sizeof(SFLOAT);
			break;

	       //	case SQL_DATE:
	       //		pBoundCol[iColumn].fSqlCType = SQL_C_DATE;
	       //		cbValueMax = sizeof(DATE_STRUCT);
	       //		break;

		case SQL_TIME:
			pBoundCol[iColumn].fSqlCType = SQL_C_TIME;
			cbValueMax = sizeof(TIME_STRUCT);
			break;

		case SQL_TIMESTAMP:
			pBoundCol[iColumn].fSqlCType = SQL_C_CHAR;
			cbValueMax = sizeof(TIMESTAMP_STRUCT)+5;
			break;

		case SQL_BINARY:
		case SQL_VARBINARY:
		case SQL_LONGVARBINARY:
			pBoundCol[iColumn].fSqlCType = SQL_C_BINARY;
			cbValueMax = min(pColumns[iColumn].cbColDef,
				SQL_MAX_BUFFER_LEN);
			break;

		case SQL_TINYINT:
			if(pColumns[iColumn].bUnsigned) {
				pBoundCol[iColumn].fSqlCType = SQL_C_UTINYINT;
				cbValueMax = sizeof(UCHAR);
			}
			else {
				pBoundCol[iColumn].fSqlCType = SQL_C_STINYINT;
				cbValueMax = sizeof(SCHAR);

			}
			break;

		case SQL_BIT:
			pBoundCol[iColumn].fSqlCType = SQL_C_BIT;
			cbValueMax = sizeof(UCHAR);

		default:
			pBoundCol[iColumn].fSqlCType = SQL_C_DEFAULT;
			cbValueMax = pColumns[iColumn].cbColDef;
		}

// Allocate the bind buffer.

		pBoundCol[iColumn].pBuffer = malloc((SWORD)cbValueMax);


		rc = SQLBindCol(hstmt, pBoundCol[iColumn].iCol,
			pBoundCol[iColumn].fSqlCType, pBoundCol[iColumn].pBuffer,
			cbValueMax, &pBoundCol[iColumn].cbValue);

	}

// Return the bound descriptors.

	if(RETCODE_IS_SUCCESSFUL(rc)) {
		*ppBound = pBoundCol;
	}

	return rc;
}


///////////////////////////////////////////////////////////////////////////////////
//////          TypeOfCol ////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
void TypeOfCol
(
              int tipo,
              char *string
)
{
 switch(tipo) {
 case SQL_LONGVARCHAR: strcpy(string,"SQL_LONGVARCHAR");break;
 case SQL_VARCHAR: strcpy(string,"SQL_VARCHAR");break;
 case SQL_CHAR:  strcpy(string,"SQL_CHAR");break;
 case SQL_NUMERIC: strcpy(string,"SQL_NUMERIC");break;
 case SQL_DECIMAL: strcpy(string,"SQL_DECIMAL");break;
 case SQL_BIGINT: strcpy(string,"SQL_BIGINT");break;
 case SQL_DATE:  strcpy(string,"SQL_DATE");break;
 case SQL_INTEGER: strcpy(string,"SQL_INTEGER");break;
 case SQL_SMALLINT:strcpy(string,"SQL_SMALLINT");break;
 case SQL_FLOAT: strcpy(string,"SQL_FLOAT");break;
 case SQL_DOUBLE:strcpy(string,"SQL_DOUBLE");break;
 case SQL_REAL:strcpy(string,"SQL_REAL");break;
 case SQL_TIME: strcpy(string,"SQL_TIME");break;
 case SQL_TIMESTAMP:  strcpy(string,"SQL_TIMESTAMP");break;
 case SQL_BINARY: strcpy(string,"SQL_BINARY");break;
 case SQL_VARBINARY: strcpy(string,"SQL_VARBINARY");break;
 case SQL_LONGVARBINARY:strcpy(string,"SQL_LONGVARBINARY");break;
 case SQL_TINYINT:strcpy(string,"SQL_TINYINT");break;
 case SQL_BIT:strcpy(string,"SQL_BIT");break;
 default:strcpy(string,"SQL DATA TYPE cannot be determined");break;
	}
}
