/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2009 Martynas Mickevicius, UDBL
 * $RCSfile: NTR_parser.y,v $
 * $Revision: 1.3 $ $Date: 2010/02/21 21:52:18 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Parser for ntriples
 * Generate code by running: bison -d -p NTR NTR_parser.y
 *
 ****************************************************************************/

%{
   #define RDFRTYPE_URI 0
   #define RDFRTYPE_LIT 1
   #define RDFRTYPE_BLA 2

   #define MAXLENGTH 4096

   #include "alisp.h"

   extern oidtype RDFResource1;         // in lexer
   extern oidtype RDFResource2;         // in lexer
   extern oidtype RDFResource3;         // in lexer
   extern char globalbuf[MAXLENGTH];    // in lexer

   char litbuf[MAXLENGTH];

   extern oidtype new_rdfr(short int, oidtype, char*, oidtype);
%}

/* %pure_parser */  /* Reentrant parser */

%union { oidtype oidval; }

    /* literal keyword tokens */

%token DOT
%token LT
%token GT
%token UC
%token QUO
%token AT
%token DBLUP
%token EF

%token NAME
%token ABSOLUTEURI
%token STRING

%%

/******************************************************************/

    /* RULES */

endoftriplestream:  triplestream EF { a_setf(RDFResource1, nil); YYACCEPT; }

triplestream:       /* empty */ {}
        |           triplestream triple {}

triple
:
    subject predicate object DOT
    {
        a_setf(RDFResource1, $<oidval>1);
        a_setf(RDFResource2, $<oidval>2);
        a_setf(RDFResource3, $<oidval>3);
        YYACCEPT;
    }
;

subject
:
    uriref
    {
        $<oidval>$ = $<oidval>1;
    }
|
    nodeid
    {
        $<oidval>$ = $<oidval>1;
    }
;

predicate
:
    uriref
    {
        $<oidval>$ = $<oidval>1;
    }
;

object
:
    uriref
    {
        $<oidval>$ = $<oidval>1;
    }
|
    nodeid
    {
        $<oidval>$ = $<oidval>1;
    }
|
    literal
    {
        $<oidval>$ = $<oidval>1;
    }
;

uriref
:
    LT ABSOLUTEURI GT
    {
        $<oidval>$ = new_rdfr(RDFRTYPE_URI, mkstring(globalbuf), NULL, nil);
    }
;

nodeid
:
    UC NAME
    {
        $<oidval>$ = new_rdfr(RDFRTYPE_BLA, mkstring(globalbuf), NULL, nil);
    }
;

literal
:
    literalstring AT NAME
    {
        // literal with language
        $<oidval>$ = new_rdfr(RDFRTYPE_LIT, mkstring(litbuf), globalbuf, nil);
    }
|
    literalstring DBLUP uriref
    {
        // literal with datatype
        $<oidval>$ = new_rdfr(RDFRTYPE_LIT, mkstring(litbuf), NULL, $<oidval>3);
    }
|
    literalstring
    {
        // plain literal
        $<oidval>$ = new_rdfr(RDFRTYPE_LIT, mkstring(litbuf), NULL, nil);
    }
;

literalstring
:
    QUO QUO
    {
        strcpy(litbuf, "");
    }
|
    QUO STRING QUO
    {
        strcpy(litbuf, globalbuf);
    }
;