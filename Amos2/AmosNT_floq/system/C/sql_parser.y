/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1998, 2004 Marcus Eriksson, Tore Risch, Markus Jägerskogh, EDSLAB, UDBL, UDBL
 * $RCSfile: sql_parser.y,v $
 * $Revision: 1.13 $ $Date: 2013/07/24 18:37:08 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Bison SQL parser for AMOS2
 * Generate code by running: bison -p SQL sql_parser.y
 ****************************************************************************/

%{
#include "alisp.h"
  extern char *SQLtext;      /* Defined in the lexer */
  extern char *myinputptr;   /* Where the SQL string to parse is */
  extern int mybufsize;      /* Size of SQL string */
  oidtype sql_statement=nil; /* The parsed SQL form */
  extern oidtype _oidrefs_;  /* List of objects created during parsing */

#define SAVE_REF a_setf(globval(_oidrefs_),\
                        cons(yyval.oidval,globval(_oidrefs_)))
#define reverse(x)nreversefn(varstack,x)
%}

/* %pure_parser */  /* Reentrant parser */

%union { oidtype oidval; }

%token NAME COLUMN
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

%token ALL AMMSC AS ASC AVG BETWEEN BOOLEAN BY CHARACTER CASCADE CASE CHECK
%token CLOB COMMIT CONSTRAINT COUNT CREATE CROSS DESC DECIMAL DEFAULT
%token _DELETE DISTINCT DOUBLE DROP ELSE END ESCAPE EXISTS _FALSE FLOAT
%token FOREIGN FROM GROUP HAVING _IN INDICATOR INNER INSERT INTEGER INTO
%token IS JOIN KEY LIKE MAX MIN NATRUAL NOT _NULL _NUMERIC OID ON ORDER
%token PARAM PARAMETER PRECISION PRIMARY REAL REFERENCES RESTRICT
%token ROLLBACK SCHEMA SELECT SET SUM TABLE THEN _TRUE UNION UNIQUE UPDATE
%token USER VALUES VARCHAR VARYING WHEN WHERE WORK _EOF _QUIT

/* cql tokens */
%token ISTREAM DSTREAM RSTREAM NOW PARTITION ROWS RANGE SECONDS MINUTES

/*sql functions*/
%token INN

%start sql

%%

/******************************************************************/

/* RULES */
sql:             stmt opt_semicolon //;
{
  _oidrefs_ = mksymbol("_oidrefs_");
  a_setf(sql_statement,$<oidval>1); 
  a_free(globval(_oidrefs_));
  YYACCEPT;
}
| _EOF 
{
  a_setf(sql_statement, mksymbol("*EOF*"));
  YYACCEPT;
}
|
error 
{
  a_free(globval(_oidrefs_));
  a_free(sql_statement); 
}
;

stmt:                    select_statement 
{$<oidval>$ = $<oidval>1;}
|
create_table_statement 
{$<oidval>$ = $<oidval>1;}
|
insert_statement 
{$<oidval>$ = $<oidval>1;}
|
delete_statement 
{$<oidval>$ = $<oidval>1;}
|
update_statement 
{$<oidval>$ = $<oidval>1;}
|
commit_statement 
{$<oidval>$ = $<oidval>1;}
|
rollback_statement 
{$<oidval>$ = $<oidval>1;}
|
drop_statement 
{$<oidval>$ = $<oidval>1;}
|
set_schema_statement 
{$<oidval>$ = $<oidval>1;}
| _QUIT
{ exit(1);}
;

opt_semicolon:          |
';'
;

/**************** SET SCHEMA STATEMENT ****************/

set_schema_statement:   SCHEMA NAME
{
  $<oidval>$ = a_list(mksymbol("SETQ"),
		      mksymbol("*currentschema*"),
		      a_list(mksymbol("QUOTE"), $<oidval>2, NULL),
		      NULL); 
  SAVE_REF;
}
|
SCHEMA DEFAULT
{
  $<oidval>$ = a_list(mksymbol("SETQ"),
		      mksymbol("*currentschema*"),
		      mkstring(""), NULL); 
  SAVE_REF;
}
;

/******************* DROP STATEMENT *******************/

drop_statement:         DROP TABLE table opt_drop_type
{
  $<oidval>$ = a_list(mksymbol("SQL-DROP-TABLE"),
		      $<oidval>3, NULL); 
  SAVE_REF;
}
;

