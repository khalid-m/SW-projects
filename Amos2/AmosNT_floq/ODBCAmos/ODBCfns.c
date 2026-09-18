/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1998, 1999 Silvio Brandani, Tore Risch EDSLAB
 * $RCSfile: ODBCfns.c,v $
 * $Revision: 1.3 $ $Date: 2008/08/14 17:23:14 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Foreign functions in ODBC interface 
 * ===========================================================================
 * $Log: ODBCfns.c,v $
 * Revision 1.3  2008/08/14 17:23:14  torer
 * *** empty log message ***
 *
 * Revision 1.2  2008/08/07 11:33:02  torer
 * Memory leak
 *
 * Revision 1.1  2008/08/05 16:36:08  torer
 * Added ODBCAmos = Amos II + basic ODBC interface
 *
 ****************************************************************************/

#include <windows.h>
#include "odbc_lib\sql.h"
#include "odbc_lib\sqlext.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "util.h"
#include "callout.h"
#include "alisp.h"
#include <math.h>

/* Global variables */

HENV henv;         // Declare a variable of type  HENV(the application's environment handle)
HDBC hdbc;         // An hdbc type variable(the application's connection handle).

DataSourceInfo *pstDSNArray; // A pointer to the array of avaialable data sources
SWORD ciDSN;                 // Number of DSN in the array

queue *pTheQueue;     /* A pointer to the queue of data sources opened with the function
                         ODBCSOURCE */
member *pActiveMember;    /* A pointer to the active data source*/


//testing function
int times_called;
void get_times_called(a_callcontext cxt, a_tuple t){
  dcl_tuple(res);
  a_setarity(res, 1);
  a_setintelem(res,0,times_called, FALSE);
  a_emit(cxt,res, FALSE);
  times_called=0;
  free_tuple(res);
}


////////////////////////////////////////////////////////////////////////////
             /*  The SQL function */
