/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1998, 2006 Yu Cao, Tore Risch, UDBL
 * $RCSfile: sparqlParser.y,v $
 * $Revision: 1.11 $ $Date: 2010/04/28 14:46:29 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Bison SparQL parser for AMOS2
 * Generate code by running: bison -p SparQL SparQL_parser.y
 * ===========================================================================
 * $Log: sparqlParser.y,v $
 * Revision 1.11  2010/04/28 14:46:29  fred2431
 * Compile and regression test for SWARD under Linux
 *
 * Revision 1.10  2008/02/22 13:20:53  petrini
 * Removed bugs from code.
 * Added very simple translator from Perl to AmosQL regex used when parsing RDQL and SPARQL queries.
 * Added RDFS classes as rdfs:range for foreign keys.
 * Added parameterized fns for serializing composite key values.
 * Deleting unused files.
 *
 * Revision 1.9  2007/11/27 12:58:12  petrini
 * Removed extern declaration of SparQLrestart.
 * SparQLerror fn is now entry point for all error handling.
 *
 * Revision 1.8  2007/11/26 18:55:51  torer
 * Fixed parser error handling problem
 *
 * Revision 1.7  2007/11/23 13:44:01  petrini
 * Removed calls to SparQLrestart and YYABORT from macro NOT_SUPPORT..
 *
 * Revision 1.6  2007/10/18 09:16:17  petrini
 * Removed some unused files. Fixed some bugs introduced in SparQL parser. Added general error handling to SparQL parser(more specifically of call to UPVOFURI). Removed fn patchSparQL.
 *
 * Revision 1.4  2007/10/05 13:02:13  silvias
 * SPARQL qorks now with DISTINCT
 *
 * Revision 1.3  2007/07/24 05:55:37  petrini
 * *** empty log message ***
 *
 * Revision 1.1  2007/07/23 20:24:16  petrini
 * *** empty log message ***
 *
 * Revision 1.2  2007/06/12 20:05:45  torer
 * Better syntax error messages
 *
 ****************************************************************************/

%{
	#include <math.h>
	#include <string.h>
	#include <malloc.h>
	#include "sparqlMemory.h"
	#include "storage.h"
	#include "sparqlUtils.h"

	extern char *SparQLtext;
	
	int	bInProlog = 1;
	char strTmp[10];
	
	//#define NOT_SUPPORT(a) 	{error_reason(a);YYABORT;}
	#define NOT_SUPPORT(a) 	{SparQLerror(a);}
	#define NOTICE_NOT_SUPPORT(a) 	{SparQLerror(a);}
%}

%union {
	unsigned int			id;
}

/* operators */

%left OR
%left AND

/* comparison */
%left EQ
%left NEQ
%left LT
%left GT
%left LTE
%left GTE

%left '+' '-'
%left '*' '/'

/* literal keyword */
%token _FALSE _TRUE
%token UPUP ANON ASC ASK 
%token BASE BLANK_NODE_LABEL BOUND BY
%token CONSTRUCT
%token DATATYPE DECIMAL DESC DESCRIBE DISTINCT DOUBLE
%token FROM FILTER
%token GRAPH
%token INTEGER IS_BLANK IS_LITERAL IS_IRI IS_URI 
%token LANG LANGMATCHES LANGTAG LIMIT
%token NAMED NCNAME NCNAME_PREFIX_SPC NIL
%token OFFSET OPTIONAL ORDER 
%token PREFIX
%token Q_IRI_REF
%token REGEX
%token SELECT STR STRING_LITERAL12 STRING_LITERAL_LONG1 STRING_LITERAL_LONG2
%token UNION
%token VAR
%token WHERE

%% /* Grammar rules and actions follow */

top: Query |
| error ';'

/*
XXXX? ==> XXXX_Q
XXXX* ==> XXXX_S, XXXX are separated by space
XXXX+ ==> XXXX_P, XXXX are separated by space
XXXX, ... ,XXXX => XXXX_C, XXXX are separated by comma, at least one XXXX
*/

/*[1] Quey*/
Query: 	{bInProlog = 1;}
				Prolog Query_Opt
				{
					/*output_query();*/
					/*help_profile();*/
					/*memory_profile();*/
					/*printf("*** DONE ***\n");*/
				}
