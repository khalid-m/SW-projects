/*****************************************************************************
 * AMOS2
 *
 * Author:  2013 Tore Risch, UDBL
 * $RCSfile: javaamos.c,v $
 * $Revision: 1.12 $ $Date: 2013/10/27 21:33:33 $
 * $State: Exp $ $Locker:  $
 *
 * Description: C program to start java with javaamos
 *
 ****************************************************************************/

#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define a_check_rc(x){int __rc=(x); if(__rc) {\
  printf("Error in call on line %d in %s\n %s raises\n Error %d: %s\n",\
          __LINE__,__FILE__,#x,__rc,strerror(__rc)); exit(1);}}

extern char* getexename(char* buf, size_t size);

int main(int argc, char **argv)
{
  char **params;
  int i, p;
  char executable[200];
  char execdir[200];
  char *jdirprefix = "-Djava.library.path=";
  char *classpath=getenv("CLASSPATH");
  int xparams;
  
  if(classpath==NULL) classpath="";
   
  getexename(executable, sizeof(executable));
  for(i=strlen(executable);i>=0;i--)
    {
      if(executable[i]=='/') break;
    }
  if(i==0) 
    {
      fprintf(stderr, "Illegal full path to executable: %s\n", executable);
      exit(1);
    }
  memcpy(execdir, executable, i);
  execdir[i] = '\0';

  /* Build command parameters to java: */
  xparams=5; /* Number of parameters to JVM */
  params = malloc((argc+xparams+1)*sizeof(*params));
  p=0;
  params[p] = "java";
  p++;
  params[p] = "-d32";
  p++;
  params[p] = malloc(strlen(jdirprefix)+strlen(execdir)+1);
  strcpy(params[p], jdirprefix);
  strcat(params[p], execdir);
  p++;
  params[p] = "-cp";
  p++;
  params[p] = malloc(strlen(classpath)+strlen(execdir)+300);
  sprintf(params[p],"%s:%s/javaamos.jar:.",classpath,execdir);
  //sprintf(params[p],"%s:%s/../jarlib/mysql-connector-java-5.1.6-bin.jar:.",
  //          params[p],execdir); 
  p++;
  params[p] = "JavaAMOS";
  assert(p==xparams);
  for(i=xparams+1;i<=argc+xparams-1;i++) params[i]=argv[i-xparams];
  params[i] = NULL;
  a_check_rc(execvp("java",params));
}
