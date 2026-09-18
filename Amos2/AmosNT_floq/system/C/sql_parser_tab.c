
/*  A Bison parser, made from sql_parser.y with Bison version GNU Bison version 1.24
  */

#define YYBISON 1  /* Identify Bison output.  */

#define yyparse SQLparse
#define yylex SQLlex
#define yyerror SQLerror
#define yylval SQLlval
#define yychar SQLchar
#define yydebug SQLdebug
#define yynerrs SQLnerrs
#define	NAME	258
#define	COLUMN	259
#define	STRING	260
#define	INTNUM	261
#define	APPROXNUM	262
#define	OR	263
#define	AND	264
#define	NOT	265
#define	EQ	266
#define	NEQ	267
#define	LT	268
#define	GT	269
#define	LTE	270
#define	GTE	271
#define	UMINUS	272
#define	ALL	273
#define	AMMSC	274
#define	AS	275
#define	ASC	276
#define	AVG	277
#define	BETWEEN	278
#define	BOOLEAN	279
#define	BY	280
#define	CHARACTER	281
#define	CASCADE	282
#define	CASE	283
#define	CHECK	284
#define	CLOB	285
#define	COMMIT	286
#define	CONSTRAINT	287
#define	COUNT	288
#define	CREATE	289
#define	CROSS	290
#define	DESC	291
#define	DECIMAL	292
#define	DEFAULT	293
#define	_DELETE	294
#define	DISTINCT	295
#define	DOUBLE	296
#define	DROP	297
#define	ELSE	298
#define	END	299
#define	ESCAPE	300
#define	EXISTS	301
#define	_FALSE	302
#define	FLOAT	303
#define	FOREIGN	304
#define	FROM	305
#define	GROUP	306
#define	HAVING	307
#define	_IN	308
#define	INDICATOR	309
#define	INNER	310
#define	INSERT	311
#define	INTEGER	312
#define	INTO	313
#define	IS	314
#define	JOIN	315
#define	KEY	316
#define	LIKE	317
#define	MAX	318
#define	MIN	319
#define	NATRUAL	320
#define	_NULL	321
#define	_NUMERIC	322
#define	OID	323
#define	ON	324
#define	ORDER	325
#define	PARAM	326
#define	PARAMETER	327
#define	PRECISION	328
#define	PRIMARY	329
#define	REAL	330
#define	REFERENCES	331
#define	RESTRICT	332
#define	ROLLBACK	333
#define	SCHEMA	334
#define	SELECT	335
#define	SET	336
#define	SUM	337
#define	TABLE	338
#define	THEN	339
#define	_TRUE	340
#define	UNION	341
#define	UNIQUE	342
#define	UPDATE	343
#define	USER	344
#define	VALUES	345
#define	VARCHAR	346
#define	VARYING	347
#define	WHEN	348
#define	WHERE	349
#define	WORK	350
#define	_EOF	351
#define	_QUIT	352
#define	ISTREAM	353
#define	DSTREAM	354
#define	RSTREAM	355
#define	NOW	356
#define	PARTITION	357
#define	ROWS	358
#define	RANGE	359
#define	SECONDS	360
#define	MINUTES	361
#define	INN	362

#line 13 "sql_parser.y"

#include "alisp.h"
  extern char *SQLtext;      /* Defined in the lexer */
  extern char *myinputptr;   /* Where the SQL string to parse is */
  extern int mybufsize;      /* Size of SQL string */
  oidtype sql_statement=nil; /* The parsed SQL form */
  extern oidtype _oidrefs_;  /* List of objects created during parsing */

#define SAVE_REF a_setf(globval(_oidrefs_),\
                        cons(yyval.oidval,globval(_oidrefs_)))
#define reverse(x)nreversefn(varstack,x)

#line 28 "sql_parser.y"
typedef union { oidtype oidval; } YYSTYPE;

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



#define	YYFINAL		405
#define	YYFLAG		-32768
#define	YYNTBASE	119

#define YYTRANSLATE(x) ((unsigned)(x) <= 362 ? yytranslate[x] : 195)

static const char yytranslate[] = {     0,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,   114,
   115,    19,    17,   113,    18,   116,    20,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,   112,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
   117,     2,   118,     2,     2,     2,     2,     2,     2,     2,
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
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     1,     2,     3,     4,     5,
     6,     7,     8,     9,    10,    11,    12,    13,    14,    15,
    16,    21,    22,    23,    24,    25,    26,    27,    28,    29,
    30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
    40,    41,    42,    43,    44,    45,    46,    47,    48,    49,
    50,    51,    52,    53,    54,    55,    56,    57,    58,    59,
    60,    61,    62,    63,    64,    65,    66,    67,    68,    69,
    70,    71,    72,    73,    74,    75,    76,    77,    78,    79,
    80,    81,    82,    83,    84,    85,    86,    87,    88,    89,
    90,    91,    92,    93,    94,    95,    96,    97,    98,    99,
   100,   101,   102,   103,   104,   105,   106,   107,   108,   109,
   110,   111
};

#if YYDEBUG != 0
static const short yyprhs[] = {     0,
     0,     3,     5,     7,     9,    11,    13,    15,    17,    19,
    21,    23,    25,    27,    28,    30,    33,    36,    41,    42,
    44,    46,    49,    50,    52,    55,    61,    63,    67,    68,
    72,    77,    84,    85,    89,    91,    95,    99,   105,   112,
   114,   118,   120,   122,   127,   129,   132,   135,   136,   140,
   142,   148,   150,   152,   155,   157,   159,   161,   163,   166,
   168,   170,   172,   173,   176,   178,   180,   182,   184,   186,
   188,   190,   191,   193,   195,   198,   202,   204,   207,   210,
   212,   216,   221,   225,   227,   233,   238,   247,   249,   253,
   254,   258,   267,   268,   270,   272,   275,   277,   281,   288,
   294,   299,   301,   304,   308,   310,   311,   314,   315,   319,
   321,   325,   326,   329,   330,   334,   337,   342,   343,   345,
   347,   349,   354,   356,   360,   362,   364,   366,   368,   371,
   375,   377,   381,   385,   389,   393,   397,   401,   404,   407,
   409,   411,   413,   415,   417,   421,   426,   433,   438,   443,
   449,   455,   461,   467,   472,   478,   484,   489,   495,   501,
   507,   512,   514,   517,   522,   524,   527,   532,   533,   536,
   538,   540,   544,   550,   554,   558,   561,   565,   567,   569,
   571,   575,   579,   585,   592,   596,   601,   607,   614,   617,
   621,   623,   625,   627,   629,   633,   638,   640,   642,   646,
   651,   654,   656,   658,   660,   662,   664,   666,   668
};

