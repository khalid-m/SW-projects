/*****************************************************************************
 * AMOS2
 *
 * Author: 2013 Khalid Mahmood, UDBL
 * $RCSfile: MongoForeign.c,v $
 * $Revision: 1.9 $ $Date: 2014/01/13 16:05:19 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Foreign functions for Mongo wrapper interface
 ****************************************************************************/
#include <math.h>
#include <time.h>
#include <string.h>
/*****************************************************************************
    MongoDB and AmosII Wrapper
 ****************************************************************************/
#include "callout.h"
#include <storagetypes.h>
#include "mongo.h"
#include "bson.h"
int PORT =  27017;
unsigned int conn_cout = 0;
#define MAXCONN 100 /* maximum no of connections */
#define MAX_ARR_INDX 20
struct connections{
mongo mongo_conn;
char HOST[30];
char arr_indx[MAX_ARR_INDX];
int isInsert;
}conn[MAXCONN]; 
//mongo mongo_conn[MAXCONN];
#define MAX_MONGO_NS 1000


int mongoConn( int conn_no);
int mongoConnStatus( int conn_no);
oidtype bson_data_to_array(bindtype env, const char *data);
oidtype bson_data_to_record(bindtype env, const char *data);
oidtype array_to_bson(bindtype env, char *key ,oidtype *arr, bson *b, 
  int conn_no);
oidtype record_to_bson(bindtype env, oidtype *rec, bson *b, int conn_no);

int too_many_connections;

/******************************************************************************
* function:     new_mongo_conn()                                              *
* Arguments :   int conn_no                                                   *
* Descriptions: This  function Connect to a single MongoDB server.            *
*                               Untill  MAXCONN reached,                      *
* Returns     : Connection number as Ingeger                                  *
* Fn Sign     : create function new_mongo_conn()-> Integer conn_no            *
*               as foreign 'new_mongo_conn';                                  *
******************************************************************************/
oidtype mongo_connectBF(a_callcontext cxt)
{  
  oidtype host;
  char *hostname;
  host = a_arg(cxt, 1);
  IntoString(host, hostname, cxt->env);
  strcpy_s(conn[conn_cout].HOST,sizeof(conn[conn_cout].HOST),hostname);
  if(conn_cout>=MAXCONN)
    {
      a_error(too_many_connections, mkinteger(conn_cout), FALSE);
    }
  if( mongoConn(conn_cout) != MONGO_OK ) {      
    return nil; 
  } 
  a_bind(cxt,2,mkinteger(conn_cout)); //the index number of connection array
  a_result(cxt); /* Emit 1st solution */
  conn_cout++; // creating the new connection 
  return nil; 
}

