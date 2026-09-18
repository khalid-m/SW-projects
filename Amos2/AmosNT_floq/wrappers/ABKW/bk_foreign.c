/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2004 Maryam Ladjvardi, UDBL
 * $RCSfile: bk_foreign.c,v $
 * $Revision: 1.9 $ $Date: 2005/03/13 19:52:59 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Foreign functions for ABKW wrapper interface
 *
 ****************************************************************************/

#include "bk_helpfunc.h"
#include <direct.h>

int handleid = 0;//Handle_id for the table used for index of the global array  
int glb_index = 0;//used for the array containing the table handles opened in
		  // metadata functions                        
const char *progname = "bk_dbw";
DB_ENV *dbenv=NULL;  //BerkeleyDB evironment structure
DB_TXN *txnid=NULL;  //Berkely transaction_id
char *HOME;//directory used by BerkeleyDB for databasefile,logging file and etc
int connect_flag = 0; //used for connection to database

void a_errormessage(int e, char *msg)
{
  a_error(e,(strlen(msg)==0?nil:mkstring(msg)),FALSE);
}

int bk_not_initialized, bk_abort_failed, bk_commit_failed,
  bk_table_already_created,
  bk_empty_database, bk_wrong_file, bk_wrong_table,
  bk_cannot_start_transaction, bk_cannot_create_handle,
  bk_handle_closed,
  bk_cannot_create_table, bk_cannot_open_metadata,
  bk_cannot_open_table, bk_wrong_arity, bk_illegal_type,
  bk_cannot_open_cursor,
  bk_cannot_insert, bk_cannot_delete, bk_cannot_close_handle,  
  bk_cannot_open_environment, bk_environment_open,
  bk_cannot_close_environment;



/*****************************************************
* check_init()                                       *
* Arguments: no arguments                            *
* This function checks if the system is initialized. *                              
* ****************************************************/
void check_init()
{
  if (dbenv == NULL)
    a_errormessage(bk_not_initialized,"");
  return;
}
/*************************************
*   End of function check_init()    *
**************************************/

/**************************************************
* check_handle()                                  *
* Arguments: handle_id                            *
* This function checks if the  is  still active.  *                                 
* *************************************************/
void check_handle(int handle_id)
{
  if (bk_handles[handle_id] == NULL)
    a_errormessage(bk_handle_closed,"");
  return;
}  
/*************************************
*   End of function check_handle()   *
**************************************/
	

/******************************************************************************
 * open_metadata_cursor()                                                     *
 * Open a cursor for metadata table in file_name                              *
 *****************************************************************************/
DBC *bk_open_metadata_cursor (DB *dbp,char *file_name, DB_TXN *txnid)
{
  int ret;
  DBC *dbcp;

  //Open the "metadata" table
  if ((ret = dbp->open(dbp,
		       txnid, file_name, "metadata", 
		       DB_BTREE, DB_CREATE, 0664)) != 0) 
    {
      dbp->err(dbp, ret, "%s", file_name);
      a_errormessage(bk_cannot_open_metadata,file_name);
      return NULL;
    }	
  //Acquire a cursor for the table
  if((ret = dbp->cursor(dbp, txnid, &dbcp, 0)) != 0)
    {
      dbp->err(dbp, ret, "DB->cursor");
      dbp->close(dbp, 0);
      a_errormessage(bk_cannot_open_metadata,file_name);
      return NULL;
    }
  return dbcp;
}

/******************************************************************************
 * handle()                                                                   *
 * Arguments: no arguments                                                    *
 * This function close every open table handle, creates new table handles     *
 * enclosed within the transaction.                                           *
 * This function is called by commit() and abort() function that close the old*
 * transaction and start a new one.                                           *
 *****************************************************************************/

void handle()
{
  int j, ret;
  DB *dbp;
  char *btree_name;
  char	*file_name;
	
  //Check the table handles are still actives then close the handles
  for(j=1; j <= handleid; j++)
    {	
      if(bk_handles[j] != NULL)
	{
	  dbp =(bk_handles[j]->dbp);
	  if((ret = dbp->close(dbp, 0)) != 0 )
	    {   
	      dbp->err(dbp, ret, "DB->get");
	      a_errormessage(bk_cannot_close_handle,"");
	      return;
	    }

	  btree_name = bk_handles[j]->btreename;
	  file_name =  bk_handles[j]->filename;
	  //Create and initialize  table object  
	  if((ret = db_create(&dbp, dbenv, 0)) != 0)
	    {
	      fprintf(stderr, "db_create: %s\n", db_strerror(ret));	
	      a_errormessage(bk_cannot_create_handle,btree_name);
	      return;
	    }		

	  dbp->set_errfile(dbp, stderr);
	  dbp->set_errpfx(dbp, progname);
	  //Opens the table
	  if ((ret = dbp->open(dbp, txnid, file_name, btree_name, DB_BTREE, 
			       0, 0664)) != 0) 
	    {
	      dbp->err(dbp, ret, "%s", file_name);
	      dbp->close(dbp, 0);
	      a_errormessage(bk_cannot_open_table, btree_name);
	    }
	  //Set a pointer to the handle in the array
	  bk_handles[j]->dbp = dbp;
	}
    }
  return;
}

/*****************************************
 * End of function handle()              *
 *****************************************/ 


/******************************************************************************
 * BKInit()                                                                   *
 * Arguments: no arguments                                                    *
 * This function creates a database environment handle to be able to support  *
 * one or more berkeley databases, creates a new transaction and set two      *
 * pointers to the enviroment handle and the transaction id in the globals    *
 * variables, respectively.                                                   *
 *****************************************************************************/
void bk_init()
{
  int ret;
	
  //Create an environment and initialize it for additional error reporting
  if((ret = db_env_create(&dbenv, 0)) != 0)
    {
      fprintf(stderr, "%s: %s+n", progname, db_strerror(ret));
      exit(ret); 
    }
  dbenv->set_errfile(dbenv, stderr);
  dbenv->set_errpfx(dbenv, progname);
  dbenv->set_flags(dbenv, DB_DIRECT_DB | DB_DIRECT_LOG, 1);
  //Open an environment
  if((ret = dbenv->open(dbenv, HOME, DB_CREATE | DB_INIT_TXN | 
			DB_INIT_MPOOL | DB_INIT_LOG, 0)) != 0)
    {
      (void)dbenv->close(dbenv, 0);
      a_errormessage(bk_cannot_open_environment, HOME);
      return;
    }	
  //start a new transaction
  if ((ret = dbenv->txn_begin(dbenv, NULL, &txnid, 0)) != 0) 
    {
      dbenv->err(dbenv, ret, "txn_begin");
      exit(ret);	
    }
  return;
}

/*****************************************
 * End of  function BKInit()             *
 *****************************************/ 

/*********************************************************
 * rollback()                                            *
 * Arguments: no arguments                               *
 * This function aborts the actual transaction, creates  *
 * a new one and calls the function handle().            *
 ********************************************************/
void rollback()
{
  int ret;
	
  check_init();
  //Abort the transaction
  if((ret = txnid->abort(txnid)) != 0)
    {
      dbenv->err(dbenv, ret, "txn_abort");
      a_errormessage(bk_abort_failed,"");
      return;
    }
  //start a new transaction
  if ((ret = dbenv->txn_begin(dbenv, NULL, &txnid, 0)) != 0) 
    {
      dbenv->err(dbenv, ret, "txn_begin");
      a_errormessage(bk_cannot_start_transaction,"");
      return;
    }
  handle();
  return;
}

/*************************************
 * End of helpfunction rollback()    *
 *************************************/

/*********************************************************
 * commit()                                              *  	
 * Arguments: no arguments                               *
 * This function Commits the actual transaction, creates *
 * a new one and calls the handle() function.            *
 ********************************************************/
void commit()
{
  int ret;

  check_init();
  //Commit the transaction
  if((ret = txnid->commit(txnid, 0)) != 0)
    {
      a_errormessage(bk_commit_failed,"");
      return;
    }
  //start a new transaction
  if ((ret = dbenv->txn_begin(dbenv, NULL, &txnid, 0)) != 0) 
    {
      dbenv->err(dbenv, ret, "txn_begin");
      a_errormessage(bk_cannot_start_transaction,"");
      return;
    }
  handle();
  return;
}

/*************************************
 * End of helpfunction commit()      *
 *************************************/
/******************************************************************************
 *bk_createhandle() (helpfunction)                                            *
 *Argumens: string filename, string tablename(btree name)                     *
 *return: int handle_id                                                       *
 *Get  all information about the btree_table from "metadata" table on the disk*
 *and put the information in a global array to  use later.                    *
 *The global array is an array which elements are pointers to btree_data      *
 *structure (see bk_helpfunc.h)                                               *
 *****************************************************************************/