static const short yyrhs[] = {   120,
   121,     0,   100,     0,     1,     0,   156,     0,   136,     0,
   132,     0,   131,     0,   128,     0,   127,     0,   125,     0,
   123,     0,   122,     0,   101,     0,     0,   112,     0,    83,
     3,     0,    83,    42,     0,    46,    87,   190,   124,     0,
     0,    81,     0,    31,     0,    82,   126,     0,     0,    99,
     0,    35,   126,     0,    92,   190,    85,   129,   162,     0,
   130,     0,   129,   113,   130,     0,     0,     3,    11,   173,
     0,    43,    54,   190,   162,     0,    60,    62,   190,   133,
    94,   135,     0,     0,   114,   134,   115,     0,     3,     0,
   134,   113,     3,     0,   114,   174,   115,     0,   135,   113,
   114,   174,   115,     0,    38,    87,   190,   114,   137,   115,
     0,   138,     0,   137,   113,   138,     0,   139,     0,   152,
     0,     3,   140,   146,   148,     0,   143,     0,   144,   141,
     0,   145,   142,     0,     0,   114,     6,   115,     0,   141,
     0,   114,     6,   113,     6,   115,     0,    61,     0,    79,
     0,    45,    77,     0,    28,     0,    52,     0,    30,     0,
    95,     0,    30,    96,     0,    34,     0,    71,     0,    41,
     0,     0,    42,   147,     0,     5,     0,     6,     0,     7,
     0,    89,     0,    51,     0,     3,     0,    70,     0,     0,
   149,     0,   150,     0,   149,   150,     0,    36,     3,   151,
     0,   151,     0,    10,    70,     0,    78,    65,     0,    91,
     0,    80,   190,   155,     0,    33,   114,   184,   115,     0,
    36,     3,   153,     0,   153,     0,    78,    65,   114,   154,
   115,     0,    91,   114,   164,   115,     0,    53,    65,   114,
   164,   115,    80,   190,   155,     0,     3,     0,   154,   113,
     3,     0,     0,   114,   164,   115,     0,    84,   157,   169,
   158,   162,   163,   165,   166,     0,     0,    22,     0,    44,
     0,    54,   159,     0,   160,     0,   159,   113,   160,     0,
   159,    59,    64,   160,    73,   184,     0,   159,    64,   160,
    73,   184,     0,   159,    39,    64,   160,     0,   190,     0,
   190,   161,     0,   190,    24,   161,     0,     3,     0,     0,
    98,   184,     0,     0,    55,    29,   164,     0,   183,     0,
   164,   113,   183,     0,     0,    56,   184,     0,     0,    74,
    29,   167,     0,   173,   168,     0,   167,   113,   173,   168,
     0,     0,    25,     0,    40,     0,   170,     0,   171,   114,
   170,   115,     0,   172,     0,   169,   113,   172,     0,   102,
     0,   103,     0,   104,     0,   173,     0,   173,     3,     0,
   173,    24,     3,     0,    19,     0,     3,   116,    19,     0,
   173,    17,   173,     0,   173,    18,   173,     0,   173,    19,
   173,     0,   173,    20,   173,     0,   114,   173,   115,     0,
    17,   173,     0,    18,   173,     0,   182,     0,   183,     0,
   175,     0,   176,     0,   173,     0,   174,   113,   173,     0,
     3,   114,   173,   115,     0,     3,   114,   173,   113,   173,
   115,     0,    37,   114,   173,   115,     0,    37,   114,    19,
   115,     0,    37,   114,    22,   173,   115,     0,    37,   114,
    44,   173,   115,     0,    68,   114,   157,   173,   115,     0,
    67,   114,   157,   173,   115,     0,    26,   114,   173,   115,
     0,    26,   114,    22,   173,   115,     0,    26,   114,    44,
   173,   115,     0,    86,   114,   173,   115,     0,    86,   114,
    22,   173,   115,     0,    86,   114,    44,   173,   115,     0,
    32,   173,   177,   181,    48,     0,    32,   179,   181,    48,
     0,   178,     0,   177,   178,     0,    97,   173,    88,   173,
     0,   180,     0,   179,   180,     0,    97,   186,    88,   173,
     0,     0,    47,   173,     0,   189,     0,     3,     0,     3,
   116,     3,     0,     3,   116,     3,   116,     3,     0,   184,
     9,   184,     0,   184,     8,   184,     0,    10,   184,     0,
   114,   184,   115,     0,   185,     0,   186,     0,   187,     0,
   173,   194,   173,     0,   173,   194,   188,     0,   173,    27,
   173,     9,   173,     0,   173,    10,    27,   173,     9,   173,
     0,   173,    66,     5,     0,   173,    10,    66,     5,     0,
   173,    57,   114,   174,   115,     0,   173,    10,    57,   114,
   174,   115,     0,    50,   188,     0,   114,   156,   115,     0,
     5,     0,     6,     0,     7,     0,     3,     0,     3,   116,
     3,     0,     3,   117,   191,   118,     0,   192,     0,   105,
     0,   108,     6,   193,     0,   106,    29,   164,   192,     0,
   107,     6,     0,   109,     0,   110,     0,    11,     0,    12,
     0,    13,     0,    14,     0,    15,     0,    16,     0
};

#endif

#if YYDEBUG != 0
static const short yyrline[] = { 0,
    78,    85,    90,    98,   100,   103,   106,   109,   112,   115,
   118,   121,   124,   128,   128,   134,   142,   154,   162,   164,
   166,   172,   178,   178,   184,   192,   206,   212,   221,   222,
   232,   243,   254,   255,   263,   268,   277,   282,   292,   302,
   307,   315,   317,   321,   330,   335,   341,   349,   350,   357,
   358,   366,   367,   368,   369,   372,   373,   374,   375,   379,
   382,   383,   386,   388,   395,   396,   397,   398,   399,   400,
   401,   404,   406,   410,   413,   417,   419,   424,   429,   435,
   441,   448,   456,   464,   473,   479,   485,   496,   501,   509,
   511,   518,   562,   563,   565,   569,   576,   581,   586,   597,
   608,   621,   626,   631,   638,   642,   644,   648,   650,   657,
   662,   670,   672,   676,   678,   685,   690,   698,   700,   702,
   706,   708,   714,   719,   727,   729,   731,   735,   737,   740,
   743,   746,   754,   760,   766,   772,   778,   780,   782,   787,
   789,   791,   795,   799,   804,   812,   817,   823,   829,   835,
   841,   847,   853,   859,   865,   871,   877,   883,   889,   903,
   910,   919,   921,   926,   933,   935,   938,   945,   947,   955,
   959,   966,   976,   988,   995,  1001,  1006,  1008,  1013,  1015,
  1019,  1024,  1029,  1035,  1042,  1060,  1079,  1085,  1093,  1100,
  1104,  1106,  1108,  1112,  1114,  1121,  1128,  1130,  1132,  1137,
  1144,  1151,  1153,  1158,  1160,  1162,  1164,  1166,  1168
};

static const char * const yytname[] = {   "$","error","$undefined.","NAME","COLUMN",
"STRING","INTNUM","APPROXNUM","OR","AND","NOT","EQ","NEQ","LT","GT","LTE","GTE",
"'+'","'-'","'*'","'/'","UMINUS","ALL","AMMSC","AS","ASC","AVG","BETWEEN","BOOLEAN",
"BY","CHARACTER","CASCADE","CASE","CHECK","CLOB","COMMIT","CONSTRAINT","COUNT",
"CREATE","CROSS","DESC","DECIMAL","DEFAULT","_DELETE","DISTINCT","DOUBLE","DROP",
"ELSE","END","ESCAPE","EXISTS","_FALSE","FLOAT","FOREIGN","FROM","GROUP","HAVING",
"_IN","INDICATOR","INNER","INSERT","INTEGER","INTO","IS","JOIN","KEY","LIKE",
"MAX","MIN","NATRUAL","_NULL","_NUMERIC","OID","ON","ORDER","PARAM","PARAMETER",
"PRECISION","PRIMARY","REAL","REFERENCES","RESTRICT","ROLLBACK","SCHEMA","SELECT",
"SET","SUM","TABLE","THEN","_TRUE","UNION","UNIQUE","UPDATE","USER","VALUES",
"VARCHAR","VARYING","WHEN","WHERE","WORK","_EOF","_QUIT","ISTREAM","DSTREAM",
"RSTREAM","NOW","PARTITION","ROWS","RANGE","SECONDS","MINUTES","INN","';'","','",
"'('","')'","'.'","'['","']'","sql","stmt","opt_semicolon","set_schema_statement",
"drop_statement","opt_drop_type","rollback_statement","opt_work_keyword","commit_statement",
"update_statement","update_column_commalist","update_column","delete_statement",
"insert_statement","opt_columns","column_commalist","values_commalist","create_table_statement",
"tbl_element_commalist","table_element","column_definition","data_type","opt_type_param1",
"opt_type_param2","type0","type1","type2","opt_default_spec","default_value",
"opt_col_constraints","col_constraints_list","col_constraint","simple_col_constraint",
"table_constraint","simple_table_constraint","local_column_refs","opt_col_ref",
"select_statement","opt_all_distinct","from_clause","table_ref_commalist","table_ref",
"range_variable","opt_where_clause","opt_group_by_clause","column_ref_commalist",
"opt_having_clause","opt_order_by_clause","order_ref_commalist","order_dir",
"selection","projection","relation_to_stream","selection_item","scalar_exp",
"scalar_exp_commalist","function_ref","case_stmt","when_stmt_list","when_stmt",
"cond_stmt_list","cond_stmt","opt_else_stmt","atom","column_ref","search_condition",
"predicate","comparison_predicate","existence_test","subquery","literal","table",
"window","rows_window","time_unit","comparison",""
};
#endif

