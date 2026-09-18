/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1999, 1998 Timour Katchaounov, Silvio Brandani, EDSLAB
 * $RCSfile: OdbcFunctions.cpp,v $
 * $Revision: 1.2 $ $Date: 2007/05/25 17:52:45 $
 * $State: Exp $ $Locker:  $
 *
 * Description: The Amos II (Lisp & OSQL) <--> ODBC interface functions.
 *
 * TODO:		- Add persistent connections.
 *				- Add class AmosException, and a mapping between exceptions
 *				  and amos errors.
 *				  use:
 *				  errno = a_register_error("some err message");
 *				  return a_error(errno, mkstring("ext. info"), FALSE);
 ****************************************************************************/
#include <windows.h>
#include <sql.h>
#include <sqlext.h>
#include <iostream>

// libodbc
#include <odbc++\setup.h>
#include <odbc++\connection.h>
#include <odbc++\databasemetadata.h>
#include <odbc++\drivermanager.h>
#include <odbc++\resultset.h>
#include <odbc++\resultsetmetadata.h>
#include <odbc++\preparedstatement.h>
#include <src\dtconv.h>
#include <odbc++\types.h>
#include <src\driverinfo.h>

// AMOS

#include <callout.h>
#include <storage.h>
#include <alisp.h>

// OdbcAmos specific
#include "HandleManager.h"
#include "AmosTypes.h"

// Bind and OSQL function to a C function
#define BIND_OSQL(fnname) a_extfunction(#fnname, fnname)

using namespace amos;
using namespace odbc;


/*****************************************************************************
 * Global variables
 *****************************************************************************/
typedef HandleManager<Connection>	        ConnectionManager;
typedef HandleManager<ResultSet>	        ResultSetManager;
typedef HandleManager<PreparedStatement>	StatementManager;

ConnectionManager   gConnPool;
ResultSetManager    gResulSetPool;
StatementManager    gStatementPool;
AmosTypes	        gTypeConvertor;



/*****************************************************************************
 * OSQL: DATASOURCES()
 *	params: void
 *	return: charstring
 *****************************************************************************/
void odbc_DataSources_f(a_callcontext cxt, a_tuple t) {
  string			strDSName;
  string			strDSNdescr;
  DataSourceList*	pDataSources;

  try {
    pDataSources = DriverManager::getDataSources();

    for (DataSourceList::iterator i = pDataSources->begin(); i != pDataSources->end(); i++) {
      strDSName	= (*i)->getName();
      strDSNdescr	= (*i)->getDescription();
      a_setstringelem(t, 0, (char*) strDSName.c_str(), FALSE);
      a_setstringelem(t, 1, (char*) strDSNdescr.c_str(), FALSE);
      a_emit(cxt, t, FALSE);
      if(cxt->done) return;
    }
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
  }
}


/*****************************************************************************
 * Open a connection by it's DSN, a username and a password
 * LISP: (odbc-connect dsn username password)
 *	params:	dsn	- string
 *		usr	- string
 *		pass	- string
 *	return:	- a handle to a connection - integer
 *****************************************************************************/
oidtype odbc_Connect(bindtype env, oidtype dsn, oidtype usr, oidtype pass) {
  char*		dsName;
  char*		userName;
  char*		password;
  Connection*	pConn;
  tHandle	hConn;


  // extract DSN, USERNAME,PASSWORD
  IntoString0(dsn, dsName, env);
  IntoString0(usr, userName, env);
  IntoString0(pass, password, env);

  try {
    pConn = DriverManager::getConnection(dsName, userName, password);
    //pConn->setTrace(true);
    hConn = gConnPool.addHandle(pConn);
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return mkinteger(ConnectionManager::invalidHandle);
  }
  // TODO: or a_return?
  return mkinteger(hConn);
}


/*****************************************************************************
 * Open a connection using an ODBC connect string, native to the DBMS to connect.
 * LISP: (odbc-connect-native connStr)
 *	params:	connStr		- string - Usually something like "DSN=db;uid=user;pwd=pass"
 *	return:				- a handle to a connection - integer
 *****************************************************************************/
