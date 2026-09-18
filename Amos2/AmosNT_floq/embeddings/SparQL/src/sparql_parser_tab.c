
/*  A Bison parser, made from sparql_parser.y with Bison version GNU Bison version 1.24
  */

#define YYBISON 1  /* Identify Bison output.  */

#define yyparse SparQLparse
#define yylex SparQLlex
#define yyerror SparQLerror
#define yylval SparQLlval
#define yychar SparQLchar
#define yydebug SparQLdebug
#define yynerrs SparQLnerrs
#define	OR	258
#define	AND	259
#define	EQ	260
#define	NEQ	261
#define	LT	262
#define	GT	263
#define	LTE	264
#define	GTE	265
#define	_FALSE	266
#define	_TRUE	267
#define	UPUP	268
#define	ANON	269
#define	ASC	270
#define	ASK	271
#define	BASE	272
#define	BLANK_NODE_LABEL	273
#define	BOUND	274
#define	BY	275
#define	CONSTRUCT	276
#define	DATATYPE	277
#define	DECIMAL	278
#define	DESC	279
#define	DESCRIBE	280
#define	DISTINCT	281
#define	DOUBLE	282
#define	FROM	283
#define	FILTER	284
#define	GRAPH	285
#define	INTEGER	286
#define	IS_BLANK	287
#define	IS_LITERAL	288
#define	IS_IRI	289
#define	IS_URI	290
#define	LANG	291
#define	LANGMATCHES	292
#define	LANGTAG	293
#define	LIMIT	294
#define	NAMED	295
#define	NCNAME	296
#define	NCNAME_PREFIX_SPC	297
#define	NIL	298
#define	OFFSET	299
#define	OPTIONAL	300
#define	ORDER	301
#define	PREFIX	302
#define	Q_IRI_REF	303
#define	REGEX	304
#define	SELECT	305
#define	STR	306
#define	STRING_LITERAL12	307
#define	STRING_LITERAL_LONG1	308
#define	STRING_LITERAL_LONG2	309
#define	UNION	310
#define	VAR	311
#define	WHERE	312

#line 12 "sparql_parser.y"

	#include <math.h>
	#include <string.h>
	#include "sparql_memory.h"
	#include "sparql_help.h"
	#include "..\..\..\wrappers\CRDF\src\rdf_reader.h"

	extern char *SparQLtext;
	
	int	bInProlog = 1;
	char strTmp[10];
	
	extern void SparQLrestart();
	#define NOT_SUPPORT(a) 	{error_reason(a);SparQLrestart();YYABORT;}
	#define NOTICE_NOT_SUPPORT(a) 	{error_reason(a);}

#line 29 "sparql_parser.y"
typedef union {
	unsigned int			id;
} YYSTYPE;

#ifndef YYLTYPE
typedef
  struct yyltype
    {
      int timestamp;
      int first_line;
      int first_column;
      int last_line;
      int last_column;
      char *text;
   }
  yyltype;

#define YYLTYPE yyltype
#endif

#include <stdio.h>

#ifndef __cplusplus
#ifndef __STDC__
#define const
#endif
#endif



#define	YYFINAL		305
#define	YYFLAG		-32768
#define	YYNTBASE	74

#define YYTRANSLATE(x) ((unsigned)(x) <= 312 ? yytranslate[x] : 171)

static const char yytranslate[] = {     0,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,    72,     2,     2,     2,     2,     2,     2,    62,
    63,    13,    11,    68,    12,    66,    14,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,    73,    67,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
    70,     2,    71,     2,     2,     2,    69,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,    64,     2,    65,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     1,     2,     3,     4,     5,
     6,     7,     8,     9,    10,    15,    16,    17,    18,    19,
    20,    21,    22,    23,    24,    25,    26,    27,    28,    29,
    30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
    40,    41,    42,    43,    44,    45,    46,    47,    48,    49,
    50,    51,    52,    53,    54,    55,    56,    57,    58,    59,
    60,    61
};

#if YYDEBUG != 0
static const short yyprhs[] = {     0,
     0,     1,     5,     7,     9,    11,    13,    16,    17,    19,
    22,    23,    26,    30,    37,    38,    40,    42,    44,    45,
    52,    53,    60,    62,    64,    65,    70,    71,    74,    77,
    79,    81,    83,    86,    88,    89,    91,    94,    95,    97,
   101,   102,   104,   108,   110,   113,   118,   123,   125,   126,
   128,   131,   132,   134,   137,   141,   144,   145,   149,   152,
   155,   156,   160,   163,   164,   166,   169,   170,   174,   176,
   178,   180,   181,   185,   189,   191,   195,   198,   200,   202,
   204,   207,   209,   213,   217,   218,   220,   222,   226,   227,
   229,   232,   235,   236,   238,   241,   246,   248,   252,   254,
   256,   258,   260,   264,   268,   270,   273,   275,   277,   279,
   281,   283,   286,   288,   290,   292,   294,   296,   298,   300,
   303,   305,   307,   310,   312,   314,   316,   317,   319,   321,
   323,   327,   329,   331,   335,   337,   341,   343,   345,   349,
   353,   357,   361,   365,   369,   371,   373,   377,   381,   383,
   387,   391,   393,   396,   399,   402,   404,   406,   408,   410,
   412,   414,   416,   418,   422,   427,   432,   439,   444,   449,
   454,   459,   464,   469,   471,   478,   480,   483,   485,   488,
   492,   494,   496,   498,   500,   502,   504,   506,   508,   510,
   512,   514,   517,   520,   522,   524,   526
};

static const short yyrhs[] = {    -1,
    75,    77,    76,     0,    82,     0,    85,     0,    87,     0,
    90,     0,    78,    80,     0,     0,    79,     0,    21,    52,
     0,     0,    81,    80,     0,    51,   170,    52,     0,    54,
    83,    84,    92,    99,   101,     0,     0,    30,     0,   145,
     0,    13,     0,     0,    25,    86,   127,    92,    99,   101,
     0,     0,    29,    88,    89,    92,    98,   101,     0,   142,
     0,    13,     0,     0,    20,    91,    92,    99,     0,     0,
    93,    92,     0,    32,    94,     0,    95,     0,    96,     0,
    97,     0,    44,    97,     0,   167,     0,     0,    99,     0,
   100,   110,     0,     0,    61,     0,   102,   106,   108,     0,
     0,   103,     0,    50,    24,   104,     0,   105,     0,   105,
   104,     0,    19,    62,    60,    63,     0,    28,    62,    60,
    63,     0,    60,     0,     0,   107,     0,    43,    35,     0,
     0,   109,     0,    48,    35,     0,    64,   111,    65,     0,
   113,   112,     0,     0,   118,    66,   111,     0,   118,   111,
     0,   115,   114,     0,     0,   123,    66,   113,     0,   123,
   113,     0,     0,   116,     0,   131,   117,     0,     0,    66,
   130,   117,     0,   119,     0,   122,     0,   121,     0,     0,
    49,   120,   110,     0,    34,   144,   110,     0,   110,     0,
   110,    59,   122,     0,    33,   124,     0,   159,     0,   160,
     0,   125,     0,   167,   126,     0,    47,     0,    62,   148,
    63,     0,    64,   128,    65,     0,     0,   129,     0,   131,
     0,   131,    66,   129,     0,     0,   131,     0,   141,   133,
     0,   136,   132,     0,     0,   133,     0,   135,   134,     0,
   135,   134,    67,   132,     0,   140,     0,   140,    68,   134,
     0,   143,     0,    69,     0,   138,     0,   137,     0,    70,
   133,    71,     0,    62,   139,    63,     0,   140,     0,   140,
   139,     0,   141,     0,   136,     0,    60,     0,   146,     0,
   143,     0,   143,   142,     0,    60,     0,   169,     0,   167,
     0,    60,     0,   169,     0,   167,     0,    60,     0,    60,
   145,     0,   167,     0,   163,     0,   147,   164,     0,   165,
     0,   169,     0,    47,     0,     0,    11,     0,    12,     0,
   149,     0,   149,    68,   148,     0,   150,     0,   151,     0,
   151,     3,   150,     0,   152,     0,   152,     4,   151,     0,
   153,     0,   154,     0,   154,     5,   154,     0,   154,     6,
   154,     0,   154,     7,   154,     0,   154,     8,   154,     0,
   154,     9,   154,     0,   154,    10,   154,     0,   155,     0,
   156,     0,   156,    11,   155,     0,   156,    12,   155,     0,
   157,     0,   157,    13,   156,     0,   157,    14,   156,     0,
   158,     0,    72,   158,     0,    11,   158,     0,    12,   158,
     0,   159,     0,   160,     0,   162,     0,   163,     0,   164,
     0,   165,     0,   169,     0,    60,     0,    62,   149,    63,
     0,    55,    62,   149,    63,     0,    40,    62,   149,    63,
     0,    41,    62,   149,    68,   149,    63,     0,    26,    62,
   149,    63,     0,    23,    62,    60,    63,     0,    38,    62,
   149,    63,     0,    39,    62,   149,    63,     0,    36,    62,
   149,    63,     0,    37,    62,   149,    63,     0,   161,     0,
    53,    62,   149,    68,   149,    63,     0,   167,     0,   167,
   126,     0,   166,     0,   166,    42,     0,   166,    17,   167,
     0,    35,     0,    27,     0,    31,     0,    16,     0,    15,
     0,    56,     0,    57,     0,    58,     0,    52,     0,   168,
     0,   170,     0,   170,    45,     0,   170,    69,     0,    22,
     0,    18,     0,    73,     0,    46,     0
};

#endif