/******************************************************************************
* function:     mongo_addBBBF()                                               *
* Arguments :   int conn_no, string database, string collection, Record oid   *
* Descriptions: This  function insert a bson object in MongoDB server.        *
* Returns     : MongoDB _id field as int, double, or string otherwise nil if  *
*               the object is already exists with same _id.                   *
* Fn Sign     : mongo_add(Integer  conn_no, Charstring  database,             *
                Charstring collection, Record oid)-> Object id                *
                as foreign 'mongo_add---+';                                   *
******************************************************************************/
oidtype mongo_addBBBBF(a_callcontext cxt)
{
  int conn_no;
  char mongoNameSpace[MAX_MONGO_NS];
  char oidhex[25];
  char *mongoDBName;
  char *mongoCollName;
  bson b[1];
  bson_iterator it;
  bson_type type;
  dcloid(rec);  
  dcloid(conn_no_oid);
  dcloid(db_oid);
  dcloid(coll_oid);
  conn_no_oid=a_arg(cxt,1);
  IntoInteger(conn_no_oid,conn_no,cxt->env); /* Unbox 1nd arg: conn_no */  
  db_oid=a_arg(cxt,2);
  IntoString(db_oid,mongoDBName,cxt->env);/*Unbox 2nd : DBName*/   
  coll_oid=a_arg(cxt,3);
  IntoString(coll_oid,mongoCollName,cxt->env);/*Unbox 3rd : CollName*/   
  sprintf_s(mongoNameSpace,MAX_MONGO_NS,"%s.%s",mongoDBName,mongoCollName);   
  rec = a_arg(cxt, 4); // Bind 4th argument to record 
  OfType(rec, recordtype, cxt->env);      
  if( mongoConnStatus(conn_no) != MONGO_OK ){//check for established conn
    if( mongoConn(conn_cout) != MONGO_OK ){  // othewise create connection
      printf("Connection Cannot be created\n"); 
      return nil; 
    }
  }
  conn[conn_no].isInsert=1;
  record_to_bson(cxt->env, &rec,b, conn_no);   /* creats bson from recods */   
  conn[conn_no].isInsert=0;
  /* Insert the BSON document. */     
  if( mongo_insert( &conn[conn_no].mongo_conn, mongoNameSpace, b, NULL ) 
      != MONGO_OK )       
      return nil; 
  type = bson_find( &it, b, "_id" );  
  switch ( type ){
    case BSON_DOUBLE:                 
      a_bind(cxt, 5, mkreal(bson_iterator_double( &it ))); 
      break;
    case BSON_STRING:      
      a_bind(cxt, 5, mkstring((char *)bson_iterator_string( &it )));
      break;
    case BSON_OID:
      bson_oid_to_string( bson_iterator_oid( &it ), oidhex );
      a_bind(cxt, 5, mkstring(oidhex));
      break;
    case BSON_INT:      
      a_bind(cxt, 5, mkinteger(bson_iterator_int( &it )));
      break;
    default:
      return nil;
  }
  a_result(cxt);  //Bind the result value @parm 5
  bson_destroy( b );      
  return nil;
}
/******************************************************************************
* function:     mongo_del()                                                   *
* Arguments :   int conn_no, string database, string collection, Record oid   *
* Descriptions: This  function delete a bson objects in MongoDB server which  *
                matches with the given Record (BSON)                          *
* Returns     : TRUE as Boolean if successfull, otherwise nil                 *
* Fn Sign     : mongo_del(Integer  conn_no, Charstring  database,             *
                Charstring collection, Record oid) -> Boolean status          *
                as foreign 'mongo_del---+';                                   *
******************************************************************************/
oidtype mongo_delBBBBF(a_callcontext cxt)
{
  int conn_no;
  char mongoNameSpace[MAX_MONGO_NS];
  char *mongoDBName;
  char *mongoCollName;
  bson b[1];
  dcloid(rec);  
  dcloid(conn_no_oid);
  dcloid(db_oid);
  dcloid(coll_oid);
  conn_no_oid=a_arg(cxt,1);
  IntoInteger(conn_no_oid,conn_no,cxt->env); /* Unbox 1nd arg: conn_no */  
  db_oid=a_arg(cxt,2);
  IntoString(db_oid,mongoDBName,cxt->env);/*Unbox 2nd : DBName*/   
  coll_oid=a_arg(cxt,3);
  IntoString(coll_oid,mongoCollName,cxt->env);/*Unbox 3rd : CollName*/   
  sprintf_s(mongoNameSpace,MAX_MONGO_NS,"%s.%s",mongoDBName,mongoCollName);   
  rec = a_arg(cxt, 4); // Bind 4th argument to record 
  OfType(rec, recordtype, cxt->env);  
  if( mongoConnStatus(conn_no) != MONGO_OK ){//check for established conn
    if( mongoConn(conn_cout) != MONGO_OK ) { // othewise create connection
      printf("Connection Cannot be created\n"); 
      return nil; 
    }
  }   
  record_to_bson(cxt->env, &rec,b, conn_no);         
  if( mongo_remove( &conn[conn_no].mongo_conn, mongoNameSpace, b, NULL )
      != MONGO_OK ) {         
    return nil; /* Always return nil */
  }  
  bson_destroy( b );
  //how to do for return TRUE????
  //a_bind(cxt, 5, mkinteger(1)); //Bind the result value @parm 5 
  a_result(cxt);
  return nil; /* Always return nil */
}
/******************************************************************************
* function:     mongo_get()                                                   *
* Arguments :   int conn_no, Charstring  database, Charstring collection,     *
                Record oid                                                    *
* Descriptions: This  function gets  bson object(s) in MongoDB server which   *
                matches with the given Record (BSON)                          *
* Returns     : Bag of Records                                                *
* Fn Sign     : create function get(Integer  conn_no, Charstring  database,   *
                Charstring collection, Record r) -> Bag of Record x           *
                as foreign 'mongo_get---+';                                   *
******************************************************************************/
oidtype mongo_getBBBBF(a_callcontext cxt)
{ 
  int conn_no;
  char mongoNameSpace[MAX_MONGO_NS];
  char *mongoDBName;
  char *mongoCollName;
  bson b[1];
  mongo_cursor cursor[1];
  dcloid(rec);  
  dcloid(conn_no_oid);
  dcloid(db_oid);
  dcloid(coll_oid);
  conn_no_oid=a_arg(cxt,1);
  IntoInteger(conn_no_oid,conn_no,cxt->env); /* Unbox 1nd arg: conn_no */  
  db_oid=a_arg(cxt,2);
  IntoString(db_oid,mongoDBName,cxt->env);/*Unbox 2nd : DBName*/   
  coll_oid=a_arg(cxt,3);
  IntoString(coll_oid,mongoCollName,cxt->env);/*Unbox 3rd : CollName*/   
  sprintf_s(mongoNameSpace,MAX_MONGO_NS,"%s.%s",mongoDBName,mongoCollName);   
  rec = a_arg(cxt, 4); // Bind 4th argument to record 
  OfType(rec, recordtype, cxt->env);  
  if( mongoConnStatus(conn_no) != MONGO_OK ){//check for established conn
    if( mongoConn(conn_cout) != MONGO_OK ){// othewise create connection
      printf("Connection Cannot be created\n"); 
      return nil; /* Always return nil */
    }
  }   
  record_to_bson(cxt->env, &rec,b, conn_no);         
  mongo_cursor_init( cursor, &conn[conn_no].mongo_conn, mongoNameSpace);
  mongo_cursor_set_query( cursor, b );  
  while( mongo_cursor_next( cursor ) == MONGO_OK )
    {           
      t = bson_data_to_record(cxt->env, (&cursor->current)->data);        
      a_bind(cxt,5,t);  //Bind the result value @parm 5
      a_result(cxt); /* Emit 1st solution */                                
    }
  mongo_cursor_destroy( cursor );
  bson_destroy( b );
  return nil;
}
/******************************************************************************
* function:     mongo_add_batch()                                             *
* Arguments :   int conn_no, string database, string collection, Record oid   *
* Arguments :   int write_concern, Vector of Records                          *
                            Vector of Records                                 *
* Descriptions: This function insert a vector of bson object in MongoDB server*
                The follwoing value of the write concern can be used          *
                w = -1 : errors ignored                                       *
                w = 0 : unacknowledged                                        *
                w = 1 : acknowledged                                          *
                w = 2 : replica acknowledged                                  *
                j = 1 (true) : journaled                                      *
                fsync = 1 (true) : fsynced                                    *
            For high performance one should use w = 0: unacknowledged write   *
* URL         : http://api.mongodb.org/c/current/write_concern.html           *
* Fn Sign     : create function mongo_add_batch(Integer  conn_no, Charstring  *
                database, Charstring collection, Integer write_concern,       *
                Vector oid)-> Object  status as foreign 'put_batch';          *
* WARNING     : Current Implementation can only handel 30,000 (approxmately ) *
                simple BSON record probably due to memory limitation(not sure)*
                This can be improved by implementing Bag of Record insted of  *
                vector of records                                             *
******************************************************************************/
oidtype mongo_add_batch(a_callcontext cxt)
{
    int conn_no;
    //int oid;
    char *mongoNameSpace;   
    int write_concern_val;
    int dim;
    int i;
    clock_t t1,t2;  
    mongo_write_concern write_concern[1];
    bson **b, *b_t;         
    dcloid(vector_record);
    IntoInteger(a_arg(cxt,1),conn_no,cxt->env); /* Unbox 1nd arg: conn_no */ 
    IntoString(a_arg(cxt,2),mongoNameSpace,cxt->env);/*Unbox 2nd NameSpace*/
    IntoInteger(a_arg(cxt,3),write_concern_val,cxt->env);/*Unbox 3nd : write*/   
    vector_record = a_arg(cxt, 4); // Bind x to 2nd argument  the record        
    if( mongoConnStatus(conn_no) != MONGO_OK ){//check for established conn
        if( mongoConn(conn_cout) != MONGO_OK ){// othewise create connection
            printf("Connection Cannot be created\n"); 
            return nil;
        }
    }  
    t1 = clock();
    dim = a_arraysize(vector_record);
    b = (bson **)malloc(sizeof(bson*)*dim);
     mongo_write_concern_init( write_concern );
     write_concern->w = write_concern_val;
     mongo_write_concern_finish( write_concern );
     conn[conn_no].isInsert=1; //set flag for every record
    for(i=0;i<dim;i++)
    {       
        oidtype ex = a_elt(vector_record, i);//Bind ex to i-th elmnt of array x
        b_t = (bson *)malloc(sizeof(bson));
        record_to_bson(cxt->env, &ex,b_t, conn_no);
        //bson_print(b_t);      
        b[i]=b_t;
    }
    conn[conn_no].isInsert=0;
    t1 = clock()-t1;
    //bson_init( b );       
    //bson_print(b);        
    //bson_finish( b ); 
    /* Insert the sample BSON document. */  
    i=10;
    //while(i--)
    if( mongo_insert_batch( &conn[conn_no].mongo_conn, mongoNameSpace,
                                     &b[0], dim, write_concern,
                                     MONGO_CONTINUE_ON_ERROR) != MONGO_OK ) 
    {
        printf( "Fail\n" );
        _itoa_s(conn[conn_no].mongo_conn.err, conn[conn_no].arr_indx, 
          sizeof(conn[conn_no].arr_indx), 10);
        strcat_s(conn[conn_no].arr_indx,sizeof(conn[conn_no].arr_indx),
          "# MongoErr");
        a_bind(cxt, 5, mkstring(conn[conn_no].arr_indx)); //Bind to parm 3
        a_result(cxt);          
    }
    //else
        //printf( "PASS\n");                    
    //free(b);
    t2 = clock();
    for(i=0;i<dim;i++)
    {
        bson_destroy(b[i]); 
        free(b[i]);
    }
    mongo_write_concern_destroy( write_concern );
    t2 = clock()-t2;
    printf("Total Time Taken to build the query string: %lf\n",(((float)t1)+
        ((float)t2))/CLOCKS_PER_SEC);
    return nil; /* Always return nil */
}
/*******************************Connection functions *************************/