;
Query_Opt: SelectQuery
						{}
					| ConstructQuery
						{}
					| DescribeQuery
						{}
					| AskQuery
						{}		
;

/*[2] Prolog*/
Prolog: BaseDecl_Q PrefixDecl_S
					{DBG_PRT("Prolog: BaseDecl_Q PrefixDecl_S\n");bInProlog = 0;}
;

/*[3]Q BaseDecl*/
BaseDecl_Q:	{}
					| BaseDecl
						{}
;						
BaseDecl:	BASE Q_IRI_REF
						{mk_base($<id>2);}
;

/*[4]S PrefixDecl*/
PrefixDecl_S:	/**/
								{}
						| PrefixDecl PrefixDecl_S
								{}
;
PrefixDecl:	PREFIX QNAME_NS Q_IRI_REF
							{mk_prfx($<id>2, $<id>3);}
;

/*[5] SelectQuery*/
SelectQuery:	SELECT Select_Opt1 Select_Opt2 DatasetClause_S WhereClause SolutionModifier
								{
									gQueryVar = $<id>3;					/*vars after 'select'  */
									if (gQueryVar == T_UNKNOWN)
										gQueryVar = amos_query_var();
									gDistinct = $<id>2;
								}
;
Select_Opt1: /**/
							{$<id>$ = T_EMPTY;}
					| DISTINCT
							{$<id>$ = mk_str(" distinct ");}
;
Select_Opt2: Var_P
							{$<id>$ = $<id>1;}
					| '*'
							{$<id>$ = T_UNKNOWN;}
;

/*[6] ConstructQuery*/
ConstructQuery: CONSTRUCT {NOT_SUPPORT("CONSTRUCT");}ConstructTemplate DatasetClause_S WhereClause SolutionModifier
									{}
;

/*[7] DescribeQuery*/
DescribeQuery: DESCRIBE {NOT_SUPPORT("DESCRIBE");}Describe_Opt DatasetClause_S WhereClause_Q SolutionModifier
								{}
;
Describe_Opt: VarOrIRIref_P
								{}
						| '*'
								{}
;

/*[8] AskQuery*/
AskQuery: ASK {NOT_SUPPORT("ASK");}DatasetClause_S WhereClause
						{}
;

/*[9]S DatasetClause*/
DatasetClause_S: /**/
									{$<id>$ = T_EMPTY;}
							| DatasetClause DatasetClause_S
									{}
;
/*Rule handling FROM clause in SparQL query. Added by Johan Petrini*/
DatasetClause:	FROM DatasetClause_opt
                                                                        {
                                                                         gRDF_src[0] = '\0';
                                                                         /*strcat(gRDF_src,"\"");*/
                                                                         strcat(gRDF_src,getstr($<id>2));
                                                                         /*strcat(gRDF_src,"\"");*/}
                                                                          		     
;									
/*Removed by Johan Petrini
DatasetClause:	FROM DatasetClause_opt
									{NOT_SUPPORT("FROM");}
;
*/
									
DatasetClause_opt: DefaultGraphClause
										{}
								| NamedGraphClause
									{}
;
	
/*[10] DefaultGraphClause*/
DefaultGraphClause: SourceSelector
											{}
;

/*[11] NamedGraphClause*/
NamedGraphClause: NAMED SourceSelector
										{NOT_SUPPORT("NAMED");}
;

/*[12] SourceSelector*/
SourceSelector: IRIref
									{}
;

/*[13]Q WhereClause*/
WhereClause_Q: /**/
						|	WhereClause
							{}
;
WhereClause: WhereClause_Opt GroupGraphPattern
							{/*$<id>$ = new_list_and_merge(mk_str("\nwhere"), amos_condition(), T_LST_END);*/}
;
WhereClause_Opt: /**/
							|	WHERE
;

/*[14] SolutionModifier*/
SolutionModifier: OrderClause_Q LimitClause_Q OffsetClause_Q
										{
											$<id>$ = T_EMPTY;
										}
;
	
/*[15]Q OrderClause*/
OrderClause_Q: /**/
						| OrderClause
								{}
;
OrderClause: ORDER BY OrderCondition_P
							{}
