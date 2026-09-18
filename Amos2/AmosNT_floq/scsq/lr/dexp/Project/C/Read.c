#include <string.h>
#include <stdio.h>
 
int main()
{
    const char delimiters[] = " ,(,),#";
    char *inName = "./data/test.txt";
    FILE *in;
    char *dump;
    char lineBuff[BUFSIZ];
    in = fopen(inName, "r");
    if (!in){
	printf("Couldn't open File");
	return 0;
    }
    char *vid, *day, *xway, *qid;
    while(fgets(lineBuff, sizeof(lineBuff), in)){

    dump=strtok(lineBuff,delimiters);
    dump=strtok(NULL,delimiters); 
    vid =strtok(NULL,delimiters);
    dump=strtok(NULL,delimiters);
    xway=strtok(NULL,delimiters);
    dump=strtok(NULL,delimiters);
    dump=strtok(NULL,delimiters);
    dump=strtok(NULL,delimiters);
    dump=strtok(NULL,delimiters);
    qid =strtok(NULL,delimiters);
    dump=strtok(NULL,delimiters);
    dump=strtok(NULL,delimiters);
    dump=strtok(NULL,delimiters);
    dump=strtok(NULL,delimiters);
    day =strtok(NULL,delimiters);     
    printf("vid = %s xway =  %s day = %s qid = %s\n", vid, xway, day, qid);
    }
    return 0;
}