/******************************************************************************
* function:     mongoConnStatus()                                             *
* Arguments:    int conn_no                                                   *
* Descriptions: This function returns the status of existing mongo connection *
                used in put, get, del foreign functions                       *
******************************************************************************/
int mongoConnStatus( int conn_no)
{   
    return mongo_check_connection( &conn[conn_no].mongo_conn); 
}
/******************************************************************************
* function:     mongoConn()                                                   *
* Arguments:    int conn_no                                                   *
* Descriptions: This  function Connect to a single MongoDB server.            *
                Returns MONGO_OK or MONGO_ERROR on failure. A constant of type*
                mongo_error_t will be set on the conn->err field.             *
******************************************************************************/
int mongoConn( int conn_no)
{
    int status;
    /*
     * mongo_client()
     * Connect to a single MongoDB server.   
     * @param conn a mongo object.
     * @param host a numerical network address or a network hostname.
     * @param port the port to connect to.   
     * @return MONGO_OK or MONGO_ERROR on failure. On failure, 
     *   a constant of type
     *  mongo_error_t will be set on the conn->err field.
     */
    status = mongo_client( &conn[conn_no].mongo_conn,conn[conn_cout].HOST, 
      PORT);
  if( status != MONGO_OK ) {
        switch ( (&conn[conn_no].mongo_conn)->err ) {
        case MONGO_CONN_NO_SOCKET:  printf( "no socket\n" ); break;
        case MONGO_CONN_FAIL:       printf( "connection failed\n" ); break;
        case MONGO_CONN_NOT_MASTER: printf( "not master\n" ); break;
        default: printf("other error\n");
      }
      return MONGO_ERROR;
  } 
  return MONGO_OK;
}