opt_drop_type:   
{$<oidval>$ = nil;}
|
RESTRICT
|
CASCADE
;

/***************** ROLLBACK STATEMENT *****************/

rollback_statement:     ROLLBACK opt_work_keyword
{
  $<oidval>$ = cons($<oidval>1, nil); 
  SAVE_REF;
}

opt_work_keyword:        |
WORK
;

/****************** COMMIT STATEMENT ******************/

commit_statement:       COMMIT opt_work_keyword
{
  $<oidval>$ = cons($<oidval>1, nil); 
  SAVE_REF;
}

/****************** UPDATE STATEMENT ******************/

update_statement:    UPDATE table SET update_column_commalist opt_where_clause
{
  $<oidval>$ = a_list(mksymbol("SQL-UPDATE"), $<oidval>2,
		      $<oidval>3, reverse($<oidval>4), 
		      NULL);
  if($<oidval>5 != nil)
    $<oidval>$ = nconc($<oidval>$,
		       cons(a_list(mksymbol("WHERE"),
				   $<oidval>5, NULL), nil),
                       NULL);
  SAVE_REF;
}
;

update_column_commalist:
update_column
{
  $<oidval>$ = cons($<oidval>1, nil); 
  SAVE_REF;
}
|
update_column_commalist ',' update_column
{
  $<oidval>$ = cons($<oidval>3, $<oidval>1); 
  SAVE_REF;
  /* Reverse */
}
;

update_column:   {$<oidval>$ = nil;}
|
NAME EQ scalar_exp
{
  $<oidval>$ = cons($<oidval>1, $<oidval>3); 
  SAVE_REF;
}
;

/****************** DELETE STATEMENT ******************/

delete_statement:       _DELETE FROM table opt_where_clause
{
  $<oidval>$ = a_list(mksymbol("SQL-DELETE"), $<oidval>3, NULL);
  if($<oidval>4 != nil)
    $<oidval>$ = nconc($<oidval>$, cons($<oidval>4, nil), NULL);
  SAVE_REF;
}
;

/****************** INSERT STATEMENT ******************/

insert_statement:       INSERT INTO table opt_columns VALUES values_commalist
{
  $<oidval>$ = cons($<oidval>5, $<oidval>6);
  if($<oidval>4!=nil)
    $<oidval>$ = cons($<oidval>4, $<oidval>$);
  $<oidval>$ = cons(mksymbol("SQL-INSERT"),
		    cons($<oidval>3, $<oidval>$));
  SAVE_REF;
}
;

opt_columns:     {$<oidval>$ = nil;}
|
'(' column_commalist ')'
{
  $<oidval>$ = reverse($<oidval>2); 
  SAVE_REF;
}
;

column_commalist:       NAME
{
  $<oidval>$ = cons($<oidval>1, nil); 
  SAVE_REF;
}
|
column_commalist ',' NAME
{
  $<oidval>$ = cons($<oidval>3, $<oidval>1); 
  SAVE_REF;
  /* Reverse */
}
;

values_commalist:       '(' scalar_exp_commalist ')'
{
  $<oidval>$ = cons(reverse($<oidval>2), nil); 
  SAVE_REF;
}
|
values_commalist ',' '(' scalar_exp_commalist ')'
{
  $<oidval>$ = nconc($<oidval>1, cons(reverse($<oidval>4), nil), NULL);
  SAVE_REF;
} 
;

/*************** CREATE TABLE STATEMENT ***************/

create_table_statement: CREATE TABLE table '(' tbl_element_commalist ')'
{
  $<oidval>$ = a_list(mksymbol("SQL-CREATE-TABLE"),
		      $<oidval>3,
		      reverse($<oidval>5),
		      NULL); 
  SAVE_REF;
}
;

tbl_element_commalist:	table_element
{
  $<oidval>$ = cons($<oidval>1,nil);
  SAVE_REF;
}
|      tbl_element_commalist ',' table_element
{
  $<oidval>$ = cons($<oidval>3,$<oidval>1);
  SAVE_REF;
  /* Reverse */
}
;

table_element:          column_definition
{$<oidval>$ = $<oidval>1;}
|
table_constraint
;