;

/*[16]P OrderCondition*/
OrderCondition_P: OrderCondition
										{}
								| OrderCondition OrderCondition_P
										{}
;
					
OrderCondition: ASC '(' VAR ')'
									{mk_ordrinf($<id>3,"\"inc\"");}
							| DESC '(' VAR ')'
									{mk_ordrinf($<id>3,"\"dec\"");}
							| VAR
									{mk_ordrinf($<id>1,"\"inc\"");}
/* The following is original defination
OrderCondition: OrderCondition_Opt BrackettedExpression
									{}
							| FunctionCall
									{}
							| VAR
									{}
;

OrderCondition_Opt:
									|	ASC
									| DESC
;									
*/

/*[17]Q LimitClause*/
LimitClause_Q: /**/
						| LimitClause
								{}
;
LimitClause: LIMIT INTEGER
							{set_limit(SparQLtext);}
;
	
/*[18]Q OffsetClause*/
OffsetClause_Q: /**/
						| OffsetClause
								{}
;
OffsetClause: OFFSET INTEGER
							{set_offset(SparQLtext);}
;

/*[19] GroupGraphPattern*/
GroupGraphPattern: '{' GraphPattern '}'
											{}
;

/*[20] GraphPattern*/
GraphPattern: FilteredBasicGraphPattern GraphPattern_Opt
								{}
;
GraphPattern_Opt: /**/
										{DBG_PRT("-- Empty GraphPattern_Opt\n");}
								|	GraphPatternNotTriples '.' GraphPattern
										{}
								| GraphPatternNotTriples GraphPattern
										{}
;

/*[21] FilteredBasicGraphPattern*/
FilteredBasicGraphPattern: BlockOfTriples_Q FilteredBasicGraphPattern_Opt
														{}
;
FilteredBasicGraphPattern_Opt: /**/
																{DBG_PRT("-- Empty FilteredBasicGraphPattern_Opt\n");}
														| Constraint '.' FilteredBasicGraphPattern
																{}
														| Constraint FilteredBasicGraphPattern
																{}
;

/*[22]Q BlockOfTriples*/
BlockOfTriples_Q: /**/
										{DBG_PRT("-- Empty BlockOfTriples_Q\n");}
								| BlockOfTriples
										{DBG_PRT("-- BlockOfTriples_Q\n");}
;
BlockOfTriples: TriplesSameSubject BlockOfTriples_Opt
									{}
;
BlockOfTriples_Opt: /**/
										{DBG_PRT("-- Empty BlockOfTriples_Opt\n");}
								| '.' TriplesSameSubject_Q BlockOfTriples_Opt
										{DBG_PRT("-- BlockOfTriples_Opt\n");}
;

/*[23] GraphPatternNotTriples*/
GraphPatternNotTriples: OptionalGraphPattern
													{}
											| GroupOrUnionGraphPattern
													{}
											| GraphGraphPattern
													{}
;

/*[24] OptionalGraphPattern*/
OptionalGraphPattern: OPTIONAL 
												{
													NOTICE_NOT_SUPPORT("Optional");
													if (in_opt()) NOT_SUPPORT("Nested Optional"); 
													enter_opt();
												} GroupGraphPattern
												{leave_opt();}
;

/*[25] GraphGraphPattern*/
GraphGraphPattern: GRAPH VarOrBlankNodeOrIRIref GroupGraphPattern
										{NOT_SUPPORT("GRAPH");}
;

/*[26] GroupOrUnionGraphPattern*/
GroupOrUnionGraphPattern: GroupGraphPattern
														{}
												| GroupGraphPattern UNION GroupOrUnionGraphPattern
														{NOT_SUPPORT("UNION");}
;

/*[27] Constraint*/
Constraint: FILTER Constraint_Opt
							{mk_fltr($<id>2,get_opt());}
;
Constraint_Opt: BrackettedExpression
									{
										$<id>$ = $<id>1;
									}
							| BuiltInCall
									{$<id>$ = $<id>1;}
							| FunctionCall
									{NOT_SUPPORT("FunctionCall");}
;

/*[28] FunctionCall*/
FunctionCall: IRIref ArgList
								{}
;