oidtype odbc_ConnectNative(bindtype env, oidtype connStr) {
  char*		connectString;
  Connection*	pConn;
  tHandle	hConn;

  // extract DSN
  IntoString0(connStr, connectString, env);

  try {
    pConn = DriverManager::getConnection(connectString);
    hConn = gConnPool.addHandle(pConn);
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return mkinteger(ConnectionManager::invalidHandle);
  }
  // TODO: or a_return?
  return mkinteger(hConn);
}

/*****************************************************************************
 * Switch on or off ODBC tracing.
 * LISP: (odbc-set-trace trace_state)
 *	params:	trace		- string - "on" or "off"
 *	return:				- the old trace state
 *****************************************************************************/
oidtype odbc_SetTrace(bindtype env, oidtype conn, oidtype trace_state) {
  tHandle     hConn;
  Connection* pConn;
  char*       psz_trace_state;

  IntoInteger(conn, hConn, env);
  IntoString0(trace_state, psz_trace_state, env);
  try {
    pConn = gConnPool.getHandle(hConn);
    if (strcmp(psz_trace_state, "on") == 0) {
      pConn->setTrace(true);
    } else if (strcmp(psz_trace_state, "off") == 0) {
      pConn->setTrace(false);
    } else {
      return a_error(0, mkstring("Invalid ODBC trace state."), FALSE);
    }
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return a_error(0, mkstring((char*)e.what()), FALSE);
  }

  return t;
}

/*****************************************************************************
 * Set the output file for ODBC tracing.
 * LISP: (odbc-set-trace-file trace_file)
 *	params:	trace_file	- string - a full path name
 *	return:				- T on success
 *****************************************************************************/
oidtype odbc_SetTraceFile(bindtype env, oidtype conn, oidtype trace_file) {
  tHandle     hConn;
  Connection* pConn;
  char*       psz_trace_file;

  IntoInteger(conn, hConn, env);
  IntoString0(trace_file, psz_trace_file, env);
  try {
    pConn = gConnPool.getHandle(hConn);
    pConn->setTraceFile(psz_trace_file);
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return a_error(0, mkstring((char*)e.what()), FALSE);
  }

  return t;
}

/*****************************************************************************
 * LISP:	(odbc-disconnect Connection)
 *	params: Connection - integer, a handle to a connection
 *****************************************************************************/
oidtype odbc_Disconnect(bindtype env, oidtype conn) {
  tHandle	hConn;

  // get the connection handle
  IntoInteger(conn, hConn, env);

  try {
    gConnPool.deleteHandle(hConn);
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return nil;
  }

  return t;
}


/*****************************************************************************
 * LISP:	(odbc-commit Connection)
 *	params: Connection - integer, a handle to a connection
 *****************************************************************************/
oidtype odbc_Commit(bindtype env, oidtype conn) {
  tHandle	hConn;
  Connection* pConn;

  // get the connection handle
  IntoInteger(conn, hConn, env);

  try {
    pConn = gConnPool.getHandle(hConn);
    pConn->commit();
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return nil;
  }

  return t;
}

/*****************************************************************************
 * LISP:	(odbc-commit Connection)
 *	params: Connection - integer, a handle to a connection
 *****************************************************************************/
oidtype odbc_Rollback(bindtype env, oidtype conn) {
  tHandle	hConn;
  Connection* pConn;

  // get the connection handle
  IntoInteger(conn, hConn, env);

  try {
    pConn = gConnPool.getHandle(hConn);
    pConn->rollback();
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return nil;
  }

  return t;
}

/*****************************************************************************
 * LISP: (odbc-get-tables Connection)
 *	params: Connection - integer, a handle to a connection
 *	return: list of lists:
 *			((string table, string catalog, string schema, string owner) ...)
 *****************************************************************************/