int bk_createhandle(char file_name[MAX_NAME_LENGTH], 
		    char btree_name[MAX_NAME_LENGTH])
{
  DB *dbp;
  DBT key, data, oldkey;
  DBC *dbcp;
  int ret, t_ret, c_ret;
  btree_info_t *btree_data;
  attribute_t *attr;
  int i = 0;
  int j = 0;
	
  check_init();	
  btree_data = (btree_info_t *) bk_malloc(sizeof(btree_info_t));
  memset(btree_data, 0, sizeof(btree_data));

  //Create a table handle  
  if((ret = db_create(&dbp, dbenv, 0)) != 0)
    {
      fprintf(stderr, "db_create: %s\n", db_strerror(ret));
      a_errormessage(bk_cannot_create_handle,btree_name);
      return 0;
    }
  dbp->set_errfile(dbp, stderr);
  dbp->set_errpfx(dbp, progname);
	
  dbcp = bk_open_metadata_cursor(dbp,file_name,txnid);
  memset(&data, 0, sizeof(data));
  memset(&key,0,sizeof(key));
  key.data =(char *) bk_malloc (strlen(btree_name) + 1);
  //Using of table_name as the key
  strcpy(key.data, btree_name);
  key.size = strlen(key.data) + 1;

  //get the first record associated with the key, 
  //the first record determines duplicate 
  if((ret = dbcp->c_get(dbcp, &key, &data, DB_SET)) != 0)
    {
      dbcp->c_close(dbcp);
      dbp->close(dbp, 0);
      a_errormessage(bk_wrong_table,btree_name);
      return 0;
    }
  //Check if the table supports duplicates or not	
  if(!strcmp(data.data, "1")) btree_data->keyspec = 1;
  else  btree_data->keyspec = 0;
	
  attr  = (attribute_t *) bk_malloc(sizeof(attribute_t));	
  memset(&oldkey, 0, sizeof(DBT));
  oldkey.data = (char *) bk_malloc(strlen(key.data) + 1);
  strcpy(oldkey.data, key.data);
  //Gets all the data which are associated with the same key
  //(the key is the name of btree_table)
  //and sends each data to parsing_descr function to be parsed 
  //to determine the name and type of 
  //attributes(primary keys and no_primary keys). 
  //Then all these information is saved in the btree_data structure. 
  while((ret = dbcp->c_get(dbcp, &key, &data, DB_NEXT)) == 0
	&& !strcmp(key.data, oldkey.data))
    {
      attr = parsing_descr(data.data);
      if(strcmp(strtok(data.data, " "), "1")==0){
	btree_data->attr_key[i] = 
	  (attribute_t *) bk_malloc(sizeof(attribute_t));
	btree_data->attr_key[i] = attr;
	i++;
      }
      else
	{
	  btree_data->attr_data[j] = 
	    (attribute_t *)bk_malloc (sizeof(attribute_t));
	  btree_data->attr_data[j] = attr;
	  j++;
	}
    }
  strcpy(btree_data->filename, file_name);
  strcpy(btree_data->btreename, btree_name);
  btree_data->primkeyNO = i;
  btree_data->noprimkeyNO= j;

  //Close the tablehandle and the cursor handle
  if((t_ret = dbp->close(dbp, 0)) != 0 && ret == 0 
     && (c_ret = dbcp->c_close(dbcp)) != 0)
    {   
      ret = t_ret;
      return nil;
    }
  //Create and initialize table object  
  if((ret = db_create(&dbp, dbenv, 0)) != 0)
    {
      fprintf(stderr, "db_create: %s\n", db_strerror(ret));
      a_errormessage(bk_cannot_create_handle,btree_name);
      return 0;
    }
  if((ret = dbp->set_flags(dbp, DB_DUP))!=0)
    {
      dbp->err(dbp, ret, "set_flags: DB_DUP");
      a_errormessage(bk_cannot_create_table,btree_name);
      return 0;
    }
  dbp->set_errfile(dbp, stderr);
  dbp->set_errpfx(dbp, progname);

  // 1K page sizes
  if((ret = dbp->set_pagesize(dbp,1024)) != 0)
    {
      dbp->err(dbp, ret, "set_pagesize");
      a_errormessage(bk_cannot_create_table,btree_name);
      return 0;
    }
  //create the table
  if ((ret = dbp->open(dbp, txnid, file_name, btree_name, DB_BTREE, 
		       DB_CREATE |DB_INIT_LOG|DB_INIT_MPOOL, 0664)) != 0) 
    {
      dbp->err(dbp, ret, "%s", file_name);
      dbp->close(dbp, 0);
      a_errormessage(bk_cannot_create_table,btree_name);
      return 0;
    }
  //Set a pointer to the handle and a pointer to the transaction_id 
  //in the array
  btree_data->dbp = dbp;
  //Increase the global variable which is used to index of the global array
  handleid++;
  //Set the btree_info structure in the array
  bk_handles[handleid] = btree_data;
  return handleid; 
}

/**************************************************
 * End of  function bk_createhandle()             *
 **************************************************/ 


/******************************************************************************
 * BkCreate()                                                                 *
 * Arguments:string filename, string tablename, a tuple which contains the    *
 * name(s), type(s) and size of the key(s), a tuple which contains the name(s)*
 * type(s) and size of the data, an integer which determines supporting of    *
 * duplicate i.e if it is equal with one, it means the key is unique and if it*
 * is zero then the key is not unique.                                        *
 * This function store metadata on the disk, it takes the arguments from user *
 * and by using the tablename as key, stores the keys and data as a btree     *
 * which is called "metadata" table.                                          *
 * "metadata" table  is created in the same file as btree table,              *
 * i.e. in a file which name is the first argument.                           *
 *****************************************************************************/
void BKCreate(a_callcontext cxt, a_tuple t){
	
  DB *dbp;
  DBT key,data;
  DBC *dbcp;
  int i, ret, t_ret, cols,k;
  char file_name[MAX_NAME_LENGTH];
  char btree_name[MAX_NAME_LENGTH];
  int  key_spec;

  dcl_tuple(k_tpl);
  dcl_tuple(d_tpl);
  dcl_tuple(tpl);

  commit();
  memset(&key, 0, sizeof(key));
  memset(&data, 0, sizeof(data));

  //get name of file
  a_getstringelem(t, 0, file_name, sizeof(file_name), FALSE);
  //get name of btree which be used as key to storing the name, type and size
  //of the key and data in "metadata" table.
  a_getstringelem(t, 1, btree_name, sizeof(btree_name), FALSE);


  check_init();
  //Create a tble handle  
  if((ret = db_create(&dbp, dbenv, 0)) != 0)
    {
      fprintf(stderr, "db_create: %s\n", db_strerror(ret));	
      a_errormessage(bk_cannot_create_handle,btree_name);
      return;
    }
  dbp->set_errfile(dbp, stderr);
  dbp->set_errpfx(dbp, progname);

  // 1K page sizes
  if((ret = dbp->set_pagesize(dbp,1024)) != 0)
    {
      dbp->err(dbp, ret, "set_pagesize");
      a_errormessage(bk_cannot_create_table,btree_name);
      return;
    }
  if((ret = dbp->set_flags(dbp, DB_DUP))!=0){
    dbp->err(dbp, ret, "set_flags: DB_DUP");
    a_errormessage(bk_cannot_create_table,btree_name);
    return;
  }
  dbcp = bk_open_metadata_cursor(dbp,file_name,txnid);
  key.data =(char *) bk_malloc (strlen(btree_name) + 1);
  //Using of table_name as the key
  strcpy(key.data, btree_name);
  key.size = strlen(key.data) + 1;
	
  if((ret = dbcp->c_get(dbcp, &key, &data, DB_SET))==0)
    {
      free(key.data);
      dbcp->c_close(dbcp);
      dbp->close(dbp, 0);	
      k = bk_createhandle(file_name,btree_name);
      free_tuple(k_tpl);
      free_tuple(d_tpl);
      free_tuple(tpl);
      a_errormessage(bk_table_already_created,btree_name);
      return;
    }
  //The femte argument determines if the table supports duplicate,
  //if this is equal to one, it means no duplicate of key i.e. to single 
  //data item for each key item. If this is zero, duplicate is supported, 
  //i.e. to support multiple data items for each key item. 
  key_spec = a_getintelem(t, 4, FALSE);	
  data.data =(char *) bk_malloc (sizeof(int));
  sprintf(data.data, "%d", key_spec);
  data.size = strlen(data.data) + 1;

  //Add element to "metadata" table, the first data associated with the table 
  //shows duplicate or not_duplicate
  if((ret = dbp->put(dbp, txnid, &key, &data, 0)) == 0)
    {
      //printf("db: %s: key stored %s data stored.\n",
      //  (char *)key.data, (char *)data.data);
    }
  else
    {
      dbp->err(dbp, ret, "DB->put");
      dbcp->c_close(dbcp);
      dbp->close(dbp, 0);	
      free(key.data);
      free(data.data);
      a_errormessage(bk_cannot_create_table,btree_name);
      return;
    }
  //get tuple key from input and store it in k_tpl tuple
  a_getseqelem(t, 2, k_tpl, FALSE);
  //cols shows the number of primarykeys
  if((cols = a_getarity(k_tpl, FALSE)) == 0)
    {
      a_errormessage(bk_wrong_arity,btree_name);
      return ;
    }
  for(i = 0; i < cols; i++)
    {
      a_getseqelem(k_tpl, i, tpl, FALSE);
      //Prepared the data, the keys are tuples of tuples, and each tuple is 
      //sent to pars_data function,
      //to be parsed and made as data which be stored to "metadata" table. 
      pars_data(&data,tpl, 1);
      if((ret = dbp->put(dbp, txnid, &key, &data, 0)) != 0)
	{
	  dbp->err(dbp, ret, "DB->put");
	  free(key.data);
	  free(data.data);
	  dbcp->c_close(dbcp);
	  dbp->close(dbp, 0);
	  a_errormessage(bk_cannot_create_table,btree_name);
	  return;
	}
	}
  //Get the second tuple from input which contains name, type, size of data
  a_getseqelem(t, 3, d_tpl, FALSE);
  //cols shows the number of noprimarykeys
  if((cols = a_getarity(d_tpl, FALSE)) == 0)
    {
      a_errormessage(bk_wrong_arity,btree_name);
      return;
    }
  for(i = 0; i < cols; i++)
    {
      a_getseqelem(d_tpl, i, tpl, FALSE);
      //Prepared the data, the no_primarykeys attribute are tuples of tuples, 
      // and each tuple is send to pars_data function,
      //to be parsed and made as data which be stored to "metadata" table.
      pars_data(&data,tpl, 0);
      if((ret = dbp->put(dbp, txnid, &key, &data, 0)) != 0)
	{
	  dbp->err(dbp, ret, "DB->put");
	  free(key.data);
	  free(data.data);
	  dbcp->c_close(dbcp);
	  dbp->close(dbp, 0);
	  a_errormessage(bk_cannot_create_table,btree_name);
	  return;
	}
    }
  dbcp->c_close(dbcp);
  commit();

  //close the table handle 
  if((t_ret = dbp->close(dbp, 0)) != 0)
    {
      a_errormessage(bk_cannot_close_handle,btree_name);
      return;
    }
  k=bk_createhandle(file_name,btree_name);
  free_tuple(k_tpl);
  free_tuple(d_tpl);
  free_tuple(tpl);
  return ;
}