column_definition:      NAME data_type opt_default_spec opt_col_constraints
{
  if($<oidval>3==nil) $<oidval>$ = a_list($<oidval>1, $<oidval>2, NULL);
    else $<oidval>$ = a_list($<oidval>1, $<oidval>2, $<oidval>3, NULL);
  $<oidval>$ = nconc($<oidval>$, $<oidval>4, NULL);
  SAVE_REF;
}
;

data_type:              type0
{
  $<oidval>$ = cons($<oidval>1, nil); 
  SAVE_REF;
}
|
type1 opt_type_param1
{
  $<oidval>$ = cons($<oidval>1, $<oidval>2); 
  SAVE_REF;
}
|
type2 opt_type_param2
{
  $<oidval>$ = cons($<oidval>1, $<oidval>2); 
  SAVE_REF;
}
;

opt_type_param1: {$<oidval>$ = nil;}
|
'(' INTNUM ')'
{
  $<oidval>$ = cons($<oidval>2, nil); 
  SAVE_REF;
}

opt_type_param2:        opt_type_param1
|
'(' INTNUM ',' INTNUM ')'
{
  $<oidval>$ = a_list($<oidval>2, $<oidval>4, NULL); 
  SAVE_REF;
}
;

type0:                  INTEGER
| REAL
| DOUBLE PRECISION
| BOOLEAN
;

type1:                  FLOAT
| CHARACTER
| VARCHAR
| CHARACTER VARYING 
{ 
  $<oidval>$ = mksymbol("VARCHAR"); 
}
| CLOB
;

type2:                  _NUMERIC
| DECIMAL
;

opt_default_spec:
{$<oidval>$ = nil;}
| DEFAULT default_value
{
  $<oidval>$ = a_list($<oidval>1, $<oidval>2, NULL); 
  SAVE_REF;
}
;

default_value:          STRING
| INTNUM
| APPROXNUM
| _TRUE
| _FALSE
| NAME
| _NULL
;

opt_col_constraints:
{$<oidval>$ = nil;}
|
col_constraints_list
;

col_constraints_list:
col_constraint
{$<oidval>$ = $<oidval>1;}
|	col_constraints_list col_constraint
{$<oidval>$ = nconc($<oidval>1,$<oidval>2, NULL);}
;

col_constraint:         CONSTRAINT NAME simple_col_constraint
{$<oidval>$ = $<oidval>3;}
|
simple_col_constraint
;


simple_col_constraint:  NOT _NULL
{
  $<oidval>$ = cons(mksymbol("NOT-NULL"), nil); 
  SAVE_REF;
}
|
PRIMARY KEY
{
  $<oidval>$ = cons(mksymbol("PRIMARY-KEY"), nil); 
  SAVE_REF;
}
|
UNIQUE
{
  $<oidval>$ = cons($<oidval>1,nil); 
  SAVE_REF;
}
|
REFERENCES table opt_col_ref
{
  if($<oidval>2 == nil) $<oidval>$ = cons($<oidval>1, nil);
  else $<oidval>$ = a_list($<oidval>1, $<oidval>2, NULL); 
  SAVE_REF;
}
|
CHECK '(' search_condition ')'
{
  $<oidval>$ = a_list($<oidval>1, $<oidval>3, NULL); 
  SAVE_REF;
}
;

table_constraint:       CONSTRAINT NAME simple_table_constraint
{
  $<oidval>$ = nconc(a_list($<oidval>1,
			    $<oidval>2, NULL),
		     $<oidval>3,
                     NULL); 
  SAVE_REF;
}
|
simple_table_constraint
{
  $<oidval>$ = cons(mksymbol("CONSTRAINT"),
		    $<oidval>1); 
  SAVE_REF;
}
;

simple_table_constraint:
PRIMARY KEY '(' local_column_refs ')'
{
  $<oidval>$ = a_list(mksymbol("PRIMARY-KEY"), $<oidval>4, NULL);
  SAVE_REF;
}
|
UNIQUE '(' column_ref_commalist ')'
{
  $<oidval>$ = a_list($<oidval>1, $<oidval>3, NULL); 
  SAVE_REF;
}
|
FOREIGN KEY '(' column_ref_commalist ')'
REFERENCES table opt_col_ref
{
  $<oidval>$ = a_list(mksymbol("FOREIGN-KEY"), $<oidval>4,
		      $<oidval>6, $<oidval>7, $<oidval>8, 
		      NULL);
  SAVE_REF;
}
;