///////////////////////////////////////////////////////////////////////////
void SQLbbbf(a_callcontext cxt, a_tuple t)
{
   HSTMT hstmt;       // Declare a statement handle variable.
   SWORD iColCount;
   ColumnDescriptor *pointer2,*pColumns = NULL;
   BoundColumn      *pointer1,*pBound=NULL;
   RETCODE rc;
   UCHAR *szSqlState[6];
   char dsname[SQL_MAX_DSN_LENGTH+1], query[MAX_QUERY_LENGTH];
   int i,integ;
   int *pInt;
   double *pDoub;
   int arity;   // Number of parameters

       SQLSMALLINT     fSqlCType;		// SQL C type
       PTR	 *name=NULL;		// Storage
       int       *pIntTemp;
       double    *pDoubTemp;
       SQLSMALLINT	 fType;		        // SQL type
       SDWORD cbTEST=SQL_NTS;
       SQLINTEGER pcbValue=SQL_NTS;
   double dop;

   dcl_tuple(resseq);
   dcl_tuple(argl);
   dcl_oid(o);

   times_called+=1;
   {unwind_protect_begin;
   /* The parameter of position 0 in the tuple t is the data source name */
   a_getstringelem(t,0,dsname,sizeof(dsname),FALSE);
   /* The parameter of position 1 in the tuple t is the query */
   a_getstringelem(t,1,query,sizeof(query),FALSE);
   /* The parameter of position 2 in the tuple t is a sequence( the parameters
       of the query)*/
   a_getseqelem(t, 2, argl, FALSE);
    /* arity get the number of parameters of the query */
   arity = dr(argl->tpl,arraycell)->size;


   /* extend the array of pointers of #arity places(one place for each parameter of the query) */
   name=(PTR *)malloc(arity * sizeof(PTR));
   if(name==NULL){
                  fprintf(stderr,"Out of storage\n");
                  exit(EXIT_FAILURE);
   }


     /* connect to the data source specified in dsname */
     if(LookForEntry(pTheQueue, dsname, &pActiveMember)){
            hdbc=pActiveMember->data->hdbc;


           /* Call SQLAllocStmt.
              SQLAllocStmt allocates memory for a statement handle and associates
              the statement handle with the connection specified by hdbc.*/

           rc= SQLAllocStmt(hdbc, &hstmt);
           if(!RETCODE_IS_SUCCESSFUL(rc)){
                printf("CANNOT SQLAllocStmt rc%d\n",rc);
                ShowError(henv, hdbc, hstmt, szSqlState);
           }
           // SQLPrepare prepares an SQL string for execution.
           rc = SQLPrepare(hstmt, (SQLCHAR*)query, SQL_NTS);

           if(!RETCODE_IS_SUCCESSFUL(rc)){
                printf("QUERY IMPOSSIBLE CON rc%d\n",rc);
                ShowError(henv, hdbc, hstmt, szSqlState);
           }

           // Bind the parameters
            for(i=0;i<arity;i++){
                 a_setf(o,a_getelem(argl,i,FALSE));      // Take i-st argument of the tuple argl

                 switch(a_datatype(o)) {
                 case STRINGTYPE:   /* The i-st parameter is a string */
                       {
                       char stringa[30];
                       a_getstringelem(argl, i,stringa,sizeof(stringa),FALSE);
                       // allocate space for the current string
                       name[i] = (PTR)malloc(strlen(stringa)+1);

                       if(name[i]==NULL){
                                  outOfStorage();
                       }

               	       fSqlCType= SQL_C_CHAR;		// SQL C type =SQL_C_CHAR
                       fType= SQL_VARCHAR ;                // The  sql data type
            /* Call the SQLBindParameter
            An application calls SQLBindParameter to bind each parameter marker in an SQL statement*/
                       rc=SQLBindParameter(hstmt, i+1, SQL_PARAM_INPUT,fSqlCType,
                                fType,strlen(stringa), 0, name[i], 0, &cbTEST);

                       // Check for errors
                       if(!RETCODE_IS_SUCCESSFUL(rc)){
                              printf("BIND IMPOSSIBLE\n");
                              ShowError(henv, hdbc, hstmt, szSqlState);
                       }

                       strcpy(name[i],stringa);    // Specify the parameter data
                       }
                      break;
                   case INTEGERTYPE:  /* The i-st parameter is an integer*/
                       fSqlCType= SQL_C_LONG;		// SQL C type
                       fType=  SQL_NUMERIC;                // The  sql data type
                       /* Allocate space for the current parameter */
                       name[i] = (PTR)malloc(sizeof(int));
                       if(name[i]==NULL){
                                  outOfStorage();
                       }
                       // Call SQLBindParameter
                       rc=SQLBindParameter(hstmt, i+1, SQL_PARAM_INPUT,fSqlCType,
                               fType,sizeof(int), 0, name[i], 0, &pcbValue);

                       // check for errors
                       if(!RETCODE_IS_SUCCESSFUL(rc)){
                              printf("BIND IMPOSSIBLE CON rc%d\n",rc);
                              ShowError(henv, hdbc, SQL_NULL_HSTMT, szSqlState);
                       }
                         pInt= name[i];
                         integ=a_getintelem(argl, i, FALSE);   // Specify the parameter data
                         *pInt=integ;
                      break;
                   case REALTYPE:   /* The i-st parameter is a real*/
                       fSqlCType= SQL_C_DEFAULT;		// SQL C type
                       fType=  SQL_DOUBLE;                // The  sql data type
                       // allocate space for the current parameter
                       name[i] = (PTR)malloc(sizeof(double));
                       if(name[i]==NULL){
                                  outOfStorage();
                       }
                       // Call SQLBindParameter
                       rc=SQLBindParameter(hstmt, i+1, SQL_PARAM_INPUT,fSqlCType,
                               fType,sizeof(double), 0, name[i], 0, &pcbValue);

                       // check for errors
                       if(!RETCODE_IS_SUCCESSFUL(rc)){
                                printf("BIND IMPOSSIBLE CON rc%d\n",rc);
                                ShowError(henv, hdbc, SQL_NULL_HSTMT, szSqlState);
                       }
                       pDoub=name[i];
                       dop=a_getdoubleelem(argl, i, FALSE);   // Specify the parameter data
                       *pDoub=dop;
                      break;
                  }

   }


   /* SQLExecute executes a prepared statement, using the current values of the
      parameter marker variables if any parameter markers exist in the statement. */
  // SQLExecute(hstmt);
   if(RETCODE_IS_SUCCESSFUL(rc)){
             /* GetColDescriptions return the number of columns and an array of column's descriptor
                for each column in the result set */
                   rc= GetColDescriptions(hstmt, TRUE, &iColCount, &pColumns);

   }
   // Bind the columns.

   if(RETCODE_IS_SUCCESSFUL(rc)){
                   rc=BindAllCols(hstmt, iColCount, pColumns, &pBound);
   }

   SQLExecute(hstmt);
   // Fetch the data.
    while(RETCODE_IS_SUCCESSFUL(rc)){
  /* SQLFetch fetches a row of data from a result set. The driver returns data for all columns
      that were bound to storage locations with SQLBindCol. */
             rc = SQLFetch(hstmt);
    if(RETCODE_IS_SUCCESSFUL(rc)){
    /* set the arity of the tuple resseq to the number of columns in the result set */
                     a_setarity(resseq,iColCount);
                     }
    else{
                ShowError(henv, hdbc, hstmt, szSqlState);
    }
    // Did we get a row??
    // Do processing.
        for(pointer1= pBound, pointer2= pColumns, i=0;
              pointer1<pBound+iColCount && RETCODE_IS_SUCCESSFUL(rc);
                                        pointer1++, pointer2++,i++){

              switch(pointer2->fType){
                case SQL_LONGVARCHAR:
		case SQL_VARCHAR:
		case SQL_CHAR:
		case SQL_NUMERIC:
		case SQL_DECIMAL:
		case SQL_BIGINT:
			a_setelem(resseq,i,mkstring(pointer1->pBuffer));
                        /* a_print(resseq->tpl);
                        printf("Column number :%d  -- Column name :%s\n",
                                pointer1->iCol,pointer2->szColName);
                        printf("The C data type of the result data :%d e contenuto :%s\n",
                                pointer1->fSqlCType, pointer1->pBuffer); */
			break;

		case SQL_INTEGER:
                case SQL_SMALLINT:
                  {
                     int theInteger;
                       pIntTemp=pointer1->pBuffer;
                       theInteger = *((short int *)pIntTemp);
                       a_setelem(resseq,i,mkinteger(theInteger));
                       /*printf("Column number :%d  -- Column name :%s\n",
                                     pointer1->iCol,pointer2->szColName);
                       printf("SQL tipo %d e dimensione %d\n",
                        pointer2->fType, sizeof(pointer2->fType));
                       printf("The Contenuto : %d\n",*pIntTemp);*/
                    }
			break;

		case SQL_FLOAT:
		case SQL_DOUBLE:
                       pDoubTemp=pointer1->pBuffer;
                       a_setelem(resseq,i,mkreal(*pDoubTemp));
                       /* printf("Column number :%d  -- Column name :%s\n",
                                     pointer1->iCol,pointer2->szColName);
                       printf("SQL type %d size %d\n",
		       pointer2->fType, sizeof(pointer2->fType));
                       printf("The Contenuto : %f\n",*pDoubTemp);*/
			break;

		case SQL_REAL:
	       case SQL_DATE:
               case SQL_TIME:
               case SQL_TIMESTAMP:
               case SQL_BINARY:
               case SQL_VARBINARY:
               case SQL_LONGVARBINARY:
               case SQL_TINYINT:
               case SQL_BIT:
               default:
		 printf("SQL type not supported: %d\n", pointer2->fType); 
                 return;
               break;
		}

                 if(i==iColCount-1){

                         a_setseqelem(t, 3, resseq, FALSE);
                         /* a_print(resseq->tpl);*/
                         a_emit(cxt,t,FALSE);
                         /*printf("t->tpl");
                         a_print(t->tpl);*/

                         }

        }

    }
    unwind_protect_catch;
    free(name);
    free(pColumns);
    free(pBound);
    free_tuple(resseq);
    free_tuple(argl);
    free_oid(o);
    /* SQLFreeStmt stops processing associated with a specific hstmt,
       frees all resources associated with the statement handle. */
    SQLFreeStmt(hstmt, SQL_DROP);
    /* SQLDisconnect closes the connection associated with a specific connection handle. */
    //SQLDisconnect(hdbc);
    unwind_protect_end;}
   }
  return;

}
/////////////////////////////////////////////////////////////////////////
///////// COLUMNS(DSN,TABLE) ///////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
void COLUMNSbbff(a_callcontext cxt, a_tuple t)
{
char dsname[SQL_MAX_DSN_LENGTH+1];
char tabname[SQL_MAX_COLUMN_NAME_LEN+1];
UCHAR szBuffer[SQL_MAX_TABLE_NAME_LEN+1];
PTR *ColType;
PTR *inttype;
char StringType[30];
HSTMT hstmt;       // Declare a statement handle variable.
RETCODE rc;
SDWORD cbValue;

/* The parameter of position 0 in the tuple t is the data source name */
a_getstringelem(t,0,dsname,sizeof(dsname),FALSE);
/* The parameter of position 1 in the tuple t is the table name */
a_getstringelem(t,1,tabname,sizeof(tabname),FALSE);

ColType = (PTR)calloc(2,sizeof(PTR));
/* connect to the data source specified in dsname */
if(LookForEntry(pTheQueue, dsname, &pActiveMember)){
      hdbc=pActiveMember->data->hdbc;
             /* Call SQLAllocStmt.
              SQLAllocStmt allocates memory for a statement handle and associates
              the statement handle with the connection specified by hdbc.*/
       ColType[1]= (PTR)malloc(sizeof(SWORD));
      rc= SQLAllocStmt(hdbc, &hstmt);
      if(!RETCODE_IS_SUCCESSFUL(rc)){
                    printf("Cannot allocate SQL statement\n");
                    }
      /* check rc */

      rc= SQLColumns(hstmt,NULL,SQL_NTS,NULL,SQL_NTS,(SQLCHAR*)tabname,sizeof(tabname),NULL,SQL_NTS);
      //rc= GetUserTable(hdbc, hstmt);
      // Fetch the data.
    while(RETCODE_IS_SUCCESSFUL(rc)){
  /* SQLFetch fetches a row of data from a result set.  */
         rc = SQLFetch(hstmt);
  /* Did we get a row? */
    if(RETCODE_IS_SUCCESSFUL(rc)){
    /* Get the column with the name of the tables */

           SQLGetData(hstmt,4, SQL_C_CHAR,szBuffer,sizeof(szBuffer),&cbValue);
           a_setelem(t, 2, mkstring((char*)szBuffer));

           SQLGetData(hstmt,5, SQL_C_SSHORT,ColType,sizeof(SWORD),&cbValue);
           inttype=ColType;
           printf("inttype %d\n",*inttype);
           TypeOfCol(*((int *)ColType), StringType);
           a_setelem(t, 3, mkstring(StringType));
           a_emit(cxt,t,FALSE);

         }
    }
    free(ColType);
   SQLFreeStmt(hstmt, SQL_DROP);
  }
 }


