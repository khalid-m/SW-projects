/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 1999 Timour Katchaounov, EDSLAB
 * $RCSfile: AmosTypes.h,v $
 * $Revision: 1.2 $ $Date: 2003/05/20 13:50:21 $
 * $State: Exp $ $Locker:  $
 *
 * Description: AMOS <--> ODBC type converision. Could be implemented in Lisp
 *				or OSQL
 ****************************************************************************/
#ifndef _AmosTypes_h
#define _AmosTypes_h

// disable the 'identifier name truncated in debug info' warning
# pragma warning(disable:4786)

#include <map>
#include <string>
#include <callin.h>
#include <storage.h>

using namespace std;

namespace amos {

typedef map<int, string> tIntToString;

/*****************************************************************************
* Purpose: AMOS <--> ODBC type converision.
*****************************************************************************/
class AmosTypes {
public:
	AmosTypes();

	// type conversion between  AMOS and SQL types
	static void			sqlToAmos(int sqlType, objtype* amosType);
	static void			amosToSql(int amosType, int* sqlType, int* precision, int* scale);
	// getting type names
	//static string		amosTypeName(int amosType);
	string		amosTypeName(int amosType);
	//static const char*	sqlTypeName(int sqlType);

	// object type conversion
	/*
	inline static objtype	getType(a_tuple tup, int idx);
	inline static string	getString(a_tuple tup, int idx);
	inline static int		getInt(a_tuple tup, int idx);
	inline static double	getDouble(a_tuple tup, int idx);
	//inline static ???		getBinary(a_tuple tup, int idx);
	*/
	inline objtype	getType(a_tuple tup, int idx);
	inline string	getString(a_tuple tup, int idx);
	inline int		getInt(a_tuple tup, int idx);
	inline double	getDouble(a_tuple tup, int idx);
private:
	//static tIntToString		m_AmosTypes;
	tIntToString		m_AmosTypes;
};



/*****************************************************************************
* Inlines
*****************************************************************************/
inline objtype AmosTypes::getType(a_tuple tup, int idx) {
	return a_getelemtype(tup, idx, FALSE);
}

inline string AmosTypes::getString(a_tuple tup, int idx) {
	char*	pBuf;
	string	strResult;
	int		size = 0;

	size = a_getelemsize(tup, idx, FALSE);
	pBuf = (char*) malloc(size); // allocate space for the current string
	a_getstringelem(tup, idx, pBuf, size, FALSE);
	strResult = pBuf;

	return strResult;
}

inline int AmosTypes::getInt(a_tuple tup, int idx) {
	 return a_getintelem(tup, idx, FALSE);
}

inline double AmosTypes::getDouble(a_tuple tup, int idx) {
	return a_getdoubleelem(tup, idx, FALSE);
}

/* TODO: handle this
??? AmosTypes::getBinary(a_tuple tup, int idx) {
	return a_getelem(tup, idx, FALSE);
}
*/

}

#endif
