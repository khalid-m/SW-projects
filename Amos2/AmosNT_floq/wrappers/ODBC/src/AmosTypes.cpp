/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 1999 Timour Katchaounov, EDSLAB
 * $RCSfile: AmosTypes.cpp,v $
 * $Revision: 1.1 $ $Date: 2003/05/19 12:24:46 $
 * $State: Exp $ $Locker:  $
 *
 * Description: AMOS <--> ODBC type converision. Could be implemented in Lisp
 *				or OSQL
 ****************************************************************************/


#include "AmosTypes.h"

#include <windows.h>
#include <sql.h>
#include <src\dtconv.h>
#include <odbc++\types.h>

using namespace amos;
using namespace odbc;


AmosTypes::AmosTypes() {
	m_AmosTypes.insert(tIntToString::value_type(STRINGTYPE,	"charstring"));
	m_AmosTypes.insert(tIntToString::value_type(INTEGERTYPE,"integer"));
	m_AmosTypes.insert(tIntToString::value_type(REALTYPE,	"real"));
	m_AmosTypes.insert(tIntToString::value_type(BINARYTYPE,	"binary"));
}


// static
void AmosTypes::sqlToAmos(int sqlType, objtype* amosType)  {
	switch (sqlType) {
	case SQL_LONGVARCHAR:	// variable length, huge
	case SQL_VARCHAR:		// variable length less than 256
	case SQL_CHAR:			// fixed length
		// TODO: map all these to a proper AMOS type
	case ODBC3_C(SQL_TYPE_DATE,SQL_DATE):
	case ODBC3_C(SQL_TYPE_TIME,SQL_TIME):
	case ODBC3_C(SQL_TYPE_TIMESTAMP,SQL_TIMESTAMP):
		(*amosType) = STRINGTYPE;
		break;

	case SQL_INTEGER:
	case SQL_SMALLINT:
	case SQL_TINYINT:
	case SQL_NUMERIC:		// (precision,scale)
	case SQL_DECIMAL:		// (precision,scale)
	case SQL_BIT:
		(*amosType) = INTEGERTYPE;
		break;

	case SQL_FLOAT:
	case SQL_DOUBLE:
	case SQL_REAL:
		(*amosType) = REALTYPE;
		break;

	case SQL_BINARY:
	case SQL_VARBINARY:		// variable length less than 256
	case SQL_LONGVARBINARY:	// variable length, huge
		(*amosType) = BINARYTYPE;
		break;
	default:
		throw SQLException("[OdbcAmos]: Illegal SQL type " + intToString(sqlType));
	}
}

// static
string AmosTypes::amosTypeName(int amosType) {
	tIntToString::iterator it;

	it = m_AmosTypes.find(amosType);
	if (it != m_AmosTypes.end())
		return (*it).second;

	throw SQLException("[OdbcAmos]: Illegal AMOS type " + intToString(amosType));

#ifdef _MSC_VER
	return NULL;    // to shut up stupid MSVC
#endif
}

// static
/*****************************************************************************
* The principle is to return the "biggest" type, so that we can send any value
* safely.
* TODO: the way size is treated is not nice - sometimes set, sometimes not ...
*****************************************************************************/
void AmosTypes::amosToSql(int amosType, int* sqlType, int* precision, int* scale) {
	switch (amosType) {
	case STRINGTYPE:
		(*sqlType) = SQL_VARCHAR;
		(*scale) = 0;
		break;

	case INTEGERTYPE:
		(*sqlType) = SQL_INTEGER;
		(*precision) = sizeof(int);
		(*scale) = 0;
		break;

	case REALTYPE:
		(*sqlType) = SQL_DOUBLE;
		(*precision) = sizeof(double);
		(*scale) = 0;
		break;

	case BINARYTYPE:
		(*sqlType) = SQL_BINARY;
		(*scale) = 0;
		break;

	default:
		throw SQLException("[OdbcAmos]: Illegal AMOS type " + intToString(amosType));
	}
}