static const short yyr1[] = {     0,
   119,   119,   119,   120,   120,   120,   120,   120,   120,   120,
   120,   120,   120,   121,   121,   122,   122,   123,   124,   124,
   124,   125,   126,   126,   127,   128,   129,   129,   130,   130,
   131,   132,   133,   133,   134,   134,   135,   135,   136,   137,
   137,   138,   138,   139,   140,   140,   140,   141,   141,   142,
   142,   143,   143,   143,   143,   144,   144,   144,   144,   144,
   145,   145,   146,   146,   147,   147,   147,   147,   147,   147,
   147,   148,   148,   149,   149,   150,   150,   151,   151,   151,
   151,   151,   152,   152,   153,   153,   153,   154,   154,   155,
   155,   156,   157,   157,   157,   158,   159,   159,   159,   159,
   159,   160,   160,   160,   161,   162,   162,   163,   163,   164,
   164,   165,   165,   166,   166,   167,   167,   168,   168,   168,
   169,   169,   170,   170,   171,   171,   171,   172,   172,   172,
   172,   172,   173,   173,   173,   173,   173,   173,   173,   173,
   173,   173,   173,   174,   174,   175,   175,   175,   175,   175,
   175,   175,   175,   175,   175,   175,   175,   175,   175,   176,
   176,   177,   177,   178,   179,   179,   180,   181,   181,   182,
   183,   183,   183,   184,   184,   184,   184,   184,   185,   185,
   186,   186,   186,   186,   186,   186,   186,   186,   187,   188,
   189,   189,   189,   190,   190,   190,   191,   191,   191,   191,
   192,   193,   193,   194,   194,   194,   194,   194,   194
};

static const short yyr2[] = {     0,
     2,     1,     1,     1,     1,     1,     1,     1,     1,     1,
     1,     1,     1,     0,     1,     2,     2,     4,     0,     1,
     1,     2,     0,     1,     2,     5,     1,     3,     0,     3,
     4,     6,     0,     3,     1,     3,     3,     5,     6,     1,
     3,     1,     1,     4,     1,     2,     2,     0,     3,     1,
     5,     1,     1,     2,     1,     1,     1,     1,     2,     1,
     1,     1,     0,     2,     1,     1,     1,     1,     1,     1,
     1,     0,     1,     1,     2,     3,     1,     2,     2,     1,
     3,     4,     3,     1,     5,     4,     8,     1,     3,     0,
     3,     8,     0,     1,     1,     2,     1,     3,     6,     5,
     4,     1,     2,     3,     1,     0,     2,     0,     3,     1,
     3,     0,     2,     0,     3,     2,     4,     0,     1,     1,
     1,     4,     1,     3,     1,     1,     1,     1,     2,     3,
     1,     3,     3,     3,     3,     3,     3,     2,     2,     1,
     1,     1,     1,     1,     3,     4,     6,     4,     4,     5,
     5,     5,     5,     4,     5,     5,     4,     5,     5,     5,
     4,     1,     2,     4,     1,     2,     4,     0,     2,     1,
     1,     3,     5,     3,     3,     2,     3,     1,     1,     1,
     3,     3,     5,     6,     3,     4,     5,     6,     2,     3,
     1,     1,     1,     1,     3,     4,     1,     1,     3,     4,
     2,     1,     1,     1,     1,     1,     1,     1,     1
};

static const short yydefact[] = {     0,
     3,    23,     0,     0,     0,     0,    23,     0,    93,     0,
     2,    13,    14,    12,    11,    10,     9,     8,     7,     6,
     5,     4,    24,    25,     0,     0,     0,     0,    22,    16,
    17,    94,    95,     0,   194,     0,    15,     1,     0,   106,
    19,    33,   171,   191,   192,   193,     0,     0,   131,     0,
     0,     0,     0,     0,     0,   125,   126,   127,     0,     0,
   121,     0,   123,   128,   142,   143,   140,   141,   170,     0,
     0,    29,     0,     0,    31,    21,    20,    18,     0,     0,
     0,     0,   171,   138,   139,     0,     0,     0,   168,   165,
     0,    93,    93,     0,     0,     0,     0,   106,     0,   129,
     0,     0,     0,     0,     0,   195,   198,     0,     0,     0,
     0,   197,     0,   106,    27,     0,     0,     0,     0,     0,
     0,    40,    42,    43,    84,     0,     0,     0,     0,   107,
   178,   179,   180,    35,     0,     0,     0,   172,   132,     0,
     0,     0,     0,     0,     0,   168,   162,     0,   166,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,   137,
    96,    97,   102,   124,   108,     0,   121,   133,   134,   135,
   136,   130,     0,   201,     0,   196,     0,    29,    26,    55,
    57,    60,    62,     0,    56,    52,    61,    53,    58,    63,
    45,    48,    48,     0,     0,     0,     0,     0,    39,   176,
     0,   189,     0,     0,     0,   204,   205,   206,   207,   208,
   209,     0,     0,     0,     0,     0,     0,     0,    34,     0,
    32,     0,   146,     0,     0,     0,   154,     0,     0,   163,
     0,   169,   161,   149,     0,     0,   148,     0,     0,     0,
     0,   157,     0,     0,     0,     0,   105,     0,   103,     0,
   112,   122,   171,     0,   110,   202,   203,   199,    30,    28,
    59,    54,     0,    72,     0,    46,     0,    50,    47,    83,
     0,     0,     0,    41,     0,   177,     0,     0,     0,     0,
     0,   185,     0,   181,   182,   175,   174,    36,   144,     0,
     0,     0,   173,   155,   156,   167,     0,   160,   150,   151,
   153,   152,   158,   159,     0,     0,     0,    98,   104,     0,
     0,   114,     0,   200,    70,    65,    66,    67,    69,    71,
    68,    64,     0,     0,     0,     0,     0,    80,    44,    73,
    74,    77,     0,     0,     0,    88,     0,    86,   190,     0,
     0,   186,     0,     0,     0,    37,     0,   147,   164,   101,
     0,     0,   109,   113,     0,    92,   111,    78,     0,     0,
    79,    90,    75,    49,     0,     0,     0,    85,     0,     0,
   183,   187,   145,     0,     0,   100,     0,     0,    76,     0,
    81,     0,     0,    89,   184,   188,    38,    99,   115,   118,
    82,     0,    51,    90,     0,   119,   120,   116,    91,    87,
   118,   117,     0,     0,     0
};

static const short yydefgoto[] = {   403,
    13,    38,    14,    15,    78,    16,    24,    17,    18,   114,
   115,    19,    20,    80,   135,   221,    21,   121,   122,   123,
   190,   266,   269,   191,   192,   193,   264,   322,   329,   330,
   331,   332,   124,   125,   337,   381,   275,    34,    98,   161,
   162,   249,    75,   251,   254,   312,   356,   389,   398,    60,
    61,    62,    63,   129,   290,    65,    66,   146,   147,    89,
    90,   150,    67,    68,   130,   131,   132,   133,   202,    69,
   163,   111,   112,   258,   215
};