oidtype odbc_GetTables(bindtype env, oidtype conn) {
  tHandle			hConn = 0;
  Connection*			pConn;
  DatabaseMetaData*	pMeta;
  ResultSet*			pResSet;
  vector<string>		catalogs;

  dcloid(lsp_result);

  // get the connection handle
  IntoInteger(conn, hConn, env);

  try {
    pConn = gConnPool.getHandle(hConn);
    pMeta = pConn->getMetaData();
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return nil;
  }

  try {
    // get all catalogs
    /*
    // Problem with Oracle driver: loops on SQLFetch.
    // See in the ODBC example code, it wasn't working for Silvio either.
    try {
    pResSet = pMeta->getCatalogs();
    while(pResSet->next())
    catalogs.push_back(pResSet->getString(1));
    } catch(SQLException& e) {
    ; // catalogs not supported
    }
    delete pResSet;
    */

    if(catalogs.size() == 0)
      catalogs.push_back("");


    // get all tables in all catalogs
    vector<string> tableTypes;
    tableTypes.push_back("TABLE");
    tableTypes.push_back("VIEW");
    for(vector<string>::iterator i = catalogs.begin(); i != catalogs.end(); i++) {
      pResSet = pMeta->getTables(*i, "","%",tableTypes);

      // TODO: quite some copying occurs here, maybe use one buffer for all?
      while(pResSet->next()) {
	string catalog	= pResSet->getString(1);
	string schema	= pResSet->getString(2);
	string tblname	= pResSet->getString(3);
	string type		= pResSet->getString(4);
				
	dcloid(lsp_tuple);

	// construct the tuple list in reverse order
	push_string(type.c_str(), lsp_tuple);
	push_string(schema.c_str(), lsp_tuple);
	push_string(catalog.c_str(), lsp_tuple);
	push_string(tblname.c_str(), lsp_tuple);
	// add the tuple to the result list
	push(lsp_tuple, lsp_result);
      }
    }

    delete pResSet;
  } catch(std::exception& e) {
    delete pResSet;
    cerr << endl << e.what() << endl;
    return nil;
  }

  a_return(lsp_result);
}


/*****************************************************************************
 * LISP:	(odbc-get-columns Connection Table)
 *	params: Connection	- integer, a handle to a connection
 *		Table		- charstring, a name of a table
 *	return: list of lists: ((string sql_type, string column_name) ...)
 *****************************************************************************/
oidtype odbc_GetColumns(bindtype env, oidtype conn, oidtype table) {
  tHandle	    hConn = 0;
  char*		    tableName;
  Connection*	    pConn;
  DatabaseMetaData* pMeta;
  ResultSet*	    pResSet;

  dcloid(lsp_result);
	
  // get the connection handle and tablename
  IntoInteger(conn, hConn, env);
  IntoString0(table, tableName, env);

  try {
    pConn = gConnPool.getHandle(hConn);
    pMeta = pConn->getMetaData();
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return nil;
  }
	
  try {
    pResSet = pMeta->getColumns("", "", tableName ,"%");
    while(pResSet->next()) {
      string column      = pResSet->getString(4);
      string sqlTypeName = pResSet->getString(6);

      dcloid(lsp_tuple);
			
      // construct the tuple list in reverse order
      push_string(column.c_str(), lsp_tuple);
      push_string(sqlTypeName.c_str(), lsp_tuple);
      push(lsp_tuple, lsp_result);
    }
    delete pResSet;
  } catch(std::exception& e) {
    delete pResSet;
    cerr << endl << e.what() << endl;
    return nil;
  }
  a_return(lsp_result);
}

/*****************************************************************************
 * LISP:	(odbc-get-primarykeys Connection Table)
 *	params: Connection	- integer, a handle to a connection
 *		Table		- charstring, a name of a table
 *	return: list of lists:
 *			((charstring col_name, charstring pkname) ...)
 *****************************************************************************/
oidtype odbc_GetPrimaryKeys(bindtype env, oidtype conn, oidtype table) {
  tHandle             hConn;
  char*				tableName;
  Connection*			pConn;
  DatabaseMetaData*	pMeta;
  ResultSet*			pResSet;
	
  dcloid(lsp_result);
	
  // get the connection handle and tablename
  IntoInteger(conn, hConn, env);
  IntoString0(table, tableName, env);
	
  try {
    pConn = gConnPool.getHandle(hConn);
    pMeta = pConn->getMetaData();
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return nil;
  }

  // to handle Access which does not support SQLPrimaryKeys
  try {
    pResSet = pMeta->getIndexInfo("", "", tableName, true, true);
		
    while(pResSet->next()) {
      int		nonUnique	= pResSet->getInt(4);
      int		colSeq		= pResSet->getInt(8);
			
      dcloid(lsp_tuple);

      // if it is a unique column and it is a "real" column with index > 0 
      if ((nonUnique == SQL_FALSE) && (colSeq > 0)) {
	string	column	= pResSet->getString(9);
	string	pkName	= pResSet->getString(6);

	push_string(pkName.c_str(), lsp_tuple);
	push_string(column.c_str(), lsp_tuple);
	push(lsp_tuple, lsp_result);
      }
    }
    delete pResSet;
  } catch(std::exception& e) {
    delete pResSet;
    cerr << endl << e.what() << endl;
    return nil;
  }
  a_return(lsp_result);
}