/*[29] ArgList*/
ArgList: NIL
					{}
			| '(' Expression_C ')'
					{}
;

/*[30] ConstructTemplate*/
ConstructTemplate: '{' ConstructTriples '}'
											{}
;

/*[31] ConstructTriples*/
ConstructTriples: /**/
								| ConstructTriples_Help
										{}
;
ConstructTriples_Help: TriplesSameSubject
												{}
										| TriplesSameSubject '.' ConstructTriples_Help
												{}
;

/*[32]Q TriplesSameSubject*/
TriplesSameSubject_Q: /**/
										| TriplesSameSubject
												{}
TriplesSameSubject: VarOrTerm PropertyListNotEmpty
											{
												if (mk_tpl($<id>1, $<id>2, get_opt())!=0)
												{	NOTICE_NOT_SUPPORT("OPTIONAL");}
												DBG_PRT("-- TriplesSameSubject 1\n");
											}
									| TriplesNode PropertyList
											{
												if (mk_tpl($<id>1, $<id>2, get_opt())!=0)
												{	NOTICE_NOT_SUPPORT("OPTIONAL");}
												DBG_PRT("-- TriplesSameSubject 2\n");
											}
;
/*[33] PropertyList*/
PropertyList: /**/
								{$<id>$ = mk_lst();}
						| PropertyListNotEmpty
								{$<id>$ = $<id>1;}
;

/*[34] PropertyListNotEmpty*/
PropertyListNotEmpty: Verb ObjectList
												{
													$<id>$ = new_list_and_merge($<id>1, $<id>2, T_LST_END);
												}
										| Verb ObjectList ';' PropertyList
												{
													/*$<id>1 will be the first node in list $<id>4*/
													append_to_list_front($<id>4, $<id>2, $<id>1, T_LST_END);
													$<id>$ = $<id>4;
												}
;

/*[35] ObjectList*/
ObjectList: GraphNode
							{$<id>$ = new_list_and_merge($<id>1, T_LST_END);}
					| GraphNode ',' ObjectList
							{
								append_to_list_front($<id>3, $<id>1, T_LST_END);
								$<id>$ = $<id>3;
							}
;

/*[36] Verb*/
Verb: VarOrIRIref
				{
					DBG_PRT("-- Verb VarOrIRIref 0x%.8X\n", $<id>1);
					$<id>$ = $<id>1;
				}
		| 'a'
				{$<id>$ = mk_iri("http://www.w3.org/1999/02/22-rdf-syntax-ns#type");}
;

/*[37] TriplesNode*/
TriplesNode: Collection
							{}
					| BlankNodePropertyList
							{$<id>$ = $<id>1;}
;

/*[38] BlankNodePropertyList*/
BlankNodePropertyList: '[' PropertyListNotEmpty ']'
													{
														$<id>$ = mk_bkv();
														if (mk_tpl($<id>$, $<id>2, get_opt()))
														{	/*NOT_SUPPORT("OPTIONAL");*/}
														DBG_PRT("-- BlankNodePropertyList\n");
													}
;

/*[39] Collection*/
Collection: '(' GraphNode_P ')'
;

/*[40]P GraphNode*/
GraphNode_P: GraphNode
							{}
					| GraphNode GraphNode_P
							{}
;
GraphNode: VarOrTerm
						{
							$<id>$ = $<id>1;
							DBG_PRT("-- GraphNode VarOrTerm\n");
						}
				| TriplesNode
						{
							$<id>$ = $<id>1;
							DBG_PRT("-- GraphNode TriplesNode\n");
						}
;

/*[41] VarOrTerm*/
VarOrTerm: VAR
						{
							DBG_PRT("-- VarOrTerm VAR\n"); 
							$<id>$ = $<id>1;
						}							
				| GraphTerm
						{
							DBG_PRT("-- VarOrTerm GraphTerm\n");
							$<id>$ = $<id>1;
						}
;

/*[42]P VarOrIRIref*/
VarOrIRIref_P: VarOrIRIref
								{}
						| VarOrIRIref VarOrIRIref_P
								{}