static const short yypact[] = {   446,
-32768,   -60,   -39,     2,   -25,    22,   -60,    47,   -17,    95,
-32768,-32768,    -5,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,-32768,-32768,    95,    95,    95,    95,-32768,-32768,
-32768,-32768,-32768,   129,   -64,    54,-32768,-32768,    35,    88,
   -23,   115,   108,-32768,-32768,-32768,   426,   426,-32768,   120,
   326,   126,   130,   139,   144,-32768,-32768,-32768,   426,   -42,
-32768,   148,-32768,   558,-32768,-32768,-32768,-32768,-32768,   187,
   112,   199,   368,    23,-32768,-32768,-32768,-32768,   245,   175,
   426,   103,   131,   125,   125,   260,   426,   436,   -36,-32768,
   220,   -17,   -17,   293,    18,    95,   359,    88,   129,-32768,
   426,   426,   426,   426,   272,-32768,-32768,   247,   274,   278,
   167,-32768,   283,   -79,-32768,   470,   299,   243,   248,   195,
   146,-32768,-32768,-32768,-32768,    23,   198,    23,   540,   159,
-32768,-32768,-32768,-32768,   168,   212,    27,   219,-32768,   333,
   426,   426,    77,   261,   426,   -16,-32768,   426,-32768,   300,
   241,   426,   426,    85,   426,   426,   426,   426,   134,-32768,
   177,-32768,    76,-32768,   312,   262,   269,   125,   125,-32768,
-32768,-32768,   384,-32768,    89,-32768,   426,   199,-32768,-32768,
   296,-32768,-32768,   325,-32768,-32768,-32768,-32768,-32768,   356,
-32768,   292,   297,   116,   302,   303,   384,   368,-32768,-32768,
   329,-32768,   164,     1,    51,-32768,-32768,-32768,-32768,-32768,
-32768,   426,   308,   409,   459,    23,    23,   421,-32768,   426,
   315,   426,-32768,   422,   140,   145,-32768,   426,    68,-32768,
   382,   517,-32768,-32768,   153,   186,-32768,   192,   254,   304,
   321,-32768,   370,   371,    95,    95,-32768,   435,-32768,   410,
   385,-32768,   332,   -56,-32768,-32768,-32768,-32768,   517,-32768,
-32768,-32768,   348,    32,   443,-32768,   451,-32768,-32768,-32768,
   384,   439,   176,-32768,   345,-32768,   426,   347,   463,   490,
   426,-32768,   383,   517,-32768,   461,-32768,-32768,   517,   180,
   357,   363,-32768,-32768,-32768,   517,   426,-32768,-32768,-32768,
-32768,-32768,-32768,-32768,    95,    95,   399,-32768,-32768,   384,
    23,   400,   384,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
-32768,-32768,   405,   365,   477,   417,    95,-32768,-32768,    32,
-32768,-32768,   372,   190,   232,-32768,   244,-32768,-32768,   570,
   426,-32768,   426,   257,   426,-32768,   426,-32768,   517,-32768,
   413,    23,   375,   159,   454,-32768,-32768,-32768,    23,    33,
-32768,   376,-32768,-32768,   489,   423,   498,-32768,   426,   282,
   517,-32768,   517,   290,    23,   159,   426,     5,-32768,   384,
-32768,   387,    95,-32768,   517,-32768,-32768,   159,   392,   499,
-32768,   295,-32768,   376,   426,-32768,-32768,-32768,-32768,-32768,
   499,-32768,   513,   514,-32768
};

static const short yypgoto[] = {-32768,
-32768,-32768,-32768,-32768,-32768,-32768,   516,-32768,-32768,-32768,
   342,-32768,-32768,-32768,-32768,-32768,-32768,-32768,   323,-32768,
-32768,   339,-32768,-32768,-32768,-32768,-32768,-32768,-32768,-32768,
   213,   165,-32768,   350,-32768,   154,   542,   121,-32768,-32768,
  -223,   314,    29,-32768,  -191,-32768,-32768,-32768,   162,   465,
   467,-32768,   471,   -27,  -278,-32768,-32768,-32768,   424,-32768,
   480,   425,-32768,  -172,  -124,-32768,   485,-32768,   366,-32768,
   -10,-32768,   320,-32768,-32768
};


#define	YYLAST		606


static const short yytable[] = {    36,
   255,   200,   344,   204,    32,   273,    64,    76,   216,   217,
   148,    96,   216,   217,    39,    40,    41,    42,    74,    84,
    85,   307,   308,    88,   255,    83,    33,    44,    45,    46,
   148,    95,   126,   178,   101,   102,   103,   104,    23,    47,
    48,   323,   323,   101,   102,   103,   104,    25,    50,    30,
   109,    70,    71,   137,    51,    26,   313,    77,   143,    52,
    87,    27,   370,   154,   324,   324,   159,   325,   374,    64,
    97,    64,   127,   168,   169,   170,   171,   277,   247,   335,
   145,   350,   351,    28,   101,   102,   103,   104,    31,    53,
    54,   286,   287,   101,   102,   103,   104,    35,   255,   248,
   203,   101,   102,   103,   104,   138,    37,   278,    55,   326,
   326,   327,   327,   225,   226,   276,   279,   229,   353,   391,
   232,   139,   328,   328,   235,   236,   165,   238,   239,   240,
   241,    43,   160,    44,    45,    46,   128,   255,    72,   222,
   357,   223,   179,   103,   104,    47,    48,    49,    73,   259,
   101,   102,   103,   104,    50,   297,   101,   102,   103,   104,
    51,   101,   102,   103,   104,    52,   216,   217,   118,   101,
   102,   103,   104,   205,   206,   207,   208,   209,   210,   211,
   101,   102,   103,   104,   280,    74,   354,   284,   392,   106,
   212,   227,   289,   119,   292,    53,    54,   256,   257,   237,
   296,   113,   101,   102,   103,   104,   120,   255,   101,   102,
   103,   104,   155,   156,    55,   243,   107,   108,   109,   110,
   213,    81,    83,    82,    44,    45,    46,   376,    79,   214,
    56,    57,    58,    86,   378,   244,    47,    48,   151,    91,
   245,   152,    59,    92,    81,    50,   140,   134,   242,   340,
   388,    51,    93,   289,   294,    95,    52,    94,   198,   295,
   199,    99,    83,   153,    44,    45,    46,   299,   136,   349,
   101,   102,   103,   104,   172,   173,    47,    48,   160,   174,
   218,   141,   219,   175,   176,    50,    53,    54,   313,   246,
   338,    51,   345,   177,   346,    83,    52,    44,    45,    46,
   300,   194,   365,   142,   364,    55,   301,   195,   197,    47,
    48,   201,   196,   289,   157,   371,   362,   373,    50,   289,
   101,   102,   103,   104,    51,   220,    53,    54,    83,    52,
    44,    45,    46,    59,   224,   138,   158,   101,   102,   103,
   104,   385,    47,    48,   313,    55,   366,   233,   228,   390,
   315,    50,   316,   317,   318,   234,   367,    51,   368,    53,
    54,    43,    52,    44,    45,    46,   250,   401,   302,   345,
   116,   372,   394,    59,    97,    47,    48,    49,    55,   101,
   102,   103,   104,   252,    50,    83,   253,    44,    45,    46,
    51,   261,    53,    54,   345,    52,   386,   263,   319,    47,
    48,   262,   345,   117,   387,   265,    59,   313,    50,   399,
   267,    55,     9,   282,    51,   271,   272,   320,   303,    52,
   118,   281,    87,   288,   293,    53,    54,   291,    83,   298,
    44,    45,    46,   305,   306,   304,   321,   247,   310,    59,
   311,   336,    47,    48,    55,   119,     1,   140,   333,    53,
    54,    50,   101,   102,   103,   104,   334,    51,   120,   339,
   341,    83,    52,    44,    45,    46,     9,   342,    55,   217,
   347,   352,    59,   355,   358,    47,    48,   348,   359,   360,
     2,   361,   377,     3,    50,   375,   364,   313,     4,   380,
    51,     5,    53,    54,   382,    52,    59,   180,   343,   181,
   384,   393,   383,   182,   395,     6,   101,   102,   103,   104,
   183,    55,   404,   405,   184,   101,   102,   103,   104,   260,
   274,   185,    29,   396,   379,    53,    54,     7,     8,     9,
   186,   268,   145,   101,   102,   103,   104,    10,   397,    59,
   187,    22,   363,   270,    55,    11,    12,   400,   188,   205,
   206,   207,   208,   209,   210,   211,   101,   102,   103,   104,
   100,   309,   402,   166,   189,   167,   212,   164,   149,   230,
   231,   144,   283,   314,   101,   102,   103,   104,   369,     0,
   285,   105,     0,     0,     0,     0,   101,   102,   103,   104,
     0,     0,     0,     0,     0,     0,   213,     0,     0,     0,
     0,     0,     0,     0,     0,   214
};