local_column_refs:	NAME
{
  $<oidval>$ = cons($<oidval>1,nil);
  SAVE_REF;
}
|      local_column_refs ',' NAME
{
  $<oidval>$ = cons($<oidval>3,$<oidval>1);
  SAVE_REF;
  /* Reverse */
}
;

opt_col_ref:
{$<oidval>$ = nil;}
|
'(' column_ref_commalist ')'
{$<oidval>$ = $<oidval>2;}
;

/****************** SELECT STATEMENT ******************/

select_statement:	SELECT opt_all_distinct selection from_clause
opt_where_clause opt_group_by_clause
opt_having_clause opt_order_by_clause
{
  if($<oidval>8 != nil)                           /* having */
    $<oidval>$ = a_list(mksymbol("ORDERBY"), $<oidval>8, NULL);
  else
    $<oidval>$ = nil;

  if($<oidval>7 != nil)
    {
      $<oidval>$ = cons($<oidval>7, $<oidval>$);    /* having */
      $<oidval>$ = cons(mksymbol("HAVING"), $<oidval>$);
    }

  if($<oidval>6 != nil)
    {
      $<oidval>$ = cons($<oidval>6, $<oidval>$);    /* group by */
      $<oidval>$ = cons(mksymbol("GROUPBY"), $<oidval>$);
    }
  if($<oidval>5 != nil)
    {                                               /* where */
      $<oidval>$ = cons($<oidval>5, $<oidval>$);
      $<oidval>$ = cons(mksymbol("WHERE"), $<oidval>$);
    }
  $<oidval>$ = cons($<oidval>4, $<oidval>$);
  $<oidval>$ = cons(mksymbol("FROM"), $<oidval>$); /* from */
  $<oidval>$ = cons(reverse($<oidval>3), $<oidval>$); /* result */
  if($<oidval>2 != nil)                           /* distinct */
    $<oidval>$ = cons($<oidval>2, $<oidval>$);
  $<oidval>$ = cons(mksymbol("SQL-SELECT"), $<oidval>$);
  SAVE_REF;

  //                  $<oidval>$ = a_list(mksymbol("SQL-SELECT"), /* select */
  //                                      $<oidval>2, /* distinct */
  //                                      $<oidval>3, /* result */
  //                                      $<oidval>4, /* from */
  //                                      $<oidval>5, /* where */
  //                                      $<oidval>6, /* group by */
  //                                      $<oidval>7, /* having */
  //                                      NULL); SAVE_REF;
}
;

opt_all_distinct: {$<oidval>$ = nil; /*mksymbol("ALL");*/}
|  ALL
{$<oidval>$ = $<oidval>1;}
|  DISTINCT
{$<oidval>$ = $<oidval>1;}
;

from_clause: FROM table_ref_commalist
{
  $<oidval>$ = reverse($<oidval>2);
  SAVE_REF;
}
;

table_ref_commalist:	table_ref
{
  $<oidval>$ = cons($<oidval>1,nil);
  SAVE_REF;
}
|	table_ref_commalist ',' table_ref
{
  $<oidval>$ = cons($<oidval>3,$<oidval>1);
  SAVE_REF;
}/* Reverse */
|	table_ref_commalist INNER JOIN table_ref ON search_condition
{
  $<oidval>$ = cons(a_list(mksymbol("INNERJOIN"),
			   call_lisp(mksymbol("SECOND"), varstack, 1, 
				     $<oidval>4),
			   call_lisp(mksymbol("THIRD"), varstack, 1, 
				     $<oidval>4),
			   $<oidval>6, NULL),
		    $<oidval>1);
  SAVE_REF;
}/* Reverse */
|	table_ref_commalist JOIN table_ref ON search_condition
{
  $<oidval>$ = cons(a_list(mksymbol("INNERJOIN"),
			   call_lisp(mksymbol("SECOND"), varstack, 1, 
				     $<oidval>3),
			   call_lisp(mksymbol("THIRD"), varstack, 1, 
				     $<oidval>3),
			   $<oidval>5, NULL),
		    $<oidval>1);
  SAVE_REF;
}/* Reverse */
|	table_ref_commalist CROSS JOIN table_ref
{
  $<oidval>$ = cons(a_list(mksymbol("CROSSJOIN"),
			   call_lisp(mksymbol("SECOND"), varstack, 1, 
				     $<oidval>4),
			   call_lisp(mksymbol("THIRD"), varstack, 1, 
				     $<oidval>4),
			   NULL),
		    $<oidval>1);
  SAVE_REF;
}/* Reverse */
;