/*****************************************************************************
 * OSQL:	CATALOG(Connection)
 *	params: Connection	- integer, a handle to a connection
 *	return: charstring
 *****************************************************************************/
void odbc_Catalog_bf(a_callcontext cxt, a_tuple t) {
  tHandle     hConn;
  Connection*	pConn;
  string		catalog;
	
  // get the connection handle
  hConn = a_getintelem(t, 0, FALSE);
  try {
    pConn = gConnPool.getHandle(hConn);
		
    catalog = pConn->getCatalog();
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
  }
  a_setstringelem	(t, 1, (char*) catalog.c_str(), FALSE);
  a_emit(cxt,t,FALSE);
}

/*****************************************************************************
 * OSQL:	DBMS_INFO(Connection)
 * bag of <charstring prodname, charstring prodversion>
 *****************************************************************************/
void odbc_DbmsInfo_bff(a_callcontext cxt, a_tuple t) {
  tHandle			    hConn;
  Connection*			pConn;
  DatabaseMetaData*	pMeta;
  string				driverName;
  string				driverVersion;
	
  // get the connection handle
  hConn = a_getintelem(t, 0, FALSE);

  try {
    pConn = gConnPool.getHandle(hConn);
    pMeta = pConn->getMetaData();
		
    driverName		= pMeta->getDatabaseProductName();
    driverVersion	= pMeta->getDatabaseProductVersion();
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
  }
  a_setstringelem	(t, 1, (char*) driverName.c_str(), FALSE);
  a_setstringelem	(t, 2, (char*) driverVersion.c_str(), FALSE);
  a_emit(cxt,t, FALSE);
}


/*****************************************************************************
 * OSQL:	DRIVER_INFO(Connection)
 * bag of <charstring dname, charstring version, integer odbc_major, integer odbc_minorv>
 *****************************************************************************/
void odbc_DriverInfo_bffff(a_callcontext cxt, a_tuple t) {
  tHandle			    hConn;
  Connection*			pConn;
  DatabaseMetaData*	pMeta;
  string				driverName;
  string				driverVersion;
  int					majorVersion;
  int					minorVersion;

  // get the connection handle
  hConn = a_getintelem(t, 0, FALSE);

  try {
    pConn = gConnPool.getHandle(hConn);
    pMeta = pConn->getMetaData();
		
    driverName		= pMeta->getDriverName();
    driverVersion	= pMeta->getDriverVersion();
    majorVersion	= pMeta->getDriverMajorVersion();
    minorVersion	= pMeta->getDriverMinorVersion();
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
  }

  a_setstringelem	(t, 1, (char*) driverName.c_str(), FALSE);
  a_setstringelem	(t, 2, (char*) driverVersion.c_str(), FALSE);
  a_setintelem	(t, 3, majorVersion, FALSE);
  a_setintelem	(t, 4, minorVersion, FALSE);

  a_emit(cxt,t, FALSE);
}

/*****************************************************************************
 * LISP: (odbc-prepare-statement conn query params)
 *	return:	a prepared statement handle
 *****************************************************************************/
oidtype odbc_PrepareStatement(bindtype env, oidtype conn, oidtype query) {
  tHandle		    hConn;
  Connection*	    pConn;
  char*		    pszQuery;
  PreparedStatement*  pStatement;
  tHandle             hStatement;

  // get the connection handle and the query string
  IntoInteger(conn, hConn, env);
  IntoString0(query, pszQuery, env);

  try {
    pConn = gConnPool.getHandle(hConn);
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return mkinteger(ConnectionManager::invalidHandle);
  }

  try {
    pStatement = pConn->prepareStatement(pszQuery);	// read-only, scroll forward only

    // Store the Prepared Statement for this query
    hStatement = gStatementPool.addHandle(pStatement);
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return mkinteger(ConnectionManager::invalidHandle);
  }

  return mkinteger(hStatement);
}

