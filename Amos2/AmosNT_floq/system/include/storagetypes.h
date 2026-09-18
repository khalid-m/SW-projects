/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2006 Tore Risch, Erik Zeitler, UDBL
 * $RCSfile: storagetypes.h,v $
 * $Revision: 1.22 $ $Date: 2014/01/12 16:28:31 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Declarations for new storage types
 * ===========================================================================
 * $Log: storagetypes.h,v $
 * Revision 1.22  2014/01/12 16:28:31  torer
 * Apple cc v5.0 safe C code
 *
 * Revision 1.21  2013/10/28 21:33:25  torer
 * Introduced record scan interface
 *
 * Revision 1.20  2013/10/28 19:52:20  torer
 * Removed record type SSRC
 *
 * Revision 1.19  2011/04/20 10:06:55  torer
 * new C function
 *   int generator_width(bindtype env, oidtype g)
 *
 * Revision 1.18  2011/03/09 12:33:54  torer
 * Amos as DLL!
 *
 * Revision 1.17  2010/12/17 13:29:35  zeitler
 * fix function naming conventions
 *
 * Revision 1.16  2009/09/01 13:56:16  zeitler
 * record extended with /kind/
 *
 * Revision 1.14  2009/08/20 17:41:11  zeitler
 * - Record is extended with /kind/ attribute
 * - kind 1 is used to carry stream source definitions
 *
 * Revision 1.13  2008/10/01 16:17:38  zeitler
 * port is extended with subscriber id
 *
 * Revision 1.12  2008/09/04 11:23:59  ruslan
 * renaming id to sid in sobject type implementation
 *
 * Revision 1.11  2008/02/28 13:10:53  ruslan
 * new data type sobject for streamed objects
 *
 * Revision 1.10  2007/11/09 08:29:46  ruslan
 * checks that the definition is loaded only once
 *
 * Revision 1.9  2006/11/15 16:19:44  zeitler
 * Fcn headers for extract of proto, host, portno
 *
 * Revision 1.8  2006/11/03 17:22:35  zeitler
 * Fixed equal fcn for generators, added fcn headers in comm.h
 *
 * Revision 1.7  2006/10/25 17:31:12  zeitler
 * Better impl of generator equality functions
 *
 * Revision 1.6  2006/10/24 14:02:24  zeitler
 * generator comparison functions
 *
 * Revision 1.5  2006/10/24 11:29:45  zeitler
 * added protocol attrib to port
 *
 * Revision 1.4  2006/10/23 15:33:42  zeitler
 * New storagetype HOSTPORT, carrying socket info
 *
 * Revision 1.3  2006/05/02 08:24:44  torer
 * extern -> EXTERN
 *
 * Revision 1.2  2006/04/26 16:55:50  torer
 * Changed Lisp constructor for STRUCT
 *
 * Revision 1.1  2006/04/26 12:23:53  torer
 * Storage type STRUCT implemented
 *
 ***************************************************************************/

#ifndef _storagetypes_h_
#define _storagetypes_h_
/********************  type PORT *******************************************/
EXTERN int porttype;                             /* Type tag for type PORT */

struct portcell
{
  objtags tags;
  HEADFILLER;
  oidtype proto;
  oidtype hostname;
  oidtype portno;
  oidtype subscriber;
};

EXTERN oidtype make_portfn(bindtype env, oidtype proto, oidtype hostname,
			   oidtype portno, oidtype subscriber);
EXTERN oidtype read_port(bindtype env, oidtype tag, oidtype x,
			 oidtype stream);
EXTERN void free_port(oidtype x);
EXTERN void print_port(oidtype x, oidtype stream, int princflg);
EXTERN oidtype port_gethostnamefn(bindtype env, oidtype port);
EXTERN oidtype port_getportnofn(bindtype env, oidtype port);
EXTERN oidtype port_getsubfn(bindtype env, oidtype port);
EXTERN oidtype port_getprotofn(bindtype env, oidtype port);