/***************Rrecors <-> BSON conversion functions ************************/
oidtype bson_data_to_array(bindtype env, const char *data)
{  
    dcloid(arr);         
    bson_iterator i;
    int j;
    const char *key;        
    char oidhex[25];    
    int len;                 
    bson_iterator_from_buffer( &i, data);
    len=0;
    // not very effective way to find the "number of elements"
    // as there is no other function
    while ( bson_iterator_next( &i ) ) 
        len++;
    // if we have variable length array it will solve this purpose
    arr= new_array(len,arr);    
    bson_iterator_from_buffer( &i, data);
    j=0;
    while ( bson_iterator_next( &i ) ){
        bson_type t = bson_iterator_type( &i );
    if ( t == 0 )
            break;
        key = bson_iterator_key( &i );
        switch ( t ){
            case BSON_DOUBLE:           
                a_seta(arr,j,mkreal(bson_iterator_double( &i )));
                break;
      case BSON_STRING:
                a_seta(arr,j,mkstring((char *)bson_iterator_string( &i )));
                break;
        /*case BSON_SYMBOL:
                bson_printf( "SYMBOL: %s" , bson_iterator_string( &i ) );
                break;*/
      case BSON_OID:
                bson_oid_to_string( bson_iterator_oid( &i ), oidhex );
                a_seta(arr,j,mkstring(oidhex));
                break;
        /*case BSON_BOOL:
            bson_printf( "%s" , bson_iterator_bool( &i ) ? "true" : "false" );
            break;          
        case BSON_DATE:
            bson_printf( "%ld" , ( long int )bson_iterator_date( &i ) );
            break;
        case BSON_BINDATA:
            bson_printf( "BSON_BINDATA" );
            break;
        case BSON_UNDEFINED:
            bson_printf( "BSON_UNDEFINED" );
            break;
        case BSON_NULL:
            bson_printf( "BSON_NULL" );
            break;
        case BSON_REGEX:
            bson_printf( "BSON_REGEX: %s", bson_iterator_regex( &i ) );
            break;
        case BSON_CODE:
            bson_printf( "BSON_CODE: %s", bson_iterator_code( &i ) );
            break;
        case BSON_CODEWSCOPE:
            bson_printf( "BSON_CODE_W_SCOPE: %s", bson_iterator_code( &i ) );
            bson_iterator_code_scope_init( &i, &scope, 0 );
            bson_printf( "\n\t SCOPE: " );
            bson_print( &scope );
            bson_destroy( &scope );
            break;*/
            case BSON_INT:
                a_seta(arr,j,mkinteger(bson_iterator_int( &i )));
                break;
        /*case BSON_LONG:
            bson_printf( "%lld" , ( uint64_t )bson_iterator_long( &i ) );
            break;
        case BSON_TIMESTAMP:
            ts = bson_iterator_timestamp( &i );
            bson_printf( "i: %d, t: %d", ts.i, ts.t );
            break;*/
            case BSON_OBJECT: 
                a_seta(arr,j,bson_data_to_record(env, 
                    bson_iterator_value( &i )));
                break;
            case BSON_ARRAY:            
                a_seta(arr,j,bson_data_to_array(env, 
                    bson_iterator_value( &i )));
                break;
        }        
        j++;
    }
     return arr;    
 }