/******************************************
 * End of  function bk_create()           *
 *****************************************/ 

/***************************************************************
 * makehandle()                                                * 
 * Arguments: Tablename and filename                            *
 * create berkeley handle for the table that exists in the     *
 * database file.                                              *
 ***************************************************************/
DB *makehandle(char *table_name, char *file_name)
{
  DB *dbp;
  int ret;

  if((ret = db_create(&dbp, dbenv, 0)) != 0)
    {
      fprintf(stderr, "db_create: %s\n", db_strerror(ret));	
      a_errormessage(bk_environment_open,table_name);
      return NULL;
    }
  dbp->set_errfile(dbp, stderr);
  dbp->set_errpfx(dbp, progname);

  //Open the table to retreive data
  if ((ret = dbp->open(dbp,
		       txnid, file_name, table_name,DB_BTREE, 0, 0664)) != 0) 
    {
      dbp->err(dbp, ret, "%s", file_name);
      a_errormessage(bk_cannot_open_table, table_name);
      return NULL;
    }
  return dbp;
}

/*************************************
 * End of  function makehandle()     *
 *************************************/ 


/*******************************************************************
 * BKConnect()                                                     * 
 * Argumens: string databasefile name                              *
 * Open the database file to enable the user to work with the      *
 * database file.                                                  *
 *******************************************************************/
void BKConnect(a_callcontext cxt, a_tuple t)
{
  DB *dbp;
  DBT key, data, oldkey;
  DBC *dbcp;
  int ret, t_ret;	
  char file_name[MAX_NAME_LENGTH];
  btree_info_t *btree_data;
  attribute_t *attr;
  int i = 0;
  int j = 0;
  int k=0;
  int flag=1;

  //get name of file
  a_getstringelem(t, 0, file_name, sizeof(file_name), FALSE);

  check_init();
  if(connect_flag == 1) return;

  //Create a table handle  
  if((ret = db_create(&dbp, dbenv, 0)) != 0)
    {
      fprintf(stderr, "db_create: %s\n", db_strerror(ret));	
      a_errormessage(bk_cannot_create_handle,file_name);
      return;
    }
  dbp->set_errfile(dbp, stderr);
  dbp->set_errpfx(dbp, progname);

  dbcp = bk_open_metadata_cursor(dbp,file_name,txnid);
	
  //Initialize key and data structures
  memset(&key, 0, sizeof(key));
  memset(&data, 0, sizeof(data));

  //Get the first key/data pair from metadata table. 
  if((ret = dbcp->c_get(dbcp, &key, &data, DB_FIRST)) != 0)
    {
      dbp->err(dbp, ret, "DB->get");
      dbcp->c_close(dbcp);
      dbp->close(dbp, 0);
      a_errormessage(bk_empty_database, file_name);
      return;
    }
  btree_data = (btree_info_t *) bk_malloc(sizeof(btree_info_t));
  memset(btree_data, 0, sizeof(btree_data));

  handleid++;
  btree_data->dbp = makehandle(key.data,file_name);

  //Checking if the table supports dupplicate or not	
  if(!strcmp(data.data, "1")) btree_data->keyspec = 1;
  else  btree_data->keyspec = 0;
  attr  = (attribute_t *) bk_malloc(sizeof(attribute_t));	
  memset(&oldkey, 0, sizeof(DBT));
  oldkey.data = (char *) bk_malloc(strlen(key.data) + 1);
  strcpy(oldkey.data, key.data);
  //Walk the table to get other key/data pairs
  while((ret = dbcp->c_get(dbcp, &key, &data, DB_NEXT)) == 0||flag)
    {
      if(ret==0 &&!strcmp(key.data, oldkey.data))
	{
	  attr = parsing_descr(data.data);
	  if(strcmp(strtok(data.data, " "), "1")==0)
	    {
	      btree_data->attr_key[i] = 
		(attribute_t *)bk_malloc(sizeof(attribute_t));
	      btree_data->attr_key[i] = attr;
	      i++;
	    }
	  else
	    {
	      btree_data->attr_data[j] = 
		(attribute_t *)bk_malloc (sizeof(attribute_t));
	      btree_data->attr_data[j] = attr;
	      j++;
	    }
	}
      else
	{
	  strcpy(btree_data->filename, file_name);
	  strcpy(btree_data->btreename, oldkey.data);
	  btree_data->primkeyNO = i;
	  btree_data->noprimkeyNO= j;		
	  bk_handles[handleid] = btree_data;	
	  strcpy(oldkey.data, key.data);
	  if(ret== DB_NOTFOUND)
	    {
	      flag = 0;
	      continue;
	    }
	  btree_data = (btree_info_t *) bk_malloc(sizeof(btree_info_t));
	  memset(btree_data, 0, sizeof(btree_data));
	  handleid++;	
	  btree_data->dbp = makehandle(key.data,file_name);	
	  //Checking if the table supports dupplicate or not	
	  if(!strcmp(data.data, "1"))btree_data->keyspec = 1;
	  else btree_data->keyspec = 0;
	  attr  = (attribute_t *) bk_malloc(sizeof(attribute_t));
	  i=0;
	  j=0;			
	}
    }
  //close the cursor handle
  dbcp->c_close(dbcp);
  //close the table handle
  if((t_ret = dbp->close(dbp, 0)) != 0 ) 
    {
      a_errormessage(bk_cannot_close_handle,file_name);
      return;
    }
  connect_flag = 1;
  return;
}

/*************************************************************************
 * BKHandle()                                                            * 
 * Argumens: string filename, string table name(btree name)              *
 * return: int handle_id                                                 *
 * This function returns the table handle if it is not exist, create it. *
 *************************************************************************/
void BKHandle(a_callcontext cxt, a_tuple t)
{	
  char file_name[MAX_NAME_LENGTH];
  char btree_name[MAX_NAME_LENGTH];
  int handle_id;	
	
  //get name of file
  a_getstringelem(t, 0, file_name, sizeof(file_name), FALSE);
  //get name of btree which is used as the key to get information 
  //from "metadata" table
  a_getstringelem(t, 1, btree_name, sizeof(btree_name), FALSE);

  check_init();
  if((handle_id=bk_open(file_name, btree_name)) == 0)
    {
      a_errormessage(bk_wrong_table,btree_name);
      return;
    }
  if(handle_id == -1)
    {
      a_errormessage(bk_wrong_file,file_name);
      return;
    }
  //Returns the index of the array to Amos	 
  a_setintelem(t, 2, handle_id, FALSE);
  a_emit(cxt, t, FALSE);
  return;
}

/*********************************
 * End of  function BKHandle()	 *
 **********************************/

/*************************************************
 * get_index()                                   *
 * return the next place in global handle array  *
 * which used for table handles that open  in    *
 * the function bk_primkeys() and bk_columns()   *
 ************************************************/

int get_index()
{
  return(++glb_index);
}

/************************************
 * End of function get_index()       *
 ************************************/
/***************************************************
 *meta_datahandel()                                *
 *this function is called by meta_data functions   *                    
 *to create table handle                           *
 **************************************************/
void meta_datahandle(char* file_name, handle_tpl_t *handle_tpl)
{ 
  DB *dbp;
  DBC *dbcp;
  int ret;
  int index;
  handle_db_t *db_hand;
	 
  check_init();
  //Create a table handle  
  if((ret = db_create(&dbp, dbenv, 0)) != 0){
    fprintf(stderr, "db_create: %s\n", db_strerror(ret));	
    exit(1);
  }
  dbp->set_errfile(dbp, stderr);
  dbp->set_errpfx(dbp, progname);	
  dbcp = bk_open_metadata_cursor(dbp,file_name,NULL);
  db_hand = (handle_db_t *) bk_malloc(sizeof(handle_db_t)); 
  db_hand->dbp = dbp;
  index = get_index();
  handle_array[index] = db_hand;

  // handle_tpl = (handle_tpl_t *) malloc(sizeof(handle_tpl_t)); 
  handle_tpl->index = index;
  handle_tpl->dbcp = dbcp;
  handle_tpl->dbp = dbp;

  return;
}
/******************************************
 * End of function meta_datahandle()      *
 *****************************************/

/***************************************************
 *get_key_data()                                   *
 *this function is called by meta_data functions   *
 *bk_primkeys()and bk_columns()                    *
 *to get data by the known key                     *
 **************************************************/
int get_key_data(DBT *key, DBT *data, DBT *oldkey,
		  char *table_name, DBC *dbcp, DB *dbp, int index)
{	
  int ret;
	
  memset(data, 0, sizeof(DBT));
  memset(key, 0, sizeof(DBT));
  key->data =(char *) bk_malloc (strlen(table_name) + 1);
  //Using of table_name as the key
  strcpy(key->data, table_name);
  key->size = strlen(key->data) + 1;
  //Get the first data which is associated with the key, and ignore this data,
  //because the first data only determines duplicate, it is not interesting 
  //here.
  if((ret = dbcp->c_get(dbcp, key, data, DB_SET)) != 0)
    {
      dbp->err(dbp, ret, "DB->get");
      dbcp->c_close(dbcp);
      handle_array[index] = NULL;
      dbp->close(dbp, 0);
      a_errormessage(bk_wrong_table,table_name);
      return 0;
    }	
  memset(oldkey, 0, sizeof(DBT));
  oldkey->data = (char *) bk_malloc(strlen(key->data) + 1);
  strcpy(oldkey->data, key->data);
	
  return 1;
}
/******************************************
 * End of function get_key_data()         *
 *****************************************/
/**************************************************************************
 * BKPrimary_keys()                                                       *
 * Arguments: charstring filename, charstring tablename                   *
 * return: bag of charstring(the column_name(s) of the key(s))            *
 * Get the keys of the table from "metadata" on the disk by using the     * 
 * tablename as the key to get info from "metadata" table                 *
 **************************************************************************/