/////////////////////////////////////////////////////////////////////////
/////////TABLES(DSN) ///////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
void TABLESbf(a_callcontext cxt, a_tuple t)
{
char dsname[SQL_MAX_DSN_LENGTH+1];
UCHAR szBuffer[SQL_MAX_TABLE_NAME_LEN+1];
HSTMT hstmt;       // Declare a statement handle variable.
RETCODE rc;
RETCODE rcGetData;
SDWORD cbValue;

/* The parameter of position 0 in the tuple t is the data source name */
a_getstringelem(t,0,dsname,sizeof(dsname),FALSE);
ods(dsname);
/* connect to the data source specified in dsname */
if(LookForEntry(pTheQueue, dsname, &pActiveMember)){
      hdbc=pActiveMember->data->hdbc;
             /* Call SQLAllocStmt.
              SQLAllocStmt allocates memory for a statement handle and associates
              the statement handle with the connection specified by hdbc.*/

      rc= SQLAllocStmt(hdbc, &hstmt);
      if(!RETCODE_IS_SUCCESSFUL(rc))
      {
        printf("SQLAllocStmt failed\n");
        exit(1);
      }
      /* check rc */

      rc= SQLTables(hstmt,NULL,SQL_NTS,NULL,SQL_NTS,NULL,SQL_NTS,(SQLCHAR*)"'TABLE'",SQL_NTS);
      //rc= GetUserTable(hdbc, hstmt);
      // Fetch the data.
    while(RETCODE_IS_SUCCESSFUL(rc)){
  /* SQLFetch fetches a row of data from a result set.  */
         rc = SQLFetch(hstmt);
  /* Did we get a row? */
    if(RETCODE_IS_SUCCESSFUL(rc)){
    /* Get the column with the name of the tables */

           rcGetData=SQLGetData(hstmt,3, SQL_C_CHAR,szBuffer,sizeof(szBuffer),&cbValue);
               if(!RETCODE_IS_SUCCESSFUL(rcGetData)){
                 printf("SQLGetData failed\n");
                 exit(1);
                 }
           a_setelem(t, 1, mkstring((char *)szBuffer));
           a_emit(cxt,t,FALSE);

         }
    }
   SQLFreeStmt(hstmt, SQL_DROP);
  }
 }