/*****************************************************************************
 * LISP: (odbc-bind-params conn statement_handle params)
 *	return:	a prepared statement handle
 *****************************************************************************/
oidtype odbc_BindParams(bindtype env, oidtype statement, oidtype params) {
  int		            arity;
  PreparedStatement*  pStatement;
  tHandle             hStatement;

  // get the statement handle
  IntoInteger(statement, hStatement, env);

  try {
    pStatement = gStatementPool.getHandle(hStatement);
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return mkinteger(ConnectionManager::invalidHandle);
  }

  arity = a_arraysize(params);

  try {
    objtype amosType;
    int     sqlType;
    int     precision;
    int     scale;

    // bind parameters
    for (int i = 1; i <= arity; i++) {
      oidtype param = a_elt(params, i - 1);

      amosType = a_datatype(param);
      gTypeConvertor.amosToSql(amosType, &sqlType, &precision, &scale);

      switch(amosType) {
      case STRINGTYPE:
	char* strParam;
	IntoString0(param, strParam, env);
	pStatement->setString(i, strParam);
	break;
      case INTEGERTYPE:
	int	intParam;
	IntoInteger(param, intParam, env);
	pStatement->setInt(i, intParam);
	break;
      case REALTYPE:
	double doubleParam;
	IntoDouble(param, doubleParam, env);
	pStatement->setDouble(i, doubleParam);
	break;
      case BINARYTYPE:
	// TODO: handle AMOS binary types
      default:
	throw SQLException("[OdbcAmos]: Unhandled AMOS type" + intToString(amosType));
      }
    }
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return mkinteger(ConnectionManager::invalidHandle);
  }

  return statement;
}

/*****************************************************************************
 * LISP: (odbc-execute-query statement)
 *	return:	a scan handle
 *****************************************************************************/
oidtype odbc_ExecuteQuery(bindtype env, oidtype statement) {
  tHandle             hStatement;
  PreparedStatement*	pStatement;
  tHandle		        hResSet;
  ResultSet*          pResSet;

  // get the statement handle
  IntoInteger(statement, hStatement, env);

  try {
    pStatement = gStatementPool.getHandle(hStatement);
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return mkinteger(ConnectionManager::invalidHandle);
  }

  try {
    // Execute the query
    pResSet	= pStatement->executeQuery();

    // Store the Result Set for this query
    hResSet = gResulSetPool.addHandle(pResSet);
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return mkinteger(ConnectionManager::invalidHandle);
  }

  return mkinteger(hResSet);
}


/*****************************************************************************
 * LISP: (odbc-update-stmt-p statement)
 *	return:	T if this is an update statement
 *****************************************************************************/
oidtype odbc_IsUpdateStatement(bindtype env, oidtype query) {
  char* pszQuery;

  IntoString0(query, pszQuery, env);
  strupr(pszQuery);

  if ( (strstr(pszQuery, "ALTER") == pszQuery) ||
       (strstr(pszQuery, "CREATE") == pszQuery) ||
       (strstr(pszQuery, "DROP") == pszQuery) ||
       (strstr(pszQuery, "GRANT") == pszQuery) ||
       (strstr(pszQuery, "REVOKE") == pszQuery) ||
       (strstr(pszQuery, "SELECT INTO") == pszQuery) ||
       (strstr(pszQuery, "TRUNCATE TABLE") == pszQuery) ||
       (strstr(pszQuery, "INSERT") == pszQuery) ||
       (strstr(pszQuery, "UPDATE") == pszQuery) ||
       (strstr(pszQuery, "DELETE") == pszQuery) )
    {
      return t;
    } else {
      return nil;
    }
}


/*****************************************************************************
 * LISP: (odbc-execute-update statement)
 *	return:	the number of rows affected by an UPDATE, INSERT, or DELETE statement
 *****************************************************************************/