void BKPrimary_keys(a_callcontext cxt, a_tuple t)
{
  DB *dbp;
  DBT key, data, oldkey;
  DBC *dbcp;
  int ret;	
  char file_name[MAX_NAME_LENGTH];
  char btree_name[MAX_NAME_LENGTH];
  int flag = 1;
  char *key_name;
  int prim_key, index;
  char *str;
  char str1[6];
  handle_tpl_t handle_tpl;
	
  //get name of file
  a_getstringelem(t, 0, file_name, sizeof(file_name), FALSE);
  //get name of btree
  a_getstringelem(t, 1, btree_name, sizeof(btree_name), FALSE);

  check_init(); 
  meta_datahandle(file_name, &handle_tpl);
  dbp=handle_tpl.dbp;
  dbcp=handle_tpl.dbcp;
  index=handle_tpl.index; 
  if(!get_key_data(&key, &data, &oldkey,btree_name,
							 dbcp, dbp, index)){
	 dbcp->c_close(dbcp);
	 dbp->close(dbp, 0);
	 free(handle_array[index]);
	 handle_array[index] = NULL;
	 return;}

  //Get all the key/data pairs which have the same key, i.e. they belong to
  //the actual table, and choose these which satisfies the key of the table.
  while((ret = dbcp->c_get(dbcp, &key, &data, DB_NEXT)) == 0
	&& !strcmp(key.data, oldkey.data) && flag)
    {
      str = strtok(data.data, " ");
      sprintf(str1, "%s\0", str);
      prim_key = atoi(str1);
      if(prim_key == 1)
	{
	  key_name = strtok(NULL, " ");	
	  //return result to Amos
	  a_setstringelem(t, 2, key_name, FALSE);
	  a_emit(cxt, t, FALSE);
	}
      else flag = 0;
    }
  dbcp->c_close(dbcp);
  dbp->close(dbp, 0);
  free(handle_array[index]);
  handle_array[index] = NULL;
  return;
}

/**************************************************
 * End of foreign function BKPrimary_key()        *
 **************************************************/ 


/******************************************************************************
 *BKColumns()                                                                 *
 *Arguments: charstring filename, charstring tablename                        *
 *return: bag of <charstring column_name, charstring column_type>             *
 *Get the name and the type of columns of BKDB_table from "metadata" on the   *
 * disk by using the tablename as the key to get info from                    *
 * "metadata" table.                                                          *
 *****************************************************************************/
void BKColumns(a_callcontext cxt, a_tuple t)
{
  DB *dbp;
  DBT key, data, oldkey;
  DBC *dbcp;
  int ret;	
  char file_name[MAX_NAME_LENGTH];
  char btree_name[MAX_NAME_LENGTH];
  char *key_name;
  int key_type, index;
  char *str, str1[5];
  handle_tpl_t handle_tpl;

  //get name of file from input
  a_getstringelem(t, 0, file_name, sizeof(file_name), FALSE);
  //get name of btree from input
  a_getstringelem(t, 1, btree_name, sizeof(btree_name), FALSE);

  check_init();
  meta_datahandle(file_name, &handle_tpl);
  dbp=handle_tpl.dbp;
  dbcp=handle_tpl.dbcp;
  index=handle_tpl.index; 
  if(!get_key_data(&key, &data, &oldkey,btree_name,
							 dbcp, dbp, index)){
	 dbcp->c_close(dbcp);
	 dbp->close(dbp, 0);
	 free(handle_array[index]);
	 handle_array[index] = NULL;
	 return;}
  

  //Get all the key/data pairs which have the same key, i.e. they belong to
  //the actual table, and determine the name and the type of the columns.
  while((ret = dbcp->c_get(dbcp, &key, &data, DB_NEXT)) == 0
	&& !strcmp(key.data, oldkey.data))
    {
      strtok(data.data, " ");
      key_name = strtok(NULL, " ");
      a_setstringelem(t, 3, key_name, FALSE);
      str = strtok(NULL, " ");
      sprintf(str1, "%s\0", str);
      key_type = atoi(str1);
		
      switch(key_type){
      case INTEGERTYPE:
	a_setstringelem(t, 2, "integer", FALSE);
	break;

      case REALTYPE:
	a_setstringelem(t, 2, "real", FALSE);
	break;

      case STRINGTYPE:
	a_setstringelem(t, 2, "charstring", FALSE);
	break;

      default:
		dbcp->c_close(dbcp);
		dbp->close(dbp, 0);
		free(handle_array[index]);
		handle_array[index] = NULL;
        a_errormessage(bk_illegal_type,"");
		return;
      }
      a_emit(cxt, t, FALSE);	
    }
  dbcp->c_close(dbcp);
  dbp->close(dbp, 0);
  free(handle_array[index]);
  handle_array[index] = NULL;
  return;
}

/**************************************************
 * End of foreign function BKColumns()            *
 **************************************************/ 

/******************************************************************************
 *BKTables()                                                                  *
 *Arguments: charstring filename                                              *
 *return: bag of charstring BKDB_table name                                   *
 *Get the name  of BKDB_table which exist in a givet berkeleydb file          *
 *Get all the key/data pairs from "metadata" table on the disk. It is the     *
 *keys which are interesting here since the keys in "metadata" base determine *
 *the name of BKDB_table.                                                     *
 *****************************************************************************/
void BKTables(a_callcontext cxt, a_tuple t)
{
  DB *dbp;
  DBT key, data, oldkey;
  DBC *dbcp;
  int ret,index;	
  char file_name[MAX_NAME_LENGTH];
  handle_tpl_t handle_tpl;

  //get name of file
  a_getstringelem(t, 0, file_name, sizeof(file_name), FALSE);

  check_init();
  meta_datahandle(file_name, &handle_tpl);
  dbp=handle_tpl.dbp;
  dbcp=handle_tpl.dbcp;
  index=handle_tpl.index;

  //Initialize key and data structures
  memset(&key, 0, sizeof(key));
  memset(&data, 0, sizeof(data));
  //Get the first key/data pair from metadata table. 
  if((ret = dbcp->c_get(dbcp, &key, &data, DB_FIRST)) != 0)
    {
      dbp->err(dbp, ret, "DB->get");
      dbcp->c_close(dbcp);
      dbp->close(dbp, 0);
      free(handle_array[index]);
      handle_array[index] = NULL;
      printf("no table in database file\n");
      return;
    }
  //return result to Amos
  a_setstringelem(t, 1, key.data, FALSE);
  a_emit(cxt, t, FALSE);

  memset(&oldkey, 0, sizeof(DBT));
  oldkey.data = (char *) bk_malloc(strlen(key.data) + 1);
  strcpy(oldkey.data, key.data);
  //Walk the table to get other key/data pairs
  while((ret = dbcp->c_get(dbcp, &key, &data, DB_NEXT)) == 0)
    {
      if(!strcmp(key.data, oldkey.data)) continue;
      else
	{
	  a_setstringelem(t, 1, key.data, FALSE);
	  strcpy(oldkey.data, key.data);
	  a_emit(cxt, t, FALSE);

	}
    }
  //close the cursor handle
  dbcp->c_close(dbcp);
  //close the table handle
  dbp->close(dbp, 0);
  free(handle_array[index]);
  handle_array[index] = NULL;
  return;
}

/**************************************************
 * End of foreign function BKTables()             *
 **************************************************/

/******************************************************************************
 *count_record()                                                              *
 *Arguments: char *file_name, char *btree_name  			      *
 *return: integer                                                             *
 *This function count the number of records which exists in the table         *
 *****************************************************************************/
int count_record(char *file_name, char *btree_name)
{	
  DB *dbp;
  DB_BTREE_STAT *statp;
  int ret;
  int no_of_record;
	
  /* Create and initialize table object, open the table. */
  if ((ret = db_create(&dbp, dbenv, 0)) != 0) 
    {
      fprintf(stderr,
	      "%s: db_create: %s\n", progname, db_strerror(ret));
      a_errormessage(bk_cannot_create_handle,file_name);
      return 0;
    }
  if ((ret = dbp->open(dbp,
		       NULL, file_name, 
		       btree_name, DB_BTREE, DB_RDONLY, 0664)) != 0) 
    {
      dbp->err(dbp, ret, "open: %s", file_name);
      a_errormessage(bk_cannot_open_table, btree_name);
      return 0;
    }
  /* Print out the number of records in the table. */

  if ((ret = dbp->stat(dbp,(void *)&statp,0)) != 0) 
    {
      dbp->err(dbp, ret, "DB->stat");
      free(statp);
      dbp->close(dbp, 0);
      exit(1);
    }
  no_of_record = (int)statp->bt_ndata;
  free(statp);
  dbp->close(dbp, 0);
  return no_of_record;
}

/**************************************************
 * End of  function count_record()                *
 **************************************************/ 

/******************************************************************************
 *BKCost()                                                                    *
 *Arguments: function fn, vector, vector				      *
 *return: The cost of execution bk_access function                            *
 *This function count the cost of execution  of bk_access function            *
 *****************************************************************************/
void BKCost(a_callcontext cxt, a_tuple t)
{
  char file_name[MAX_NAME_LENGTH];
  char btree_name[MAX_NAME_LENGTH];
  int no_of_records, sum;
  int handle_id;
  int type;
  dcl_tuple(arg_tpl);
	
  a_getseqelem(t, 2, arg_tpl, FALSE);

  if((type = a_datatype(a_getelem(arg_tpl,0, FALSE))) == 1)
    {
      sum = 3000;
      no_of_records = 1000;
    }
  else 
    {
      handle_id = a_getintelem(arg_tpl,0,FALSE);
      strcpy(file_name, bk_handles[handle_id]->filename);
      strcpy(btree_name, bk_handles[handle_id]->btreename);
      no_of_records = count_record(file_name, btree_name);
      sum = 1000 + (no_of_records * 2);
    }
  a_setintelem(t, 3, sum, FALSE);
  a_setintelem(t, 4, no_of_records, FALSE);
  a_emit(cxt, t, FALSE);
  return;
}
/*********************************
 * End of  function bk_cost()    *      
 *********************************/ 

/*******************************************
 *encode_tuple()                           *
 *This function takes a tuple and puts     *
 *the contents of the tuple in the buffer  *
 ********************************************/