///////////////////////////////////////////////////////////////////////////
/////// ODBCSOURCE(DSN,username,PASSWORD)/////////////////////////////
/////////////////////////////////////////////////////////////////////////////


void ODBCSOURCEbbbf(a_callcontext cxt, a_tuple t)
{
   int i;
   char stringa[SQL_MAX_DSN_LENGTH+1];
   BOOL tofind=FALSE;
   Conne data;
   member *pMember;
    RETCODE	rc;
   UCHAR *szSqlState[6];
   /* in position 0 there is the DSN */
   a_getstringelem(t,0, stringa,sizeof(stringa),FALSE);
    // check if the DSN is available using the pointer to the array of avaialable data sources
   /*
   pERCHE' NON FUNZIONA????
   tofind= IsThereDSN(ciDSN,pstDSNArray,stringa);
   */

    for(i=0;i<ciDSN && tofind ;i++){
            if(strcmp((char *)pstDSNArray[i].szDSN, stringa) == 0){
                     tofind = FALSE;
        }
     }
     if(tofind) {     /* Show the dsn list */
                     PrintDSN(pstDSNArray,ciDSN);
                     printf("\nData Source Name : %s NOT AVAILABLE\n",stringa);
     }
     else {
        tofind=TRUE;
       // The DSN has been opened before??
        pMember=pTheQueue->front;
        while(pMember!=NULL && tofind) {
         	if(strcmp(stringa, (char*)pMember->data->names[0]) == 0) {
                       tofind = FALSE;
                }
                else {
                       pMember=pMember->next;
                }
       }

      if(!tofind) {
               printf("DSN %s has been opened before\n",stringa);
	}
	else {


                  /* insert DSN, USERNAME,PASSWORD in the DSN's row inthe table */
                  for(i=0;i<3;i++){
                     a_getstringelem(t,i, stringa,sizeof(stringa),FALSE);
                         strcpy( (char*)data.names[i],stringa);
                     }
/*SQLAllocConnect allocates memory for a connection handle within the environment identified
  by henv. The driver allocates memory and stores the value of the associated handle in the
  hdbc. The application passes the hdbc value in all subsequent calls that require an hdbc .*/

                  SQLAllocConnect(henv,&(data.hdbc));
          /* the hdbc in the DSN's row now contains an allocated connection handle. */
                rc = SQLConnect(data.hdbc, data.names[0], SQL_NTS, data.names[1], SQL_NTS, data.names[2], SQL_NTS);
                if(!RETCODE_IS_SUCCESSFUL(rc)){
                    printf("CONNECTION IMPOSSIBLE\n");
                    ShowError(henv, data.hdbc, SQL_NULL_HSTMT, szSqlState);
                    }
                 else{
          /* add the info of the data source to the back of the queue */
                  add(&data,pTheQueue);
          /* return the position of the data source in the queue(the last position) */
                  a_setelem(t,3,mkinteger(pTheQueue->number));
                  a_emit(cxt,t, FALSE);
                  }
   }
  }
}
////////////////////////////////////////////////////////////////////////////////////
///////datasources()  ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
 void DATASOURCESf(a_callcontext cxt, a_tuple t)
{
   int i;
   /* set the arity of the tuple resseq to the number of DSNs */

   for(i=0;i<ciDSN;i++) {
          a_setelem(t, 0, mkstring((char*)pstDSNArray[i].szDSN));
          a_emit(cxt,t,FALSE);
   }

}