oidtype odbc_ExecuteUpdate(bindtype env, oidtype statement) {
  tHandle             hStatement;
  PreparedStatement*	pStatement;
  int                 iUpdateCount;

  // get the statement handle
  IntoInteger(statement, hStatement, env);

  try {
    pStatement = gStatementPool.getHandle(hStatement);
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return mkinteger(ConnectionManager::invalidHandle);
  }

  try {
    // Execute the update statement
    iUpdateCount = pStatement->executeUpdate();
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return mkinteger(ConnectionManager::invalidHandle);
  }

  return mkinteger(iUpdateCount);
}

/*****************************************************************************
 * LISP: (odbc-next-row scan)
 *	return:	list
 *****************************************************************************/
/*
  oidtype odbc_NextRow(bindtype env, oidtype scan) {
  tHandle		hResSet;
  ResultSet*	pResSet;

  dcloid(lsp_tuple);

  // get the result set handle and tablename
  IntoInteger(scan, hResSet, env);
  try {
  pResSet = gResulSetPool.getHandle(hResSet);

  ResultSetMetaData*	pResMeta	= pResSet->getMetaData();
  int					colCount	= pResMeta->getColumnCount();
  objtype				amosType;

  // retrieve the result
  if (pResSet->next()) {
  // push the elements of the tuple in reverse order
  for (int i = colCount; i > 0; i--) {
  gTypeConvertor.sqlToAmos(pResMeta->getColumnType(i), &amosType);
  switch(amosType) {
  case STRINGTYPE:
  {
  string result = pResSet->getString(i);
  push_string(result.c_str(), lsp_tuple);
  break;
  }
  case INTEGERTYPE:
  {
  int result = pResSet->getInt(i);
  push_integer(result, lsp_tuple);
  break;
  }
  case REALTYPE:
  {
  double result = pResSet->getDouble(i);
  push_real(result, lsp_tuple);
  break;
  }
  case BINARYTYPE:
  // TODO: how to handle AMOS binary types?
  break;
  default:
  assert(false);
  }
  }
  } else {
  return nil;				// no more tuples
  }
  } catch(SQLException& e) {
  cerr << e.getMessage() << endl << flush;
  return nil;
  }

  a_return(lsp_tuple);	// return the tuple
  }*/

/*****************************************************************************
 * LISP: (odbc-next-row scan)
 *	return:	lisp array (or an osql vector)
 *****************************************************************************/
oidtype odbc_NextRow(bindtype env, oidtype scan) {
  tHandle		hResSet;
  ResultSet*	pResSet;

  dcloid(lsp_tuple);

  // get the scan handle
  IntoInteger(scan, hResSet, env);
  try {
    pResSet = gResulSetPool.getHandle(hResSet);

    ResultSetMetaData*	pResMeta	= pResSet->getMetaData();
    int			colCount	= pResMeta->getColumnCount();
    objtype			amosType;

    // retrieve the result
    if (pResSet->next()) {
      a_setf(lsp_tuple, new_array(colCount, nil));	// make the array to hold the tuple
      for (int i = 0; i < colCount; i++) {
	gTypeConvertor.sqlToAmos(pResMeta->getColumnType(i + 1), &amosType);
	switch(amosType) {
	case STRINGTYPE:
	  {
	    string result = pResSet->getString(i + 1);
	    a_seta(lsp_tuple, i, mkstring((char*)result.c_str()));
	    break;
	  }
	case INTEGERTYPE:
	  {
	    int result = pResSet->getInt(i + 1);
	    a_seta(lsp_tuple, i, mkinteger(result));
	    break;
	  }
	case REALTYPE:
	  {
	    double result = pResSet->getDouble(i + 1);
	    a_seta(lsp_tuple, i, mkreal(result));
	    break;
	  }
	case BINARYTYPE:
	  // TODO: how to handle AMOS binary types?
	  break;
	default:
	  assert(false);
	}
      }
    } else {
      return nil;				// no more tuples
    }
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    a_free(lsp_tuple);
    return nil;
  }

  a_return(lsp_tuple);	// return the tuple
}

