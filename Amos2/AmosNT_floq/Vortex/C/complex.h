
#define IntoComplex(oid, re, im, env)\
    if(integerp(oid)) {\
        re = (float)getinteger(oid); im = 0.0;\
    } else if(realp(oid)) {\
        re = (float)getreal(oid); im = 0.0;\
    } else if (a_datatype(oid) == complex) {\
        re = dr(oid,complexcell)->real; \
        im = dr(oid,complexcell)->imag;\
    }  else return lerror(ARG_NOT_NUMBER, oid, env)

struct complexcell  /* Template for complex numbers */
{
   objtags tags;              /* System tags */
   short int bytes;           /* Total size of object in bytes, incl. header */
   float real;                /* Real part */
   float imag;                /* Imaginaly part */
};

EXTERN oidtype new_complex(double re,double im);