#if YYDEBUG != 0
static const short yyrline[] = { 0,
    79,    80,    88,    90,    92,    94,    99,   104,   105,   108,
   113,   115,   118,   123,   131,   133,   136,   138,   143,   143,
   148,   148,   151,   153,   158,   158,   163,   165,   169,   183,
   185,   190,   195,   200,   205,   206,   209,   212,   213,   217,
   224,   225,   228,   233,   235,   239,   241,   243,   261,   262,
   265,   270,   271,   274,   279,   284,   287,   289,   291,   296,
   299,   301,   303,   308,   310,   313,   316,   318,   323,   325,
   327,   332,   338,   342,   347,   349,   354,   357,   361,   363,
   368,   373,   375,   380,   385,   386,   389,   391,   396,   397,
   399,   405,   413,   415,   420,   424,   433,   435,   443,   448,
   453,   455,   460,   470,   474,   476,   479,   484,   492,   497,
   505,   507,   510,   515,   520,   528,   530,   532,   537,   542,
   551,   556,   558,   564,   566,   571,   574,   576,   578,   583,
   585,   588,   593,   595,   601,   603,   609,   614,   616,   618,
   620,   622,   624,   626,   631,   636,   638,   641,   647,   649,
   652,   658,   660,   662,   664,   669,   671,   673,   675,   677,
   679,   681,   683,   689,   694,   696,   698,   701,   704,   706,
   708,   710,   712,   714,   721,   736,   738,   742,   744,   746,
   751,   753,   755,   760,   762,   767,   769,   771,   776,   778,
   783,   785,   787,   792,   794,   802,   809
};

static const char * const yytname[] = {   "$","error","$undefined.","OR","AND",
"EQ","NEQ","LT","GT","LTE","GTE","'+'","'-'","'*'","'/'","_FALSE","_TRUE","UPUP",
"ANON","ASC","ASK","BASE","BLANK_NODE_LABEL","BOUND","BY","CONSTRUCT","DATATYPE",
"DECIMAL","DESC","DESCRIBE","DISTINCT","DOUBLE","FROM","FILTER","GRAPH","INTEGER",
"IS_BLANK","IS_LITERAL","IS_IRI","IS_URI","LANG","LANGMATCHES","LANGTAG","LIMIT",
"NAMED","NCNAME","NCNAME_PREFIX_SPC","NIL","OFFSET","OPTIONAL","ORDER","PREFIX",
"Q_IRI_REF","REGEX","SELECT","STR","STRING_LITERAL12","STRING_LITERAL_LONG1",
"STRING_LITERAL_LONG2","UNION","VAR","WHERE","'('","')'","'{'","'}'","'.'","';'",
"','","'a'","'['","']'","'!'","':'","Query","@1","Query_Opt","Prolog","BaseDecl_Q",
"BaseDecl","PrefixDecl_S","PrefixDecl","SelectQuery","Select_Opt1","Select_Opt2",
"ConstructQuery","@2","DescribeQuery","@3","Describe_Opt","AskQuery","@4","DatasetClause_S",
"DatasetClause","DatasetClause_opt","DefaultGraphClause","NamedGraphClause",
"SourceSelector","WhereClause_Q","WhereClause","WhereClause_Opt","SolutionModifier",
"OrderClause_Q","OrderClause","OrderCondition_P","OrderCondition","LimitClause_Q",
"LimitClause","OffsetClause_Q","OffsetClause","GroupGraphPattern","GraphPattern",
"GraphPattern_Opt","FilteredBasicGraphPattern","FilteredBasicGraphPattern_Opt",
"BlockOfTriples_Q","BlockOfTriples","BlockOfTriples_Opt","GraphPatternNotTriples",
"OptionalGraphPattern","@5","GraphGraphPattern","GroupOrUnionGraphPattern","Constraint",
"Constraint_Opt","FunctionCall","ArgList","ConstructTemplate","ConstructTriples",
"ConstructTriples_Help","TriplesSameSubject_Q","TriplesSameSubject","PropertyList",
"PropertyListNotEmpty","ObjectList","Verb","TriplesNode","BlankNodePropertyList",
"Collection","GraphNode_P","GraphNode","VarOrTerm","VarOrIRIref_P","VarOrIRIref",
"VarOrBlankNodeOrIRIref","Var_P","GraphTerm","GraphTerm_Opt","Expression_C",
"Expression","ConditionalOrExpression","ConditionalAndExpression","ValueLogical",
"RelationalExpression","NumericExpression","AdditiveExpression","MultiplicativeExpression",
"UnaryExpression","PrimaryExpression","BrackettedExpression","BuiltInCall","RegexExpression",
"IRIrefOrFunction","RDFLiteral","NumericLiteral","BooleanLiteral","String","IRIref",
"QName","BlankNode","QNAME_NS",""
};
#endif

static const short yyr1[] = {     0,
    75,    74,    76,    76,    76,    76,    77,    78,    78,    79,
    80,    80,    81,    82,    83,    83,    84,    84,    86,    85,
    88,    87,    89,    89,    91,    90,    92,    92,    93,    94,
    94,    95,    96,    97,    98,    98,    99,   100,   100,   101,
   102,   102,   103,   104,   104,   105,   105,   105,   106,   106,
   107,   108,   108,   109,   110,   111,   112,   112,   112,   113,
   114,   114,   114,   115,   115,   116,   117,   117,   118,   118,
   118,   120,   119,   121,   122,   122,   123,   124,   124,   124,
   125,   126,   126,   127,   128,   128,   129,   129,   130,   130,
   131,   131,   132,   132,   133,   133,   134,   134,   135,   135,
   136,   136,   137,   138,   139,   139,   140,   140,   141,   141,
   142,   142,   143,   143,   143,   144,   144,   144,   145,   145,
   146,   146,   146,   146,   146,   146,   147,   147,   147,   148,
   148,   149,   150,   150,   151,   151,   152,   153,   153,   153,
   153,   153,   153,   153,   154,   155,   155,   155,   156,   156,
   156,   157,   157,   157,   157,   158,   158,   158,   158,   158,
   158,   158,   158,   159,   160,   160,   160,   160,   160,   160,
   160,   160,   160,   160,   161,   162,   162,   163,   163,   163,
   164,   164,   164,   165,   165,   166,   166,   166,   167,   167,
   168,   168,   168,   169,   169,   170,   170
};

static const short yyr2[] = {     0,
     0,     3,     1,     1,     1,     1,     2,     0,     1,     2,
     0,     2,     3,     6,     0,     1,     1,     1,     0,     6,
     0,     6,     1,     1,     0,     4,     0,     2,     2,     1,
     1,     1,     2,     1,     0,     1,     2,     0,     1,     3,
     0,     1,     3,     1,     2,     4,     4,     1,     0,     1,
     2,     0,     1,     2,     3,     2,     0,     3,     2,     2,
     0,     3,     2,     0,     1,     2,     0,     3,     1,     1,
     1,     0,     3,     3,     1,     3,     2,     1,     1,     1,
     2,     1,     3,     3,     0,     1,     1,     3,     0,     1,
     2,     2,     0,     1,     2,     4,     1,     3,     1,     1,
     1,     1,     3,     3,     1,     2,     1,     1,     1,     1,
     1,     2,     1,     1,     1,     1,     1,     1,     1,     2,
     1,     1,     2,     1,     1,     1,     0,     1,     1,     1,
     3,     1,     1,     3,     1,     3,     1,     1,     3,     3,
     3,     3,     3,     3,     1,     1,     3,     3,     1,     3,
     3,     1,     2,     2,     2,     1,     1,     1,     1,     1,
     1,     1,     1,     3,     4,     4,     6,     4,     4,     4,
     4,     4,     4,     1,     6,     1,     2,     1,     2,     3,
     1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
     1,     2,     2,     1,     1,     1,     1
};

static const short yydefact[] = {     1,
     8,     0,     0,    11,     9,    10,    25,    19,    21,    15,
     2,     3,     4,     5,     6,     0,     7,    11,    27,     0,
     0,    16,     0,   197,   196,     0,    12,     0,    38,    27,
   127,    27,    24,   195,   194,   189,   113,    27,    23,   111,
   115,   190,   114,   191,    18,   119,    27,    17,    13,     0,
    29,    30,    31,    32,    34,    39,    26,     0,    28,   128,
   129,   185,   184,   126,   186,   187,   188,   109,   127,     0,
     0,    86,    87,    93,   102,   101,     0,   110,     0,   122,
   124,   178,   121,   125,    38,    35,   112,   192,   193,   120,
    38,    33,    64,    37,   108,     0,   127,   107,   100,     0,
   127,    99,    84,   127,    92,    94,    91,   182,   183,   181,
   123,     0,   179,    41,    41,    36,    41,     0,    57,    61,
    65,    67,   104,   106,   103,    95,    97,    88,   180,     0,
    20,    49,    42,    22,    14,    55,     0,    72,    75,    56,
    64,    69,    71,    70,     0,    60,    64,    89,    66,    93,
   127,     0,     0,    52,    50,   116,     0,   118,   117,     0,
     0,    64,    59,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,    77,    80,    78,    79,   174,     0,
    64,    63,    67,    90,    96,    98,     0,     0,    48,    43,
    44,    51,     0,    40,    53,    74,    73,    76,    58,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,   163,     0,     0,   132,   133,   135,   137,   138,   145,
   146,   149,   152,   156,   157,   158,   159,   160,   161,   176,
   162,    82,     0,    81,    62,    68,     0,     0,    45,    54,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
   154,   155,   153,   164,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,   177,     0,   130,     0,
     0,   169,   168,   172,   173,   170,   171,   166,     0,     0,
   165,   134,   136,   139,   140,   141,   142,   143,   144,   147,
   148,   150,   151,    83,     0,    46,    47,     0,     0,   131,
   167,   175,     0,     0,     0
};

