/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 1997 Tore Risch
 * $RCSfile: top.c,v $
 * $Revision: 1.30 $ $Date: 2014/01/13 17:11:21 $
 * $State: Exp $ $Locker:  $
 *
 * Description: Parsing and top loop
 * ===========================================================================
 * $Log: top.c,v $
 * Revision 1.30  2014/01/13 17:11:21  torer
 * cc v5.0 safe
 *
 * Revision 1.29  2014/01/12 16:28:23  torer
 * Apple cc v5.0 safe C code
 *
 * Revision 1.28  2014/01/11 10:38:11  torer
 * More MacProblems fixed
 *
 * Revision 1.27  2013/04/29 17:04:40  torer
 * Removed trace printings
 *
 * Revision 1.26  2013/04/29 14:11:16  torer
 * 1. AMOS_HOME must be exported under Linux
 * 2. LD_LIBRARY_PATH muste be set to $(AMOS_HOME)/bin under Linux
 * 3. libamos.so is now a shared object ubnder Linux
 * 4. $(AMOS_HOME)/bin/libamos.a is no longer used. Delete it!
 *
 * Revision 1.25  2013/02/26 18:10:21  torer
 * Using sdterr to represent fake file handle
 *
 * Revision 1.24  2013/02/14 07:02:12  torer
 * Total recompile on Kalkyl
 *
 * Revision 1.23  2013/01/24 16:41:24  torer
 * mac adapted
 *
 * Revision 1.22  2012/06/28 20:00:32  torer
 * Global variables EXPORTTO and IMPORTFROM removed
 * New stream headers in C
 *
 * Revision 1.21  2012/03/28 11:14:16  torer
 * regression testing if (setq _regression_ t)
 *
 * Revision 1.20  2012/03/28 08:17:24  torer
 * SSDM release regression tested
 *
 * Revision 1.19  2012/01/16 12:27:59  torer
 * _prompter_ changes only main prompter
 *
 * Revision 1.18  2011/12/30 15:26:56  torer
 * Introduced flex_c, the last character read in a flexstream
 *
 * Revision 1.17  2011/12/30 14:41:31  torer
 * Cleaned up SQL parser.
 *
 * Revision 1.16  2011/12/29 07:29:13  torer
 * Memory corruption in flex
 *
 * Revision 1.15  2011/12/02 15:27:32  torer
 * new function to parse any supported language from stream: PARSE-STREAM
 *
 * Revision 1.14  2011/11/17 21:44:33  torer
 * A more modular C interface to parsers fro different languages
 *
 * Revision 1.13  2011/11/17 11:23:44  torer
 * SQL parser integrated
 * Try:  amos2 -q SQL
 *
 * Revision 1.12  2011/11/16 22:08:41  torer
 * removed declaration
 *
 * Revision 1.10  2011/11/16 14:43:31  torer
 * Option to change initial query language by
 *   amos2 -q <language>
 *
 * Revision 1.9  2011/11/16 12:12:38  torer
 * Support for multiple parsers
 *
 * Revision 1.8  2011/02/17 19:46:01  torer
 * Removed debug printing
 *
 * Revision 1.5  2009/03/27 15:59:54  torer
 * :help in ALisp toploop
 *
 * Revision 1.4  2008/11/24 08:06:23  torer
 * Error line number adjustment
 *
 * Revision 1.2  2006/11/17 08:13:17  torer
 * System prompt can now be changed by setting global variable _PROMPTER_!
 *
 * Revision 1.1  2006/07/27 14:32:41  torer
 * top.c to repository
 *
 ****************************************************************************/

#include "amos.h"

#include <ctype.h>
extern void check_init_hooks(void);

oidtype parse_return, _parsetrace_, lispsymbol, eof_symbol, osql_keyword;
oidtype prognsymbol, autosymbol, print_amosql_result, _within_lisp_;
oidtype _parse_error_message_, no_result, _oidrefs_;
extern oidtype _debugging_;

extern oidtype _history_, _generations_, _storagestat_;

/*** flexstream management ***/

#define MAXLENGTH 4096
char cmd_line[MAXLENGTH];
char *cmd_linep;
int flex_c; /* The last read character */
#define AMOSQL 0
#define LISP 1
#define SQL 2
#define PARSERS 10  /* Max # of parsers supported */
int last_parser = -1;
int illegal_language, too_many_languages;  /* Error messages */