int encode_tuple(a_tuple t, bk_buf_t *bkbuf, int handle_id){

  int i,j, size, bufsize;
  int primkey_NO;		//number of primary key
  int attr_type,len;
  char *stri;
  int str_len = 0;
  int key_len = 0;
  int ivalue;
  unsigned ivalu;
  double dvalue;
  char ibuf[sizeof(int)];
  char rbuf[sizeof(short int)];
  unsigned char dst[sizeof(double)];

  //Get the number of the primary key(s)
  primkey_NO = a_getarity(t, FALSE);
  //Check to see if number of key is the same as number of BKDB_table key
  if(primkey_NO != bk_handles[handle_id]->primkeyNO){
    printf("Wrong number of primary key values");
    return 0;}

  if(str_len == 0){
    stri = (char *) malloc(1000);
    str_len = 1000;
  }
 
  //Get type of the key from the global array
  for(i=0; i < primkey_NO; i++){
    attr_type = bk_handles[handle_id]->attr_key[i]->type;
    //Check the datatype
    switch(attr_type){
    case INTEGERTYPE:
      ivalue = a_getintelem(t, i, FALSE);
      ivalu = bk_encode(ivalue);
      bk_normal_int(ivalu, ibuf); 
      bufsize = bkbuf->size - bkbuf->pos;
      if(bufsize < sizeof(int)){
	bkbuf->size = bkbuf->size *2;
	if((bkbuf->buf = realloc(bkbuf->buf, bkbuf->size)) == NULL){
	  fprintf(stderr, "ERROR: realloc failed");
	  free(stri);
	  return 0;}
      }

      memcpy(bkbuf->buf, ibuf, sizeof(int));
      bkbuf->buf= bkbuf->buf+ sizeof(int);
      bkbuf->pos = bkbuf->pos + sizeof(int);
      break;

    case REALTYPE:
      dvalue = a_getdoubleelem(t, i, FALSE);
      bk_encode_double(dvalue, rbuf, dst); 
      bufsize = bkbuf->size - bkbuf->pos;
      if(bufsize < sizeof(double) + sizeof(short int)){
	bkbuf->size = bkbuf->size *2;
	if((bkbuf->buf = realloc(bkbuf->buf, bkbuf->size)) == NULL){
	  fprintf(stderr, "ERROR: realloc failed");
	  free(stri);
	  return 0;}
      }
      memcpy(bkbuf->buf, rbuf, sizeof(short int));
      bkbuf->buf= bkbuf->buf+ sizeof(short int);
      bkbuf->pos = bkbuf->pos  + sizeof(short int);
      memcpy(bkbuf->buf, dst, sizeof(double));
      bkbuf->buf= bkbuf->buf+ sizeof(double);
      bkbuf->pos = bkbuf->pos + sizeof(double);
      break;

    case STRINGTYPE:
      size = bk_handles[handle_id]->attr_key[i]->size;
      len = a_getelemsize(t, i, FALSE);
      if(len > str_len){
	if((stri = realloc(stri, len*2)) == NULL){
	  fprintf(stderr, "ERROR: realloc failed");
	  free(stri);
	  return 0;}
	str_len = len*2;}
      bufsize = bkbuf->size - bkbuf->pos;
      if(bufsize < len ){
	if((bkbuf->buf = realloc(bkbuf->buf, len*2)) == NULL){
	  fprintf(stderr, "ERROR: realloc failed");
	  free(stri);
	  return 0;}
	bkbuf->size = len*2;
      }
      a_getstringelem(t, i, stri, len, FALSE);
      memcpy(bkbuf->buf, stri, len);
      for (j=len; j<size; j++)
	bkbuf->buf[j] = ' ';
      bkbuf->pos = bkbuf->pos + size;
      bkbuf->buf = bkbuf->buf + size;
      break;

    default:
      free(stri);
      a_errormessage(bk_illegal_type,"");
      return 0;
    }

   
  }
  free(stri);
  return 1;

}
/**************************************
 * End of  function encode_tuple()    *      
 **************************************/
 
/********************************************
 *init_buf()                                *
 *This function initialize bk_buf data      *
 *structure. (see bk_helpfuc.h)             *
 ********************************************/
void init_buf(bk_buf_t *bkbuf, char *buf)
{

  bkbuf->buf = buf;
  bkbuf->size = 1000;
  bkbuf->pos = 0;
}
/**********************************
 * End of  function init_buf()    *      
 **********************************/

/*******************************************
 *decode_tuple()                            *
 *This function goes through the data and   *
 *fills the tuple to return to amos.        *
 ********************************************/
int decode_tuple(a_callcontext cxt, a_tuple t, DBT *data, int no_primkey, 
		 int handle_id,int pos, char *dataval){

  int i, size;
  int attr_type;
  unsigned res;
  char dobbuf[sizeof(double)];
  double *dobvalue;

  dcl_tuple(result);
  a_newtuple(result, no_primkey, FALSE);
  
  //Get type of the data from the global array and do the needed operations
  //to be able to return the correct format of the data to Amos.
  for(i=0; i < no_primkey; i++){
    attr_type = bk_handles[handle_id]->attr_data[i]->type;
    //Check the datatype
    switch(attr_type){
    case INTEGERTYPE:
      memcpy(&res, data->data, sizeof(int));
      a_setintelem(result, i, res, FALSE);
      data->data = (char *)data->data + sizeof(int);
      break;

    case REALTYPE:
      memcpy(dobbuf, data->data, sizeof(double));
      dobvalue=(double *) dobbuf;
      a_setdoubleelem(result, i, (*dobvalue), FALSE);
      data->data =(char *) data->data + sizeof(double);
      break;

    case STRINGTYPE:
      size = bk_handles[handle_id]->attr_data[i]->size;
      memcpy(dataval, data->data, size);
      dataval=strtok(dataval,"\0");
      a_setstringelem(result, i, dataval, FALSE);
      data->data = (char*)data->data + size;
      break;
   
    default:
      free(result);
      a_errormessage(bk_illegal_type,"");
      return 0;
    }
    a_setseqelem(t, pos, result, FALSE);
  }
  a_emit(cxt, t, FALSE);
  free(result);
  return 1;
}

/**************************************
 * End of  function decode_tuple()    *      
 **************************************/

/******************************************************************************
 *BKSet()                                                                     *
 *Arguments: integer handle_id, a tuple of key(s), a tuple of data            *
 *return: integer handle_id                                                   *
 *Store key/data pair in BKDB_table(update or add function)                   *
 *Gathering info about the BKDB_table from the global array by using handle_id*
 *as index and do the needed operaitons for inserting or updating.            *
 *Before insert key/data pair in the BKDB_table check if the table support    *
 *duplicate, in this case the key/data pair is inserted(add function),        *
 *otherwise(not duplicate) check if the key is already exist and delete the   *
 *key/data pair and then the new key/data pair is inserted(update function)   *
 *****************************************************************************/