static const short yydefgoto[] = {   303,
     1,    11,     3,     4,     5,    17,    18,    12,    23,    47,
    13,    20,    14,    21,    38,    15,    19,    29,    30,    51,
    52,    53,    54,   115,    57,    58,   131,   132,   133,   190,
   191,   154,   155,   194,   195,   139,   118,   140,   119,   146,
   120,   121,   149,   141,   142,   160,   143,   144,   147,   175,
   176,   234,    32,    71,    72,   183,   122,   105,   106,   126,
   101,    74,    75,    76,    96,    97,    77,    39,   102,   157,
    48,    78,    79,   268,   269,   215,   216,   217,   218,   219,
   220,   221,   222,   223,   224,   225,   179,   226,   227,   228,
   229,    82,   230,    42,   231,    44
};

static const short yypact[] = {-32768,
    -6,   -28,     3,     1,-32768,-32768,-32768,-32768,-32768,    29,
-32768,-32768,-32768,-32768,-32768,   -33,-32768,     1,    53,    26,
     8,-32768,    -9,-32768,-32768,    44,-32768,   -32,    45,    53,
   359,    53,-32768,-32768,-32768,-32768,-32768,    53,-32768,   213,
-32768,-32768,-32768,    17,-32768,    48,    53,-32768,-32768,     9,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,    50,-32768,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,   434,    76,
    58,-32768,    59,    76,-32768,-32768,    76,-32768,    68,-32768,
-32768,     5,-32768,-32768,    45,    40,-32768,-32768,-32768,-32768,
    45,-32768,   337,-32768,-32768,    75,   415,-32768,-32768,    69,
   434,-32768,-32768,   434,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,     9,-32768,    98,    98,-32768,    98,    85,   -18,   126,
-32768,   109,-32768,-32768,-32768,   111,   128,-32768,-32768,   173,
-32768,   158,-32768,-32768,-32768,-32768,   230,-32768,   143,-32768,
   231,-32768,-32768,-32768,   511,-32768,   284,   337,-32768,    76,
   434,   -10,   169,   157,-32768,-32768,    50,-32768,-32768,    50,
    50,   337,-32768,   152,   153,   154,   155,   160,   161,   164,
   171,   174,   175,   172,-32768,-32768,-32768,-32768,-32768,    30,
   337,-32768,   109,-32768,-32768,-32768,   176,   179,-32768,-32768,
   -10,-32768,   185,-32768,-32768,-32768,-32768,-32768,-32768,   146,
   172,   172,   172,   172,   172,   172,   172,   172,   172,   483,
   483,-32768,   483,   187,-32768,   218,   247,-32768,   147,-32768,
   159,   167,-32768,-32768,-32768,-32768,-32768,-32768,-32768,    30,
-32768,-32768,   172,-32768,-32768,-32768,   194,   195,-32768,-32768,
   193,   197,   198,   200,   201,   211,   212,   189,   216,   217,
-32768,-32768,-32768,-32768,   172,   172,   172,   172,   172,   172,
   172,   172,   172,   172,   172,   172,-32768,   222,   224,   235,
   242,-32768,-32768,-32768,-32768,-32768,-32768,-32768,   172,   172,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,-32768,   172,-32768,-32768,   244,   245,-32768,
-32768,-32768,   279,   281,-32768
};

static const short yypgoto[] = {-32768,
-32768,-32768,-32768,-32768,-32768,   276,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,-32768,-32768,-32768,-32768,   144,-32768,-32768,
-32768,-32768,   259,-32768,    -7,-32768,    -2,-32768,-32768,   119,
-32768,-32768,-32768,-32768,-32768,   -55,   -98,-32768,  -136,-32768,
-32768,-32768,   129,-32768,-32768,-32768,-32768,   156,-32768,-32768,
-32768,    83,-32768,-32768,   210,-32768,   -29,   166,   -35,   170,
-32768,   -64,-32768,-32768,   221,   -93,   -63,   280,     4,-32768,
   277,-32768,-32768,    27,   -40,    70,    71,-32768,-32768,    10,
   -91,   -73,-32768,  -101,   181,   183,-32768,-32768,   -30,   250,
    38,-32768,   -21,-32768,    -4,   308
};


#define	YYLAST		584


static const short yytable[] = {    41,
    80,    73,    94,    45,    95,    98,    55,   127,   187,    83,
   182,    50,    24,    24,     2,   137,    43,   188,    41,    36,
    33,   112,     7,     6,    40,    34,    84,     8,    55,    35,
   138,     9,    95,    98,   100,    43,    95,    98,    80,    25,
    25,   107,   163,    40,   235,    93,   113,    83,    41,   189,
    46,    16,    41,    24,    24,    41,    10,   127,    22,    36,
    36,    88,    80,   199,    84,    43,    80,    37,    81,    43,
    80,    83,    43,    80,    73,    83,   232,   114,   116,    83,
    25,    25,    83,   117,    28,    89,    95,    98,    84,    31,
   129,   233,    84,    34,   108,    49,    84,    35,   109,    84,
    56,   196,   110,   -38,   197,    56,    81,    46,   251,   252,
    80,   253,   134,    93,   135,   158,    80,    80,   184,    83,
    80,    24,   103,   180,   104,    83,    83,    36,    41,    83,
    81,    80,   159,   214,    81,    37,    84,   123,    81,   125,
    83,    81,    84,    84,    99,    43,    84,   130,    25,   136,
    80,   257,   258,   259,   260,   261,   262,    84,   145,    83,
   242,   243,   244,   245,   246,   247,   248,   249,   250,   263,
   264,   290,   291,    59,   148,    85,    84,   150,    81,   265,
   266,    86,   210,   211,    81,    81,    62,    63,    81,    34,
    91,   292,   293,    35,   164,   151,   152,   165,   108,    81,
   153,   161,   109,   192,   193,   241,   110,   166,   167,   168,
   169,   170,   171,   200,   201,   202,   203,    24,    81,   240,
   255,   204,   205,    36,   172,   206,   173,    65,    66,    67,
    34,   212,   207,   174,    35,   208,   209,   237,   298,   299,
   238,    60,    61,   213,    25,    62,    63,    34,    34,   254,
   256,    35,    35,   270,   271,   272,   279,  -127,    24,   273,
   274,  -127,   275,   276,    36,  -127,   284,   285,   286,   287,
   288,   289,    37,   277,   278,    24,    24,    64,   304,   281,
   305,    36,    36,   280,   294,    25,    65,    66,    67,   156,
    68,   295,    69,    27,    60,    61,   162,   296,    62,    63,
    70,    34,    25,    25,   297,    35,   301,   302,    92,   239,
  -127,   236,   267,   128,  -127,   185,   198,   124,  -127,    87,
   186,   300,    90,    26,   282,   177,   283,   178,   111,    24,
    64,     0,     0,     0,     0,    36,     0,     0,     0,    65,
    66,    67,     0,    68,     0,    69,     0,    60,    61,   181,
     0,    62,    63,    70,    34,     0,    25,     0,    35,     0,
     0,     0,     0,  -127,     0,     0,     0,  -127,     0,    60,
    61,  -127,     0,    62,    63,     0,    34,     0,     0,     0,
    35,     0,    24,    64,     0,     0,     0,     0,    36,     0,
     0,     0,    65,    66,    67,     0,    68,     0,    69,     0,
     0,     0,     0,     0,    24,    64,    70,     0,     0,    25,
    36,     0,     0,     0,    65,    66,    67,     0,    68,     0,
    69,     0,     0,   -85,     0,    60,    61,     0,    70,    62,
    63,    25,    34,     0,     0,     0,    35,     0,     0,     0,
     0,     0,     0,     0,    60,    61,     0,     0,    62,    63,
     0,    34,     0,     0,     0,    35,     0,     0,     0,     0,
    24,    64,     0,     0,     0,     0,    36,     0,     0,     0,
    65,    66,    67,     0,    68,     0,    69,  -105,     0,    24,
    64,     0,     0,     0,    70,    36,     0,    25,     0,    65,
    66,    67,     0,    68,     0,    69,     0,    62,    63,     0,
    34,     0,     0,    70,    35,   164,    25,     0,   165,   108,
     0,     0,     0,   109,     0,     0,     0,   110,   166,   167,
   168,   169,   170,   171,     0,     0,     0,     0,    24,     0,
     0,     0,     0,   164,    36,   172,   165,   173,    65,    66,
    67,     0,   212,     0,   174,     0,   166,   167,   168,   169,
   170,   171,     0,     0,     0,    25,    24,     0,     0,     0,
     0,     0,    36,   172,     0,   173,     0,     0,     0,     0,
     0,     0,   174,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,    25
};