struct parser
{
  char *language; /* Name of language */
  oidtype identifier; /* Indentifier for language */
  oidtype(*parser)(bindtype, flexstream *); /* Parser to Lisp */
  void(*result_printer)(oidtype); /* query result printing */
  void(*initializer)(flexstream *); /* when shitched to */
  void(*finalizer)(flexstream *); /* when switched from */
};

struct parser parsers[PARSERS];

EXPORT int a_query_language=0; /* The initial query language */

EXPORT oidtype a_language_object(char *language)
     /*** Returns the Lisp symbol representing the parsr for a language ***/
{
  char *prefix = "language-";
  char *buff = (char *)alloca(strlen(prefix)+strlen(language)+1);

  strcpy(buff,"language-");
  strcat(buff,language);
  return mksymbol(buff);  
}

EXPORT int a_define_parser(char *language, 
                            oidtype(*parser)(bindtype, flexstream *),
                            void(*result_printer)(oidtype),
                            void(*initializer)(flexstream *),
                            void(*finalizer)(flexstream *))
     /*** Register a new parser for a language ***/
{
  if(last_parser + 1 >= PARSERS)
    a_error_str(too_many_languages, language, FALSE);
  last_parser++;
  parsers[last_parser].language = strdup(language);
  parsers[last_parser].identifier = a_language_object(language);
  parsers[last_parser].parser = parser;
  parsers[last_parser].result_printer = result_printer;
  parsers[last_parser].initializer = initializer;
  parsers[last_parser].finalizer = finalizer;
  return last_parser;
}

int get_parser_id(oidtype lango)
     /*** Get the id number for the language identified by lango ***/
{
  int i;

  for(i=0;i<=last_parser;i++)
    {
      if(parsers[i].identifier==lango) return i;
    }
  return -1; /* Not found */
}

EXPORT int a_language_parser_id(char *language)
     /*** Get the id number for the parser for a language ***/
{
  int lid = get_parser_id(a_language_object(language));

  if(lid>=0) return lid;
  a_error_str(illegal_language, language, FALSE);
  return -1;
}

void init_flexstream(oidtype stream, flexstream *fs, int language)
{
  if(stream == stdinstream) fs->filedesc = *stdin;
  else fs->filedesc = *stderr; /* makes fake flex buffer file input */
  fs->stream = stream;
  if(!a_streamp(stream))
    {
      a_error(ARG_NOT_STREAM, stream, FALSE);
      return;
    }
  switch (a_datatype(stream))
    {
    case TEXTSTREAMTYPE:
      /* For textstreams the logstream is the stream itself */
      fs->logstream = stream;
      break;
    default:
      /* For non-textstreams the input is always logged in a textstream */
      if(dr(stream,streamcell)->header.logstream==nil)
	{
	  a_let(dr(stream,streamcell)->header.logstream,new_textstream(512));
	  fs->logstream=dr(stream,streamcell)->header.logstream;
	}
    }
  fs->char_num = 0;
  fs->function_flg = TRUE;
  fs->key_pos = 0;
  fs->language = language;
  if(parsers[language].initializer!=NULL)
    (*(parsers[language].initializer))(fs);
}

void free_flexstream(flexstream *fs)
{
  if(parsers[fs->language].finalizer!=NULL)
    (*(parsers[fs->language].finalizer))(fs);
}

void change_language(flexstream *fs, int from, int to)
{
  fs->language = from;
  free_flexstream(fs); 
  init_flexstream(fs->stream,fs,to);
}

EXPORT int a_flexstream_getc(flexstream *fs, char* buf)
{
  int c; 

  cmd_linep = cmd_line; 
  signal(SIGINT,SIG_IGN); c = a_getc(fs->stream); 
  signal(SIGINT,a_interrupt_handler); 
  if (c == '\r') c = ' '; flex_c = c;
  if(fs->char_num >= MAXLENGTH-1) fs->char_num = -1;
  cmd_line[fs->char_num++]= c; 
  cmd_line[fs->char_num]= 0; 
  if (c == '\n') fs->char_num = 0;  
  return( (c == EOF) ? 0 : (buf[0] = c, 1)); 
}

/*** end flexstream management ***/

int nextgen(void)
     /* Get the present savepoint generation number for the Amos II toploop */
{
  if(globval(_generations_)==nil) return 1;
  else return(1 + getinteger(hd(hd(globval(_generations_)))));
}