///////////////////////////////////////////////////////////////
//////////   OPENSOURCES() /////////////////////////////////
//////////////////////////////////////////////////////////////////////////
void OPENSOURCESf(a_callcontext cxt, a_tuple t)
{
int i;
member *pMember;
dcl_tuple(resseq);

/* set the arity of the tuple resseq to the number of DSNs */
 a_setarity(resseq,pTheQueue->number);
 pMember=pTheQueue->front;
 for(i=0;i<pTheQueue->number;i++) {
           a_setelem(resseq,i,mkstring((char*)pMember->data->names[0]));
           pMember=pMember->next;
 }

 if(i==0){
         printf("No sources opened\n");
        }
 else{
         a_setseqelem(t, 0, resseq, FALSE);
         /* a_print(resseq->tpl);*/
         a_emit(cxt,t,FALSE);
     }
 }

/////////////////////////////////////////////////////////////////////////////
///////////   database(DSN)  ///////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////


 void DATABASEbf(a_callcontext cxt, a_tuple t)
 {
 /////////////////////
 UCHAR szDBMS[256];  // RESERVE a buffer for th eDBMS name
 SWORD cbDBMS;       // storage for how many bytes are returned in szDBMS.
 char stringa[SQL_MAX_DSN_LENGTH+1];
 BOOL tofind=TRUE;
 member *pMember;

   /* in position 0 there is the DSN */
   a_getstringelem(t,0, stringa,sizeof(stringa),FALSE);
   ods(stringa);
   /* look for the DSN passed with the argument in the queue */
   pMember=pTheQueue->front;
   while(pMember!=NULL && tofind) {
	if(strcmp(stringa,(char*)pMember->data->names[0]) == 0) {
                       tofind = FALSE;
        }
        else {
           pMember=pMember->next;
         }
   }
   if(!tofind) {  /* found the data source we wish to connect to */
               SQLGetInfo(pMember->data->hdbc,SQL_DATABASE_NAME,szDBMS,sizeof(szDBMS),&cbDBMS);
               a_setelem(t,1,mkstring((char*)szDBMS));
               a_emit(cxt,t, FALSE);
	}
	else {
                 printf("DSN %s NOT OPENED\n",stringa);
	}
}

/////////////////////////////////////////////////////////////////////////////
///////////   dbms(DSN)  ///////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////


 void DBMSbf(a_callcontext cxt, a_tuple t)
 {
 /////////////////////
 UCHAR szDBMS[256];  // RESERVE a buffer for th eDBMS name
 SWORD cbDBMS;       // storage for how many bytes are returned in szDBMS.
 char stringa[SQL_MAX_DSN_LENGTH+1];
 BOOL tofind=TRUE;
 member *pMember;

   /* in position 0 there is the DSN */
   a_getstringelem(t,0, stringa,sizeof(stringa),FALSE);
   ods(stringa);

   /* look for the DSN passed with the argument in the queue */
   pMember=pTheQueue->front;
   while(pMember!=NULL && tofind) {
	if(strcmp(stringa,(char*)pMember->data->names[0]) == 0) {
                       tofind = FALSE;
        }
        else {
           pMember=pMember->next;
         }
   }
   if(!tofind) {
                    SQLGetInfo(pMember->data->hdbc,SQL_DBMS_NAME,szDBMS,sizeof(szDBMS),&cbDBMS);
                    a_setelem(t,1,mkstring((char*)szDBMS));
                    a_emit(cxt,t, FALSE);
                    }
	else {
                 printf("DSN %s NOT OPENED\n",stringa);
	}
}
/////////////////////////////////////////////////////////////////////////////
///////////   CONFLEVEL(DSN)  ///////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////


