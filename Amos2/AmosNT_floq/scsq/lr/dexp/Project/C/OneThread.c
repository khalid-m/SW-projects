#include <string.h>
#include <stdio.h>
#include <sqlite3.h>
#include <stdlib.h>
#include <sys/time.h> 

#define Multiplier 1;
#define FILENAME "./data/test.txt";
#define L 64;

typedef struct
{
    unsigned short simTime;
    int vid;
    unsigned short xway;
    unsigned short day;
    int qid;
    long readTime;
    
    
}inRow;

int main()
{
    const int Max64input= 776886;
    const char delimiters[] = " ,(,),#";
    char *inName = "./data/outDexpSort.txt";
    FILE *in;
    char *token, *chk;
    char lineBuff[BUFSIZ];
    int retval;
    char * ErrMsg;
    char * sql;
    struct timeval t1, t2;

    inRow* inputs = (inRow*) malloc(Max64input * (sizeof (inRow)));
    sqlite3_stmt *stmt;
    sqlite3 *handle;

    in = fopen(inName, "r");
    if (!in){
        printf("Couldn't open File");
        return 0;
    }

    int val, count, countIn;
    short sval;
    countIn = 0;
    while(fgets(lineBuff, sizeof(lineBuff), in)){
	count = 0;
	token=strtok(lineBuff,delimiters);
	//printf("p = %d",countIn);
   	while(token != NULL){
	    //gettimeofday(&t1, NULL);
	    //inputs[countIn].readTime = (t1.tv_sec * 1000.0) + (t1.tv_usec/1000);
	    if (count == 1){
    		sval = (short) strtol(token, &chk, 10);
		if (isspace(*chk) || *chk == 0)
    		{
        	    inputs[countIn].simTime= sval;
        	    //printf("vid = %d ",val);
                }
            }
	    if (count == 2){
		val = (int) strtol(token, &chk, 10);
		if (isspace(*chk) || *chk == 0)
    		{
	    	    inputs[countIn].vid= val;
		    //printf("vid = %d ",val);
		}
	    }
	    if (count == 4){
 	        sval = (short) strtol(token, &chk, 10);
	        if (isspace(*chk) || *chk == 0)
    		{
        	    inputs[countIn].xway= sval;
		    //printf("xway = %d ",val);
    		}
	    }
	    if (count == 9){
    		val = (int) strtol(token, &chk, 10);
	        if (isspace(*chk) || *chk == 0)
    		{
        	    inputs[countIn].qid= val;
		    //printf("qid = %d ",val);
    		}
	    }
	    if (count == 14){
    		sval = (short) strtol(token, &chk, 10);
    		if (isspace(*chk) || *chk == 0)
    		{
        	    inputs[countIn].day= sval;
		    //printf("day = %d\n",val);
    		}
	    }
	    count++;
	    token=strtok(NULL,delimiters);
	}
	//printf("vid = %s xway =  %s day = %s qid = %s\n", vid, xway, day, qid);
	countIn++;
    }
    printf("Reading from file completed!\n");    
    retval = sqlite3_open("Lr.db", &handle);
    if(retval)
    {
	printf("Database connection failed\n");
	return -1;
    }
    printf("Connection successful\n");
    sql = "SELECT toll from hist where vid = ? and xway = ? and day = ?";
    int j;
    int countRows = 0;
    long milliTime=0;
    retval = sqlite3_prepare_v2(handle,sql,-1,&stmt,0);
    for (j=0; j<Max64input;j++)
    {
	gettimeofday(&t1, NULL);
	inputs[j].readTime = (t1.tv_sec * 1000000.0) + (t1.tv_usec);
    	sqlite3_bind_int(stmt, 1, inputs[j].vid);
	sqlite3_bind_int(stmt, 2, inputs[j].xway);
	sqlite3_bind_int(stmt, 3, inputs[j].day);
	/*if(retval)
    	{
            printf("Selecting data from DB Failed %s\n", &ErrMsg);
            return -1;
    	}*/
	while(1)
	{
	    retval = sqlite3_step(stmt);
            //gettimeofday(&t2, NULL);
            //milliTime = (t2.tv_sec * 1000000.0) + (t2.tv_usec);	    
	    if(retval == SQLITE_ROW)
	    {	
 		gettimeofday(&t2, NULL);
		milliTime = (t2.tv_sec * 1000000.0) + (t2.tv_usec);
		int val = sqlite3_column_int(stmt,0);
 		printf("(#3,%d,%ld,%d,%d,%ld,%d)\n",inputs[j].simTime,milliTime,inputs[j].vid,inputs[j].qid,inputs[j].readTime,val);
 		
 	    }
 	    else if(retval == SQLITE_DONE)
 	    {
 		//printf("All rows fetched\n");
 		break;
 	    }
 	    else
 	    {
 		printf("Some error encountered\n");
 		return -1;
 	    }
	}
	sqlite3_reset(stmt);
        sqlite3_clear_bindings(stmt);
    }
sqlite3_finalize(stmt); 
sqlite3_close(handle); 
return 0;
}