void BKSet(a_callcontext cxt, a_tuple t)
{

  DB *dbp;
  DBT key, data;
  int handle_id, i, size;
  int j =0, k = 0;
  int noprimkey_No;		//number of not primary key
  int attr_type, bufsize;
  int ret, len, key_spec; 
  int str_len = 0;
  int key_len = 0; 
  int data_len = 0;
  char *stri;
  int ivalue;
  double dvalue;
  char* dbuf;
  char* dobbuf;
  bk_buf_t bkbuf1, bkbuf2;

  dcl_tuple(k_tpl);
  dcl_tuple(d_tpl);

  //get handle_id to open the handle
  handle_id = a_getintelem(t, 0, FALSE);
  check_init();
  check_handle(handle_id);
  //The key tuple(first tuple) from input is stored in k_tpl tuple
  a_getseqelem(t, 1, k_tpl, FALSE);
  
  memset(&key, 0, sizeof(key));
  if(key_len == 0){
    key.data = bk_malloc(1000);
    key_len = 1000;
  }
  init_buf(&bkbuf1, key.data);
  //check if an error happened in encode_tuple
  if(!encode_tuple(k_tpl, &bkbuf1, handle_id)){
    free(key.data);
    free(k_tpl);
    free(d_tpl);
    return;}

  //The data tuple(second tuple) from input is stored in d_tpl tuple
  a_getseqelem(t, 2, d_tpl, FALSE);
  //Get the number of the not primary key(s) 
  noprimkey_No = a_getarity(d_tpl, FALSE);
  //Check to see if number of not key is the same as number of BKDB_table 
  //not key
  if(noprimkey_No != bk_handles[handle_id]->noprimkeyNO)
    {
      free(key.data);
      free(k_tpl);
      free(d_tpl);
      a_errormessage(bk_wrong_arity,bk_handles[handle_id]->btreename);
      return;
    }
  
  memset(&data, 0, sizeof(data));
  if(data_len == 0){
    data.data = bk_malloc(1000);
    data_len = 1000;
  }
  init_buf(&bkbuf2, data.data);

  if(str_len == 0){
    stri = (char *) malloc(1000);
    str_len = 1000;
  }
 

  //Get type of the data from the global array
  for(i=0; i < noprimkey_No; i++)
    {
      attr_type = bk_handles[handle_id]->attr_data[i]->type;
      //Check the datatype
      switch(attr_type){
      case INTEGERTYPE:
	ivalue = a_getintelem(d_tpl, i, FALSE);
	dbuf =(char *) &ivalue;
	bufsize = bkbuf2.size - bkbuf2.pos;
	if(bufsize < sizeof(int)){
	  bkbuf2.size = bkbuf2.size *2;
	  if((bkbuf2.buf = realloc(bkbuf2.buf, bkbuf2.size)) == NULL){
	    fprintf(stderr, "ERROR: realloc failed");	
	    free(stri);
	    free(key.data);
	    free(data.data);
	    free(k_tpl);
	    free(d_tpl);
	    return;}
	}
	memcpy(bkbuf2.buf, dbuf, sizeof(int));
	bkbuf2.buf= bkbuf2.buf+ sizeof(int);
	bkbuf2.pos = bkbuf2.pos + sizeof(int);
	break;

      case REALTYPE:
	dvalue = a_getdoubleelem(d_tpl, i, FALSE);
	dobbuf=(char *)&dvalue;
	bufsize = bkbuf2.size - bkbuf2.pos;
        if(bufsize < sizeof(double)){
	  bkbuf2.size = bkbuf2.size *2;
	  if((bkbuf2.buf = realloc(bkbuf2.buf, bkbuf2.size)) == NULL){
	    fprintf(stderr, "ERROR: realloc failed");	
	    free(stri);
	    free(key.data);
	    free(data.data);
	    free(k_tpl);
	    free(d_tpl);

	    return;}
	}
	memcpy(bkbuf2.buf, dobbuf, sizeof(double));
	bkbuf2.buf= bkbuf2.buf+ sizeof(double);
	bkbuf2.pos = bkbuf2.pos + sizeof(double);
	break;

      case STRINGTYPE:
	size = bk_handles[handle_id]->attr_data[i]->size;
	len = a_getelemsize(d_tpl, i, FALSE);
	if(len > str_len){
	  if((stri = bk_realloc(stri, len*2)) == NULL){
	    fprintf(stderr, "ERROR: realloc failed");	
	    free(stri);
	    free(key.data);
	    free(data.data);
	    free(k_tpl);
	    free(d_tpl);
	    return;}
	  str_len = len*2;}

	bufsize = bkbuf2.size - bkbuf2.pos;
	if(bufsize < len ){
	  if((bkbuf2.buf = realloc(bkbuf2.buf, len*2)) == NULL){
	    fprintf(stderr, "ERROR: realloc failed");
	    free(stri);
	    free(key.data);
	    free(data.data);
	    free(k_tpl);
	    free(d_tpl);
	    return;}
	  bkbuf2.size = len*2;
	}
	a_getstringelem(d_tpl, i, stri, len, FALSE);
	memcpy(bkbuf2.buf, stri, len);
	for (j=len; j<size; j++)
	  bkbuf2.buf[j] = ' ';
	bkbuf2.pos = bkbuf2.pos + size;
	bkbuf2.buf = bkbuf2.buf + size;	
	break;

      default:
	free(stri);
	free(key.data);
	free(data.data);
	free(k_tpl);
	free(d_tpl);
	a_errormessage(bk_illegal_type,"");
	return;
      }
    }
  key.size = bkbuf1.buf - (char*)key.data;
  data.size = bkbuf2.buf - (char *)data.data;
  dbp =  bk_handles[handle_id]->dbp;	
  //if the table does not support dupplicate key, check if the key is already 
  //existed, it must be deleted
  if((key_spec = bk_handles[handle_id]->keyspec) == 1)
    {
      ret = dbp->del(dbp, txnid, &key, 0);	
      if((	ret != 0 ) && (ret != DB_NOTFOUND))
	{
	  dbp->err(dbp, ret, "DB->del");
	  free(stri);
	  free(key.data);
	  free(data.data);
	  free(k_tpl);
	  free(d_tpl);
	  dbp->close(dbp, 0);
	  a_errormessage(bk_cannot_delete,bk_handles[handle_id]->btreename);
	  return;
	}
    }
  //Store the key/data pair in the BKDB table
  if((ret = dbp->put(dbp, txnid, &key, &data, 0)) == 0)
    {
      free(stri);
      free(key.data);
      free(data.data);
      str_len=0;
    }
  else
    {
      dbp->err(dbp, ret, "DB->put");
      free(stri);
      free(key.data);
      free(data.data);
      free(k_tpl);
      free(d_tpl);
      dbp->close(dbp, 0);
      a_errormessage(bk_cannot_insert,bk_handles[handle_id]->btreename);
      return;
    }
  free_tuple(k_tpl);
  free_tuple(d_tpl);
  return ;
}
 

/**************************************************
 * End of foreign function BKSet()                *
 **************************************************/ 


/******************************************************************************
 *BKDelete()                                                                  *
 *Arguments: integer handle_id, a tuple of key(s)                             *
 *return: ínteger handle_id                                                   *
 *Gathering info about the BKDB_table from the global array by using handle_id*
 *as index and do the needed operaitons for deleting the key/data pair        *
 *Remove both the key and the  data associated with the key if the key exists *
 *in BKDB table.                                                              *
 *otherwise the message:                                                      *
 *      DB->del: DB_NOTFOUND: No matching key/data pair found                 *
 *is send to Amos.                                                            *
 *Check to see if duplicate is supported in this case remove all  data which  *
 *ís associated with the key.                                                 *
 *****************************************************************************/
void BKDelete(a_callcontext cxt, a_tuple t)
{
  DB *dbp;
  DBT key;
  int handle_id;
  int j =0, key_len=0;
  int ret;
  int str_len = 0;
  bk_buf_t bkbuf;
  
  dcl_tuple(k_tpl);
 
		
  //Get handle_id from input
  handle_id = a_getintelem(t, 0, FALSE);
  check_init();
  check_handle(handle_id);
  //The key tuple from input is stored in k_tpl tuple
  a_getseqelem(t, 1, k_tpl, FALSE);
  
  memset(&key, 0, sizeof(key));
  if(key_len == 0){
    key.data = bk_malloc(1000);
    key_len = 1000;
  }

  init_buf(&bkbuf, key.data);
  //check if an error happened in encode_tuple
  if(!encode_tuple(k_tpl, &bkbuf, handle_id)){
    free(key.data);
    free(k_tpl);
    return;}


  key.size = bkbuf.buf - (char*)key.data;
   
  dbp =  bk_handles[handle_id]->dbp;
  ret = dbp->del(dbp, txnid, &key, 0);
  if((	ret != 0 ) && (ret != DB_NOTFOUND))
    {
      dbp->err(dbp, ret, "DB->del");
      free(key.data);
      free_tuple(k_tpl);
      dbp->close(dbp, 0);
      a_errormessage(bk_cannot_delete,bk_handles[handle_id]->btreename);
      return;
    }
  if ( ret == DB_NOTFOUND)
    {
      dbp->err(dbp, ret, "DB->del");
      free(key.data);
      free_tuple(k_tpl);
      return;
    }
  printf("The key/data pair/s is/are deleted\n");
  free(key.data);
  free_tuple(k_tpl);
  return;			
}
/**************************************************
 * End of foreign function BKDelete()             *
 **************************************************/ 

