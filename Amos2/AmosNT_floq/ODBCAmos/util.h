////////////////////////////////////////////////////////////////////////////
//
// FILE: UTIL.H
//
//	This file defines some handy macros, functions, and structures for 
//	use in your ODBC programs
//
                
//////////////////////////////////////////////////////////////////////////
//  M A C R O S
//////////////////////////////////////////////////////////////////////////


#ifndef __UTIL
#define __UTIL
// Helpful macros to check function return codes.
//
#define RETCODE_IS_FAILURE(x)	((x) == SQL_ERROR  || \
				(x) == SQL_INVALID_HANDLE || \
				(x) == SQL_STILL_EXECUTING)

#define RETCODE_IS_SUCCESSFUL(x)	((x) == SQL_SUCCESS || \
				(x)  == SQL_SUCCESS_WITH_INFO)
                                 
// A define for maximum string lengths used in ODBC programming.
//
#define SQL_MAX_IDENTIFIER_LEN	128     
#define SQL_MAX_BUFFER_LEN		64000L
#define MAX_QUERY_LENGTH            500  // Max length of a query
        
// Column positions for SQLGetTypeInfo result set.
//
#define SQL_SQLGETTYPEINFO_COL_TYPE_NAME		1
#define SQL_SQLGETTYPEINFO_COL_DATA_TYPE		2
#define SQL_SQLGETTYPEINFO_COL_PRECISION		3
#define SQL_SQLGETTYPEINFO_COL_LITERAL_PREFIX		4	
#define SQL_SQLGETTYPEINFO_COL_LITERAL_SUFFIX		5
#define SQL_SQLGETTYPEINFO_COL_CREATE_PARAMS		6
#define SQL_SQLGETTYPEINFO_COL_NULLABLE			7
#define SQL_SQLGETTYPEINFO_COL_CASE_SENSITIVE		8
#define SQL_SQLGETTYPEINFO_COL_SEARCHABLE		9
#define SQL_SQLGETTYPEINFO_COL_UNSIGNED_ATTRIBUTE	10
#define SQL_SQLGETTYPEINFO_COL_MONEY			11
#define SQL_SQLGETTYPEINFO_COL_AUTO_INCREMENT		12
#define SQL_SQLGETTYPEINFO_COL_LOCAL_TYPE_NAME		13
#define SQL_SQLGETTYPEINFO_COL_MINIMUM_SCALE		14
#define SQL_SQLGETTYPEINFO_COL_MAXIMUM_SCALE		15

//////////////////////////////////////////////////////////////////////////  
//   T Y P E S   A N D   S T R U C T U R E S
//////////////////////////////////////////////////////////////////////////

// Define a structure to hold a data source name and description. 
//
typedef struct stConne {
      SQLCHAR          names[3][SQL_MAX_DSN_LENGTH+1];
      HDBC             hdbc;
} Conne;

typedef struct X member;


typedef struct X {
		member *next;
		Conne  *data;
}  member;


typedef struct {
		member *front;
            member *back;
		int    number;
} queue;



typedef struct stDataSourceInfo {
	UCHAR	szDSN[SQL_MAX_DSN_LENGTH + 1];	// The DSN
	UCHAR	szDescription[256];		// The DSNs description
      UCHAR szUSR[SQL_MAX_DSN_LENGTH +1];   //The username
      UCHAR szPWD[SQL_MAX_DSN_LENGTH +1];   // The password
} DataSourceInfo;

// Define a structure to hold a driver's information.
//
typedef struct stDriverInfo {
	UCHAR	szDriver[256];		// driver name
	DWORD	fFileUsage;		// file usage flag
	UCHAR	szFileExtns[256];	// list of file masks
	DWORD	fDirectConnect;	// does the driver support SQLDriverConnect
} DriverInfo;