oidtype bson_data_to_record(bindtype env, const char *data)
{
    dcloid(rec);
  bson_iterator i;
  const char *key;    
  char oidhex[25];  
    int size;   
    a_blob theBLOB;
    char *theBytes;
    dcloid(oidtypeBLOB);
    rec = make_recordfn(env, rec);  
    bson_iterator_from_buffer( &i, data);
    while ( bson_iterator_next( &i ) ) {
        bson_type t = bson_iterator_type( &i );
        if ( t == 0 )
            break;
        key = bson_iterator_key( &i );
        switch ( t ){
            case BSON_DOUBLE:           
            record_putfn(env, rec, mkstring((char *)key), 
                mkreal(bson_iterator_double( &i )));            
                break;
            case BSON_STRING:
                record_putfn(env,  rec, mkstring((char *)key), 
                mkstring((char *)bson_iterator_string( &i )));            
                break;
        /*case BSON_SYMBOL:
                bson_printf( "SYMBOL: %s" , bson_iterator_string( &i ) );
        break;*/
      case BSON_OID:
                bson_oid_to_string( bson_iterator_oid( &i ), oidhex );
                record_putfn(env,  rec, mkstring((char *)key), 
                    mkstring(oidhex));            
                break;
            /*case BSON_BOOL:
                    bson_printf( "%s" , bson_iterator_bool( &i ) ? "true" : "false" );
                    break;          
        case BSON_DATE:
          bson_printf( "%ld" , ( long int )bson_iterator_date( &i ) );
          break;*/
        case BSON_BINDATA:          
                    theBLOB = a_initBLOB();
                    size = bson_iterator_bin_len(&i);
                    theBytes = (char *) bson_iterator_bin_data(&i);
                    //a_blob theBLOB = a_initBLOB();
                    a_newBLOB(theBLOB, size, FALSE);
                    a_putBLOBbytes(theBLOB, 0, size, theBytes, FALSE);
                    //a_putBLOBelem(theTuple, index, theBLOB, FALSE);
                    //oidtypeBLOB
                    //a_let(oidtypeBLOB,theBLOB);
                    //record_putfn(env,  rec, mkstring((char *)key), 
                    //mkinteger(bson_iterator_int( &i )));
                    a_freeBLOB(theBLOB, FALSE); 
                    //bson_printf( "BSON_BINDATA" );
          break;
            /*case BSON_UNDEFINED:
                    bson_printf( "BSON_UNDEFINED" );
                    break;
            case BSON_NULL:
                    bson_printf( "BSON_NULL" );
                    break;
            case BSON_REGEX:
                    bson_printf( "BSON_REGEX: %s", bson_iterator_regex( &i ) );
                    break;
            case BSON_CODE:
                    bson_printf( "BSON_CODE: %s", bson_iterator_code( &i ) );
                    break;
            case BSON_CODEWSCOPE:
                    bson_printf( "BSON_CODE_W_SCOPE: %s", bson_iterator_code( &i ) );
                    bson_iterator_code_scope_init( &i, &scope, 0 );
                    bson_printf( "\n\t SCOPE: " );
                    bson_print( &scope );
                    bson_destroy( &scope );
                    break;
        */
            case BSON_INT:
                record_putfn(env,  rec, mkstring((char *)key), 
                mkinteger(bson_iterator_int( &i )));        
                break;
        /*case BSON_LONG:
            bson_printf( "%lld" , ( uint64_t )bson_iterator_long( &i ) );
            break;
        case BSON_TIMESTAMP:
            ts = bson_iterator_timestamp( &i );
            bson_printf( "i: %d, t: %d", ts.i, ts.t );
            break;*/
        case BSON_OBJECT://BSON_OBJECT & BSON_ARRAY has the same functionality
                    record_putfn(env,  rec, mkstring((char *)key), 
                    bson_data_to_record(env,bson_iterator_value( &i )));
                    break;
        case BSON_ARRAY:
                    record_putfn(env,  rec, mkstring((char *)key), 
                    bson_data_to_array(env,bson_iterator_value( &i )));
          break;
        }        
    }
     return rec;    
 }