void prprompt(flexstream fs, char *prompter)
     /* Print prompter for console input to Amos II toploop */
{
  char buffer[100];
  oidtype promptstring;

  if(fs.language==0 && stringp(promptstring=globval(mksymbol("_prompter_"))))
    {
      sprintf(buffer,"%s %d> ",getstring(promptstring),nextgen());
      a_message(buffer);
    }
  else if(fs.language==0 && strcmp(prompter,"")!=0) 
    {
      sprintf(buffer,"%s %d> ",prompter,nextgen());
      a_message(buffer);
    }
  else
    {
      sprintf(buffer,"%s %d> ",parsers[fs.language].language,nextgen());
      a_message(buffer);
    }
}

oidtype parse_and_eval(bindtype env, flexstream *fs,
                       int printflg, int evalflg, int *eofflg, double *time)
     /* Parse a statement to an S-expression.
	fs: descriptor of scanner state and stream object.
	if evalflg is TRUE then the parsed S-expression shall be evaluated.
	else return the parsed S-expression without evaluation.
	eofflg is set to TRUE if end-of-file detected during parsing.
	time is set to time spent during the evaluation of the S-expression
     */
{
  oidtype parsed_form=nil, res=nil;
  double cl;
  oidtype old_within_lisp;
  int oldlang = fs->language, newlang, lid;
  oidtype stream = fs->stream;

  *time = 0.0;
  *eofflg = FALSE;
  if(dr(stream,streamcell)->header.logstream != nil)
    /* Only need to log one statement at the time */
    a_fclose(dr(stream,streamcell)->header.logstream);
  oldlang = fs->language;
  res = (*(parsers[fs->language].parser))(env, fs); /* Parse stmt */
  if (globval(_parsetrace_) != nil) a_print(res);
  lid = get_parser_id(res); 
  if(lid>=0)
   {
      newlang = lid; /* Language identifier returned */
      res = no_result;
   }
  else newlang = fs->language;
  if(newlang!=oldlang) change_language(fs,oldlang,newlang);
  if(res==eof_symbol)
    { 
      *eofflg = TRUE;
      return res;
    }
  if(res==no_result) return no_result;
  if(!evalflg) return res;
  a_let(parsed_form,res);
  if(parsed_form == mksymbol(":help")) 
    {a_setf(parsed_form, mksymbol("_toploop-help_"));}

  /* Set special variable *WITHIN-LISP* to T if in Lisp mode: */
  old_within_lisp = globval(_within_lisp_);
  if(fs->language==LISP){a_setf(globval(_within_lisp_),t)}
  else {a_setf(globval(_within_lisp_),nil)};

  cl = run_time(); /* Measure time for evaluation */

  {unwind_protect_begin;
  a_let(res,evalfn(env, parsed_form));
  unwind_protect_catch;
  *time = run_time() - cl;
  a_free(parsed_form);
  if(printflg && !unwind_reset) /* Print evaluation result */
    (*(parsers[fs->language].result_printer))(res);
  a_setf(globval(_within_lisp_),old_within_lisp); /* Reset old _WITHIN-LISP_ */
  unwind_protect_end;}
  a_return(res);
}

void add_savepoint(oidtype oldhist, oidtype oldgen)
     /* Add old log state as new savepoint to _GENERATIONS_
        if evaluation changed _HISTORY_ */
{
  oidtype gen = globval(_generations_);

  if(oldhist == globval(_history_))
    return; /* no change */
  if(oldgen != gen)
    return; /* rollback happened and it updated _generations_ */
  /* New savepoint */
  a_setf(globval(_generations_),
	 cons(cons(mkinteger(nextgen()),oldhist),
	      gen));
  return;
}

EXPORT void amos_toploop(char *prompter)
     /* The AmosQL top loop */
{
  int end_of_file = FALSE;
  bindtype env = topframe();
  volatile flexstream topstream;
  double time;
  volatile oidtype oldhist=nil, oldgen=nil;

  check_init_hooks();
  init_flexstream(stdinstream,&topstream,a_query_language);
  if(globval(mksymbol("_lisp-mode_"))!=nil) topstream.language = LISP;
  while (TRUE)
    {
      unwind_protect_begin;
      a_setf(oldhist,globval(_history_));
      a_setf(oldgen,globval(_generations_));
      if(!end_of_file) prprompt(topstream,prompter);
      end_of_file = FALSE;
      signal(SIGINT,lsp_interrupthandler);
      release(parse_and_eval(env,&topstream,TRUE,TRUE,&end_of_file,&time));
      unwind_protect_catch;
      if(time>1.0e-6)
	{  
	  char buffer[100];

	  sprintf(buffer,"%g s\n",time);
	  a_message(buffer);
	}
      if(a_check_reset(env)) break;
      if(unwind_reset && globval(mksymbol("_regression_"))!=nil)
	{ a_setf(globval(mksymbol("_regression-failed_")), t);}
      if(unwind_reset)
	history_rollbackfn(env,oldhist); /* undo errored statement */
      else add_savepoint(oldhist,oldgen);
      if (globval(_storagestat_) != nil) a_printstat();
    }
  free_flexstream(&topstream);
}