/*****************************************************************************
 * LISP: (odbc-free-statement statement)
 *	return:	T or NIL
 *****************************************************************************/
oidtype odbc_FreeStatment(bindtype env, oidtype statement) {
  tHandle     hStatement;

  // get the scan handle
  IntoInteger(statement, hStatement, env);
  try {
    gStatementPool.deleteHandle(hStatement);
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return nil;
  }

  return t;
}

/*****************************************************************************
 * LISP: (odbc-close-scan scan)
 *	return:	T or NIL
 *****************************************************************************/
oidtype odbc_CloseScan(bindtype env, oidtype scan) {
  tHandle		hResSet;

  // get the scan handle
  IntoInteger(scan, hResSet, env);
  try {
    gResulSetPool.deleteHandle(hResSet);
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
    return nil;
  }

  return t;
}

/*****************************************************************************
 * A native OSQL variant of the SQL function. The intention is to try to execute
 * it in a thread and compare to the Iterator version of the same function.
 *
 * OSQL: SQL(Connection, SQLStatement, Params)
 *	params: Connection		- integer, a handle to a connection
 *			SQLStatement	- charstring
 *			Params			- a sequence
 *	return: list of array (<...> ...)
 *****************************************************************************/
void odbc_sql_bbbf(a_callcontext cxt, a_tuple t) {
  tHandle			hConn = 0;
  Connection*		pConn = NULL;
  string			sql;
  int				arity;
  dcl_tuple(argList);
  dcl_tuple(resSequence);
	
  {unwind_protect_begin;
  // a_print(t->tpl);	// for debugging
  hConn = gTypeConvertor.getInt(t, 0);	// the connection handle
  sql = gTypeConvertor.getString(t, 1);	// the query
  a_getseqelem(t, 2, argList, FALSE);	// a sequence of the the parameters of the query
		
  // arity: the number of parameters of the query
  arity = a_getarity(argList, FALSE);

  try {
    objtype amosType;
    int		sqlType;
    int		precision;
    int		scale;
    pConn = gConnPool.getHandle(hConn);

    // TODO: add code, so, that not to prepare again - stmnt cache

    PreparedStatement*	pStmt = pConn->prepareStatement(sql);	// read-only, scroll forward only
			
    // bind parameters
    for (int i = 0; i < arity; i++) {
      string strParam;
      amosType = gTypeConvertor.getType(argList, i);
      gTypeConvertor.amosToSql(amosType, &sqlType, &precision, &scale);
      switch(amosType) {
      case STRINGTYPE:
	strParam = gTypeConvertor.getString(argList, i);
	pStmt->setString(i + 1, strParam);
	break;
      case INTEGERTYPE:
	pStmt->setInt(i + 1, gTypeConvertor.getInt(argList, i));
	break;
      case REALTYPE:
	pStmt->setDouble(i + 1, gTypeConvertor.getDouble(argList, i));
	break;
      case BINARYTYPE:
	// TODO: how to handle AMOS binary types?
      default:
	throw SQLException("[OdbcAmos]: Unhandled AMOS type" + intToString(amosType));
      }
    }
			
    ResultSet*			pResSet		= pStmt->executeQuery();
			
    // retrieve the result
    ResultSetMetaData*	pResMeta	= pResSet->getMetaData();
    int					colCount	= pResMeta->getColumnCount();
    while (pResSet->next()) {
      a_newtuple(resSequence, colCount, FALSE);
      // get the data for one tuple
      for (int i = 0; i < colCount; i++) {
	gTypeConvertor.sqlToAmos(pResMeta->getColumnType(i + 1), &amosType);
	switch(amosType) {
	case STRINGTYPE:
	  {
	    string result = pResSet->getString(i + 1);
	    a_setstringelem(resSequence, i, (char*)result.c_str(), FALSE);
	    break;
	  }
	case INTEGERTYPE:
	  {
	    int result = pResSet->getInt(i + 1);
	    a_setintelem(resSequence, i, result, FALSE);
	    break;
	  }
	case REALTYPE:
	  {
	    double result = pResSet->getDouble(i + 1);
	    a_setdoubleelem(resSequence, i, result, FALSE);
	    break;
	  }
	case BINARYTYPE:
	  // TODO: how to handle AMOS binary types?
	  break;
	default:
	  assert(false);
	}
      }
      // emit the tuple
      a_setseqelem(t, 3, resSequence, FALSE);
      a_emit(cxt,t,FALSE);
    }
  } catch(std::exception& e) {
    cerr << endl << e.what() << endl;
  }

  unwind_protect_catch;
  free_tuple(resSequence);
  free_tuple(argList);
  unwind_protect_end;}
}

