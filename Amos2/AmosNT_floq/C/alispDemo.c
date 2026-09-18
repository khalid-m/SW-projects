/*****************************************************************************
 * AMOS2
 * 
 * Author: (c) 1998 Tore Risch, EDSLAB
 * $RCSfile: alispDemo.c,v $
 * $Revision: 1.2 $ $Date: 2009/05/20 15:58:47 $
 * $State: Exp $ $Locker:  $
 *
 * Description:  Demo program illustrating the C <-> ALisp interface
 * Language:     C
 ****************************************************************************/

#include "alisp.h"   /* Include Lisp interfaces */


/*** Define a new storage type in C to hold complex numbers ***/

struct mycomplexcell  /* Template for mycomplex numbers */
{
   objtags tags;               /* System tags */
   short int bytes;            /* Total size of object in bytes, incl. header */
   double real;                 /* Real part */
   double imag;                 /* Imaginaly part */
};
int mycomplex;             /* Will hold the type tag of objects of type MYCOMPLEX */


oidtype squarefn(bindtype env, oidtype x)
   /*** A Lisp function in C that computes X**2 where X is an integer ***/
{
    int i;

    IntoInteger(x,i,env);
    printf("Squaring %d\n",i);
    return mkinteger(i*i);
}

oidtype new_mycomplex(double re,double im)
   /*** Constructor for the mycomplex number re + i*im ***/
{
    /*** Allocate a new object of type MYCOMPLEX in the image ***/
    oidtype res = new_object(sizeof(struct mycomplexcell),mycomplex);

    /*** Set the real and imaginary parts of the new object ***/
    dr(res, mycomplexcell)->real = re;
    dr(res, mycomplexcell)->imag = im;

    /*** Return the new object ***/
    return res;
}

void print_mycomplex(oidtype o, oidtype stream, int princflg)
   /*** Print function for mycomplex numbers as
        e.g. #[mycomplex 1.2 4.2]
	***/
{
    dcloid(re);
    dcloid(im);

    a_puts("#[mycomplex ",stream);
    a_setf(re,mkreal(dr(o,mycomplexcell)->real));
    a_setf(im,mkreal(dr(o,mycomplexcell)->imag));
    a_prin1(re,stream,princflg);
    a_puts(" ",stream);
    a_prin1(im,stream,princflg);
    a_puts("]",stream);
    a_free(re); /* re no longer used */
    a_free(im); /* im no longer used */
    return;
}

oidtype read_mycomplex(bindtype env, oidtype tag, oidtype x, oidtype stream)
{
	/*** Helper function to read printed mycomplex numbers ***/
    oidtype re, im;

    re = hd(x);
    im = hd(tl(x));
    OfType(re,REALTYPE,env);
    OfType(im,REALTYPE,env);
    return new_mycomplex(getreal(re),getreal(im));
}

oidtype summycomplexfn(bindtype env, oidtype x, oidtype y)
    /*** Add the two mycomplex numbers x and y ***/
{
    struct mycomplexcell *dx, *dy; /* Will hold dereferenced mycomplex numbers */

    OfType(x,mycomplex,env); /* Check type of x */
    OfType(y,mycomplex,env); /* Check type of y */
    dx = dr(x,mycomplexcell); /* Dereference x */
    dy = dr(y,mycomplexcell); /* Dereference y */
    return new_mycomplex(dx->real + dy->real,
                       dx->imag + dy->imag); /* Construct result */
}

main(int argc,char **argv)
{
  dcloid(two);       /* Declare Lisp object two */
  dcloid(four);      /* Declare Lisp object four */
  dcloid(c1);        /* A mycomplex number */
  dcloid(c2);        /* A mycomplex number */
  dcloid(c3);        /* A mycomplex number */
  bindtype env;

  init_amos(argc,argv); /* Initialize embedded Amos and ALisp */

  env  = topframe(); /* Top frame on Lisp stack */
  
  /*** Testing mixed C++ and Amos2 I/O ***/

  printf("Hello C ALisp user.\n");
  a_puts("Testing ALisp stream output\n", stdoutstream);

  /*** Defining user defined Lisp function named SQUARE 
       implemented by C function squarefn ***/
  extfunction1("square",squarefn);

  /*** Call aLisp function SQUARE from C ***/
  a_setf(two, mkinteger(2)); /* Bind io to integer 1 */
  a_setf(four,call_lisp(mksymbol("square"),env,1,two));
                                                 /* Call Lisp function SQUARE */
  printf("The result should be four: ");
  a_print(four); /* Print result followed by CR on stdout */
  released(two);   /* two no longer used */
  released(four);  /* four no longer used */

  /*** Define new user defined aLisp datatype MYCOMPLEX ***/
  mycomplex = a_definetype("mycomplex",dealloc_object,print_mycomplex);

  /*** Define user defined reader for #[mycomplex r.r i.i] ***/
  type_reader_function("MYCOMPLEX", read_mycomplex);

  /*** Define Lisp function SUMMYCOMPLEX to add mycomplex numbers ***/
  extfunction2("summycomplex",summycomplexfn);

  /*** Call SUMMYCOMPLEX from C ***/
  a_setf(c1, new_mycomplex(2.0,4.0));
  a_setf(c2, new_mycomplex(1.0,2.0));
  a_setf(c3, summycomplexfn(topframe(),c1,c2));  /* Direct C call */
  a_prin1(c1,stdoutstream,TRUE);
  a_puts(" + ",stdoutstream);
  a_prin1(c2, stdoutstream,TRUE);
  a_puts(" = ",stdoutstream);
  a_prin1(c3,stdoutstream,TRUE);
  a_puts("\n",stdoutstream);
  a_setf(c3, call_lisp(mksymbol("summycomplex"),env,2,c1,c2));/* Call through Lisp */
  a_print(c3);


  /*** Release variables used in program no longer used: ***/
  a_free(c1);
  a_free(c2);
  a_free(c3);

  /*** Test hash tables ***/

  { oidtype ht=nil, key=nil, res=nil, val=nil;

   a_setf(ht, new_hashtable(TRUE));
   a_setf(key, mkstring("key"));
   a_setf(val, mkstring("value"));
   put_hashtable(ht,key,val);
   a_setf(res, get_hashtable(ht, key));
   a_print(res);
   a_free(ht); a_free(key); a_free(res); a_free(val);
  }

  /*** Enter Amos top loop ***/
  printf("Type 'a' to enter Amos top loop >");
  if(getc(stdin)=='a')amos_toploop("Amos");

  return 0;
}
