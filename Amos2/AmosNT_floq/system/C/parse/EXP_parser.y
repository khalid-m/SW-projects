/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2009 Tore Risch, UDBL
 * $RCSfile: EXP_parser.y,v $
 * $Revision: 1.1 $ $Date: 2009/09/01 20:20:17 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Parser for simple expressions
 * Generate code by running: bison -p EXP EXP_parser.y
 * ===========================================================================
 * $Log: EXP_parser.y,v $
 * Revision 1.1  2009/09/01 20:20:17  torer
 * Added example of very simple bison/flex parser
 *
 ****************************************************************************/

%{
   #include "alisp.h"
   extern oidtype EXP_statement; /* in lexer */
   extern oidtype EXPrefs;       /* in lexer */
   #define SAVE_REF a_setf(EXPrefs,cons(EXPlval.oidval,EXPrefs))
   extern void EXPerror(char *); /* in lexer */
%}

/* %pure_parser */  /* Reentrant parser */

%union { oidtype oidval; }

%token NAME
%token STRING
%token INTNUM APPROXNUM


	/* operators */

%left OR
%left AND
%left NOT

/* comparison */
%left EQ
%left NEQ
%left LT
%left GT
%left LTE
%left GTE

%left '+' '-'
%left '*' '/'
%nonassoc UMINUS


	/* literal keyword tokens */

%start EXP

%%

/******************************************************************/

	/* RULES */

EXP:                    expression
                 {a_setf(EXP_statement,$<oidval>1); 
		 a_free(EXPrefs); // free unreferenced parsed objects 
                  YYACCEPT;}


expression:		expression '+' expression
                  {$<oidval>$ = a_list(mksymbol("PLUS"),
				       $<oidval>1,$<oidval>3,NULL); SAVE_REF;}
			|	   expression '-' expression
                  {$<oidval>$ = a_list(mksymbol("MINUS"),
				       $<oidval>1,$<oidval>3,NULL); SAVE_REF;}
			|	   expression '*' expression
                  {$<oidval>$ = a_list(mksymbol("TIMES"),
				       $<oidval>1,$<oidval>3,NULL); SAVE_REF;}
			|	   expression '/' expression
                  {$<oidval>$ = a_list(mksymbol("DIV"),
                                      $<oidval>1,$<oidval>3,NULL); SAVE_REF}
			|	   '(' expression ')'		
                  {$<oidval>$ = $<oidval>2;}
			|	   '+' expression
                  {$<oidval>$ = $<oidval>2;}
			|	   '-' expression
                  {$<oidval>$ = a_list(mksymbol("MINUS"), mksymbol("0"), $<oidval>2, NULL); SAVE_REF}
			|	   literal
                  {$<oidval>$ = $<oidval>1;}


literal:		STRING
                  {$<oidval>$ = $<oidval>1;}
			|	INTNUM		
                  {$<oidval>$ = $<oidval>1;}
			|	APPROXNUM	
                  {$<oidval>$ = $<oidval>1;}