static const short yycheck[] = {    10,
   173,   126,   281,   128,    22,   197,    34,    31,     8,     9,
    47,    54,     8,     9,    25,    26,    27,    28,    98,    47,
    48,   245,   246,    51,   197,     3,    44,     5,     6,     7,
    47,    59,    10,   113,    17,    18,    19,    20,    99,    17,
    18,    10,    10,    17,    18,    19,    20,    87,    26,     3,
   107,   116,   117,    81,    32,    54,   113,    81,    86,    37,
    97,    87,   341,    91,    33,    33,    94,    36,   347,    97,
   113,    99,    50,   101,   102,   103,   104,    27,     3,   271,
    97,   305,   306,    62,    17,    18,    19,    20,    42,    67,
    68,   216,   217,    17,    18,    19,    20,     3,   271,    24,
   128,    17,    18,    19,    20,     3,   112,    57,    86,    78,
    78,    80,    80,   141,   142,   115,    66,   145,   310,   115,
   148,    19,    91,    91,   152,   153,    98,   155,   156,   157,
   158,     3,   115,     5,     6,     7,   114,   310,    85,   113,
   313,   115,   114,    19,    20,    17,    18,    19,   114,   177,
    17,    18,    19,    20,    26,    88,    17,    18,    19,    20,
    32,    17,    18,    19,    20,    37,     8,     9,    53,    17,
    18,    19,    20,    10,    11,    12,    13,    14,    15,    16,
    17,    18,    19,    20,   212,    98,   311,   215,   380,     3,
    27,   115,   220,    78,   222,    67,    68,   109,   110,   115,
   228,     3,    17,    18,    19,    20,    91,   380,    17,    18,
    19,    20,    92,    93,    86,    39,   105,   106,   107,   108,
    57,   114,     3,   116,     5,     6,     7,   352,   114,    66,
   102,   103,   104,   114,   359,    59,    17,    18,    19,   114,
    64,    22,   114,   114,   114,    26,   116,     3,   115,   277,
   375,    32,   114,   281,   115,   283,    37,   114,   113,   115,
   115,   114,     3,    44,     5,     6,     7,   115,    94,   297,
    17,    18,    19,    20,     3,    29,    17,    18,   115,     6,
   113,    22,   115,     6,   118,    26,    67,    68,   113,   113,
   115,    32,   113,    11,   115,     3,    37,     5,     6,     7,
   115,     3,   113,    44,   115,    86,   115,    65,   114,    17,
    18,   114,    65,   341,    22,   343,   327,   345,    26,   347,
    17,    18,    19,    20,    32,   114,    67,    68,     3,    37,
     5,     6,     7,   114,   116,     3,    44,    17,    18,    19,
    20,   369,    17,    18,   113,    86,   115,    48,    88,   377,
     3,    26,     5,     6,     7,   115,   113,    32,   115,    67,
    68,     3,    37,     5,     6,     7,    55,   395,   115,   113,
     3,   115,   383,   114,   113,    17,    18,    19,    86,    17,
    18,    19,    20,   115,    26,     3,     3,     5,     6,     7,
    32,    96,    67,    68,   113,    37,   115,    42,    51,    17,
    18,    77,   113,    36,   115,   114,   114,   113,    26,   115,
   114,    86,    84,     5,    32,   114,   114,    70,   115,    37,
    53,   114,    97,     3,     3,    67,    68,   113,     3,    48,
     5,     6,     7,    64,    64,   115,    89,     3,    29,   114,
    56,     3,    17,    18,    86,    78,     1,   116,     6,    67,
    68,    26,    17,    18,    19,    20,     6,    32,    91,   115,
   114,     3,    37,     5,     6,     7,    84,     5,    86,     9,
   114,    73,   114,    74,    70,    17,    18,   115,   114,     3,
    35,    65,    29,    38,    26,    73,   115,   113,    43,   114,
    32,    46,    67,    68,     6,    37,   114,    28,     9,    30,
     3,   115,    80,    34,   113,    60,    17,    18,    19,    20,
    41,    86,     0,     0,    45,    17,    18,    19,    20,   178,
   198,    52,     7,    25,   360,    67,    68,    82,    83,    84,
    61,   193,    97,    17,    18,    19,    20,    92,    40,   114,
    71,     0,   330,   194,    86,   100,   101,   394,    79,    10,
    11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
     3,   248,   401,    99,    95,    99,    27,    97,    89,   146,
   146,    87,   114,   254,    17,    18,    19,    20,     9,    -1,
   215,    24,    -1,    -1,    -1,    -1,    17,    18,    19,    20,
    -1,    -1,    -1,    -1,    -1,    -1,    57,    -1,    -1,    -1,
    -1,    -1,    -1,    -1,    -1,    66
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
#line 79 "sql_parser.y"
{
  _oidrefs_ = mksymbol("_oidrefs_");
  a_setf(sql_statement,yyvsp[-1].oidval); 
  a_free(globval(_oidrefs_));
  YYACCEPT;
;
    break;}
case 2:
#line 86 "sql_parser.y"
{
  a_setf(sql_statement, mksymbol("*EOF*"));
  YYACCEPT;
;
    break;}
case 3:
#line 92 "sql_parser.y"
{
  a_free(globval(_oidrefs_));
  a_free(sql_statement); 
;
    break;}
case 4:
#line 99 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 5:
#line 102 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 6:
#line 105 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 7:
#line 108 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 8:
#line 111 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 9:
#line 114 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 10:
#line 117 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 11:
#line 120 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 12:
#line 123 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 13:
#line 125 "sql_parser.y"
{ exit(1);;
    break;}
case 16:
#line 135 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("SETQ"),
		      mksymbol("*currentschema*"),
		      a_list(mksymbol("QUOTE"), yyvsp[0].oidval, NULL),
		      NULL); 
  SAVE_REF;
;
    break;}
case 17:
#line 144 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("SETQ"),
		      mksymbol("*currentschema*"),
		      mkstring(""), NULL); 
  SAVE_REF;
;
    break;}
case 18:
#line 155 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("SQL-DROP-TABLE"),
		      yyvsp[-1].oidval, NULL); 
  SAVE_REF;
;
    break;}
case 19:
#line 163 "sql_parser.y"
{yyval.oidval = nil;;
    break;}
case 22:
#line 173 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[-1].oidval, nil); 
  SAVE_REF;
;
    break;}