table_ref:		table
{
  $<oidval>$ = a_list(nil, $<oidval>1, NULL); 
  SAVE_REF;
}
|	table range_variable
{
  $<oidval>$ = a_list(nil,$<oidval>1,$<oidval>2, NULL); 
  SAVE_REF;
}
|	table AS range_variable
{
  $<oidval>$ = a_list(nil,$<oidval>1,$<oidval>3, NULL); 
  SAVE_REF;
}
;

range_variable:		NAME
{$<oidval>$ = $<oidval>1;}
;

opt_where_clause:	/* empty */
{$<oidval>$ = nil;}
|  WHERE search_condition
{$<oidval>$ = $<oidval>2;}
;

opt_group_by_clause:	/* empty */
{$<oidval>$ = nil;}
|  GROUP BY column_ref_commalist
{
  $<oidval>$ = reverse($<oidval>3); 
  SAVE_REF;
}
;

column_ref_commalist:	column_ref
{
  $<oidval>$ = cons($<oidval>1,nil);
  SAVE_REF;
}
|      column_ref_commalist ',' column_ref
{
  $<oidval>$ = cons($<oidval>3,$<oidval>1);
  SAVE_REF;
  /* Reverse */
}
;

opt_having_clause:	/* empty */
{$<oidval>$ = nil;}
|  HAVING search_condition
{$<oidval>$ = $<oidval>2;}
;

opt_order_by_clause:    /* empty */
{$<oidval>$ = nil;}
|  ORDER BY order_ref_commalist
{
  $<oidval>$ = reverse($<oidval>3); 
  SAVE_REF;
}
;

order_ref_commalist:	scalar_exp order_dir
{
  $<oidval>$ = cons(a_list($<oidval>2, $<oidval>1, NULL),nil); 
  SAVE_REF;
}
|	order_ref_commalist ',' scalar_exp order_dir
{
  $<oidval>$ = cons(a_list($<oidval>4, $<oidval>3, NULL),$<oidval>1); 
  SAVE_REF;
  /* Reverse */
}
;

order_dir:              /* empty */
{$<oidval>$ = mksymbol("ASC");}
| ASC
{$<oidval>$ = $<oidval>1;}
| DESC
{$<oidval>$ = $<oidval>1;}
;

selection:      projection
{$<oidval>$ = $<oidval>1;}
|      relation_to_stream '(' projection ')'
{
  $<oidval>$ = a_list($<oidval>3, $<oidval>1, NULL); 
  SAVE_REF;
}
                  
projection:  selection_item
{
  $<oidval>$ = cons($<oidval>1,nil); 
  SAVE_REF;
}
|	selection ',' selection_item
{
  $<oidval>$ = cons($<oidval>3,$<oidval>1); 
  SAVE_REF;
  /* Reverse */
}
;
            
relation_to_stream: ISTREAM 
{$<oidval>$ = $<oidval>1;}
| DSTREAM 
{$<oidval>$ = $<oidval>1;}
| RSTREAM 
{$<oidval>$ = $<oidval>1;}
;                                                     

selection_item:         scalar_exp
{$<oidval>$ = $<oidval>1;}
|
scalar_exp NAME
{$<oidval>$ = $<oidval>1;}
|
scalar_exp AS NAME
{$<oidval>$ = $<oidval>1;}
|
'*'
{$<oidval>$ = $<oidval>1;}
|
NAME '.' '*'
{
  $<oidval>$ = cons($<oidval>3, $<oidval>1); 
  SAVE_REF;
}
;