;
VarOrIRIref: VAR
							{
								DBG_PRT("-- VarOrIRIref VAR 0x%.8X\n", $<id>1);
								$<id>$ = $<id>1;
							}
					| BlankNode
							{
								$<id>$ = $<id>1;
								DBG_PRT("-- VarOrIRIref BlankNode\n");
							}
					| IRIref
							{
								DBG_PRT("-- VarOrIRIref IRIref 0x%.8X\n", $<id>1);
								$<id>$ = $<id>1;
							}
;

/*[43] VarOrBlankNodeOrIRIref*/
VarOrBlankNodeOrIRIref: VAR
													{}
											| BlankNode
													{}
											| IRIref
													{}
;

/*[44]P Var*/
Var_P: VAR
				{
					DBG_PRT("-- Var_P : VAR\n");
					$<id>$ = new_list_and_merge($<id>1, T_LST_END);
				}
		| VAR Var_P
				{
					DBG_PRT("-- Var_P : VAR Var_P\n");
					append_to_list_front($<id>2, gComma, $<id>1, T_LST_END);
					$<id>$ = $<id>2;
				}
;

/*[45] GraphTerm*/
GraphTerm: IRIref
						{
							DBG_PRT("-- GraphTerm IRIref 0x%.8X\n", $<id>1);
							$<id>$ = $<id>1;
						}
				| RDFLiteral
						{DBG_PRT("-- GraphTerm RDFLiteral\n");}
				| GraphTerm_Opt NumericLiteral
						{
							DBG_PRT("-- GraphTerm GraphTerm_Opt\n");
							if ($<id>1 == 0)
								$<id>$ = $<id>2;
						}
				| BooleanLiteral
						{DBG_PRT("-- GraphTerm BooleanLiteral\n");}
				| BlankNode
						{
							$<id>$ = $<id>1;
							DBG_PRT("-- GraphTerm BlankNode\n");
						}
				| NIL
						{DBG_PRT("-- GraphTerm NIL\n");}
;
GraphTerm_Opt: /**/
							{$<id>$ = 0;}
						| '+'
							{$<id>$ = '+';}
						| '-'
							{$<id>$ = '-';}
;

/*[46]C Expression*/
Expression_C: Expression
								{}
						| Expression ',' Expression_C
								{}
;
Expression: ConditionalOrExpression
							{$<id>$ = $<id>1;}
;

/*[47] ConditionalOrExpression*/
ConditionalOrExpression: ConditionalAndExpression
													{$<id>$=$<id>1;}
											| ConditionalAndExpression OR ConditionalOrExpression
													{$<id>$ = new_list_and_merge(
														mk_str("l_o("),$<id>1,gComma,$<id>3,gCloseB,T_LST_END);}
;

/*[48] ConditionalAndExpression*/
ConditionalAndExpression: ValueLogical
														{$<id>$=$<id>1;}
												| ValueLogical AND ConditionalAndExpression
														{$<id>$ = new_list_and_merge(
															mk_str("l_a("),$<id>1,gComma,$<id>3,gCloseB,T_LST_END);}
;

/*[49] ValueLogical*/
ValueLogical: RelationalExpression
								{$<id>$ = $<id>1;}
;

/*[50] RelationalExpression*/
RelationalExpression: NumericExpression
												{$<id>$ = $<id>1;}
									| NumericExpression EQ NumericExpression
										{$<id>$ = new_list_and_merge(mk_str("EQ("),$<id>1,gComma,$<id>3,gCloseB,T_LST_END);}
									| NumericExpression NEQ NumericExpression
										{$<id>$ = new_list_and_merge(mk_str("NEQ("),$<id>1,gComma,$<id>3,gCloseB,T_LST_END);}
									| NumericExpression LT NumericExpression
										{$<id>$ = new_list_and_merge(mk_str("LT("),$<id>1,gComma,$<id>3,gCloseB,T_LST_END);}
									| NumericExpression GT NumericExpression
										{$<id>$ = new_list_and_merge(mk_str("GT("),$<id>1,gComma,$<id>3,gCloseB,T_LST_END);}
									| NumericExpression LTE NumericExpression
										{$<id>$ = new_list_and_merge(mk_str("LTE("),$<id>1,gComma,$<id>3,gCloseB,T_LST_END);}
									| NumericExpression GTE NumericExpression
										{$<id>$ = new_list_and_merge(mk_str("GTE("),$<id>1,gComma,$<id>3,gCloseB,T_LST_END);}