case 25:
#line 185 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[-1].oidval, nil); 
  SAVE_REF;
;
    break;}
case 26:
#line 193 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("SQL-UPDATE"), yyvsp[-3].oidval,
		      yyvsp[-2].oidval, reverse(yyvsp[-1].oidval), 
		      NULL);
  if(yyvsp[0].oidval != nil)
    yyval.oidval = nconc(yyval.oidval,
		       cons(a_list(mksymbol("WHERE"),
				   yyvsp[0].oidval, NULL), nil),
                       NULL);
  SAVE_REF;
;
    break;}
case 27:
#line 208 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[0].oidval, nil); 
  SAVE_REF;
;
    break;}
case 28:
#line 214 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[0].oidval, yyvsp[-2].oidval); 
  SAVE_REF;
  /* Reverse */
;
    break;}
case 29:
#line 221 "sql_parser.y"
{yyval.oidval = nil;;
    break;}
case 30:
#line 224 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[-2].oidval, yyvsp[0].oidval); 
  SAVE_REF;
;
    break;}
case 31:
#line 233 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("SQL-DELETE"), yyvsp[-1].oidval, NULL);
  if(yyvsp[0].oidval != nil)
    yyval.oidval = nconc(yyval.oidval, cons(yyvsp[0].oidval, nil), NULL);
  SAVE_REF;
;
    break;}
case 32:
#line 244 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[-1].oidval, yyvsp[0].oidval);
  if(yyvsp[-2].oidval!=nil)
    yyval.oidval = cons(yyvsp[-2].oidval, yyval.oidval);
  yyval.oidval = cons(mksymbol("SQL-INSERT"),
		    cons(yyvsp[-3].oidval, yyval.oidval));
  SAVE_REF;
;
    break;}
case 33:
#line 254 "sql_parser.y"
{yyval.oidval = nil;;
    break;}
case 34:
#line 257 "sql_parser.y"
{
  yyval.oidval = reverse(yyvsp[-1].oidval); 
  SAVE_REF;
;
    break;}
case 35:
#line 264 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[0].oidval, nil); 
  SAVE_REF;
;
    break;}
case 36:
#line 270 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[0].oidval, yyvsp[-2].oidval); 
  SAVE_REF;
  /* Reverse */
;
    break;}
case 37:
#line 278 "sql_parser.y"
{
  yyval.oidval = cons(reverse(yyvsp[-1].oidval), nil); 
  SAVE_REF;
;
    break;}
case 38:
#line 284 "sql_parser.y"
{
  yyval.oidval = nconc(yyvsp[-4].oidval, cons(reverse(yyvsp[-1].oidval), nil), NULL);
  SAVE_REF;
;
    break;}
case 39:
#line 293 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("SQL-CREATE-TABLE"),
		      yyvsp[-3].oidval,
		      reverse(yyvsp[-1].oidval),
		      NULL); 
  SAVE_REF;
;
    break;}
case 40:
#line 303 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[0].oidval,nil);
  SAVE_REF;
;
    break;}
case 41:
#line 308 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[0].oidval,yyvsp[-2].oidval);
  SAVE_REF;
  /* Reverse */
;
    break;}
case 42:
#line 316 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 44:
#line 322 "sql_parser.y"
{
  if(yyvsp[-1].oidval==nil) yyval.oidval = a_list(yyvsp[-3].oidval, yyvsp[-2].oidval, NULL);
    else yyval.oidval = a_list(yyvsp[-3].oidval, yyvsp[-2].oidval, yyvsp[-1].oidval, NULL);
  yyval.oidval = nconc(yyval.oidval, yyvsp[0].oidval, NULL);
  SAVE_REF;
;
    break;}
case 45:
#line 331 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[0].oidval, nil); 
  SAVE_REF;
;
    break;}
case 46:
#line 337 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[-1].oidval, yyvsp[0].oidval); 
  SAVE_REF;
;
    break;}
case 47:
#line 343 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[-1].oidval, yyvsp[0].oidval); 
  SAVE_REF;
;
    break;}
case 48:
#line 349 "sql_parser.y"
{yyval.oidval = nil;;
    break;}
case 49:
#line 352 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[-1].oidval, nil); 
  SAVE_REF;
;
    break;}
case 51:
#line 360 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-3].oidval, yyvsp[-1].oidval, NULL); 
  SAVE_REF;
;
    break;}
case 59:
#line 376 "sql_parser.y"
{ 
  yyval.oidval = mksymbol("VARCHAR"); 
;
    break;}
case 63:
#line 387 "sql_parser.y"
{yyval.oidval = nil;;
    break;}
case 64:
#line 389 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-1].oidval, yyvsp[0].oidval, NULL); 
  SAVE_REF;
;
    break;}
case 72:
#line 405 "sql_parser.y"
{yyval.oidval = nil;;
    break;}
case 74:
#line 412 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 75:
#line 414 "sql_parser.y"
{yyval.oidval = nconc(yyvsp[-1].oidval,yyvsp[0].oidval, NULL);;
    break;}
case 76:
#line 418 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 78:
#line 425 "sql_parser.y"
{
  yyval.oidval = cons(mksymbol("NOT-NULL"), nil); 
  SAVE_REF;
;
    break;}
case 79:
#line 431 "sql_parser.y"
{
  yyval.oidval = cons(mksymbol("PRIMARY-KEY"), nil); 
  SAVE_REF;
;
    break;}
case 80:
#line 437 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[0].oidval,nil); 
  SAVE_REF;
;
    break;}
case 81:
#line 443 "sql_parser.y"
{
  if(yyvsp[-1].oidval == nil) yyval.oidval = cons(yyvsp[-2].oidval, nil);
  else yyval.oidval = a_list(yyvsp[-2].oidval, yyvsp[-1].oidval, NULL); 
  SAVE_REF;
;
    break;}
case 82:
#line 450 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-3].oidval, yyvsp[-1].oidval, NULL); 
  SAVE_REF;
;
    break;}
case 83:
#line 457 "sql_parser.y"
{
  yyval.oidval = nconc(a_list(yyvsp[-2].oidval,
			    yyvsp[-1].oidval, NULL),
		     yyvsp[0].oidval,
                     NULL); 
  SAVE_REF;
;
    break;}
case 84:
#line 466 "sql_parser.y"
{
  yyval.oidval = cons(mksymbol("CONSTRAINT"),
		    yyvsp[0].oidval); 
  SAVE_REF;
;
    break;}
case 85:
#line 475 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("PRIMARY-KEY"), yyvsp[-1].oidval, NULL);
  SAVE_REF;
;
    break;}
case 86:
#line 481 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-3].oidval, yyvsp[-1].oidval, NULL); 
  SAVE_REF;
;
    break;}
case 87:
#line 488 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("FOREIGN-KEY"), yyvsp[-4].oidval,
		      yyvsp[-2].oidval, yyvsp[-1].oidval, yyvsp[0].oidval, 
		      NULL);
  SAVE_REF;
;
    break;}
case 88:
#line 497 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[0].oidval,nil);
  SAVE_REF;
;
    break;}
case 89:
#line 502 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[0].oidval,yyvsp[-2].oidval);
  SAVE_REF;
  /* Reverse */
;
    break;}
case 90:
#line 510 "sql_parser.y"
{yyval.oidval = nil;;
    break;}
case 91:
#line 513 "sql_parser.y"
{yyval.oidval = yyvsp[-1].oidval;;
    break;}