void bk_interval_search(a_callcontext cxt, a_tuple t,
                        a_tuple lowk_tpl, a_tuple upk_tpl, int respos)
{
  DB *dbp;
  DBT key, data; 
  DBT low_key, up_key;
  DBC *dbcp;
  int handle_id, i, flag = 0;
  int j =0;
  int ivalue, exp;
  unsigned res;
  double dvalue;
  int primkey_No;      //number of primary key
  int noprimkey_No;    //number of noprimary key
  int upkey_No, lowkey_No;
  int attr_type;
  int ret, size;
  int k_len=0 , d_len=0;
  char *keyval, *dataval;
  int lowkey_len=0, upkey_len=0;
  char ibuf[sizeof(int)];
  char mybuf[sizeof(int)];
  char rbuf[sizeof(short int)];//???
  unsigned char src[sizeof(double)];
  unsigned char src2[sizeof(double)];
  char isrc[sizeof(short int)];
  short int rres;
  bk_buf_t bkbuf1, bkbuf2;
  
  dcl_tuple(k_res);
  dcl_tuple(d_res);

  //get handle_id from 1st argument
  handle_id = a_getintelem(t, 0, FALSE);
  check_init();
  check_handle(handle_id);

  // lower key
  memset(&low_key, 0, sizeof(DBT));
  lowkey_No = a_getarity(lowk_tpl, FALSE);
  if(lowkey_No>0)
    {
      low_key.data =  bk_malloc(1000);
      lowkey_len = 1000;
      init_buf(&bkbuf1, low_key.data);
      if(!encode_tuple(lowk_tpl, &bkbuf1, handle_id)){
	free(low_key.data);
	free(k_res);
	free(d_res);
	return;}
      low_key.size = bkbuf1.buf - (char*)low_key.data;
    }
 
  // Upper key
  upkey_No = a_getarity(upk_tpl, FALSE);
  memset(&up_key, 0, sizeof(DBT));
  if(upkey_No>0)
    {
      up_key.data =  bk_malloc(1000);
      upkey_len = 1000;
      init_buf(&bkbuf2, up_key.data);
      if(!encode_tuple(upk_tpl, &bkbuf2, handle_id)){
	if(lowkey_No>0)free(low_key.data);
	free(up_key.data);
	free(k_res);
	free(d_res);
	return;}
      up_key.size = bkbuf2.buf - (char *)up_key.data;
    }

  // up_key.size = bkbuf2.buf - (char *)up_key.data;
  memset(&key, 0, sizeof(DBT));
  memset(&data, 0, sizeof(DBT)); 
  dbp = bk_handles[handle_id]->dbp;

  //Acquire a cursor for the table
  if((ret = dbp->cursor(dbp, txnid, &dbcp, 0)) != 0)
    {
      if(lowkey_No > 0) free(low_key.data);
      if (upkey_No>0) free(up_key.data); 
      dbp->err(dbp, ret, "DB->cursor");
      dbp->close(dbp, 0);
      dbcp->c_close(dbcp);
      a_errormessage(bk_cannot_open_cursor,bk_handles[handle_id]->btreename);
      return;
    }	
  primkey_No = bk_handles[handle_id]->primkeyNO; //number of primary key
  noprimkey_No = bk_handles[handle_id]->noprimkeyNO;//number of not_primary key
  a_newtuple(k_res, primkey_No, FALSE);
  a_newtuple(d_res, noprimkey_No, FALSE);
  
  if(k_len == 0){
    keyval = (char *) bk_malloc(1000);
    k_len = 1000;}
  if(d_len == 0){
    dataval =(char *) bk_malloc(1000);
    d_len =1000;}

  //Get the key/data pair(if there exists) which associated with lowkey
  //or  beginning of file is lowkey nil
  if(lowkey_No==0)
    ret = dbcp->c_get(dbcp, &low_key, &data, DB_FIRST);
  else ret = dbcp->c_get(dbcp, &low_key, &data, DB_SET_RANGE);
  if(ret==0)
    {
      flag = 1;
      if((int)low_key.size > k_len)
	{
	  keyval = bk_realloc(keyval, low_key.size*2);
	  k_len = key.size*2;
	}

      //Get type of the key from the global array and do the needed operations
      //to be able to return the correct format of the data to Amos. 
      for(i=0; i < primkey_No; i++)
	{
	  attr_type = bk_handles[handle_id]->attr_key[i]->type;

	  switch(attr_type){

	  case INTEGERTYPE:
	    memcpy(ibuf, low_key.data, sizeof(int));
	    bk_normalinvers_int(mybuf, ibuf);
	    memcpy(&res, mybuf, sizeof(int));
	    ivalue = bk_decode(res);
	    a_setintelem(k_res, i, ivalue, FALSE);
	    low_key.data = (char *)low_key.data + sizeof(int);
	    break;

	  case REALTYPE:
	    memcpy(isrc, low_key.data, sizeof(isrc));
	    bk_normalinvers_shortint(rbuf, isrc);
	    memcpy(&rres, rbuf, sizeof(short int));
	    exp = bk_decode_exp(rres);
	    low_key.data = (char *)low_key.data + sizeof(isrc);
	    memcpy(src, low_key.data, sizeof(double));
	    bk_normalinvers_double(src2, src);
	    memcpy(&dvalue,src2, sizeof(src2));
	    dvalue = bk_decode_double(dvalue);
	    dvalue=ldexp(dvalue, exp);
	    a_setdoubleelem(k_res, i, dvalue, FALSE);
	    low_key.data = (char *)low_key.data + sizeof(double);
	    break;

	  case STRINGTYPE:
	    size = bk_handles[handle_id]->attr_key[i]->size;
	    memcpy(keyval, low_key.data, size);
	    keyval = strtok(keyval, "\0");
	    a_setstringelem(k_res, i, keyval, FALSE);
	    low_key.data = (char*)low_key.data + size;
	    break;

	  default:
	    if(lowkey_No>0)free(low_key.data);
	    if(upkey_No>0)free(up_key.data);
	    free_tuple(k_res);
	    free_tuple(d_res);
	    free(keyval);
	    free(dataval);
	    a_errormessage(bk_illegal_type,"");
	    return;
	  }
	  a_setseqelem(t, respos, k_res, FALSE);
	}
      if((int)data.size > d_len)
	{
	  dataval = bk_realloc(dataval, data.size*2);
	  d_len = data.size*2;
	}

      //check if an error happened in decode_tuple
      if(!decode_tuple(cxt, t, &data, noprimkey_No, handle_id, 
		       respos+1, dataval)){
	if(lowkey_No>0)free(low_key.data);
	if(upkey_No>0)free(up_key.data);
	free_tuple(k_res);
	free_tuple(d_res);
	free(keyval);
	free(dataval);		
	return;}
 
    }
  else if (ret != 0 && ret != DB_NOTFOUND)
    {
      dbp->err(dbp, ret, "DB->get");
      if(lowkey_No>0)free(low_key.data);
      if(upkey_No>0)free(up_key.data);
      free_tuple(k_res);
      free_tuple(d_res);
      free(keyval);
      free(dataval);
      dbp->err(dbp, ret, "DB->cursor");
      dbp->close(dbp, 0);
      dbcp->c_close(dbcp);
      exit(1);
    }
  // Move the cursor a record forward to get other key/data pairs which
  //exist in the given interval
  while ((ret = dbcp->c_get(dbcp, &key, &data, DB_NEXT)) == 0)
    {
      if(upkey_No <=0 ||
         memcmp(key.data, up_key.data, sizeof(key.data)) <= 0)
	{
	  flag = 1;
	  if((int)key.size > k_len)
	    {
	      keyval = bk_realloc(keyval, key.size*2);
	      k_len = key.size*2;
	    }
	  //Get type of the key from the global array and do 
	  //the needed operations to be able to return the correct
	  //format of the data to Amos. 
	  for(i=0; i < primkey_No; i++)
	    {
	      attr_type = bk_handles[handle_id]->attr_key[i]->type;
	      //Check the datatype
	      switch(attr_type){
	      case INTEGERTYPE:
		memcpy(ibuf, key.data, sizeof(int));
		bk_normalinvers_int(mybuf, ibuf);
		memcpy(&res, mybuf, sizeof(int));
		ivalue = bk_decode(res);
		a_setintelem(k_res, i, ivalue, FALSE);
		key.data = (char *)key.data + sizeof(int);
		break;
	
	      case REALTYPE:
		memcpy(isrc, key.data, sizeof(isrc));
		bk_normalinvers_shortint(rbuf, isrc);
		memcpy(&rres, rbuf, sizeof(short int));
		exp = bk_decode_exp(rres);
		key.data = (char *)key.data + sizeof(isrc);
		memcpy(src, key.data, sizeof(src));
		bk_normalinvers_double(src2, src);
		memcpy(&dvalue,src2, sizeof(src2));
		dvalue = bk_decode_double(dvalue);
		dvalue=ldexp(dvalue, exp);
		a_setdoubleelem(k_res, i, dvalue, FALSE);
		key.data = (char *)key.data + sizeof(src);
		break;

	      case STRINGTYPE:
		size = bk_handles[handle_id]->attr_key[i]->size;
		memcpy(keyval, key.data, size);
		keyval = strtok(keyval, "\0");
		a_setstringelem(k_res, i, keyval, FALSE);
		key.data = (char*)key.data + size;
		break;

	      default:
		if(lowkey_No>0)free(low_key.data);
		if(upkey_No>0)free(up_key.data);
		free_tuple(k_res);
		free_tuple(d_res);
		free(keyval);
		free(dataval);
		a_errormessage(bk_illegal_type,"");
		return;
	      }
	      a_setseqelem(t, respos, k_res, FALSE);	
	    }
	  if((int)data.size > d_len)
	    {
	      dataval = bk_realloc(dataval, data.size*2);
	      d_len = data.size*2;
	    }
	  //Get type of the data from the global array and do the needed
	  // operations to be able to return the correct format of the 
          // data to Amos. 

	  //check if an error happened in decode_tuple
	  if(!decode_tuple(cxt, t, &data, noprimkey_No, 
		  handle_id, respos+1, dataval)){
	    if(lowkey_No>0)free(low_key.data);
	    if(upkey_No>0)free(up_key.data);
	    free_tuple(k_res);
	    free_tuple(d_res);
	    free(keyval);
	    free(dataval);		
	    return;}
	  }
  }
  if(lowkey_No>0)free(low_key.data);
  if(upkey_No>0)free(up_key.data);
  free_tuple(k_res);
  free_tuple(d_res);
  free(keyval);
  free(dataval);
  if(flag == 0) dbp->err(dbp, ret, "DB->get");
  dbcp->c_close(dbcp);
  return;
}

/******************************************************************************
 *BKScan()                                                                    *
 *Arguments: integer handle_id                                                *
 *return: bag of <vector keys, vector data>                                   *
 *Scan the BKDB_table                                                         *
 *Gathering info about the BKDB_table from the global array by using handle_id*
 *as index.                                                                   *
 *****************************************************************************/
void BKScan(a_callcontext cxt, a_tuple t)
{
  dcl_tuple(k_tpl);

  a_setarity(k_tpl, 0); // open lower and upper limit
  bk_interval_search(cxt, t, k_tpl, k_tpl, 1);
  free_tuple(k_tpl);
  return;
}
/**************************************************
 * End of foreign function BKScan()               *
 **************************************************/ 

/******************************************************************************
 *BKGet()                                                                     *
 *Arguments: integer handle_id, a tuple of key(s)                             *
 *return: bag of vectors data                                                 *
 *Gathering info about the BKDB_table from the global array by using handle_id*
 *as index and do the needed operaitons for getting data        .             *
 *Get data associated with the key in the BKDB table if the key exists,       *
 *otherwise the message:                                                      *
 *   DB->get: DB_NOTFOUND: No matching key/data pair found                    *
 *is send to Amos.                                                            *
 *Check to see if duplicate is supported in this case get other data which is *
 *associated with the key and return them.                                    *
 *****************************************************************************/
void BKGet(a_callcontext cxt, a_tuple t)
{
  dcl_tuple(k_tpl);

  //The key tuple from input is stored in k_tpl tuple
  a_getseqelem(t, 1, k_tpl, FALSE);
  bk_interval_search(cxt, t, k_tpl, k_tpl, 1);
  free_tuple(k_tpl);
  return;
}
/**************************************************
 * End of foreign function BKGet()                *
 **************************************************/ 

/******************************************************************************
 *BKGet_between_interval()                                                    *
 *Arguments: integer handle_id, two tuples of key(lowest and highest bound)   *
 *return: bag of vectors data                                                 *
 *Gathering info about the BKDB_table from the global array by using handle_id*
 *as index and walk on the btree to retrieve  all key/data pairs which key is *
 *between the lowest and highest keys, i.e. in the given                      *
 *intervall [lowkey, highkey], if there is(are) such  pair(s), otherwise      *
 *the message:                                                                *
 *      DB->get: DB_NOTFOUND: No matching key/data pair found                 *
 *is send to Amos.                                                            *
 *****************************************************************************/
void BKGet_between_interval(a_callcontext cxt, a_tuple t)
{
  dcl_tuple(lowk_tpl);
  dcl_tuple(upk_tpl);

  //2nd argument is the lower key stored in lowk_tpl tuple
  //Empty key => Scan from start of table
  a_getseqelem(t, 1, lowk_tpl, FALSE);
  //3rd argument is the upper key stored in upk_tpl tuple
  //Empty key => Scan to end of table
  a_getseqelem(t, 2, upk_tpl, FALSE);

  //1st argument, the handle passed through t
	
  bk_interval_search(cxt, t, lowk_tpl, upk_tpl, 3);
  free_tuple(lowk_tpl);
  free_tuple(upk_tpl);
  return;
}

/**************************************************
 * End of foreign function BKGet_between_interval *
 **************************************************/ 