// A structure to describe a column to create
//
typedef struct stCreateColumnDescriptor {
	UCHAR	szColumnName[SQL_MAX_IDENTIFIER_LEN + 1];	// The column name
	SWORD	iType;						// The SQL_type
	SDWORD	iPrecision;					// The precision for the data
	SWORD	iScale;						// The Scale for the data
	BOOL		bRequired;				// Must column be NOT NULL
	BOOL		bUnsigned;				// Must the type be unsigned
	BOOL		bMoney;					// Must the type be money
	BOOL		bAutoIncrement;				// Must the type be autoincrement
} CreateColumnDescriptor;

// A structure to describe a table to create
//
typedef struct stCreateTableDescriptor {
	UCHAR				szTableName[SQL_MAX_IDENTIFIER_LEN + 1];	// Name of the table to create
	UWORD				iNumColumns;					// Number of columns within the table
	CreateColumnDescriptor	*prgColumns;						// The columns to create
} CreateTableDescriptor;

typedef struct stTypeInfo {
	UCHAR			szTypeName[SQL_MAX_IDENTIFIER_LEN + 1];	// The name of the type
	SWORD			fType;					// The SQL type
	BOOL				bPrecision;			// Does the type need a precision?
	BOOL				bScale;				// Does the type need a scale?
	SDWORD			iMaxPrecision;				// The max precision for the type
	BOOL				bRequired;			// Must type be NOT NULL
	BOOL				bUnsigned;			// Is type unsigned?
	BOOL				bMoney;				// Is type money?
	BOOL				bAutoIncrement;			// Is type autoincrement?
	SWORD			iMinScale;				// Smallest scale
	SWORD			iMaxScale;				// Largest scale
	struct stTypeInfo	*prgNext;				// Next type
} TypeInfo;

typedef struct stColumnDescriptor {

// Standard information returned by SQLDescribeCol

	UCHAR	szColName[SQL_MAX_IDENTIFIER_LEN + 1];	// Column name
	UWORD	iCol;					// Column number
	SWORD	fType;					// SQL type
	UDWORD	cbColDef;				// Precision
	SWORD	ibScale;				// Scale
	SWORD	fNullable;				// Is column nullable?

// what follows is information returned by SQLGetColAttributes

	BOOL	bExtendedInfo;				// Does the structure contain the extra info?
	BOOL	bAutoIncrement;				// Is column auto incrementing?
	BOOL	bCaseSensitive;				// Is column case sensitive?
	SDWORD	iDisplaySize;				// The display size
	UCHAR	szColumnLabel[SQL_MAX_IDENTIFIER_LEN + 1]; // Label
	SDWORD	iLength;				// Length of the data transfered
	BOOL	bMoney;					// Is type money?
	UCHAR	szOwnerName[SQL_MAX_IDENTIFIER_LEN + 1]; // Owner name
	UCHAR	szQualifier[SQL_MAX_IDENTIFIER_LEN + 1]; // Qualifier
	SDWORD	fSearchable;				// Flags for WHERE clause use
	UCHAR	szTableName[SQL_MAX_IDENTIFIER_LEN + 1]; // Table name
	UCHAR	szTypeName[SQL_MAX_IDENTIFIER_LEN + 1];	// Type name
	BOOL	bUnsigned;				// Is column unsigned?
	SDWORD	fUpdatable;				// Flags for update ability

// this information is used for SQLExtendedFetch routines

	SDWORD	iOffset;		// Offset in the record buffer
	SDWORD	*pcbValue;		// Pointer to the cbValue in the buffer
} ColumnDescriptor;

typedef struct stBoundColumn {
	UWORD	iCol;			// Column number
	SWORD	fSqlCType;		// SQL C type
	PTR	pBuffer;		// Storage
	SDWORD	cbValue;		// Returned cbvalue after fetch
} BoundColumn;

typedef struct stExtendedFetch {
	UDWORD			iPageSize;
	PTR			pRecordBuffer;
	UDWORD			iRecordSize;
	SWORD			iNumCols;
	ColumnDescriptor	*pColDesc;
	UWORD			*prgfRowStatus;
} ExtendedFetch;

typedef struct stmtarray {
        char* sqlstring;
        HSTMT hstmt;
} StmtArray;


//////////////////////////////////////////////////////////////////////////
//  F U N C T I O N S
//////////////////////////////////////////////////////////////////////////