;

/*[51] NumericExpression*/
NumericExpression: AdditiveExpression
										{$<id>$ = $<id>1;}
;

/*[52] AdditiveExpression*/
AdditiveExpression: MultiplicativeExpression
										{$<id>$ = $<id>1;}
								| MultiplicativeExpression '+' AdditiveExpression
										{$<id>$ = new_list_and_merge(
											$<id>1,mk_str("+"),$<id>3,T_LST_END);}
								| MultiplicativeExpression '-' AdditiveExpression
										{$<id>$ = new_list_and_merge(
											$<id>1,mk_str("-"),$<id>3,T_LST_END);}
;

/*[53] MultiplicativeExpression*/
MultiplicativeExpression: UnaryExpression
														{$<id>$ = $<id>1;}
											| UnaryExpression '*' MultiplicativeExpression
													{$<id>$ = new_list_and_merge(
														$<id>1,mk_str("*"),$<id>3,T_LST_END);}
											| UnaryExpression '/' MultiplicativeExpression
													{$<id>$ = new_list_and_merge(
														$<id>1,mk_str("/"),$<id>3,T_LST_END);}
;

/*[54] UnaryExpression*/
UnaryExpression: PrimaryExpression
									{$<id>$ = $<id>1;}
							| '!' PrimaryExpression
									{$<id>$ = new_list_and_merge(mk_str("fn_not("),$<id>2,gCloseB,T_LST_END);}
							| '+' PrimaryExpression
									{$<id>$ = $<id>1;}
							| '-' PrimaryExpression
									{$<id>$ = new_list_and_merge(mk_str("fn_neg("),$<id>2,gCloseB,T_LST_END);}
;

/*[55] PrimaryExpression*/
/*Modified by Johan Petrini 07-06-07. Removed call to uri().*/
PrimaryExpression: BrackettedExpression
										{$<id>$=$<id>1;}
								| BuiltInCall
										{$<id>$=$<id>1;}
								| IRIrefOrFunction
										{$<id>$=new_list_and_merge(mk_str("\""),$<id>1,mk_str("\""),T_LST_END);}
								| RDFLiteral
										{$<id>$=$<id>1;}
								| NumericLiteral
									{$<id>$=$<id>1;}
								| BooleanLiteral
										{$<id>$=$<id>1;}
								| BlankNode
										{}
								| VAR
										{$<id>$=$<id>1;}
;

/*[56] BrackettedExpression*/
BrackettedExpression: '(' Expression ')'
												{$<id>$ = new_list_and_merge(mk_str("("),$<id>2,gCloseB,T_LST_END);}
;

/*[57] BuiltInCall*/
BuiltInCall: STR '(' Expression ')'
							{$<id>$ = new_list_and_merge(mk_str("STR("),$<id>3,gCloseB,T_LST_END);}
					| LANG '(' Expression ')'
							{$<id>$ = new_list_and_merge(mk_str("LANG("),$<id>3,gCloseB,T_LST_END);}
					| LANGMATCHES '(' Expression ',' Expression ')'
							{$<id>$ = new_list_and_merge(mk_str("langMatches("),$<id>3,
										gComma,$<id>5,gCloseB,T_LST_END);}
					| DATATYPE '(' Expression ')'
							{$<id>$ = new_list_and_merge(
							mk_str("DT("),$<id>3,mk_str(")"),T_LST_END);}
					| BOUND  '(' VAR ')' 
							{NOT_SUPPORT("function BOUND");}
					| IS_IRI '(' Expression ')'
							{$<id>$ = new_list_and_merge(mk_str("isIRI("),$<id>3,gCloseB,T_LST_END);}
					| IS_URI '(' Expression ')'
							{$<id>$ = new_list_and_merge(mk_str("isIRI("),$<id>3,gCloseB,T_LST_END);}
					| IS_BLANK '(' Expression ')'
							{$<id>$ = new_list_and_merge(mk_str("isBlnk("),$<id>3,gCloseB,T_LST_END);}
					| IS_LITERAL '(' Expression ')'
							{$<id>$ = new_list_and_merge(mk_str("isLtrl("),$<id>3,gCloseB,T_LST_END);}
					| RegexExpression
							{}
