/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2009 Martynas Mickevicius, UDBL
 * $RCSfile: driver.c,v $
 * $Revision: 1.7 $ $Date: 2010/02/21 21:52:19 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Amos2 driver program for ntriples wrapper
 ****************************************************************************/
#include "rdfr.h"

#include "amos.h"

#include <stdio.h>
#include <stdlib.h>

extern FILE *NTRin;
extern int NTRparse (void);
extern oidtype RDFResource1;
extern oidtype RDFResource2;
extern oidtype RDFResource3;
extern unsigned int NTRerrno;
extern void register_rdfr(void);

oidtype ntriples_alisp_fn(bindtype env, oidtype stream)
      // ALisp function to parse a file and return list of triples
{
  flexstream fls;
  oidtype triples = nil;

  OfType(stream, STREAMTYPE, env);
  init_flexstream(stream, &fls);
  NTRin = (FILE *)&fls;

  NTRparse();
  while (RDFResource1 != nil)
  {
    a_setf(triples, cons(a_list(RDFResource1, RDFResource2, RDFResource3, NULL), triples));

    a_free(RDFResource1);
    a_free(RDFResource2);
    a_free(RDFResource3);

    NTRparse();
  }

  return triples;
}

oidtype ntriples_fn(a_callcontext cxt)
      // Amos II TBR implementation to parse a file and return bags of triples
{
  oidtype filename = nil;
  oidtype stream = nil;
  flexstream fls;

  filename = a_arg(cxt, 1);

  if (filename != nil)
  {
    OfType(filename, STRINGTYPE, a_env(cxt));

    stream = call_lisp(mksymbol("openstream"), varstack, 2, filename, mkstring("r"));

    init_flexstream(stream, &fls);
    NTRin = (FILE *)&fls;

    NTRparse();

    while (RDFResource1 != nil)
    {
      /*a_setobjectelem(tuple, 1, RDFResource1, FALSE);
      a_setobjectelem(tuple, 2, RDFResource2, FALSE);
      a_setobjectelem(tuple, 3, RDFResource3, FALSE);
      a_emit(cxt, tuple, FALSE);*/

      a_bind(cxt, 2, RDFResource1);
      a_bind(cxt, 3, RDFResource2);
      a_bind(cxt, 4, RDFResource3);
      a_result(cxt);

      a_free(RDFResource1);
      a_free(RDFResource2);
      a_free(RDFResource3);

      NTRparse();
    }
  }
  return nil;
}

main(int argc,char **argv)
{
  init_amos(argc,argv);

  register_rdfr();
  extfunction1("ntriplesfn", ntriples_alisp_fn);

  // register custom error for parser
  NTRerrno = a_register_error("PARSE-NTRIPLES");

  // register custom errors for RDFResource
  error_defs[NTR_ERR_NO_CODEC_BY_KIND] = a_register_error("No encoder/decoder was found in type table by kind");
  error_defs[NTR_ERR_URI_FROM_OBJECT] = a_register_error("Can not create RDF URI from internal object");
  error_defs[NTR_ERR_LIT_FROM_OBJECT] = a_register_error("Can not create plain RDF literal from internal object");
  error_defs[NTR_ERR_BNODE_FROM_OBJECT] = a_register_error("Can not create RDF blank node from internal object");

  a_extimpl("ntriples", ntriples_fn);

  amos_toploop("Amos");
  return 0;
}
