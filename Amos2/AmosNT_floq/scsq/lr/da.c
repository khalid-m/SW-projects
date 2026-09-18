#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

extern int lrinit(char* filename, int, FILE*);
extern int lrdata();
extern void lrfinalize();

int main(int argc, char* argv[]) {
  int i, j, num;
  int maxnum = 20;
  FILE* fh[2];
  int pfd[2];
  pipe(pfd);
  fh[0] = fdopen(pfd[0],"r");
  fh[1] = fdopen(pfd[1],"a");
  int localdata[15];

  if (lrinit(argv[1], maxnum, fh[1])) {
    for (;;) {
      do {
	num = lrdata();
	if (num == -1) {
	  lrfinalize();
	  return 0;
	}
	printf("== NUM %d ==\n", num);
/* 	for (i=0; i<num; i++) { */
/* 	  fread(localdata, sizeof(int), 15, fh[0]); */
/* 	  for(j=0;j<15;j++) { */
/* 	    printf("%d ", localdata[j]); */
/* 	  } */
/* 	  printf("\n"); */
/* 	} */
	printf("\n");
      } while (maxnum == num);
      sleep(1);
    }
  }

  return 0;
}