/* void CONFLEVELbf(a_callcontext cxt, a_tuple t)
 {
 /////////////////////
 SWORD szConf;  // RESERVE a buffer for th eDBMS name
 SWORD cbConf;       // storage for how many bytes are returned in szDBMS.
 char stringa[SQL_MAX_DSN_LENGTH+1];
 RETCODE	rc;
 int i;
 BOOL tofind=TRUE;
 UCHAR szSqlState[6];
 member *pMember;
 char *string;
   /* in position 0 there is the DSN */
 /*  a_getstringelem(t,0, stringa,sizeof(stringa),FALSE);
   /* look for the DSN passed with the argument in the queue */
  /* pMember=pTheQueue->front;
   while(pMember!=NULL && tofind) {
    	if(strcmp(stringa,pMember->data->names[0]) == 0) {
                       tofind = FALSE;
        }
        else {
           pMember=pMember->next;
         }
   }
   if(!tofind) {
                    SQLGetInfo(pMember->data->hdbc,SQL_ODBC_SQL_CONFORMANCE,
                                              szConf,sizeof(szConf),&cbConf);
                 switch(szConf) {
                 case SQL_OSC_MINIMUM: strcpy(string,"SQL_OSC_MINIMUM");break;
                 case SQL_OSC_CORE: strcpy(string,"SQL_OSC_CORE");break;
                 case SQL_OSC_EXTENDED:strcpy(string,"SQL_OSC_EXTENDED");break;
                  }
                  a_setelem(t,1,mkstring(string));
                  a_emit(cxt,t, FALSE);
        }
	else {
                 printf("DSN %s NOT OPENED\n",stringa);
	}
}   */
////////////////////////////////////////////////////////////////////////////////////
///////dbtype(DSN)  ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
 void DBTYPEbf(a_callcontext cxt, a_tuple t)
{
   int i;
   char stringa[SQL_MAX_DSN_LENGTH+1];
   BOOL tofind=FALSE;
   /* in position 0 there is the DSN */
   a_getstringelem(t,0, stringa,sizeof(stringa),FALSE);
    // check if the DSN is available using the pointer to the array of avaialable data sources
    for(i=0;i<ciDSN && tofind ;i++){
            if(strcmp((char*)pstDSNArray[i].szDSN, stringa) == 0){
                     tofind = FALSE;
        }
     }
     if(tofind) {
          printf("\nData Source Name : %s NOT AVAILABLE\n",stringa);
     }
     else{
          a_setelem(t,1,mkstring((char*)pstDSNArray[--i].szDescription));
          a_emit(cxt,t, FALSE);
     }
}


////////////////////////////////////////////////////////////////////////////////////
///////ODBCSOURCE(DSN)  ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
 void ODBCSOURCEbf(a_callcontext cxt, a_tuple t)
{
   int i;
   char stringa[SQL_MAX_DSN_LENGTH+1];
   BOOL tofind=FALSE;
   Conne data;
   member *pMember;
   RETCODE	rc;
   UCHAR *szSqlState[6];
   /* in position 0 there is the DSN */
   a_getstringelem(t,0, stringa,sizeof(stringa),FALSE);
    // check if the DSN is available using the pointer to the array of avaialable data sources
    for(i=0;i<ciDSN && tofind ;i++){
            if(strcmp((char*)pstDSNArray[i].szDSN, stringa) == 0){
                     tofind = FALSE;
        }
     }
     if(tofind) {     /* Show the dsn list */
                PrintDSN(pstDSNArray,ciDSN);
                printf("\nData Source Name : %s NOT AVAILABLE\n",stringa);
     }
     else {
        tofind=TRUE;
       // The DSN has been opened before??
        pMember=pTheQueue->front;
        while(pMember!=NULL && tofind) {
         	if(strcmp(stringa, (char*)pMember->data->names[0]) == 0) {
                       tofind = FALSE;
                }
                else {
                       pMember=pMember->next;
                }
         }

      if(!tofind) {
               printf("DSN %s has been opened before\n",stringa);
	}
	else {
                 a_getstringelem(t,0, stringa,sizeof(stringa),FALSE);
                 strcpy( (char*)data.names[0],stringa);

                  /* insert DSN, USERNAME,PASSWORD in the DSN's row inthe table */
                           strcpy((char*)data.names[1],"SYSDBA");
                           strcpy((char *)data.names[2],"masterkey");

/*SQLAllocConnect allocates memory for a connection handle within the environment identified
  by henv. The driver allocates memory and stores the value of the associated handle in the
  hdbc. The application passes the hdbc value in all subsequent calls that require an hdbc .*/

                  SQLAllocConnect(henv,&(data.hdbc));
          /* the hdbc in the DSN's row now contains an allocated connection handle. */
          /* SQLConnect loads a driver and establishes a connection to a data source.*/
          rc = SQLConnect(data.hdbc, data.names[0], SQL_NTS, data.names[1], SQL_NTS, data.names[2], SQL_NTS);
                if(!RETCODE_IS_SUCCESSFUL(rc)){
                    printf("CONNECTION IMPOSSIBLE\n");
                    ShowError(henv, data.hdbc, SQL_NULL_HSTMT, szSqlState);
                    }
                else{
                   /* add the info of the data source to the back of the queue */
                   add(&data,pTheQueue);
            /* return the position of the data source in the queue(the last position) */
                   a_setelem(t,1,mkinteger(pTheQueue->number));
                   a_emit(cxt,t, FALSE);
                   }
   }
  }
}