EXPORT void a_parse_error(flexstream *fs,char *s)
     /* Print parse error message */
{
  int p,elength;
  oidtype errmsg = globval(_parse_error_message_);
  bindtype env = topframe();
  char mesg[100];

  sprintf(mesg,"%s in line %d\n",s,dr(fs->stream,streamcell)->header.line_num+1);
  closestreamfn(env,errmsg);
  a_puts(mesg,errmsg);
  for(elength=0;elength<(fs->char_num - 1); elength++)
    a_putc(cmd_linep[elength], errmsg);
  a_putc('\n', errmsg);
  /* find erroneous character */
  while (elength>0 && (a_isalnum((char)*(cmd_linep+elength-1)))) elength--;
  for (p=0; p<elength; p++) 
    {
      if (*(cmd_linep+p) == '\t')
	a_puts("\t", errmsg);
      else a_puts(" ", errmsg);
    };
  a_puts("^\n", errmsg);
  fs->char_num = 0;
  release(call_lisp(mksymbol("amos-error"),env,1,
		    textstreamstringfn(env,errmsg)));
}

EXPORT oidtype a_parse_streamfn(bindtype env, oidtype filep, oidtype language,
                              oidtype loudflg)
     /* Parse the next expression in an open stream str with statements in 
        specified language. loudflg != nil => print each parsed statement */
{
  flexstream fs;
  char *lang;
  int end_of_file=FALSE;
  oidtype res;
  double time;

  IntoString(language, lang, env);
  init_flexstream(filep,&fs,a_language_parser_id(lang));
  res = parse_and_eval(env,&fs,loudflg!=nil,FALSE,&end_of_file,&time);
  return res;
}

EXPORT oidtype a_parse_filefn(bindtype env, oidtype filep, oidtype language,
                              oidtype loudflg)
     /* Load file named file with statements in specified language.
	loudflg != nil => print each statement read */
{
  int end_of_file=FALSE;
  oidtype fp=nil, fullname=nil;
  double time;
  flexstream fs;
  char *lang;

  {unwind_protect_begin;

  IntoString(language, lang, env);

  a_setf(fullname,full_filenamefn(env,filep));
  a_puts("Reading ", stdoutstream); 
  a_puts(lang, stdoutstream); 
  a_puts(" statements from ", stdoutstream); 
  a_print(fullname);
  a_let(fp, call_lisp(mksymbol("openstream"),
		      env,2,fullname,mkstring("r")));
  init_flexstream(fp,&fs,a_language_parser_id(lang));
  for(;;)
    {
      release(parse_and_eval(env,&fs,loudflg!=nil,TRUE,&end_of_file,&time));
      if(end_of_file) break;
    }
  unwind_protect_catch;
  if(fp!=nil)
    {
      closestreamfn(env,fp);
      free_flexstream(&fs);
    }
  released(fp);
  released(fullname);
  unwind_protect_end;}
  return filep;
}

oidtype parsefn(bindtype env, oidtype str, oidtype evalflg, 
                oidtype language)
     /* Parse an statment in string STR.
        if EVALFLG is true then evaluate parsed expression too.
        Default language is AmosQL */ 
{
  oidtype fp = new_textstream(100), res=nil, temp=nil;
  int end_of_file=FALSE;
  flexstream fs;
  char *string;
  double time;
  char *lang;
  int langtag=AMOSQL; /* default language */ 

  if(language!=nil)
    {
      IntoString(language, lang, env);
      langtag = a_language_parser_id(lang);
    }
  init_flexstream(fp,&fs,langtag);
  IntoString(str,string,env); 
  {unwind_protect_begin;
  a_puts(string,fp);
  a_putc(' ',fp);
  closestreamfn(env,fp);
  for(;;)
    {
      if(evalflg!=nil)
	{
	  a_setf(temp, parse_and_eval(env,&fs,FALSE,TRUE,&end_of_file,&time));
	  if(end_of_file) break;
	  a_setf(res,temp);
	}
      else
	{
	  a_setf(temp, 
		 parse_and_eval(env,&fs,FALSE,FALSE,&end_of_file, &time));
	  if(end_of_file) break;
	  a_setf(res,cons(temp ,res));
	}
    }
  unwind_protect_catch;
  release(fp);
  released(temp);
  if(unwind_reset) a_free(res);
  free_flexstream(&fs);
  unwind_protect_end;}
  if(evalflg!=nil || !listp(res)) a_return(res); 
  if(ftl(res)==nil) {a_setf(res,fhd(res));}
  else {a_setf(res,cons(prognsymbol,nreversefn(env,res)));}
  a_return(res);
}