case 92:
#line 521 "sql_parser.y"
{
  if(yyvsp[0].oidval != nil)                           /* having */
    yyval.oidval = a_list(mksymbol("ORDERBY"), yyvsp[0].oidval, NULL);
  else
    yyval.oidval = nil;

  if(yyvsp[-1].oidval != nil)
    {
      yyval.oidval = cons(yyvsp[-1].oidval, yyval.oidval);    /* having */
      yyval.oidval = cons(mksymbol("HAVING"), yyval.oidval);
    }

  if(yyvsp[-2].oidval != nil)
    {
      yyval.oidval = cons(yyvsp[-2].oidval, yyval.oidval);    /* group by */
      yyval.oidval = cons(mksymbol("GROUPBY"), yyval.oidval);
    }
  if(yyvsp[-3].oidval != nil)
    {                                               /* where */
      yyval.oidval = cons(yyvsp[-3].oidval, yyval.oidval);
      yyval.oidval = cons(mksymbol("WHERE"), yyval.oidval);
    }
  yyval.oidval = cons(yyvsp[-4].oidval, yyval.oidval);
  yyval.oidval = cons(mksymbol("FROM"), yyval.oidval); /* from */
  yyval.oidval = cons(reverse(yyvsp[-5].oidval), yyval.oidval); /* result */
  if(yyvsp[-6].oidval != nil)                           /* distinct */
    yyval.oidval = cons(yyvsp[-6].oidval, yyval.oidval);
  yyval.oidval = cons(mksymbol("SQL-SELECT"), yyval.oidval);
  SAVE_REF;

  //                  $<oidval>$ = a_list(mksymbol("SQL-SELECT"), /* select */
  //                                      $<oidval>2, /* distinct */
  //                                      $<oidval>3, /* result */
  //                                      $<oidval>4, /* from */
  //                                      $<oidval>5, /* where */
  //                                      $<oidval>6, /* group by */
  //                                      $<oidval>7, /* having */
  //                                      NULL); SAVE_REF;
;
    break;}
case 93:
#line 562 "sql_parser.y"
{yyval.oidval = nil; /*mksymbol("ALL");*/;
    break;}
case 94:
#line 564 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 95:
#line 566 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 96:
#line 570 "sql_parser.y"
{
  yyval.oidval = reverse(yyvsp[0].oidval);
  SAVE_REF;
;
    break;}
case 97:
#line 577 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[0].oidval,nil);
  SAVE_REF;
;
    break;}
case 98:
#line 582 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[0].oidval,yyvsp[-2].oidval);
  SAVE_REF;
;
    break;}
case 99:
#line 587 "sql_parser.y"
{
  yyval.oidval = cons(a_list(mksymbol("INNERJOIN"),
			   call_lisp(mksymbol("SECOND"), varstack, 1, 
				     yyvsp[-2].oidval),
			   call_lisp(mksymbol("THIRD"), varstack, 1, 
				     yyvsp[-2].oidval),
			   yyvsp[0].oidval, NULL),
		    yyvsp[-5].oidval);
  SAVE_REF;
;
    break;}
case 100:
#line 598 "sql_parser.y"
{
  yyval.oidval = cons(a_list(mksymbol("INNERJOIN"),
			   call_lisp(mksymbol("SECOND"), varstack, 1, 
				     yyvsp[-2].oidval),
			   call_lisp(mksymbol("THIRD"), varstack, 1, 
				     yyvsp[-2].oidval),
			   yyvsp[0].oidval, NULL),
		    yyvsp[-4].oidval);
  SAVE_REF;
;
    break;}
case 101:
#line 609 "sql_parser.y"
{
  yyval.oidval = cons(a_list(mksymbol("CROSSJOIN"),
			   call_lisp(mksymbol("SECOND"), varstack, 1, 
				     yyvsp[0].oidval),
			   call_lisp(mksymbol("THIRD"), varstack, 1, 
				     yyvsp[0].oidval),
			   NULL),
		    yyvsp[-3].oidval);
  SAVE_REF;
;
    break;}
case 102:
#line 622 "sql_parser.y"
{
  yyval.oidval = a_list(nil, yyvsp[0].oidval, NULL); 
  SAVE_REF;
;
    break;}
case 103:
#line 627 "sql_parser.y"
{
  yyval.oidval = a_list(nil,yyvsp[-1].oidval,yyvsp[0].oidval, NULL); 
  SAVE_REF;
;
    break;}
case 104:
#line 632 "sql_parser.y"
{
  yyval.oidval = a_list(nil,yyvsp[-2].oidval,yyvsp[0].oidval, NULL); 
  SAVE_REF;
;
    break;}
case 105:
#line 639 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 106:
#line 643 "sql_parser.y"
{yyval.oidval = nil;;
    break;}
case 107:
#line 645 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 108:
#line 649 "sql_parser.y"
{yyval.oidval = nil;;
    break;}
case 109:
#line 651 "sql_parser.y"
{
  yyval.oidval = reverse(yyvsp[0].oidval); 
  SAVE_REF;
;
    break;}
case 110:
#line 658 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[0].oidval,nil);
  SAVE_REF;
;
    break;}
case 111:
#line 663 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[0].oidval,yyvsp[-2].oidval);
  SAVE_REF;
  /* Reverse */
;
    break;}
case 112:
#line 671 "sql_parser.y"
{yyval.oidval = nil;;
    break;}
case 113:
#line 673 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 114:
#line 677 "sql_parser.y"
{yyval.oidval = nil;;
    break;}
case 115:
#line 679 "sql_parser.y"
{
  yyval.oidval = reverse(yyvsp[0].oidval); 
  SAVE_REF;
;
    break;}
case 116:
#line 686 "sql_parser.y"
{
  yyval.oidval = cons(a_list(yyvsp[0].oidval, yyvsp[-1].oidval, NULL),nil); 
  SAVE_REF;
;
    break;}
case 117:
#line 691 "sql_parser.y"
{
  yyval.oidval = cons(a_list(yyvsp[0].oidval, yyvsp[-1].oidval, NULL),yyvsp[-3].oidval); 
  SAVE_REF;
  /* Reverse */
;
    break;}
case 118:
#line 699 "sql_parser.y"
{yyval.oidval = mksymbol("ASC");;
    break;}
case 119:
#line 701 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 120:
#line 703 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 121:
#line 707 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 122:
#line 709 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-1].oidval, yyvsp[-3].oidval, NULL); 
  SAVE_REF;
;
    break;}
case 123:
#line 715 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[0].oidval,nil); 
  SAVE_REF;
;
    break;}
case 124:
#line 720 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[0].oidval,yyvsp[-2].oidval); 
  SAVE_REF;
  /* Reverse */
;
    break;}
case 125:
#line 728 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 126:
#line 730 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 127:
#line 732 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 128:
#line 736 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 129:
#line 739 "sql_parser.y"
{yyval.oidval = yyvsp[-1].oidval;;
    break;}
case 130:
#line 742 "sql_parser.y"
{yyval.oidval = yyvsp[-2].oidval;;
    break;}
case 131:
#line 745 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 132:
#line 748 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[0].oidval, yyvsp[-2].oidval); 
  SAVE_REF;
;
    break;}
case 133:
#line 755 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("PLUS"),
		      yyvsp[-2].oidval,yyvsp[0].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 134:
#line 761 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("MINUS"),
		      yyvsp[-2].oidval,yyvsp[0].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 135:
#line 767 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("TIMES"),
		      yyvsp[-2].oidval,yyvsp[0].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 136:
#line 773 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("DIV"),
		      yyvsp[-2].oidval,yyvsp[0].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 137:
#line 779 "sql_parser.y"
{yyval.oidval = yyvsp[-1].oidval;;
    break;}
case 138:
#line 781 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 139:
#line 783 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("MINUS"), mksymbol("0"), yyvsp[0].oidval, NULL); 
  SAVE_REF;
;
    break;}
case 140:
#line 788 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 141:
#line 790 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 142:
#line 792 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 143:
#line 796 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 144:
#line 800 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[0].oidval,nil); 
  SAVE_REF;
;
    break;}
