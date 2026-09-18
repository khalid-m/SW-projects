#include <malloc.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

extern char* getexename(char* buf, size_t size);

int main(int argc, char **argv)
{
  char **params;
  int i, rc;
  char executable[200];
  char execdir[200];
  char *jdirprefix = "-Djava.library.path=";
  char *classpath=getenv("CLASSPATH");
  char *amospath=getenv("AMOS_HOME");
  
  if(classpath==NULL)
    {
      fprintf(stderr, "CLASSPATH not set\n");
      exit(1);
    }
  if(amospath==NULL)
    {
      fprintf(stderr, "AMOS_HOME not set\n");
      exit(1);
    }
  sprintf( classpath, "%s:/%s/wrappers/JDBC/", classpath, amospath);
  int xparams;
   
  getexename(executable, sizeof(executable));
  for(i=strlen(executable);i>=0;i--)
    {
      if(executable[i]=='/') break;
    }
  if(i==0) 
    {
      fprintf(stderr, "Illegal full path to executable: %s \n");
      exit(1);
    }
  memcpy(execdir, executable, i);
  execdir[i] = '\0';
  params = malloc((argc+5)*sizeof(*params));

  params[0] = "java";
  params[1] = malloc(strlen(jdirprefix)+strlen(execdir)+1);
  strcpy(params[1], jdirprefix);
  strcat(params[1], execdir);
  params[2] = "-cp";
  params[3] = malloc(strlen(classpath)+strlen(execdir)+75);
  sprintf(params[3],"%s:%s/sward.jar:.",classpath,execdir); 
  sprintf(params[3],"%s:%s/jarlib/mysql-connector-java-5.1.6-bin.jar:.",params[3],amospath);
  
  strcat(params[3], " -classpath ");
  strcat(params[3], amospath);
  strcat(params[3], "/wrappers/JDBC/:.");
  
  params[4] = "SWARD";
  xparams = 4;
  for(i=xparams+1;i<=argc+xparams-1;i++) params[i]=argv[i-xparams];
  
  params[i] = NULL;
  rc = execvp("java",params);
  if(rc) perror("Error");
}
