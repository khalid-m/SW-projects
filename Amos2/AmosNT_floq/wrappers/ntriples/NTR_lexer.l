/*****************************************************************************
 * AMOS2
 *
 * Author: (c) 2009 Martynas Mickevicius, UDBL
 * $RCSfile: NTR_lexer.l,v $
 * $Revision: 1.2 $ $Date: 2010/02/21 21:52:18 $
 * $State: Exp $ $Locker:  $
 *
 * Description: A ntriples parser
 * Generate code by running: flex -PNTR -i NTR_lexer.l
 *
 ****************************************************************************/

%{
#include "amos.h"
#include "NTR_parser_tab.h"
#include <memory.h>
#define MAXLENGTH 4096

oidtype RDFResource1 = nil; // subject
oidtype RDFResource2 = nil; // predicate
oidtype RDFResource3 = nil; // object

unsigned int NTRerrno;      // Parser error number. Assigned in driver

char globalbuf[MAXLENGTH];  // stores strings for parser

#undef NTRwrap
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
{ \
    int c; flexstream *fs=(flexstream *)yyin; \
    c = a_getc(fs->stream); \
    if (c == '\r') c = ' '; \
    if (c == '\n' || fs->char_num>=MAXLENGTH) {fs->char_num = 0; };  \
        result = (c == EOF) ? YY_NULL : (buf[0] = c, 1); \
}

void NTRerror(char *s){ a_error(NTRerrno, mkstring(s), FALSE);};

#define TOK(name) {return name;}
#define STRTOK(name) { strcpy(globalbuf, yytext); return name;}
%}

%x sc_absoluteuri sc_string

%%

    /* symbols */

"."                 TOK(DOT)

"<"                 {
                        BEGIN(sc_absoluteuri);
                        TOK(LT);
                    }

<sc_absoluteuri>">" {
                        BEGIN(INITIAL);
                        TOK(GT);
                    }

"\""                {
                        BEGIN(sc_string);
                        TOK(QUO);
                    }

<sc_string>"\""     {
                        BEGIN(INITIAL);
                        TOK(QUO);
                    }

"_:"                TOK(UC)
"@"                 TOK(AT)
"^^"                TOK(DBLUP)
<<EOF>>             return EF;

    /* strings */

[A-Za-z][A-Za-z0-9-]*   STRTOK(NAME)

    /* ABSOLUTEURI token is
    *   sequence of anything until symbol > is found
    */

<sc_absoluteuri>[^>]+   STRTOK(ABSOLUTEURI)

    /* string token is:
    *   sequence of symbols ending with anything thats not \ and followed by "
    *   or
    *   sequence of symbols ending with \\ (double slash) and followed by "
    */

<sc_string>.*[^\\]/\"   |
<sc_string>.*\\\\/\"    STRTOK(STRING)

    /* whitespace */

\n          {}

[ \t\r\f]+  {}

    /* comments */

"#".*       {}

    /* anything else */

.           {
                NTRerror("syntax error, invalid character");
            }

%%

int NTRwrap()
{
    return 1;
}