/********************  type GENERATOR **************************************/
EXTERN int generatortype;                   /* Type tag for type GENERATOR */

struct generatorcell
{
  objtags tags;
  HEADFILLER;
  oidtype fn;                  /* AmosQL function generating stream tuples */
  oidtype params;                              /* Parameters for generator */
  oidtype type;
};

EXTERN oidtype make_generatorfn(bindtype env, oidtype type, oidtype fn, 
				oidtype params);
EXTERN oidtype generator_functionfn(bindtype env, oidtype g);
EXTERN oidtype generator_paramsfn(bindtype env, oidtype g);
EXTERN oidtype inspect_generatorfn(bindtype env, oidtype x);
EXTERN int equal_generatorfn(oidtype x, oidtype y);
EXTERN int equal_functionfn(oidtype x, oidtype y);
EXTERN int equal_typefn(oidtype x, oidtype y);
EXTERN int equal_paramsfn(oidtype x, oidtype y);
EXTERN oidtype generator_functionfn(bindtype env, oidtype g);
EXTERN oidtype generator_paramsfn(bindtype env, oidtype g);
EXTERN oidtype generator_typefn(bindtype env, oidtype g);
EXTERN int generator_width(bindtype env, oidtype g);
/********************  type RECORD     **************************************/
EXTERN int recordtype;                          /* Type tag for type RECORD */

struct recordcell
{
  objtags tags;
  short int filler;
  oidtype fields;               /* The attribute/value pairs of the record */
}; 

EXTERN oidtype make_recordfn(bindtype env, oidtype fields);
EXTERN oidtype record_getfn(bindtype env, oidtype rec, oidtype key);
EXTERN oidtype record_putfn(bindtype env, oidtype rec, oidtype key, 
                            oidtype val);

struct record_scan
{
  oidtype scan;
  int scanpos;
  int size;
};

EXTERN int open_record_scan(oidtype rec,struct record_scan *rs,int catcherror);
#define record_scan_key(rs) a_elt((rs)->scan,(rs)->scanpos)
#define record_scan_value(rs) a_elt((rs)->scan,(rs)->scanpos+1)
#define record_scan_next(rs) (rs)->scanpos=(rs)->scanpos+2
#define record_scan_empty(rs) ((rs)->scanpos>=(rs)->size)
 
/********************  type STRUCT     **************************************/
EXTERN int structtype;                          /* Type tag for type STRUCT */

struct structcell
{
  objtags tags;
  short int size;                                   /* Number of attributes */
  oidtype typeo;                                          /* Type of struct */
  oidtype attributes[1];                      /* The attributes padded here */
}; 

EXTERN oidtype make_struct(oidtype type, short int size);
EXTERN oidtype struct_get(bindtype env, oidtype s, int i);
EXTERN oidtype struct_set(bindtype env, oidtype s, int i,oidtype val);

EXTERN oidtype make_structfn(bindtype env, oidtype type, oidtype cont);
EXTERN oidtype struct_getelemfn(bindtype env, oidtype s, oidtype i);
EXTERN oidtype struct_setelemfn(bindtype env, oidtype s,oidtype i,oidtype val);
EXTERN oidtype struct_typefn(bindtype env, oidtype s);
EXTERN oidtype struct_sizefn(bindtype env, oidtype s);

/********************  type SOBJECT     **************************************/
EXTERN int sobjecttype;                         /* Type tag for type SOBJECT */

struct sobjectcell
{
  objtags tags;
  short int size;                                   /* Number of attributes */
  oidtype typeo;                                          /* Type of sobject */
  oidtype src;                                          /* Soruce of sobject */
  oidtype sid;                               /* Identifier of sobject in src */
  oidtype attributes[1];                       /* The attributes padded here */
}; 

EXTERN oidtype make_sobject(oidtype type, oidtype src, oidtype sid, 
                            short int size);
EXTERN oidtype sobject_get(oidtype s, int i);
EXTERN oidtype sobject_set(oidtype s, int i,oidtype val);

#endif /* _storagetypes_h_ */