queue * newQueue(void);
member * newMember(const Conne *const dataValue);
void add(const Conne *const dataValue, queue *const aQueue);
void outOfStorage(void);
///////////////////////////////////////////////////////////////////////////
//
//     ConnectToKnownDataSources
//
////////////////////////////////////////////////////////////////////////////
BOOL ConnectToKnownDataSources(
	HENV henv,	  	// The application's environment handle
        queue *pTheQueue,       //  Pointer to the list od DSNs
        char *szDSN,            // the Data source name to connect to
        member **pActive        // pointer to return the active DSN
);

////////////////////////////////////////////////////////////////////
//
// BuildDSN
//
// This function builds an array of DataSourceInfo's,  one for
// each DSN returned by SQLDataSources.
//
BOOL BuildDSNList(
	HENV 		henv, 		// Application's environment handle
	DataSourceInfo **ppstDSNArray,	// Pointer to return array in
	SWORD 		*pciDSN		// Count of array elements
);

//////////////////////////////////////////////////////////////////////
//
// BuildDDN
//
// This function builds an array of DataSourceInfo's, one for each
// data source returned by SQLDataSources.
//
BOOL BuildDSN(
	HENV 		henv,            	// Application's environment
	DataSourceInfo     **ppstDriverArray,	// Returned driver array
	SWORD		*pciDriver		// Returned number of drivers
);

///////////////////////////////////////////////////////////////////////////
//
// AutoLogon
//
// This function allows the user to select a single-tier file to open
// and then it connects to the driver. The new connection handle,
// selected file and directory is returned to the calling function.
//
BOOL AutoLogon(
	HENV	henv,			// Application's environment handle
	HWND	hwnd,			// Parent's windows handle
	HDBC	*phdbc,			// If the user selects a file, this will
					// 	be allocated and connected.
	UCHAR 	*szTableName,  		// Selected table's name.
	UCHAR	*szDir,			// Directory where the table is.
	DWORD	*pfFileUsage		// What does the selected file represent?
);

/////////////////////////////////////////////////////////////////////////
//
// ShowError
//
// This function calls SQLError and pops all the errors of of the error
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
);

/////////////////////////////////////////////////////////////////////////////
//
// ClearStatement
//
// The function ClearStatement resets all column and parameter buffers and
// closes the cursor associated with the statement handle.  The statement
// handle is left in the allocated state so that it may be used again
// without being allocated again.
//
RETCODE ClearStatement
(
	HSTMT	hstmt	// The statement handle to clear
);

/////////////////////////////////////////////////////////////////////////////
//
// GetUserTables
//
// This function reterieves the current qualifier, a user's owner name, and
// calls SQLTables to retrieve the list of tables for a user.
//
RETCODE GetUserTable
(
	HDBC	hdbc,	// The connection to retrieve the list of tables from
	HSTMT	hstmt	// An allocated statement handle to return the
			// 	SQLTable result set on
);

/////////////////////////////////////////////////////////////////////////////
//
// GetTableColumns
//
// This function reterieves the columns within a given table name.  This
// function expects to receieve a qualfier name, an owner name, and table
// name so that the chances are the best to describe the columns
// within one table.
//
RETCODE GetTableColumns
(
	HSTMT	hstmt,		// An allocated statement handle to return
				// 	the SQLColumns result set in
	UCHAR	*pszQualifier,	// The qualifier name or NULL if not required
	UCHAR	*pszOwner,    	// The owner name or NULL if not required
	UCHAR	*pszTable	// The talbe name
);

/////////////////////////////////////////////////////////////////////////////
//
// CreateTable
//
// This function helps to create a table.  As input, the function takes a
// description of the table and its columns.  The column types are expressed
// as SQL types.  The function then looks at SQLGetTypeInfo to see if that
// type exists.  If it does not, it finds a type that is compatible to the
// type wanted.  For example, iF the columns requested type is SQL_INTEGER, then
// SQL_BIGINT, SQL_DECIMAL, SQL_NUMERIC, SQL_FLOAT, SQL_DOUBLE, and SQL_REAL
// can also hold an integer value if the data souce does not support
// SQL_INTEGER.
//
BOOL CreateTable
(
	HDBC	hdbc,			// Connection to create the table on.
	CreateTableDescriptor *prgTable	// The structure that describes the
					// 	table to create
);