/************************************************************************   
 *BKRemove()                                                            *
 *Arguments: charstring filename, charstring tablename                  *
 *return: void                                                          *
 *Remove the table and information about the table from "metadata"      *
 *table.							        *
 ************************************************************************/
void BKRemove(a_callcontext cxt, a_tuple t)
{	
  DB *dbp;
  DBC *dbcp;		
  DBT key, data, oldkey;
  int ret, t_ret, c_ret;
  char file_name[MAX_NAME_LENGTH];
  char btree_name[MAX_NAME_LENGTH];
  int handle_id;

  //get name of file from input
  a_getstringelem(t, 0, file_name, sizeof(file_name), FALSE);
  //get name of btree from input
  a_getstringelem(t, 1, btree_name, sizeof(btree_name), FALSE);

/*if (dbenv == NULL)
    {
      a_errormessage(bk_not_initialized,"");
      return;
    }*/
  check_init();
  if((ret = txnid->commit(txnid, 0)) != 0)
    {
      a_errormessage(bk_commit_failed,btree_name);
      return;
    }
  if((handle_id = bk_open(file_name, btree_name))!=0)
    {
      if(bk_handles[handle_id]==NULL)
	{
	  //start a new transaction
	  if ((ret = dbenv->txn_begin(dbenv, NULL, &txnid, 0)) != 0) 
	    {
	      dbenv->err(dbenv, ret, "txn_begin");
	      a_errormessage(bk_cannot_start_transaction,"");
	    }
	  return;
	}
      dbp = bk_handles[handle_id]->dbp;
      if((t_ret = dbp->close(dbp, 0)) != 0)
	{
	  rollback();
	  a_errormessage(bk_cannot_close_handle,btree_name);
	  return;
	}
    }
  //start a new transaction
  if ((ret = dbenv->txn_begin(dbenv, NULL, &txnid, 0)) != 0) 
    {
      dbenv->err(dbenv, ret, "txn_begin");
      a_errormessage(bk_cannot_start_transaction,"");
      return;
    }
  dbenv->dbremove(dbenv, txnid, file_name, btree_name, 0);

  //Create a table handle  
  if((ret = db_create(&dbp, dbenv, 0)) != 0)
    {
      fprintf(stderr, "db_create: %s\n", db_strerror(ret));
      rollback();
      a_errormessage(bk_cannot_create_handle,btree_name);
      return;
    }
  dbp->set_errfile(dbp, stderr);
  dbp->set_errpfx(dbp, progname);

  // 1K page sizes
  if((ret = dbp->set_pagesize(dbp,1024)) != 0)
    {
      dbp->err(dbp, ret, "set_pagesize");
      exit(1);
    }
  if((ret = dbp->set_flags(dbp, DB_DUP))!=0)
    {
      dbp->err(dbp, ret, "set_flags: DB_DUP");
      exit(1);
    }	
  dbcp = bk_open_metadata_cursor(dbp,file_name,NULL);
  memset(&data, 0, sizeof(data));
  memset(&oldkey, 0, sizeof(DBT));
  memset(&key,0,sizeof(key));
  key.data =(char *) bk_malloc (strlen(btree_name) + 1);
  //Using of table_name as the key
  strcpy(key.data, btree_name);
  key.size = strlen(key.data) + 1;

  //Get the first data which is associated with the key, and remove it.
  if((ret = dbcp->c_get(dbcp, &key, &data, DB_SET)) != 0)
    {
      printf("The table does not exit\n");
      dbcp->c_close(dbcp);
      rollback();
      dbp->close(dbp, 0);
      return;
    }
  oldkey.data = (char *) bk_malloc(strlen(key.data) + 1);
  strcpy(oldkey.data, key.data);	
  if((ret = dbp->del(dbp, txnid, &key, 0)) != 0)
    {
      dbp->err(dbp, ret, "DB->del");
      free(key.data);
      free(data.data);
      dbcp->c_close(dbcp);
      rollback();
      dbp->close(dbp, 0);
      a_errormessage(bk_cannot_delete,btree_name);
      return;
    }
  if((c_ret = dbcp->c_close(dbcp)) != 0)
    {
      rollback();
      return;
    }
  if((t_ret = dbp->close(dbp, 0)) != 0)
    {
      rollback();
      return;
    }
  if((ret = txnid->commit(txnid, 0)) != 0)
    {
      a_errormessage(bk_commit_failed,"");
      return;
    }
  //start a new transaction
  if ((ret = dbenv->txn_begin(dbenv, NULL, &txnid, 0)) != 0) 
    {
      dbenv->err(dbenv, ret, "txn_begin");
      a_errormessage(bk_cannot_start_transaction,"");
      return;
    }
  bk_handles[handle_id] = NULL;
  return;
}
  
/********************************************
 * End of foreign function BKRemove()       *
 ********************************************/ 

/******************************************************
 *BKCommit()                                          *
 *return: void                                        *
 *commit the transaction                              *
 ******************************************************/
void BKCommit(a_callcontext cxt, a_tuple t)
{
  commit();
  return;
}

/****************************************
 * End of foreign function BKCommit()   *
 ****************************************/ 

/********************************
 *BKRollback()                  *
 *return: void                  *
 *Abort the transaction         *
 ********************************/
void BKRollback(a_callcontext cxt, a_tuple t)
{
  rollback();
  return;
}
/*******************************************
 * End of foreign function BKRollback()    *
 *******************************************/ 

/*******************************************
 *BKDisconnect()	                   *
 *return: void                             *
 *close connection to the database file    *
 ******************************************/
void BKDisconnect(a_callcontext cxt, a_tuple t)
{
  int ret, j, i;
  DB *dbp, *dbp1;
	
  for(i = 1; i <= glb_index; i++)
    {
      if(handle_array[i] != NULL)
	{
	  dbp1 = handle_array[i]->dbp;
	  dbp1->close(dbp1,0);
	}
    }
  glb_index=0;
/*if (dbenv == NULL)
    {
      a_errormessage(bk_not_initialized,"");
      return;
    }*/
  check_init();
  //Commit the transaction
  if((ret = txnid->commit(txnid, 0)) != 0)
    {
      a_errormessage(bk_commit_failed,"");
      return;
    }
  //Check the table handles are still actives then close the handles
  for(j=1; j <= handleid; j++)
    {	
      if(bk_handles[j] != NULL)
	{
	  dbp = bk_handles[j]->dbp;
	  if((ret = dbp->close(dbp, 0)) != 0 )
	    {   
	      dbp->err(dbp, ret, "DB->get");
	      a_errormessage(bk_cannot_close_handle,"");
	      return;
	    }
	}
    }
  //close the database environment handle.  
  if((ret = dbenv->close(dbenv, 0)) != 0 )
    {   
      a_errormessage(bk_cannot_close_environment,"");
      return;
    }
  dbenv = NULL;
  return;
}

int  main(int argc, char **argv)
{
  dcl_connection(c);
	
  init_amos(argc, argv);
 
  //Bind C functions to Amos foreign predicates
  a_extfunction("BKCreateaa", BKCreate);
  a_extfunction("BKConnectaa", BKConnect);
  a_extfunction("BKHandleaa", BKHandle);
  a_extfunction("BKPrimary_keysaa", BKPrimary_keys);  
  a_extfunction("BKColumnsaa", BKColumns);
  a_extfunction("BKTablesaa", BKTables);
  a_extfunction("BKScanaa", BKScan);
  a_extfunction("BKSetaa", BKSet);	
  a_extfunction("BKGetaa", BKGet);
  a_extfunction("BKDeleteaa", BKDelete);
  a_extfunction("BKGet_between_intervalaa", BKGet_between_interval);
  a_extfunction("BKRemoveaa", BKRemove);
  a_extfunction("BKCostaa", BKCost);
  a_extfunction("BKDisconnectaa", BKDisconnect);
  a_extfunction("bk_scan", BKScan);
  a_extfunction("bk_get", BKGet);
  a_extfunction("BKRollbackaa", BKRollback);
  a_extfunction("BKCommitaa", BKCommit);

  a_connect(c, "", FALSE);

  bk_not_initialized = a_register_error("ABKW not initialized");
  bk_abort_failed = a_register_error("BerkeleyDB abort failed");
  bk_commit_failed = a_register_error("BerkeleyDB commit failed");
  bk_cannot_start_transaction = 
    a_register_error("Cannot start new BerkeleyDB transaction"); 
  bk_wrong_file = a_register_error("Wrong BerkeleyDB file name");
  bk_wrong_table = a_register_error("Wrong BerkeleyDB table name");
  bk_handle_closed = a_register_error("BerkeleyDB handle closed");
  bk_cannot_create_handle = 
    a_register_error("Cannot create BekeleyDB table handle");		
  bk_cannot_create_table = a_register_error("Cannot create BerkeleyDB table");
  bk_cannot_open_table = a_register_error("Cannot open BerkeleyDB table");
  bk_cannot_open_cursor = a_register_error("Cannot open BerkeleyDB cursor");
  bk_cannot_open_metadata = 
    a_register_error("Cannot open BerkeleyDB metadata table");
  bk_table_already_created = 
    a_register_error("BerkeleyDB table already created");
  bk_empty_database = a_register_error("Empty BerkeleyDB database");
  bk_cannot_close_handle =
    a_register_error("Cannot close BerkelyDB table handle");
  bk_environment_open = a_register_error("BerkeleyDB environment open");
  bk_cannot_open_environment =
    a_register_error("Cannot open BerkeleyDB environment");
  bk_cannot_close_environment =
    a_register_error("Cannot close BerkeleyDB environment");
  bk_wrong_arity = a_register_error("Wrong key arity for BerkeleyDB table");
  bk_illegal_type = a_register_error("Illegal type in BerkeleyDB interface");
  bk_cannot_delete = a_register_error("Cannot remove row in BerkeleyDB table");
  bk_cannot_insert = a_register_error("Cannot insert row in BerkeleyDB table");

  HOME = getenv("bk_home");
  if(HOME==NULL)
    {
      printf("Environment variable BK_HOME not set!");
      exit(1);
    }
  printf("BerkeleyDB stored in %s\n",HOME);
  bk_init();

  amos_toploop("ABKW");
  return 0;
}