////////////////////////////////////////////////////////////////////////////////////
///////opends(DSN)  ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
 BOOL ods(char *strin)
{
   int i;
   BOOL tofind=FALSE;
   Conne data;
   member *pMember;
   RETCODE	rc;
   UCHAR *szSqlState[6];

    // check if the DSN is available using the pointer to the array of avaialable data sources
    for(i=0;i<ciDSN && tofind ;i++){
            if(strcmp((char*)pstDSNArray[i].szDSN, strin) == 0){
                     tofind = FALSE;
        }
     }
     if(tofind) {     /* Show the dsn list */
                PrintDSN(pstDSNArray,ciDSN);
                printf("\nData Source Name : %s NOT AVAILABLE\n",strin);
     }
     else {
        tofind=TRUE;
       // The DSN has been opened before??
        pMember=pTheQueue->front;
        while(pMember!=NULL && tofind) {
         	if(strcmp(strin, (char*)pMember->data->names[0]) == 0) {
                       tofind = FALSE;
                }
                else {
                       pMember=pMember->next;
                }
         }

      if(!tofind) {
            //  printf("DSN %s has been opened before\n",strin);
	}
	else {

                 strcpy( (char*)data.names[0],strin);

                  /* insert DSN, USERNAME,PASSWORD in the DSN's row inthe table */
                           strcpy((char *)data.names[1],"SYSDBA");
                           strcpy((char *)data.names[2],"masterkey");

/*SQLAllocConnect allocates memory for a connection handle within the environment identified
  by henv. The driver allocates memory and stores the value of the associated handle in the
  hdbc. The application passes the hdbc value in all subsequent calls that require an hdbc .*/

                  SQLAllocConnect(henv,&(data.hdbc));
          /* the hdbc in the DSN's row now contains an allocated connection handle. */
          /* SQLConnect loads a driver and establishes a connection to a data source.*/
          rc = SQLConnect(data.hdbc, data.names[0], SQL_NTS, data.names[1], SQL_NTS, data.names[2], SQL_NTS);
                if(!RETCODE_IS_SUCCESSFUL(rc)){
                    printf("CONNECTION IMPOSSIBLE\n");
                    ShowError(henv, data.hdbc, SQL_NULL_HSTMT, szSqlState);
                    return(FALSE);
                    }
                else{
                   /* add the info of the data source to the back of the queue */
                   add(&data,pTheQueue);
                   return(TRUE);

                   }
   }
  }
  return FALSE;
}







///////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////  CLOSEODBC   ///////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
  void CLOSEODBCbf(a_callcontext cxt, a_tuple t)
{
   int i;
   char stringa[SQL_MAX_DSN_LENGTH+1];
   BOOL tofind=TRUE;
   member *pMember;
   member *pTemp=NULL;
   a_getstringelem(t,0, stringa,sizeof(stringa),FALSE);

   pMember=pTheQueue->front;
   i=0;
    while(tofind && pMember!=NULL) {
        i++;
	if(strcmp(stringa, (char *)pMember->data->names[0]) == 0) {
           tofind = FALSE;
        }
        else {
           pTemp=pMember;
           pMember=pMember->next;
        }

      }

   /* If is the last member of the queue then change the back of the queue*/
   if(pTheQueue->back==pMember) {
            pTheQueue->back=pTemp;
   }

   if(!tofind) {
       if(pTemp == NULL) {
                pTheQueue->front=pTheQueue->front->next;
       }
       else {
                pTemp->next=pMember->next;
       }
       pTheQueue->number--;
/* SQLDisconnect closes the connection associated with a specific connection handle. */
       SQLDisconnect(pMember->data->hdbc);
       SQLFreeConnect(pMember->data->hdbc);
       free(pMember);

     }
    else {
        printf("DSN IS NO IN THE LIST\n");
        }
    a_setelem(t,1,mkinteger(i));
    a_emit(cxt,t, FALSE);


  }
//////////////////////////////////////////////////////////////////////////
////////          initialization     /////////////////////////////////////
//////////////////////////////////////////////////////////////////////////