static const short yycheck[] = {    21,
    31,    31,    58,    13,    69,    69,    28,   101,    19,    31,
   147,    44,    46,    46,    21,    34,    21,    28,    40,    52,
    13,    17,    20,    52,    21,    18,    31,    25,    50,    22,
    49,    29,    97,    97,    70,    40,   101,   101,    69,    73,
    73,    77,   141,    40,   181,    64,    42,    69,    70,    60,
    60,    51,    74,    46,    46,    77,    54,   151,    30,    52,
    52,    45,    93,   162,    69,    70,    97,    60,    31,    74,
   101,    93,    77,   104,   104,    97,    47,    85,    86,   101,
    73,    73,   104,    91,    32,    69,   151,   151,    93,    64,
   112,    62,    97,    18,    27,    52,   101,    22,    31,   104,
    61,   157,    35,    64,   160,    61,    69,    60,   210,   211,
   141,   213,   115,    64,   117,   137,   147,   148,   148,   141,
   151,    46,    65,   145,    66,   147,   148,    52,   150,   151,
    93,   162,   137,   174,    97,    60,   141,    63,   101,    71,
   162,   104,   147,   148,    69,   150,   151,    50,    73,    65,
   181,     5,     6,     7,     8,     9,    10,   162,    33,   181,
   201,   202,   203,   204,   205,   206,   207,   208,   209,    11,
    12,   263,   264,    30,    66,    32,   181,    67,   141,    13,
    14,    38,    11,    12,   147,   148,    15,    16,   151,    18,
    47,   265,   266,    22,    23,    68,    24,    26,    27,   162,
    43,    59,    31,    35,    48,    60,    35,    36,    37,    38,
    39,    40,    41,    62,    62,    62,    62,    46,   181,    35,
     3,    62,    62,    52,    53,    62,    55,    56,    57,    58,
    18,    60,    62,    62,    22,    62,    62,    62,   279,   280,
    62,    11,    12,    72,    73,    15,    16,    18,    18,    63,
     4,    22,    22,    60,    60,    63,    68,    27,    46,    63,
    63,    31,    63,    63,    52,    35,   257,   258,   259,   260,
   261,   262,    60,    63,    63,    46,    46,    47,     0,    63,
     0,    52,    52,    68,    63,    73,    56,    57,    58,    60,
    60,    68,    62,    18,    11,    12,    66,    63,    15,    16,
    70,    18,    73,    73,    63,    22,    63,    63,    50,   191,
    27,   183,   230,   104,    31,   150,   161,    97,    35,    40,
   151,   295,    46,    16,   255,   145,   256,   145,    79,    46,
    47,    -1,    -1,    -1,    -1,    52,    -1,    -1,    -1,    56,
    57,    58,    -1,    60,    -1,    62,    -1,    11,    12,    66,
    -1,    15,    16,    70,    18,    -1,    73,    -1,    22,    -1,
    -1,    -1,    -1,    27,    -1,    -1,    -1,    31,    -1,    11,
    12,    35,    -1,    15,    16,    -1,    18,    -1,    -1,    -1,
    22,    -1,    46,    47,    -1,    -1,    -1,    -1,    52,    -1,
    -1,    -1,    56,    57,    58,    -1,    60,    -1,    62,    -1,
    -1,    -1,    -1,    -1,    46,    47,    70,    -1,    -1,    73,
    52,    -1,    -1,    -1,    56,    57,    58,    -1,    60,    -1,
    62,    -1,    -1,    65,    -1,    11,    12,    -1,    70,    15,
    16,    73,    18,    -1,    -1,    -1,    22,    -1,    -1,    -1,
    -1,    -1,    -1,    -1,    11,    12,    -1,    -1,    15,    16,
    -1,    18,    -1,    -1,    -1,    22,    -1,    -1,    -1,    -1,
    46,    47,    -1,    -1,    -1,    -1,    52,    -1,    -1,    -1,
    56,    57,    58,    -1,    60,    -1,    62,    63,    -1,    46,
    47,    -1,    -1,    -1,    70,    52,    -1,    73,    -1,    56,
    57,    58,    -1,    60,    -1,    62,    -1,    15,    16,    -1,
    18,    -1,    -1,    70,    22,    23,    73,    -1,    26,    27,
    -1,    -1,    -1,    31,    -1,    -1,    -1,    35,    36,    37,
    38,    39,    40,    41,    -1,    -1,    -1,    -1,    46,    -1,
    -1,    -1,    -1,    23,    52,    53,    26,    55,    56,    57,
    58,    -1,    60,    -1,    62,    -1,    36,    37,    38,    39,
    40,    41,    -1,    -1,    -1,    73,    46,    -1,    -1,    -1,
    -1,    -1,    52,    53,    -1,    55,    -1,    -1,    -1,    -1,
    -1,    -1,    62,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
    -1,    -1,    -1,    73
};
/* -*-C-*-  Note some compilers choke on comments on `#line' lines.  */
#line 3 "bison.simple"

/* Skeleton output parser for bison,
   Copyright (C) 1984, 1989, 1990 Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.  */

/* As a special exception, when this file is copied by Bison into a
   Bison output file, you may use that output file without restriction.
   This special exception was added by the Free Software Foundation
   in version 1.24 of Bison.  */

#ifdef __GNUC__
#define alloca __builtin_alloca
#else /* not __GNUC__ */
#if HAVE_ALLOCA_H
#include <alloca.h>
#else /* not HAVE_ALLOCA_H */
#ifdef _AIX
 #pragma alloca
#else /* not _AIX */
/* char *alloca (); defined by PC compilers */
#endif /* not _AIX */
#endif /* not HAVE_ALLOCA_H */
#endif /* not __GNUC__ */

extern int yylex();
extern void yyerror();

#ifndef alloca
#ifdef __GNUC__
#define alloca __builtin_alloca
#else /* not GNU C.  */
#if (!defined (__STDC__) && defined (sparc)) || defined (__sparc__) || defined (__sparc) || defined (__sgi)
#include <alloca.h>
#else /* not sparc */
#if defined (MSDOS) && !defined (__TURBOC__)
#include <malloc.h>
#else /* not MSDOS, or __TURBOC__ */
#if defined(_AIX)
#include <malloc.h>
 #pragma alloca
#else /* not MSDOS, __TURBOC__, or _AIX */
#ifdef __hpux
#ifdef __cplusplus
extern "C" {
void *alloca (unsigned int);
};
#else /* not __cplusplus */
void *alloca ();
#endif /* not __cplusplus */
#endif /* __hpux */
#endif /* not _AIX */
#endif /* not MSDOS, or __TURBOC__ */
#endif /* not sparc.  */
#endif /* not GNU C.  */
#endif /* alloca not defined.  */

/* This is the parser code that is written into each bison parser
  when the %semantic_parser declaration is not specified in the grammar.
  It was written by Richard Stallman by simplifying the hairy parser
  used when %semantic_parser is specified.  */

/* Note: there must be only one dollar sign in this file.
   It is replaced by the list of actions, each action
   as one case of the switch.  */

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		-2
#define YYEOF		0
#define YYACCEPT	return(0)
#define YYABORT 	return(1)
#define YYERROR		goto yyerrlab1
/* Like YYERROR except do call yyerror.
   This remains here temporarily to ease the
   transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */
#define YYFAIL		goto yyerrlab
#define YYRECOVERING()  (!!yyerrstatus)
#define YYBACKUP(token, value) \
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    { yychar = (token), yylval = (value);			\
      yychar1 = YYTRANSLATE (yychar);				\
      YYPOPSTACK;						\
      goto yybackup;						\
    }								\
  else								\
    { yyerror ("syntax error: cannot back up"); YYERROR; }	\
while (0)

#define YYTERROR	1
#define YYERRCODE	256

#ifndef YYPURE
#define YYLEX		yylex()
#endif

#ifdef YYPURE
#ifdef YYLSP_NEEDED
#ifdef YYLEX_PARAM
#define YYLEX		yylex(&yylval, &yylloc, YYLEX_PARAM)
#else
#define YYLEX		yylex(&yylval, &yylloc)
#endif
#else /* not YYLSP_NEEDED */
#ifdef YYLEX_PARAM
#define YYLEX		yylex(&yylval, YYLEX_PARAM)
#else
#define YYLEX		yylex(&yylval)
#endif
#endif /* not YYLSP_NEEDED */
#endif

/* If nonreentrant, generate the variables here */

#ifndef YYPURE

int	yychar;			/*  the lookahead symbol		*/
YYSTYPE	yylval;			/*  the semantic value of the		*/
				/*  lookahead symbol			*/

#ifdef YYLSP_NEEDED
YYLTYPE yylloc;			/*  location data for the lookahead	*/
				/*  symbol				*/
#endif

int yynerrs;			/*  number of parse errors so far       */
#endif  /* not YYPURE */

#if YYDEBUG != 0
int yydebug;			/*  nonzero means print parse trace	*/
/* Since this is uninitialized, it does not stop multiple parsers
   from coexisting.  */
#endif

/*  YYINITDEPTH indicates the initial size of the parser's stacks	*/

#ifndef	YYINITDEPTH
#define YYINITDEPTH 200
#endif

/*  YYMAXDEPTH is the maximum size the stacks can grow to
    (effective only if the built-in stack extension method is used).  */

#if YYMAXDEPTH == 0
#undef YYMAXDEPTH
#endif

#ifndef YYMAXDEPTH
#define YYMAXDEPTH 10000
#endif

/* Prevent warning if -Wstrict-prototypes.  */
#ifdef __GNUC__
int yyparse (void);
#endif

#if __GNUC__ > 1		/* GNU C and GNU C++ define this.  */
#define __yy_memcpy(FROM,TO,COUNT)	__builtin_memcpy(TO,FROM,COUNT)
#else				/* not GNU C or C++ */
#ifndef __cplusplus

/* This is the most reliable way to avoid incompatibilities
   in available built-in functions on various systems.  */
static void
__yy_memcpy (from, to, count)
     char *from;
     char *to;
     int count;
{
  register char *f = from;
  register char *t = to;
  register int i = count;

  while (i-- > 0)
    *t++ = *f++;
}

#else /* __cplusplus */

/* This is the most reliable way to avoid incompatibilities
   in available built-in functions on various systems.  */
static void
__yy_memcpy (char *from, char *to, int count)
{
  register char *f = from;
  register char *t = to;
  register int i = count;

  while (i-- > 0)
    *t++ = *f++;
}

#endif
#endif

#line 192 "bison.simple"