scalar_exp:		scalar_exp '+' scalar_exp
{
  $<oidval>$ = a_list(mksymbol("PLUS"),
		      $<oidval>1,$<oidval>3,NULL); 
  SAVE_REF;
}
|	   scalar_exp '-' scalar_exp
{
  $<oidval>$ = a_list(mksymbol("MINUS"),
		      $<oidval>1,$<oidval>3,NULL); 
  SAVE_REF;
}
|	   scalar_exp '*' scalar_exp
{
  $<oidval>$ = a_list(mksymbol("TIMES"),
		      $<oidval>1,$<oidval>3,NULL); 
  SAVE_REF;
}
|	   scalar_exp '/' scalar_exp
{
  $<oidval>$ = a_list(mksymbol("DIV"),
		      $<oidval>1,$<oidval>3,NULL); 
  SAVE_REF;
}
|	   '(' scalar_exp ')'		
{$<oidval>$ = $<oidval>2;}
|	   '+' scalar_exp
{$<oidval>$ = $<oidval>2;}
|	   '-' scalar_exp
{
  $<oidval>$ = a_list(mksymbol("MINUS"), mksymbol("0"), $<oidval>2, NULL); 
  SAVE_REF;
}
|	   atom
{$<oidval>$ = $<oidval>1;}
|	   column_ref		
{$<oidval>$ = $<oidval>1;}
|	   function_ref		
{$<oidval>$ = $<oidval>1;}
//			|	   PARAM
//                  {$<oidval>$ = $<oidval>1;}
|          case_stmt
{$<oidval>$ = $<oidval>1;}
;

scalar_exp_commalist:	scalar_exp
{
  $<oidval>$ = cons($<oidval>1,nil); 
  SAVE_REF;
}
|	scalar_exp_commalist ',' scalar_exp
{
  $<oidval>$ = cons($<oidval>3,$<oidval>1); 
  SAVE_REF;
  /* Reverse */
}
;

function_ref:		NAME '(' scalar_exp ')'
{
  $<oidval>$ = a_list($<oidval>1,$<oidval>3,NULL); 
  SAVE_REF;
}
|
NAME '(' scalar_exp ',' scalar_exp')'
{
  $<oidval>$ = a_list($<oidval>1,$<oidval>3,$<oidval>5, NULL); 
  SAVE_REF;
}
|
COUNT '(' scalar_exp ')'
{
  $<oidval>$ = a_list(mksymbol("SQL_COUNT"),$<oidval>3,NULL); 
  SAVE_REF;
}
|
COUNT '(' '*' ')'
{
  $<oidval>$ = a_list(mksymbol("SQL_COUNT"),$<oidval>3,NULL); 
  SAVE_REF;
}
|
COUNT '(' ALL scalar_exp ')'
{
  $<oidval>$ = a_list(mksymbol("SQL_COUNT"),$<oidval>4,NULL); 
  SAVE_REF;
}
|
COUNT '(' DISTINCT scalar_exp ')'
{
  $<oidval>$ = a_list(mksymbol("SQL_COUNTD"),$<oidval>4,NULL); 
  SAVE_REF;
}
|
MIN '(' opt_all_distinct scalar_exp ')'
{
  $<oidval>$ = a_list(mksymbol("SQL_MIN"),$<oidval>4,NULL); 
  SAVE_REF;
}
|
MAX '(' opt_all_distinct scalar_exp ')'
{
  $<oidval>$ = a_list(mksymbol("SQL_MAX"),$<oidval>4,NULL); 
  SAVE_REF;
}
|
AVG '(' scalar_exp ')'
{
  $<oidval>$ = a_list(mksymbol("SQL_AVG"),$<oidval>3,NULL); 
  SAVE_REF;
}
|
AVG '(' ALL scalar_exp ')'
{
  $<oidval>$ = a_list(mksymbol("SQL_AVG"),$<oidval>4,NULL); 
  SAVE_REF;
}
|
AVG '(' DISTINCT scalar_exp ')'
{
  $<oidval>$ = a_list(mksymbol("SQL_AVGD"),$<oidval>4,NULL); 
  SAVE_REF;
}
|
SUM '(' scalar_exp ')'
{
  $<oidval>$ = a_list(mksymbol("SQL_SUM"),$<oidval>3,NULL); 
  SAVE_REF;
}
|
SUM '(' ALL scalar_exp ')'
{
  $<oidval>$ = a_list(mksymbol("SQL_SUM"),$<oidval>4,NULL); 
  SAVE_REF;
}
|
SUM '(' DISTINCT scalar_exp ')'
{
  $<oidval>$ = a_list(mksymbol("SQL_SUMD"),$<oidval>4,NULL); 
  SAVE_REF;
}
//|
//ABS '(' scalar_exp ')'
//{
//  $<oidval>$ = a_list(mksymbol("SQL_SUM"),$<oidval>3,NULL); 
//  SAVE_REF;
//}
;

