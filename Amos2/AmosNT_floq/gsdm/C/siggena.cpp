#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "callout.h"

//---------------------------------------------------------------------------

/*  Author: Milena Koparanova, UDBL, 21 02 2003
Generator of signals to be imported to Amos. Two versions available
1. One signal generator as a global variable
Interface : init_gen initiates the generator with parameters a,b,c,d
            get_next(g) returns the next generated value

The signal has segments with different levels.
 segment_gen calculates new segment size, allocates memory, sets the
 generator fields,
 and calls segment_gen0 for data generation (1 segment per call)

2. Signal generator implemented as Amos type.
 Use a C foreign function only for segment generation
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
/*   printf("Generation with s0 = %f\n", g->s0);
   printf("New signal level %8.3f for n1 = %d steps\n", s, n1); */

   return s;
}

/* test print */
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

/*   gen_print(g);*/
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

/* Amos foreign functions in C for interface to the generator  */

Gptr MyGen;

void init_genbbbb(a_callcontext cxt, a_tuple tpl)
{
   double a, d; // a = maximum amplitude, signal levels in [-a,a]
   int b,c;     // b = max number of steps for signal to reach the new level
                // c = max number of steps for signal to stay at the new level

    a = a_getdoubleelem(tpl,0,FALSE);
    b = a_getintelem(tpl,1,FALSE);
    c = a_getintelem(tpl,2,FALSE);
    d = a_getdoubleelem(tpl,3,FALSE);
    MyGen = init_gen(a,b,c,d);
    a_emit(cxt,tpl,FALSE);
    return;
}

void get_nextf(a_callcontext cxt, a_tuple tpl)
{
        double n = get_next(MyGen);
        a_setdoubleelem(tpl,0,n,FALSE);
        a_emit(cxt,tpl,FALSE);
        return;
}

/* Version 2
Signal generator implemented as Amos type.
Only needs the segment generation foreign function.
Get parameters A,B,C,D and the seed */

void gen_segment0(double a, double d, double seed, int n1, int n2, double *x)
/* s0 initial signal level
   a = maximum amplitude, signal levels in [0,a]
   b = max number of steps for signal to reach the new level
   c = max number of steps for signal to stay at the new level
   d = maximum variation of the signal at the new level */
{
   double s, ds, e;
   double mc = 100.0;  //coeff for variations
   int i;

   s= (double)random((int)a);
   if (fabs(s - seed)<1) s= s+1;
   ds = (s-seed)/n1;

   for(int i=0; i<n1; i++)
        x[i]= seed + (i+1)*ds;
   for(i=n1; i<n1+n2; i++)
   {    e= (double)random(int(2*d*mc));
        e= (e - mc*d)/mc;
        x[i]= s + e;
   }
  return;
}


void gen_segment0bbbbbf(a_callcontext cxt, a_tuple tpl)
{
   double a, d, seed; // a = maximum amplitude, signal levels in [-a,a]
   int b,c;     // b = max number of steps for signal to reach the new level
                // c = max number of steps for signal to stay at the new level
   int n1, n2;
   double *x;
   dcl_tuple(seg);

   a = a_getdoubleelem(tpl,0,FALSE);
   b = a_getintelem(tpl,1,FALSE);
   c = a_getintelem(tpl,2,FALSE);
   d = a_getdoubleelem(tpl,3,FALSE);
   seed = a_getdoubleelem(tpl,4,FALSE);

   n1= random(b) +1;
   n2= random(c);
   x= (double *)malloc((n1+n2)*sizeof(double));
   gen_segment0(a,d,seed,n1,n2,x);

   a_newtuple(seg,n1+n2,FALSE);
   for(int i=0; i<n1+n2; i++)
        a_setdoubleelem(seg,i,x[i],FALSE);

   a_setseqelem(tpl,5,seg,FALSE);
   
   a_emit(cxt,tpl,FALSE);
   free_tuple(seg);
   return;
}

void register_signal_generator(void)
{
  a_extfunction("init_gen", init_genbbbb);
  a_extfunction("get_next", get_nextf);
  a_extfunction("gen_segment0", gen_segment0bbbbbf);
}
