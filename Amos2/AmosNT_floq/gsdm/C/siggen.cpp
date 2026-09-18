
#pragma hdrstop
#include <condefs.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

//---------------------------------------------------------------------------
#pragma argsused

/* Generator of signals as stand-alone program in C.
Interface : init_gen initiates the generator with parameters a,b,c,d
            get_next(g) returns the next generated value

The signal has segments with different levels.
 segment_gen calculates new segment size, allocates memory, sets the
 generator fields,
 and calls segment_gen0 for data generation (1 segment per call)

Author:  Milena Koparanova
*/


struct generator{
double a;  // a = maximum amplitude, signal levels in [-a,a]
int b;     // b = max number of steps for signal to reach the new level
int c;     // c = max number of steps for signal to stay at the new level
double d;  //  d = maximum variation of the signal at the new level
double s0; //  initial value for a segment
double *x; // array for storing generated data
int cur;   //pointer to the current value
int n;     //size of x
};

typedef struct generator *Gptr;
Gptr init_gen(double a, int b, int c, double d)
{
   Gptr g = (Gptr)malloc(sizeof(struct generator));;
   g->a=a;
   g->b=b;
   g->c=c;
   g->d=d;
   g->x=NULL;
   g->n = 0;
   g->cur = 0;
   g->s0 = 0.0; //initial signal value
   return g;
}

double segment_gen0(Gptr g,int n1)
{
   double s, ds, e;
   double *x1= g->x;
   int i;
   double mc = 100.0;  //coeff for variations

   s= (double)random((int)g->a);
   if (fabs(s -g->s0)<1) s= s+1;
   ds = (s- g->s0)/n1;
   for(i=0; i<n1; i++)
        x1[i]= g->s0 + (i+1)*ds;
  for(i=n1; i< g->n; i++)
   {    e= (double)random((int)(2* g->d * mc));
        e= (e - mc* g->d)/mc;
        x1[i]= s + e;
   }
   printf("Generation with s0 = %f\n", g->s0);
   printf("New signal level %8.3f for n1 = %d steps\n", s, n1);
   return s;
}

void gen_print(Gptr g)
{
   int i;
   for(i=0; i<g->n; i++) printf("%8.3f ", g->x[i]);
   printf("\n n= %d cur %d s0= %8.3f \n", g->n, g->cur, g->s0);
}


void segment_gen(Gptr g)
/* calculates new segment size, allocates memory, calls segment_gen0
 for data generation, and sets generator fields */
{
   int n, n1, n2;

   n1= random(g->b) +1;
   n2= random(g->c);
   n=n1+n2;     //segment size
   g->n=n; g->cur=0;
   if (g->x!=NULL) free(g->x);   //free memory from previous segment
   g->x = (double *)malloc(n*sizeof(double));
   g->s0 = segment_gen0(g,n1);

   gen_print(g);
}


double get_next(Gptr g)
/* returns the next generated value. If the generated data are finished
 in the array x, generates a new segment */
{
    double res;
    if (g->x== NULL)  // next segment generation
       segment_gen(g);
    if (g->cur == g->n) //the last element was taken
        segment_gen(g);
    res = g->x[g->cur];
    g->cur++;
    return res;
}

int main (int argc, char* argv[])
{
    Gptr g;
    FILE *fp;
    fp = fopen("datagen.dat","w+");
    g = init_gen(100.0,15,6,10.0);
    for (int i= 0; i<200; i++)
       /* printf("Gen. %d = %8.3f \n", i,get_next(g));*/
     fprintf(fp,"%d %8.3f\n", i,get_next(g));

    if (g->x!=NULL) free(g->x);
    fclose(fp);
    return 0;
}