oidtype odbc_shutdown(bindtype env) {
  gResulSetPool.deleteAllHandles();
  gStatementPool.deleteAllHandles();
  gConnPool.deleteAllHandles();
  return t;
}

/*****************************************************************************
 * Binds Lisp and OSQL function names to their implementations.
 *****************************************************************************/
void odbc_bind() {
  // initialization
  extfunction3("odbc-connect",		 odbc_Connect);
  extfunction1("odbc-connect-native",	 odbc_ConnectNative);
  extfunction1("odbc-disconnect",	 odbc_Disconnect);
  extfunction0("odbc-shutdown",          odbc_shutdown);
  // metadata functions
  extfunction1("odbc-tables",		 odbc_GetTables);
  extfunction2("odbc-columns",		 odbc_GetColumns);
  extfunction2("odbc-primary-keys",	 odbc_GetPrimaryKeys);
  // query execution interface
  extfunction2("odbc-prepare-statement", odbc_PrepareStatement);
  extfunction2("odbc-bind-params",       odbc_BindParams);
  extfunction1("odbc-execute-query",	 odbc_ExecuteQuery);
  extfunction1("odbc-update-stmt-p",     odbc_IsUpdateStatement);
  extfunction1("odbc-execute-update",    odbc_ExecuteUpdate);
  extfunction1("odbc-next-row",		 odbc_NextRow);
  extfunction1("odbc-free-statement",    odbc_FreeStatment);
  extfunction1("odbc-close-scan",	 odbc_CloseScan);
  // transactions
  extfunction1("odbc-commit",		 odbc_Commit);
  extfunction1("odbc-rollback",		 odbc_Rollback);
  // debugging
  extfunction2("odbc-set-trace",         odbc_SetTrace);
  extfunction2("odbc-set-trace-file",    odbc_SetTraceFile);
  // Native OSQL functions
  BIND_OSQL(odbc_DataSources_f);
  BIND_OSQL(odbc_Catalog_bf);
  BIND_OSQL(odbc_DriverInfo_bffff);
  BIND_OSQL(odbc_DbmsInfo_bff);
  BIND_OSQL(odbc_sql_bbbf);
}

/*****************************************************************************
 * Initialization
 *****************************************************************************/
/*
  const char DEFAULT_DUMP_FILE[] = "amos2.dmp";
  void odbc_init(int argc, char **argv) {
  char pszDumpFile[MAX_PATH + 1];	// The name of the dump file
  char pszLoadCmd[MAX_PATH + 6];	// buffer to hold additional commands
  dcl_connection(c);      // To hold connection to Amos
  dcl_scan(s);            // To hold result streams from Amos queries and function calls
  int i = 2;				// Counter for argc

  if (argc > 1)
  sprintf(pszDumpFile, argv[1]);
  else
  sprintf(pszDumpFile, DEFAULT_DUMP_FILE);

  // Initialize embedded Amos
  a_initialize(pszDumpFile, FALSE);

  // Bind function names
  odbc_bind(NULL);

  {unwind_protect_begin;
  a_connect(c,"",FALSE); // Connect to embedded Amos

  // The initialization of the ODBC module should be executed only at BOOT time
  if (strcmp(pszDumpFile, "*INIT*") == 0) {
  bindtype env = topframe();
  // call a Lisp function that performs the initialization
  call_lisp(mksymbol("init-odbc-ds"), env, 0);
  }

  // Execute the rest of the OSQL files on the command line (if any)
  for (i; i < argc; i++) {
  sprintf(pszLoadCmd, "< '%s';", argv[i]);
  a_execute(c, s, pszLoadCmd, FALSE);
  }
  unwind_protect_catch;
  free_scan(s);
  free_connection(c);
  unwind_protect_end;}
  }
*/