/* The user can define YYPARSE_PARAM as the name of an argument to be passed
   into yyparse.  The argument should have type void *.
   It should actually point to an object.
   Grammar actions can access the variable by casting it
   to the proper pointer type.  */

#ifdef YYPARSE_PARAM
#define YYPARSE_PARAM_DECL void *YYPARSE_PARAM;
#else
#define YYPARSE_PARAM
#define YYPARSE_PARAM_DECL
#endif

int
yyparse(YYPARSE_PARAM)
     YYPARSE_PARAM_DECL
{
  register int yystate;
  register int yyn;
  register short *yyssp;
  register YYSTYPE *yyvsp;
  int yyerrstatus;	/*  number of tokens to shift before error messages enabled */
  int yychar1 = 0;		/*  lookahead token as an internal (translated) token number */

  short	yyssa[YYINITDEPTH];	/*  the state stack			*/
  YYSTYPE yyvsa[YYINITDEPTH];	/*  the semantic value stack		*/

  short *yyss = yyssa;		/*  refer to the stacks thru separate pointers */
  YYSTYPE *yyvs = yyvsa;	/*  to allow yyoverflow to reallocate them elsewhere */

#ifdef YYLSP_NEEDED
  YYLTYPE yylsa[YYINITDEPTH];	/*  the location stack			*/
  YYLTYPE *yyls = yylsa;
  YYLTYPE *yylsp;

#define YYPOPSTACK   (yyvsp--, yyssp--, yylsp--)
#else
#define YYPOPSTACK   (yyvsp--, yyssp--)
#endif

  int yystacksize = YYINITDEPTH;

#ifdef YYPURE
  int yychar;
  YYSTYPE yylval;
  int yynerrs;
#ifdef YYLSP_NEEDED
  YYLTYPE yylloc;
#endif
#endif

  YYSTYPE yyval;		/*  the variable used to return		*/
				/*  semantic values from the action	*/
				/*  routines				*/

  int yylen;

#if YYDEBUG != 0
  if (yydebug)
    fprintf(stderr, "Starting parse\n");
#endif

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss - 1;
  yyvsp = yyvs;
#ifdef YYLSP_NEEDED
  yylsp = yyls;
#endif

/* Push a new state, which is found in  yystate  .  */
/* In all cases, when you get here, the value and location stacks
   have just been pushed. so pushing a state here evens the stacks.  */
yynewstate:

  *++yyssp = yystate;

  if (yyssp >= yyss + yystacksize - 1)
    {
      /* Give user a chance to reallocate the stack */
      /* Use copies of these so that the &'s don't force the real ones into memory. */
      YYSTYPE *yyvs1 = yyvs;
      short *yyss1 = yyss;
#ifdef YYLSP_NEEDED
      YYLTYPE *yyls1 = yyls;
#endif

      /* Get the current used size of the three stacks, in elements.  */
      int size = yyssp - yyss + 1;

#ifdef yyoverflow
      /* Each stack pointer address is followed by the size of
	 the data in use in that stack, in bytes.  */
#ifdef YYLSP_NEEDED
      /* This used to be a conditional around just the two extra args,
	 but that might be undefined if yyoverflow is a macro.  */
      yyoverflow("parser stack overflow",
		 &yyss1, size * sizeof (*yyssp),
		 &yyvs1, size * sizeof (*yyvsp),
		 &yyls1, size * sizeof (*yylsp),
		 &yystacksize);
#else
      yyoverflow("parser stack overflow",
		 &yyss1, size * sizeof (*yyssp),
		 &yyvs1, size * sizeof (*yyvsp),
		 &yystacksize);
#endif

      yyss = yyss1; yyvs = yyvs1;
#ifdef YYLSP_NEEDED
      yyls = yyls1;
#endif
#else /* no yyoverflow */
      /* Extend the stack our own way.  */
      if (yystacksize >= YYMAXDEPTH)
	{
	  yyerror("parser stack overflow");
	  return 2;
	}
      yystacksize *= 2;
      if (yystacksize > YYMAXDEPTH)
	yystacksize = YYMAXDEPTH;
      yyss = (short *) alloca (yystacksize * sizeof (*yyssp));
      __yy_memcpy ((char *)yyss1, (char *)yyss, size * sizeof (*yyssp));
      yyvs = (YYSTYPE *) alloca (yystacksize * sizeof (*yyvsp));
      __yy_memcpy ((char *)yyvs1, (char *)yyvs, size * sizeof (*yyvsp));
#ifdef YYLSP_NEEDED
      yyls = (YYLTYPE *) alloca (yystacksize * sizeof (*yylsp));
      __yy_memcpy ((char *)yyls1, (char *)yyls, size * sizeof (*yylsp));
#endif
#endif /* no yyoverflow */

      yyssp = yyss + size - 1;
      yyvsp = yyvs + size - 1;
#ifdef YYLSP_NEEDED
      yylsp = yyls + size - 1;
#endif

#if YYDEBUG != 0
      if (yydebug)
	fprintf(stderr, "Stack size increased to %d\n", yystacksize);
#endif

      if (yyssp >= yyss + yystacksize - 1)
	YYABORT;
    }

#if YYDEBUG != 0
  if (yydebug)
    fprintf(stderr, "Entering state %d\n", yystate);
#endif

  goto yybackup;
 yybackup:

/* Do appropriate processing given the current state.  */
/* Read a lookahead token if we need one and don't already have one.  */
/* yyresume: */

  /* First try to decide what to do without reference to lookahead token.  */

  yyn = yypact[yystate];
  if (yyn == YYFLAG)
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* yychar is either YYEMPTY or YYEOF
     or a valid token in external form.  */

  if (yychar == YYEMPTY)
    {
#if YYDEBUG != 0
      if (yydebug)
	fprintf(stderr, "Reading a token: ");
#endif
      yychar = YYLEX;
    }

  /* Convert token to internal form (in yychar1) for indexing tables with */

  if (yychar <= 0)		/* This means end of input. */
    {
      yychar1 = 0;
      yychar = YYEOF;		/* Don't call YYLEX any more */

#if YYDEBUG != 0
      if (yydebug)
	fprintf(stderr, "Now at end of input.\n");
#endif
    }
  else
    {
      yychar1 = YYTRANSLATE(yychar);

#if YYDEBUG != 0
      if (yydebug)
	{
	  fprintf (stderr, "Next token is %d (%s", yychar, yytname[yychar1]);
	  /* Give the individual parser a way to print the precise meaning
	     of a token, for further debugging info.  */
#ifdef YYPRINT
	  YYPRINT (stderr, yychar, yylval);
#endif
	  fprintf (stderr, ")\n");
	}
#endif
    }

  yyn += yychar1;
  if (yyn < 0 || yyn > YYLAST || yycheck[yyn] != yychar1)
    goto yydefault;

  yyn = yytable[yyn];

  /* yyn is what to do for this token type in this state.
     Negative => reduce, -yyn is rule number.
     Positive => shift, yyn is new state.
       New state is final state => don't bother to shift,
       just return success.
     0, or most negative number => error.  */

  if (yyn < 0)
    {
      if (yyn == YYFLAG)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }
  else if (yyn == 0)
    goto yyerrlab;

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Shift the lookahead token.  */

#if YYDEBUG != 0
  if (yydebug)
    fprintf(stderr, "Shifting token %d (%s), ", yychar, yytname[yychar1]);
#endif

  /* Discard the token being shifted unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  *++yyvsp = yylval;
#ifdef YYLSP_NEEDED
  *++yylsp = yylloc;
#endif

  /* count tokens shifted since error; after three, turn off error status.  */
  if (yyerrstatus) yyerrstatus--;

  yystate = yyn;
  goto yynewstate;

/* Do the default action for the current state.  */
yydefault:

  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;

/* Do a reduction.  yyn is the number of a rule to reduce with.  */
yyreduce:
  yylen = yyr2[yyn];
  if (yylen > 0)
    yyval = yyvsp[1-yylen]; /* implement default value of the action */

#if YYDEBUG != 0
  if (yydebug)
    {
      int i;

      fprintf (stderr, "Reducing via rule %d (line %d), ",
	       yyn, yyrline[yyn]);

      /* Print the symbols being reduced, and their result.  */
      for (i = yyprhs[yyn]; yyrhs[i] > 0; i++)
	fprintf (stderr, "%s ", yytname[yyrhs[i]]);
      fprintf (stderr, " -> %s\n", yytname[yyr1[yyn]]);
    }
#endif


  switch (yyn) {

case 1:
#line 79 "sparql_parser.y"
{bInProlog = 1;;
    break;}
case 2:
#line 81 "sparql_parser.y"
{
					/*output_query();*/
					/*help_profile();*/
					/*memory_profile();*/
					/*printf("*** DONE ***\n");*/
				;
    break;}
case 3:
#line 89 "sparql_parser.y"
{;
    break;}
case 4:
#line 91 "sparql_parser.y"
{;
    break;}
case 5:
#line 93 "sparql_parser.y"
{;
    break;}
case 6:
#line 95 "sparql_parser.y"
{;
    break;}
case 7:
#line 100 "sparql_parser.y"
{DBG_PRT("Prolog: BaseDecl_Q PrefixDecl_S\n");bInProlog = 0;;
    break;}
case 8:
#line 104 "sparql_parser.y"
{;
    break;}
case 9:
#line 106 "sparql_parser.y"
{;
    break;}
case 10:
#line 109 "sparql_parser.y"
{mk_base(yyvsp[0].id);;
    break;}
case 11:
#line 114 "sparql_parser.y"
{;
    break;}
case 12:
#line 116 "sparql_parser.y"
{;
    break;}
case 13:
#line 119 "sparql_parser.y"
{mk_prfx(yyvsp[-1].id, yyvsp[0].id);;
    break;}
case 14:
#line 124 "sparql_parser.y"
{
									gQueryVar = yyvsp[-3].id;					/*vars after 'select'  */
									if (gQueryVar == T_UNKNOWN)
										gQueryVar = amos_query_var();
									gDistinct = yyvsp[-4].id;
								;
    break;}
case 15:
#line 132 "sparql_parser.y"
{yyval.id = T_EMPTY;;
    break;}
case 16:
#line 134 "sparql_parser.y"
{yyval.id = mk_str(" distinct");;
    break;}
case 17:
#line 137 "sparql_parser.y"
{yyval.id = yyvsp[0].id;;
    break;}
case 18:
#line 139 "sparql_parser.y"
{yyval.id = T_UNKNOWN;;
    break;}
case 19:
#line 143 "sparql_parser.y"
{NOT_SUPPORT("CONSTRUCT");;
    break;}
case 20:
#line 144 "sparql_parser.y"
{;
    break;}
case 21:
#line 148 "sparql_parser.y"
{NOT_SUPPORT("DESCRIBE");;
    break;}
case 22:
#line 149 "sparql_parser.y"
{;
    break;}
case 23:
#line 152 "sparql_parser.y"
{;
    break;}
case 24:
#line 154 "sparql_parser.y"
{;
    break;}
case 25:
#line 158 "sparql_parser.y"
{NOT_SUPPORT("ASK");;
    break;}
case 26:
#line 159 "sparql_parser.y"
{;
    break;}
case 27:
#line 164 "sparql_parser.y"
{yyval.id = T_EMPTY;;
    break;}
case 28:
#line 166 "sparql_parser.y"
{;
    break;}
case 29:
#line 170 "sparql_parser.y"
{
                                                                         gRDF_src[0] = '\0';
                                                                         strcat(gRDF_src,"\"");
                                                                         strcat(gRDF_src,getstr(yyvsp[0].id));
                                                                         strcat(gRDF_src,"\"");;
    break;}
case 30:
#line 184 "sparql_parser.y"
{;
    break;}
case 31:
#line 186 "sparql_parser.y"
{;
    break;}
case 32:
#line 191 "sparql_parser.y"
{;
    break;}
case 33:
#line 196 "sparql_parser.y"
{NOT_SUPPORT("NAMED");;
    break;}
case 34:
#line 201 "sparql_parser.y"
{;
    break;}
case 36:
#line 207 "sparql_parser.y"
{;
    break;}
case 37:
#line 210 "sparql_parser.y"
{/*$<id>$ = new_list_and_merge(mk_str("\nwhere"), amos_condition(), T_LST_END);*/;
    break;}
case 40:
#line 218 "sparql_parser.y"
{
											yyval.id = T_EMPTY;
										;
    break;}
case 42:
#line 226 "sparql_parser.y"
{;
    break;}
case 43:
#line 229 "sparql_parser.y"
{;
    break;}
case 44:
#line 234 "sparql_parser.y"
{;
    break;}
case 45:
#line 236 "sparql_parser.y"
{;
    break;}
case 46:
#line 240 "sparql_parser.y"
{mk_ordrinf(yyvsp[-1].id,"\"inc\"");;
    break;}
case 47:
#line 242 "sparql_parser.y"
{mk_ordrinf(yyvsp[-1].id,"\"dec\"");;
    break;}
case 48:
#line 244 "sparql_parser.y"
{mk_ordrinf(yyvsp[0].id,"\"inc\"");;
    break;}
case 50:
#line 263 "sparql_parser.y"
{;
    break;}
case 51:
#line 266 "sparql_parser.y"
{set_limit(SparQLtext);;
    break;}
case 53:
#line 272 "sparql_parser.y"
{;
    break;}
case 54:
#line 275 "sparql_parser.y"
{set_offset(SparQLtext);;
    break;}
case 55:
#line 280 "sparql_parser.y"
{;
    break;}
case 56:
#line 285 "sparql_parser.y"
{;
    break;}
case 57:
#line 288 "sparql_parser.y"
{DBG_PRT("-- Empty GraphPattern_Opt\n");;
    break;}
case 58:
#line 290 "sparql_parser.y"
{;
    break;}
case 59:
#line 292 "sparql_parser.y"
{;
    break;}
case 60:
#line 297 "sparql_parser.y"
{;
    break;}
case 61:
#line 300 "sparql_parser.y"
{DBG_PRT("-- Empty FilteredBasicGraphPattern_Opt\n");;
    break;}
case 62:
#line 302 "sparql_parser.y"
{;
    break;}
case 63:
#line 304 "sparql_parser.y"
{;
    break;}
case 64:
#line 309 "sparql_parser.y"
{DBG_PRT("-- Empty BlockOfTriples_Q\n");;
    break;}
case 65:
#line 311 "sparql_parser.y"
{DBG_PRT("-- BlockOfTriples_Q\n");;
    break;}
case 66:
#line 314 "sparql_parser.y"
{;
    break;}
case 67:
#line 317 "sparql_parser.y"
{DBG_PRT("-- Empty BlockOfTriples_Opt\n");;
    break;}
case 68:
#line 319 "sparql_parser.y"
{DBG_PRT("-- BlockOfTriples_Opt\n");;
    break;}
case 69:
#line 324 "sparql_parser.y"
{;
    break;}
case 70:
#line 326 "sparql_parser.y"
{;
    break;}
case 71:
#line 328 "sparql_parser.y"
{;
    break;}
case 72:
#line 333 "sparql_parser.y"
{
													NOTICE_NOT_SUPPORT("Optional");
													if (in_opt()) NOT_SUPPORT("Nested Optional"); 
													enter_opt();
												;
    break;}
case 73:
#line 338 "sparql_parser.y"
{leave_opt();;
    break;}
case 74:
#line 343 "sparql_parser.y"
{NOT_SUPPORT("GRAPH");;
    break;}
case 75:
#line 348 "sparql_parser.y"
{;
    break;}
case 76:
#line 350 "sparql_parser.y"
{NOT_SUPPORT("UNION");;
    break;}
case 77:
#line 355 "sparql_parser.y"
{mk_fltr(yyvsp[0].id,get_opt());;
    break;}
case 78:
#line 358 "sparql_parser.y"
{
										yyval.id = yyvsp[0].id;
									;
    break;}
case 79:
#line 362 "sparql_parser.y"
{yyval.id = yyvsp[0].id;;
    break;}
case 80:
#line 364 "sparql_parser.y"
{NOT_SUPPORT("FunctionCall");;
    break;}
case 81:
#line 369 "sparql_parser.y"
{;
    break;}
case 82:
#line 374 "sparql_parser.y"
{;
    break;}
case 83:
#line 376 "sparql_parser.y"
{;
    break;}
case 84:
#line 381 "sparql_parser.y"
{;
    break;}
case 86:
#line 387 "sparql_parser.y"
{;
    break;}
case 87:
#line 390 "sparql_parser.y"
{;
    break;}
case 88:
#line 392 "sparql_parser.y"
{;
    break;}
case 90:
#line 398 "sparql_parser.y"
{;
    break;}
case 91:
#line 400 "sparql_parser.y"
{
												if (mk_tpl(yyvsp[-1].id, yyvsp[0].id, get_opt())!=0)
												{	NOTICE_NOT_SUPPORT("OPTIONAL");}
												DBG_PRT("-- TriplesSameSubject 1\n");
											;
    break;}
case 92:
#line 406 "sparql_parser.y"
{
												if (mk_tpl(yyvsp[-1].id, yyvsp[0].id, get_opt())!=0)
												{	NOTICE_NOT_SUPPORT("OPTIONAL");}
												DBG_PRT("-- TriplesSameSubject 2\n");
											;
    break;}
case 93:
#line 414 "sparql_parser.y"
{yyval.id = mk_lst();;
    break;}
case 94:
#line 416 "sparql_parser.y"
{yyval.id = yyvsp[0].id;;
    break;}
case 95:
#line 421 "sparql_parser.y"
{
													yyval.id = new_list_and_merge(yyvsp[-1].id, yyvsp[0].id, T_LST_END);
												;
    break;}
case 96:
#line 425 "sparql_parser.y"
{
													/*$<id>1 will be the first node in list $<id>4*/
													append_to_list_front(yyvsp[0].id, yyvsp[-2].id, yyvsp[-3].id, T_LST_END);
													yyval.id = yyvsp[0].id;
												;
    break;}
case 97:
#line 434 "sparql_parser.y"
{yyval.id = new_list_and_merge(yyvsp[0].id, T_LST_END);;
    break;}
case 98:
#line 436 "sparql_parser.y"
{
								append_to_list_front(yyvsp[0].id, yyvsp[-2].id, T_LST_END);
								yyval.id = yyvsp[0].id;
							;
    break;}
case 99:
#line 444 "sparql_parser.y"
{
					DBG_PRT("-- Verb VarOrIRIref 0x%.8X\n", yyvsp[0].id);
					yyval.id = yyvsp[0].id;
				;
    break;}
case 100:
#line 449 "sparql_parser.y"
{yyval.id = mk_iri("http://www.w3.org/1999/02/22-rdf-syntax-ns#type");;
    break;}
case 101:
#line 454 "sparql_parser.y"
{;
    break;}
case 102:
#line 456 "sparql_parser.y"
{yyval.id = yyvsp[0].id;;
    break;}
case 103:
#line 461 "sparql_parser.y"
{
														yyval.id = mk_bkv();
														if (mk_tpl(yyval.id, yyvsp[-1].id, get_opt()))
														{	/*NOT_SUPPORT("OPTIONAL");*/}
														DBG_PRT("-- BlankNodePropertyList\n");
													;
    break;}
case 105:
#line 475 "sparql_parser.y"
{;
    break;}
case 106:
#line 477 "sparql_parser.y"
{;
    break;}
case 107:
#line 480 "sparql_parser.y"
{
							yyval.id = yyvsp[0].id;
							DBG_PRT("-- GraphNode VarOrTerm\n");
						;
    break;}
case 108:
#line 485 "sparql_parser.y"
{
							yyval.id = yyvsp[0].id;
							DBG_PRT("-- GraphNode TriplesNode\n");
						;
    break;}
case 109:
#line 493 "sparql_parser.y"
{
							DBG_PRT("-- VarOrTerm VAR\n"); 
							yyval.id = yyvsp[0].id;
						;
    break;}
case 110:
#line 498 "sparql_parser.y"
{
							DBG_PRT("-- VarOrTerm GraphTerm\n");
							yyval.id = yyvsp[0].id;
						;
    break;}
case 111:
#line 506 "sparql_parser.y"
{;
    break;}
case 112:
#line 508 "sparql_parser.y"
{;
    break;}
case 113:
#line 511 "sparql_parser.y"
{
								DBG_PRT("-- VarOrIRIref VAR 0x%.8X\n", yyvsp[0].id);
								yyval.id = yyvsp[0].id;
							;
    break;}
case 114:
#line 516 "sparql_parser.y"
{
								yyval.id = yyvsp[0].id;
								DBG_PRT("-- VarOrIRIref BlankNode\n");
							;
    break;}
case 115:
#line 521 "sparql_parser.y"
{
								DBG_PRT("-- VarOrIRIref IRIref 0x%.8X\n", yyvsp[0].id);
								yyval.id = yyvsp[0].id;
							;
    break;}
case 116:
#line 529 "sparql_parser.y"
{;
    break;}
case 117:
#line 531 "sparql_parser.y"
{;
    break;}
case 118:
#line 533 "sparql_parser.y"
{;
    break;}
case 119:
#line 538 "sparql_parser.y"
{
					DBG_PRT("-- Var_P : VAR\n");
					yyval.id = new_list_and_merge(yyvsp[0].id, T_LST_END);
				;
    break;}
case 120:
#line 543 "sparql_parser.y"
{
					DBG_PRT("-- Var_P : VAR Var_P\n");
					append_to_list_front(yyvsp[0].id, gComma, yyvsp[-1].id, T_LST_END);
					yyval.id = yyvsp[0].id;
				;
    break;}
case 121:
#line 552 "sparql_parser.y"
{
							DBG_PRT("-- GraphTerm IRIref 0x%.8X\n", yyvsp[0].id);
							yyval.id = yyvsp[0].id;
						;
    break;}
case 122:
#line 557 "sparql_parser.y"
{DBG_PRT("-- GraphTerm RDFLiteral\n");;
    break;}
case 123:
#line 559 "sparql_parser.y"
{
							DBG_PRT("-- GraphTerm GraphTerm_Opt\n");
							if (yyvsp[-1].id == 0)
								yyval.id = yyvsp[0].id;
						;
    break;}
case 124:
#line 565 "sparql_parser.y"
{DBG_PRT("-- GraphTerm BooleanLiteral\n");;
    break;}
case 125:
#line 567 "sparql_parser.y"
{
							yyval.id = yyvsp[0].id;
							DBG_PRT("-- GraphTerm BlankNode\n");
						;
    break;}
case 126:
#line 572 "sparql_parser.y"
{DBG_PRT("-- GraphTerm NIL\n");;
    break;}
case 127:
#line 575 "sparql_parser.y"
{yyval.id = 0;;
    break;}
case 128:
#line 577 "sparql_parser.y"
{yyval.id = '+';;
    break;}
case 129:
#line 579 "sparql_parser.y"
{yyval.id = '-';;
    break;}
case 130:
#line 584 "sparql_parser.y"
{;
    break;}
case 131:
#line 586 "sparql_parser.y"
{;
    break;}
case 132:
#line 589 "sparql_parser.y"
{yyval.id = yyvsp[0].id;;
    break;}
case 133:
#line 594 "sparql_parser.y"
{yyval.id=yyvsp[0].id;;
    break;}
case 134:
#line 596 "sparql_parser.y"
{yyval.id = new_list_and_merge(
														mk_str("l_o("),yyvsp[-2].id,gComma,yyvsp[0].id,gCloseB,T_LST_END);;
    break;}
case 135:
#line 602 "sparql_parser.y"
{yyval.id=yyvsp[0].id;;
    break;}
case 136:
#line 604 "sparql_parser.y"
{yyval.id = new_list_and_merge(
															mk_str("l_a("),yyvsp[-2].id,gComma,yyvsp[0].id,gCloseB,T_LST_END);;
    break;}
case 137:
#line 610 "sparql_parser.y"
{yyval.id = yyvsp[0].id;;
    break;}
case 138:
#line 615 "sparql_parser.y"
{yyval.id = yyvsp[0].id;;
    break;}
case 139:
#line 617 "sparql_parser.y"
{yyval.id = new_list_and_merge(mk_str("EQ("),yyvsp[-2].id,gComma,yyvsp[0].id,gCloseB,T_LST_END);;
    break;}
case 140:
#line 619 "sparql_parser.y"
{yyval.id = new_list_and_merge(mk_str("NEQ("),yyvsp[-2].id,gComma,yyvsp[0].id,gCloseB,T_LST_END);;
    break;}
case 141:
#line 621 "sparql_parser.y"
{yyval.id = new_list_and_merge(mk_str("LT("),yyvsp[-2].id,gComma,yyvsp[0].id,gCloseB,T_LST_END);;
    break;}
case 142:
#line 623 "sparql_parser.y"
{yyval.id = new_list_and_merge(mk_str("GT("),yyvsp[-2].id,gComma,yyvsp[0].id,gCloseB,T_LST_END);;
    break;}
case 143:
#line 625 "sparql_parser.y"
{yyval.id = new_list_and_merge(mk_str("LTE("),yyvsp[-2].id,gComma,yyvsp[0].id,gCloseB,T_LST_END);;
    break;}
case 144:
#line 627 "sparql_parser.y"
{yyval.id = new_list_and_merge(mk_str("GTE("),yyvsp[-2].id,gComma,yyvsp[0].id,gCloseB,T_LST_END);;
    break;}
case 145:
#line 632 "sparql_parser.y"
{yyval.id = yyvsp[0].id;;
    break;}
case 146:
#line 637 "sparql_parser.y"
{yyval.id = yyvsp[0].id;;
    break;}
case 147:
#line 639 "sparql_parser.y"
{yyval.id = new_list_and_merge(
											yyvsp[-2].id,mk_str("+"),yyvsp[0].id,T_LST_END);;
    break;}
case 148:
#line 642 "sparql_parser.y"
{yyval.id = new_list_and_merge(
											yyvsp[-2].id,mk_str("-"),yyvsp[0].id,T_LST_END);;
    break;}
case 149:
#line 648 "sparql_parser.y"
{yyval.id = yyvsp[0].id;;
    break;}
case 150:
#line 650 "sparql_parser.y"
{yyval.id = new_list_and_merge(
														yyvsp[-2].id,mk_str("*"),yyvsp[0].id,T_LST_END);;
    break;}
case 151:
#line 653 "sparql_parser.y"
{yyval.id = new_list_and_merge(
														yyvsp[-2].id,mk_str("/"),yyvsp[0].id,T_LST_END);;
    break;}
case 152:
#line 659 "sparql_parser.y"
{yyval.id = yyvsp[0].id;;
    break;}
case 153:
#line 661 "sparql_parser.y"
{yyval.id = new_list_and_merge(mk_str("fn_not("),yyvsp[0].id,gCloseB,T_LST_END);;
    break;}
case 154:
#line 663 "sparql_parser.y"
{yyval.id = yyvsp[-1].id;;
    break;}
case 155:
#line 665 "sparql_parser.y"
{yyval.id = new_list_and_merge(mk_str("fn_neg("),yyvsp[0].id,gCloseB,T_LST_END);;
    break;}
case 156:
#line 670 "sparql_parser.y"
{yyval.id=yyvsp[0].id;;
    break;}
case 157:
#line 672 "sparql_parser.y"
{yyval.id=yyvsp[0].id;;
    break;}
case 158:
#line 674 "sparql_parser.y"
{yyval.id=new_list_and_merge(mk_str("uri(\""),yyvsp[0].id,mk_str("\")"),T_LST_END);;
    break;}
case 159:
#line 676 "sparql_parser.y"
{yyval.id=yyvsp[0].id;;
    break;}
case 160:
#line 678 "sparql_parser.y"
{yyval.id=yyvsp[0].id;;
    break;}
case 161:
#line 680 "sparql_parser.y"
{yyval.id=yyvsp[0].id;;
    break;}
case 162:
#line 682 "sparql_parser.y"
{;
    break;}
case 163:
#line 684 "sparql_parser.y"
{yyval.id=yyvsp[0].id;;
    break;}
case 164:
#line 690 "sparql_parser.y"
{yyval.id = new_list_and_merge(mk_str("("),yyvsp[-1].id,gCloseB,T_LST_END);;
    break;}
case 165:
#line 695 "sparql_parser.y"
{yyval.id = new_list_and_merge(mk_str("STR("),yyvsp[-1].id,gCloseB,T_LST_END);;
    break;}
case 166:
#line 697 "sparql_parser.y"
{yyval.id = new_list_and_merge(mk_str("LANG("),yyvsp[-1].id,gCloseB,T_LST_END);;
    break;}
case 167:
#line 699 "sparql_parser.y"
{yyval.id = new_list_and_merge(mk_str("langMatches("),yyvsp[-3].id,
										gComma,yyvsp[-1].id,gCloseB,T_LST_END);;
    break;}
case 168:
#line 702 "sparql_parser.y"
{yyval.id = new_list_and_merge(
							mk_str("DT("),yyvsp[-1].id,mk_str(")"),T_LST_END);;
    break;}
case 169:
#line 705 "sparql_parser.y"
{NOT_SUPPORT("function BOUND");;
    break;}
case 170:
#line 707 "sparql_parser.y"
{yyval.id = new_list_and_merge(mk_str("isIRI("),yyvsp[-1].id,gCloseB,T_LST_END);;
    break;}
case 171:
#line 709 "sparql_parser.y"
{yyval.id = new_list_and_merge(mk_str("isIRI("),yyvsp[-1].id,gCloseB,T_LST_END);;
    break;}
case 172:
#line 711 "sparql_parser.y"
{yyval.id = new_list_and_merge(mk_str("isBlnk("),yyvsp[-1].id,gCloseB,T_LST_END);;
    break;}
case 173:
#line 713 "sparql_parser.y"
{yyval.id = new_list_and_merge(mk_str("isLtrl("),yyvsp[-1].id,gCloseB,T_LST_END);;
    break;}
case 174:
#line 715 "sparql_parser.y"
{;
    break;}
case 175:
#line 722 "sparql_parser.y"
{yyval.id = new_list_and_merge(mk_str("like("),yyvsp[-3].id,
										gComma,yyvsp[-1].id,gCloseB,T_LST_END);;
    break;}
case 176:
#line 737 "sparql_parser.y"
{yyval.id=yyvsp[0].id;;
    break;}
case 177:
#line 739 "sparql_parser.y"
{NOT_SUPPORT("IRI(...)");;
    break;}
case 178:
#line 743 "sparql_parser.y"
{yyval.id=mk_plain_ltr(yyvsp[0].id, NULL);;
    break;}
case 179:
#line 745 "sparql_parser.y"
{yyval.id=mk_plain_ltr(yyvsp[-1].id, SparQLtext);;
    break;}
case 180:
#line 747 "sparql_parser.y"
{yyval.id=mk_ltr2(yyvsp[-2].id, yyvsp[0].id);;
    break;}
case 181:
#line 752 "sparql_parser.y"
{yyval.id = mk_ltr(SparQLtext,L_INT);;
    break;}
case 182:
#line 754 "sparql_parser.y"
{yyval.id = mk_ltr(SparQLtext,L_DEC);;
    break;}
case 183:
#line 756 "sparql_parser.y"
{yyval.id = mk_ltr(SparQLtext,L_DBL);;
    break;}
case 184:
#line 761 "sparql_parser.y"
{yyval.id = mk_ltr(SparQLtext,L_BOOL);;
    break;}
case 185:
#line 763 "sparql_parser.y"
{yyval.id = mk_ltr(SparQLtext,L_BOOL);;
    break;}
case 186:
#line 768 "sparql_parser.y"
{yyval.id = yyvsp[0].id;;
    break;}
case 187:
#line 770 "sparql_parser.y"
{;
    break;}
case 188:
#line 772 "sparql_parser.y"
{;
    break;}
case 189:
#line 777 "sparql_parser.y"
{yyval.id = yyvsp[0].id;;
    break;}
case 190:
#line 779 "sparql_parser.y"
{yyval.id = yyvsp[0].id;;
    break;}
case 191:
#line 784 "sparql_parser.y"
{yyval.id = get_prfx_uri(yyvsp[0].id);;
    break;}
case 192:
#line 786 "sparql_parser.y"
{yyval.id = map_prfx_uri(yyvsp[-1].id, SparQLtext);;
    break;}
case 193:
#line 788 "sparql_parser.y"
{yyval.id = map_prfx_uri(yyvsp[-1].id, "a");;
    break;}
case 194:
#line 793 "sparql_parser.y"
{NOT_SUPPORT("BLANK_NODE_LABEL");;
    break;}
case 195:
#line 795 "sparql_parser.y"
{yyval.id=mk_bkv();;
    break;}
case 196:
#line 803 "sparql_parser.y"
{
							if (bInProlog) 
								yyval.id = mk_str(":");
							else
								yyval.id = find_prfx(":");
						;
    break;}
case 197:
#line 810 "sparql_parser.y"
{
							if (bInProlog)
								yyval.id = mk_str(SparQLtext);
							else
								yyval.id = find_prfx(SparQLtext);
						;
    break;}
}
   /* the action file gets copied in in place of this dollarsign */
#line 487 "bison.simple"

  yyvsp -= yylen;
  yyssp -= yylen;
#ifdef YYLSP_NEEDED
  yylsp -= yylen;
#endif

#if YYDEBUG != 0
  if (yydebug)
    {
      short *ssp1 = yyss - 1;
      fprintf (stderr, "state stack now");
      while (ssp1 != yyssp)
	fprintf (stderr, " %d", *++ssp1);
      fprintf (stderr, "\n");
    }
#endif

  *++yyvsp = yyval;

#ifdef YYLSP_NEEDED
  yylsp++;
  if (yylen == 0)
    {
      yylsp->first_line = yylloc.first_line;
      yylsp->first_column = yylloc.first_column;
      yylsp->last_line = (yylsp-1)->last_line;
      yylsp->last_column = (yylsp-1)->last_column;
      yylsp->text = 0;
    }
  else
    {
      yylsp->last_line = (yylsp+yylen-1)->last_line;
      yylsp->last_column = (yylsp+yylen-1)->last_column;
    }
#endif

  /* Now "shift" the result of the reduction.
     Determine what state that goes to,
     based on the state we popped back to
     and the rule number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTBASE] + *yyssp;
  if (yystate >= 0 && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTBASE];

  goto yynewstate;

yyerrlab:   /* here on detecting error */

  if (! yyerrstatus)
    /* If not already recovering from an error, report this error.  */
    {
      ++yynerrs;

#ifdef YYERROR_VERBOSE
      yyn = yypact[yystate];

      if (yyn > YYFLAG && yyn < YYLAST)
	{
	  int size = 0;
	  char *msg;
	  int x, count;

	  count = 0;
	  /* Start X at -yyn if nec to avoid negative indexes in yycheck.  */
	  for (x = (yyn < 0 ? -yyn : 0);
	       x < (sizeof(yytname) / sizeof(char *)); x++)
	    if (yycheck[x + yyn] == x)
	      size += strlen(yytname[x]) + 15, count++;
	  msg = (char *) malloc(size + 15);
	  if (msg != 0)
	    {
	      strcpy(msg, "parse error");

	      if (count < 5)
		{
		  count = 0;
		  for (x = (yyn < 0 ? -yyn : 0);
		       x < (sizeof(yytname) / sizeof(char *)); x++)
		    if (yycheck[x + yyn] == x)
		      {
			strcat(msg, count == 0 ? ", expecting `" : " or `");
			strcat(msg, yytname[x]);
			strcat(msg, "'");
			count++;
		      }
		}
	      yyerror(msg);
	      free(msg);
	    }
	  else
	    yyerror ("parse error; also virtual memory exceeded");
	}
      else
#endif /* YYERROR_VERBOSE */
	yyerror("parse error");
    }

  goto yyerrlab1;
yyerrlab1:   /* here on error raised explicitly by an action */

  if (yyerrstatus == 3)
    {
      /* if just tried and failed to reuse lookahead token after an error, discard it.  */

      /* return failure if at end of input */
      if (yychar == YYEOF)
	YYABORT;

#if YYDEBUG != 0
      if (yydebug)
	fprintf(stderr, "Discarding token %d (%s).\n", yychar, yytname[yychar1]);
#endif

      yychar = YYEMPTY;
    }

  /* Else will try to reuse lookahead token
     after shifting the error token.  */

  yyerrstatus = 3;		/* Each real token shifted decrements this */

  goto yyerrhandle;

yyerrdefault:  /* current state does not do anything special for the error token. */

#if 0
  /* This is wrong; only states that explicitly want error tokens
     should shift them.  */
  yyn = yydefact[yystate];  /* If its default is to accept any token, ok.  Otherwise pop it.*/
  if (yyn) goto yydefault;
#endif

yyerrpop:   /* pop the current state because it cannot handle the error token */

  if (yyssp == yyss) YYABORT;
  yyvsp--;
  yystate = *--yyssp;
#ifdef YYLSP_NEEDED
  yylsp--;
#endif

#if YYDEBUG != 0
  if (yydebug)
    {
      short *ssp1 = yyss - 1;
      fprintf (stderr, "Error: state stack now");
      while (ssp1 != yyssp)
	fprintf (stderr, " %d", *++ssp1);
      fprintf (stderr, "\n");
    }
#endif

yyerrhandle:

  yyn = yypact[yystate];
  if (yyn == YYFLAG)
    goto yyerrdefault;

  yyn += YYTERROR;
  if (yyn < 0 || yyn > YYLAST || yycheck[yyn] != YYTERROR)
    goto yyerrdefault;

  yyn = yytable[yyn];
  if (yyn < 0)
    {
      if (yyn == YYFLAG)
	goto yyerrpop;
      yyn = -yyn;
      goto yyreduce;
    }
  else if (yyn == 0)
    goto yyerrpop;

  if (yyn == YYFINAL)
    YYACCEPT;

#if YYDEBUG != 0
  if (yydebug)
    fprintf(stderr, "Shifting error token, ");
#endif

  *++yyvsp = yylval;
#ifdef YYLSP_NEEDED
  *++yylsp = yylloc;
#endif

  yystate = yyn;
  goto yynewstate;
}
#line 851 "sparql_parser.y"