/////////////////////////////////////////////////////////////////////////////
//
// GetColDescriptors
//
// This function reterieves a ColumnDescriptor for each column within a
// result.  The flag bExtendedAttrs tells the function if it should
// get the additional attributes available from SQLColAttributes.  If the
// flat is FALSE, then only SQLDescribeCol is called.
//
RETCODE GetColDescriptions
(
	HSTMT			hstmt,			// The statement to describe cols for
	BOOL			bExtendedAttrs,		// Return SQLColAttribute information
	SWORD			*piColCount,		// Returns the number of columns
	ColumnDescriptor	**ppColDescriptors	// Returns an array of column descriptors
);

///////////////////////////////////////////////////////////////////////////
//
// BindAllCols
//
// This function binds all the columns within a result set.  As input,
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
);

/////////////////////////////////////////////////////////////////////////
//
// PrepareForExtendedFetch
//
// This function prepares a SQL statement for retrieval using
// SQLExtendedFetch.  The statement will be PREPARED, but not EXECUTED.
// It sets up the requested cursor and curency type, and sets up row-wise
// bound columns.  The bound column information is returned in the
// ExtendedFetch structure.  The offset of the column's data within the
// record buffer can be found in the ColumnDescriptor->iOffset member.
// All columns will be bound.
//
RETCODE PrepareForExtendedFetch
(
	HSTMT	hstmt,		// Statement to prepare
	UCHAR	*pszSqlStr,	// SQL statement
	SDWORD	cbSqlStr,	// # of bytes in the SQL string
	UDWORD	fConcurrency,	// Requested concurrency
	UDWORD	fCursor,	// Requested cursor
	UDWORD	iPageSize,	// Number of rows per page
	ExtendedFetch	*pExtInfo	// Extended fetch descriptor
);

/////////////////////////////////////////////////////////////////////////
//
// GetBookmark
//
// This function reterieves the bookmark for the current row.  This
// function should only be called after calling PrepareForExtendedFetch.
//
RETCODE GetBookmark
(
	HSTMT		hstmt,		// Statement to get the bookmark for
	SDWORD		*pvBookmark     // Returns the bookmark
);

//////////////////////////////////////////////////////////////////////
//
// DoExtendedFetch
//
// This function actually calls SQLExtendedFetch.
//
RETCODE DoExtendedFetch
(
	HSTMT		hstmt,		// Statement
	UWORD		fFetchType,	// What operation should be performed?
	SDWORD		iRow,		// Some row value
	ExtendedFetch	*pFetchDesc,	// The extended fetch descriptor
	UDWORD		*pcrow		// Returns # of rows fetched
);

//////////////////////////////////////////////////////////////////////////
//
// CheckOneRow
//
// This function makes sure that only one row is affected by a DELETE
// or UPDATE statment.  Before executing the statement, a transaction is
// started.  After the execution, the row count is reterieved.  If the
// number of rows is greated than one, the transaction is rolled back and
// the function returns FALSE.
//
BOOL CheckOneRow
(
	HENV		henv,	// Environment handle
	HDBC		hdbc,	// The connection handle
	HSTMT		hstmt	// A prepared DELETE or UPDATE statement
);

BOOL LookForEntry
(
        queue *pTheQueue,               // Pointer to the queue of the data source opened
        char *szDSN,                    // the Data source name to connect to
        member **pActive                /* member of the queue with the informations of the
                                           data source we wish  to  connect to */
);

void TypeOfCol
(
              int tipo,
              char *string
);

BOOL ods(char *strin);

void PrintDSN
(
	 DataSourceInfo     *pstDSNArray,	// A pointer to return an array
	 SWORD		      ciDSN	        // Returned number of DSN
) ;

#endif  /* #ifndef __UTIL */

