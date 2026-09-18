#include <stdio.h>
#include <sqlite3.h>
#include<stdlib.h>

main()
{
// Create an int variable for storing the return code for each call
int retval;
char * ErrMsg;
char * sql;
sqlite3_stmt *stmt;

sqlite3 *handle;

retval = sqlite3_open("newDB", &handle);

if(retval)
{
fprintf(stderr,"Database connection failed\n");
return -1;
}
fprintf(stderr,"Connection successful\n");

sql = "SELECT * from hist";

retval = sqlite3_prepare_v2(handle,sql,-1,&stmt,0);

if(retval)
{
printf("Selecting data from DB Failed %s\n", &ErrMsg);
return -1;
}

int cols = sqlite3_column_count(stmt);

while(1)
{
// fetch a rows status
 retval = sqlite3_step(stmt);

 if(retval == SQLITE_ROW)
 {
 // SQLITE_ROW means fetched a row
	int col=0;
 	//sqlite3_column_text returns a const void* , typecast it to const char*
 	for(col; col<cols;col++)
 	{
 		const char *val = (const char*)sqlite3_column_text(stmt,col);
 		printf("%s = %s\t",sqlite3_column_name(stmt,col),val);
 	}
 	printf("\n");
 }
 else if(retval == SQLITE_DONE)
 {
 	// All rows finished
 	printf("All rows fetched\n");
 	break;
 }
 else
 {
 	// Some error encountered
 	printf("Some error encountered\n");
 	return -1;
 }
}
return 0;

} 