int isHexArr24( char *hexArr ) {
  int i, len;
  len = strlen(hexArr);
  if(len!=24)// as bson _id is always 24      
    return 0; 
  for(i=0;i<24;i++) 
    if (!( (hexArr[i]>= '0' && hexArr[i]<= '9') || 
      (hexArr[i]>= 'a' && hexArr[i]<= 'f') 
      || (hexArr[i]>= 'A' && hexArr[i] <= 'F') ))
      return 0; 
  return 1;
}
oidtype array_to_bson(bindtype env, char *key ,oidtype *arr, bson *b, 
  int conn_no)
 {  
    int type,i=0;
    int arr_len;    
    dcloid(val);    
    arr_len = a_arraysize(*arr);
    bson_append_start_array( b, key );
    while(i<arr_len)
    {       
        val= a_elt(*arr, i);        
        type= a_datatype(val);      
        _itoa_s(i,conn[conn_no].arr_indx,sizeof(conn[conn_no].arr_indx),10);
        if(type == recordtype){
            bson bson_temp[1];          
            record_to_bson(env, &val, bson_temp, conn_no);           
            bson_append_bson(b, conn[conn_no].arr_indx, bson_temp);
            bson_destroy(bson_temp);            
        }
        else            
        switch(type)
            {
            case INTEGERTYPE:
                {
                    int j;
                    IntoInteger(val,j,env); 
                    bson_append_int( b, conn[conn_no].arr_indx, j);
                    break;
                }
            case REALTYPE:
                {
                    double r;
                    IntoDouble(val,r,env);
                    bson_append_double( b, conn[conn_no].arr_indx, r);
                    break;                      
                }
            case STRINGTYPE:
                {
                    char *str;
                    IntoString(val,str,env);
                    if(strcmp(key,"_id")!=0 || isHexArr24(str)==0)
                        bson_append_string( b, conn[conn_no].arr_indx, str);  
                    else
                    {
                        bson_oid_t oid;
                        bson_oid_from_string( &oid, str );
                        bson_append_oid( b, conn[conn_no].arr_indx, &oid );   
                    }                   
                    break;
                }               
            case ARRAYTYPE:             
                    array_to_bson(env, conn[conn_no].arr_indx ,&val, b, 
                      conn_no);
            /*
            case SYMBOLTYPE:
                {
                    oidtype symb = a_getobjectelem(tpl, i, TRUE);
                        
                    CHECK_AMOS_ERROR;
                    if(symb == a_true) ZVAL_BOOL(the_zval,TRUE)
                    else if(symb == a_false) ZVAL_BOOL(the_zval, FALSE)
                    else ZVAL_NULL(the_zval); // symbols except NIL regarded as NULL 
                    break;
                }
            case SURROGATETYPE:
                {
                    char *str;
                    oidtype obj = a_getobjectelem(tpl, i, TRUE);

                    CHECK_AMOS_ERROR;
                    str = make_OID_string(obj);
                    ZVAL_STRING(the_zval,str,1);
                    break;
                }
            default: zend_error(E_ERROR, "Illegal Amos II type in tuple %d", tpe);
            */
            }               
        i++;
    }   
    bson_append_finish_object( b);
    return nil;
}