case_stmt:              CASE scalar_exp when_stmt_list opt_else_stmt END
{
  $<oidval>$ = cons($<oidval>2, $<oidval>3);
  $<oidval>$ = cons($<oidval>1, $<oidval>$);
  $<oidval>$ = nconc($<oidval>$,$<oidval>4,NULL);
  SAVE_REF;
}
|
CASE cond_stmt_list opt_else_stmt END
{
  $<oidval>$ = cons(mksymbol("COND"), $<oidval>2);
  $<oidval>$ = nconc($<oidval>$,$<oidval>3,NULL);
  SAVE_REF;
}
;

when_stmt_list:         when_stmt
{$<oidval>$ = $<oidval>1;}
|      when_stmt_list when_stmt
{
  $<oidval>$ = nconc($<oidval>1,$<oidval>2,NULL);
}

when_stmt:              WHEN scalar_exp THEN scalar_exp
{
  $<oidval>$ = a_list($<oidval>2, $<oidval>4, NULL); 
  SAVE_REF;
}
;

cond_stmt_list:         cond_stmt
{$<oidval>$ = $<oidval>1;}
|      cond_stmt_list cond_stmt
{$<oidval>$ = nconc($<oidval>1,$<oidval>2,NULL);}

cond_stmt:              WHEN comparison_predicate THEN scalar_exp
{
  $<oidval>$ = a_list($<oidval>2, $<oidval>4, NULL); 
  SAVE_REF;
}
;

opt_else_stmt:          /* empty */
{$<oidval>$ = nil;}
|
ELSE scalar_exp
{
  $<oidval>$ = a_list($<oidval>1, $<oidval>2, NULL); 
  SAVE_REF;
}
;

atom:			literal
{$<oidval>$ = $<oidval>1;}
;

column_ref:		//range_variable '.' NAME
//                  {$<oidval>$ = mksymbol(a_list($<oidval>1, '.', $<oidval>3)); SAVE_REF;}
NAME
{
  $<oidval>$ = a_list(mksymbol("COLUMN"), nil, nil, $<oidval>1, NULL);
  SAVE_REF;
}
|
NAME '.' NAME
{
  $<oidval>$ = a_list(mksymbol("COLUMN"), nil, $<oidval>1, $<oidval>3, NULL);
  SAVE_REF;
}
/*                  {$<oidval>$ = call_lisp(mksymbol("pack"),varstack,3,
		    $<oidval>1, mkstring("."),
		    $<oidval>3); SAVE_REF;}
*/
|
NAME '.' NAME '.' NAME
{
  $<oidval>$ = a_list(mksymbol("COLUMN"), $<oidval>1, $<oidval>3,
		      $<oidval>5, NULL);
  SAVE_REF;
}
;


/* search conditions */

search_condition:
search_condition AND search_condition
{
  $<oidval>$ = a_list($<oidval>2,
		      $<oidval>1,$<oidval>3,NULL); 
  SAVE_REF;
}
| search_condition OR search_condition
{
  $<oidval>$ = a_list($<oidval>2,
		      $<oidval>1,$<oidval>3,NULL); 
  SAVE_REF;
}
| NOT search_condition
{
  $<oidval>$ = a_list($<oidval>1,$<oidval>2,NULL); 
  SAVE_REF;
}
| '(' search_condition ')'
{$<oidval>$ = $<oidval>2;}
| predicate
{$<oidval>$ = $<oidval>1;}
;


predicate:		comparison_predicate
{$<oidval>$ = $<oidval>1; }
| existence_test
{$<oidval>$ = $<oidval>1; }
;