/*** Lisp parser interface ***/

oidtype parseLispForm(bindtype env, flexstream *fs)
     /* Parse Lisp form */
{
  oidtype res = readfn(env, fs->stream);

  if(res==osql_keyword) 
    return a_language_object("AmosQL"); /*backward compatibility*/
  return res;
}

void printLispResult(oidtype form)
     /* Print result of AmosQL evaluation */
{
  release(a_print(form));
  return;
}

void enterLispMode(flexstream *fs)
     /*** Switch from other language to Lisp ***/
{
  checkauth(AUTH_LISP);
  if(globval(_debugging_)==nil) globval(_debugging_)=autosymbol;
}

void leaveLispMode(flexstream *fs)
     /*** Switch from Lisp to other language ***/
{
  if(globval(_debugging_)==autosymbol) globval(_debugging_)=nil;
}

/*** AmosQL parser interface ***/

extern void yy_initialize_flexstream(flexstream *fs);
extern void yy_finalize_flexstream(flexstream *fs);
extern yy_switch_to_buffer(char *); /* from flex */
extern FILE *yyin;
extern int yyparse (void);

oidtype parseAmosQL(bindtype env, flexstream *fs)
     /* Parse query statement */
{
  oidtype stream = fs->stream;

  yyin = (FILE*)fs;
  yy_switch_to_buffer(fs->buffer);
  fs->function_flg = TRUE;
  yyparse();
  return parse_return;
}
 
void printAmosQLResult(oidtype form)
     /* Print result of AmosQL evaluation */
{
  release(call_lisp(print_amosql_result,topframe(),1,form));
  return;
}

/*** SQL parser interface ***/

extern void SQL_initialize_flexstream(flexstream *fs);
extern void SQL_finalize_flexstream(flexstream *fs);
extern SQL_switch_to_buffer(char *); /* from flex */
extern int SQLparse (void);
extern oidtype sql_statement;
extern FILE *SQLin;

oidtype parseSQL(bindtype env, flexstream *fs)
     /* Parse SQL statement */
{
  oidtype stream = fs->stream, res;

  SQLin = (FILE*)fs;
  SQL_switch_to_buffer(fs->buffer);
  SQLparse(); 
  res = sql_statement;
  return res;
}

void register_top(void)
{ 
  illegal_language = a_register_error("Illegal language");
  too_many_languages = a_register_error("Too many languages to parse");

  a_define_parser("AmosQL", parseAmosQL, printAmosQLResult,
                  yy_initialize_flexstream, yy_finalize_flexstream);
  a_define_parser("Lisp", parseLispForm, printLispResult, 
                  enterLispMode, leaveLispMode);
  a_define_parser("SQL", parseSQL, printAmosQLResult, 
                  SQL_initialize_flexstream, SQL_finalize_flexstream);

  extfunction3("parse-file",a_parse_filefn);
  extfunction3("parse-stream",a_parse_streamfn);
  extfunction3("parse",parsefn);

  _parsetrace_ = mksymbol("_parsetrace_");
  a_setf(globval(_parsetrace_),nil);
  eof_symbol = mksymbol("*eof*");
  prognsymbol = mksymbol("progn");
  autosymbol = mksymbol("auto");
  lispsymbol = mksymbol("lisp");
  osql_keyword = mksymbol(":osql");
  print_amosql_result = mksymbol("print-amosql-result");
  _within_lisp_ = mksymbol("*within-lisp*");
  no_result = mksymbol("no-result");
  _parse_error_message_ = mksymbol("parse-error-message");
  a_setf(globval(_parse_error_message_),new_textstream(512));
  _oidrefs_ = mksymbol("_oidrefs_");
  globval(_oidrefs_) = nil;
}

#ifdef __APPLE__
void yywrap(void){}
#endif