init_ODBCAmos(int argc,char **argv)
{

  dcl_connection(c);      /* To hold connection to Amos */
  dcl_oid(fn);            /* To hold Amos functions ODBCSOURCE,CLOSEODBC,SQL0*/
  dcl_scan(s);            /* To hold result streams from Amos queries and function calls */


  /* Pass the address of henv(the application's environment handle) to SQLAllocEnv.*/
  /* SQLAllocEnv allocates memory for an environment handle and initializes the ODBC
     call-level interface for use by an application. An application must call SQLAllocEnv
     prior to calling any other ODBC function.*/
  SQLAllocEnv(&henv);
  /* Create a new queue to hold all the connection opened */
  pTheQueue = newQueue();

  /* Build an array of data source info's for each DSN */
  if(!BuildDSN(henv, &pstDSNArray,&ciDSN)) {
      printf("DSN list empty");
     }
  else {
         PrintDSN(pstDSNArray,ciDSN);
  }

  printf("\n");

  init_amos(argc,argv); /* Initialize embedded Amos */
  a_connect(c,"",FALSE); /* Connect to embedded Amos */

  a_extfunction("ODBCSOURCEbf",ODBCSOURCEbf);
  a_execute(c,s,"create function ODBCSOURCE(charstring a) -> integer x as foreign 'ODBCSOURCEbf';", FALSE);
  a_setf(fn,a_getfunction(c,"charstring.ODBCSOURCE->integer",FALSE));

  a_extfunction("ODBCSOURCEbbbf",ODBCSOURCEbbbf);
  a_execute(c,s,"create function ODBCSOURCE(charstring a, charstring b, charstring c) -> integer x as foreign 'ODBCSOURCEbbbf';", FALSE);
  a_setf(fn,a_getfunction(c,"charstring.charstring.charstring.ODBCSOURCE->integer",FALSE));

  a_extfunction("DATASOURCESf",DATASOURCESf);
  a_execute(c,s,"create function datasources() -> charstring x as foreign 'DATASOURCESf';", FALSE);
  a_setf(fn,a_getfunction(c,"datasources->charstring",FALSE));

  a_extfunction("OPENSOURCESf",OPENSOURCESf);
  a_execute(c,s,"create function opensources() -> vector x as foreign 'OPENSOURCESf';", FALSE);
  a_setf(fn,a_getfunction(c,"opensources->vector",FALSE));

  a_extfunction("DBTYPEbf",DBTYPEbf);
  a_execute(c,s,"create function dbtype(charstring a) -> charstring x as foreign 'DBTYPEbf';", FALSE);
  a_setf(fn,a_getfunction(c,"charstring.dbtype->charstring",FALSE));

  a_extfunction("DATABASEbf",DATABASEbf);
  a_execute(c,s,"create function database(charstring a) -> charstring x as foreign 'DATABASEbf';", FALSE);
  a_setf(fn,a_getfunction(c,"charstring.database->charstring",FALSE));

  a_extfunction("DBMSbf",DBMSbf);
  a_execute(c,s,"create function dbms(charstring a) -> charstring x as foreign 'DBMSbf';", FALSE);
  a_setf(fn,a_getfunction(c,"charstring.dbms->charstring",FALSE));

  a_extfunction("CLOSEODBCbf",CLOSEODBCbf);
  a_execute(c,s,"create function CLOSEODBC(charstring a) -> integer x as foreign 'CLOSEODBCbf';", FALSE);
  a_setf(fn,a_getfunction(c,"charstring.CLOSEODBC->integer",FALSE));

  a_extfunction("TABLESbf",TABLESbf);
  a_execute(c,s,"create function ODBC_TABLES(charstring a) -> charstring x as foreign 'TABLESbf';", FALSE);
  a_setf(fn,a_getfunction(c,"charstring.ODBC_TABLES->charstring",FALSE));


  a_extfunction("get_times_called", get_times_called);
  a_execute(c,s,"create function get_times_called() -> integer x as foreign 'get_times_called';", FALSE);
  a_setf(fn,a_getfunction(c,"GET_TIMES_CALLED->INTEGER",FALSE));

  a_extfunction("COLUMNSbbff",COLUMNSbbff);
  a_execute(c,s,"create function COLUMNS(charstring a,charstring b) -> <charstring x,charstring y> as foreign 'COLUMNSbbff';", FALSE);
  a_setf(fn,a_getfunction(c,"charstring.charstring.COLUMNS->charstring.charstring",FALSE));

  /* Bind C function 'SQL0bbbf' to Amos foreign predicate named 'SQL0bbbf': */
  a_extfunction("SQLbbbf",SQLbbbf);

  /* Define AMOSQL function 'SQL0(a,b,c)->x' to be defined as SQL0bbbf when

     a and b and c are known while x is unknown: */



  // SQL2(charstring, charstring, vector)-> vector

  a_execute(c,s,"create function SQLO(charstring a, charstring b, vector c) -> vector x as foreign 'SQLbbbf';", FALSE);
  a_setf(fn,a_getfunction(c,"charstring.charstring.vector.SQLO->vector",FALSE));

  released(fn);

  free_scan(s);
  free_connection(c);
  amos_toploop("Amos");

  /* Application finish free the environment*/
  SQLFreeEnv(henv);
  return 0;
}