comparison_predicate:	scalar_exp comparison scalar_exp
{
  $<oidval>$ = a_list($<oidval>2,$<oidval>1,$<oidval>3,NULL);
  SAVE_REF;
}
|	scalar_exp comparison subquery
{
  $<oidval>$ = a_list($<oidval>2,$<oidval>1,$<oidval>3,NULL);
  SAVE_REF;
}
|
scalar_exp BETWEEN scalar_exp AND scalar_exp
{
  $<oidval>$ = a_list($<oidval>2,$<oidval>1,$<oidval>3,$<oidval>5,NULL);
  SAVE_REF;
}
|
scalar_exp NOT BETWEEN scalar_exp AND scalar_exp
{
  $<oidval>$ = a_list($<oidval>3,$<oidval>1,$<oidval>4,$<oidval>6,NULL);
  $<oidval>$ = a_list($<oidval>2, $<oidval>$, NULL);
  SAVE_REF;
}
| scalar_exp LIKE STRING
{
  char *tmp;
  size_t i;
  tmp = getstring($<oidval>3);
  for (i=0; i<strlen(tmp); i++)
    switch (tmp[i])
      {
      case '%':
	tmp[i]='*';
	break;
      case '_':
	tmp[i]='?';
	break;
      }
  $<oidval>$ = a_list($<oidval>2,$<oidval>1,$<oidval>3,NULL);
  SAVE_REF;
}
| scalar_exp NOT LIKE STRING
{
  char *tmp;
  size_t i;
  tmp = getstring($<oidval>4);
  for (i=0; i<strlen(tmp); i++)
    switch (tmp[i])
      {
      case '%':
	tmp[i]='*';
	break;
      case '_':
	tmp[i]='?';
	break;
      }
  $<oidval>$ = a_list(mksymbol("LIKE_I"),$<oidval>1,$<oidval>4,NULL);
  $<oidval>$ = a_list($<oidval>2, $<oidval>$, NULL);
  SAVE_REF;
}
| scalar_exp _IN '(' scalar_exp_commalist ')'
{
  $<oidval>$ = cons($<oidval>1,reverse($<oidval>4));
  $<oidval>$ = cons($<oidval>2,$<oidval>$);
  SAVE_REF;
}
| scalar_exp NOT _IN '(' scalar_exp_commalist ')'
{
  $<oidval>$ = cons($<oidval>1,reverse($<oidval>5));
  $<oidval>$ = a_list($<oidval>2, cons($<oidval>3,$<oidval>$), NULL);
  SAVE_REF;
}
;

existence_test:		EXISTS subquery
{
  $<oidval>$ = a_list($<oidval>1,$<oidval>2,NULL); 
  SAVE_REF;
}
;

subquery:		'(' select_statement ')' 
{$<oidval>$ = $<oidval>2;} 
;

literal:		STRING
{$<oidval>$ = $<oidval>1;}
|	INTNUM		
{$<oidval>$ = $<oidval>1;}
|	APPROXNUM	
{$<oidval>$ = $<oidval>1;}
;

table:			NAME			
{$<oidval>$ = $<oidval>1;}
|
NAME '.' NAME
{
  $<oidval>$ = cons($<oidval>1, $<oidval>3); 
  SAVE_REF;
}
/* cql stream */
|   NAME '[' window ']'  
{
  $<oidval>$ = a_list($<oidval>1, $<oidval>3, NULL); 
  SAVE_REF;
}
;
            
window:         rows_window
{$<oidval>$ = $<oidval>1;}
|   NOW
{$<oidval>$ = $<oidval>1;}
|   RANGE INTNUM time_unit
{
  $<oidval>$ = a_list($<oidval>1, $<oidval>2, $<oidval>3, NULL); 
  SAVE_REF;
}                  
|   PARTITION BY column_ref_commalist rows_window
{
  $<oidval>$ = a_list($<oidval>1, $<oidval>3, $<oidval>4, NULL); 
  SAVE_REF;
}
;
            
rows_window:    ROWS INTNUM
{
  $<oidval>$ = a_list($<oidval>1, $<oidval>2, NULL); 
  SAVE_REF;
}
;
             
time_unit:      SECONDS 
{$<oidval>$ = $<oidval>1;}
|
MINUTES 
{$<oidval>$ = $<oidval>1;}
;

comparison:		EQ			
{$<oidval>$ = $<oidval>1;}
|	NEQ
{$<oidval>$ = mksymbol("!=");}
|	LT		
{$<oidval>$ = $<oidval>1;}
|	GT		
{$<oidval>$ = $<oidval>1;}
|	LTE		
{$<oidval>$ = $<oidval>1;}
|	GTE		
{$<oidval>$ = $<oidval>1;}
;