;

/*[58] RegexExpression*/

/*Modified by Johan Petrini 07-06-07. Added handling of regular expressions*/
RegexExpression: REGEX '(' Expression ',' Expression ')'
                                                          {$<id>$ = new_list_and_merge(mk_str("like("),$<id>3,
										gComma,mk_str("areg("),$<id>5,mk_str(")"),gCloseB,T_LST_END);}
;


                                                           
/*[59] IRIrefOrFunction*/
IRIrefOrFunction: IRIref
										{$<id>$=$<id>1;}
								| IRIref ArgList
										{NOT_SUPPORT("IRI(...)");}
;
/*[60] RDFLiteral*/
RDFLiteral: String
							{$<id>$=mk_plain_ltr($<id>1, NULL);}
					| String LANGTAG
							{$<id>$=mk_plain_ltr($<id>1, SparQLtext);}
					| String UPUP IRIref
							{$<id>$=mk_ltr2($<id>1, $<id>3);}
;

/*[61] NumericLiteral*/
NumericLiteral: INTEGER
									{$<id>$ = mk_ltr(SparQLtext,L_INT);}
							| DECIMAL
									{$<id>$ = mk_ltr(SparQLtext,L_DEC);}
							| DOUBLE
									{$<id>$ = mk_ltr(SparQLtext,L_DBL);}
;

/*[62] BooleanLiteral*/
BooleanLiteral: _TRUE
									{$<id>$ = mk_ltr(SparQLtext,L_BOOL);}
							| _FALSE
									{$<id>$ = mk_ltr(SparQLtext,L_BOOL);}
;

/*[63] String*/
String: STRING_LITERAL12
					{$<id>$ = $<id>1;}
			| STRING_LITERAL_LONG1
					{}
			| STRING_LITERAL_LONG2
					{}
;

/*[64] IRIref*/
IRIref: Q_IRI_REF
					{$<id>$ = $<id>1;}
			| QName
					{$<id>$ = $<id>1;}
;

/*[65] QName*/
QName: QNAME_NS
				{$<id>$ = get_prfx_uri($<id>1);}
		| QNAME_NS NCNAME
				{$<id>$ = map_prfx_uri($<id>1, SparQLtext);}
		| QNAME_NS 'a'
				{$<id>$ = map_prfx_uri($<id>1, "a");}
;

/*[66] BlankNode*/
BlankNode: BLANK_NODE_LABEL
						{NOT_SUPPORT("BLANK_NODE_LABEL");}
				| ANON
						{$<id>$=mk_bkv();}
;

/*[67] Q_IRI_REF*/
/* In SparQL_lexer.l */

/*[68] QNAME_NS*/
QNAME_NS: ':'
						{
							if (bInProlog) 
								$<id>$ = mk_str(":");
							else
								$<id>$ = find_prfx(":");
						}
				| NCNAME_PREFIX_SPC
						{
							if (bInProlog)
								$<id>$ = mk_str(SparQLtext);
							else
								$<id>$ = find_prfx(SparQLtext);
						}
;

/*[69] QNAME*/
/*I changed the Official design, which seems to have a flaw*/


/***********************************
	Read SparQL_lexer.l for reference
   *Unsolved problem with unicode* 
 ***********************************/
/*[70] BLANK_NODE_LABEL*/
/*[71] VAR1*/
/*[72] VAR2*/
/*[73] LANGTAG*/
/*[74] INTEGER*/
/*[75] DECIMAL*/
/*[76] DOUBLE*/
/*[77] EXPONENT*/
/*[78] STRING_LITERAL1*/
/*[79] STRING_LITERAL2*/
/*[80] STRING_LITERAL_LONG1*/
/*[81] STRING_LITERAL_LONG2*/
/*[82] ECHAR*/
/*[83] UCHAR*/
/*[84] HEX*/
/*[85] NIL*/
/*[86] WS*/
/*[87] ANON*/
/*[88] NCCHAR1p*/
/*[89] NCCHAR1*/
/*[90] VARNAME*/
/*[91] NCCHAR*/
/*[92] NCNAME_PREFIX*/
/*[93] NCNAME*/

%%