oidtype record_to_bson(bindtype env, oidtype *rec, bson *b, int conn_no) 
{   
  int type;
  int isKey = 0;
  dcloid(x);
  struct record_scan rs;
  char *key;              
  dcloid(val);
  open_record_scan(*rec, &rs, FALSE); 
  bson_init(b);
  while(!record_scan_empty(&rs))
    {   
      x=record_scan_key(&rs);
      IntoString(x,key,env);
      if(strcmp(key,"_id")==0)
        isKey=1;
      val=record_scan_value(&rs);
      type= a_datatype(val);
      //printf("type is: %d\n",type);
      if(type == recordtype)
            {
                bson bson_temp[1];    
                record_to_bson(env, &val, bson_temp,conn_no);     
                bson_append_bson(b, key, bson_temp);
                bson_destroy(bson_temp);            
            }
      else          
                switch(type)
                {
                    case INTEGERTYPE:
                        {
                            int j;
                            IntoInteger(val,j,env); 
                            bson_append_int( b, key, j);              
                            break;
                        }
                    case REALTYPE:
                        {
                            double r;
                            IntoDouble(val,r,env);
                            bson_append_double( b, key, r);         
                            break;                      
                        }
                    case STRINGTYPE:
                        {
                            char *str;
                            IntoString(val,str,env);
                            if(strcmp(key,"_id")!=0 || isHexArr24(str)==0)
                                bson_append_string( b, key, str);   
                            else
                            {
                                bson_oid_t oid;
                                bson_oid_from_string( &oid, str );
                                bson_append_oid( b, key, &oid );
                            }    
                            break;
                        }
                    case BINARYTYPE:                        
                            printf("BinData\n");                        
                    case ARRAYTYPE:     
                            array_to_bson(env, key ,&val, b, conn_no);       
                        /*case SYMBOLTYPE:
                            {
                            oidtype symb = a_getobjectelem(tpl, i, TRUE);
                        
                            CHECK_AMOS_ERROR;
                            if(symb == a_true) ZVAL_BOOL(the_zval,TRUE)
                            else if(symb == a_false) ZVAL_BOOL(the_zval, FALSE)
                            else ZVAL_NULL(the_zval); // symbols except NIL regarded as NULL 
                            break;
                            }
                            case SURROGATETYPE:
                            {
                            char *str;
                            oidtype obj = a_getobjectelem(tpl, i, TRUE);

                            CHECK_AMOS_ERROR;
                            str = make_OID_string(obj);
                            ZVAL_STRING(the_zval,str,1);
                            break;
                            }
                            default: zend_error(E_ERROR, "Illegal Amos II type in tuple %d", tpe);*/
                }   
      record_scan_next(&rs);
    }
    
  if(conn[conn_no].isInsert==1 && isKey == 0)//only append _id at mongo_add
    bson_append_new_oid( b,"_id");          
  bson_finish(b);  
  return nil;
}
/**************  Initialization *******************/
EXPORT oidtype a_initialize_extension(void)// EXPORT makes DLL entry.
     /* This code is executed when the extension is loaded.
        This happpend when either:
        1. call to load_extension("Mongo_wrapper"); Alloed once only! 
        2. Call to reload_extension("Mongo_wrapper");
        3. The system is initialized with an image where an extension is saved.
     */
{
  int i;

  printf("Loading extension\n");
  a_extimpl("mongo_connect-+",mongo_connectBF);
  a_extimpl("mongo_get----+",mongo_getBBBBF);
  a_extimpl("mongo_add----+",mongo_addBBBBF);
  a_extimpl("mongo_add_batch",mongo_add_batch);     
  a_extimpl("mongo_del----+",mongo_delBBBBF); 
  too_many_connections = 
    a_register_error
    ("Cannot create more connection, maximum connection reached\n");  
  for(i=0;i<MAXCONN;i++)
    conn[i].isInsert=0;
  return nil; 
}