case 145:
#line 805 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[0].oidval,yyvsp[-2].oidval); 
  SAVE_REF;
  /* Reverse */
;
    break;}
case 146:
#line 813 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-3].oidval,yyvsp[-1].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 147:
#line 819 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-5].oidval,yyvsp[-3].oidval,yyvsp[-1].oidval, NULL); 
  SAVE_REF;
;
    break;}
case 148:
#line 825 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("SQL_COUNT"),yyvsp[-1].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 149:
#line 831 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("SQL_COUNT"),yyvsp[-1].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 150:
#line 837 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("SQL_COUNT"),yyvsp[-1].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 151:
#line 843 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("SQL_COUNTD"),yyvsp[-1].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 152:
#line 849 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("SQL_MIN"),yyvsp[-1].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 153:
#line 855 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("SQL_MAX"),yyvsp[-1].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 154:
#line 861 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("SQL_AVG"),yyvsp[-1].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 155:
#line 867 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("SQL_AVG"),yyvsp[-1].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 156:
#line 873 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("SQL_AVGD"),yyvsp[-1].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 157:
#line 879 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("SQL_SUM"),yyvsp[-1].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 158:
#line 885 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("SQL_SUM"),yyvsp[-1].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 159:
#line 891 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("SQL_SUMD"),yyvsp[-1].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 160:
#line 904 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[-3].oidval, yyvsp[-2].oidval);
  yyval.oidval = cons(yyvsp[-4].oidval, yyval.oidval);
  yyval.oidval = nconc(yyval.oidval,yyvsp[-1].oidval,NULL);
  SAVE_REF;
;
    break;}
case 161:
#line 912 "sql_parser.y"
{
  yyval.oidval = cons(mksymbol("COND"), yyvsp[-2].oidval);
  yyval.oidval = nconc(yyval.oidval,yyvsp[-1].oidval,NULL);
  SAVE_REF;
;
    break;}
case 162:
#line 920 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 163:
#line 922 "sql_parser.y"
{
  yyval.oidval = nconc(yyvsp[-1].oidval,yyvsp[0].oidval,NULL);
;
    break;}
case 164:
#line 927 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-2].oidval, yyvsp[0].oidval, NULL); 
  SAVE_REF;
;
    break;}
case 165:
#line 934 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 166:
#line 936 "sql_parser.y"
{yyval.oidval = nconc(yyvsp[-1].oidval,yyvsp[0].oidval,NULL);;
    break;}
case 167:
#line 939 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-2].oidval, yyvsp[0].oidval, NULL); 
  SAVE_REF;
;
    break;}
case 168:
#line 946 "sql_parser.y"
{yyval.oidval = nil;;
    break;}
case 169:
#line 949 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-1].oidval, yyvsp[0].oidval, NULL); 
  SAVE_REF;
;
    break;}
case 170:
#line 956 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 171:
#line 962 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("COLUMN"), nil, nil, yyvsp[0].oidval, NULL);
  SAVE_REF;
;
    break;}
case 172:
#line 968 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("COLUMN"), nil, yyvsp[-2].oidval, yyvsp[0].oidval, NULL);
  SAVE_REF;
;
    break;}
case 173:
#line 978 "sql_parser.y"
{
  yyval.oidval = a_list(mksymbol("COLUMN"), yyvsp[-4].oidval, yyvsp[-2].oidval,
		      yyvsp[0].oidval, NULL);
  SAVE_REF;
;
    break;}
case 174:
#line 990 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-1].oidval,
		      yyvsp[-2].oidval,yyvsp[0].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 175:
#line 996 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-1].oidval,
		      yyvsp[-2].oidval,yyvsp[0].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 176:
#line 1002 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-1].oidval,yyvsp[0].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 177:
#line 1007 "sql_parser.y"
{yyval.oidval = yyvsp[-1].oidval;;
    break;}
case 178:
#line 1009 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 179:
#line 1014 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval; ;
    break;}
case 180:
#line 1016 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval; ;
    break;}
case 181:
#line 1020 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-1].oidval,yyvsp[-2].oidval,yyvsp[0].oidval,NULL);
  SAVE_REF;
;
    break;}
case 182:
#line 1025 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-1].oidval,yyvsp[-2].oidval,yyvsp[0].oidval,NULL);
  SAVE_REF;
;
    break;}
case 183:
#line 1031 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-3].oidval,yyvsp[-4].oidval,yyvsp[-2].oidval,yyvsp[0].oidval,NULL);
  SAVE_REF;
;
    break;}
case 184:
#line 1037 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-3].oidval,yyvsp[-5].oidval,yyvsp[-2].oidval,yyvsp[0].oidval,NULL);
  yyval.oidval = a_list(yyvsp[-4].oidval, yyval.oidval, NULL);
  SAVE_REF;
;
    break;}
case 185:
#line 1043 "sql_parser.y"
{
  char *tmp;
  size_t i;
  tmp = getstring(yyvsp[0].oidval);
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
  yyval.oidval = a_list(yyvsp[-1].oidval,yyvsp[-2].oidval,yyvsp[0].oidval,NULL);
  SAVE_REF;
;
    break;}
case 186:
#line 1061 "sql_parser.y"
{
  char *tmp;
  size_t i;
  tmp = getstring(yyvsp[0].oidval);
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
  yyval.oidval = a_list(mksymbol("LIKE_I"),yyvsp[-3].oidval,yyvsp[0].oidval,NULL);
  yyval.oidval = a_list(yyvsp[-2].oidval, yyval.oidval, NULL);
  SAVE_REF;
;
    break;}
case 187:
#line 1080 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[-4].oidval,reverse(yyvsp[-1].oidval));
  yyval.oidval = cons(yyvsp[-3].oidval,yyval.oidval);
  SAVE_REF;
;
    break;}
case 188:
#line 1086 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[-5].oidval,reverse(yyvsp[-1].oidval));
  yyval.oidval = a_list(yyvsp[-4].oidval, cons(yyvsp[-3].oidval,yyval.oidval), NULL);
  SAVE_REF;
;
    break;}
case 189:
#line 1094 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-1].oidval,yyvsp[0].oidval,NULL); 
  SAVE_REF;
;
    break;}
case 190:
#line 1101 "sql_parser.y"
{yyval.oidval = yyvsp[-1].oidval;;
    break;}
case 191:
#line 1105 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 192:
#line 1107 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 193:
#line 1109 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 194:
#line 1113 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 195:
#line 1116 "sql_parser.y"
{
  yyval.oidval = cons(yyvsp[-2].oidval, yyvsp[0].oidval); 
  SAVE_REF;
;
    break;}
case 196:
#line 1122 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-3].oidval, yyvsp[-1].oidval, NULL); 
  SAVE_REF;
;
    break;}
case 197:
#line 1129 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 198:
#line 1131 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 199:
#line 1133 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-2].oidval, yyvsp[-1].oidval, yyvsp[0].oidval, NULL); 
  SAVE_REF;
;
    break;}
case 200:
#line 1138 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-3].oidval, yyvsp[-1].oidval, yyvsp[0].oidval, NULL); 
  SAVE_REF;
;
    break;}
case 201:
#line 1145 "sql_parser.y"
{
  yyval.oidval = a_list(yyvsp[-1].oidval, yyvsp[0].oidval, NULL); 
  SAVE_REF;
;
    break;}
case 202:
#line 1152 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 203:
#line 1155 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 204:
#line 1159 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 205:
#line 1161 "sql_parser.y"
{yyval.oidval = mksymbol("!=");;
    break;}
case 206:
#line 1163 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 207:
#line 1165 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 208:
#line 1167 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
    break;}
case 209:
#line 1169 "sql_parser.y"
{yyval.oidval = yyvsp[0].oidval;;
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
#line 1172 "sql_parser.y"
